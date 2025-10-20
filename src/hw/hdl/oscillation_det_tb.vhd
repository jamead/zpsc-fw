library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity oscillation_det_tb is
end entity;

architecture sim of oscillation_det_tb is

-- DUT component
component running_mean
    port (
        clk       : in  std_logic;
        reset     : in  std_logic;
        sample_in : in  signed(15 downto 0);
        mean_out  : out signed(15 downto 0)
    );
end component;

component running_variance
    port (
        clk       : in  std_logic;
        reset     : in  std_logic;
        sample_in : in  signed(15 downto 0);
        variance_out  : out signed(31 downto 0)
    );
end component;



    -- Signals
    signal clk       : std_logic := '0';
    signal reset     : std_logic := '1';
    signal sample_in : signed(15 downto 0) := (others => '0');
    signal mean      : signed(15 downto 0);
    signal variance  : signed(31 downto 0);

    constant CLK_PERIOD : time := 10 ns;

begin

-- Clock generation
clk <= not clk after CLK_PERIOD / 2;

-- DUT instantiation
mean_uut: running_mean
    port map (
        clk       => clk,
        reset     => reset,
        sample_in => sample_in,
        mean_out  => mean
    );

variance_uut: running_variance
    port map (
        clk       => clk,
        reset     => reset,
        sample_in => sample_in,
        variance_out  => variance
    );



    -- Stimulus process
    stim_proc: process
        file infile   : text open read_mode is "/home/mead/chiesa/psc/src/hw/sim/oscillation_det_tb.txt";
        variable inline : line;
        variable val     : integer;
    begin
        -- Reset pulse
        reset <= '1';
        wait for 5 * CLK_PERIOD;
        reset <= '0';

        -- Read all samples
        while not endfile(infile) loop
            readline(infile, inline);
            read(inline, val);
            sample_in <= to_signed(val, 16);
            wait for CLK_PERIOD;
        end loop;

        -- Let last few means propagate
        wait for 50 * CLK_PERIOD;
        report "Simulation finished" severity note;
        wait;
    end process;

end architecture;

