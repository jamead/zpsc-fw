


/***************************** Include Files *********************************/

#include "xparameters.h"	/* SDK generated parameters */
#include "xqspips.h"		/* QSPI device driver */
#include <stdio.h>
#include "xil_printf.h"
#include "local.h"
#include "pl_regs.h"
#include "qspi_flash.h"
#include <string.h>
#include <ctype.h>


extern XQspiPs QspiInstance;
extern ScaleFactorType scalefactors[4];
extern float CONVDACBITSTOVOLTS;


/*  Each Channel Data is stored in a different sector
 *  Ch1 = Sector1, Ch2 = Sector2 ...
 *  All reads, writes to QSPI are FLASH_PAGE_LENGTH bytes long
 */

void InitSettingsfromQspi(net_config *conf) {

    u32 chan;
    u8 readbuf[FLASH_PAGE_SIZE];

    // global values - hardcode for now
    Xil_Out32(XPAR_M_AXI_BASEADDR + EVR_INJ_EVENTNUM_REG, 10);
    Xil_Out32(XPAR_M_AXI_BASEADDR + EVR_PM_EVENTNUM_REG, 10);

    QspiFlashRead(FLASH_UBOOTENV_OFFSET, FLASH_PAGE_SIZE, readbuf);
    QspiUBootEnvRead(readbuf, FLASH_PAGE_SIZE, conf);

    //channel values, readfromflash and write FPGA registers
    for (chan=1; chan<=4; chan++) {
       //xil_printf("Channel : %d\r\n",chan);
       QspiFlashRead(chan*FLASH_SECTOR_SIZE + FLASH_PSCPARAM_OFFSET, FLASH_PAGE_SIZE, readbuf);
       QspiDisperseData(chan,readbuf);
       //xil_printf("\r\n\r\n");
    }

}



int QspiFlashInit()
{
    XQspiPs_Config *QspiConfig;
    int Status;

    QspiConfig = XQspiPs_LookupConfig(XPAR_XQSPIPS_0_DEVICE_ID);
    if (NULL == QspiConfig) {
        return XST_FAILURE;
    }

    Status = XQspiPs_CfgInitialize(&QspiInstance, QspiConfig, QspiConfig->BaseAddress);
    if (Status != XST_SUCCESS) {
        return XST_FAILURE;
    }

    XQspiPs_SetOptions(&QspiInstance, XQSPIPS_MANUAL_START_OPTION | XQSPIPS_FORCE_SSELECT_OPTION);
    XQspiPs_SetClkPrescaler(&QspiInstance, XQSPIPS_CLK_PRESCALE_8);

    XQspiPs_SetSlaveSelect(&QspiInstance);

    return XST_SUCCESS;
}





void QspiFlashRead(u32 Address, u32 ByteCount, u8 *ReadBuf)
{
    //Address = Address + FLASH_PSCPARAM_OFFSET;

    u8 WriteBuf[4];

    WriteBuf[0] =  FLASH_READ_CMD;
    WriteBuf[1] = (u8)((Address & 0xFF0000) >> 16);
    WriteBuf[2] = (u8)((Address & 0xFF00) >> 8);
    WriteBuf[3] = (u8)(Address & 0xFF);

    //first 4 bytes are garbage, ignore them.
    XQspiPs_PolledTransfer(&QspiInstance, WriteBuf, ReadBuf, ByteCount);

}




void QspiFlashWrite(u32 Address, u32 ByteCount, u8 *WriteBuf)
{
    // First 4 bytes are for the command, overwrites WriteBuf
	
    u8 WriteEnableCmd = { FLASH_WRITE_ENABLE_CMD };
    u8 ReadStatusCmd[] = { FLASH_READ_STATUS_CMD, 0 };  /* Must send 2 bytes */
    u8 FlashStatus[2];

    // Send the write enable command to the Flash so that it can be
    // written to, this needs to be sent as a separate transfer before the write
    //Address = Address + FLASH_PSCPARAM_OFFSET;
    XQspiPs_PolledTransfer(&QspiInstance, &WriteEnableCmd, NULL, sizeof(WriteEnableCmd));

    // Setup the write command with the specified address and data for the Flash
    WriteBuf[0] = FLASH_WRITE_CMD;
    WriteBuf[1] = (u8)((Address & 0xFF0000) >> 16);
    WriteBuf[2] = (u8)((Address & 0xFF00) >> 8);
    WriteBuf[3] = (u8)(Address & 0xFF);

	
    // Send the write command, address, and data to the Flash to be
    // written, no receive buffer is specified since there is nothing to receive
    XQspiPs_PolledTransfer(&QspiInstance, WriteBuf, NULL, ByteCount);



    // Wait for the write command to the Flash to be completed, it takes
    // some time for the data to be written
    while (1) {		
        // Poll the status register of the Flash to determine when it
        // completes, by sending a read status command and receiving the
        // status byte
        XQspiPs_PolledTransfer(&QspiInstance, ReadStatusCmd, FlashStatus,sizeof(ReadStatusCmd));
        if ((FlashStatus[1] & 0x01) == 0) {
            break;
	}
    }

}



void QspiFlashEraseSect(u32 sector)
{
    u8 WriteEnableCmd = { FLASH_WRITE_ENABLE_CMD };
    u8 ReadStatusCmd[] = { FLASH_READ_STATUS_CMD, 0 };  /* Must send 2 bytes */
    u8 FlashStatus[2];
    u8 WriteBuf[4];
    u32 Address;

    //Address = sector * FLASH_SECTOR_SIZE + FLASH_PSCPARAM_OFFSET;
    Address = sector * FLASH_SECTOR_SIZE;
    // Send the write enable command to the EEPROM so that it can be
    // written to, this needs to be sent as a separate transfer
    // before the write
    XQspiPs_PolledTransfer(&QspiInstance, &WriteEnableCmd, NULL, sizeof(WriteEnableCmd));

    // Setup the write command with the specified address and data for the Flash
    WriteBuf[0] = FLASH_SECTOR_ERASE_CMD;
    WriteBuf[1] = (u8)((Address >> 16) & 0xFF);
    WriteBuf[2] = (u8)((Address >> 8) & 0xFF);
    WriteBuf[3] = (u8)(Address & 0xFF);


    // Send the sector erase command and address; no receive buffer
    // is specified since there is nothing to receive
    XQspiPs_PolledTransfer(&QspiInstance, WriteBuf, NULL, FLASH_SECTOR_ERASE_SIZE);


    // Wait for the sector erase command to the Flash to be competed
    while (1) {
        // Poll the status register of the device to determine
        // when it completes, by sending a read status command
        // and receiving the status byte
        XQspiPs_PolledTransfer(&QspiInstance, ReadStatusCmd,FlashStatus,sizeof(ReadStatusCmd));
        if ((FlashStatus[1] & 0x01) == 0)
           break;
    }
}

void QspiGatherData(u32 chan, u8 *writebuf) {

    QspiData_t qspidata;
    u32 base;

    base = XPAR_M_AXI_BASEADDR + (chan) * CHBASEADDR;

    //DAC
    qspidata.dac_setpt_offset = (s32)Xil_In32(base + DAC_SETPT_OFFSET_REG);
    qspidata.dac_setpt_gain = (s32)Xil_In32(base + DAC_SETPT_GAIN_REG);

    // ADC's
    qspidata.dcct1_offset = (s32)Xil_In32(base + DCCT1_OFFSET_REG);
    qspidata.dcct1_gain = (s32)Xil_In32(base + DCCT1_GAIN_REG);
    qspidata.dcct2_offset = (s32)Xil_In32(base + DCCT2_OFFSET_REG);
    qspidata.dcct2_gain = (s32)Xil_In32(base + DCCT2_GAIN_REG);
    qspidata.dacmon_offset = (s32)Xil_In32(base + DACMON_OFFSET_REG);
    qspidata.dacmon_gain = (s32)Xil_In32(base + DACMON_GAIN_REG);
    qspidata.volt_offset = (s32)Xil_In32(base + VOLT_OFFSET_REG);
    qspidata.volt_gain = (s32)Xil_In32(base + VOLT_GAIN_REG);
    qspidata.gnd_offset = (s32)Xil_In32(base + GND_OFFSET_REG);
    qspidata.gnd_gain = (s32)Xil_In32(base + GND_GAIN_REG);
    qspidata.spare_offset = (s32)Xil_In32(base + SPARE_OFFSET_REG);
    qspidata.spare_gain = (s32)Xil_In32(base + SPARE_GAIN_REG);
    qspidata.reg_offset = (s32)Xil_In32(base + REG_OFFSET_REG);
    qspidata.reg_gain = (s32)Xil_In32(base + REG_GAIN_REG);
    qspidata.error_offset = (s32)Xil_In32(base + ERR_OFFSET_REG);
    qspidata.error_gain = (s32)Xil_In32(base + ERR_GAIN_REG);

    //Faults
    qspidata.ovc1_thresh = (s32)Xil_In32(base + OVC1_THRESH_REG);
    qspidata.ovc2_thresh = (s32)Xil_In32(base + OVC2_THRESH_REG);
    qspidata.ovv_thresh = Xil_In32(base + OVV_THRESH_REG);
    qspidata.err1_thresh = Xil_In32(base + ERR1_THRESH_REG);
    qspidata.err2_thresh = Xil_In32(base + ERR2_THRESH_REG);
    qspidata.ignd_thresh = Xil_In32(base + IGND_THRESH_REG);

    //Count Limits
    qspidata.ovc1_cntlim = Xil_In32(base + OVC1_CNTLIM_REG);
    qspidata.ovc2_cntlim = Xil_In32(base + OVC2_CNTLIM_REG);
    qspidata.ovv_cntlim = Xil_In32(base + OVV_CNTLIM_REG);
    qspidata.err1_cntlim = Xil_In32(base + ERR1_CNTLIM_REG);
    qspidata.err2_cntlim = Xil_In32(base + ERR2_CNTLIM_REG);
    qspidata.ignd_cntlim = Xil_In32(base + IGND_CNTLIM_REG);
    qspidata.dcct_cntlim = Xil_In32(base + DCCT_CNTLIM_REG);
    qspidata.flt1_cntlim = Xil_In32(base + FLT1_CNTLIM_REG);
    qspidata.flt2_cntlim = Xil_In32(base + FLT2_CNTLIM_REG);
    qspidata.flt3_cntlim = Xil_In32(base + FLT3_CNTLIM_REG);
    qspidata.on_cntlim = Xil_In32(base + ON_CNTLIM_REG);
    qspidata.heartbeat_cntlim = Xil_In32(base + HEARTBEAT_CNTLIM_REG);

    qspidata.fault_mask = Xil_In32(base + FAULT_MASK_REG);

    //ScaleFactors
    qspidata.sf_ampspersec = scalefactors[chan-1].ampspersec;
    qspidata.sf_dac_dccts = scalefactors[chan-1].dac_dccts;
    qspidata.sf_vout = scalefactors[chan-1].vout;
    qspidata.sf_ignd = scalefactors[chan-1].ignd;
    qspidata.sf_spare = scalefactors[chan-1].spare;
    qspidata.sf_regulator = scalefactors[chan-1].regulator;
    qspidata.sf_error = scalefactors[chan-1].error;

    xil_printf("Current QSPI Data...\r\n");
    QspiPrintData(&qspidata, chan);
    //copy the structure to the PSC msg buffer
    memcpy(writebuf,&qspidata,sizeof(qspidata));

}



void QspiPrintData(QspiData_t *data, u32 chan)
{
    xil_printf("QspiData Contents:\r\n");
    xil_printf("header            = 0x%08X\r\n", data->header);
    printf("dac_setpt_offset  = %f\r\n", data->dac_setpt_offset * CONVDACBITSTOVOLTS * scalefactors[chan-1].dac_dccts);
    printf("dac_setpt_gain    = %f\r\n", data->dac_setpt_gain  / GAIN20BITFRACT);
    printf("dcct1_offset      = %f\r\n", data->dcct1_offset * CONVDACBITSTOVOLTS * scalefactors[chan-1].dac_dccts);
    printf("dcct1_gain        = %f\r\n", data->dcct1_gain  / GAIN20BITFRACT);
    printf("dcct2_offset      = %f\r\n", data->dcct2_offset  * CONVDACBITSTOVOLTS * scalefactors[chan-1].dac_dccts);
    printf("dcct2_gain        = %f\r\n", data->dcct2_gain  / GAIN20BITFRACT);
    printf("dacmon_offset     = %f\r\n", data->dacmon_offset * CONV16BITSTOVOLTS * scalefactors[chan-1].dac_dccts);
    printf("dacmon_gain       = %f\r\n", data->dacmon_gain  / GAIN20BITFRACT);
    printf("volt_offset       = %f\r\n", data->volt_offset * CONV16BITSTOVOLTS * scalefactors[chan-1].vout);
    printf("volt_gain         = %f\r\n", data->volt_gain  / GAIN20BITFRACT);
    printf("gnd_offset        = %f\r\n", data->gnd_offset * CONV16BITSTOVOLTS * scalefactors[chan-1].ignd);
    printf("gnd_gain          = %f\r\n", data->gnd_gain  / GAIN20BITFRACT);
    printf("spare_offset      = %f\r\n", data->spare_offset * CONV16BITSTOVOLTS * scalefactors[chan-1].spare);
    printf("spare_gain        = %f\r\n", data->spare_gain  / GAIN20BITFRACT);
    printf("reg_offset        = %f\r\n", data->reg_offset * CONV16BITSTOVOLTS * scalefactors[chan-1].regulator);
    printf("reg_gain          = %f\r\n", data->reg_gain  / GAIN20BITFRACT);
    printf("error_offset      = %f\r\n", data->error_offset * CONV16BITSTOVOLTS * scalefactors[chan-1].error);
    printf("error_gain        = %f\r\n", data->error_gain / GAIN20BITFRACT);
    printf("ovc1_thresh       = %f\r\n", data->ovc1_thresh * CONVDACBITSTOVOLTS * scalefactors[chan-1].dac_dccts);
    printf("ovc2_thresh       = %f\r\n", data->ovc2_thresh * CONVDACBITSTOVOLTS * scalefactors[chan-1].dac_dccts);
    printf("ovv_thresh        = %f\r\n", data->ovv_thresh * CONV16BITSTOVOLTS * scalefactors[chan-1].vout);
    printf("err1_thresh       = %f\r\n", data->err1_thresh * CONV16BITSTOVOLTS * scalefactors[chan-1].error);
    printf("err2_thresh       = %f\r\n", data->err2_thresh * CONV16BITSTOVOLTS * scalefactors[chan-1].error);
    printf("ignd_thresh       = %f\r\n", data->ignd_thresh * CONV16BITSTOVOLTS * scalefactors[chan-1].ignd);
    printf("ovc1_cntlim       = %f\r\n", data->ovc1_cntlim / SAMPLERATE);
    printf("ovc2_cntlim       = %f\r\n", data->ovc2_cntlim / SAMPLERATE);
    printf("ovv_cntlim        = %f\r\n", data->ovv_cntlim / SAMPLERATE);
    printf("err1_cntlim       = %f\r\n", data->err1_cntlim / SAMPLERATE);
    printf("err2_cntlim       = %f\r\n", data->err2_cntlim / SAMPLERATE);
    printf("ignd_cntlim       = %f\r\n", data->ignd_cntlim / SAMPLERATE);
    printf("dcct_cntlim       = %f\r\n", data->dcct_cntlim / SAMPLERATE);
    printf("flt1_cntlim       = %f\r\n", data->flt1_cntlim / SAMPLERATE);
    printf("flt2_cntlim       = %f\r\n", data->flt2_cntlim / SAMPLERATE);
    printf("flt3_cntlim       = %f\r\n", data->flt3_cntlim / SAMPLERATE);
    printf("on_cntlim         = %f\r\n", data->on_cntlim / SAMPLERATE);
    printf("heartbeat_cntlim  = %f\r\n", data->heartbeat_cntlim / SAMPLERATE);
    xil_printf("fault_mask        = 0x%08X\r\n", data->fault_mask);

    // Now print the floats using printf
    printf("sf_ampspersec     = %.6f\r\n", data->sf_ampspersec);
    printf("sf_dac_dccts      = %.6f\r\n", data->sf_dac_dccts);
    printf("sf_vout           = %.6f\r\n", data->sf_vout);
    printf("sf_ignd           = %.6f\r\n", data->sf_ignd);
    printf("sf_spare          = %.6f\r\n", data->sf_spare);
    printf("sf_regulator      = %.6f\r\n", data->sf_regulator);
    printf("sf_error          = %.6f\r\n", data->sf_error);
}


void QspiUBootEnvRead(u8 *readbuf, size_t data_size, net_config *conf)
{
    const char* ethaddr_value = find_uboot_env_variable(readbuf, data_size, "ethaddr");
    if (ethaddr_value) {
        if (decode_mac_address(conf->hwaddr, ethaddr_value) == 0) {
            xil_printf("Decoded MAC address from U-Boot env: %02X:%02X:%02X:%02X:%02X:%02X\r\n",
                       conf->hwaddr[0], conf->hwaddr[1], conf->hwaddr[2],
                       conf->hwaddr[3], conf->hwaddr[4], conf->hwaddr[5]);
        } else {
            xil_printf("Failed to decode MAC address from U-Boot env\r\n");
        }
    } else {
        xil_printf("ethaddr variable not found in U-Boot env\r\n");
    }
}

int hex_char_to_int(char c) {
    if (c >= '0' && c <= '9') return c - '0';
    if (c >= 'a' && c <= 'f') return c - 'a' + 10;
    if (c >= 'A' && c <= 'F') return c - 'A' + 10;
    return -1; // Invalid hex character
}

int decode_mac_address(unsigned char* dest, const char* src) {
    int byte_index = 0;
    const char* p = src;

    while (byte_index < 6 && *p) {
        // Skip any non-hex characters (like colons, dashes, or spaces)
        while (*p && isspace((unsigned char)*p)) p++;
        
        int high_digit = hex_char_to_int(*p);
        if (high_digit == -1) return -1;
        p++;

        while (*p && isspace((unsigned char)*p)) p++;

        int low_digit = hex_char_to_int(*p);
        if (low_digit == -1) return -1;
        p++;

        dest[byte_index++] = (unsigned char)((high_digit << 4) | low_digit);

        // After a byte is decoded, skip any separator characters
        while (*p && *p == ':') p++;
    }

    // Check if we successfully decoded exactly 6 bytes
    return (byte_index == 6) ? 0 : -1;
}

const char* find_uboot_env_variable(u8* buffer, size_t data_size, const char* var_name) {
    const int DATA_START_OFFSET = 5 + 4; // SPI_OVERHEAD_BYTES + UBOOT_CRC_BYTES
    const char* current_var = (const char*)(buffer+DATA_START_OFFSET);
    size_t search_len = data_size - DATA_START_OFFSET;
    const char* end_of_data = current_var + search_len;

    size_t var_name_len = strlen(var_name);

    while (current_var < end_of_data && *current_var != '\0') {
        //printf("DEBUG: current_var points to string: '%s'\n", current_var);
        if (strncmp(current_var, var_name, var_name_len) == 0 && current_var[var_name_len] == '=') {
            //printf("      -> Found a match for '%s'!\n", var_name);
            return current_var + var_name_len + 1;
        }
        current_var += strlen(current_var) + 1;
    }
    return NULL;
}


