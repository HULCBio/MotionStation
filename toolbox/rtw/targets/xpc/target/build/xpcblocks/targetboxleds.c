/* $Revision: 1.1 $ */
// targetboxleds.c - xPC Target, non-inlined S-function driver for 
// the MPL TargetBox User LEDs  
// Copyright 2000-2002 The MathWorks, Inc.

#define     S_FUNCTION_LEVEL  2
#undef      S_FUNCTION_NAME
#define     S_FUNCTION_NAME   targetboxleds

#include    <stddef.h>
#include    <stdlib.h>

#include    "simstruc.h"

#ifdef  MATLAB_MEX_FILE
#include    "mex.h"
#endif

#ifndef MATLAB_MEX_FILE
#include    <windows.h>
#include    "io_xpcimport.h"
#include    "util_xpcimport.h"
#endif

#define NUM_ARGS         (4)
#define LEDS_ARG         ssGetSFcnParam(S,0) // vector of 1-2
#define RESET_ARG        ssGetSFcnParam(S,1) // vector of boolean
#define INIT_VAL_ARG     ssGetSFcnParam(S,2) // vector of double
#define SAMP_TIME_ARG    ssGetSFcnParam(S,3) // double

#define SAMP_TIME_IND    (0)
#define NUM_I_WORKS      (0)
#define NUM_R_WORKS      (0)
#define THRESHOLD        (0.5)

#define MPL_LED_CONTROL_REGISTER (0x0809)

static char_T msg[256];

static void mdlInitializeSizes(SimStruct *S)
{
    uint32_T i;

#ifndef MATLAB_MEX_FILE
#include "io_xpcimport.c"
#include "util_xpcimport.c"
#endif

    ssSetNumSFcnParams(S, NUM_ARGS);
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
        sprintf(msg,"%d arguments passed - %d expected\n",
            ssGetSFcnParamsCount(S), ssGetNumSFcnParams(S));
        ssSetErrorStatus(S,msg);
        return;
    }


    ssSetNumInputPorts(S, mxGetN(LEDS_ARG));
    for (i = 0; i < mxGetN(LEDS_ARG); i++) {
        ssSetInputPortWidth(S, i, 1);
        ssSetInputPortDirectFeedThrough(S, i, 1);
    }

    ssSetNumOutputPorts(S, 0);
    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 0);
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
    ssSetSampleTime(S, 0, mxGetPr(SAMP_TIME_ARG)[SAMP_TIME_IND]);
    ssSetOffsetTime(S, 0, 0.0);
}

#define MDL_START
static void mdlStart(SimStruct *S)
{
#ifndef MATLAB_MEX_FILE
#endif
}

static void mdlOutputs(SimStruct *S, int_T tid)
{
#ifndef MATLAB_MEX_FILE
    int_T     i;
    uint8_T   bit, value;
    uint32_T *iPtr;

    InputRealPtrsType uPtrs;

    value = 0;

    for (i = 0; i < mxGetN(LEDS_ARG); i++) {
        uPtrs = ssGetInputPortRealSignalPtrs(S, i);
        bit = 1 << ((int_T)mxGetPr(LEDS_ARG)[i] - 1);
        if (*uPtrs[0] < THRESHOLD)
            value &= ~bit; 
        else
            value |= bit;
    }
 
    rl32eOutpB(MPL_LED_CONTROL_REGISTER, value);
#endif
}


static void mdlTerminate(SimStruct *S)
{
#ifndef MATLAB_MEX_FILE
    int_T     i;
    uint32_T  bit, value;

    // At load time, set LEDs to their initial values.
    // At model termination, reset resettable LEDs to their initial values.

    value = rl32eInpB(MPL_LED_CONTROL_REGISTER);

    for (i = 0; i < mxGetN(LEDS_ARG); i++) {
        if (xpceIsModelInit() || (uint_T)mxGetPr(RESET_ARG)[i]) {
            bit = 1 << ((int_T)mxGetPr(LEDS_ARG)[i] - 1);
            if ((uint_T)mxGetPr(INIT_VAL_ARG)[i] == 0)
                value &= ~bit; 
            else
                value |= bit;
        }
    }

    rl32eOutpB(MPL_LED_CONTROL_REGISTER, value);
#endif
}

#ifdef MATLAB_MEX_FILE  /* Is this file being compiled as a MEX-file? */
#include "simulink.c"   /* Mex glue */
#else
#include "cg_sfun.h"    /* Code generation glue */
#endif
