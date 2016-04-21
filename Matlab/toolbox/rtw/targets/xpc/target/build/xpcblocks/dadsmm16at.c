/* $Revision: 1.3.6.1 $ */
// dadsmm16at.c - xPC Target, non-inlined S-function driver for
// the analog output section of Diamond Systems MM-16-AT boards 
 
// Copyright 1996-2003 The MathWorks, Inc.


#define     S_FUNCTION_LEVEL    2
#undef      S_FUNCTION_NAME
#define     S_FUNCTION_NAME     dadsmm16at

#include    <stddef.h>
#include    <stdlib.h>

#include    "simstruc.h" 

#ifdef      MATLAB_MEX_FILE
#include    "mex.h"
#endif

#ifndef     MATLAB_MEX_FILE
#include    <math.h>
#include    <windows.h>
#include    "io_xpcimport.h"
#include    "time_xpcimport.h" 
#include    "util_xpcimport.h" 
#endif

// input arguments
#define NUM_ARGS               (6)
#define CHANNEL_ARG            ssGetSFcnParam(S,0) // vector of 1:4
#define RANGE_ARG              ssGetSFcnParam(S,1) // 1: 0 to 5; 2: -5 to 5
#define RESET_ARG              ssGetSFcnParam(S,2) // vector of boolean
#define INIT_VAL_ARG           ssGetSFcnParam(S,3) // vector of double
#define SAMPLE_TIME_ARG        ssGetSFcnParam(S,4) // double
#define BASE_ARG               ssGetSFcnParam(S,5) // double

// write register byte offsets
#define DAC_LSB                (1)
#define DAC_0_MSB              (4)

// read register byte offsets
#define STATUS_REGISTER        (8)

// status register bits         
#define STS                    (0x80)

#define MAX_CHAN               (4)

#define NUM_I_WORKS            (0)

#define NUM_R_WORKS            (2)
#define GAIN_R_IND             (0)
#define OFFSET_R_IND           (1)

#define RESOLUTION             (4096)
#define MAX_COUNT              (RESOLUTION - 1)

static char_T msg[256];

static void mdlInitializeSizes(SimStruct *S)
{
    int_T i, numChans;

#ifndef MATLAB_MEX_FILE
#include "io_xpcimport.c"
#include "time_xpcimport.c"
#include "util_xpcimport.c" 
#endif

    ssSetNumSFcnParams(S, NUM_ARGS);
    if (NUM_ARGS != ssGetSFcnParamsCount(S)) {
        sprintf(msg, "%d input args expected, %d passed", 
            NUM_ARGS, ssGetSFcnParamsCount(S));
        ssSetErrorStatus(S, msg);
        return;
    }

    numChans = mxGetN(CHANNEL_ARG);
    if (numChans > MAX_CHAN) {
        sprintf(msg, "%d channels passed, but max number is %d", 
            numChans, MAX_CHAN);
        ssSetErrorStatus(S, msg);
        return;
    }

    ssSetNumContStates(S,0);
    ssSetNumDiscStates(S,0);
    ssSetNumOutputPorts(S,0);

    ssSetNumInputPorts(S, numChans);
    for (i = 0; i < numChans; i++) {
        ssSetInputPortWidth(S, i, 1);
        ssSetInputPortDirectFeedThrough(S, i, 1);
    }

    ssSetNumSampleTimes(S, 1);
    ssSetNumIWork(S, NUM_I_WORKS);
    ssSetNumRWork(S, NUM_R_WORKS);
    ssSetNumPWork(S, 0);
    ssSetNumModes(S, 0);
    ssSetNumNonsampledZCs(S, 0);

    for (i = 0; i < NUM_ARGS; i++)
        ssSetSFcnParamTunable(S, i, 0);

    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE | SS_OPTION_PLACE_ASAP);
}

 
static void mdlInitializeSampleTimes(SimStruct *S)
{
    if (mxGetPr(SAMPLE_TIME_ARG)[0] == -1.0) {
        ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
        ssSetOffsetTime(S, 0, FIXED_IN_MINOR_STEP_OFFSET);
    } else {
        ssSetSampleTime(S, 0, mxGetPr(SAMPLE_TIME_ARG)[0]);
        ssSetOffsetTime(S, 0, 0.0);
    }
}
 

#define MDL_START
static void mdlStart(SimStruct *S)
{
#ifndef MATLAB_MEX_FILE
    real_T *RWork    = ssGetRWork(S);
    int_T   base     = mxGetPr(BASE_ARG)[0]; 
    int_T   range    = mxGetPr(RANGE_ARG)[0]; 
    int_T   numChans = mxGetN(CHANNEL_ARG);
    int_T   max      = 1000000;

    int_T   i;

    // wait a second or so for A/D to idle
    for (i = 0; i < max; i++)
        if ((rl32eInpB(base + STATUS_REGISTER) & STS) == 0)
            break;

    if (i >= max) {
        sprintf(msg, "Diamond MM board at base %03x does not respond", base);
        ssSetErrorStatus(S, msg);
        return;
    }

    switch (range) {
    case 1: // 0 to 5V
        RWork[GAIN_R_IND]   = RESOLUTION / 5.0;
        RWork[OFFSET_R_IND] = 0;
        break;
    case 2: // -5V to 5V
        RWork[GAIN_R_IND]   = RESOLUTION / 10.0;
        RWork[OFFSET_R_IND] = RESOLUTION / 2;
        break;
    default: 
        sprintf(msg, "bad range code %d", range); 
        ssSetErrorStatus(S, msg);
        return;
    }
#endif
}


static void mdlOutputs(SimStruct *S, int_T tid)
{
#ifndef MATLAB_MEX_FILE
    real_T *RWork    = ssGetRWork(S);
    real_T  gain     = RWork[GAIN_R_IND];
    real_T  offset   = RWork[OFFSET_R_IND];
    int_T   base     = mxGetPr(BASE_ARG)[0];
    int_T   numChans = mxGetN(CHANNEL_ARG);

    InputRealPtrsType uPtrs;
    int_T   i, chan, count;
    real_T  value;

    for (i = 0; i < numChans; i++) {
        chan = mxGetPr(CHANNEL_ARG)[i] - 1;

        uPtrs = ssGetInputPortRealSignalPtrs(S, i);

        value = *uPtrs[0];

        count = value * gain + offset;

        if (count < 0) count = 0;
        if (count > MAX_COUNT) count = MAX_COUNT;

        rl32eOutpB(base + DAC_LSB, count & 0xff);
        rl32eOutpB(base + DAC_0_MSB + chan, (count >> 8) & 0xf);
    }
    
    rl32eInpB(base + DAC_0_MSB); // update all D/A channels

#endif
}


static void mdlTerminate(SimStruct *S)
{   
#ifndef MATLAB_MEX_FILE
    real_T *RWork    = ssGetRWork(S);
    real_T  gain     = RWork[GAIN_R_IND];
    real_T  offset   = RWork[OFFSET_R_IND];
    int_T   base     = mxGetPr(BASE_ARG)[0];
    int_T   numChans = mxGetN(CHANNEL_ARG);

    int_T   i, chan, count;
    real_T  value;

    for (i = 0; i < numChans; i++) {

        if (xpceIsModelInit() || (uint_T)mxGetPr(RESET_ARG)[i]) {

            chan = mxGetPr(CHANNEL_ARG)[i] - 1;

            value = mxGetPr(INIT_VAL_ARG)[i];

            count = value * gain + offset;

            if (count < 0) count = 0;
            if (count > MAX_COUNT) count = MAX_COUNT;

            rl32eOutpB(base + DAC_LSB, count & 0xff);
            rl32eOutpB(base + DAC_0_MSB + chan, (count >> 8) & 0xf);
        }
    }
    
    rl32eInpB(base + DAC_0_MSB); // update all D/A channels

#endif
}


#ifdef MATLAB_MEX_FILE  
#include "simulink.c"   // Mex glue
#else
#include "cg_sfun.h"    // Code generation glue
#endif