void QspiDisperseData(u32 chan, u8 *readbuf)
{

    QspiData_t qspidata;
    u32 base;

    //copy the qspi buffer to the qspi data structure
    memcpy(&qspidata,readbuf,sizeof(qspidata));


    base = XPAR_M_AXI_BASEADDR + (chan) * CHBASEADDR;

    Xil_Out32(base + DAC_SETPT_OFFSET_REG, qspidata.dac_setpt_offset);
    Xil_Out32(base + DAC_SETPT_GAIN_REG, qspidata.dac_setpt_gain);

    Xil_Out32(base + DCCT1_OFFSET_REG, qspidata.dcct1_offset);
    Xil_Out32(base + DCCT1_GAIN_REG, qspidata.dcct1_gain);
    Xil_Out32(base + DCCT2_OFFSET_REG, qspidata.dcct2_offset);
    Xil_Out32(base + DCCT2_GAIN_REG, qspidata.dcct2_gain);
    Xil_Out32(base + DACMON_OFFSET_REG, qspidata.dacmon_offset);
    Xil_Out32(base + DACMON_GAIN_REG, qspidata.dacmon_gain);
    Xil_Out32(base + VOLT_OFFSET_REG, qspidata.volt_offset);
    Xil_Out32(base + VOLT_GAIN_REG, qspidata.volt_gain);
    Xil_Out32(base + GND_OFFSET_REG, qspidata.gnd_offset);
    Xil_Out32(base + GND_GAIN_REG, qspidata.gnd_gain);
    Xil_Out32(base + SPARE_OFFSET_REG, qspidata.spare_offset);
    Xil_Out32(base + SPARE_GAIN_REG, qspidata.spare_gain);
    Xil_Out32(base + REG_OFFSET_REG, qspidata.reg_offset);
    Xil_Out32(base + REG_GAIN_REG, qspidata.reg_gain);
    Xil_Out32(base + ERR_OFFSET_REG, qspidata.error_offset);
    Xil_Out32(base + ERR_GAIN_REG, qspidata.error_gain);

    Xil_Out32(base + OVC1_THRESH_REG, qspidata.ovc1_thresh);
    Xil_Out32(base + OVC2_THRESH_REG, qspidata.ovc2_thresh);
    Xil_Out32(base + OVV_THRESH_REG, qspidata.ovv_thresh);
    Xil_Out32(base + ERR1_THRESH_REG, qspidata.err1_thresh);
    Xil_Out32(base + ERR2_THRESH_REG, qspidata.err2_thresh);
    Xil_Out32(base + IGND_THRESH_REG, qspidata.ignd_thresh);

    Xil_Out32(base + OVC1_CNTLIM_REG, qspidata.ovc1_cntlim);
    Xil_Out32(base + OVC2_CNTLIM_REG, qspidata.ovc2_cntlim);
    Xil_Out32(base + OVV_CNTLIM_REG, qspidata.ovv_cntlim);
    Xil_Out32(base + ERR1_CNTLIM_REG, qspidata.err1_cntlim);
    Xil_Out32(base + ERR2_CNTLIM_REG, qspidata.err2_cntlim);
    Xil_Out32(base + IGND_CNTLIM_REG, qspidata.ignd_cntlim);
    Xil_Out32(base + DCCT_CNTLIM_REG, qspidata.dcct_cntlim);
    Xil_Out32(base + FLT1_CNTLIM_REG, qspidata.flt1_cntlim);
    Xil_Out32(base + FLT2_CNTLIM_REG, qspidata.flt2_cntlim);
    Xil_Out32(base + FLT3_CNTLIM_REG, qspidata.flt3_cntlim);
    Xil_Out32(base + ON_CNTLIM_REG, qspidata.on_cntlim);
    Xil_Out32(base + HEARTBEAT_CNTLIM_REG, qspidata.heartbeat_cntlim);

    Xil_Out32(base + FAULT_MASK_REG, qspidata.fault_mask);

    scalefactors[chan-1].ampspersec = qspidata.sf_ampspersec;
    scalefactors[chan-1].dac_dccts = qspidata.sf_dac_dccts;
    scalefactors[chan-1].vout = qspidata.sf_vout;
    scalefactors[chan-1].ignd = qspidata.sf_ignd;
    scalefactors[chan-1].spare = qspidata.sf_spare;
    scalefactors[chan-1].regulator = qspidata.sf_regulator;
    scalefactors[chan-1].error = qspidata.sf_error;

    //QspiPrintData(&qspidata, chan);


    //Xil_Out32(base + FAULT_CLEAR_REG, 0x1);
    //usleep(1000);
    //Xil_Out32(base + FAULT_CLEAR_REG, 0);


}





