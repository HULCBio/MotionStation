/* $Revision: 1.1.6.1 $ */
/*
 *  Simulink selected output pattern.
 *
 *  Syntax:  [sys, x0] = stdmamux(t, x, u, flag, switch_box)
 *  This function takes multiple inputs and may be multi-output
 *  depending on the value of the second input port.
 *  This block takes N+1 input. The first N inputs are the
 *  signals. The last signal of the block input is the index value
 *  for the output.
 *
 *  switch_box: The column number is the block output number. The row
 *              number decides how many switching options there are. 
 *              The element values of the block are in the range [0, N], 
 *              where N is the vector length of the input signals of this 
 *              block. This block switches the output at the rising edge
 *              of the trigger signal. When the content of the output is 0,
 *              this block outputs the default value.
 *              When the input value of the second input is i, the
 *              block outputs the value following the row i pattern in
 *              the switch box.
 *              The block keeps the last value if the input is 0.
 *  default_value: The keeping value should be a vector with its length
 *              the same as the column number of the variable switch_box.
 *  The vector size of this block is the same as the column number of
 *  the variable switch_box, as well as the vector size of
 *  keeping_value and ini_value.
 *
 * Wes Wang  Dec. 13, 1995
 * Copyright 1996-2002 The MathWorks, Inc.
 */

#define S_FUNCTION_NAME switchbx

#ifdef MATLAB_MEX_FILE
#include "mex.h"      /* needed for declaration of mexErrMsgTxt */
#endif

/*
 * need to include simstruc.h for the definition of the SimStruct and
 * its associated macro definitions.
 */

#include "simstruc.h"
#include "tmwtypes.h"
#include <math.h>

/* For RTW */
#if defined(RT) || defined(NRT)  
#undef  mexPrintf
#define mexPrintf printf
#endif

/*
 * Defines for easy access of the input parameters
 */

#define NUM_ARGS   2
#define SWITCH_BOX         ssGetArg(S,0)
#define DEFAULT_OUT        ssGetArg(S,1)

/*
 * mdlInitializeSizes - called to initialize the sizes array stored in
 *                      the SimStruct.  The sizes array defines the
 *                      characteristics (number of inputs, outputs,
 *                      states, etc.) of the S-Function.
 */

static void mdlInitializeSizes(SimStruct *S)
{
    /*
     * Set-up size information.
     */ 
    
    if (ssGetNumArgs(S) == NUM_ARGS) {
      int_T i, numoutput;
      numoutput = mxGetN(DEFAULT_OUT) * mxGetM(DEFAULT_OUT);
      if (numoutput < 1) {
#ifdef MATLAB_MEX_FILE
        char_T err_msg[256];
        sprintf(err_msg, "Empty initial variable assignment.");
        mexErrMsgTxt(err_msg);
#endif  
      }
      if (mxGetN(SWITCH_BOX) != numoutput) {
#ifdef MATLAB_MEX_FILE
        char_T err_msg[256];
        sprintf(err_msg, "The column number of Switch_Box must match the vector size of Ini_Value.");
        mexErrMsgTxt(err_msg);
#endif
      }
      ssSetNumContStates(    S, 0);
      ssSetNumDiscStates(    S, 0);
      ssSetNumInputs(        S, -1);
      ssSetNumOutputs(       S, numoutput);
      ssSetDirectFeedThrough(S, 1);
      ssSetNumInputArgs(     S, NUM_ARGS);
      ssSetNumSampleTimes(   S, 1);
      ssSetNumRWork(         S, 0);
      ssSetNumIWork(         S, 0);
      ssSetNumPWork(         S, 0);
    } else {
#ifdef MATLAB_MEX_FILE
 char_T err_msg[256];
      sprintf(err_msg, "Wrong number of input arguments passed to S-function MEX-file.\n"
             "%d input arguments were passed in when expecting %d input arguments.\n", ssGetNumArgs(S) + 4, NUM_ARGS + 4);
   mexErrMsgTxt(err_msg);
#endif
    }
}

/*
 * mdlInitializeSampleTimes - initializes the array of sample times stored in
 *                            the SimStruct associated with this S-Function.
 */

static void mdlInitializeSampleTimes(SimStruct *S)
{
    /*
     * Note, blocks that are continuous in nature should have a single
     * sample time of 0.0.
     */

    ssSetSampleTimeEvent(S, 0, INHERITED_SAMPLE_TIME);
    ssSetOffsetTimeEvent(S, 0, FIXED_IN_MINOR_STEP_OFFSET);
}

/*
 * mdlInitializeConditions - initializes the states for the S-Function
 */

static void mdlInitializeConditions(real_T *x0, SimStruct *S)
{
    /*
     * Initialize the current buffer position and buffer start
     */
}

/*
 * mdlOutputs - computes the outputs of the S-Function
 */

static void mdlOutputs(real_T *y, const real_T *x, const real_T *u, SimStruct *S, int_T tid)
{
    int_T     numoutput       = ssGetNumOutputs(S);
    int_T     numinput        = ssGetNumInputs(S);
    
    int_T     Index;
    int_T     i, out_index, m_switch_box;
    /*
     * acquire the buffer data
     */
    if (ssGetT(S) <= 0.0) {
        for (i=0; i<numoutput; i++)
            y[i] = mxGetPr(DEFAULT_OUT)[i];
    }
    Index = floor(u[numinput - 1] + .5);
    m_switch_box = mxGetM(SWITCH_BOX);
    if ((Index > 0) && (Index <= m_switch_box)) {
        for (i = 0; i < numoutput; i++) {
            out_index = (int_T)mxGetPr(SWITCH_BOX)[Index - 1 + m_switch_box * i];
            if (out_index <= 0) {
               y[i] = mxGetPr(DEFAULT_OUT)[i];
            } else if (Index > numinput - 1) {
#ifdef MATLAB_MEX_FILE
               char_T err_msg[256];
               sprintf(err_msg, "The index number in Switch_Box variable is larger than the signal input vector.");
               mexErrMsgTxt(err_msg);
#endif            
             } else {
                 y[i] = u[out_index-1];
             }
         }
    } else {
        for (i = 0; i < numoutput; i++) {
            y[i] = mxGetPr(DEFAULT_OUT)[i];
        }
    }
}

/*
 * mdlUpdate - computes the discrete states of the S-Function
 */

static void mdlUpdate(real_T *x, const real_T *u, SimStruct *S, int_T tid)
{
}

/*
 * mdlDerivatives - computes the derivatives of the S-Function
 */

static void mdlDerivatives(real_T *dx, const real_T *x, const real_T *u, SimStruct *S, int_T tid)
{
}

/*
 * mdlTerminate - called at termination of model execution.
 */

static void mdlTerminate(SimStruct *S)
{
}

#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-File interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif
