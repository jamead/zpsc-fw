--=============================================================================
-- Manchester Decoder - 32-bit Packet Receiver
--
-- Description:
--   This module receives Manchester-encoded serial data and reconstructs
--   fixed-length 32-bit packets. The decoder is designed for a 100 MHz FPGA
--   clock and a nominal Manchester data rate of 50 kbps.
--
-- Manchester Encoding Convention:
--     Data '0' : High-to-Low transition at the center of the bit period
--     Data '1' : Low-to-High transition at the center of the bit period
--
-- Bit Ordering:
--     Data is transmitted and received Most Significant Bit (MSB) first.
--     The first decoded bit becomes packet_data(31) and the last decoded
--     bit becomes packet_data(0).
--
-- Operation:
--   1. The incoming asynchronous signal is synchronized to the FPGA clock.
--   2. Input transitions are detected and used to recover bit timing.
--   3. The first detected edge establishes timing lock.
--   4. Subsequent center-of-bit transitions are decoded into data bits,
--      while boundary transitions are ignored.
--   5. Decoded bits are shifted into a 32-bit register.
--   6. After 32 bits have been received, packet_valid is asserted for one
--      clock cycle and packet_data contains the received 32-bit word.
--
-- Features:
--   • Self-clocking Manchester receiver
--   • MSB-first 32-bit packet format
--   • Adjustable timing tolerance via TOL_PERCENT generic
--   • Automatic loss-of-lock detection
--   • Fixed-length 32-bit packet output
--   • No variables used in the implementation
--
-- Parameters:
--   CLK_FREQ_HZ   : FPGA clock frequency
--   DATA_RATE_BPS : Manchester data rate
--   TOL_PERCENT   : Allowed timing error percentage
--
-- Example:
--   For CLK_FREQ_HZ = 100 MHz and DATA_RATE_BPS = 50 kbps:
--       Bit period      = 20 us (2000 clocks)
--       Half-bit period = 10 us (1000 clocks)
--
-- Author: ChatGPT / OpenAI
--=============================================================================




library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity manchester_rx_32 is
  generic (
    CLK_FREQ_HZ   : integer := 100_000_000;
    DATA_RATE_BPS : integer := 50_000;
    TOL_PERCENT   : integer := 35
  );
  port (
    clk          : in  std_logic;
    rst          : in  std_logic;
    manch_in     : in  std_logic;

    packet_valid : out std_logic;
    packet_data  : out std_logic_vector(31 downto 0);

    rx_locked    : out std_logic;
    rx_error     : out std_logic
  );
end entity;

architecture rtl of manchester_rx_32 is

  constant BIT_CLKS  : integer := CLK_FREQ_HZ / DATA_RATE_BPS;
  constant HALF_CLKS : integer := BIT_CLKS / 2;
  constant TOL_CLKS  : integer := HALF_CLKS * TOL_PERCENT / 100;

  signal rx_meta : std_logic := '0';
  signal rx_sync : std_logic := '0';
  signal rx_last : std_logic := '0';

  signal edge_det    : std_logic;
  signal decoded_bit : std_logic;

  signal locked       : std_logic := '0';
  signal first_center : std_logic := '0';

  signal ctr        : integer range 0 to BIT_CLKS * 2 := 0;
  signal latch_ctr  : integer range 0 to BIT_CLKS * 2 := 0;
  signal pkt_sr  : std_logic_vector(31 downto 0) := (others => '0');
  signal bit_cnt : integer range 0 to 31 := 0;

  signal packet_valid_i : std_logic := '0';
  signal packet_valid_d : std_logic := '0';
  
  signal latch_bit      : std_logic := '0';

  
  
  attribute mark_debug                 : string;
  attribute mark_debug of manch_in : signal is "true";
  attribute mark_debug of rx_locked : signal is "true";
  attribute mark_debug of edge_det : signal is "true";  
  attribute mark_debug of bit_cnt : signal is "true";  
  attribute mark_debug of ctr : signal is "true";     
  attribute mark_debug of rx_locked : signal is "true";  
  attribute mark_debug of packet_data: signal is "true";
  attribute mark_debug of packet_valid: signal is "true";
  attribute mark_debug of first_center: signal is "true";
  attribute mark_debug of pkt_sr: signal is "true";
  attribute mark_debug of latch_bit: signal is "true";
  attribute mark_debug of latch_ctr: signal is "true";

begin

  rx_locked    <= locked;
  packet_valid <= packet_valid_d;

  edge_det    <= rx_sync xor rx_last;
  decoded_bit <= rx_sync;

  process(clk)
  begin
    if rising_edge(clk) then

      if rst = '1' then
        rx_meta        <= '0';
        rx_sync        <= '0';
        rx_last        <= '0';

        locked         <= '0';
        first_center   <= '0';
        ctr            <= 0;

        pkt_sr         <= (others => '0');
        bit_cnt        <= 0;

        packet_valid_i <= '0';
        packet_valid_d <= '0';
        packet_data    <= (others => '0');

        rx_error       <= '0';
        
        latch_bit      <= '0';
        latch_ctr      <= 0; 

      else
        latch_bit <= '0';
        packet_valid_i <= '0';
        packet_valid_d <= packet_valid_i;
        rx_error       <= '0';

        rx_meta <= manch_in;
        rx_sync <= rx_meta;
        rx_last <= rx_sync;

        -- on first edge only
        if locked = '0' then

          ctr <= 0;

          if edge_det = '1' then
            locked       <= '1';
            first_center <= '1';
            ctr          <= 0;
            bit_cnt      <= 0;
            pkt_sr       <= (others => '0');
          end if;


        else

          if ctr < BIT_CLKS * 2 then
            ctr <= ctr + 1;
          end if;

          if edge_det = '1' then

            if first_center = '1' then
               
              if abs(ctr - HALF_CLKS) <= TOL_CLKS then
                latch_ctr <= ctr;
                latch_bit <= '1';
                first_center <= '0';
                ctr          <= 0;

                pkt_sr <= pkt_sr(30 downto 0) & decoded_bit;

                if bit_cnt = 31 then
                  bit_cnt        <= 0;
                  packet_valid_i <= '1';
                  packet_data    <= pkt_sr(30 downto 0) & decoded_bit;
                else
                  bit_cnt <= bit_cnt + 1;
                end if;

              else
                locked       <= '0';
                first_center <= '0';
                ctr          <= 0;
                bit_cnt      <= 0;
                pkt_sr       <= (others => '0');
                rx_error     <= '1';
              end if;

            else

              if abs(ctr - HALF_CLKS) <= TOL_CLKS then
                null;

              elsif abs(ctr - BIT_CLKS) <= TOL_CLKS then
                ctr <= 0;
                latch_ctr <= ctr;
                latch_bit <= '1';
                
                pkt_sr <= pkt_sr(30 downto 0) & decoded_bit;

                if bit_cnt = 31 then
                  bit_cnt        <= 0;
                  packet_valid_i <= '1';
                  packet_data    <= pkt_sr(30 downto 0) & decoded_bit;
                else
                  bit_cnt <= bit_cnt + 1;
                end if;

              else
                locked       <= '0';
                first_center <= '0';
                ctr          <= 0;
                bit_cnt      <= 0;
                pkt_sr       <= (others => '0');
                rx_error     <= '1';
              end if;

            end if;

          elsif ctr > BIT_CLKS + TOL_CLKS then
            locked       <= '0';
            first_center <= '0';
            ctr          <= 0;
            bit_cnt      <= 0;
            pkt_sr       <= (others => '0');
            rx_error     <= '1';
          end if;

        end if;
      end if;
    end if;
  end process;

end architecture;

