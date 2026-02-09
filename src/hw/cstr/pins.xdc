

# 24 16-bit ADC Channels (3 - ADS5868)
set_property PACKAGE_PIN C1 [get_ports mon_adc_rst]
set_property IOSTANDARD LVCMOS18 [get_ports mon_adc_rst]
set_property PACKAGE_PIN D1 [get_ports mon_adc_cnv]
set_property IOSTANDARD LVCMOS18 [get_ports mon_adc_cnv]
set_property PACKAGE_PIN B4 [get_ports mon_adc_sck]
set_property IOSTANDARD LVCMOS18 [get_ports mon_adc_sck]
set_property PACKAGE_PIN B3 [get_ports mon_adc_fs]
set_property IOSTANDARD LVCMOS18 [get_ports mon_adc_fs]
set_property PACKAGE_PIN D3 [get_ports {mon_adc_busy[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports {mon_adc_busy[0]}]
set_property PACKAGE_PIN C4 [get_ports {mon_adc_busy[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {mon_adc_busy[1]}]
set_property PACKAGE_PIN D5 [get_ports {mon_adc_busy[2]}]
set_property IOSTANDARD LVCMOS18 [get_ports {mon_adc_busy[2]}]
set_property PACKAGE_PIN A1 [get_ports {mon_adc_sdo[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports {mon_adc_sdo[0]}]
set_property PACKAGE_PIN A2 [get_ports {mon_adc_sdo[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {mon_adc_sdo[1]}]
set_property PACKAGE_PIN C3 [get_ports {mon_adc_sdo[2]}]
set_property IOSTANDARD LVCMOS18 [get_ports {mon_adc_sdo[2]}]


# 8 20-bit ADC Channels for DCCT's (8 - LTC2376)
set_property PACKAGE_PIN E8 [get_ports dcct_adc_cnv]
set_property IOSTANDARD LVCMOS18 [get_ports dcct_adc_cnv]
set_property PACKAGE_PIN D8 [get_ports dcct_adc_sck]
set_property IOSTANDARD LVCMOS18 [get_ports dcct_adc_sck]
set_property PACKAGE_PIN B1 [get_ports {dcct_adc_busy[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports {dcct_adc_busy[0]}]
set_property PACKAGE_PIN B2 [get_ports {dcct_adc_busy[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {dcct_adc_busy[1]}]
set_property PACKAGE_PIN E3 [get_ports {dcct_adc_busy[2]}]
set_property IOSTANDARD LVCMOS18 [get_ports {dcct_adc_busy[2]}]
set_property PACKAGE_PIN E4 [get_ports {dcct_adc_busy[3]}]
set_property IOSTANDARD LVCMOS18 [get_ports {dcct_adc_busy[3]}]
set_property PACKAGE_PIN F6 [get_ports {dcct_adc_sdo[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports {dcct_adc_sdo[0]}]
set_property PACKAGE_PIN G6 [get_ports {dcct_adc_sdo[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {dcct_adc_sdo[1]}]
set_property PACKAGE_PIN F4 [get_ports {dcct_adc_sdo[2]}]
set_property IOSTANDARD LVCMOS18 [get_ports {dcct_adc_sdo[2]}]
set_property PACKAGE_PIN G4 [get_ports {dcct_adc_sdo[3]}]
set_property IOSTANDARD LVCMOS18 [get_ports {dcct_adc_sdo[3]}]


# 4 18-bit DAC Channels AD5781
set_property PACKAGE_PIN A7 [get_ports {stpt_dac_sync[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports {stpt_dac_sync[0]}]
set_property PACKAGE_PIN A4 [get_ports {stpt_dac_sync[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {stpt_dac_sync[1]}]

set_property PACKAGE_PIN A6 [get_ports stpt_dac_sck]
set_property IOSTANDARD LVCMOS18 [get_ports stpt_dac_sck]
set_property PACKAGE_PIN G7 [get_ports {stpt_dac_sdo[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports {stpt_dac_sdo[0]}]
set_property PACKAGE_PIN G8 [get_ports {stpt_dac_sdo[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {stpt_dac_sdo[1]}]
set_property PACKAGE_PIN E7 [get_ports {stpt_dac_sdo[2]}]
set_property IOSTANDARD LVCMOS18 [get_ports {stpt_dac_sdo[2]}]
set_property PACKAGE_PIN F7 [get_ports {stpt_dac_sdo[3]}]
set_property IOSTANDARD LVCMOS18 [get_ports {stpt_dac_sdo[3]}]





# Command digital outputs
set_property PACKAGE_PIN M4 [get_ports {rcom[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports {rcom[0]}]
set_property DRIVE 12 [get_ports {rcom[0]}]
set_property SLEW SLOW [get_ports {rcom[0]}]

set_property PACKAGE_PIN M3 [get_ports {rcom[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {rcom[1]}]
set_property DRIVE 12 [get_ports {rcom[1]}]
set_property SLEW SLOW [get_ports {rcom[1]}]

set_property PACKAGE_PIN K7 [get_ports {rcom[2]}]
set_property IOSTANDARD LVCMOS18 [get_ports {rcom[2]}]
set_property DRIVE 12 [get_ports {rcom[2]}]
set_property SLEW SLOW [get_ports {rcom[2]}]

set_property PACKAGE_PIN L7 [get_ports {rcom[3]}]
set_property IOSTANDARD LVCMOS18 [get_ports {rcom[3]}]
set_property DRIVE 12 [get_ports {rcom[3]}]
set_property SLEW SLOW [get_ports {rcom[3]}]

set_property PACKAGE_PIN P7 [get_ports {rcom[4]}]
set_property IOSTANDARD LVCMOS18 [get_ports {rcom[4]}]
set_property DRIVE 12 [get_ports {rcom[4]}]
set_property SLEW SLOW [get_ports {rcom[4]}]

set_property PACKAGE_PIN R7 [get_ports {rcom[5]}]
set_property IOSTANDARD LVCMOS18 [get_ports {rcom[5]}]
set_property DRIVE 12 [get_ports {rcom[5]}]
set_property SLEW SLOW [get_ports {rcom[5]}]

set_property PACKAGE_PIN N4 [get_ports {rcom[6]}]
set_property IOSTANDARD LVCMOS18 [get_ports {rcom[6]}]
set_property DRIVE 12 [get_ports {rcom[6]}]
set_property SLEW SLOW [get_ports {rcom[6]}]

set_property PACKAGE_PIN N3 [get_ports {rcom[7]}]
set_property IOSTANDARD LVCMOS18 [get_ports {rcom[7]}]
set_property DRIVE 12 [get_ports {rcom[7]}]
set_property SLEW SLOW [get_ports {rcom[7]}]

set_property PACKAGE_PIN M2 [get_ports {rcom[8]}]
set_property IOSTANDARD LVCMOS18 [get_ports {rcom[8]}]
set_property DRIVE 12 [get_ports {rcom[8]}]
set_property SLEW SLOW [get_ports {rcom[8]}]

set_property PACKAGE_PIN M1 [get_ports {rcom[9]}]
set_property IOSTANDARD LVCMOS18 [get_ports {rcom[9]}]
set_property DRIVE 12 [get_ports {rcom[9]}]
set_property SLEW SLOW [get_ports {rcom[9]}]

set_property PACKAGE_PIN K4 [get_ports {rcom[10]}]
set_property IOSTANDARD LVCMOS18 [get_ports {rcom[10]}]
set_property DRIVE 12 [get_ports {rcom[10]}]
set_property SLEW SLOW [get_ports {rcom[10]}]

set_property PACKAGE_PIN K3 [get_ports {rcom[11]}]
set_property IOSTANDARD LVCMOS18 [get_ports {rcom[11]}]
set_property DRIVE 12 [get_ports {rcom[11]}]
set_property SLEW SLOW [get_ports {rcom[11]}]

set_property PACKAGE_PIN T2 [get_ports {rcom[12]}]
set_property IOSTANDARD LVCMOS18 [get_ports {rcom[12]}]
set_property DRIVE 12 [get_ports {rcom[12]}]
set_property SLEW SLOW [get_ports {rcom[12]}]

set_property PACKAGE_PIN T1 [get_ports {rcom[13]}]
set_property IOSTANDARD LVCMOS18 [get_ports {rcom[13]}]
set_property DRIVE 12 [get_ports {rcom[13]}]
set_property SLEW SLOW [get_ports {rcom[13]}]

set_property PACKAGE_PIN R3 [get_ports {rcom[14]}]
set_property IOSTANDARD LVCMOS18 [get_ports {rcom[14]}]
set_property DRIVE 12 [get_ports {rcom[14]}]
set_property SLEW SLOW [get_ports {rcom[14]}]

set_property PACKAGE_PIN R2 [get_ports {rcom[15]}]
set_property IOSTANDARD LVCMOS18 [get_ports {rcom[15]}]
set_property DRIVE 12 [get_ports {rcom[15]}]
set_property SLEW SLOW [get_ports {rcom[15]}]

set_property PACKAGE_PIN J5 [get_ports {rcom[16]}]
set_property IOSTANDARD LVCMOS18 [get_ports {rcom[16]}]
set_property DRIVE 12 [get_ports {rcom[16]}]
set_property SLEW SLOW [get_ports {rcom[16]}]

set_property PACKAGE_PIN K5 [get_ports {rcom[17]}]
set_property IOSTANDARD LVCMOS18 [get_ports {rcom[17]}]
set_property DRIVE 12 [get_ports {rcom[17]}]
set_property SLEW SLOW [get_ports {rcom[17]}]

set_property PACKAGE_PIN J7 [get_ports {rcom[18]}]
set_property IOSTANDARD LVCMOS18 [get_ports {rcom[18]}]
set_property DRIVE 12 [get_ports {rcom[18]}]
set_property SLEW SLOW [get_ports {rcom[18]}]

set_property PACKAGE_PIN J6 [get_ports {rcom[19]}]
set_property IOSTANDARD LVCMOS18 [get_ports {rcom[19]}]
set_property DRIVE 12 [get_ports {rcom[19]}]
set_property SLEW SLOW [get_ports {rcom[19]}]



# Command digital inputs
set_property PACKAGE_PIN J2 [get_ports {rsts[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports {rsts[0]}]

set_property PACKAGE_PIN J1 [get_ports {rsts[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {rsts[1]}]

set_property PACKAGE_PIN J3 [get_ports {rsts[2]}]
set_property IOSTANDARD LVCMOS18 [get_ports {rsts[2]}]

set_property PACKAGE_PIN K2 [get_ports {rsts[3]}]
set_property IOSTANDARD LVCMOS18 [get_ports {rsts[3]}]

set_property PACKAGE_PIN L2 [get_ports {rsts[4]}]
set_property IOSTANDARD LVCMOS18 [get_ports {rsts[4]}]

set_property PACKAGE_PIN L1 [get_ports {rsts[5]}]
set_property IOSTANDARD LVCMOS18 [get_ports {rsts[5]}]

set_property PACKAGE_PIN P3 [get_ports {rsts[6]}]
set_property IOSTANDARD LVCMOS18 [get_ports {rsts[6]}]

set_property PACKAGE_PIN P2 [get_ports {rsts[7]}]
set_property IOSTANDARD LVCMOS18 [get_ports {rsts[7]}]

set_property PACKAGE_PIN N1 [get_ports {rsts[8]}]
set_property IOSTANDARD LVCMOS18 [get_ports {rsts[8]}]

set_property PACKAGE_PIN P1 [get_ports {rsts[9]}]
set_property IOSTANDARD LVCMOS18 [get_ports {rsts[9]}]

set_property PACKAGE_PIN L5 [get_ports {rsts[10]}]
set_property IOSTANDARD LVCMOS18 [get_ports {rsts[10]}]

set_property PACKAGE_PIN L4 [get_ports {rsts[11]}]
set_property IOSTANDARD LVCMOS18 [get_ports {rsts[11]}]

set_property PACKAGE_PIN U2 [get_ports {rsts[12]}]
set_property IOSTANDARD LVCMOS18 [get_ports {rsts[12]}]

set_property PACKAGE_PIN U1 [get_ports {rsts[13]}]
set_property IOSTANDARD LVCMOS18 [get_ports {rsts[13]}]

set_property PACKAGE_PIN L6 [get_ports {rsts[14]}]
set_property IOSTANDARD LVCMOS18 [get_ports {rsts[14]}]

set_property PACKAGE_PIN M6 [get_ports {rsts[15]}]
set_property IOSTANDARD LVCMOS18 [get_ports {rsts[15]}]

set_property PACKAGE_PIN R5 [get_ports {rsts[16]}]
set_property IOSTANDARD LVCMOS18 [get_ports {rsts[16]}]

set_property PACKAGE_PIN R4 [get_ports {rsts[17]}]
set_property IOSTANDARD LVCMOS18 [get_ports {rsts[17]}]

set_property PACKAGE_PIN P6 [get_ports {rsts[18]}]
set_property IOSTANDARD LVCMOS18 [get_ports {rsts[18]}]

set_property PACKAGE_PIN P5 [get_ports {rsts[19]}]
set_property IOSTANDARD LVCMOS18 [get_ports {rsts[19]}]



# Trigger inputs
set_property PACKAGE_PIN M7 [get_ports {trig[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports {trig[0]}]

set_property PACKAGE_PIN M8 [get_ports {trig[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {trig[1]}]

set_property PACKAGE_PIN P8 [get_ports {trig[2]}]
set_property IOSTANDARD LVCMOS18 [get_ports {trig[2]}]

set_property PACKAGE_PIN N8 [get_ports {trig[3]}]
set_property IOSTANDARD LVCMOS18 [get_ports {trig[3]}]



#front panel LEDS
set_property PACKAGE_PIN AA14 [get_ports {fp_leds[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {fp_leds[0]}]
set_property DRIVE 12 [get_ports {fp_leds[0]}]
set_property SLEW SLOW [get_ports {fp_leds[0]}]

set_property PACKAGE_PIN AA15 [get_ports {fp_leds[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {fp_leds[1]}]
set_property DRIVE 12 [get_ports {fp_leds[1]}]
set_property SLEW SLOW [get_ports {fp_leds[1]}]

set_property PACKAGE_PIN U19 [get_ports {fp_leds[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {fp_leds[2]}]
set_property DRIVE 12 [get_ports {fp_leds[2]}]
set_property SLEW SLOW [get_ports {fp_leds[2]}]

set_property PACKAGE_PIN V19 [get_ports {fp_leds[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {fp_leds[3]}]
set_property DRIVE 12 [get_ports {fp_leds[3]}]
set_property SLEW SLOW [get_ports {fp_leds[3]}]

set_property PACKAGE_PIN Y14 [get_ports {fp_leds[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {fp_leds[4]}]
set_property DRIVE 12 [get_ports {fp_leds[4]}]
set_property SLEW SLOW [get_ports {fp_leds[4]}]

set_property PACKAGE_PIN Y15 [get_ports {fp_leds[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {fp_leds[5]}]
set_property DRIVE 12 [get_ports {fp_leds[5]}]
set_property SLEW SLOW [get_ports {fp_leds[5]}]

set_property PACKAGE_PIN V18 [get_ports {fp_leds[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {fp_leds[6]}]
set_property DRIVE 12 [get_ports {fp_leds[6]}]
set_property SLEW SLOW [get_ports {fp_leds[6]}]

set_property PACKAGE_PIN W18 [get_ports {fp_leds[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {fp_leds[7]}]
set_property DRIVE 12 [get_ports {fp_leds[7]}]
set_property SLEW SLOW [get_ports {fp_leds[7]}]





## SFP I2C
set_property PACKAGE_PIN AB11 [get_ports {sfp_sck[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sfp_sck[0]}]
set_property PACKAGE_PIN AA11 [get_ports {sfp_sda[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sfp_sda[0]}]

set_property PACKAGE_PIN W11 [get_ports {sfp_sck[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sfp_sck[1]}]
set_property PACKAGE_PIN V11 [get_ports {sfp_sda[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sfp_sda[1]}]

set_property PACKAGE_PIN W13 [get_ports {sfp_sck[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sfp_sck[2]}]
set_property PACKAGE_PIN W12 [get_ports {sfp_sda[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sfp_sda[2]}]

set_property PACKAGE_PIN W15 [get_ports {sfp_sck[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sfp_sck[3]}]
set_property PACKAGE_PIN V15 [get_ports {sfp_sda[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sfp_sda[3]}]


#SFP LEDS
set_property PACKAGE_PIN AA16 [get_ports {sfp_leds[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sfp_leds[0]}]
set_property DRIVE 12 [get_ports {sfp_leds[0]}]
set_property SLEW SLOW [get_ports {sfp_leds[0]}]

set_property PACKAGE_PIN AA17 [get_ports {sfp_leds[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sfp_leds[1]}]
set_property DRIVE 12 [get_ports {sfp_leds[1]}]
set_property SLEW SLOW [get_ports {sfp_leds[1]}]

set_property PACKAGE_PIN Y12 [get_ports {sfp_leds[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sfp_leds[2]}]
set_property DRIVE 12 [get_ports {sfp_leds[2]}]
set_property SLEW SLOW [get_ports {sfp_leds[2]}]

set_property PACKAGE_PIN Y13 [get_ports {sfp_leds[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sfp_leds[3]}]
set_property DRIVE 12 [get_ports {sfp_leds[3]}]
set_property SLEW SLOW [get_ports {sfp_leds[3]}]

set_property PACKAGE_PIN R17 [get_ports {sfp_leds[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sfp_leds[4]}]
set_property DRIVE 12 [get_ports {sfp_leds[4]}]
set_property SLEW SLOW [get_ports {sfp_leds[4]}]

set_property PACKAGE_PIN T17 [get_ports {sfp_leds[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sfp_leds[5]}]
set_property DRIVE 12 [get_ports {sfp_leds[5]}]
set_property SLEW SLOW [get_ports {sfp_leds[5]}]

set_property PACKAGE_PIN V16 [get_ports {sfp_leds[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sfp_leds[6]}]
set_property DRIVE 12 [get_ports {sfp_leds[6]}]
set_property SLEW SLOW [get_ports {sfp_leds[6]}]

set_property PACKAGE_PIN W16 [get_ports {sfp_leds[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sfp_leds[7]}]
set_property DRIVE 12 [get_ports {sfp_leds[7]}]
set_property SLEW SLOW [get_ports {sfp_leds[7]}]





# Si570 programmable oscillator for EVR reference clock
set_property PACKAGE_PIN Y19 [get_ports si570_sck]
set_property IOSTANDARD LVCMOS33 [get_ports si570_sck]
set_property PACKAGE_PIN Y18 [get_ports si570_sda]
set_property IOSTANDARD LVCMOS33 [get_ports si570_sda]

# One wire interface
set_property PACKAGE_PIN H6 [get_ports onewire_sck]
set_property IOSTANDARD LVCMOS18 [get_ports onewire_sck]
set_property PACKAGE_PIN H5 [get_ports onewire_sda]
set_property IOSTANDARD LVCMOS18 [get_ports onewire_sda]


# MAC ID
set_property PACKAGE_PIN V14 [get_ports mac_id]
set_property IOSTANDARD LVCMOS33 [get_ports mac_id]

#fan cntrl
set_property PACKAGE_PIN AB19 [get_ports fan_ctrl]
set_property IOSTANDARD LVCMOS33 [get_ports fan_ctrl]
set_property DRIVE 12 [get_ports fan_ctrl]
set_property SLEW SLOW [get_ports fan_ctrl]


















































