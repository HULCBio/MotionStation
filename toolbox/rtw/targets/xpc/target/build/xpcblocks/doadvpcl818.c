/* $Revision: 1.6 $ $Date: 2002/03/25 04:04:03 $ */
/* doadvpcl818.c - xPC Target, non-inlined S-function driver for digital output section of Advantech PCL-818 series boards  */
/* Copyright 1996-2002 The MathWorks, Inc.
*/

#define 	S_FUNCTION_LEVEL 	2
#undef 		S_FUNCTION_NAME
#define 	S_FUNCTION_NAME 	doadvpcl818

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
    switch ((int_T)mxGetPr(DEV_ARG)[0]) {
        case 1:                  // Advantech PCL-818;
            dout_low=BASE+3;
            dout_high=BASE+11;
            break;
        case 2:                  // Advantech PCL-818L;
            dout_low=BASE+3;
            dout_high=BASE+11;
            break;
        case 3:                  // Advantech PCL-818H;
            dout_low=BASE+3;
            dout_high=BASE+11;
            break;
        case 4:                  // Advantech PCL-818HD;
            dout_low=BASE+3;
            dout_high=BASE+11;
            break;
        case 5:                  // Advantech PCL-818HG;
            dout_low=BASE+3;
            dout_high=BASE+11;
            break;
        case 9:                  // Advantech PCL-1800;
            dout_low=BASE+3;
            dout_high=BASE+11;
            break;
        case 10:                 // Advantech PCL-726;
            dout_low=BASE+13;
            dout_high=BASE+12;
            break;
        case 11:                 // Advantech PCL-727;
            dout_low=BASE+25;
            dout_high=BASE+24;
            break;
	}

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
    uint_T pcl818DOPortData = 0;
    uint_T val;
    
    /* Send Input to Digital Output */	
    pcl818DOPortData = 0;

    for (i=0;i < mxGetNumberOfElements(CHANNEL_ARG);i++) {
        uPtrs = ssGetInputPortRealSignalPtrs(S,i);
        if (*uPtrs[0]>=THRESHOLD) {
            pcl818DOPortData |= (1 << (((short)mxGetPr(CHANNEL_ARG)[i])-1));
        }
    } 

    rl32eOutpB(dout_low,pcl818DOPortData);
    rl32eOutpB(dout_high,pcl818DOPortData>>8);

#endif /* METLAB_MAE_FILE */
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
