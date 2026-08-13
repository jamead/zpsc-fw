proc init {} {}

proc setSources {} {
  variable Sources
  ::fwfwk::printInfo "In Set Sources..."
  #::fwfwk::printCBM "TclPath = ${TclPath}"
  #::fwfwk::printCBM "SrcPath = ${::fwfwk::SrcPath}"
  # path relative to tcl file
  #lappend Sources {../inc "includes"}
  lappend Sources {../src "sources"}
  lappend Sources {../lscript.ld "linker-script"}
  ::fwfwk::printInfo "Finished adding sources..."

}

proc customizeFsblBsp {} {
  #variable Config
  #::fwfwk::printInfo "Customizing FSBL BSP"
  
  #domain active {zynqmp_fsbl}
  # add customizations here
  #if {[string equal $Config(ConsoleUart) "USB"]} {
  #  ::fwfwk::printInfo "Setting console port psu_uart_1"
  #  bsp config stdin "psu_uart_1"
  #  bsp config stdout "psu_uart_1"
  #}
  ##end customizations
  #bsp write
  #bsp reload
  #bsp regenerate
}

proc customizeAppBsp {} {
  variable Config
  ::fwfwk::printInfo "Customizing application BSP"

  domain active {app_domain}
  # add customizations here
  app config -name ${::fwfwk::AppName} libraries "m"
  #bsp config total_heap_size "1048576"
  #bsp config minimal_stack_size "1024"
  #bsp config max_task_name_len "32"
  #if {[string equal $Config(ConsoleUart) "USB"]} {
  #  ::fwfwk::printInfo "Setting console port psu_uart_1"
  #  bsp config stdin "psu_uart_1"
  #  bsp config stdout "psu_uart_1"
  #}
  ##end customizations
  #bsp write
  #bsp reload
  #bsp regenerate
}

proc doOnCreate {} {
  #variable Config
  #variable Sources
  addSources Sources
  fwfwk::printInfo "doOnCreate in src/sw_take2/main.tcl - Adding LWIP 211"

  #domain active {app_domain}
  #bsp setlib xilpm 
  bsp config total_heap_size "16777216"
  bsp config minimal_stack_size "1024"
  bsp config max_task_name_len "32"
  bsp config generate_runtime_stats "1"
  
  bsp config check_for_stack_overflow "2"
  bsp config use_malloc_failed_hook "true"
  bsp config use_freertos_asserts "true"
  
  # Give every FreeRTOS task an FPU context
  bsp config use_task_fpu_support "2"
  
  bsp setlib -name xilffs
  bsp config enable_exfat true
  bsp config use_strfunc "1"
  bsp config set_fs_rpath "2"
  # XilFFS overrides


  
  bsp setlib -name lwip211
  bsp config api_mode "SOCKET_API"
  bsp config dhcp_does_arp_check true
  bsp config lwip_dhcp "true"
  bsp config pbuf_pool_size 2048 
  bsp config mem_size 16777216
  bsp config tick_rate 1000
  bsp config lwip_stats true 
  # bsp config lwip_debug true
  # bsp config pbuf_debug true 
  
  # HACK: inject extra lwipopts.h options the xilinx generator doesn't know about...
  # Make available socket send()/recv() timeout sockopts.
  bsp config udp_ttl "255\n#define LWIP_SO_RCVTIMEO 1\n#define LWIP_SO_SNDTIMEO 1"
  
  # HACK: inject extra lwipopts.h options the xilinx generator doesn't know about...
  # Enable socket send()/recv() timeouts.
  # Enable use of the same socket from multiple FreeRTOS tasks:
  #   one task doing recv()
  #   other tasks doing send()
  #bsp config udp_ttl "255\n#define LWIP_SO_RCVTIMEO 1\n#define LWIP_SO_SNDTIMEO 1\n#define LWIP_NETCONN_SEM_PER_THREAD 1\n#define LWIP_NETCONN_FULLDUPLEX 1"
  
  
  bsp write
  bsp reload
  bsp regenerate
  #if {[info exists ::fwfwk::ConsoleUart]} {
  #  fwfwk::printInfo "ConsoleUart = ${::fwfwk::ConsoleUart}"
  #  set Config(ConsoleUart) [string toupper ${::fwfwk::ConsoleUart}]
  #} else {
  #  puts "ConsoleUart not defined, default to RS232"
  #  set Config(ConsoleUart) "RS232"
  #}
  #customizeFsblBsp
  customizeAppBsp
}

proc doOnBuild {} {}
