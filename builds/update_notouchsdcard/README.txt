
# Program the updated firmware via JTAG with SmartLynq Programmer
xsct load_zynq.tcl <smartlynq ip address>  psc.bit psc.elf


# From Box64, use tftp to update the BOOT.bin file on the SDCARD
curl --tftp-no-options -T BOOT.bin tftp://10.0.142.115/BOOT.bin

Then power-cycle

