/*
 * $Revision: 1.4.6.1 $
 *
 * Abstract: xPC Target Asynchronous Interrupt Block.
 *
 * Copyright 1996-2003 The MathWorks, Inc.
 */

#define S_FUNCTION_NAME xpcinterrupt
#define S_FUNCTION_LEVEL 2

#include "simstruc.h"

#define NUM_PARAMS           6

#define ISR_NUMBER           (ssGetSFcnParam(S, 0))
#define DEVICE_ID            (ssGetSFcnParam(S, 1))
#define VENDOR_ID            (ssGetSFcnParam(S, 2))
#define PCI_SLOT             (ssGetSFcnParam(S, 3))
#define HANDLERS             (ssGetSFcnParam(S, 4))
#define PREEMPT              (ssGetSFcnParam(S, 5))

static char msg[200];

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
static void mdlInitializeSizes(SimStruct *S) {
    ssSetNumSFcnParams(S, NUM_PARAMS);
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
        sprintf(msg, "Wrong number of input arguments passed;\n"
                "%d arguments are expected\n", NUM_PARAMS);
        ssSetErrorStatus(S, msg);
        return; /* Simulink will report a parameter mismatch error */
    }

    ssSetSFcnParamNotTunable(        S, 0);
    ssSetSFcnParamNotTunable(        S, 1);
    ssSetSFcnParamNotTunable(        S, 2);
    ssSetSFcnParamNotTunable(        S, 3);
    ssSetSFcnParamNotTunable(        S, 4);
    ssSetSFcnParamNotTunable(        S, 5);
    
    ssSetNumInputPorts(              S, 0);

    ssSetNumOutputPorts(             S, 1);
    ssSetOutputPortWidth(            S, 0, 1);

    ssSetNumIWork(                   S, 0);
    ssSetNumRWork(                   S, 0);
    ssSetNumPWork(                   S, 0);

    ssSetNumSampleTimes(             S, 1);
    ssSetNumContStates(              S, 0);
    ssSetNumDiscStates(              S, 0);
    ssSetNumModes(                   S, 0);
    ssSetNumNonsampledZCs(           S, 0);

    ssSetOptions(                    S, (SS_OPTION_EXCEPTION_FREE_CODE |
                                         SS_OPTION_ASYNCHRONOUS        |
                                         SS_OPTION_FORCE_NONINLINED_FCNCALL));
}


static void mdlInitializeSampleTimes(SimStruct *S) {
    ssSetSampleTime(S, 0, mxGetInf());
    ssSetOffsetTime(S, 0, 0.0);

    ssSetCallSystemOutput(S,0);
}

#define MDL_INITIALIZE_CONDITIONS
static void mdlInitializeConditions(SimStruct *S) {
}

static void mdlOutputs(SimStruct *S, int_T tid) {
    if (tid == CONSTANT_TID)
        ssCallSystemWithTid(S, 0, 0);
}

static void mdlTerminate(SimStruct *S) {}

#define MDL_RTW
static void mdlRTW(SimStruct *S)
{
#define STRING_SIZE 100
    int32_T irq, devid, vendid, slot = 0, preempt;
    char    *preHookName, *postHookName, *includeFileName, *startFunction,
            *stopFunction;

    irq     = (int32_T)mxGetPr(ISR_NUMBER)[0];
    devid   = (int32_T)mxGetPr(DEVICE_ID)[0];
    vendid  = (int32_T)mxGetPr(VENDOR_ID)[0];
    preempt = (int32_T)mxGetPr(PREEMPT)[0];
    if (mxGetN(PCI_SLOT) == 2)
        slot = ((int32_T)mxGetPr(PCI_SLOT)[1] & 0xff) << 8 |
            (int32_T)mxGetPr(PCI_SLOT)[0] & 0xff;
    else
        slot = (int32_T)mxGetPr(PCI_SLOT)[0];

    preHookName     = mxArrayToString(mxGetCell(HANDLERS, 0));
    postHookName    = mxArrayToString(mxGetCell(HANDLERS, 1));
    includeFileName = mxArrayToString(mxGetCell(HANDLERS, 2));
    startFunction   = mxArrayToString(mxGetCell(HANDLERS, 3));
    stopFunction    = mxArrayToString(mxGetCell(HANDLERS, 4));

    if (!ssWriteRTWParamSettings(S, 10,
                                 SSWRITE_VALUE_DTYPE_NUM, "IRQ",
                                 &irq,    DTINFO(SS_INT32, 0),
                                 SSWRITE_VALUE_DTYPE_NUM, "VendorId",
                                 &vendid, DTINFO(SS_INT32, 0),
                                 SSWRITE_VALUE_DTYPE_NUM, "DeviceId",
                                 &devid,  DTINFO(SS_INT32, 0),
                                 SSWRITE_VALUE_DTYPE_NUM, "PCISlot",
                                 &slot,   DTINFO(SS_INT32, 0),
                                 SSWRITE_VALUE_DTYPE_NUM, "Preemptable",
                                 &preempt, DTINFO(SS_INT32, 0),
                                 SSWRITE_VALUE_QSTR,
                                 "PreHookFunction",  preHookName,
                                 SSWRITE_VALUE_QSTR,
                                 "PostHookFunction", postHookName,
                                 SSWRITE_VALUE_QSTR,
                                 "HookIncludeFile",  includeFileName,
                                 SSWRITE_VALUE_QSTR,
                                 "StartFunction",    startFunction,
                                 SSWRITE_VALUE_QSTR,
                                 "StopFunction",     stopFunction)) {
        return; /* An error occurred which will be reported by SL */
    }
    mxFree(preHookName);
    mxFree(postHookName);
    mxFree(includeFileName);
    mxFree(startFunction);
    mxFree(stopFunction);
}

/*=============================*
 * Required S-function trailer *
 *=============================*/

#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif

/* EOF: xpcinterrupt.c*/
