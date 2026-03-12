library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;


library work;
use work.psc_pkg.ALL;


entity fault_module is 
  port(
    clk             : in std_logic; 
    reset           : in std_logic; 
    tenkhz_trig     : in std_logic; 
    dig_cntrl       : in t_dig_cntrl;	
    fault_params    : in t_fault_params; 
    dcct_adcs       : in t_dcct_adcs; 
    mon_adcs        : in t_mon_adcs; 
    dac_stat        : in t_dac_stat;
    rcom            : in std_logic_vector(19 downto 0);
    rsts            : in std_logic_vector(19 downto 0); 
    fault_stat      : out t_fault_stat 
);	
end fault_module;

architecture behv of fault_module is	
		
  signal fault      : std_logic_vector(3 downto 0);
  signal error      : std_logic_vector(3 downto 0);


begin




ch1_faults: entity work.fault_block
  port map(
    clk => clk,
    reset => reset,
    tenkhz_trig => tenkhz_trig,
    fault_params => fault_params.ps1,
    dig_cntrl => dig_cntrl.ps1,
    dcct_adcs => dcct_adcs.ps1,
    mon_adcs => mon_adcs.ps1,
    fault1 => rsts(1),
    fault2 => rsts(2), 
    fault3 => rsts(3), 
    dcct_fault => rsts(16),
    ac_on_in => rsts(0), 
    ac_on_out => rcom(0), 
    park => rcom(16), 
    dac_setpoint => std_logic_vector(dac_stat.ps1.dac_setpt),
    evr_flt_in => '0',
    fault_stat => fault_stat.ps1  

);    


ch2_faults: entity work.fault_block
  port map(
    clk => clk,
    reset => reset,
    tenkhz_trig => tenkhz_trig,
    fault_params => fault_params.ps2,
    dig_cntrl => dig_cntrl.ps2,
    dcct_adcs => dcct_adcs.ps2,
    mon_adcs => mon_adcs.ps2,
    fault1 => rsts(5),
    fault2 => rsts(6), 
    fault3 => rsts(7), 
    dcct_fault => rsts(17), 
    ac_on_in => rsts(4), 
    ac_on_out => rcom(4), 
    park => rcom(16), 
    dac_setpoint => std_logic_vector(dac_stat.ps2.dac_setpt),
    evr_flt_in => '0',
    fault_stat => fault_stat.ps2
  
);    


ch3_faults: entity work.fault_block
  port map(
    clk => clk,
    reset => reset,
    tenkhz_trig => tenkhz_trig,
    fault_params => fault_params.ps3,
    dig_cntrl => dig_cntrl.ps3,
    dcct_adcs => dcct_adcs.ps3,
    mon_adcs => mon_adcs.ps3,
    fault1 => rsts(9),
    fault2 => rsts(10), 
    fault3 => rsts(11), 
    dcct_fault => rsts(18), 
    ac_on_in => rsts(8), 
    ac_on_out => rcom(8), 
    park => rcom(18), 
    dac_setpoint => std_logic_vector(dac_stat.ps3.dac_setpt),
    evr_flt_in => '0',
    fault_stat => fault_stat.ps3 
);    


ch4_faults: entity work.fault_block
  port map(
    clk => clk,
    reset => reset,
    tenkhz_trig => tenkhz_trig,
    dig_cntrl => dig_cntrl.ps4,
    fault_params => fault_params.ps4,
    dcct_adcs => dcct_adcs.ps4,
    mon_adcs => mon_adcs.ps4,
    fault1 => rsts(13),
    fault2 => rsts(14), 
    fault3 => rsts(15), 
    dcct_fault => rsts(19), 
    ac_on_in => rsts(12), 
    ac_on_out => rcom(12), 
    park => rcom(19), 
    dac_setpoint => std_logic_vector(dac_stat.ps4.dac_setpt),
    evr_flt_in => '0',
    fault_stat => fault_stat.ps4 
);    





end architecture; 
