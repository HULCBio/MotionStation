/* $Revision: 1.1.6.2 $ */
//===========================================================================
//
// NAME:    powerdaq.h
//
// DESCRIPTION:
//
//          PowerDAQ QNX driver definitions needed to include into the library
//          and applications
//
// AUTHOR:  Alex Ivchenko
//
// DATE:    12-APR-2000
//
// REV:     0.8
//
// R DATE:  
//
// HISTORY:
//
//      Rev 0.8,     12-MAR-2000,     Initial version.
//
//
//---------------------------------------------------------------------------
//      Copyright (C) 2000 United Electronic Industries, Inc.
//      All rights reserved.
//---------------------------------------------------------------------------
//
#ifndef __POWER_DAQ_H__
#define __POWER_DAQ_H__


#include "pdfw_def.h"
#include "win2qnx.h"

// AIn modes definition
#define AIN_SINGLE_ENDED   0
#define AIN_DIFFERENTIAL   AIB_INPMODE

#define AIN_UNIPOLAR       0
#define AIN_BIPOLAR        AIB_INPTYPE

#define AIN_RANGE_5V       0
#define AIN_RANGE_10V      AIB_INPRANGE

#define AIN_CV_CLOCK_SW          0
#define AIN_CV_CLOCK_INTERNAL    AIB_CVSTART1
#define AIN_CV_CLOCK_EXTERNAL    AIB_CVSTART0
#define AIN_CV_CLOCK_CONTINUOUS  (AIB_CVSTART0 | AIB_CVSTART1)

#define AIN_CV_EXT_CLOCK_RISE    0
#define AIN_CV_EXT_CLOCK_FALL    AIB_EXTCVS

#define AIN_CL_CLOCK_SW          0
#define AIN_CL_CLOCK_INTERNAL    AIB_CLSTART1
#define AIN_CL_CLOCK_EXTERNAL    AIB_CLSTART0
#define AIN_CL_CLOCK_CONTINUOUS  (AIB_CLSTART0 | AIB_CLSTART1)

#define AIN_CL_EXT_CLOCK_RISE    0
#define AIN_CL_EXT_CLOCK_FALL    AIB_EXTCLS

#define AIN_CV_INT_CLOCK_BASE_11MHZ  0
#define AIN_CV_INT_CLOCK_BASE_33MHZ  AIB_INTCVSBASE

#define AIN_CL_INT_CLOCK_BASE_11MHZ  0
#define AIN_CL_INT_CLOCK_BASE_33MHZ  AIB_INTCLSBASE

#define AIN_START_TRIGGER_NONE       0
#define AIN_START_TRIGGER_RISE       AIB_STARTTRIG1
#define AIN_START_TRIGGER_FALL       AIB_STARTTRIG0
#define AIN_START_TRIGGER_EITHER     (AIB_STARTTRIG0 | AIB_STARTTRIG1)

#define AIN_STOP_TRIGGER_NONE        0
#define AIN_STOP_TRIGGER_RISE        AIB_STOPTRIG1
#define AIN_STOP_TRIGGER_FALL        AIB_STOPTRIG0
#define AIN_STOP_TRIGGER_EITHER      (AIB_STOPTRIG0 | AIB_STOPTRIG1)



//---------------------------------------------------------------------------
//
// Macros for constructing Channel List entries.
//
#define CHAN(c)     ((c) & 0x3f)
#define GAIN(g)     (((g) & 0x3) << 6)
#define SLOW        (1<<8)
#define CHLIST_ENT(c,g,s)   (CHAN(c) | GAIN(g) | ((s) ? SLOW : 0))

//---------------------------------------------------------------------------
//
// Macro to convert A/D samples from 2's complement to straight binary.
//
//Alex::No longer needed. Use pd_hcaps.h for conversion
// ...
//#define AIN_BINARY(a)   (((a) & ANDWORD) ^ XORWORD)


//-----------------------------------------------------------------------
// Definitions for mapdsp.sys Device Driver.
//-----------------------------------------------------------------------
#define TRUE        1
#define FALSE       0

#define STATUS_SUCCESS      1
#define STATUS_UNSUCCESSFUL 0

#ifndef PCI_TYPE0_ADDRESSES
  #define PCI_TYPE0_ADDRESSES     6
#endif

#pragma pack(1)
//---------------------------------------------------------------------------
//
// PCI Configuration Space:
//
typedef struct _PD_PCI_CONFIG
{
    unsigned short      VendorID;
    unsigned short      DeviceID;
    unsigned short      Command;
    unsigned short      Status;
    char                RevisionID;
	char				Class_Code[3];             
    char                CacheLineSize;
    char                LatencyTimer;
	char				Header_Type;               
	char				BIST;                      
    unsigned long       BaseAddress[6];
    unsigned long       CardBusCISPtr;
    unsigned short      SubsystemVendorID;
    unsigned short      SubsystemID;
	unsigned long		ROM_Base_Address;          
	unsigned long		Reserved2[2];              
	char				InterruptLine;            
	char				InterruptPin;             
	char				Min_Gnt;                   
	char				Max_Lat;                   
	char                Reserved3[16];
} PD_PCI_CONFIG, * PPD_PCI_CONFIG;


#define PD_MAX_BOARDS  32       // The max number of boards the driver can deal with.
#define PD_MAX_CL_SIZE 64       // Longest channel list
#define AINBUFSIZE 1024         // Buffer size
#define MAX_PWRDAQ_SUBSYSTEMS 6 // max number of subsystems in PowerDAQ PCI cards
#define MAX_PCI_SPACES      1   // number of PCI Type 0 base address registers

//---------------------------------------------------------------------------
//
// Interface Data Structures:
//

#define PD_EEPROM_SIZE          256     // EEPROM size in 16-bit words
#define PD_SERIALNUMBER_SIZE    10      // serial number length in bytes
#define PD_DATE_SIZE            12      // date string length in bytes
#define PD_CAL_AREA_SIZE        32      // EEPROM calibration area size in 16-bit words
#define PD_SST_AREA_SIZE        32      // EEPROM start-up state area size in 16-bit words

typedef struct _PD_EEPROM
{
        union
        {
        struct _Header
        {
            UCHAR   ADCFifoSize;
            UCHAR   CLFifoSize;
            UCHAR   SerialNumber[PD_SERIALNUMBER_SIZE];
            UCHAR   ManufactureDate[PD_DATE_SIZE];
            UCHAR   CalibrationDate[PD_DATE_SIZE];
            ULONG   Revision;
            USHORT  FirstUseDate;
            USHORT  CalibrArea[PD_CAL_AREA_SIZE];
            USHORT  FWModeSelect;
            USHORT  StartupArea[PD_SST_AREA_SIZE];
        } Header;

        USHORT WordValues[PD_EEPROM_SIZE];
    } u;
} PD_EEPROM, *PPD_EEPROM;

typedef enum
{
    BoardLevel  = 0,
    AnalogIn    = 1,
    AnalogOut,
    DigitalIn,
    DigitalOut,
    CounterTimer,
    CalDiag
} PD_SUBSYSTEM, * PPD_SUBSYSTEM;


// Subsystem Events (Events):
//
typedef enum {
    eStartTrig          = (1L<<0),   // start trigger / operation started
    eStopTrig           = (1L<<1),   // stop trigger / operation stopped
    eInputTrig          = (1L<<2),   // subsystem specific input trigger
    eDataAvailable      = (1L<<3),   // new data / points available

    eScanDone           = (1L<<4),   // scan done
    eFrameDone          = (1L<<5),   // logical frame done
    eFrameRecycled      = (1L<<6),   // cyclic buffer frame recycled
    eBlockDone          = (1L<<7),   // logical block done (FUTURE)

    eBufferDone         = (1L<<8),   // buffer done
    eBufListDone        = (1L<<9),   // buffer list done (FUTURE)
    eBufferWrapped      = (1L<<10),  // cyclic buffer / list wrapped
    eConvError          = (1L<<11),  // conversion clock error

    eScanError          = (1L<<12),  // scan clock error
    eDataError          = (1L<<13),  // data error (out-of-range)
    eBufferError        = (1L<<14),  // buffer over/under run error
    eTrigError          = (1L<<15),  // trigger error

    eStopped            = (1L<<16),  // operation stopped
    eTimeout            = (1L<<17),  // operation timed-out
    eAllEvents          = (0xFFFFF), // set/clear all events
} PDEvent;

typedef enum {
    eDInEvent           = (1L<<0),   // Digital Input event
    eUct0Event          = (1L<<1),   // Uct0 countdown event
    eUct1Event          = (1L<<2),   // Uct1 countdown event
    eUct2Event          = (1L<<3),   // Uct2 countdown event
} PDDigEvent;

