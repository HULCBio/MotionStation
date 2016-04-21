 /*  File    : sfunmem.c
 *  Abstract:
 *
 *      A one integration-step delay and hold "memory" function.
 *
 *      Syntax:  [sys, x0] = sfunmem(t,x,u,flag)
 *
 *      This file is designed to be used in a Simulink S-Function block.
 *      It performs a one integration-step delay and hold "memory" function.
 *      Thus, no matter how large or small the last time increment was in
 *      the integration process, this function will hold the input variable
 *      from the last integration step.
 *
 *      Use this function with a clock as input to get the step-size at each
 *      step of a simulation.
 *
 *      This function is similar to the built-in "Memory" block.
 *
 *      For more details about S-functions, see simulink/src/sfuntmpl_doc.c
 *
 *  Copyright 1990-2004 The MathWorks, Inc.
 *  $Revision: 1.16.4.2 $
 */

#define S_FUNCTION_NAME sfunmem
#define S_FUNCTION_LEVEL 2

#include <string.h>
#include "simstruc.h"

#define U(element) (*uPtrs[element])  /* Pointer to Input Port0 */

/*====================*
 * S-function methods *
 *====================*/

/* Function: mdlInitializeSizes ===============================================
 * Abstract:
 *    Call mdlCheckParameters to verify that the parameters are okay,
 *    then setup sizes of the various vectors.
 */
static void mdlInitializeSizes(SimStruct *S)
{
    ssSetNumSFcnParams(S, 0);  /* Number of expected parameters */
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
        return; /* Parameter mismatch will be reported by Simulink */
    }

    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 0);

    if (!ssSetNumInputPorts(S, 1)) return;
    ssSetInputPortWidth (S, 0, DYNAMICALLY_SIZED);
    ssSetInputPortDirectFeedThrough(S, 0, 0);

    if (!ssSetNumOutputPorts(S, 1)) return;
    ssSetOutputPortWidth(S, 0, DYNAMICALLY_SIZED);

    ssSetNumSampleTimes(S, 1);
    ssSetNumRWork(S, DYNAMICALLY_SIZED);
    ssSetNumIWork(S, 0);
    ssSetNumPWork(S, 0);
    ssSetNumModes(S, 0);
    ssSetNumNonsampledZCs(S, 0);

    /* Take care when specifying exception free code - see sfuntmpl_doc.c */
    ssSetOptions(S,
                 SS_OPTION_WORKS_WITH_CODE_REUSE |
                 SS_OPTION_EXCEPTION_FREE_CODE |
                 SS_OPTION_USE_TLC_WITH_ACCELERATOR);
}



/* Function: mdlInitializeSampleTimes =========================================
 * Abstract:
 *    S-function is continuous, fixed in minor time steps.
 */
static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, CONTINUOUS_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, FIXED_IN_MINOR_STEP_OFFSET);
    ssSetModelReferenceSampleTimeDefaultInheritance(S);
}



#define MDL_INITIALIZE_CONDITIONS
/* Function: mdlInitializeConditions ========================================
 * Abstract:
 *    The memory state is stored in the RWork vector, initialize it to zero
 */
static void mdlInitializeConditions(SimStruct *S)
{
    real_T *rwork = ssGetRWork(S);
    int_T  i;
 
    for (i = 0; i < ssGetNumRWork(S); i++) {
        rwork[i] = 0.0;
    }
}
 
 

/* Function: mdlOutputs =======================================================
 * Abstract:
 *
 *      y = rwork
 */
static void mdlOutputs(SimStruct *S, int_T tid)
{
    real_T *y     = ssGetOutputPortRealSignal(S,0);
    real_T *rwork = ssGetRWork(S);
    int_T  i;
 
    UNUSED_ARG(tid); /* not used in single tasking mode */

    /* Output the last input, which is stored in the real work vector */
    for (i = 0; i < ssGetNumRWork(S); i++) {
        y[i] = rwork[i];
    }
}



#define MDL_UPDATE
/* Function: mdlUpdate ========================================================
 * Abstract:
 *    This function is called once for every major integration time step.
 *    Discrete states are typically updated here, but this function is useful
 *    for performing any tasks that should only take place once per integration
 *    step.
 */
static void mdlUpdate(SimStruct *S, int_T tid)
{
    InputRealPtrsType uPtrs  = ssGetInputPortRealSignalPtrs(S,0);
    real_T            *rwork = ssGetRWork(S);
    int_T             i;
 
    UNUSED_ARG(tid); /* not used in single tasking mode */

    /* Just set memory to last input */
    for (i = 0; i < ssGetNumRWork(S); i++) {
        rwork[i] = U(i);
    }
}



/* Function: mdlTerminate =====================================================
 * Abstract:
 *    No termination needed, but we are required to have this routine.
 */
static void mdlTerminate(SimStruct *S)
{
    UNUSED_ARG(S); /* unused input argument */
}

#if defined(MATLAB_MEX_FILE)
#define MDL_RTW
/* Function: mdlRTW ===========================================================
 * Abstract:
 *    It registers the name "InputAtLastUpdate" for the RWork vector.
 */
static void mdlRTW(SimStruct *S)
{
    if (!ssWriteRTWWorkVect(S, "RWork", 1 /* nNames */,
                            "InputAtLastUpdate", ssGetNumRWork(S))) {
        return;
    }
    /*
      This registration of the symbol "InputAtLastUpdate" allows sfunmem.tlc to
      call LibBlockRWork(InputAtLastUpdate,[...])
     */

}
#endif /* MDL_RTW */

#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif
