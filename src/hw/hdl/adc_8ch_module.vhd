-------------------------------------------------------------------------------
-- Title         : ADC 8 Channel module
-------------------------------------------------------------------------------
-- File          : ADC_8CH_module.vhd
-- Author        : Thomas Chiesa tchiesa@bnl.gov
-- Created       : 07/19/2020
-------------------------------------------------------------------------------
-- Description:
-- This is the controller for the three 8 Channel ADS8568 ADCs. Gains
-- and offsets are applied
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Modification history:
-- 07/19/2020: created.


-- ADC Channel Mapping
-- ADC0.CH0 = PS1 DAC Setpoint
-- ADC0.CH1 = PS3 DAC Setpoint
-- ADC0.CH2 = PS2 DAC Setpoint
-- ADC0.CH3 = PS4 DAC Setpoint
-- ADC0.CH4 = PS1 Voltage Monitor
-- ADC0.CH5 = PS1 Spare Voltage Monitor
-- ADC0.CH6 = PS1 Gound Current Shunt Voltage Monitor
-- ADC0.CH7 = PS2 Voltage Monitor

-- ADC1.CH0 = PS2 Ground Current Shunt Voltage Monitor
-- ADC1.CH1 = PS3 Voltage Monitor
-- ADC1.CH2 = PS2 Spare Voltage Monitor
-- ADC1.CH3 = PS3 Ground Current Shunt Voltage Monitor
-- ADC1.CH4 = PS3 Spare Voltage Monitor
-- ADC1.CH5 = PS4 Gound Current Shunt Voltage Monitor
-- ADC1.CH6 = PS4 Voltage Monitor
-- ADC1.CH7 = PS4 Spare Voltage Monitor

-- ADC2.CH0 = PS1 Regulator Output
-- ADC2.CH1 = PS2 Regulator Output
-- ADC2.CH2 = PS1 Error 
-- ADC2.CH3 = PS2 Error
-- ADC2.CH4 = PS3 Regulator Output
-- ADC2.CH5 = PS4 Regulator Output
-- ADC2.CH6 = PS3 Error
-- ADC2.CH7 = PS4 Error



-------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.psc_pkg.all;


entity adc_8ch_module is
	port(
		 clk           : in std_logic;
		 reset         : in std_logic;
		 start         : in std_logic;
		 mon_adcs      : out t_mon_adcs;
		 mon_params    : in t_mon_adcs_params;
		 ADC8C_SDO     : in std_logic_vector(2 downto 0);
		 ADC8C_CONV123 : out std_logic;
		 ADC8C_FS123   : out std_logic;
		 ADC8C_SCK123  : out std_logic;
		 done          : out std_logic
	);
end entity;


architecture arch of adc_8ch_module is
signal ADC_8CH_ADC1     : std_logic_vector(127 downto 0);
signal ADC_8CH_ADC2     : std_logic_vector(127 downto 0);
signal ADC_8CH_ADC3     : std_logic_vector(127 downto 0);
signal conv_done        : std_logic;
signal done_pipe        : std_logic;
signal mon_adcs_in      : t_mon_adcs;
signal count            : signed(15 downto 0);


   --debug signals (connect to ila)
   attribute mark_debug                 : string;
   attribute mark_debug of count: signal is "true";
--   attribute mark_debug of ADC8C_CONV123: signal is "true";
--   attribute mark_debug of ADC8C_FS123: signal is "true";
--   attribute mark_debug of ADC8C_SCK123: signal is "true";
--   attribute mark_debug of ADC8C_SDO: signal is "true";
--   attribute mark_debug of ADC_8CH_ADC1: signal is "true";
--   attribute mark_debug of ADC_8CH_ADC2: signal is "true";
--   attribute mark_debug of ADC_8CH_ADC3: signal is "true";       
--   attribute mark_debug of mon_adcs_in: signal is "true";


begin


process(clk)
begin 
  if rising_edge(clk) then
    if (reset = '1') then
      count <= 16d"0";
    else
      if (start = '1') then
        count <= count + 1;
      end if;
    end if;
  end if;
end process;



adc1_8ch: entity work.adc_ads8568_intf
  generic map(DATA_BITS   => 128,	SPI_CLK_DIV => 5)
  port map(
	clk => clk,
	reset => reset,
	start => start,
	busy => '0',
	sdi => ADC8C_SDO(0), --ADC8C_MISO1,
	cnv => ADC8C_CONV123,
	n_fs => ADC8C_FS123,
	sclk => ADC8C_SCK123,
	sdo => open,
	data_out => ADC_8CH_ADC1,
	data_rdy => conv_done
);


adc2_8ch: entity work.adc_ads8568_intf
  generic map(DATA_BITS   => 128, SPI_CLK_DIV => 5)
    port map(
      clk => clk,
      reset => reset,
      start => start,
      busy => '0',
      sdi => ADC8C_SDO(1), --ADC8C_MISO2,
      cnv => open,
      n_fs => open,
      sclk => open,
      sdo => open,
      data_out => ADC_8CH_ADC2,
      data_rdy => open
);


adc3_8ch: entity work.adc_ads8568_intf
  generic map(DATA_BITS   => 128, SPI_CLK_DIV => 5)
  port map(
    clk       => clk,
    reset     => reset,
    start     => start,
    busy      => '0',
    sdi       => ADC8C_SDO(2), --ADC8C_MISO3,
    cnv       => open,
    n_fs      => open,
    sclk      => open,
    sdo       => open,
    data_out  => ADC_8CH_ADC3,
    data_rdy  => open
);


process(clk) 
  begin 
	if rising_edge(clk) then 
      if (mon_params.numchan_sel = '1') then  
        -- 4 channel mapping
        -- mapping from phyical to logical adc channels
        mon_adcs_in.ps1.dacmon_raw <= signed(ADC_8CH_ADC1(127 downto 112));  -- A0-1
        mon_adcs_in.ps3.dacmon_raw <= signed(ADC_8CH_ADC1(111 downto 96));   -- A1-1
        mon_adcs_in.ps2.dacmon_raw <= signed(ADC_8CH_ADC1(95 downto 80));    -- B0-1
        mon_adcs_in.ps4.dacmon_raw <= signed(ADC_8CH_ADC1(79 downto 64));    -- B1-1
        mon_adcs_in.ps1.voltage_raw <= signed(ADC_8CH_ADC1(63 downto 48));   -- C0-1
        mon_adcs_in.ps1.spare_raw <= signed(ADC_8CH_ADC1(47 downto 32));     -- C1-1
        mon_adcs_in.ps1.ignd_raw <= signed(ADC_8CH_ADC1(31 downto 16));      -- D0-1
        mon_adcs_in.ps2.voltage_raw <= signed(ADC_8CH_ADC1(15 downto 0));    -- D1-1

        mon_adcs_in.ps2.ignd_raw <= signed(ADC_8CH_ADC2(127 downto 112));    -- A0-2
        mon_adcs_in.ps3.voltage_raw <= signed(ADC_8CH_ADC2(111 downto 96));  -- A1-2
        mon_adcs_in.ps2.spare_raw <= signed(ADC_8CH_ADC2(95 downto 80));     -- B0-2
        mon_adcs_in.ps3.ignd_raw <= signed(ADC_8CH_ADC2(79 downto 64));      -- B1-2
        mon_adcs_in.ps3.spare_raw <= signed(ADC_8CH_ADC2(63 downto 48));     -- C0-2
        mon_adcs_in.ps4.ignd_raw <= signed(ADC_8CH_ADC2(47 downto 32));      -- C1-2
        mon_adcs_in.ps4.voltage_raw <= signed(ADC_8CH_ADC2(31 downto 16));   -- D0-2
        mon_adcs_in.ps4.spare_raw <= signed(ADC_8CH_ADC2(15 downto 0));      -- D1-2

        mon_adcs_in.ps1.ps_reg_raw <= signed(ADC_8CH_ADC3(127 downto 112));  -- A0-3
        mon_adcs_in.ps2.ps_reg_raw <= signed(ADC_8CH_ADC3(111 downto 96));   -- A1-3
        mon_adcs_in.ps1.ps_error_raw <= signed(ADC_8CH_ADC3(95 downto 80));  -- B0-3
        mon_adcs_in.ps2.ps_error_raw <= signed(ADC_8CH_ADC3(79 downto 64));  -- B1-3
        mon_adcs_in.ps3.ps_reg_raw <= signed(ADC_8CH_ADC3(63 downto 48));    -- C0-3
        mon_adcs_in.ps4.ps_reg_raw <= signed(ADC_8CH_ADC3(47 downto 32));    -- C1-3
        mon_adcs_in.ps3.ps_error_raw <= signed(ADC_8CH_ADC3(31 downto 16));  -- D0-3
        mon_adcs_in.ps4.ps_error_raw <= signed(ADC_8CH_ADC3(15 downto 0));   -- D1-3
    else
         -- 2 channel mapping
        -- mapping from phyical to logical adc channels
        mon_adcs_in.ps1.dacmon_raw <= signed(ADC_8CH_ADC1(127 downto 112));  -- A0-1
        mon_adcs_in.ps1.voltage_raw <= signed(ADC_8CH_ADC1(111 downto 96));  -- A1-1
        mon_adcs_in.ps2.dacmon_raw <= signed(ADC_8CH_ADC1(95 downto 80));    -- B0-1
        mon_adcs_in.ps1.ignd_raw <= signed(ADC_8CH_ADC1(79 downto 64));      -- B1-1
        mon_adcs_in.ps1.spare_raw <= signed(ADC_8CH_ADC1(63 downto 48));     -- C0-1
        mon_adcs_in.ps2.voltage_raw <= signed(ADC_8CH_ADC1(47 downto 32));   -- C1-1

        mon_adcs_in.ps2.ignd_raw <= signed(ADC_8CH_ADC2(127 downto 112));    -- A0-2
        mon_adcs_in.ps1.ps_reg_raw <= signed(ADC_8CH_ADC2(111 downto 96));   -- A1-2
        mon_adcs_in.ps2.spare_raw <= signed(ADC_8CH_ADC2(95 downto 80));     -- B0-2
        mon_adcs_in.ps1.ps_error_raw <= signed(ADC_8CH_ADC2(79 downto 64));  -- B1-2
        mon_adcs_in.ps2.ps_reg_raw <= signed(ADC_8CH_ADC2(63 downto 48));    -- C0-2
        mon_adcs_in.ps2.ps_error_raw <= signed(ADC_8CH_ADC2(47 downto 32));  -- C1-2
     
        mon_adcs_in.ps3.dacmon_raw <= (others => '0');
        mon_adcs_in.ps3.voltage_raw <= (others => '0');
        mon_adcs_in.ps3.ignd_raw <= (others => '0');
        mon_adcs_in.ps3.spare_raw <= (others => '0');       
        mon_adcs_in.ps3.ps_reg_raw <= (others => '0');
        mon_adcs_in.ps3.ps_error_raw <= (others => '0');  
        
        mon_adcs_in.ps4.dacmon_raw <= (others => '0');
        mon_adcs_in.ps4.voltage_raw <= (others => '0');
        mon_adcs_in.ps4.ignd_raw <= (others => '0');
        mon_adcs_in.ps4.spare_raw <= (others => '0');       
        mon_adcs_in.ps4.ps_reg_raw <= (others => '0');
        mon_adcs_in.ps4.ps_error_raw <= (others => '0');               
        
    end if;
  end if;
