/* $Revision: 1.2.6.1 $ */
// addsmm16at.c - xPC Target, non-inlined S-function driver for
// the analog input section of Diamond Systems MM-16-AT boards  

// Copyright 1996-2003 The MathWorks, Inc.


#define     S_FUNCTION_LEVEL    2
#undef      S_FUNCTION_NAME
#define     S_FUNCTION_NAME     addsmm16at

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
#include    "util_xpcimport.h" 
#endif

// input arguments
#define NUM_ARGS               (8)
#define FIRST_CHAN_ARG         ssGetSFcnParam(S,0) // 1:8 (DI) or 1:16 (SE)
#define NUM_CHANS_ARG          ssGetSFcnParam(S,1) // 1:8 (DI) or 1:16 (SE)
#define GAIN_ARG               ssGetSFcnParam(S,2) // double
#define OFFSET_ARG             ssGetSFcnParam(S,3) // double
#define RANGE_CODE_ARG         ssGetSFcnParam(S,4) // integer
#define SHOW_STATUS_ARG        ssGetSFcnParam(S,5) // boolean
#define SAMPLE_TIME_ARG        ssGetSFcnParam(S,6) // double
#define BASE_ARG               ssGetSFcnParam(S,7) // integer

// write register byte offsets
#define START_AD_CONVERSION    (0)
#define AD_CHANNEL_REGISTER    (2)
#define CONTROL_REGISTER       (9)
#define RANGE_REGISTER         (11)

// read register byte offsets
#define AD_LSB                 (0)
#define AD_MSB                 (1)
#define STATUS_REGISTER        (8)
#define FIFO_STATUS_REGISTER   (10)

// status register bits
#define STS                    (0x80)
#define WAIT                   (0x80)

#define NUM_I_WORKS            (1)
#define MAX_LOOPS_I_IND        (0)

#define NUM_R_WORKS            (0)

#define MAX_CHANS              (16)
#define SAMPLES_PER_SEC        (100000)
#define SECS_PER_CHAN          (1.0 / SAMPLES_PER_SEC)

static char_T msg[256];

static void mdlInitializeSizes(SimStruct *S)
{
    int_T numChans    = mxGetPr(NUM_CHANS_ARG)[0];
    int_T showStatus  = mxGetPr(SHOW_STATUS_ARG)[0];
    int_T numOutPorts = showStatus ? numChans + 1 : numChans;

    int_T i;

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

    ssSetNumContStates(S,0);
    ssSetNumDiscStates(S,0);
    ssSetNumInputPorts(S,0);

    ssSetNumOutputPorts(S, numOutPorts);
    for (i = 0; i < numOutPorts; i++) 
        ssSetOutputPortWidth(S, i, 1);

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
    int_T   base       = mxGetPr(BASE_ARG)[0]; 
    int_T   firstChan  = mxGetPr(FIRST_CHAN_ARG)[0] - 1; 
    int_T   numChans   = mxGetPr(NUM_CHANS_ARG)[0]; 
    int_T   lastChan   = firstChan + numChans - 1; 
    int_T   rangeCode  = mxGetPr(RANGE_CODE_ARG)[0]; 
    int_T   showStatus = mxGetPr(SHOW_STATUS_ARG)[0]; 
    int_T   iterations = 1000;

    int_T   i, maxLoops;
    real_T  start, secPerLoop;


    if (xpceIsModelInit()) { // at download time

        // estimate number of loops for A/D to settle

        start = rl32eGetTicksDouble();

        for (i = 0; i < iterations; i++)
            rl32eInpB(base + STATUS_REGISTER);

        secPerLoop = rl32eETimeDouble(rl32eGetTicksDouble(), start) / iterations;

        maxLoops = (int_T) (2 * MAX_CHANS * SECS_PER_CHAN / secPerLoop);

        IWork[MAX_LOOPS_I_IND] = maxLoops;

        // no interrupts, no DMA, no hardware A/D trigger
        rl32eOutpB(base + CONTROL_REGISTER, 0);

        // set high and low channels
        rl32eOutpB(base + AD_CHANNEL_REGISTER, (lastChan << 4) | firstChan);

        // set input range for all channels
        rl32eOutpB(base + RANGE_REGISTER, rangeCode);

        // wait for A/D circuit to settle
        for (i = 0; i < maxLoops; i++)
            if ((rl32eInpB(base + FIFO_STATUS_REGISTER) & WAIT) == 0)
                break;

        if (i >= maxLoops) {
            sprintf(msg, "Diamond MM-16-AT at base %03x does not respond", base);
            ssSetErrorStatus(S, msg);
            return;
        }
    }
#endif
}

static void mdlOutputs(SimStruct *S, int_T tid)
{
#ifndef MATLAB_MEX_FILE

    int_T *IWork      = ssGetIWork(S);
    int_T  maxLoops   = IWork[MAX_LOOPS_I_IND];
    int_T  base       = mxGetPr(BASE_ARG)[0];
    int_T  firstChan  = mxGetPr(FIRST_CHAN_ARG)[0] - 1;
    int_T  numChans   = mxGetPr(NUM_CHANS_ARG)[0];
    int_T  showStatus = mxGetPr(SHOW_STATUS_ARG)[0];
    real_T gain       = mxGetPr(GAIN_ARG)[0];
    real_T offset     = mxGetPr(OFFSET_ARG)[0];
    uint_T status     = 0;

    int_T   i, chan;
    int16_T count;
    real_T *y;

    for (chan = firstChan; chan < numChans; chan++) {

        rl32eOutpB(base + START_AD_CONVERSION, 0);

        y = ssGetOutputPortSignal(S, chan);

        // wait for A/D to finish
        for (i = 0; i < maxLoops; i++)
            if ((rl32eInpB(base + STATUS_REGISTER) & STS) == 0)
                break;

        count  = (rl32eInpB(base + AD_LSB) & 0xff);
        count += (rl32eInpB(base + AD_MSB) & 0xff) << 8;

        if (i >= maxLoops)
            status |= 1 << chan;
        else
            y[0] = gain * (offset + (real_T)count);     
        
        if (showStatus) {
            y = ssGetOutputPortRealSignal(S, numChans);
            y[0] = (real_T) status;
        }
    }
#endif
}

static void mdlTerminate(SimStruct *S)
{   
#ifndef MATLAB_MEX_FILE
#endif
}


#ifdef MATLAB_MEX_FILE  
#include "simulink.c"   // Mex glue
#else
#include "cg_sfun.h"    // Code generation glue
#endif
