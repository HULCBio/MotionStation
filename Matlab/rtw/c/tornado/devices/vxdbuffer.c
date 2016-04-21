/* 
 * $Revision: 1.11 $
 * $RCSfile: vxdbuffer.c,v $
 *
 * Abstract:
 *      VxWorks Asynchronous Double Block for RTW.
 * Author:
 *      Pete Szpak, Jim Carrick
 * Date:
 *      10-15-97
 *
 * Copyright 1994-2002 The MathWorks, Inc.
 */

#define S_FUNCTION_NAME vxdbuffer
#define S_FUNCTION_LEVEL 2

#define BUFFER_SIDE     (ssGetSFcnParam(S,0))
#define SAMPLE_TIME     (ssGetSFcnParam(S,1))

#include "tmwtypes.h"
#include "simstruc.h"

#ifndef MATLAB_MEX_FILE
/* Since we have a target file for this S-function, declare an error here
 * so that, if for some reason this file is being used (instead of the
 * target file) for code generation, we can trap this problem at compile
 * time. */
#  error This_file_can_be_used_only_during_simulation_inside_Simulink
#endif

/*====================*
 * S-function methods *
 *====================*/

#define MDL_CHECK_PARAMETERS
static void mdlCheckParameters(SimStruct *S)
{
    const char *msg = NULL;
    ssSetErrorStatus(S,msg);
}

static void mdlInitializeSizes(SimStruct *S)
{
    ssSetNumSFcnParams(S, 2);
    if (ssGetNumSFcnParams(S) == ssGetSFcnParamsCount(S)) {
        mdlCheckParameters(S);
        if (ssGetErrorStatus(S) != NULL) {
            return;
        }
    } else {
        return; /* Simulink will report a parameter mismatch error */
    }
    ssSetSFcnParamNotTunable(        S, 0);
    ssSetSFcnParamNotTunable(        S, 1);
    ssSetNumInputPorts(              S, 1);
    ssSetInputPortWidth(             S, 0, DYNAMICALLY_SIZED);
    ssSetInputPortDirectFeedThrough( S, 0, 1);
    ssSetNumOutputPorts(             S, 1);
    ssSetOutputPortWidth(            S, 0, DYNAMICALLY_SIZED);
    ssSetNumIWork(                   S, DYNAMICALLY_SIZED);
    ssSetNumRWork(                   S, DYNAMICALLY_SIZED);
    ssSetNumPWork(                   S, DYNAMICALLY_SIZED);
    ssSetNumSampleTimes(             S, 1);
    ssSetNumContStates(              S, 0);
    ssSetNumDiscStates(              S, 0);
    ssSetNumModes(                   S, 0);
    ssSetNumNonsampledZCs(           S, 0);
    ssSetOptions(                    S, (SS_OPTION_EXCEPTION_FREE_CODE |
                                         SS_OPTION_ASYNC_RATE_TRANSITION));
}

static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, (mxGetPr(SAMPLE_TIME)[0]));
    ssSetOffsetTime(S, 0, 0.0);
}

static void mdlOutputs(SimStruct *S, int_T tid)
{
    int_T i;
    InputRealPtrsType uPtrs = ssGetInputPortRealSignalPtrs(S,0);
    
    for(i = 0; i < ssGetInputPortWidth(S,0);i++) {
        ssGetOutputPortRealSignal(S,0)[i] = *uPtrs[i];
    }
}

static void mdlTerminate(SimStruct *S){}

#define MDL_SET_WORK_WIDTHS
static void mdlSetWorkWidths(SimStruct *S)
{
    char_T str[20];
    mxGetString(BUFFER_SIDE, str, 20);
    if (!strcmp("WRITE",str)) {
        ssSetNumRWork(S,0);
        ssSetNumIWork(S,0);
        ssSetNumPWork(S,0);
    }
    else if (!strcmp("READ",str)) {
        ssSetNumRWork(S,ssGetInputPortWidth(S, 0));
        ssSetNumIWork(S,3);
        ssSetNumPWork(S,2);
    }
    else {
        ssSetErrorStatus(S,"invalid BUFFER_SIDE");
    }
}

#define MDL_RTW
static void mdlRTW(SimStruct *S)
{
    char_T str[20];
    
    mxGetString(BUFFER_SIDE, str, 20);
    if (!strcmp("READ",str)) {
        /* Write out names for the IWork vectors.*/
        if (!ssWriteRTWWorkVect(S, "IWork", 3, 
                                "Reading", 1,
                                "Writing", 1,
                                "Last",    1
                                )) {
            return; /* An error occurred which will be reported by SL */
        }
    }
}

/*=============================*
 * Required S-function trailer *
 *=============================*/

#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif

/* EOF: vxdbuffer.c*/

