library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity live_time is
  generic (
    CLK_FREQ_HZ : natural := 100_000_000
  );
  port (
    clk             : in  std_logic;
    rst             : in  std_logic;

    seconds         : out std_logic_vector(31 downto 0);
    tenths          : out std_logic_vector(31 downto 0);

    tenth_sec_pulse : out std_logic;
    one_sec_pulse   : out std_logic
  );
end entity live_time;

architecture rtl of live_time is

  constant TENTH_SEC_COUNT : natural := CLK_FREQ_HZ / 10;

  -- 100 MHz / 10 = 10,000,000 clocks
  -- Need 24 bits because 2^24 = 16,777,216
  signal clk_cnt   : unsigned(23 downto 0) := (others => '0');

  -- Full running counters
  signal sec_cnt   : unsigned(31 downto 0) := (others => '0');
  signal tenth_cnt : unsigned(31 downto 0) := (others => '0');

  -- Counts 0 to 9 to generate exact 1 second pulse
  signal tenth_div : unsigned(3 downto 0) := (others => '0');

begin

  process(clk)
  begin
    if rising_edge(clk) then

      tenth_sec_pulse <= '0';
      one_sec_pulse   <= '0';

      if rst = '1' then
        clk_cnt   <= (others => '0');
        sec_cnt   <= (others => '0');
        tenth_cnt <= (others => '0');
        tenth_div <= (others => '0');

      else

        if clk_cnt = TENTH_SEC_COUNT - 1 then
          clk_cnt <= (others => '0');

          -- Increment every 0.1 second
          tenth_cnt <= tenth_cnt + 1;
          tenth_sec_pulse <= '1';

          -- Increment seconds every 10 tenths
          if tenth_div = 9 then
            tenth_div <= (others => '0');
            sec_cnt <= sec_cnt + 1;
            one_sec_pulse <= '1';
          else
            tenth_div <= tenth_div + 1;
          end if;

        else
          clk_cnt <= clk_cnt + 1;
        end if;

      end if;
    end if;
  end process;

  seconds <= std_logic_vector(sec_cnt);
  tenths  <= std_logic_vector(tenth_cnt);

end architecture rtl;