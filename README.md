
# Power Supply Controller

This is a custom designed hardware platform for the next gen power supply controller.

Uses the DESY FWK FPGA Firmware Framework https://fpgafw.pages.desy.de/docs-pub/fwk/index.html

## About this branch

This branch is to keep track of the activities by LBNL. 

## Requires

* Xilinx 2022.2
* git
* python3

## Building

```sh
. /path/to/Vitis/2022.2/settings64.sh

git clone --recurse-submodules git@github.com:jamead/zpsc-fw.git
make env

make cfg=hw project
make cfg=hw build

make cfg=sw project
make cfg=sw build

```



## Flash memory configuration for TFTP boot 
[Picozed 7030 SOM](https://www.avnet.com/opasdata/d120001/medias/docus/126/$v2/5279-UG-PicoZed-7015-7030-V2_0.pdf) contains 16 MB (256MiB) flash

| Begin | End | Contents | Size |  NOTE |
| :--- | :--- | :--- | :--- | :-- |
| 0x000000 | 0x6FFFFF | BOOT.bin | 7MB | U-boot boot loader |
| 0x700000 | 0xB0FFFF | Free space | ~4MB | Empty Space |
| 0xB10000 | 0xB3FFFF | PSC parameters | 256KB | calibration data |
| 0xB40000 | 0xBFFFFF | Free space | 768 KB | Empty Space |
| 0xC00000 | 0xC1FFFF | QSPI.env | 128KB | boot script |
| 0xC20000 | 0xC3FFFF | QSPI.env | 128KB | copy of QSPI.env |
| 0xC40000 | 0xFFFFFF | Free space | ~2MB | Empty Space |