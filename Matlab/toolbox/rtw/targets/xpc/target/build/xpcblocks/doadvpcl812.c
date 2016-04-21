/* $Revision: 1.4 $ $Date: 2002/03/25 04:04:00 $ */
/* doadvpcl812.c - xPC Target, non-inlined S-function driver for digital output section of Advantech PCL-812 series boards  */
/* Copyright 1996-2002 The MathWorks, Inc.
*/

#define 	S_FUNCTION_LEVEL 	2
#undef 		S_FUNCTION_NAME
#define 	S_FUNCTION_NAME 	doadvpcl812

#include 	<stddef.h>
#include 	<stdlib.h>

#include 	"simstruc.h" 

#ifdef 		MATLAB_MEX_FILE
#include 	"mex.h"
#else
#include 	<windows.h>
#include 	"io_xpcimport.h"
#endif


/* Input Arguments */
#define NUM_PARAMS             (4)
#define BASE_ADDRESS_ARG       (ssGetSFcnParam(S,0))
#define DEV_ARG                (ssGetSFcnParam(S,1))
#define CHANNEL_ARG            (ssGetSFcnParam(S,2))
#define SAMPLE_TIME_PARAM      (ssGetSFcnParam(S,3))

/* Convert S Function Parameters to Varibles */

#define BASE                   ((uint_T) mxGetPr(BASE_ADDRESS_ARG)[0])
#define SAMPLE_TIME            ((real_T) mxGetPr(SAMPLE_TIME_PARAM)[0])
#define SAMPLE_OFFSET          ((real_T) mxGetPr(SAMPLE_TIME_PARAM)[1])

#define THRESHOLD              	0.5


static char_T msg[256];
static uint_T dout_low;
static uint_T dout_high;



/*====================*
 * S-function methods *
 *====================*/

static void mdlCheckParameters(SimStruct *S)
{
}

static void mdlInitializeSizes(SimStruct *S)
{
    uint_T i;

#ifndef MATLAB_MEX_FILE
#include "io_xpcimport.c"
#endif


    ssSetNumSFcnParams(S, NUM_PARAMS);
    if (ssGetNumSFcnParams(S) == ssGetSFcnParamsCount(S)) {
        mdlCheckParameters(S);
        if (ssGetErrorStatus(S) != NULL) {
            return;
        }
    } else {
        return; /* Parameter mismatch will be reported by Simulink */
    }

    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 0);

    if (!ssSetNumInputPorts(S, mxGetNumberOfElements(CHANNEL_ARG))) return;

    for (i=0;i<mxGetNumberOfElements(CHANNEL_ARG);i++) {
        ssSetInputPortWidth(S, i, 1);
        ssSetInputPortDirectFeedThrough(S,i,1);
    }

    if (!ssSetNumOutputPorts(S, 0)) return;
 
    ssSetNumSampleTimes(S, 1);

    ssSetNumModes(S, 0);
    ssSetNumNonsampledZCs(S, 0);

    ssSetSFcnParamNotTunable(S,0);
    ssSetSFcnParamNotTunable(S,1);
    ssSetSFcnParamNotTunable(S,2);
    ssSetSFcnParamNotTunable(S,3);

    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE | SS_OPTION_PLACE_ASAP);
	
}

static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, SAMPLE_TIME);
    ssSetOffsetTime(S, 0, SAMPLE_OFFSET);

}


#define MDL_START
static void mdlStart(SimStruct *S)
{

#ifndef MATLAB_MEX_FILE

    dout_low=BASE+13;
    dout_high=BASE+14;

    /* Set Digital Output to Initial State */

    rl32eOutpB(dout_low,0);
    rl32eOutpB(dout_high,0);

#endif /* MATLAB_MEX_FILE */

}

static void mdlOutputs(SimStruct *S, int_T tid)
{

#ifndef MATLAB_MEX_FILE	
    
    uint_T i;
    uint_T baseAddr = BASE;
    InputRealPtrsType uPtrs;
    uint_T pcl812DOPortData = 0;
    uint_T val;

    /* Send Input to Digital Output */	
    pcl812DOPortData = 0;

    for (i=0;i < mxGetNumberOfElements(CHANNEL_ARG);i++) {
        uPtrs = ssGetInputPortRealSignalPtrs(S,i);
        if (*uPtrs[0]>=THRESHOLD) {
            pcl812DOPortData |= (1 << (((short)mxGetPr(CHANNEL_ARG)[i])-1));
        }
    } 

    rl32eOutpB(dout_low,pcl812DOPortData);
    rl32eOutpB(dout_high,pcl812DOPortData>>8);

#endif /* MATLAB_MEX_FILE */
}

static void mdlTerminate(SimStruct *S)
{
#ifndef MATLAB_MEX_FILE
	
    uint_T baseAddr = BASE;

    /* Set Final State of digital output */

    rl32eOutpB(dout_low,0);
    rl32eOutpB(dout_high,0);

    ssSetUserData(S,NULL);

#endif /* MATLAB_MEX_FILE */
}

/*=============================*
 * Required S-function trailer *
 *=============================*/

#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif
