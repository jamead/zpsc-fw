#ifndef PSC_LOCAL_H
#define PSC_LOCAL_H

#include <stdlib.h>
#include <stdint.h>

#include <lwip/def.h>
#include <lwip/inet.h>

#include <xil_io.h>
#include <xparameters.h>

#include "pscserver.h"

#define THREAD_STACKSIZE 1024
#define MAX_TASKS 16


// parsed from NET.CNF
typedef struct {
    ip_addr_t addr, mask, gw;
    uint8_t use_static;
    uint8_t hwaddr[NETIF_MAX_HWADDR_LEN];
} net_config;


typedef union {
    u32 u;
    float f;
    s32 i;
} MsgUnion;

extern struct netif server_netif;

void net_setup(net_config *conf);
void discover_setup(void);
void tftp_setup(void);
void lstats_setup(void);
void sadata_setup(void);
void snapshot_setup(void);
void console_setup(void);
void sdcard_handle(net_config *conf);
void init_i2c(void);
void i2c_get_mac_address();
void i2c_eeprom_readBytes(u8, u8 *, u8);
void i2c_eeprom_writeBytes(u8, u8 *, u8);
void eeprom_dump();
void menu_get_ipaddr();
void prog_si570();
void InitSettingsfromQspi();
void chan_settings(u32, void *, u32);
float ReadAccumSA(u32, u32);
void write_ramptable(u32, void *, u32);
void ReadHardwareFlavor(void);


/* registers from Controller.v by word offset
 */
typedef enum {
    Controller_GitHash = 27,
} Controller_reg;

static inline
uint32_t Controller_read_(Controller_reg reg) {
    return Xil_In32(XPAR_M_AXI_BASEADDR + 4u * reg);
}
// eg.
//  uint32_t val = Controller_read(GitHash);
#define Controller_read(REG) Controller_read_(Controller_ ## REG)

static inline
void Controller_write_(Controller_reg reg, uint32_t val) {
    Xil_Out32(XPAR_M_AXI_BASEADDR + 4u * reg, val);
}
#define Controller_write(REG, VAL) Controller_write_(Controller_ ## REG, VAL)


/* Read from 24AA025E48T-I/OT 256B EEPROM on PSC carrier.
 *
 * ee_* are not reentrant.
 */
#define EE_SIZE 256
int ee_read(uint8_t addr, uint8_t *dst, size_t count);
int ee_write(uint8_t addr, const uint8_t *src, size_t count);

extern psc_key* the_server;
extern uint32_t git_hash;

static inline
uint32_t htonf(float f) {
    union {
        float f;
        uint32_t u;
    } pun;
    pun.f = f;
    return htonl(pun.u);
}



#define GAIN20BITFRACT 1048575.0
#define GAIN16BITFRACT 65535.0

#define CONVVOLTSTO16BITS  3276.8   // 2^16/20.0
#define CONV16BITSTOVOLTS  (1.0/CONVVOLTSTO16BITS)

#define CONVVOLTSTO18BITS  13107.2  // 2^20/20.0
#define CONV18BITSTOVOLTS  1/CONVVOLTSTO18BITS

#define CONVVOLTSTO20BITS  52428.8   // 2^20/20.0
#define CONV20BITSTOVOLTS  1/CONVVOLTSTO20BITS

#define SAMPLERATE 10000.0

#define MS_RES 0  //medium resolution, 18bits
#define HS_RES 1  //high resolution, 20bits


typedef struct ScaleFactorType {
	float ampspersec;
	float dac_dccts;
	float vout;
	float ignd;
	float spare;
	float regulator;
	float error;
} ScaleFactorType;

















#endif // PSC_LOCAL_H
