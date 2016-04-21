/*  File    : mixedmex.c
 *  Abstract:
 *
 *      Example MEX-file for a single-input, single-output system
 *      with mixed continuous and discrete states.
 *
 *      Syntax:  [sys, x0] = mixedmex(t,x,u,flag)
 *
 *      For more details about S-functions, see simulink/src/sfuntmpl_doc.c
 * 
 *  Copyright 1990-2004 The MathWorks, Inc.
 *  $Revision: 1.11.4.2 $
 */

#define S_FUNCTION_NAME  mixedmex
#define S_FUNCTION_LEVEL 2

#include "simstruc.h"

#define U(element) (*uPtrs[element])  /* Pointer to Input Port0 */


/*====================*
 * S-function methods *
 *====================*/

/* Function: mdlInitializeSizes ===============================================
 * Abstract:
 *    The sizes information is used by Simulink to determine the S-function
 *    block's characteristics (number of inputs, outputs, states, etc.).
 */
static void mdlInitializeSizes(SimStruct *S)
{
    ssSetNumSFcnParams(S, 0);  /* Number of expected parameters */
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
        return; /* Parameter mismatch will be reported by Simulink */
    }

    ssSetNumContStates(S, 1);
    ssSetNumDiscStates(S, 1);

    if (!ssSetNumInputPorts(S, 1)) return;
    ssSetInputPortWidth(S, 0, 1);
    ssSetInputPortDirectFeedThrough(S, 0, 0);

    if (!ssSetNumOutputPorts(S, 1)) return;
    ssSetOutputPortWidth(S, 0, 1);

    ssSetNumSampleTimes(S, 2);
    ssSetNumRWork(S, 1);
    ssSetNumIWork(S, 0);
    ssSetNumPWork(S, 0);
    ssSetNumModes(S, 0);
    ssSetNumNonsampledZCs(S, 0);

    /* Take care when specifying exception free code - see sfuntmpl_doc.c */
    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE);
}



/* Function: mdlInitializeSampleTimes =========================================
 * Abstract:
 *    Two tasks: One continuous, one with discrete sample time of 1.0.
 *
 * Note: This S-function is block based one. To run this S-function in a 
 *       multi-tasking or auto mode, it will have a warning message suggesting
 *       to convert this to PORT_BASED_SAMPLE_TIME S-function.
 *       See sfun_multirate.c file as an example.
 */
static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, CONTINUOUS_SAMPLE_TIME);
    ssSetSampleTime(S, 1, 1.0);

    ssSetOffsetTime(S, 0, 0.0);
    ssSetOffsetTime(S, 1, 0.0);
    ssSetModelReferenceSampleTimeDefaultInheritance(S);
}



#define MDL_INITIALIZE_CONDITIONS
/* Function: mdlInitializeConditions ========================================
 * Abstract:
 *    Initialize both states to one
 */
static void mdlInitializeConditions(SimStruct *S)
{
    real_T *xC0   = ssGetContStates(S);
    real_T *xD0   = ssGetRealDiscStates(S);
    real_T *lasty = ssGetRWork(S);
 
    /* initialize the states to 1.0 */
    xC0[0] = 1.0;
    xD0[0] = 1.0;

    /* Set initial output to initial value of delay */
    lasty[0] = 1.0;
}



/* Function: mdlOutputs =======================================================
 * Abstract:
 *      y = x
 *     If this is a sample hit for the discrete task, set the output to the
 *     value of the discrete state, otherwise, maintain the current output.
 */
static void mdlOutputs(SimStruct *S, int_T tid)
{
    real_T *y     = ssGetOutputPortRealSignal(S,0);
    real_T *xD    = ssGetRealDiscStates(S);
    real_T *lasty = ssGetRWork(S);

    UNUSED_ARG(tid); /* not used in single tasking mode */

    if (ssIsSampleHit(S, 1, tid)) {
        y[0]     = xD[0];
        lasty[0] = xD[0];
    } else {
        y[0] = lasty[0];
    }
}



#define MDL_UPDATE
/* Function: mdlUpdate ======================================================
 * Abstract:
 *      xD = xC
 */
static void mdlUpdate(SimStruct *S, int_T tid)
{
    real_T *xD = ssGetRealDiscStates(S);
    real_T *xC = ssGetContStates(S);
 
    UNUSED_ARG(tid); /* not used in single tasking mode */

    if (ssIsSampleHit(S, 1, tid)) {
        xD[0] = xC[0];
    }
}
 
 
 
#define MDL_DERIVATIVES
/* Function: mdlDerivatives =================================================
 * Abstract:
 *      xdot = u
 */
static void mdlDerivatives(SimStruct *S)
{
    real_T            *dx   = ssGetdX(S);
    InputRealPtrsType uPtrs = ssGetInputPortRealSignalPtrs(S,0);

    dx[0] = U(0);
}



/* Function: mdlTerminate =====================================================
 * Abstract:
 *    No termination needed, but we are required to have this routine.
 */
static void mdlTerminate(SimStruct *S)
{
    UNUSED_ARG(S); /* unused input argument */
}

#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif
