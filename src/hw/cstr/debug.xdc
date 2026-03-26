create_debug_core u_ila_0 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_0]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_0]
set_property C_DATA_DEPTH 1024 [get_debug_cores u_ila_0]
set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_0]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_0]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
set_property port_width 1 [get_debug_ports u_ila_0/clk]
connect_debug_port u_ila_0/clk [get_nets [list sys/processing_system7_0/inst/FCLK_CLK0]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
set_property port_width 8 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {write_dacs/dac4/dac_cntrl[cntrl][0]} {write_dacs/dac4/dac_cntrl[cntrl][1]} {write_dacs/dac4/dac_cntrl[cntrl][2]} {write_dacs/dac4/dac_cntrl[cntrl][3]} {write_dacs/dac4/dac_cntrl[cntrl][4]} {write_dacs/dac4/dac_cntrl[cntrl][5]} {write_dacs/dac4/dac_cntrl[cntrl][6]} {write_dacs/dac4/dac_cntrl[cntrl][7]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
set_property port_width 16 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list {write_dacs/dac4/dac_cntrl[dpram_addr][0]} {write_dacs/dac4/dac_cntrl[dpram_addr][1]} {write_dacs/dac4/dac_cntrl[dpram_addr][2]} {write_dacs/dac4/dac_cntrl[dpram_addr][3]} {write_dacs/dac4/dac_cntrl[dpram_addr][4]} {write_dacs/dac4/dac_cntrl[dpram_addr][5]} {write_dacs/dac4/dac_cntrl[dpram_addr][6]} {write_dacs/dac4/dac_cntrl[dpram_addr][7]} {write_dacs/dac4/dac_cntrl[dpram_addr][8]} {write_dacs/dac4/dac_cntrl[dpram_addr][9]} {write_dacs/dac4/dac_cntrl[dpram_addr][10]} {write_dacs/dac4/dac_cntrl[dpram_addr][11]} {write_dacs/dac4/dac_cntrl[dpram_addr][12]} {write_dacs/dac4/dac_cntrl[dpram_addr][13]} {write_dacs/dac4/dac_cntrl[dpram_addr][14]} {write_dacs/dac4/dac_cntrl[dpram_addr][15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe2]
set_property port_width 20 [get_debug_ports u_ila_0/probe2]
connect_debug_port u_ila_0/probe2 [get_nets [list {write_dacs/dac4/dac_cntrl[dpram_data][0]} {write_dacs/dac4/dac_cntrl[dpram_data][1]} {write_dacs/dac4/dac_cntrl[dpram_data][2]} {write_dacs/dac4/dac_cntrl[dpram_data][3]} {write_dacs/dac4/dac_cntrl[dpram_data][4]} {write_dacs/dac4/dac_cntrl[dpram_data][5]} {write_dacs/dac4/dac_cntrl[dpram_data][6]} {write_dacs/dac4/dac_cntrl[dpram_data][7]} {write_dacs/dac4/dac_cntrl[dpram_data][8]} {write_dacs/dac4/dac_cntrl[dpram_data][9]} {write_dacs/dac4/dac_cntrl[dpram_data][10]} {write_dacs/dac4/dac_cntrl[dpram_data][11]} {write_dacs/dac4/dac_cntrl[dpram_data][12]} {write_dacs/dac4/dac_cntrl[dpram_data][13]} {write_dacs/dac4/dac_cntrl[dpram_data][14]} {write_dacs/dac4/dac_cntrl[dpram_data][15]} {write_dacs/dac4/dac_cntrl[dpram_data][16]} {write_dacs/dac4/dac_cntrl[dpram_data][17]} {write_dacs/dac4/dac_cntrl[dpram_data][18]} {write_dacs/dac4/dac_cntrl[dpram_data][19]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe3]
set_property port_width 24 [get_debug_ports u_ila_0/probe3]
connect_debug_port u_ila_0/probe3 [get_nets [list {write_dacs/dac4/dac_cntrl[gain][0]} {write_dacs/dac4/dac_cntrl[gain][1]} {write_dacs/dac4/dac_cntrl[gain][2]} {write_dacs/dac4/dac_cntrl[gain][3]} {write_dacs/dac4/dac_cntrl[gain][4]} {write_dacs/dac4/dac_cntrl[gain][5]} {write_dacs/dac4/dac_cntrl[gain][6]} {write_dacs/dac4/dac_cntrl[gain][7]} {write_dacs/dac4/dac_cntrl[gain][8]} {write_dacs/dac4/dac_cntrl[gain][9]} {write_dacs/dac4/dac_cntrl[gain][10]} {write_dacs/dac4/dac_cntrl[gain][11]} {write_dacs/dac4/dac_cntrl[gain][12]} {write_dacs/dac4/dac_cntrl[gain][13]} {write_dacs/dac4/dac_cntrl[gain][14]} {write_dacs/dac4/dac_cntrl[gain][15]} {write_dacs/dac4/dac_cntrl[gain][16]} {write_dacs/dac4/dac_cntrl[gain][17]} {write_dacs/dac4/dac_cntrl[gain][18]} {write_dacs/dac4/dac_cntrl[gain][19]} {write_dacs/dac4/dac_cntrl[gain][20]} {write_dacs/dac4/dac_cntrl[gain][21]} {write_dacs/dac4/dac_cntrl[gain][22]} {write_dacs/dac4/dac_cntrl[gain][23]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe4]
set_property port_width 2 [get_debug_ports u_ila_0/probe4]
connect_debug_port u_ila_0/probe4 [get_nets [list {write_dacs/dac4/dac_cntrl[mode][0]} {write_dacs/dac4/dac_cntrl[mode][1]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe5]
set_property port_width 32 [get_debug_ports u_ila_0/probe5]
connect_debug_port u_ila_0/probe5 [get_nets [list {write_dacs/dac4/dac_cntrl[smooth_phaseinc][0]} {write_dacs/dac4/dac_cntrl[smooth_phaseinc][1]} {write_dacs/dac4/dac_cntrl[smooth_phaseinc][2]} {write_dacs/dac4/dac_cntrl[smooth_phaseinc][3]} {write_dacs/dac4/dac_cntrl[smooth_phaseinc][4]} {write_dacs/dac4/dac_cntrl[smooth_phaseinc][5]} {write_dacs/dac4/dac_cntrl[smooth_phaseinc][6]} {write_dacs/dac4/dac_cntrl[smooth_phaseinc][7]} {write_dacs/dac4/dac_cntrl[smooth_phaseinc][8]} {write_dacs/dac4/dac_cntrl[smooth_phaseinc][9]} {write_dacs/dac4/dac_cntrl[smooth_phaseinc][10]} {write_dacs/dac4/dac_cntrl[smooth_phaseinc][11]} {write_dacs/dac4/dac_cntrl[smooth_phaseinc][12]} {write_dacs/dac4/dac_cntrl[smooth_phaseinc][13]} {write_dacs/dac4/dac_cntrl[smooth_phaseinc][14]} {write_dacs/dac4/dac_cntrl[smooth_phaseinc][15]} {write_dacs/dac4/dac_cntrl[smooth_phaseinc][16]} {write_dacs/dac4/dac_cntrl[smooth_phaseinc][17]} {write_dacs/dac4/dac_cntrl[smooth_phaseinc][18]} {write_dacs/dac4/dac_cntrl[smooth_phaseinc][19]} {write_dacs/dac4/dac_cntrl[smooth_phaseinc][20]} {write_dacs/dac4/dac_cntrl[smooth_phaseinc][21]} {write_dacs/dac4/dac_cntrl[smooth_phaseinc][22]} {write_dacs/dac4/dac_cntrl[smooth_phaseinc][23]} {write_dacs/dac4/dac_cntrl[smooth_phaseinc][24]} {write_dacs/dac4/dac_cntrl[smooth_phaseinc][25]} {write_dacs/dac4/dac_cntrl[smooth_phaseinc][26]} {write_dacs/dac4/dac_cntrl[smooth_phaseinc][27]} {write_dacs/dac4/dac_cntrl[smooth_phaseinc][28]} {write_dacs/dac4/dac_cntrl[smooth_phaseinc][29]} {write_dacs/dac4/dac_cntrl[smooth_phaseinc][30]} {write_dacs/dac4/dac_cntrl[smooth_phaseinc][31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe6]
set_property port_width 20 [get_debug_ports u_ila_0/probe6]
connect_debug_port u_ila_0/probe6 [get_nets [list {write_dacs/dac4/dac_cntrl[setpoint][0]} {write_dacs/dac4/dac_cntrl[setpoint][1]} {write_dacs/dac4/dac_cntrl[setpoint][2]} {write_dacs/dac4/dac_cntrl[setpoint][3]} {write_dacs/dac4/dac_cntrl[setpoint][4]} {write_dacs/dac4/dac_cntrl[setpoint][5]} {write_dacs/dac4/dac_cntrl[setpoint][6]} {write_dacs/dac4/dac_cntrl[setpoint][7]} {write_dacs/dac4/dac_cntrl[setpoint][8]} {write_dacs/dac4/dac_cntrl[setpoint][9]} {write_dacs/dac4/dac_cntrl[setpoint][10]} {write_dacs/dac4/dac_cntrl[setpoint][11]} {write_dacs/dac4/dac_cntrl[setpoint][12]} {write_dacs/dac4/dac_cntrl[setpoint][13]} {write_dacs/dac4/dac_cntrl[setpoint][14]} {write_dacs/dac4/dac_cntrl[setpoint][15]} {write_dacs/dac4/dac_cntrl[setpoint][16]} {write_dacs/dac4/dac_cntrl[setpoint][17]} {write_dacs/dac4/dac_cntrl[setpoint][18]} {write_dacs/dac4/dac_cntrl[setpoint][19]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe7]
set_property port_width 20 [get_debug_ports u_ila_0/probe7]
connect_debug_port u_ila_0/probe7 [get_nets [list {write_dacs/dac4/dac_cntrl[offset][0]} {write_dacs/dac4/dac_cntrl[offset][1]} {write_dacs/dac4/dac_cntrl[offset][2]} {write_dacs/dac4/dac_cntrl[offset][3]} {write_dacs/dac4/dac_cntrl[offset][4]} {write_dacs/dac4/dac_cntrl[offset][5]} {write_dacs/dac4/dac_cntrl[offset][6]} {write_dacs/dac4/dac_cntrl[offset][7]} {write_dacs/dac4/dac_cntrl[offset][8]} {write_dacs/dac4/dac_cntrl[offset][9]} {write_dacs/dac4/dac_cntrl[offset][10]} {write_dacs/dac4/dac_cntrl[offset][11]} {write_dacs/dac4/dac_cntrl[offset][12]} {write_dacs/dac4/dac_cntrl[offset][13]} {write_dacs/dac4/dac_cntrl[offset][14]} {write_dacs/dac4/dac_cntrl[offset][15]} {write_dacs/dac4/dac_cntrl[offset][16]} {write_dacs/dac4/dac_cntrl[offset][17]} {write_dacs/dac4/dac_cntrl[offset][18]} {write_dacs/dac4/dac_cntrl[offset][19]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe8]
set_property port_width 16 [get_debug_ports u_ila_0/probe8]
connect_debug_port u_ila_0/probe8 [get_nets [list {write_dacs/dac4/dac_cntrl[ramplen][0]} {write_dacs/dac4/dac_cntrl[ramplen][1]} {write_dacs/dac4/dac_cntrl[ramplen][2]} {write_dacs/dac4/dac_cntrl[ramplen][3]} {write_dacs/dac4/dac_cntrl[ramplen][4]} {write_dacs/dac4/dac_cntrl[ramplen][5]} {write_dacs/dac4/dac_cntrl[ramplen][6]} {write_dacs/dac4/dac_cntrl[ramplen][7]} {write_dacs/dac4/dac_cntrl[ramplen][8]} {write_dacs/dac4/dac_cntrl[ramplen][9]} {write_dacs/dac4/dac_cntrl[ramplen][10]} {write_dacs/dac4/dac_cntrl[ramplen][11]} {write_dacs/dac4/dac_cntrl[ramplen][12]} {write_dacs/dac4/dac_cntrl[ramplen][13]} {write_dacs/dac4/dac_cntrl[ramplen][14]} {write_dacs/dac4/dac_cntrl[ramplen][15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe9]
set_property port_width 20 [get_debug_ports u_ila_0/probe9]
connect_debug_port u_ila_0/probe9 [get_nets [list {write_dacs/dac4/dac_cntrl[setpoint_last][0]} {write_dacs/dac4/dac_cntrl[setpoint_last][1]} {write_dacs/dac4/dac_cntrl[setpoint_last][2]} {write_dacs/dac4/dac_cntrl[setpoint_last][3]} {write_dacs/dac4/dac_cntrl[setpoint_last][4]} {write_dacs/dac4/dac_cntrl[setpoint_last][5]} {write_dacs/dac4/dac_cntrl[setpoint_last][6]} {write_dacs/dac4/dac_cntrl[setpoint_last][7]} {write_dacs/dac4/dac_cntrl[setpoint_last][8]} {write_dacs/dac4/dac_cntrl[setpoint_last][9]} {write_dacs/dac4/dac_cntrl[setpoint_last][10]} {write_dacs/dac4/dac_cntrl[setpoint_last][11]} {write_dacs/dac4/dac_cntrl[setpoint_last][12]} {write_dacs/dac4/dac_cntrl[setpoint_last][13]} {write_dacs/dac4/dac_cntrl[setpoint_last][14]} {write_dacs/dac4/dac_cntrl[setpoint_last][15]} {write_dacs/dac4/dac_cntrl[setpoint_last][16]} {write_dacs/dac4/dac_cntrl[setpoint_last][17]} {write_dacs/dac4/dac_cntrl[setpoint_last][18]} {write_dacs/dac4/dac_cntrl[setpoint_last][19]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe10]
set_property port_width 20 [get_debug_ports u_ila_0/probe10]
connect_debug_port u_ila_0/probe10 [get_nets [list {write_dacs/dac4/dac_data[0]} {write_dacs/dac4/dac_data[1]} {write_dacs/dac4/dac_data[2]} {write_dacs/dac4/dac_data[3]} {write_dacs/dac4/dac_data[4]} {write_dacs/dac4/dac_data[5]} {write_dacs/dac4/dac_data[6]} {write_dacs/dac4/dac_data[7]} {write_dacs/dac4/dac_data[8]} {write_dacs/dac4/dac_data[9]} {write_dacs/dac4/dac_data[10]} {write_dacs/dac4/dac_data[11]} {write_dacs/dac4/dac_data[12]} {write_dacs/dac4/dac_data[13]} {write_dacs/dac4/dac_data[14]} {write_dacs/dac4/dac_data[15]} {write_dacs/dac4/dac_data[16]} {write_dacs/dac4/dac_data[17]} {write_dacs/dac4/dac_data[18]} {write_dacs/dac4/dac_data[19]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe11]
set_property port_width 20 [get_debug_ports u_ila_0/probe11]
connect_debug_port u_ila_0/probe11 [get_nets [list {write_dacs/dac4/dac_setpt[0]} {write_dacs/dac4/dac_setpt[1]} {write_dacs/dac4/dac_setpt[2]} {write_dacs/dac4/dac_setpt[3]} {write_dacs/dac4/dac_setpt[4]} {write_dacs/dac4/dac_setpt[5]} {write_dacs/dac4/dac_setpt[6]} {write_dacs/dac4/dac_setpt[7]} {write_dacs/dac4/dac_setpt[8]} {write_dacs/dac4/dac_setpt[9]} {write_dacs/dac4/dac_setpt[10]} {write_dacs/dac4/dac_setpt[11]} {write_dacs/dac4/dac_setpt[12]} {write_dacs/dac4/dac_setpt[13]} {write_dacs/dac4/dac_setpt[14]} {write_dacs/dac4/dac_setpt[15]} {write_dacs/dac4/dac_setpt[16]} {write_dacs/dac4/dac_setpt[17]} {write_dacs/dac4/dac_setpt[18]} {write_dacs/dac4/dac_setpt[19]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe12]
set_property port_width 20 [get_debug_ports u_ila_0/probe12]
connect_debug_port u_ila_0/probe12 [get_nets [list {write_dacs/dac4/dac_setpt_raw[0]} {write_dacs/dac4/dac_setpt_raw[1]} {write_dacs/dac4/dac_setpt_raw[2]} {write_dacs/dac4/dac_setpt_raw[3]} {write_dacs/dac4/dac_setpt_raw[4]} {write_dacs/dac4/dac_setpt_raw[5]} {write_dacs/dac4/dac_setpt_raw[6]} {write_dacs/dac4/dac_setpt_raw[7]} {write_dacs/dac4/dac_setpt_raw[8]} {write_dacs/dac4/dac_setpt_raw[9]} {write_dacs/dac4/dac_setpt_raw[10]} {write_dacs/dac4/dac_setpt_raw[11]} {write_dacs/dac4/dac_setpt_raw[12]} {write_dacs/dac4/dac_setpt_raw[13]} {write_dacs/dac4/dac_setpt_raw[14]} {write_dacs/dac4/dac_setpt_raw[15]} {write_dacs/dac4/dac_setpt_raw[16]} {write_dacs/dac4/dac_setpt_raw[17]} {write_dacs/dac4/dac_setpt_raw[18]} {write_dacs/dac4/dac_setpt_raw[19]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe13]
set_property port_width 20 [get_debug_ports u_ila_0/probe13]
connect_debug_port u_ila_0/probe13 [get_nets [list {write_dacs/dac4/fofb_dac_setpt[0]} {write_dacs/dac4/fofb_dac_setpt[1]} {write_dacs/dac4/fofb_dac_setpt[2]} {write_dacs/dac4/fofb_dac_setpt[3]} {write_dacs/dac4/fofb_dac_setpt[4]} {write_dacs/dac4/fofb_dac_setpt[5]} {write_dacs/dac4/fofb_dac_setpt[6]} {write_dacs/dac4/fofb_dac_setpt[7]} {write_dacs/dac4/fofb_dac_setpt[8]} {write_dacs/dac4/fofb_dac_setpt[9]} {write_dacs/dac4/fofb_dac_setpt[10]} {write_dacs/dac4/fofb_dac_setpt[11]} {write_dacs/dac4/fofb_dac_setpt[12]} {write_dacs/dac4/fofb_dac_setpt[13]} {write_dacs/dac4/fofb_dac_setpt[14]} {write_dacs/dac4/fofb_dac_setpt[15]} {write_dacs/dac4/fofb_dac_setpt[16]} {write_dacs/dac4/fofb_dac_setpt[17]} {write_dacs/dac4/fofb_dac_setpt[18]} {write_dacs/dac4/fofb_dac_setpt[19]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe14]
set_property port_width 20 [get_debug_ports u_ila_0/probe14]
connect_debug_port u_ila_0/probe14 [get_nets [list {write_dacs/dac4/ramp_dac_setpt[0]} {write_dacs/dac4/ramp_dac_setpt[1]} {write_dacs/dac4/ramp_dac_setpt[2]} {write_dacs/dac4/ramp_dac_setpt[3]} {write_dacs/dac4/ramp_dac_setpt[4]} {write_dacs/dac4/ramp_dac_setpt[5]} {write_dacs/dac4/ramp_dac_setpt[6]} {write_dacs/dac4/ramp_dac_setpt[7]} {write_dacs/dac4/ramp_dac_setpt[8]} {write_dacs/dac4/ramp_dac_setpt[9]} {write_dacs/dac4/ramp_dac_setpt[10]} {write_dacs/dac4/ramp_dac_setpt[11]} {write_dacs/dac4/ramp_dac_setpt[12]} {write_dacs/dac4/ramp_dac_setpt[13]} {write_dacs/dac4/ramp_dac_setpt[14]} {write_dacs/dac4/ramp_dac_setpt[15]} {write_dacs/dac4/ramp_dac_setpt[16]} {write_dacs/dac4/ramp_dac_setpt[17]} {write_dacs/dac4/ramp_dac_setpt[18]} {write_dacs/dac4/ramp_dac_setpt[19]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe15]
set_property port_width 20 [get_debug_ports u_ila_0/probe15]
connect_debug_port u_ila_0/probe15 [get_nets [list {write_dacs/dac4/smooth_dac_setpt[0]} {write_dacs/dac4/smooth_dac_setpt[1]} {write_dacs/dac4/smooth_dac_setpt[2]} {write_dacs/dac4/smooth_dac_setpt[3]} {write_dacs/dac4/smooth_dac_setpt[4]} {write_dacs/dac4/smooth_dac_setpt[5]} {write_dacs/dac4/smooth_dac_setpt[6]} {write_dacs/dac4/smooth_dac_setpt[7]} {write_dacs/dac4/smooth_dac_setpt[8]} {write_dacs/dac4/smooth_dac_setpt[9]} {write_dacs/dac4/smooth_dac_setpt[10]} {write_dacs/dac4/smooth_dac_setpt[11]} {write_dacs/dac4/smooth_dac_setpt[12]} {write_dacs/dac4/smooth_dac_setpt[13]} {write_dacs/dac4/smooth_dac_setpt[14]} {write_dacs/dac4/smooth_dac_setpt[15]} {write_dacs/dac4/smooth_dac_setpt[16]} {write_dacs/dac4/smooth_dac_setpt[17]} {write_dacs/dac4/smooth_dac_setpt[18]} {write_dacs/dac4/smooth_dac_setpt[19]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe16]
set_property port_width 16 [get_debug_ports u_ila_0/probe16]
connect_debug_port u_ila_0/probe16 [get_nets [list {fault_gen/ch4_faults/fault_live[0]} {fault_gen/ch4_faults/fault_live[1]} {fault_gen/ch4_faults/fault_live[2]} {fault_gen/ch4_faults/fault_live[3]} {fault_gen/ch4_faults/fault_live[4]} {fault_gen/ch4_faults/fault_live[5]} {fault_gen/ch4_faults/fault_live[6]} {fault_gen/ch4_faults/fault_live[7]} {fault_gen/ch4_faults/fault_live[8]} {fault_gen/ch4_faults/fault_live[9]} {fault_gen/ch4_faults/fault_live[10]} {fault_gen/ch4_faults/fault_live[11]} {fault_gen/ch4_faults/fault_live[12]} {fault_gen/ch4_faults/fault_live[13]} {fault_gen/ch4_faults/fault_live[14]} {fault_gen/ch4_faults/fault_live[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe17]
set_property port_width 16 [get_debug_ports u_ila_0/probe17]
connect_debug_port u_ila_0/probe17 [get_nets [list {fault_gen/ch4_faults/fault_params[enable][0]} {fault_gen/ch4_faults/fault_params[enable][1]} {fault_gen/ch4_faults/fault_params[enable][2]} {fault_gen/ch4_faults/fault_params[enable][3]} {fault_gen/ch4_faults/fault_params[enable][4]} {fault_gen/ch4_faults/fault_params[enable][5]} {fault_gen/ch4_faults/fault_params[enable][6]} {fault_gen/ch4_faults/fault_params[enable][7]} {fault_gen/ch4_faults/fault_params[enable][8]} {fault_gen/ch4_faults/fault_params[enable][9]} {fault_gen/ch4_faults/fault_params[enable][10]} {fault_gen/ch4_faults/fault_params[enable][11]} {fault_gen/ch4_faults/fault_params[enable][12]} {fault_gen/ch4_faults/fault_params[enable][13]} {fault_gen/ch4_faults/fault_params[enable][14]} {fault_gen/ch4_faults/fault_params[enable][15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe18]
set_property port_width 16 [get_debug_ports u_ila_0/probe18]
connect_debug_port u_ila_0/probe18 [get_nets [list {fault_gen/ch4_faults/fault_reg[0]} {fault_gen/ch4_faults/fault_reg[1]} {fault_gen/ch4_faults/fault_reg[2]} {fault_gen/ch4_faults/fault_reg[3]} {fault_gen/ch4_faults/fault_reg[4]} {fault_gen/ch4_faults/fault_reg[5]} {fault_gen/ch4_faults/fault_reg[6]} {fault_gen/ch4_faults/fault_reg[7]} {fault_gen/ch4_faults/fault_reg[8]} {fault_gen/ch4_faults/fault_reg[9]} {fault_gen/ch4_faults/fault_reg[10]} {fault_gen/ch4_faults/fault_reg[11]} {fault_gen/ch4_faults/fault_reg[12]} {fault_gen/ch4_faults/fault_reg[13]} {fault_gen/ch4_faults/fault_reg[14]} {fault_gen/ch4_faults/fault_reg[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe19]
set_property port_width 16 [get_debug_ports u_ila_0/probe19]
connect_debug_port u_ila_0/probe19 [get_nets [list {fault_gen/ch4_faults/fault_reg_lat[0]} {fault_gen/ch4_faults/fault_reg_lat[1]} {fault_gen/ch4_faults/fault_reg_lat[2]} {fault_gen/ch4_faults/fault_reg_lat[3]} {fault_gen/ch4_faults/fault_reg_lat[4]} {fault_gen/ch4_faults/fault_reg_lat[5]} {fault_gen/ch4_faults/fault_reg_lat[6]} {fault_gen/ch4_faults/fault_reg_lat[7]} {fault_gen/ch4_faults/fault_reg_lat[8]} {fault_gen/ch4_faults/fault_reg_lat[9]} {fault_gen/ch4_faults/fault_reg_lat[10]} {fault_gen/ch4_faults/fault_reg_lat[11]} {fault_gen/ch4_faults/fault_reg_lat[12]} {fault_gen/ch4_faults/fault_reg_lat[13]} {fault_gen/ch4_faults/fault_reg_lat[14]} {fault_gen/ch4_faults/fault_reg_lat[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe20]
set_property port_width 16 [get_debug_ports u_ila_0/probe20]
connect_debug_port u_ila_0/probe20 [get_nets [list {fault_gen/ch4_faults/fault_stat[lat][0]} {fault_gen/ch4_faults/fault_stat[lat][1]} {fault_gen/ch4_faults/fault_stat[lat][2]} {fault_gen/ch4_faults/fault_stat[lat][3]} {fault_gen/ch4_faults/fault_stat[lat][4]} {fault_gen/ch4_faults/fault_stat[lat][5]} {fault_gen/ch4_faults/fault_stat[lat][6]} {fault_gen/ch4_faults/fault_stat[lat][7]} {fault_gen/ch4_faults/fault_stat[lat][8]} {fault_gen/ch4_faults/fault_stat[lat][9]} {fault_gen/ch4_faults/fault_stat[lat][10]} {fault_gen/ch4_faults/fault_stat[lat][11]} {fault_gen/ch4_faults/fault_stat[lat][12]} {fault_gen/ch4_faults/fault_stat[lat][13]} {fault_gen/ch4_faults/fault_stat[lat][14]} {fault_gen/ch4_faults/fault_stat[lat][15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe21]
set_property port_width 16 [get_debug_ports u_ila_0/probe21]
connect_debug_port u_ila_0/probe21 [get_nets [list {fault_gen/ch4_faults/fault_stat[live][0]} {fault_gen/ch4_faults/fault_stat[live][1]} {fault_gen/ch4_faults/fault_stat[live][2]} {fault_gen/ch4_faults/fault_stat[live][3]} {fault_gen/ch4_faults/fault_stat[live][4]} {fault_gen/ch4_faults/fault_stat[live][5]} {fault_gen/ch4_faults/fault_stat[live][6]} {fault_gen/ch4_faults/fault_stat[live][7]} {fault_gen/ch4_faults/fault_stat[live][8]} {fault_gen/ch4_faults/fault_stat[live][9]} {fault_gen/ch4_faults/fault_stat[live][10]} {fault_gen/ch4_faults/fault_stat[live][11]} {fault_gen/ch4_faults/fault_stat[live][12]} {fault_gen/ch4_faults/fault_stat[live][13]} {fault_gen/ch4_faults/fault_stat[live][14]} {fault_gen/ch4_faults/fault_stat[live][15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe22]
set_property port_width 1 [get_debug_ports u_ila_0/probe22]
connect_debug_port u_ila_0/probe22 [get_nets [list write_dacs/dac4/ramp_active]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe23]
set_property port_width 1 [get_debug_ports u_ila_0/probe23]
connect_debug_port u_ila_0/probe23 [get_nets [list write_dacs/dac4/smooth_active]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe24]
set_property port_width 1 [get_debug_ports u_ila_0/probe24]
connect_debug_port u_ila_0/probe24 [get_nets [list fault_gen/ch4_faults/dac_change_flag]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe25]
set_property port_width 1 [get_debug_ports u_ila_0/probe25]
connect_debug_port u_ila_0/probe25 [get_nets [list tenkhz_trig]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe26]
set_property port_width 1 [get_debug_ports u_ila_0/probe26]
connect_debug_port u_ila_0/probe26 [get_nets [list {fault_gen/ch4_faults/fault_params[clear]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe27]
set_property port_width 1 [get_debug_ports u_ila_0/probe27]
connect_debug_port u_ila_0/probe27 [get_nets [list {write_dacs/dac4/dac_cntrl[ramprun]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe28]
set_property port_width 1 [get_debug_ports u_ila_0/probe28]
connect_debug_port u_ila_0/probe28 [get_nets [list {write_dacs/dac4/dac_cntrl[dpram_we]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe29]
set_property port_width 1 [get_debug_ports u_ila_0/probe29]
connect_debug_port u_ila_0/probe29 [get_nets [list {write_dacs/dac4/dac_cntrl[setpoint_changed]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe30]
set_property port_width 1 [get_debug_ports u_ila_0/probe30]
connect_debug_port u_ila_0/probe30 [get_nets [list {write_dacs/dac4/dac_cntrl[reset]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe31]
set_property port_width 1 [get_debug_ports u_ila_0/probe31]
connect_debug_port u_ila_0/probe31 [get_nets [list fault_gen/ch4_faults/startup_state]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe32]
set_property port_width 1 [get_debug_ports u_ila_0/probe32]
connect_debug_port u_ila_0/probe32 [get_nets [list fault_gen/ch4_faults/run_state]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe33]
set_property port_width 1 [get_debug_ports u_ila_0/probe33]
connect_debug_port u_ila_0/probe33 [get_nets [list {fault_gen/ch4_faults/fault_stat[flt_trig]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe34]
set_property port_width 1 [get_debug_ports u_ila_0/probe34]
connect_debug_port u_ila_0/probe34 [get_nets [list {fault_gen/ch4_faults/fault_stat[err_trig]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe35]
set_property port_width 1 [get_debug_ports u_ila_0/probe35]
connect_debug_port u_ila_0/probe35 [get_nets [list write_dacs/tenkhz_trig]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets pl_clk0]
