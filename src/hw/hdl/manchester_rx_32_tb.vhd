library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_manchester_rx_32 is
end entity;

architecture sim of tb_manchester_rx_32 is

  constant CLK_FREQ_HZ   : integer := 100_000_000;
  constant DATA_RATE_BPS : integer := 50_000;

  constant CLK_PERIOD : time := 10 ns;
  constant BIT_TIME   : time := 20 us;
  constant HALF_TIME  : time := 10 us;

  signal clk          : std_logic := '0';
  signal rst          : std_logic := '1';

  signal manch_in     : std_logic := '0';

  signal packet_valid : std_logic;
  signal packet_data  : std_logic_vector(31 downto 0);

  signal rx_locked    : std_logic;
  signal rx_error     : std_logic;

begin

  clk <= not clk after CLK_PERIOD / 2;

  dut : entity work.manchester_rx_32
    generic map (
      CLK_FREQ_HZ   => CLK_FREQ_HZ,
      DATA_RATE_BPS => DATA_RATE_BPS,
      TOL_PERCENT   => 25
    )
    port map (
      clk          => clk,
      rst          => rst,

      manch_in     => manch_in,

      packet_valid => packet_valid,
      packet_data  => packet_data,

      rx_locked    => rx_locked,
      rx_error     => rx_error
    );

  stim : process

    procedure send_bit(b : std_logic) is
    begin
      -- Manchester encoding:
      -- 0 = high then low
      -- 1 = low then high

      if b = '0' then
        manch_in <= '1';
        wait for HALF_TIME;
        manch_in <= '0';
        wait for HALF_TIME;
      else
        manch_in <= '0';
        wait for HALF_TIME;
        manch_in <= '1';
        wait for HALF_TIME;
      end if;
    end procedure;

    procedure send_packet(d : std_logic_vector(31 downto 0)) is
    begin
      -- MSB first
      for i in 31 downto 0 loop
        send_bit(d(i));
      end loop;
    end procedure;

  begin

    rst <= '1';
    manch_in <= '0';
    wait for 2 us;

    rst <= '0';
    wait for 200 us;

    -- Optional preamble to help receiver lock
    send_packet(x"55555555");
    send_packet(x"55555555");

    -- Real 32-bit packets
    send_packet(x"50534344"); -- "PSCD"
    send_packet(x"52560001"); -- "RV" + version/type example
    send_packet(x"12345678");
    --send_packet(x"ABCDEF01");
    --send_packet(x"00000000");
    --send_packet(x"FFFFFFFF");

    wait for 200 us;

    report "Simulation complete";
    wait;

  end process;

  monitor : process(clk)
  begin
    if rising_edge(clk) then

      if packet_valid = '1' then
        report "RX packet = 0x" & to_hstring(packet_data);
      end if;

      if rx_error = '1' then
        report "Manchester RX error";
      end if;

    end if;
  end process;

end architecture;
