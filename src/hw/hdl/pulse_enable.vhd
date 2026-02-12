library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pulse_enable is 
	port(
		 clk          : in std_logic; 
		 reset        : in std_logic; 
		 en           : in std_logic; -- if '1' use pulsed output, if '0' use static output
		 enable_in    : in std_logic; -- Single channel
		 en_out       : out std_logic; 
		 period_in    : in std_logic_vector(31 downto 0)
	); 
end entity; 

architecture arch of pulse_enable is 

signal pulse_counter : unsigned(31 downto 0); 
signal pulse_enable  : std_logic; 
signal ch_enable     : std_logic; 
signal enable_in_reg : std_logic; 
signal PERIOD        : integer; 

begin 

PERIOD <= to_integer(unsigned(period_in)); 

-- Output selection: pulsed or static
en_out <= ch_enable when en = '1' else enable_in_reg; 

-- Capture input
process(clk)
begin 
    if rising_edge(clk) then 
        if reset = '1' then 
            pulse_enable <= '0'; 
            enable_in_reg <= '0';
        else 
            pulse_enable <= enable_in; 
            enable_in_reg <= enable_in; 
        end if; 
    end if; 
end process; 

-- Pulse generation
process(clk) 
begin 
   if rising_edge(clk) then 
        if reset = '1' then 
            pulse_counter <= (others => '0'); 
            ch_enable <= '0'; 
        else 
            if en = '1' then 
                if pulse_enable = '1' then 
                    if pulse_counter = to_unsigned(PERIOD,32) then 
                        pulse_counter <= (others => '0'); 
                    elsif pulse_counter >= to_unsigned(PERIOD/2,32) then  
                        ch_enable <= '1'; 
                        pulse_counter <= pulse_counter + 1; 
                    else 
                        ch_enable <= '0'; 
                        pulse_counter <= pulse_counter + 1; 
                    end if;     
                else 
                    pulse_counter <= (others => '0'); 
                    ch_enable <= '0';
                end if;             
            else 
                pulse_counter <= (others => '0'); 
            end if;                
        end if; 
    end if; 
end process; 

end architecture;

