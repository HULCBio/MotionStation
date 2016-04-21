/*  File    : sfun_errhdl.c
 *  Abstract:
 *
 *      Example of an S-function which used mdlCheckParameters to
 *      verify parameters are okay.
 *
 *  Copyright 1990-2004 The MathWorks, Inc.
 *  $Revision: 1.16.4.3 $
 */



#define S_FUNCTION_LEVEL 2
#define S_FUNCTION_NAME  sfun_errhdl

#include "simstruc.h"


#define PARAM1(S) ssGetSFcnParam(S,0)
#define IS_PARAM_DOUBLE(pVal) (mxIsNumeric(pVal) && !mxIsLogical(pVal) &&\
!mxIsEmpty(pVal) && !mxIsSparse(pVal) && !mxIsComplex(pVal) && mxIsDouble(pVal))


#if defined(MATLAB_MEX_FILE)
  /* Function: mdlCheckParameters =============================================
   * Abstract:
   *    This routine will be called after mdlInitializeSizes, whenever
   *    parameters change or get re-evaluated. The purpose of this routine is
   *    to verify that the new parameter setting are correct.
   *
   *    You should add a call to this routine from mdlInitalizeSizes
   *    to check the parameters. After setting your sizes elements, you should:
   *       if (ssGetSFcnParamsCount(S) == ssGetNumSFcnParams(S)) {
   *           mdlCheckParameters(S);
   *       }
   */
# define MDL_CHECK_PARAMETERS
  static void mdlCheckParameters(SimStruct *S)
  {
      if (mxGetNumberOfElements(PARAM1(S)) != 1 || !IS_PARAM_DOUBLE(PARAM1(S)) ) {
          ssSetErrorStatus(S,"Parameter to S-function must be a scalar");
          return;
      } else if (mxGetPr(PARAM1(S))[0] < 0) {
          ssSetErrorStatus(S, "Parameter to S-function must be non-negative");
          return;
      }
  }
#endif



/* Function: mdlInitializeSizes ===============================================
 * Abstract:
 *    Call mdlCheckParameters to verify that the parameters are okay,
 *    then setup sizes of the various vectors.
 */
static void mdlInitializeSizes(SimStruct *S)
{
    ssSetNumSFcnParams(    S, 1);  /* Number of expected parameters */

    /*
     * Check parameters passed in, providing the correct number was specified
     * in the S-function dialog box. If an incorrect number of parameters
     * was specified, Simulink will detect the error since ssGetNumSFcnParams
     * and ssGetSFcnParamsCount will differ.
     *   ssGetNumSFcnParams   - This sets the number of parameters your
     *                          S-function expects.
     *   ssGetSFcnParamsCount - This is the number of parameters entered by
     *                          the user in the Simulink S-function dialog box.
     */
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

    /*
     * If there are no errors with the S-function parameters, we continue
     * by setting the remaining sizes. These sizes can (optionally) be a
     * function of the S-function parameters.
     */

    ssSetNumContStates(    S, 0);
    ssSetNumDiscStates(    S, 0);

    if (!ssSetNumInputPorts(S, 1)) return;
    ssSetInputPortWidth(S, 0, 1);
    ssSetInputPortDirectFeedThrough(S, 0, 1);

    if (!ssSetNumOutputPorts(S,1)) return;
    ssSetOutputPortWidth(S, 0, 1);

    ssSetNumSampleTimes(S, 1);
    ssSetNumRWork(S, 0);
    ssSetNumIWork(S, 0);
    ssSetNumPWork(S, 0);
    ssSetNumModes(S, 0);
    ssSetNumNonsampledZCs( S, 0);

    /* Take care when specifying exception free code - see sfuntmpl_doc.c */
    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE);
}



/* Function: mdlInitializeSampleTimes =========================================
 * Abstract:
 *    Specifiy that we inherit our sample time from the driving block.
 */
static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, 0);
    ssSetModelReferenceSampleTimeDefaultInheritance(S);
}


/* Function: mdlOutputs =======================================================
 * Abstract:
 *    y = k * u
 */
static void mdlOutputs(SimStruct *S, int_T tid)
{
    InputRealPtrsType uPtrs = ssGetInputPortRealSignalPtrs(S,0);
    real_T            *y    = ssGetOutputPortRealSignal(S,0);
    real_T            k     = mxGetPr(PARAM1(S))[0];

    UNUSED_ARG(tid); /* not used in single tasking mode */

    y[0] = k * (*uPtrs[0]);
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
