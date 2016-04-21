/*
 *   SCOMPNSEQ2 A sample-time driven Simulink PN Sequence Generator.
 *
 *   Copyright 1996-2003 The MathWorks, Inc.
 *   $Revision: 1.13.4.3 $  $Date: 2004/04/12 23:03:33 $
 */


#define S_FUNCTION_NAME scompnseq2
#define S_FUNCTION_LEVEL 2

#include "comm_defs.h"

/* D-work vectors */
enum {SHIFT_REG=0, SHIFT_REG_COPY, MASK, NUM_DWORKS};

/* Ports */
enum {INPORT=0, NUM_INPORTS};
enum {OUTPORT=0, NUM_OUTPORTS};

/* S-fcn parameters */
enum {POLYNOMIAL_ARGC=0, INITIAL_STATE_ARGC, SHIFT_ARGC, SAMPLE_TIME_ARGC, \
    FRAME_BASED_ARGC, SAMPLES_PER_FRAME_ARGC, RESET_ARGC, NUM_ARGS};

#define POLYNOMIAL_ARG          ssGetSFcnParam(S, POLYNOMIAL_ARGC)
#define INITIAL_STATE_ARG       ssGetSFcnParam(S, INITIAL_STATE_ARGC)
#define SHIFT_ARG               ssGetSFcnParam(S, SHIFT_ARGC)
#define SAMPLE_TIME_ARG         ssGetSFcnParam(S, SAMPLE_TIME_ARGC)
#define FRAME_BASED_ARG         ssGetSFcnParam(S, FRAME_BASED_ARGC)
#define SAMPLES_PER_FRAME_ARG   ssGetSFcnParam(S, SAMPLES_PER_FRAME_ARGC)
#define RESET_ARG               ssGetSFcnParam(S, RESET_ARGC)

#define FRAME_BASED             (mxGetPr(FRAME_BASED_ARG)[0] != 0.0)
#define RESET_ON                (mxGetPr(RESET_ARG)[0] != 0.0)

#ifdef MATLAB_MEX_FILE
#define MDL_CHECK_PARAMETERS
static void mdlCheckParameters(SimStruct *S)
{
    /* The individual checks are made in the mask function for
     *      Generator polynomial parameter - real, integer vector.
     *      Initial state parameter - real, integer vector.
     *      Shift (or mask) parameter - integer scalar, or binary vector.
     */

    /* Sample Time parameter - real scalar greater than 0 */
    if (OK_TO_CHECK_VAR(S, SAMPLE_TIME_ARG)) 
    {
        if ( !mxIsDouble(SAMPLE_TIME_ARG) || mxIsComplex(SAMPLE_TIME_ARG) || 
             (mxGetNumberOfElements(SAMPLE_TIME_ARG) != 1) ||
             (mxGetPr(SAMPLE_TIME_ARG)[0] <= 0) )
        {
            THROW_ERROR(S,"The sample time parameter must be a real scalar greater than 0.");
        }
    }

    /* Samples per frame parameter - integer scalar > 0 */
    if ( !IS_FLINT_GE(SAMPLES_PER_FRAME_ARG,1) )
       THROW_ERROR(S, "The samples per frame parameter must be an integer-valued scalar greater than 0.");

}
#endif

static void mdlInitializeSizes(SimStruct *S)
{
    int i;

    ssSetNumSFcnParams(S, NUM_ARGS);

#if defined(MATLAB_MEX_FILE)
    if (ssGetNumSFcnParams(S) != NUM_ARGS) return;
    mdlCheckParameters(S);
    if (ssGetErrorStatus(S) != NULL) return;
#endif

    /* All parameters are non-tunable */
    for (i = 0; i < NUM_ARGS; i++)
        ssSetSFcnParamNotTunable(S, i);
    
    /* Port parameters */
    /* Input port */
    if (RESET_ON) 
    { /* one input port */
        if (!ssSetNumInputPorts(S, NUM_INPORTS)) return;
        if (!ssSetInputPortDimensionInfo(S, INPORT, DYNAMIC_DIMENSION)) return;
        ssSetInputPortFrameData(         S, INPORT, FRAME_INHERITED);
        ssSetInputPortComplexSignal(     S, INPORT, COMPLEX_NO);
        ssSetInputPortSampleTime(        S, INPORT, INHERITED_SAMPLE_TIME);
        ssSetInputPortDirectFeedThrough( S, INPORT, 1);
        ssSetInputPortRequiredContiguous(S, INPORT, 1);
        ssSetInputPortReusable(          S, INPORT, 0);
    } else 
    { /* no input port */
        if (!ssSetNumInputPorts(S, 0)) return;
    }
    
    /* Single output port */
    if (!ssSetNumOutputPorts(S, NUM_OUTPORTS)) return;
    if (FRAME_BASED) 
    {
        int_T  frameSize  = (int_T)mxGetPr(SAMPLES_PER_FRAME_ARG)[0];

        ssSetOutputPortFrameData(S, OUTPORT, FRAME_YES);
        ssSetOutputPortMatrixDimensions(S, OUTPORT, frameSize, 1);
    } else 
    { /* unoriented scalar only */
        ssSetOutputPortFrameData(S, OUTPORT, FRAME_NO);
        ssSetOutputPortVectorDimension( S, OUTPORT, 1);
    }
    ssSetOutputPortComplexSignal(S, OUTPORT, COMPLEX_NO);
    ssSetOutputPortReusable(     S, OUTPORT, 1);

    /* Set up sample times */
    if (RESET_ON) 
    {
        ssSetOutputPortSampleTime(S, OUTPORT, INHERITED_SAMPLE_TIME);
        ssSetNumSampleTimes(      S, PORT_BASED_SAMPLE_TIMES); 
    } else 
    {
        ssSetNumSampleTimes(S, 1); /* block based sample times */ 
    }

    if (!ssSetNumDWork(S, DYNAMICALLY_SIZED)) return;

    ssSetOptions( S, SS_OPTION_EXCEPTION_FREE_CODE);
}

static void mdlInitializeSampleTimes(SimStruct *S)
{
    if (RESET_ON) /* Port-Based Sample Times */
    {
#ifdef MATLAB_MEX_FILE

        /* Do error checking */
        const real_T Tsin  = ssGetInputPortSampleTime(S, INPORT);
        const real_T Tsout = ssGetOutputPortSampleTime(S, OUTPORT);

        if ( (Tsin == INHERITED_SAMPLE_TIME)||(Tsout == INHERITED_SAMPLE_TIME) )
        {
            THROW_ERROR(S,"Sample time propagation failed.");
        }

        if ( (ssGetOutputPortWidth(S,OUTPORT) == DYNAMICALLY_SIZED) ||
             (ssGetInputPortWidth( S,INPORT ) == DYNAMICALLY_SIZED)   )
        {
            THROW_ERROR(S,"Port width propagation failed.");
        }
#endif

    } else /* Block-Based Sample Times*/
    {
        const real_T Ts           = mxGetPr(SAMPLE_TIME_ARG)[0];
        const int_T  frameSize    = (int_T)mxGetPr(SAMPLES_PER_FRAME_ARG)[0];

        if (FRAME_BASED) 
            ssSetSampleTime(S, 0, frameSize*Ts);
        else 
            ssSetSampleTime(S, 0, Ts);
        ssSetOffsetTime(S, 0, 0.0);
    }
    
    ssSetModelReferenceSampleTimeInheritanceRule(S, USE_DEFAULT_FOR_DISCRETE_INHERITANCE);
}

#define MDL_INITIALIZE_CONDITIONS
/* If given a shift (scalar) advance the sequence by that much before 
 * outputting, else if given a mask (vector), store it in the work vector
 * to apply it in mdlOutputs.
 */
