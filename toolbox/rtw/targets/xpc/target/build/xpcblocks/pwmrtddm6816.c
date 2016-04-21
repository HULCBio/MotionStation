/* $Revision: 1.1 $ */
// pwmrtddm6816.c - xPC Target, non-inlined S-function driver for
// the PWM section of the Real Time Devices DM6816  
// Copyright 2002 The MathWorks, Inc.

#define     S_FUNCTION_LEVEL  2
#undef      S_FUNCTION_NAME
#define     S_FUNCTION_NAME   pwmrtddm6816

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

#define NUM_ARGS            (5)
#define CHANNEL_ARG         ssGetSFcnParam(S,0) // vector of [1-9]
#define CLOCK_SOURCE_ARG    ssGetSFcnParam(S,1) // vector[3] of clock_T
#define FREQ_DIVISOR_ARG    ssGetSFcnParam(S,2) // vector[3] of [2-65535]
#define SAMP_TIME_ARG       ssGetSFcnParam(S,3) // double
#define BASE_ARG            ssGetSFcnParam(S,4) // base address

#define SAMP_TIME_IND       (0)
#define NUM_I_WORKS         (0)
#define NUM_R_WORKS         (0)

#define PWM_0_0_DUTY_CYCLE  (0) // write register offsets
#define PWM_0_1_DUTY_CYCLE  (1)
#define PWM_0_2_DUTY_CYCLE  (2)
#define PWM_0_CONTROL       (3)
#define PWM_1_0_DUTY_CYCLE  (4)
#define PWM_1_1_DUTY_CYCLE  (5)
#define PWM_1_2_DUTY_CYCLE  (6)
#define PWM_1_CONTROL       (7)
#define PWM_2_0_DUTY_CYCLE  (8)
#define PWM_2_1_DUTY_CYCLE  (9)
#define PWM_2_2_DUTY_CYCLE  (10)
#define PWM_2_CONTROL       (11)
#define TC_COUNTER_0        (12)
#define TC_COUNTER_1        (13)
#define TC_COUNTER_2        (14)
#define TC_CONTROL          (15)

static dutyCycleRegister[9] = {
    PWM_0_0_DUTY_CYCLE,  
    PWM_0_1_DUTY_CYCLE,  
    PWM_0_2_DUTY_CYCLE,  
    PWM_1_0_DUTY_CYCLE, 
    PWM_1_1_DUTY_CYCLE,  
    PWM_1_2_DUTY_CYCLE, 
    PWM_2_0_DUTY_CYCLE, 
    PWM_2_1_DUTY_CYCLE, 
    PWM_2_2_DUTY_CYCLE
};

typedef enum { 
    clock_from_8MHz = 1,
    clock_from_timer1 = 2
} clock_T;

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
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
        sprintf(msg,"%d input args expected, %d passed", 
            ssGetNumSFcnParams(S), ssGetSFcnParamsCount(S));
        ssSetErrorStatus(S, msg);
        return;
    }

    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 0);

    ssSetNumInputPorts(S, nChans);
    for (i = 0; i < nChans; i++) {
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
    int_T base      = mxGetPr(BASE_ARG)[0];
    int_T nChans    = mxGetN(CHANNEL_ARG);
    int_T timCmd[3] = {0x34, 0x74, 0xb4};
    int_T pwmCmd[3] = {0x00, 0x00, 0x00};

    int_T i, chan, chip, source, divisor;

    // disable output for each PWM chip
    rl32eOutpB(base + PWM_0_CONTROL, 0);
    rl32eOutpB(base + PWM_1_CONTROL, 0);
    rl32eOutpB(base + PWM_2_CONTROL, 0);

    // set timers to binary, read/load LSB-then-MSB, mode 2 (rate generator)
    rl32eOutpB(base + TC_CONTROL, timCmd[0]);
    rl32eOutpB(base + TC_CONTROL, timCmd[1]);
    rl32eOutpB(base + TC_CONTROL, timCmd[2]);


    // load frequency divisors (counters) for each timer
    for( i = 0 ; i < 3 ; i++ ) {
        divisor = mxGetPr(FREQ_DIVISOR_ARG)[i];
        rl32eOutpB(base + TC_COUNTER_0 + i, divisor & 0xff); divisor >>= 8;
        rl32eOutpB(base + TC_COUNTER_0 + i, divisor & 0xff); 
    }


    // compute the control command for each PWM chip
    for( i = 0 ; i < nChans ; i++ ) {
        chan = mxGetPr(CHANNEL_ARG)[i] - 1;
        chip = chan / 3;
        source = mxGetPr(CLOCK_SOURCE_ARG)[chip] - 1;
        pwmCmd[chip] |= (1 << (chan % 3));  // chan enable
        pwmCmd[chip] |= (source << 3);      // set clock source
    }

    for( chan = 0; chan < 9; chan++ )
        rl32eOutpB(base + dutyCycleRegister[chan], 0);

    // initialize the PWM chips
    rl32eOutpB(base + PWM_0_CONTROL, pwmCmd[0]);
    rl32eOutpB(base + PWM_1_CONTROL, pwmCmd[1]);
    rl32eOutpB(base + PWM_2_CONTROL, pwmCmd[2]);
#endif
}

static void mdlOutputs(SimStruct *S, int_T tid)
{
#ifndef MATLAB_MEX_FILE
    int_T   base   = mxGetPr(BASE_ARG)[0];
    int_T   nChans = mxGetN(CHANNEL_ARG);
    real_T  input;
    uint8_T dutyCycle;

    InputRealPtrsType uPtrs;

    int_T   i, chan;

    for( i = 0 ; i < nChans ; i++ ) {
        chan = mxGetPr(CHANNEL_ARG)[i] - 1;
        uPtrs = ssGetInputPortRealSignalPtrs(S,i);
        input = *uPtrs[0];

        if (input < 0)
            dutyCycle = 0;
        else if (input > 255)
            dutyCycle = 255;
        else
            dutyCycle = (uint8_T)input;

        rl32eOutpB(base + dutyCycleRegister[chan], dutyCycle);
    }
#endif
}

static void mdlTerminate(SimStruct *S)
{   
#ifndef MATLAB_MEX_FILE
    int_T base = mxGetPr(BASE_ARG)[0];

    // disable output for each PWM chip
    rl32eOutpB(base + PWM_0_CONTROL, 0);
    rl32eOutpB(base + PWM_1_CONTROL, 0);
    rl32eOutpB(base + PWM_2_CONTROL, 0);
#endif
}

#ifdef MATLAB_MEX_FILE  /* Is this file being compiled as a MEX-file? */
#include "simulink.c"   /* Mex glue */
#else
#include "cg_sfun.h"    /* Code generation glue */
#endif
