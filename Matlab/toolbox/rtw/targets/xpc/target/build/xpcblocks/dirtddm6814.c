/* $Revision: 1.1.6.2 $ */
// dirtddm6814.c - xPC Target, non-inlined S-function driver 
// for digital input section of RTD DM6814 boards  
// Copyright 1996-2003 The MathWorks, Inc.

#define     S_FUNCTION_LEVEL    2
#undef      S_FUNCTION_NAME
#define     S_FUNCTION_NAME     dirtddm6814

#include    <stddef.h>
#include    <stdlib.h>

#include    "simstruc.h" 

#ifdef      MATLAB_MEX_FILE
#include    "mex.h"
#endif

#ifndef     MATLAB_MEX_FILE
#include    <windows.h>
#include    "io_xpcimport.h"
#endif


// input arguments
#define NUM_ARGS        (5)
#define MODE_ARG        ssGetSFcnParam(S,0) // bits D2-D7 of mode
#define CHANNEL_ARG     ssGetSFcnParam(S,1) // vector of 1:8
#define PORT_ARG        ssGetSFcnParam(S,2) // 1:3
#define SAMP_TIME_ARG   ssGetSFcnParam(S,3) // double
#define BASE_ARG        ssGetSFcnParam(S,4) // integer

#define DIGITAL_IO      (2)    // register offsets
#define MODE            (3)

#define DIO_MODE        (0x02) // D0-D1 of MODE register

#define NUM_I_WORKS     (0)
#define NUM_R_WORKS     (0)

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
 

#define MDL_START
static void mdlStart(SimStruct *S)
{
#ifndef MATLAB_MEX_FILE
    int_T mode = mxGetPr(MODE_ARG)[0]; 
    int_T port = mxGetPr(PORT_ARG)[0] - 1; 
    int_T base = mxGetPr(BASE_ARG)[0] + 4 * port; 
    int_T encoderPresent = (mode & 0xf0); 

    if (~encoderPresent) 
        rl32eOutpB(base + MODE, mode | DIO_MODE);
#endif
}

static void mdlOutputs(SimStruct *S, int_T tid)
{
#ifndef MATLAB_MEX_FILE
    int_T nChans = mxGetN(CHANNEL_ARG);
    int_T mode   = mxGetPr(MODE_ARG)[0]; 
    int_T port   = mxGetPr(PORT_ARG)[0] - 1; 
    int_T base   = mxGetPr(BASE_ARG)[0] + 4 * port; 
    int_T bit[8] = {1, 2, 4, 8, 16, 32, 64, 128};
    int_T encoderPresent = (mode & 0xf0); 

    int_T   i, chan, value;
    real_T *y;
 
    if (encoderPresent) 
        rl32eOutpB(base + MODE, mode | DIO_MODE);

    // read digital input
    value = rl32eInpB(base + DIGITAL_IO);

    for (i = 0; i < nChans; i++) {
        chan = mxGetPr(CHANNEL_ARG)[i] - 1;
        y = ssGetOutputPortSignal(S, i);
        y[0] = (value & bit[chan]) ? 1.0 : 0.0;
    }
#endif
}

static void mdlTerminate(SimStruct *S)
{   
#ifndef MATLAB_MEX_FILE
#endif
}


#ifdef MATLAB_MEX_FILE  // Is this file being compiled as a MEX-file? 
#include "simulink.c"   // Mex glue 
#else
#include "cg_sfun.h"    // Code generation glue 
#endif
