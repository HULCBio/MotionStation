/* $Revision: 1.1.6.2 $ */
/*
 * ARYSIN  array sin computation.
 *
 *           Syntax:  [sys, x0] = arysin(t,x,u,flag,Func)
 *                      where Func is the computation function to be specified.
 *                      the size of the output array is the same as the size
 *                      of the input array.
 * Wes Wang 5/11/94
 * Copyright 1996-2003 The MathWorks, Inc.
 */

/* specify the name of this S-Function. */
#define S_FUNCTION_NAME arysin

/* Defines for easy access  the matrices which are passed in */
#define NUM_ARGS    1
#define FUN_NAME    ssGetArg(S, 0)

/* include simstruc.h for the definition of the SimStruct and macro definitions. */
#include "simstruc.h"
#include "tmwtypes.h"
#include <math.h>

/* For RTW */
#if defined(RT) || defined(NRT)  
#undef  mexPrintf
#define mexPrintf printf
#endif

#ifdef MATLAB_MEX_FILE
#include "mex.h"
#endif

/*
 * mdlInitializeSizes - initialize the sizes array
 */

static void mdlInitializeSizes(SimStruct *S)
{
        ssSetNumContStates(    S, 0);        /* number of continuous states */
        ssSetNumDiscStates(    S, 0);        /* number of discrete states */
        ssSetNumInputs    (    S, -1);       /* number of inputs */
        ssSetNumOutputs   (    S, -1);       /* number of outputs */
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
    int_T  inSize, i;
    char_T funct[4];

    mxGetString(FUN_NAME, funct, 3);
    inSize = ssGetNumInputs(S);

#ifdef MATLAB_MEX_FILE
      if (0) {
	char_T err_msg[255];
	sprintf(err_msg, "Input character %c %c %c \n", funct[0], funct[1], funct[2]);
	mexPrintf(err_msg);
      }
#endif

/*    mexPrintf(funct);   */
    if ((funct[0]== 's') && (funct[1] == 'i')) {
      /* sin function */
      for (i=0; i < inSize; i++) y[i] = sin(u[i]);
    } else if ((funct[0]== 'c') && (funct[1] == 'o')) {
      /* cos function */
      for (i=0; i < inSize; i++) y[i] = cos(u[i]);
    } else if ((funct[0]== 't') && (funct[1] == 'a')) {
      /* tan function */
      for (i=0; i < inSize; i++) y[i] = tan(u[i]);
    } else if ((funct[0]== 'e') && (funct[1] == 'x')) {
      /* exp function */
      for (i=0; i < inSize; i++) y[i] = exp(u[i]);
    } else if ((funct[0]== 'a') && (funct[1] == 's')) {
      /* asin function */
      for (i=0; i < inSize; i++) y[i] = asin(u[i]);
    } else if ((funct[0]== 'a') && (funct[1] == 'c')) {
      /* acos function */
      for (i=0; i < inSize; i++) y[i] = acos(u[i]);
    } else if ((funct[0]== 'a') && (funct[1] == 't')) {
      /* atan function */
      for (i=0; i < inSize; i++) y[i] = atan(u[i]);
    } else if ((funct[0]== 'l') && (funct[1] == 'n')) {
      /* ln function */
      for (i=0; i < inSize; i++) y[i] = log(u[i]);
    } else if ((funct[0]== 'l') && (funct[1] == 'o')) {
      /* log10 function */
      for (i=0; i < inSize; i++) y[i] = log10(u[i]);
    } else if ((funct[0]== 's') && (funct[1] == 'q')) {
      /* sqrt function */
      for (i=0; i < inSize; i++) {
       	if (u[i] > 0)
	       y[i] = sqrt(u[i]);
	    else if (u[i] < 0)
	       y[i] = -sqrt(-u[i]);
     	else
	       y[i] = 0;
      }
    } else if ((funct[0]== 's') && (funct[1] == 'g')) {
       /* sgn function */
       for (i=0; i< inSize; i++) {
          if (u[i] < 0)
            y[i] = -1.;
          else
            y[i] = 1.;
       }
    } else if ((funct[0]== 'r') && (funct[1] == 'o')) {
        /* round to the nearest integers */
        for (i=0; i<inSize; i++) {
            y[i] = (real_T) floor(u[i]);
            if ((u[i]-y[i]) >= .5) {
                y[i] = (real_T) ceil(u[i]);
            }
        }
    } else if ((funct[0]== 'f') && (funct[1] == 'l')) {
        /* floor */
        for (i=0; i<inSize; i++) {
            y[i] = (real_T) floor(u[i]);
        }
    } else if ((funct[0]== 'c') && (funct[1] == 'e')) {
        /* ceiling */
        for (i=0; i<inSize; i++) {
            y[i] = (real_T) ceil(u[i]);
        }
    } else if ((funct[0]== 'a') && (funct[1] == 'b')) {
        /* abs */
        for (i=0; i<inSize; i++) {
            y[i] = fabs(u[i]);
        }        
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

#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif
