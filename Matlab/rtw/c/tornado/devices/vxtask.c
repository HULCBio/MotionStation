/*
 * $Revision: 1.14 $
 * $RCSfile: vxtask.c,v $
 *
 * Abstract:
 *      VxWorks Task Block for RTW.
 * Author:
 *      Pete Szpak, Jim Carrick
 * Date:
 *      10-15-97
 *
 * Copyright 1994-2002 The MathWorks, Inc.
 */

#define S_FUNCTION_NAME vxtask
#define S_FUNCTION_LEVEL 2

#define TASK_NAME       (ssGetSFcnParam(S,0))
#define PRIORITY        (ssGetSFcnParam(S,1))
#define STACK_SIZE      (ssGetSFcnParam(S,2))

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
    int_T priority  = (int_T) (*(mxGetPr(PRIORITY)));
    int_T stackSize = (int_T) (*(mxGetPr(STACK_SIZE)));
    
    if( priority < 0 | priority > 255 ) {
        ssSetErrorStatus(S, "Priority must be 0-255.");
	return;
    }
    
    if( stackSize <= 0 ) {
        ssSetErrorStatus(S, "Stack size must be >= 0");
	return;
    }
}

static void mdlInitializeSizes(SimStruct *S)
{
    ssSetNumSFcnParams(       S, 3);
    if (ssGetNumSFcnParams(S) == ssGetSFcnParamsCount(S)) {
        mdlCheckParameters(S);
        if (ssGetErrorStatus(S) != NULL) {
            return;
        }
    } else {
        return; /* Simulink will report a parameter mismatch error */
    }
    ssSetSFcnParamNotTunable( S, 0);
    ssSetSFcnParamNotTunable( S, 1);
    ssSetSFcnParamNotTunable( S, 2);
    ssSetNumInputPorts(       S, 0);
    ssSetNumOutputPorts(      S, 1);
    ssSetOutputPortWidth(     S, 0, 1);
    ssSetNumIWork(            S, 1);
    ssSetNumRWork(            S, 0);
    ssSetNumPWork(            S, 1);
    ssSetNumSampleTimes(      S, 1);
    ssSetNumContStates(       S, 0);
    ssSetNumDiscStates(       S, 0);
    ssSetNumModes(            S, 0);
    ssSetNumNonsampledZCs(    S, 0);
    ssSetOptions(             S, (SS_OPTION_EXCEPTION_FREE_CODE |
                                  SS_OPTION_ASYNCHRONOUS        |
                                  SS_OPTION_FORCE_NONINLINED_FCNCALL));
}

static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, 0.0);
    ssSetCallSystemOutput(S, 0);
}

static void mdlOutputs(SimStruct *S, int_T tid)
{
    ssCallSystemWithTid(S, 0, tid);
}

static void mdlTerminate(SimStruct *S) {}

#define MDL_RTW
static void mdlRTW(SimStruct *S)
{
    int_T numElements = mxGetNumberOfElements(TASK_NAME);
    char *buf = NULL;
    
    if ((buf = malloc(numElements +1)) == NULL) {
        ssSetErrorStatus(S,"memory allocation error in mdlRTW");
        return;
    }
    if (mxGetString(TASK_NAME,buf,numElements+1) != 0) {
        ssSetErrorStatus(S,"mxGetString error in mdlRTW");
        free(buf);
        return;
    }

    /* Write out the parameters for this block.*/
    if (!ssWriteRTWParamSettings(S, 3, 
                                 SSWRITE_VALUE_QSTR,"TaskName", buf,
                                 SSWRITE_VALUE_NUM,"Priority",
                                 (real_T) (*(mxGetPr(PRIORITY))),
                                 SSWRITE_VALUE_NUM,"StackSize",
                                 (real_T) (*(mxGetPr(STACK_SIZE)))
                                 )) {
        return; /* An error occurred which will be reported by SL */
    }
    
    /* Write out names for the IWork vectors.*/
    if (!ssWriteRTWWorkVect(S, "IWork", 1, "TaskID", 1)) {
        return; /* An error occurred which will be reported by SL */
    }
    
    /* Write out names for the PWork vectors.*/
    if (!ssWriteRTWWorkVect(S, "PWork", 1, "SemID", 1)) {
        return; /* An error occurred which will be reported by SL */
    }
    
    free(buf);
}

/*=============================*
 * Required S-function trailer *
 *=============================*/

#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif


/* EOF: vxtask.c*/
