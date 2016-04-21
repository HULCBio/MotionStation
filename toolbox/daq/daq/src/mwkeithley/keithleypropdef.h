// keithleypropdef.h - Contains the enumeration definitions for device properties.
// $Revision: 1.1.6.1 $
// $Date: 2003/10/15 18:31:39 $

// Copyright 2002-2003 The MathWorks, Inc. 
// Coded by OPTI-NUM solutions

#ifndef __KEITHLEYPROPDEF_H__
#define __KEITHLEYPROPDEF_H__

// These constants are used for message window task registration
#define analoginputMask 0x0100 
#define analogoutputMask 0x0200

struct RANGE_INFO {
    short	gainCode;
	float	gain;		// Store this to provide polarity information.
    double	minVal;
    double	maxVal;
};

typedef enum {
	STATUS_STOPPED = 0,
	STATUS_RUNNING
} StatusTypes;

typedef enum {
    CHAN_SKEW_MANUAL = 0,
	CHAN_SKEW_EQUISAMPLE,
	CHAN_SKEW_MIN
} ChannelSkewModeTypes;

typedef enum {
	IN_SINGLEENDED = 0,
	IN_DIFFERENTIAL
} InputTypes;

typedef enum {
	CLCK_INTERNAL,
	CLCK_EXTERNAL,
	CLCK_SOFTWARE
} ClockSourceTypes;

typedef enum {
	TRIG_COND_NONE = 0,
	TRIG_COND_RISING = 0,
	TRIG_COND_FALLING,
	TRIG_COND_GATEHIGH,
	TRIG_COND_GATELOW
} TriggerConditionTypes;

typedef enum {
	TRIGGER_IMMEDIATE = TRIG_IMMEDIATE,
	TRIGGER_MANUAL = TRIG_MANUAL,
	TRIGGER_SOFTWARE = TRIG_SOFTWARE,
	TRIGGER_HWDIGITAL = MAKE_USER_TRIGGER(TRIG_PRETRIGGER_DISABLED | TRIG_TRIGGER_IS_HARDWARE,3L)
} TriggerTypes;

typedef enum {
	STP_TRIGT_NONE = 0,
	STP_TRIGT_HWDIGITAL,
	STP_TRIGT_HWANALOG
} StopTriggerTypes;

typedef enum {
	STP_TRIGC_NONE = 0,
	STP_TRIGC_RISING = 0,
	STP_TRIGC_FALLING
	//STP_TRIGC_ABOVE = 0,	% The following are not supported for consistency amongst boards
	//STP_TRIGC_BELOW,
	//STP_TRIGC_INSIDE,
	//STP_TRIGC_OUTSIDE
} StopTriggerConditionTypes;

typedef enum {
	STDU_SECONDS = 0,
	STDU_SAMPLES
} StopTriggerDelayUnitTypes;

typedef enum {
	TRANSFER_DMA = 0,
	TRANSFER_INTERRUPTS,
	TRANSFER_POLLED
} TransferModeTypes;

typedef enum {
	POLARITY_BIPOLAR = 0,
	POLARITY_UNIPOLAR
} PolarityTypes;

typedef enum{
	CHAN_SKEW_SAFE_TICS = 0,
	CHAN_SKEW_SAFE_MICROSEC = 1
} ChannelSkewSafetyUnitTypes;

#endif // __KEITHLEYPROPDEF_H__