/* $Revision: 1.1.6.1 $ */
/*============================================================================
 *  Syntax:[sys, x0, str, ts] = simbchdc(t, x, u, flag, n, k, t_err, tp, dim)
 *SIMBCHDC Simulink S-function for BCH decode.
 *       The M-file is designed to be used in a Simulink S-Function block.
 *       This function will decode the cyclic code using BCH decod method.
 *       Parameters: n -- length of code word.
 *                   k -- length of message.
 *                   t -- error-correction capability.
 *                   tp-- list of all GF(2^M) elements. n=2^M-1.
 *
 *       The output has length n+1, the last digit is the error signal err.
 *       A non-negative err indicates number of errors have been corrected.
 *       A nagative err indicates that more than t error have been found in
 *       in the code, the routine cannot correct such error.
 *
 *============================================================================
 *
 *     Originally designed by Wes Wang,
 *     Copyright 1996-2002 The MathWorks, Inc.
 *
 *     Jun Wu,     The MathWorks, Inc.
 *     Feb-07, 1996
 *
 *==========================================================================*/
#define S_FUNCTION_NAME simbchdc

/* need to include simstruc.h for the definition of the SimStruct and
 * its associated macro definitions.
 */
#include "simstruc.h"
#include "tmwtypes.h"
#include <math.h>
#include "gflibv0.c"

#ifdef MATLAB_MEX_FILE
#include "mex.h"        /* needed for declaration of mexErrMsgTxt */
#endif

#define NUM_ARGS    5           /* five additional input arguments */
#define N       ssGetArg(S,0)
#define K       ssGetArg(S,1)
#define T_ERR   ssGetArg(S,2)
#define P       ssGetArg(S,3)
#define DIM     ssGetArg(S,4)

#define Prim 2 

static void mdlInitializeSizes(SimStruct *S)
{
  int_T     i, np;
  int_T     n = (int_T)mxGetPr(N)[0];
  int_T     k = (int_T)mxGetPr(K)[0];
  int_T     t_err = (int_T)mxGetPr(T_ERR)[0];
  int_T     dim = (int_T)mxGetPr(DIM)[0];
  
  np = 1;
  for(i=0; i < dim; i++)
    np = np*2;
  
  if ( np-1 != n ){
#ifdef MATLAB_MEX_FILE
    mexErrMsgTxt("BCH decode has illegal code word length");
#endif
  }
  ssSetNumContStates(     S, 0);          /* no continuous states */
  ssSetNumDiscStates(     S, 0);          /* no discrete states */
  ssSetNumOutputs(        S, k+1);        /* number of output, code word length plus one*/
  ssSetNumInputs(         S, n+1);        /* number of inputs, message length*/
  ssSetDirectFeedThrough( S, 1);          /* direct feedthrough flag */
  ssSetNumSampleTimes(    S, 1);          /* number of sample times */
  ssSetNumInputArgs(      S, NUM_ARGS);   /* number of input arguments*/
  ssSetNumRWork(          S, 0);
  ssSetNumIWork(          S, 6*n+(3*n+2)*dim+5*t_err+(n-k)*(n-k)+10*(n-k)+20 );
  /* n -------------- *code
   * (n+1)*dim ------ *pp
   * n -------------- *ccode
   * 1 -------------- *err
   *(2+dim)*(2*n+1)+5*t_err+(n-k)*(n-k)+10*(n-k)+17 --- Iwork for bchcore()
   */
  ssSetNumPWork(          S, 0);
}
/*
 * mdlInitializeConditions - initialize the states
 * Initialize the states, Integers and real-numbers
 */
static void mdlInitializeConditions(real_T *x0, SimStruct *S)
{
  int_T     i;
  int_T     n, k, dim, t_err;
  int_T     *code, *pp, *ccode, *Iwork, *err;
  real_T  *p;
  
  p = mxGetPr(P);
  n = (int_T)mxGetPr(N)[0];
  k = (int_T)mxGetPr(K)[0];
  dim = (int_T)mxGetPr(DIM)[0];
  t_err = (int_T)mxGetPr(T_ERR)[0];
  
  code =  ssGetIWork(S);
  pp =    ssGetIWork(S)+n;
  ccode = ssGetIWork(S)+n+(n+1)*dim;
  err =   ssGetIWork(S)+2*n+(n+1)*dim;
  Iwork = ssGetIWork(S)+2*n+(n+1)*dim+1;
  for(i=0; i<(n+1)*dim; i++)
    pp[i] = (int_T)p[i];
}
/*
 * mdlInitializeSampleTimes - initialize the sample times array
 *
 * This function is used to specify the sample time(s) for your S-function.
 * If your S-function is continuous, you must specify a sample time of 0.0.
 * Sample times must be registered in ascending order.
 */
static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTimeEvent(S, 0, INHERITED_SAMPLE_TIME);
    ssSetOffsetTimeEvent(S, 0, FIXED_IN_MINOR_STEP_OFFSET);
}
/*if (flag == 3)
 *    % refresh the state only when there is a trigger signal
 *    len_u = length(u);
 *    if u(len_u)
 *        % output the decode result.
 *        % main calculation
 *        [sys, err] = bchcore(u(1:len_u-1), n, dim, k, t_err, tp);
 *        % output is the combination of message and error information.
 *        sys = [sys(:); err];
 *    elseif (t <= 0)
 *        % if there is no trigger, no calculation.
 *        sys = zeros(k+1, 1);
 *    end;
 */    
/*
 * mdlOutputs - compute the outputs
 *
 * In this function, you compute the outputs of your S-function
 * block.  The outputs are placed in the y variable.
 */
static void mdlOutputs(real_T *y, const real_T *x, const real_T *u, SimStruct *S, int_T tid)
{
  int_T     i;
  int_T     n, k, dim, t_err;
  int_T     *code, *pp, *ccode, *Iwork, *err;
  real_T  t;
  real_T  *p;
  
  t = ssGetT(S);
  p = mxGetPr(P); 

  n = (int_T)mxGetPr(N)[0];
  k = (int_T)mxGetPr(K)[0];
  dim = (int_T)mxGetPr(DIM)[0];
  t_err = (int_T)mxGetPr(T_ERR)[0];
  
  code =  ssGetIWork(S);
  pp =    ssGetIWork(S)+n;
  ccode = ssGetIWork(S)+n+(n+1)*dim;
  err =   ssGetIWork(S)+2*n+(n+1)*dim;
  Iwork = ssGetIWork(S)+2*n+(n+1)*dim+1;
  
  for(i=0; i<(n+1)*dim; i++)
    pp[i] = (int_T)p[i];
  for(i=0; i<n; i++)
    code[i] = (int_T)u[i];
  if( u[n] != 0 ){
    /* output the decode result.
     * main calculation
     *        [sys, err] = bchcore(u(1:len_u-1), n, dim, k, t_err, tp);
     */
    err[0] = 0; 
    bchcore(code,n,dim,k,t_err,pp,Iwork,err,ccode);
    
    /* output is the combination of message and error information.*/
    for(i=n-k; i < n; i++)
      y[i-n+k] = (real_T)ccode[i];
    y[k] = (real_T)err[0];
  }else if(t < 0){
    /* if there is no trigger, no calculation. */
    for(i=0; i<k+1; i++)
      y[i] = 0;
  }
}

/*
 * mdlUpdate - perform action at major integration time step
 *
 * This function is called once for every major integration time step.
 * Discrete states are typically updated here, but this function is useful
 * for performing any tasks that should only take place once per integration
 * step.
 */
static void mdlUpdate(real_T *x, const real_T *u, SimStruct *S, int_T tid)
{
}

/*
 * mdlDerivatives - compute the derivatives
 *
 * In this function, you compute the S-function block's derivatives.
 * The derivatives are placed in the dx variable.
 */
static void mdlDerivatives(real_T *dx, const real_T *x, const real_T *u, SimStruct *S, int_T tid)
{
}

/*
 * mdlTerminate - called when the simulation is terminated.
 *
 * In this function, you should perform any actions that are necessary
 * at the termination of a simulation.  For example, if memory was allocated
 * in mdlInitializeConditions, this is the place to free it.
 */
static void mdlTerminate(SimStruct *S)
{
}

#ifdef      MATLAB_MEX_FILE /* Is this file being compiled as a MEX-file? */
#include "simulink.c"       /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"        /* Code generation registration function */
#endif

