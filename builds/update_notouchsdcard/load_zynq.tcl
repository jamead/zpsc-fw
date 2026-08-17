#
# load_zynq.tcl
#
# Usage:
#   xsct load_zynq.tcl <SmartLynq_IP> <bitfile> <elffile>
#
# Example:
#   xsct load_zynq.tcl 10.0.142.50 ./top.bit ./zpsc.elf
#

if {$argc != 3} {
    puts "Usage:"
    puts "  xsct load_zynq.tcl <SmartLynq_IP> <bitfile> <elffile>"
    exit 1
}

set smartlynq_ip [lindex $argv 0]
set bit_file     [lindex $argv 1]
set elf_file     [lindex $argv 2]

if {![file exists $bit_file]} {
    puts "ERROR: Bitstream does not exist: $bit_file"
    exit 1
}

if {![file exists $elf_file]} {
    puts "ERROR: ELF does not exist: $elf_file"
    exit 1
}

puts ""
puts "=========================================="
puts " Zynq JTAG FPGA + Software Loader"
puts "=========================================="
puts "SmartLynq : $smartlynq_ip"
puts "BIT       : $bit_file"
puts "ELF       : $elf_file"
puts ""

#
# Connect
#
puts "Connecting to SmartLynq..."

connect -url tcp:${smartlynq_ip}:3121

puts ""
puts "Targets:"
targets
puts ""

#
# Select Cortex-A9 #0
#
puts "Selecting Cortex-A9 #0..."

targets -set -nocase -filter {name =~ "*Cortex-A9*#0"}

#
# IMPORTANT:
# Stop the running software BEFORE touching the FPGA.
#
puts "Stopping processor..."
stop

puts "Processor stopped."

#
# Program FPGA.
#
# XSCT will use the FPGA device in the JTAG chain.
#
puts ""
puts "Programming FPGA..."
fpga -file $bit_file

puts "FPGA programmed successfully."

#
# Go back to Cortex-A9 #0
#
puts ""
puts "Selecting Cortex-A9 #0..."

targets -set -nocase -filter {name =~ "*Cortex-A9*#0"}

#
# Reset ONLY the processor.
#
# DO NOT use rst -system.
#
puts "Resetting processor..."
rst -processor

#
# Download new software
#
puts ""
puts "Downloading ELF..."
dow $elf_file

#
# Start new application
#
puts ""
puts "Starting processor..."
con

puts ""
puts "=========================================="
puts " FPGA and application loaded successfully"
puts "=========================================="
puts ""

exit
