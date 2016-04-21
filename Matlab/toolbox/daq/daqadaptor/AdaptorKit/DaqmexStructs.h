#ifndef _DaqmexStructs__
#define _DaqmexStructs__

// Copyright 1998-2003 The MathWorks, Inc.

#pragma once
#include "daqmex.h"

// BUFFER_ST is defined in the IDL file

#define BUFFER_GAP_BEFORE 0x1
#define BUFFER_START_TIME_VALID 0x2
#define BUFFER_END_TIME_VALID 0x4
/* set by the engine to indecate last buffer use valid samples to
   determine how many samples to transfer */
#define BUFFER_IS_LAST 0x8          // if all buffers are filled full then this is the last buffer
#define BUFFER_TRANSMIT_DATA 0x10  // the buffer contains valid data
/***************************************
*******    Error constants
****************************************/
/* These values may be returned as any Hresult from
an adaptor (ImwDevice) function or any other daq toolbox interface
*/
#define DAQERROR_MASK MAKE_HRESULT
#define DE_BASE     0x400
#define PRIVATE_BASE 0x800
#define PRIVATE_MAX  0xffff
// error codes between 0 and DE_BASE are used by COM
// error codes between DE_BASE and PRIVATE_BASE are reserved by the engine.
// An adaptor may return these error codes but should not define new errors in this range.
#define MAKE_DE(x) MAKE_HRESULT(SEVERITY_ERROR,FACILITY_ITF,x+DE_BASE)
#define IS_DE(x) ( (HRESULT_FACILITY(x) == FACILITY_ITF) && (HRESULT_CODE(x)< PRIVATE_BASE) && (HRESULT_CODE(x)>DE_BASE))
// An adaptor is welcome to define any errors greator then PRIVATE_BASE  Using MAKE_PRIVATE_ERROR adaptor error codes
// may start with 1
#define MAKE_PRIVATE_ERROR(x) MAKE_HRESULT(SEVERITY_ERROR,FACILITY_ITF,x+PRIVATE_BASE)
#define IS_PRIVATE_ERROR(x) ( (HRESULT_FACILITY(x) == FACILITY_ITF) && (HRESULT_CODE(x)> PRIVATE_BASE))

#define DE_INVALID_CHAN_RANGE           MAKE_DE(1)
#define DE_RATE_TOO_HIGH_GIVEN_CHANNELS MAKE_DE(2)
#define DE_NOT_RUNNING                  MAKE_DE(3)  // The engine returns this from getbuffer when not running
// These errors may be returned for use of a Iprop or IPropContainer interface


// Return these errors when appropreate.


/***************************************
*******    Property constants
****************************************/
// Constants for Engine created (pre existing) enums.
// Adaptor created enums may use any adaptor defined enum values
#define ENGINE_ENUM_MASK   0xffff   // used for masked enumes  (InputType,and others?)
#define ADAPTOR_ENUM_MASK   0xffff0000   // used for masked enumes  (InputType,and others?)
#define ENGINE_ENUM_USER    0x8000    // should be used by the adaptor when adding a enum to a list that does not act like current enums
#define MAKE_ENUM_VALUE(enginval,adaptorvalue)  MAKELONG(enginval, adaptorvalue)
#define GET_ADAPTOR_ENUM_VALUE(enumvalue) HIWORD(enumvalue)

typedef enum tagOUTOFDATAMODES { ODM_HOLD,ODM_DEFAULTVALUE} OUTOFDATAMODES;

// for input type ADAPTOR MUST SET UP INPUT TYPE ENUM
#define INPUT_TYPE_MANUAL       0     // Adaptor is responcible for mantaining hwChannel range info
#define INPUT_TYPE_DIFFERENTIAL 1     // Engine will use daqhwinfo DifferentialIDs to set range of hwChannel
#define INPUT_TYPE_SINGLEENDED  2     // Engine will use daqhwinfo SingleEndedIDs to set range of hwChannel

#define CLOCKSOURCE_INTERNAL    0
#define CLOCKSOURCE_SOFTWARE    1    // This is NOT implemented by the engine but can be implemented by the adaptor
#define CLOCKSOURCE_NONE	2

// for daqhwinfo sampletype
#define SAMPLE_TYPE_SCANNING 0
#define SAMPLE_TYPE_SIMULTANEOUS_SAMPLE 1

/* Trigger type enum values are a special case. The low order bits give info about
    the trigger and the upper bits define the uniqe trigger */
#define MAKE_ENGINE_TRIGGER(charistics,value)  ((charistics) | (value << 8L))
#define MAKE_USER_TRIGGER(charistics,value)  ((charistics) | (value << 16L))

// Trigger charistics
#define TRIG_PRETRIGGER_DISABLED           1L    // if this is set then data flow (HW) stops between triggers
/*  Total samples will be (SamplesPerTrigger+triggerdelay)*(TriggerRepeat+1).  triggerdelay<0 is not legal
   note that: ether can be inf. Check hidden property TotalPointsToAcqure to see if burst operation is posible*/
#define TRIG_SOFTWARE_TRIGGER_ACTIVE  2L     // Logging will not alwase be on and the engine is responcible for posting
                                            // Posting trigger events.
#define TRIG_TRIGGER_IS_HARDWARE      4L    // The adaptor is responcible for calling engine->DaqEvent(EVENT_TRIGGER
                                            // dataflow starts under hardware (adaptor) contol The engine will still call trigger

// all trigger constansts must resolve to unique values
// current engine trigger types:
#define TRIG_IMMEDIATE          MAKE_ENGINE_TRIGGER(TRIG_PRETRIGGER_DISABLED,0L) // this is funny because there is 0 time between triggers so hw does not stop...
// These constants should not be needed by the adaptors use {TRIG_PRETRIGGER_DISABLED,TRIG_SOFTWARE_TRIGGER_ACTIVE}
#define TRIG_MANUAL             MAKE_ENGINE_TRIGGER(TRIG_PRETRIGGER_DISABLED,1L) // User must call trigger for each trigger
#define TRIG_MANUAL_SOFTWARE    MAKE_ENGINE_TRIGGER(0 ,0L) // base manual trigger
#define TRIG_SOFTWARE           MAKE_ENGINE_TRIGGER(TRIG_SOFTWARE_TRIGGER_ACTIVE,0L)

// Typical hardware triggers
//#define TRIG_HW_DIGITAL     MAKE_USER_TRIGGER(TRIG_PRETRIGGER_DISABLED |TRIG_TRIGGER_IS_HARDWARE,1L)
//#define TRIG_HW_DIGITAL_PRETRIG     MAKE_USER_TRIGGER(  TRIG_TRIGGER_IS_HARDWARE,1L)

// Illegal combinations
//TRIG_SOFTWARE_TRIGGER_ACTIVE & TRIG_PRETRIGGER_DISABLED

// Untested (but legal?) combinations:
// TRIG_1_TRIGGER_PER_REPEAT | TRIG_TRIGGER_IS_HARDWARE without TRIG_TOTAL_SAMPLES_KNOWN ie pretrigger
// any combination of Hardware and software trigger


// Daqevent types
typedef enum {EVENT_START,EVENT_STOP,EVENT_TRIGGER,
			  EVENT_ERR,EVENT_OVERRANGE,EVENT_DATAMISSED,
			  EVENT_SAMPLESACQUIRED,EVENT_SAMPLESOUTPUT,EVENT_USER} DAQEventTypes;

/* Nestable property structures and conststants these are shortcuts to channel data */

//typedef enum tagNESTABLEPROPTYPES {NPAICHANNEL,NPAOCHANNEL,NPDIGITALLINE} NESTABLEPROPTYPES;


#define NPextraSize 0 // should be 0 but that generates ugly compiler warnings

#if 0 // now declaired in daqmex.idl
typedef struct tagNESTABLEPROP
{
    long StructSize;
    long Index;
    NESTABLEPROPTYPES Type;
    long HwChan;
    BSTR Name;
} NESTABLEPROP;
#endif

#pragma warning(push)
#pragma warning(disable: 4200) //zero sized arrays are non portable
typedef struct tagAICHANNEL {
    NESTABLEPROP Nestable;
    BSTR Units;
    double VoltRange[2];
    double UnitRange[2];
    double SensorRange[2];
    double ConversionExtraScaling; // this values can be modified by the adaptor
    double ConversionOffset;
    double NativeOffset;        // The adaptor should consider this read only
    double NativeScaling;
    BYTE extra[];	// do not access this NPextrasize is Nestable.StructSize-sizeof(AICHANNEL)
} AICHANNEL;

typedef struct tagAOCHANNEL {
    NESTABLEPROP Nestable;
    BSTR Units;
    double VoltRange[2];
    double UnitRange[2];
    double ConversionExtraScaling; // this values can be modified by the adaptor
    double ConversionOffset;
    double NativeOffset;        // The adaptor should consider this read only
    double NativeScaling;
    double DefaultValue;
    BYTE extra[];
} AOCHANNEL;

typedef struct tagDIGITALLINE {
    NESTABLEPROP Nestable;
    long Direction;
    long Port;
    BYTE extra[];
} DIGITALLINE;
#pragma warning(pop)

// Digitalio constants
enum DIO_DIRS { DIO_INPUT, DIO_OUTPUT, DIO_BIDIRECTIONAL};


// types of change for childchange

#define  CHILDCHANGE_REASON_MASK 0xff
typedef enum tagCHILDCHANGEREASON { ADD_CHILD=1, REINDEX_CHILD ,DELETE_CHILD,
                                  } CHILDCHANGEREASON;

#define  START_CHANGE  0x100
#define  END_CHANGE    0x200


#endif