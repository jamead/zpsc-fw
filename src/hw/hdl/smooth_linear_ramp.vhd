library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity smooth_linear_ramp is
  port (
    clk           : in std_logic;
    reset         : in std_logic;
    tenkhz_trig   : in std_logic;
    mode          : in std_logic_vector(1 downto 0);
    cur_setpt     : in signed(19 downto 0);
    new_setpt     : in signed(19 downto 0);
    linear_len    : in std_logic_vector(31 downto 0);
    curved_len    : in std_logic_vector(31 downto 0);
    dy            : in signed(31 downto 0);
    dy_per_pt     : in signed(31 downto 0);
    smooth_active : out std_logic;
    rampout       : out signed(19 downto 0)
  );
end entity;
 

architecture behv of smooth_linear_ramp is


  type state_type is (IDLE, START_CURVED, SC_CALC_DY0, SC_WAIT_DY0_MULT, SC_CALC_SETPT_CUR, SC_UPDATE_SETPT_LAST, 
                            LINEAR, LN_CALC_SETPT_CUR, LN_UPDATE_SETPT_LAST,
                            END_CURVED, EC_CALC_DY0, EC_WAIT_DY0_MULT, EC_CALC_SETPT_CUR, EC_UPDATE_SETPT_LAST); 
  signal state : state_type;
  


  signal cnt                 : signed(31 downto 0);
  signal last_point          : std_logic;
  signal new_setpt_prev      : signed(19 downto 0);
  signal old_setpt           : signed(19 downto 0);
  signal dy0                 : signed(63 downto 0);
  signal setpt_cur           : signed(63 downto 0);   -- Q10.22
  signal setpt_last          : signed(63 downto 0);   -- Q10.22
  signal total_len           : signed(31 downto 0);
  
  signal mult_wait_cnt       : unsigned(3 downto 0);
  signal ramp_curved_active  : std_logic;
  signal ramp_linear_active  : std_logic;

   --debug signals (connect to ila)
   attribute mark_debug: string;   
   attribute mark_debug of cur_setpt: signal is "true";
   attribute mark_debug of tenkhz_trig: signal is "true";  
   attribute mark_debug of old_setpt: signal is "true";   
   attribute mark_debug of new_setpt: signal is "true";  
 

begin

rampout <= resize(shift_right(setpt_last, 22), rampout'length);

process(clk)
  begin 
    if (rising_edge(clk)) then
      if (reset = '1') then
        state <= idle;
        cnt <= (others => '0');
        last_point <= '0';
        smooth_active <= '0';
        new_setpt_prev <= (others => '0');
        dy0 <= 64d"0";
        setpt_cur <= 64d"0";
        setpt_last <= 64d"0";
        ramp_curved_active <= '0';
        ramp_linear_active <= '0';
        --rampout <= 20d"0";
      
      else
        case (state) is  
          when IDLE =>
            ramp_curved_active <= '0';
            ramp_linear_active <= '0';
            new_setpt_prev <= new_setpt;
            last_point <= '0';
            smooth_active <= '0';
               
            -- run if dac setpt changes and dac_opmode is Smooth
            if (new_setpt_prev /= new_setpt) and (mode = "00")then
              -- load the setpt_last, which is in Q10.22 format with the signed(19 downto 0) current setpoint
              setpt_last <= shift_left(resize(cur_setpt, 64), 22);
              state <= start_curved;
              cnt <= 32d"0";
              last_point <= '0';
              smooth_active <= '1';
              total_len <= signed(curved_len) + signed(curved_len) + signed(linear_len);
            end if;
                 
                      
          when START_CURVED =>  
            if (tenkhz_trig = '1') then
              ramp_curved_active <= '1';
              ramp_linear_active <= '0';
              if cnt < signed(curved_len) then
                state <= sc_calc_dy0; 
              else
                state <= linear;
              end if;
            end if;
     
          when SC_CALC_DY0 =>
            dy0 <= resize(cnt * dy_per_pt, 64);
            mult_wait_cnt <= to_unsigned(10, mult_wait_cnt'length);
            state <= sc_wait_dy0_mult;  
           
          when SC_WAIT_DY0_MULT =>
            if mult_wait_cnt = 0 then
              -- dy0 is now valid
              state <= sc_calc_setpt_cur; 
            else
              mult_wait_cnt <= mult_wait_cnt - 1;        
            end if;  
           
          when SC_CALC_SETPT_CUR =>
            setpt_cur <= setpt_last + dy0;
            state <= sc_update_setpt_last; 
    
          when SC_UPDATE_SETPT_LAST =>
            setpt_last <= setpt_cur;
            --rampout <= resize(setpt_cur(63 downto 44), 20);
            cnt <= cnt + 1;
            state <= start_curved;           
            
            
          when LINEAR => 
            ramp_linear_active <= '1';
            ramp_curved_active <= '0'; 
            if (tenkhz_trig = '1') then
              if cnt < (signed(curved_len) + signed(linear_len)) then
                state <= ln_calc_setpt_cur; 
              else
                state <= end_curved;
              end if;
            end if;
     
          when LN_CALC_SETPT_CUR =>
            setpt_cur <= setpt_last + dy;
            state <= ln_update_setpt_last; 
    
          when LN_UPDATE_SETPT_LAST =>
            setpt_last <= setpt_cur;
            --rampout <= resize(setpt_cur(63 downto 44), 20);
            cnt <= cnt + 1;
            state <= linear;        


         when END_CURVED =>  
            ramp_linear_active <= '0';
            ramp_curved_active <= '1'; 
            if (tenkhz_trig = '1') then
              if cnt < signed(total_len) then
                state <= ec_calc_dy0; 
              else
                state <= idle;
              end if;
            end if;
     
          when EC_CALC_DY0 =>
            dy0 <= resize((total_len - cnt) * dy_per_pt, 64);
            mult_wait_cnt <= to_unsigned(10, mult_wait_cnt'length);
            state <= ec_wait_dy0_mult;  
           
          when EC_WAIT_DY0_MULT =>
            if mult_wait_cnt = 0 then
              -- dy0 is now valid
              state <= ec_calc_setpt_cur; 
            else
              mult_wait_cnt <= mult_wait_cnt - 1;        
            end if;  
           
          when EC_CALC_SETPT_CUR =>
            setpt_cur <= setpt_last + dy0;
            state <= ec_update_setpt_last; 
    
          when EC_UPDATE_SETPT_LAST =>
            setpt_last <= setpt_cur;
            --rampout <= resize(setpt_cur(63 downto 44), 20);
            cnt <= cnt + 1;
            state <= end_curved;                 

            
    
               
        end case;
      end if;
    end if;
end process;      
    
    
             
end behv;           
          
          
          
  


 
