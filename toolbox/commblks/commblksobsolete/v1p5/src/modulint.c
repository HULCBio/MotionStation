/* $Revision: 1.1.6.1 $ */
/*
 * MODULINT  A modulate integrator.
 *           (see manual under Advanced Topics).
 *
 *           Syntax:  [sys, x0] = moldulint(t,x,u,flag,x0,lowbd,upbd)
 *
 * Wes Wang 5/5/94
 * Copyright 1996-2002 The MathWorks, Inc.
 */
#define S_FUNCTION_NAME modulint

#undef MODEL_NAME
#define MODEL_NAME modulint

#define NUM_ARGS   3
#define X0  ssGetArg(S, 0)
#define MX_UP  ssGetArg(S,1)
#define MX_LOW ssGetArg(S,2)

/*
    Matrix *MX_UP, *MX_LOW;
    mxArray  *MX_UP, *MX_LOW;
*/


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
    
    ssSetNumContStates(    S, 1);
    ssSetNumDiscStates(    S, 0);
    ssSetNumOutputs(       S, 1);
    ssSetNumInputs(        S, 1);
    ssSetDirectFeedThrough(S, 0);
    ssSetNumSampleTimes(   S, 1);
    ssSetNumRWork(         S, 0);
    ssSetNumIWork(         S, 0);
    ssSetNumInputArgs(     S, 3);
}

/*
 * mdlInitializeSampleTimes - initializes the array of sample times stored in
 *                            the SimStruct associated with this S-Function.
 */

static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTimeEvent(S, 0, 0.);
    ssSetOffsetTimeEvent(S, 0, 0.);
}

/*
 * mdlInitializeConditions - initializes the states for the S-Function
 */

static void mdlInitializeConditions(real_T *x0, SimStruct *S)
{
    if ((mxGetM(X0) == 0) || (mxGetN(X0) == 0))
     *x0 = 0.;
    else
       *x0 = mxGetPr(X0)[0];
}

/*
 * mdlOutputs - computes the outputs of the S-Function
 */

static void mdlOutputs(real_T *y, const real_T *x, const real_T *u, SimStruct *S, int_T tid)
{
    y[0] = x[0];
}

/*
 * mdlUpdate - computes the discrete states of the S-Function
 */

static void mdlUpdate(real_T *x, const real_T *u, SimStruct *S, int_T tid)
{
    real_T bd_up, bd_low, differ;


    if ( mxGetM(MX_UP) == 0 || mxGetN(MX_UP) == 0 )    
      bd_up = 0;
    else
      bd_up = mxGetPr(MX_LOW)[0];

    if ( mxGetM(MX_LOW) == 0 || mxGetN(MX_LOW) == 0 )    
      bd_low = 0.;
    else
      bd_low = mxGetPr(MX_UP)[0];

    differ = bd_up - bd_low;

	if (differ > 0.0) {
		/* This xt is using here because the MSVC++ compiler's problem.
		 * old code is like the  following:
		 * 
		      if (differ > 0.0) {
			while (u[0] < bd_low)
			    x[0] = x[0] + differ;
			while (x[0] > bd_up)
			    x[0] = x[0] - differ;
		       }
		 *      
                 * This caused a compileing error. Reason unknown.
		 */
		real_T xt;
		xt = x[0];
		while ( xt < bd_low){
			xt = xt + differ;
		}
		while (xt > bd_up){
			xt = xt - differ;
		}
		x[0] = xt;
    }

}

/*
 * mdlDerivatives - computes the derivatives of the S-Function
 */

static void mdlDerivatives(real_T *dx, const real_T *x, const real_T *u, SimStruct *S, int_T tid)
{
    dx[0] = u[0];
}

/*
 * mdlTerminate - called at termination of model execution.
 */

static void mdlTerminate(SimStruct *S)
{
}

#ifdef    MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX glue */
#else
#include "cg_glue.h"       /* Code generation glue */
#endif