#define     AIB_BUFFERWRAPPED   0x1
#define     AIB_BUFFERRECYCLED  0x2

//---------------------------------------------------------------------------
//
// PowerDAQ IOCTL:
//

#define PWRDAQX_CONTROL_CODE(request, method) request+0x100
#define METHOD_BUFFERED 0

//---------------------------------------------------------------------------

#define IOCTL_PWRDAQ_PRIVATE_MAP_DEVICE   PWRDAQX_CONTROL_CODE(0, METHOD_BUFFERED)
#define IOCTL_PWRDAQ_PRIVATE_UNMAP_DEVICE PWRDAQX_CONTROL_CODE(1, METHOD_BUFFERED)
#define IOCTL_PWRDAQ_PRIVATE_GETCFG       PWRDAQX_CONTROL_CODE(2, METHOD_BUFFERED)
#define IOCTL_PWRDAQ_PRIVATE_SETCFG       PWRDAQX_CONTROL_CODE(3, METHOD_BUFFERED)
#define IOCTL_PWRDAQ_PRIVATE_SET_EVENT    PWRDAQX_CONTROL_CODE(4, METHOD_BUFFERED)
#define IOCTL_PWRDAQ_PRIVATE_CLR_EVENT    PWRDAQX_CONTROL_CODE(5, METHOD_BUFFERED)

#define IOCTL_PWRDAQ_GET_NUMBER_ADAPTER PWRDAQX_CONTROL_CODE(9, METHOD_BUFFERED)
#define IOCTL_PWRDAQ_ACQUIRESUBSYSTEM   PWRDAQX_CONTROL_CODE(10, METHOD_BUFFERED)
#define IOCTL_PWRDAQ_REGISTER_BUFFER    PWRDAQX_CONTROL_CODE(11, METHOD_BUFFERED)
#define IOCTL_PWRDAQ_UNREGISTER_BUFFER  PWRDAQX_CONTROL_CODE(12, METHOD_BUFFERED)
#define IOCTL_PWRDAQ_REGISTER_EVENTS    PWRDAQX_CONTROL_CODE(13, METHOD_BUFFERED)
#define IOCTL_PWRDAQ_UNREGISTER_EVENTS  PWRDAQX_CONTROL_CODE(14, METHOD_BUFFERED)
#define IOCTL_PWRDAQ_GET_EVENTS         PWRDAQX_CONTROL_CODE(15, METHOD_BUFFERED)

#define IOCTL_PWRDAQ_SET_USER_EVENTS    PWRDAQX_CONTROL_CODE(20, METHOD_BUFFERED)
#define IOCTL_PWRDAQ_CLEAR_USER_EVENTS  PWRDAQX_CONTROL_CODE(21, METHOD_BUFFERED)
#define IOCTL_PWRDAQ_GET_USER_EVENTS    PWRDAQX_CONTROL_CODE(22, METHOD_BUFFERED)
#define IOCTL_PWRDAQ_IMMEDIATE_UPDATE   PWRDAQX_CONTROL_CODE(23, METHOD_BUFFERED)
#define IOCTL_PWRDAQ_SET_TIMED_UPDATE   PWRDAQX_CONTROL_CODE(24, METHOD_BUFFERED)

// PowerDAQ Asynchronous Buffered AIn/AOut Operations.
#define IOCTL_PWRDAQ_AIN_ASYNC_INIT     PWRDAQX_CONTROL_CODE(30, METHOD_BUFFERED)
#define IOCTL_PWRDAQ_AIN_ASYNC_TERM     PWRDAQX_CONTROL_CODE(31, METHOD_BUFFERED)
#define IOCTL_PWRDAQ_AIN_ASYNC_START    PWRDAQX_CONTROL_CODE(32, METHOD_BUFFERED)
#define IOCTL_PWRDAQ_AIN_ASYNC_STOP     PWRDAQX_CONTROL_CODE(33, METHOD_BUFFERED)

#define IOCTL_PWRDAQ_GET_DAQBUF_STATUS  PWRDAQX_CONTROL_CODE(40, METHOD_BUFFERED)
#define IOCTL_PWRDAQ_GET_DAQBUF_SCANS   PWRDAQX_CONTROL_CODE(41, METHOD_BUFFERED)
#define IOCTL_PWRDAQ_CLEAR_DAQBUF       PWRDAQX_CONTROL_CODE(42, METHOD_BUFFERED)

// Low Level PowerDAQ Board Level Commands.
#define IOCTL_PWRDAQ_BRDRESET           PWRDAQX_CONTROL_CODE(100, METHOD_BUFFERED)
#define IOCTL_PWRDAQ_BRDEEPROMREAD      PWRDAQX_CONTROL_CODE(101, METHOD_BUFFERED)
#define IOCTL_PWRDAQ_BRDEEPROMWRITEDATE PWRDAQX_CONTROL_CODE(102, METHOD_BUFFERED)
#define IOCTL_PWRDAQ_BRDENABLEINTERRUPT PWRDAQX_CONTROL_CODE(103, METHOD_BUFFERED)
#define IOCTL_PWRDAQ_BRDTESTINTERRUPT   PWRDAQX_CONTROL_CODE(104, METHOD_BUFFERED)
#define IOCTL_PWRDAQ_BRDSTATUS          PWRDAQX_CONTROL_CODE(105, METHOD_BUFFERED)
#define IOCTL_PWRDAQ_BRDSETEVNTS1       PWRDAQX_CONTROL_CODE(106, METHOD_BUFFERED)
#define IOCTL_PWRDAQ_BRDSETEVNTS2       PWRDAQX_CONTROL_CODE(107, METHOD_BUFFERED)
#define IOCTL_PWRDAQ_BRDFWLOAD          PWRDAQX_CONTROL_CODE(108, METHOD_BUFFERED)
#define IOCTL_PWRDAQ_BRDFWEXEC          PWRDAQX_CONTROL_CODE(109, METHOD_BUFFERED)

// Low Level PowerDAQ AIn Subsystem Commands.
#define IOCTL_PWRDAQ_AISETCFG           PWRDAQX_CONTROL_CODE(200, METHOD_BUFFERED)
#define IOCTL_PWRDAQ_AISETCVCLK         PWRDAQX_CONTROL_CODE(201, METHOD_BUFFERED)
#define IOCTL_PWRDAQ_AISETCLCLK         PWRDAQX_CONTROL_CODE(202, METHOD_BUFFERED)
#define IOCTL_PWRDAQ_AISETCHLIST        PWRDAQX_CONTROL_CODE(203, METHOD_BUFFERED)
#define IOCTL_PWRDAQ_AISETEVNT          PWRDAQX_CONTROL_CODE(204, METHOD_BUFFERED)
#define IOCTL_PWRDAQ_AISTATUS           PWRDAQX_CONTROL_CODE(205, METHOD_BUFFERED)
#define IOCTL_PWRDAQ_AICVEN             PWRDAQX_CONTROL_CODE(206, METHOD_BUFFERED)
#define IOCTL_PWRDAQ_AISTARTTRIG        PWRDAQX_CONTROL_CODE(207, METHOD_BUFFERED)
#define IOCTL_PWRDAQ_AISTOPTRIG         PWRDAQX_CONTROL_CODE(208, METHOD_BUFFERED)
#define IOCTL_PWRDAQ_AISWCVSTART        PWRDAQX_CONTROL_CODE(209, METHOD_BUFFERED)
#define IOCTL_PWRDAQ_AISWCLSTART        PWRDAQX_CONTROL_CODE(210, METHOD_BUFFERED)
#define IOCTL_PWRDAQ_AICLRESET          PWRDAQX_CONTROL_CODE(211, METHOD_BUFFERED)
#define IOCTL_PWRDAQ_AICLRDATA          PWRDAQX_CONTROL_CODE(212, METHOD_BUFFERED)
#define IOCTL_PWRDAQ_AIRESET            PWRDAQX_CONTROL_CODE(213, METHOD_BUFFERED)
#define IOCTL_PWRDAQ_AIGETVALUE         PWRDAQX_CONTROL_CODE(214, METHOD_BUFFERED)
#define IOCTL_PWRDAQ_AIGETSAMPLES       PWRDAQX_CONTROL_CODE(215, METHOD_BUFFERED)
#define IOCTL_PWRDAQ_AISETSSHGAIN       PWRDAQX_CONTROL_CODE(216, METHOD_BUFFERED)
#define IOCTL_PWRDAQ_AIGETXFERSAMPLES   PWRDAQX_CONTROL_CODE(217, METHOD_BUFFERED)
#define IOCTL_PWRDAQ_AISETXFERSIZE      PWRDAQX_CONTROL_CODE(218, METHOD_BUFFERED)

//?ALEX:
#define IOCTL_PWRDAQ_AIENABLECLCOUNT    PWRDAQX_CONTROL_CODE(120, METHOD_BUFFERED)
#define IOCTL_PWRDAQ_AIENABLETIMER      PWRDAQX_CONTROL_CODE(121, METHOD_BUFFERED)
#define IOCTL_PWRDAQ_AIFLUSHFIFO        PWRDAQX_CONTROL_CODE(122, METHOD_BUFFERED)
#define IOCTL_PWRDAQ_AIGETSAMPLECOUNT   PWRDAQX_CONTROL_CODE(123, METHOD_BUFFERED)

// Low Level PowerDAQ AOut Subsystem Commands.
#define IOCTL_PWRDAQ_AOSETCFG           PWRDAQX_CONTROL_CODE(300, METHOD_BUFFERED)
#define IOCTL_PWRDAQ_AOSETCVCLK         PWRDAQX_CONTROL_CODE(301, METHOD_BUFFERED)
#define IOCTL_PWRDAQ_AOSETEVNT          PWRDAQX_CONTROL_CODE(302, METHOD_BUFFERED)
#define IOCTL_PWRDAQ_AOSTATUS           PWRDAQX_CONTROL_CODE(303, METHOD_BUFFERED)
#define IOCTL_PWRDAQ_AOCVEN             PWRDAQX_CONTROL_CODE(304, METHOD_BUFFERED)
#define IOCTL_PWRDAQ_AOSTARTTRIG        PWRDAQX_CONTROL_CODE(305, METHOD_BUFFERED)
#define IOCTL_PWRDAQ_AOSTOPTRIG         PWRDAQX_CONTROL_CODE(306, METHOD_BUFFERED)
#define IOCTL_PWRDAQ_AOSWCVSTART        PWRDAQX_CONTROL_CODE(307, METHOD_BUFFERED)
#define IOCTL_PWRDAQ_AOCLRDATA          PWRDAQX_CONTROL_CODE(308, METHOD_BUFFERED)
#define IOCTL_PWRDAQ_AORESET            PWRDAQX_CONTROL_CODE(309, METHOD_BUFFERED)
#define IOCTL_PWRDAQ_AOPUTVALUE         PWRDAQX_CONTROL_CODE(310, METHOD_BUFFERED)
#define IOCTL_PWRDAQ_AOPUTBLOCK         PWRDAQX_CONTROL_CODE(311, METHOD_BUFFERED)

// Low Level PowerDAQ DIn Subsystem Commands.
#define IOCTL_PWRDAQ_DISETCFG           PWRDAQX_CONTROL_CODE(400, METHOD_BUFFERED)
#define IOCTL_PWRDAQ_DISTATUS           PWRDAQX_CONTROL_CODE(401, METHOD_BUFFERED)
#define IOCTL_PWRDAQ_DIREAD             PWRDAQX_CONTROL_CODE(402, METHOD_BUFFERED)
#define IOCTL_PWRDAQ_DICLRDATA          PWRDAQX_CONTROL_CODE(403, METHOD_BUFFERED)
#define IOCTL_PWRDAQ_DIRESET            PWRDAQX_CONTROL_CODE(404, METHOD_BUFFERED)

// Low Level PowerDAQ DOut Subsystem Commands.
#define IOCTL_PWRDAQ_DOWRITE            PWRDAQX_CONTROL_CODE(500, METHOD_BUFFERED)
#define IOCTL_PWRDAQ_DORESET            PWRDAQX_CONTROL_CODE(501, METHOD_BUFFERED)

// Low Level PowerDAQ DIO-256 Subsystem Commands.
#define IOCTL_PWRDAQ_DIO256CMDWR        PWRDAQX_CONTROL_CODE(502, METHOD_BUFFERED)
#define IOCTL_PWRDAQ_DIO256CMDRD        PWRDAQX_CONTROL_CODE(503, METHOD_BUFFERED)

// Low Level PowerDAQ UCT Subsystem Commands.
#define IOCTL_PWRDAQ_UCTSETCFG          PWRDAQX_CONTROL_CODE(600, METHOD_BUFFERED)
#define IOCTL_PWRDAQ_UCTSTATUS          PWRDAQX_CONTROL_CODE(601, METHOD_BUFFERED)
#define IOCTL_PWRDAQ_UCTWRITE           PWRDAQX_CONTROL_CODE(602, METHOD_BUFFERED)
#define IOCTL_PWRDAQ_UCTREAD            PWRDAQX_CONTROL_CODE(603, METHOD_BUFFERED)
#define IOCTL_PWRDAQ_UCTSWGATE          PWRDAQX_CONTROL_CODE(604, METHOD_BUFFERED)
#define IOCTL_PWRDAQ_UCTSWCLK           PWRDAQX_CONTROL_CODE(605, METHOD_BUFFERED)
#define IOCTL_PWRDAQ_UCTRESET           PWRDAQX_CONTROL_CODE(606, METHOD_BUFFERED)

// Low Level PowerDAQ Cal Subsystem Commands.
#define IOCTL_PWRDAQ_CALSETCFG          PWRDAQX_CONTROL_CODE(700, METHOD_BUFFERED)
#define IOCTL_PWRDAQ_CALDACWRITE        PWRDAQX_CONTROL_CODE(701, METHOD_BUFFERED)

// Low Level PowerDAQ Diag Subsystem Commands.
#define IOCTL_PWRDAQ_DIAGPCIECHO        PWRDAQX_CONTROL_CODE(800, METHOD_BUFFERED)
#define IOCTL_PWRDAQ_DIAGPCIINT         PWRDAQX_CONTROL_CODE(801, METHOD_BUFFERED)
#define IOCTL_PWRDAQ_BRDEEPROMWRITE     PWRDAQX_CONTROL_CODE(802, METHOD_BUFFERED)

// QNX driver test only ioctl's
#define IOCTL_PWRDAQ_TESTEVENTS         PWRDAQX_CONTROL_CODE(901, METHOD_BUFFERED)
#define IOCTL_PWRDAQ_TESTBUFFERING      PWRDAQX_CONTROL_CODE(902, METHOD_BUFFERED)
#define IOCTL_PWRDAQ_OPENSUBSYSTEM      PWRDAQX_CONTROL_CODE(903, METHOD_BUFFERED)
#define IOCTL_PWRDAQ_CLOSESUBSYSTEM     PWRDAQX_CONTROL_CODE(904, METHOD_BUFFERED)
#define IOCTL_PWRDAQ_RELEASEALL         PWRDAQX_CONTROL_CODE(905, METHOD_BUFFERED)


//
// File contains structures to perform requests to the driver
// structures for PowerDAQ user-level library
//

// Command to access the board
// Make shure that additional "high-level" commands
// are not conflictiong with FW commands in pdfw_def.h
//
#define  AINSETSYNCCFG  0xF101
#define  AINREADSCAN    0xF102


// Analog Input synchronous operation structure
// return averaged channel values in dwChList
typedef struct
{
  uint32_t dwMode;
  uint32_t dwChListSize;
  uint32_t dwChList[PD_MAX_CL_SIZE];

} TAinSyncCfg, *PTAinSyncCfg;

typedef struct
{
  uint32_t dwAInCfg;
  uint32_t dwEventsNotify;
  uint32_t dwAInPreTrigCount;
  uint32_t dwAInPostTrigCount;
  uint32_t dwCvRate;
  uint32_t dwClRate;
  uint32_t dwChListSize;
  uint32_t dwChList[PD_MAX_CL_SIZE];

} TAinAsyncCfg, *PTAinAsyncCfg;

// Board hardware event words.
typedef struct
{
    uint32_t   Board;
    uint32_t   ADUIntr;
    uint32_t   AIOIntr;
    uint32_t   AInIntr;
    uint32_t   AOutIntr;

} TEvents, * PTEvents;

// DaqBuf Get Scan Info Struct
typedef struct
{
    uint32_t   NumScans;       // number of scans to get
    uint32_t   ScanIndex;      // buffer index of first scan
    uint32_t   NumValidScans;  // number of valid scans available

} TScan_Info, * PTScan_Info;


typedef struct
{
    unsigned long MaxSize;
    unsigned long WordsRead;
    uint16_t Buffer[PD_EEPROM_SIZE];

} TEepromAcc;


typedef struct {
	PD_SUBSYSTEM sys;
    uint32_t *events;
} pd_get_user_events_t;


// Main command structure
// union contains ioctl-specific information needed to communicate
// with the driver
//
typedef union {
     TAinSyncCfg  AinSyncCfg;
     TEvents      Event;
     uint32_t     dwParam[8];
     TEepromAcc   EepromAcc;
     TAinAsyncCfg AinAsyncCfg;

} TCmd, *PTCmd;


#endif


