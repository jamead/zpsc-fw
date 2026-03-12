library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package psc_pkg is


type t_dig_cntrl_onech is record
  on1           : std_logic;
  on2           : std_logic;
  polarity      : std_logic;
  reset         : std_logic;
  spare         : std_logic;
  park          : std_logic;
end record;

type t_dig_cntrl is record
  ps1        : t_dig_cntrl_onech;
  ps2        : t_dig_cntrl_onech;
  ps3        : t_dig_cntrl_onech;
  ps4        : t_dig_cntrl_onech;
end record;

type t_dig_stat_onech is record
  acon       : std_logic;
  flt1       : std_logic;
  flt2       : std_logic;
  spare      : std_logic;
  dcct_flt   : std_logic;
end record;

type t_dig_stat is record
  ps1        : t_dig_stat_onech;
  ps2        : t_dig_stat_onech;
  ps3        : t_dig_stat_onech;
  ps4        : t_dig_stat_onech;
end record;



-- fault control parameters
type t_fault_params_onech is record
  clear           : std_logic;
  enable          : std_logic_vector(15 downto 0);
  ovc1_thresh     : std_logic_vector(19 downto 0); 
  ovc2_thresh     : std_logic_vector(19 downto 0);  
  ovv_thresh      : std_logic_vector(15 downto 0);  
  err1_thresh     : std_logic_vector(15 downto 0);  
  err2_thresh     : std_logic_vector(15 downto 0);  
  ignd_thresh     : std_logic_vector(15 downto 0);  
  ovc1_cntlim     : std_logic_vector(15 downto 0);  -- over current on DCCT1                    flt_reg(0)
  ovc2_cntlim     : std_logic_vector(15 downto 0);  -- over current on DCCT2                    flt_reg(1)
  ovv_cntlim      : std_logic_vector(15 downto 0);  -- over voltage on Voltage monitor          flt_reg(2)
  err1_cntlim     : std_logic_vector(15 downto 0);  -- PI Loop Error signal too large           flt_reg(3)
  err2_cntlim     : std_logic_vector(15 downto 0);  -- PI Loop Error glitch                     flt_reg(4)
  ignd_cntlim     : std_logic_vector(15 downto 0);  -- GND current too large                    flt_reg(5)
  dcct_cntlim     : std_logic_vector(15 downto 0);  -- Digital DCCT (Bipolar) fault Check       flt_reg(6)
  flt1_cntlim     : std_logic_vector(15 downto 0);  -- Bipolar supply fault (David wants live)  flt_reg(7)    
  flt2_cntlim     : std_logic_vector(15 downto 0);  -- Bipolar heartbeat                        flt_reg(8) 
  flt3_cntlim     : std_logic_vector(15 downto 0);  -- external interlock fault                 flt_reg(9) 
  on_cntlim       : std_logic_vector(15 downto 0);  -- ac_on_out - ac_on_in fault               flt_reg(10)
  heart_cntlim    : std_logic_vector(15 downto 0);  -- spare                                    flt_reg(11)
end record;

type t_fault_params is record
  ps1           : t_fault_params_onech;
  ps2           : t_fault_params_onech;
  ps3           : t_fault_params_onech;
  ps4           : t_fault_params_onech;
end record;


type t_fault_stat_onech is record
  live       : std_logic_vector(15 downto 0);
  lat        : std_logic_vector(15 downto 0);
  flt_trig   : std_logic;
  err_trig   : std_logic;
end record;

type t_fault_stat is record
  ps1           : t_fault_stat_onech;
  ps2           : t_fault_stat_onech;
  ps3           : t_fault_stat_onech;
  ps4           : t_fault_stat_onech;
end record;




type t_evr_params is record
   reset          : std_logic_vector(7 downto 0);
   nco_stepsize   : std_logic_vector(31 downto 0);
   inj_eventno    : std_logic_vector(7 downto 0);
   pm_eventno     : std_logic_vector(7 downto 0);
   onehz_eventno  : std_logic_vector(7 downto 0);
   tenhz_eventno  : std_logic_vector(7 downto 0);
   tenkhz_eventno : std_logic_vector(7 downto 0);
end record;

