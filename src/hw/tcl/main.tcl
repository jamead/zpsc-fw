################################################################################
# Main tcl for the module
################################################################################

# ==============================================================================
proc init {} {
  ::fwfwk::printCBM "In ./hw/src/main.tcl init()..."



}

# ==============================================================================
proc setSources {} {
  ::fwfwk::printCBM "In ./hw/src/main.tcl setSources()..."

  variable Sources 
  lappend Sources {"../hdl/top_tb.sv" "SystemVerilog"} 
  
  lappend Sources {"../hdl/top.vhd" "VHDL 2008"} 
  lappend Sources {"../hdl/psc_pkg.vhd" "VHDL 2008"}

  lappend Sources {"../hdl/ps_io.vhd" "VHDL 2008"} 
  
  lappend Sources {"../hdl/fofb_top_tb.vhd" "VHDL 2008"}
  lappend Sources {"../hdl/fofb_top.vhd" "VHDL 2008"} 
  lappend Sources {"../hdl/fofb_phy.vhd" "VHDL 2008"} 
  lappend Sources {"../hdl/fofb_flt2fix.vhd" "VHDL 2008"}   
  lappend Sources {"../hdl/fofb_udp_rx.vhd" "VHDL 2008"} 

  lappend Sources {"../hdl/dcct_adc_module.vhd" "VHDL 2008"} 
  lappend Sources {"../hdl/adc_ltc2376.vhd"  "VHDL 2008"}
  lappend Sources {"../hdl/dcct_gainoffset.vhd" "VHDL 2008"}   
   
  lappend Sources {"../hdl/adc_8ch_module.vhd" "VHDL 2008"} 
  lappend Sources {"../hdl/adc_ads8568_intf.vhd" "VHDL 2008"} 
  lappend Sources {"../hdl/mon_gainoffset.vhd" "VHDL 2008"}  
  
  lappend Sources {"../hdl/dac_ctrlr.vhd" "VHDL 2008"} 
  lappend Sources {"../hdl/dac_chan.vhd" "VHDL 2008"}  
  lappend Sources {"../hdl/dac_ad5781.vhd" "VHDL 2008"}  
  lappend Sources {"../hdl/dac_gainoffset.vhd" "VHDL 2008"}  
  lappend Sources {"../hdl/smooth_ramp.vhd" "VHDL 2008"} 
  lappend Sources {"../hdl/ramptable_ramp.vhd" "VHDL 2008"}   
  lappend Sources {"../hdl/smooth_ramp_tb.vhd" "VHDL 2008"}  
  lappend Sources {"../hdl/cordic_sine_tb.vhd" "VHDL 2008"}
  
  
  lappend Sources {"../hdl/fault_module.vhd" "VHDL 2008"} 
  lappend Sources {"../hdl/fault_block.vhd" "VHDL 2008"}  
 
  
  lappend Sources {"../hdl/digio_logic.vhd" "VHDL 2008"} 
  lappend Sources {"../hdl/pulse_enable.vhd" "VHDL 2008"} 
  lappend Sources {"../hdl/pulse_delay.vhd" "VHDL 2008"} 
     
  lappend Sources {"../hdl/adc_accumulator_top.vhd" "VHDL 2008"}   
  lappend Sources {"../hdl/adc_accumulator.vhd" "VHDL 2008"} 
  lappend Sources {"../hdl/average.vhd" "VHDL 2008"} 
  
  lappend Sources {"../hdl/tenkhz_gen.vhd" "VHDL 2008"}   
  lappend Sources {"../hdl/nco_srocgen.vhd" "VHDL 2008"}  
  lappend Sources {"../hdl/nco_srocgen_tb.vhd" "VHDL 2008"} 
  
  lappend Sources {"../hdl/adc2ddr.vhd" "VHDL 2008"}  
  
  lappend Sources {"../hdl/evr_top.vhd" "VHDL 2008"}  
  lappend Sources {"../hdl/event_rcv_chan.vhd" "VHDL 2008"}   
  lappend Sources {"../hdl/event_rcv_ts.vhd" "VHDL 2008"}   
  
  lappend Sources {"../hdl/stretch.vhd" "VHDL 2008"}  

  lappend Sources {"../cstr/pins.xdc"  "XDC"}
  lappend Sources {"../cstr/gtx.xdc"  "XDC"}
  lappend Sources {"../cstr/debug.xdc"  "XDC"}
  lappend Sources {"../cstr/timing.xdc"  "XDC"}   


  
}

# ==============================================================================
proc setAddressSpace {} {
   ::fwfwk::printCBM "In ./hw/src/main.tcl setAddressSpace()..."
  variable AddressSpace
  
  addAddressSpace AddressSpace "pl_regs"   RDL  {} ../rdl/pl_regs.rdl

}
 

# ==============================================================================
proc doOnCreate {} {
  # variable Vhdl
  variable TclPath

      
  ::fwfwk::printCBM "In ./hw/src/main.tcl doOnCreate()"
  set_property part             xc7z030sbg485-1              [current_project]
  set_property target_language  VHDL                         [current_project]
  set_property default_lib      xil_defaultlib               [current_project]
   
  #set_property used_in_synthesis false [get_files /home/mead/rfbpm/fwk/zubpm/src/hw/hdl/top_tb.sv] 
  #set_property used_in_implementation false [get_files  top_tb.v] 
   
  source ${TclPath}/system.tcl
  source ${TclPath}/dac_dpram.tcl
  source ${TclPath}/evr_gtx.tcl
  source ${TclPath}/cordic_sine.tcl
  source ${TclPath}/gige_pcs_pma_tx.tcl
  source ${TclPath}/gige_pcs_pma_rx.tcl
  source ${TclPath}/shift_ram.tcl
  source ${TclPath}/float_to_fix.tcl
  source ${TclPath}/fp_mult.tcl

  addSources "Sources" 
  
  ::fwfwk::printCBM "TclPath = ${TclPath}"
  ::fwfwk::printCBM "SrcPath = ${::fwfwk::SrcPath}"
  
  set_property used_in_synthesis false [get_files ${::fwfwk::SrcPath}/hw/hdl/top_tb.sv] 
  set_property used_in_simulation true [get_files ${::fwfwk::SrcPath}/hw/hdl/top_tb.sv] 
  
  set_property used_in_synthesis false [get_files ${::fwfwk::SrcPath}/hw/hdl/cordic_sine_tb.vhd] 
  set_property used_in_simulation true [get_files ${::fwfwk::SrcPath}/hw/hdl/cordic_sine_tb.vhd]  
  
  set_property used_in_synthesis false [get_files ${::fwfwk::SrcPath}/hw/hdl/smooth_ramp_tb.vhd] 
  set_property used_in_simulation true [get_files ${::fwfwk::SrcPath}/hw/hdl/smooth_ramp_tb.vhd] 
  
  set_property used_in_synthesis false [get_files ${::fwfwk::SrcPath}/hw/hdl/fofb_top_tb.vhd] 
  set_property used_in_simulation true [get_files ${::fwfwk::SrcPath}/hw/hdl/fofb_top_tb.vhd] 
  
  set_property used_in_synthesis false [get_files ${::fwfwk::SrcPath}/hw/hdl/nco_srocgen_tb.vhd] 
  set_property used_in_simulation true [get_files ${::fwfwk::SrcPath}/hw/hdl/nco_srocgen_tb.vhd]   
  
  #get error message, open manually in tcl window for now.
  #open_wave_config "${::fwfwk::SrcPath}/hw/sim/top_tb_behav.wcfg"
  

  
  
}

# ==============================================================================
proc doOnBuild {} {
  ::fwfwk::printCBM "In ./hw/src/main.tcl doOnBuild()"



}


# ==============================================================================
proc setSim {} {
}
