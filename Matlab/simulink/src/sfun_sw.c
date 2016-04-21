/*
 * File : sfun_sw.c
 * Abstract:
 *      This S-function has 3 scalar inputs and one scalar output.
 *      The first and third inputs are data inputs, and the second input
 *      is the control input. 
 *      If the control input is greater than 0.5, the first input port
 *      passes through, otherwise, the third input port passess through.
 *      Since the block conditionally needs its data inputs based on 
 *      its control input, it conditionally computes its inputs.
 *
 *  Copyright 1990-2004 The MathWorks, Inc.
 *  $Revision: 1.4.4.2 $
 */


/*
 * You must specify the S_FUNCTION_NAME as the name of your S-function.
 */

#define S_FUNCTION_NAME  sfun_sw
#define S_FUNCTION_LEVEL 2

/*
 * Need to include simstruc.h for the definition of the SimStruct and
 * its associated macro definitions.
 */
#include <string.h>
#include "simstruc.h"

#if !defined(MATLAB_MEX_FILE)
/*
 * This file cannot be used directly with the Real-Time Workshop. However,
 * this S-function does work with the Real-Time Workshop via
 * the Target Language Compiler technology. See 
 * matlabroot/toolbox/simulink/blocks/tlc_c/sfun_multiport.tlc   
 * for the C version
 * matlabroot/toolbox/simulink/blocks/tlc_ada/sfun_multiport.tlc 
 * for the Ada version
 */
# error This_file_can_be_used_only_during_simulation_inside_Simulink
#endif


/*====================*
 * S-function methods *
 *====================*/

/* Function: mdlInitializeSizes ===============================================
 * Abstract:
 *     Initialize the block.
 */
static void mdlInitializeSizes(SimStruct *S)
{
    int_T i;
    ssSetNumSFcnParams(S, 0);
#if defined(MATLAB_MEX_FILE)
    if (ssGetNumSFcnParams(S) == ssGetSFcnParamsCount(S)) {
        if (ssGetErrorStatus(S) != NULL) {
            return;
        }
    } else {
        return; /* Parameter mismatch will be reported by Simulink */
    }
#endif

    if (!ssSetNumInputPorts( S, 3)) return;
    if (!ssSetNumOutputPorts(S, 1)) return;
    
    for (i = 0; i < 3; i++) {
        ssSetInputPortWidth(S, i, 1);
        ssSetInputPortDirectFeedThrough(S, i, 1);
    }
    ssSetOutputPortWidth(S, 0, 1);
    
    ssSetNumSampleTimes(S, 1);
    ssSetNumRWork(S, 0);
    ssSetNumIWork(S, 0);
    ssSetNumPWork(S, 0);
    ssSetNumModes(S, 0);
    ssSetNumNonsampledZCs(S, 0);
    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 0);

    /* Take care when specifying exception free code - see sfuntmpl_doc.c */
    ssSetOptions(S,
                 SS_OPTION_WORKS_WITH_CODE_REUSE |
                 SS_OPTION_CAN_BE_CALLED_CONDITIONALLY  |
                 SS_OPTION_USE_TLC_WITH_ACCELERATOR);
}


/* Function: mdlInitializeSampleTimes =========================================
 * Abstract:
 *    Specifiy that we inherit our sample time from the driving block.
 */
static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, 0.0);
    ssSetModelReferenceSampleTimeDefaultInheritance(S);
}


#define MDL_SET_WORK_WIDTHS   /* Change to #undef to remove function */
#if defined(MDL_SET_WORK_WIDTHS) && defined(MATLAB_MEX_FILE)
/* Function: mdlSetWorkWidths ===============================================
 * Abstract:
 *      Set up run-time parameters.
 */
static void mdlSetWorkWidths(SimStruct *S)
{
    ssSetInputPortSignalWhenNeeded( S, 0, CONDITIONALLY_NEEDED);
    ssSetInputPortSignalWhenNeeded( S, 1, ALWAYS_NEEDED); /* Default */
    ssSetInputPortSignalWhenNeeded( S, 2, CONDITIONALLY_NEEDED);
}
#endif /* MDL_SET_WORK_WIDTHS */



/* Function: mdlOutputs =======================================================
 * Abstract:
 */
static void mdlOutputs(SimStruct *S, int_T tid)
{
    real_T            *y     = ssGetOutputPortRealSignal(S,0);
    InputRealPtrsType uPtrs0 = ssGetInputPortRealSignalPtrs(S, 0);
    InputRealPtrsType uPtrs1 = ssGetInputPortRealSignalPtrs(S, 1);
    InputRealPtrsType uPtrs2 = ssGetInputPortRealSignalPtrs(S, 2);

    if((*uPtrs1[0]) > 0.5 ){
        if(!ssComputeInput(S, 0)) return;
        *y = (*uPtrs0[0]);
    }else{
        if(!ssComputeInput(S, 2)) return;
        *y = (*uPtrs2[0]);
    }
}


/* Function: mdlTerminate =====================================================
 * Abstract:
 *      Free the user data.
 */
static void mdlTerminate(SimStruct *S)
{
}

/*======================================================*
 * See sfuntmpl_doc.c for the optional S-function methods *
 *======================================================*/

/*=============================*
 * Required S-function trailer *
 *=============================*/

#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif

