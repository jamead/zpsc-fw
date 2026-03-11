
// Gather and Send 10Hz data

#include <stdio.h>
#include <math.h>

#include <xsysmon.h>
#include <xparameters.h>

#include <FreeRTOS.h>
#include <lwip/sys.h>
#include <lwip/stats.h>

#include "local.h"
#include "sadata.h"
#include "pl_regs.h"

//static XSysMon xmon;
extern ScaleFactorType scalefactors[4];

extern float CONVDACBITSTOVOLTS;

static
void hton_conv(char *inbuf, int len) {

    int i;
    u8 temp;
    //Swap bytes to reverse the order within the 4-byte segment
    //Start at byte 8 (skip the PSC Header)
    for (i=0;i<len;i=i+4) {
    	temp = inbuf[i];
    	inbuf[i] = inbuf[i + 3];
    	inbuf[i + 3] = temp;
    	temp = inbuf[i + 1];
    	inbuf[i + 1] = inbuf[i + 2];
    	inbuf[i + 2] = temp;
    }

}



float ReadAccumSA(u32 reg_addr, u32 ave_mode) {

	s32 raw;
	float averaged;

    raw = (s32)Xil_In32(reg_addr);
    //xil_printf("Raw: %d  ",raw);
    if (ave_mode == 0)
 	   averaged = (float) raw;
    else if (ave_mode == 1)
 	   averaged = raw / 167.0;
    else if (ave_mode == 2)
 	   averaged = raw / 500.0;
    else
       averaged = NAN;

    //printf("AveMode: %d   Raw: %d    Ave%f  \r\n",(int)ave_mode, (int)raw, averaged);
    return averaged;
}


static
void sadata_push(void *unused)
{
    (void)unused;
    u32 chan, base, ave_mode;
    static char msg[1400];
    struct SAdataMsg sadata;



    while(1) {
        vTaskDelay(pdMS_TO_TICKS(95));

        //blink front panel LED
        Xil_Out32(XPAR_M_AXI_BASEADDR + TENHZ_DATASEND_REG, 1);
        Xil_Out32(XPAR_M_AXI_BASEADDR + TENHZ_DATASEND_REG, 0);

        sadata.resolution =  Xil_In32(XPAR_M_AXI_BASEADDR + RESOLUTION_REG);
        sadata.numchans = Xil_In32(XPAR_M_AXI_BASEADDR + NUMCHANS_REG);
        sadata.polarity = Xil_In32(XPAR_M_AXI_BASEADDR + POLARITY_REG);
        sadata.bandwidth = Xil_In32(XPAR_M_AXI_BASEADDR + BANDWIDTH_REG);
        sadata.ch34_dualmode = Xil_In32(XPAR_M_AXI_BASEADDR + CH34_DUALMODE_REG);

        //xil_printf("Resolution: %d\r\n",sadata.resolution);
        //xil_printf("NumChans  : %d\r\n",sadata.numchans);
        //xil_printf("Polarity  : %d\r\n",sadata.polarity);
        //xil_printf("DualMode : %d\r\n",sadata.ch34_dualmode);

        //read FPGA version (git checksum) from PL register
        sadata.git_shasum = Xil_In32(XPAR_M_AXI_BASEADDR + PRJ_SHASUM);
        //xil_printf("Git : %x\r\n",sadata.git_shasum);

        sadata.evr_ts_s =  Xil_In32(XPAR_M_AXI_BASEADDR + EVR_TS_S_REG);
        sadata.evr_ts_ns = Xil_In32(XPAR_M_AXI_BASEADDR + EVR_TS_NS_REG);

        sadata.fofb_pktsrcvd = Xil_In32(XPAR_M_AXI_BASEADDR + FOFB_PACKETS_RCVD_REG);
        sadata.fofb_command = Xil_In32(XPAR_M_AXI_BASEADDR + FOFB_COMMAND_REG);
        sadata.fofb_nonce = Xil_In32(XPAR_M_AXI_BASEADDR + FOFB_NONCE_REG);

        sadata.tenkhz_freq = 1 / ((float)Xil_In32(XPAR_M_AXI_BASEADDR + TENKHZ_FREQ_REG) * 10e-9);
        sadata.onehz_freq  = 1 / ((float)Xil_In32(XPAR_M_AXI_BASEADDR + ONEHZ_FREQ_REG) * 10e-9);
        //printf("TenKHz Freq: %f\n",sadata.tenkhz_freq);

        for (chan=0; chan<4; chan++) {
           base = XPAR_M_AXI_BASEADDR + (chan + 1) * CHBASEADDR;
           ave_mode = Xil_In32(base + AVEMODE_REG);
           //xil_printf("Chan: %d  Ave Mode: %d\r\n",chan, ave_mode);

           sadata.ps[chan].dcct1 = ReadAccumSA(base+DCCT1_REG, ave_mode) * CONVDACBITSTOVOLTS * scalefactors[chan].dac_dccts;
           sadata.ps[chan].dcct1_offset = (s32)Xil_In32(base + DCCT1_OFFSET_REG) * CONVDACBITSTOVOLTS * scalefactors[chan].dac_dccts;
           sadata.ps[chan].dcct1_gain = (s32)Xil_In32(base + DCCT1_GAIN_REG) / GAIN20BITFRACT;
           sadata.ps[chan].dcct2 = ReadAccumSA(base + DCCT2_REG, ave_mode) * CONVDACBITSTOVOLTS * scalefactors[chan].dac_dccts;
           sadata.ps[chan].dcct2_offset = (s32)Xil_In32(base + DCCT2_OFFSET_REG) * CONVDACBITSTOVOLTS * scalefactors[chan].dac_dccts;
           sadata.ps[chan].dcct2_gain = (s32)Xil_In32(base + DCCT2_GAIN_REG) / GAIN20BITFRACT;
           sadata.ps[chan].dacmon = ReadAccumSA(base + DACMON_REG, ave_mode) * CONV16BITSTOVOLTS * scalefactors[chan].dac_dccts;
           sadata.ps[chan].dacmon_offset = (s32)Xil_In32(base + DACMON_OFFSET_REG) * CONV16BITSTOVOLTS * scalefactors[chan].dac_dccts;
           sadata.ps[chan].dacmon_gain = (s32)Xil_In32(base + DACMON_GAIN_REG) / GAIN20BITFRACT;
           sadata.ps[chan].volt = ReadAccumSA(base + VOLT_REG, ave_mode) * CONV16BITSTOVOLTS * scalefactors[chan].vout;
           sadata.ps[chan].volt_offset = (s32)Xil_In32(base + VOLT_OFFSET_REG) * CONV16BITSTOVOLTS * scalefactors[chan].vout;
           sadata.ps[chan].volt_gain = (s32)Xil_In32(base + VOLT_GAIN_REG) / GAIN20BITFRACT;
           sadata.ps[chan].gnd = ReadAccumSA(base + GND_REG, ave_mode) * CONV16BITSTOVOLTS * scalefactors[chan].ignd;
           sadata.ps[chan].gnd_offset = (s32)Xil_In32(base + GND_OFFSET_REG) * CONV16BITSTOVOLTS * scalefactors[chan].ignd;
           sadata.ps[chan].gnd_gain = (s32)Xil_In32(base + GND_GAIN_REG) / GAIN20BITFRACT;
           sadata.ps[chan].spare = ReadAccumSA(base + SPARE_REG, ave_mode) * CONV16BITSTOVOLTS * scalefactors[chan].spare;
           sadata.ps[chan].spare_offset = (s32)Xil_In32(base + SPARE_OFFSET_REG) * CONV16BITSTOVOLTS * scalefactors[chan].spare;
           sadata.ps[chan].spare_gain = (s32)Xil_In32(base + SPARE_GAIN_REG) / GAIN20BITFRACT;
           sadata.ps[chan].reg = ReadAccumSA(base + REG_REG, ave_mode) * CONV16BITSTOVOLTS * scalefactors[chan].regulator;
           sadata.ps[chan].reg_offset = (s32)Xil_In32(base + REG_OFFSET_REG) * CONV16BITSTOVOLTS * scalefactors[chan].regulator;
           sadata.ps[chan].reg_gain = (s32)Xil_In32(base + REG_GAIN_REG) / GAIN20BITFRACT;

           sadata.ps[chan].error = ReadAccumSA(base + ERR_REG, ave_mode) * CONV16BITSTOVOLTS * scalefactors[chan].error;
           sadata.ps[chan].error_offset = (s32)Xil_In32(base + ERR_OFFSET_REG) * CONV16BITSTOVOLTS * scalefactors[chan].error;
           sadata.ps[chan].error_gain = (s32)Xil_In32(base + ERR_GAIN_REG) / GAIN20BITFRACT;

           //DAC
           sadata.ps[chan].dac_setpt = (s32)Xil_In32(base + DAC_CURRSETPT_REG) * CONVDACBITSTOVOLTS * scalefactors[chan].dac_dccts;
           sadata.ps[chan].dac_setpt_raw = (s32)Xil_In32(base + DAC_CURRSETPT_REG);

           sadata.ps[chan].dac_setpt_offset = (s32)Xil_In32(base + DAC_SETPT_OFFSET_REG) * CONVDACBITSTOVOLTS * scalefactors[chan].dac_dccts;
           sadata.ps[chan].dac_setpt_gain = (s32)Xil_In32(base + DAC_SETPT_GAIN_REG) / GAIN20BITFRACT;
           sadata.ps[chan].dac_rampactive = Xil_In32(base + DAC_RAMPACTIVE_REG);


           //Faults
           sadata.ps[chan].ovc1_thresh = (s32)Xil_In32(base + OVC1_THRESH_REG) * CONVDACBITSTOVOLTS * fabs(scalefactors[chan].dac_dccts);
           sadata.ps[chan].ovc2_thresh = (s32)Xil_In32(base + OVC2_THRESH_REG) * CONVDACBITSTOVOLTS * fabs(scalefactors[chan].dac_dccts);
           sadata.ps[chan].ovv_thresh = Xil_In32(base + OVV_THRESH_REG) * CONV16BITSTOVOLTS * fabs(scalefactors[chan].vout);
           sadata.ps[chan].err1_thresh = Xil_In32(base + ERR1_THRESH_REG) * CONV16BITSTOVOLTS * fabs(scalefactors[chan].error);
           sadata.ps[chan].err2_thresh = Xil_In32(base + ERR2_THRESH_REG) * CONV16BITSTOVOLTS * fabs(scalefactors[chan].error);
           sadata.ps[chan].ignd_thresh = Xil_In32(base + IGND_THRESH_REG) * CONV16BITSTOVOLTS * fabs(scalefactors[chan].ignd);

           sadata.ps[chan].ovc1_cntlim = Xil_In32(base + OVC1_CNTLIM_REG) / SAMPLERATE;
           sadata.ps[chan].ovc2_cntlim = Xil_In32(base + OVC2_CNTLIM_REG) / SAMPLERATE;
           sadata.ps[chan].ovv_cntlim = Xil_In32(base + OVV_CNTLIM_REG) / SAMPLERATE;
           sadata.ps[chan].err1_cntlim = Xil_In32(base + ERR1_CNTLIM_REG) / SAMPLERATE;
           sadata.ps[chan].err2_cntlim = Xil_In32(base + ERR2_CNTLIM_REG) / SAMPLERATE;
           sadata.ps[chan].ignd_cntlim = Xil_In32(base + IGND_CNTLIM_REG) / SAMPLERATE;
           sadata.ps[chan].dcct_cntlim = Xil_In32(base + DCCT_CNTLIM_REG) / SAMPLERATE;
           sadata.ps[chan].flt1_cntlim = Xil_In32(base + FLT1_CNTLIM_REG) / SAMPLERATE;
           sadata.ps[chan].flt2_cntlim = Xil_In32(base + FLT2_CNTLIM_REG) / SAMPLERATE;
           sadata.ps[chan].flt3_cntlim = Xil_In32(base + FLT3_CNTLIM_REG) / SAMPLERATE;
           sadata.ps[chan].on_cntlim = Xil_In32(base + ON_CNTLIM_REG) / SAMPLERATE;
           sadata.ps[chan].heartbeat_cntlim = Xil_In32(base + HEARTBEAT_CNTLIM_REG) / SAMPLERATE;

           sadata.ps[chan].fault_clear = Xil_In32(base + FAULT_CLEAR_REG);
           sadata.ps[chan].fault_mask = Xil_In32(base + FAULT_MASK_REG);
           sadata.ps[chan].digout_on1 = Xil_In32(base + DIGOUT_ON1_REG);
           sadata.ps[chan].digout_on2 = Xil_In32(base + DIGOUT_ON1_REG);
           sadata.ps[chan].digout_reset = Xil_In32(base + DIGOUT_ON1_REG);
           sadata.ps[chan].digout_spare = Xil_In32(base + DIGOUT_RESET_REG);
           sadata.ps[chan].digout_park = Xil_In32(base + DIGOUT_PARK_REG);
           sadata.ps[chan].digin = Xil_In32(base + DIGIN_REG);

           sadata.ps[chan].faults_live = Xil_In32(base + FAULTS_LIVE_REG);
           sadata.ps[chan].faults_latched = Xil_In32(base + FAULTS_LAT_REG);

           sadata.ps[chan].sf_ampspersec = scalefactors[chan].ampspersec;
           sadata.ps[chan].sf_dac_dccts = scalefactors[chan].dac_dccts;
           sadata.ps[chan].sf_vout = scalefactors[chan].vout;
           sadata.ps[chan].sf_ignd = scalefactors[chan].ignd;
           sadata.ps[chan].sf_spare = scalefactors[chan].spare;
           sadata.ps[chan].sf_regulator = scalefactors[chan].regulator;
           sadata.ps[chan].sf_error = scalefactors[chan].error;

           sadata.ps[chan].fofb_dacsetpt = ((MsgUnion){ .u = Xil_In32(base + FOFB_DACSETPT_REG) }).f;
        }


        //copy the structure to the PSC msg buffer
        memcpy(&msg,&sadata,sizeof(sadata));

        hton_conv(msg,sizeof(sadata));
        psc_send(the_server, 31, sizeof(msg), &msg);
    }
}

void sadata_setup(void)
{
    printf("INFO: Starting 10Hz data daemon\n");

    sys_thread_new("sadata", sadata_push, NULL, THREAD_STACKSIZE, DEFAULT_THREAD_PRIO);
}
