#
# load_zynq.tcl
#
# Load a new FPGA bitstream and ARM ELF into an installed Zynq-7000
# through SmartLynq/JTAG.
#
# The board may have originally booted from SD.
#
# Sequence:
#   1. Connect to SmartLynq
#   2. Select Cortex-A9 #0
#   3. Perform a system reset
#   4. Halt the processors
#   5. Program the FPGA
#   6. Run ps7_init
#   7. Run ps7_post_config
#   8. Download the ELF
#   9. Run the application
#
# Usage:
#
#   xsct load_zynq.tcl <SmartLynq_IP> <bitfile> <elffile>
#
# Example:
#
#   xsct load_zynq.tcl 10.0.142.200 psc.bit psc.elf
#

# ------------------------------------------------------------
# Check command-line arguments
# ------------------------------------------------------------

if {$argc != 3} {
    puts ""
    puts "Usage:"
    puts "  xsct load_zynq.tcl <SmartLynq_IP> <bitfile> <elffile>"
    puts ""
    puts "Example:"
    puts "  xsct load_zynq.tcl 10.0.142.200 psc.bit psc.elf"
    puts ""
    exit 1
}

set smartlynq_ip [lindex $argv 0]
set bit_file     [file normalize [lindex $argv 1]]
set elf_file     [file normalize [lindex $argv 2]]

#
# ps7_init.tcl is expected in the current directory.
#
set ps7_init_file [file normalize "./ps7_init.tcl"]


# ------------------------------------------------------------
# Verify files exist
# ------------------------------------------------------------

if {![file exists $bit_file]} {
    puts ""
    puts "ERROR: Bitstream file not found:"
    puts "  $bit_file"
    puts ""
    exit 1
}

if {![file exists $elf_file]} {
    puts ""
    puts "ERROR: ELF file not found:"
    puts "  $elf_file"
    puts ""
    exit 1
}

if {![file exists $ps7_init_file]} {
    puts ""
    puts "ERROR: ps7_init.tcl not found:"
    puts "  $ps7_init_file"
    puts ""
    exit 1
}


# ------------------------------------------------------------
# Timing helpers
# ------------------------------------------------------------

set start_time [clock milliseconds]
set last_time  $start_time

proc mark {msg} {
    global start_time last_time

    set now [clock milliseconds]

    set total [expr {($now - $start_time) / 1000.0}]
    set delta [expr {($now - $last_time)  / 1000.0}]

    puts [format "%-34s +%8.3f sec   total=%8.3f sec" \
        $msg $delta $total]

    set last_time $now
}

proc fatal {msg} {
    puts ""
    puts "=========================================="
    puts " ERROR"
    puts "=========================================="
    puts $msg
    puts ""

    catch {disconnect}

    exit 1
}


# ------------------------------------------------------------
# Header
# ------------------------------------------------------------

puts ""
puts "=========================================="
puts " Zynq JTAG FPGA + Software Loader"
puts "=========================================="
puts "SmartLynq : $smartlynq_ip"
puts "BIT       : $bit_file"
puts "ELF       : $elf_file"
puts "PS7 INIT  : $ps7_init_file"
puts "=========================================="
puts ""


# ------------------------------------------------------------
# Connect to SmartLynq
# ------------------------------------------------------------

mark "Connecting to SmartLynq"

if {[catch {
    connect -url tcp:${smartlynq_ip}:3121
} result]} {
    fatal "Unable to connect to SmartLynq:\n$result"
}

mark "Connected"

after 100


# ------------------------------------------------------------
# Show available targets
# ------------------------------------------------------------

puts ""
puts "Available targets:"

if {[catch {
    targets
} result]} {
    fatal "Unable to read JTAG targets:\n$result"
}

puts ""


# ------------------------------------------------------------
# Select Cortex-A9 #0
# ------------------------------------------------------------

mark "Selecting Cortex-A9 #0"

if {[catch {
    targets -set -nocase -filter {name =~ "*Cortex-A9*#0"}
} result]} {
    fatal "Unable to select Cortex-A9 #0:\n$result"
}

mark "Cortex-A9 #0 selected"


# ------------------------------------------------------------
# SYSTEM RESET
#
# This is intentional.
#
# We want to get away from stopping the currently-running
# FreeRTOS application at an arbitrary point where an AXI
# transaction into the PL may already be outstanding.
# ------------------------------------------------------------

mark "Resetting Zynq system"

if {[catch {
    rst -system
} result]} {
    fatal "System reset failed:\n$result"
}

mark "System reset complete"


# ------------------------------------------------------------
# Immediately halt Cortex-A9 #0 after reset.
#
# Since the board boot mode is still SD, we do not want to let
# the normal SD boot proceed while we are taking control over
# JTAG.
# ------------------------------------------------------------

after 100

mark "Selecting A9 #0 after reset"

if {[catch {
    targets -set -nocase -filter {name =~ "*Cortex-A9*#0"}
} result]} {
    fatal "Unable to select Cortex-A9 #0 after reset:\n$result"
}

mark "Halting A9 #0"

if {[catch {
    stop
} result]} {
    puts "WARNING: Could not stop A9 #0: $result"
}

mark "A9 #0 halted"


# ------------------------------------------------------------
# Halt Cortex-A9 #1 as well, if present.
# ------------------------------------------------------------

mark "Halting A9 #1"

if {[catch {
    targets -set -nocase -filter {name =~ "*Cortex-A9*#1"}
    stop
} result]} {

    #
    # "Already stopped" is harmless.
    #
    puts "A9 #1 status: $result"

} else {

    mark "A9 #1 halted"
}


# ------------------------------------------------------------
# Program FPGA
# ------------------------------------------------------------

mark "Starting FPGA programming"

if {[catch {
    fpga -file $bit_file
} result]} {
    fatal "FPGA programming failed:\n$result"
}

mark "FPGA programming complete"


# ------------------------------------------------------------
# Allow configuration to settle
# ------------------------------------------------------------

after 500

mark "FPGA settle complete"


# ------------------------------------------------------------
# Select A9 #0 again
# ------------------------------------------------------------

mark "Selecting Cortex-A9 #0"

if {[catch {
    targets -set -nocase -filter {name =~ "*Cortex-A9*#0"}
} result]} {
    fatal "Unable to select Cortex-A9 #0:\n$result"
}

mark "Cortex-A9 #0 selected"


# ------------------------------------------------------------
# Load PS initialization script
# ------------------------------------------------------------

mark "Sourcing ps7_init.tcl"

if {[catch {
    source $ps7_init_file
} result]} {
    fatal "Unable to source ps7_init.tcl:\n$result"
}

mark "ps7_init.tcl sourced"


# ------------------------------------------------------------
# Initialize Processing System
#
# This restores the PS configuration expected by the hardware
# design, including DDR, clocks, MIO, etc.
# ------------------------------------------------------------

mark "Starting ps7_init"

if {[catch {
    ps7_init
} result]} {
    fatal "ps7_init failed:\n$result"
}

mark "ps7_init complete"


# ------------------------------------------------------------
# Complete PS <-> PL configuration
# ------------------------------------------------------------

mark "Starting ps7_post_config"

if {[catch {
    ps7_post_config
} result]} {
    fatal "ps7_post_config failed:\n$result"
}

mark "ps7_post_config complete"


# ------------------------------------------------------------
# Give PS/PL interfaces a short settling period
# ------------------------------------------------------------

after 200

mark "PS/PL settle complete"


# ------------------------------------------------------------
# Select Cortex-A9 #0 before download
# ------------------------------------------------------------

mark "Selecting Cortex-A9 #0"

if {[catch {
    targets -set -nocase -filter {name =~ "*Cortex-A9*#0"}
} result]} {
    fatal "Unable to select Cortex-A9 #0 before ELF download:\n$result"
}

mark "Cortex-A9 #0 selected"


# ------------------------------------------------------------
# Download application
# ------------------------------------------------------------

mark "Starting ELF download"

if {[catch {
    dow $elf_file
} result]} {
    fatal "ELF download failed:\n$result"
}

mark "ELF download complete"


# ------------------------------------------------------------
# Start application
# ------------------------------------------------------------

mark "Starting application"

if {[catch {
    con
} result]} {
    fatal "Unable to start application:\n$result"
}

mark "Application running"


# ------------------------------------------------------------
# Done
# ------------------------------------------------------------

puts ""
puts "=========================================="
puts " Programming completed successfully"
puts "=========================================="
puts ""

catch {disconnect}

exit 0
