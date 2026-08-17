#!/bin/bash

#
# load_zynq.sh
#
# Usage:
#   ./load_zynq.sh <SmartLynq_IP> <bitfile> <elffile>
#
# Example:
#   ./load_zynq.sh 10.0.142.50 ./system.bit ./zpsc.elf
#

set -e

if [ "$#" -ne 3 ]; then
    echo "Usage:"
    echo "  $0 <SmartLynq_IP> <bitfile> <elffile>"
    echo
    echo "Example:"
    echo "  $0 10.0.142.50 ./system.bit ./zpsc.elf"
    exit 1
fi

SMARTLYNQ="$1"
BITFILE="$2"
ELFFILE="$3"

#
# Check files
#
if [ ! -f "$BITFILE" ]; then
    echo "ERROR: Bitstream file not found:"
    echo "  $BITFILE"
    exit 1
fi

if [ ! -f "$ELFFILE" ]; then
    echo "ERROR: ELF file not found:"
    echo "  $ELFFILE"
    exit 1
fi

#
# Find directory containing this script.
# load_zynq.tcl is expected to be in the same directory.
#
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TCL_SCRIPT="$SCRIPT_DIR/load_zynq.tcl"

if [ ! -f "$TCL_SCRIPT" ]; then
    echo "ERROR: Cannot find:"
    echo "  $TCL_SCRIPT"
    exit 1
fi

#
# Load Xilinx tools
#
XILINX_SETTINGS="/opt/Xilinx/Vitis/2022.2/settings64.sh"

if [ ! -f "$XILINX_SETTINGS" ]; then
    echo "ERROR: Cannot find Xilinx settings file:"
    echo "  $XILINX_SETTINGS"
    exit 1
fi

source "$XILINX_SETTINGS"

echo
echo "=========================================="
echo " Zynq JTAG FPGA + Software Loader"
echo "=========================================="
echo "SmartLynq : $SMARTLYNQ"
echo "BIT       : $BITFILE"
echo "ELF       : $ELFFILE"
echo "=========================================="
echo

#
# Run XSCT script
#
xsct "$TCL_SCRIPT" "$SMARTLYNQ" "$BITFILE" "$ELFFILE"

STATUS=$?

if [ $STATUS -ne 0 ]; then
    echo
    echo "ERROR: Zynq programming failed."
    exit $STATUS
fi

echo
echo "=========================================="
echo " Programming completed successfully"
echo "=========================================="
