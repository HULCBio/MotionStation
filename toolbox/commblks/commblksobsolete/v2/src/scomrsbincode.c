/*
 *  Syntax:[sys, x0, str, ts] = scomrsbincode(t, x, u, flag, n, k, pg, tp, dim)
 *  SCOMRSBINCODE Simulink S-function for Reed-Solomon code, binary vector version
 *       This file is designed to be used in a Simulink S-Function block.
 *       This function will encode the k*dim input binary vector to a n*m
 *       binary code word.
 *       Parameters: n -- length of code word.
 *                   k -- length of message.
 *                   pg-- generator polynomial
 *                   tp-- list of all GF(2^M) elements. n=2^M-1.
 *                   dim -- M.
 *
 *       The output has length n*dim.
 *
 *  Copyright 1996-2003 The MathWorks, Inc.
 *  $Revision: 1.1.6.2 $  $Date: 2004/04/12 23:02:22 $
 */
 
#define S_FUNCTION_NAME scomrsbincode

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

#define NUM_ARGS    5           /* five additional input arguments */
#define N       ssGetArg(S,0)
#define K       ssGetArg(S,1)
#define PG      ssGetArg(S,2)
#define P       ssGetArg(S,3)
#define DIM     ssGetArg(S,4)

#define Prim 2 
/*elseif flag == 0
 *    if 2^dim-1 ~= n
 *        error('Reed-Solomon encode has illegal code word length')
 *    end;
 *    sys(1) = 0; % no continuous state
 *    sys(2) = 0;
 *    sys(3) = n * dim;   % number of output, code word length plus one.
 *    sys(4) = k * dim + 1;       % number of input, message length.
 *    sys(5) = 0;
 *    sys(6) = 1;       % direct through flag.
 *    sys(7) = 1;       % one sample rate
 *    x0 = [];
 *    ts = [-1, 0];
 *else
 *    sys = [];
 *end;
 */
static void mdlInitializeSizes(SimStruct *S)
{
    int_T     i, np, len_pg;
    int_T     n = (int_T)mxGetPr(N)[0];
    int_T     k = (int_T)mxGetPr(K)[0];
    int_T     dim = (int_T)mxGetPr(DIM)[0];

    len_pg = mxGetM(PG)*mxGetN(PG);
    np = 1;
    for(i=0; i < dim; i++)
        np = np*2;

    if ( np-1 != n ){
#ifdef MATLAB_MEX_FILE
        mexErrMsgTxt("Reed-Solomon decode has illegal code word length");
#endif
    } 
    ssSetNumContStates(     S, 0);          /* no continuous states */
    ssSetNumDiscStates(     S, 0);          /* no discrete states */
    ssSetNumOutputs(        S, n*dim);      /* number of output, code word length plus one*/
    ssSetNumInputs(         S, k*dim);      /* number of inputs, message length*/
    ssSetDirectFeedThrough( S, 1);          /* direct feedthrough flag */
    ssSetNumSampleTimes(    S, 1);          /* number of sample times */
    ssSetNumInputArgs(      S, NUM_ARGS);   /* number of input arguments*/
    ssSetNumRWork(          S, 0);
    ssSetNumIWork(          S, (2*n+3)*dim+len_pg+k+3*n+6);
                                /* (n+1)*dim    --- *pp
                                 * len_pg-1 ------- *pgg
                                 * k*dim ---------- *tmpRoom
                                 * k -------------- *pDec
                                 * n -------------- *msg
                                 * 1 -------------- *tmpMul
                                 * 1 -------------- *len
                                 * n+3+dim -------- Iwork for gfpmul()
                                 * n+2+dim -------- Iwork for gfpadd()
                                 * (n-k)*dim ------ tmpOut
                                 */
    ssSetNumPWork(          S, 0);
}                                  

/*
 * mdlInitializeConditions - initialize the states
 * Initialize the states, Integers and real-numbers
 */
static void mdlInitializeConditions(real_T *x0, SimStruct *S)
{
    int_T     i, len_pg;
    int_T     n, k, dim; 
    int_T     *pp, *pgg, *tmpRoom, *pDec, *msg, *tmpMul;
    int_T     *len, *IworkMul, *IworkAdd, *tmpOut;
    real_T  *p, *pg;

    pg = (real_T *)mxGetPr(PG);
    p = (real_T *)mxGetPr(P); 
    len_pg = mxGetM(PG)*mxGetN(PG);

    n = (int_T)mxGetPr(N)[0];
    k = (int_T)mxGetPr(K)[0];
    dim = (int_T)mxGetPr(DIM)[0];
    
    pp =        ssGetIWork(S);
    pgg =       ssGetIWork(S)+(n+1)*dim;
    tmpRoom =   ssGetIWork(S)+(n+1)*dim+len_pg-1;
    pDec =      ssGetIWork(S)+(n+1)*dim+len_pg-1+k*dim;
    msg =       ssGetIWork(S)+(n+1)*dim+len_pg-1+k*dim+k;
    tmpMul =    ssGetIWork(S)+(n+1)*dim+len_pg-1+k*dim+k+n;
    len =       ssGetIWork(S)+(n+1)*dim+len_pg-1+k*dim+k+n+1;
    IworkMul =  ssGetIWork(S)+(n+1)*dim+len_pg-1+k*dim+k+n+2;
    IworkAdd =  ssGetIWork(S)+(n+1)*dim+len_pg-1+k*dim+k+n+2+n+3+dim;
    tmpOut =    ssGetIWork(S)+(n+1)*dim+len_pg-1+k*dim+k+n+2+n+3+dim+n+2+dim;

    for( i=0; i<(n+1)*dim; i++ )
        pp[i] = (int_T)p[i];
    for(i=0; i<len_pg-1; i++)
        pgg[i] = (int_T)pg[len_pg-2-i];
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
 *        % main calculation
 *        t2 = n - k;
 *        pgg = fliplr(pg(1:length(pg)-1));       % pg is a monic polynomial
 *        msg = bi2de(vec2mat(u(1 : len_u-1), dim)) - 1;
 *        msg = [flipud(msg); -ones(t2,1)];
 *        sz = (len_u - 1) /dim;
 *        for main_j = 1 : sz
 *            if msg(main_j)>= 0
 *                for main_k = 1: t2
 *                    msg(main_j + main_k) = gfadd(msg(main_j + main_k), gfmul(msg(main_j), pgg(main_k), tp), tp);
 *                end;
 *            end;
 *        end;
 *        sys = [flipud(msg(sz+1:n))+1];
 *        indx = find(~(sys >= 0));
 *        sys(indx) = indx - indx;
 *        sys = de2bi(sys, dim)';
 *        sys = sys(:);
 *        sys = [sys; u(1:len_u - 1)];
 *%        disp(['should output ', num2str(n * dim), ' it is now ', num2str(length(sys))])
 *    else
 *        % if there is no trigger, no calculation.
 *        if t <= 0
 *            sys = zeros(n * dim, 1);
 *        end;
 *    end;
 */
/* mdlOutputs - compute the outputs
 * In this function, you compute the outputs of your S-function
 * block.  The outputs are placed in the y variable.
 */
static void mdlOutputs(real_T *y, const real_T *x, const real_T *u, SimStruct *S, int_T tid)
{
    int_T     i, j, len_pg, t2, tmp;
    int_T     main_j, main_k;
    int_T     n, k, dim; 
    int_T     *pp, *pgg, *tmpRoom, *pDec, *msg, *tmpMul;
    int_T     *len, *IworkMul, *IworkAdd, *tmpOut;
    real_T  *p, *pg;
    real_T  t;

    t =     ssGetT(S);
    pg =    (real_T *)mxGetPr(PG);
    p =     (real_T *)mxGetPr(P); 
    len_pg= mxGetM(PG)*mxGetN(PG);

    n = (int_T)mxGetPr(N)[0];
    k = (int_T)mxGetPr(K)[0];
    dim = (int_T)mxGetPr(DIM)[0];
    
    pp =        ssGetIWork(S);
    pgg =       ssGetIWork(S)+(n+1)*dim;
    tmpRoom =   ssGetIWork(S)+(n+1)*dim+len_pg-1;
    pDec =      ssGetIWork(S)+(n+1)*dim+len_pg-1+k*dim;
    msg =       ssGetIWork(S)+(n+1)*dim+len_pg-1+k*dim+k;
    tmpMul =    ssGetIWork(S)+(n+1)*dim+len_pg-1+k*dim+k+n;
    len =       ssGetIWork(S)+(n+1)*dim+len_pg-1+k*dim+k+n+1;
    IworkMul =  ssGetIWork(S)+(n+1)*dim+len_pg-1+k*dim+k+n+2;
    IworkAdd =  ssGetIWork(S)+(n+1)*dim+len_pg-1+k*dim+k+n+2+n+3+dim;
    tmpOut =    ssGetIWork(S)+(n+1)*dim+len_pg-1+k*dim+k+n+2+n+3+dim+n+2+dim;

    for( i=0; i<(n+1)*dim; i++ )
      pp[i] = (int_T)p[i];

    for(i=0; i<len_pg-1; i++)
      pgg[i] = (int_T)pg[len_pg-2-i];

    t2 = n - k;

    for(i=0; i < dim; i++){
      for(j=0; j < k; j++)
        tmpRoom[i*k+j] = (int_T)u[i+j*dim];
    }

    bi2de(tmpRoom, k, dim, Prim, pDec);

    for(i=0; i < n; i++){
      if(i < k) 
        msg[i] = pDec[k-1-i]-1;
      else
        msg[i] = -1;
    }

    for(main_j=0; main_j < k; main_j++){
      if (msg[main_j] >= 0){
        for(main_k=0; main_k < t2; main_k++){
          tmpMul[0] = 0;
          len[0] = 1;
          gfpmul(&msg[main_j],1,&pgg[main_k],1,pp,n+1,dim,tmpMul,len,IworkMul);
          gfpadd(&msg[main_j+main_k+1],1,tmpMul,1,pp,n+1,dim,&msg[main_j+main_k+1],len,IworkAdd);
        }
      }
    }

    for(i=0; i < n-k; i++){
      if( msg[n-1-i]+1 >= 0 )
        tmp = msg[n-1-i]+1;
      else
        tmp = 0;
      for(j=0; j < dim; j++){
        tmpOut[i*dim+j] = tmp % Prim;
        if(j < dim-1)
          tmp = (int_T)tmp/Prim;
      }
    }

    for(i=0; i<(n-k)*dim; i++)
      y[i] = (real_T)tmpOut[i];

    for(i=0; i < k*dim; i++)
      y[i+(n-k)*dim] = u[i];

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