type t_evr_trigs is record
   rcvd_clk           : std_logic;
   tbt_trig           : std_logic; 
   fa_trig            : std_logic;  
   sa_trig            : std_logic; 
   onehz_trig         : std_logic;
   onehz_trig_stretch : std_logic;
   sa_trig_stretch    : std_logic;
   inj_trig           : std_logic;
   inj_trig_stretch   : std_logic;  
   pm_trig            : std_logic;
   onehz_freq         : std_logic_vector(31 downto 0);
   ts_s               : std_logic_vector(31 downto 0);
   ts_ns              : std_logic_vector(31 downto 0);
end record;  




-- DCCT ADC record types
type t_dcct_adcs_onech is record 
  dcct0          : signed(19 downto 0);
  dcct1          : signed(19 downto 0);  
end record;

type t_dcct_adcs is record
  ps1           : t_dcct_adcs_onech;
  ps2           : t_dcct_adcs_onech;
  ps3           : t_dcct_adcs_onech;
  ps4           : t_dcct_adcs_onech;
end record;

type t_dcct_adcs_params_onech is record  
  ave_mode        : std_logic_vector(1 downto 0);
  dcct0_gain      : signed(23 downto 0); --Q3.20 format
  dcct0_offset    : signed(19 downto 0);
  dcct1_gain      : signed(23 downto 0); --Q3.20 format
  dcct1_offset    : signed(19 downto 0);  
end record;

type t_dcct_adcs_params is record
  numbits_sel   : std_logic;   --0=18 bits, 1=20bits
  ps1           : t_dcct_adcs_params_onech;
  ps2           : t_dcct_adcs_params_onech;
  ps3           : t_dcct_adcs_params_onech;
  ps4           : t_dcct_adcs_params_onech;
end record;


type t_dcct_adcs_ave_onech is record
  dcct0         : signed(31 downto 0);
  dcct1         : signed(31 downto 0);
end record;

type t_dcct_adcs_ave is record
  ps1           : t_dcct_adcs_ave_onech;
  ps2           : t_dcct_adcs_ave_onech;
  ps3           : t_dcct_adcs_ave_onech;
  ps4           : t_dcct_adcs_ave_onech;
end record;



-- Monitor ADC record types
type t_mon_adcs_onech is record
  dacmon_raw    : signed(15 downto 0);
  dacmon_oc     : signed(15 downto 0);
  dacmon        : signed(15 downto 0);
  voltage_raw   : signed(15 downto 0);  
  voltage_oc    : signed(15 downto 0);  
  voltage       : signed(15 downto 0);
  ignd_raw      : signed(15 downto 0);  
  ignd_oc       : signed(15 downto 0);
  ignd          : signed(15 downto 0);
  spare_raw     : signed(15 downto 0);  
  spare_oc      : signed(15 downto 0);  
  spare         : signed(15 downto 0);
  ps_reg_raw    : signed(15 downto 0); 
  ps_reg_oc     : signed(15 downto 0);  
  ps_reg        : signed(15 downto 0); 
  ps_error_raw  : signed(15 downto 0); 
  ps_error_oc   : signed(15 downto 0);  
  ps_error      : signed(15 downto 0);
end record;

type t_mon_adcs is record
  ps1           : t_mon_adcs_onech;
  ps2           : t_mon_adcs_onech;
  ps3           : t_mon_adcs_onech;
  ps4           : t_mon_adcs_onech;
end record;


type t_mon_adcs_params_onech is record 
  dacmon_offset    : signed(15 downto 0);
  dacmon_gain      : signed(23 downto 0);    
  voltage_offset   : signed(15 downto 0);
  voltage_gain     : signed(23 downto 0); 
  ignd_offset      : signed(15 downto 0);
  ignd_gain        : signed(23 downto 0);   
  spare_offset     : signed(15 downto 0);
  spare_gain       : signed(23 downto 0);  
  ps_reg_offset    : signed(15 downto 0);
  ps_reg_gain      : signed(23 downto 0);   
  ps_error_offset  : signed(15 downto 0);
  ps_error_gain    : signed(23 downto 0);  
end record;


type t_mon_adcs_params is record
  numchan_sel   : std_logic;   --0=2channel, 1=4channel
  ps1           : t_mon_adcs_params_onech;
  ps2           : t_mon_adcs_params_onech;
  ps3           : t_mon_adcs_params_onech;
  ps4           : t_mon_adcs_params_onech;
end record;





type t_mon_adcs_ave_onech is record
  dacmon        : signed(31 downto 0);
  voltage       : signed(31 downto 0);
  ignd          : signed(31 downto 0);
  spare         : signed(31 downto 0);
  ps_reg        : signed(31 downto 0);
  ps_error      : signed(31 downto 0);
