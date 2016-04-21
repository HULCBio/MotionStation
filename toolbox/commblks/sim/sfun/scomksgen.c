/*
 *   SCOMKSGEN Simulink's Large Set Kasami Sequence Generator.
 *
 *   The Large set of Kasami Sequences (for n mod4 = 2) is defined as:
 *
 *     K(n,k,m)  =  u                   for k = -2,        m = -1
 *                  v                   for k = -1,        m = -1
 *                  u + T^k v           for k = 0..2^n-2,  m = -1
 *                  u + T^m w           for k = -2,        m = 0..2^(n/2)-2
 *                  v + T^m w           for k = -1,        m = 0..2^(n/2)-2
 *                  u + T^k v + T^m w   for k = 0..2^n-2,  m = 0..2^(n/2)-2
 *
 *   where k and m are the shift parameters for the v and w sequences
 *   respectively. T denotes the left shift operator, + denotes modulo 2 
 *   addition and n is an even integer <= 32. If n mod 4 == 0, only the small 
 *   set of Kasami sequences is obtained (i.e. u + T^m w set of sequences).
 *
 *   The three sequences, u, v, w are described as:
 *      u is the original PN for which genPoly of degree n is specified.
 *      v is the pair PN obtained as u[2^((n+2)/2)+1] (only for n mod 4 == 2).
 *      w is the decimated sequence obtained as u[2^(n/2)+1].
 *
 *   Copyright 1996-2003 The MathWorks, Inc.
 *   $Revision: 1.2.4.3 $  $Date: 2004/04/12 23:03:30 $
 */


#define S_FUNCTION_NAME scomksgen
#define S_FUNCTION_LEVEL 2

#include "comm_defs.h"

/* D-work vectors */
enum {SHIFT_REG=0, SHIFT_REG_COPY, V_SEQ, VSEQ_IDX, W_SEQ, WSEQ_IDX, \
      NUM_DWORKS};

/* Ports */
enum {INPORT=0, NUM_INPORTS};
enum {OUTPORT=0, NUM_OUTPORTS};

/* S-fcn parameters */
enum {POLYNOMIAL_ARGC=0, INITIAL_STATE_ARGC, INDEX_ARGC, SHIFT_ARGC, \
    SAMPLE_TIME_ARGC, FRAME_BASED_ARGC, SAMPLES_PER_FRAME_ARGC, RESET_ARGC, \
    NUM_ARGS};

#define POLYNOMIAL_ARG          ssGetSFcnParam(S, POLYNOMIAL_ARGC)
#define INITIAL_STATE_ARG       ssGetSFcnParam(S, INITIAL_STATE_ARGC)
#define INDEX_ARG               ssGetSFcnParam(S, INDEX_ARGC)
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
     *      Generator polynomial parameter - binary-valued vector 
     *      Initial state parameter - binary-valued vector 
     *      Index parameter - 2-element integer vector 
     *      Shift parameter - integer scalar
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

        ssSetOutputPortFrameData(       S, OUTPORT, FRAME_YES);
        ssSetOutputPortMatrixDimensions(S, OUTPORT, frameSize, 1);
    } else 
    { /* Un-oriented scalar only */
        ssSetOutputPortFrameData(      S, OUTPORT, FRAME_NO);
        ssSetOutputPortVectorDimension(S, OUTPORT, 1);
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

        if ((Tsin == INHERITED_SAMPLE_TIME)||(Tsout == INHERITED_SAMPLE_TIME))
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
/* 
 * Based on the genPoly specified and the iniState, run the shift register
 * so as to determine a full period of the decimated sequences v and w 
 * which are stored in V_SEQ and W_SEQ respectively. At the same time, account
 * for the shift parameter also by storing states.
 *
 * The v, w sequences are then cyclically left-shifted by an amount equal
 * to the INDEX + SHIFT parameter (in accordance with the set's definition).
 */
static void mdlInitializeConditions(SimStruct *S)
{
    int_T     i, tmp;
    uint32_T  uk, vk, wk; /* indices for the 3 sequences */
    real_T    j;

    int_T    *shiftReg     = (int_T *)ssGetDWork(S, SHIFT_REG);
    int_T    *shiftRegCp   = (int_T *)ssGetDWork(S, SHIFT_REG_COPY);
    int_T    *vSeq         = (int_T *)ssGetDWork(S, V_SEQ);
    int_T    *wSeq         = (int_T *)ssGetDWork(S, W_SEQ);

    real_T   *iniState     = (real_T *)mxGetPr(INITIAL_STATE_ARG);
    real_T   *polynomial   = (real_T *)mxGetPr(POLYNOMIAL_ARG);
    real_T   *index        = (real_T *)mxGetPr(INDEX_ARG);
    real_T   *shift        = (real_T *)mxGetPr(SHIFT_ARG);
    
    int_T     polyOrder    = (int_T)mxGetN(POLYNOMIAL_ARG) * 
                                    mxGetM(POLYNOMIAL_ARG) - 1;
    int_T     iniStateSize = (int_T)mxGetN(INITIAL_STATE_ARG) *  
                                    mxGetM(INITIAL_STATE_ARG);

    /* Note: uPeriod is same as vPeriod */
    uint32_T  vPeriod      = (uint32_T) pow(2, polyOrder) - 1;
    uint32_T  vDecIdx      = (uint32_T) pow(2, polyOrder/2 + 1) + 1;
    uint32_T  wPeriod      = (uint32_T) pow(2, polyOrder/2) - 1;
    
    /* Set up the initial states */
    if (iniStateSize == polyOrder) 
    {
        for (i = 0; i < polyOrder; i++)
            shiftReg[i] = (int_T)iniState[i];
    } else 
    { /* scalar expand */
        for (i = 0; i < polyOrder; i++)
            shiftReg[i] = (int_T)iniState[0];
    }

    /* Generate a period of the decimated sequences v and w */
    uk = 0; vk = 0; wk = 0;

    /* Get the first bit as the start of the V_SEQ, W_SEQ */
    vSeq[vk] = shiftReg[polyOrder-1];
    wSeq[wk] = shiftReg[polyOrder-1];

    /* Loop over for a whole period of v */
    while (vk < vPeriod-1)
    {
        /* account for the shift parameter by storing states */
        if ( uk == shift[0] )
        { 
            for(i = 0; i < polyOrder; i++)
                shiftRegCp[i] = shiftReg[i];
        }

        /* compute feedback bit */
        tmp = 0;
        for (i = 1; i <= polyOrder; i++)
            tmp += (int_T) polynomial[i] * shiftReg[i-1];
        tmp %= 2;

        /* store the two decimated sequences */
        if (uk > 0) /* first bit is already taken */
        {
            /* V_SEQ - last register contents every 2^(polyOrder/2+1)+1 bits */
            if ( fmod(uk+1, vDecIdx) == 1 ) {
                vSeq[vk+1] = shiftReg[polyOrder-1];
                vk++;
            }

            /* W_SEQ - last register contents every 2^(polyOrder/2)+1 bits */
            if ( (wk != wPeriod-1) && (fmod(uk+1, wPeriod+2) == 1) ) {
                wSeq[wk+1] = shiftReg[polyOrder-1];
                wk++;
            }
        } /* end if uk>0 statement */
        
        /* right shift */
        for (i = polyOrder-1; i > 0; i--)
            shiftReg[i] = shiftReg[i-1];
        shiftReg[0] = tmp;

        /* increment running index for u sequence */
        uk++;

    } /* end while loop */

    /* Restore the states back to initial (advanced by shift) ones*/
    for(i = 0; i < polyOrder; i++)
        shiftReg[i] = shiftRegCp[i];

    /* Left shift V_SEQ by INDEX[0] + SHIFT amount for later direct xoring */
    j = shift[0];
    if (index[0] < 0)  /* Handle the negative values */
        j -= index[0];

    for (i = 0; i < index[0]+j; i++) 
    {
        tmp = vSeq[0];
        for (vk = 0; vk < vPeriod-1; vk++)
            vSeq[vk] = vSeq[vk+1];
        vSeq[vPeriod-1] = tmp;
    }

    /* Left shift W_SEQ by INDEX[1] + SHIFT amount for later direct xoring */
    j = shift[0];
    if (index[1] < 0) /* Handle the negative values */
        j -= index[1];

    for (i = 0; i < index[1]+j; i++) 
    {
        tmp = wSeq[0];
        for (wk = 0; wk < wPeriod-1; wk++)
            wSeq[wk] = wSeq[wk+1];
        wSeq[wPeriod-1] = tmp;
    }
        
} /* end mdlInitializeConditions */

/* Output the original PN sequence from the advanced iniState and xor it with
 * the cyclically shifted decimated sequences, V_SEQ and W_SEQ as per the
 * indexes specified.
 * Manage the indexing of the elements of the sequences v and w, for outputs 
 * and handle the resetting capability by checking at each sample point.  
 */
static void mdlOutputs(SimStruct *S, int_T tid)
{
    int_T     i, tmp;
    uint32_T  tmp2, tmp3, frameSize, resetSize, j;
    
    int_T    *shiftReg   = (int_T    *)ssGetDWork(S, SHIFT_REG);
    int_T    *shiftRegCp = (int_T    *)ssGetDWork(S, SHIFT_REG_COPY);
    int_T    *wSeq       = (int_T    *)ssGetDWork(S, W_SEQ);
    uint32_T *wSeqIdx    = (uint32_T *)ssGetDWork(S, WSEQ_IDX);
    int_T    *vSeq       = (int_T    *)ssGetDWork(S, V_SEQ);
    uint32_T *vSeqIdx    = (uint32_T *)ssGetDWork(S, VSEQ_IDX);

    real_T   *polynomial = (real_T   *)mxGetPr(POLYNOMIAL_ARG);
    real_T   *index      = (real_T   *)mxGetPr(INDEX_ARG);

    real_T   *y          = (real_T   *)ssGetOutputPortRealSignal(S,OUTPORT);
    real_T   *inp;
    
    int_T     polyOrder  = (int_T)mxGetN(POLYNOMIAL_ARG) *
                                  mxGetM(POLYNOMIAL_ARG) - 1;
    uint32_T  vPeriod    = (uint32_T) pow(2, polyOrder) - 1;
    uint32_T  wPeriod    = (uint32_T) pow(2, polyOrder/2) - 1;

    /* Determine the frame size */
    if (FRAME_BASED)
        frameSize  = (uint32_T)mxGetPr(SAMPLES_PER_FRAME_ARG)[0];
    else
        frameSize = 1;  /* sample-based */

    if (RESET_ON)
    {   /* Get the reset signal */
        inp       = (real_T *)ssGetInputPortRealSignal(S, INPORT);
        resetSize = (uint32_T)ssGetInputPortWidth(S, INPORT);

        if (resetSize == 1) /* for scalar resetting and at start of frame */ 
        {
            if (*inp != 0.0)
            {   /* reset the shift register for nonzero input */
                for(i = 0; i < polyOrder; i++)
                    shiftReg[i] = shiftRegCp[i];
                    
                /* reset the v, w sequence indexes */
                vSeqIdx[0] = 0;
                wSeqIdx[0] = 0;    
            }
        }
    } /* end if(RESET_ON) statement */

    /* Loop over samples in the frame */
    for (j = 0; j < frameSize; j++)
    {
        /* Check for reset */
        if (RESET_ON)
        {
            if (resetSize > 1)  /* For resetting within a frame */
            {
                if (inp[j] != 0.0)
                {   /* reset the shift register for nonzero input */
                    for(i = 0; i < polyOrder; i++)
                        shiftReg[i] = shiftRegCp[i];

                    /* reset the v, w sequence indexes */
                    vSeqIdx[0] = 0;
                    wSeqIdx[0] = 0;    
                }
            }
        } /* end check for reset */
        
        /* Compute feedback bit */
        tmp = 0;
        for (i = 1; i <= polyOrder; i++)
            tmp += (int_T) polynomial[i] * shiftReg[i-1];
        tmp %= 2;

        /* Set-up the V_SEQ index */
        tmp2 = vSeqIdx[0];
        if (tmp2 > vPeriod-1) {
            tmp2 -=  vPeriod;
            vSeqIdx[0] = tmp2; /* reset */
        }
        (*vSeqIdx)++;

        /* Set-up the W_SEQ index */
        tmp3 = wSeqIdx[0];
        if (tmp3 > wPeriod-1) {
            tmp3 -=  wPeriod;
            wSeqIdx[0] = tmp3; /* reset */
        }
        (*wSeqIdx)++;

        /* Output data - last stage of the register xored with the bits of 
         * the decimated sequences as per the index values/ranges.
         * K(n,k,m) = u                  for k = -2,        m = -1
         *            v                  for k = -1,        m = -1
         *            u + T^k v          for k = 0..2^n-2,  m = -1
         *            u + T^m w          for k = -2,        m = 0..2^(n/2)-2
         *            v + T^m w          for k = -1,        m = 0..2^(n/2)-2
         *            u + T^k v + T^m w  for k = 0..2^n-2,  m = 0..2^(n/2)-2  
         */
        if ( (index[0] == -2) && (index[1] == -1) ) {
            /* U sequence */
            y[j] = shiftReg[polyOrder-1];

        } else if ( (index[0] == -1) && (index[1] == -1) ) {
            /* V sequence */
            y[j] = vSeq[tmp2];

        } else if ( (index[0] >= 0) && (index[1] == -1) ) {
            /* Gold sequences */
            y[j] = (shiftReg[polyOrder-1] + vSeq[tmp2]) % 2;
        
        } else if ( (index[0] == -2) && (index[1] >= 0) ) {
            /* Small Set of Kasami sequences */
            y[j] = (shiftReg[polyOrder-1] + wSeq[tmp3]) % 2;

        } else if ( (index[0] == -1) && (index[1] >= 0) ) {
            y[j] = (vSeq[tmp2] + wSeq[tmp3]) % 2;
        
        } else if ( (index[0] >= 0) && (index[1] >= 0) ) {
            y[j] = (shiftReg[polyOrder-1] + vSeq[tmp2] + wSeq[tmp3]) % 2;

        } /* end if index.. */

        /* Right shift */
        for (i = polyOrder-1; i > 0; i--)
            shiftReg[i] = shiftReg[i-1];
        shiftReg[0] = tmp;

    } /* end for loop j */ 

} /* end mdloutputs */


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
     *   [1] or [1x1]SB      [1]   SB
     *                       [Nx1] FB    -> resetting at start of frame
     *
     *   [Nx1]FB             [Nx1] FB    -> resetting within a frame
     *
     *   N is the number of samples per frame in the output.
     *   Note: The output is pre-set as per the parameters in the mask and 
     *         is NOT dependent on the reset signal attributes.
     *         All we are doing here is setting and validating the input port. 
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
        if ( fabs(Tsout - sampleTime) > (pow(2, -52)) )  /* if >eps error */
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

    int_T   polyOrder = mxGetN(POLYNOMIAL_ARG) * mxGetM(POLYNOMIAL_ARG) - 1;

    uint32_T  vPeriod = (uint32_T) pow(2, polyOrder) - 1;
    uint32_T  wPeriod = (uint32_T) pow(2, polyOrder/2) - 1;

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

    /* Decimated Sequence V*/
    ssSetDWorkWidth(        S, V_SEQ, vPeriod);
    ssSetDWorkDataType(     S, V_SEQ, SS_INT32);
    ssSetDWorkComplexSignal(S, V_SEQ, COMPLEX_NO);

    /* Decimated Sequence V Index - used for output*/
    ssSetDWorkWidth(        S, VSEQ_IDX, 1);
    ssSetDWorkDataType(     S, VSEQ_IDX, SS_UINT32);
    ssSetDWorkComplexSignal(S, VSEQ_IDX, COMPLEX_NO);

    /* Decimated Sequence W*/
    ssSetDWorkWidth(        S, W_SEQ, wPeriod);
    ssSetDWorkDataType(     S, W_SEQ, SS_INT32);
    ssSetDWorkComplexSignal(S, W_SEQ, COMPLEX_NO);

    /* Decimated Sequence W Index - used for output*/
    ssSetDWorkWidth(        S, WSEQ_IDX, 1);
    ssSetDWorkDataType(     S, WSEQ_IDX, SS_UINT32);
    ssSetDWorkComplexSignal(S, WSEQ_IDX, COMPLEX_NO);
}
#endif

#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-File interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif

/* EOF */
