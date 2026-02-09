library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;


library work;
use work.psc_pkg.ALL;


entity fault_block is 
	port(
	
	    --Clocks and Reset
		clk               : in std_logic; 
		reset             : in std_logic; 
		tenkhz_trig       : in std_logic; 
		fault_params      : in t_fault_params_onech;
		dcct_adcs         : in t_dcct_adcs_onech;
		mon_adcs          : in t_mon_adcs_onech;
		fault1            : in std_logic; 
		fault2            : in std_logic; 
		fault3            : in std_logic; 
		dcct_fault        : in std_logic; 
		ac_on_in          : in std_logic; 
		ac_on_out         : in std_logic; 
		park              : in std_logic; 
		dac_setpoint      : in std_logic_vector(19 downto 0); 
		evr_flt_in        : in std_logic;
		fault_stat        : out t_fault_stat_onech
	); 
	
end entity; 
	
architecture arch of fault_block is 

  signal dff0, dff1, dff2, dff3  : std_logic; 
  signal heartbeat               : std_logic; 
  signal ten_khz_pulse           : std_logic; 

  --analog fault counters
  signal ovc_fault_cnt1          : unsigned(15 downto 0); --6.55 seconds at 10 kHz
  signal ovc_fault_cnt2          : unsigned(15 downto 0);  
  signal ovv_fault_cnt           : unsigned(15 downto 0); 
  signal err_fault_cnt1          : unsigned(15 downto 0); 
  signal err_fault_cnt2          : unsigned(15 downto 0); 
  signal ignd_fault_cnt          : unsigned(15 downto 0); 
  signal on_fault_cnt            : unsigned(31 downto 0); 
  signal heart_cnt               : unsigned(31 downto 0); 

  --digital fault counters
  signal dcct_fault_cnt          : unsigned(15 downto 0); 
  signal fault1_cnt              : unsigned(15 downto 0); 
  signal fault2_cnt              : unsigned(15 downto 0); 
  signal fault3_cnt              : unsigned(15 downto 0); 
  signal error_sub               : integer;  
  signal fault_reg               : std_logic_vector(15 downto 0) := (others => '0'); 
  signal dac_setpoint_reg_new    : std_logic_vector(19 downto 0); 
  signal dac_setpoint_reg_old    : std_logic_vector(19 downto 0); 
  signal dac_change_flag         : std_logic; 
  signal re, re_reg              : std_logic;
  signal clear_pulse             : std_logic;
  signal fault_reg_lat           : std_logic_vector(15 downto 0);
  signal fault_reg_lat_mask      : std_logic_vector(15 downto 0);
  signal error_reg_mask          : std_logic_vector(15 downto 0);

  --signal err_abs                 : signed(15 downto 0); 


  --debug signals (connect to ila)
   attribute mark_debug                 : string;
   attribute mark_debug of fault_params: signal is "true";
--   attribute mark_debug of clear_pulse: signal is "true";
--   attribute mark_debug of re: signal is "true";
--   attribute mark_debug of re_reg: signal is "true";
--   attribute mark_debug of fault_reg: signal is "true";
--   attribute mark_debug of fault_reg_lat: signal is "true";
--   attribute mark_debug of fault_params: signal is "true";
--   attribute mark_debug of fault_stat: signal is "true";
--   attribute mark_debug of dac_change_flag: signal is "true";
--   attribute mark_debug of fault_reg_lat_mask: signal is "true";
--   attribute mark_debug of error_reg_mask: signal is "true";


begin 

fault_stat.live <= fault_reg;
fault_stat.lat  <= fault_reg_lat_mask; 
fault_stat.flt_trig <= or fault_reg_lat_mask;
fault_stat.err_trig <= or error_reg_mask;


--This allows the user to ignore faults by setting a bit to zero in the mask register
process(clk) 
begin 
    if rising_edge(clk) then      
        fault_reg_lat_mask <= x"1FEF" and fault_reg_lat and fault_params.enable;
        error_reg_mask <= x"0010" and fault_reg and fault_params.enable;      
    end if; 
end process; 


process(clk) 
begin 
    if rising_edge(clk) then 
        if reset = '1' then 
            dac_setpoint_reg_new <= (others => '0'); 
            dac_setpoint_reg_old <= (others => '0'); 
        else 
            if tenkhz_trig = '1' then 
                dac_setpoint_reg_new <= dac_setpoint; 
                dac_setpoint_reg_old <= dac_setpoint_reg_new; 
            end if; 
        end if; 
    end if; 
end process; 



process(clk) 
begin 
    if rising_edge(clk) then 
        if reset = '1' then 
            dff0 <= '0'; 
            dff1 <= '0'; 
            ten_khz_pulse <= '0'; 
        else 
            dff0 <= tenkhz_trig; 
            dff1 <= dff0; 
            ten_khz_pulse <= dff1; 
        end if; 
    end if; 
end process; 



process(clk)
begin
    if rising_edge(clk) then
        re <= fault_params.clear;  --clear_reg_in(0);      
        re_reg <= re;
       
        if(re_reg = '0' and re = '1') then
            clear_pulse <= '1';
        elsif ten_khz_pulse = '1' then 
            clear_pulse <= '0';
        end if;
    end if;
end process;



--on fault rising edge detector
process(clk) 
begin 
    if rising_edge(clk) then 
        if reset = '1' then 
            dff2 <= '0'; 
            dff3 <= '0';
            heartbeat <= '0'; 
        else 
            dff2 <= fault2; 
            dff3 <= dff2; 
            heartbeat <= not(dff2) and dff3; 
        end if; 
    end if; 
end process; 





process(clk) 
begin 
    if rising_edge(clk) then 
        if reset = '1' then 
            error_sub <= 0; 
            dac_change_flag <= '0';
        else 
        --Note: 2 Channel will not be signed when using binary offset mode for dac.  
        --    error_sub <= abs(to_integer(signed(dac_setpoint))) - abs(to_integer(signed(dcct1)));
        
        --previous and present dac value comparison
            if dac_setpoint_reg_new /= dac_setpoint_reg_old then 
                dac_change_flag <= '1'; 
            else 
                dac_change_flag <= '0'; 
            end if;  
      end if;     
    end if; 
end process; 






--Main Fault Logic
process(clk) 
begin
    if rising_edge(clk) then 
        if reset = '1' then 
            fault_reg <= (others => '0'); 
            fault_reg_lat <= (others => '0'); 
            ovc_fault_cnt1 <= (others => '0'); 
            ovc_fault_cnt2 <= (others => '0'); 
            ovv_fault_cnt  <= (others => '0'); 
            err_fault_cnt1 <= (others => '0'); 
            err_fault_cnt2 <= (others => '0'); 
            ignd_fault_cnt <= (others => '0'); 
            
        else 
        
    
        if ten_khz_pulse = '1' then    
          
        --#############################################################
        --Analog Threshold Checks
        --#############################################################
        --Over Current DCCT 1 Fault Check
            if (abs(dcct_adcs.dcct0) >= abs(signed(fault_params.ovc1_thresh))) and clear_pulse = '0' then 
                if ovc_fault_cnt1 = unsigned(fault_params.ovc1_cntlim) then 
                    fault_reg(0) <= '1'; 
                 else
                    ovc_fault_cnt1 <= ovc_fault_cnt1 +1; 
                 end if; 
            else 
                ovc_fault_cnt1 <= (others => '0'); 
                fault_reg(0) <= '0';
            end if;  
            
            --Over Current DCCT 2 Fault Check
            if (abs(dcct_adcs.dcct1) >= abs(signed(fault_params.ovc2_thresh))) and clear_pulse = '0' then 
                if ovc_fault_cnt2 = unsigned(fault_params.ovc2_cntlim) then 
                    fault_reg(1) <= '1'; 
                else 
                    ovc_fault_cnt2 <= ovc_fault_cnt2 +1; 
                end if; 
            else 
                ovc_fault_cnt2 <= (others => '0'); 
                fault_reg(1) <= '0';
            end if;           
            
            --Over Voltage Fault Check
            if (abs(mon_adcs.voltage) >= abs(signed(fault_params.ovv_thresh))) and clear_pulse = '0' then 
                if ovv_fault_cnt = unsigned(fault_params.ovv_cntlim) then 
                    fault_reg(2) <= '1'; 
                else 
                    ovv_fault_cnt <= ovv_fault_cnt + 1; 
                end if; 
            else 
                ovv_fault_cnt <= (others => '0');
                fault_reg(2) <= '0';
            end if;  
            
            --PI Looop ERROR Fault Check
            --Note: if channel is in park then this error is ignored.
            --or if the DAC setpoint input register changed then the error is ignored. 
            if park = '0' then --error will be high when park enabled 
                if dac_change_flag = '0' then --ensure that the dac setpoint isn't commanded to change
                     if (abs(mon_adcs.ps_error) >= abs(signed(fault_params.err1_thresh))) and clear_pulse = '0'  then 
                        if err_fault_cnt1 = unsigned(fault_params.err1_cntlim) then 
                            fault_reg(3) <= '1'; 
                        else 
                            err_fault_cnt1 <= err_fault_cnt1 + 1; 
                        end if; 
                     else 
                        err_fault_cnt1 <= (others => '0'); 
                        fault_reg(3) <= '0';
                    end if;  
                    
                    --error glitch (only used for triggering a snapshot, not an interlock fault
                    if (abs(mon_adcs.ps_error) >= abs(signed(fault_params.err2_thresh))) and clear_pulse = '0'  then 
                        if err_fault_cnt2 = unsigned(fault_params.err2_cntlim) then 
                            fault_reg(4) <= '1'; 
                        else 
                            err_fault_cnt2 <= err_fault_cnt2 + 1; 
                        end if; 
                    else 
                        err_fault_cnt2 <= (others => '0');
                        fault_reg(4) <= '0';
                    end if;   
                else 
                    err_fault_cnt1 <= (others => '0'); 
                    err_fault_cnt2 <= (others => '0');  
                    fault_reg(3)   <= '0'; 
                    fault_reg(4)   <= '0';                         
                end if; 
            else 
                err_fault_cnt1 <= (others => '0'); 
                err_fault_cnt2 <= (others => '0');  
                fault_reg(3)   <= '0'; 
                fault_reg(4)   <= '0'; 
            end if; 

            
            --Ground Current Fault Check             
            if (abs(mon_adcs.ignd) >= abs(signed(fault_params.ignd_thresh))) and clear_pulse = '0'  then 
                if ignd_fault_cnt = unsigned(fault_params.ignd_cntlim) then 
                    fault_reg(5) <= '1'; 
                else 
                    ignd_fault_cnt <= ignd_fault_cnt +1; 
                end if; 
            else 
                ignd_fault_cnt <= (others => '0'); 
                fault_reg(5) <= '0';
            end if;       
            
        --#############################################################
        --Digital Fault Checks
        --#############################################################   
         --DCCT Status Fault Check        
            if dcct_fault = '0' and clear_pulse = '0' then 
                if dcct_fault_cnt = unsigned(fault_params.dcct_cntlim) then 
                    fault_reg(6) <= '1'; 
                else 
                    dcct_fault_cnt <= dcct_fault_cnt +1; 
                end if; 
            else 
                dcct_fault_cnt <= (others => '0');
                fault_reg(6) <= '0';
            end if; 
            
            --Bipolar Power Supply Fault
            --David wanted this live not latched
            if fault1 = '1'  and clear_pulse = '0' then 
                if fault1_cnt = unsigned(fault_params.flt1_cntlim) then 
                    fault_reg(7) <= '1'; 
                else 
                    fault1_cnt <= fault1_cnt +1; 
                end if; 
            else 
                fault1_cnt <= (others => '0');
                fault_reg(7) <= '0'; 
            end if; 
            
            --Bipolar Heartbeat Fault
            if fault2 = '1' and clear_pulse = '0' then 
                if fault2_cnt = unsigned(fault_params.flt2_cntlim) then 
                    fault_reg(8) <= '1'; 
                else 
                    fault2_cnt <= fault2_cnt +1; 
                end if; 
            else 
                fault2_cnt <= (others => '0');
                fault_reg(8) <= '0'; 
            end if; 
            
            --External Interlock Fault Check
            if fault3 = '1' and clear_pulse = '0'  then 
                if fault3_cnt = unsigned(fault_params.flt3_cntlim) then 
                    fault_reg(9) <= '1'; 
                else 
                    fault3_cnt <= fault3_cnt +1; 
                end if; 
            else 
                fault3_cnt <= (others => '0');
                fault_reg(9) <= '0';  
            end if; 
    
            if ac_on_out = '1' and ac_on_in = '0' and clear_pulse = '0'  then 
                if on_fault_cnt = unsigned(fault_params.on_cntlim) then 
                    fault_reg(10) <= '1'; 
                else 
                    on_fault_cnt <= on_fault_cnt +1; 
                end if; 
            else 
                on_fault_cnt <= (others => '0');
                fault_reg(10) <= '0';  
            end if;         
            
                                           
         end if;     
         
         --Bipolar Converter Heartbeat Detection
--         if heartbeat = '0' and clear_pulse = '0'  then 
--             if heart_cnt = unsigned(fault_params.heart_cntlim) then 
--                 fault_reg(11) <= '1'; 
--             else 
--                 heart_cnt <= heart_cnt +1; 
--             end if; 
--         else 
--             heart_cnt <= (others => '0');
--             fault_reg(11) <= '0';  
--         end if;      
         
         
        --#############################################################
        --Fault Latches: fault is latched until clear reg bit is set 
        --############################################################# 
        fault_reg(12) <= evr_flt_in;
        for i in 0 to 12 loop
            if clear_pulse = '0' then
                if fault_reg(i) = '1' then
                    fault_reg_lat(i) <= '1';
                end if;
            else
                fault_reg_lat(i) <= '0';
            end if;
         end loop;

  
           
    end if; 
    end if; 
end process; 

end architecture; 
