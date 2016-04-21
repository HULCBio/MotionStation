/* $Revision: 1.2 $ $Date: 2002/03/25 04:11:12 $ */
/* rs232bsend.c - xPC Target, non-inlined S-function driver for RS-232 send
 *                Done the binary way: (asynchronous)
 */
/* Copyright 1996-2002 The MathWorks, Inc. */

#define S_FUNCTION_LEVEL      2
#undef S_FUNCTION_NAME
#define S_FUNCTION_NAME       rs232bsend

#include <stddef.h>
#include <stdlib.h>

#include "tmwtypes.h"
#include "simstruc.h"

#ifdef MATLAB_MEX_FILE
#include "mex.h"
#else
#include <windows.h>
#include <string.h>
#include "rs232_xpcimport.h"
#include "time_xpcimport.h"
#endif

/* Input Arguments */
#define NUMBER_OF_ARGS          (3)
#define PORT_ARG                ssGetSFcnParam(S,0)
#define WIDTH_ARG               ssGetSFcnParam(S,1)
#define SAMP_TIME_ARG           ssGetSFcnParam(S,2)

#define NO_I_WORKS              (0)
#define NO_R_WORKS              (0)
#define NO_P_WORKS              (0)

static char_T msg[256];

extern int rs232ports[];

static void mdlInitializeSizes(SimStruct *S)
{
    int_T i, port;

#ifndef MATLAB_MEX_FILE
#include "rs232_xpcimport.c"
#include "time_xpcimport.c"
#endif

    ssSetNumSFcnParams(S, NUMBER_OF_ARGS);
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
        sprintf(msg,"Wrong number of input arguments passed.\n"
                "%d arguments are expected\n",NUMBER_OF_ARGS);
        ssSetErrorStatus(S,msg);
        return;
    }

    /* Set-up size information */
    ssSetNumContStates( S, 0);
    ssSetNumDiscStates( S, 0);
    ssSetNumOutputPorts(S, 0);

    ssSetNumInputPorts(S, 1);

    ssSetInputPortWidth(             S, 0, (int)mxGetPr(WIDTH_ARG)[0]);
    ssSetInputPortDirectFeedThrough( S, 0, 1);
    ssSetInputPortDataType(          S, 0, SS_UINT8);
    ssSetInputPortRequiredContiguous(S, 0, 1);

    ssSetNumSampleTimes(  S, 1);
    ssSetNumIWork(        S, NO_I_WORKS);
    ssSetNumRWork(        S, NO_R_WORKS);
    ssSetNumPWork(        S, NO_P_WORKS);
    ssSetNumModes(        S, 0);
    ssSetNumNonsampledZCs(S, 0);

    ssSetSFcnParamNotTunable(S,0);
    ssSetSFcnParamNotTunable(S,1);
    ssSetSFcnParamNotTunable(S,2);

    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE | SS_OPTION_PLACE_ASAP);
}

/* Function to initialize sample times */
static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, mxGetPr(SAMP_TIME_ARG)[0]);
    if (mxGetN((SAMP_TIME_ARG))==1) {
        ssSetOffsetTime(S, 0, 0.0);
    } else {
        ssSetOffsetTime(S, 0, mxGetPr(SAMP_TIME_ARG)[1]);
    }
}

#define MDL_START  /* Change to #undef to remove function */
#if defined(MDL_START)
static void mdlStart(SimStruct *S)
{
}
#endif

/* Function to compute outputs */
static void mdlOutputs(SimStruct *S, int_T tid)
{
#ifndef MATLAB_MEX_FILE

    int_T port, h, ini, inputindex;
    float delay;
    char *format_send;
    char tempChar;

    port=((int_T)mxGetPr(PORT_ARG)[0])-1;
    if (!rs232ports[port]) {
        ssSetErrorStatus(S,"        RS232 Send: chosen COM-port "
                           "not initialized\n");
        return;
    }

    rl32eSendBlock(port, (unsigned char *)ssGetInputPortSignal(S, 0),
                   (int)mxGetPr(WIDTH_ARG)[0]);
#endif
}

/* Function to perform housekeeping at execution termination */
static void mdlTerminate(SimStruct *S)
{
}

#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif
