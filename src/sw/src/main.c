#include <stdlib.h>
#include <unistd.h>


#include "xil_cache.h"
#include "xil_printf.h"
#include "xil_types.h"


#include <FreeRTOS.h>
#include <xil_cache_l.h>
#include <xil_io.h>

#include <lwip/init.h>
#include <lwip/sockets.h>
#include <lwip/sys.h>
#include <lwip/opt.h>
#include <netif/xadapter.h>
#include <xparameters_ps.h>

#include "xqspips.h"
#include "xiicps.h"

#include "local.h"
#include "control.h"
#include "pl_regs.h"
#include "qspi_flash.h"

#include "xuartps.h"

psc_key* the_server;

struct ScaleFactorType scalefactors[4];
XQspiPs QspiInstance;
XIicPs IicPsInstance0;	    // si570
XIicPs IicPsInstance1;      // eeprom, one-wire

uint32_t git_hash;

float CONVVOLTSTODACBITS;
float CONVDACBITSTOVOLTS;





static void PrintCacheState(void)
{
    u32 sctlr;

    __asm__ volatile ("mrc p15, 0, %0, c1, c0, 0" : "=r" (sctlr));

    xil_printf("SCTLR = 0x%08x\r\n", sctlr);
    xil_printf("D-cache bit C[2]  = %d\r\n", (sctlr >> 2)  & 1);
    xil_printf("I-cache bit I[12] = %d\r\n", (sctlr >> 12) & 1);
}




static void client_event(void *pvt, psc_event evt, psc_client *ckey)
{
    if(evt!=PSC_CONN)
        return;
    // send some "static" information once when a new client connects.
    struct {
        uint32_t git_hash;
        uint32_t serial;
    } msg = {
        .git_hash = htonl(git_hash),
        .serial = 0, // TODO: read from EEPROM
    };
    (void)pvt;

    psc_send_one(ckey, 0x100, sizeof(msg), &msg);
}

static void client_msg(void *pvt, psc_client *ckey, uint16_t msgid, uint32_t msglen, void *msg)
{
    (void)pvt;

	//xil_printf("In Client_Msg:  MsgID=%d   MsgLen=%d\r\n",msgid,msglen);


    //blink front panel LED
    Xil_Out32(XPAR_M_AXI_BASEADDR + IOC_ACCESS_REG, 1);
    Xil_Out32(XPAR_M_AXI_BASEADDR + IOC_ACCESS_REG, 0);

    switch(msgid) {
        case 0:
        	glob_settings(msg);
        	break;

        case 1:
        case 2:
        case 3:
        case 4:
         	chan_settings(msgid,msg,msglen);
            break;
        case 101:
        	write_ramptable(1,msg,msglen);
            break;
        case 102:
        case 103:
        case 104:
            break;
    }



}

static void on_startup(void *pvt, psc_key *key)
{
    (void)pvt;
    (void)key;
    u32 polarity;

    lstats_setup();

    sadata_setup();
    snapshot_setup();
    console_setup();

    polarity = Xil_In32(XPAR_M_AXI_BASEADDR + POLARITY_REG);
    if (polarity == 0)  {
      xil_printf("Bipolar, add BPC Thread\r\n");
      bpc_setup();
    }


}

static void realmain(void *arg)
{
    (void)arg;

    printf("Main thread running\n");

    {
        net_config conf = {};
        sdcard_handle(&conf);
        InitSettingsfromQspi();
        net_setup(&conf);

    }

    discover_setup();
    //tftp_setup();

    const psc_config conf = {
        .port = 3000,
        .start = on_startup,
        .conn = client_event,
        .recv = client_msg,
    };
    

	PrintCacheState();

    psc_run(&the_server, &conf);
    while(1) {
        fprintf(stderr, "ERROR: PSC server loop returns!\n");
        sys_msleep(1000);
    }
}


void print_firmware_version()
{

    time_t epoch_time;
    struct tm *human_time;
    char timebuf[80];

    xil_printf("Module ID Number: %x\r\n", Xil_In32(XPAR_M_AXI_BASEADDR + ID));
    xil_printf("Module Version Number: %x\r\n", Xil_In32(XPAR_M_AXI_BASEADDR + VERSION));
    xil_printf("Project ID Number: %x\r\n", Xil_In32(XPAR_M_AXI_BASEADDR + PRJ_ID));
    xil_printf("Project Version Number: %x\r\n", Xil_In32(XPAR_M_AXI_BASEADDR + PRJ_VERSION));
    //compare to git commit with command: git rev-parse --short HEAD
    xil_printf("Git Checksum: %x\r\n", Xil_In32(XPAR_M_AXI_BASEADDR + PRJ_SHASUM));
    epoch_time = Xil_In32(XPAR_M_AXI_BASEADDR + PRJ_TIMESTAMP);
    human_time = localtime(&epoch_time);
    strftime(timebuf, sizeof(timebuf), "%Y-%m-%d %H:%M:%S", human_time);
    xil_printf("Project Compilation Timestamp: %s\r\n", timebuf);
}









int main(void) {

	u32 chan, base;
	/*
	u32 numwords, i;

	union {
	    u32   u;
	    float f;
	} data;
    */

	//Xil_DCacheDisable();   // Disable data cache
	//Xil_ICacheDisable();   // Disable instruction cache

	PrintCacheState();

    xil_printf("Power Supply Controller\r\n");
    print_firmware_version();


    printf("LWIP_SO_SNDTIMEO             = %d\r\n",
           LWIP_SO_SNDTIMEO);
    printf("LWIP_SO_RCVTIMEO             = %d\r\n",
           LWIP_SO_RCVTIMEO);
    printf("LWIP_NETCONN_FULLDUPLEX      = %d\r\n",
           LWIP_NETCONN_FULLDUPLEX);
    printf("LWIP_NETCONN_SEM_PER_THREAD  = %d\r\n",
           LWIP_NETCONN_SEM_PER_THREAD);
    printf("MIB2_STATS                    = %d\r\n",
           MIB2_STATS);


    //Set 10KHz trigger frequency
    //Step Size = 2^n * fout / fclk
    //          = 2^32 * 9.961722 KHz / 100MHz
    //          = 427852.7
	Xil_Out32(XPAR_M_AXI_BASEADDR + NCO_STEPSIZE_REG, 427853);


	/*
	Xil_Out32(XPAR_M_AXI_BASEADDR + NUMCHANS_REG, 0);
	xil_printf("Numchans = %d\r\n", Xil_In32(XPAR_M_AXI_BASEADDR + NUMCHANS_REG));
	Xil_Out32(XPAR_M_AXI_BASEADDR + NUMCHANS_REG, 1);
	xil_printf("Numchans = %d\r\n", Xil_In32(XPAR_M_AXI_BASEADDR + NUMCHANS_REG));

	Xil_Out32(XPAR_M_AXI_BASEADDR + CH34_DUALMODE_REG, 1);
	xil_printf("DualMode = %d\r\n", Xil_In32(XPAR_M_AXI_BASEADDR + CH34_DUALMODE_REG));
	Xil_Out32(XPAR_M_AXI_BASEADDR + CH34_DUALMODE_REG, 0);
	xil_printf("DualMode = %d\r\n", Xil_In32(XPAR_M_AXI_BASEADDR + CH34_DUALMODE_REG));
    */

	init_i2c();
	prog_si570();
	QspiFlashInit();

	usleep(100);
	ReadHardwareFlavor();


	//EVR reset
    xil_printf("Resetting EVR GTX...\r\n");
	Xil_Out32(XPAR_M_AXI_BASEADDR + EVR_RESET_REG, 0xFF);
	usleep(100);
	Xil_Out32(XPAR_M_AXI_BASEADDR + EVR_RESET_REG, 0);
	usleep(100);
	Xil_Out32(XPAR_M_AXI_BASEADDR + EVR_PM_EVENTNUM_REG, 29);
	Xil_Out32(XPAR_M_AXI_BASEADDR + EVR_1HZ_EVENTNUM_REG, 32);
	Xil_Out32(XPAR_M_AXI_BASEADDR + EVR_INJ_EVENTNUM_REG, 32);


	// Set FOFB IP Address
    xil_printf("Setting FOFB IP Address to 10.0.142.100...\r\n");
	Xil_Out32(XPAR_M_AXI_BASEADDR + FOFB_IPADDR_REG, 0x0A008E64);

	usleep(100);
	//Set Fault Enable Registers, clear faults
	/*
	for (chan=1;chan<5;chan++) {
		xil_printf("Clearing Faults...\r\n");
	    base = XPAR_M_AXI_BASEADDR + chan * CHBASEADDR;
	    Xil_Out32(base + FAULT_MASK_REG,0x1FEF);
	    xil_printf("Fault Mask Reg = %x\r\n",Xil_In32(base + FAULT_MASK_REG));
	    Xil_Out32(base + FAULT_CLEAR_REG,1);
	    usleep(10);
	    Xil_Out32(base + FAULT_CLEAR_REG,0);
	}
	*/

   /*
   numwords = Xil_In32(XPAR_M_AXI_BASEADDR + CHBASEADDR + MANCH_FIFO_WDCNT_REG);
   xil_printf("Number of Words in Manch FIFO : %d\r\n",numwords);
   numwords = Xil_In32(XPAR_M_AXI_BASEADDR + CHBASEADDR + MANCH_FIFO_DATA_REG);
   xil_printf("Data Word in Manch FIFO : %d\r\n",numwords);
   xil_printf("Resetting Manchester FIFO\r\n");
   Xil_Out32(XPAR_M_AXI_BASEADDR + CHBASEADDR + MANCH_FIFO_RESET_REG, 1);
   Xil_Out32(XPAR_M_AXI_BASEADDR + CHBASEADDR + MANCH_FIFO_RESET_REG, 0);


   while (1) {
	  usleep(500000);
      numwords = Xil_In32(XPAR_M_AXI_BASEADDR + CHBASEADDR + MANCH_FIFO_WDCNT_REG);
      xil_printf("Number of Words in Manch FIFO : %d\r\n",numwords);
      if (numwords > 0) {
    	  xil_printf("Reading FIFO\r\n");
    	  for (i=0;i<62;i++) {
    	       data.u = Xil_In32(XPAR_M_AXI_BASEADDR + CHBASEADDR + MANCH_FIFO_DATA_REG);
    	       printf("Word # %2d :  %10x   %8.3f\r\n",i, data.u,  data.f);
    	   }
    	   Xil_Out32(XPAR_M_AXI_BASEADDR + CHBASEADDR + MANCH_FIFO_RESET_REG, 1);
    	   Xil_Out32(XPAR_M_AXI_BASEADDR + CHBASEADDR + MANCH_FIFO_RESET_REG, 0);
      }
   }
   */


    sys_thread_new("main", realmain, NULL, THREAD_STACKSIZE, DEFAULT_THREAD_PRIO);

    // Run threads.  Does not return.
    vTaskStartScheduler();
    // never reached
    return 42;
}
