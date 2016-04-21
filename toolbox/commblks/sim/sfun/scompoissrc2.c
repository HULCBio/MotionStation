/*
 * SCOMPOISSRC2  Communication Blockset Poisson distribution 
 *               number generator based on the v5 Uniform Number
 *               generator (using dsp run-time library functions).
 *
 *   Copyright 1996-2004 The MathWorks, Inc.
 *   $Revision: 1.2.4.4 $ $Date: 2004/04/12 23:03:34 $
 */


#define S_FUNCTION_NAME scompoissrc2
#define S_FUNCTION_LEVEL 2

#include "comm_defs.h"

/* DSP header for Random source functions */
#include "dsprandsrc64bit_rt.h" 

/* Input/Output ports */
enum {NUM_INPORTS = 0};
enum {OUTPORT = 0, NUM_OUTPORTS};

/* S-fcn parameters */
enum {SEED_ARGC = 0,
      LAMBDA_ARGC,
      SAMPLE_TIME_ARGC,
      NUM_CHANNEL_ARGC,
      FRAME_BASED_ARGC,
      SAMPLES_PER_FRAME_ARGC,
      IS_ONE_DIM_ARGC,
      ORIENTSBVEC_ARGC,
      NUM_ARGS};

/* D-work vectors */
enum {SEEDWORK = 0, STATEWORK, NUM_DWORKS};

#define SEED_ARG                ssGetSFcnParam(S, SEED_ARGC)
#define LAMBDA_ARG              ssGetSFcnParam(S, LAMBDA_ARGC)
#define SAMPLE_TIME_ARG         ssGetSFcnParam(S, SAMPLE_TIME_ARGC)
#define NUM_CHANNEL_ARG         ssGetSFcnParam(S, NUM_CHANNEL_ARGC)
#define FRAME_BASED_ARG         ssGetSFcnParam(S, FRAME_BASED_ARGC)
#define SAMPLES_PER_FRAME_ARG   ssGetSFcnParam(S, SAMPLES_PER_FRAME_ARGC)
#define IS_ONE_DIM_ARG          ssGetSFcnParam(S, IS_ONE_DIM_ARGC)
#define ORIENTSBVEC_ARG         ssGetSFcnParam(S, ORIENTSBVEC_ARGC)

#define FRAMEBASED              (mxGetPr(FRAME_BASED_ARG)[0] != 0.0)
#define ISONEDIM                (mxGetPr(IS_ONE_DIM_ARG)[0] != 0.0)

#ifdef MATLAB_MEX_FILE
#define MDL_CHECK_PARAMETERS
static void mdlCheckParameters(SimStruct *S)
{
    /* Checks for the Seed and Lambda parameters are done in the mask */

    /* Sample Time parameter - real scalar greater than 0 */
    if (OK_TO_CHECK_VAR(S, SAMPLE_TIME_ARG)) 
    {
        if ( !mxIsDouble(SAMPLE_TIME_ARG)                  ||
             (mxGetNumberOfElements(SAMPLE_TIME_ARG) != 1) ||
              mxIsComplex(SAMPLE_TIME_ARG)                 ||
             (mxGetPr(SAMPLE_TIME_ARG)[0] <= 0 ) )
        {
            THROW_ERROR(S, "The sample time parameter must be a positive"
                            " real scalar value.");
        }
    }

    /* Number of Channels parameter - integer scalar > 0 */
    /* Internal error */
    if (OK_TO_CHECK_VAR(S, NUM_CHANNEL_ARG)) 
    {
        if (!IS_FLINT_GE(NUM_CHANNEL_ARG,1))
        {
            THROW_ERROR(S, "The number of channels parameter must be an"
                           " integer-valued scalar greater than 0.");
        }
    }

    /* Samples per frame parameter - integer scalar > 0 */
    if (OK_TO_CHECK_VAR(S, SAMPLES_PER_FRAME_ARG)) 
    {
        if ( !IS_FLINT_GE(SAMPLES_PER_FRAME_ARG,1)               ||
             (mxGetNumberOfElements(SAMPLES_PER_FRAME_ARG) != 1) ||
              mxIsComplex(SAMPLES_PER_FRAME_ARG) ) 
        {
            THROW_ERROR(S, "The number of samples per frame must be an"
                           " integer-valued scalar greater than 0.");
        }
    }

    /* Sample-based vector orientation parameter - 0 or 1 */
    /* Internal error */
    if (OK_TO_CHECK_VAR(S, ORIENTSBVEC_ARG)) 
    {
        if ( !IS_FLINT_IN_RANGE(ORIENTSBVEC_ARG, 0, 1) ) 
        {
            THROW_ERROR(S, "The sample based vector orientation parameter"
                           " must be binary valued.");
        }
    }
} /* end mdlCheckParameters */
#endif


/*
 * mdlInitializeSizes - called to initialize the sizes array stored in
 *                      the SimStruct.  The sizes array defines the
 *                      characteristics (number of inputs, outputs,
 *                      states, etc.) of the S-Function.
 */
static void mdlInitializeSizes(SimStruct *S)
{
    int i;
    /* Parameters: */
    ssSetNumSFcnParams(S, NUM_ARGS);

#if defined(MATLAB_MEX_FILE)
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) return;
    mdlCheckParameters(S);
    if (ssGetErrorStatus(S) != NULL) return;
#endif    

    /* All parameters excpet Lambda are non-tunable */
    ssSetSFcnParamTunable(S,0,0);
    ssSetSFcnParamTunable(S,1,1);
    for (i = 2; i < NUM_ARGS; i++)
        ssSetSFcnParamTunable(S, i, 0);

    /* Port parameters */
    /* No input ports */
    if (!ssSetNumInputPorts(S, NUM_INPORTS)) return;

    /* Single output port */
    if (!ssSetNumOutputPorts(S, NUM_OUTPORTS)) return;
    {
        int_T   numChan = (int_T)mxGetPr(NUM_CHANNEL_ARG)[0];

        if (FRAMEBASED) 
        {   
            int_T frameSize = (int_T)mxGetPr(SAMPLES_PER_FRAME_ARG)[0];

            /* frame-based */
            ssSetOutputPortFrameData(S, OUTPORT, FRAME_YES);
            ssSetOutputPortMatrixDimensions(S, OUTPORT, frameSize, numChan);
            
        } else 
        {   /* sample-based */
            ssSetOutputPortFrameData(S, OUTPORT, FRAME_NO);

            if (ISONEDIM)
            {  /* 1D */
                ssSetOutputPortVectorDimension(S, OUTPORT, numChan);
            } else 
            {   /* 2D  - only scalars and vectors, no matrices */
                int_T orientSBVec = (int_T)mxGetPr(ORIENTSBVEC_ARG)[0];

                if (orientSBVec)  /* row [1xN] vector */
                    ssSetOutputPortMatrixDimensions(S, OUTPORT, 1, numChan);
                else  /* column [Nx1] vector */
                    ssSetOutputPortMatrixDimensions(S, OUTPORT, numChan, 1);
            }
        } /* end if (FRAMEBASED) */
    }
    ssSetOutputPortComplexSignal(S, OUTPORT, COMPLEX_NO);
    ssSetOutputPortReusable(     S, OUTPORT, 1);

    /* Set up sample times: block-based*/
    ssSetNumSampleTimes(S, 1);

    if (!ssSetNumDWork( S, DYNAMICALLY_SIZED)) return;

    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE |
                    SS_OPTION_NONVOLATILE);
}


/*
 * mdlInitializeSampleTimes - initializes the array of sample times stored in
 *                            the SimStruct associated with this S-Function.
 */
static void mdlInitializeSampleTimes(SimStruct *S)
{
    const real64_T Ts        = (real64_T)mxGetPr(SAMPLE_TIME_ARG)[0];
    const int_T    frameSize = (int_T)mxGetPr(SAMPLES_PER_FRAME_ARG)[0];

    if (FRAMEBASED)
        ssSetSampleTime(S, 0, frameSize*Ts);
    else
        ssSetSampleTime(S, 0, Ts);

    ssSetOffsetTime(S, 0, 0.0);
    
    ssSetModelReferenceSampleTimeInheritanceRule(S, USE_DEFAULT_FOR_DISCRETE_INHERITANCE);
}


