library ieee;
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all;
use work.psc_pkg.all;


entity udp_rx is
  port (
    fofb_clk      		: in  std_logic;           
    reset			    : in  std_logic;    
    fofb_params         : in t_fofb_params;
    rx_data_in	      	: in  std_logic_vector(7 downto 0); 
    rx_dv			    : in  std_logic;                                      	              
    fofb_packet         : out std_logic;
    rx_done             : out std_logic := '0';
    fofb_stat           : out t_fofb_stat

  );
end udp_rx;


architecture udp_rx_arch OF udp_rx is
    type state_type is (IDLE, RX_PREAMBLE, RX_HEADER, RX_ADDRHI, RX_ADDRLO, 
                        RX_SETPT_BYTE3, RX_SETPT_BYTE2, RX_SETPT_BYTE1, RX_SETPT_BYTE0, 
                        RX_DATA, CHECK_ADDR, RX_FINISHED);
    signal state: state_type;
	 
	 signal rx_dv_prev          : std_logic;
     signal framebytenum 		: INTEGER range 0 to 32767;
	 signal databytenum 		: INTEGER RANGE 0 TO 127;
	 
     signal stretch_count       : integer := 0; 
     signal stretch_pulse       : std_logic;
     signal rx_check_count      : integer; 
     signal rx_check            : std_logic; 
     signal udp_pkt_buf_rx      : t_udp_pkt; 
     signal pkt_length_int      : integer; 
     
     signal fast_addr           : std_logic_vector(15 downto 0);
     signal setpt               : std_logic_vector(31 downto 0);
     
     
--     attribute mark_debug : string;  
--     attribute mark_debug of framebytenum: signal is "true";
--     attribute mark_debug of state: signal is "true";  
--     attribute mark_debug of udp_pkt_buf_rx: signal is "true";
     
     

begin



process(fofb_clk) 
  begin
  if rising_edge(fofb_clk) then 
     if reset = '1' then
        state <= idle;
		framebytenum <= 0;
		databytenum <= 0;
		rx_done <= '0'; 
		rx_dv_prev <= '0';
		fofb_stat.ps1_setpt_flt <= 32d"0";
		fofb_stat.ps2_setpt_flt <= 32d"0";
		fofb_stat.ps3_setpt_flt <= 32d"0";
		fofb_stat.ps4_setpt_flt <= 32d"0";
		fofb_stat.packets_rcvd <= 32d"0";
		fofb_stat.command <= 32d"0";
		fofb_stat.nonce <= 32d"0";
		fofb_packet <= '0';
		
     else 
        case(state) is
          when IDLE =>
                fofb_packet <= '0';
				rx_done <= '0';
                rx_dv_prev <= rx_dv;
                if (rx_dv = '1' and rx_dv_prev = '0') then              
                  state <= rx_preamble;	
                  framebytenum <= 0;
                  databytenum <= 0;
                end if;
                
           when RX_PREAMBLE =>
              if (rx_data_in = x"D5") then
                 state <= rx_header;          
              end if;
               
           when RX_HEADER =>
  				framebytenum <= framebytenum + 1;
				case framebytenum is 
				    --- IP Header ---
				    when 0 =>      udp_pkt_buf_rx.mac_dest_addr(47 downto 40)   <= rx_data_in;
					when 1 =>      udp_pkt_buf_rx.mac_dest_addr(39 downto 32)   <= rx_data_in;
					when 2 =>      udp_pkt_buf_rx.mac_dest_addr(31 downto 24)   <= rx_data_in;
					when 3 =>      udp_pkt_buf_rx.mac_dest_addr(23 downto 16)   <= rx_data_in;
					when 4 =>      udp_pkt_buf_rx.mac_dest_addr(15 downto 8)    <= rx_data_in;
					when 5 =>      udp_pkt_buf_rx.mac_dest_addr(7 downto 0)     <= rx_data_in;
					when 6 =>      udp_pkt_buf_rx.mac_src_addr(47 downto 40)	<= rx_data_in;
					when 7 =>      udp_pkt_buf_rx.mac_src_addr(39 downto 32)	<= rx_data_in;
					when 8 =>      udp_pkt_buf_rx.mac_src_addr(31 downto 24)	<= rx_data_in;
					when 9 =>      udp_pkt_buf_rx.mac_src_addr(23 downto 16)	<= rx_data_in;
					when 10 =>     udp_pkt_buf_rx.mac_src_addr(15 downto 8)	    <= rx_data_in;
					when 11 =>     udp_pkt_buf_rx.mac_src_addr(7 downto 0)		<= rx_data_in;   
					when 12 =>     udp_pkt_buf_rx.mac_len_type(15 downto 8)     <= rx_data_in;
					when 13 =>     udp_pkt_buf_rx.mac_len_type(7 downto 0)      <= rx_data_in;
					when 14 =>     udp_pkt_buf_rx.ip_ver                        <= rx_data_in(7 downto 4);
						           udp_pkt_buf_rx.ip_ihl                        <= rx_data_in(3 downto 0);
					when 15 =>     udp_pkt_buf_rx.ip_tos                        <= rx_data_in;
					when 16 =>     udp_pkt_buf_rx.total_len(15 downto 8)        <= rx_data_in;
					when 17 =>     udp_pkt_buf_rx.total_len(7 downto 0)         <= rx_data_in;
					when 18 =>     udp_pkt_buf_rx.ip_ident(15 downto 8)         <= rx_data_in;
					when 19 =>     udp_pkt_buf_rx.ip_ident(7 downto 0)          <= rx_data_in;
					when 20 =>     udp_pkt_buf_rx.ip_flags(2 downto 0)          <= rx_data_in(7 downto 5);
	                               udp_pkt_buf_rx.ip_fragoffset(12 downto 8)    <= rx_data_in(4 downto 0);
					when 21 =>     udp_pkt_buf_rx.ip_fragoffset(7 downto 0)     <= rx_data_in;
					when 22 =>     udp_pkt_buf_rx.ip_ttl					    <= rx_data_in;
					when 23 =>     udp_pkt_buf_rx.ip_protocol				    <= rx_data_in;
					when 24 =>     udp_pkt_buf_rx.header_checksum(15 downto 8)  <= rx_data_in;
					when 25 =>     udp_pkt_buf_rx.header_checksum(7 downto 0)   <= rx_data_in;
					when 26 =>     udp_pkt_buf_rx.ip_src_addr(31 downto 24)     <= rx_data_in;
					when 27 =>     udp_pkt_buf_rx.ip_src_addr(23 downto 16)     <= rx_data_in;
					when 28 =>     udp_pkt_buf_rx.ip_src_addr(15 downto 8)      <= rx_data_in;
					when 29 =>     udp_pkt_buf_rx.ip_src_addr(7 downto 0)       <= rx_data_in;
					when 30 =>     udp_pkt_buf_rx.ip_dest_addr(31 downto 24)    <= rx_data_in;
					when 31 =>     udp_pkt_buf_rx.ip_dest_addr(23 downto 16)    <= rx_data_in;
					when 32 =>     udp_pkt_buf_rx.ip_dest_addr(15 downto 8)     <= rx_data_in;
					when 33 =>     udp_pkt_buf_rx.ip_dest_addr(7 downto 0)      <= rx_data_in;						
					when 34 =>     udp_pkt_buf_rx.udp_src_port(15 downto 8)     <= rx_data_in;
					when 35 =>     udp_pkt_buf_rx.udp_src_port(7 downto 0)      <= rx_data_in;
					when 36 =>     udp_pkt_buf_rx.udp_dest_port(15 downto 8)    <= rx_data_in;
					when 37 =>     udp_pkt_buf_rx.udp_dest_port(7 downto 0)     <= rx_data_in;				
					when 38 =>     udp_pkt_buf_rx.udp_len(15 downto 8)	        <= rx_data_in;
					when 39 =>     udp_pkt_buf_rx.udp_len(7 downto 0)           <= rx_data_in;						
					when 40 =>     udp_pkt_buf_rx.udp_checksum(15 downto 8)     <= rx_data_in;
					when 41 =>     udp_pkt_buf_rx.udp_checksum(7 downto 0)      <= rx_data_in;	
					--Start of UDP Payload							   		   			
					when 42 => 	   udp_pkt_buf_rx.fast_ps_id(15 downto 8)       <= rx_data_in;
					when 43 =>     udp_pkt_buf_rx.fast_ps_id(7 downto 0)        <= rx_data_in;
					when 44 =>     udp_pkt_buf_rx.readback_cmd(15 downto 8)     <= rx_data_in; 
					when 45 =>     udp_pkt_buf_rx.readback_cmd(7 downto 0)      <= rx_data_in;
					when 46 =>     udp_pkt_buf_rx.nonce(63 downto 56)           <= rx_data_in;
					when 47 =>     udp_pkt_buf_rx.nonce(55 downto 48)           <= rx_data_in;  
					when 48 =>     udp_pkt_buf_rx.nonce(47 downto 40)           <= rx_data_in;  
                    when 49 =>     udp_pkt_buf_rx.nonce(39 downto 32)           <= rx_data_in; 
                    when 50 =>     udp_pkt_buf_rx.nonce(31 downto 24)           <= rx_data_in; 
                    when 51 =>     udp_pkt_buf_rx.nonce(23 downto 16)           <= rx_data_in;  
                    when 52 =>     udp_pkt_buf_rx.nonce(15 downto 8)            <= rx_data_in; 
                    when 53 =>     udp_pkt_buf_rx.nonce(7 downto 0)             <= rx_data_in; 
                                   if (udp_pkt_buf_rx.ip_dest_addr = fofb_params.ipaddr) and 
                                      (udp_pkt_buf_rx.fast_ps_id = x"7631") then
                                      state <= rx_addrhi;
                                      fofb_stat.nonce <= udp_pkt_buf_rx.nonce(31 downto 8) & rx_data_in;
                                      fofb_stat.command <= 16d"0" & udp_pkt_buf_rx.readback_cmd;
                                      fofb_stat.packets_rcvd <= std_logic_vector(unsigned(fofb_stat.packets_rcvd) + 1);
                                      fofb_packet <= '1';
                                   else 
                                      state <= idle;
                                   end if;
                                   
                    when others => null;               
                end case;  
            
            when RX_ADDRHI =>  
                    fofb_packet <= '0';  
                    if (rx_dv = '0') then
                      state <= idle;
                      rx_done <= '1';
                    else              
                      state <= rx_addrhi;                              
                      fast_addr(15 downto 8) <= rx_data_in;
                      state <= rx_addrlo;
                    end if;
                    
            when RX_ADDRLO =>
                    fast_addr(7 downto 0) <= rx_data_in;
                    state <= rx_setpt_byte3;
                    
            when RX_SETPT_BYTE3 =>
                    setpt(31 downto 24) <= rx_data_in;
                    state <= rx_setpt_byte2;
                    
             when RX_SETPT_BYTE2 =>
                    setpt(23 downto 16) <= rx_data_in;
                    state <= rx_setpt_byte1;                   
                    
             when RX_SETPT_BYTE1 =>
                    setpt(15 downto 8) <= rx_data_in;
                    state <= rx_setpt_byte0;                   
                    
             when RX_SETPT_BYTE0 =>
                    setpt(7 downto 0) <= rx_data_in;
                    if (fast_addr = fofb_params.ps1_addr) then
                       fofb_stat.ps1_setpt_flt <= setpt(31 downto 8) & rx_data_in;
                    end if;
                    if (fast_addr = fofb_params.ps2_addr) then
                       fofb_stat.ps2_setpt_flt <= setpt(31 downto 8) & rx_data_in;
                    end if;     
                    if (fast_addr = fofb_params.ps3_addr) then
                       fofb_stat.ps3_setpt_flt <= setpt(31 downto 8) & rx_data_in;
                    end if;                   
                    if (fast_addr = fofb_params.ps4_addr) then
                       fofb_stat.ps4_setpt_flt <= setpt(31 downto 8) & rx_data_in;
                    end if;                    
                                   
                    if (rx_dv = '0') then
                      state <= idle;
                      rx_done <= '1';
                    else              
                      state <= rx_addrhi;
                    end if; 
                    				
		     when others => 
		       state <= idle;				
					
        end case;
     end if;
  end if; 
  end process;
end architecture;
