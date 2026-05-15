library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_smooth_ramp is
end entity;

architecture tb of tb_smooth_ramp is

  -- Clock period (e.g., 100 MHz => 10 ns)
  constant clk_period : time := 10 ns;

  -- Signals
  signal clk         : std_logic := '0';
  signal reset       : std_logic := '0';
  signal tenkhz_trig : std_logic := '0';
  signal trig        : std_logic := '0';

  signal old_setpt   : signed(19 downto 0) := (others => '0');
  signal new_setpt   : signed(19 downto 0) := (others => '0');
  signal phase_inc   : signed(31 downto 0) := (others => '0');
  signal rampout     : signed(19 downto 0);

begin

  -- Clock generation
  clk_process: process
  begin
    clk <= '0';
    wait for clk_period / 2;
    clk <= '1';
    wait for clk_period / 2;
  end process;

  -- Instantiate DUT
  uut: entity work.smooth_ramp
    port map (
      clk         => clk,
      reset       => reset,
      tenkhz_trig => tenkhz_trig,
      trig        => trig,
      old_setpt   => old_setpt,
      new_setpt   => new_setpt,
      phase_inc   => phase_inc,
      rampout     => rampout
    );

  -- Stimulus process
  stim_proc: process
  begin
    -- Initial reset
    reset <= '1';
    wait for 100 ns;
    reset <= '0';

    -- Initialize input values
    old_setpt <= to_signed(2**19-1, 20); -- Start point
    new_setpt <= to_signed(-90000, 20);  -- End point
    

    -- N = (new_setpt - old_setpt) / RampRate
    -- phase inc = pi/4*2^29 / N 
    phase_inc <= to_signed(45000, 32);    -- Number of points

    wait for 1 ms;

    -- Trigger the ramp
    trig <= '1';
    wait for clk_period;
    trig <= '0';

    -- Generate tenkhz_trig every 100 us (10 kHz)
    for i in 0 to 100500 loop
      wait for 10 us;
      tenkhz_trig <= '1';
      wait for clk_period;
      tenkhz_trig <= '0';
    end loop;

    -- End simulation
    wait for 10000 ms;
    assert false report "Simulation complete" severity failure;
  end process;

end architecture;



 
