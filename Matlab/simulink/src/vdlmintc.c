/*  File    :  vdlmintc.c
 *  Abstract:
 *
 *      Example MEX-file for a discrete-time vectorized limited integrator.
 *
 *      For more details about S-functions, see simulink/src/sfuntmpl_doc.c
 *
 *  Copyright 1990-2004 The MathWorks, Inc.
 *  $Revision: 1.13.4.3 $
 */

#define S_FUNCTION_NAME vdlmintc
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
   *    If the parameter matrices are not all vectors of the same length
   *    report error back to Simulink
   */
  static void mdlCheckParameters(SimStruct *S)
  {
      int_T sizeLB = mxGetNumberOfElements(LB_PARAM(S));

      /* First three parameter must be vectors */
      {
          if (((mxGetN(LB_PARAM(S)) != 1) && (mxGetM(LB_PARAM(S)) != 1)) ||
              ((mxGetM(UB_PARAM(S)) != 1) && (mxGetM(UB_PARAM(S)) != 1)) ||
              ((mxGetM(X0_PARAM(S)) != 1) && (mxGetM(X0_PARAM(S)) != 1))) {
              ssSetErrorStatus(S,"First three parameter to S-function must be "
                               "vectors");
              return;
          }
      }

      /* First three parameters must be the same length */
      {
          if ((sizeLB != mxGetNumberOfElements(UB_PARAM(S))) || 
              (sizeLB != mxGetNumberOfElements(X0_PARAM(S)))) {
              ssSetErrorStatus(S,"First three parameters to S-function "
                               "must be the same length");
              return;
          }
      }
 
      /* Empty matrices not allowed (LB, UB, X0) */
      {
          if (sizeLB == 0) {
              ssSetErrorStatus(S,"First three parameters to S-function "
                               "cannot be empty matrix");
              return;
          }
      }
 
      /* Check 4th parameter: Sample Time (TS) */
      {
          if (mxGetNumberOfElements(TS_PARAM(S)) != 1) {
              ssSetErrorStatus(S,"4th parameter to S-function must be a "
                               "scalar \"Sample Time\"");
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
    int_T sizeLB;
 
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

    sizeLB = mxGetNumberOfElements(LB_PARAM(S));

    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, DYNAMICALLY_SIZED);

    if (!ssSetNumInputPorts(S, 1)) return;
    ssSetInputPortWidth(S, 0, DYNAMICALLY_SIZED);
    ssSetInputPortDirectFeedThrough(S, 0, 0);

    if (!ssSetNumOutputPorts(S, 1)) return;
    ssSetOutputPortWidth(S, 0, DYNAMICALLY_SIZED);

    ssSetNumSampleTimes(S, 1);
    ssSetNumRWork(S, 0);
    ssSetNumIWork(S, 0);
    ssSetNumPWork(S, 0);
    ssSetNumModes(S, 0);
    ssSetNumNonsampledZCs(S, 0);

    /*
     * if the length of the parameters is not scalar, fix
     * the input, output, and states width
     */
    if (sizeLB > 1) {
        ssSetNumDiscStates(S, sizeLB);
        ssSetInputPortWidth(S, 0, sizeLB);
        ssSetOutputPortWidth(S, 0, sizeLB);
    }

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
 *    All that has to be done here is to return the n initial
 *    conditions in the X0 vector.  If this is a scalar, and the
 *    number of states is not 1, Simulink automatically propogates
 *    the initial condition to all states.  If this is a vector,
 *    then all that needs to be done is to copy it to the x0 array,
 *    since the number of states will be equal to the length of
 *    this vector.
 */
static void mdlInitializeConditions(SimStruct *S)
{
    real_T *x0    = ssGetRealDiscStates(S);
    int_T  sizeX0 = mxGetNumberOfElements(X0_PARAM(S));
    real_T *pX0   = mxGetPr(X0_PARAM(S));
    int_T  i;

    for (i = 0; i < sizeX0; i++) {
        *x0++ = *pX0++;
    }
}



/* Function: mdlOutputs =======================================================
 * Abstract:
 *      y = x
 */
static void mdlOutputs(SimStruct *S, int_T tid)
{
    real_T *y       = ssGetOutputPortRealSignal(S,0);
    real_T *x       = ssGetRealDiscStates(S);
    int_T  nOutputs = ssGetOutputPortWidth(S, 0);
    int_T  i;

    /* Propagate the discrete state to the output vector */
    for (i = 0; i < nOutputs; i++) {
      *y++ = *x++;
    }
}



#define MDL_UPDATE
/* Function: mdlUpdate ======================================================
 * Abstract:
 *     If this is a sample hit, update the discrete states (i.e.
 *     perform the discrete integration of the input signal)
 */
static void mdlUpdate(SimStruct *S, int_T tid)
{
    real_T            *x       = ssGetRealDiscStates(S);
    InputRealPtrsType uPtrs    = ssGetInputPortRealSignalPtrs(S,0);

    real_T *u     = (real_T *) &U(0);
    real_T *lb    = mxGetPr(LB_PARAM(S));
    real_T *ub    = mxGetPr(UB_PARAM(S));
    real_T ts     = *mxGetPr(TS_PARAM(S));
    int_T sizeLB  = mxGetNumberOfElements(LB_PARAM(S));
    int_T nStates = ssGetNumDiscStates(S);
    int_T i;
       
    /*
     * If the parameters are scalars, the apply bounds to all states;
     * otherwise, apply individual bounds to each state.
     */
 
    if (sizeLB == 1) {
      for (i = 0; i < nStates; i++, x++, u++) {
        if (!((*x <= *lb && *u < 0.0) || (*x >= *ub && *u > 0.0))) {
          *x += *u * ts;
        }
      }
    } else {
      for (i = 0; i < nStates; i++, x++, u++, lb++, ub++) {
        if (!((*x <= *lb && *u < 0.0) || (*x >= *ub && *u > 0.0))) {
          *x += *u * ts;
        }
      }
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
