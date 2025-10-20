library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity running_variance is
    port (
        clk         : in  std_logic;
        reset       : in  std_logic;
        sample_in   : in  signed(15 downto 0);
        variance_out: out signed(31 downto 0)
    );
end entity;

architecture rtl of running_variance is

    constant N : integer := 32;

    type sample_array is array(0 to N-1) of signed(15 downto 0);
    signal buf        : sample_array := (others => (others => '0'));
    signal sum_x      : signed(31 downto 0) := (others => '0');
    signal sum_x2     : signed(47 downto 0) := (others => '0');
    signal wr_idx     : integer range 0 to N-1 := 0;
    signal variance_s : signed(31 downto 0) := (others => '0');

begin

    process(clk)
        variable x_old, x_new : signed(15 downto 0);
        variable x_old2, x_new2 : signed(63 downto 0);
        variable mean_term, mean_sq, var_val : signed(47 downto 0);
    begin
        if rising_edge(clk) then
            if reset = '1' then
                buf        <= (others => (others => '0'));
                sum_x      <= (others => '0');
                sum_x2     <= (others => '0');
                wr_idx     <= 0;
                variance_s <= (others => '0');

            else
                x_old := buf(wr_idx);
                x_new := sample_in;

                -- update sums
                sum_x  <= sum_x  - resize(x_old, 32) + resize(x_new, 32);
                x_old2 := resize(x_old, 32) * resize(x_old, 32);
                x_new2 := resize(x_new, 32) * resize(x_new, 32);
                sum_x2 <= resize(sum_x2 - resize(x_old2, 48) + resize(x_new2, 48), 48);

                -- update buffer
                buf(wr_idx) <= x_new;
                if wr_idx = N-1 then
                    wr_idx <= 0;
                else
                    wr_idx <= wr_idx + 1;
                end if;

                -- compute variance = E[x^2] - (E[x])^2
                mean_term := resize(sum_x, 48) srl 5;   -- divide by 32
                mean_sq   := resize(mean_term * mean_term,48);
                var_val   := (sum_x2 srl 5) - mean_sq;

                variance_s <= resize(var_val(47 downto 16), 32); -- scale/truncate to 32 bits
            end if;
        end if;
    end process;

    variance_out <= variance_s;

end architecture;

