

create_clock -period 3.200 [get_ports gtx_evr_refclk_p]
create_clock -period 8.000 [get_ports gtx_gige_refclk_p]


#MGTREFCLK1 - U501  (Si570 programmable oscillator 312.5MHz)
set_property PACKAGE_PIN U5 [get_ports gtx_evr_refclk_p]
set_property PACKAGE_PIN V5 [get_ports gtx_evr_refclk_n]


#MGTREFCLK0 - U500  (125MHz)
set_property PACKAGE_PIN U9 [get_ports gtx_gige_refclk_p]
set_property PACKAGE_PIN V9 [get_ports gtx_gige_refclk_n]

#

################################# mgt wrapper constraints #####################

##---------- Set placement for gt0_gtx_wrapper_i/GTXE2_CHANNEL ------

set_property LOC GTXE2_CHANNEL_X0Y2 [get_cells evr/evr_gtx_init_i/U0/evr_gtx_i/gt0_evr_gtx_i/gtxe2_i]

set_property LOC GTXE2_CHANNEL_X0Y0 [get_cells fofb/fofb_phy/phy_sfp0_rx/U0/pcs_pma_block_i/transceiver_inst/gtwizard_inst/U0/gtwizard_i/gt0_GTWIZARD_i/gtxe2_i]
set_property LOC GTXE2_CHANNEL_X0Y1 [get_cells fofb/fofb_phy/phy_sfp1_tx/U0/transceiver_inst/gtwizard_inst/U0/gtwizard_i/gt0_GTWIZARD_i/gtxe2_i]














































