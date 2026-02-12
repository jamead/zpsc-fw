library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.psc_pkg.all;

entity tb_digio_logic is
end entity;

architecture tb of tb_digio_logic is

  -- 100 MHz clock
  constant CLK_PERIOD : time := 10 ns;

  signal clk           : std_logic := '0';
  signal reset         : std_logic := '1';
  signal tenkhz_trig   : std_logic := '0';
  signal ch34_dualmode : std_logic := '0';

  signal fault     : t_fault_stat;
  signal rsts      : std_logic_vector(19 downto 0) := (others => '0');
  signal rcom      : std_logic_vector(19 downto 0);
  signal dig_cntrl : t_dig_cntrl;
  signal dig_stat  : t_dig_stat;

  -- Zero constants for clean init
  constant C_FAULT_ONECH_ZERO : t_fault_stat_onech := (
    live     => (others => '0'),
    lat      => (others => '0'),
    flt_trig => '0',
    err_trig => '0'
  );

  constant C_FAULT_ZERO : t_fault_stat := (
    ps1 => C_FAULT_ONECH_ZERO,
    ps2 => C_FAULT_ONECH_ZERO,
    ps3 => C_FAULT_ONECH_ZERO,
    ps4 => C_FAULT_ONECH_ZERO
  );

  constant C_DIG_CNTRL_ONECH_ZERO : t_dig_cntrl_onech := (
    on1          => '0',
    on2          => '0',
    on2_pulseenb => '0',
    reset        => '0',
    spare        => '0',
    park         => '0'
  );

  constant C_DIG_CNTRL_ZERO : t_dig_cntrl := (
    ps1 => C_DIG_CNTRL_ONECH_ZERO,
    ps2 => C_DIG_CNTRL_ONECH_ZERO,
    ps3 => C_DIG_CNTRL_ONECH_ZERO,
    ps4 => C_DIG_CNTRL_ONECH_ZERO
  );

  -- Helpers
  procedure wait_clks(n : natural) is
  begin
    for i in 1 to n loop
      wait until rising_edge(clk);
    end loop;
  end procedure;

begin

  -----------------------------------------------------------------------------
  -- Clock
  -----------------------------------------------------------------------------
  clk <= not clk after CLK_PERIOD/2;

  -----------------------------------------------------------------------------
  -- DUT
  -----------------------------------------------------------------------------
  dut : entity work.digio_logic
    port map (
      clk           => clk,
      reset         => reset,
      tenkhz_trig   => tenkhz_trig,
      ch34_dualmode => ch34_dualmode,
      fault         => fault,
      rsts          => rsts,
      rcom          => rcom,
      dig_cntrl     => dig_cntrl,
      dig_stat      => dig_stat
    );

  -----------------------------------------------------------------------------
  -- Stimulus + Checks
  -----------------------------------------------------------------------------
  stim : process
  begin
    -- Init
    fault     <= C_FAULT_ZERO;
    dig_cntrl <= C_DIG_CNTRL_ZERO;
    rsts      <= (others => '0');
    ch34_dualmode <= '0';
    tenkhz_trig <= '0';

    -- Reset
    reset <= '1';
    wait_clks(20);
    reset <= '0';
    wait_clks(20);

    ---------------------------------------------------------------------------
    -- 1) Check rsts -> dig_stat mapping (pure combinational)
    ---------------------------------------------------------------------------
    rsts <= (others => '0');

    -- PS1 inputs
    rsts(0)  <= '0'; -- ps1.acon
    rsts(1)  <= '0'; -- ps1.flt1
    rsts(2)  <= '0'; -- ps1.flt2
    rsts(3)  <= '0'; -- ps1.spare
    rsts(16) <= '0'; -- ps1.dcct_flt

    -- PS2 inputs
    rsts(4)  <= '0'; -- ps2.acon
    rsts(5)  <= '0'; -- ps2.flt1
    rsts(6)  <= '0'; -- ps2.flt2
    rsts(7)  <= '0'; -- ps2.spare
    rsts(17) <= '0'; -- ps2.dcct_flt

    -- PS3 inputs
    rsts(8)  <= '0'; -- ps3.acon
    rsts(9)  <= '0'; -- ps3.flt1
    rsts(10) <= '0'; -- ps3.flt2
    rsts(11) <= '0'; -- ps3.spare
    rsts(18) <= '0'; -- ps3.dcct_flt

    -- PS4 inputs
    rsts(12) <= '0'; -- ps4.acon
    rsts(13) <= '0'; -- ps4.flt1
    rsts(14) <= '0'; -- ps4.flt2
    rsts(15) <= '0'; -- ps4.spare
    rsts(19) <= '0'; -- ps4.dcct_flt

    wait_clks(2);

    -- Clear rsts
    rsts <= (others => '0');
    wait_clks(2);

    ---------------------------------------------------------------------------
    -- 2) Check direct rcom mappings for reset/spare/park bits
    ---------------------------------------------------------------------------
    dig_cntrl <= C_DIG_CNTRL_ZERO;

    -- Dualmode: ch34_dualmode=1
    ch34_dualmode <= '1';
    wait for 100 ms;

    --check 50 ms delay
    --dig_cntrl.ps3.on1 <= '1';
    --wait for 300 ms;
    --dig_cntrl.ps3.on1 <= '0';
    --wait for 300 ms;
    
    
    --check ch3_flt trips ch4_flt delay
    dig_cntrl.ps3.on1 <= '1';
    wait for 200 ms;
    fault.ps3.flt_trig <= '1';
    wait for 200 ms;
    dig_cntrl.ps3.on1 <= '0';
    wait for 10 ms;
    fault.ps3.flt_trig <= '0';

     wait for 300 ms;
   
 
   --check ch4_flt trips ch3_flt delay
    dig_cntrl.ps3.on1 <= '1';
    wait for 200 ms;
    fault.ps4.flt_trig <= '1';
    wait for 200 ms;
    dig_cntrl.ps3.on1 <= '0';
    wait for 10 ms;
    fault.ps3.flt_trig <= '0';    

   
     wait for 2000 ms;   
    
    
    
  end process;

end architecture;

