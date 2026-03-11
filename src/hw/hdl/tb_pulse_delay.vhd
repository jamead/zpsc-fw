-- Testbench for: signal_gate_after_delay
-- 100 MHz clk, active-high reset
--
-- Stimulus:
--   1) Apply reset
--   2) Run 1 kHz pulse train; verify sig_out stays low for first 50 ms after
--      the *first rising edge*, then sig_out follows sig_in
--   3) Stop pulse train (sig_in held low) for >50 ms; verify DUT rearms
--   4) Restart pulse train; verify it qualifies again the same way
--
-- NOTE: DELAY_COUNTS = 5_000_000 means ~50 ms @ 100 MHz and the sim will run
--       for hundreds of milliseconds. If you want a quicker sim, reduce
--       DELAY_COUNTS_SIM (e.g., 500_000 for 5 ms) and shorten the waits.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_pulse_delay is
end entity;

architecture tb of tb_pulse_delay is

  -- ===== Clock / timing =====
  constant CLK_PERIOD : time := 10 ns;  -- 100 MHz

  -- ===== DUT generic (set to 5_000_000 for 50 ms @ 100 MHz) =====
  constant DELAY_COUNTS_SIM : natural := 5_000_000;

  -- 1 kHz pulse train @ 100 MHz:
  -- period = 1 ms = 100,000 clocks; 50% duty = 50,000 clocks
  constant PULSE_PERIOD_CLKS : natural := 100_000;
  constant PULSE_HIGH_CLKS   : natural := 50_000;

  signal clk     : std_logic := '0';
  signal rst     : std_logic := '0';
  signal sig_in  : std_logic := '0';
  signal sig_out : std_logic;

  signal pulse_en : std_logic := '0';

  -- ===== Reference model state (to self-check DUT) =====
  signal ref_started   : std_logic := '0';
  signal ref_qualified : std_logic := '0';
  signal ref_qual_cnt  : unsigned(31 downto 0) := (others => '0');
  signal ref_low_cnt   : unsigned(31 downto 0) := (others => '0');
  signal ref_sig_in_d  : std_logic := '0';
  signal ref_sig_out   : std_logic := '0';

begin

  -- =========================
  -- DUT Instantiation
  -- =========================
  dut : entity work.pulse_delay
    generic map (
      DELAY_COUNTS => DELAY_COUNTS_SIM
    )
    port map (
      clk     => clk,
      rst     => rst,
      sig_in  => sig_in,
      sig_out => sig_out
    );

  -- =========================
  -- Clock generation
  -- =========================
  clk <= not clk after CLK_PERIOD/2;

  -- =========================
  -- 1 kHz pulse generator (synchronous to clk)
  -- =========================
  pulse_gen : process(clk)
    variable p_cnt : natural := 0;
  begin
    if rising_edge(clk) then
      if rst = '1' then
        p_cnt  := 0;
        sig_in <= '0';
      else
        if pulse_en = '1' then
          -- 50% duty-cycle pulse train
          if p_cnt < PULSE_HIGH_CLKS then
            sig_in <= '1';
          else
            sig_in <= '0';
          end if;

          if p_cnt = PULSE_PERIOD_CLKS - 1 then
            p_cnt := 0;
          else
            p_cnt := p_cnt + 1;
          end if;
        else
          -- disabled: hold low
          p_cnt  := 0;
          sig_in <= '0';
        end if;
      end if;
    end if;
  end process;

  -- =========================
  -- Reference model + checker
  -- =========================
  ref_and_check : process(clk)
    variable delay_u32      : unsigned(31 downto 0);
    variable delay_minus_1  : unsigned(31 downto 0);
    variable expected_out   : std_logic;
  begin
    if rising_edge(clk) then
      delay_u32     := to_unsigned(DELAY_COUNTS_SIM, 32);
      if DELAY_COUNTS_SIM = 0 then
        delay_minus_1 := (others => '0');
      else
        delay_minus_1 := to_unsigned(DELAY_COUNTS_SIM - 1, 32);
      end if;

      if rst = '1' then
        ref_started   <= '0';
        ref_qualified <= '0';
        ref_qual_cnt  <= (others => '0');
        ref_low_cnt   <= (others => '0');
        ref_sig_in_d  <= '0';
        ref_sig_out   <= '0';

      else
        -- register input for edge detect
        ref_sig_in_d <= sig_in;

        -- count continuous LOW time
        if sig_in = '0' then
          if ref_low_cnt /= delay_u32 then
            ref_low_cnt <= ref_low_cnt + 1;
          end if;
        else
          ref_low_cnt <= (others => '0');
        end if;

        -- if low long enough, disarm/rearm
        if (DELAY_COUNTS_SIM /= 0) and (ref_low_cnt >= delay_u32) then
          ref_started   <= '0';
          ref_qualified <= '0';
          ref_qual_cnt  <= (others => '0');
        end if;

        -- first rising edge starts qualification
        if (sig_in = '1' and ref_sig_in_d = '0') and (ref_started = '0') and (ref_qualified = '0') then
          ref_started  <= '1';
          ref_qual_cnt <= (others => '0');
        end if;

        -- qualify timer
        if (ref_started = '1') and (ref_qualified = '0') then
          if DELAY_COUNTS_SIM = 0 then
            ref_qualified <= '1';
          elsif ref_qual_cnt = delay_minus_1 then
            ref_qualified <= '1';
          else
            ref_qual_cnt <= ref_qual_cnt + 1;
          end if;
        end if;

        -- gate output
        if ref_qualified = '1' then
          ref_sig_out <= sig_in;
        else
          ref_sig_out <= '0';
        end if;
      end if;

      -- Checker: compare DUT output to reference each clock
      expected_out := ref_sig_out;
      assert sig_out = expected_out
        report "Mismatch: sig_out /= expected (ref_sig_out)"
        severity error;

    end if;
  end process;

  -- =========================
  -- Test sequence
  -- =========================
  stim : process
  begin
    -- Reset
    rst      <= '1';
    pulse_en <= '0';
    wait for 200 ns;
    rst <= '0';

    -- Start pulse train; let it run long enough to qualify + follow
    pulse_en <= '1';
    wait for 80 ms;  -- > 50 ms delay

    -- Stop pulses; hold low long enough to force rearm
    pulse_en <= '0';
    wait for 60 ms;  -- > 50 ms low => disarm

    -- Restart pulse train; should require delay again
    pulse_en <= '1';
    wait for 80 ms;

    -- Done
    pulse_en <= '0';
    wait for 1 ms;

    report "TB completed without assertion failures." severity note;
    wait;
  end process;

end architecture;


