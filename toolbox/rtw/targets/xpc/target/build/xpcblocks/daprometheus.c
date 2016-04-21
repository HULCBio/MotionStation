/* $Revision: 1.1.6.1 $ */
// daprometheus.c - xPC Target, non-inlined S-function driver for
// D/A section of Diamond Systems Prometheus board  
// Copyright 1996-2002 The MathWorks, Inc.

#define     S_FUNCTION_LEVEL    2
#undef      S_FUNCTION_NAME
#define     S_FUNCTION_NAME     daprometheus

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
#define NUM_ARGS               (7)
#define CHANNEL_ARG            ssGetSFcnParam(S,0) // vector of 1:4
#define RANGE_ARG              ssGetSFcnParam(S,1) // 1: -10 to 10V; 2: 0 to 10V
#define RESET_ARG              ssGetSFcnParam(S,2) // vector of boolean
#define INIT_VAL_ARG           ssGetSFcnParam(S,3) // vector of double
#define SAMPLE_TIME_ARG        ssGetSFcnParam(S,4) // double
#define BASE_ARG               ssGetSFcnParam(S,5) // double
#define SHOW_STATUS_ARG        ssGetSFcnParam(S,6) // boolean

// write register byte offsets
#define DA_LSB                 (6)
#define DA_MSB                 (7)

// read register byte offsets
#define STATUS                 (3)
#define UPDATE_DAC             (4)

// status register bits         
#define STS                    (0x80)
#define DACBSY                 (0x10)

#define MAX_CHAN               (4)

#define NUM_I_WORKS            (1)
#define MAX_LOOPS_I_IND        (0)

#define NUM_R_WORKS            (2)
#define GAIN_R_IND             (0)
#define OFFSET_R_IND           (1)

#define RESOLUTION             (4096)
#define MAX_COUNT              (RESOLUTION - 1)
#define SECS_PER_CHAN          (0.000030) // time for D/A to go idle

static char_T msg[256];

static void mdlInitializeSizes(SimStruct *S)
{
    int_T   showStatus = mxGetPr(SHOW_STATUS_ARG)[0];
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

    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 0);

    if (showStatus) {
        ssSetNumOutputPorts(S, 1);
        ssSetOutputPortWidth(S, 0, 1);
    }

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
    int_T  *IWork      = ssGetIWork(S);
    real_T *RWork      = ssGetRWork(S);
    int_T   base       = mxGetPr(BASE_ARG)[0]; 
    int_T   numChans   = mxGetN(CHANNEL_ARG);
    int_T   iterations = 1000;

    real_T  start, loopsPerSec;
    int_T   i, loop, range, maxLoops;

    // estimate max number of loops for D/A to go idle

    start = rl32eGetTicksDouble();

    for (i = 0; i < iterations; i++)
        rl32eInpB(base + STATUS);

    loopsPerSec = iterations / rl32eETimeDouble(rl32eGetTicksDouble(), start);

    maxLoops = (int_T) (2.0 * SECS_PER_CHAN * loopsPerSec);

    IWork[MAX_LOOPS_I_IND] = maxLoops;

    for (loop = 0; loop < maxLoops; loop++)
        if (~(rl32eInpB(base + STATUS) & DACBSY))
            break;      

    if (loop >= maxLoops) {
        sprintf(msg, "Diamond Prometheus board at base %03x does not respond", base);
        ssSetErrorStatus(S, msg);
        return;
    }

    range = mxGetPr(RANGE_ARG)[0];

    switch (range) {
        case 1: // -10V to 10V
            RWork[GAIN_R_IND]   = RESOLUTION / 20.0;
            RWork[OFFSET_R_IND] = RESOLUTION / 2;
            break;

        case 2: // 0 to 10V
            RWork[GAIN_R_IND] = RESOLUTION / 10.0;
            RWork[OFFSET_R_IND] = 0.0;
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
    int_T  *IWork      = ssGetIWork(S);
    real_T *RWork      = ssGetRWork(S);
    real_T  gain       = RWork[GAIN_R_IND];
    real_T  offset     = RWork[OFFSET_R_IND];
    int_T   maxLoops   = IWork[MAX_LOOPS_I_IND];
    int_T   numChans   = mxGetN(CHANNEL_ARG);
    int_T   base       = mxGetPr(BASE_ARG)[0];
    int_T   showStatus = mxGetPr(SHOW_STATUS_ARG)[0];
    int_T   status     = 0;

    InputRealPtrsType uPtrs;
    int_T   i, loop, chan, count;
    real_T  *y, volts;

    for (i = 0; i < numChans; i++) {

        chan = mxGetPr(CHANNEL_ARG)[i] - 1;

        uPtrs = ssGetInputPortRealSignalPtrs(S, i);

        volts = *uPtrs[0];

        count = volts * gain + offset;

        if (count < 0) count = 0;
        if (count > MAX_COUNT) count = MAX_COUNT;

        // wait for DAC to go idle
        for (loop = 0; loop < maxLoops; loop++)
            if (~(rl32eInpB(base + STATUS) & DACBSY))
                break;

        if (loop >= maxLoops)
          status = status | (1 << chan);

        else {
            rl32eOutpB(base + DA_LSB, count & 0xff);
            rl32eOutpB(base + DA_MSB, (count >> 8) & 0xf | chan << 6);
        }
    }

    if (showStatus) {
       y = ssGetOutputPortRealSignal(S, 0);
       y[0] = (real_T) status;
    }
#endif
}


static void mdlTerminate(SimStruct *S)
{   
#ifndef MATLAB_MEX_FILE
    int_T  *IWork    = ssGetIWork(S);
    real_T *RWork    = ssGetRWork(S);
    real_T  gain     = RWork[GAIN_R_IND];
    real_T  offset   = RWork[OFFSET_R_IND];
    int_T   maxLoops = IWork[MAX_LOOPS_I_IND];
    int_T   base     = mxGetPr(BASE_ARG)[0];
    int_T   numChans = mxGetN(CHANNEL_ARG);

    int_T   i, loop, chan, count;
    real_T  volts;

    for (i = 0; i < numChans; i++) {

        if (xpceIsModelInit() || (uint_T)mxGetPr(RESET_ARG)[i]) {

            chan = mxGetPr(CHANNEL_ARG)[i] - 1;

            volts = mxGetPr(INIT_VAL_ARG)[i];

            count = volts * gain + offset;

            if (count < 0) count = 0;
            if (count > MAX_COUNT) count = MAX_COUNT;

            // wait for DAC to go idle
            for (loop = 0; loop < maxLoops; loop++)
                if (~(rl32eInpB(base + STATUS) & DACBSY))
                    break;

            if (loop < maxLoops) {
                rl32eOutpB(base + DA_LSB, count & 0xff);
                rl32eOutpB(base + DA_MSB, (count >> 8) & 0xf | chan << 6);
            }
        }
    }
#endif
}


#ifdef MATLAB_MEX_FILE  
#include "simulink.c"   // Mex glue
#else
#include "cg_sfun.h"    // Code generation glue
#endif
