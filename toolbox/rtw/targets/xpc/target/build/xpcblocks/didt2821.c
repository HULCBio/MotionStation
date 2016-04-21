/* 
   didt2821.c - xPC Target, non-inlined S-function driver for the 
   digital input section of Data Translation DT2821 series boards.

   Copyright 1996-2002 The MathWorks, Inc.
*/

#define		S_FUNCTION_LEVEL 	2
#undef		S_FUNCTION_NAME
#define		S_FUNCTION_NAME		didt2821

#include	<stddef.h>
#include	<stdlib.h>
#include	<string.h>

#include	"tmwtypes.h"
#include	"simstruc.h" 

#ifdef MATLAB_MEX_FILE
#include	"mex.h"
#else
#include	<windows.h>
#include	"io_xpcimport.h"
#include	"dt2821.h"
#endif

#define		NUM_ARGS     	(4)
#define		PORT_ARG		ssGetSFcnParam(S, 0)
#define		CHANNEL_ARG   	ssGetSFcnParam(S, 1)
#define		SAMPLE_TIME_ARG ssGetSFcnParam(S, 2)
#define		BASE_ARG	 	ssGetSFcnParam(S, 3)

#define		NUM_I_WORKS		(0)
#define		NUM_R_WORKS		(0)

static char_T msg[256];

static void mdlInitializeSizes(SimStruct *S)
{
	int_T num_channels,i;

#ifndef MATLAB_MEX_FILE
#include "io_xpcimport.c"
#endif

	ssSetNumSFcnParams(S, NUM_ARGS);  
	if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
		sprintf(msg,"%d input arguments were expected, but %d were passed\n",
			NUM_ARGS, ssGetSFcnParamsCount(S));
		ssSetErrorStatus(S, msg);
		return;
	}

	ssSetNumContStates(S, 0);
	ssSetNumDiscStates(S, 0);

	ssSetNumInputPorts(S, 0);

	ssSetNumOutputPorts(S, mxGetN(CHANNEL_ARG));
	for (i = 0; i < mxGetN(CHANNEL_ARG); i++) {
		ssSetOutputPortWidth(S, i, 1);
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
		case 0: dacsr &= ~LBOE;	break; /* set DIOLO for input */
		case 1: dacsr &= ~HBOE;	break; /* set DIOHI for input */
	}

	rl32eOutpW(DACSR(base), dacsr);

	/* check that board is present */
	if (rl32eInpW(DACSR(base)) == 0xffff) {
		sprintf(msg, "no DT2821 for DI at base address 0x%x", base);
		ssSetErrorStatus(S, msg);
		return;
	}

#endif
}
	

static void mdlOutputs(SimStruct *S, int_T tid)
{
#ifndef MATLAB_MEX_FILE

	unsigned short diodat;
	int_T bit, i;
	real_T *y;
	int_T base = (int_T) mxGetPr(BASE_ARG)[0];
	int_T port = (int_T) mxGetPr(PORT_ARG)[0] - 1;

	diodat = rl32eInpW(DIODAT(base));

	for (i = 0; i < mxGetN(CHANNEL_ARG); i++) {

		y = ssGetOutputPortSignal(S, i);

		bit = (int_T) mxGetPr(CHANNEL_ARG)[i] - 1;

		if (port)
			bit += 8;

		y[0] = (diodat >> bit) & 1;
	}

#endif
}

#define MDL_TERMINATE
static void mdlTerminate(SimStruct *S)
{
}

#ifdef	MATLAB_MEX_FILE		/* Is this file being compiled as a MEX-file? */
#include "simulink.c"		/* MEX-file interface mechanism */
#else
#include "cg_sfun.h"		/* Code generation registration function */
#endif

