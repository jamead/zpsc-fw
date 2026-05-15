library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_smooth_linear_ramp is
end entity;

architecture sim of tb_smooth_linear_ramp is

  constant CLK_PERIOD : time := 10 ns;  -- 100 MHz clock

  signal clk           : std_logic := '0';
  signal reset         : std_logic := '0';
  signal tenkhz_trig   : std_logic := '0';
  signal mode          : std_logic_vector(1 downto 0) := "00";

  signal cur_setpt     : signed(19 downto 0) := (others => '0');
  signal new_setpt     : signed(19 downto 0) := (others => '0');

  signal linear_len    : std_logic_vector(31 downto 0) := (others => '0');
  signal curved_len    : std_logic_vector(31 downto 0) := (others => '0');

  signal dy            : signed(31 downto 0) := (others => '0');
  signal dy_per_pt     : signed(31 downto 0) := (others => '0');

  signal smooth_active : std_logic;
  signal rampout       : signed(19 downto 0);

begin

  --------------------------------------------------------------------------
  -- Unit Under Test
  --------------------------------------------------------------------------
  uut : entity work.smooth_linear_ramp
    port map (
      clk           => clk,
      reset         => reset,
      tenkhz_trig   => tenkhz_trig,
      mode          => mode,
      cur_setpt     => cur_setpt,
      new_setpt     => new_setpt,
      linear_len    => linear_len,
      curved_len    => curved_len,
      dy            => dy,
      dy_per_pt     => dy_per_pt,
      smooth_active => smooth_active,
      rampout       => rampout
    );


  --------------------------------------------------------------------------
  -- Clock generation
  --------------------------------------------------------------------------
  clk <= not clk after CLK_PERIOD / 2;


  --------------------------------------------------------------------------
  -- Generate fake 10 kHz trigger pulses
  --
  -- Real 10 kHz from 100 MHz would be one pulse every 10000 clocks.
  -- For simulation, this uses a much faster pulse rate so you do not
  -- need to simulate forever.
  --------------------------------------------------------------------------
  trig_proc : process
  begin
    tenkhz_trig <= '0';

    wait until reset = '0';
    wait for 100 ns;

    while true loop
      wait until rising_edge(clk);
      tenkhz_trig <= '1';

      wait until rising_edge(clk);
      tenkhz_trig <= '0';

      -- Shortened interval for simulation.
      -- Increase this to 100 us if you want true 10 kHz timing.
      wait for 1 us;
    end loop;
  end process;


  --------------------------------------------------------------------------
  -- Stimulus
  --------------------------------------------------------------------------
  stim_proc : process
  begin

    ------------------------------------------------------------------------
    -- Initial values
    ------------------------------------------------------------------------
    mode       <= "00";  -- smooth mode
    cur_setpt  <= to_signed(0, 20);
    new_setpt  <= to_signed(0, 20);

    linear_len <= std_logic_vector(to_unsigned(16000, 32));
    curved_len <= std_logic_vector(to_unsigned(1600, 32));


    -- Example fixed-point values using Q10.22 format:
    --
    -- dy = 0.2977272727 bits/sample
    -- dy_q = round(0.2977272727 * 2^22)
    --      = round(0.2977272727 * 4194304)
    --      = 1248759
    dy <= to_signed(1248759, 32);

    -- dy_per_pt = dy / curved_len
    -- curved_len = 1600
    -- dy_per_pt = 0.2977272727 / 1600
    --            = 0.0001860795 bits/sample/count
    --
    -- dy_per_pt_q = round(0.0001860795 * 2^22)
    --              = round(0.0001860795 * 4194304)
    --              = 781
    dy_per_pt <= to_signed(781, 32);




    ------------------------------------------------------------------------
    -- Reset
    ------------------------------------------------------------------------
    reset <= '1';
    wait for 200 ns;
    wait until rising_edge(clk);
    reset <= '0';

    wait for 5 us;

    ------------------------------------------------------------------------
    -- Trigger a ramp by changing new_setpt
    ------------------------------------------------------------------------
    
    cur_setpt  <= to_signed(0, 20);
    new_setpt <= to_signed(5240, 20);

    wait for 50 ms;

    ------------------------------------------------------------------------
    -- Change setpoint again later
    ------------------------------------------------------------------------
    
    dy <= to_signed(-1248759, 32);
    dy_per_pt <= to_signed(-781, 32);
    cur_setpt <= to_signed(5240,20); 
    new_setpt <= to_signed(0, 20);

    wait for 50 ms;

    ------------------------------------------------------------------------
    -- End simulation
    ------------------------------------------------------------------------
    report "Simulation finished." severity note;
    wait;

  end process;


  --------------------------------------------------------------------------
  -- Monitor useful outputs
  --------------------------------------------------------------------------
  monitor_proc : process(clk)
  begin
    if rising_edge(clk) then
      if tenkhz_trig = '1' then
        report
          "tenkhz_trig=1" &
          " smooth_active=" & std_logic'image(smooth_active) &
          " cur_setpt=" & integer'image(to_integer(cur_setpt)) &
          " new_setpt=" & integer'image(to_integer(new_setpt)) &
          " rampout=" & integer'image(to_integer(rampout));
      end if;
    end if;
  end process;

end architecture;
          
          
  


 
