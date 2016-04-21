/*  File    : sfun_io_handling2.c
 *  Abstract:
 *
 *      This s-function and companion TLC file sfun_io_handling2.tlc 
 *      demonstrate accessing block inputs using the TLC construct
 *      user-control variable (ucv) with the native C for loop construct
 *      instead of the TLC %roll construct.  This s-function requires
 *      contiguous inputs.
 *
 *      For more details about S-functions, see simulink/src/sfuntmpl_doc.c
 *
 *  Copyright 1990-2004 The MathWorks, Inc.
 *  $Revision: 1.4.4.2 $
 */

#define S_FUNCTION_NAME sfun_io_handling2
#define S_FUNCTION_LEVEL 2

#include <math.h>
#include <string.h>
#include "simstruc.h"

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
    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 0);

    if (!ssSetNumInputPorts(S, 1)) return;
    ssSetInputPortDirectFeedThrough(S, 0, 1);

    if (!ssSetNumOutputPorts(S, 1)) return;

    ssSetInputPortWidth (S, 0, DYNAMICALLY_SIZED);
    ssSetInputPortComplexSignal(S, 0, COMPLEX_INHERITED);
    ssSetInputPortRequiredContiguous(S, 0, 1);

    ssSetOutputPortWidth (S, 0, DYNAMICALLY_SIZED);
    ssSetOutputPortComplexSignal(S, 0, COMPLEX_INHERITED);

    ssSetNumSampleTimes(S, 1);
    ssSetNumRWork(S, 0);
    ssSetNumIWork(S, 0);
    ssSetNumPWork(S, 0);
    ssSetNumModes(S, 0);
    ssSetNumNonsampledZCs(S, 0);

    /* Take care when specifying exception free code - see sfuntmpl_doc.c */
    ssSetOptions(S,
                 SS_OPTION_WORKS_WITH_CODE_REUSE |
                 SS_OPTION_USE_TLC_WITH_ACCELERATOR |
                 SS_OPTION_EXCEPTION_FREE_CODE);
}


#if defined(MATLAB_MEX_FILE)
# define MDL_SET_INPUT_PORT_WIDTH
  static void mdlSetInputPortWidth(SimStruct *S, int_T port,
                                    int_T inputPortWidth)
  {
      ssSetInputPortWidth(S,port,inputPortWidth);
  }
# define MDL_SET_OUTPUT_PORT_WIDTH
  static void mdlSetOutputPortWidth(SimStruct *S, int_T port,
                                     int_T outputPortWidth)
  {
      ssSetOutputPortWidth(S,port,ssGetInputPortWidth(S,0));
  }
#endif

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
 *      y0 = u * 0.7
 */
static void mdlOutputs(SimStruct *S, int_T tid)
{
    const real_T      *u     = (const real_T *) ssGetInputPortSignal(S,0);
    boolean_T u0IsComplex    = ssGetInputPortComplexSignal(S, 0) == COMPLEX_YES;
    int_T             iWidth = ssGetInputPortWidth(S, 0);
    int_T             i;
    real_T            gain   = 0.7;

    real_T *y = ssGetOutputPortRealSignal(S,0);
    for (i=0; i<iWidth; i++) {
       *y++ = *u++ * gain;
       if (u0IsComplex) {
          *y++ = *u++ * gain;
       }
    }
}

static void mdlTerminate(SimStruct *S)
{
}


#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif
