library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.psc_pkg.all; 



entity fofb_top is
  generic (
    SIM_MODE     : integer := 0
  );
  port (
    pl_clk0      : in  std_logic;
    reset        : in  std_logic;   
    gtrefclk_p   : in  std_logic;
    gtrefclk_n   : in  std_logic;
    rxp          : in  std_logic_vector(1 downto 0);
    rxn          : in  std_logic_vector(1 downto 0);
    txp          : out std_logic_vector(1 downto 0);
    txn          : out std_logic_vector(1 downto 0);
    fofb_params  : in t_fofb_params; 
	fofb_stat    : out t_fofb_stat;
	fofb_data    : out t_fofb_data
  );
end entity fofb_top;

architecture behv of fofb_top is

  signal shift_q               : std_logic_vector(8 downto 0);
  signal fofb_clk              : std_logic;
  signal fofb_rxd              : std_logic_vector(7 downto 0);
  signal fofb_rx_dv            : std_logic;
  signal fofb_rxd_dly          : std_logic_vector(7 downto 0);
  signal fofb_rx_dv_dly        : std_logic; 

  signal fofb_packet           : std_logic;
  signal udp_rx_done           : std_logic;
  signal fofb_new              : std_logic;


--  attribute mark_debug : string;  
--  attribute mark_debug of fofb_params: signal is "true";
--  attribute mark_debug of fofb_stat: signal is "true"; 
--  attribute mark_debug of fofb_data: signal is "true";
--  attribute mark_debug of fofb_rx_dv: signal is "true";
--  attribute mark_debug of fofb_rxd: signal is "true";
--  attribute mark_debug of fofb_packet: signal is "true";
--  attribute mark_debug of udp_rx_done: signal is "true";
--  attribute mark_debug of fofb_rx_dv_dly: signal is "true";
--  attribute mark_debug of fofb_rxd_dly: signal is "true";

begin



--phy instantiations
fofb_phy : entity work.fofb_phy
  generic map (
    SIM_MODE => SIM_MODE  
  )
  port map (
    clk => pl_clk0,
    reset => reset,
    gtrefclk_p => gtrefclk_p,
    gtrefclk_n => gtrefclk_n,
    rxp => rxp,
    rxn => rxn,
    txp => txp,
    txn => txn,
    fofb_clk => fofb_clk,
    fofb_rxd => fofb_rxd,
    fofb_rx_dv => fofb_rx_dv,
    fofb_txd => fofb_rxd_dly,
    fofb_tx_en => fofb_rx_dv_dly
);




--FOFB receive fsm 
fofb_rcv : entity work.udp_rx
  port map (  
    fofb_clk => fofb_clk,         
    reset => reset,	
    fofb_params => fofb_params,
    fofb_stat => fofb_stat,
    rx_data_in => fofb_rxd, 
    rx_dv => fofb_rx_dv, 
    fofb_packet => fofb_packet,                                  	                         
    rx_done => fofb_new
);
	 
	 
--converts to fixed point, syncs to pl_clk0 domain	 
ps1 : entity work.fofb_flt2fix
  port map (
    fofb_clk => fofb_clk,
    pl_clk0 => pl_clk0,
    fofb_new => fofb_new, 
    fofb_setpt_flt => fofb_stat.ps1_setpt_flt,
    scale_factor => fofb_params.ps1_scalefactor,
    fofb_setpt => fofb_data.ps1_setpt
 );
 	 
ps2 : entity work.fofb_flt2fix
  port map (
    fofb_clk => fofb_clk,
    pl_clk0 => pl_clk0,
    fofb_new => fofb_new,
    fofb_setpt_flt => fofb_stat.ps2_setpt_flt,
    scale_factor => fofb_params.ps2_scalefactor,
    fofb_setpt => fofb_data.ps2_setpt
 );

ps3 : entity work.fofb_flt2fix
  port map (
    fofb_clk => fofb_clk,
    pl_clk0 => pl_clk0,
    fofb_new => fofb_new,
    fofb_setpt_flt => fofb_stat.ps3_setpt_flt,
    scale_factor => fofb_params.ps3_scalefactor,
    fofb_setpt => fofb_data.ps3_setpt
 );

ps4 : entity work.fofb_flt2fix
  port map (
    fofb_clk => fofb_clk,
    pl_clk0 => pl_clk0,
    fofb_new => fofb_new,
    fofb_setpt_flt => fofb_stat.ps4_setpt_flt,
    scale_factor => fofb_params.ps4_scalefactor,
    fofb_setpt => fofb_data.ps4_setpt
 );



dly_packet: shift_ram
  port map (
    clk => fofb_clk,
    d => fofb_rx_dv & fofb_rxd,
    q => shift_q
);

fofb_rx_dv_dly <= shift_q(8);
fofb_rxd_dly <= shift_q(7 downto 0);
  


end architecture behv;
