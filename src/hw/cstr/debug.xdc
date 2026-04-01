

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
set_property port_width 16 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {fault_gen/ch1_faults/fault_stat[live][0]} {fault_gen/ch1_faults/fault_stat[live][1]} {fault_gen/ch1_faults/fault_stat[live][2]} {fault_gen/ch1_faults/fault_stat[live][3]} {fault_gen/ch1_faults/fault_stat[live][4]} {fault_gen/ch1_faults/fault_stat[live][5]} {fault_gen/ch1_faults/fault_stat[live][6]} {fault_gen/ch1_faults/fault_stat[live][7]} {fault_gen/ch1_faults/fault_stat[live][8]} {fault_gen/ch1_faults/fault_stat[live][9]} {fault_gen/ch1_faults/fault_stat[live][10]} {fault_gen/ch1_faults/fault_stat[live][11]} {fault_gen/ch1_faults/fault_stat[live][12]} {fault_gen/ch1_faults/fault_stat[live][13]} {fault_gen/ch1_faults/fault_stat[live][14]} {fault_gen/ch1_faults/fault_stat[live][15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
set_property port_width 16 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list {fault_gen/ch1_faults/fault_stat[lat][0]} {fault_gen/ch1_faults/fault_stat[lat][1]} {fault_gen/ch1_faults/fault_stat[lat][2]} {fault_gen/ch1_faults/fault_stat[lat][3]} {fault_gen/ch1_faults/fault_stat[lat][4]} {fault_gen/ch1_faults/fault_stat[lat][5]} {fault_gen/ch1_faults/fault_stat[lat][6]} {fault_gen/ch1_faults/fault_stat[lat][7]} {fault_gen/ch1_faults/fault_stat[lat][8]} {fault_gen/ch1_faults/fault_stat[lat][9]} {fault_gen/ch1_faults/fault_stat[lat][10]} {fault_gen/ch1_faults/fault_stat[lat][11]} {fault_gen/ch1_faults/fault_stat[lat][12]} {fault_gen/ch1_faults/fault_stat[lat][13]} {fault_gen/ch1_faults/fault_stat[lat][14]} {fault_gen/ch1_faults/fault_stat[lat][15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe2]
set_property port_width 16 [get_debug_ports u_ila_0/probe2]
connect_debug_port u_ila_0/probe2 [get_nets [list {fault_gen/ch1_faults/fault_reg_lat[0]} {fault_gen/ch1_faults/fault_reg_lat[1]} {fault_gen/ch1_faults/fault_reg_lat[2]} {fault_gen/ch1_faults/fault_reg_lat[3]} {fault_gen/ch1_faults/fault_reg_lat[4]} {fault_gen/ch1_faults/fault_reg_lat[5]} {fault_gen/ch1_faults/fault_reg_lat[6]} {fault_gen/ch1_faults/fault_reg_lat[7]} {fault_gen/ch1_faults/fault_reg_lat[8]} {fault_gen/ch1_faults/fault_reg_lat[9]} {fault_gen/ch1_faults/fault_reg_lat[10]} {fault_gen/ch1_faults/fault_reg_lat[11]} {fault_gen/ch1_faults/fault_reg_lat[12]} {fault_gen/ch1_faults/fault_reg_lat[13]} {fault_gen/ch1_faults/fault_reg_lat[14]} {fault_gen/ch1_faults/fault_reg_lat[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe3]
set_property port_width 16 [get_debug_ports u_ila_0/probe3]
connect_debug_port u_ila_0/probe3 [get_nets [list {fault_gen/ch1_faults/fault_reg[0]} {fault_gen/ch1_faults/fault_reg[1]} {fault_gen/ch1_faults/fault_reg[2]} {fault_gen/ch1_faults/fault_reg[3]} {fault_gen/ch1_faults/fault_reg[4]} {fault_gen/ch1_faults/fault_reg[5]} {fault_gen/ch1_faults/fault_reg[6]} {fault_gen/ch1_faults/fault_reg[7]} {fault_gen/ch1_faults/fault_reg[8]} {fault_gen/ch1_faults/fault_reg[9]} {fault_gen/ch1_faults/fault_reg[10]} {fault_gen/ch1_faults/fault_reg[11]} {fault_gen/ch1_faults/fault_reg[12]} {fault_gen/ch1_faults/fault_reg[13]} {fault_gen/ch1_faults/fault_reg[14]} {fault_gen/ch1_faults/fault_reg[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe4]
set_property port_width 16 [get_debug_ports u_ila_0/probe4]
connect_debug_port u_ila_0/probe4 [get_nets [list {fault_gen/ch1_faults/fault_params[enable][0]} {fault_gen/ch1_faults/fault_params[enable][1]} {fault_gen/ch1_faults/fault_params[enable][2]} {fault_gen/ch1_faults/fault_params[enable][3]} {fault_gen/ch1_faults/fault_params[enable][4]} {fault_gen/ch1_faults/fault_params[enable][5]} {fault_gen/ch1_faults/fault_params[enable][6]} {fault_gen/ch1_faults/fault_params[enable][7]} {fault_gen/ch1_faults/fault_params[enable][8]} {fault_gen/ch1_faults/fault_params[enable][9]} {fault_gen/ch1_faults/fault_params[enable][10]} {fault_gen/ch1_faults/fault_params[enable][11]} {fault_gen/ch1_faults/fault_params[enable][12]} {fault_gen/ch1_faults/fault_params[enable][13]} {fault_gen/ch1_faults/fault_params[enable][14]} {fault_gen/ch1_faults/fault_params[enable][15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe5]
set_property port_width 16 [get_debug_ports u_ila_0/probe5]
connect_debug_port u_ila_0/probe5 [get_nets [list {fault_gen/ch1_faults/fault_live[0]} {fault_gen/ch1_faults/fault_live[1]} {fault_gen/ch1_faults/fault_live[2]} {fault_gen/ch1_faults/fault_live[3]} {fault_gen/ch1_faults/fault_live[4]} {fault_gen/ch1_faults/fault_live[5]} {fault_gen/ch1_faults/fault_live[6]} {fault_gen/ch1_faults/fault_live[7]} {fault_gen/ch1_faults/fault_live[8]} {fault_gen/ch1_faults/fault_live[9]} {fault_gen/ch1_faults/fault_live[10]} {fault_gen/ch1_faults/fault_live[11]} {fault_gen/ch1_faults/fault_live[12]} {fault_gen/ch1_faults/fault_live[13]} {fault_gen/ch1_faults/fault_live[14]} {fault_gen/ch1_faults/fault_live[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe6]
set_property port_width 1 [get_debug_ports u_ila_0/probe6]
connect_debug_port u_ila_0/probe6 [get_nets [list {fault_gen/ch1_faults/dig_cntrl[main_dipole]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe7]
set_property port_width 1 [get_debug_ports u_ila_0/probe7]
connect_debug_port u_ila_0/probe7 [get_nets [list {fault_gen/ch1_faults/fault_params[clear]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe8]
set_property port_width 1 [get_debug_ports u_ila_0/probe8]
connect_debug_port u_ila_0/probe8 [get_nets [list {fault_gen/ch1_faults/dig_cntrl[spare]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe9]
set_property port_width 1 [get_debug_ports u_ila_0/probe9]
connect_debug_port u_ila_0/probe9 [get_nets [list {fault_gen/ch1_faults/dig_cntrl[polarity]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe10]
set_property port_width 1 [get_debug_ports u_ila_0/probe10]
connect_debug_port u_ila_0/probe10 [get_nets [list {fault_gen/ch1_faults/dig_cntrl[reset]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe11]
set_property port_width 1 [get_debug_ports u_ila_0/probe11]
connect_debug_port u_ila_0/probe11 [get_nets [list {fault_gen/ch1_faults/dig_cntrl[on2]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe12]
set_property port_width 1 [get_debug_ports u_ila_0/probe12]
connect_debug_port u_ila_0/probe12 [get_nets [list {fault_gen/ch1_faults/dig_cntrl[park]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe13]
set_property port_width 1 [get_debug_ports u_ila_0/probe13]
connect_debug_port u_ila_0/probe13 [get_nets [list fault_gen/ch1_faults/startup_state]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe14]
set_property port_width 1 [get_debug_ports u_ila_0/probe14]
connect_debug_port u_ila_0/probe14 [get_nets [list fault_gen/ch1_faults/run_state]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe15]
set_property port_width 1 [get_debug_ports u_ila_0/probe15]
connect_debug_port u_ila_0/probe15 [get_nets [list {fault_gen/ch1_faults/fault_stat[err_trig]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe16]
set_property port_width 1 [get_debug_ports u_ila_0/probe16]
connect_debug_port u_ila_0/probe16 [get_nets [list {fault_gen/ch1_faults/fault_stat[flt_trig]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe17]
set_property port_width 1 [get_debug_ports u_ila_0/probe17]
connect_debug_port u_ila_0/probe17 [get_nets [list fault_gen/ch1_faults/dac_change_flag]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe18]
set_property port_width 1 [get_debug_ports u_ila_0/probe18]
connect_debug_port u_ila_0/probe18 [get_nets [list fault_gen/ch1_faults/ac_on_out]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets pl_clk0]
