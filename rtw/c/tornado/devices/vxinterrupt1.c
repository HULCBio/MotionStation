/*
 * $Revision $
 * $RCSfile: vxinterrupt1.c,v $
 *
 * Abstract:
 *      VxWorks Asynchronous Interrupt Block.
 *
 * Copyright 2003-2004 The MathWorks, Inc.
 */

#define S_FUNCTION_NAME vxinterrupt1
#define S_FUNCTION_LEVEL 2

#include "simstruc.h"


#define ISR_NUMBERS          (ssGetSFcnParam(S,0))
#define ISR_OFFSETS          (ssGetSFcnParam(S,1))
#define ISR_PRIORITIES       (ssGetSFcnParam(S,2))
#define ISR_PREEMPTION       (ssGetSFcnParam(S,3))
#define SHOW_INPUTPORT       (ssGetSFcnParam(S,4))
#define TICK_RES             (ssGetSFcnParam(S,5))

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
    int_T i,j[8],k;
    int_T numISRs       = (int_T) (mxGetNumberOfElements(ISR_NUMBERS));
    int_T numOffsets    = (int_T) (mxGetNumberOfElements(ISR_OFFSETS));
    int_T numPriorities = (int_T) (mxGetNumberOfElements(ISR_PRIORITIES));
    int_T numPreempts   = (int_T) (mxGetNumberOfElements(ISR_PREEMPTION));
    int_T numTickSize   = (int_T) (mxGetNumberOfElements(TICK_RES));
    
    /* Check ISR_NUMBERS */
    if (numISRs < 1) {
        ssSetErrorStatus(S,"Must specify at least 1 interrrupt.");
        return;
    } else if (!mxIsDouble(ISR_NUMBERS)) {
        ssSetErrorStatus(S,"Must specify interrupt number as type 'double'.");
        return;
    }
    for (i=0;i<8;i++) j[i] = false;
    for (i=0;i<numISRs;i++) {
        int_T intnum = (int_T)(mxGetPr(ISR_NUMBERS)[i]);
        if ((intnum > 7) || (intnum < 1)) {
            ssSetErrorStatus(S,"Interrupt numbers must be 1-7.");
            return;
        }
        if (j[intnum] == true) {
            ssSetErrorStatus(S,"Interrupt numbers must be unique.");
            return;
        } else {
            j[intnum] = true;
        }
    }

    /* Check ISR_OFFSETS */
    if (!mxIsDouble(ISR_OFFSETS)) {
        ssSetErrorStatus(S,"Must specify vector offset number as type 'double'.");
        return;
    } else if (numOffsets != numISRs) {
        ssSetErrorStatus(S,"The number of interrupt vector offsets must match the"
                         " number of interrupts.");
        return;
    }
    for (i=0;i<numOffsets;i++) j[i] = 0;
    for (i=0;i<numOffsets;i++) {
        int_T intoffset = (int_T)(mxGetPr(ISR_OFFSETS)[i]);
        for (k=0;k<numOffsets;k++) {
            if (j[k] == intoffset) {
                ssSetErrorStatus(S,"Vector offset numbers must be unique.");
                return;
            } else if (j[k] == 0) {
                j[k] = intoffset;
                break;
            }
        }
    }

    /* Check ISR_PRIORITIES */
    if (!mxIsDouble(ISR_PRIORITIES)) {
        ssSetErrorStatus(S,"Must specify priority number as type 'double'.");
        return;
    } else if (numPriorities != numISRs) {
        ssSetErrorStatus(S,"The number of interrupt priorities must match the"
                         " number of interrupts.");
        return;
    }

    /* Check ISR_PREEMPTION */
    if (!mxIsDouble(ISR_PREEMPTION)) {
        ssSetErrorStatus(S,"Must specify preemption number as type 'double'.");
        return;
    } else if ((numPreempts != numISRs) && (numPreempts != 1)) {
        ssSetErrorStatus(S,"The number of preemption flags must match the"
                         " number of interrupts or be one.");
        return;
    } else {
        for(i=0;i<numPreempts;i++) {
            int_T preemptflag = (int_T)(mxGetPr(ISR_PREEMPTION)[i]);
            if ((preemptflag != 0) && (preemptflag != 1)) {
                ssSetErrorStatus(S,"The values of the preemption flags must"
                                 "  be '0' or '1'");
                return;
            }
        }
    }

    /* Check TICK_RES */
    if (!mxIsDouble(TICK_RES)) {
        ssSetErrorStatus(S,"Must specify timer tick size as type 'double'.");
        return;
    } else if (numTickSize != 1) {
        ssSetErrorStatus(S,"Must specify one value for tick size.");
        return;
    }
}

static void mdlInitializeSizes(SimStruct *S)
{
    int_T numISRs;
    int_T *priorityArray = NULL;
    int_T i;

    ssSetNumSFcnParams(S, 6);
    if (ssGetNumSFcnParams(S) == ssGetSFcnParamsCount(S)) {
        mdlCheckParameters(S);
        if (ssGetErrorStatus(S) != NULL) {
            return;
        }
    } else {
        return; /* Parameter mismatch will be reported by Simulink */
    }

    numISRs = (int_T) (mxGetNumberOfElements(ISR_NUMBERS));

    ssSetSFcnParamNotTunable(        S, 0);
    ssSetSFcnParamNotTunable(        S, 1);
    ssSetSFcnParamNotTunable(        S, 2);
    ssSetSFcnParamNotTunable(        S, 3);
    ssSetSFcnParamNotTunable(        S, 4);
    ssSetSFcnParamNotTunable(        S, 5);
    if ((int_T)(mxGetPr(SHOW_INPUTPORT)[0])) {
        ssSetNumInputPorts(          S, 1);
        ssSetInputPortWidth(         S, 0, numISRs);
        ssSetInputPortDirectFeedThrough(S, 0, 1);
        ssSetInputPortDataType(      S, 0, DYNAMICALLY_TYPED);
    }
    else {
        ssSetNumInputPorts(          S, 0);
    }
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
                                         SS_OPTION_DISALLOW_CONSTANT_SAMPLE_TIME |
                                         SS_OPTION_ASYNCHRONOUS_INTERRUPT));

    /* Setup Async Timer attributes */
    ssSetTimeSource(S, SELF);
    ssSetAsyncTimerAttributes(S,mxGetPr(TICK_RES)[0]);

    /* Setup Async Task Priorities */
    priorityArray = malloc(numISRs*sizeof(int_T));
    for (i=0; i<numISRs; i++) {
        priorityArray[i] = (int_T)(mxGetPr(ISR_PRIORITIES)[i]);
    }
    ssSetAsyncTaskPriorities(S, numISRs, priorityArray); 
    free(priorityArray);
    priorityArray = NULL;
}


static void mdlInitializeSampleTimes(SimStruct *S)
{
    int_T i;

    ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, FIXED_IN_MINOR_STEP_OFFSET);
    
    for(i = 0; i < ssGetOutputPortWidth(S,0); i++) {
        ssSetCallSystemOutput(S,i);
    }
}


static void mdlOutputs(SimStruct *S, int_T tid)
{
    int_T i,j;
    
    if (ssGetNumInputPorts(S) == 0) {
        int_T numISRs = (int_T) (mxGetNumberOfElements(ISR_NUMBERS));
        
        for(j=7; j > 0; j--) {
            for(i = 0; i < numISRs; i++) {
                /*call ISRs based on 7 being highest priority*/
                if (((int_T)(mxGetPr(ISR_NUMBERS)[i])) == j) {
                    ssCallSystemWithTid(S,i,tid);
                }
            }
        }
    }
    else {
        InputPtrsType uPtrs = ssGetInputPortSignalPtrs(S,0);
        
        for(j=7; j > 0; j--) {
            for(i = 0; i < ssGetInputPortWidth(S,0); i++) {
                /*call ISRs based on 7 being highest priority*/
                if (((int_T)(mxGetPr(ISR_NUMBERS)[i])) == j) {
                    switch (ssGetInputPortDataType(S, 0))
                    {
                      case SS_DOUBLE:
                        {
                            InputRealPtrsType pU  = (InputRealPtrsType)uPtrs;
                            if(*pU[i]) {
                                ssCallSystemWithTid(S,i,tid);
                            }
                            break;
                        }
                      case SS_SINGLE:
                        {
                            InputReal32PtrsType pU  = (InputReal32PtrsType)uPtrs;
                            if(*pU[i]) {
                                ssCallSystemWithTid(S,i,tid);
                            }
                            break;
                        }
                      case SS_INT8:
                        {
                            InputInt8PtrsType pU  = (InputInt8PtrsType)uPtrs;
                            if(*pU[i]) {
                                ssCallSystemWithTid(S,i,tid);
                            }
                            break;
                        }
                      case SS_UINT8:
                        {
                            InputUInt8PtrsType pU  = (InputUInt8PtrsType)uPtrs;
                            if(*pU[i]) {
                                ssCallSystemWithTid(S,i,tid);
                            }
                            break;
                        }
                      case SS_INT16:
                        {
                            InputInt16PtrsType pU  = (InputInt16PtrsType)uPtrs;
                            if(*pU[i]) {
                                ssCallSystemWithTid(S,i,tid);
                            }
                            break;
                        }
                      case SS_UINT16:
                        {
                            InputUInt16PtrsType pU  = (InputUInt16PtrsType)uPtrs;
                            if(*pU[i]) {
                                ssCallSystemWithTid(S,i,tid);
                            }
                            break;
                        }
                      case SS_INT32:
                        {
                            InputInt32PtrsType pU  = (InputInt32PtrsType)uPtrs;
                            if(*pU[i]) {
                                ssCallSystemWithTid(S,i,tid);
                            }
                            break;
                        }
                      case SS_UINT32:
                        {
                            InputUInt32PtrsType pU  = (InputUInt32PtrsType)uPtrs;
                            if(*pU[i]) {
                                ssCallSystemWithTid(S,i,tid);
                            }
                            break;
                        }
                      case SS_BOOLEAN:
                        {
                            InputBooleanPtrsType pU  = (InputBooleanPtrsType)uPtrs;
                            if(*pU[i]) {
                                ssCallSystemWithTid(S,i,tid);
                            }
                            break;
                        }
                    }
                }
            }
        }
    }
}

static void mdlTerminate(SimStruct *S) {}

#define MDL_SET_INPUT_PORT_DATA_TYPE
static void mdlSetInputPortDataType(SimStruct *S, 
                                    int       port, 
                                    DTypeId   dataType)
{
    switch(dataType)
    {
        /* Accept Simulink data types */
      case SS_DOUBLE:
      case SS_SINGLE:
      case SS_INT8:
      case SS_UINT8: 
      case SS_INT16:
      case SS_UINT16:
      case SS_INT32:
      case SS_UINT32:
      case SS_BOOLEAN:
        ssSetInputPortDataType(S, 0, dataType);
        break;
        
      default:
        /* Reject proposed data type */
        ssSetErrorStatus(S,"Invalid input port data type");
        break;
    }
} /* mdlSetInputPortDataType */

#define MDL_SET_DEFAULT_PORT_DATA_TYPES
static void mdlSetDefaultPortDataTypes(SimStruct *S)
{
    /* Set input port data type to bool */
    ssSetInputPortDataType(  S, 0, SS_BOOLEAN);            

} /* mdlSetDefaultPortDataTypes */

#define MDL_RTW
static void mdlRTW(SimStruct *S)
{
    /* Write out parameters for this block.*/
    if (!ssWriteRTWParamSettings(S, 3, 
                                 SSWRITE_VALUE_VECT,"Numbers",
                                 (real_T *) mxGetPr(ISR_NUMBERS), 
                                 mxGetNumberOfElements(ISR_NUMBERS),
                                 SSWRITE_VALUE_VECT,"Offsets",
                                 (real_T *) mxGetPr(ISR_OFFSETS), 
                                 mxGetNumberOfElements(ISR_OFFSETS),
                                 SSWRITE_VALUE_VECT,"Preemption",
                                 (real_T *) mxGetPr(ISR_PREEMPTION), 
                                 mxGetNumberOfElements(ISR_PREEMPTION)
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

/* EOF: vxinterrupt1.c*/
