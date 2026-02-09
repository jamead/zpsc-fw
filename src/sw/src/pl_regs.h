#define AXI_CIRBUFBASE 0x10000000

#define CHBASEADDR      0x200


// global registers
#define FPGAVER_REG              0X0      // FPGA Version
#define LEDS_REG                 0X4      // PS Leds
#define RESOLUTION_REG           0x8      // DCCT, DAC Number of Bits (0=18, 1=20)
#define NUMCHANS_REG             0xC      // Number of Channels (0=2chan, 1=4chan)
#define BANDWIDTH_REG            0x10     // Bandwidth (0=Fast, 1=Medium)
#define POLARITY_REG             0x14     // Polarity (0=Bipolar, 1=Unipolar)
#define NCO_STEPSIZE_REG         0x18     // Stepsize for NCO to generate the 10KHz trigger
#define TENKHZ_FREQ_REG          0x1C     // Measurement of frequency of 10KHz pulse from NCO
#define EVR_INJ_EVENTNUM_REG     0x20     // EVR Injection Event Code (for Shot-to-Shot)
#define EVR_PM_EVENTNUM_REG      0x24     // EVR Post-Mortem Event Code
#define EVR_1HZ_EVENTNUM_REG     0x28     // EVR 1Hz Event
#define EVR_10HZ_EVENTNUM_REG    0x2C     // EVR 10Hz Event
#define EVR_10KHZ_EVENTNUM_REG   0x30     // EVR 10KHz Event
#define ONEHZ_FREQ_REG           0x34     // Measurement of 1Hz trigger rate frequency
#define EVR_TS_S_REG             0X40     // EVR Timestamp (s)
#define EVR_TS_NS_REG            0X44     // EVR Timestamp (ns)
#define EVR_RESET_REG            0X48     // EVR Reset
#define IOC_ACCESS_REG           0x50     // IOC control word sent to psc (blinks fp led)
#define TENHZ_DATASEND_REG       0x54     // 10Hz Data transmitted to IOC (blinks fp led)
#define FOFB_IPADDR_REG          0x60     // Destination IP Address of FOFB Packet to Decode
#define FOFB_PACKETS_RCVD_REG    0x64     // Number of valid FOFB packets
#define FOFB_COMMAND_REG         0x68     // Readback of Command Register of FOFB packet
#define FOFB_NONCE_REG           0x6C     // Readback of NONCE Register in FOFB packet
#define CH34_DUALMODE_REG        0x70     // Links Ch3 and Ch4 on and fault registers for Series Connected Supplies


