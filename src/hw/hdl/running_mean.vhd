library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity running_mean is
    port (
        clk         : in  std_logic;
        reset       : in  std_logic;
        sample_in   : in  signed(15 downto 0);
        mean_out    : out signed(15 downto 0)
    );
end entity;

architecture rtl of running_mean is

    constant N : integer := 32;

    type sample_array is array(0 to N-1) of signed(15 downto 0);
    signal buf       : sample_array := (others => (others => '0'));
    signal sum_accum : signed(31 downto 0) := (others => '0');
    signal wr_idx    : integer range 0 to N-1 := 0;
    signal mean_reg  : signed(15 downto 0);

begin

    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                buf       <= (others => (others => '0'));
                sum_accum <= (others => '0');
                wr_idx    <= 0;
                mean_reg  <= (others => '0');

            else
                -- Subtract old sample and add new one
                sum_accum <= sum_accum - resize(buf(wr_idx), 32) + resize(sample_in, 32);

                -- Replace old sample in buffer
                buf(wr_idx) <= sample_in;

                -- Advance circular index
                if wr_idx = N-1 then
                    wr_idx <= 0;
                else
                    wr_idx <= wr_idx + 1;
                end if;

                -- Compute mean (divide by 32 using right shift)
                mean_reg <= resize(sum_accum(31 downto 5), 16); -- >> 5
            end if;
        end if;
    end process;

    mean_out <= mean_reg;

end architecture;


