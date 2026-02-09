
#include <stdio.h>
#include <string.h>
#include <sleep.h>
#include "xil_cache.h"
#include "math.h"


#include "lwip/sockets.h"
//#include "netif/xadapter.h"
//#include "lwipopts.h"
#include "xil_printf.h"
#include "FreeRTOS.h"
#include "task.h"

/* Hardware support includes */
#include "control.h"
#include "pl_regs.h"
#include "local.h"
#include "qspi_flash.h"





extern ScaleFactorType scalefactors[4];
extern float CONVVOLTSTODACBITS;
extern float CONVDACBITSTOVOLTS;



void set_fpleds(u32 msgVal)  {
	Xil_Out32(XPAR_M_AXI_BASEADDR + LEDS_REG, msgVal);
}


void soft_trig(u32 msgVal) {
	xil_printf("Soft Trig Value: %d\r\n",msgVal);
	Xil_Out32(XPAR_M_AXI_BASEADDR + SOFTTRIG, msgVal);
	Xil_Out32(XPAR_M_AXI_BASEADDR + SOFTTRIG, 0);

}

void dump_adcs(u32 chan) {

   u32 base, ave_mode;

   base = XPAR_M_AXI_BASEADDR + (chan) * CHBASEADDR;
   ave_mode = Xil_In32(base + AVEMODE_REG);

   printf("DCCT1 (A)     : %f\n", ReadAccumSA(base + DCCT1_REG, ave_mode) * CONVDACBITSTOVOLTS * scalefactors[chan-1].dac_dccts);
   printf("DCCT2 (A)     : %f\n", ReadAccumSA(base + DCCT2_REG, ave_mode) * CONVDACBITSTOVOLTS * scalefactors[chan-1].dac_dccts);
   printf("DAC (A)       : %f\n", ReadAccumSA(base + DACMON_REG, ave_mode) * CONV16BITSTOVOLTS * scalefactors[chan-1].dac_dccts);
   printf("Vout (V)      : %f\n", ReadAccumSA(base + VOLT_REG, ave_mode) * CONV16BITSTOVOLTS * scalefactors[chan-1].vout);
   printf("iGND (mA)     : %f\n", ReadAccumSA(base + GND_REG, ave_mode) * CONV16BITSTOVOLTS * scalefactors[chan-1].ignd);
   printf("Spare (V)     : %f\n", ReadAccumSA(base + SPARE_REG, ave_mode) * CONV16BITSTOVOLTS * scalefactors[chan-1].spare);
   printf("Reg (A)       : %f\n", ReadAccumSA(base + REG_REG, ave_mode) * CONV16BITSTOVOLTS * scalefactors[chan-1].regulator);
   printf("Error (V)     : %f\n", ReadAccumSA(base + ERR_REG, ave_mode) * CONV16BITSTOVOLTS * scalefactors[chan-1].error);
   printf("DAC Setpt Raw : %d\n", (int)Xil_In32(base + DAC_CURRSETPT_REG));
   printf("DAC Setpt (A) : %f\n", (s32)Xil_In32(base + DAC_CURRSETPT_REG) * CONVDACBITSTOVOLTS * scalefactors[chan-1].dac_dccts);


}


void load_ramptable(u32 chan, void *msg, u32 msglen) {

	int i;
	MsgUnion data;

	u32 *msgptr = (u32 *)msg;

	xil_printf("Writing Ramp Table... MsgLen=%d\r\n",msglen);
	for (i=0;i<msglen/4;i++) {
		data.u = htonl(msgptr[i]);
		printf("%d: %f\r\n",i,data.f);
	}

}




// Writes Ramptable to Fabric, using DPRAM for storage
void write_ramptable(u32 chan, void *msg, u32 msglen)
{


  MsgUnion data;
  int i;
  u32 dpram_addr, dpram_data, ramp_len;
  u32 *msgptr = (u32 *)msg;
  s32 scaled_val;
  u32 psc_resolution;

  ramp_len = msglen / 4;
  xil_printf("Writing %d point Ramptable for Channel %d...\r\n",ramp_len, chan);

	for (i=0;i<20&&i<ramp_len;i++) {
		data.u = htonl(msgptr[i]);
		printf("%d: %f\r\n",i,data.f);
	}

  if (ramp_len > 50000) {
	  xil_printf("Max Ramp Table is 50,000 pts\r\n");
	  return;
  }


  dpram_addr = DAC_RAMPADDR_REG + chan*CHBASEADDR;
  dpram_data = DAC_RAMPDATA_REG + chan*CHBASEADDR;
  Xil_Out32(XPAR_M_AXI_BASEADDR + DAC_RAMPLEN_REG + chan*CHBASEADDR, ramp_len);

  //Read FPGA register for saturation checking 0=MS, 1=HS
  psc_resolution = Xil_In32(XPAR_M_AXI_BASEADDR + RESOLUTION_REG);

  printf("ScaleFactor = %f\n",scalefactors[chan-1].dac_dccts);
  printf("CONVVOLTSTODACBITS = %f\n",CONVVOLTSTODACBITS);

  for (i=0;i<ramp_len;i++) {
	data.u = htonl(msgptr[i]);
	scaled_val = data.f*CONVVOLTSTODACBITS / scalefactors[chan-1].dac_dccts;
	if ((psc_resolution == 1) && (abs(scaled_val) > (1 << 20))) {
	    scaled_val = (scaled_val > 0) ? ((1 << 20) - 1) : -(1 << 20);
	} else if ((psc_resolution == 0) && (abs(scaled_val) > (1 << 18))) {
	    scaled_val = (scaled_val > 0) ? ((1 << 18) - 1) : -(1 << 18);
	}

	if (i<20)
       printf("%d: %f  %d\r\n",i,data.f, (int)scaled_val);
	Xil_Out32(XPAR_M_AXI_BASEADDR + dpram_addr, i);
    Xil_Out32(XPAR_M_AXI_BASEADDR + dpram_data, scaled_val);
  }

	//update dac setpt with last value from ramp, so whenever we switch
	// back to FOFB or JumpMode there is no change
	//Xil_Out32(XPAR_M_AXI_BASEADDR + DAC_RAMPLEN + chan*CHBASEADDR, (s32)val);

}




void set_eventno(u32 msgVal) {
	//Xil_Out32(XPAR_M_AXI_BASEADDR + EVR_TRIGNUM_REG, msgVal);
}

void Calc_WriteSmooth(u32 chan, s32 new_setpt) {


	s32 cur_setpt;
	u32 smooth_len, num_samples;
	float phase_inc;
	float ramp_rate, ramp_duration;

	//Cordic Starts at -PI and goes to 0
	//cordic phase is 1.2.31 format  3.14/4 * 2^31
	const u32 CORDIC_INIT_PHASE = 421657300U;


    cur_setpt = Xil_In32(XPAR_M_AXI_BASEADDR + DAC_CURRSETPT_REG + chan*CHBASEADDR);

	//calculate the length of the smooth length using the ramp rate scale factor
	ramp_rate = (scalefactors[chan-1].ampspersec / scalefactors[chan-1].dac_dccts) * CONVVOLTSTODACBITS;  // in bits/sec
	printf("Ramp Rate: %f (Amps/Sec) \r\n",ramp_rate);

	ramp_duration = abs(new_setpt - cur_setpt) / ramp_rate;
	printf("Ramp Duration: %f (sec)\r\n",ramp_duration);
	num_samples = ramp_duration * SAMPLERATE;
	xil_printf("Ramp Duration: %d (samples)\r\n", num_samples);


	smooth_len = (u32)(abs(new_setpt - cur_setpt) / ramp_rate * SAMPLERATE);
	xil_printf("Smooth Length: %d\r\n",smooth_len);

	//calculate phase increment for CORDIC
	//Cordic Starts at -PI (
	//cordic phase is 1.2.31 format  3.14/4 * 2^31 = 421657428
	phase_inc = CORDIC_INIT_PHASE / num_samples;
	printf("CORDIC Phase Inc = %f\r\n",phase_inc);

	//write the phase inc
	Xil_Out32(XPAR_M_AXI_BASEADDR + SMOOTH_PHASEINC_REG + chan*CHBASEADDR, phase_inc);

	//write the new setpoint to kick it off
	Xil_Out32(XPAR_M_AXI_BASEADDR + DAC_SETPT_REG  + chan*CHBASEADDR, new_setpt);


}





//When changing modes between Smooth/Ramp and Jump, need to smoothly
//transition
//In Smooth/Ramp mode the dac_setpt comes from the DPRAM
//In Jump Mode the dac_setpt comes from the register
void Set_dacOpmode(u32 chan, s32 new_opmode) {
	//u32 dac_mode;
	MsgUnion data;

	//dac_mode = Xil_In32(XPAR_M_AXI_BASEADDR + DAC_OPMODE_REG + chan*CHBASEADDR);


	//if changing to jump mode first ramp to 0?
	if (new_opmode == JUMP) {
		xil_printf("Switching to Jump Mode\r\n");
		//Set the DAC to 0
		//Calc_WriteSmooth(chan, 0);
		//Set the Jump set point to 0
		//Xil_Out32(XPAR_M_AXI_BASEADDR + DAC_SETPT_REG  + chan*CHBASEADDR, 0);
		//Now safe to switch to jumpmode
		Xil_Out32(XPAR_M_AXI_BASEADDR + DAC_OPMODE_REG + chan*CHBASEADDR, JUMP);
	}

	//if changing to fofb mode first update the FOFB scalefactor register
	if (new_opmode == FOFB) {
		xil_printf("Switching to FOFB Mode\r\n");
   	    data.f = scalefactors[chan-1].dac_dccts;
   	    //update FOFB scalefactor register, used to convert the FOFB input
   	    //which is in Amps to DAC bits.
   	    data.f = 1 / data.f * CONVVOLTSTODACBITS;
   	    printf("FOFB ScaleFactor = %f\r\n",data.f);
   	    Xil_Out32(XPAR_M_AXI_BASEADDR + FOFB_SCALEFACTOR_REG + chan*CHBASEADDR, data.u);
		//Now safe to switch to FOFB
		Xil_Out32(XPAR_M_AXI_BASEADDR + DAC_OPMODE_REG + chan*CHBASEADDR, FOFB);
	}


	//if changing from jump mode to smooth/ramp mode
	if (((new_opmode == SMOOTH) || (new_opmode == RAMP))) {
		xil_printf("Switching to Smooth/Ramp Mode\r\n");
		// Smooth the DAC to 0
		//Calc_WriteSmooth(chan, 0);
		//Set the Jump set point to 0 too
		//Xil_Out32(XPAR_M_AXI_BASEADDR + DAC_SETPT_REG + chan*CHBASEADDR, 0);
		//Now safe to switch to smooth/ramp
		Xil_Out32(XPAR_M_AXI_BASEADDR + DAC_OPMODE_REG + chan*CHBASEADDR, new_opmode);
	}


}






void Set_dac(u32 chan, float new_setpt_amps) {

	u32 dac_mode;
	s32 new_setpt;

	//first get the DAC opmode
	dac_mode = Xil_In32(XPAR_M_AXI_BASEADDR + DAC_OPMODE_REG + chan*CHBASEADDR);

	//check boundary conditions (firmware only checking if setpt*gain is above limits, need to fix)
	if (new_setpt_amps > (9.9999 * scalefactors[chan-1].dac_dccts)) {
	    xil_printf("Saturated High\r\n");
	    new_setpt_amps = 9.9999 * scalefactors[chan-1].dac_dccts;
	}
	else if (new_setpt_amps < (-10 * scalefactors[chan-1].dac_dccts)) {
	    xil_printf("Saturated Low\r\n");
	    new_setpt_amps = -10 * scalefactors[chan-1].dac_dccts;
	}


	new_setpt = (s32)(new_setpt_amps * CONVVOLTSTODACBITS / scalefactors[chan-1].dac_dccts);
	printf("New DAC Setpt: %f    %d\r\n",new_setpt_amps, (int)new_setpt);


	if (dac_mode == SMOOTH) {
        xil_printf("In Smooth Mode\r\n");
        Calc_WriteSmooth(chan, new_setpt);
	}

	else if (dac_mode == JUMP) {
        xil_printf("In Jump Mode\r\n");
		Xil_Out32(XPAR_M_AXI_BASEADDR + DAC_SETPT_REG + chan*CHBASEADDR, new_setpt);
	}

}




void glob_settings(void *msg) {

	u32 *msgptr = (u32 *)msg;
	u32 addr;
	MsgUnion data;

	addr = htonl(msgptr[0]);
	data.u = htonl(msgptr[1]);
	//xil_printf("Addr: %d    Data: %d\r\n",addr,data.u);


    //xil_printf("In Global Settings...\r\n");
    switch(addr) {
		case SOFT_TRIG_MSG:
			xil_printf("Soft Trigger Message:   Value=%d\r\n",data.u);
			soft_trig(data.u);
            break;

		case TEST_TRIG_MSG:
			xil_printf("Test Trigger Message:   Value=%d\r\n",data.u);
			Xil_Out32(XPAR_M_AXI_BASEADDR + TESTTRIG, data.u);
			Xil_Out32(XPAR_M_AXI_BASEADDR + TESTTRIG, 0);
            break;

        case FP_LED_MSG:
         	xil_printf("Setting FP LED:   Value=%d\r\n",data.u);
         	set_fpleds(data.u);
         	break;

		case EVR_RESET_MSG:
			xil_printf("Resetting EVR:   Value=%d\r\n",data.u);
			if (data.u == 1) Xil_Out32(XPAR_M_AXI_BASEADDR + EVR_RESET_REG, 0xFF);
			else Xil_Out32(XPAR_M_AXI_BASEADDR + EVR_RESET_REG, 0);
            break;

		case EVR_INJ_EVENTNUM_MSG:
			xil_printf("Setting INJ Event Number:   Value=%d\r\n",data.u);
			Xil_Out32(XPAR_M_AXI_BASEADDR + EVR_INJ_EVENTNUM_REG, data.u);
			break;

		case EVR_PM_EVENTNUM_MSG:
			xil_printf("Setting Post Mortem Event Number:   Value=%d\r\n",data.u);
			Xil_Out32(XPAR_M_AXI_BASEADDR + EVR_PM_EVENTNUM_REG, data.u);
            break;

		case EVR_1HZ_EVENTNUM_MSG:
			xil_printf("Setting 1Hz Event Number:   Value=%d\r\n",data.u);
			Xil_Out32(XPAR_M_AXI_BASEADDR + EVR_1HZ_EVENTNUM_REG, data.u);
            break;

		case EVR_10HZ_EVENTNUM_MSG:
			xil_printf("Setting 10Hz Event Number:   Value=%d\r\n",data.u);
			Xil_Out32(XPAR_M_AXI_BASEADDR + EVR_10HZ_EVENTNUM_REG, data.u);
            break;

		case EVR_10KHZ_EVENTNUM_MSG:
			xil_printf("Setting 10KHz Event Number:   Value=%d\r\n",data.u);
			Xil_Out32(XPAR_M_AXI_BASEADDR + EVR_10KHZ_EVENTNUM_REG, data.u);
            break;

		case FOFB_IPADDR_MSG:
			xil_printf("Setting FOFB IP Address:   Value=%d\r\n",data.u);
			Xil_Out32(XPAR_M_AXI_BASEADDR + FOFB_IPADDR_REG, data.u);
            break;



    }

}






void chan_settings(u32 chan, void *msg, u32 msglen) {

    s32 scaled_val;
    u8 qspibuf[FLASH_PAGE_SIZE];

	u32 *msgptr = (u32 *)msg;
	u32 addr;
	MsgUnion data;


	addr = htonl(msgptr[0]);
	data.u = htonl(msgptr[1]);
	xil_printf("MsgLen=%d\r\n",msglen);
	printf("Chan: %d Addr: %d   Data(i): %d   Data(f): %f\r\n",(int)chan,(int)addr,(int)data.u,data.f);




    switch(addr) {

        case DAC_OPMODE_MSG:
	        xil_printf("Setting DAC CH%d Operating Mode:   Value=%d\r\n",chan,data.u);
	        Set_dacOpmode(chan,data.u);
	        break;

        case DAC_SETPT_MSG:
        	scaled_val = data.f*CONVVOLTSTODACBITS / scalefactors[chan-1].dac_dccts;
	        printf("Setting DAC CH%d SetPoint:   Value=%f   Bits=%d\r\n", (int)chan, data.f, (int)scaled_val);
	        Set_dac(chan, data.f);
	        break;

        case DAC_RAMPLEN_MSG:
 	        xil_printf("Setting DAC CH%d RampTable Length:   Value=%d\r\n",chan,data.u);
 	        Xil_Out32(XPAR_M_AXI_BASEADDR + DAC_RAMPLEN_REG + chan*CHBASEADDR, data.u);
 	        break;

        case DAC_RUNRAMP_MSG:
	        xil_printf("Running DAC CH%d Ramptable:   Value=%d\r\n",chan,data.u);
	        Xil_Out32(XPAR_M_AXI_BASEADDR + DAC_RUNRAMP_REG + chan*CHBASEADDR, data.u);
	        break;

        case DAC_SETPT_GAIN_MSG:
	        printf("Setting DAC SetPt CH%d Gain:   Value=%f\r\n",(int)chan,data.f);
	        Xil_Out32(XPAR_M_AXI_BASEADDR + DAC_SETPT_GAIN_REG + chan*CHBASEADDR, data.f*GAIN20BITFRACT);
	        break;

        case DAC_SETPT_OFFSET_MSG:
	        printf("Setting DAC SetPt CH%d Offset:   Value=%f\r\n",(int)chan,data.f);
	        scaled_val = data.f * CONVVOLTSTODACBITS / scalefactors[chan-1].dac_dccts;
	        Xil_Out32(XPAR_M_AXI_BASEADDR + DAC_SETPT_OFFSET_REG + chan*CHBASEADDR, scaled_val);
	        break;

        case DCCT1_GAIN_MSG:
 	        printf("Setting DAC CH%d Gain:   Value=%f\r\n",(int)chan,data.f);
 	        Xil_Out32(XPAR_M_AXI_BASEADDR + DCCT1_GAIN_REG + chan*CHBASEADDR, data.f*GAIN20BITFRACT);
 	        break;

        case DCCT1_OFFSET_MSG:
 	        printf("Setting DCCT1 CH%d Offset:   Value=%f\r\n",(int)chan,data.f);
 	        scaled_val = data.f*CONVVOLTSTODACBITS / scalefactors[chan-1].dac_dccts;
 	        xil_printf("ScaledVal: %d\r\n",scaled_val);
 	        Xil_Out32(XPAR_M_AXI_BASEADDR + DCCT1_OFFSET_REG + chan*CHBASEADDR, scaled_val);
 	        break;

        case DCCT2_GAIN_MSG:
  	        printf("Setting DCCT1 CH%d Gain:   Value=%f\r\n",(int)chan,data.f);
  	        Xil_Out32(XPAR_M_AXI_BASEADDR + DCCT2_GAIN_REG + chan*CHBASEADDR, data.f*GAIN20BITFRACT);
  	        break;

        case DCCT2_OFFSET_MSG:
  	        printf("Setting DCCT2 CH%d Offset:   Value=%f\r\n",(int)chan,data.f);
  	        scaled_val = data.f*CONVVOLTSTODACBITS / scalefactors[chan-1].dac_dccts;
  	        Xil_Out32(XPAR_M_AXI_BASEADDR + DCCT2_OFFSET_REG + chan*CHBASEADDR, scaled_val);
  	        break;

        case DACMON_GAIN_MSG:
  	        printf("Setting DAC Mon CH%d Gain:   Value=%f\r\n",(int)chan,data.f);
  	        Xil_Out32(XPAR_M_AXI_BASEADDR + DACMON_GAIN_REG + chan*CHBASEADDR, data.f*GAIN20BITFRACT);
  	        break;

        case DACMON_OFFSET_MSG:
  	        printf("Setting DAC Mon CH%d Offset:   Value=%f\r\n",(int)chan,data.f);
  	        scaled_val = data.f*CONVVOLTSTO16BITS / scalefactors[chan-1].dac_dccts;
  	        Xil_Out32(XPAR_M_AXI_BASEADDR + DACMON_OFFSET_REG + chan*CHBASEADDR, scaled_val);
  	        break;

        case VOLT_GAIN_MSG:
  	        printf("Setting Voltage CH%d Gain:   Value=%f\r\n",(int)chan,data.f);
  	        Xil_Out32(XPAR_M_AXI_BASEADDR + VOLT_GAIN_REG + chan*CHBASEADDR, data.f*GAIN20BITFRACT);
  	        break;

        case VOLT_OFFSET_MSG:
  	        printf("Setting Voltage CH%d Offset:   Value=%f\r\n",(int)chan,data.f);
  	        scaled_val = data.f*CONVVOLTSTO16BITS / scalefactors[chan-1].vout;
  	        Xil_Out32(XPAR_M_AXI_BASEADDR + VOLT_OFFSET_REG + chan*CHBASEADDR, scaled_val);
  	        break;

        case GND_GAIN_MSG:
  	        printf("Setting iGND CH%d Gain:   Value=%f\r\n",(int)chan,data.f);
  	        Xil_Out32(XPAR_M_AXI_BASEADDR + GND_GAIN_REG + chan*CHBASEADDR, data.f*GAIN20BITFRACT);
  	        break;

        case GND_OFFSET_MSG:
  	        printf("Setting iGND CH%d Offset:   Value=%f\r\n",(int)chan,data.f);
  	        scaled_val = data.f*CONVVOLTSTO16BITS / scalefactors[chan-1].ignd;
  	        Xil_Out32(XPAR_M_AXI_BASEADDR + GND_OFFSET_REG + chan*CHBASEADDR, scaled_val);
  	        break;

        case SPARE_GAIN_MSG:
   	        printf("Setting Spare CH%d Gain:   Value=%f\r\n",(int)chan,data.f);
   	        Xil_Out32(XPAR_M_AXI_BASEADDR + SPARE_GAIN_REG + chan*CHBASEADDR, data.f*GAIN20BITFRACT);
   	        break;

        case SPARE_OFFSET_MSG:
   	        printf("Setting Spare CH%d Offset:   Value=%f\r\n",(int)chan,data.f);
  	        scaled_val = data.f*CONVVOLTSTO16BITS / scalefactors[chan-1].spare;
   	        Xil_Out32(XPAR_M_AXI_BASEADDR + SPARE_OFFSET_REG + chan*CHBASEADDR, scaled_val);
   	        break;

        case REG_GAIN_MSG:
   	        printf("Setting Regulator CH%d Gain:   Value=%f\r\n",(int)chan,data.f);
   	        Xil_Out32(XPAR_M_AXI_BASEADDR + REG_GAIN_REG + chan*CHBASEADDR, data.f*GAIN20BITFRACT);
   	        break;

        case REG_OFFSET_MSG:
   	        printf("Setting Regulator CH%d Offset:   Value=%f\r\n",(int)chan,data.f);
  	        scaled_val = data.f*CONVVOLTSTO16BITS / scalefactors[chan-1].regulator;
   	        Xil_Out32(XPAR_M_AXI_BASEADDR + REG_OFFSET_REG + chan*CHBASEADDR, scaled_val);
   	        break;

        case ERR_GAIN_MSG:
   	        printf("Setting Error CH%d Gain:   Value=%f\r\n",(int)chan,data.f);
   	        Xil_Out32(XPAR_M_AXI_BASEADDR + ERR_GAIN_REG + chan*CHBASEADDR, data.f*GAIN20BITFRACT);
   	        break;

        case ERR_OFFSET_MSG:
   	        printf("Setting Error CH%d Offset:   Value=%f\r\n",(int)chan,data.f);
  	        scaled_val = data.f*CONVVOLTSTO16BITS / scalefactors[chan-1].error;
   	        Xil_Out32(XPAR_M_AXI_BASEADDR + ERR_OFFSET_REG + chan*CHBASEADDR, scaled_val);
   	        break;


        case OVC1_THRESH_MSG:
   	        printf("Setting OVC1 Threshold CH%d :   Value=%f\r\n",(int)chan,data.f);
   	        scaled_val = fabs(data.f*CONVVOLTSTODACBITS) / fabs(scalefactors[chan-1].dac_dccts);
   	        xil_printf("ScaledVal: %d\r\n", scaled_val);
   	        Xil_Out32(XPAR_M_AXI_BASEADDR + OVC1_THRESH_REG + chan*CHBASEADDR, scaled_val);
   	        break;

        case OVC2_THRESH_MSG:
   	        printf("Setting OVC2 Threshold CH%d :   Value=%f\r\n",(int)chan,data.f);
   	        scaled_val = fabs(data.f*CONVVOLTSTODACBITS) / fabs(scalefactors[chan-1].dac_dccts);
   	        Xil_Out32(XPAR_M_AXI_BASEADDR + OVC2_THRESH_REG + chan*CHBASEADDR, scaled_val);
   	        break;

        case OVV_THRESH_MSG:
   	        printf("Setting OVV Threshold CH%d :   Value=%f\r\n",(int)chan,data.f);
   	        scaled_val = fabs(data.f*CONVVOLTSTO16BITS) / fabs(scalefactors[chan-1].vout);
   	        xil_printf("OVV=%d\r\n",scaled_val);
   	        if (scaled_val >= 32767) scaled_val = 32767;
   	        Xil_Out32(XPAR_M_AXI_BASEADDR + OVV_THRESH_REG + chan*CHBASEADDR, scaled_val);
   	        break;

        case ERR1_THRESH_MSG:
   	        printf("Setting Err1 Threshold CH%d :   Value=%f\r\n",(int)chan,data.f);
   	        scaled_val = fabs(data.f*CONVVOLTSTO16BITS) / fabs(scalefactors[chan-1].error);
   	        if (scaled_val >= 32767) scaled_val = 32767;
   	        Xil_Out32(XPAR_M_AXI_BASEADDR + ERR1_THRESH_REG + chan*CHBASEADDR, scaled_val);
   	        break;

        case ERR2_THRESH_MSG:
   	        printf("Setting Err2 Threshold CH%d :   Value=%f\r\n",(int)chan,data.f);
   	        scaled_val = fabs(data.f*CONVVOLTSTO16BITS) / fabs(scalefactors[chan-1].error);
   	        if (scaled_val >= 32767) scaled_val = 32767;
   	        Xil_Out32(XPAR_M_AXI_BASEADDR + ERR2_THRESH_REG + chan*CHBASEADDR, scaled_val);
   	        break;

        case IGND_THRESH_MSG:
   	        printf("Setting Ignd Threshold CH%d :   Value=%f\r\n",(int)chan,data.f);
   	        scaled_val = fabs(data.f*CONVVOLTSTO16BITS) / fabs(scalefactors[chan-1].error);
   	        if (scaled_val >= 32767) scaled_val = 32767;
   	        Xil_Out32(XPAR_M_AXI_BASEADDR + IGND_THRESH_REG + chan*CHBASEADDR, scaled_val);
   	        break;

        case OVC1_CNTLIM_MSG:
   	        printf("Setting OVC1 Count Limit CH%d :   Value=%f sec\r\n",(int)chan,data.f);
   	        scaled_val = (s32)(data.f * SAMPLERATE);
   	        printf("Scaled Val: %d\r\n",(int)scaled_val);
   	        Xil_Out32(XPAR_M_AXI_BASEADDR + OVC1_CNTLIM_REG + chan*CHBASEADDR, scaled_val);
   	        break;

        case OVC2_CNTLIM_MSG:
   	        printf("Setting OVC2 Count Limit CH%d :   Value=%f sec\r\n",(int)chan,data.f);
   	        scaled_val = (s32)(data.f * SAMPLERATE);
   	        Xil_Out32(XPAR_M_AXI_BASEADDR + OVC2_CNTLIM_REG + chan*CHBASEADDR, scaled_val);
   	        break;

        case OVV_CNTLIM_MSG:
   	        printf("Setting OVV Count Limit CH%d :   Value=%f sec\r\n",(int)chan,data.f);
   	        scaled_val = (s32)(data.f * SAMPLERATE);
   	        Xil_Out32(XPAR_M_AXI_BASEADDR + OVV_CNTLIM_REG + chan*CHBASEADDR, scaled_val);
   	        break;

        case ERR1_CNTLIM_MSG:
   	        printf("Setting Err1 Count Limit CH%d :   Value=%f sec\r\n",(int)chan,data.f);
   	        scaled_val = (s32)(data.f * SAMPLERATE);
   	        Xil_Out32(XPAR_M_AXI_BASEADDR + ERR1_CNTLIM_REG + chan*CHBASEADDR, scaled_val);
   	        break;

        case ERR2_CNTLIM_MSG:
   	        printf("Setting Err2 Count Limit CH%d :   Value=%f sec\r\n",(int)chan,data.f);
   	        scaled_val = (s32)(data.f * SAMPLERATE);
   	        Xil_Out32(XPAR_M_AXI_BASEADDR + ERR2_CNTLIM_REG + chan*CHBASEADDR, scaled_val);
   	        break;

        case IGND_CNTLIM_MSG:
   	        printf("Setting Ignd Count Limit CH%d :   Value=%f sec\r\n",(int)chan,data.f);
   	        scaled_val = (s32)(data.f * SAMPLERATE);
   	        Xil_Out32(XPAR_M_AXI_BASEADDR + IGND_CNTLIM_REG + chan*CHBASEADDR, scaled_val);
   	        break;

        case DCCT_CNTLIM_MSG:
   	        printf("Setting DCCT Count Limit CH%d :   Value=%f sec\r\n",(int)chan,data.f);
   	        scaled_val = (s32)(data.f * SAMPLERATE);
   	        Xil_Out32(XPAR_M_AXI_BASEADDR + DCCT_CNTLIM_REG + chan*CHBASEADDR, scaled_val);
   	        break;

        case FLT1_CNTLIM_MSG:
    	    printf("Setting Fault1 Count Limit CH%d :   Value=%f sec\r\n",(int)chan,data.f);
   	        scaled_val = (s32)(data.f * SAMPLERATE);
    	    Xil_Out32(XPAR_M_AXI_BASEADDR + FLT1_CNTLIM_REG + chan*CHBASEADDR, scaled_val);
    	    break;

        case FLT2_CNTLIM_MSG:
    	    printf("Setting Fault2 Count Limit CH%d :   Value=%f sec\r\n",(int)chan,data.f);
   	        scaled_val = (s32)(data.f * SAMPLERATE);
    	    Xil_Out32(XPAR_M_AXI_BASEADDR + FLT2_CNTLIM_REG + chan*CHBASEADDR, scaled_val);
    	    break;

        case FLT3_CNTLIM_MSG:
    	    printf("Setting Fault3 Count Limit CH%d :   Value=%f sec\r\n",(int)chan,data.f);
   	        scaled_val = (s32)(data.f * SAMPLERATE);
    	    Xil_Out32(XPAR_M_AXI_BASEADDR + FLT3_CNTLIM_REG + chan*CHBASEADDR, scaled_val);
    	    break;

        case ON_CNTLIM_MSG:
    	    printf("Setting On Count Limit CH%d :   Value=%f sec\r\n",(int)chan,data.f);
   	        scaled_val = (s32)(data.f * SAMPLERATE);
    	    Xil_Out32(XPAR_M_AXI_BASEADDR + ON_CNTLIM_REG + chan*CHBASEADDR, scaled_val);
    	    break;

        case HEART_CNTLIM_MSG:
    	    printf("Setting Heart Beat Limit CH%d :   Value=%f sec\r\n",(int)chan,data.f);
   	        scaled_val = (s32)(data.f * SAMPLERATE);
    	    Xil_Out32(XPAR_M_AXI_BASEADDR + HEARTBEAT_CNTLIM_REG + chan*CHBASEADDR, scaled_val);
    	    break;

        case FAULT_CLEAR_MSG:
     	    xil_printf("Setting Fault Clear CH%d :   Value=%d\r\n",chan,data.u);
     	    Xil_Out32(XPAR_M_AXI_BASEADDR + FAULT_CLEAR_REG + chan*CHBASEADDR, data.u);
     	    break;

        case FAULT_MASK_MSG:
      	    xil_printf("Setting Fault Mask CH%d :   Value=%d\r\n",chan,data.u);
      	    Xil_Out32(XPAR_M_AXI_BASEADDR + FAULT_MASK_REG + chan*CHBASEADDR, data.u);
      	    break;

        case DIGOUT_ON1_MSG:
       	    xil_printf("Setting DigOut On1 CH%d :   Value=%d\r\n",chan,data.u);
       	    Xil_Out32(XPAR_M_AXI_BASEADDR + DIGOUT_ON1_REG + chan*CHBASEADDR, data.u);
       	    break;

        case DIGOUT_ON2_MSG:
       	    xil_printf("Setting DigOut On2 CH%d :   Value=%d\r\n",chan,data.u);
       	    Xil_Out32(XPAR_M_AXI_BASEADDR + DIGOUT_ON2_REG + chan*CHBASEADDR, data.u);
       	    break;

        case DIGOUT_RESET_MSG:
       	    xil_printf("Setting DigOut Reset CH%d :   Value=%d\r\n",chan,data.u);
       	    Xil_Out32(XPAR_M_AXI_BASEADDR + DIGOUT_RESET_REG + chan*CHBASEADDR, data.u);
       	    break;

        case DIGOUT_SPARE_MSG:
       	    xil_printf("Setting DigOut Spare CH%d :   Value=%d\r\n",chan,data.u);
       	    Xil_Out32(XPAR_M_AXI_BASEADDR + DIGOUT_SPARE_REG + chan*CHBASEADDR, data.u);
       	    break;

        case DIGOUT_PARK_MSG:
       	    xil_printf("Setting DigOut Park CH%d :   Value=%d\r\n",chan,data.u);
       	    Xil_Out32(XPAR_M_AXI_BASEADDR + DIGOUT_PARK_REG + chan*CHBASEADDR, data.u);
       	    break;

         case SF_AMPS_PER_SEC_MSG:
       	    printf("Setting Amps/Sec CH%d :   Value=%f\r\n",(int)chan,data.f);
       	    scalefactors[chan-1].ampspersec = data.f;
       	    break;

        case SF_DAC_DCCTS_MSG:
       	    printf("Setting ScaleFactor DAC DCCT's Amps/Volt CH%d :   Value=%f\r\n",(int)chan,data.f);
       	    scalefactors[chan-1].dac_dccts = data.f;
       	    //update FOFB scalefactor register
       	    data.f = 1 / data.f * CONVVOLTSTODACBITS;
       	    printf("FOFB ScaleFactor = %f\r\n",data.f);
       	    Xil_Out32(XPAR_M_AXI_BASEADDR + FOFB_SCALEFACTOR_REG + chan*CHBASEADDR, data.u);
       	    break;

        case SF_VOUT_MSG:
       	    printf("Setting ScaleFactor Vout CH%d :   Value=%f\r\n",(int)chan,data.f);
       	    scalefactors[chan-1].vout = data.f;
       	    break;

        case SF_IGND_MSG:
        	printf("Setting ScaleFactor Ignd CH%d :   Value=%f\r\n",(int)chan,data.f);
        	scalefactors[chan-1].ignd = data.f;
        	break;

        case SF_SPARE_MSG:
        	printf("Setting ScaleFactor Spare CH%d :   Value=%f\r\n",(int)chan,data.f);
        	scalefactors[chan-1].spare = data.f;
        	break;

        case SF_REGULATOR_MSG:
        	printf("Setting ScaleFactor Regulator CH%d :   Value=%f\r\n",(int)chan,data.f);
        	scalefactors[chan-1].regulator = data.f;
        	break;

        case SF_ERROR_MSG:
        	printf("Setting ScaleFactor Error CH%d :   Value=%f\r\n",(int)chan,data.f);
        	scalefactors[chan-1].error = data.f;
        	break;

        case FOFB_FASTADDR_MSG:
        	xil_printf("Setting FOFB Fast Address CH%d : Value=%d\r\n",chan,data.u);
        	Xil_Out32(XPAR_M_AXI_BASEADDR + FOFB_FASTADDR_REG + chan*CHBASEADDR, data.u);
        	break;

		case USR_TRIG_MSG:
			xil_printf("User Trigger Message CH%d:   Value=%d\r\n",chan,data.u);
			if (data.u == 1)
			   soft_trig(1 << (chan - 1));
            break;

        case AVE_MODE_MSG:
        	xil_printf("Setting 10Hz Average Mode CH%d : Value=%d\r\n",chan,data.u);
        	Xil_Out32(XPAR_M_AXI_BASEADDR + AVEMODE_REG + chan*CHBASEADDR, data.u);
        	break;

        case WRITE_QSPI_MSG:
        	xil_printf("Write Qspi Message..\r\n");
        	if (data.u == 1) {
        	   xil_printf("Writing current values for CH%dto QSPI FLASH..\r\n",chan);
           	   QspiFlashEraseSect(chan);
        	   QspiGatherData(chan, qspibuf);
        	   QspiFlashWrite(chan*FLASH_SECTOR_SIZE, FLASH_PAGE_SIZE, qspibuf);
        	   //read it back out from qspi, just for kicks
        	   QspiFlashRead(chan*FLASH_SECTOR_SIZE, FLASH_PAGE_SIZE, qspibuf);
               QspiDisperseData(chan,qspibuf);
        	}
        	break;

        case READ_QSPI_MSG:
        	xil_printf("Read Qspi Message..\r\n");
        	if (data.u == 1) {
        	   xil_printf("Reading current values for CH%d from QSPI FLASH..\r\n",chan);
        	   QspiFlashRead(chan*FLASH_SECTOR_SIZE, FLASH_PAGE_SIZE, qspibuf);
               QspiDisperseData(chan,qspibuf);
        	}
        	break;

        case DUMP_ADCS_MSG:
        	dump_adcs(chan);
        	break;





        default:
        	xil_printf("Unsupported Message\r\n");

    }



}


