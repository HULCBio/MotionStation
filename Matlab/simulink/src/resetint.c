/*  File    : resetint.c
 *  Abstract:
 *
 *      Example of a integerator. This integrator has an input port
 *      width of three where the first element is the signal being 
 *      integrated, the second element is the reset signal, and the
 *      third element is the value to reset to.
 *
 *  Copyright 1990-2004 The MathWorks, Inc.
 *  $Revision: 1.10.4.3 $
 */


#define S_FUNCTION_LEVEL 2
#define S_FUNCTION_NAME  resetint
#include "simstruc.h"

/*
 * Defines for easy access of the X0 matrix which is passed in
 */

#define X0(S) ssGetSFcnParam(S, 0)



#if defined(MATLAB_MEX_FILE)
  /* Function: mdlCheckParameters =============================================
   * Abstract:
   *    This routine will be called after mdlInitializeSizes, whenever
   *    parameters change or get re-evaluated. The purpose of this routine is
   *    to verify that the new parameter setting are correct.
   */
# define MDL_CHECK_PARAMETERS
  static void mdlCheckParameters(SimStruct *S)
  {
      if (!mxIsDouble(X0(S)) ||
          mxGetNumberOfElements(X0(S)) != 1) {
          ssSetErrorStatus(S,"Parameter to S-function must be a "
                           "scalar \"X0\" inital condition value");
          return;
      }
  }
#endif



/* Function: mdlInitializeSizes ===============================================
 * Abstract:
 *    The sizes information is used by Simulink to determine the S-function
 *    block's characteristics (number of inputs, outputs, states, etc.).
 */
static void mdlInitializeSizes(SimStruct *S)
{
    ssSetNumSFcnParams(S, 1);  /* Number of expected parameters */
#if defined(MATLAB_MEX_FILE)
    if (ssGetNumSFcnParams(S) == ssGetSFcnParamsCount(S)) {
        mdlCheckParameters(S);
        if (ssGetErrorStatus(S) != NULL) {
            return;
        }
    } else {
        return; /* Parameter mismatch will be reported by Simulink */
    }
#endif

    {
        int iParam = 0;
        int nParam = ssGetNumSFcnParams(S);

        for ( iParam = 0; iParam < nParam; iParam++ )
        {
            ssSetSFcnParamTunable( S, iParam, SS_PRM_SIM_ONLY_TUNABLE );
        }
    }

    ssSetNumContStates(S, 1);
    ssSetNumDiscStates(S, 0);

    if (!ssSetNumInputPorts(S, 1)) return;
    ssSetInputPortWidth(S, 0, 3);
    ssSetInputPortDirectFeedThrough(S, 0, 0);

    if (!ssSetNumOutputPorts(S, 1)) return;
    ssSetOutputPortWidth(S, 0, 1);

    ssSetNumSampleTimes(   S, 1);
    ssSetNumRWork(         S, 0);
    ssSetNumIWork(         S, 0);
    ssSetNumPWork(         S, 0);
    ssSetNumModes(S, 0);
    ssSetNumNonsampledZCs(S, 0);

    /* Take care when specifying exception free code - see sfuntmpl_doc.c */
    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE);
}



/* Function: mdlInitializeSampleTimes =========================================
 * Abstract:
 *    Specifiy that we inherit our sample time from the driving block.
 */
static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, CONTINUOUS_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, 0.0);
    ssSetModelReferenceSampleTimeDefaultInheritance(S);
}



#define MDL_INITIALIZE_CONDITIONS   /* Change to #undef to remove function */
#if defined(MDL_INITIALIZE_CONDITIONS)
  /* Function: mdlInitializeConditions ========================================
   * Abstract:
   *    Initialize the state. Note, that if this S-function is placed
   *    with in an enabled subsystem which is configured to reset states,
   *    this routine will be called during the reset of the states.
   */
  static void mdlInitializeConditions(SimStruct *S)
  {
      real_T *x0 = ssGetContStates(S);
      *x0 = mxGetPr(X0(S))[0];
  }
#endif /* MDL_INITIALIZE_CONDITIONS */



/* Function: mdlOutputs =======================================================
 * Abstract:
 *      The output of the reset integrator is the current state
 */
static void mdlOutputs(SimStruct *S, int_T tid)
{
    real_T *y = ssGetOutputPortRealSignal(S,0);
    real_T *x = ssGetContStates(S);
    y[0] = x[0];
}



#define MDL_UPDATE  /* Change to #undef to remove function */
#if defined(MDL_UPDATE)
  /* Function: mdlUpdate ======================================================
   * Abstract:
   *    This function is called once for every major integration time step.
   *    If input element two is a nonzero value, reset the state of the
   *    integrator to the value of the third input element.
   */
  static void mdlUpdate(SimStruct *S, int_T tid)
  {
      InputRealPtrsType uPtrs = ssGetInputPortRealSignalPtrs(S,0);
      real_T            *x    = ssGetContStates(S);

      if (*uPtrs[1] != 0.0) {
          x[0] = *uPtrs[2];
          /*
           * It is important to tell the solvers that the state has
           * been changed by us so they can reset their derivative "cache" 
           * from the last time step.
           */
          ssSetSolverNeedsReset(S);
      }
  }
#endif /* MDL_UPDATE */



#define MDL_DERIVATIVES  /* Change to #undef to remove function */
#if defined(MDL_DERIVATIVES)
  /* Function: mdlDerivatives =================================================
   * Abstract:
   *     Compute the derivatives, dx, for a basic integrator
   */
  static void mdlDerivatives(SimStruct *S)
  {
      real_T            *dx   = ssGetdX(S);
      InputRealPtrsType uPtrs = ssGetInputPortRealSignalPtrs(S,0);
      
      dx[0] = *uPtrs[0];
  }

#endif /* MDL_DERIVATIVES */



/* Function: mdlTerminate =====================================================
 * Abstract:
 *    In this function, you should perform any actions that are necessary
 *    at the termination of a simulation.  For example, if memory was allocated
 *    in mdlInitializeSizes or mdlStart, this is the place to free it.
 */
static void mdlTerminate(SimStruct *S)
{
}


#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif
