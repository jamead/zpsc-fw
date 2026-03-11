-- Delays the 1ms ON1 pulse delay for 50ms.
-- On1 is a 1KHz pulse. 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pulse_delay is
  generic (
    DELAY_COUNTS : natural := 5_000_000  -- 50 ms @ 100 MHz
  );
  port (
    clk     : in  std_logic;  -- 100 MHz
    rst     : in  std_logic;  -- active-high
    sig_in  : in  std_logic;  -- 1 kHz pulse (assumed synchronous to clk)
    sig_out : out std_logic
  );
end entity;

architecture rtl of pulse_delay is

  signal qual_cnt  : unsigned(31 downto 0) := (others => '0');
  signal low_cnt   : unsigned(31 downto 0) := (others => '0');

  signal started   : std_logic := '0';
  signal qualified : std_logic := '0';

  signal sig_in_d  : std_logic := '0';  -- for rising-edge detect

begin

  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        qual_cnt  <= (others => '0');
        low_cnt   <= (others => '0');
        started   <= '0';
        qualified <= '0';
        sig_in_d  <= '0';
        sig_out   <= '0';

      else
        -- register input for edge detect
        sig_in_d <= sig_in;

        -- count continuous LOW time (re-arm logic)
        if sig_in = '0' then
          if low_cnt /= to_unsigned(DELAY_COUNTS, 32) then
            low_cnt <= low_cnt + 1;
          end if;
        else
          low_cnt <= (others => '0');
        end if;

        -- if input has been LOW long enough, disarm so we can trigger again
        if (DELAY_COUNTS /= 0) and (low_cnt >= to_unsigned(DELAY_COUNTS, 32)) then
          started   <= '0';
          qualified <= '0';
          qual_cnt  <= (others => '0');
        end if;

        -- detect rising edge to start qualification (only when disarmed)
        if (sig_in = '1' and sig_in_d = '0') and (started = '0') and (qualified = '0') then
          started  <= '1';
          qual_cnt <= (others => '0');
        end if;

        -- run qualify timer once started
        if (started = '1') and (qualified = '0') then
          if (DELAY_COUNTS = 0) then
            qualified <= '1';
          elsif qual_cnt = to_unsigned(DELAY_COUNTS - 1, 32) then
            qualified <= '1';
          else
            qual_cnt <= qual_cnt + 1;
          end if;
        end if;

        -- output gating
        if qualified = '1' then
          sig_out <= sig_in;   -- follow pulse train
        else
          sig_out <= '0';      -- hold low until qualified
        end if;

      end if;
    end if;
  end process;

end architecture;