end process;
 
    


-- apply gains and offsets
gainoff_ps1: entity work.mon_gainoffset
  port map(
    clk => clk,
    reset => reset,
    conv_done => conv_done,
    mon_adc => mon_adcs_in.ps1,
    mon_params => mon_params.ps1,
    mon_out => mon_adcs.ps1,
    done => done
);

-- apply gains and offsets
gainoff_ps2: entity work.mon_gainoffset
  port map(
    clk => clk,
    reset => reset,
    conv_done => conv_done,
    mon_adc => mon_adcs_in.ps2,
    mon_params => mon_params.ps2,
    mon_out => mon_adcs.ps2,
    done => done
);

-- apply gains and offsets
gainoff_ps3: entity work.mon_gainoffset
  port map(
    clk => clk,
    reset => reset,
    conv_done => conv_done,
    mon_adc => mon_adcs_in.ps3,
    mon_params => mon_params.ps3,
    mon_out => mon_adcs.ps3,
    done => done
);

-- apply gains and offsets
gainoff_ps4: entity work.mon_gainoffset
  port map(
    clk => clk,
    reset => reset,
    conv_done => conv_done,
    mon_adc => mon_adcs_in.ps4,
    mon_params => mon_params.ps4,
    mon_out => mon_adcs.ps4,
    done => done
);




end architecture;
