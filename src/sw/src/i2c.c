#include "xparameters.h"
#include "xiicps.h"
#include <sleep.h>
#include "xil_printf.h"
#include <stdio.h>
#include "FreeRTOS.h"
#include "task.h"

#include "pl_regs.h"
#include "local.h"


extern XIicPs IicPsInstance0;			/* Instance of the IIC Device */
extern XIicPs IicPsInstance1;			/* Instance of the IIC Device */

extern float CONVVOLTSTODACBITS;
extern float CONVDACBITSTOVOLTS;

#define IIC0_DEVICE_ID    XPAR_XIICPS_0_DEVICE_ID
#define IIC1_DEVICE_ID    XPAR_XIICPS_1_DEVICE_ID




// Registers to program si570 to 312.3MHz.
static const uint8_t si570_values[][2] = {
	{137, 0x10}, //Freeze DCO
	{7, 0x00},
    {8, 0xC2},
    {9, 0xBB},
    {10, 0xBE},
    {11, 0x6E},
    {12, 0x69},
    {137, 0x0},  //Unfreeze DCO
	{135, 0x40}  //Enable New Frequency
};






void init_i2c() {
    s32 Status;
    XIicPs_Config *ConfigPtr;


    // Look up the configuration in the config table
    ConfigPtr = XIicPs_LookupConfig(0);
    if(ConfigPtr == NULL) {
    	xil_printf("I2C Bus 0 Lookup failed!\r\n");
    	//return XST_FAILURE;
    }

    // Initialize the I2C driver configuration
    Status = XIicPs_CfgInitialize(&IicPsInstance0, ConfigPtr, ConfigPtr->BaseAddress);
    if(Status != XST_SUCCESS) {
    	xil_printf("I2C Bus 0 initialization failed!\r\n");
    	//return XST_FAILURE;
    }


    // Look up the configuration in the config table
    ConfigPtr = XIicPs_LookupConfig(1);
    if(ConfigPtr == NULL) {
    	xil_printf("I2C Bus 1 Lookup failed!\r\n");
    	//return XST_FAILURE;
    }

    Status = XIicPs_CfgInitialize(&IicPsInstance1, ConfigPtr, ConfigPtr->BaseAddress);
     if(Status != XST_SUCCESS) {
     	xil_printf("I2C Bus 1 initialization failed!\r\n");
     	//return XST_FAILURE;
     }

    //set i2c clock rate to 100KHz
    XIicPs_SetSClk(&IicPsInstance0, 100000);
    XIicPs_SetSClk(&IicPsInstance1, 100000);
}



s32 i2c0_write(u8 *buf, u8 len, u8 addr) {

	s32 status;

	while (XIicPs_BusIsBusy(&IicPsInstance0));
	status = XIicPs_MasterSendPolled(&IicPsInstance0, buf, len, addr);
	return status;
}

s32 i2c0_read(u8 *buf, u8 len, u8 addr) {

	s32 status;

    while (XIicPs_BusIsBusy(&IicPsInstance0)) {};
    status = XIicPs_MasterRecvPolled(&IicPsInstance0, buf, len, addr);
    return status;
}


s32 i2c1_write(u8 *buf, u8 len, u8 addr) {

	s32 status;

	while (XIicPs_BusIsBusy(&IicPsInstance1));
	status = XIicPs_MasterSendPolled(&IicPsInstance1, buf, len, addr);
	return status;
}

s32 i2c1_read(u8 *buf, u8 len, u8 addr) {

	s32 status;

    while (XIicPs_BusIsBusy(&IicPsInstance1)) {};
    status = XIicPs_MasterRecvPolled(&IicPsInstance1, buf, len, addr);
    return status;
}




void read_si570() {
   u8 i, buf[2], stat;

   xil_printf("Read si570 registers\r\n");
   for (i=0;i<6;i++) {
       buf[0] = i+7;
       i2c0_write(buf,1,0x55);
       stat = i2c0_read(buf, 1, 0x55);
       xil_printf("Stat: %d:   val0:%x  \r\n",stat, buf[0]);
	}
	xil_printf("\r\n");
}



void prog_si570() {
	u8 buf[2];

	xil_printf("Si570 Registers before re-programming...\r\n");
	read_si570();
	//Program New Registers
	for (size_t i = 0; i < sizeof(si570_values) / sizeof(si570_values[0]); i++) {
	    buf[0] = si570_values[i][0];
	    buf[1] = si570_values[i][1];
	    i2c0_write(buf, 2, 0x55);
	}
	xil_printf("Si570 Registers after re-programming...\r\n");
    read_si570();
}




// 24AA025E48 EEPROM  --------------------------------------
#define IIC_EEPROM_ADDR 0x50
#define IIC_MAC_REG 0xFA


void i2c_get_mac_address(u8 *mac){
	//i2c_set_port_expander(I2C_PORTEXP1_ADDR,0x80);
    u8 buf[6] = {0};
    buf[0] = IIC_MAC_REG;
    i2c1_write(buf,1,IIC_EEPROM_ADDR);
    i2c1_read(mac,6,IIC_EEPROM_ADDR);
    xil_printf("EEPROM MAC ADDR = %2x %2x %2x %2x %2x %2x\r\n",mac[0], mac[1], mac[2], mac[3], mac[4], mac[5]);
    //iic_chp_recv_repeated_start(buf, 1, mac, 6, IIC_EEPROM_ADDR);
}




void i2c_eeprom_writeBytes(u8 startAddr, u8 *data, u8 len){
	//i2c_set_port_expander(I2C_PORTEXP1_ADDR,0x80);
    u8 buf[len + 1];
    buf[0] = startAddr;
    for(int i = 0; i < len; i++) buf[i+1] = data[i];
    i2c1_write(buf, len + 1, IIC_EEPROM_ADDR);
}


void i2c_eeprom_readBytes(u8 startAddr, u8 *data, u8 len){
	u8 buf[] = {startAddr};
	//i2c_set_port_expander(I2C_PORTEXP1_ADDR,0x80);
    i2c1_write(buf,1,IIC_EEPROM_ADDR);
    i2c1_read(data,len,IIC_EEPROM_ADDR);
    //u8 buf[] = {startAddr};
    //iic_chp_recv_repeated_start(buf, 1, data, len, IIC_EEPROM_ADDR);
    //iic_pe_disable(2, 0);
}



void eeprom_dump()
{
  u8 rdBuf[129];
  memset(rdBuf, 0xFF, sizeof(rdBuf));
  rdBuf[128] = 0;
  i2c_eeprom_readBytes(0, rdBuf, 128);

  for (int i = 0; i < 128; i++) {
    if ((i % 16) == 0)
      printf("\r\n0x%02x:  ", i);
    printf("%02x  ", rdBuf[i]);
  }
  printf("\r\n");
}




void ReadHardwareFlavor(void)  {


    u8 rdBuf[8];
    u8 val;

    i2c_eeprom_readBytes(0x10, rdBuf, 8);
    xil_printf("\r\nReading PSC Settings from EEPROM...\r\n");
    // 2 or 4 channel
    val = rdBuf[0];
    if (val == 0) {
 		printf("This is a 2 channel PSC\r\n");
 		Xil_Out32(XPAR_M_AXI_BASEADDR + NUMCHANS_REG, 0);
    }
	else if (val == 1) {
 		printf("This is a 4 channel PSC\r\n");
 		Xil_Out32(XPAR_M_AXI_BASEADDR + NUMCHANS_REG, 1);
	}
	else {
		Xil_Out32(XPAR_M_AXI_BASEADDR + NUMCHANS_REG, 2);
	    xil_printf("Invalid Number of Channel Setting...\r\n");
	}

    // Resolution
	val = rdBuf[1];
    //Write FPGA register 0=MS, 1=HS
	Xil_Out32(XPAR_M_AXI_BASEADDR + RESOLUTION_REG, val);
	if (val == 0) {
		xil_printf("This is an Medium Resolution (18bit) PSC\r\n");
        CONVVOLTSTODACBITS = CONVVOLTSTO18BITS;
        CONVDACBITSTOVOLTS = CONV18BITSTOVOLTS;
	}
    else if (val == 1) {
		xil_printf("This is a High Resolution (20bit) PSC\r\n");
	    CONVVOLTSTODACBITS = CONVVOLTSTO20BITS;
	    CONVDACBITSTOVOLTS = CONV20BITSTOVOLTS;
	}
    else {
		Xil_Out32(XPAR_M_AXI_BASEADDR + RESOLUTION_REG, 2);
    	xil_printf("Invalid Resolution Setting...\r\n");
    }


	// Bandwidth
    val = rdBuf[2];
	if (val == 0) {
 		Xil_Out32(XPAR_M_AXI_BASEADDR + BANDWIDTH_REG, 0);
        xil_printf("This is a High Bandwidth (Fast) PSC\r\n");
	}
	else if (val == 1) {
		xil_printf("This is a Low Bandwidth (Slow) PSC\r\n");
		Xil_Out32(XPAR_M_AXI_BASEADDR + BANDWIDTH_REG, 1);
    }
	else {
		Xil_Out32(XPAR_M_AXI_BASEADDR + BANDWIDTH_REG, 2);
	    xil_printf("Invalid Bandwidth Setting\r\n");
	}


	// Polarity
	// Polarity (4 channels packed into low 4 bits of rdBuf[3])
	val = rdBuf[3] & 0x0F;   // keep only 4 bits

	// Write the 4-bit field to the polarity register (HW decodes per-channel)
	Xil_Out32(XPAR_M_AXI_BASEADDR + POLARITY_REG, val);

	// Print per-channel polarity
	for (int ch = 0; ch < 4; ch++) {
	    u8 p = (val >> ch) & 0x1;

	    if (p == 0) {
	        xil_printf("CH%d: Bipolar\r\n", ch);
	    } else {
	        xil_printf("CH%d: Unipolar\r\n", ch);

	    }
	}
	// Optional: sanity check if upper bits were set (indicates bad EEPROM data)
	if (rdBuf[3] & 0xF0) {
	    xil_printf("Warning: Polarity byte has unexpected upper bits set: 0x%02X\r\n", rdBuf[3]);
	}


	// Ch3 - Ch4 Dual Mode
    val = rdBuf[4];
    xil_printf("Reading Dual Mode...\r\n");
	if (val == 0) {
		// DualMode is enabled
 		Xil_Out32(XPAR_M_AXI_BASEADDR + CH34_DUALMODE_REG, 1);
 		//xil_printf("Dual Mode Reg = %d\r\n", Xil_In32(XPAR_M_AXI_BASEADDR + CH34_DUALMODE_REG));
        xil_printf("Dual Mode is enabled for Ch3-Ch4 (Series Connected supplies)\r\n");
	}

	else {
		Xil_Out32(XPAR_M_AXI_BASEADDR + CH34_DUALMODE_REG, 0);
 		//xil_printf("Dual Mode Reg = %d\r\n", Xil_In32(XPAR_M_AXI_BASEADDR + CH34_DUALMODE_REG));
	    xil_printf("Dual Mode is disabled for Ch3-Ch4\r\n");
	}



    xil_printf("\r\n\r\n");
}














