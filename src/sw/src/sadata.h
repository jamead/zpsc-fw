





typedef struct SAdataChan {
	float dcct1;
	float dcct1_offset;
	float dcct1_gain;
    float dcct2;
	float dcct2_offset;
	float dcct2_gain;
	float dacmon;
	float dacmon_offset;
	float dacmon_gain;
	float volt;
	float volt_offset;
	float volt_gain;
	float gnd;
	float gnd_offset;
	float gnd_gain;
	float spare;
	float spare_offset;
	float spare_gain;
	float reg;
	float reg_offset;
	float reg_gain;
	float error;
	float error_offset;
	float error_gain;
    float dac_setpt;
    float dac_setpt_offset;
    float dac_setpt_gain;
    s32 dac_rampactive;
    float ovc1_thresh;
    float ovc2_thresh;
    float ovv_thresh;
    float err1_thresh;
    float err2_thresh;
    float ignd_thresh;
    float ovc1_cntlim;
    float ovc2_cntlim;
    float ovv_cntlim;
    float err1_cntlim;
    float err2_cntlim;
    float ignd_cntlim;
    float dcct_cntlim;
    float flt1_cntlim;
    float flt2_cntlim;
    float flt3_cntlim;
    float on_cntlim;
    float heartbeat_cntlim;
    u32 fault_clear;
    u32 fault_mask;
    u32 digout_on1;
    u32 digout_on2;
    u32 digout_reset;
    u32 digout_spare;
    u32 digout_park;
    u32 digin;
    u32 faults_live;
    u32 faults_latched;
    float sf_ampspersec;
    float sf_dac_dccts;
    float sf_vout;
    float sf_ignd;
    float sf_spare;
    float sf_regulator;
    float sf_error;
    s32 dac_setpt_raw;
    float fofb_dacsetpt;
    u32 rsvd[10];
} SAdataChan;


// PSC Message ID 31
typedef struct SAdataMsg {
	u32 numchans;             // PSC Offset 0
	u32 evr_ts_ns;            // PSC Offset 4
	u32 evr_ts_s;             // PSC Offset 8
	u32 resolution;           // PSC Offset 12
	u32 git_shasum;           // PSC Offset 16
	float die_temp;           // PSC Offset 20
	float vccint;             // PSC Offset 24
	float vccaux;             // PSC Offset 28
	u32 bandwidth;            // PSC Offset 32
	u32 polarity;             // PSC Offset 36
	u32 fofb_pktsrcvd;        // PSC Offset 40
	u32 fofb_command;         // PSC Offset 44
	u32 fofb_nonce;           // PSC Offset 48
	float tenkhz_freq;        // PSC Offset 52
	float onehz_freq;         // PSC Offset 56
	u32 ch34_dualmode;        // PSC Offset 60
	u32 rsvd[9];
    struct SAdataChan ps[4];  // PSC Offset 100
} SAdataMsg;
