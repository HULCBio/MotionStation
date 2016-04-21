/* $Revision: 1.3 $ $Date: 2002/03/25 03:57:47 $ */
/* xpctimeinfo.c - xPC Target, non-inlined S-function driver for xPC kernel timing information */
/* Copyright 1996-2002 The MathWorks, Inc.
*/

#define 	S_FUNCTION_LEVEL 	2
#undef 		S_FUNCTION_NAME
#define 	S_FUNCTION_NAME 	xpctimeinfo

#include 	<stddef.h>
#include 	<stdlib.h>

#include 	"simstruc.h" 

#ifdef 		MATLAB_MEX_FILE
#include 	"mex.h"
#endif

#ifndef 	MATLAB_MEX_FILE
#include 	<windows.h>
#include 	"time_xpcimport.h"
#endif



/* Input Arguments */
#define NUMBER_OF_ARGS          (2)
#define FUNCTION_ARG          	ssGetSFcnParam(S,0)
#define SAMP_TIME_ARG          	ssGetSFcnParam(S,1)


#define SAMP_TIME_IND           (0)
#define BASE_ADDR_IND           (0)            

#define NO_I_WORKS              (0)

#define NO_R_WORKS              (0)


static char_T msg[256];

static void mdlInitializeSizes(SimStruct *S)
{

	int i;

#ifndef MATLAB_MEX_FILE
#include "time_xpcimport.c"
#endif

    ssSetNumSFcnParams(S, NUMBER_OF_ARGS);
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
		sprintf(msg,"Wrong number of input arguments passed.\n%d arguments are expected\n",NUMBER_OF_ARGS);
        ssSetErrorStatus(S,msg);
        return;
    }

    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 0);

	ssSetNumOutputPorts(S, 1);
	ssSetOutputPortWidth(S, 0, 1);

    ssSetNumInputPorts(S, 0);

    ssSetNumSampleTimes(S, 1);

    ssSetNumRWork(S, NO_R_WORKS);
    ssSetNumIWork(S, NO_I_WORKS);
    ssSetNumPWork(S, 0);

    ssSetNumModes(S, 0);
    ssSetNumNonsampledZCs(S, 0);

	ssSetSFcnParamNotTunable(S,0);

    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE | SS_OPTION_PLACE_ASAP);
	
        
}
 
static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, mxGetPr(SAMP_TIME_ARG)[SAMP_TIME_IND]);
    ssSetOffsetTime(S, 0, 0.0);
}
 

static void mdlOutputs(SimStruct *S, int_T tid)
{

#ifndef MATLAB_MEX_FILE

	real_T *y;
     
	y=ssGetOutputPortSignal(S,0);
	switch ((int_T)mxGetPr(FUNCTION_ARG)[0]) {
		case 1:
			y[0]=xpceGetTET();
			break;
		case 2:
			y[0]=rl32eGetTicksDouble();
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


