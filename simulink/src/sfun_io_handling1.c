/*  File    : sfun_io_handling1.c
 *  Abstract:
 *
 *      This s-function and companion TLC file sfun_io_handling1.tlc 
 *      demonstrate the various methods for accessing block inputs
 *      using TLC constructs {%roll, rollthreshold, user control variable,
 *      loop control-variable, signal index, and %foreach}.  The .tlc file
 *      sfun_io_handling1.tlc stresses TLC utility functions 
 *      LibBlock[In|Out]putSignal[Addr] found in blkiolib.tlc by performing
 *      gain operations in a variety of block i/o accessing methods.  
 *
 *      For more details about S-functions, see simulink/src/sfuntmpl_doc.c
 *
 *  Copyright 1990-2004 The MathWorks, Inc.
 *  $Revision: 1.3.4.2 $
 */

#define S_FUNCTION_NAME sfun_io_handling1
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

    if (!ssSetNumOutputPorts(S, 6)) return;

    ssSetInputPortWidth (S, 0, DYNAMICALLY_SIZED);
    ssSetInputPortComplexSignal(S, 0, COMPLEX_INHERITED);

    ssSetOutputPortWidth (S, 0, DYNAMICALLY_SIZED);
    ssSetOutputPortComplexSignal(S, 0, COMPLEX_INHERITED);
    ssSetOutputPortWidth (S, 1, DYNAMICALLY_SIZED);
    ssSetOutputPortComplexSignal(S, 1, COMPLEX_INHERITED);
    ssSetOutputPortWidth (S, 2, DYNAMICALLY_SIZED);
    ssSetOutputPortComplexSignal(S, 2, COMPLEX_INHERITED);
    ssSetOutputPortWidth (S, 3, DYNAMICALLY_SIZED);
    ssSetOutputPortComplexSignal(S, 3, COMPLEX_INHERITED);
    ssSetOutputPortWidth (S, 4, DYNAMICALLY_SIZED);
    ssSetOutputPortComplexSignal(S, 4, COMPLEX_INHERITED);
    ssSetOutputPortWidth (S, 5, DYNAMICALLY_SIZED);
    ssSetOutputPortComplexSignal(S, 5, COMPLEX_INHERITED);

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
 *      y0 = u * 0.1
 *      y1 = u * 0.2
 *      y2 = u * 0.3
 *      y3 = u * 0.4
 *      y4 = u * 0.5
 *      y5 = u * 0.6
 */
static void mdlOutputs(SimStruct *S, int_T tid)
{
    InputRealPtrsType uPtrs  = ssGetInputPortRealSignalPtrs(S,0);
    boolean_T u0IsComplex    = ssGetInputPortComplexSignal(S, 0) == COMPLEX_YES;
    int_T             iWidth = ssGetInputPortWidth(S, 0);
    int_T             i, j;
    real_T            gain   = 0.0;

    for (j=0; j<6; j++) {
       real_T *y = ssGetOutputPortRealSignal(S,j);
       /* Output of jth Port is gain [(j+1)*(0.1)] */
       if (j != 2) {
          gain += 0.1;
       } else {
          /* special case due to normalize numerical precision */
          gain = 0.3;
       }
       for (i=0; i<iWidth; i++) {
          *y++ = uPtrs[i][0] * gain;
          if (u0IsComplex) {
             *y++ = uPtrs[i][1] * gain;
          }
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
