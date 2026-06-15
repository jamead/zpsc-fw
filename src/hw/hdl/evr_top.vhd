
-- The evr_top module is a top-level entity for an Event Receiver (EVR) system, 
-- designed to decode timing and control events in a high-precision timing environment. 
-- The design leverages Gigabit Transceiver (GTX) functionality for data reception 


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;

library work;
use work.psc_pkg.ALL;


entity evr_top is
   port(

    sys_clk          : in std_logic;
    sys_rst          : in std_logic; 
    gtx_evr_refclk_p : in std_logic; 
    gtx_evr_refclk_n : in std_logic;
    rx_p             : in std_logic;
    rx_n             : in std_logic; 
    evr_params       : in t_evr_params;
    evr_trigs        : out t_evr_trigs
   
);
end evr_top;
 
 
architecture behv of evr_top is
	


   type  state_type is (IDLE, ACTIVE);  
   signal state :  state_type;
   
   signal gtx_refclk        : std_logic;

   signal datastream        : std_logic_vector(7 downto 0);
   signal eventstream       : std_logic_vector(7 downto 0);
   
   signal timestamp         : std_logic_vector(63 downto 0);
   signal rxdata            : std_logic_vector(15 downto 0);
   signal rxcharisk         : std_logic_vector(1 downto 0);
   signal rxout_clk         : std_logic;   
   signal rxusr_clk         : std_logic;
   signal rxresetdone       : std_logic;
         
   signal cpllfbcklost         : std_logic;
   signal cplllock             : std_logic;

   
   signal tx_fsm_reset_done : std_logic;
   signal rx_fsm_reset_done : std_logic;   
   
   signal eventclock        : std_logic;
   
   signal prev_datastream   : std_logic_vector(3 downto 0);
   signal tbt_trig_i        : std_logic;
   signal tbt_trig_stretch  : std_logic;
   signal tbt_cnt           : std_logic_vector(2 downto 0);
   signal inj_trig          : std_logic;
   signal inj_trig_sync     : std_logic_vector(1 downto 0);
   signal onehz_trig        : std_logic;
   signal onehz_trig_sync   : std_logic_vector(2 downto 0);   
   signal onehz_rate_cnt    : std_logic_vector(31 downto 0);
   


   --debug signals (connect to ila)
--   attribute mark_debug     : string;
--   attribute mark_debug of eventstream: signal is "true";
--   attribute mark_debug of datastream: signal is "true";
--   attribute mark_debug of evr_trigs: signal is "true";
--   attribute mark_debug of evr_params: signal is "true";
--   attribute mark_debug of onehz_trig: signal is "true";
--   attribute mark_debug of onehz_trig_sync: signal is "true";   
   
--   attribute mark_debug of onehz_rate_cnt: signal is "true";
--   attribute mark_debug of evr_trigs: signal is "true";
--   attribute mark_debug of evr_params: signal is "true";  
   
----   attribute mark_debug of inj_trig: signal is "true";
----   attribute mark_debug of inj_trig_sync: signal is "true";
   
----   attribute mark_debug of timestamp: signal is "true";
------   attribute mark_debug of eventclock: signal is "true";
------   attribute mark_debug of prev_datastream: signal is "true";

--   attribute mark_debug of rxdata: signal is "true";
--   attribute mark_debug of rxcharisk: signal is "true";
----   --attribute mark_debug of gtx_reset: signal is "true";
   
----   attribute mark_debug of rxresetdone: signal is "true"; 
----   attribute mark_debug of tx_fsm_reset_done: signal is "true"; 
----   attribute mark_debug of rx_fsm_reset_done: signal is "true"; 
----   attribute mark_debug of cplllock: signal is "true";          
----   attribute mark_debug of cpllfbcklost: signal is "true"; 

   

begin

evr_trigs.rcvd_clk <= rxusr_clk;
evr_trigs.tbt_trig <= tbt_trig_stretch;



--gtx refclk for EVR
evr_refclk : IBUFDS_GTE2  
  port map (
    O => gtx_refclk, 
    ODIV2 => open,
    CEB => 	'0',
    I => gtx_evr_refclk_p,
    IB => gtx_evr_refclk_n
);



rxoutclk_bufg0_i : BUFG   port map ( I => rxout_clk, O => rxusr_clk);  



process(sys_clk)
  begin
    if rising_edge(sys_clk) then
        inj_trig_sync(0) <= inj_trig;
        inj_trig_sync(1) <= inj_trig_sync(0); 
        evr_trigs.inj_trig <= inj_trig_sync(1);
        onehz_trig_sync(0) <= onehz_trig;
        onehz_trig_sync(1) <= onehz_trig_sync(0); 
        onehz_trig_sync(2) <= onehz_trig_sync(1);
        --evr_trigs.onehz_trig <= onehz_trig_sync(1);               
    end if;
end process;


--check that 1Hz event is in a valid range, measure frequency
process(sys_clk)
  begin
    if rising_edge(sys_clk) then
      onehz_rate_cnt <= onehz_rate_cnt + 1;
      if (onehz_rate_cnt > 200000000) then
        evr_trigs.onehz_freq <= 32d"0";
      end if;
      evr_trigs.onehz_trig <= '0';
      if (onehz_trig_sync(2) = '0' and onehz_trig_sync(1) = '1') then
        onehz_rate_cnt <= 32d"0";
        evr_trigs.onehz_freq <= onehz_rate_cnt;        
        if (onehz_rate_cnt > 95000000 and onehz_rate_cnt < 150000000) then
           evr_trigs.onehz_trig <= '1';
        end if;
      end if;
    end if;
end process;   
      





--datastream <= gt0_rxdata(7 downto 0);
--eventstream <= gt0_rxdata(15 downto 8);
--switch byte locations of datastream and eventstream  9-20-18
process(rxusr_clk)
  begin
    if rising_edge(rxusr_clk) then
      datastream <= rxdata(15 downto 8);
      eventstream <= rxdata(7 downto 0);
    end if;
end process;



evr_trigs.ts_s <= timestamp(63 downto 32);
evr_trigs.ts_ns <= timestamp(31 downto 0);

-- timestamp decoder
ts : entity work.event_rcv_ts
   port map(
       clock => rxusr_clk,
       reset => sys_rst,
       eventstream => eventstream,
       timestamp => timestamp,
       seconds => open, 
       offset => open, 
       position => open, 
       eventclock => eventclock
 );


	
-- Post Mortem Event	
event_pm : entity work.event_rcv_chan 
    port map(
       clock => rxusr_clk,
       reset => sys_rst,
       eventstream => eventstream,
       myevent => evr_params.pm_eventno, 
       mydelay => (x"00000001"),
       mywidth => (x"00000175"),   -- //creates a pulse about 3us long
       mypolarity => ('0'),
       trigger => evr_trigs.pm_trig
);


-- 1 Hz 	
event_1Hz : entity work.event_rcv_chan
    port map(
       clock => rxusr_clk,
       reset => sys_rst,
       eventstream => eventstream,
       myevent => evr_params.onehz_eventno, 
       mydelay => 32d"1",
       mywidth => 32d"12",   -- //creates a pulse about 100ns long
       mypolarity => ('0'),
       trigger => onehz_trig 
);



-- 10 Hz 	
event_10Hz : entity work.event_rcv_chan
    port map(
       clock => rxusr_clk,
       reset => sys_rst,
       eventstream => eventstream,
       myevent => evr_params.tenhz_eventno, --(x"1E"),     -- 30d
       mydelay => 32d"1",
       mywidth => 32d"12",   -- //creates a pulse about 100ns long
       mypolarity => ('0'),
       trigger => evr_trigs.sa_trig
);




-- 10 KHz 	
event_10KHz : entity work.event_rcv_chan
    port map(
       clock => rxusr_clk,
       reset => sys_rst,
       eventstream => eventstream,
       myevent => evr_params.tenkhz_eventno, --(x"1F"),     -- 31d
       mydelay => 32d"1",
       mywidth => 32d"12",   -- //creates a pulse about 100ns long
       mypolarity => ('0'),
       trigger => evr_trigs.fa_trig
);
		
		
-- Inj Event 	
event_inj : entity work.event_rcv_chan
    port map(
       clock => rxusr_clk,
       reset => sys_rst,
       eventstream => eventstream,
       myevent => evr_params.inj_eventno,
       mydelay => 32d"1",  --evr_params.trigdly, 
       mywidth => 32d"12",   -- //creates a pulse about 100ns long
       mypolarity => ('0'),
       trigger => inj_trig --evr_trigs.inj_trig
);




--stretch the sa_trig signal so can be seen on LED
sa_led : entity work.stretch
  port map (
	clk => sys_clk,
	reset => sys_rst, 
	sig_in => evr_trigs.sa_trig, 
	len => 3000000, -- ~25ms;
	sig_out => evr_trigs.sa_trig_stretch
);	  


--stretch the sa_trig signal so can be seen on LED
onehz_led : entity work.stretch
  port map (
	clk => sys_clk,
	reset => sys_rst, 
	sig_in => evr_trigs.onehz_trig, 
	len => 3000000, -- ~25ms;
	sig_out => evr_trigs.onehz_trig_stretch
);	 


--stretch the inj_trig signal so can be seen on LED
inj_led : entity work.stretch
  port map (
	clk => sys_clk,
	reset => sys_rst, 
	sig_in => evr_trigs.inj_trig, 
	len => 3000000, -- ~25ms;
	sig_out => evr_trigs.inj_trig_stretch
);	  	




evr_gtx_init_i : evr_gtx
    port map
    (
        sysclk_in                       =>      sys_clk,
        soft_reset_rx_in                =>      evr_params.reset(1), 
        dont_reset_on_data_error_in     =>      '0', 
        gt0_tx_fsm_reset_done_out       =>      tx_fsm_reset_done,
        gt0_rx_fsm_reset_done_out       =>      rx_fsm_reset_done,
        gt0_data_valid_in               =>      '1', 

        --_____________________________________________________________________
        --_____________________________________________________________________
        --GT0  (X1Y0)

        --------------------------------- CPLL Ports -------------------------------
        gt0_cpllfbclklost_out           =>      cpllfbcklost, 
        gt0_cplllock_out                =>      cplllock,
        gt0_cplllockdetclk_in           =>      sys_clk,
        gt0_cpllreset_in                =>      evr_params.reset(0), 
        -------------------------- Channel - Clocking Ports ------------------------
        gt0_gtrefclk0_in                =>      '0',
        gt0_gtrefclk1_in                =>      gtx_refclk, 
        ---------------------------- Channel - DRP Ports  --------------------------
        gt0_drpaddr_in                  =>      (others => '0'), 
        gt0_drpclk_in                   =>      sys_clk,
        gt0_drpdi_in                    =>      (others => '0'),
        gt0_drpdo_out                   =>      open, 
        gt0_drpen_in                    =>      '0',
        gt0_drprdy_out                  =>      open,
        gt0_drpwe_in                    =>      '0', 
        --------------------------- Digital Monitor Ports --------------------------
        gt0_dmonitorout_out             =>      open,
        --------------------- RX Initialization and Reset Ports --------------------
        gt0_eyescanreset_in             =>      '0',
        gt0_rxuserrdy_in                =>      '1',
        -------------------------- RX Margin Analysis Ports ------------------------
        gt0_eyescandataerror_out        =>      open,
        gt0_eyescantrigger_in           =>      '0',
        ------------------ Receive Ports - FPGA RX Interface Ports -----------------
        gt0_rxusrclk_in                 =>      rxusr_clk,
        gt0_rxusrclk2_in                =>      rxusr_clk,
        ------------------ Receive Ports - FPGA RX interface Ports -----------------
        gt0_rxdata_out                  =>      rxdata,
        ------------------ Receive Ports - RX 8B/10B Decoder Ports -----------------
        gt0_rxdisperr_out               =>      open, 
        gt0_rxnotintable_out            =>      open, 
        --------------------------- Receive Ports - RX AFE -------------------------
        gt0_gtxrxp_in                   =>      rx_p,
        ------------------------ Receive Ports - RX AFE Ports ----------------------
        gt0_gtxrxn_in                   =>      rx_n,
        -------------- Receive Ports - RX Byte and Word Alignment Ports ------------
        gt0_rxcommadet_out              =>      open, 
        --------------------- Receive Ports - RX Equalizer Ports -------------------
        gt0_rxdfelpmreset_in            =>      '0',
        gt0_rxmonitorout_out            =>      open,
        gt0_rxmonitorsel_in             =>      "00",
        --------------- Receive Ports - RX Fabric Output Control Ports -------------
        gt0_rxoutclk_out                =>      rxout_clk,
        gt0_rxoutclkfabric_out          =>      open,
        ------------- Receive Ports - RX Initialization and Reset Ports ------------
        gt0_gtrxreset_in                =>      evr_params.reset(3), 
        gt0_rxpmareset_in               =>      evr_params.reset(4), 
        ------------------- Receive Ports - RX8B/10B Decoder Ports -----------------
        gt0_rxchariscomma_out           =>      open, 
        gt0_rxcharisk_out               =>      rxcharisk,
        -------------- Receive Ports -RX Initialization and Reset Ports ------------
        gt0_rxresetdone_out             =>      rxresetdone,
        --------------------- TX Initialization and Reset Ports --------------------
        gt0_gttxreset_in                =>      evr_params.reset(5),

        gt0_qplloutclk_in               =>      '0', 
        gt0_qplloutrefclk_in            =>      '0'
    );





		 
		

			 
end behv;
