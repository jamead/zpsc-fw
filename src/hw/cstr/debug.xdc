create_debug_core u_ila_0 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_0]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_0]
set_property C_DATA_DEPTH 2048 [get_debug_cores u_ila_0]
set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_0]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_0]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
set_property port_width 1 [get_debug_ports u_ila_0/clk]
connect_debug_port u_ila_0/clk [get_nets [list sys/processing_system7_0/inst/FCLK_CLK0]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
set_property port_width 16 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {read_mon_adcs/count[0]} {read_mon_adcs/count[1]} {read_mon_adcs/count[2]} {read_mon_adcs/count[3]} {read_mon_adcs/count[4]} {read_mon_adcs/count[5]} {read_mon_adcs/count[6]} {read_mon_adcs/count[7]} {read_mon_adcs/count[8]} {read_mon_adcs/count[9]} {read_mon_adcs/count[10]} {read_mon_adcs/count[11]} {read_mon_adcs/count[12]} {read_mon_adcs/count[13]} {read_mon_adcs/count[14]} {read_mon_adcs/count[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
set_property port_width 32 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list {adc2ddr/datacnt[0]} {adc2ddr/datacnt[1]} {adc2ddr/datacnt[2]} {adc2ddr/datacnt[3]} {adc2ddr/datacnt[4]} {adc2ddr/datacnt[5]} {adc2ddr/datacnt[6]} {adc2ddr/datacnt[7]} {adc2ddr/datacnt[8]} {adc2ddr/datacnt[9]} {adc2ddr/datacnt[10]} {adc2ddr/datacnt[11]} {adc2ddr/datacnt[12]} {adc2ddr/datacnt[13]} {adc2ddr/datacnt[14]} {adc2ddr/datacnt[15]} {adc2ddr/datacnt[16]} {adc2ddr/datacnt[17]} {adc2ddr/datacnt[18]} {adc2ddr/datacnt[19]} {adc2ddr/datacnt[20]} {adc2ddr/datacnt[21]} {adc2ddr/datacnt[22]} {adc2ddr/datacnt[23]} {adc2ddr/datacnt[24]} {adc2ddr/datacnt[25]} {adc2ddr/datacnt[26]} {adc2ddr/datacnt[27]} {adc2ddr/datacnt[28]} {adc2ddr/datacnt[29]} {adc2ddr/datacnt[30]} {adc2ddr/datacnt[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe2]
set_property port_width 3 [get_debug_ports u_ila_0/probe2]
connect_debug_port u_ila_0/probe2 [get_nets [list {adc2ddr/s_axi4_m2s[awsize][0]} {adc2ddr/s_axi4_m2s[awsize][1]} {adc2ddr/s_axi4_m2s[awsize][2]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe3]
set_property port_width 1 [get_debug_ports u_ila_0/probe3]
connect_debug_port u_ila_0/probe3 [get_nets [list {adc2ddr/s_axi4_m2s[awlock][0]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe4]
set_property port_width 3 [get_debug_ports u_ila_0/probe4]
connect_debug_port u_ila_0/probe4 [get_nets [list {adc2ddr/s_axi4_m2s[awprot][0]} {adc2ddr/s_axi4_m2s[awprot][1]} {adc2ddr/s_axi4_m2s[awprot][2]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe5]
set_property port_width 4 [get_debug_ports u_ila_0/probe5]
connect_debug_port u_ila_0/probe5 [get_nets [list {adc2ddr/s_axi4_m2s[awqos][0]} {adc2ddr/s_axi4_m2s[awqos][1]} {adc2ddr/s_axi4_m2s[awqos][2]} {adc2ddr/s_axi4_m2s[awqos][3]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe6]
set_property port_width 32 [get_debug_ports u_ila_0/probe6]
connect_debug_port u_ila_0/probe6 [get_nets [list {adc2ddr/s_axi4_m2s[awaddr][0]} {adc2ddr/s_axi4_m2s[awaddr][1]} {adc2ddr/s_axi4_m2s[awaddr][2]} {adc2ddr/s_axi4_m2s[awaddr][3]} {adc2ddr/s_axi4_m2s[awaddr][4]} {adc2ddr/s_axi4_m2s[awaddr][5]} {adc2ddr/s_axi4_m2s[awaddr][6]} {adc2ddr/s_axi4_m2s[awaddr][7]} {adc2ddr/s_axi4_m2s[awaddr][8]} {adc2ddr/s_axi4_m2s[awaddr][9]} {adc2ddr/s_axi4_m2s[awaddr][10]} {adc2ddr/s_axi4_m2s[awaddr][11]} {adc2ddr/s_axi4_m2s[awaddr][12]} {adc2ddr/s_axi4_m2s[awaddr][13]} {adc2ddr/s_axi4_m2s[awaddr][14]} {adc2ddr/s_axi4_m2s[awaddr][15]} {adc2ddr/s_axi4_m2s[awaddr][16]} {adc2ddr/s_axi4_m2s[awaddr][17]} {adc2ddr/s_axi4_m2s[awaddr][18]} {adc2ddr/s_axi4_m2s[awaddr][19]} {adc2ddr/s_axi4_m2s[awaddr][20]} {adc2ddr/s_axi4_m2s[awaddr][21]} {adc2ddr/s_axi4_m2s[awaddr][22]} {adc2ddr/s_axi4_m2s[awaddr][23]} {adc2ddr/s_axi4_m2s[awaddr][24]} {adc2ddr/s_axi4_m2s[awaddr][25]} {adc2ddr/s_axi4_m2s[awaddr][26]} {adc2ddr/s_axi4_m2s[awaddr][27]} {adc2ddr/s_axi4_m2s[awaddr][28]} {adc2ddr/s_axi4_m2s[awaddr][29]} {adc2ddr/s_axi4_m2s[awaddr][30]} {adc2ddr/s_axi4_m2s[awaddr][31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe7]
set_property port_width 2 [get_debug_ports u_ila_0/probe7]
connect_debug_port u_ila_0/probe7 [get_nets [list {adc2ddr/s_axi4_m2s[awburst][0]} {adc2ddr/s_axi4_m2s[awburst][1]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe8]
set_property port_width 8 [get_debug_ports u_ila_0/probe8]
connect_debug_port u_ila_0/probe8 [get_nets [list {adc2ddr/s_axi4_m2s[awlen][0]} {adc2ddr/s_axi4_m2s[awlen][1]} {adc2ddr/s_axi4_m2s[awlen][2]} {adc2ddr/s_axi4_m2s[awlen][3]} {adc2ddr/s_axi4_m2s[awlen][4]} {adc2ddr/s_axi4_m2s[awlen][5]} {adc2ddr/s_axi4_m2s[awlen][6]} {adc2ddr/s_axi4_m2s[awlen][7]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe9]
set_property port_width 2 [get_debug_ports u_ila_0/probe9]
connect_debug_port u_ila_0/probe9 [get_nets [list {adc2ddr/s_axi4_s2m[bresp][0]} {adc2ddr/s_axi4_s2m[bresp][1]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe10]
set_property port_width 32 [get_debug_ports u_ila_0/probe10]
connect_debug_port u_ila_0/probe10 [get_nets [list {adc2ddr/s_axi4_m2s[wdata][0]} {adc2ddr/s_axi4_m2s[wdata][1]} {adc2ddr/s_axi4_m2s[wdata][2]} {adc2ddr/s_axi4_m2s[wdata][3]} {adc2ddr/s_axi4_m2s[wdata][4]} {adc2ddr/s_axi4_m2s[wdata][5]} {adc2ddr/s_axi4_m2s[wdata][6]} {adc2ddr/s_axi4_m2s[wdata][7]} {adc2ddr/s_axi4_m2s[wdata][8]} {adc2ddr/s_axi4_m2s[wdata][9]} {adc2ddr/s_axi4_m2s[wdata][10]} {adc2ddr/s_axi4_m2s[wdata][11]} {adc2ddr/s_axi4_m2s[wdata][12]} {adc2ddr/s_axi4_m2s[wdata][13]} {adc2ddr/s_axi4_m2s[wdata][14]} {adc2ddr/s_axi4_m2s[wdata][15]} {adc2ddr/s_axi4_m2s[wdata][16]} {adc2ddr/s_axi4_m2s[wdata][17]} {adc2ddr/s_axi4_m2s[wdata][18]} {adc2ddr/s_axi4_m2s[wdata][19]} {adc2ddr/s_axi4_m2s[wdata][20]} {adc2ddr/s_axi4_m2s[wdata][21]} {adc2ddr/s_axi4_m2s[wdata][22]} {adc2ddr/s_axi4_m2s[wdata][23]} {adc2ddr/s_axi4_m2s[wdata][24]} {adc2ddr/s_axi4_m2s[wdata][25]} {adc2ddr/s_axi4_m2s[wdata][26]} {adc2ddr/s_axi4_m2s[wdata][27]} {adc2ddr/s_axi4_m2s[wdata][28]} {adc2ddr/s_axi4_m2s[wdata][29]} {adc2ddr/s_axi4_m2s[wdata][30]} {adc2ddr/s_axi4_m2s[wdata][31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe11]
set_property port_width 4 [get_debug_ports u_ila_0/probe11]
connect_debug_port u_ila_0/probe11 [get_nets [list {adc2ddr/s_axi4_m2s[wstrb][0]} {adc2ddr/s_axi4_m2s[wstrb][1]} {adc2ddr/s_axi4_m2s[wstrb][2]} {adc2ddr/s_axi4_m2s[wstrb][3]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe12]
set_property port_width 6 [get_debug_ports u_ila_0/probe12]
connect_debug_port u_ila_0/probe12 [get_nets [list {adc2ddr/state[0]} {adc2ddr/state[1]} {adc2ddr/state[2]} {adc2ddr/state[3]} {adc2ddr/state[4]} {adc2ddr/state[5]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe13]
set_property port_width 4 [get_debug_ports u_ila_0/probe13]
connect_debug_port u_ila_0/probe13 [get_nets [list {adc2ddr/s_axi4_m2s[awcache][0]} {adc2ddr/s_axi4_m2s[awcache][1]} {adc2ddr/s_axi4_m2s[awcache][2]} {adc2ddr/s_axi4_m2s[awcache][3]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe14]
set_property port_width 32 [get_debug_ports u_ila_0/probe14]
connect_debug_port u_ila_0/probe14 [get_nets [list {adc2ddr/addr_base[0]} {adc2ddr/addr_base[1]} {adc2ddr/addr_base[2]} {adc2ddr/addr_base[3]} {adc2ddr/addr_base[4]} {adc2ddr/addr_base[5]} {adc2ddr/addr_base[6]} {adc2ddr/addr_base[7]} {adc2ddr/addr_base[8]} {adc2ddr/addr_base[9]} {adc2ddr/addr_base[10]} {adc2ddr/addr_base[11]} {adc2ddr/addr_base[12]} {adc2ddr/addr_base[13]} {adc2ddr/addr_base[14]} {adc2ddr/addr_base[15]} {adc2ddr/addr_base[16]} {adc2ddr/addr_base[17]} {adc2ddr/addr_base[18]} {adc2ddr/addr_base[19]} {adc2ddr/addr_base[20]} {adc2ddr/addr_base[21]} {adc2ddr/addr_base[22]} {adc2ddr/addr_base[23]} {adc2ddr/addr_base[24]} {adc2ddr/addr_base[25]} {adc2ddr/addr_base[26]} {adc2ddr/addr_base[27]} {adc2ddr/addr_base[28]} {adc2ddr/addr_base[29]} {adc2ddr/addr_base[30]} {adc2ddr/addr_base[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe15]
set_property port_width 6 [get_debug_ports u_ila_0/probe15]
connect_debug_port u_ila_0/probe15 [get_nets [list {adc2ddr/wordnum[0]} {adc2ddr/wordnum[1]} {adc2ddr/wordnum[2]} {adc2ddr/wordnum[3]} {adc2ddr/wordnum[4]} {adc2ddr/wordnum[5]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe16]
set_property port_width 1 [get_debug_ports u_ila_0/probe16]
connect_debug_port u_ila_0/probe16 [get_nets [list tenkhz_trig]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe17]
set_property port_width 1 [get_debug_ports u_ila_0/probe17]
connect_debug_port u_ila_0/probe17 [get_nets [list adc2ddr/trigger]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe18]
set_property port_width 1 [get_debug_ports u_ila_0/probe18]
connect_debug_port u_ila_0/probe18 [get_nets [list adc2ddr/prev_trigger]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe19]
set_property port_width 1 [get_debug_ports u_ila_0/probe19]
connect_debug_port u_ila_0/probe19 [get_nets [list {adc2ddr/s_axi4_m2s[awvalid]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe20]
set_property port_width 1 [get_debug_ports u_ila_0/probe20]
connect_debug_port u_ila_0/probe20 [get_nets [list {adc2ddr/s_axi4_m2s[bready]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe21]
set_property port_width 1 [get_debug_ports u_ila_0/probe21]
connect_debug_port u_ila_0/probe21 [get_nets [list {adc2ddr/s_axi4_s2m[awready]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe22]
set_property port_width 1 [get_debug_ports u_ila_0/probe22]
connect_debug_port u_ila_0/probe22 [get_nets [list {adc2ddr/s_axi4_s2m[wready]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe23]
set_property port_width 1 [get_debug_ports u_ila_0/probe23]
connect_debug_port u_ila_0/probe23 [get_nets [list {adc2ddr/s_axi4_s2m[bvalid]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe24]
set_property port_width 1 [get_debug_ports u_ila_0/probe24]
connect_debug_port u_ila_0/probe24 [get_nets [list {adc2ddr/s_axi4_m2s[wvalid]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe25]
set_property port_width 1 [get_debug_ports u_ila_0/probe25]
connect_debug_port u_ila_0/probe25 [get_nets [list {adc2ddr/s_axi4_m2s[wlast]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe26]
set_property port_width 1 [get_debug_ports u_ila_0/probe26]
connect_debug_port u_ila_0/probe26 [get_nets [list adc2ddr/debug_trig]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets pl_clk0]
