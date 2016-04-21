/*  File    : vdpmex.c
 *  Abstract:
 *
 *      Example MEX-file system for Van der Pol equations
 *
 *      Use this as a template for other MEX-file systems
 *      which are only composed of differential equations.
 *
 *      Syntax  [sys, x0] = vdpmex(t, x, u, flag)
 *
 *      For more details about S-functions, see simulink/src/sfuntmpl_doc.c
 * 
 *  Copyright 1990-2004 The MathWorks, Inc.
 *  $Revision: 1.11.4.2 $
 */

#define S_FUNCTION_NAME  vdpmex
#define S_FUNCTION_LEVEL 2

#include "simstruc.h"


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

    ssSetNumContStates(S, 2);
    ssSetNumDiscStates(S, 0);

    if (!ssSetNumInputPorts(S, 0)) return;

    if (!ssSetNumOutputPorts(S, 0)) return;

    ssSetNumSampleTimes(S, 1);
    ssSetNumRWork(S, 0);
    ssSetNumIWork(S, 0);
    ssSetNumPWork(S, 0);
    ssSetNumModes(S, 0);
    ssSetNumNonsampledZCs(S, 0);

    /* Take care when specifying exception free code - see sfuntmpl_doc.c */
    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE);
}



/* Function: mdlInitializeSampleTimes =========================================
 * Abstract:
 *    S-function is comprised of only continuous sample time elements
 */
static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, CONTINUOUS_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, 0.0);
    ssSetModelReferenceSampleTimeDefaultInheritance(S); 
}



#define MDL_INITIALIZE_CONDITIONS
/* Function: mdlInitializeConditions ========================================
 * Abstract:
 *    Initialize both continuous states to zero
 */
static void mdlInitializeConditions(SimStruct *S)
{
    real_T *x0 = ssGetContStates(S);

    /*  int x2 */
    x0[0] = 0.25;
 
    /*  int x1 */
    x0[1] = 0.25;
}



/* Function: mdlOutputs =======================================================
 * Abstract:
 *      This S-Function has no outputs but the S-Function interface requires
 *      that a mdlOutputs() exist so we have a trivial one here.
 */
static void mdlOutputs(SimStruct *S, int_T tid)
{
    UNUSED_ARG(S);    /* unused input argument */
    UNUSED_ARG(tid); /* not used in single tasking mode */
}



#define MDL_DERIVATIVES
/* Function: mdlDerivatives =================================================
 * Abstract:
 *      xdot(x0) = x0*(1-x1^2) -x1
 *      xdot(x1) = x0
 */
static void mdlDerivatives(SimStruct *S)
{
    real_T *dx   = ssGetdX(S);
    real_T *x    = ssGetContStates(S);

    dx[0] = x[0] * (1.0 - x[1] * x[1]) - x[1];
    dx[1] = x[0];
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
