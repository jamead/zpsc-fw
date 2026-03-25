library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.psc_pkg.ALL;

entity axi4_write_adc is
  port (
    clk             : in std_logic;
    reset           : in std_logic;
    trigger         : in std_logic;  -- 10 kHz trigger

    s_axi4_m2s      : out t_pl_snapshot_axi4_m2s;
    s_axi4_s2m      : in t_pl_snapshot_axi4_s2m;
            
    dcct_adcs       : in t_dcct_adcs;
    mon_adcs        : in t_mon_adcs;
    dac_stat        : in t_dac_stat;
    dig_cntrl       : in t_dig_cntrl;
	dig_stat        : in t_dig_stat;
	fault_stat      : in t_fault_stat;
    
	ss_buf_stat      : out t_snapshot_stat        
    );
end entity axi4_write_adc;

architecture rtl of axi4_write_adc is


   constant BURST_LEN : integer := 40;
   constant DDR_BASE_ADDR   : std_logic_vector(31 downto 0) := x"1000_0000";
   constant DDR_MAX_ADDR    : std_logic_vector(31 downto 0) := x"11E8_4800";  --10KHz * 40beats*4bytes/beat * 20 sec 
   
   type  state_type is (IDLE, ADDRESS, HDR, CNT, 
                        PS1_DCCT1, PS1_DCCT2, PS1_MON1, PS1_MON2, PS1_MON3, PS1_MON4, PS1_MON5, PS1_MON6, 
                        PS2_DCCT1, PS2_DCCT2, PS2_MON1, PS2_MON2, PS2_MON3, PS2_MON4, PS2_MON5, PS2_MON6,                
                        PS3_DCCT1, PS3_DCCT2, PS3_MON1, PS3_MON2, PS3_MON3, PS3_MON4, PS3_MON5, PS3_MON6,
                        PS4_DCCT1, PS4_DCCT2, PS4_MON1, PS4_MON2, PS4_MON3, PS4_MON4, PS4_MON5, PS4_MON6,              
                        WRD35, WRD36, WRD37, WRD38, WRD39, WRDLAST, AWAITRESP);  
   signal state :  state_type;


    signal wordnum : integer range 0 to 63 := 0;
    signal addr_base : std_logic_vector(31 downto 0) := DDR_BASE_ADDR;  -- Example DDR address
    
    signal datacnt : std_logic_vector(31 downto 0);
    signal prev_trigger : std_logic;
    signal ps1_digbits : std_logic_vector(31 downto 0);
    signal ps2_digbits : std_logic_vector(31 downto 0);
    signal ps3_digbits : std_logic_vector(31 downto 0);
    signal ps4_digbits : std_logic_vector(31 downto 0);
    
    --debug signals (connect to ila)
--    attribute mark_debug                 : string;
--    attribute mark_debug of trigger : signal is "true";
--    attribute mark_debug of prev_trigger : signal is "true";   
--    attribute mark_debug of s_axi4_m2s: signal is "true";
--    attribute mark_debug of s_axi4_s2m: signal is "true";   
--    attribute mark_debug of wordnum : signal is "true"; 
--    attribute mark_debug of datacnt : signal is "true";  
--    attribute mark_debug of state : signal is "true"; 
  
  
  
  
  
  
  

   
procedure write_word (
    signal wdata   : out std_logic_vector(31 downto 0);
    signal wvalid  : out std_logic;
    signal next_state : out state_type;
    constant data  : std_logic_vector(31 downto 0);
    constant state : state_type
) is
begin
   
    if (s_axi4_s2m.wready = '1') then
        wvalid <= '1';
        wdata <= data;
        next_state <= state;
    end if;
end procedure;    
    
  
   
begin


ps1_digbits <= dig_stat.ps1.acon & dig_stat.ps1.flt1 & dig_stat.ps1.flt2 & dig_stat.ps1.spare & dig_stat.ps1.dcct_flt & 3d"0" & 
               dig_cntrl.ps1.on1 & dig_cntrl.ps1.on2 & dig_cntrl.ps1.reset & dig_cntrl.ps1.spare & dig_cntrl.ps1.park & 3d"0" &
               fault_stat.ps1.lat(15 downto 0);

ps2_digbits <= dig_stat.ps2.acon & dig_stat.ps2.flt1 & dig_stat.ps2.flt2 & dig_stat.ps2.spare & dig_stat.ps2.dcct_flt & 3d"0" & 
               dig_cntrl.ps2.on1 & dig_cntrl.ps2.on2 & dig_cntrl.ps2.reset & dig_cntrl.ps2.spare & dig_cntrl.ps2.park & 3d"0" &
               fault_stat.ps2.lat(15 downto 0);

ps3_digbits <= dig_stat.ps3.acon & dig_stat.ps3.flt1 & dig_stat.ps3.flt2 & dig_stat.ps3.spare & dig_stat.ps3.dcct_flt & 3d"0" & 
               dig_cntrl.ps3.on1 & dig_cntrl.ps3.on2 & dig_cntrl.ps3.reset & dig_cntrl.ps3.spare & dig_cntrl.ps3.park & 3d"0" &
               fault_stat.ps3.lat(15 downto 0);

ps4_digbits <= dig_stat.ps4.acon & dig_stat.ps4.flt1 & dig_stat.ps4.flt2 & dig_stat.ps4.spare & dig_stat.ps4.dcct_flt & 3d"0" & 
               dig_cntrl.ps4.on1 & dig_cntrl.ps4.on2 & dig_cntrl.ps4.reset & dig_cntrl.ps4.spare & dig_cntrl.ps4.park & 3d"0" &
               fault_stat.ps4.lat(15 downto 0);



process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        wordnum <= 0;
        s_axi4_m2s.awvalid <= '0';
        s_axi4_m2s.wvalid <= '0';
        s_axi4_m2s.bready <= '0';
        s_axi4_m2s.wdata <= 32d"0";
        state <= idle;
        datacnt <= 32d"0";
      else
        case state is 
          when IDLE =>                
            prev_trigger <= trigger;
            if (trigger = '1' and prev_trigger = '0') then
              ss_buf_stat.addr_ptr <= addr_base;
              ss_buf_stat.tenkhzcnt <= datacnt;
              datacnt <= std_logic_vector(unsigned(datacnt) + 1);             
              wordnum <= 0;
              s_axi4_m2s.awaddr <= addr_base;
              s_axi4_m2s.awvalid <= '1';
              s_axi4_m2s.awburst <= "01";   -- Incrementing burst
              s_axi4_m2s.awcache <= "0011"; -- Normal non-cacheable bufferable
              s_axi4_m2s.awlen <= std_logic_vector(to_signed(BURST_LEN-1, 8));  -- beats per burst
              s_axi4_m2s.awlock <= "0";    
              s_axi4_m2s.awprot <= "000";  -- Unprivileged secure data
              s_axi4_m2s.awqos <= "0000";   
              s_axi4_m2s.awsize <= "010"; -- 4 bytes (32-bit)
              state <= address;
            end if;

          when ADDRESS =>
             -- Address handshake
             if (s_axi4_s2m.awready = '1') then
                 s_axi4_m2s.awvalid <= '0';  -- Address accepted
                 s_axi4_m2s.wdata <= 32d"0"; 
                 s_axi4_m2s.wstrb <= x"F";
                 state <= hdr; 
                 wordnum <= 0;
             end if;
             
          when HDR => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, x"80000000", CNT);
          when CNT => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(unsigned(datacnt)), PS1_DCCT1); 
           
          when PS1_DCCT1 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(resize(signed(dcct_adcs.ps1.dcct0), 32)), PS1_DCCT2); 
          when PS1_DCCT2 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(resize(signed(dcct_adcs.ps1.dcct1), 32)), PS1_MON1); 
          when PS1_MON1 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(resize(signed(mon_adcs.ps1.dacmon), 32)), PS1_MON2);          
          when PS1_MON2 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(resize(signed(mon_adcs.ps1.voltage), 32)), PS1_MON3);   
          when PS1_MON3 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(resize(signed(mon_adcs.ps1.ignd), 32)), PS1_MON4);   
          when PS1_MON4 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(resize(signed(mon_adcs.ps1.spare), 32)), PS1_MON5);            
          when PS1_MON5 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(resize(signed(mon_adcs.ps1.ps_reg), 32)), PS1_MON6);   
          when PS1_MON6 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(resize(signed(mon_adcs.ps1.ps_error), 32)), PS2_DCCT1); 
            
          when PS2_DCCT1 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(resize(signed(dcct_adcs.ps2.dcct0), 32)), PS2_DCCT2); 
          when PS2_DCCT2 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(resize(signed(dcct_adcs.ps2.dcct1), 32)), PS2_MON1); 
          when PS2_MON1 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(resize(signed(mon_adcs.ps2.dacmon), 32)), PS2_MON2);          
          when PS2_MON2 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(resize(signed(mon_adcs.ps2.voltage), 32)), PS2_MON3);   
          when PS2_MON3 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(resize(signed(mon_adcs.ps2.ignd), 32)), PS2_MON4);   
          when PS2_MON4 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(resize(signed(mon_adcs.ps2.spare), 32)), PS2_MON5);            
          when PS2_MON5 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(resize(signed(mon_adcs.ps2.ps_reg), 32)), PS2_MON6);   
          when PS2_MON6 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(resize(signed(mon_adcs.ps2.ps_error), 32)), PS3_DCCT1);

          when PS3_DCCT1 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(resize(signed(dcct_adcs.ps3.dcct0), 32)), PS3_DCCT2); 
          when PS3_DCCT2 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(resize(signed(dcct_adcs.ps3.dcct1), 32)), PS3_MON1); 
          when PS3_MON1 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(resize(signed(mon_adcs.ps3.dacmon), 32)), PS3_MON2);          
          when PS3_MON2 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(resize(signed(mon_adcs.ps3.voltage), 32)), PS3_MON3);   
          when PS3_MON3 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(resize(signed(mon_adcs.ps3.ignd), 32)), PS3_MON4);   
          when PS3_MON4 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(resize(signed(mon_adcs.ps3.spare), 32)), PS3_MON5);            
          when PS3_MON5 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(resize(signed(mon_adcs.ps3.ps_reg), 32)), PS3_MON6);   
          when PS3_MON6 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(resize(signed(mon_adcs.ps3.ps_error), 32)), PS4_DCCT1);   

          when PS4_DCCT1 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(resize(signed(dcct_adcs.ps4.dcct0), 32)), PS4_DCCT2); 
          when PS4_DCCT2 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(resize(signed(dcct_adcs.ps4.dcct1), 32)), PS4_MON1); 
          when PS4_MON1 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(resize(signed(mon_adcs.ps4.dacmon), 32)), PS4_MON2);          
          when PS4_MON2 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(resize(signed(mon_adcs.ps4.voltage), 32)), PS4_MON3);   
          when PS4_MON3 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(resize(signed(mon_adcs.ps4.ignd), 32)), PS4_MON4);   
          when PS4_MON4 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(resize(signed(mon_adcs.ps4.spare), 32)), PS4_MON5);            
          when PS4_MON5 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(resize(signed(mon_adcs.ps4.ps_reg), 32)), PS4_MON6);   
          when PS4_MON6 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(resize(signed(mon_adcs.ps4.ps_error), 32)), WRD35);

          when WRD35 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, ps1_digbits, WRD36);
          when WRD36 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, ps2_digbits, WRD37);
          when WRD37 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, ps3_digbits, WRD38);
          when WRD38 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, ps4_digbits, WRD39);         
          when WRD39 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, 32d"39", WRDLAST);        

          --assert wlast
          when WRDLAST => 
            if (s_axi4_s2m.wready = '1') then
              s_axi4_m2s.wvalid <= '1';
              s_axi4_m2s.wlast <= '1';
              s_axi4_m2s.wdata <=  32d"40";  
              state <= awaitresp;  
            end if;
               
          when AWAITRESP =>
              s_axi4_m2s.wlast <= '0';
              s_axi4_m2s.wvalid <= '0';
              s_axi4_m2s.bready <= '1';
              -- Clear bready after response
              if s_axi4_s2m.bvalid = '1' then
                if (addr_base < DDR_MAX_ADDR) then
                   addr_base <= std_logic_vector(unsigned(addr_base) + 4*BURST_LEN);
                else
                   addr_base <= DDR_BASE_ADDR;
                end if;
                s_axi4_m2s.bready <= '0';
                state <= idle;
              end if;
              
          end case;
        end if;
      end if;
   end process;
end architecture;


