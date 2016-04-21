/* $Revision: 1.1.6.1 $ */
/*
 * SIMSCRAM   A Simulink scrambler
 *
 *  Syntax:  [sys, x0] = simscram(t,x,u,flag,M,poly,flag)
 *  This function has two inputs and one ouput. The first input is the signal
 *  to be processed by scrambler. The second signal is the clock pulse, which
 *  triggers the process (input, output refresh) with its rising edge.
 *  The function causes a delay in the transmission. The initial values of the
 *  block is assigned to be zeros.
 *
 *  M is a scalar parameter, which specifies the base of the computation.
 *
 *  poly is the polynomial of the scrambler. poly is a vector with
 *  poly = [p0, p1, p2, p3, ... pn], which specifing the generator
 *  polynomial g(x) = p0 + p1 x^-1 + p2 x^-2 + p3 x^-3 + ... pn x^-n
 *
 * Wes Wang  Sept. 25, 1997
 * Copyright 1996-2002 The MathWorks, Inc.
 */

#define S_FUNCTION_NAME simscram

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

#define NUM_ARGS   4
#define M_BASE         ssGetArg(S,0)
#define POLYNOMIAL     ssGetArg(S,1)
/* 0 -- scramble, 1 -- descramble */
#define SCRM_DESCRM    ssGetArg(S,2)
#define INITIAL_STAT   ssGetArg(S,3)


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
      int_T polydegree;

      polydegree = mxGetN(POLYNOMIAL) * mxGetM(POLYNOMIAL);
      if (polydegree < 1) {
#ifdef MATLAB_MEX_FILE
        char_T err_msg[256];
        sprintf(err_msg, "Generator polynomial is empty.");
        mexErrMsgTxt(err_msg);
#endif  
      }
       
      ssSetNumContStates(    S, 0);
      ssSetNumDiscStates(    S, 0);
      ssSetNumInputs(        S, 2);
      ssSetNumOutputs(       S, polydegree);
      ssSetDirectFeedThrough(S, 1);
      ssSetNumInputArgs(     S, NUM_ARGS);
      ssSetNumSampleTimes(   S, 1);
      ssSetNumRWork(         S, 1);
      ssSetNumIWork(         S, polydegree+2);
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
    int_T    *lastTrig       = ssGetIWork(S);
    int_T    *saved_output   = ssGetIWork(S) + 1;
    real_T   *lastTime       = ssGetRWork(S);
    real_T   *initial_stat  = mxGetPr(INITIAL_STAT);
    
    int_T i, polydegree;

    /* 
     * Initialize the register_buff to all zeros.
     */
    
    polydegree = mxGetN(POLYNOMIAL) * mxGetM(POLYNOMIAL);

    *lastTrig        = 0;
    *lastTime        = -1.0;

    if (mxGetN(INITIAL_STAT) * mxGetM(INITIAL_STAT) >= polydegree -1) {
      for (i = 0; i < polydegree; i++)
        *saved_output++ = initial_stat[i+1];
      *saved_output++ = initial_stat[0];
    } else {
      for (i = 0; i <= polydegree; i++)
        *saved_output++ = initial_stat[0];
    }
}

/*
 * mdlOutputs - computes the outputs of the S-Function
 */

static void mdlOutputs(real_T *y, const real_T *x, const real_T *u, SimStruct *S, int_T tid)
{
    int_T    *lastTrig        = ssGetIWork(S);
    int_T    *saved_output    = ssGetIWork(S) + 1;
    real_T   *lastTime        = ssGetRWork(S);
    
    real_T  trigThreshold   = 0.0000001;

    real_T  currentTime     = ssGetT(S);

    /*
     * acquire the buffer data
     */

    if ((u[1] >= trigThreshold) & (*lastTrig == 0)) {
      int_T    i, tmp, polydegree;
      int_T    M_base = (int_T) mxGetPr(M_BASE)[0];
      int_T    scrm_descrm = (int_T) mxGetPr(SCRM_DESCRM)[0];      
      real_T   *polynomial = mxGetPr(POLYNOMIAL);
      
      polydegree = mxGetN(POLYNOMIAL) * mxGetM(POLYNOMIAL);            
      /* shift and do scramble
       * don't shift after computation
      */
      /* shift */
      for (i = polydegree-1; i > 0; i--)
        saved_output[i] = saved_output[i - 1];
      saved_output[0] = saved_output[polydegree];

      /* scramble */
      tmp = 0;
      for (i = 0; i<polydegree; i++) {
          if (0) {
            char_T err_msg[255];
            sprintf(err_msg, "    Index %d, polynomial[i] %d, saved_output[i-1] %d \n", i, (int_T)polynomial[i], saved_output[i-1]);
            mexPrintf(err_msg);
          }        
        if (polynomial[i]) {
          if (i==0)
            tmp = (int_T)u[0];
          else
            tmp = tmp + (int_T)polynomial[i] * saved_output[i - 1];
        }
      }
         if (0) {
           char_T err_msg[255];
           sprintf(err_msg, "Tmp %d, M_base %d, polydegree %d\n", tmp, M_base, polydegree);
           mexPrintf(err_msg);
         }
      tmp = tmp % M_base;
      /* output and save data */
      y[0] = tmp;
      if (scrm_descrm)
        saved_output[polydegree] = (int_T)u[0];
      else
        saved_output[polydegree] = tmp;
      for (i = 1; i < polydegree; i++)
        y[i] = saved_output[i-1];
    } else {
      if (currentTime <= 0.0) {
        y[0] = 0.0;
      } else if ((currentTime - *lastTime) / currentTime < 0.00000001) {
        /* keep the most recent change in the buffer */
        /* this is backup the case when there are tow calls at the same time.
         * the two values of the same time are different.
         * This is assume the time variable is always increasing
         */
        int_T    i, tmp, polydegree;
        int_T    M_base = (int_T) mxGetPr(M_BASE)[0];
        int_T    scrm_descrm = (int_T) mxGetPr(SCRM_DESCRM)[0];              
        real_T   *polynomial = mxGetPr(POLYNOMIAL);
      
        polydegree = mxGetN(POLYNOMIAL) * mxGetM(POLYNOMIAL);             
        /* do scramble without shift
         * don't shift after computation
        */
        /* scramble */
        tmp = 0;
        for (i = 0; i<polydegree; i++) {
          if (polynomial[i]) {
            if (i==0)
              tmp = (int_T)u[0];
            else
              tmp = tmp + (int_T)polynomial[i] * saved_output[i - 1];
          }
        }
        tmp = tmp % M_base;

        /* output and save data */
        y[0] = tmp;
        if (scrm_descrm)
          saved_output[polydegree] = (int_T)u[0];
        else
          saved_output[polydegree] = tmp;        
        for (i = 1; i < polydegree; i++)
          y[i] = saved_output[i-1];
      }
      if (*lastTrig == 1) {
        if (u[1] < trigThreshold) {
          *lastTrig = 0;
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



