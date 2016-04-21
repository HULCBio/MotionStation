/*  File    : sfun_zc.c
 *  Abstract:
 *
 *      Example of an S-function which has nonsampled zero crossings to
 *      implement abs(u). This S-function is designed to be used with
 *      a variable step solver.
 *
 *  Copyright 1990-2004 The MathWorks, Inc.
 *  $Revision: 1.12.4.2 $
 */


#define S_FUNCTION_NAME  sfun_zc
#define S_FUNCTION_LEVEL 2

#include "simstruc.h"



/* Function: mdlInitializeSizes ===============================================
 * Abstract:
 *   Setup sizes of the various vectors.
 */
static void mdlInitializeSizes(SimStruct *S)
{
    ssSetNumSFcnParams(S, 0);
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
        return; /* Parameter mismatch will be reported by Simulink */
    }

    ssSetNumContStates(    S, 0);
    ssSetNumDiscStates(    S, 0);

    if (!ssSetNumInputPorts(S, 1)) return;
    ssSetInputPortWidth(S, 0, DYNAMICALLY_SIZED);
    ssSetInputPortDirectFeedThrough(S, 0, 1);

    if (!ssSetNumOutputPorts(S,1)) return;
    ssSetOutputPortWidth(S, 0, DYNAMICALLY_SIZED);

    ssSetNumSampleTimes(S, 1);
    ssSetNumRWork(S, 0);
    ssSetNumIWork(S, 0);
    ssSetNumPWork(S, 0);
    ssSetNumModes(S, DYNAMICALLY_SIZED);
    ssSetNumNonsampledZCs(S, DYNAMICALLY_SIZED);

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
    ssSetOffsetTime(S, 0, 0);
    ssSetModelReferenceSampleTimeDefaultInheritance(S);
}



/* Function: mdlOutputs =======================================================
 * Abstract:
 *    y = abs(u)
 */
static void mdlOutputs(SimStruct *S, int_T tid)
{
    int_T             i;
    InputRealPtrsType uPtrs = ssGetInputPortRealSignalPtrs(S,0);
    real_T            *y    = ssGetOutputPortRealSignal(S,0);
    int_T             width = ssGetOutputPortWidth(S,0);
    int_T             *mode = ssGetModeVector(S);

    UNUSED_ARG(tid); /* not used in single tasking mode */

    if (ssIsMajorTimeStep(S)) {
        for (i = 0; i < width; i++) {
            mode[i] = (*uPtrs[i] >= 0.0);
        }
    }

    for (i = 0; i < width; i++) {
        y[i] = mode[i]? (*uPtrs[i]): -(*uPtrs[i]);
    }
}



#if defined(MATLAB_MEX_FILE) || defined(NRT)
/* Function: mdlZeroCrossings =================================================
 * Abstract:
 *    Zero crossing signal to track is the input signal.
 */
#define MDL_ZERO_CROSSINGS
  static void mdlZeroCrossings(SimStruct *S)
  {
      int_T             i;
      real_T            *zcSignals = ssGetNonsampledZCs(S);
      InputRealPtrsType uPtrs      = ssGetInputPortRealSignalPtrs(S,0);
      int_T             nZCSignals = ssGetNumNonsampledZCs(S);

      for (i = 0; i < nZCSignals; i++) {
          zcSignals[i] = *uPtrs[i];
      }
  }
#endif


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
