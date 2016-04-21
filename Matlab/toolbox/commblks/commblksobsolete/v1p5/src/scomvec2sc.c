/* $Revision: 1.1.6.1 $ */
/*
 * scomvec2sc  Vector to scalar conversion for Simulink block
 *
 *           Syntax:  [sys, x0] = scomvec2sc(t,x,u,flag,p,MSBFlag)
 *                          where p is the calculation base.
 *
 * Modified by Trefor Delve 6/10/98
 * Originally Wes Wang 6/14/94
 * Copyright 1996-2002 The MathWorks, Inc.
 */

/* specify the name of this S-Function. */
#define S_FUNCTION_NAME scomvec2sc

/* Defines for easy access  the matrices which are passed in */
#define NUM_ARGS    2
#define CAL_BASE    ssGetArg(S, 0)
#define MSB_FLAG    ssGetArg(S, 1)

#include "simstruc.h"
#include "tmwtypes.h"

/* For RTW */
#if defined(RT) || defined(NRT)  
#undef  mexPrintf
#define mexPrintf printf
#endif
/*
 * mdlInitializeSizes - initialize the sizes array
 */

static void mdlInitializeSizes(SimStruct *S)
{
        ssSetNumContStates(    S, 0); /* number of continuous states */
        ssSetNumDiscStates(    S, 0);       /* number of discrete states */
        ssSetNumInputs    (    S, -1);   /* number of inputs */
        ssSetNumOutputs   (    S, 1);   /* number of outputs */
        ssSetDirectFeedThrough(S, 1);       /* direct feedthrough flag */
        ssSetNumSampleTimes(   S, 1);       /* number of sample times */
        ssSetNumInputArgs(     S, NUM_ARGS);/* number of input arguments */
        ssSetNumRWork(         S, 0);       /* number of real work vector elements */
        ssSetNumIWork(         S, 0);      /* number of integer work vector elements */
        ssSetNumPWork(         S, 0);      /* number of pointer work vector elements */
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
    long inSize, i, pow, p;
    int_T inc = 1, Count = 0,MSBFlag = 0;

    inSize = (int_T)ssGetNumInputs(S);

    MSBFlag = (int_T)mxGetPr(MSB_FLAG)[0];

    p = (int_T)mxGetPr(CAL_BASE)[0];
    if (p < 2)
        p = 2;    
    y[0] = 0;
    pow = 1;

    /* --- If the MSB is required as the first element of the vector, change the order */
    if(MSBFlag)
    {
      Count = inSize - 1;
      inc = -1;
    }

    for (i=0; i <inSize; i++)
    {
      y[0] += (real_T)(abs((int_T)u[Count]) % p * pow);
      pow  *= p;

      Count += inc;
    }



/*    for (i=inSize-1; i>=0; i--) 
    {
         y[0] += (real_T)(abs((int_T)u[i]) % p * pow);
         pow  *= p;
    }
*/

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

#ifdef       MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif
