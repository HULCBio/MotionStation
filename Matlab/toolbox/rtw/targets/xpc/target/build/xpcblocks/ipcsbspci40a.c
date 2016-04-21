/* $Revision: 1.2 $ */
/* 
   ipcsbspci40a.c - xPC Target, non-inlined S-function driver for the 
   SBS PCI-40A Quad IndustryPack carrier board.

   Copyright 1996-2002 The MathWorks, Inc.
*/

#define     S_FUNCTION_LEVEL    2
#undef      S_FUNCTION_NAME
#define     S_FUNCTION_NAME     ipcsbspci40a

#include    <stddef.h>
#include    <stdlib.h>
#include    <string.h>

#include    "tmwtypes.h"
#include    "simstruc.h" 

#ifdef MATLAB_MEX_FILE
#include    "mex.h"
#else
#include    <windows.h>
#include    "io_xpcimport.h"
#include    "pci_xpcimport.h"
#endif

#define     NUM_ARGS          (0)
#define     NUM_I_WORKS       (0)
#define     NUM_R_WORKS       (0)

static char_T msg[256];

static void mdlInitializeSizes(SimStruct *S)
{
    int i;

#ifndef MATLAB_MEX_FILE
#include "io_xpcimport.c"
#include "pci_xpcimport.c"
#endif

    ssSetNumSFcnParams(S, NUM_ARGS);  
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
        sprintf(msg,"%d input arguments were expected, but %d were passed\n",
            NUM_ARGS, ssGetSFcnParamsCount(S));
        ssSetErrorStatus(S, msg);
        return;
    }

    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 0);

    ssSetNumInputPorts(S, 0);

    ssSetNumOutputPorts(S, 0);

    ssSetNumSampleTimes(S, 0);

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
}

#define MDL_START 
static void mdlStart(SimStruct *S)
{
#ifndef MATLAB_MEX_FILE
#endif
}
    

static void mdlOutputs(SimStruct *S, int_T tid)
{
#ifndef MATLAB_MEX_FILE
#endif
}

#define MDL_TERMINATE
static void mdlTerminate(SimStruct *S)
{
}

#ifdef  MATLAB_MEX_FILE     /* Is this file being compiled as a MEX-file? */
#include "simulink.c"       /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"        /* Code generation registration function */
#endif

