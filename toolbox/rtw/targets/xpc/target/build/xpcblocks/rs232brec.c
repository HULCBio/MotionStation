/* $Revision: 1.2 $ $Date: 2002/03/25 04:11:09 $ */
/* rs232rec.c - xPC Target, non-inlined S-function driver for RS-232 receive (asynchronious)  */
/* Copyright 1996-2002 The MathWorks, Inc.
*/

#define S_FUNCTION_LEVEL 2
#undef S_FUNCTION_NAME
#define S_FUNCTION_NAME rs232brec

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
#define WIDTH_ARG               ssGetSFcnParam(S,1) /* max width */
#define SAMP_TIME_ARG           ssGetSFcnParam(S,2)

#define NO_I_WORKS              (2)     /* current pos, rec length */
#define NO_R_WORKS              (0)
#define NO_P_WORKS              (0)
#define NO_D_WORKS              (1)

static char_T msg[256];
extern int rs232ports[];

static void mdlInitializeSizes(SimStruct *S)
{
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
    ssSetNumOutputPorts(S, 2);          /* data, "done pulse" */
    ssSetNumInputPorts( S, 2);          /* rec length, enable */

    ssSetOutputPortWidth(   S, 0, 1);   /* Function-call */

    ssSetOutputPortWidth(   S, 1, (int)mxGetPr(WIDTH_ARG)[0]);
    ssSetOutputPortDataType(S, 1, SS_UINT8);

    ssSetInputPortDirectFeedThrough(S, 0, 1);
    ssSetInputPortDirectFeedThrough(S, 1, 1);
    ssSetInputPortWidth(            S, 0, 1);
    ssSetInputPortWidth(            S, 1, 1);

    ssSetInputPortRequiredContiguous(S, 0, 1);
    ssSetInputPortRequiredContiguous(S, 1, 1);

    ssSetNumSampleTimes(S,1);
    ssSetNumIWork(S, NO_I_WORKS);
    ssSetNumRWork(S, NO_R_WORKS);
    ssSetNumPWork(S, NO_P_WORKS);
    ssSetNumDWork(S, NO_D_WORKS);

    ssSetDWorkDataType(S, 0, SS_UINT8);
    ssSetDWorkWidth(   S, 0, (int)mxGetPr(WIDTH_ARG)[0]);

    ssSetNumModes(         S, 0);
    ssSetNumNonsampledZCs( S, 0);

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
    ssSetCallSystemOutput(S, 0);
}

#define MDL_START  /* Change to #undef to remove function */
#if defined(MDL_START)
static void mdlStart(SimStruct *S)
{
#ifndef MATLAB_MEX_FILE
    ssGetIWork(S)[0] = 0;
#endif
}
#endif

/* Function to compute outputs */
static void mdlOutputs(SimStruct *S, int_T tid)
{
#ifndef MATLAB_MEX_FILE
    int width   = (int)mxGetPr(WIDTH_ARG)[0];
    int port    = (int)mxGetPr(PORT_ARG )[0] - 1; /* 1 based to 0 based */
    unsigned char tmp;
    unsigned char *buf = (unsigned char *)ssGetDWork(S, 0);
    int *current   = ssGetIWork(S);
    int *recLength = ssGetIWork(S) + 1;
    int bufCount;

    if (ssGetInputPortRealSignal(S, 1)[0] == 0) /* disabled */
        return;
    if (*current == 0)
        *recLength = ssGetInputPortRealSignal(S, 0)[0];
    if (*recLength > width) {
        printf("RS232Receive: Receive Length must be <= %d\n", width);
        return;
    }
    bufCount = rl32eReceiveBufferCount(port);
    while (bufCount && (*current < *recLength)) {
        tmp = rl32eReceiveChar(port);
        if ((tmp & 0xff00) != 0) {
            printf("RS232Receive: Error\n");
            return;
        }
        buf[(*current)++] = tmp & 0xff;
        bufCount--;
    }

    if (*current >= *recLength) {
        memcpy(ssGetOutputPortSignal(S, 1), buf, width);
        *current = 0;
        ssCallSystemWithTid(S, 0, 0);
    }
    return;
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
