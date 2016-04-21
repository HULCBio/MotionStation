/*
 * FILE : SCOMRBITSRC2.c
 *
 * SCOMRBITSRC2 outputs a zero vector with random bit ones.
 *
 * This function has no input and one output. The output is a zero vector
 * with ones in the vector. The probability of ones in the vector is
 * controlled by the input vector prob[].
 *
 * n    is the element number of output vector. 
 * prob is the probability of ones in the output vector. The sum of all
 *      elements in prob cannot be greater than one.
 * seed is the seed of the random number generator.
 *
 *   Copyright 1996-2004 The MathWorks, Inc.
 *   $Revision: 1.1.6.4 $ $Date: 2004/04/12 23:03:36 $
 */


#define S_FUNCTION_NAME scomrbitsrc2
#define S_FUNCTION_LEVEL 2

#include "comm_defs.h"
/* DSP header for Random source functions */
#include "dsprandsrc64bit_rt.h" 

/* Input/Output ports */
enum {NUM_INPORTS=0};
enum {OUTPORT=0, NUM_OUTPORTS};

/* S-fcn parameters */
enum {BLK_LENGTH_ARGC=0, PROB_ARGC, SEED_ARGC, SAMPLE_TIME_ARGC,
      FRAME_BASED_ARGC, BLKS_PER_FRAME_ARGC, IS_ONE_DIM_ARGC, NUM_ARGS};
     
/* D-work vectors */
enum {DIVIDING=0, DIV_ZEROS, RAND, INDX, INDX_ZEROS, IND_LOC, SEED,STATEWORK, NUM_DWORKS};

#define BLK_LENGTH_ARG      	ssGetSFcnParam(S, BLK_LENGTH_ARGC)
#define PROB_ARG      	        ssGetSFcnParam(S, PROB_ARGC)
#define SEED_ARG      	        ssGetSFcnParam(S, SEED_ARGC)
#define SAMPLE_TIME_ARG 	ssGetSFcnParam(S, SAMPLE_TIME_ARGC)
#define FRAME_BASED_ARG 	ssGetSFcnParam(S, FRAME_BASED_ARGC)
#define BLKS_PER_FRAME_ARG	ssGetSFcnParam(S, BLKS_PER_FRAME_ARGC)
#define IS_ONE_DIM_ARG          ssGetSFcnParam(S, IS_ONE_DIM_ARGC)

#define FRAMEBASED 		(mxGetPr(FRAME_BASED_ARG)[0] != 0.0)
#define ISONEDIM 		(mxGetPr(IS_ONE_DIM_ARG)[0] != 0.0)

#define BLOCK_BASED_SAMPLE_TIMES		1

/* Function: mdlCheckParameters  */
#ifdef MATLAB_MEX_FILE
#define MDL_CHECK_PARAMETERS
static void mdlCheckParameters(SimStruct *S) {

    /* Block Length parameter - integer scalar greater than 0. */
    if (OK_TO_CHECK_VAR(S, BLK_LENGTH_ARG)) 
    {
        if  (!IS_FLINT_GE(BLK_LENGTH_ARG,1) )  {
	    THROW_ERROR(S,"The block length parameter must be an "
			    "integer-valued scalar greater than 0.");
	}
    } else if(mxIsEmpty(BLK_LENGTH_ARG) )
    {
	THROW_ERROR(S,"The block length parameter must be an "
			"integer-valued scalar greater than 0.");
    }


    /* Probability vector parameter - scalar or vector of reals,
       of at most the block length, with sum less than 1. 
       checks made in mask function just check for empty value here. */
    if(mxIsEmpty(PROB_ARG) )
    {
	THROW_ERROR(S,"The length of probabilities parameter must be "
			"smaller or equal to the block length parameter.");
    }

    /* Seed parameter - integer scalar greater than 0 */
    if (OK_TO_CHECK_VAR(S, SEED_ARG)) {
        if (!IS_FLINT_GE(SEED_ARG,1) ) {
       	    THROW_ERROR(S, "The initial seed parameter must be an "
       	   	            "integer-valued scalar greater than 0.");
	}
    } else if(mxIsEmpty(SEED_ARG) )
    {
       	    THROW_ERROR(S, "The initial seed parameter must be an "
       	   	            "integer-valued scalar greater than 0.");
    }


    /* Sample Time parameter - real scalar not equal to 0 */
    if (OK_TO_CHECK_VAR(S, SAMPLE_TIME_ARG)) {
	if (
	    !mxIsDouble(SAMPLE_TIME_ARG)                  ||
	    (mxGetNumberOfElements(SAMPLE_TIME_ARG) != 1) ||
	    mxIsComplex(SAMPLE_TIME_ARG)		      ||
	    (mxGetPr(SAMPLE_TIME_ARG)[0] == 0 )
	    ) 
	{
	    THROW_ERROR(S, "The sample time parameter must be a real scalar value.");
	}
    } else if (mxIsEmpty(SAMPLE_TIME_ARG) )
    {
	THROW_ERROR(S, "The sample time parameter must be a real scalar value.");
    }

    /* Blocks per frame parameter - integer scalar > 0 */
    if (OK_TO_CHECK_VAR(S, BLKS_PER_FRAME_ARG)) {
        if ( !IS_FLINT_GE(BLKS_PER_FRAME_ARG,1) ) {
	   THROW_ERROR(S, "The blocks per frame parameter must be an "
                        "integer-valued scalar greater than 0.");
	}
    } else if(mxIsEmpty(BLKS_PER_FRAME_ARG))
    {
	THROW_ERROR(S, "The blocks per frame parameter must be an "
		       "integer-valued scalar greater than 0.");
    }
}
#endif


