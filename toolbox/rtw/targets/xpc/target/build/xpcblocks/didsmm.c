/* $Revision: 1.1 $ */
// didsmm.c - xPC Target, non-inlined S-function driver for 
// the digital input section of Diamond MM series boards

// Copyright 1996-2002 The MathWorks, Inc.


#define     S_FUNCTION_LEVEL    2
#undef      S_FUNCTION_NAME
#define     S_FUNCTION_NAME didsmm

#include    <stddef.h>
#include    <stdlib.h>
#include    <string.h>

#include    "tmwtypes.h"
#include    "simstruc.h" 

#ifdef MATLAB_MEX_FILE
#include    "mex.h"
#else
#include    <windows.h>
#include    "io_xpcimport.h"
#endif

#define     NUM_ARGS        (3)
#define     CHANNEL_ARG     ssGetSFcnParam(S,0)
#define     SAMP_TIME_ARG   ssGetSFcnParam(S,1)
#define     BASE_ARG        ssGetSFcnParam(S,2)

#define     DIGITAL_IO      (3)   // register offset

#define     NUM_I_WORKS     (0)
#define     NUM_R_WORKS     (0)

static char_T msg[256];

static void mdlInitializeSizes(SimStruct *S)
{
    int_T nChans = mxGetN(CHANNEL_ARG);
    int_T i;

#ifndef MATLAB_MEX_FILE
#include "io_xpcimport.c"
#endif

    ssSetNumSFcnParams(S, NUM_ARGS);
    if (NUM_ARGS != ssGetSFcnParamsCount(S)) {
        sprintf(msg, "%d input args expected, %d passed", 
            NUM_ARGS, ssGetSFcnParamsCount(S));
        ssSetErrorStatus(S, msg);
        return;
    }

    ssSetNumContStates(S,0);
    ssSetNumDiscStates(S,0);
    ssSetNumInputPorts(S,0);

    ssSetNumOutputPorts(S, nChans);
    for (i = 0; i < nChans; i++) {
        ssSetOutputPortWidth(S, i, 1);
    }

    ssSetNumSampleTimes(S, 1);
    ssSetNumRWork(S, NUM_R_WORKS);
    ssSetNumIWork(S, NUM_I_WORKS);
    ssSetNumPWork(S, 0);
    ssSetNumModes(S, 0);
    ssSetNumNonsampledZCs(S, 0);

    for (i = 0; i < NUM_ARGS; i++)
        ssSetSFcnParamTunable(S, i, 0);

    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE | SS_OPTION_PLACE_ASAP);
}
 
static void mdlInitializeSampleTimes(SimStruct *S)
{    
    if (mxGetPr(SAMP_TIME_ARG)[0] == -1.0) {
        ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
        ssSetOffsetTime(S, 0, FIXED_IN_MINOR_STEP_OFFSET);
    } else {
        ssSetSampleTime(S, 0, mxGetPr(SAMP_TIME_ARG)[0]);
        ssSetOffsetTime(S, 0, 0.0);
    }
} 

static void mdlOutputs(SimStruct *S, int_T tid)
{
#ifndef MATLAB_MEX_FILE
    int_T nChans = mxGetN(CHANNEL_ARG);
    int_T base   = mxGetPr(BASE_ARG)[0]; 
    int_T bit[8] = {1, 2, 4, 8, 16, 32, 64, 128};

    int_T   i, chan, value;
    real_T *y;

    value = (int_T) rl32eInpB(base + DIGITAL_IO);

    for (i = 0; i < nChans; i++) {
        chan = mxGetPr(CHANNEL_ARG)[i] - 1;
        y = ssGetOutputPortSignal(S, chan);
        y[0] = (value & bit[chan]) ? 1.0 : 0.0;
    }
#endif        
}

static void mdlTerminate(SimStruct *S)
{
}

#ifdef  MATLAB_MEX_FILE
#include "simulink.c"   // MEX-file interface mechanism
#else
#include "cg_sfun.h"    // Code generation registration function
#endif

