

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
connect_debug_port u_ila_0/probe0 [get_nets [list {fault_gen/ch1_faults/fault_params[ovv_thresh][0]} {fault_gen/ch1_faults/fault_params[ovv_thresh][1]} {fault_gen/ch1_faults/fault_params[ovv_thresh][2]} {fault_gen/ch1_faults/fault_params[ovv_thresh][3]} {fault_gen/ch1_faults/fault_params[ovv_thresh][4]} {fault_gen/ch1_faults/fault_params[ovv_thresh][5]} {fault_gen/ch1_faults/fault_params[ovv_thresh][6]} {fault_gen/ch1_faults/fault_params[ovv_thresh][7]} {fault_gen/ch1_faults/fault_params[ovv_thresh][8]} {fault_gen/ch1_faults/fault_params[ovv_thresh][9]} {fault_gen/ch1_faults/fault_params[ovv_thresh][10]} {fault_gen/ch1_faults/fault_params[ovv_thresh][11]} {fault_gen/ch1_faults/fault_params[ovv_thresh][12]} {fault_gen/ch1_faults/fault_params[ovv_thresh][13]} {fault_gen/ch1_faults/fault_params[ovv_thresh][14]} {fault_gen/ch1_faults/fault_params[ovv_thresh][15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
set_property port_width 16 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list {fault_gen/ch1_faults/fault_params[enable][0]} {fault_gen/ch1_faults/fault_params[enable][1]} {fault_gen/ch1_faults/fault_params[enable][2]} {fault_gen/ch1_faults/fault_params[enable][3]} {fault_gen/ch1_faults/fault_params[enable][4]} {fault_gen/ch1_faults/fault_params[enable][5]} {fault_gen/ch1_faults/fault_params[enable][6]} {fault_gen/ch1_faults/fault_params[enable][7]} {fault_gen/ch1_faults/fault_params[enable][8]} {fault_gen/ch1_faults/fault_params[enable][9]} {fault_gen/ch1_faults/fault_params[enable][10]} {fault_gen/ch1_faults/fault_params[enable][11]} {fault_gen/ch1_faults/fault_params[enable][12]} {fault_gen/ch1_faults/fault_params[enable][13]} {fault_gen/ch1_faults/fault_params[enable][14]} {fault_gen/ch1_faults/fault_params[enable][15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe2]
set_property port_width 16 [get_debug_ports u_ila_0/probe2]
connect_debug_port u_ila_0/probe2 [get_nets [list {fault_gen/ch1_faults/fault_reg[0]} {fault_gen/ch1_faults/fault_reg[1]} {fault_gen/ch1_faults/fault_reg[2]} {fault_gen/ch1_faults/fault_reg[3]} {fault_gen/ch1_faults/fault_reg[4]} {fault_gen/ch1_faults/fault_reg[5]} {fault_gen/ch1_faults/fault_reg[6]} {fault_gen/ch1_faults/fault_reg[7]} {fault_gen/ch1_faults/fault_reg[8]} {fault_gen/ch1_faults/fault_reg[9]} {fault_gen/ch1_faults/fault_reg[10]} {fault_gen/ch1_faults/fault_reg[11]} {fault_gen/ch1_faults/fault_reg[12]} {fault_gen/ch1_faults/fault_reg[13]} {fault_gen/ch1_faults/fault_reg[14]} {fault_gen/ch1_faults/fault_reg[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe3]
set_property port_width 16 [get_debug_ports u_ila_0/probe3]
connect_debug_port u_ila_0/probe3 [get_nets [list {fault_gen/ch1_faults/fault_params[ovv_cntlim][0]} {fault_gen/ch1_faults/fault_params[ovv_cntlim][1]} {fault_gen/ch1_faults/fault_params[ovv_cntlim][2]} {fault_gen/ch1_faults/fault_params[ovv_cntlim][3]} {fault_gen/ch1_faults/fault_params[ovv_cntlim][4]} {fault_gen/ch1_faults/fault_params[ovv_cntlim][5]} {fault_gen/ch1_faults/fault_params[ovv_cntlim][6]} {fault_gen/ch1_faults/fault_params[ovv_cntlim][7]} {fault_gen/ch1_faults/fault_params[ovv_cntlim][8]} {fault_gen/ch1_faults/fault_params[ovv_cntlim][9]} {fault_gen/ch1_faults/fault_params[ovv_cntlim][10]} {fault_gen/ch1_faults/fault_params[ovv_cntlim][11]} {fault_gen/ch1_faults/fault_params[ovv_cntlim][12]} {fault_gen/ch1_faults/fault_params[ovv_cntlim][13]} {fault_gen/ch1_faults/fault_params[ovv_cntlim][14]} {fault_gen/ch1_faults/fault_params[ovv_cntlim][15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe4]
set_property port_width 16 [get_debug_ports u_ila_0/probe4]
connect_debug_port u_ila_0/probe4 [get_nets [list {fault_gen/ch1_faults/fault_reg_lat_mask[0]} {fault_gen/ch1_faults/fault_reg_lat_mask[1]} {fault_gen/ch1_faults/fault_reg_lat_mask[2]} {fault_gen/ch1_faults/fault_reg_lat_mask[3]} {fault_gen/ch1_faults/fault_reg_lat_mask[4]} {fault_gen/ch1_faults/fault_reg_lat_mask[5]} {fault_gen/ch1_faults/fault_reg_lat_mask[6]} {fault_gen/ch1_faults/fault_reg_lat_mask[7]} {fault_gen/ch1_faults/fault_reg_lat_mask[8]} {fault_gen/ch1_faults/fault_reg_lat_mask[9]} {fault_gen/ch1_faults/fault_reg_lat_mask[10]} {fault_gen/ch1_faults/fault_reg_lat_mask[11]} {fault_gen/ch1_faults/fault_reg_lat_mask[12]} {fault_gen/ch1_faults/fault_reg_lat_mask[13]} {fault_gen/ch1_faults/fault_reg_lat_mask[14]} {fault_gen/ch1_faults/fault_reg_lat_mask[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe5]
set_property port_width 16 [get_debug_ports u_ila_0/probe5]
connect_debug_port u_ila_0/probe5 [get_nets [list {fault_gen/ch1_faults/fault_stat[lat][0]} {fault_gen/ch1_faults/fault_stat[lat][1]} {fault_gen/ch1_faults/fault_stat[lat][2]} {fault_gen/ch1_faults/fault_stat[lat][3]} {fault_gen/ch1_faults/fault_stat[lat][4]} {fault_gen/ch1_faults/fault_stat[lat][5]} {fault_gen/ch1_faults/fault_stat[lat][6]} {fault_gen/ch1_faults/fault_stat[lat][7]} {fault_gen/ch1_faults/fault_stat[lat][8]} {fault_gen/ch1_faults/fault_stat[lat][9]} {fault_gen/ch1_faults/fault_stat[lat][10]} {fault_gen/ch1_faults/fault_stat[lat][11]} {fault_gen/ch1_faults/fault_stat[lat][12]} {fault_gen/ch1_faults/fault_stat[lat][13]} {fault_gen/ch1_faults/fault_stat[lat][14]} {fault_gen/ch1_faults/fault_stat[lat][15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe6]
set_property port_width 16 [get_debug_ports u_ila_0/probe6]
connect_debug_port u_ila_0/probe6 [get_nets [list {fault_gen/ch1_faults/fault_stat[live][0]} {fault_gen/ch1_faults/fault_stat[live][1]} {fault_gen/ch1_faults/fault_stat[live][2]} {fault_gen/ch1_faults/fault_stat[live][3]} {fault_gen/ch1_faults/fault_stat[live][4]} {fault_gen/ch1_faults/fault_stat[live][5]} {fault_gen/ch1_faults/fault_stat[live][6]} {fault_gen/ch1_faults/fault_stat[live][7]} {fault_gen/ch1_faults/fault_stat[live][8]} {fault_gen/ch1_faults/fault_stat[live][9]} {fault_gen/ch1_faults/fault_stat[live][10]} {fault_gen/ch1_faults/fault_stat[live][11]} {fault_gen/ch1_faults/fault_stat[live][12]} {fault_gen/ch1_faults/fault_stat[live][13]} {fault_gen/ch1_faults/fault_stat[live][14]} {fault_gen/ch1_faults/fault_stat[live][15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe7]
set_property port_width 16 [get_debug_ports u_ila_0/probe7]
connect_debug_port u_ila_0/probe7 [get_nets [list {dig_io/fault[ps1][live][0]} {dig_io/fault[ps1][live][1]} {dig_io/fault[ps1][live][2]} {dig_io/fault[ps1][live][3]} {dig_io/fault[ps1][live][4]} {dig_io/fault[ps1][live][5]} {dig_io/fault[ps1][live][6]} {dig_io/fault[ps1][live][7]} {dig_io/fault[ps1][live][8]} {dig_io/fault[ps1][live][9]} {dig_io/fault[ps1][live][10]} {dig_io/fault[ps1][live][11]} {dig_io/fault[ps1][live][12]} {dig_io/fault[ps1][live][13]} {dig_io/fault[ps1][live][14]} {dig_io/fault[ps1][live][15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe8]
set_property port_width 4 [get_debug_ports u_ila_0/probe8]
connect_debug_port u_ila_0/probe8 [get_nets [list {dig_io/ps_on2[0]} {dig_io/ps_on2[1]} {dig_io/ps_on2[2]} {dig_io/ps_on2[3]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe9]
set_property port_width 8 [get_debug_ports u_ila_0/probe9]
connect_debug_port u_ila_0/probe9 [get_nets [list {dig_io/rcom_orig[0]} {dig_io/rcom_orig[1]} {dig_io/rcom_orig[4]} {dig_io/rcom_orig[5]} {dig_io/rcom_orig[8]} {dig_io/rcom_orig[9]} {dig_io/rcom_orig[12]} {dig_io/rcom_orig[13]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe10]
set_property port_width 4 [get_debug_ports u_ila_0/probe10]
connect_debug_port u_ila_0/probe10 [get_nets [list {dig_io/ps_on1[0]} {dig_io/ps_on1[1]} {dig_io/ps_on1[2]} {dig_io/ps_on1[3]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe11]
set_property port_width 16 [get_debug_ports u_ila_0/probe11]
connect_debug_port u_ila_0/probe11 [get_nets [list {dig_io/fault[ps1][lat][0]} {dig_io/fault[ps1][lat][1]} {dig_io/fault[ps1][lat][2]} {dig_io/fault[ps1][lat][3]} {dig_io/fault[ps1][lat][4]} {dig_io/fault[ps1][lat][5]} {dig_io/fault[ps1][lat][6]} {dig_io/fault[ps1][lat][7]} {dig_io/fault[ps1][lat][8]} {dig_io/fault[ps1][lat][9]} {dig_io/fault[ps1][lat][10]} {dig_io/fault[ps1][lat][11]} {dig_io/fault[ps1][lat][12]} {dig_io/fault[ps1][lat][13]} {dig_io/fault[ps1][lat][14]} {dig_io/fault[ps1][lat][15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe12]
set_property port_width 12 [get_debug_ports u_ila_0/probe12]
connect_debug_port u_ila_0/probe12 [get_nets [list {dig_io/rcom[2]} {dig_io/rcom[3]} {dig_io/rcom[6]} {dig_io/rcom[7]} {dig_io/rcom[10]} {dig_io/rcom[11]} {dig_io/rcom[14]} {dig_io/rcom[15]} {dig_io/rcom[16]} {dig_io/rcom[17]} {dig_io/rcom[18]} {dig_io/rcom[19]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe13]
set_property port_width 16 [get_debug_ports u_ila_0/probe13]
connect_debug_port u_ila_0/probe13 [get_nets [list {fault_gen/ch1_faults/mon_adcs[spare][0]} {fault_gen/ch1_faults/mon_adcs[spare][1]} {fault_gen/ch1_faults/mon_adcs[spare][2]} {fault_gen/ch1_faults/mon_adcs[spare][3]} {fault_gen/ch1_faults/mon_adcs[spare][4]} {fault_gen/ch1_faults/mon_adcs[spare][5]} {fault_gen/ch1_faults/mon_adcs[spare][6]} {fault_gen/ch1_faults/mon_adcs[spare][7]} {fault_gen/ch1_faults/mon_adcs[spare][8]} {fault_gen/ch1_faults/mon_adcs[spare][9]} {fault_gen/ch1_faults/mon_adcs[spare][10]} {fault_gen/ch1_faults/mon_adcs[spare][11]} {fault_gen/ch1_faults/mon_adcs[spare][12]} {fault_gen/ch1_faults/mon_adcs[spare][13]} {fault_gen/ch1_faults/mon_adcs[spare][14]} {fault_gen/ch1_faults/mon_adcs[spare][15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe14]
set_property port_width 16 [get_debug_ports u_ila_0/probe14]
connect_debug_port u_ila_0/probe14 [get_nets [list {fault_gen/ch1_faults/p_0_in0_in[0]} {fault_gen/ch1_faults/p_0_in0_in[1]} {fault_gen/ch1_faults/p_0_in0_in[2]} {fault_gen/ch1_faults/p_0_in0_in[3]} {fault_gen/ch1_faults/p_0_in0_in[4]} {fault_gen/ch1_faults/p_0_in0_in[5]} {fault_gen/ch1_faults/p_0_in0_in[6]} {fault_gen/ch1_faults/p_0_in0_in[7]} {fault_gen/ch1_faults/p_0_in0_in[8]} {fault_gen/ch1_faults/p_0_in0_in[9]} {fault_gen/ch1_faults/p_0_in0_in[10]} {fault_gen/ch1_faults/p_0_in0_in[11]} {fault_gen/ch1_faults/p_0_in0_in[12]} {fault_gen/ch1_faults/p_0_in0_in[13]} {fault_gen/ch1_faults/p_0_in0_in[14]} {fault_gen/ch1_faults/p_0_in0_in[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe15]
set_property port_width 16 [get_debug_ports u_ila_0/probe15]
connect_debug_port u_ila_0/probe15 [get_nets [list {fault_gen/ch1_faults/mon_adcs[voltage_raw][0]} {fault_gen/ch1_faults/mon_adcs[voltage_raw][1]} {fault_gen/ch1_faults/mon_adcs[voltage_raw][2]} {fault_gen/ch1_faults/mon_adcs[voltage_raw][3]} {fault_gen/ch1_faults/mon_adcs[voltage_raw][4]} {fault_gen/ch1_faults/mon_adcs[voltage_raw][5]} {fault_gen/ch1_faults/mon_adcs[voltage_raw][6]} {fault_gen/ch1_faults/mon_adcs[voltage_raw][7]} {fault_gen/ch1_faults/mon_adcs[voltage_raw][8]} {fault_gen/ch1_faults/mon_adcs[voltage_raw][9]} {fault_gen/ch1_faults/mon_adcs[voltage_raw][10]} {fault_gen/ch1_faults/mon_adcs[voltage_raw][11]} {fault_gen/ch1_faults/mon_adcs[voltage_raw][12]} {fault_gen/ch1_faults/mon_adcs[voltage_raw][13]} {fault_gen/ch1_faults/mon_adcs[voltage_raw][14]} {fault_gen/ch1_faults/mon_adcs[voltage_raw][15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe16]
set_property port_width 16 [get_debug_ports u_ila_0/probe16]
connect_debug_port u_ila_0/probe16 [get_nets [list {fault_gen/ch1_faults/mon_adcs[voltage_oc][0]} {fault_gen/ch1_faults/mon_adcs[voltage_oc][1]} {fault_gen/ch1_faults/mon_adcs[voltage_oc][2]} {fault_gen/ch1_faults/mon_adcs[voltage_oc][3]} {fault_gen/ch1_faults/mon_adcs[voltage_oc][4]} {fault_gen/ch1_faults/mon_adcs[voltage_oc][5]} {fault_gen/ch1_faults/mon_adcs[voltage_oc][6]} {fault_gen/ch1_faults/mon_adcs[voltage_oc][7]} {fault_gen/ch1_faults/mon_adcs[voltage_oc][8]} {fault_gen/ch1_faults/mon_adcs[voltage_oc][9]} {fault_gen/ch1_faults/mon_adcs[voltage_oc][10]} {fault_gen/ch1_faults/mon_adcs[voltage_oc][11]} {fault_gen/ch1_faults/mon_adcs[voltage_oc][12]} {fault_gen/ch1_faults/mon_adcs[voltage_oc][13]} {fault_gen/ch1_faults/mon_adcs[voltage_oc][14]} {fault_gen/ch1_faults/mon_adcs[voltage_oc][15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe17]
set_property port_width 16 [get_debug_ports u_ila_0/probe17]
connect_debug_port u_ila_0/probe17 [get_nets [list {fault_gen/ch1_faults/mon_adcs[spare_oc][0]} {fault_gen/ch1_faults/mon_adcs[spare_oc][1]} {fault_gen/ch1_faults/mon_adcs[spare_oc][2]} {fault_gen/ch1_faults/mon_adcs[spare_oc][3]} {fault_gen/ch1_faults/mon_adcs[spare_oc][4]} {fault_gen/ch1_faults/mon_adcs[spare_oc][5]} {fault_gen/ch1_faults/mon_adcs[spare_oc][6]} {fault_gen/ch1_faults/mon_adcs[spare_oc][7]} {fault_gen/ch1_faults/mon_adcs[spare_oc][8]} {fault_gen/ch1_faults/mon_adcs[spare_oc][9]} {fault_gen/ch1_faults/mon_adcs[spare_oc][10]} {fault_gen/ch1_faults/mon_adcs[spare_oc][11]} {fault_gen/ch1_faults/mon_adcs[spare_oc][12]} {fault_gen/ch1_faults/mon_adcs[spare_oc][13]} {fault_gen/ch1_faults/mon_adcs[spare_oc][14]} {fault_gen/ch1_faults/mon_adcs[spare_oc][15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe18]
set_property port_width 16 [get_debug_ports u_ila_0/probe18]
connect_debug_port u_ila_0/probe18 [get_nets [list {fault_gen/ch1_faults/mon_adcs[spare_raw][0]} {fault_gen/ch1_faults/mon_adcs[spare_raw][1]} {fault_gen/ch1_faults/mon_adcs[spare_raw][2]} {fault_gen/ch1_faults/mon_adcs[spare_raw][3]} {fault_gen/ch1_faults/mon_adcs[spare_raw][4]} {fault_gen/ch1_faults/mon_adcs[spare_raw][5]} {fault_gen/ch1_faults/mon_adcs[spare_raw][6]} {fault_gen/ch1_faults/mon_adcs[spare_raw][7]} {fault_gen/ch1_faults/mon_adcs[spare_raw][8]} {fault_gen/ch1_faults/mon_adcs[spare_raw][9]} {fault_gen/ch1_faults/mon_adcs[spare_raw][10]} {fault_gen/ch1_faults/mon_adcs[spare_raw][11]} {fault_gen/ch1_faults/mon_adcs[spare_raw][12]} {fault_gen/ch1_faults/mon_adcs[spare_raw][13]} {fault_gen/ch1_faults/mon_adcs[spare_raw][14]} {fault_gen/ch1_faults/mon_adcs[spare_raw][15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe19]
set_property port_width 16 [get_debug_ports u_ila_0/probe19]
connect_debug_port u_ila_0/probe19 [get_nets [list {fault_gen/ch1_faults/mon_adcs[voltage][0]} {fault_gen/ch1_faults/mon_adcs[voltage][1]} {fault_gen/ch1_faults/mon_adcs[voltage][2]} {fault_gen/ch1_faults/mon_adcs[voltage][3]} {fault_gen/ch1_faults/mon_adcs[voltage][4]} {fault_gen/ch1_faults/mon_adcs[voltage][5]} {fault_gen/ch1_faults/mon_adcs[voltage][6]} {fault_gen/ch1_faults/mon_adcs[voltage][7]} {fault_gen/ch1_faults/mon_adcs[voltage][8]} {fault_gen/ch1_faults/mon_adcs[voltage][9]} {fault_gen/ch1_faults/mon_adcs[voltage][10]} {fault_gen/ch1_faults/mon_adcs[voltage][11]} {fault_gen/ch1_faults/mon_adcs[voltage][12]} {fault_gen/ch1_faults/mon_adcs[voltage][13]} {fault_gen/ch1_faults/mon_adcs[voltage][14]} {fault_gen/ch1_faults/mon_adcs[voltage][15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe20]
set_property port_width 1 [get_debug_ports u_ila_0/probe20]
connect_debug_port u_ila_0/probe20 [get_nets [list {dig_io/fault[ps2][flt_trig]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe21]
set_property port_width 1 [get_debug_ports u_ila_0/probe21]
connect_debug_port u_ila_0/probe21 [get_nets [list {dig_io/fault[ps1][err_trig]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe22]
set_property port_width 1 [get_debug_ports u_ila_0/probe22]
connect_debug_port u_ila_0/probe22 [get_nets [list {dig_io/fault[ps1][flt_trig]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe23]
set_property port_width 1 [get_debug_ports u_ila_0/probe23]
connect_debug_port u_ila_0/probe23 [get_nets [list {dig_io/dig_stat[ps1][spare]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe24]
set_property port_width 1 [get_debug_ports u_ila_0/probe24]
connect_debug_port u_ila_0/probe24 [get_nets [list {dig_io/dig_stat[ps2][acon]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe25]
set_property port_width 1 [get_debug_ports u_ila_0/probe25]
connect_debug_port u_ila_0/probe25 [get_nets [list {dig_io/dig_stat[ps2][dcct_flt]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe26]
set_property port_width 1 [get_debug_ports u_ila_0/probe26]
connect_debug_port u_ila_0/probe26 [get_nets [list {dig_io/dig_stat[ps2][flt1]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe27]
set_property port_width 1 [get_debug_ports u_ila_0/probe27]
connect_debug_port u_ila_0/probe27 [get_nets [list {fault_gen/ch1_faults/fault_stat[flt_trig]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe28]
set_property port_width 1 [get_debug_ports u_ila_0/probe28]
connect_debug_port u_ila_0/probe28 [get_nets [list tenkhz_trig]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe29]
set_property port_width 1 [get_debug_ports u_ila_0/probe29]
connect_debug_port u_ila_0/probe29 [get_nets [list {dig_io/dig_stat[ps2][spare]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe30]
set_property port_width 1 [get_debug_ports u_ila_0/probe30]
connect_debug_port u_ila_0/probe30 [get_nets [list {dig_io/dig_stat[ps2][flt2]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe31]
set_property port_width 1 [get_debug_ports u_ila_0/probe31]
connect_debug_port u_ila_0/probe31 [get_nets [list {fault_gen/ch1_faults/fault_stat[err_trig]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe32]
set_property port_width 1 [get_debug_ports u_ila_0/probe32]
connect_debug_port u_ila_0/probe32 [get_nets [list {fault_gen/ch1_faults/fault_params[clear]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe33]
set_property port_width 1 [get_debug_ports u_ila_0/probe33]
connect_debug_port u_ila_0/probe33 [get_nets [list {dig_io/dig_stat[ps1][acon]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe34]
set_property port_width 1 [get_debug_ports u_ila_0/probe34]
connect_debug_port u_ila_0/probe34 [get_nets [list {dig_io/dig_stat[ps1][dcct_flt]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe35]
set_property port_width 1 [get_debug_ports u_ila_0/probe35]
connect_debug_port u_ila_0/probe35 [get_nets [list {dig_io/dig_stat[ps1][flt1]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe36]
set_property port_width 1 [get_debug_ports u_ila_0/probe36]
connect_debug_port u_ila_0/probe36 [get_nets [list {dig_io/dig_stat[ps1][flt2]}]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets pl_clk0]
