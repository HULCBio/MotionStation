/* $Revision: 1.1.6.2 $ */

/*========================================================================
 *     Syntax: [sys, x0, str, ts] = srandbit(t, x, u, flag, n, prob, seed)
 *
 * SCOMRBITSRC.c --- file name
 * COMMU TOOLBOX : Outputs a zero vector with random bit ones as Source.
 * SCOMRBITSRC outputs a zero vector with random bit ones.
 *           This block outputs a zero vector with ones in the vector.
 *       	The probability of ones in the vector is controlled by the input
 *       	vector prob.
 *
 * Modified by Trefor Delve, 28th May 1998
 *
 * Jun Wu,  The MathWorks, Inc.
 * Nov. 14, 1995
 *
 * Originally designed by Wes Wang,
 * Copyright 1996-2003 The MathWorks, Inc.
 *
 *========================================================================
 *
 * This function has no input and one output. The output is a zero vector
 * with ones in the vector. The probability of ones in the vector is
 * controlled by the input vector prob[].
 *
 * n    is the element number of output vector. 
 * prob is the probability of ones in the output vector. The sum of all
 *           elements in prob cannot be greater than one.
 * seed is the seed of the random number generator.
 *
 *========================================================================*/
#define S_FUNCTION_NAME scomrbitsrc

/* need to include simstruc.h for the definition of the SimStruct and
 * its associated macro definitions.
 */ 
#include "simstruc.h"
#include "tmwtypes.h"

#define NUM_ARGS    4           /* Four additional input arguments */
#define N       ssGetArg(S,0)   /* the length of  output vector */
#define PROB    ssGetArg(S,1)   /* the probability of ones in output vector */
#define SEED    ssGetArg(S,2)   /* the seed of output */

#define TS      ssGetArg(S,3)   /* Sample time */

#define LOW_SEED    1           /* minimum seed value */
#define HIGH_SEED   2147483646  /* maximum seed value */
#define START_SEED  1144108930  /* default seed value */          

/*
 * uniform mxRandom number generator
 */
static real_T Urand(uint_T *seed)  		/* pointer to a running seed */
{
#if (UINT_MAX == 0xffffffff)
    int_T test;
#else
    long test;
#endif

#define IA	16807			/*	magic multiplier = 7^5	*/
#define IM	2147483647		/*	modulus = 2^31-1	*/  
#define IQ	127773			/*	IM div IA		*/
#define IR	2836			/*	IM modulo IA		*/
#define S	4.656612875245797e-10 	/*	reciprocal of 2^31-1	*/

    uint_T hi, lo;
    
    hi = *seed / IQ;
    lo = *seed % IQ;
    test = IA * lo - IR * hi;	/* never overflows	*/
    
    *seed = ((test < 0) ? (uint_T)(test + IM) : (uint_T)test);
    
    return ((real_T) (*seed *S));
    
#undef  IA
#undef  IM
#undef  IQ
#undef  IR
#undef  S
}


/* Function: mdlCheckParameters ===============================================
 * Abstract:
 *      Check if the specified parameters are ok. If they are, then check if
 *      this block's sub-class record is set, if it is not, then cache away
 *      the parameter values in this record.
 */
#ifdef MATLAB_MEX_FILE
#define MDL_CHECK_PARAMETERS
static void mdlCheckParameters(SimStruct *S) {

    static char_T err_msg[256];

    int_T     i, tempVar;
    int_T     NumOutput=0;
    int_T     len_prob = 0;
    real_T    sum = 0.0;

    /* --- Length of the output vector --- */

    if (mxGetN(N)*mxGetM(N) < 1) 
    {
      sprintf(err_msg, "Output vector length not defined");
      ssSetErrorStatus(S,err_msg);
      return;
    }

    if ((mxGetN(N) > 1) + (mxGetM(N) > 1)) 
    {
      sprintf(err_msg, "Output vector length must be specified as a scalar");
      ssSetErrorStatus(S,err_msg);
      return;
    }

    NumOutput = (int)mxGetPr(N)[0];

    if (NumOutput < 1) 
    {
      sprintf(err_msg, "Output vector length must be greater than zero");
      ssSetErrorStatus(S,err_msg);
      return;
    }

    /* --- Probability vector --- */

    if (mxGetN(PROB)*mxGetM(PROB) < 1) 
    {
      sprintf(err_msg, "Probability vector length not defined");
      ssSetErrorStatus(S,err_msg);
      return;
    }

    if ((mxGetN(PROB) > 1) * (mxGetM(PROB) > 1)) 
    {
      sprintf(err_msg, "Probability parameter may be a scalar or vector NOT a matrix");
      ssSetErrorStatus(S,err_msg);
      return;
    }

    len_prob= mxGetN(PROB) * mxGetM(PROB);

    for ( i = 0;   i < len_prob; i++)
    {
       if(mxGetPr(PROB)[i] < 0.0)
       {
          sprintf(err_msg, "Elements of the probability vector must be >= 0");
          ssSetErrorStatus(S,err_msg);
          return;
       }

       sum = sum + mxGetPr(PROB)[i];
    }

    if ((sum < 0) + (sum > 1))
    {
      sprintf(err_msg, "Sum of probability vector must not be less than zero or greater than one");
      ssSetErrorStatus(S,err_msg);
      return;
    }

    /* --- Seed --- */

    if (mxGetN(SEED)*mxGetM(SEED) < 1) 
    {
      sprintf(err_msg, "Seed not defined");
      ssSetErrorStatus(S,err_msg);
      return;
    }

    if ((mxGetN(SEED) > 1) + (mxGetM(SEED) > 1)) 
    {
      sprintf(err_msg, "Seed must be specified as a scalar");
      ssSetErrorStatus(S,err_msg);
      return;
    }

    tempVar = (int)mxGetPr(SEED)[0];
    if(tempVar <= 0)
    {
       sprintf(err_msg, "Seed must be > 0");
       ssSetErrorStatus(S,err_msg);
       return;
    }

    /* --- Sample time --- */

    if (mxGetN(TS)*mxGetM(TS) < 1) 
    {
      sprintf(err_msg, "Sample time not defined");
      ssSetErrorStatus(S,err_msg);
      return;
    }

    if ((mxGetN(TS) > 1) + (mxGetM(TS) > 1)) 
    {
      sprintf(err_msg, "Sample time must be specified as a scalar");
      ssSetErrorStatus(S,err_msg);
      return;
    }

    if(mxGetPr(TS)[0] < 0)
    {
      sprintf(err_msg, "Sample time must be > 0");
      ssSetErrorStatus(S,err_msg);
      return;
    }


} /* end mdlCheckParameters */
#endif




static void mdlInitializeSizes(SimStruct *S)
{
    /* print warning messages. */  
    int_T     NumOutput=0;
    int_T     len_prob = 0;
    real_T    sum = 0.0;
    
    /* Check the values of the variables in the mask */   


    ssSetNumInputArgs(      S, NUM_ARGS);   /* number of input arguments */

    ssSetSFcnParamNotTunable(S,3); /* the sample time should not be tunable */
#if defined(MATLAB_MEX_FILE)
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) return;
    mdlCheckParameters(S);
    if (ssGetErrorStatus(S) != NULL) return;
#endif


    NumOutput = (int)mxGetPr(N)[0];
    len_prob= mxGetN(PROB) * mxGetM(PROB);
    
    ssSetNumContStates(     S, 0);          /* number of continuous states */
    ssSetNumDiscStates(     S, 0);          /* number of discrete states */
    ssSetNumOutputs(        S, NumOutput);  /* number of outputs */
    ssSetNumInputs(         S, 0);          /* number of inputs */
    ssSetDirectFeedThrough( S, 0);          /* direct feedthrough flag */
    ssSetNumSampleTimes(    S, 1);          /* number of sample times */
    ssSetNumRWork(          S, 2*NumOutput+2);
    /*  1st: dividing [0 -- len_prob];
     *  2nd: div_zeros[len_prob+1 -- 2*len_prob];
     *  3rd: Rand[2*len_prob+1 -- last one];
     */
    ssSetNumIWork(          S, 3*NumOutput+1);
    /*  1st: indx[0 -- NumOutput-1];
     *  2nd: indx_zeros[NumOutput -- 2*NumOutput-1];
     *  3rd: ind_loc[2*NumOutput -- 3*NumOutput-1];
     *  4th: Seed[3*NumOutput -- last one];
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
    int_T     len_prob = mxGetM(PROB) * mxGetN(PROB);
    int_T     NumOutput = (int)mxGetPr(N)[0];

    int_T     *indx = ssGetIWork(S);
    int_T     *ind_zeros = ssGetIWork(S)+NumOutput;
    int_T     *ind_loc = ssGetIWork(S)+2*NumOutput;
    int_T     *Seed = ssGetIWork(S)+3*NumOutput;

    real_T  *dividing = ssGetRWork(S);
    real_T  *div_zeros= ssGetRWork(S)+NumOutput+1;
    real_T  *Rand = ssGetRWork(S)+2*NumOutput+1;

    real_T  *Pseed = (real_T *)mxGetPr(SEED);

    dividing[len_prob] = 0.0;
    for (i=0; i < len_prob; i++){
        dividing[i] = 0.0;
        div_zeros[i]= 0.0;
        indx[i] = 0;
    }
    for (i=0; i < NumOutput; i++){
        ind_zeros[i] = 0;
        ind_loc[i] = 0;
	}

    if ( Pseed[0] < LOW_SEED || Pseed[0] > HIGH_SEED)
        Seed[0] = START_SEED;
    else
        Seed[0] = (int_T)Pseed[0];
    Rand[0] = Urand((uint_T *) &Seed[0]);
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
	real_T  Ts  = mxGetPr(TS)[0]; 

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
 * mdlOutputs - compute the outputs
 *
 * In this function, you compute the outputs of your S-function
 * block.  The outputs are placed in the y variable.
 */

static void mdlOutputs(real_T *y, const real_T *x, const real_T *u, SimStruct *S, int_T tid)
{
    int_T     NumOutput = (int)mxGetPr(N)[0];
    int_T     len_prob = mxGetM(PROB) * mxGetN(PROB);
    real_T  *prob    = (real_T *)mxGetPr(PROB);       /* inputed probability by user */    

    int_T     *indx = ssGetIWork(S);
    int_T     *ind_zeros = ssGetIWork(S)+NumOutput;
    int_T     *ind_loc = ssGetIWork(S)+2*NumOutput;
    int_T     *Seed = ssGetIWork(S)+3*NumOutput;

    real_T  *dividing = ssGetRWork(S);
    real_T  *div_zeros= ssGetRWork(S)+NumOutput+1;
    real_T  *Rand = ssGetRWork(S)+2*NumOutput+1;

    int_T     i, j;
    int_T     len_indx=0, len_ind_zeros=0, len_ind_loc=0;
    
	if(ssIsSampleHit(S,0,tid))
	{
      ssSetSolverNeedsReset(S); 

      for ( i=len_prob-1; i > -1; i-- )
         dividing[i] = dividing[i+1] + prob[i];

      for (i=0; i<NumOutput; i++)
         y[i] = 0;

      len_indx = 0;       
      Rand[0] = Urand((uint_T *) &Seed[0]);

      for ( i=0; i < len_prob; i++ ){
         if (dividing[i] >= Rand[0]){        
            indx[len_indx] = i+1;
            len_indx ++;
         }
      }

      if ( len_indx != 0 ){ 
         for (i=0; i < len_indx; i++){         
            len_ind_zeros = 0;
            for (j=0; j < NumOutput; j++){
               if (y[j] <= 0.5){
                  ind_zeros[len_ind_zeros] = j;
                  len_ind_zeros++;
               }
            }

            if ( len_ind_zeros >= 1 ){
               for (j=0; j < len_ind_zeros; j++)
                  div_zeros[j] =  (real_T)j/(real_T)len_ind_zeros;

               Rand[0] = Urand((uint_T *) &Seed[0]);
               len_ind_loc = 0;
               for (j=0; j < len_ind_zeros; j++){
                  if (div_zeros[j] >= Rand[0])
                  len_ind_loc++;
               }
               j = ind_zeros[len_ind_loc];
               y[j] = 1;
   	     }
         }
      }
   } /* End of if(ssIsSampleHit(S,0,tid)) */
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