static void mdlInitializeConditions(SimStruct *S)
{
    int_T    *shift_reg     = (int_T *)ssGetDWork(S, SHIFT_REG);
    int_T    *shift_reg_cp  = (int_T *)ssGetDWork(S, SHIFT_REG_COPY);
    int_T    *mask          = (int_T *)ssGetDWork(S, MASK);
    real_T   *initial_state = (real_T *)mxGetPr(INITIAL_STATE_ARG);
    real_T   *shift         = (real_T *)mxGetPr(SHIFT_ARG);
    real_T   *polynomial    = (real_T *)mxGetPr(POLYNOMIAL_ARG);
    
    int_T    i, polyOrder, iniStateSize, shiftSize, tmp;
    real_T   j;
    
    polyOrder    = mxGetN(POLYNOMIAL_ARG) * mxGetM(POLYNOMIAL_ARG) - 1;
    iniStateSize = mxGetN(INITIAL_STATE_ARG) * mxGetM(INITIAL_STATE_ARG);
    shiftSize    = mxGetN(SHIFT_ARG) * mxGetM(SHIFT_ARG);

    /* Set up the initial states */
    if (iniStateSize == polyOrder) 
    {
        for (i = 0; i < polyOrder; i++)
            shift_reg[i] = (int_T)initial_state[i];
    } else 
    { /* scalar expand */
        for (i = 0; i < polyOrder; i++)
            shift_reg[i] = (int_T)initial_state[0];
    }

    /* Account for the mask/shift parameter */
    if (shiftSize == 1) 
    { /* Scalar => shift specified, advance the register that many times */
        for (j = 0; j < shift[0]; j++)
        {
            /* compute feedback bit */
            tmp = 0;
            for (i = 1; i <= polyOrder; i++)
                tmp += (int_T)polynomial[i] * shift_reg[i-1];
            tmp = tmp % 2;
    
            /* right shift */
            for (i = polyOrder-1; i > 0; i--)
                shift_reg[i] = shift_reg[i-1];
            shift_reg[0] = tmp;
        }
        /* Set the default mask to be 00...01 => outputs last stage */ 
        for (i = 0; i < polyOrder-1; i++)
            mask[i] = 0;
        mask[polyOrder-1] = 1;
    } else
    { /* Vector => mask specified, store in work vector, apply in mdlOutputs */ 
        if (shiftSize == polyOrder)
        {
            for (i = 0; i < polyOrder; i++)
                mask[i] = (int_T) shift[i];
        }
    }

    /* Store states for resetting */
    if (RESET_ON) /* if there is a resetting input */
    {
        for(i = 0; i < polyOrder; i++)
            shift_reg_cp[i] = shift_reg[i];
    }
}

static void mdlOutputs(SimStruct *S, int_T tid)
{
    int_T    i, j, polyOrder, frameSize, tmp, tmp2, resetSize;

    int_T    *shift_reg     = (int_T *)ssGetDWork(S, SHIFT_REG);
    int_T    *shift_reg_cp  = (int_T *)ssGetDWork(S, SHIFT_REG_COPY);
    int_T    *mask          = (int_T *)ssGetDWork(S, MASK);

    real_T   *polynomial = (real_T *)mxGetPr(POLYNOMIAL_ARG);
    real_T   *y          = (real_T *)ssGetOutputPortRealSignal(S,OUTPORT);
    real_T   *u;

    polyOrder = mxGetN(POLYNOMIAL_ARG) * mxGetM(POLYNOMIAL_ARG) - 1;

    /* Determine the frame size */
    if (FRAME_BASED)
        frameSize  = (int_T)mxGetPr(SAMPLES_PER_FRAME_ARG)[0];
    else 
        frameSize = 1;  /* sample-based */

    if (RESET_ON)
    {   /* Get the reset signal */
        u  = (real_T *)ssGetInputPortRealSignal(S, INPORT);
        resetSize = (int_T)ssGetInputPortWidth(S, INPORT);

        if (resetSize == 1) /* for scalar resetting and at start of frame */ 
        {
            if (*u != 0.0)
            { /* reset the shift register to the initial conditions for non-zero input */
                for(i = 0; i < polyOrder; i++)
                    shift_reg[i] = shift_reg_cp[i];
            }
        }
    }

    /* Loop over samples in a frame */
    for (j = 0; j < frameSize; j++)
    {
        /* Check for reset */
        if (RESET_ON)
        {
            if (resetSize > 1)  /* For resetting within a frame */
            {
                if (u[j] != 0.0)
                { /* reset the shift register to the initial conditions for non-zero input */
                    for(i = 0; i < polyOrder; i++)
                        shift_reg[i] = shift_reg_cp[i];
                }
            }
        }

        /* compute feedback bit */
        tmp = 0;
        for (i = 1; i <= polyOrder; i++)
            tmp += (int_T) polynomial[i] * shift_reg[i-1];
        tmp %= 2;

        /* output data - apply the mask */
        tmp2 = 0;
        for (i = 0; i < polyOrder; i++)
            tmp2 += shift_reg[i] * mask[i];
        y[j] = tmp2 % 2;

        /* right shift */
        for (i = polyOrder-1; i > 0; i--)
            shift_reg[i] = shift_reg[i-1];
        shift_reg[0] = tmp;
    }

}

static void mdlTerminate(SimStruct *S)
{
}

#ifdef MATLAB_MEX_FILE
#define MDL_SET_INPUT_PORT_DIMENSION_INFO
static void mdlSetInputPortDimensionInfo(SimStruct *S, int_T port,
                                      const DimsInfo_T *dimsInfo)
{
    /*
     *   Allowed Dimension cases for Input Reset port for the block
     *
     *       Input            Output
     *   [1] or [1x1]SB        [1] SB
     *                       [Nx1] FB    -> resetting at start of frame
     *
     *   [Nx1]FB             [Nx1] FB    -> resetting within a frame
     *
     *   N is the number of samples per frame in the output.
     *   Note: The output is pre-set as per the parameters in the mask and 
     *         is NOT dependent on the reset signal attributes.
     */

    if (RESET_ON) /* if there is a reset input */
    { 
        int_T frameSize, resetSize, numDims, inRows, inCols;

        if (!ssSetInputPortDimensionInfo(S, port, dimsInfo)) return;
    
        resetSize = ssGetInputPortWidth(S, INPORT);
        numDims   = ssGetInputPortNumDimensions(S, INPORT);
		inRows    = (numDims >= 1) ? dimsInfo->dims[0] : 0;
		inCols    = (numDims >= 2) ? dimsInfo->dims[1] : 0;

        /* Check against invalid input dimensions */
        if (inCols > 1)
            THROW_ERROR(S,"The reset port signal must be a scalar or a column vector.");

        if ( (numDims == 1) && (resetSize > 1) )
            THROW_ERROR(S,"The reset port signal must be a sample-based scalar.");

        /* Get the frame size */
        if (FRAME_BASED)
            frameSize  = (int_T)mxGetPr(SAMPLES_PER_FRAME_ARG)[0];
        else
            frameSize  = 1;

        /* Check for scalar - sample-based mode, single-sample frame mode */
        if ( (frameSize == 1) && (frameSize != resetSize) )
            THROW_ERROR(S, "The reset port signal must be a scalar.");

        /* Check for frame input size of the reset signal */
        if ( (resetSize > 1) && (frameSize != resetSize) )
            THROW_ERROR(S, "The reset port width must be equal to the samples per frame parameter.");
    }
}

#define MDL_SET_OUTPUT_PORT_DIMENSION_INFO
static void mdlSetOutputPortDimensionInfo(SimStruct *S, int_T port,
                                      const DimsInfo_T *dimsInfo)
{
    /* There are no propagation attributes defined as the output port  
     * size is independent of the reset port attributes. */
}

#define MDL_SET_DEFAULT_PORT_DIMENSION_INFO
static void mdlSetDefaultPortDimensionInfo(SimStruct *S)
{
    /* initialize a dynamically-dimensioned DimsInfo_T */
    DECL_AND_INIT_DIMSINFO(dInfo); 
    int_T dims[2] = {1, 1};

    /* select valid port dimensions */
    dInfo.width     = 1;
    dInfo.numDims   = 2;
    dInfo.dims      = dims;

    /* call the input functions */
    if ( (RESET_ON) && (ssGetInputPortWidth(S,INPORT) == DYNAMICALLY_SIZED) )
    { 
        mdlSetInputPortDimensionInfo(S, INPORT, &dInfo);
    }
}


#define MDL_SET_INPUT_PORT_SAMPLE_TIME
static void mdlSetInputPortSampleTime(SimStruct *S,
                                      int_T     portIdx,
                                      real_T    sampleTime,
                                      real_T    offsetTime)
{
    /* Only if there is a reset port */
    if (RESET_ON)
    {
              real_T Tsout      = 0.0;
        const real_T Ts         = (real_T)mxGetPr(SAMPLE_TIME_ARG)[0];
        const real_T frameSize  = (real_T)mxGetPr(SAMPLES_PER_FRAME_ARG)[0];

        /* Checks */
        if (sampleTime == CONTINUOUS_SAMPLE_TIME)
            THROW_ERROR(S,"All signals must be discrete.");

        if (offsetTime != 0.0)
            THROW_ERROR(S,"Non-zero sample time offsets are not allowed.");

        ssSetInputPortSampleTime(S, INPORT, sampleTime);
        ssSetInputPortOffsetTime(S, INPORT, offsetTime);
        
        /* Determine the specified output sample time */
        if (FRAME_BASED) 
            Tsout = Ts * frameSize;
        else 
            Tsout = Ts;

        /* Ensure the sample times are same within a tolerance*/
        if ( fabs(Tsout - sampleTime) > (pow(2,-52)) )  /* if >eps error */
            THROW_ERROR(S, "The reset port signal's sample time must be equal "
                           "to the output port sample time.");

        /* Set the sample times */
        /* Give control to the reset (input) port */
        ssSetOutputPortSampleTime(S, OUTPORT, sampleTime);
        ssSetOutputPortOffsetTime(S, OUTPORT, offsetTime);
    }
}


#define MDL_SET_OUTPUT_PORT_SAMPLE_TIME
static void mdlSetOutputPortSampleTime(SimStruct *S,
                                      int_T     portIdx,
                                      real_T    sampleTime,
                                      real_T    offsetTime)
{
    /* Only if there is a reset port */
    if (RESET_ON)
    {
              real_T Tsout      = 0.0;
        const real_T Ts         = (real_T)mxGetPr(SAMPLE_TIME_ARG)[0];
        const real_T frameSize  = (real_T)mxGetPr(SAMPLES_PER_FRAME_ARG)[0];

        /* Checks */
        if (sampleTime == CONTINUOUS_SAMPLE_TIME)
            THROW_ERROR(S, "All signals must be discrete.");

        if (offsetTime != 0.0)
            THROW_ERROR(S, "Non-zero sample time offsets are not allowed.");

        /* Set the sample times */
        ssSetOutputPortSampleTime(S, OUTPORT, sampleTime);
        ssSetOutputPortOffsetTime(S, OUTPORT, offsetTime);

        /* Determine the specified output sample time */
        if (FRAME_BASED) 
            Tsout = Ts * frameSize;
        else 
            Tsout = Ts;

        /* Ensure the sample times are same */
        if (Tsout != sampleTime)
            THROW_ERROR(S, "Invalid sample time specified.");

        /* Set the sample times */
        ssSetInputPortSampleTime(S, INPORT, sampleTime);
        ssSetInputPortOffsetTime(S, INPORT, offsetTime);
    }
}


#define MDL_SET_WORK_WIDTHS
static void mdlSetWorkWidths(SimStruct *S)
{
    int_T polyOrder;
    polyOrder = mxGetN(POLYNOMIAL_ARG) * mxGetM(POLYNOMIAL_ARG) - 1;

    /* Set DWork vector: */
    if (!ssSetNumDWork(S, NUM_DWORKS)) return;

    /* Shift Register */
    ssSetDWorkWidth(        S, SHIFT_REG, polyOrder);
    ssSetDWorkDataType(     S, SHIFT_REG, SS_INT32);
    ssSetDWorkComplexSignal(S, SHIFT_REG, COMPLEX_NO);

    /* Shift Register copy for resetting */
    ssSetDWorkWidth(        S, SHIFT_REG_COPY, polyOrder);
    ssSetDWorkDataType(     S, SHIFT_REG_COPY, SS_INT32);
    ssSetDWorkComplexSignal(S, SHIFT_REG_COPY, COMPLEX_NO);

    /* Mask */
    ssSetDWorkWidth(        S, MASK, polyOrder);
    ssSetDWorkDataType(     S, MASK, SS_INT32);
    ssSetDWorkComplexSignal(S, MASK, COMPLEX_NO);
}
#endif

#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-File interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif

/* EOF */
