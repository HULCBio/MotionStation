/* $Revision: 1.3 $ $Date: 2002/03/25 04:00:07 $ */
/* adrtddm64x0.c - xPC Target, non-inlined S-function driver for A/D section of RTD DM64x0 boards  */
/* Copyright 1996-2002 The MathWorks, Inc.
*/

#define 	S_FUNCTION_LEVEL 	2
#undef 		S_FUNCTION_NAME
#define 	S_FUNCTION_NAME 	adrtddm64x0

#include 	<stddef.h>
#include 	<stdlib.h>

#include 	"simstruc.h" 

#ifdef 		MATLAB_MEX_FILE
#include 	"mex.h"
#endif

#ifndef 	MATLAB_MEX_FILE
#include 	<windows.h>
#include 	"io_xpcimport.h"
#endif

#define BURST_RATE       		500000.0 	   // Burst rate in [Hz].
#define BURST_RATE_16      		100000.0 	   // Burst rate in [Hz].


/* Input Arguments */
#define NUMBER_OF_ARGS          (7)
#define CHANNEL_ARG             ssGetSFcnParam(S,0)
#define COUPLING_ARG			ssGetSFcnParam(S,1)
#define RANGE_ARG            	ssGetSFcnParam(S,2)
#define GAIN_ARG            	ssGetSFcnParam(S,3)
#define SAMP_TIME_ARG           ssGetSFcnParam(S,4)
#define BASE_ADDR_ARG           ssGetSFcnParam(S,5)
#define BOARD_TYPE_ARG          ssGetSFcnParam(S,6)


#define SAMP_TIME_IND           (0)

#define NO_I_WORKS              (1)
#define BASE_ADDR_I_IND         (0)

#define NO_R_WORKS              (0)

#define RES20V					0.0048828125
#define RES10V					0.00244140625
#define RES20V_16				0.00030517578125


#define r_CLEAR							0		// Clear Register (Read/Write)
#define r_STATUS						2		// Status Register (Read)
#define r_CONTROL						2		// Control Register (Write)
#define r_AD							4		// AD Data (Read)
#define r_CHANNEL_GAIN					4		// Channel/Gain Register (Write)
#define r_AD_TABLE						4		// AD Table (Write)
#define r_DIGITAL_TABLE					4		// Digital Table (Write)
#define r_START_CONVERSION				6		// Start Conversion (Read)
#define r_TRIGGER						6		// Trigger Register (Write)
#define r_IRQ							8		// IRQ Register (Write)
#define r_DIN_FIFO						10		// Digital Input FIFO Data (Read)
#define r_DIN_CONFIG					10		// Config Digital Input FIFO (Write)
#define r_DAC1							12		// DAC 1 Data (Write)
#define r_LOAD_AD_SAMPLE_COUNT			14		// Load A/D Sample Counter (Read)
#define r_DAC2							14		// DAC 2 Data (Write)
#define r_TIMER_CLCK0					16		// Timer/Counter 0 (Read/Write)
#define r_TIMER_CLCK1					18		// Timer/Counter 1 (Read/Write)
#define r_TIMER_CLCK2					20		// Timer/Counter 2 (Read/Write)
#define r_TIMER_CTRL					22		// Timer/Counter Control Word (Write)



static char_T msg[256];

static void mdlInitializeSizes(SimStruct *S)
{

	uint_T i;

#ifndef MATLAB_MEX_FILE
#include "io_xpcimport.c"
#endif

    ssSetNumSFcnParams(S, NUMBER_OF_ARGS);
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
		sprintf(msg,"Wrong number of input arguments passed.\n%d arguments are expected\n",NUMBER_OF_ARGS);
        ssSetErrorStatus(S,msg);
        return;
    }

    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 0);

	ssSetNumOutputPorts(S,mxGetN(CHANNEL_ARG));
	for (i=0; i<mxGetN(CHANNEL_ARG); i++) {
		ssSetOutputPortWidth(S, i, 1);
	}

    ssSetNumInputPorts(S, 0);

    ssSetNumSampleTimes(S, 1);

    ssSetNumRWork(S, NO_R_WORKS);
    ssSetNumIWork(S, NO_I_WORKS);
    ssSetNumPWork(S, 0);

    ssSetNumModes(S, 0);
    ssSetNumNonsampledZCs(S, 0);

	for (i=0; i<NUMBER_OF_ARGS; i++) {
		ssSetSFcnParamNotTunable(S,i);
	}

    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE | SS_OPTION_PLACE_ASAP);
	        
}


 
static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, mxGetPr(SAMP_TIME_ARG)[SAMP_TIME_IND]);
    ssSetOffsetTime(S, 0, 0.0);
}
 

#define MDL_START
static void mdlStart(SimStruct *S)
{

#ifndef MATLAB_MEX_FILE


  	uint16_T numChannels, BaseAddress; 	        
	uint16_T i, j;
	uint16_T output, channel, gain, coupling, range;         
	real_T currentTime;

    BaseAddress = (uint16_T)mxGetPr(BASE_ADDR_ARG)[0]; 
	ssSetIWorkValue(S, BASE_ADDR_I_IND, (int_T)BaseAddress);

    numChannels = (int16_T)mxGetN(CHANNEL_ARG);

	/* clear board */
	//rl32eOutpW((unsigned short)(BaseAddress + r_CLEAR), 0x0001);
	//rl32eInpW((unsigned short)(BaseAddress + r_CLEAR));

	/* ClearADDMADone */
	rl32eOutpW((unsigned short)(BaseAddress + r_CLEAR), 0x0004);
	rl32eInpW((unsigned short)(BaseAddress + r_CLEAR));

	/* ClearChannelGainTable */
	rl32eOutpW((unsigned short)(BaseAddress + r_CLEAR), 0x0008);
	rl32eInpW((unsigned short)(BaseAddress + r_CLEAR));

	/* ClearADFIFO */
	rl32eOutpW((unsigned short)(BaseAddress + r_CLEAR), 0x0002);
	rl32eInpW((unsigned short)(BaseAddress + r_CLEAR));

	/* SetBurstClock */
	rl32eOutpB((unsigned short)(BaseAddress + r_TIMER_CTRL), 0xb4);
	{
		uint16_T Divisor;
		uint8_T LSB, MSB;
		switch ((uint16_T)mxGetPr(BOARD_TYPE_ARG)[0]) {
		case 1:
			Divisor= (8000000L / BURST_RATE);
			break;
		case 2:
			Divisor= (8000000L / BURST_RATE_16);
			break;
		}
		LSB = Divisor & 0xff;
		MSB = (Divisor & 0xff00) >> 8;
		rl32eOutpB((unsigned short)BaseAddress + r_TIMER_CLCK2, (unsigned short)LSB);
		rl32eOutpB((unsigned short)BaseAddress + r_TIMER_CLCK2, (unsigned short)MSB);
	}
	
  	/* Trigger Select */
	rl32eOutpW((unsigned short)(BaseAddress + r_TRIGGER), 0x0062);

	/* Enable loading AD table */
	rl32eOutpW((unsigned short)(BaseAddress + r_CONTROL), 0x0001);

	/* Load AD table */
	for (i=0;i<numChannels;i++) {
		uint16_T	channel	=	(uint16_T)mxGetPr(CHANNEL_ARG)[i];
		uint16_T 	coupling=	(uint16_T)mxGetPr(COUPLING_ARG)[i];
		uint16_T 	range	=	(uint16_T)mxGetPr(RANGE_ARG)[i];
		uint16_T 	gain	=	(uint16_T)mxGetPr(GAIN_ARG)[i];
		uint16_T 	output=0x0000;
		output|= channel;
		output|= gain << 4;
		switch ((uint16_T)mxGetPr(BOARD_TYPE_ARG)[0]) {
		case 1:
			output|= range << 7;
			break;
		}
		output|= coupling << 9;
		rl32eOutpW((unsigned short)(BaseAddress + r_AD_TABLE), output);
	}

	/* Disable loading AD table */
	rl32eOutpW((unsigned short)(BaseAddress + r_CONTROL), 0x0000);

	/* Enable A/D table */
	rl32eOutpW((unsigned short)(BaseAddress + r_CONTROL), 0x0004);

	/* ClearADFIFO */
	rl32eOutpW((unsigned short)(BaseAddress + r_CLEAR), 0x0002);
	rl32eInpW((unsigned short)(BaseAddress + r_CLEAR));

#endif
                 
}

static void mdlOutputs(SimStruct *S, int_T tid)
{

#ifndef MATLAB_MEX_FILE

	uint16_T 	BaseAddress = (uint16_T)ssGetIWorkValue(S, BASE_ADDR_I_IND);
	int16_T		rawValue, i;
	real_T  	*y, resolution, gain;

	/* initiate burst scan */
	rl32eInpW((unsigned short)(BaseAddress + r_START_CONVERSION));

	switch ((uint16_T)mxGetPr(BOARD_TYPE_ARG)[0]) {
	case 1:
		for (i=0; i<mxGetN(CHANNEL_ARG); i++) {
			y=ssGetOutputPortSignal(S,i);
			gain= (real_T)(1 << ((uint16_T)mxGetPr(GAIN_ARG)[i]));
			if (((uint16_T)mxGetPr(RANGE_ARG)[i])==1) {
				resolution=RES20V;	
			} else {
				resolution=RES10V;
			}
			while ( !(rl32eInpW((unsigned short)(BaseAddress + r_STATUS)) & 0x0001) );
			rawValue= (int16_T)rl32eInpW((unsigned short)(BaseAddress + r_AD)) >> (int16_T)3;
			y[0]= resolution/gain*(real_T)rawValue;
		}
		break;
	case 2:
		for (i=0; i<mxGetN(CHANNEL_ARG); i++) {
			y=ssGetOutputPortSignal(S,i);
			gain= (real_T)(1 << ((uint16_T)mxGetPr(GAIN_ARG)[i]));
			resolution=RES20V_16;	
			while ( !(rl32eInpW((unsigned short)(BaseAddress + r_STATUS)) & 0x0001) );
			rawValue= (int16_T)rl32eInpW((unsigned short)(BaseAddress + r_AD));
			y[0]= resolution/gain*(real_T)rawValue;
		}
		break;
	}

		
#endif
	        
}

static void mdlTerminate(SimStruct *S)
{   
}




#ifdef MATLAB_MEX_FILE  /* Is this file being compiled as a MEX-file? */
#include "simulink.c"   /* Mex glue */
#else
#include "cg_sfun.h"    /* Code generation glue */
#endif


