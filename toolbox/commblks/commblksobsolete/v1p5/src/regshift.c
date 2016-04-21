/* $Revision: 1.1.6.1 $ */
/*
 * REGSHIFT   A Simulink triggered register_buff shift
 *
 *           Syntax:  [sys, x0] = regshift(t,x,u,flag,outDelay,tirgThreshold)
 *  This function has two inputs and a number of outputs. The first input is
 *  the signal to be stored and output. The second signal is the clock pulse.
 *  The function refreshes its register_buff and outputs only at the rising 
 *  edge of the clock pulse. The function assigns a maximum delay number in 
 *  outDelay as its register numebr. When the function finishes refreshing all
 *  registers, it is called a cycle.
 *
 *  outDelay is a scalar or vector which contains integers of desired delay
 *           steps from the input. The size of the vector determines the
 *           size of the output.
 *  trigThreshold is the threshold in detecting the rising edge of the clock
 *          pulse.
 *  The size of the output of this function is the size of outDelay pulse one.
 *  Each output element outputs the delay step as indicated in the corrsponding
 *  value in outDelay. The last output is zero and is one only at the time when
 *  the register_buff and output are triggered in a complete cycle (a cycle of
 *  complete a refresh cycle). The pulse keeps the same length as the input
 *  trigger pulse.
 *
 * Wes Wang  August 22, 1994
 * Copyright 1996-2002 The MathWorks, Inc.
 */

#define S_FUNCTION_NAME regshift

#ifdef MATLAB_MEX_FILE
#include "mex.h"      /* needed for declaration of mexErrMsgTxt */
#endif

/*
 * need to include simstruc.h for the definition of the SimStruct and
 * its associated macro definitions.
 */

#include "simstruc.h"
#include "tmwtypes.h"

/* For RTW */
#if defined(RT) || defined(NRT)  
#undef  mexPrintf
#define mexPrintf printf
#endif

/*
 * Defines for easy access of the input parameters
 */

#define NUM_ARGS   2
#define REGISTER_DELAY ssGetArg(S,0)
#define TRIG_THRESHOLD     ssGetArg(S,1)

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
      int_T i, regDelay, numOutput, maxDelay;
      numOutput = mxGetN(REGISTER_DELAY) * mxGetM(REGISTER_DELAY);
      if (numOutput < 1) {
#ifdef MATLAB_MEX_FILE
        char_T err_msg[256];
        sprintf(err_msg, "Output buffer is empty");
        mexErrMsgTxt(err_msg);
#endif  
      }
       
      maxDelay = 1;
      for(i=0; i<numOutput; i++) {
        regDelay = (int_T)(mxGetPr(REGISTER_DELAY)[i]);
        maxDelay = (maxDelay > regDelay) ? maxDelay : regDelay;
      }
      ssSetNumContStates(    S, 0);
      ssSetNumDiscStates(    S, 0);
      ssSetNumInputs(        S, 2);
      ssSetNumOutputs(       S, 1 + numOutput);
      ssSetDirectFeedThrough(S, 1);
      ssSetNumInputArgs(     S, NUM_ARGS);
      ssSetNumSampleTimes(   S, 1);
      ssSetNumRWork(         S, maxDelay+1);
      ssSetNumIWork(         S, 2);
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
    real_T *register_buff       = ssGetRWork(S);

    int_T    *regIndex       = ssGetIWork(S);
    int_T    *lastTrig       = ssGetIWork(S) + 1;    

    int_T     numOutput      = ssGetNumOutputs(S);
    int_T     maxDelay       = ssGetNumRWork(S) - 1;
    
    real_T *lastTime       = ssGetRWork(S) + maxDelay;
    
    int_T i;
    
    /* 
     * Initialize the register_buff to all zeros.
     */
    
    for (i = 0; i < maxDelay; i++)
     *register_buff++ = 0.0;

    /*
     * Initialize the current buffer position and buffer start
     */
    
    *regIndex       = 0;
    *lastTrig       = 0;
    *lastTime       = -1.0;
}

/*
 * mdlOutputs - computes the outputs of the S-Function
 */

static void mdlOutputs(real_T *y, const real_T *x, const real_T *u, SimStruct *S, int_T tid)
{
    real_T *register_buff        = ssGetRWork(S);
    real_T  trigThreshold   = mxGetPr(TRIG_THRESHOLD)[0];
    int_T    *regIndex        = ssGetIWork(S);
    int_T    *lastTrig        = ssGetIWork(S) + 1;    
    int_T     numOutput       = ssGetNumOutputs(S) - 1;
    int_T     maxDelay        = ssGetNumRWork(S) - 1;
    real_T *lastTime        = ssGetRWork(S) + maxDelay;
    
    int_T     i, outnum;
    real_T  currentTime     = ssGetT(S);

    /*
     * acquire the buffer data
     */

    if ((u[1] >= trigThreshold) & (*lastTrig == 0)) {

      for (i = 0; i < numOutput; i++) {
        outnum = (int_T)(mxGetPr(REGISTER_DELAY)[i]);

        if (outnum == 0)
          y[i] = *u;
        else
          y[i] = register_buff[(maxDelay + *regIndex - outnum) % maxDelay];
      }
      if (*regIndex == 0)
        y[numOutput] = 1.0;
      else
        y[numOutput] = 0.0;
        
      register_buff[(*regIndex)++] = *u;
      *regIndex %= maxDelay;
      *lastTrig = 1;
      *lastTime = currentTime;
     } else {
      if (currentTime <= 0.0) {
        for (i = 0; i < numOutput; i++)
          y[i] = 0.0;
      } else if ((currentTime - *lastTime) / currentTime < 0.00000001) {
        /* keep the most recent change in the buffer */
        /* this is backup the case when there are tow calls at the same time.
         * the two values of the same time are different.
         * This is assume the time variable is always increasing
         */

        if (u[1] >= trigThreshold) {
          int_T backIndex;
          backIndex = *regIndex - 1;
          if (backIndex < 0)
            backIndex = maxDelay - 1;                
          for (i = 0; i < numOutput; i++) {
            outnum = (int_T)(mxGetPr(REGISTER_DELAY)[i]);
            if (outnum == 0)
              y[i] = *u;
          }
          if (backIndex == 0)
            y[numOutput] = 1.0;
          else
            y[numOutput] = 0.0;         
          register_buff[backIndex] = *u;
        }
      }
      if (*lastTrig == 1) {
        if (u[1] < trigThreshold) {
          *lastTrig = 0;
          y[numOutput] = 0.0;
        }
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





