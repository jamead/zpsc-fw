-------------------------------------------------------------------------------
-- Title         : DAC Controller
-------------------------------------------------------------------------------
-- File          : DAC_ctrlr.vhd
-- Author        : Thomas Chiesa tchiesa@bnl.gov
-- Created       : 07/19/2020
-------------------------------------------------------------------------------
-- Description:
-- This program is the DAC controller for the PSC.  It controls all
-- four DACs on the PSC. 
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Modification history:
-- 07/19/2020: created.
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.psc_pkg.all;



entity dac_ctrlr is
  port(
    clk                  : in std_logic; 
    reset                : in std_logic; 
    tenkhz_trig          : in std_logic;
    dig_cntrl            : in t_dig_cntrl;
    fofb_data            : in t_fofb_data;
    dac_cntrl            : in t_dac_cntrl;
    dac_stat             : out t_dac_stat;
    sync    		     : out std_logic_vector(1 downto 0); 
    sclk     		     : out std_logic; 
    sdo                  : out std_logic_vector(3 downto 0)	
    );
end entity;

architecture arch of dac_ctrlr is

   signal rampout       : signed(19 downto 0);

   --debug signals (connect to ila)
   attribute mark_debug: string;   
   attribute mark_debug of tenkhz_trig: signal is "true";
   attribute mark_debug of rampout: signal is "true";



begin


dac1: entity work.dac_chan
  port map (
    clk  => clk,
    reset => reset,
    tenkhz_trig => tenkhz_trig,
    dig_cntrl => dig_cntrl.ps1,
    fofb_dac_setpt => fofb_data.ps1_setpt,
    dac_numbits_sel => dac_cntrl.numbits_sel,
    dac_cntrl => dac_cntrl.ps1,
    dac_stat => dac_stat.ps1,
    n_sync1234 => sync(0),
    sclk1234 => sclk,
    sdo => sdo(0)
  );


dac2: entity work.dac_chan
  port map (
    clk => clk,
    reset => reset,
    tenkhz_trig => tenkhz_trig,
    dig_cntrl => dig_cntrl.ps2,
    fofb_dac_setpt => fofb_data.ps2_setpt,    
    dac_numbits_sel => dac_cntrl.numbits_sel,    
    dac_cntrl => dac_cntrl.ps2,
    dac_stat => dac_stat.ps2,
    n_sync1234 => sync(1), 
    sclk1234 => open, 
    sdo => sdo(1)
  );

dac3: entity work.dac_chan
  port map (
    clk => clk,
    reset => reset,
    tenkhz_trig => tenkhz_trig,
    dig_cntrl => dig_cntrl.ps3,
    fofb_dac_setpt => fofb_data.ps3_setpt,    
    dac_numbits_sel => dac_cntrl.numbits_sel,   
    dac_cntrl => dac_cntrl.ps3,
    dac_stat => dac_stat.ps3,
    n_sync1234 => open, 
    sclk1234 => open, 
    sdo => sdo(2)
  );

dac4: entity work.dac_chan
  port map (
    clk => clk,
    reset => reset,
    tenkhz_trig => tenkhz_trig,
    dig_cntrl => dig_cntrl.ps4, 
    fofb_dac_setpt => fofb_data.ps4_setpt,   
    dac_numbits_sel => dac_cntrl.numbits_sel,
    dac_cntrl => dac_cntrl.ps4,
    dac_stat => dac_stat.ps4,
    n_sync1234 => open,
    sclk1234 => open,
    sdo => sdo(3)
  );



    




end arch;
