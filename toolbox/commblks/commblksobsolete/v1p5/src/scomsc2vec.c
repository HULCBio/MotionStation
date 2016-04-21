/* $Revision: 1.1.6.1 $ */
/*
 * Modified by Trefor Delve 6/10/98
 * Originally Wes Wang 6/14/94
 * Copyright 1996-2002 The MathWorks, Inc.
 */

/* specify the name of this S-Function. */
#define S_FUNCTION_NAME scomsc2vec

#include "simstruc.h"
#include "tmwtypes.h"

/* For RTW */
#if defined(RT) || defined(NRT)  
#undef  mexPrintf
#define mexPrintf printf
#endif

/* Defines for easy access  the matrices which are passed in */
#define NUM_ARGS    3 
#define BUFF_LEN    ssGetArg(S, 0)
#define CAL_BASE    ssGetArg(S, 1)
#define MSB_FLAG    ssGetArg(S, 2)

/*
 * mdlInitializeSizes - initialize the sizes array
 */

static void mdlInitializeSizes(SimStruct *S)
{
        int_T outSize;

        outSize = (int_T)mxGetPr(BUFF_LEN)[0];    

        ssSetNumContStates(    S, 0); /* number of continuous states */
        ssSetNumDiscStates(    S, 0);       /* number of discrete states */
        ssSetNumInputs    (    S, 1);   /* number of inputs */
        ssSetNumOutputs   (    S, outSize);   /* number of outputs */
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
    long outSize, i, p, inNum;
    int_T inc = 1, Count = 0,MSBFlag = 0;

    inNum = (int_T)u[0];
    outSize = (int_T)mxGetPr(BUFF_LEN)[0];
    MSBFlag = (int_T)mxGetPr(MSB_FLAG)[0];

    p = (int_T)mxGetPr(CAL_BASE)[0];
    if (p < 2)
        p = 2;       

    /* --- If the MSB is required as the first element of the vector, change the order */
    if(MSBFlag)
    {
      Count = outSize - 1;
      inc = -1;
    }

    if (inNum > 0) 
    {
      for (i=0; i < outSize; i++) 
      {
         y[Count] = inNum % p;
         inNum /= p;
         Count += inc;
      }
    }
    else
    {
      for (i=0; i < outSize; i++)
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

#ifdef      MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif
