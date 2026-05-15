library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity smooth_cosine_ramp is
  port (
    clk           : in std_logic;
    reset         : in std_logic;
    tenkhz_trig   : in std_logic;
    mode          : in std_logic_vector(1 downto 0);
    cur_setpt     : in signed(19 downto 0);
    new_setpt     : in signed(19 downto 0);
    phase_inc     : in signed(31 downto 0);
    smooth_active : out std_logic;
    rampout       : out signed(19 downto 0)
  );
end entity;
 

architecture behv of smooth_cosine_ramp is


component cordic_sine
  port (
      aclk                : in  std_logic;
      s_axis_phase_tvalid : in  std_logic;
      s_axis_phase_tdata  : in  std_logic_vector(23 downto 0);
      m_axis_dout_tvalid  : out std_logic;
      m_axis_dout_tdata   : out std_logic_vector(47 downto 0)
    );
  end component;
  
  
  type state_type is (IDLE, RUN_RAMP); 
  signal state : state_type;
  
  --cordic phase is 1.2.31 format  3.14/4 * 2^31 = 421657428                     
  constant POS_PI            : signed(31 downto 0) := 32d"421657300";            
  constant NEG_PI            : signed(31 downto 0) := to_signed(-421657300, 32); 
  
  
  signal cordic_valid        : std_logic;
  signal cordic_dout         : std_logic_vector(47 downto 0);

  signal phase               : signed(31 downto 0);
  signal phase_out           : signed(23 downto 0);

  signal sin                 : signed(23 downto 0);
  signal cos                 : signed(23 downto 0);
  signal raised_cos          : signed(23 downto 0);
  signal raised_cos20        : signed(19 downto 0);
  signal cnt                 : std_logic_vector(19 downto 0);
  signal rampout_wdiff       : signed(47 downto 0);
  signal rampout_fp          : signed(23 downto 0);
  signal scaled_sine         : signed(23 downto 0);
  signal last_point          : std_logic;
  signal diff_setpt          : signed(23 downto 0);
  signal new_setpt_prev      : signed(19 downto 0);
  signal new_setpt_lat       : signed(19 downto 0);
  signal old_setpt           : signed(19 downto 0);

  

   --debug signals (connect to ila)
   attribute mark_debug: string;   
   attribute mark_debug of cur_setpt: signal is "true";
   attribute mark_debug of tenkhz_trig: signal is "true";  
   attribute mark_debug of old_setpt: signal is "true";   
   attribute mark_debug of new_setpt: signal is "true";  
   attribute mark_debug of phase_inc: signal is "true";   
   attribute mark_debug of cos: signal is "true";
   attribute mark_debug of phase: signal is "true";             
   attribute mark_debug of state: signal is "true";   
   attribute mark_debug of last_point: signal is "true";  
   attribute mark_debug of cnt: signal is "true";    
   attribute mark_debug of raised_cos: signal is "true";  
   attribute mark_debug of new_setpt_lat: signal is "true";   
   attribute mark_debug of diff_setpt: signal is "true";  
   attribute mark_debug of rampout_wdiff: signal is "true";  
   attribute mark_debug of rampout_fp: signal is "true";    
   attribute mark_debug of rampout: signal is "true";  

begin



--24 bits 
-- Input is 3 integer bits (1 sign) and 20 fractional bits
-- Output is 2 integer bits (1 sign) and 20 fractional bits
uut: cordic_sine
  port map (
    aclk                => clk,
    s_axis_phase_tvalid => tenkhz_trig,
    s_axis_phase_tdata  => std_logic_vector(phase_out),
    m_axis_dout_tvalid  => cordic_valid, 
    m_axis_dout_tdata   => cordic_dout
);


sin <= signed(cordic_dout(47 downto 24));
cos <= signed(cordic_dout(23 downto 0));



process(clk)
  begin 
    if (rising_edge(clk)) then
      if (reset = '1') then
        state <= idle;
        phase <= NEG_PI;
        phase_out <= NEG_PI(31 downto 8);
        rampout_wdiff <= 48d"0";
        rampout <= 20d"0";
        raised_cos <= 24d"0";
        rampout_fp <= 24d"0";
        cnt <= (others => '0');
        last_point <= '0';
        smooth_active <= '0';
        new_setpt_prev <= (others => '0');
      
      else
        case (state) is  
          when IDLE =>
            new_setpt_prev <= new_setpt;
            last_point <= '0';
            smooth_active <= '0';
            phase <= NEG_PI;  
            raised_cos <= 24d"0";  
            rampout_wdiff <= 48d"0";                
            -- run if dac setpt changes and dac_opmode is Smooth
            if (new_setpt_prev /= new_setpt) and (mode = "00")then
              old_setpt <= cur_setpt;
              new_setpt_lat <= new_setpt;
              state <= run_ramp;
              phase <= NEG_PI; 
              phase_out <= NEG_PI(31 downto 8);
              cnt <= 20d"0";
              last_point <= '0';
              smooth_active <= '1';
            end if;
                      
          when RUN_RAMP =>  
            if (tenkhz_trig = '1') then
              -- smooth ramp =  old_setpt + (new_setpt - old_setpt) * 0.5 * (1 - cos(i*pi/N)
              
              --this gives a smooth function from 0 to 1
              -- run cosine from -pi/2 to 0 to get output -1 to 1, then add 1 and divide by 2
              raised_cos <= ((resize(cos,24) + to_signed(2**20,24)) srl 1);
                   
              --ramp with difference
              diff_setpt <= resize(new_setpt_lat,24) - resize(old_setpt,24);
              rampout_wdiff <= (resize(new_setpt_lat,24) - resize(old_setpt,24)) * raised_cos;      
              
              --resize back to 24 bits and add old_setpt 
              rampout_fp <= old_setpt + rampout_wdiff(43 downto 20);
              
              --resize back to 20 or 18 bits
              rampout <= rampout_fp(19 downto 0);

              if (last_point = '1') then
                 state <= idle;
              end if;
              
              if (phase > 0) then  
                phase <= (others => '0');
                last_point <= '1';
              else
                cnt <= std_logic_vector(unsigned(cnt) + 1);
                --phase inc comes from ARM, it is (pi*i/N) where N= abs(new_setpt - oldsetpt / ramprate)
                phase <= phase + phase_inc; 
                phase_out <= phase(31 downto 8);
              end if;
            end if;
               
        end case;
      end if;
    end if;
end process;      
    
    
             
end behv;           
          
          
          
  


 
