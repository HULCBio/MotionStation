/*  File    : dlimintc.c
 *  Abstract:
 *
 *      Example MEX-file for a discrete-time limited integrator.
 *
 *      Syntax:  [sys, x0] = dlimintc(t,x,u,flag,lb,ub,x0,ts)
 *
 *      For more details about S-functions, see simulink/src/sfuntmpl_doc.c
 *
 *  Copyright 1990-2004 The MathWorks, Inc.
 *  $Revision: 1.13.4.3 $
 */

#define S_FUNCTION_NAME dlimintc
#define S_FUNCTION_LEVEL 2

#include "simstruc.h"

#define U(element) (*uPtrs[element])  /* Pointer to Input Port0 */

#define LB_IDX 0
#define LB_PARAM(S) ssGetSFcnParam(S,LB_IDX)
 
#define UB_IDX 1
#define UB_PARAM(S) ssGetSFcnParam(S,UB_IDX)
 
#define X0_IDX 2
#define X0_PARAM(S) ssGetSFcnParam(S,X0_IDX)
 
#define TS_IDX 3
#define TS_PARAM(S) ssGetSFcnParam(S,TS_IDX)
 
#define NPARAMS 4


/*====================*
 * S-function methods *
 *====================*/
 
#define MDL_CHECK_PARAMETERS
#if defined(MDL_CHECK_PARAMETERS) && defined(MATLAB_MEX_FILE)
  /* Function: mdlCheckParameters =============================================
   * Abstract:
   *    Validate our parameters to verify they are okay.
   */
  static void mdlCheckParameters(SimStruct *S)
  {
      /* Check 1st parameter: Lower Bound (LB) parameter */
      {
          if (!mxIsDouble(LB_PARAM(S)) ||
              mxGetNumberOfElements(LB_PARAM(S)) != 1) {
              ssSetErrorStatus(S,"1st parameter to S-function must be a "
                               "scalar \"lower bound\" which limits "
                               "the lower value of the integrator");
              return;
          }
      }
 
      /* Check 2nd parameter: Upper Bound (UB) parameter */
      {
          if (!mxIsDouble(UB_PARAM(S)) ||
              mxGetNumberOfElements(UB_PARAM(S)) != 1) {
              ssSetErrorStatus(S,"2nd parameter to S-function must be a "
                               "scalar \"upper bound\" which limits "
                               "the upper value of the integrator");
              return;
          }
      }
 
      /* Check 3rd parameter: Initial Value (X0) of integrator */
      {
          if (!mxIsDouble(X0_PARAM(S)) ||
              mxGetNumberOfElements(X0_PARAM(S)) != 1) {
              ssSetErrorStatus(S,"3rd parameter to S-function must be a "
                               "scalar \"initial value\" to "
                               "initialize the integrator");
              return;
          }
      }

      /* Check 4th parameter: Sample Time (TS) of integrator */
      {
          if (!mxIsDouble(TS_PARAM(S)) ||
              mxGetNumberOfElements(TS_PARAM(S)) != 1) {
              ssSetErrorStatus(S,"4th parameter to S-function must be a "
                               "scalar \"Sample Time\" to "
                               "execute the S-function");
              return;
          }
      }
  }
#endif /* MDL_CHECK_PARAMETERS */
 


/* Function: mdlInitializeSizes ===============================================
 * Abstract:
 *    The sizes information is used by Simulink to determine the S-function
 *    block's characteristics (number of inputs, outputs, states, etc.).
 */
static void mdlInitializeSizes(SimStruct *S)
{
    ssSetNumSFcnParams(S, NPARAMS);  /* Number of expected parameters */
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
            switch ( iParam )
            {
              case TS_IDX:
                
                ssSetSFcnParamTunable( S, iParam, 0 );
                break;

              default:
                ssSetSFcnParamTunable( S, iParam, SS_PRM_SIM_ONLY_TUNABLE );
                break;
            }
        }
    }

    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 1);

    if (!ssSetNumInputPorts(S, 1)) return;
    ssSetInputPortWidth(S, 0, 1);
    ssSetInputPortDirectFeedThrough(S, 0, 0);

    if (!ssSetNumOutputPorts(S, 1)) return;
    ssSetOutputPortWidth(S, 0, 1);

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
 *    One sample time, and it's passed in as the fourth S-function parameter
 */
static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, *mxGetPr(TS_PARAM(S)));
    ssSetOffsetTime(S, 0, 0.0);
    ssSetModelReferenceSampleTimeDisallowInheritance(S);         
}



#define MDL_INITIALIZE_CONDITIONS
/* Function: mdlInitializeConditions ========================================
 * Abstract:
 *    Initialize both continuous states to zero
 */
static void mdlInitializeConditions(SimStruct *S)
{
    real_T *x0 = ssGetRealDiscStates(S);

    /* 
     * The initial condition is passed in as the third 
     * S-function parameter
     */
    x0[0] = *mxGetPr(X0_PARAM(S));
}



/* Function: mdlOutputs =======================================================
 * Abstract:
 *      y = x
 */
static void mdlOutputs(SimStruct *S, int_T tid)
{
    real_T *y = ssGetOutputPortRealSignal(S,0);
    real_T *x = ssGetRealDiscStates(S);

    /* Return the current state as the output */
    y[0] = x[0];
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
    real_T            lb    = *mxGetPr(LB_PARAM(S));
    real_T            ub    = *mxGetPr(UB_PARAM(S));
    real_T            ts    = *mxGetPr(TS_PARAM(S));
    real_T            *x    = ssGetRealDiscStates(S);
    InputRealPtrsType uPtrs = ssGetInputPortRealSignalPtrs(S,0);
        
    /*
     * If the current state is outside of the limits, and the input
     * will force it to be further out of bounds, don't update the
     * discrete state, effectively shutting the integrator off.
     * Otherwise, integrate normally.
     */
        
    if (!((x[0] <= lb && U(0) < 0.0) || (x[0] >= ub && U(0) > 0.0))) {
        x[0] += U(0) * ts;
    }
}



/* Function: mdlTerminate =====================================================
 * Abstract:
 *    No termination needed, but we are required to have this routine.
 */
static void mdlTerminate(SimStruct *S)
{
}

#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif
