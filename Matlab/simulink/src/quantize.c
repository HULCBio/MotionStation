/*  File    : quantize.c
 *  Abstract:
 *
 *      Example mex-file for a vectorized quantizer block.
 *      Quantizes the input into steps as specified by the
 *      quantization interval parameter, q.
 *
 *      [sys, x0] = quantize(t, x, u, flag, q);
 *
 *      For more details about S-functions, see simulink/src/sfuntmpl_doc.c
 *
 *  Copyright 1990-2004 The MathWorks, Inc.
 *  $Revision: 1.12.4.3 $
 */

#define S_FUNCTION_NAME quantize
#define S_FUNCTION_LEVEL 2

#include <math.h>
#include <string.h>
#include "simstruc.h"

#define U(element) (*uPtrs[element])  /* Pointer to Input Port0 */

#define QUANTIZATION_IDX 0
#define QUANTIZATION_PARAM(S) ssGetSFcnParam(S,QUANTIZATION_IDX)

#define NPARAMS 1

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
      /* Check 1st parameter: quantization interval */
      {
          if (!mxIsDouble(QUANTIZATION_PARAM(S))) {
              ssSetErrorStatus(S,"Parameter to S-function must be a "
                               "double \"quantization\" interval.  The "
                               "interval can be either a scalar or vector");
              return;
          }

          if ((mxGetM(QUANTIZATION_PARAM(S)) > 1) && 
              (mxGetN(QUANTIZATION_PARAM(S)) > 1)) {
              ssSetErrorStatus(S,"Parameter to S-function must be either "
                               "a scalar or a vector.");
              return;
          }
      }
  }
#endif /* MDL_CHECK_PARAMETERS */



/* Function: mdlInitializeSizes ===============================================
 * Abstract:
 *    Call mdlCheckParameters to verify that the parameters are okay,
 *    then setup sizes of the various vectors.
 */
static void mdlInitializeSizes(SimStruct *S)
{
    int_T intervalSize;

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
            ssSetSFcnParamTunable( S, iParam, SS_PRM_SIM_ONLY_TUNABLE );
        }
    }

    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 0);

    if (!ssSetNumInputPorts(S, 1)) return;
    ssSetInputPortDirectFeedThrough(S, 0, 1);

    if (!ssSetNumOutputPorts(S, 1)) return;

    /*
     * If the quantization interval is a vector, set the width
     * of the input and the output to be the same size as it.
     * Otherwise, set the widths to be DYNAMICALLY_SIZED.
     */
    intervalSize = (mxGetM(QUANTIZATION_PARAM(S)) *
                    mxGetN(QUANTIZATION_PARAM(S)));

    if (intervalSize > 1) {
        ssSetInputPortWidth (S, 0, intervalSize);
        ssSetOutputPortWidth(S, 0, intervalSize);
    } else {
        ssSetInputPortWidth (S, 0, DYNAMICALLY_SIZED);
        ssSetOutputPortWidth(S, 0, DYNAMICALLY_SIZED);
    }

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
 *    Specifiy that we inherit our sample time from the driving block.
 */
static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, 0.0);
    ssSetModelReferenceSampleTimeDefaultInheritance(S);
}



/* Function: mdlOutputs =======================================================
 * Abstract:
 *
 *      y = q * floor(fabs(u/q) + 0.5) * (u >= 0 ? 1.0 : -1.0);
 */
static void mdlOutputs(SimStruct *S, int_T tid)
{
    InputRealPtrsType uPtrs        = ssGetInputPortRealSignalPtrs(S,0);
    real_T            *y           = ssGetOutputPortRealSignal(S,0);
    int_T             yWidth       = ssGetOutputPortWidth(S,0);
    const mxArray     *quant       = (const mxArray *) QUANTIZATION_PARAM(S);
    int_T             intervalSize = mxGetM (quant) * mxGetN (quant);
    const real_T      *q           = mxGetPr(quant);
    int_T             i;

    UNUSED_ARG(tid); /* not used in single tasking mode */

    if (intervalSize == 1) {
        for (i = 0; i < yWidth; i++) {
            y[i] = q[0] * floor(fabs(U(i)/q[0]) + 0.5) * 
                   (U(i) >= 0.0 ? 1.0 : -1.0);
        }
    } else {
        for (i = 0; i < yWidth; i++) {
            y[i] = q[i] * floor(fabs(U(i)/q[i]) + 0.5) * 
                   (U(i) >= 0.0 ? 1.0 : -1.0);
        }
    }
}



/* Function: mdlTerminate ===================================================== * Abstract:
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
