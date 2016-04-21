// adprometheus.c - xPC Target, non-inlined S-function driver 
// for A/D section of Diamond Systems Prometheus   
// Copyright 1996-2002 The MathWorks, Inc.

// This driver uses SCAN mode, in which one trigger initiates conversion 
// for all the channels specified by the AD_CHANNEL register. SCAN mode 
// has the benefit that there is a fixed 10us skew between channels.
// It is however slower than single conversion mode - single conversion
// mode for 16 channels takes ~285us, whereas SCAN takes ~337us.

/* $Revision: 1.2.6.1 $ */

#define     S_FUNCTION_LEVEL    2
#undef      S_FUNCTION_NAME
#define     S_FUNCTION_NAME     adprometheus

#include    <stddef.h>
#include    <stdlib.h>

#include    "simstruc.h" 

#ifdef      MATLAB_MEX_FILE
#include    "mex.h"
#endif

#ifndef     MATLAB_MEX_FILE
#include    <windows.h>
#include    "io_xpcimport.h"
#include    "time_xpcimport.h" 
#endif


// input arguments
#define NUM_ARGS           (8)
#define FIRST_CHAN_ARG     ssGetSFcnParam(S,0)
#define NUM_CHANS_ARG      ssGetSFcnParam(S,1)
#define GAIN_ARG           ssGetSFcnParam(S,2)
#define OFFSET_ARG         ssGetSFcnParam(S,3)
#define CONTROL_ARG        ssGetSFcnParam(S,4)
#define SAMP_TIME_ARG      ssGetSFcnParam(S,5)
#define BASE_ARG           ssGetSFcnParam(S,6)
#define SHOW_STATUS_ARG    ssGetSFcnParam(S,7)

// write registers (byte offsets)
#define COMMAND            (0)
#define AD_CHANNEL         (2)
#define AD_GAIN_SCAN       (3)
#define INT_DMA_COUNTER    (4)
#define FIFO_THRESHOLD     (5)

// read registers (byte offsets)
#define AD_LSB             (0)
#define AD_MSB             (1)
#define STATUS             (3)

// COMMAND bits
#define STRTAD             (0x80) 
#define RSTFIFO            (0x10) 

// STATUS bits
#define STS                (0x80)
#define WAIT               (0x20)
#define SCANEN             (0x04)

#define MAX_CHAN           (16)
#define RESOLUTION         (4096)
#define SAMPLES_PER_SEC    (100000)
#define SECS_PER_CHAN      (1.0 / SAMPLES_PER_SEC)

#define NUM_I_WORKS        (3)
#define BASE_I_IND         (0)
#define MAX_LOOPS_I_IND    (1)
#define SHOW_STATUS_I_IND  (2)

#define NUM_R_WORKS        (2)
#define GAIN_R_IND         (0)
#define OFFSET_R_IND       (1)

static char_T msg[256];


static void waitToSettle(SimStruct *S, int_T base, int_T maxLoops)
{
#ifndef MATLAB_MEX_FILE
    int_T i;

    for (i = 0; i < maxLoops && (rl32eInpB(base + STATUS) & WAIT); i++);

    if (i >= maxLoops) {
        sprintf(msg, "Diamond Prometheus at base %03x does not respond\n", base);
        ssSetErrorStatus(S, msg);
        return;
    }
#endif
}

static void mdlInitializeSizes(SimStruct *S)
{
#ifndef MATLAB_MEX_FILE
#include "io_xpcimport.c"
#include "time_xpcimport.c"
#endif

#ifdef MATLAB_MEX_FILE
    int_T numChans    = mxGetPr(NUM_CHANS_ARG)[0];
    int_T showStatus  = mxGetPr(SHOW_STATUS_ARG)[0];
    int_T numOutPorts = showStatus ? numChans + 1 : numChans;

    uint_T i;


    ssSetNumSFcnParams(S, NUM_ARGS);
    if (NUM_ARGS != ssGetSFcnParamsCount(S)) {
        sprintf(msg, "%d input args expected, %d passed", 
            NUM_ARGS, ssGetSFcnParamsCount(S));
        ssSetErrorStatus(S, msg);
        return;
    }

    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 0);

    ssSetNumOutputPorts(S, numOutPorts);
    for (i = 0; i < numOutPorts; i++) 
        ssSetOutputPortWidth(S, i, 1);

    ssSetNumInputPorts(S, 0);
    ssSetNumSampleTimes(S,1);

    ssSetNumIWork(S, NUM_I_WORKS); 
    ssSetNumRWork(S, NUM_R_WORKS);

    ssSetNumPWork(S, 0);
    ssSetNumModes(S, 0);
    ssSetNumNonsampledZCs(S, 0);

    for (i = 0; i < NUM_ARGS; i++)
        ssSetSFcnParamTunable(S, i, 0);

    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE | SS_OPTION_PLACE_ASAP);
#endif
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
    real_T *RWork      = ssGetRWork(S);
    int_T  *IWork      = ssGetIWork(S);
    int_T   base       = mxGetPr(BASE_ARG)[0];
    int_T   nChans     = mxGetPr(NUM_CHANS_ARG)[0];
    int_T   firstChan  = mxGetPr(FIRST_CHAN_ARG)[0] - 1;
    int_T   control    = mxGetPr(CONTROL_ARG)[0];
    int_T   showStatus = mxGetPr(SHOW_STATUS_ARG)[0];
    real_T  gain       = (real_T) mxGetPr(GAIN_ARG)[0];
    real_T  offset     = (real_T) mxGetPr(OFFSET_ARG)[0];
    int_T   iterations = 1000;

    real_T  start, loopsPerSec;
    int_T   i, maxLoops, adChannel;

    adChannel  = firstChan;
    adChannel |= (firstChan + nChans - 1) << 4;

    IWork[BASE_I_IND] = base;
    IWork[SHOW_STATUS_I_IND] = showStatus;

    RWork[GAIN_R_IND] = gain;
    RWork[OFFSET_R_IND] = offset;

    // estimate max number of loops for A/D to settle

    start = rl32eGetTicksDouble();

    for (i = 0; i < iterations; i++)
        rl32eInpB(base + STATUS);

    loopsPerSec = iterations / rl32eETimeDouble(rl32eGetTicksDouble(), start);

    maxLoops = (int_T) (2.0 * nChans * SECS_PER_CHAN * loopsPerSec);

    IWork[MAX_LOOPS_I_IND] = maxLoops;

    // internal oscillator, no DMA, no timer or digital or analog interrupts
    rl32eOutpB(base + INT_DMA_COUNTER, 0);
    waitToSettle(S, base, maxLoops); 
     
    // set gain control bits G0, G1 and SCANEN
    rl32eOutpB(base + AD_GAIN_SCAN, control  | SCANEN );
    waitToSettle(S, base, maxLoops); 

    // set A/D channels 
    rl32eOutpB(base + AD_CHANNEL, adChannel);
    waitToSettle(S, base, maxLoops); 

    // set FIFO threshold 
    rl32eOutpB(base + FIFO_THRESHOLD, nChans | 0x3F);
    waitToSettle(S, base, maxLoops); 

    // reset A/D FIFO 
    rl32eOutpB(base + COMMAND, RSTFIFO);
    waitToSettle(S, base, maxLoops); 
#endif
}


static void mdlOutputs(SimStruct *S, int_T tid)
{
#ifndef MATLAB_MEX_FILE
    real_T  *RWork       = ssGetRWork(S);
    int_T   *IWork       = ssGetIWork(S);
    int_T    maxLoops    = IWork[MAX_LOOPS_I_IND];
    int_T    base        = IWork[BASE_I_IND];
    int_T    showStatus  = IWork[SHOW_STATUS_I_IND];
    real_T   gain        = RWork[GAIN_R_IND];
    real_T   offset      = RWork[OFFSET_R_IND];
    int_T    nChans      = mxGetPr(NUM_CHANS_ARG)[0];
    int_T    status      = 0;
    int16_T  count;
    int_T    i, error;
    real_T  *y;

    // start conversion 
    rl32eOutpB(base + COMMAND, STRTAD);

    // wait for STS to go low
    for (i = 0; i < maxLoops && (rl32eInpB(base + STATUS) & STS); i++);

    error = (i >= maxLoops);

    for (i = 0; i < nChans; i++){

        y = ssGetOutputPortRealSignal(S,i);

        count = rl32eInpW(base + AD_LSB);

       if (error)
          status = status | (1 << i);
       else
           y[0] = gain * count - offset; 
    } 

    if (showStatus) {
       y = ssGetOutputPortRealSignal(S, nChans);
       y[0] = (real_T) status;
    }
#endif
}


static void mdlTerminate(SimStruct *S)
{   
}

#ifdef MATLAB_MEX_FILE  // Is this file being compiled as a MEX-file? 
#include "simulink.c"   // Mex glue 
#else
#include "cg_sfun.h"    // Code generation glue 
#endif


