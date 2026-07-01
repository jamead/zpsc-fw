library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.psc_pkg.all; 



entity fofb_flt2fix is
  port (
    fofb_clk       : in std_logic;
    pl_clk0        : in std_logic;
    fofb_new       : in std_logic;
    fofb_setpt_flt : in std_logic_vector(31 downto 0);
    scale_factor   : in std_logic_vector(31 downto 0);
    fofb_setpt     : out signed(19 downto 0)
);
end entity fofb_flt2fix;


architecture behv of fofb_flt2fix is

  signal setptout_fp       : std_logic_vector(23 downto 0); 
  signal setpt_scaled      : std_logic_vector(31 downto 0);
  signal setpt             : std_logic_vector(19 downto 0);
  signal test              : signed(19 downto 0);
  
  signal fofb_data_toggle  : std_logic := '0';
  signal data_toggle_meta  : std_logic := '0';
  signal data_toggle_sync1 : std_logic := '0';
  signal data_toggle_sync2 : std_logic := '0';
  signal data_toggle_prev  : std_logic := '0';
  signal fofb_valid        : std_logic := '0';
  signal mult_valid        : std_logic;
  signal data_rdy          : std_logic;

--  attribute mark_debug : string;  
--  attribute mark_debug of fofb_new: signal is "true";
--  attribute mark_debug of mult_valid: signal is "true";
--  attribute mark_debug of fofb_valid: signal is "true"; 
--  attribute mark_debug of setpt_scaled: signal is "true";
--  attribute mark_debug of setptout_fp: signal is "true";
--  attribute mark_debug of fofb_setpt: signal is "true";
--  attribute mark_debug of data_rdy: signal is "true";

begin


-- Scale to 20 bit dac  (scalefactor from ARM, Volts/Amp * DACVOLTSTOBITS)
scaleps1: entity work.fp_mult
  port map (
    aclk  => fofb_clk,
    s_axis_a_tvalid => '1',  
    s_axis_a_tdata => scale_factor,
    s_axis_b_tvalid => fofb_new,
    s_axis_b_tdata => fofb_setpt_flt,
    m_axis_result_tvalid => mult_valid, 
    m_axis_result_tdata => setpt_scaled
 );


-- Convert to Fixed20 and Output to DAC
setpt_outps1 : entity work.float_to_fix
  PORT MAP (
    aclk => fofb_clk,
    s_axis_a_tvalid => mult_valid, 
    s_axis_a_tdata => setpt_scaled,
    m_axis_result_tvalid => fofb_valid, 
    m_axis_result_tdata => setptout_fp
  );


--sync to pl_clk0 domain
process(fofb_clk)
begin
  if rising_edge(fofb_clk) then
    if fofb_valid = '1' then  
      setpt <= setptout_fp(19 downto 0);       
      fofb_data_toggle <= not fofb_data_toggle; 
    end if;
  end if;
end process;


-- synchronize toggle across domains
process(pl_clk0)
begin
  if rising_edge(pl_clk0) then
    data_toggle_meta  <= fofb_data_toggle;
    data_toggle_sync1 <= data_toggle_meta;
    data_toggle_sync2 <= data_toggle_sync1;

    if data_toggle_sync2 /= data_toggle_prev then
      fofb_setpt <= signed(setpt); 
      data_rdy <= '1';
    else 
      data_rdy <= '0';
    end if;

    data_toggle_prev <= data_toggle_sync2;
    
  end if;
end process;




end architecture behv;
