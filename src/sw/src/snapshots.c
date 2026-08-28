// Handles gathering and sending Snapshot (10KHz) data buffers from triggers

#include <stdio.h>
#include "xil_cache.h"

#include <FreeRTOS.h>
#include <lwip/sys.h>
#include <lwip/stats.h>

#include "local.h"
#include "snapshot.h"
#include "pl_regs.h"


extern ScaleFactorType scalefactors[4];
extern float CONVDACBITSTOVOLTS;



static
void hton_conv(char *inbuf, int len) {

    int i;
    u8 temp;
    //Swap bytes to reverse the order within the 4-byte segment
    for (i=0;i<len;i=i+4) {
    	temp = inbuf[i];
    	inbuf[i] = inbuf[i + 3];
    	inbuf[i + 3] = temp;
    	temp = inbuf[i + 1];
    	inbuf[i + 1] = inbuf[i + 2];
    	inbuf[i + 2] = temp;
    }

}

// This information is send to the IOC at ~10Hz
static
void SendSnapShotStats(psc_key *PSC, char *msg, TriggerTypes *trig) {

   struct SnapStatsMsg snapstats;
   u32 i;

   snapstats.cur_bufaddr = Xil_In32(XPAR_M_AXI_BASEADDR + SNAPSHOT_ADDRPTR);
   snapstats.totalfacnt = Xil_In32(XPAR_M_AXI_BASEADDR + SNAPSHOT_TOTALTRIGS);
   //xil_printf("CurBuf = %x   TotalCnts = %d\r\n",snapstats.cur_bufaddr, snapstats.totalfacnt);

   for (i=0;i<4;i++) {
       snapstats.usr[i].lataddr = Xil_In32(XPAR_M_AXI_BASEADDR + USR1TRIG_BUFPTR + i*0x10);
       snapstats.usr[i].active  = trig->usr[i].active;
       snapstats.usr[i].ts_s    = Xil_In32(XPAR_M_AXI_BASEADDR + USR1TRIG_TS_S + i*0x10);
       snapstats.usr[i].ts_ns   = Xil_In32(XPAR_M_AXI_BASEADDR + USR1TRIG_TS_NS + i*0x10);

       snapstats.flt[i].lataddr = Xil_In32(XPAR_M_AXI_BASEADDR + FLT1TRIG_BUFPTR + i*0x10);
       snapstats.flt[i].active  = trig->flt[i].active;
       snapstats.flt[i].ts_s    = Xil_In32(XPAR_M_AXI_BASEADDR + FLT1TRIG_TS_S + i*0x10);
       snapstats.flt[i].ts_ns   = Xil_In32(XPAR_M_AXI_BASEADDR + FLT1TRIG_TS_NS + i*0x10);

       snapstats.err[i].lataddr = Xil_In32(XPAR_M_AXI_BASEADDR + ERR1TRIG_BUFPTR + i*0x10);
       snapstats.err[i].active  = trig->err[i].active;
       snapstats.err[i].ts_s    = Xil_In32(XPAR_M_AXI_BASEADDR + ERR1TRIG_TS_S + i*0x10);
       snapstats.err[i].ts_ns   = Xil_In32(XPAR_M_AXI_BASEADDR + ERR1TRIG_TS_NS + i*0x10);

       snapstats.inj[i].lataddr = Xil_In32(XPAR_M_AXI_BASEADDR + INJ1TRIG_BUFPTR + i*0x10);
       snapstats.inj[i].active  = trig->inj[i].active;
       snapstats.inj[i].ts_s    = Xil_In32(XPAR_M_AXI_BASEADDR + INJ1TRIG_TS_S + i*0x10);
       snapstats.inj[i].ts_ns   = Xil_In32(XPAR_M_AXI_BASEADDR + INJ1TRIG_TS_NS + i*0x10);

       snapstats.evr[i].lataddr = 0; //Xil_In32(XPAR_M_AXI_BASEADDR + EVRTRIG_BUFPTR);
       snapstats.evr[i].active  = 0; //trig->evr[3].active;
       snapstats.evr[i].ts_s    = 0; //Xil_In32(XPAR_M_AXI_BASEADDR + EVRTRIG_TS_S);
       snapstats.evr[i].ts_ns   = 0; //Xil_In32(XPAR_M_AXI_BASEADDR + EVRTRIG_TS_NS);
   }


   //copy the structure to the PSC msg buffer
   memcpy(msg,&snapstats,sizeof(snapstats));
   hton_conv(msg,sizeof(snapstats));
   psc_send(PSC, MSGWFMSTATS , MSGWFMSTATSLEN, msg);

}





static
void CopyDataChan(float **msg_ptr, u32 *buf_data, u32 numwords, int chan) {

	u32 i;

	//inject some errors at sample 30000 for DCCT1 & DCCT2 for testing
    //buf_data[30000*40+2] = 0;
    //buf_data[30000*40+3] = 0;
    //xil_printf("Start CopyDataChan...\r\n");
	//taskENTER_CRITICAL(); // disables context switches but not interrupts
	//vTaskSuspendAll();
	////portENTER_CRITICAL(); // disables context switches and interrupts

	/*
	int offsets[] = {0, 10, 18, 26};  // Channel-specific offsets
	if (chan < 1 || chan > 4) {
	    xil_printf("Error: Invalid chan value: %d\n", chan);
	    return;
	}

	int base_offset = offsets[chan - 1];

	for (i = 0; i < numwords; i += 40) {
	    **msg_ptr = buf_data[i + 0];   // header
	    (*msg_ptr)++;
	    **msg_ptr = buf_data[i + 1];   // data pt. counter
	    (*msg_ptr)++;

	    **msg_ptr = (float)(s32)(buf_data[i + base_offset + 0]) * CONVDACBITSTOVOLTS * scalefactors[chan - 1].dac_dccts;   // DCCT1
	    (*msg_ptr)++;
	    **msg_ptr = (float)(s32)(buf_data[i + base_offset + 1]) * CONVDACBITSTOVOLTS * scalefactors[chan - 1].dac_dccts;   // DCCT2
	    (*msg_ptr)++;
	    **msg_ptr = (float)(s32)(buf_data[i + base_offset + 2]) * CONV16BITSTOVOLTS * scalefactors[chan - 1].dac_dccts;    // DAC Monitor
	    (*msg_ptr)++;
	    **msg_ptr = (float)(s32)(buf_data[i + base_offset + 3]) * CONV16BITSTOVOLTS * scalefactors[chan - 1].vout;         // Voltage Monitor
	    (*msg_ptr)++;
	    **msg_ptr = (float)(s32)(buf_data[i + base_offset + 4]) * CONV16BITSTOVOLTS * scalefactors[chan - 1].ignd;         // iGND Monitor
	    (*msg_ptr)++;
	    **msg_ptr = (float)(s32)(buf_data[i + base_offset + 5]) * CONV16BITSTOVOLTS * scalefactors[chan - 1].spare;        // Spare Monitor
	    (*msg_ptr)++;
	    **msg_ptr = (float)(s32)(buf_data[i + base_offset + 6]) * CONV16BITSTOVOLTS * scalefactors[chan - 1].regulator;    // Regulator
	    (*msg_ptr)++;
	    **msg_ptr = (float)(s32)(buf_data[i + base_offset + 7]) * CONV16BITSTOVOLTS * scalefactors[chan - 1].error;        // Error
	    (*msg_ptr)++;
	}
	*/


    switch (chan) {
        case 1:  // Copy elements 0-9
            for (i=0; i<numwords; i=i+40) {
                **msg_ptr = buf_data[i+0];   //header
                (*msg_ptr)++;
                **msg_ptr = buf_data[i+1];   //data pt. counter
                (*msg_ptr)++;
                **msg_ptr = (float)(s32)(buf_data[i+2]) * CONVDACBITSTOVOLTS * scalefactors[chan-1].dac_dccts;   //DCCT1
                (*msg_ptr)++;
                **msg_ptr = (float)(s32)(buf_data[i+3]) * CONVDACBITSTOVOLTS * scalefactors[chan-1].dac_dccts;   //DCCT2
                (*msg_ptr)++;
                **msg_ptr = (float)(s32)(buf_data[i+4]) * CONV16BITSTOVOLTS * scalefactors[chan-1].dac_dccts;   //DAC Monitor
                (*msg_ptr)++;
                **msg_ptr = (float)(s32)(buf_data[i+5]) * CONV16BITSTOVOLTS * scalefactors[chan-1].vout;   //Voltage Monitor
                (*msg_ptr)++;
                **msg_ptr = (float)(s32)(buf_data[i+6]) * CONV16BITSTOVOLTS * scalefactors[chan-1].ignd;   //iGND Monitor
                (*msg_ptr)++;
                **msg_ptr = (float)(s32)(buf_data[i+7]) * CONV16BITSTOVOLTS * scalefactors[chan-1].spare;   //Spare Monitor
                (*msg_ptr)++;
                **msg_ptr = (float)(s32)(buf_data[i+8]) * CONV16BITSTOVOLTS * scalefactors[chan-1].regulator;   //Regulator
                (*msg_ptr)++;
                **msg_ptr = (float)(s32)(buf_data[i+9]) * CONV16BITSTOVOLTS * scalefactors[chan-1].error;   //Error
                (*msg_ptr)++;
                // check for any zeros
                //for (j=0; j<39; j++) {
          		//  if (buf_data[i+j] == 0)
          		//	xil_printf("BufData=%d    i=%d, j=%d\r\n",buf_data[i+j], i, j);
                //}

            }
            break;


        case 2: // Copy elements 0, 1, 10-17
            for (i=0; i<numwords; i=i+40) {
                **msg_ptr = buf_data[i+0];   //header
                (*msg_ptr)++;
                **msg_ptr = buf_data[i+1];   //data pt. counter
                (*msg_ptr)++;
                **msg_ptr = (float)(s32)(buf_data[i+10]) * CONVDACBITSTOVOLTS * scalefactors[chan-1].dac_dccts;   //DCCT1
                (*msg_ptr)++;
                **msg_ptr = (float)(s32)(buf_data[i+11]) * CONVDACBITSTOVOLTS * scalefactors[chan-1].dac_dccts;   //DCCT2
                (*msg_ptr)++;
                **msg_ptr = (float)(s32)(buf_data[i+12]) * CONV16BITSTOVOLTS * scalefactors[chan-1].dac_dccts;   //DAC Monitor
                (*msg_ptr)++;
                **msg_ptr = (float)(s32)(buf_data[i+13]) * CONV16BITSTOVOLTS * scalefactors[chan-1].vout;   //Voltage Monitor
                (*msg_ptr)++;
                **msg_ptr = (float)(s32)(buf_data[i+14]) * CONV16BITSTOVOLTS * scalefactors[chan-1].ignd;   //iGND Monitor
                (*msg_ptr)++;
                **msg_ptr = (float)(s32)(buf_data[i+15]) * CONV16BITSTOVOLTS * scalefactors[chan-1].spare;   //Spare Monitor
                (*msg_ptr)++;
                **msg_ptr = (float)(s32)(buf_data[i+16]) * CONV16BITSTOVOLTS * scalefactors[chan-1].regulator;   //Regulator
                (*msg_ptr)++;
                **msg_ptr = (float)(s32)(buf_data[i+17]) * CONV16BITSTOVOLTS * scalefactors[chan-1].error;   //Error
                (*msg_ptr)++;
            }
            break;

        case 3: // Copy elements 0, 1, 18-25
            for (i=0; i<numwords; i=i+40) {
                 **msg_ptr = buf_data[i+0];   //header
                (*msg_ptr)++;
                **msg_ptr = buf_data[i+1];   //data pt. counter
                (*msg_ptr)++;
                **msg_ptr = (float)(s32)(buf_data[i+18]) * CONVDACBITSTOVOLTS * scalefactors[chan-1].dac_dccts;   //DCCT1
                (*msg_ptr)++;
                **msg_ptr = (float)(s32)(buf_data[i+19]) * CONVDACBITSTOVOLTS * scalefactors[chan-1].dac_dccts;   //DCCT2
                (*msg_ptr)++;
                **msg_ptr = (float)(s32)(buf_data[i+20]) * CONV16BITSTOVOLTS * scalefactors[chan-1].dac_dccts;   //DAC Monitor
                (*msg_ptr)++;
                **msg_ptr = (float)(s32)(buf_data[i+21]) * CONV16BITSTOVOLTS * scalefactors[chan-1].vout;   //Voltage Monitor
                (*msg_ptr)++;
                **msg_ptr = (float)(s32)(buf_data[i+22]) * CONV16BITSTOVOLTS * scalefactors[chan-1].ignd;   //iGND Monitor
                (*msg_ptr)++;
                **msg_ptr = (float)(s32)(buf_data[i+23]) * CONV16BITSTOVOLTS * scalefactors[chan-1].spare;   //Spare Monitor
                (*msg_ptr)++;
                **msg_ptr = (float)(s32)(buf_data[i+24]) * CONV16BITSTOVOLTS * scalefactors[chan-1].regulator;   //Regulator
                (*msg_ptr)++;
                **msg_ptr = (float)(s32)(buf_data[i+25]) * CONV16BITSTOVOLTS * scalefactors[chan-1].error;   //Error
                (*msg_ptr)++;
            }
            break;

        case 4: // Copy elements 0, 1, 26-33
            for (i=0; i<numwords; i=i+40) {
                **msg_ptr = buf_data[i+0];   //header
                (*msg_ptr)++;
                **msg_ptr = buf_data[i+1];   //data pt. counter
                (*msg_ptr)++;
                **msg_ptr = (float)(s32)(buf_data[i+26]) * CONVDACBITSTOVOLTS * scalefactors[chan-1].dac_dccts;   //DCCT1
                (*msg_ptr)++;
                **msg_ptr = (float)(s32)(buf_data[i+27]) * CONVDACBITSTOVOLTS * scalefactors[chan-1].dac_dccts;   //DCCT2
                (*msg_ptr)++;
                **msg_ptr = (float)(s32)(buf_data[i+28]) * CONV16BITSTOVOLTS * scalefactors[chan-1].dac_dccts;   //DAC Monitor
                (*msg_ptr)++;
                **msg_ptr = (float)(s32)(buf_data[i+29]) * CONV16BITSTOVOLTS * scalefactors[chan-1].vout;   //Voltage Monitor
                (*msg_ptr)++;
                **msg_ptr = (float)(s32)(buf_data[i+30]) * CONV16BITSTOVOLTS * scalefactors[chan-1].ignd;   //iGND Monitor
                (*msg_ptr)++;
                **msg_ptr = (float)(s32)(buf_data[i+31]) * CONV16BITSTOVOLTS * scalefactors[chan-1].spare;   //Spare Monitor
                (*msg_ptr)++;
                **msg_ptr = (float)(s32)(buf_data[i+32]) * CONV16BITSTOVOLTS * scalefactors[chan-1].regulator;   //Regulator
                (*msg_ptr)++;
                **msg_ptr = (float)(s32)(buf_data[i+33]) * CONV16BITSTOVOLTS * scalefactors[chan-1].error;   //Error
                (*msg_ptr)++;
             }
            break;

        default:
            //xil_printf("Error: Invalid chan value: %d\n", chan);
            break;
    }
    //xil_printf("Finish CopyDataChan...\r\n");
    //xTaskResumeAll();
    //taskEXIT_CRITICAL();
    ////portEXIT_CRITICAL();

}



static
void ReadDMABuf(char *msg, TriggerInfo *trig) {

	u32 BUFSTART = 0x10000000;
	u32 BUFLEN   = 0x01E84800;
	u32 const BUFSTEPBYTES  = 0xA0; //160 bytes
    u32 const BUFSTEPWORDS = BUFSTEPBYTES/4;
    u32 const WORDSPERSAMPLE = 40;
	u32 *buf_data;
    float *msg_fltptr;
    u32 startaddr, stopaddr;
    u32 prefirstnumwords, presecnumwords, postfirstnumwords, postsecnumwords;

    //xil_printf("In ReadDMABuf Message ID: %d\r\n",trig->msgID);

    msg_fltptr = (float *)msg;

	// Invalidate cache of entire circular buffer
	Xil_DCacheInvalidateRange(0x10000000,16e6);

    //find start and stop addresses for snapshot dump
    //each trigger is 10kHz
    //Each point is 160 bytes
    startaddr = trig->addr - trig->pretrigpts*BUFSTEPBYTES;
    stopaddr = trig->addr + trig->posttrigpts*BUFSTEPBYTES;
    if (startaddr < 0x10000000) {
       //pretrigger wrap
	   presecnumwords = (trig->addr - BUFSTART) >> 2;
	   prefirstnumwords   = trig->pretrigpts*WORDSPERSAMPLE - presecnumwords;
	   startaddr = BUFSTART+BUFLEN - prefirstnumwords*4;
	   //copy pre-trigger
	   buf_data = (u32 *) startaddr;
	   CopyDataChan(&msg_fltptr, buf_data, prefirstnumwords, trig->channum);
	   //copy first postbuf
	   buf_data = (u32 *) BUFSTART;
	   CopyDataChan(&msg_fltptr, buf_data, presecnumwords, trig->channum);
	   //copy second postbuf
  	   buf_data = (u32 *) trig->addr;
	   CopyDataChan(&msg_fltptr, buf_data, trig->posttrigpts*BUFSTEPWORDS, trig->channum);

    }
    else if (stopaddr > BUFSTART+BUFLEN) {
       //posttrigger wrap
	   postfirstnumwords = (BUFSTART+BUFLEN - trig->addr) >> 2;
	   postsecnumwords   = trig->posttrigpts*WORDSPERSAMPLE - postfirstnumwords;
	   //copy pre-trigger
	   buf_data = (u32 *) startaddr;
	   CopyDataChan(&msg_fltptr, buf_data, trig->pretrigpts*BUFSTEPWORDS, trig->channum);
		//copy first postbuf
	   buf_data = (u32 *) trig->addr;
	   CopyDataChan(&msg_fltptr, buf_data, postfirstnumwords, trig->channum);
  	   //copy second postbuf
  	   buf_data = (u32 *) BUFSTART;
	   CopyDataChan(&msg_fltptr, buf_data, postsecnumwords, trig->channum);
    }

    else {
       //no wraps
	   buf_data = (u32 *) startaddr;
	   CopyDataChan(&msg_fltptr, buf_data, (trig->pretrigpts+trig->posttrigpts)*BUFSTEPWORDS, trig->channum);
    }


}




static
s32 SendWfmData(psc_key *PSC, char *msg, TriggerInfo *trig) {



    trig->sendbuf = 0;
    trig->active = 0;

	ReadDMABuf(msg,trig);
	trig->trigcnt++;


	//hton_conv(msg,MSGWFMLEN);
	//psc_send(PSC, trig->msgID, MSGWFMLEN, msg);

	if ((trig->msgID == MSGINJCH1) || (trig->msgID == MSGINJCH2) ||
		(trig->msgID == MSGINJCH3) || (trig->msgID == MSGINJCH4)) {
		//xil_printf("Sending Inj Snapshot:  %d\r\n",trig->msgID);
		//Inj Trigger only wants 1k points
		hton_conv(msg,MSGINJWFMLEN);
		//xil_printf("SendWfmData TrigNum: %d: Ch%d  Calling psc_send...",trig->trigcnt,(trig->msgID & 0x3)+1);
		psc_send(PSC, trig->msgID, MSGINJWFMLEN, msg);
		//xil_printf("    Done\r\n");
	}
	else {
		//xil_printf("Sending Other Snapshot:  %d\r\n",trig->msgID);
		hton_conv(msg,MSGWFMLEN);
		psc_send(PSC, trig->msgID, MSGWFMLEN, msg);
	}



    return 0;
}




static
void ProcessTrigger(TriggerInfo *trig, const char *trig_name) {


    if ((trig->addr != trig->addr_last) && (trig->active == 0)) {
        trig->active = 1;
        trig->addr_last = trig->addr;
        //xil_printf("Got %s Trigger...   BufPtr Addr: %x\r\n", trig_name, trig->addr);
        trig->postdlycnt = 0;
    }

    if (trig->active == 1) {
        if (trig->postdlycnt < (trig->posttrigpts/1000)) {
        	//this is expecting the loop to run at 10Hz
            (trig->postdlycnt)++;
            //xil_printf("Post Trig Cnt = %d\r\n",trig->postdlycnt);
        } else {
            trig->sendbuf = 1;
            //xil_printf("\r\nSend Buf...\r\n");
        }
    }
}





static
void CheckforTriggers(TriggerTypes *trig) {


    if (trig->usr[0].active == 0)
       trig->usr[0].addr = Xil_In32(XPAR_M_AXI_BASEADDR + USR1TRIG_BUFPTR);
    ProcessTrigger(&trig->usr[0], "Usr1");

    if (trig->usr[1].active == 0)
       trig->usr[1].addr = Xil_In32(XPAR_M_AXI_BASEADDR + USR2TRIG_BUFPTR);
    ProcessTrigger(&trig->usr[1], "Usr2");

    if (trig->usr[2].active == 0)
       trig->usr[2].addr = Xil_In32(XPAR_M_AXI_BASEADDR + USR3TRIG_BUFPTR);
    ProcessTrigger(&trig->usr[2], "Usr3");

    if (trig->usr[3].active == 0)
       trig->usr[3].addr = Xil_In32(XPAR_M_AXI_BASEADDR + USR4TRIG_BUFPTR);
    ProcessTrigger(&trig->usr[3], "Usr4");


    if (trig->flt[0].active == 0)
       trig->flt[0].addr = Xil_In32(XPAR_M_AXI_BASEADDR + FLT1TRIG_BUFPTR);
    ProcessTrigger(&trig->flt[0], "Flt1");

    if (trig->flt[1].active == 0)
       trig->flt[1].addr = Xil_In32(XPAR_M_AXI_BASEADDR + FLT2TRIG_BUFPTR);
    ProcessTrigger(&trig->flt[1], "Flt2");

    if (trig->flt[2].active == 0)
       trig->flt[2].addr = Xil_In32(XPAR_M_AXI_BASEADDR + FLT3TRIG_BUFPTR);
    ProcessTrigger(&trig->flt[2], "Flt3");

    if (trig->flt[3].active == 0)
       trig->flt[3].addr = Xil_In32(XPAR_M_AXI_BASEADDR + FLT4TRIG_BUFPTR);
    ProcessTrigger(&trig->flt[3], "Flt4");


    if (trig->err[0].active == 0)
       trig->err[0].addr = Xil_In32(XPAR_M_AXI_BASEADDR + ERR1TRIG_BUFPTR);
    ProcessTrigger(&trig->err[0], "Err1");

    if (trig->err[1].active == 0)
       trig->err[1].addr = Xil_In32(XPAR_M_AXI_BASEADDR + ERR2TRIG_BUFPTR);
    ProcessTrigger(&trig->err[1], "Err2");

    if (trig->err[2].active == 0)
       trig->err[2].addr = Xil_In32(XPAR_M_AXI_BASEADDR + ERR3TRIG_BUFPTR);
    ProcessTrigger(&trig->err[2], "Err3");

    if (trig->err[3].active == 0)
       trig->err[3].addr = Xil_In32(XPAR_M_AXI_BASEADDR + ERR4TRIG_BUFPTR);
    ProcessTrigger(&trig->err[3], "Err4");


    if (trig->inj[0].active == 0)
       trig->inj[0].addr = Xil_In32(XPAR_M_AXI_BASEADDR + INJ1TRIG_BUFPTR);
    ProcessTrigger(&trig->inj[0], "Inj1");

    if (trig->inj[1].active == 0)
       trig->inj[1].addr = Xil_In32(XPAR_M_AXI_BASEADDR + INJ2TRIG_BUFPTR);
    ProcessTrigger(&trig->inj[1], "Inj2");

    if (trig->inj[2].active == 0)
       trig->inj[2].addr = Xil_In32(XPAR_M_AXI_BASEADDR + INJ3TRIG_BUFPTR);
    ProcessTrigger(&trig->inj[2], "Inj3");

    if (trig->inj[3].active == 0)
       trig->inj[3].addr = Xil_In32(XPAR_M_AXI_BASEADDR + INJ4TRIG_BUFPTR);
    ProcessTrigger(&trig->inj[3], "Inj4");


    if (trig->evr[0].active == 0)
       trig->evr[0].addr = Xil_In32(XPAR_M_AXI_BASEADDR + EVRTRIG_BUFPTR);
    ProcessTrigger(&trig->evr[0], "Evr1");

    if (trig->evr[1].active == 0)
       trig->evr[1].addr = Xil_In32(XPAR_M_AXI_BASEADDR + EVRTRIG_BUFPTR);
    ProcessTrigger(&trig->evr[1], "Evr2");

    if (trig->evr[2].active == 0)
       trig->evr[2].addr = Xil_In32(XPAR_M_AXI_BASEADDR + EVRTRIG_BUFPTR);
    ProcessTrigger(&trig->evr[2], "Evr3");

    if (trig->evr[3].active == 0)
       trig->evr[3].addr = Xil_In32(XPAR_M_AXI_BASEADDR + EVRTRIG_BUFPTR);
    ProcessTrigger(&trig->evr[3], "Evr4");

}






static
void InitTriggerInfo(struct TriggerTypes * trig) {

	int i;

    //initialize data structures
    for (i=0;i<=3;i++) {
	  trig->usr[i].addr_last = trig->usr[i].addr = trig->usr[i].active = trig->usr[i].sendbuf = trig->usr[i].postdlycnt = 0;
      trig->usr[i].pretrigpts = trig->usr[i].posttrigpts = 50000;
	  trig->usr[i].channum = i+1;
	  trig->usr[i].msgID = MSGUSRCH1+i;

	  trig->flt[i].addr_last = trig->flt[i].addr = trig->flt[i].active = trig->flt[i].sendbuf = trig->flt[i].postdlycnt = 0;
      trig->flt[i].pretrigpts = trig->flt[i].posttrigpts = 50000;
	  trig->flt[i].channum = i+1;
	  trig->flt[i].msgID = MSGFLTCH1+i;

	  trig->err[i].addr_last = trig->err[i].addr = trig->err[i].active = trig->err[i].sendbuf = trig->err[i].postdlycnt = 0;
      trig->err[i].pretrigpts = trig->err[i].posttrigpts = 50000;
	  trig->err[i].channum = i+1;
	  trig->err[i].msgID = MSGERRCH1+i;

	  trig->inj[i].addr_last = trig->inj[i].addr = trig->inj[i].active = trig->inj[i].sendbuf = trig->inj[i].postdlycnt = 0;
      trig->inj[i].pretrigpts = 0;
      trig->inj[i].posttrigpts = 8000;
	  trig->inj[i].channum = i+1;
	  trig->inj[i].msgID = MSGINJCH1+i;
	  trig->inj[i].trigcnt = 0;

	  trig->evr[i].addr_last = trig->evr[i].addr = trig->evr[i].active = trig->evr[i].sendbuf = trig->evr[i].postdlycnt = 0;
      trig->evr[i].pretrigpts = trig->evr[i].posttrigpts = 50000;
	  trig->evr[i].channum = i+1;
	  trig->evr[i].msgID = MSGEVRCH1+i;
    }



}




/* Snapshot state persists between 100 ms calls from pscdata_poll(). */
static struct TriggerTypes snapshot_trig;

/* Waveform buffers.  EVR waveform transmission is currently disabled. */
static char msgUsr_buf[4][MSGWFMLEN];
static char msgFlt_buf[4][MSGWFMLEN];
static char msgErr_buf[4][MSGWFMLEN];
static char msgInj_buf[4][MSGWFMLEN];
static char msgWfmStats_buf[MSGWFMSTATSLEN];

void snapshot_init(void)
{
    InitTriggerInfo(&snapshot_trig);
    printf("INFO: Initializing snapshot processing\n");
}

void snapshot_process(psc_key *PSC)
{
    TriggerTypes *trig = &snapshot_trig;

    CheckforTriggers(trig);

    /* Scan all trigger types and send any completed waveform. */
    for (int i = 0; i < 4; ++i) {
        if (trig->usr[i].sendbuf == 1)
            SendWfmData(PSC, msgUsr_buf[i], &trig->usr[i]);
        if (trig->flt[i].sendbuf == 1)
            SendWfmData(PSC, msgFlt_buf[i], &trig->flt[i]);
        if (trig->err[i].sendbuf == 1)
            SendWfmData(PSC, msgErr_buf[i], &trig->err[i]);
        if (trig->inj[i].sendbuf == 1)
            SendWfmData(PSC, msgInj_buf[i], &trig->inj[i]);
    }

    SendSnapShotStats(PSC, msgWfmStats_buf, trig);
}
