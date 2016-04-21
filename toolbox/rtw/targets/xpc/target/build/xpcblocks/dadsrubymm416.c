/* $Revision: 1.1 $ */
// dadsrubymm416.c - xPC Target, non-inlined S-function driver for 
// analog output section of the Diamond Systems Ruby-MM-416 D/A 
// Copyright 2002 The MathWorks, Inc.

#define     S_FUNCTION_LEVEL  2
#undef      S_FUNCTION_NAME
#define     S_FUNCTION_NAME   dadsrubymm416

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

#define NUM_ARGS          (6)
#define CHANNEL_ARG       ssGetSFcnParam(S,0) // vector of {1, 2, 3, 4}
#define RANGE_ARG         ssGetSFcnParam(S,1) // vector of {-5, -10, 10}
#define RESET_ARG         ssGetSFcnParam(S,2) // vector of boolean
#define INIT_VAL_ARG      ssGetSFcnParam(S,3) // vector of double
#define SAMP_TIME_ARG     ssGetSFcnParam(S,4) // double
#define BASE_ARG          ssGetSFcnParam(S,5) // 0x100 .. 0x3C0

#define SAMP_TIME_IND     (0)

#define NUM_I_WORKS       (0)

#define NUM_R_WORKS       (8)
#define GAIN_R_IND        (0)
#define OFFSET_R_IND      (4)

#define RESOLUTION        (65536)
#define MIN_CODE          (-32768)
#define MAX_CODE          (32767)

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
        sprintf(msg,"%d input args expected, %d passed", NUM_ARGS, ssGetSFcnParamsCount(S));
        ssSetErrorStatus(S,msg);
        return;
    }

    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 0);

    ssSetNumInputPorts(S, mxGetN(CHANNEL_ARG));
    for (i=0; i<mxGetN(CHANNEL_ARG); i++)
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
    real_T *RWork  = ssGetRWork(S);
    int_T   nChans = (int_T)mxGetN(CHANNEL_ARG);
    int_T   i;

    for( i = 0 ; i < nChans ; i++ ) {
        switch ((int_T)mxGetPr(RANGE_ARG)[i]) {
            case -5: // -5V to 5V
                RWork[GAIN_R_IND + i]   = RESOLUTION / 10.0;
                RWork[OFFSET_R_IND + i] = 0.0;
                break;
            case -10: // -10V to 10V
                RWork[GAIN_R_IND + i]   = RESOLUTION / 20.0;
                RWork[OFFSET_R_IND + i] = 0.0;
                break;
            case 10: // 0V to 10V
                RWork[GAIN_R_IND + i]   = RESOLUTION / 10.0;
                RWork[OFFSET_R_IND + i] = -5.0;
                break;
        }
    }
#endif
}

static void mdlOutputs(SimStruct *S, int_T tid)
{
#ifndef MATLAB_MEX_FILE
    int_T   base     = (int_T)mxGetPr(BASE_ARG)[0];
    int_T   nChans   = (int_T)mxGetN(CHANNEL_ARG);
    real_T *RWork    = ssGetRWork(S);

    InputRealPtrsType uPtrs;

    int_T   i, count, channel;
    real_T  voltage, gain, offset, temp;

    for( i = 0 ; i < nChans ; i++ ) {
        channel = (int_T)mxGetPr(CHANNEL_ARG)[i] - 1;
        uPtrs = ssGetInputPortRealSignalPtrs(S,i);

        voltage = *uPtrs[0];
        temp = (voltage + RWork[OFFSET_R_IND + i]) * RWork[GAIN_R_IND + i];

        if (temp > MAX_CODE)
            count = MAX_CODE;
        else if (temp < MIN_CODE)
            count = MIN_CODE;
        else
            count = temp;

        rl32eOutpW(base + 2 * channel, count);
    }

    rl32eInpB(base);  // update all channels
#endif
        
}

static void mdlTerminate(SimStruct *S)
{   

#ifndef MATLAB_MEX_FILE
    int_T   base     = (int_T)mxGetPr(BASE_ARG)[0];
    int_T   nChans   = (int_T)mxGetN(CHANNEL_ARG);
    real_T *RWork    = ssGetRWork(S);

    int_T   i, count, channel;
    real_T  voltage, gain, offset, temp;

    // At load time, set channel to its initial value.
    // At termination, set channel to its initial value if reset requested.

    for( i = 0 ; i < nChans ; i++ ) {
        if (xpceIsModelInit() || (uint_T)mxGetPr(RESET_ARG)[i]) {
            channel = (int_T)mxGetPr(CHANNEL_ARG)[i] - 1;
            voltage = (real_T)mxGetPr(INIT_VAL_ARG)[i];
            temp = (voltage + RWork[OFFSET_R_IND + i]) * RWork[GAIN_R_IND + i];

            if (temp > MAX_CODE)
                count = MAX_CODE;
            else if (temp < MIN_CODE)
                count = MIN_CODE;
            else
                count = temp;

            rl32eOutpW(base + 2 * channel, count);
        }
    }

    rl32eInpB(base);  // update all channels

#endif

}

#ifdef MATLAB_MEX_FILE  /* Is this file being compiled as a MEX-file? */
#include "simulink.c"   /* Mex glue */
#else
#include "cg_sfun.h"    /* Code generation glue */
#endif
