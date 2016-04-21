/* 
   dodt2821.c - xPC Target, non-inlined S-function driver for the
   digital output section of Data Translation DT2821 series boards

   Copyright 1996-2002 The MathWorks, Inc.
*/

#define 	S_FUNCTION_LEVEL 	2
#undef 		S_FUNCTION_NAME
#define 	S_FUNCTION_NAME		dodt2821

#include 	<stddef.h>
#include 	<stdlib.h>
#include 	<string.h>

#include 	"tmwtypes.h"
#include 	"simstruc.h" 

#ifdef MATLAB_MEX_FILE
#include 	"mex.h"
#else
#include 	<windows.h>
#include 	"io_xpcimport.h"
#include 	"dt2821.h"
#endif

#define 	NUMBER_OF_ARGS	(4)
#define 	PORT_ARG		ssGetSFcnParam(S, 0)
#define 	CHANNEL_ARG		ssGetSFcnParam(S, 1)
#define 	SAMPLE_TIME_ARG	ssGetSFcnParam(S, 2)
#define 	BASE_ARG		ssGetSFcnParam(S, 3)

#define 	NUM_I_WORKS		(0)
#define 	NUM_R_WORKS		(0)

#define 	THRESHOLD		0.5

static char_T msg[256];

static void mdlInitializeSizes(SimStruct *S)
{
	int_T num_channels,i;

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

	ssSetNumOutputPorts(S, 0);

	ssSetNumInputPorts(S, mxGetN(CHANNEL_ARG));
	for (i = 0; i < mxGetN(CHANNEL_ARG); i++) {
		ssSetInputPortWidth(S, i, 1);
		ssSetInputPortDirectFeedThrough(S, i, 1);
	}

	ssSetNumSampleTimes(S, 1);

	ssSetNumRWork(S, NUM_R_WORKS);
	ssSetNumIWork(S, NUM_I_WORKS);
	ssSetNumPWork(S, 0);

	ssSetNumModes(S, 0);
	ssSetNumNonsampledZCs(S, 0);


	ssSetSFcnParamNotTunable(S, 0);
	ssSetSFcnParamNotTunable(S, 1);

	ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE | SS_OPTION_PLACE_ASAP);
}

static void mdlInitializeSampleTimes(SimStruct *S)
{
	ssSetSampleTime(S, 0, mxGetPr(SAMPLE_TIME_ARG)[0]);

	if (mxGetN((SAMPLE_TIME_ARG)) == 1) 
		ssSetOffsetTime(S, 0, 0.0);
	else
		ssSetOffsetTime(S, 0, mxGetPr(SAMPLE_TIME_ARG)[1]);
}

#define MDL_START 
static void mdlStart(SimStruct *S)
{
#ifndef MATLAB_MEX_FILE

	unsigned short dacsr;
	int_T base = (int_T) mxGetPr(BASE_ARG)[0];
	int_T port = (int_T) mxGetPr(PORT_ARG)[0] - 1;

	dacsr = rl32eInpW(DACSR(base));
	
	switch (port) {
		case 0: dacsr |= LBOE;	break; /* set DIO port 0 for output */
		case 1: dacsr |= HBOE;	break; /* set DIO port 1 for output */
	}

	rl32eOutpW(DACSR(base), dacsr);

	/* note: writes to an input DIODAT port are ignored */
	rl32eOutpW(DIODAT(base), 0x0000); 

	/* check that board is present */
	if (rl32eInpW(DACSR(base)) == 0xffff) {
		sprintf(msg, "no DT2821 for DO at base address 0x%x", base);
		ssSetErrorStatus(S, msg);
		return;
	}

#endif
}
	

static void mdlOutputs(SimStruct *S, int_T tid)
{
#ifndef MATLAB_MEX_FILE

	int_T bit, i;
	unsigned short diodat;
	InputRealPtrsType uPtrs;
	int_T base = (int_T) mxGetPr(BASE_ARG)[0];
	int_T port = (int_T) mxGetPr(PORT_ARG)[0] - 1;

	diodat = rl32eInpW(DIODAT(base));

	for (i = 0; i < mxGetN(CHANNEL_ARG); i++) {

		bit = (int_T) mxGetPr(CHANNEL_ARG)[i] - 1;

		if (port)
			bit +=8;

		uPtrs = ssGetInputPortRealSignalPtrs(S, i);

		if (*uPtrs[0] >= THRESHOLD) 
			diodat |= (1 << bit);
		else 
			diodat &= ~(1 << bit);
	}
			
	rl32eOutpW(DIODAT(base), diodat); 

#endif
}

static void mdlTerminate(SimStruct *S)
{
#ifndef MATLAB_MEX_FILE

	int_T base = (int_T) mxGetPr(BASE_ARG)[0];
	
	rl32eOutpW(DIODAT(base), 0x0000); 

#endif	
}

#ifdef	MATLAB_MEX_FILE		/* Is this file being compiled as a MEX-file? */
#include "simulink.c"		/* MEX-file interface mechanism */
#else
#include "cg_sfun.h"		/* Code generation registration function */
#endif

