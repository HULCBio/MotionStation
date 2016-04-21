/* $Revision: 1.1.6.2 $ $Date: 2004/04/08 21:01:39 $ */
/* can527status.c - xPC Target, non-inlined S-function driver for Intel 82527   */
/* Copyright 1994-2004 The MathWorks, Inc. */

#define 	S_FUNCTION_LEVEL 	2
#undef 		S_FUNCTION_NAME
#define 	S_FUNCTION_NAME can527status

#include 	<stddef.h>
#include 	<stdlib.h>
#include 	<string.h>

#include 	"tmwtypes.h"
#include 	"simstruc.h" 

#ifdef MATLAB_MEX_FILE
#include 	"mex.h"
#else
#include 	<windows.h>
#include 	"time_xpcimport.h"
#include 	"io_xpcimport.h"
#include	"canxpc527.h"
#endif

#define 	NUMBER_OF_ARGS        	(1)
#define 	SAMP_TIME_ARG          	ssGetSFcnParam(S,0)

#define 	SAMP_TIME_IND           (0)

#define 	NO_I_WORKS             	(1)

#define 	NO_R_WORKS              (0)

static char_T msg[256];

static void mdlInitializeSizes(SimStruct *S)
{
	int_T num_channels, i;

#ifndef MATLAB_MEX_FILE
#include "io_xpcimport.c"
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
	ssSetSFcnParamNotTunable(S,1);

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




#define MDL_START 
static void mdlStart(SimStruct *S)
{

#ifndef MATLAB_MEX_FILE

	uint16_T resourceReg, baseAddr, presc, tsync, tseg1, tseg2, i;

	resourceReg= (uint16_T)rl32eInpB(0x804);
    switch (resourceReg & 0xf) {
	case 1:
		baseAddr= 0x1000;
		break;
	case 2:
		baseAddr= 0x8000;
		break;
	case 3:
		baseAddr= 0xe000;
		break;
    default: 
		sprintf(msg,"xPC TargetBox CAN controller disabled in BIOS");
        ssSetErrorStatus(S,msg);
        return;
	}
	
	ssSetIWorkValue(S,0,(int_T)baseAddr);

#endif

}

	

static void mdlOutputs(SimStruct *S, int_T tid)
{

#ifndef MATLAB_MEX_FILE

	uint16_T baseAddr= ssGetIWorkValue(S,0);
	uint16_T status;
	real_T *y;

	y= ssGetOutputPortSignal(S,0);
	y[0]= (real_T)(rl32eInpB(baseAddr + 1) & 0xff);
	rl32eOutpB(baseAddr + 1, 0x00);
	
#endif
        
}

static void mdlTerminate(SimStruct *S)
{

#ifndef MATLAB_MEX_FILE


#endif

}

#ifdef	MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif

