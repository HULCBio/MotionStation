/* $Revision: 1.1 $ */
// dodsmm.c - xPC Target, non-inlined S-function driver for
// the digital output section of Diamond MM boards  

// Copyright 1996-2002 The MathWorks, Inc.


#define     S_FUNCTION_LEVEL    2
#undef      S_FUNCTION_NAME
#define     S_FUNCTION_NAME     dodsmm

#include    <stddef.h>
#include    <stdlib.h>

#include    "simstruc.h" 

#ifdef      MATLAB_MEX_FILE
#include    "mex.h"
#endif

#ifndef     MATLAB_MEX_FILE
#include    <windows.h>
#include    "io_xpcimport.h"
#include    "util_xpcimport.h"
#endif


// input arguments
#define NUM_ARGS        (5)
#define CHANNEL_ARG     ssGetSFcnParam(S,0) // vector of 1:8
#define RESET_ARG       ssGetSFcnParam(S,1) // vector of boolean
#define INIT_VAL_ARG    ssGetSFcnParam(S,2) // vector of double
#define SAMP_TIME_ARG   ssGetSFcnParam(S,3) // double
#define BASE_ARG        ssGetSFcnParam(S,4) // integer

#define DIGITAL_IO      (3)    // register offsets

#define NUM_R_WORKS     (0)
#define NUM_I_WORKS     (1)
#define VALUE_I_IND     (0)
#define THRESHOLD       (0.5)

static char_T msg[256];

static void mdlInitializeSizes(SimStruct *S)
{
    int_T nChans = mxGetN(CHANNEL_ARG);
    int_T i;

#ifndef MATLAB_MEX_FILE
#include "io_xpcimport.c"
#include "util_xpcimport.c"
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

    ssSetNumInputPorts(S, nChans);
    for (i = 0; i < nChans; i++) {
        ssSetInputPortWidth(S, i, 1);
    }

    ssSetNumOutputPorts(S,0);
    ssSetNumSampleTimes(S,1);
    ssSetNumRWork(S, NUM_R_WORKS);
    ssSetNumIWork(S, NUM_I_WORKS);
    ssSetNumPWork(S, 0);
    ssSetNumModes(S, 0);
    ssSetNumNonsampledZCs(S,0);

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
 

#define MDL_START
static void mdlStart(SimStruct *S)
{
}

static void mdlOutputs(SimStruct *S, int_T tid)
{
#ifndef MATLAB_MEX_FILE
    int_T *IWork  = ssGetIWork(S);
    int_T  nChans = mxGetN(CHANNEL_ARG);
    int_T  base   = mxGetPr(BASE_ARG)[0]; 
    int_T  bit[8] = {1, 2, 4, 8, 16, 32, 64, 128};

    int_T  i, chan, value;

    InputRealPtrsType uPtrs;
   
    value = 0;

    for (i = 0; i < nChans; i++) {
        chan = mxGetPr(CHANNEL_ARG)[i] - 1;
        uPtrs = ssGetInputPortRealSignalPtrs(S, i);
        if (*uPtrs[0] >= THRESHOLD)
            value |= bit[chan];  
    }

    // write digital output
    rl32eOutpB(base + DIGITAL_IO, value);
    IWork[VALUE_I_IND] = value;

#endif
}

static void mdlTerminate(SimStruct *S)
{   
#ifndef MATLAB_MEX_FILE
    int_T *IWork  = ssGetIWork(S);
    int_T  value  = IWork[VALUE_I_IND];
    int_T  nChans = mxGetN(CHANNEL_ARG);
    int_T  base   = mxGetPr(BASE_ARG)[0]; 
    int_T  bit[8] = {1, 2, 4, 8, 16, 32, 64, 128};

    int_T  i, chan;

    // At load time, set channels to their initial values.
    // At model termination, reset resettable channels to their initial values.

    for (i = 0; i < nChans; i++) {
        if (xpceIsModelInit() || (uint_T)mxGetPr(RESET_ARG)[i]) {
            chan = mxGetPr(CHANNEL_ARG)[i] - 1;
            if ((uint_T)mxGetPr(INIT_VAL_ARG)[i]) {
                value |= bit[chan];  
            }
        }
    }

    // write digital output
    rl32eOutpB(base + DIGITAL_IO, value);
#endif
}


#ifdef MATLAB_MEX_FILE  // Is this file being compiled as a MEX-file? 
#include "simulink.c"   // Mex glue 
#else
#include "cg_sfun.h"    // Code generation glue 
#endif
