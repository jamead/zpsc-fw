-------------------------------------------------------------------------------
-- Title       : Manchester Decoder Wrapper
-- File        : manch_decoder.vhd
-- Description :
--   Combines the 32-bit Manchester receiver with the Manchester data FIFO.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.psc_pkg.ALL;

entity manch_decoder is
  port (
    clk        : in  std_logic;
    reset      : in  std_logic;
    manch_in   : in  std_logic;

    manch_fifo_cntrl   : in t_manch_fifo_cntrl_onech;
    manch_fifo_data    : out t_manch_fifo_data_onech

  );
end entity manch_decoder;


architecture behv of manch_decoder is

  signal packet_valid : std_logic;
  signal packet_data  : std_logic_vector(31 downto 0);
  signal wdcnt        : std_logic_vector(6 downto 0);
  
  signal fifo_rdstr_prev   : std_logic;
  signal fifo_rdstr_fe     : std_logic;
  signal rx_locked         : std_logic;
  signal rx_error          : std_logic;


  attribute mark_debug                 : string;
  attribute mark_debug of manch_fifo_cntrl : signal is "true";
  attribute mark_debug of manch_fifo_data : signal is "true";
  attribute mark_debug of fifo_rdstr_fe   : signal is "true";



begin


manch_fifo_data.wdcnt <= 25d"0" & wdcnt;


  ---------------------------------------------------------------------------
  -- 32-bit Manchester receiver
  ---------------------------------------------------------------------------
u_manchester_rx : entity work.manchester_rx_32
    generic map (
      CLK_FREQ_HZ   => 100_000_000,
      DATA_RATE_BPS => 50_000,
      TOL_PERCENT   => 35
    )
    port map (
      clk          => clk,
      rst          => reset,
      manch_in     => manch_in,
      packet_valid => packet_valid,
      packet_data  => packet_data,
      rx_locked    => rx_locked,
      rx_error     => rx_error
    );


  ---------------------------------------------------------------------------
  -- Manchester packet FIFO
  ---------------------------------------------------------------------------

--since fifo is fall-through mode, want the rdstr
--to happen after the current word is read.
process (reset,clk)
   begin
       if (reset = '1') then
          fifo_rdstr_prev <= '0';
          fifo_rdstr_fe <= '0';
       elsif (clk'event and clk = '1') then
          fifo_rdstr_prev <= manch_fifo_cntrl.rdstr;
          if (manch_fifo_cntrl.rdstr = '0' and fifo_rdstr_prev = '1') then
              fifo_rdstr_fe <= '1'; --falling edge of rdstr
          else
              fifo_rdstr_fe <= '0';
          end if;
       end if;
end process;




u_manchdata_fifo : entity work.manchdata_fifo
    port map (
      clk        => clk,
      srst       => manch_fifo_cntrl.reset,
      din        => packet_data,
      wr_en      => packet_valid,
      rd_en      => manch_fifo_cntrl.rdstr, --fifo_rdstr_fe, 
      dout       => manch_fifo_data.data,
      full       => open, 
      empty      => open, 
      data_count => wdcnt
    );

end architecture behv;
