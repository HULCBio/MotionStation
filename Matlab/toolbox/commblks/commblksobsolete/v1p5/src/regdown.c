/* $Revision: 1.1.6.1 $ */
/*
 * REGDOWN   A Simulink register down block
 *
 * Syntax:  [sys, x0] = regdown(t, x, u, flag, OutputIndex, Increament, trigThreshold, cycl_flag)
 *      This block outputs a vector with the initial index given in OutputIndex.
 *      The increament of the index is given in Increament. This block has three
 *      input veriables. The first is a vector providing the register signals.
 *      The second is a clock signal to trigger the refreshment of the register in
 *      in this block. The third is a trigger signal for the output refreshment.
 *      The block uses the rising edge of both second and third input pulse
 *      to trigger the action. At the rising edge of the third signal, a positive
 *      signal at the third inport would cause the output refreshemnt.
 *
 * Wes Wang 8/23, 1994
 *
 * Copyright 1996-2002 The MathWorks, Inc.
 */

#define S_FUNCTION_NAME regdown

#ifdef MATLAB_MEX_FILE
#include "mex.h"      /* needed for declaration of mexErrMsgTxt */
#endif

/*
 * need to include simstruc.h for the definition of the SimStruct and
 * its associated macro definitions.
 */

#include "simstruc.h"
#include "tmwtypes.h"

/*
 * Defines for easy access of the input parameters
 */

#define NUM_ARGS        4
#define OUTPUT_INDEX   ssGetArg(S,0)
#define INCREAMENT     ssGetArg(S,1)
#define TRIG_THRSHLD   ssGetArg(S,2)
#define CYCLIC_FLAG    ssGetArg(S,3)

/*
 * mdlInitializeSizes - called to initialize the sizes array stored in
 *                      the SimStruct.  The sizes array defines the
 *                      characteristics (number of inputs, outputs,
 *                      states, etc.) of the S-Function.
 */

static void mdlInitializeSizes(SimStruct *S)
{
  int_T num_output_idx, num_increament;
    
  /*
   * Set-up size information.
   */ 

  if (ssGetNumArgs(S) == NUM_ARGS) {
    /* check the dimension for OUTPUT_INDEX and INCREAMNET */
    num_output_idx = mxGetN(OUTPUT_INDEX) * mxGetM(OUTPUT_INDEX);
    num_increament  = mxGetN(INCREAMENT)   * mxGetM(INCREAMENT);
    if (num_output_idx <= 0) {
#ifdef MATLAB_MEX_FILE
      mexErrMsgTxt("OutputIndex cannot be a empty vector.");
#endif        
    }
    if (num_output_idx != num_increament) {
      if (num_increament != 1) {
#ifdef MATLAB_MEX_FILE
         mexErrMsgTxt("The vector size for OutputIndex and Increment must be the same.");
#endif
      }
    }
    
    if ((mxGetN(TRIG_THRSHLD)*mxGetM(TRIG_THRSHLD) != 1)) {
#ifdef MATLAB_MEX_FILE
      mexErrMsgTxt("The threshold must be a scalar.");
#endif
    } 
       
    ssSetNumContStates(    S, 0);
    ssSetNumDiscStates(    S, 0);
    ssSetNumInputs(        S, -1);
    ssSetNumOutputs(       S, 1 + num_output_idx);
    ssSetDirectFeedThrough(S, 1);
    ssSetNumInputArgs(     S, NUM_ARGS);
    ssSetNumSampleTimes(   S, 1);
    ssSetNumRWork(         S, -1);
    /* the buffer size is input_vector + trig_in + trig_out
     * R vector is assigned as buffer, lastTime2, lastTime3
     */
    ssSetNumIWork(         S, 2 + 2 * num_output_idx);
    ssSetNumPWork(         S, 0);

  }  else {
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
    int_T num_output_idx   = ssGetNumOutputs(S) - 1;
    real_T *regi         = ssGetRWork(S);

    int_T *lastTrig2       = ssGetIWork(S);
    int_T *lastTrig3       = ssGetIWork(S) + 1;
    int_T *outputIndex     = ssGetIWork(S) + 2; 

    int_T *increament      = ssGetIWork(S) + num_output_idx + 2;

    int_T num_increament   = mxGetN(INCREAMENT) * mxGetM(INCREAMENT);

    int_T regiSize         = ssGetNumInputs(S) - 2;

    int_T i;

    /* 
     * Initialize the buffer to all zeros, we could allow this to
     * be an additional paramter.
     */
    
    for (i = 0; i < regiSize; i++)
        *regi++ = 0.;
    /*
     * Initialize the current buffer position, buffer start, and output index
     */
    
    for (i = 0; i < num_output_idx; i++) {
        if (mxGetPr(OUTPUT_INDEX)[i] < 0) {
#ifdef MATLAB_MEX_FILE
             mexErrMsgTxt("Output Index must be positive integers.");
#endif
                }
        *outputIndex++ = (int_T) mxGetPr(OUTPUT_INDEX)[i];
        if (num_increament == 1) {
            *increament++ = (int_T)mxGetPr(INCREAMENT)[0];
                } else {
            *increament++ = (int_T)mxGetPr(INCREAMENT)[i];
        }
    }
    *lastTrig2 = 0;
    *lastTrig3 = 0;
    if (regiSize >= 0) {
        real_T *lastTime2    = ssGetRWork(S) + regiSize;
        real_T *lastTime3    = ssGetRWork(S) + regiSize + 1;
        *lastTime2 = -1.0;
        *lastTime3 = -1.0;
    }
}

/*
 * mdlOutputs - computes the outputs of the S-Function
 */
static void mdlOutputs(real_T *y, const real_T *x, const real_T *u, SimStruct *S, int_T tid)
{
    int_T num_output_idx   = ssGetNumOutputs(S) - 1;
    real_T *regi         = ssGetRWork(S);
    real_T  trigThreshold   = mxGetPr(TRIG_THRSHLD)[0];
    
    int_T *lastTrig2       = ssGetIWork(S);
    int_T *lastTrig3       = ssGetIWork(S) + 1;
    int_T *outputIndex     = ssGetIWork(S) + 2; 

    int_T *increament      = ssGetIWork(S)+ num_output_idx + 2;

    int_T regiSize         = ssGetNumInputs(S) - 2;

    real_T *lastTime2    = ssGetRWork(S) + regiSize;
    real_T *lastTime3    = ssGetRWork(S) + regiSize + 1;
    real_T currentTime   = ssGetT(S);
    
    int_T cycl_flag   = (int_T)mxGetPr(CYCLIC_FLAG)[0];
    
    int_T i, modulo_idx;
    if ((u[regiSize] >= trigThreshold) & (*lastTrig2 == 0)) {
      for (i = 0; i < regiSize; i++)
        regi[i] = u[i];
      /* refresh output index */
      for (i = 0; i < num_output_idx; i++)
        outputIndex[i] = (int_T) mxGetPr(OUTPUT_INDEX)[i];
      /* reset trigger flag */
      *lastTrig2 = 1;
      y[num_output_idx] = 1;
      *lastTime2 = currentTime;
    } else {
      if (u[regiSize] >= trigThreshold) {
        if (currentTime > 0) {
          if ((currentTime - *lastTime2) / currentTime < 0.00000001) {
            /* re-refresh the buffer, use the most recent one */
            for (i = 0; i < regiSize; i++)
              regi[i] = u[i];
            /* verify whether the output needs to refresh */
            if ((u[regiSize + 1] >= trigThreshold) && ((currentTime - *lastTime3) / currentTime < 0.00000001)) {
              int_T backIndex;
                
              for (i = 0; i < num_output_idx; i++) {
                backIndex = outputIndex[i] - increament[i];

                if (cycl_flag > 0) {
                  if (backIndex >= 0)
                    backIndex %= regiSize;
                  else 
                    backIndex = (regiSize - ((-backIndex) % regiSize)) % regiSize;
                  y[i] = regi[backIndex];
                } else {
                  if ((backIndex < regiSize) & (backIndex >= 0))
                    y[i] = regi[backIndex];
                  else
                    y[i] = 0.0;
                }
              }
            }
          }
        }
      } else if (*lastTrig2 == 1) {
        if (u[regiSize] < trigThreshold) {
          *lastTrig2 = 0;
          y[num_output_idx] = 0.0;
        }
      }
    }
    if ((u[regiSize + 1] >= trigThreshold) & (*lastTrig3 == 0)) {
      for (i = 0; i < num_output_idx; i++) {
        /* refresh output */
        if (cycl_flag > 0) {
          modulo_idx = outputIndex[i];
          if (modulo_idx >= 0)
            modulo_idx %= regiSize;
          else 
            modulo_idx = (regiSize - ((-modulo_idx) % regiSize)) % regiSize;
          y[i] = regi[modulo_idx];
        } else {
          if ((outputIndex[i] < regiSize) & (outputIndex[i] >= 0))
            y[i] = regi[outputIndex[i]];
          else
            y[i] = 0.0;
        }

        /* refresh output index */                
        outputIndex[i] += increament[i];
      }
      *lastTrig3 = 1;
      *lastTime3 = currentTime;
    } else {
      if (*lastTrig3 == 1) {
        if (u[regiSize+1] < trigThreshold)
          *lastTrig3 = 0;
      }
      if (ssGetT(S) <= 0.0) {
        for (i = 0; i < num_output_idx; i++)
          y[i] = 0.0;         
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
#include "simulink.c"   /* MEX-File interface mechanism */
#else
#include "cg_sfun.h"    /* Code generation registration function */
#endif

