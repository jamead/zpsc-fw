
// Read Data from BPC from digital I/O bit 2, data
// is Manchester encoded.

#include <stdio.h>


//#include <xparameters.h>

#include <FreeRTOS.h>
#include <lwip/sys.h>
#include <lwip/stats.h>

#include "local.h"
#include "pl_regs.h"

#include "xtime_l.h"





void bpc_init(void)
{
    u32 numwords;

    numwords = Xil_In32(XPAR_M_AXI_BASEADDR + CHBASEADDR + MANCH_FIFO_WDCNT_REG);
    xil_printf("Number of Words in Manch FIFO : %d\r\n",numwords);
    numwords = Xil_In32(XPAR_M_AXI_BASEADDR + CHBASEADDR + MANCH_FIFO_DATA_REG);
    xil_printf("Data Word in Manch FIFO : %d\r\n",numwords);
    xil_printf("Resetting Manchester FIFO\r\n");
    Xil_Out32(XPAR_M_AXI_BASEADDR + CHBASEADDR + MANCH_FIFO_RESET_REG, 1);
    Xil_Out32(XPAR_M_AXI_BASEADDR + CHBASEADDR + MANCH_FIFO_RESET_REG, 0);


}

void bpc_send(psc_key *PSC)
{
    static u32 msg[60];
	u32 numwords, i;

	union {
	    u32   u;
	    float f;
	} data;

        numwords = Xil_In32(XPAR_M_AXI_BASEADDR + CHBASEADDR + MANCH_FIFO_WDCNT_REG);
        //xil_printf("Number of Words in Manch FIFO : %d\r\n",numwords);
        if (numwords >= 62) {
      	  //xil_printf("Reading FIFO\r\n");
       	  for (i=0;i<62;i++) {
              data.u = Xil_In32(XPAR_M_AXI_BASEADDR + CHBASEADDR + MANCH_FIFO_DATA_REG);
          	  //printf("Word # %2d :  %10x   %8.3f\r\n",i, data.u,  data.f);
          	  if (i >= 2)
          	     msg[i - 2] = htonf(data.f);

          }
          Xil_Out32(XPAR_M_AXI_BASEADDR + CHBASEADDR + MANCH_FIFO_RESET_REG, 1);
          Xil_Out32(XPAR_M_AXI_BASEADDR + CHBASEADDR + MANCH_FIFO_RESET_REG, 0);
        }


    psc_send(PSC, 15, sizeof(msg), msg);
}
