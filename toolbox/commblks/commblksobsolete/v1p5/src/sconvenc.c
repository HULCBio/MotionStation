/* $Revision: 1.1.6.1 $ */
/*============================================================================
 *  Syntax: [sys, x0, str, ts] = sconvenc(t, x, u, flag, tran_func);
 * SCONVENC Simulink file for convolution encoding.
 *   This file is designed to be used in a Simulink S-Function block.
 *   The function requires the system inputs
 *   tran_func  is one of the two forms of convolution code transfer function.
 *
 *=============================================================================
 *
 *     Originally designed by Wes Wang,
 *     Copyright 1996-2002 The MathWorks, Inc.
 *
 *     Jun Wu,     The MathWorks, Inc.
 *     Feb-07, 1996
 *
 *===========================================================================*/
#define S_FUNCTION_NAME sconvenc

/* need to include simstruc.h for the definition of the SimStruct and
 * its associated macro definitions.
 */ 
#include "simstruc.h"
#include "tmwtypes.h"
#include <math.h>

#define NUM_ARGS        1
#define TRAN_FUNC   ssGetArg(S,0)

#define Prim 2

static void de2bi(int_T *pde, int_T dim, int_T pow_dim, int_T *pbi)
{
  int_T     i, j, tmp;

  for(i=0; i < pow_dim; i++){
    tmp = pde[i];
    for(j=0; j < dim; j++){
      pbi[i+j*pow_dim] = tmp % Prim;
      if(j < dim-1)
	tmp = (int_T)(tmp/Prim);
    }
  }
}

static void mdlInitializeSizes(SimStruct *S)
{
  int_T     i;
  int_T     N, M, K, colFunc, rowFunc;
  
  rowFunc = mxGetM(TRAN_FUNC);
  colFunc = mxGetN(TRAN_FUNC);
  
  if( mxGetPr(TRAN_FUNC)[rowFunc*colFunc-1] < 0 ){
    N = (int_T)mxGetPr(TRAN_FUNC)[rowFunc*(colFunc-1)];
    K = (int_T)mxGetPr(TRAN_FUNC)[rowFunc*(colFunc-1)+1];
    M = (int_T)mxGetPr(TRAN_FUNC)[rowFunc*(colFunc-1)+2];
  }else{
    M = (int_T)mxGetPr(TRAN_FUNC)[1];
    N = (int_T)mxGetPr(TRAN_FUNC)[rowFunc];
    K = (int_T)mxGetPr(TRAN_FUNC)[rowFunc+1];
  }
  
  ssSetNumContStates(     S, 0);          /* number of continuous states */
  ssSetNumDiscStates(     S, M);          /* number of discrete states */
  ssSetNumOutputs(        S, N);          /* number of outputs */
  ssSetNumInputs(         S, K+1);        /* number of inputs */
  ssSetDirectFeedThrough( S, 1);          /* direct feedthrough flag */
  ssSetNumSampleTimes(    S, 1);          /* number of sample times */
  ssSetNumInputArgs(      S, NUM_ARGS);   /* number of input arguments */
  ssSetNumRWork(          S, 0);          /* number of real working space */
  if( mxGetPr(TRAN_FUNC)[rowFunc*colFunc-1] < 0 )
    ssSetNumIWork( S,  (M+N)*(M+K)+M);
  /* A -------------- M*M
   * B -------------- M*K
   * C -------------- N*M
   * D -------------- N*K
   * tmpRoom -------- M
   */
  else
    ssSetNumIWork( S, (rowFunc-2)*(M+N+2));
  /* TRAN_A --------- rowFunc-2
   * TRAN_B --------- rowFunc-2
   * A -------------- (rowFunc-2)*M
   * B -------------- (rowFunc-2)*N
   */
  ssSetNumPWork(          S, 0);
}

/*
 * mdlInitializeConditions - initialize the states
 * Initialize the states, Integers and real-numbers
 */
static void mdlInitializeConditions(real_T *x0, SimStruct *S)
{
/*elseif flag == 0
 *  [A, B, C, D, N, K, M] = gen2abcd(tran_func);
 *  x0 = zeros(M, 1);
 *  sys = [0; length(x0); N; K+1; 0; 0; 1];
 *  ts = [-1, 0];
 *else
 *  sys = [];
 *end;
 */
  int_T     i, j, len_C;
  int_T     N, M, K, colFunc, rowFunc;
  int_T     *TRAN_A, *TRAN_B;
  int_T     *A, *B, *C, *D, *tmpRoom;
  
  colFunc = mxGetN(TRAN_FUNC);
  rowFunc = mxGetM(TRAN_FUNC);
  
  if( mxGetPr(TRAN_FUNC)[rowFunc*colFunc-1] < 0 ){
    N = (int_T)mxGetPr(TRAN_FUNC)[rowFunc*(colFunc-1)];
    K = (int_T)mxGetPr(TRAN_FUNC)[rowFunc*(colFunc-1)+1];
    M = (int_T)mxGetPr(TRAN_FUNC)[rowFunc*(colFunc-1)+2];
    len_C = M*N;
    
    A = ssGetIWork(S);
    B = A + M*M;
    C = B + M*K;
    D = C + N*M;
    tmpRoom = D + N*K;
    for(i=0; i < M; i++){
      x0[i] = 0;
      tmpRoom[i] = (int_T)x0[i];
    }
    
  }else{
    N = (int_T)mxGetPr(TRAN_FUNC)[rowFunc];
    K = (int_T)mxGetPr(TRAN_FUNC)[rowFunc+1];
    M = (int_T)mxGetPr(TRAN_FUNC)[1];
    len_C = 0;
    
    /* Assignment */
    TRAN_A =    ssGetIWork(S);/*   !--- size of *TRAN_A */
    TRAN_B =    ssGetIWork(S) + (rowFunc-2);/* <--- size of *TRAN_B */
    A =         ssGetIWork(S) + 2*(rowFunc-2);/*    !----- size of *A */ 
    B =         ssGetIWork(S) + 2*(rowFunc-2) + (rowFunc-2)*M;/*    !----- size of *B */
    /* Get the input Matrix A, B */
    for(i=0; i < rowFunc-2; i++){
      TRAN_A[i] = (int_T)mxGetPr(TRAN_FUNC)[i+2];
      TRAN_B[i] = (int_T)mxGetPr(TRAN_FUNC)[rowFunc+i+2];
    }
    de2bi(TRAN_A, M, rowFunc-2, A);
    de2bi(TRAN_B, N, rowFunc-2, B);
    for(i=0; i < M; i++)
      x0[i] = 0;
  }
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

/*
 * mdlOutputs - compute the outputs
 *
 * In this function, you compute the outputs of your S-function
 * block.  The outputs are placed in the y variable.
 */
static void mdlOutputs(real_T *y, const real_T *x, const real_T *u, SimStruct *S, int_T tid)
{
/*elseif flag == 3 % output
 *  if u(length(u)) < .2
 *    % in the case of no signal, no processing.
 *    return;
 *  end;
 *  % otherwise, there is a signal, have to process.
 *  % initial parameters.
 *  [A, B, C, D, N, K, M] = gen2abcd(tran_func);
 *  u = u(1:K);
 *  if isempty(C)
 *    msg_i = bi2de(u(:)');
 *%    tran_indx = x(1) + 1 + msg_i * 2^K;
 *    tran_indx = x(1) + 1 + msg_i * 2^M;
 *    sys = B(tran_indx, :)';
 *  else
 *    x = x(:); u = u(:);
 *    sys = C * x + D * u;
 *    sys = rem(sys, 2);
 *  end;
 */
  int_T     i, j, len_C, msg_i, tran_indx, sum, tmp;
  int_T     colFunc, rowFunc, M, K, N, n_std_sta;
  int_T     *TRAN_A, *TRAN_B;
  int_T     *A, *B, *C, *D, *tmpRoom;
  
  rowFunc = mxGetM(TRAN_FUNC);
  colFunc = mxGetN(TRAN_FUNC);
  
  if( mxGetPr(TRAN_FUNC)[rowFunc*colFunc-1] < 0 ){
    N = (int_T)mxGetPr(TRAN_FUNC)[rowFunc*(colFunc-1)];
    K = (int_T)mxGetPr(TRAN_FUNC)[rowFunc*(colFunc-1)+1];
    M = (int_T)mxGetPr(TRAN_FUNC)[rowFunc*(colFunc-1)+2];
    len_C = M*N;
    
    A = ssGetIWork(S);
    B = A + M*M;
    C = B + M*K;
    D = C + N*M;
    tmpRoom = D + N*K;
    for(i=0; i < M; i++)
      tmpRoom[i] = (int_T)x[i];
    
    /* Get the input Matrix A, B, C, D */
    for( i=0; i < M+N; i++ ){
      for( j=0; j < M+K; j++ ){
	if( i<M   && j<M )
	  A[i+j*M] = (int_T)mxGetPr(TRAN_FUNC)[i+j*(M+N)];
	if( i>M-1 && j<M )
	  C[i+j*N-M] = (int_T)mxGetPr(TRAN_FUNC)[i+j*(M+N)];
	if( i<M   && j>M-1 )
	  B[i+j*M-M*M] = (int_T)mxGetPr(TRAN_FUNC)[i+j*(M+N)];
	if( i>M-1 && j>M-1 )
	  D[i+j*N-M*(N+1)] = (int_T)mxGetPr(TRAN_FUNC)[i+j*(M+N)];
      }
    }
  }else{
    N = (int_T)mxGetPr(TRAN_FUNC)[rowFunc];
    K = (int_T)mxGetPr(TRAN_FUNC)[rowFunc+1];
    M = (int_T)mxGetPr(TRAN_FUNC)[1];
    len_C = 0;
    
    /* Assignment */
    TRAN_A =    ssGetIWork(S);/*   !--- size of *TRAN_A */
    TRAN_B =    ssGetIWork(S) + (rowFunc-2);/* <--- size of *TRAN_B */
    A =         ssGetIWork(S) + 2*(rowFunc-2);/*    !----- size of *A */ 
    B =         ssGetIWork(S) + 2*(rowFunc-2) + (rowFunc-2)*M;/*    !----- size of *B */
    
    /* Get the input Matrix A, B */
    for(i=0; i < rowFunc-2; i++){
      TRAN_A[i] = (int_T)mxGetPr(TRAN_FUNC)[i+2];
      TRAN_B[i] = (int_T)mxGetPr(TRAN_FUNC)[rowFunc+i+2];
    }
    de2bi(TRAN_A, M, rowFunc-2, A);
    de2bi(TRAN_B, N, rowFunc-2, B);
  }
  
  n_std_sta = 1;
  for(i=0; i < M; i++)
    n_std_sta = n_std_sta * 2;
  
  if( u[K] >= 0.2 ){
    if( len_C == 0 ){
      msg_i = 0;
      for (i=0; i < K; i++){
       	tmp = (int_T)u[i];
    	if ( tmp != 0 && i > 0 ){
    	  for (j=0; j < i; j++)
    	    tmp = tmp*2;
    	}
    	msg_i = msg_i + tmp;
      }
      tran_indx = (int_T)x[0] +1 + msg_i * n_std_sta;
      for(i=0; i < N; i++)
    	y[i] = (real_T)B[tran_indx-1+i*(rowFunc-2)];
    }else{
      for(i=0; i < N; i++){
    	sum = 0;
    	for(j=0; j < M; j++)
    	  sum = sum + C[i+j*N]*tmpRoom[j];
    	for(j=0; j < K; j++)
    	  sum = sum + D[i+j*N]*u[j];
    	y[i] = (real_T)(sum % 2);
      }
    }
  }
}

/*
 * mdlUpdate - perform action at major integration time step
 *
 * This function is called once for every major integration time step.
 * Discrete states are typically updated here, but this function is useful
 * for performing any tasks that should only take place once per integration
 * step. PS: flag = 2.
 */
static void mdlUpdate(real_T *x, const real_T *u, SimStruct *S, int_T tid)
{
  /*
   *if (flag == 2) % refresh discrete-time states
   *  % the major processing routine.
   *  if u(length(u)) < .2
   *    % in the case of no signal, no processing.
   *    return;
   *  end;
   *
   *  % otherwise, there is a signal, have to process.
   *
   *  % initial parameters.
   *  [A, B, C, D, N, K, M] = gen2abcd(tran_func);
   *  u = u(1:K);
   *  if isempty(C)
   *    sys = zeros(M, 1);
   *    msg_i = bi2de(u(:)');
   *    tran_indx = x(1) + 1 + msg_i * 2^M;
   *    sys(1) = tran_func(tran_indx+2, 1);
   *  else
   *    x = x(:); u = u(:);
   *    sys = A * x + B * u;
   *    sys = rem(sys, 2);
   *  end;
   */    
  int_T     i, j, sum, len_C, msg_i, tran_indx, tmp;
  int_T     colFunc, rowFunc, M, K, N, n_std_sta;
  int_T     *TRAN_A, *TRAN_B;
  int_T     *A, *B, *C, *D, *tmpRoom;
  
  rowFunc = mxGetM(TRAN_FUNC);
  colFunc = mxGetN(TRAN_FUNC);
  
  if( mxGetPr(TRAN_FUNC)[rowFunc*colFunc-1] < 0 ){
    N = (int_T)mxGetPr(TRAN_FUNC)[rowFunc*(colFunc-1)];
    K = (int_T)mxGetPr(TRAN_FUNC)[rowFunc*(colFunc-1)+1];
    M = (int_T)mxGetPr(TRAN_FUNC)[rowFunc*(colFunc-1)+2];
    len_C = M*N;
    
    A = ssGetIWork(S);
    B = A + M*M;
    C = B + M*K;
    D = C + N*M;
    tmpRoom = D + N*K;
    for(i=0; i < M; i++)
      tmpRoom[i] = (int_T)x[i];
    
    /* Get the input Matrix A, B, C, D */
    for( i=0; i < M+N; i++ ){
      for( j=0; j < M+K; j++ ){
	if( i<M   && j<M )
	  A[i+j*M] = (int_T)mxGetPr(TRAN_FUNC)[i+j*(M+N)];
	if( i>M-1 && j<M )
	  C[i+j*N-M] = (int_T)mxGetPr(TRAN_FUNC)[i+j*(M+N)];
	if( i<M   && j>M-1 )
	  B[i+j*M-M*M] = (int_T)mxGetPr(TRAN_FUNC)[i+j*(M+N)];
	if( i>M-1 && j>M-1 )
	  D[i+j*N-M*(N+1)] = (int_T)mxGetPr(TRAN_FUNC)[i+j*(M+N)];
      }
    }
  }else{
    N = (int_T)mxGetPr(TRAN_FUNC)[rowFunc];
    K = (int_T)mxGetPr(TRAN_FUNC)[rowFunc+1];
    M = (int_T)mxGetPr(TRAN_FUNC)[1];
    len_C = 0;
  }
  
  n_std_sta = 1;
  for(i=0; i < M; i++)
    n_std_sta = n_std_sta * 2;
  
  if ( u[K] >= 0.2 ){
    if( len_C == 0 ){
      msg_i = 0;    
      for (i=0; i < K; i++){
	tmp = (int_T)u[i];
	if ( u[i] != 0 && i > 0 ){
	  for (j=0; j < i; j++)
	    tmp = tmp*2;
	}
	msg_i = msg_i + tmp;
      }
      tran_indx = (int_T)x[0] + 1 + msg_i * n_std_sta;
      x[0] = mxGetPr(TRAN_FUNC)[tran_indx+1];
    }else{
      for(i=0; i < M; i++){
	sum = 0;
	for(j=0; j < M; j++)
	  sum = sum + A[i+j*M]*tmpRoom[j];
	for(j=0; j < K; j++)
	  sum = sum + B[i+j*M]*u[j];
	x[i] = (real_T)(sum % 2);
      }
    }
  }
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
#include "cg_sfun.h"       /* code generation registration function */
#endif