end record;

type t_mon_adcs_ave is record
  ps1           : t_mon_adcs_ave_onech;
  ps2           : t_mon_adcs_ave_onech;
  ps3           : t_mon_adcs_ave_onech;
  ps4           : t_mon_adcs_ave_onech;
end record;



-- DAC record types
type t_dac_stat_onech is record
  active                : std_logic;
  cur_addr              : std_logic_vector(15 downto 0);
  dac_setpt             : signed(19 downto 0);
end record;

type t_dac_stat is record
  ps1           : t_dac_stat_onech;
  ps2           : t_dac_stat_onech;
  ps3           : t_dac_stat_onech;
  ps4           : t_dac_stat_onech;
end record;


type t_dac_cntrl_onech is record 
  --DAC controls 
  setpoint            : signed(19 downto 0); 
  ramprun             : std_logic; 
  ramplen             : std_logic_vector(15 downto 0);
  gain                : signed(23 downto 0);  --Q3.20 format
  offset              : signed(19 downto 0);
  smooth_phaseinc     : signed(31 downto 0);
  --Control Register Bits 
  cntrl               : std_logic_vector(7 downto 0); 
  -- DPRAM for table
  dpram_addr          : std_logic_vector(15 downto 0);
  dpram_data          : std_logic_vector(19 downto 0);
  dpram_we            : std_logic;
  --Reset
  reset               : std_logic; 
  --mode  0=smooth ramp, 1=ramp table, 2=FOFB, 3=Jump Mode
  mode                : std_logic_vector(1 downto 0); 
end record; 

type t_dac_cntrl is record
  numbits_sel  : std_logic;   --0=18 bits, 1=20bits 
  numchan_sel  : std_logic;   --0=2channel, 1=4channel
  ps1           : t_dac_cntrl_onech;
  ps2           : t_dac_cntrl_onech;
  ps3           : t_dac_cntrl_onech;
  ps4           : t_dac_cntrl_onech;
end record;


type t_fofb_params is record
  ipaddr               : std_logic_vector(31 downto 0);
  ps1_addr             : std_logic_vector(15 downto 0);
  ps2_addr             : std_logic_vector(15 downto 0);
  ps3_addr             : std_logic_vector(15 downto 0);
  ps4_addr             : std_logic_vector(15 downto 0);
  ps1_scalefactor      : std_logic_vector(31 downto 0);
  ps2_scalefactor      : std_logic_vector(31 downto 0);  
  ps3_scalefactor      : std_logic_vector(31 downto 0);
  ps4_scalefactor      : std_logic_vector(31 downto 0);    
end record;


type t_fofb_stat is record
  packets_rcvd         : std_logic_vector(31 downto 0);
  command              : std_logic_vector(31 downto 0);
  nonce                : std_logic_vector(31 downto 0); 
  ps1_setpt_flt        : std_logic_vector(31 downto 0);
  ps2_setpt_flt        : std_logic_vector(31 downto 0);
  ps3_setpt_flt        : std_logic_vector(31 downto 0);
  ps4_setpt_flt        : std_logic_vector(31 downto 0); 
end record;

type t_fofb_data is record
  ps1_setpt            : signed(19 downto 0);
  ps2_setpt            : signed(19 downto 0);
  ps3_setpt            : signed(19 downto 0);
  ps4_setpt            : signed(19 downto 0);  
end record;



-- snapshot data (circular buffer) types
type t_snapshot_stat is record
  addr_ptr  : std_logic_vector(31 downto 0);
  tenkhzcnt : std_logic_vector(31 downto 0);
end record;


type t_pl_snapshot_axi4_m2s is record
  awaddr :  std_logic_vector(31 downto 0);
  awburst : std_logic_vector(1 downto 0);
  awcache : std_logic_vector(3 downto 0);
  awlen : std_logic_vector(7 downto 0);
  awlock : std_logic_vector(0 to 0);
  awprot : std_logic_vector(2 downto 0);
  awqos : std_logic_vector(3 downto 0);
  awsize : std_logic_vector(2 downto 0);
  awvalid : std_logic;
  wdata : std_logic_vector(31 downto 0);
  wlast : std_logic;
  wstrb : std_logic_vector(3 downto 0);
  wvalid : std_logic;
  bready : std_logic;
end record;



type t_pl_snapshot_axi4_s2m is record
  awready : std_logic;
  wready : std_logic;
  bresp : std_logic_vector(1 downto 0);
  bvalid : std_logic;
end record;




type t_udp_pkt is record                	              
  mac_src_addr        : std_logic_vector(47 downto 0);
  mac_dest_addr       : std_logic_vector(47 downto 0);
  mac_len_type        : std_logic_vector(15 downto 0);
  ip_ver              : std_logic_vector(3 downto 0);
  ip_ihl              : std_logic_vector(3 downto 0);
  ip_tos              : std_logic_vector(7 downto 0);
  ip_ident            : std_logic_vector(15 downto 0);
  ip_ttl              : std_logic_vector(7 downto 0); 
  ip_protocol         : std_logic_vector(7 downto 0);
  ip_flags            : std_logic_vector(2 downto 0);
  ip_fragoffset       : std_logic_vector(12 downto 0);                                                                     
  udp_src_port        : std_logic_vector(15 downto 0);
  udp_dest_port       : std_logic_vector(15 downto 0);
  header_checksum     : std_logic_vector(15 downto 0);
  total_len           : std_logic_vector(15 downto 0);
  ip_src_addr         : std_logic_vector(31 downto 0);
  ip_dest_addr        : std_logic_vector(31 downto 0);
  udp_len             : std_logic_vector(15 downto 0);
  udp_checksum        : std_logic_vector(15 downto 0);
  ps_ctrl_bits        : std_logic_vector(31 downto 0);
  fast_ps_id          : std_logic_vector(15 downto 0);
  readback_cmd        : std_logic_vector(15 downto 0); 
  nonce               : std_logic_vector(63 downto 0); 
end record;







--########################################################################
--                         Components
--########################################################################
component system is
  port (
    DDR_cas_n : inout STD_LOGIC;
    DDR_cke : inout STD_LOGIC;
    DDR_ck_n : inout STD_LOGIC;
    DDR_ck_p : inout STD_LOGIC;
    DDR_cs_n : inout STD_LOGIC;
    DDR_reset_n : inout STD_LOGIC;
    DDR_odt : inout STD_LOGIC;
    DDR_ras_n : inout STD_LOGIC;
    DDR_we_n : inout STD_LOGIC;
    DDR_ba : inout STD_LOGIC_VECTOR ( 2 downto 0 );
    DDR_addr : inout STD_LOGIC_VECTOR ( 14 downto 0 );
    DDR_dm : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_dq : inout STD_LOGIC_VECTOR ( 31 downto 0 );
    DDR_dqs_n : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_dqs_p : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    FIXED_IO_mio : inout STD_LOGIC_VECTOR ( 53 downto 0 );
    FIXED_IO_ddr_vrn : inout STD_LOGIC;
    FIXED_IO_ddr_vrp : inout STD_LOGIC;
    FIXED_IO_ps_srstb : inout STD_LOGIC;
    FIXED_IO_ps_clk : inout STD_LOGIC;
    FIXED_IO_ps_porb : inout STD_LOGIC;
    iic_0_scl_i : in STD_LOGIC;
    iic_0_scl_o : out STD_LOGIC;
    iic_0_scl_t : out STD_LOGIC;
    iic_0_sda_i : in STD_LOGIC;
    iic_0_sda_o : out STD_LOGIC;
    iic_0_sda_t : out STD_LOGIC; 
    iic_1_scl_i : in STD_LOGIC;
    iic_1_scl_o : out STD_LOGIC;
    iic_1_scl_t : out STD_LOGIC;
    iic_1_sda_i : in STD_LOGIC;
    iic_1_sda_o : out STD_LOGIC;
    iic_1_sda_t : out STD_LOGIC; 
    m_axi_awaddr : out STD_LOGIC_VECTOR ( 31 downto 0 );
    m_axi_awprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    m_axi_awvalid : out STD_LOGIC;
    m_axi_awready : in STD_LOGIC;
    m_axi_wdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    m_axi_wstrb : out STD_LOGIC_VECTOR ( 3 downto 0 );
    m_axi_wvalid : out STD_LOGIC;
    m_axi_wready : in STD_LOGIC;
    m_axi_bresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    m_axi_bvalid : in STD_LOGIC;
    m_axi_bready : out STD_LOGIC;
    m_axi_araddr : out STD_LOGIC_VECTOR ( 31 downto 0 );
    m_axi_arprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    m_axi_arvalid : out STD_LOGIC;
    m_axi_arready : in STD_LOGIC;
    m_axi_rdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    m_axi_rresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    m_axi_rvalid : in STD_LOGIC;
    m_axi_rready : out STD_LOGIC;
    s_axi_awaddr : in STD_LOGIC_VECTOR ( 31 downto 0 );
    s_axi_awburst : in STD_LOGIC_VECTOR ( 1 downto 0 );
    s_axi_awcache : in STD_LOGIC_VECTOR ( 3 downto 0 );
    s_axi_awlen : in STD_LOGIC_VECTOR ( 7 downto 0 );
    s_axi_awlock : in STD_LOGIC_VECTOR ( 0 to 0 );
    s_axi_awprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    s_axi_awqos : in STD_LOGIC_VECTOR ( 3 downto 0 );
    s_axi_awready : out STD_LOGIC;
    s_axi_awsize : in STD_LOGIC_VECTOR ( 2 downto 0 );
    s_axi_awvalid : in STD_LOGIC;
    s_axi_bready : in STD_LOGIC;
    s_axi_bresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    s_axi_bvalid : out STD_LOGIC;
    s_axi_wdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    s_axi_wlast : in STD_LOGIC;
    s_axi_wready : out STD_LOGIC;
    s_axi_wstrb : in STD_LOGIC_VECTOR ( 3 downto 0 );
    s_axi_wvalid : in STD_LOGIC;      
    pl_clk0 : out STD_LOGIC;
    pl_resetn : out STD_LOGIC_VECTOR(0 downto 0);
    pl_temp: out std_logic_vector(11 downto 0)
  );
  end component;
  
  

component timeofDayReceiver is
   port (
       clock        : in std_logic;
       reset        : in std_logic; 
       eventstream  : in std_logic_vector(7 downto 0);
       timestamp    : out std_logic_vector(63 downto 0); 
       seconds      : out std_logic_vector(31 downto 0); 
       offset       : out std_logic_vector(31 downto 0); 
       position     : out std_logic_vector(4 downto 0);
       eventclock   : out std_logic
 );
end component;


component EventReceiverChannel is 
    port (
       clock        : in std_logic;
       reset        : in std_logic;
       eventstream  : in std_logic_vector(7 downto 0); 
       myevent      : in std_logic_vector(7 downto 0);
       mydelay      : in std_logic_vector(31 downto 0); 
       mywidth      : in std_logic_vector(31 downto 0); 
       mypolarity   : in std_logic;
       trigger      : out std_logic 
);
end component;


component evr_gtx
 
port
(
    SYSCLK_IN                               : in   std_logic;
    SOFT_RESET_RX_IN                        : in   std_logic;
    DONT_RESET_ON_DATA_ERROR_IN             : in   std_logic;
    GT0_TX_FSM_RESET_DONE_OUT               : out  std_logic;
    GT0_RX_FSM_RESET_DONE_OUT               : out  std_logic;
    GT0_DATA_VALID_IN                       : in   std_logic;

    --_________________________________________________________________________
    --GT0  (X1Y0)
    --____________________________CHANNEL PORTS________________________________
    --------------------------------- CPLL Ports -------------------------------
    gt0_cpllfbclklost_out                   : out  std_logic;
    gt0_cplllock_out                        : out  std_logic;
    gt0_cplllockdetclk_in                   : in   std_logic;
    gt0_cpllreset_in                        : in   std_logic;
    -------------------------- Channel - Clocking Ports ------------------------
    gt0_gtrefclk0_in                        : in   std_logic;
    gt0_gtrefclk1_in                        : in   std_logic;
    ---------------------------- Channel - DRP Ports  --------------------------
    gt0_drpaddr_in                          : in   std_logic_vector(8 downto 0);
    gt0_drpclk_in                           : in   std_logic;
    gt0_drpdi_in                            : in   std_logic_vector(15 downto 0);
    gt0_drpdo_out                           : out  std_logic_vector(15 downto 0);
    gt0_drpen_in                            : in   std_logic;
    gt0_drprdy_out                          : out  std_logic;
    gt0_drpwe_in                            : in   std_logic;
    --------------------------- Digital Monitor Ports --------------------------
    gt0_dmonitorout_out                     : out  std_logic_vector(7 downto 0);
    --------------------- RX Initialization and Reset Ports --------------------
    gt0_eyescanreset_in                     : in   std_logic;
    gt0_rxuserrdy_in                        : in   std_logic;
    -------------------------- RX Margin Analysis Ports ------------------------
    gt0_eyescandataerror_out                : out  std_logic;
    gt0_eyescantrigger_in                   : in   std_logic;
    ------------------ Receive Ports - FPGA RX Interface Ports -----------------
    gt0_rxusrclk_in                         : in   std_logic;
    gt0_rxusrclk2_in                        : in   std_logic;
    ------------------ Receive Ports - FPGA RX interface Ports -----------------
    gt0_rxdata_out                          : out  std_logic_vector(15 downto 0);
    ------------------ Receive Ports - RX 8B/10B Decoder Ports -----------------
    gt0_rxdisperr_out                       : out  std_logic_vector(1 downto 0);
    gt0_rxnotintable_out                    : out  std_logic_vector(1 downto 0);
    --------------------------- Receive Ports - RX AFE -------------------------
    gt0_gtxrxp_in                           : in   std_logic;
    ------------------------ Receive Ports - RX AFE Ports ----------------------
    gt0_gtxrxn_in                           : in   std_logic;
    -------------- Receive Ports - RX Byte and Word Alignment Ports ------------
    gt0_rxcommadet_out                      : out  std_logic;
    --------------------- Receive Ports - RX Equalizer Ports -------------------
    gt0_rxdfelpmreset_in                    : in   std_logic;
    gt0_rxmonitorout_out                    : out  std_logic_vector(6 downto 0);
    gt0_rxmonitorsel_in                     : in   std_logic_vector(1 downto 0);
    --------------- Receive Ports - RX Fabric Output Control Ports -------------
    gt0_rxoutclk_out                        : out  std_logic;
    gt0_rxoutclkfabric_out                  : out  std_logic;
    ------------- Receive Ports - RX Initialization and Reset Ports ------------
    gt0_gtrxreset_in                        : in   std_logic;
    gt0_rxpmareset_in                       : in   std_logic;
    ------------------- Receive Ports - RX8B/10B Decoder Ports -----------------
    gt0_rxchariscomma_out                   : out  std_logic_vector(1 downto 0);
    gt0_rxcharisk_out                       : out  std_logic_vector(1 downto 0);
    -------------- Receive Ports -RX Initialization and Reset Ports ------------
    gt0_rxresetdone_out                     : out  std_logic;
    --------------------- TX Initialization and Reset Ports --------------------
    gt0_gttxreset_in                        : in   std_logic;


    --____________________________COMMON PORTS________________________________
     GT0_QPLLOUTCLK_IN  : in std_logic;
     GT0_QPLLOUTREFCLK_IN : in std_logic

);

end component;  
  
  
component gige_pcs_pma_rx is
generic (
    EXAMPLE_SIMULATION        : in integer := 01
          );
  port (
    gtrefclk_p : in  std_logic;                         
    gtrefclk_n : in  std_logic;                         
    gtrefclk_out : out std_logic;                         
    gtrefclk_bufg_out : out std_logic; 
    txp : out std_logic;                    -- Differential +ve of serial transmission from PMA to PMD.
    txn : out std_logic;                    -- Differential -ve of serial transmission from PMA to PMD.
    rxp : in std_logic;                     -- Differential +ve for serial reception from PMD to PMA.
    rxn : in std_logic;                     -- Differential -ve for serial reception from PMD to PMA.
    userclk_out : out std_logic;                        
    userclk2_out : out std_logic;                        
    rxuserclk_out : out std_logic;                        
    rxuserclk2_out : out std_logic;                        
    pma_reset_out : out std_logic;                           -- transceiver PMA reset signal
    mmcm_locked_out : out std_logic;                           -- MMCM Locked
    resetdone : out std_logic;
    independent_clock_bufg : in std_logic;                 
    gmii_txd : in std_logic_vector(7 downto 0);  -- Transmit data from client MAC.
    gmii_tx_en : in std_logic;                     -- Transmit control signal from client MAC.
    gmii_tx_er : in std_logic;                     -- Transmit control signal from client MAC.
    gmii_rxd : out std_logic_vector(7 downto 0); -- Received Data to client MAC.
    gmii_rx_dv : out std_logic;                    -- Received control signal to client MAC.
    gmii_rx_er : out std_logic;                    -- Received control signal to client MAC.
    gmii_isolate : out std_logic;                    -- Tristate control to electrically isolate GMII.
    configuration_vector : in std_logic_vector(4 downto 0);  -- Alternative to MDIO interface.
    an_interrupt : out std_logic;                    -- Interrupt to processor to signal that Auto-Negotiation has completed
    an_adv_config_vector : in std_logic_vector(15 downto 0); -- Alternate interface to program REG4 (AN ADV)
    an_restart_config : in std_logic;                     -- Alternate signal to modify AN restart bit in REG0
    status_vector : out std_logic_vector(15 downto 0); -- Core status.
    reset : in std_logic;                     -- Asynchronous reset for entire core.
    signal_detect : in std_logic;                      -- Input from PMD to indicate presence of optical input.
    gt0_qplloutclk_out : out std_logic;
    gt0_qplloutrefclk_out : out std_logic
   );
end component;  
  

component gige_pcs_pma_tx is
  generic
(
    EXAMPLE_SIMULATION                      : integer   := 0
);
      port(
      -- Transceiver Interface
      ---------------------


      gtrefclk                 : in  std_logic;                           -- Very high quality clock for GT transceiver.
      gtrefclk_bufg            : in  std_logic;
      
      txp                  : out std_logic;                    -- Differential +ve of serial transmission from PMA to PMD.
      txn                  : out std_logic;                    -- Differential -ve of serial transmission from PMA to PMD.
      rxp                  : in std_logic;                     -- Differential +ve for serial reception from PMD to PMA.
      rxn                  : in std_logic;                     -- Differential -ve for serial reception from PMD to PMA.
      resetdone                : out std_logic;                           -- The GT transceiver has completed its reset cycle
      cplllock                : out std_logic;                           -- The GT transceiver has completed its reset cycle
      mmcm_reset              : out std_logic;         
      txoutclk                 : out std_logic;                     
      rxoutclk                 : out std_logic;                     
      userclk                  : in  std_logic;                     
      userclk2                 : in  std_logic;                     
      rxuserclk                  : in  std_logic;                   
      rxuserclk2                 : in  std_logic;                   
      pma_reset                : in  std_logic;                           -- transceiver PMA reset signal
      mmcm_locked              : in  std_logic;                           -- MMCM Locked
      independent_clock_bufg : in std_logic;                   

      -- GMII Interface
      -----------------
      gmii_txd             : in std_logic_vector(7 downto 0);  -- Transmit data from client MAC.
      gmii_tx_en           : in std_logic;                     -- Transmit control signal from client MAC.
      gmii_tx_er           : in std_logic;                     -- Transmit control signal from client MAC.
      gmii_rxd             : out std_logic_vector(7 downto 0); -- Received Data to client MAC.
      gmii_rx_dv           : out std_logic;                    -- Received control signal to client MAC.
      gmii_rx_er           : out std_logic;                    -- Received control signal to client MAC.
      gmii_isolate         : out std_logic;                    -- Tristate control to electrically isolate GMII.

      -- Management: Alternative to MDIO Interface
      --------------------------------------------
      configuration_vector : in std_logic_vector(4 downto 0);  -- Alternative to MDIO interface.


      an_interrupt         : out std_logic;                    -- Interrupt to processor to signal that Auto-Negotiation has completed
      an_adv_config_vector : in std_logic_vector(15 downto 0); -- Alternate interface to program REG4 (AN ADV)
      an_restart_config    : in std_logic;                     -- Alternate signal to modify AN restart bit in REG0


      -- General IO's
      ---------------
      status_vector        : out std_logic_vector(15 downto 0); -- Core status.
      reset                : in std_logic;                     -- Asynchronous reset for entire core.
     
      signal_detect         : in std_logic;                      -- Input from PMD to indicate presence of optical input.
      gt0_qplloutclk_in      : in  std_logic;
      gt0_qplloutrefclk_in   : in  std_logic

      );
end component;




  

component dac_dpram IS
  port (
    clka : IN STD_LOGIC;
    wea : IN STD_LOGIC;  --_VECTOR(0 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(19 DOWNTO 0);
    clkb : IN STD_LOGIC;
    enb : IN STD_LOGIC;
    addrb : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    doutb : OUT STD_LOGIC_VECTOR(19 DOWNTO 0)
  );
END component;


component shift_ram IS
  PORT (
    D : IN STD_LOGIC_VECTOR(8 DOWNTO 0);
    CLK : IN STD_LOGIC;
    Q : OUT STD_LOGIC_VECTOR(8 DOWNTO 0)
  );
END component;




end package;
