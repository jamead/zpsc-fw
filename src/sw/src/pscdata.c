/*
 * Periodic PSC data work.
 *
 * There is intentionally NO FreeRTOS thread in this file.  pscdata_poll() is
 * called by psc_run(), so all normal TCP sends occur from the one network
 * thread which owns the socket.
 */

#include <stdio.h>

#include <FreeRTOS.h>
#include <task.h>

#include "local.h"
#include "pl_regs.h"

#define FAST_PERIOD_MS  100u
#define SLOW_PERIOD_MS  500u

static TickType_t last_fast;
static TickType_t last_slow;
static int bpc_enabled;

void pscdata_init(void)
{
    TickType_t now = xTaskGetTickCount();
    u32 polarity;

    last_fast = now;
    last_slow = now;

    lstats_init();
    snapshot_init();

    polarity = Xil_In32(XPAR_M_AXI_BASEADDR + POLARITY_REG);
    bpc_enabled = (polarity == 0);

    if (bpc_enabled) {
        xil_printf("Bipolar, enable BPC processing\r\n");
        bpc_init();
    }

    printf("INFO: PSC periodic data runs in network thread\n");
}

void pscdata_poll(psc_key *PSC)
{
    TickType_t now = xTaskGetTickCount();
    const TickType_t fast_ticks = pdMS_TO_TICKS(FAST_PERIOD_MS);
    const TickType_t slow_ticks = pdMS_TO_TICKS(SLOW_PERIOD_MS);

    if ((TickType_t)(now - last_fast) < fast_ticks)
        return;

    /* Do not try to catch up with bursts after a long waveform send. */
    last_fast = now;

    /* Small routine traffic first. */
    sadata_send(PSC);

    if ((TickType_t)(now - last_slow) >= slow_ticks) {
        last_slow = now;
        lstats_send(PSC);

        if (bpc_enabled)
            bpc_send(PSC);
    }

    /* Snapshot transmission can be large, so do it last. */
    snapshot_process(PSC);
}
