-------------------------------------------------------------------------------
-- Title         : DCCT ADC module
-------------------------------------------------------------------------------
-- File          : DCCT_ADC_module.vhd
-- Author        : Thomas Chiesa tchiesa@bnl.gov
-- Created       : 07/19/2020
-------------------------------------------------------------------------------
-- Description:
-- This progam contains the 8 DCCT ADCs with gain and offset control. 

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Modification history:
-- 07/19/2020: created.
-------------------------------------------------------------------------------
library IEEE;
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all; 


entity adc_ltc2376 is
port (
        --Control inputs
        clk          : in std_logic; 
        reset        : in std_logic; 
        start        : in std_logic; 
        resolution   : in std_logic;
        --ADC Inputs
        busy         : in std_logic; 
        sdi          : in std_logic; 
        --ADC Outputs
        cnv          : out std_logic; 
        sclk         : out std_logic; 
        sdo          : out std_logic;
        dcct1        : out signed(19 downto 0);
        dcct2        : out signed(19 downto 0);
        data_rdy     : out std_logic
       );
end entity;

architecture arch of adc_ltc2376 is
  
  type state_type is (IDLE,SET_CNV,WAIT_FOR_NOT_BUSY,SCLK_HI,SCLK_LO,DONE); 
  constant CNV_PULSE : natural := 10; --2 clock counts, 40ns, datasheet specifies min of 20ns
  constant CNV_WIDTH : natural := 51; --slightly more than 3us, max wait is 3us according to datasheet

  signal state       : state_type; 
  signal shift_reg   : std_logic_vector(39 downto 0); 
  signal cnv_count   : natural range 0 to 500 := 0; 
  signal bit_count   : natural range 0 to 500 := 0; 
  signal num_bits    : integer range 0 to 40  := 0;
  signal clk_enb     : std_logic;  
  signal clk_cnt     : std_logic_vector(7 downto 0);  
  signal start_lat   : std_logic;

--debug signals (connect to ila)
--   attribute mark_debug                 : string;
--   attribute mark_debug of clk_enb: signal is "true";
--   attribute mark_debug of start_lat: signal is "true";
--   attribute mark_debug of state  : signal is "true";
--   attribute mark_debug of cnv     : signal is "true";
--   attribute mark_debug of sclk  : signal is "true";
--   attribute mark_debug of sdi     : signal is "true";
--   attribute mark_debug of dcct1  : signal is "true";
--   attribute mark_debug of dcct2  : signal is "true";
--   attribute mark_debug of num_bits     : signal is "true";
--   attribute mark_debug of bit_count     : signal is "true";
--   attribute mark_debug of data_rdy     : signal is "true";
--   attribute mark_debug of start     : signal is "true";
--   attribute mark_debug of shift_reg     : signal is "true";  
   

begin

--HS=0, MS=1
num_bits <= 36 when resolution = '0' else 40;



process(clk) 
begin 
  if rising_edge(clk) then 
    if reset = '1' then 
      cnv_count <= 0; 
      bit_count <= 0;
      shift_reg <= (others => '0');
      dcct1 <= 20d"0";
      dcct2 <= 20d"0";
      data_rdy  <= '0';
      cnv <= '0';
      start_lat <= '0';
      state <= IDLE;      
    else 
      if (start = '1') then
        start_lat <= '1';
      end if;  
      if (clk_enb = '1') then
        case(state) is 
          --IDLE: wait for start trigger
           when IDLE => 
              if start_lat = '1' then 
                 state <= SET_CNV; 
                 start_lat <= '0';
              end if;  
              bit_count <= num_bits-1;               
              sclk     <= '0'; 
              data_rdy <= '0'; 
                    
           --SET_CNV: set cnv signal high for at least
           --2 clocks datasheet specifies a min of 20ns 
           when SET_CNV => 
              if cnv_count = CNV_PULSE then 
                 cnv <= '0'; 
                 cnv_count <= 0; 
                 state <= WAIT_FOR_NOT_BUSY; 
              else 
                 cnv <= '1'; 
                 cnv_count <= cnv_count +1; 
               end if;       
                    
           --WAIT_FOR_NOT_BUSY: wait for busy to go low, then 
           --transition to starting sclk      
           when WAIT_FOR_NOT_BUSY => 
              if cnv_count = CNV_WIDTH then 
                 cnv_count     <= 0;
                 state <= SCLK_HI;      
              else 
                 cnv_count <= cnv_count +1;
              end if; 
                                              
           when SCLK_HI =>  
                shift_reg(bit_count) <= sdi;
                state <= SCLK_LO; 
                sclk <= '1';

           when SCLK_LO => 
                sclk <= '0';
                bit_count <= bit_count - 1; 
                if bit_count = 0 then                                   
                   state <= DONE;           
                else               
                   state <= SCLK_HI; 
                end if;     
     
           when DONE => 
                if (resolution = '0') then
                   dcct2 <= resize(signed(shift_reg(35 downto 18)),20); 
                   dcct1 <= resize(signed(shift_reg(17 downto 0)),20);
                else
                   dcct2 <= signed(shift_reg(39 downto 20));
                   dcct1 <= signed(shift_reg(19 downto 0));
                end if;
                bit_count <= 0; 
                data_rdy <= '1';
                state <= idle;                 
                
           when others => 
                state <= IDLE;
        end case; 
      end if; 
    end if;
  end if; 
end process; 



-- creates a 100ns clk enable pulse
clkdivide : process(clk, reset)
  begin
     if (rising_edge(clk)) then
       if (reset = '1') then  
          clk_cnt <= (others => '0');
          clk_enb <= '0';
       else
          clk_cnt <= std_logic_vector(unsigned(clk_cnt) + 1);
          if (clk_cnt = 8d"4") then  
             clk_cnt <= 8d"0";
		 	 clk_enb <= '1';
		  else 	 
		 	 clk_enb <= '0'; 
		  end if;
	   end if;
    end if;
end process; 




end architecture;
