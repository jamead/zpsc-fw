
//Waveform Thread: Snapshot Statistics (pointers, etc)
// Updated at 10Hz, keeps waveform connection alive
#define MSGWFMSTATS 50
#define MSGWFMSTATSLEN 500


//Waveform Thread: This message is for Snapshot 10KHz data
//10KS/s * 10sec *40bytes/sample = 4Mbytes
#define MSGUSRCH1 60
#define MSGUSRCH2 61
#define MSGUSRCH3 62
#define MSGUSRCH4 63

#define MSGFLTCH1 70
#define MSGFLTCH2 71
#define MSGFLTCH3 72
#define MSGFLTCH4 73

#define MSGERRCH1 80
#define MSGERRCH2 81
#define MSGERRCH3 82
#define MSGERRCH4 83

#define MSGINJCH1 90
#define MSGINJCH2 91
#define MSGINJCH3 92
#define MSGINJCH4 93

#define MSGEVRCH1 100
#define MSGEVRCH2 101
#define MSGEVRCH3 102
#define MSGEVRCH4 103

#define MSGWFMLEN 4000000   //in bytes
//#define MSGWFMLEN 1000000

typedef struct SnapTrigData {
	u32 lataddr;
	u32 active;
	u32 ts_s;
	u32 ts_ns;
} SnapTrigData;


typedef struct SnapStatsMsg {
	u32 cur_bufaddr;     // PSC Offset 0
	u32 totalfacnt;      // PSC Offset 4
    SnapTrigData usr[4]; // PSC Offset 8
    SnapTrigData flt[4]; // PSC Offset 72
    SnapTrigData err[4]; // PSC Offset 136
    SnapTrigData inj[4]; // PSC Offset 200
    SnapTrigData evr[4]; // PSC OFfset 264
} SnapStatsMsg;


typedef struct TriggerInfo {
	u32 addr;
	u32 addr_last;
	u32 pretrigpts;
	u32 posttrigpts;
	u32 active;
	u32 postdlycnt;
	u32 sendbuf;
	u32 msgID;
	u32 channum;
} TriggerInfo;

typedef struct TriggerTypes {
	struct TriggerInfo usr[4];
	struct TriggerInfo flt[4];
	struct TriggerInfo err[4];
	struct TriggerInfo inj[4];
	struct TriggerInfo evr[4];
} TriggerTypes;
