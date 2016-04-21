// dartddm6430.c - xPC Target, non-inlined S-function driver for
// analog output section of the Real Time Devices DM6430 D/A 
// Copyright 1999-2002 The MathWorks, Inc.

#define     S_FUNCTION_LEVEL  2
#undef      S_FUNCTION_NAME
#define     S_FUNCTION_NAME   dartddm6430

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

#define NUM_ARGS         (5)
#define CHANNEL_ARG      ssGetSFcnParam(S,0) // vector of {1 .. 2}
#define RESET_ARG        ssGetSFcnParam(S,1) // vector of boolean
#define INIT_VAL_ARG     ssGetSFcnParam(S,2) // vector of double
#define SAMP_TIME_ARG    ssGetSFcnParam(S,3) // double
#define BASE_ARG         ssGetSFcnParam(S,4) // ISA base address

#define SAMP_TIME_IND    (0)
#define NUM_I_WORKS      (0)
#define NUM_R_WORKS      (0)

#define RESOLUTION       (65536)
#define MIN_COUNT        (-RESOLUTION / 2)
#define MAX_COUNT        (RESOLUTION / 2 - 1)
#define VOLTAGE_TO_COUNT (RESOLUTION / 20.0)

#define LOAD_DA_CONVERTER_1_DATA  (12) // Output register offsets
#define LOAD_DA_CONVERTER_2_DATA  (14) 

static char_T msg[256];

static void mdlInitializeSizes(SimStruct *S)
{
    int i;

#ifndef MATLAB_MEX_FILE
#include "io_xpcimport.c"
#include "util_xpcimport.c"
#endif

    ssSetNumSFcnParams(S, NUM_ARGS);
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
        sprintf(msg,"%d input args expected, %d passed", 
            NUM_ARGS, ssGetSFcnParamsCount(S));
        ssSetErrorStatus(S,msg);
        return;
    }

    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 0);

    ssSetNumInputPorts(S, mxGetN(CHANNEL_ARG));
    for (i = 0; i < mxGetN(CHANNEL_ARG); i++)
    {
        ssSetInputPortWidth(S, i, 1);
        ssSetInputPortDirectFeedThrough(S, i, 1);
    }

    ssSetNumOutputPorts(S, 0);
    ssSetNumSampleTimes(S, 1);
    ssSetNumRWork(S, NUM_R_WORKS);
    ssSetNumIWork(S, NUM_I_WORKS);
    ssSetNumPWork(S, 0);
    ssSetNumModes(S, 0);
    ssSetNumNonsampledZCs(S, 0);

    for( i = 0 ; i < NUM_ARGS ; i++ ) {
        ssSetSFcnParamTunable(S,i,0); 
    }

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
#ifndef MATLAB_MEX_FILE
#endif
}

static void mdlOutputs(SimStruct *S, int_T tid)
{
#ifndef MATLAB_MEX_FILE
    int_T   base   = (int_T)mxGetPr(BASE_ARG)[0];
    int_T   nChans = (int_T)mxGetN(CHANNEL_ARG);

    InputRealPtrsType uPtrs;

    int_T   i, channel;
    real_T  voltage, count;

    for( i = 0 ; i < nChans ; i++ ) {
        channel = mxGetPr(CHANNEL_ARG)[i];
        uPtrs = ssGetInputPortRealSignalPtrs(S,i);

        voltage = *uPtrs[0];
        count = voltage * VOLTAGE_TO_COUNT;

        if (count < MIN_COUNT)
            count = MIN_COUNT;
        if (count > MAX_COUNT)
            count = MAX_COUNT;

        switch (channel) {
            case 1: rl32eOutpW(base + LOAD_DA_CONVERTER_1_DATA, (int16_T)count); break;
            case 2: rl32eOutpW(base + LOAD_DA_CONVERTER_2_DATA, (int16_T)count); break;
        }
    }
#endif
        
}

static void mdlTerminate(SimStruct *S)
{   

#ifndef MATLAB_MEX_FILE
    int_T   base   = (int_T)mxGetPr(BASE_ARG)[0];
    int_T   nChans = (int_T)mxGetN(CHANNEL_ARG);

    int_T   i, channel;
    real_T  voltage, count;

    // At load time, set channel to its initial value.
    // At termination, set channel to its initial value if reset requested.

    for( i = 0 ; i < nChans ; i++ ) {
        if (xpceIsModelInit() || (uint_T)mxGetPr(RESET_ARG)[i]) {
            channel = mxGetPr(CHANNEL_ARG)[i];
            voltage = (real_T)mxGetPr(INIT_VAL_ARG)[i];
            count = voltage * VOLTAGE_TO_COUNT;

            if (count < MIN_COUNT)
                count = MIN_COUNT;
            if (count > MAX_COUNT)
                count = MAX_COUNT;

            switch (channel) {
                case 1: rl32eOutpW(base + LOAD_DA_CONVERTER_1_DATA, (int16_T)count); break;
                case 2: rl32eOutpW(base + LOAD_DA_CONVERTER_2_DATA, (int16_T)count); break;
            }
        }
    }

#endif

}

#ifdef MATLAB_MEX_FILE  /* Is this file being compiled as a MEX-file? */
#include "simulink.c"   /* Mex glue */
#else
#include "cg_sfun.h"    /* Code generation glue */
#endif