// channel registers
#define DCCT1_REG                0X00     // DCCT 0
#define DCCT2_REG                0X04     // DCCT 1
#define DACMON_REG               0X08     // DAC Monitor
#define VOLT_REG                 0X0C     // Voltage Monitor
#define GND_REG                  0X10     // GND Monitor
#define SPARE_REG                0X14     // Spare Monitor
#define REG_REG                  0X18     // Regulator Output Monitor
#define ERR_REG                  0X1C     // Error
#define DAC_SETPT_OFFSET_REG     0X20     // DAC Offset
#define DAC_SETPT_GAIN_REG       0X24     // DAC Gain
#define DAC_SETPT_REG            0X28     // DAC SetPoint - when in jumpmode
#define DAC_OPMODE_REG           0X2C     // DAC Mode 0=smooth ramp, 1=ramp table, 2=FOFB, 3=Jump Mode
#define DAC_CNTRL_REG            0X30     // DAC Control bit0=op_gnd, bit1=sdo_dis, bit2=dac_tri, bit3=rbuf, bit4=bin2sc
#define DAC_RESET_REG            0X34     // DAC Reset
#define DAC_RAMPLEN_REG          0X38     // DAC Ramp Table Length
#define DAC_RAMPADDR_REG         0X3C     // DAC Ramp Table Address
#define DAC_RAMPDATA_REG         0X40     // DAC Ramp Table Data
#define DAC_RUNRAMP_REG          0X44     // DAC Run RampTable
#define DAC_RAMPACTIVE_REG       0X48     // DAC Ramptable Run Active
#define DAC_CURRSETPT_REG        0X4C     // DAC Current SetPt
#define DCCT1_OFFSET_REG         0X50     // DCCT 0 Offset
#define DCCT1_GAIN_REG           0X54     // DCCT 0 Gain
#define DCCT2_OFFSET_REG         0X58     // DCCT 1 Offset
#define DCCT2_GAIN_REG           0X5C     // DCCT 1 Gain
#define DACMON_OFFSET_REG        0X60     // DAC Monitor Offset
#define DACMON_GAIN_REG          0X64     // DAC Monitor Gain
#define VOLT_OFFSET_REG          0X68     // Voltage Monitor Offset
#define VOLT_GAIN_REG            0X6C     // Voltage Monitor Gain
#define GND_OFFSET_REG           0X70     // GND Monitor Offset
#define GND_GAIN_REG             0X74     // GND Monitor Gain
#define SPARE_OFFSET_REG         0X78     // Spare Monitor Offset
#define SPARE_GAIN_REG           0X7C     // Spare Monitor Gain
#define REG_OFFSET_REG           0X80     // Regulator Output Offset
#define REG_GAIN_REG             0X84     // Regulator Output Gain
#define ERR_OFFSET_REG           0X88     // Error Monitor Offset
#define ERR_GAIN_REG             0X8C     // Error Monitor Gain
#define OVC1_THRESH_REG          0X90      // DCCT1 Over Current Fault Threshold
#define OVC2_THRESH_REG          0X94      // DCCT2 Over Current Fault Threshold
#define OVV_THRESH_REG           0X98      // Over Voltage Fault Threshold
#define ERR1_THRESH_REG          0X9C      // PID Error1 Fault Threshold
#define ERR2_THRESH_REG          0XA0      // PID Error2 Fault Threshold
#define IGND_THRESH_REG          0XA4      // Gnd Current Fault Threshold
#define OVC1_CNTLIM_REG          0XA8      // DCCT1 Over Current Fault Counter Limit
#define OVC2_CNTLIM_REG          0XAC      // DCCT2 Over Current Fault Counter Limit
#define OVV_CNTLIM_REG           0XB0      // Over Voltage Fault Counter Limit
#define ERR1_CNTLIM_REG          0XB4      // PID Error1 Fault Counter Limit
#define ERR2_CNTLIM_REG          0XB8      // PID Error2 Fault Counter Limit
#define IGND_CNTLIM_REG          0XBC      // Gnd Current Fault Counter Limit
#define DCCT_CNTLIM_REG          0XC0      // Digital DCCT Counter Limit
#define FLT1_CNTLIM_REG          0XC4      // Fault1 Counter Limit
#define FLT2_CNTLIM_REG          0XC8      // Fault2 Counter Limit
#define FLT3_CNTLIM_REG          0XCC      // Fault3 Counter Limit
#define ON_CNTLIM_REG            0XD0      // On Counter Limit
#define FAULT_CLEAR_REG          0XD4      // Fault Clear
#define FAULT_MASK_REG           0XD8      // Fault Mask
#define HEARTBEAT_CNTLIM_REG     0XDC      // HeartBeat Counter Limit
#define DIGOUT_ON1_REG           0XE0      // Digital Outputs bit0=On1
#define DIGOUT_ON2_REG           0XE4      // Digital Outputs bit1=On2
#define DIGOUT_RESET_REG         0XE8      // Digital Outputs bit2=Reset
#define DIGOUT_SPARE_REG         0XEC      // Digital Outputs bit3=spare
#define DIGOUT_PARK_REG          0XF0      // Digital Outputs bit4=Park
#define DIGIN_REG                0XF4      // Digital Inputs bit0=Acon, bit1=Flt1, bit2=Flt2, bit3=spare, bit4=DCCTflt
#define FAULTS_LIVE_REG          0xF8      // Live Faults
#define FAULTS_LAT_REG           0xFC      // Latched Faults
#define AVEMODE_REG              0x100     // Average mode for 10Hz data
#define SMOOTH_PHASEINC_REG      0x104     // Phase Increment for Infinity Smooth Ramp
#define DIGOUT_ON2_PULSEENB_REG  0x108     // Enable Pulsing on ON2 Digital Output
#define FOFB_FASTADDR_REG        0x120     // FOFB Address
#define FOFB_DACSETPT_REG        0x124     // Read back of Set Point received from FOFB link
#define FOFB_SCALEFACTOR_REG     0x128     // Scalefactor to convert FOFB Float Input to DAC Bits



#define SNAPSHOT_ADDRPTR         0xA00     // Snapshot 20 sec circular buffer current address pointer
#define SNAPSHOT_TOTALTRIGS      0xA04     // Snapshot 20 sec circular buffer total data points written
#define SOFTTRIG                 0xA08     // Soft Trig
#define TESTTRIG                 0xA0C     // Test Trig - Test the 4-Fault, 4-Error and EVR Trigger
#define USR1TRIG_BUFPTR          0xA20     // Usr1 Trig Buffer Ptr.  Buffer Point latched value gets put here on User1 trigger
#define USR1TRIG_TS_S            0xA24     // Usr1 Trig Timestamp (s)
#define USR1TRIG_TS_NS           0xA28     // Usr1 Trig Timestamp (ns)
#define USR2TRIG_BUFPTR          0xA30     // Usr2 Trig Buffer Ptr.  Buffer Point latched value gets put here on User2 trigger
#define USR2TRIG_TS_S            0xA34     // Usr2 Trig Timestamp (s)
#define USR2TRIG_TS_NS           0xA38     // Usr2 Trig Timestamp (ns)
#define USR3TRIG_BUFPTR          0xA40     // Usr3 Trig Buffer Ptr.  Buffer Point latched value gets put here on User3 trigger
#define USR3TRIG_TS_S            0xA44     // Usr3 Trig Timestamp (s)
#define USR3TRIG_TS_NS           0xA48     // Usr3 Trig Timestamp (ns)
#define USR4TRIG_BUFPTR          0xA50     // Usr4 Trig Buffer Ptr.  Buffer Point latched value gets put here on User4 trigger
#define USR4TRIG_TS_S            0xA54     // Usr4 Trig Timestamp (s)
#define USR4TRIG_TS_NS           0xA58     // Usr4 Trig Timestamp (ns)
#define FLT1TRIG_BUFPTR          0xA60     // Fault1 Buffer Ptr.  Buffer Point latched value gets put here on Fault1 trigger
#define FLT1TRIG_TS_S            0xA64     // Fault1 Trig Timestamp (s)
#define FLT1TRIG_TS_NS           0xA68     // Fault1 Trig Timestamp (ns)
#define FLT2TRIG_BUFPTR          0xA70     // Fault2 Buffer Ptr.  Buffer Point latched value gets put here on Fault2 trigger
#define FLT2TRIG_TS_S            0xA74     // Fault2 Trig Timestamp (s)
#define FLT2TRIG_TS_NS           0xA78     // Fault2 Trig Timestamp (ns)
#define FLT3TRIG_BUFPTR          0xA80     // Fault3 Buffer Ptr.  Buffer Point latched value gets put here on Fault3 trigger
#define FLT3TRIG_TS_S            0xA84     // Fault3 Trig Timestamp (s)
#define FLT3TRIG_TS_NS           0xA88     // Fault3 Trig Timestamp (ns)
#define FLT4TRIG_BUFPTR          0xA90     // Fault4 Buffer Ptr.  Buffer Point latched value gets put here on Fault4 trigger
#define FLT4TRIG_TS_S            0xA94     // Fault4 Trig Timestamp (s)
#define FLT4TRIG_TS_NS           0xA98     // Fault4 Trig Timestamp (ns)
#define ERR1TRIG_BUFPTR          0xAA0     // Err1 Buffer Ptr.  Buffer Point latched value gets put here on Err1 trigger
#define ERR1TRIG_TS_S            0xAA4     // Err1 Trig Timestamp (s)
#define ERR1TRIG_TS_NS           0xAA8     // Err1 Trig Timestamp (ns)
#define ERR2TRIG_BUFPTR          0xAB0     // Err2 Buffer Ptr.  Buffer Point latched value gets put here on Err2 trigger
#define ERR2TRIG_TS_S            0xAB4     // Err2 Trig Timestamp (s)
#define ERR2TRIG_TS_NS           0xAB8     // Err2 Trig Timestamp (ns)
#define ERR3TRIG_BUFPTR          0xAC0     // Err3 Buffer Ptr.  Buffer Point latched value gets put here on Err3 trigger
#define ERR3TRIG_TS_S            0xAC4     // Err3 Trig Timestamp (s)
#define ERR3TRIG_TS_NS           0xAC8     // Err3 Trig Timestamp (ns)
#define ERR4TRIG_BUFPTR          0xAD0     // Err4 Buffer Ptr.  Buffer Point latched value gets put here on Err4 trigger
#define ERR4TRIG_TS_S            0xAD4     // Err4 Trig Timestamp (s)
#define ERR4TRIG_TS_NS           0xAD8     // Err4 Trig Timestamp (ns)
#define INJ1TRIG_BUFPTR          0xAE0     // Inj1 Buffer Ptr.  Buffer Point latched value gets put here on Inj1 trigger
#define INJ1TRIG_TS_S            0xAE4     // Inj1 Trig Timestamp (s)
#define INJ1TRIG_TS_NS           0xAE8     // Inj1 Trig Timestamp (ns)
#define INJ2TRIG_BUFPTR          0xAF0     // Inj2 Buffer Ptr.  Buffer Point latched value gets put here on Inj2 trigger
#define INJ2TRIG_TS_S            0xAF4     // Inj2 Trig Timestamp (s)
#define INJ2TRIG_TS_NS           0xAF8     // Inj2 Trig Timestamp (ns)
#define INJ3TRIG_BUFPTR          0XB00     // Inj3 Buffer Ptr.  Buffer Point latched value gets put here on Inj3 trigger
#define INJ3TRIG_TS_S            0XB04     // Inj3 Trig Timestamp (s)
#define INJ3TRIG_TS_NS           0XB08     // Inj3 Trig Timestamp (ns)
#define INJ4TRIG_BUFPTR          0XB10     // Inj4 Buffer Ptr.  Buffer Point latched value gets put here on Inj4 trigger
#define INJ4TRIG_TS_S            0XB14     // Inj4 Trig Timestamp (s)
#define INJ4TRIG_TS_NS           0XB18     // Inj4 Trig Timestamp (ns)
#define EVRTRIG_BUFPTR           0XB20     // EVR Buffer Ptr.  Buffer Point latched value gets put here on EVR trigger
#define EVRTRIG_TS_S             0XB24     // EVR Trig Timestamp (s)
#define EVRTRIG_TS_NS            0XB28     // EVR Trig Timestamp (ns)



#define ID                       0XC00     // Module Identification Number
#define VERSION                  0XC04     // Module Version Number
#define PRJ_ID                   0XC08     // Project Identification Number
#define PRJ_VERSION              0XC0C     // Project Version Number
#define PRJ_SHASUM               0XC10     // Project Repository check sum.
#define PRJ_TIMESTAMP            0XC14     // Project compilation timestamp




