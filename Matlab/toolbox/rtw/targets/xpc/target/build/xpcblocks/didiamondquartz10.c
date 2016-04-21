/* $Revision: 1.3 $ $Date: 2002/03/25 04:06:32 $ */
/* didiamondquartz10.c - xPC Target, non-inlined S-function driver for digital I/O section of QUARTZ-MM from Diamond  */
/* Copyright 1996-2002 The MathWorks, Inc.
*/

#define 	S_FUNCTION_LEVEL 	2
#undef 		S_FUNCTION_NAME
#define 	S_FUNCTION_NAME didiamondquartz10

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
#endif

#define 	NUMBER_OF_ARGS        	(3)
#define 	CHANNEL_ARG         	ssGetSFcnParam(S,0)
#define 	SAMP_TIME_ARG          	ssGetSFcnParam(S,1)
#define 	BASE_ADDR_ARG           ssGetSFcnParam(S,2)


#define 	SAMP_TIME_IND           (0)

#define 	NO_I_WORKS             	(0)

#define 	NO_R_WORKS              (0)

#define 	THRESHOLD				0.5

static char_T msg[256];

static void mdlInitializeSizes(SimStruct *S)
{
	int_T num_channels, i;

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

	ssSetNumOutputPorts(S, mxGetN(CHANNEL_ARG));
	for (i=0;i<mxGetN(CHANNEL_ARG);i++) {
		ssSetOutputPortWidth(S, i, 1);
	}

    ssSetNumInputPorts(S, 0);

    ssSetNumSampleTimes(S, 1);

    ssSetNumRWork(S, NO_R_WORKS);
    ssSetNumIWork(S, NO_I_WORKS);
    ssSetNumPWork(S, 0);

    ssSetNumModes(S, 0);
    ssSetNumNonsampledZCs(S, 0);


	ssSetSFcnParamNotTunable(S,0);
	ssSetSFcnParamNotTunable(S,1);
	ssSetSFcnParamNotTunable(S,2);

    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE | SS_OPTION_PLACE_ASAP);
        
}
 
static void mdlInitializeSampleTimes(SimStruct *S)
{    
   	ssSetSampleTime(S, 0, mxGetPr(SAMP_TIME_ARG)[SAMP_TIME_IND]);
    if (mxGetN((SAMP_TIME_ARG))==1) {
		ssSetOffsetTime(S, 0, 0.0);
	} else {
       	ssSetOffsetTime(S, 0, mxGetPr(SAMP_TIME_ARG)[1]);
	}

}

	

static void mdlOutputs(SimStruct *S, int_T tid)
{

#ifndef MATLAB_MEX_FILE

	int_T i;
	uchar_T channel, tmp; 
	real_T  *y;

	tmp=rl32eInpB(((uint_T)mxGetPr(BASE_ADDR_ARG)[0]+0x02));
	
	for (i=0;i<mxGetN(CHANNEL_ARG);i++) {
		channel=(uchar_T)mxGetPr(CHANNEL_ARG)[i];
		y=ssGetOutputPortSignal(S,i);
		y[0]=(tmp & (1<<(channel-1))) >>(channel-1); 
	}
			
#endif
        
}

static void mdlTerminate(SimStruct *S)
{
}

#ifdef	MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif

