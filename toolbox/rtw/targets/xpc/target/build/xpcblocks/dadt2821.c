/* 
  dadt2821.c - xPC Target, non-inlined S-function driver for the 
  analog output section of Data Translation 2821-series boards

  Copyright 1996-2002 The MathWorks, Inc.

*/

#define 	S_FUNCTION_LEVEL 	2
#undef 		S_FUNCTION_NAME
#define 	S_FUNCTION_NAME 	dadt2821

#include 	<stddef.h>
#include 	<stdlib.h>

#include 	"simstruc.h" 

#ifdef 		MATLAB_MEX_FILE
#include 	"mex.h"
#endif

#ifndef 	MATLAB_MEX_FILE
#include 	<windows.h>
#include 	"io_xpcimport.h"
#include 	"dt2821.h"
#endif

#define NUMBER_OF_ARGS		(5)
#define CHANNEL_ARG			ssGetSFcnParam(S,0)
#define RANGE_ARG			ssGetSFcnParam(S,1)
#define SAMPLE_TIME_ARG		ssGetSFcnParam(S,2)
#define BASE_ARG			ssGetSFcnParam(S,3)
#define DEVICE_ID_ARG		ssGetSFcnParam(S,4)

#define SAMP_TIME_IND		(0)

#define NO_I_WORKS			(1)
#define MAX_COUNT_I_IND		(0)

#define NO_R_WORKS			(4)
#define GAIN_R_IND			(0)
#define OFFSET_R_IND		(2)

static char_T msg[256];


static void mdlInitializeSizes(SimStruct *S)
{
	int i;

#ifndef MATLAB_MEX_FILE
#include "io_xpcimport.c"
#endif

	ssSetNumSFcnParams(S, NUMBER_OF_ARGS);  
	if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
		sprintf(msg,"%d input arguments were expected, but %d were passed\n",
			NUMBER_OF_ARGS, ssGetSFcnParamsCount(S));
		ssSetErrorStatus(S, msg);
		return;
	}

	ssSetNumContStates(S, 0);
	ssSetNumDiscStates(S, 0);

	ssSetNumInputPorts(S, mxGetN(CHANNEL_ARG));
	for (i = 0; i < mxGetN(CHANNEL_ARG); i++) {
		ssSetInputPortWidth(S, i, 1);
		ssSetInputPortDirectFeedThrough(S, i, 1);
	}

	ssSetNumOutputPorts(S, 0);

	ssSetNumSampleTimes(S, 1);

	ssSetNumRWork(S, NO_R_WORKS);
	ssSetNumIWork(S, NO_I_WORKS);
	ssSetNumPWork(S, 0);

	ssSetNumModes(S, 0);
	ssSetNumNonsampledZCs(S, 0);

	ssSetSFcnParamNotTunable(S,0);
	ssSetSFcnParamNotTunable(S,1);
	ssSetSFcnParamNotTunable(S,2);
	ssSetSFcnParamNotTunable(S,3);
	ssSetSFcnParamNotTunable(S,4);

	ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE | SS_OPTION_PLACE_ASAP);
}
 
static void mdlInitializeSampleTimes(SimStruct *S)
{
	ssSetSampleTime(S, 0, mxGetPr(SAMPLE_TIME_ARG)[SAMP_TIME_IND]);
	ssSetOffsetTime(S, 0, 0.0);
}

#define MDL_START
static void mdlStart(SimStruct *S)
{
#ifndef MATLAB_MEX_FILE
	int_T 	*IWork		= ssGetIWork(S);
	real_T 	*RWork		= ssGetRWork(S);

	int_T	base		= (int_T) mxGetPr(BASE_ARG)[0];
	int_T	device_id	= (int_T) mxGetPr(DEVICE_ID_ARG)[0];
	int_T 	nChannels	= mxGetN(CHANNEL_ARG);

	int_T	i, channel, range, count, diobits, maxCount; 
	real_T 	size, voltage;

	if (device_id == DT2823) {	/* DT2823 has 16-bit D/A */
		size = 65536.0;
		maxCount = 65535;
	}
	else {						/* the others have 12-bit D/A */
		size = 4096.0;
		maxCount = 4095;
	}

	IWork[MAX_COUNT_I_IND] = maxCount;

	for (i = 0; i < nChannels; i++) {

		range = 10.0 * mxGetPr(RANGE_ARG)[i];
		channel = (int_T) mxGetPr(CHANNEL_ARG)[i] - 1;

		switch (range) {
			case -100:
				RWork[GAIN_R_IND + channel] = 20.0 / size;
				RWork[OFFSET_R_IND + channel] = 10.0;
				break;

			case -50:
				RWork[GAIN_R_IND + channel] = 10.0 / size;
				RWork[OFFSET_R_IND + channel] = 5.0;
				break;

			case -25:
				RWork[GAIN_R_IND + channel] = 5.0 / size;
				RWork[OFFSET_R_IND + channel] = 2.5;
				break;

			case 100:
				RWork[GAIN_R_IND + channel] = 10.0 / size;
				RWork[OFFSET_R_IND + channel] = 0.0;
				break;

			case 50:
				RWork[GAIN_R_IND + channel] = 5.0 / size;
				RWork[OFFSET_R_IND + channel] = 0.0;
				break;
		}
					
	}

/* set all output voltages to 0.0 */

	voltage = 0.0;
	diobits = rl32eInpW(DACSR(base)) & (LBOE | HBOE);

	for (i = 0; i < nChannels; i++) {

		channel = (int_T) mxGetPr(CHANNEL_ARG)[i] - 1; 

		count = (voltage + RWork[OFFSET_R_IND + channel]) / 
			RWork[GAIN_R_IND + channel];

		if (count > maxCount)
			count = maxCount;

		if (count < 0)
			count = 0;

		/* clear D/A error, init DAC data buffers, no error interrupt, no DMA */
		rl32eOutpW(SUPCSR(base), 0x0020);	
											
		/* specify DAC, single conversion, no interrupt when done, disable clock, */
		/* being careful not to disturb the DIO control bits */
		rl32eOutpW(DACSR(base), ((channel) ? 0x0300 : 0x0100) | diobits);		
											
		/* check that board is present */
		if (
			rl32eInpW(SUPCSR(base)) == 0xffff &&
			rl32eInpW(DACSR (base)) == 0xffff 
		) {
			sprintf(msg, "no DT2821 for D/A at base address 0x%x", base);
			ssSetErrorStatus(S, msg);
			return;
		}

		/* load desired output count */
		rl32eOutpW(DADAT(base), count);		

		/* programmed I/O, start D/A at next clock, no error interrupt (?) */
		rl32eOutpW(SUPCSR(base), 0x0080);	
											
		/* wait for D/A to complete */		
		while (rl32eInpW(DACSR(base)) & 0x0080 == 0)
			;	
	}

#endif
}


static void mdlOutputs(SimStruct *S, int_T tid)
{
#ifndef MATLAB_MEX_FILE
	int_T	*IWork		= ssGetIWork(S);
	real_T	*RWork		= ssGetRWork(S);

	int_T 	base		= (int_T) mxGetPr(BASE_ARG)[0];
	int_T 	nChannels	= mxGetN(CHANNEL_ARG);
	int_T 	maxCount	= IWork[MAX_COUNT_I_IND];

	int_T 	i, channel, diobits, count;

	InputRealPtrsType 	uPtrs;

	real_T	voltage;

/* set each output voltage to that of the corresponding signal */

	diobits = rl32eInpW(DACSR(base)) & (LBOE | HBOE);

	for (i = 0; i < nChannels; i++) {

		channel = (int_T) mxGetPr(CHANNEL_ARG)[i] - 1;
		uPtrs = ssGetInputPortRealSignalPtrs(S, i);
		voltage = *uPtrs[0];

		count = (voltage + RWork[OFFSET_R_IND + channel]) /
			RWork[GAIN_R_IND + channel];

		if (count > maxCount) 
			count = maxCount;

		if (count < 0)
			count = 0;

	/* clear D/A error, init DAC data buffers, no error interrupt, no DMA */
		rl32eOutpW(SUPCSR(base), 0x0020);	
											
	/* specify DAC, single conversion, no interrupt when done, disable clock, */
	/* being careful not to disturb the DIO control bits */
		rl32eOutpW(DACSR(base), ((channel) ? 0x0300 : 0x0100) | diobits);		
											
	/* load desired output count */
		rl32eOutpW(DADAT(base), count);		

	/* programmed I/O, start D/A at next clock, no error interrupt (?) */
		rl32eOutpW(SUPCSR(base), 0x0080);	
											
	/* wait for D/A to complete */		
		while (rl32eInpW(DACSR(base)) & 0x0080 == 0)
			;							
	}

#endif
}

static void mdlTerminate(SimStruct *S)
{
#ifndef MATLAB_MEX_FILE

	int_T	*IWork		= ssGetIWork(S);
	real_T	*RWork		= ssGetRWork(S);

	int_T 	base		= (int_T) mxGetPr(BASE_ARG)[0];
	int_T 	nChannels	= mxGetN(CHANNEL_ARG);
	int_T 	maxCount	= IWork[MAX_COUNT_I_IND];

	int_T 	channel, i, count;
	real_T	voltage;

/* set all output voltages to 0.0 */

	voltage = 0.0;

	for (i = 0; i < nChannels; i++) {

		channel = (int_T) mxGetPr(CHANNEL_ARG)[i] - 1;

		count = (voltage + RWork[OFFSET_R_IND + channel]) /
			RWork[GAIN_R_IND + channel];

		if (count > maxCount) 
			count = maxCount;

		if (count < 0)
			count = 0;

	/* clear D/A error, init DAC data buffers, no error interrupt, no DMA */
		rl32eOutpW(SUPCSR(base), 0x0020);	
											
	/* specify DAC, single conversion, no interrupt when done, disable clock */
		rl32eOutpW(DACSR(base), (channel) ? 0x0300 : 0x0100);		
											
	/* load desired output count */
		rl32eOutpW(DADAT(base), count);		

	/* programmed I/O, start D/A at next clock, no error interrupt (?) */
		rl32eOutpW(SUPCSR(base), 0x0080);	
											
	/* wait for D/A to complete */		
		while (rl32eInpW(DACSR(base)) & 0x0080 == 0)
			;							
	}

#endif
}

#ifdef MATLAB_MEX_FILE	/* Is this file being compiled as a MEX-file? */
#include "simulink.c"	/* Mex glue */
#else
#include "cg_sfun.h"	/* Code generation glue */
#endif




