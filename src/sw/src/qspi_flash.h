
#define FLASH_WRITE_CMD		    0x02
#define FLASH_READ_CMD              0x03
#define FLASH_SECTOR_ERASE_CMD      0xD8
#define FLASH_SECTOR_ERASE_SIZE	    4
#define FLASH_WRITE_ENABLE_CMD      0x06
#define FLASH_READ_STATUS_CMD       0x05
#define FLASH_READ_FLAG_STATUS_CMD  0x70
#define FLASH_SECTOR_SIZE           0x10000  // 64KB per sector for Micron flash
#define FLASH_PSCPARAM_OFFSET       0xB00000 // Offset in flash where PSC params are stored
#define FLASH_PAGE_SIZE             256      // Typical for Micron/N25Q flash
#define FLASH_UBOOTENV_OFFSET       0x100000 // Offset in flash where env is stored




typedef struct QspiData {
    u32 header;
    s32 dac_setpt_offset;
    s32 dac_setpt_gain;
    u32 dcct1_offset;
    u32 dcct1_gain;
    u32 dcct2_offset;
    u32 dcct2_gain;
    s32 dacmon_offset;
    s32 dacmon_gain;
    s32 volt_offset;
    s32 volt_gain;
    s32 gnd_offset;
    s32 gnd_gain;
    s32 spare_offset;
    s32 spare_gain;
    s32 reg_offset;
    s32 reg_gain;
    s32 error_offset;
    s32 error_gain;
    u32 ovc1_thresh;
    u32 ovc2_thresh;
    u32 ovv_thresh;
    u32 err1_thresh;
    u32 err2_thresh;
    u32 ignd_thresh;
    u32 ovc1_cntlim;
    u32 ovc2_cntlim;
    u32 ovv_cntlim;
    u32 err1_cntlim;
    u32 err2_cntlim;
    u32 ignd_cntlim;
    u32 dcct_cntlim;
    u32 flt1_cntlim;
    u32 flt2_cntlim;
    u32 flt3_cntlim;
    u32 on_cntlim;
    u32 heartbeat_cntlim;
    u32 fault_mask;
    float sf_ampspersec;
    float sf_dac_dccts;
    float sf_vout;
    float sf_ignd;
    float sf_spare;
    float sf_regulator;
    float sf_error;
} QspiData_t;



int QspiFlashInit();
void QspiFlashEraseSect(u32);
void QspiFlashWrite(u32, u32, u8 *);
void QspiFlashRead(u32, u32, u8 *);
void QspiGatherData(u32, u8 *);
void QspiDisperseData(u32, u8 *);
void QspiPrintData(QspiData_t *, u32 );

const char* find_uboot_env_variable(u8* env_buffer, size_t data_size, const char* var_name);
void QspiUBootEnvRead(u8* readbuf, size_t data_size, net_config *conf);
int decode_mac_address(unsigned char* dest, const char* src);

