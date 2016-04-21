/*
 *  Syntax: [sys, x0, str, ts] = scomrsdec(t, x, u, flag, n, k, t_err, tp, dim)
 *  SCOMRSDEC Simulink S-function for R-S decode.
 *       The M-file is designed to be used in a Simulink S-Function block.
 *       This function will decode the cyclic code using R-S decode method.
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
 *  Copyright 1996-2003 The MathWorks, Inc.
 *  $Revision: 1.1.6.2 $ $Date: 2004/04/12 23:02:25 $
 */
 
#define S_FUNCTION_NAME scomrsdec

/* need to include simstruc.h for the definition of the SimStruct and
 * its associated macro definitions.
 */ 
#include "simstruc.h"
#include "gflib.h"

/* For RTW */
#if defined(RT) || defined(NRT)  
#undef  mexPrintf
#define mexPrintf printf
#endif

#define NUM_ARGS    4           /* four additional input arguments */
#define N       ssGetArg(S,0)
#define K       ssGetArg(S,1)
#define P       ssGetArg(S,2)
#define DIM     ssGetArg(S,3)

/*elseif (flag == 0)
 *    if 2^dim-1 ~= n
 *        error('Reed-Solomon decode has illegal code word length')
 *    end;
 *    sys(1) = 0; % no continuous state
 *    sys(2) = k+1; % number of discrete state
 *    sys(3) = k + 1;   % number of output, code word length plus one.
 *    sys(4) = n + 1;       % number of input, message length.
 *    sys(5) = 0;
 *    sys(6) = 1;       % direct through flag.
 *    sys(7) = 1;       % one sample rate
 *    x0 = [];
 *    ts = [-1, 0];
 */
static void mdlInitializeSizes(SimStruct *S)
{
  int_T     i, np;
  int_T     n = (int_T)mxGetPr(N)[0];
  int_T     k = (int_T)mxGetPr(K)[0];
  int_T     dim = (int_T)mxGetPr(DIM)[0];
  
  np = 1;
  for(i=0; i < dim; i++)
    np = np*2;
  
  if ( np-1 != n ){
#ifdef MATLAB_MEX_FILE
    mexErrMsgTxt("Reed-Solomon decode has illegal code word length");
#endif 
  }

  ssSetNumContStates(     S, 0);          /* no continuous states */
  ssSetNumDiscStates(     S, 0);          /* number of discrete states */
  ssSetNumOutputs(        S, k+1);        /* number of output, code word length plus 4one*/
  ssSetNumInputs(         S, n);          /* number of inputs, message length*/
  ssSetDirectFeedThrough( S, 1);          /* direct feedthrough flag */
  ssSetNumSampleTimes(    S, 1);          /* number of sample times */
  ssSetNumInputArgs(      S, NUM_ARGS);   /* number of input arguments*/
  ssSetNumRWork(          S, 0);
  ssSetNumIWork(          S, (n-2*k+6*dim+20)*n+4*dim+k*(k-12)+28);
  /* n ------------- *code
   * (n+1)*dim ----- *pp
   * k ------------- *msg
   * n ------------- *ccode
   * 1 ------------- *err
   * (n-2*k+5*dim+18)*n
   *     +3*dim+k*(k-13)+27 --- Iwork for rscore()
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
  int_T     n = (int_T)mxGetPr(N)[0];
  int_T     k = (int_T)mxGetPr(K)[0];
  int_T     dim = (int_T)mxGetPr(DIM)[0];
  int_T     *code, *pp, *Iwork;
  int_T     *msg, *ccode, *err;
  
  code =  ssGetIWork(S);
  pp =    ssGetIWork(S)+n;
  msg =   ssGetIWork(S)+n+(n+1)*dim;
  ccode = ssGetIWork(S)+n+(n+1)*dim + k;
  err =   ssGetIWork(S)+2*n+(n+1)*dim + k;
  Iwork = ssGetIWork(S)+2*n+(n+1)*dim + k + 1;
  err[0] = 0;
  for( i=0; i<(n+1)*dim; i++)
    pp[i] = (int_T)mxGetPr(P)[i]; 
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
 *        [sys, err] = rscore(u(1:len_u-1)-1, k, tp, dim, n);
 *        % output is the combination of message and error information.
 *        sys = sys +1;
 *        indx = find(~(sys>=0));
 *        sys(indx) = indx-indx;
 *        sys = [sys(:); err];
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
  int_T     n = (int_T)mxGetPr(N)[0];
  int_T     k = (int_T)mxGetPr(K)[0];
  int_T     dim = (int_T)mxGetPr(DIM)[0];
  int_T     *code, *pp, *Iwork;
  int_T     *msg, *ccode, *err;
  
  code =  ssGetIWork(S);
  pp =    ssGetIWork(S)+n;
  msg =   ssGetIWork(S)+n+(n+1)*dim;
  ccode = ssGetIWork(S)+n+(n+1)*dim + k;
  err =   ssGetIWork(S)+2*n+(n+1)*dim + k;
  Iwork = ssGetIWork(S)+2*n+(n+1)*dim + k + 1;

  
  /* output the decode result.
   * main calculation
   *        [sys, err] = rscore(u(1:len_u-1), n, dim, k, t_err, tp);
   */
  for( i=0; i<(n+1)*dim; i++)
    pp[i] = (int_T)mxGetPr(P)[i];
  for( i=0; i<n; i++ )
    code[i] = (int_T)(u[i]-1);

  rscore(code, k, pp, dim, n, Iwork, err, ccode);
  /* output is the combination of message and error information.*/

  for(i=n-k; i < n; i++)
    msg[i-n+k] = ccode[i];            

  for(i=0; i < k; i++){
    if( msg[i]+1 < 0 )
	  y[i] = 0.0;
    else
	  y[i] = (real_T)(msg[i]+1);
  }

  y[k] = (real_T)err[0];
  
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

#ifdef      MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif
