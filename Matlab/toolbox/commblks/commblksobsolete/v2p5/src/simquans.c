/* $Revision: 1.1.6.2 $ */
/*
 * SIMQUANS   A Simulink quantizer block
 *
 * Syntax:  [sys, x0] = regdown(t, x, u, flag, k, partition, codebook, sample_time)
 *      This block quantizes individual elements of the input vector using
 *      scalar quantization method. The input vector has dimension n, the
 *      partition is an N-1 vector and codebook is a length N vector. The output
 *      of this block is a length 2N+1 vector with the first n elements being the
 *      index, which is one of the N integers in the range [0 : N-1]. The second
 *      N elements are the quantized output. The last N elements of the output
 *      vector are the estimation of the distortion.
 *
 * Wes Wang 10/6, 1994
 *
 * Copyright 1996-2003 The MathWorks, Inc.
 */

#define S_FUNCTION_NAME simquans

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

#define NUM_ARGS        4
#define NUM_INPUT      ssGetArg(S,0)
#define PARTITION      ssGetArg(S,1)
#define CODEBOOK       ssGetArg(S,2)
#define SAMPLE_TIME    ssGetArg(S,3)

/*
 * mdlInitializeSizes - called to initialize the sizes array stored in
 *                      the SimStruct.  The sizes array defines the
 *                      characteristics (number of inputs, outputs,
 *                      states, etc.) of the S-Function.
 */

static void mdlInitializeSizes(SimStruct *S)
{
    int_T Num_Index;
    int_T Num_Input = (int_T)mxGetPr(NUM_INPUT)[0];
    /*
     * Set-up size information.
     */ 

    if (ssGetNumArgs(S) == NUM_ARGS) {
        /* check the dimensions */
        
        if ((mxGetN(NUM_INPUT) != 1) || (mxGetM(NUM_INPUT) != 1)) {
#ifdef MATLAB_MEX_FILE
            mexErrMsgTxt("Input size must be a nonempty scalar.");
#endif        
        }

        Num_Index = mxGetN(CODEBOOK) * mxGetM(CODEBOOK);
        if (Num_Index - 1 != mxGetN(PARTITION) * mxGetM(PARTITION)) {
#ifdef MATLAB_MEX_FILE
            mexErrMsgTxt("The vector size for PARTITION must be the size of CODEBOOK -1.");
#endif
        }
    
        if (Num_Index <= 1) {
#ifdef MATLAB_MEX_FILE
            mexErrMsgTxt("The vector PARTITION cannot be empty.");
#endif
        } 
       
        ssSetNumContStates(    S, 0);
        ssSetNumDiscStates(    S, 0);
        ssSetNumInputs(        S, Num_Input);
        ssSetNumOutputs(       S, 3*Num_Input);
        ssSetDirectFeedThrough(S, 1);
        ssSetNumInputArgs(     S, NUM_ARGS);
        ssSetNumSampleTimes(   S, 1);
        /* Real number for distortion computation, first number is the number of
         * elements have been processed */
        ssSetNumRWork(         S, 1 + Num_Input);
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
     * sample time.
     */
    real_T sampleTime, offsetTime;

    sampleTime = mxGetPr(SAMPLE_TIME)[0];
    if ((mxGetN(SAMPLE_TIME) * mxGetM(SAMPLE_TIME)) == 2)
            offsetTime = mxGetPr(SAMPLE_TIME)[1];
    else
           offsetTime = 0.;
    
    ssSetSampleTimeEvent(S, 0, sampleTime);
    ssSetOffsetTimeEvent(S, 0, offsetTime);
}

/*
 * mdlInitializeConditions - initializes the states for the S-Function
 */

static void mdlInitializeConditions(real_T *x0, SimStruct *S)
{
    int_T Num_Input       = ssGetNumInputs(S);
    int_T Num_Index       = mxGetN(PARTITION) * mxGetM(PARTITION);
    int_T    *J_Bound     = ssGetIWork(S);
    real_T *Num_Done    = ssGetRWork(S);
    real_T *Distortion  = ssGetRWork(S) + 1;    

    int_T i;

    /* 
     * Initialize the buffer to all zeros, we could allow this to
     * be an additional paramter.
     */
    
    for (i = 0; i < Num_Input; i++) 
        *Distortion++ = 0.;

    *Num_Done = 0.;
    *J_Bound  = Num_Index;
}

/*
 * mdlOutputs - computes the outputs of the S-Function
 */
static void mdlOutputs(real_T *y, const real_T *x, const real_T *u, SimStruct *S, int_T tid)
{
    int_T Num_Input       = ssGetNumInputs(S);
    int_T    *J_Bound     = ssGetIWork(S);
    real_T *Num_Done    = ssGetRWork(S);
    real_T *Distortion  = ssGetRWork(S) + 1;

    int_T i, j;
    real_T Num_Done_1, Dist_tmp;

    Num_Done_1 = *Num_Done;
    *Num_Done = *Num_Done + 1;
    for (i = 0; i < Num_Input; i++) {
        /* for each input */
        j = 0;
        while ((j < *J_Bound) && (u[i] > mxGetPr(PARTITION)[j]))
            j++;

        /* index */
        y[i] = j;

        /* Quantized value */
        y[i + Num_Input] = mxGetPr(CODEBOOK)[j];

        /* Distortion computation */
        Dist_tmp = (u[i] - mxGetPr(CODEBOOK)[j]);
        Dist_tmp *= Dist_tmp;
        if (Num_Done_1) {
            Dist_tmp = (Dist_tmp + Distortion[i] * Num_Done_1) / *Num_Done;
        }
        Distortion[i] = Dist_tmp;
        y[i + Num_Input + Num_Input] = Dist_tmp;
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
