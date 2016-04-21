/* $Revision: 1.4.4.1 $ $Date: */
/* encrtddm6814.c - xPC Target, non-inlined S-function driver for encoder section of RTD DM6814 board  */
/* Copyright 1996-2003 The MathWorks, Inc.
*/

#define     S_FUNCTION_LEVEL    2
#undef      S_FUNCTION_NAME
#define     S_FUNCTION_NAME     encrtddm6814

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
#define NUM_ARGS          (6)
#define MODE_ARG          ssGetSFcnParam(S,0) // bits D2-D7 of mode
#define NO_DIO_ARG        ssGetSFcnParam(S,1) // no DIO for this encoder chan?
#define CHAN_ARG          ssGetSFcnParam(S,2) // 1, 2, or 3
#define INIT_VAL_ARG      ssGetSFcnParam(S,3) // 0-65535
#define SAMP_TIME_ARG     ssGetSFcnParam(S,4) // double
#define BASE_ARG          ssGetSFcnParam(S,5) // integer

#define ENCODER_LSB       (0)  // register offsets
#define ENCODER_MSB       (1)
#define CLEAR             (2)
#define HOLD              (2)
#define DIGITAL_IO        (2)
#define MODE              (3)

#define CLEAR_MODE        (0x00) // D0-D1 of MODE register
#define HOLD_MODE         (0x01)
#define DIO_MODE          (0x02)

#define NUM_I_WORKS       (1)
#define NUM_R_WORKS       (0)
#define BASE_ADDR_I_IND   (0)

static char_T msg[256];

static void mdlInitializeSizes(SimStruct *S)
{
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

    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 0);

    ssSetNumOutputPorts(S, 1);
    ssSetOutputPortWidth(S, 0, 1);

    ssSetNumInputPorts(S, 0);

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
    ssSetSampleTime(S, 0, mxGetPr(SAMP_TIME_ARG)[0]);
    ssSetOffsetTime(S, 0, 0.0);
}
 

#define MDL_START
static void mdlStart(SimStruct *S)
{
#ifndef MATLAB_MEX_FILE
    int_T mode  = mxGetPr(MODE_ARG)[0]; 
    int_T chan  = mxGetPr(CHAN_ARG)[0] - 1; 
    int_T base  = mxGetPr(BASE_ARG)[0] + 4 * chan; 
    int_T init  = mxGetPr(INIT_VAL_ARG)[0];
    int_T noDio = mxGetPr(NO_DIO_ARG)[0]; 

    ssSetIWorkValue(S, BASE_ADDR_I_IND, base);

    // reset counter chip (resets counter to zero), disable encoder
    rl32eOutpB(base + MODE, 0);
    rl32eOutpB(base + CLEAR, 0);

    // set initial value for counter
    rl32eOutpB(base + ENCODER_LSB, 0xff & init); init >>= 8; 
    rl32eOutpB(base + ENCODER_MSB, 0xff & init);

    if (noDio)
        rl32eOutpB(base + MODE, mode | HOLD_MODE);

#endif
}

static void mdlOutputs(SimStruct *S, int_T tid)
{
#ifndef MATLAB_MEX_FILE
    int_T base = ssGetIWorkValue(S, BASE_ADDR_I_IND);
    int_T mode = mxGetPr(MODE_ARG)[0]; 
    int_T dio  = (mxGetPr(NO_DIO_ARG)[0] == 0); 

    int_T value;
    real_T *y;

    if (dio)
    // set mode to hold mode, retaining the current D2-D7
        rl32eOutpB(base + MODE, mode | HOLD_MODE);

    // latch counter
    rl32eOutpB(base + HOLD, 0);
    
    // read latched counter value
    value  = rl32eInpB(base + ENCODER_MSB) & 0xff;  value <<= 8;
    value |= rl32eInpB(base + ENCODER_LSB) & 0xff;

    y = ssGetOutputPortSignal(S,0);

    y[0] = (double) value;
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


