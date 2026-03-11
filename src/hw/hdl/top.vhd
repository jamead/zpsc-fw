
library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.ALL;

library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
 
library desyrdl;
use desyrdl.common.all;
use desyrdl.pkg_pl_regs.all;

library xil_defaultlib;
use xil_defaultlib.psc_pkg.ALL;
 

library work;
use work.psc_pkg.ALL;


entity top is
generic(
    FPGA_VERSION			: integer := 1;
    SIM_MODE				: integer := 0
    );
  port (
    ddr_addr                : inout std_logic_vector ( 14 downto 0 );
    ddr_ba                  : inout std_logic_vector ( 2 downto 0 );
    ddr_cas_n               : inout std_logic;
    ddr_ck_n                : inout std_logic;
    ddr_ck_p                : inout std_logic;
    ddr_cke                 : inout std_logic;
    ddr_cs_n                : inout std_logic;
    ddr_dm                  : inout std_logic_vector ( 3 downto 0 );
    ddr_dq                  : inout std_logic_vector ( 31 downto 0 );
    ddr_dqs_n               : inout std_logic_vector ( 3 downto 0 );
    ddr_dqs_p               : inout std_logic_vector ( 3 downto 0 );
    ddr_odt                 : inout std_logic;
    ddr_ras_n               : inout std_logic;
    ddr_reset_n             : inout std_logic;
    ddr_we_n                : inout std_logic;
    fixed_io_ddr_vrn        : inout std_logic;
    fixed_io_ddr_vrp        : inout std_logic;
    fixed_io_mio            : inout std_logic_vector ( 53 downto 0 );
    fixed_io_ps_clk         : inout std_logic;
    fixed_io_ps_porb        : inout std_logic;
    fixed_io_ps_srstb       : inout std_logic;
    
    -- Regulator command bits
    rcom                    : out std_logic_vector(19 downto 0);
    
    --Regulator status
    rsts                    : in std_logic_vector(19 downto 0);
    
    -- 24 16-bit ADC Channels for monitoring (3 - ADS5868)
    mon_adc_rst            : out std_logic;
    mon_adc_cnv            : out std_logic;
    mon_adc_sck            : out std_logic;
    mon_adc_fs             : out std_logic; 
    mon_adc_busy           : in std_logic_vector(2 downto 0);
    mon_adc_sdo            : in std_logic_vector(2 downto 0);

    -- 8 20-bit ADC Channels for DCCT (8 - LTC2376)
    dcct_adc_cnv            : out std_logic;
    dcct_adc_sck            : out std_logic;
    dcct_adc_busy           : in std_logic_vector(3 downto 0);
    dcct_adc_sdo            : in std_logic_vector(3 downto 0);

   -- 4 18-bit DAC Channels (4 - AD5781)
    stpt_dac_sck            : out std_logic;
    stpt_dac_sync           : out std_logic_vector(1 downto 0);
    stpt_dac_sdo            : out std_logic_vector(3 downto 0);
     
    --sfp i2c
    sfp_sck                 : inout std_logic_vector(3 downto 0);
    sfp_sda                 : inout std_logic_vector(3 downto 0);
    sfp_leds                : out std_logic_vector(7 downto 0);
          
    -- Embedded Event Receiver
    gtx_evr_refclk_p        : in std_logic;
    gtx_evr_refclk_n        : in std_logic;
    gtx_evr_rx_p            : in std_logic;
    gtx_evr_rx_n            : in std_logic;
    
    --FOFB gigE interface
    gtx_gige_refclk_p       : in std_logic;
    gtx_gige_refclk_n       : in std_logic;
    gtx_gige_rx_p           : in std_logic_vector(1 downto 0);
    gtx_gige_rx_n           : in std_logic_vector(1 downto 0);
    gtx_gige_tx_p           : out std_logic_vector(1 downto 0);
    gtx_gige_tx_n           : out std_logic_vector(1 downto 0);
    
    --Trigger inputs
    trig                    : in std_logic_vector(3 downto 0);
    
    -- Programmable oscillator for EVR reference clock
    si570_sck               : inout std_logic;
    si570_sda               : inout std_logic;
      
    -- EEPROM for ip addr and mac & one wire interface
    onewire_sck             : inout std_logic;
    onewire_sda             : inout std_logic;
    
    --MAC ID eeprom (11AA02E48T)
    mac_id                  : inout std_logic;
   
    --  Front panel LED's
    fp_leds                 : out std_logic_vector(7 downto 0);
    
    -- Fan for picozed
    fan_ctrl                : out std_logic

  );
end top;
 

architecture behv of top is

   signal pl_reset              : std_logic;
   signal pl_resetn             : std_logic_vector(0 downto 0);
   signal pl_clk0               : std_logic;
   
   signal i2c0_scl_i            : std_logic;
   signal i2c0_scl_t            : std_logic;
   signal i2c0_scl_o            : std_logic;
   signal i2c0_sda_i            : std_logic;
   signal i2c0_sda_t            : std_logic;
   signal i2c0_sda_o            : std_logic;  
   
   signal i2c1_scl_i            : std_logic;
   signal i2c1_scl_t            : std_logic;
   signal i2c1_scl_o            : std_logic;
   signal i2c1_sda_i            : std_logic;
   signal i2c1_sda_t            : std_logic;
   signal i2c1_sda_o            : std_logic;     
   
   
   signal gtx_gige_refclk       : std_logic;
   signal gtx_evr_refclk        : std_logic;
   
   signal tenkhz_trig           : std_logic; 
   signal tenkhz_freq           : std_logic_vector(31 downto 0);  
   signal adc_done              : std_logic;   
 
   signal m_axi4_m2s            : t_pl_regs_m2s;
   signal m_axi4_s2m            : t_pl_regs_s2m;
 
   signal s_axi4_m2s            : t_pl_snapshot_axi4_m2s;
   signal s_axi4_s2m            : t_pl_snapshot_axi4_s2m;  
   signal ss_buf_stat           : t_snapshot_stat; 
   
   signal fault_params          : t_fault_params;
   signal fault_stat            : t_fault_stat;
       
   signal dcct_adcs             : t_dcct_adcs;
   signal dcct_adcs_ave         : t_dcct_adcs_ave;
   signal dcct_params           : t_dcct_adcs_params;

   signal mon_params            : t_mon_adcs_params;
   signal mon_adcs              : t_mon_adcs;
   signal mon_adcs_ave          : t_mon_adcs_ave;
   
   signal evr_params            : t_evr_params;
   signal evr_trigs             : t_evr_trigs;
   
   signal dig_cntrl             : t_dig_cntrl;
   signal dig_stat              : t_dig_stat;
   
   signal fofb_params           : t_fofb_params;
   signal fofb_stat             : t_fofb_stat;
   signal fofb_data             : t_fofb_data;
   
   signal accum_done            : std_logic_vector(3 downto 0);
   
   signal dac_cntrl             : t_dac_cntrl;
   signal dac_stat              : t_dac_stat;  
   signal pl_temp               : std_logic_vector(11 downto 0); 
   
   signal ioc_access_led        : std_logic;
   signal tenhz_datasend_led    : std_logic;

   signal sa_trig_stretch       : std_logic;

   signal ch34_dualmode         : std_logic;   
  
   --debug signals (connect to ila)
   attribute mark_debug                 : string;
   attribute mark_debug of pl_reset : signal is "true";
   attribute mark_debug of pl_resetn : signal is "true";
   attribute mark_debug of tenkhz_trig : signal is "true";
   attribute mark_debug of pl_temp: signal is "true";
   --attribute mark_debug of evr_params : signal is "true";
   --attribute mark_debug of evr_trigs : signal is "true";
   --attribute mark_debug of m_axi4_m2s      : signal is "true";
   --attribute mark_debug of m_axi4_s2m      : signal is "true";



begin

fan_ctrl <= '1';

fp_leds(0) <= tenhz_datasend_led;   
fp_leds(2) <= ioc_access_led;  
fp_leds(4) <= evr_trigs.onehz_trig_stretch; 
fp_leds(6) <= rcom(0) or rcom(4) or rcom(8) or rcom(12);  
fp_leds(1) <= tenkhz_trig; --'0';
fp_leds(3) <= '0';
fp_leds(5) <= '0';
fp_leds(7) <= '0';

sfp_leds(3 downto 0) <= "0000";
sfp_leds(4) <= evr_trigs.onehz_trig_stretch;
sfp_leds(7 downto 5) <= "000";


pl_reset <= not pl_resetn(0); 



fofb: entity work.fofb_top
  port map(
    pl_clk0 => pl_clk0,
    reset => pl_reset,
    gtrefclk_p => gtx_gige_refclk_p,
    gtrefclk_n => gtx_gige_refclk_n,   
    rxp => gtx_gige_rx_p,
    rxn => gtx_gige_rx_n,
    txp => gtx_gige_tx_p,
    txn => gtx_gige_tx_n,
    fofb_params => fofb_params,
    fofb_stat => fofb_stat,
	fofb_data => fofb_data 
);
  

-- reads 8 channels of DCCT ADC's
read_dcct_adcs: entity work.DCCT_ADC_module
  port map(
    clk => pl_clk0, 
    reset => pl_reset, 
    start => tenkhz_trig,  
    dcct_params => dcct_params,
    dcct_out => dcct_adcs, 
    sdi => dcct_adc_sdo, 
    cnv => dcct_adc_cnv, 
    sclk => dcct_adc_sck, 
    sdo => open,
	done => adc_done 
);


---- reads 24 channels of monitor ADC's
mon_adc_rst <= '0';
read_mon_adcs: entity work.adc_8ch_module
  port map(
    clk => pl_clk0, 
    reset => pl_reset, 
    start => tenkhz_trig, 
    mon_params => mon_params,  
    mon_adcs => mon_adcs,
    adc8c_sdo => mon_adc_sdo,
    adc8c_conv123 => mon_adc_cnv, 
    adc8c_fs123 => mon_adc_fs, 
    adc8c_sck123 => mon_adc_sck,
    done => open
);


write_dacs: entity work.dac_ctrlr
  port map(
    clk => pl_clk0,  
    reset => pl_reset, 
    tenkhz_trig => tenkhz_trig,
    fofb_data => fofb_data,
    dac_cntrl => dac_cntrl,
    dac_stat => dac_stat,  	
    sync => stpt_dac_sync,  
    sclk => stpt_dac_sck, 
    sdo => stpt_dac_sdo 	
);



fault_gen: entity work.fault_module
  port map(
    clk => pl_clk0,
    reset => pl_reset,
    tenkhz_trig => tenkhz_trig,
    fault_params => fault_params,
    dcct_adcs => dcct_adcs,
    mon_adcs => mon_adcs,
    dac_stat => dac_stat,
    rcom => rcom,
    rsts => rsts,
    fault_stat => fault_stat 
);  
    
    
--accumulator (not yet integrated)
accum: entity work.adc_accumulator_top
  port map(
    clk => pl_clk0,
    reset => pl_reset,
    start => adc_done, 
    dcct_params => dcct_params, 
    mon_params => mon_params,
    dcct_adcs => dcct_adcs,
    mon_adcs => mon_adcs,
    dcct_adcs_ave => dcct_adcs_ave,
    mon_adcs_ave => mon_adcs_ave,
    done => accum_done
);
    
    
--generates the 10KHz triggers
sroc_gen: entity work.tenkhz_gen 
  port map(
    clk => pl_clk0,  
    reset => pl_reset,  	  
    evr_trigs => evr_trigs,
    evr_params => evr_params,
    flt_10kHz => open,  
    tenkhz_freq => tenkhz_freq,
	tenkhz_trig => tenkhz_trig
    ); 
    
    
--PS digital inputs/outputs
dig_io: entity work.digio_logic
  port map(
    clk => pl_clk0,
    reset => pl_reset,
    tenkhz_trig => tenkhz_trig,
    ch34_dualmode => ch34_dualmode,
    fault => fault_stat,   
    rsts => rsts,
    rcom => rcom,
    dig_cntrl => dig_cntrl,
    dig_stat => dig_stat
);


--embedded event receiver
evr: entity work.evr_top 
  port map(
    sys_clk => pl_clk0,
    sys_rst => pl_reset,
    gtx_evr_refclk_p => gtx_evr_refclk_p,
    gtx_evr_refclk_n => gtx_evr_refclk_n,
    rx_p => gtx_evr_rx_p,
    rx_n => gtx_evr_rx_n,
    evr_params => evr_params,
    evr_trigs => evr_trigs
);	


--registers from/to ARM
ps_regs: entity work.ps_io
  generic map (
    FPGA_VERSION => FPGA_VERSION
    )
  port map (
    pl_clock => pl_clk0, 
    pl_reset => pl_reset, 
    m_axi4_m2s => m_axi4_m2s, 
    m_axi4_s2m => m_axi4_s2m,
    dcct_params => dcct_params,
    dcct_adcs => dcct_adcs_ave, 
    mon_adcs => mon_adcs_ave,
    mon_params => mon_params,
    dac_cntrl => dac_cntrl,
    dac_stat => dac_stat,
    ss_buf_stat => ss_buf_stat,
    evr_params => evr_params,
    evr_trigs => evr_trigs,
    dig_cntrl => dig_cntrl,
    dig_stat => dig_stat,
    fault_params => fault_params,
    fault_stat => fault_stat,
    fofb_params => fofb_params,
	fofb_stat => fofb_stat,
	tenkhz_freq => tenkhz_freq,
	ch34_dualmode => ch34_dualmode,
    ioc_access_led => ioc_access_led,
    tenhz_datasend_led => tenhz_datasend_led               
  );

    
--store snapshot data to DDR 
adc2ddr : entity work.axi4_write_adc
  port map (
    clk => pl_clk0,
    reset => pl_reset,
    trigger => tenkhz_trig, 
    s_axi4_m2s => s_axi4_m2s,
    s_axi4_s2m => s_axi4_s2m,
    dcct_adcs => dcct_adcs,
    mon_adcs => mon_adcs,
    dac_stat => dac_stat,
    ss_buf_stat => ss_buf_stat       
  );


sys: component system
  port map (
    ddr_addr(14 downto 0) => ddr_addr(14 downto 0),
    ddr_ba(2 downto 0) => ddr_ba(2 downto 0),
    ddr_cas_n => ddr_cas_n,
    ddr_ck_n => ddr_ck_n,
    ddr_ck_p => ddr_ck_p,
    ddr_cke => ddr_cke,
    ddr_cs_n => ddr_cs_n,
    ddr_dm(3 downto 0) => ddr_dm(3 downto 0),
    ddr_dq(31 downto 0) => ddr_dq(31 downto 0),
    ddr_dqs_n(3 downto 0) => ddr_dqs_n(3 downto 0),
    ddr_dqs_p(3 downto 0) => ddr_dqs_p(3 downto 0),
    ddr_odt => ddr_odt,
    ddr_ras_n => ddr_ras_n,
    ddr_reset_n => ddr_reset_n,
    ddr_we_n  => ddr_we_n,
    fixed_io_ddr_vrn => fixed_io_ddr_vrn,
    fixed_io_ddr_vrp => fixed_io_ddr_vrp,
    fixed_io_mio(53 downto 0) => fixed_io_mio(53 downto 0),
    fixed_io_ps_clk => fixed_io_ps_clk,
    fixed_io_ps_porb => fixed_io_ps_porb,
    fixed_io_ps_srstb => fixed_io_ps_srstb,
    iic_0_scl_i => i2c0_scl_i, 
    iic_0_scl_o => i2c0_scl_o, 
    iic_0_scl_t => i2c0_scl_t, 
    iic_0_sda_i => i2c0_sda_i, 
    iic_0_sda_o => i2c0_sda_o, 
    iic_0_sda_t => i2c0_sda_t,
    iic_1_scl_i => i2c1_scl_i, 
    iic_1_scl_o => i2c1_scl_o, 
    iic_1_scl_t => i2c1_scl_t, 
    iic_1_sda_i => i2c1_sda_i, 
    iic_1_sda_o => i2c1_sda_o, 
    iic_1_sda_t => i2c1_sda_t,   
    pl_clk0 => pl_clk0,
    pl_resetn => pl_resetn,  
    pl_temp => pl_temp,
    m_axi_araddr => m_axi4_m2s.araddr, 
    m_axi_arprot => m_axi4_m2s.arprot,
    m_axi_arready => m_axi4_s2m.arready,
    m_axi_arvalid => m_axi4_m2s.arvalid,
    m_axi_awaddr => m_axi4_m2s.awaddr,
    m_axi_awprot => m_axi4_m2s.awprot,
    m_axi_awready => m_axi4_s2m.awready,
    m_axi_awvalid => m_axi4_m2s.awvalid,
    m_axi_bready => m_axi4_m2s.bready,
    m_axi_bresp => m_axi4_s2m.bresp,
    m_axi_bvalid => m_axi4_s2m.bvalid,
    m_axi_rdata => m_axi4_s2m.rdata,
    m_axi_rready => m_axi4_m2s.rready,
    m_axi_rresp => m_axi4_s2m.rresp,
    m_axi_rvalid => m_axi4_s2m.rvalid,
    m_axi_wdata => m_axi4_m2s.wdata,
    m_axi_wready => m_axi4_s2m.wready,
    m_axi_wstrb => m_axi4_m2s.wstrb,
    m_axi_wvalid => m_axi4_m2s.wvalid,
    s_axi_awaddr => s_axi4_m2s.awaddr, 
    s_axi_awburst => s_axi4_m2s.awburst, 
    s_axi_awcache => s_axi4_m2s.awcache, 
    s_axi_awlen => s_axi4_m2s.awlen, 
    s_axi_awlock => s_axi4_m2s.awlock, 
    s_axi_awprot => s_axi4_m2s.awprot, 
    s_axi_awqos => s_axi4_m2s.awqos, 
    s_axi_awready => s_axi4_s2m.awready, 
    s_axi_awsize => s_axi4_m2s.awsize, 
    s_axi_awvalid => s_axi4_m2s.awvalid, 
    s_axi_bready => s_axi4_m2s.bready, 
    s_axi_bresp => s_axi4_s2m.bresp, 
    s_axi_bvalid => s_axi4_s2m.bvalid, 
    s_axi_wdata => s_axi4_m2s.wdata, 
    s_axi_wlast => s_axi4_m2s.wlast, 
    s_axi_wready => s_axi4_s2m.wready, 
    s_axi_wstrb => s_axi4_m2s.wstrb, 
    s_axi_wvalid => s_axi4_m2s.wvalid         
  );






-- tri-state buffers for i2c interface from PS to si570
i2c0_scl_buf : IOBUF port map (O=>i2c0_scl_i, IO=>si570_sck, I=>i2c0_scl_o, T=>i2c0_scl_t);
i2c0_sda_buf : IOBUF port map (O=>i2c0_sda_i, IO=>si570_sda, I=>i2c0_sda_o, T=>i2c0_sda_t);
       
i2c1_scl_buf : IOBUF port map (O=>i2c1_scl_i, IO=>onewire_sck, I=>i2c1_scl_o, T=>i2c1_scl_t);
i2c1_sda_buf : IOBUF port map (O=>i2c1_sda_i, IO=>onewire_sda, I=>i2c1_sda_o, T=>i2c1_sda_t);    
    
end behv;
