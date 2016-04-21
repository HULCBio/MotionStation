// advantechpropdef.h - Contains the enumeration definitions for device properties.
// Copyright 2002-2003 The MathWorks, Inc.
// $Revision: 1.1.6.1 $  $Date: 2003/10/15 18:30:34 $

#ifndef __ADVANTECHPROPDEF_H__
#define __ADVANTECHPROPDEF_H__

// These constants are used for message window task registration
#define analoginputMask 0x0100 
#define analogoutputMask 0x0200

struct RANGE_INFO {
    short	gainCode;
	float	gain;		// Store this to provide polarity information.
    float	minVal;
    float	maxVal;
};

typedef enum {
	CHAN_SKEW_EQUISAMPLE = 0,
	CHAN_SKEW_MANUAL,
	CHAN_SKEW_MIN
} ChannelSkewMode;

typedef enum {
	IT_SINGLE_ENDED = 0,
	IT_DIFFERENTIAL,	// NOTE: this is defined in Driver.h as 1, single ended as SINGLEENDED 
	IT_ERROR
} ITInputType;		

typedef enum {
	CLCK_INTERNAL,
	CLCK_EXTERNAL,
	CLCK_SOFTWARE,
} ClockSource;

typedef enum {
	POLARITY_BIPOLAR = 0,
	POLARITY_UNIPOLAR
} PolarityType;

typedef enum {
	TRANSFER_DMA = 0,
	TRANSFER_INTERRUPT_PB,
	TRANSFER_INTERRUPT_PP,
	TRANSFER_SOFTWARE,
} TransferMode;

typedef enum {
	TRIG_COND_NONE = 0,
	TRIG_COND_RISING = 0,
	TRIG_COND_FALLING,
	TRIG_COND_ABOVE = 0,
	TRIG_COND_BELOW
} TriggerCondition;

typedef enum {
	TRIGGER_IMMEDIATE = TRIG_IMMEDIATE,
	TRIGGER_MANUAL = TRIG_MANUAL,
	TRIGGER_SOFTWARE = TRIG_SOFTWARE,
	TRIGGER_HWDIGITAL = MAKE_USER_TRIGGER(TRIG_PRETRIGGER_DISABLED | TRIG_TRIGGER_IS_HARDWARE,3L),
	TRIGGER_HWANALOG = MAKE_USER_TRIGGER(TRIG_PRETRIGGER_DISABLED | TRIG_TRIGGER_IS_HARDWARE, 4L)
} TriggerTypes;

// The following define the types for ManualTriggerHwOn settings.
typedef enum {
	MTHO_START = 0,
	MTHO_TRIGGER} MTHOType;

enum CHANUSER {DEFAULTCHANVAL=1,HWCHANNEL,OUTPUTRANGE, INPUTRANGE};

#endif //__ADVANTECHPROPDEF_H__