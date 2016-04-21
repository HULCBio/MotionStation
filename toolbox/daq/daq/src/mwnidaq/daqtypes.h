// Copyright 1998-2003 The MathWorks, Inc. 
// $Revision: 1.3.4.4 $  $Date: 2003/10/15 18:32:45 $


#if !defined _DAQTYPES_H
#define	_DAQTYPES_H

#if _MSC_VER >= 1000
#pragma once
#endif // _MSC_VER >= 1000

#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <comdef.h>
#include <DaqmexStructs.h> 


#define DAQ_ERROR (-1)
#define DAQ_NO_ERROR (0)

#define MAX_DEVICES (16)

#define MOST_RECENT_BUFFER (0)
#define CONSECUTIVE_BUFFER (1)

#define ENABLE_DOUBLE_BUFFER (1)
#define DISABLE_DOUBLE_BUFFER (0)

// this file contains board family constants used by NI-DAQ
// I have commented out all obsolete products.

// Note that E-Series boards can be either MIO_E_SERIES, NEW_E_SERIES, or E_SERIES
// The LAB_PC class also includes 1200 products

   #define NO_BRD          0
   // #define AT_MIO_16       1
   #define AT_DIO_32F      2
   #define AT_DIO_24       3     
   #define LAB_PC          4
   // #define EISA_A2000      5
   // #define AT_MIO_16F5     6
   #define PC_DIO_96       7
   #define PC_LPM_16       8     
   #define PC_TIO_10       9
   #define AT_AO_610       10
   // #define AT_A2150        11
   // #define AT_DSP2200      12
   // #define AT_MIO_16X      13
   // #define AT_MIO_64F_5    14
   // #define AT_MIO_16D      15
   // #define SB_A2200        16
   //#define DAQCARD_700     17    // not used
   #define MIO_E_SERIES    18    
   // #define SB_MIO_16E_4       19
   #define DAQCARD_DIO24      20    
   #define AO_DC              21    
   #define VXI_AO_DC_SERIES   22
   #define VXI_DIO_SERIES     23
   #define NEW_E_SERIES       24
   #define DS51XX_SERIES      25
   #define ARB_54XX_SERIES    26
   #define DMM_40XX_SERIES          27
   #define DAQMETER_4350_SERIES     28
   #define INTELLIGENT_70XX_SERIES  29
   #define FLEX_59XX_SERIES         30
   #define DAQTIO_SERIES            31
   #define DSA_SERIES               32
   #define NIDAQ_RPC_DEVICE         33
   #define NIDAQ_SIMULATED_DEVICE   34
   #define DAQMETER_4060_SERIES     35
   #define HS51XX_SERIES            36
   #define E_SERIES                 37


/* 
 * DAQ subsystems. All "useable" subsystems are derived from DEVICE
 */
typedef enum {
    AI,
    AO,
    DIO,
    CT
} SSType;


typedef enum {
    DIFFERENTIAL=MAKE_ENUM_VALUE(INPUT_TYPE_DIFFERENTIAL,0),
    REF_SINGLE_ENDED=MAKE_ENUM_VALUE(INPUT_TYPE_SINGLEENDED,1),
    NON_REF_SINGLE_ENDED=MAKE_ENUM_VALUE(INPUT_TYPE_SINGLEENDED ,2)
} ChannelType;

typedef enum {
    BINARY,
    TWOS_COMPLEMENT
} Encoding;

typedef enum {
    BIPOLAR,
    UNIPOLAR
} Polarity;


/*
* Determine how analog output buffers are updated
*/
typedef enum {
    UPDATE_AUTO,
    UPDATE_MANUAL,
    UPDATE_TRIGGER
} UpdateMode;

/*
 * Data source for DAC
 */
typedef enum {
    FROM_FILE,
    FROM_WORKSPACE
} DataSource;


/*
 * Determine how A/D conversion is initiated
 */
typedef enum {
    INTERNAL, /* Onboard clock */
    EXT_SAMPLE_CTRL,
    EXT_SCAN_CTRL,
    EXT_SAMPLE_AND_SCAN_CTRL,
    EXT_OTHER
} ClockSrc;

typedef enum {
    NO_TRIGGER_SOURCE,
    INTERNAL_TRIGGER_SOURCE,
    EXTERNAL_TRIGGER_SOURCE,
    ANALOG_INPUT_CHANNEL
} TriggerSource;

typedef enum {
    UPDATE_CLOCK,
    DELAY_CLOCK,
    DELAY_CLOCK_PRESCALAR_1,
    DELAY_CLOCK_PRESCALAR_2
} WfmClock;


typedef enum {
    TRIG_NONE,    
    TRIG_RISING,
    TRIG_FALLING,
    TRIG_EITHER,
    TRIG_ABOVE,
    TRIG_BELOW,
    TRIG_INSIDE,
    TRIG_BELOW_HYST,
    TRIG_ABOVE_HYST,
    TRIG_RISING_EDGE,
    TRIG_FALLING_EDGE,
    TRIG_EITHER_EDGE,
    TRIG_LEAVING,
    TRIG_ENTERING
} TriggerCondition;

typedef enum {
//    TRIG_TYPE_MANUAL,
//    TRIG_TYPE_IMMEDIATE,
    SOFTWARE=TRIG_SOFTWARE,
    HW_DIGITAL=MAKE_USER_TRIGGER(TRIG_PRETRIGGER_DISABLED | TRIG_TRIGGER_IS_HARDWARE,1L),
    HW_ANALOG_CHANNEL=MAKE_USER_TRIGGER(TRIG_PRETRIGGER_DISABLED | TRIG_TRIGGER_IS_HARDWARE,2L),
    HW_ANALOG_PIN=MAKE_USER_TRIGGER(TRIG_PRETRIGGER_DISABLED | TRIG_TRIGGER_IS_HARDWARE,3L)
} AITriggerType;


typedef enum {
    NO_STOP_CONDITION,
    HW_ANALOG_STOP,
    HW_DIGITAL_STOP,
    SW_ANALOG_STOP,
    CONTINUOUS
} StopCondition;

typedef enum {
    CHAN_SKEW_NONE=1,
    EQUISAMPLE,
    CHAN_SKEW_MANUAL,
    CHAN_SKEW_MIN
} ChannelSkewMode;

#define CLR_MSGS    0   /* Clears all messages */
#define ADD_MSG     1   /* Adds a specific message to be received */
#define DEL_MSG     2   /* Deletes a specific message added earlier */

typedef enum {
	NOTIFY_AFTER_NSCANS,
	NOTIFY_AFTER_EACH_NSCANS,
	NOTIFY_WHEN_DONE_OR_ERR,
	NOTIFY_WHEN_GREATER0_LESS1,
	NOTIFY_WHEN_LESS0_GREATER1,
	NOTIFY_ANALOG_POSITIVE_TRIG,
	NOTIFY_ANALOG_NEGATIVE_TRIG,
	NOTIFY_ANALOG_EITHER_TRIG,
	NOTIFY_WHEN_AND0_NOTEQUAL1,
	NOTIFY_WHEN_AND0_EQUAL1
} EventType;



#define WM_MWDAQ  WM_USER+100

#define WM_NOTIFY_AFTER_NSAMPS         (WM_MWDAQ+1)
#define WM_NOTIFY_AFTER_EACH_NSAMPS    (WM_MWDAQ+2)
#define WM_NOTIFY_WHEN_DONE_OR_ERR     (WM_MWDAQ+3)
#define WM_NOTIFY_WHEN_GREATER0_LESS1  (WM_MWDAQ+4)
#define WM_NOTIFY_WHEN_LESS0_GREATER1  (WM_MWDAQ+5)
#define WM_NOTIFY_ANALOG_POSITIVE_TRIG (WM_MWDAQ+6)
#define WM_NOTIFY_ANALOG_NEGATIVE_TRIG (WM_MWDAQ+7)
#define WM_NOTIFY_WHEN_AND0_NOTEQUAL1  (WM_MWDAQ+8)
#define WM_NOTIFY_WHEN_AND0_EQUAL1     (WM_MWDAQ+9)

#define WM_NOTIFY_ANALOG_EITHER_TRIG   (WM_MWDAQ+11)
/* Deadband Alarm messages passed to receiving window.
 * Each alarm constant begins at a new block to allow
 * different messages of the same type to be configured
 * for at least 10 seperate channels.
 */
#define WM_NOTIFY_HI_ALARM_ON          (WM_MWDAQ+10)
#define WM_NOTIFY_HI_ALARM_OFF         (WM_MWDAQ+20)
#define WM_NOTIFY_LO_ALARM_ON          (WM_MWDAQ+30)
#define WM_NOTIFY_LO_ALARM_OFF         (WM_MWDAQ+40)

/* Additional messages */
#define WM_NOTIFY_AO_READY             (WM_MWDAQ+60) 


class DevCaps {
public:
    DevCaps();
    ~DevCaps();
    int GetDeviceData(int deviceNum);
    double FindRate(double rate, short *TimeBase, unsigned short *Interval);
    bool IsESeries() {return (deviceType == NEW_E_SERIES);}
    bool IsLab() { return Is1200() || Is700();} // board uses Lab_ISCAN...
    bool Is1200() { return deviceType == LAB_PC;}  // LabPC+ and 1200
    bool Is700() { return deviceType ==PC_LPM_16;} // Other Lab boards
    bool IsDSA() { return (deviceType == DSA_SERIES); }
    bool IsAODC() { return (deviceType == AO_DC); }
    long GetType() { return deviceType;}

    bool IsValid() { return (this!=NULL) && (deviceType >0);}
    bool HasAI() { return nInputs>0;}
    bool HasAO() { return nOutputs>0;}
    bool HasDIO() { return nDIOLines>0;}
    bool SupportsCoupling() { return wcschr( Coupling, L',' ) != NULL;}
    LPCOLESTR       GetCoupling() {return Coupling;}
    char	    drvVersion[8];
    unsigned long   deviceCode;
    long            deviceType;
    LPSTR           deviceName;
    LPCSTR	    baseAddress;
    DWORD	    transferModeAI;
    DWORD	    transferModeAO;

    DWORD           dmaLevelA;
    DWORD           dmaLevelB;
    DWORD           dmaLevelC;
    DWORD           irqLevelA;
    DWORD           irqLevelB;	
    short	    adcResolution;
    short           dacResolution;
    double          minSampleRate;
    double	    maxAISampleRate;
    double          maxAOSampleRate;
    DWORD           AIFifoSize;
    DWORD           AOFifoSize;
    double          settleTime;
    WORD            nInputs;
    unsigned short  nOutputs;
    WORD            nDIOLines;


    bool	    scanning;
    bool            analogTrig;
    bool            digitalTrig;
    bool            HasMite;
    bool            supportsUnipolar;
//    LPCSTR          subsystemType;
//    LPCSTR          nativeDataType;
    CComBSTR        Coupling;
//    LPCSTR *        polarity;    
//    LPSTR           family;
    short           nSEInputIDs;
    short           nDIInputIDs;

    short             numUnipolarGains;
    short             numBipolarGains;
    double*         unipolarGains;
    double*         bipolarGains;
    short*          unipolarGainSettings;
    short*          bipolarGainSettings;
    short*          SEInputIDs;
    short*          DIInputIDs;

    double          unipolarRange;
    double          bipolarRange;
    double          dacUnipolarRange;
    double          dacBipolarRange;
    // protect against invalid autogenerated functions
    DevCaps(DevCaps const&);
    void operator =(DevCaps const&);
private:
    int LoadDeviceInfo();
};


#endif 