/* mdlInitializeConditions - initializes the states for the S-Function 
 *
 * NOTE: An assumption made is that the Lambda parameter is always 
 *       of the same length as NumChan (i.e., it has been pre-scalar 
 *       expanded). The Seed parameter may be a scalar or a vector and 
 *       if it is a scalar and needs expansion, then that is done here.
 */
#define MDL_INITIALIZE_CONDITIONS
static void mdlInitializeConditions(SimStruct *S)
{
    int i;

    uint32_T *seedWork  = (uint32_T *)ssGetDWork(S, SEEDWORK);
    real64_T *stateWork = (real64_T *)ssGetDWork(S, STATEWORK);

    real64_T *Pseed     = (real64_T *)mxGetPr(SEED_ARG);
    int_T     seedLen   = (int_T)mxGetNumberOfElements(SEED_ARG);
    int_T     numChan   = (int_T)mxGetPr(NUM_CHANNEL_ARG)[0];

    /* Initialize the seed vector */
    if ( (numChan != seedLen) && (seedLen==1) ) {
        /* Seed expansion - create random seeds */
        MWDSP_RandSrcCreateSeeds_64((uint32_T)Pseed[0], seedWork, (uint32_T)numChan);
    } else {
        for (i = 0; i < seedLen; i++)
            seedWork[i] = (uint32_T)Pseed[i];
    }

    /* Initialize the state vector */
    MWDSP_RandSrcInitState_U_64(seedWork, stateWork, numChan);
}


/* mdlOutputs - computes the outputs of the S-Function */
static void mdlOutputs(SimStruct *S, int_T tid)
{
    int_T     i, j, whileFlag;
    real64_T  p, lam, outTemp;

    real64_T *stateWork = (real64_T *)ssGetDWork(S, STATEWORK);

    real64_T urnd       = 0.0;
    real64_T *y         = (real64_T *)ssGetOutputPortRealSignal(S, OUTPORT);

    real64_T *Lambda    = (real64_T *)mxGetPr(LAMBDA_ARG);

    int_T     numChan   = (int_T)mxGetPr(NUM_CHANNEL_ARG)[0];
    int_T     frameSize = (FRAMEBASED) ? 
                          (int_T)mxGetPr(SAMPLES_PER_FRAME_ARG)[0] : 1;

    const real64_T min  = 0.0;
    const real64_T max  = 1.0;

    for (i = 0; i < numChan; i++) 
    {
        lam = Lambda[i];

        for (j = 0; j < frameSize; j++)
        {
            outTemp = 0;
            p = 0;
            whileFlag = 1;
            while (whileFlag) 
            {
                /* Uniform no. generation - access states for each channel */
                MWDSP_RandSrc_U_D(&urnd, &min, 1, &max, 1, &stateWork[35*i],
                                  1, 1);    

                p -= log(urnd);
                if (p > lam)
                    whileFlag = 0;
                else
                    outTemp += 1;
            }

            *y++ = outTemp;
        } /* end for j, frameSize */
    } /* end for i, numChan */

} /* end mdlOutputs */

static void mdlTerminate(SimStruct *S)
{
}


#define MDL_SET_WORK_WIDTHS
static void mdlSetWorkWidths(SimStruct *S)
{
    int_T   numChan   = (int_T)mxGetPr(NUM_CHANNEL_ARG)[0];

    /* Set number of DWork vectors */
    if (!ssSetNumDWork(S, NUM_DWORKS)) return;

    /* for seed values - uint32 type */
    ssSetDWorkWidth(        S, SEEDWORK, numChan);
    ssSetDWorkDataType(     S, SEEDWORK, SS_UINT32);
    ssSetDWorkComplexSignal(S, SEEDWORK, COMPLEX_NO);

    /* for state values - double type */
    ssSetDWorkWidth(        S, STATEWORK, 35*numChan);
    ssSetDWorkDataType(     S, STATEWORK, SS_DOUBLE);
    ssSetDWorkComplexSignal(S, STATEWORK, COMPLEX_NO);
}

#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-File interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif

/* [EOF] */
