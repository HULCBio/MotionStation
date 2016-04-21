/* $Revision: 1.1.6.1 $ */
/*
 * SCOMPOISSRC  Simulink poisson distribution number generator.
 *
 *      Syntax:  [sys, x0] = SCOMPOISSRC(t, x, u, flag, seed, lambda,Ts)
 *      This function generates the poisson distribution number.
 *      When seed is a vector, the function generates a vector with
 *      the vector length same as the length of seed vector.
 *
 * Modified by Trefor Delve May 28 1998
 * Originally Wes Wang  Feb. 16, 1995
 * Copyright 1996-2002 The MathWorks, Inc.
 */

#define S_FUNCTION_NAME scompoissrc

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

#define NUM_ARGS       3
#define INISEED        ssGetArg(S,0)
#define LAMBDA         ssGetArg(S,1)
#define TS             ssGetArg(S,2)

#define LOW_SEED   1          /* minimum seed value */
#define HIGH_SEED  2147483646 /* maximum seed value */
#define START_SEED 1144108930 /* default seed value */

/*
 * mdlInitializeSizes - called to initialize the sizes array stored in
 *                      the SimStruct.  The sizes array defines the
 *                      characteristics (number of inputs, outputs,
 *                      states, etc.) of the S-Function.
 */

static real_T urand(uint_T *seed)
{
	uint_T hi, lo;
#if (UINT_MAX == 0xffffffff)
	int_T test;
#else
	long test;
#endif

#define IA 16807	/* magic multiplier = 7^5 */
#define IM 2147483647	/* modulus = 2^31 - 1 */
#define IQ 127773	/*IM div IA */
#define IR 2836	/* IM modulo IA */
#define S  4.656612875245797e-10	/* reciprocal of 2^31-1 */

	hi = *seed / IQ;
	lo = *seed % IQ;
	test = IA * lo - IR * hi;

	*seed = ((test < 0) ? (uint_T)(test + IM) : (uint_T)test);

	return ((real_T) (*seed * S));

#undef IA
#undef IM
#undef IQ
#undef IR
#undef S
}

static void mdlInitializeSizes(SimStruct *S)
{
  /*
   * Set-up size information.
   */ 
    
  if (ssGetNumArgs(S) == NUM_ARGS) {
    int_T numOutput;

    numOutput = mxGetN(INISEED) * mxGetM(INISEED);

#ifdef MATLAB_MEX_FILE
    if (numOutput < 1) {
      char_T err_msg[256];
      sprintf(err_msg, "Input variable is empty.");
      mexErrMsgTxt(err_msg);
    }

    if (((mxGetN(LAMBDA) * mxGetM(LAMBDA)) != 1) && (mxGetN(LAMBDA) * mxGetM(LAMBDA)) != numOutput) {
      char_T err_msg[256];
      sprintf(err_msg, "Dimension for LAMBDA must match the dimension for seeds.");
      mexErrMsgTxt(err_msg);
    }

    if(mxGetNumberOfElements(TS) != 1) {
        char_T err_msg[256];
        sprintf(err_msg, "The sample time must be a scalar value.");
        mexErrMsgTxt(err_msg);
    }
#endif    

    ssSetNumContStates(    S, 0);
    ssSetNumDiscStates(    S, 0);
    ssSetNumInputs(        S, 0);
    ssSetNumOutputs(       S, numOutput);
    ssSetDirectFeedThrough(S, 0);
    ssSetNumInputArgs(     S, NUM_ARGS);
    ssSetNumSampleTimes(   S, 1);
    ssSetNumRWork(         S, numOutput);
    ssSetNumIWork(         S, numOutput);
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
   	real_T  Ts         = mxGetPr(TS)[0];

   	if(Ts == -1.0)
	  {
	       ssSetSampleTimeEvent(S, 0, INHERITED_SAMPLE_TIME);
   	    ssSetOffsetTimeEvent(S, 0, FIXED_IN_MINOR_STEP_OFFSET);
	  }
   	else
	  {
	       ssSetSampleTimeEvent(S, 0, Ts);
   	    ssSetOffsetTimeEvent(S, 0, 0);
	  }
}

/*
 * mdlInitializeConditions - initializes the states for the S-Function
 */

static void mdlInitializeConditions(real_T *x0, SimStruct *S)
{
    int_T     numOutput, i, mFlag, while_flag;
    real_T  p, lam;
    real_T  *RWork         = ssGetRWork(S);       /* Real Work Vector */
    int_T   *IWork         = ssGetIWork(S);       /* Integer Work Vector */
    real_T  *Pseed         = (real_T *)mxGetPr(INISEED);
    real_T  *Lambda        = (real_T *)mxGetPr(LAMBDA);

    numOutput = mxGetN(INISEED) * mxGetM(INISEED);

    if (mxGetN(LAMBDA) * mxGetM(LAMBDA) <= 1) {
      mFlag = 1;
    } else {
      mFlag = 0;
    }

    for (i = 0; i < numOutput; i++) {
      IWork[i] = (int)Pseed[i];
      if ((IWork[i] < LOW_SEED) || (IWork[i] > HIGH_SEED))
	  IWork[i] = START_SEED + i;
      RWork[i] = 0;
      if (mFlag)
	lam = Lambda[0];
      else
	lam = Lambda[i];
      p = 0;
      while_flag = 1;
      while (while_flag) {
	p = p - log(urand((uint_T *) &IWork[i]));
	if (p > lam)
	  while_flag = 0;
	else
	  RWork[i] += 1;
      }
    }
}

/*
 * mdlOutputs - computes the outputs of the S-Function
 */

static void mdlOutputs(real_T *y, const real_T *x, const real_T *u, SimStruct *S, int_T tid)
{
    int_T     numOutput, i, mFlag, while_flag;
    real_T  *RWork         = ssGetRWork(S);       /* Real Work Vector */
    int_T     *IWork         = ssGetIWork(S);       /* Integer Work Vector */
    real_T  *Lambda        = (real_T *)mxGetPr(LAMBDA);
    real_T  p, lam;

    ssSetSolverNeedsReset(S);

	if(ssIsSampleHit(S,0,tid))
	{

      numOutput = mxGetN(INISEED) * mxGetM(INISEED);

       if (mxGetN(LAMBDA) * mxGetM(LAMBDA) <= 1) {
         mFlag = 1;
       } else {
         mFlag = 0;
       }

       for (i = 0; i < numOutput; i++) {
         y[i] = RWork[i];
         RWork[i] = 0;
         if (mFlag)
           	lam = Lambda[0];
         else
   	     lam = Lambda[i];
         p = 0;
         while_flag = 1;
            while (while_flag) {
         	  p = p - log(urand((uint_T *) &IWork[i]));
         	if (p > lam)
	          while_flag = 0;
         	else
         	  RWork[i] += 1;
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