/*
 * mdlInitializeSizes - called to initialize the sizes array stored in
 *                      the SimStruct.  The sizes array defines the
 *                      characteristics (number of inputs, outputs,
 *                      states, etc.) of the S-Function.
 */
static void mdlInitializeSizes(SimStruct *S)
{
    int_T i, blkLength, blksPerFrame;

    /* Parameters: */
    ssSetNumSFcnParams(S, NUM_ARGS);

#if defined(MATLAB_MEX_FILE)
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) return;
    mdlCheckParameters(S);
    if (ssGetErrorStatus(S) != NULL) return;
#endif    


    /* All parameters are non-tunable */
    for (i = 0; i< NUM_ARGS; i++)
        ssSetSFcnParamTunable(S, i, 0);

    /* Port parameters */
    /* No input ports */
    if (!ssSetNumInputPorts(S, NUM_INPORTS)) return;

    /* Single output port */
    if (!ssSetNumOutputPorts(S, NUM_OUTPORTS)) return;
    {
	blkLength     = (int_T)mxGetPr(BLK_LENGTH_ARG)[0];
	blksPerFrame  = (int_T)mxGetPr(BLKS_PER_FRAME_ARG)[0];

  	if (FRAMEBASED) { /* frame-based */
  	    ssSetOutputPortFrameData(S, OUTPORT, FRAME_YES);
	    ssSetOutputPortMatrixDimensions(S, OUTPORT, blkLength*blksPerFrame, 1);
  	} else { /* sample-based */
  	    if (ISONEDIM){ /* 1D */
	    	ssSetOutputPortVectorDimension(	S, OUTPORT, blkLength);
	    } else { /* 2D */
		ssSetOutputPortMatrixDimensions(S, OUTPORT, 1, blkLength);
		/* dont allow Rx1 outputs, only 1xC - for backwards compatibility*/
	    }
	    ssSetOutputPortFrameData(S, OUTPORT, FRAME_NO);
  	}
    }
    ssSetOutputPortComplexSignal(S, OUTPORT, COMPLEX_NO);
    ssSetOutputPortReusable(     S, OUTPORT, 1);

    /* Set up sample times: */
    ssSetNumSampleTimes(      S, BLOCK_BASED_SAMPLE_TIMES);

    if (!ssSetNumDWork(S, DYNAMICALLY_SIZED)) return;
    ssSetOptions( S, SS_OPTION_EXCEPTION_FREE_CODE);
}

/*
 * mdlInitializeSampleTimes - initializes the array of sample times stored in
 *                            the SimStruct associated with this S-Function.
 */
static void mdlInitializeSampleTimes(SimStruct *S)
{
    const real_T  Ts  		    = mxGetPr(SAMPLE_TIME_ARG)[0];
    const int_T   blkLength     = (int_T)mxGetPr(BLK_LENGTH_ARG)[0];
    const int_T	  blksPerFrame  = (int_T)mxGetPr(BLKS_PER_FRAME_ARG)[0];

    if (FRAMEBASED) {
	    ssSetSampleTime(S, 0, (blkLength*blksPerFrame)*Ts);
    } else {
	    ssSetSampleTime(S, 0, Ts);
    }
    ssSetOffsetTime(S, 0, 0.0);
    
    ssSetModelReferenceSampleTimeInheritanceRule(S, USE_DEFAULT_FOR_DISCRETE_INHERITANCE);
}


/* mdlInitializeConditions - initializes the states for the S-Function  */
#define MDL_INITIALIZE_CONDITIONS
static void mdlInitializeConditions(SimStruct *S)
{
    real64_T  *Pseed      = (real64_T *)mxGetPr(SEED_ARG);    

    uint32_T *seedWork  = (uint32_T *)ssGetDWork(S, SEED);
    real64_T *stateWork = (real64_T *)ssGetDWork(S, STATEWORK);

    seedWork[0] = (uint32_T)Pseed[0];

    MWDSP_RandSrcInitState_U_64(seedWork, stateWork, 1);
	
}


/* mdlOutputs - computes the outputs of the S-Function  */
static void mdlOutputs(SimStruct *S, int_T tid)
{ 
    int_T   blkLength     = (int_T)mxGetPr(BLK_LENGTH_ARG)[0];
    int_T   blksPerFrame  = (int_T)mxGetPr(BLKS_PER_FRAME_ARG)[0];
    int_T   len_prob      = mxGetM(PROB_ARG) * mxGetN(PROB_ARG);
    real_T  *prob         = (real_T *)mxGetPr(PROB_ARG);
    real_T  *y            = (real_T *)ssGetOutputPortRealSignal(S,OUTPORT);
    
    int_T   *indx       = (int_T *)ssGetDWork(S, INDX);
    int_T   *ind_zeros  = (int_T *)ssGetDWork(S, INDX_ZEROS);
    int_T   *ind_loc    = (int_T *)ssGetDWork(S, IND_LOC);
  
    real_T  *dividing   = (real_T *)ssGetDWork(S, DIVIDING);
    real_T  *div_zeros  = (real_T *)ssGetDWork(S, DIV_ZEROS);
    real64_T  *Rand     = (real64_T *)ssGetDWork(S, RAND);
    
    int_T   i, j, k;
    int_T   len_indx=0, len_ind_zeros=0, len_ind_loc=0;
    
    const real64_T min  = 0.0;
    const real64_T max  = 1.0;

    real64_T *stateWork = (real64_T *)ssGetDWork(S, STATEWORK);

    for ( i = len_prob-1; i > -1; i-- )
       dividing[i] = dividing[i+1] + prob[i];
  
    for (k = 0; k < blksPerFrame; k++)
    {
        for (i = 0; i < blkLength; i++)
           y[k*blkLength + i] = 0;
      
       len_indx = 0;
       
       /* Uniform no. generation - access states  */
       MWDSP_RandSrc_U_D(Rand, &min, 1, &max, 1, &stateWork[0], 1, 1);    

        for (i = 0; i < len_prob; i++ ){
           if (dividing[i] >= Rand[0]){        
              indx[len_indx] = i+1;
              len_indx ++;
           }
        }
      
        if ( len_indx != 0 )
	{ 
           for (i = 0; i < len_indx; i++){         
              len_ind_zeros = 0;
              for (j = 0; j < blkLength; j++){
                 if (y[k*blkLength + j] <= 0.5){
                    ind_zeros[len_ind_zeros] = j;
                    len_ind_zeros++;
                 }
              }
      
              if ( len_ind_zeros >= 1 ){
                 for (j = 0; j < len_ind_zeros; j++)
                    div_zeros[j] =  (real_T)j/(real_T)len_ind_zeros;
		  MWDSP_RandSrc_U_D(Rand, &min, 1, &max, 1, &stateWork[0], 1, 1);   

                 len_ind_loc = 0;
                 for (j = 0; j < len_ind_zeros; j++){
                    if (div_zeros[j] >= Rand[0])
		     len_ind_loc++;
                 }
                 j = ind_zeros[len_ind_loc];
                 y[k*blkLength + j] = 1;
              }
           }
        }
    } /* end for k->blksPerFrame loop */
} /* end mdlOutputs */

static void mdlTerminate(SimStruct *S)
{
}

/* Function: ssSetDWorkAndParams
   Purpose: Set the DWork Vector and its parameters. */
void ssSetDWorkAndParams(SimStruct *S,
                          int_T     name,
                          int_T     size,
                          int_T     dataType,
                          int_T     complexity)
{
    ssSetDWorkWidth(        S, name, size);
    ssSetDWorkDataType(     S, name, dataType);
    ssSetDWorkComplexSignal(S, name, complexity);
}

#if defined(MATLAB_MEX_FILE)
#define MDL_SET_WORK_WIDTHS
static void mdlSetWorkWidths(SimStruct *S)
{
    const int_T   blkLength     = (int_T)mxGetPr(BLK_LENGTH_ARG)[0];
    const int_T	  blksPerFrame  = (int_T)mxGetPr(BLKS_PER_FRAME_ARG)[0];

    /* Set DWork vector: */
    if (!ssSetNumDWork(S, NUM_DWORKS)) return;

    /* double types */
    ssSetDWorkAndParams(S, DIVIDING, blkLength, SS_DOUBLE, COMPLEX_NO);
    ssSetDWorkAndParams(S, DIV_ZEROS, blkLength, SS_DOUBLE, COMPLEX_NO);
    ssSetDWorkAndParams(S, RAND, 1, SS_DOUBLE, COMPLEX_NO);

    /* integer types */
    ssSetDWorkAndParams(S, INDX, blkLength, SS_INT32, COMPLEX_NO);
    ssSetDWorkAndParams(S, INDX_ZEROS, blkLength, SS_INT32, COMPLEX_NO);
    ssSetDWorkAndParams(S, IND_LOC, blkLength, SS_INT32, COMPLEX_NO);
    ssSetDWorkAndParams(S, SEED, 1, SS_INT32, COMPLEX_NO);


    /* for seed values - uint32 type */
    ssSetDWorkWidth(        S, SEED, 1);
    ssSetDWorkDataType(     S, SEED, SS_UINT32);
    ssSetDWorkComplexSignal(S, SEED, COMPLEX_NO);

    /* for state values - double type */
    ssSetDWorkWidth(        S, STATEWORK, 35*1);
    ssSetDWorkDataType(     S, STATEWORK, SS_DOUBLE);
    ssSetDWorkComplexSignal(S, STATEWORK, COMPLEX_NO);
}
#endif

#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif

/* [EOF] */
