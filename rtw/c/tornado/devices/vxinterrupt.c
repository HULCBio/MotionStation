/*
 * $Revision: 1.19 $
 * $RCSfile: vxinterrupt.c,v $
 *
 * Abstract:
 *      VxWorks Asynchronous Interrupt Block.
 * Author:
 *      Pete Szpak, Jim Carrick
 * Date:
 *      10-15-97
 *
 * Copyright 1994-2002 The MathWorks, Inc.
 */

#define S_FUNCTION_NAME vxinterrupt
#define S_FUNCTION_LEVEL 2

#include "simstruc.h"


#define ISR_MODE             (ssGetSFcnParam(S,0))
#define ISR_NUMBERS          (ssGetSFcnParam(S,1))
#define ISR_OFFSETS          (ssGetSFcnParam(S,2))
#define ISR_DIRECTION        (ssGetSFcnParam(S,3))
#define ISR_PREEMPTION_FLAGS (ssGetSFcnParam(S,4))

#define ISR_MODE_SIMULATION  1
#define ISR_MODE_RTW         2


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
static void mdlInitializeSizes(SimStruct *S)
{
    int_T numISRs;
    
    ssSetNumSFcnParams(              S, 5);
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
        return; /* Simulink will report a parameter mismatch error */
    }

    numISRs = (int_T) (mxGetNumberOfElements(ISR_NUMBERS));

    ssSetSFcnParamNotTunable(        S, 0);
    ssSetSFcnParamNotTunable(        S, 1);
    ssSetSFcnParamNotTunable(        S, 2);
    ssSetSFcnParamNotTunable(        S, 3);
    ssSetSFcnParamNotTunable(        S, 4);
    ssSetNumInputPorts(              S, 1);

    if (*mxGetPr(ISR_MODE) == ISR_MODE_SIMULATION) {
        ssSetInputPortWidth(         S, 0, numISRs);
    } else {
        ssSetInputPortWidth(         S, 0, 1);        
    }
    ssSetInputPortDirectFeedThrough( S, 0, 1);
    ssSetNumOutputPorts(             S, 1);
    ssSetOutputPortWidth(            S, 0, numISRs);
    ssSetNumIWork(                   S, 0);
    ssSetNumRWork(                   S, 0);
    ssSetNumPWork(                   S, 0);
    ssSetNumSampleTimes(             S, 1);
    ssSetNumContStates(              S, 0);
    ssSetNumDiscStates(              S, 0);
    ssSetNumModes(                   S, 0);
    ssSetNumNonsampledZCs(           S, 0);
    ssSetOptions(                    S, (SS_OPTION_EXCEPTION_FREE_CODE |
                                         SS_OPTION_ASYNCHRONOUS_INTERRUPT |
                                         SS_OPTION_FORCE_NONINLINED_FCNCALL));
}


static void mdlInitializeSampleTimes(SimStruct *S)
{
    int_T i;
    int_T mode = (int_T) (*(mxGetPr(ISR_MODE)));

    if (mode == ISR_MODE_SIMULATION) {
        /* simulation mode - used inside of triggered subsystem */
        ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
        ssSetOffsetTime(S, 0, FIXED_IN_MINOR_STEP_OFFSET);
    } else {
        /* RTW mode - used only to register ISR */
        ssSetSampleTime(S, 0, mxGetInf());
        ssSetOffsetTime(S, 0, 0.0);
    }
    
    for(i = 0; i < ssGetOutputPortWidth(S,0); i++) {
        ssSetCallSystemOutput(S,i);
    }
}


#define MDL_INITIALIZE_CONDITIONS
static void mdlInitializeConditions(SimStruct *S)
{
    int_T mode = (int_T) (*(mxGetPr(ISR_MODE)));
    
    if( mode != ISR_MODE_SIMULATION && ssGetSimMode(S) == SS_SIMMODE_NORMAL) {
        ssSetErrorStatus(S, "Switch the mode of the interrupt block to "
                         "simulation.");
	return;
    }
}

static void mdlOutputs(SimStruct *S, int_T tid)
{
    int_T i,j;
    InputRealPtrsType uPtrs = ssGetInputPortRealSignalPtrs(S,0);
    
    for(j=1; j < 8; j++) {
        for(i = 0; i < ssGetInputPortWidth(S,0); i++) {
            /*call ISRs based on 1 being highest priority*/
            if (((int_T)(mxGetPr(ISR_NUMBERS)[i])) == j) {
                if( (int_T) *uPtrs[i] ) {
                    ssCallSystemWithTid(S,i,0);
                }
            }
        }
    }
}

static void mdlTerminate(SimStruct *S) {}

#define MDL_RTW
static void mdlRTW(SimStruct *S)
{
    /* Write out 4 of the 5 parameters for this block.*/
    if (!ssWriteRTWParamSettings(S, 4, 
                                 SSWRITE_VALUE_NUM,"Mode",
                                 (real_T) (*(mxGetPr(ISR_MODE))),
                                 SSWRITE_VALUE_VECT,"Numbers",
                                 (real_T *) mxGetPr(ISR_NUMBERS), 
                                 mxGetNumberOfElements(ISR_NUMBERS),
                                 SSWRITE_VALUE_VECT,"Offsets",
                                 (real_T *) mxGetPr(ISR_OFFSETS),
                                 mxGetNumberOfElements(ISR_OFFSETS),
                                 SSWRITE_VALUE_VECT,"Preemption",
                                 (real_T *) mxGetPr(ISR_PREEMPTION_FLAGS),
                                 mxGetNumberOfElements(ISR_PREEMPTION_FLAGS)
                                 )) {
        return; /* An error occurred which will be reported by SL */
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

/* EOF: vxinterrupt.c*/
