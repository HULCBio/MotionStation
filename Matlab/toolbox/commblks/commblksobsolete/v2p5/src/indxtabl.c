/* $Revision: 1.1.6.2 $ */
/*
 * INDXTABL   A Simulink index look up table.
 *
 * Syntax:  [sys, x0] = indxtabl(t, x, u, flag, codebook)
 *      This block takes the block input as index and the output is one of the
 *      values provided in the codebook. Variable codebook could be a vector
 *      or matrix.
 *      When codebook is a M-by-N matrix, the block input must be a scalar. The
 *      output is a length N vector. The block outputs the first row of the
 *      matrix when input index u is less or equal to zero; second row when u is
 *      less than or equal to one; ... Nth row when u is greater than N-2.
 *
 *      When codebook is a length N vector, the block input could be a scalar
 *      or vector. The output has the same length as that of the input vecotr.
 *      The output y(i) = 1st_element_of_codebook when u(i) is less or equal
 *      to zero; y(i) = 2nd_element_of_codebook when u(i) is less or euqal to
 *      one; ... y(i) = Nth_element_of_codebook when u(i) is greater than N-2.
 *      
 * Wes Wang 10/7, 1994
 *
 * Copyright 1996-2003 The MathWorks, Inc.
 */

#define S_FUNCTION_NAME indxtabl

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

#define NUM_ARGS        1
#define CODEBOOK       ssGetArg(S,0)

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
        int_T M, N, Min_N_M;
        /* check the dimensions */

        M = mxGetM(CODEBOOK);
        N = mxGetN(CODEBOOK);
        Min_N_M = (M < N) ? M : N;
        if (Min_N_M < 1) {
#ifdef MATLAB_MEX_FILE
            mexErrMsgTxt("Input size must be a nonempty vector or matrix");
#endif        
        }
        Min_N_M = (Min_N_M == 1);
       
        ssSetNumContStates(    S, 0);
        ssSetNumDiscStates(    S, 0);
        if (Min_N_M) {
            ssSetNumInputs(        S, -1);
            ssSetNumOutputs(       S, -1);
        } else {
            ssSetNumInputs(        S, 1);
            ssSetNumOutputs(       S, N);            
        }
        ssSetDirectFeedThrough(S, 1);
        ssSetNumInputArgs(     S, NUM_ARGS);
        ssSetNumSampleTimes(   S, 1);
        ssSetNumRWork(         S, 0);
        /* store Min_N_M here */
        ssSetNumIWork(         S, 1);
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
    int_T    *Min_N_M     = ssGetIWork(S);

    int_T M, N;

    M = mxGetM(CODEBOOK);
    N = mxGetN(CODEBOOK);
    *Min_N_M = (M < N) ? M : N;
    *Min_N_M = (*Min_N_M == 1);    
}

/*
 * mdlOutputs - computes the outputs of the S-Function
 */
static void mdlOutputs(real_T *y, const real_T *x, const real_T *u, SimStruct *S, int_T tid)
{
    int_T *Min_N_M    = ssGetIWork(S);

    if (*Min_N_M) {
        /* vector codebook, output length equals to the input length */
        int_T N = ssGetNumInputs(S);
        int_T M = mxGetM(CODEBOOK) * mxGetN(CODEBOOK) - 1;
        int_T i, indx;
        
        for (i = 0; i < N; i++){
            indx = (int_T)u[i];
            if (indx < 0) {
                indx = 0;
            } else { if (indx > M)
                indx = M;
            }
            y[i] = mxGetPr(CODEBOOK)[indx];            
        }
    } else {
        /* matrix codebook, output length is N */
        int_T M = mxGetM(CODEBOOK);
        int_T N = mxGetN(CODEBOOK);
        int_T i, indx;

        indx = (int_T)u[0];
        if (indx < 0) {
            indx = 0;
        } else { if (indx > M-1)
            indx = M-1;
        }
        for (i = 0; i < N; i++)
            y[i] = mxGetPr(CODEBOOK)[indx + i*M];
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
