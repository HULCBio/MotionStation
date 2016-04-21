/* $Revision: 1.1.6.2 $ */
/*
 * ARYMIMAI  array minimum/maximum index computation. 
 *
 *           Syntax:  [sys, x0] = arymimai(t,x,u,flag,Func)
 *                      where Func is the string which could be min or max.
 *                      There is one output which is the index number range
 *                      from 0 to M-1 where M is the input vector size.
 *                      The input could be any real data.
 * Wes Wang 5/11/94
 * Copyright 1996-2003 The MathWorks, Inc.
 */

/* specify the name of this S-Function. */
#define S_FUNCTION_NAME arymimai

/* Defines for easy access  the matrices which are passed in */
#define NUM_ARGS    1
#define FUN_NAME    ssGetArg(S, 0)

/* include simstruc.h for the definition of the SimStruct and macro definitions. */
#include "simstruc.h"
#include "tmwtypes.h"
#include <math.h>

/*
 * mdlInitializeSizes - initialize the sizes array
 */

static void mdlInitializeSizes(SimStruct *S)
{
  ssSetNumContStates(    S, 0);        /* number of continuous states */
  ssSetNumDiscStates(    S, 0);        /* number of discrete states */
  ssSetNumInputs    (    S, -1);       /* number of inputs */
  ssSetNumOutputs   (    S, 1);        /* number of outputs */
  ssSetDirectFeedThrough(S, 1);        /* direct feedthrough flag */
  ssSetNumSampleTimes(   S, 1);        /* number of sample times */
  ssSetNumInputArgs(     S, NUM_ARGS); /* number of input arguments */
  ssSetNumRWork(         S, 0);        /* number of real work vector elements */
  ssSetNumIWork(         S, 0);        /* number of integer work vector elements */
  ssSetNumPWork(         S, 0);        /* number of pointer work vector elements */
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
 * mdlInitializeConditions - initialize the states
 * Initialize the states, Integers and real-numbers
 */

static void mdlInitializeConditions(real_T *x0, SimStruct *S)
{
}

/*
 * mdlOutputs - compute the outputs
 *
 * In this function, you compute the outputs of your S-function
 * block.  The outputs are placed in the y variable.
 */

static void mdlOutputs(real_T *y, const real_T *x, const real_T *u, SimStruct *S, int_T tid)
{
	int_T  inSize, i, ind;
	real_T tmp;
	char_T funct[5];

	mxGetString(FUN_NAME, funct, 4);  
	inSize = ssGetNumInputs(S);
	tmp = u[0];
	ind = 0;
	if (inSize > 1) 
	{
		if (funct[1] == 'a')
		{
			for (i=1; i<inSize; i++) 
			{
				if (tmp < u[i]) 
				{
					tmp = u[i];
					ind = i;
				}
			}
		}
		if (funct[1] == 'i') 
		{
			for (i=1; i<inSize; i++) 
			{
				if (tmp > u[i]) 
				{
					tmp = u[i];
					ind = i;
				}
			}
		}
	}
	y[0] = (real_T)ind;

	if (funct[2] == 'v')
		y[0] = tmp;
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

#ifdef   MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif
