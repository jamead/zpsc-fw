

create_debug_core u_ila_0 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_0]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_0]
set_property C_DATA_DEPTH 32768 [get_debug_cores u_ila_0]
set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_0]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_0]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
set_property port_width 1 [get_debug_ports u_ila_0/clk]
connect_debug_port u_ila_0/clk [get_nets [list sys/processing_system7_0/inst/FCLK_CLK0]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
set_property port_width 5 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {dig_io/ps1_manch_decoder/u_manchester_rx/bit_cnt[0]} {dig_io/ps1_manch_decoder/u_manchester_rx/bit_cnt[1]} {dig_io/ps1_manch_decoder/u_manchester_rx/bit_cnt[2]} {dig_io/ps1_manch_decoder/u_manchester_rx/bit_cnt[3]} {dig_io/ps1_manch_decoder/u_manchester_rx/bit_cnt[4]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
set_property port_width 12 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list {dig_io/ps1_manch_decoder/u_manchester_rx/ctr[0]} {dig_io/ps1_manch_decoder/u_manchester_rx/ctr[1]} {dig_io/ps1_manch_decoder/u_manchester_rx/ctr[2]} {dig_io/ps1_manch_decoder/u_manchester_rx/ctr[3]} {dig_io/ps1_manch_decoder/u_manchester_rx/ctr[4]} {dig_io/ps1_manch_decoder/u_manchester_rx/ctr[5]} {dig_io/ps1_manch_decoder/u_manchester_rx/ctr[6]} {dig_io/ps1_manch_decoder/u_manchester_rx/ctr[7]} {dig_io/ps1_manch_decoder/u_manchester_rx/ctr[8]} {dig_io/ps1_manch_decoder/u_manchester_rx/ctr[9]} {dig_io/ps1_manch_decoder/u_manchester_rx/ctr[10]} {dig_io/ps1_manch_decoder/u_manchester_rx/ctr[11]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe2]
set_property port_width 12 [get_debug_ports u_ila_0/probe2]
connect_debug_port u_ila_0/probe2 [get_nets [list {dig_io/ps1_manch_decoder/u_manchester_rx/latch_ctr[0]} {dig_io/ps1_manch_decoder/u_manchester_rx/latch_ctr[1]} {dig_io/ps1_manch_decoder/u_manchester_rx/latch_ctr[2]} {dig_io/ps1_manch_decoder/u_manchester_rx/latch_ctr[3]} {dig_io/ps1_manch_decoder/u_manchester_rx/latch_ctr[4]} {dig_io/ps1_manch_decoder/u_manchester_rx/latch_ctr[5]} {dig_io/ps1_manch_decoder/u_manchester_rx/latch_ctr[6]} {dig_io/ps1_manch_decoder/u_manchester_rx/latch_ctr[7]} {dig_io/ps1_manch_decoder/u_manchester_rx/latch_ctr[8]} {dig_io/ps1_manch_decoder/u_manchester_rx/latch_ctr[9]} {dig_io/ps1_manch_decoder/u_manchester_rx/latch_ctr[10]} {dig_io/ps1_manch_decoder/u_manchester_rx/latch_ctr[11]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe3]
set_property port_width 32 [get_debug_ports u_ila_0/probe3]
connect_debug_port u_ila_0/probe3 [get_nets [list {dig_io/ps1_manch_decoder/u_manchester_rx/packet_data[0]} {dig_io/ps1_manch_decoder/u_manchester_rx/packet_data[1]} {dig_io/ps1_manch_decoder/u_manchester_rx/packet_data[2]} {dig_io/ps1_manch_decoder/u_manchester_rx/packet_data[3]} {dig_io/ps1_manch_decoder/u_manchester_rx/packet_data[4]} {dig_io/ps1_manch_decoder/u_manchester_rx/packet_data[5]} {dig_io/ps1_manch_decoder/u_manchester_rx/packet_data[6]} {dig_io/ps1_manch_decoder/u_manchester_rx/packet_data[7]} {dig_io/ps1_manch_decoder/u_manchester_rx/packet_data[8]} {dig_io/ps1_manch_decoder/u_manchester_rx/packet_data[9]} {dig_io/ps1_manch_decoder/u_manchester_rx/packet_data[10]} {dig_io/ps1_manch_decoder/u_manchester_rx/packet_data[11]} {dig_io/ps1_manch_decoder/u_manchester_rx/packet_data[12]} {dig_io/ps1_manch_decoder/u_manchester_rx/packet_data[13]} {dig_io/ps1_manch_decoder/u_manchester_rx/packet_data[14]} {dig_io/ps1_manch_decoder/u_manchester_rx/packet_data[15]} {dig_io/ps1_manch_decoder/u_manchester_rx/packet_data[16]} {dig_io/ps1_manch_decoder/u_manchester_rx/packet_data[17]} {dig_io/ps1_manch_decoder/u_manchester_rx/packet_data[18]} {dig_io/ps1_manch_decoder/u_manchester_rx/packet_data[19]} {dig_io/ps1_manch_decoder/u_manchester_rx/packet_data[20]} {dig_io/ps1_manch_decoder/u_manchester_rx/packet_data[21]} {dig_io/ps1_manch_decoder/u_manchester_rx/packet_data[22]} {dig_io/ps1_manch_decoder/u_manchester_rx/packet_data[23]} {dig_io/ps1_manch_decoder/u_manchester_rx/packet_data[24]} {dig_io/ps1_manch_decoder/u_manchester_rx/packet_data[25]} {dig_io/ps1_manch_decoder/u_manchester_rx/packet_data[26]} {dig_io/ps1_manch_decoder/u_manchester_rx/packet_data[27]} {dig_io/ps1_manch_decoder/u_manchester_rx/packet_data[28]} {dig_io/ps1_manch_decoder/u_manchester_rx/packet_data[29]} {dig_io/ps1_manch_decoder/u_manchester_rx/packet_data[30]} {dig_io/ps1_manch_decoder/u_manchester_rx/packet_data[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe4]
set_property port_width 32 [get_debug_ports u_ila_0/probe4]
connect_debug_port u_ila_0/probe4 [get_nets [list {dig_io/ps1_manch_decoder/u_manchester_rx/pkt_sr[0]} {dig_io/ps1_manch_decoder/u_manchester_rx/pkt_sr[1]} {dig_io/ps1_manch_decoder/u_manchester_rx/pkt_sr[2]} {dig_io/ps1_manch_decoder/u_manchester_rx/pkt_sr[3]} {dig_io/ps1_manch_decoder/u_manchester_rx/pkt_sr[4]} {dig_io/ps1_manch_decoder/u_manchester_rx/pkt_sr[5]} {dig_io/ps1_manch_decoder/u_manchester_rx/pkt_sr[6]} {dig_io/ps1_manch_decoder/u_manchester_rx/pkt_sr[7]} {dig_io/ps1_manch_decoder/u_manchester_rx/pkt_sr[8]} {dig_io/ps1_manch_decoder/u_manchester_rx/pkt_sr[9]} {dig_io/ps1_manch_decoder/u_manchester_rx/pkt_sr[10]} {dig_io/ps1_manch_decoder/u_manchester_rx/pkt_sr[11]} {dig_io/ps1_manch_decoder/u_manchester_rx/pkt_sr[12]} {dig_io/ps1_manch_decoder/u_manchester_rx/pkt_sr[13]} {dig_io/ps1_manch_decoder/u_manchester_rx/pkt_sr[14]} {dig_io/ps1_manch_decoder/u_manchester_rx/pkt_sr[15]} {dig_io/ps1_manch_decoder/u_manchester_rx/pkt_sr[16]} {dig_io/ps1_manch_decoder/u_manchester_rx/pkt_sr[17]} {dig_io/ps1_manch_decoder/u_manchester_rx/pkt_sr[18]} {dig_io/ps1_manch_decoder/u_manchester_rx/pkt_sr[19]} {dig_io/ps1_manch_decoder/u_manchester_rx/pkt_sr[20]} {dig_io/ps1_manch_decoder/u_manchester_rx/pkt_sr[21]} {dig_io/ps1_manch_decoder/u_manchester_rx/pkt_sr[22]} {dig_io/ps1_manch_decoder/u_manchester_rx/pkt_sr[23]} {dig_io/ps1_manch_decoder/u_manchester_rx/pkt_sr[24]} {dig_io/ps1_manch_decoder/u_manchester_rx/pkt_sr[25]} {dig_io/ps1_manch_decoder/u_manchester_rx/pkt_sr[26]} {dig_io/ps1_manch_decoder/u_manchester_rx/pkt_sr[27]} {dig_io/ps1_manch_decoder/u_manchester_rx/pkt_sr[28]} {dig_io/ps1_manch_decoder/u_manchester_rx/pkt_sr[29]} {dig_io/ps1_manch_decoder/u_manchester_rx/pkt_sr[30]} {dig_io/ps1_manch_decoder/u_manchester_rx/pkt_sr[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe5]
set_property port_width 32 [get_debug_ports u_ila_0/probe5]
connect_debug_port u_ila_0/probe5 [get_nets [list {dig_io/ps1_manch_decoder/manch_fifo_data[data][0]} {dig_io/ps1_manch_decoder/manch_fifo_data[data][1]} {dig_io/ps1_manch_decoder/manch_fifo_data[data][2]} {dig_io/ps1_manch_decoder/manch_fifo_data[data][3]} {dig_io/ps1_manch_decoder/manch_fifo_data[data][4]} {dig_io/ps1_manch_decoder/manch_fifo_data[data][5]} {dig_io/ps1_manch_decoder/manch_fifo_data[data][6]} {dig_io/ps1_manch_decoder/manch_fifo_data[data][7]} {dig_io/ps1_manch_decoder/manch_fifo_data[data][8]} {dig_io/ps1_manch_decoder/manch_fifo_data[data][9]} {dig_io/ps1_manch_decoder/manch_fifo_data[data][10]} {dig_io/ps1_manch_decoder/manch_fifo_data[data][11]} {dig_io/ps1_manch_decoder/manch_fifo_data[data][12]} {dig_io/ps1_manch_decoder/manch_fifo_data[data][13]} {dig_io/ps1_manch_decoder/manch_fifo_data[data][14]} {dig_io/ps1_manch_decoder/manch_fifo_data[data][15]} {dig_io/ps1_manch_decoder/manch_fifo_data[data][16]} {dig_io/ps1_manch_decoder/manch_fifo_data[data][17]} {dig_io/ps1_manch_decoder/manch_fifo_data[data][18]} {dig_io/ps1_manch_decoder/manch_fifo_data[data][19]} {dig_io/ps1_manch_decoder/manch_fifo_data[data][20]} {dig_io/ps1_manch_decoder/manch_fifo_data[data][21]} {dig_io/ps1_manch_decoder/manch_fifo_data[data][22]} {dig_io/ps1_manch_decoder/manch_fifo_data[data][23]} {dig_io/ps1_manch_decoder/manch_fifo_data[data][24]} {dig_io/ps1_manch_decoder/manch_fifo_data[data][25]} {dig_io/ps1_manch_decoder/manch_fifo_data[data][26]} {dig_io/ps1_manch_decoder/manch_fifo_data[data][27]} {dig_io/ps1_manch_decoder/manch_fifo_data[data][28]} {dig_io/ps1_manch_decoder/manch_fifo_data[data][29]} {dig_io/ps1_manch_decoder/manch_fifo_data[data][30]} {dig_io/ps1_manch_decoder/manch_fifo_data[data][31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe6]
set_property port_width 32 [get_debug_ports u_ila_0/probe6]
connect_debug_port u_ila_0/probe6 [get_nets [list {dig_io/ps1_manch_decoder/manch_fifo_data[wdcnt][0]} {dig_io/ps1_manch_decoder/manch_fifo_data[wdcnt][1]} {dig_io/ps1_manch_decoder/manch_fifo_data[wdcnt][2]} {dig_io/ps1_manch_decoder/manch_fifo_data[wdcnt][3]} {dig_io/ps1_manch_decoder/manch_fifo_data[wdcnt][4]} {dig_io/ps1_manch_decoder/manch_fifo_data[wdcnt][5]} {dig_io/ps1_manch_decoder/manch_fifo_data[wdcnt][6]} {dig_io/ps1_manch_decoder/manch_fifo_data[wdcnt][7]} {dig_io/ps1_manch_decoder/manch_fifo_data[wdcnt][8]} {dig_io/ps1_manch_decoder/manch_fifo_data[wdcnt][9]} {dig_io/ps1_manch_decoder/manch_fifo_data[wdcnt][10]} {dig_io/ps1_manch_decoder/manch_fifo_data[wdcnt][11]} {dig_io/ps1_manch_decoder/manch_fifo_data[wdcnt][12]} {dig_io/ps1_manch_decoder/manch_fifo_data[wdcnt][13]} {dig_io/ps1_manch_decoder/manch_fifo_data[wdcnt][14]} {dig_io/ps1_manch_decoder/manch_fifo_data[wdcnt][15]} {dig_io/ps1_manch_decoder/manch_fifo_data[wdcnt][16]} {dig_io/ps1_manch_decoder/manch_fifo_data[wdcnt][17]} {dig_io/ps1_manch_decoder/manch_fifo_data[wdcnt][18]} {dig_io/ps1_manch_decoder/manch_fifo_data[wdcnt][19]} {dig_io/ps1_manch_decoder/manch_fifo_data[wdcnt][20]} {dig_io/ps1_manch_decoder/manch_fifo_data[wdcnt][21]} {dig_io/ps1_manch_decoder/manch_fifo_data[wdcnt][22]} {dig_io/ps1_manch_decoder/manch_fifo_data[wdcnt][23]} {dig_io/ps1_manch_decoder/manch_fifo_data[wdcnt][24]} {dig_io/ps1_manch_decoder/manch_fifo_data[wdcnt][25]} {dig_io/ps1_manch_decoder/manch_fifo_data[wdcnt][26]} {dig_io/ps1_manch_decoder/manch_fifo_data[wdcnt][27]} {dig_io/ps1_manch_decoder/manch_fifo_data[wdcnt][28]} {dig_io/ps1_manch_decoder/manch_fifo_data[wdcnt][29]} {dig_io/ps1_manch_decoder/manch_fifo_data[wdcnt][30]} {dig_io/ps1_manch_decoder/manch_fifo_data[wdcnt][31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe7]
set_property port_width 1 [get_debug_ports u_ila_0/probe7]
connect_debug_port u_ila_0/probe7 [get_nets [list {dig_io/ps1_manch_decoder/manch_fifo_cntrl[reset]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe8]
set_property port_width 1 [get_debug_ports u_ila_0/probe8]
connect_debug_port u_ila_0/probe8 [get_nets [list dig_io/ps1_manch_decoder/u_manchester_rx/edge_det]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe9]
set_property port_width 1 [get_debug_ports u_ila_0/probe9]
connect_debug_port u_ila_0/probe9 [get_nets [list tenkhz_trig]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe10]
set_property port_width 1 [get_debug_ports u_ila_0/probe10]
connect_debug_port u_ila_0/probe10 [get_nets [list dig_io/ps1_manch_decoder/u_manchester_rx/first_center]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe11]
set_property port_width 1 [get_debug_ports u_ila_0/probe11]
connect_debug_port u_ila_0/probe11 [get_nets [list dig_io/ps1_manch_decoder/u_manchester_rx/latch_bit]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe12]
set_property port_width 1 [get_debug_ports u_ila_0/probe12]
connect_debug_port u_ila_0/probe12 [get_nets [list dig_io/ps1_manch_decoder/u_manchester_rx/packet_valid]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe13]
set_property port_width 1 [get_debug_ports u_ila_0/probe13]
connect_debug_port u_ila_0/probe13 [get_nets [list dig_io/ps1_manch_decoder/u_manchester_rx/manch_in]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe14]
set_property port_width 1 [get_debug_ports u_ila_0/probe14]
connect_debug_port u_ila_0/probe14 [get_nets [list dig_io/ps1_manch_decoder/u_manchester_rx/rx_locked]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe15]
set_property port_width 1 [get_debug_ports u_ila_0/probe15]
connect_debug_port u_ila_0/probe15 [get_nets [list dig_io/ps1_manch_decoder/fifo_rdstr_fe]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe16]
set_property port_width 1 [get_debug_ports u_ila_0/probe16]
connect_debug_port u_ila_0/probe16 [get_nets [list {dig_io/ps1_manch_decoder/manch_fifo_cntrl[rdstr]}]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets pl_clk0]
