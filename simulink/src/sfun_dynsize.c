/*  File    : sfun_dynsize.c
 *  Abstract:
 *
 *      Example of a Level 2 S-function which implements which accepts
 *      an input of width N and produces an output of width N/2:
 *
 *                   .-------.
 *            u ---->| s-fcn |---(width u/2) ---> y
 *                   `-------'
 *
 *      In addition, if u is unconnected, then the input width is set to 2
 *      and the output width is set to 1.
 *
 *      This S-function is a resembles a 2-to-1 summer with a "memory" block
 *      type delay. It is primarily provided to demonstrate how to work
 *      with dynamically sized vectors.
 *
 *      For more details about S-functions, see src/simulink/sfuntmpl_doc.c
 *
 *  Copyright 1990-2004 The MathWorks, Inc.
 *  $Revision: 1.14.4.2 $
 */


#define S_FUNCTION_NAME  sfun_dynsize
#define S_FUNCTION_LEVEL 2

#include "simstruc.h"




/* Function: mdlInitializeSizes ===============================================
 * Abstract:
 *   Setup sizes of the various vectors.
 */
static void mdlInitializeSizes(SimStruct *S)
{
    ssSetNumSFcnParams(S, 0); /* Number of expected parameters */
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
        return; /* Parameter mismatch will be reported by Simulink */
    }

    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 1);

    if (!ssSetNumInputPorts(S, 1)) return;
    ssSetInputPortDirectFeedThrough(S, 0, 0);

    if (!ssSetNumOutputPorts(S,1)) return;

    if (!ssGetInputPortConnected(S,0)) {
        ssWarning(S,"input is unconnected or grounded, "
                  "setting input width to 2");
        ssSetInputPortWidth(S, 0, 2);
        ssSetOutputPortWidth(S, 0, 1);
    } else {
        ssSetInputPortWidth(S, 0, DYNAMICALLY_SIZED);
        ssSetOutputPortWidth(S, 0, DYNAMICALLY_SIZED);
    }

    if (!ssGetOutputPortConnected(S,0)) {
        ssWarning(S,"output is unconnected or terminated");
    }

    ssSetNumSampleTimes(S, 1);

    ssSetNumRWork(S, DYNAMICALLY_SIZED);
    ssSetNumIWork(S, 0);
    ssSetNumPWork(S, 0);

    ssSetNumModes(S, 0);
    ssSetNumNonsampledZCs( S, 0);

    /* Take care when specifying exception free code - see sfuntmpl_doc.c */
    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE);
}

#if defined(MATLAB_MEX_FILE)
# define MDL_SET_INPUT_PORT_WIDTH
  static void mdlSetInputPortWidth(SimStruct *S, int_T port,
                                    int_T inputPortWidth)
  {
      if (inputPortWidth % 2 != 0) {
          ssSetErrorStatus(S,"Input width must be a multiple of 2");
          return;
      }
      ssSetInputPortWidth(S,port,inputPortWidth);
      ssSetOutputPortWidth(S,port,inputPortWidth/2);
  }

# define MDL_SET_OUTPUT_PORT_WIDTH
  static void mdlSetOutputPortWidth(SimStruct *S, int_T port,
                                     int_T outputPortWidth)
  {
      ssSetInputPortWidth(S,port,2*outputPortWidth);
      ssSetOutputPortWidth(S,port,outputPortWidth);
  }
#endif



/* Function: mdlInitializeSampleTimes =========================================
 * Abstract:
 *    Specifiy that we inherit our sample time from the driving block.
 *    However, we don't execute in minor steps.
 */
static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, FIXED_IN_MINOR_STEP_OFFSET);
    ssSetModelReferenceSampleTimeDefaultInheritance(S);
}



#if defined(MATLAB_MEX_FILE)
# define MDL_SET_WORK_WIDTHS
  static void mdlSetWorkWidths(SimStruct *S)
  {
      ssSetNumRWork(S, ssGetOutputPortWidth(S,0));
  }
#endif /* defined(MATLAB_MEX_FILE) */


/* Function: mdlOutputs =======================================================
 * Abstract:
 *    y = rwork
 */
static void mdlOutputs(SimStruct *S, int_T tid)
{
    int_T  i;
    real_T *y     = ssGetOutputPortRealSignal(S,0);
    int_T  ny     = ssGetOutputPortWidth(S,0);
    real_T *rwork = ssGetRWork(S);

    UNUSED_ARG(tid); /* not used in single tasking mode */

    for (i = 0; i < ny; i++) {
        *y++ = *rwork++;
    }
}



/* Function: mdlUpdate ========================================================
 * Abstract:
 *    Update the rwork's after each major output has been done.
 */
#define MDL_UPDATE
static void mdlUpdate(SimStruct *S, int_T tid)
{
    int_T             i;
    InputRealPtrsType uPtrs  = ssGetInputPortRealSignalPtrs(S,0);
    int_T             ny     = ssGetOutputPortWidth(S,0);
    real_T            *rwork = ssGetRWork(S);

    UNUSED_ARG(tid); /* not used in single tasking mode */

    for (i = 0; i < ny; i++) {
        *rwork++ = *uPtrs[2*i] + *uPtrs[2*i+1];
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



#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif
