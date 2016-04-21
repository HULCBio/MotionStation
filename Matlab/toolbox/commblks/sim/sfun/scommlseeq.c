/*
 *   SCOMMLSEEQ Communications Blockset S-function for MLSE
 *   Equalizer. This S-Function receives dispersed signal
 *   sequence as input and outputs estimates of the transmitted
 *   input sequence computed using the Viterbi Algorithm.
 *
 *   This S-function has helper function (viterbi_acs_tbd.c) that is
 *   also used by the other S-functions with the Viterbi Algorithm.
 *
 *   Copyright 1996-2004 The MathWorks, Inc.
 *   $Revision: 1.1.8.7 $  $Date: 2004/04/12 23:03:31 $
 */

#define S_FUNCTION_NAME scommlseeq
#define S_FUNCTION_LEVEL 2

#include "scommlseeq.h"


/* Function: mdlCheckParameters ========================================= */
#ifdef MATLAB_MEX_FILE
#define MDL_CHECK_PARAMETERS
static void mdlCheckParameters(SimStruct *S)
{
    /* The mask checks the parameters. */
    UNUSED_ARG(S);

} /* end of mdlCheckParameters */
#endif


/* Function: mdlInitializeSizes ========================================= */
static void mdlInitializeSizes(SimStruct *S)
{
    int_T  argCount;

    /* Parameters: */
    ssSetNumSFcnParams(S, NUM_ARGS);

    #if defined(MATLAB_MEX_FILE)
        if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S))
            return;
        mdlCheckParameters(S);
        if (ssGetErrorStatus(S) != NULL) return;
    #endif

    /* Cannot change params while running: */
    for(argCount = 0; argCount < NUM_ARGS; ++argCount)
    {
        ssSetSFcnParamTunable(S, argCount, 0);
    }

    /* Block-based */
    ssSetNumSampleTimes(S, 1);

    /* Inputs and Outputs */
    {
        int_T	numInports ;

        const boolean_T hasChanPort = HAS_CHAN_PORT(S);
        const boolean_T hasRstPort  = HAS_RST_PORT(S);

        numInports = hasChanPort ? 2 : 1;
        numInports = hasRstPort  ? numInports+1 : numInports;

        /* Initialize Input ports: */
        if (!ssSetNumInputPorts(S, numInports)) return;

        /* Data input */
        if (!ssSetInputPortDimensionInfo(S, INPORT_DATA, \
             DYNAMIC_DIMENSION))  return;
        ssSetInputPortFrameData(         S, INPORT_DATA, FRAME_YES);
        ssSetInputPortDirectFeedThrough( S, INPORT_DATA, 1);
        ssSetInputPortReusable(          S, INPORT_DATA, 1);
        ssSetInputPortComplexSignal(     S, INPORT_DATA, COMPLEX_YES);
        ssSetInputPortRequiredContiguous(S, INPORT_DATA, 1);

        /* Channel input */
        if (hasChanPort)
        {
            if(!ssSetInputPortDimensionInfo(S, INPORT_CHAN, \
                DYNAMIC_DIMENSION)) return;
            ssSetInputPortFrameData(         S, INPORT_CHAN, FRAME_YES);
            ssSetInputPortDirectFeedThrough( S, INPORT_CHAN, 1);
            ssSetInputPortReusable(          S, INPORT_CHAN, 1);
            ssSetInputPortComplexSignal(     S, INPORT_CHAN, COMPLEX_INHERITED);
            ssSetInputPortRequiredContiguous(S, INPORT_CHAN, 1);
        }

        /* Reset input */
        if (hasRstPort)
        {
           /* Since the the number of input ports is variable,
            * can't use INPORT_RESET. Whenever there is a reset
            * port, its port index is one less then the total
            * number of input ports
            */
            int_T  rstPortIdx = numInports - 1;

            /* Reset is always a scalar */
            if(!ssSetInputPortMatrixDimensions(S, rstPortIdx, 1, 1))
                return;
            ssSetInputPortFrameData(           S, rstPortIdx, FRAME_INHERITED);
            ssSetInputPortDirectFeedThrough(   S, rstPortIdx, 1);
            ssSetInputPortReusable(            S, rstPortIdx, 1);
            ssSetInputPortComplexSignal(       S, rstPortIdx, COMPLEX_NO);
            ssSetInputPortRequiredContiguous(  S, rstPortIdx, 1);
        }

        /* Initialize Output ports: */
        if (!ssSetNumOutputPorts(S,1)) return;
        if(!ssSetOutputPortDimensionInfo(S, OUTPORT_DATA, \
            DYNAMIC_DIMENSION)) return;
        ssSetOutputPortFrameData(        S, OUTPORT_DATA, FRAME_YES);
        ssSetOutputPortComplexSignal(    S, OUTPORT_DATA, COMPLEX_YES);
        ssSetOutputPortReusable(         S, OUTPORT_DATA, 1);

        if (!ssSetNumDWork(S, DYNAMICALLY_SIZED)) return;

        ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE |
                        SS_OPTION_REQ_INPUT_SAMPLE_TIME_MATCH);
    }
} /* end of mdlInitializeSizes */


/* Function: mdlInitializeSampleTimes =================================== */
static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, FIXED_IN_MINOR_STEP_OFFSET);

#ifdef MATLAB_MEX_FILE
      	if (ssGetSampleTime(S, 0) == CONTINUOUS_SAMPLE_TIME)
        {
		    THROW_ERROR(S, "All signals must be discrete.");
    	}
#endif

   ssSetModelReferenceSampleTimeInheritanceRule(S, USE_DEFAULT_FOR_DISCRETE_INHERITANCE);
 
} /* end of mdlInitializeSampleTimes */


#ifdef MATLAB_MEX_FILE
/* Function: mdlSetWorkWidths =========================================== */
#define MDL_SET_WORK_WIDTHS
static void mdlSetWorkWidths(SimStruct *S)
{
    /*
     *  This is where we allocate memory for work vectors.
     *  Storage requirements:
     *
     * BMETRIC      : Stores the branch metric for all branches
     *                in trellis
     *                "numStates*alpha" units of storage
     * STATE_METRIC : Stores state metrics for every state
     *                "numStates" units of storage
     * TEMP_METRIC  : Stores temporary state metric for every
     *                state
     *                "numStates" units of storage
     * TBSTATE      : Stores the traceback state information
     *                "numStates*(tblen+1)" units of storage
     * TBINPUT      : Stores the traceback input information
     *                "numStates*(tblen+1)" units of storage
     * TBPTR        : Stores the traceback pointer to begin
     *                traceback
     *                "1" unit of storage
     * EXP_OUTPUT   : Stores the expected output computed from
     *                channel estimates and constellation
     *                information
     *                "numStates*alpha*numSamp" units of storage
     * LEN_PREAMBLE : Stores the preamble length
     *                "1" unit of storage
     * LEN_POSTAMBLE: Stores the postamble length
     *                "1" unit of storage
     * CHANTAPS_IM  : Channel vector for imag part, size (chMem+1)*numSamp
     * CHANTAPS_RE  : Channel vector for real part, size (chMem+1)*numSamp
     * NUM_STATES   : Stores the number of trellis states
     *                "1" unit of storage
     * NXT_STATES   : Stores the next states matrix for the channel trellis
     *               "numStates*alpha" units of storage
     * OUTPUTS      : Stores the outputs matrix for the channel trellis
     *               "numStates*alpha" units of storage
     */

    int_T           chMem;
    uint32_T        numStates ;

    const int_T     alpha       = (int_T)mxGetNumberOfElements(CONST_PTS_RE_ARG(S));
    const int_T     tbLen       = (int_T) mxGetPr(TB_ARG(S))[0];
    const int_T     numSamp     = (int_T) mxGetPr(SAMP_PER_SYM_ARG(S))[0];

    const boolean_T hasChanPort = HAS_CHAN_PORT(S);
    /* 2^16 was derived experimentally
     * 2^20 was computed using sum of all
     * the work vector memory requirements
     */
    uint32_T        limit1      = (uint32_T)(pow(2, 16)-1);
    uint32_T        limit2      = (uint32_T)(pow(2, 20)-1);

    chMem     = (hasChanPort)? CHMEM_PORT(S,numSamp) : CHMEM_MASK(S,numSamp);
    numStates = (uint32_T)pow(alpha,chMem);

    /* Memory Limitation error / warnings when channel is specified via port */
    if( (hasChanPort) && (numStates > limit1) )
    {
        if( numStates > limit2 )
        {
            /* Simulink error window */
            THROW_ERROR(S,"MLSE Equalizer block parameter "
                          "settings describe a trellis with more "
                          "than 2^20 states leading to memory "
                          "allocation failure.");
        }
        else
        {
            /* This brings a warning in the MATLAB window */
            ssWarning(S, "MLSE Equalizer parameter settings "
                         "create a trellis with more than 2^16 "
                         "states." );
        }

    }

    ssSetNumDWork(S, NUM_DWORK);

    ssSetDWorkName(         S, BMETRIC, "BranchMetric");
    ssSetDWorkWidth(        S, BMETRIC, numStates*alpha);
    ssSetDWorkDataType(     S, BMETRIC, SS_DOUBLE);
    ssSetDWorkComplexSignal(S, BMETRIC, COMPLEX_NO);
    ssSetDWorkUsedAsDState( S, BMETRIC, SS_DWORK_USED_AS_DSTATE);

    ssSetDWorkName(         S, STATE_METRIC, "NormStateMetric");
    ssSetDWorkWidth(        S, STATE_METRIC, numStates);
    ssSetDWorkDataType(     S, STATE_METRIC, SS_DOUBLE);
    ssSetDWorkComplexSignal(S, STATE_METRIC, COMPLEX_NO);
    ssSetDWorkUsedAsDState( S, STATE_METRIC, SS_DWORK_USED_AS_DSTATE);

    ssSetDWorkName(         S, TEMP_METRIC, "TempStateMetric");
    ssSetDWorkWidth(        S, TEMP_METRIC, numStates);
    ssSetDWorkDataType(     S, TEMP_METRIC, SS_DOUBLE);
    ssSetDWorkComplexSignal(S, TEMP_METRIC, COMPLEX_NO);

    ssSetDWorkName(         S, TBSTATE, "TracebackState");
    ssSetDWorkWidth(        S, TBSTATE, numStates*(tbLen + 1));
    ssSetDWorkDataType(     S, TBSTATE, SS_UINT32);
    ssSetDWorkComplexSignal(S, TBSTATE, COMPLEX_NO);

    ssSetDWorkName(         S, TBINPUT, "TracebackInput");
    ssSetDWorkWidth(        S, TBINPUT, numStates*(tbLen + 1));
    ssSetDWorkDataType(     S, TBINPUT, SS_UINT32);
	ssSetDWorkComplexSignal(S, TBINPUT, COMPLEX_NO);

    ssSetDWorkName(         S, TBPTR, "TracebackPtr");
    ssSetDWorkWidth(        S, TBPTR, 1);
    ssSetDWorkDataType(     S, TBPTR, SS_INT32);
    ssSetDWorkComplexSignal(S, TBPTR, COMPLEX_NO);

    ssSetDWorkName(         S, EXP_OUTPUT, "ExpectedOutput");
    ssSetDWorkWidth(        S, EXP_OUTPUT, numStates*alpha*numSamp);
    ssSetDWorkDataType(     S, EXP_OUTPUT, SS_DOUBLE);
    ssSetDWorkComplexSignal(S, EXP_OUTPUT, COMPLEX_YES);
    ssSetDWorkUsedAsDState( S, EXP_OUTPUT, SS_DWORK_USED_AS_DSTATE);

    ssSetDWorkName(         S, LEN_PREAMBLE, "PreambleLen");
    ssSetDWorkWidth(        S, LEN_PREAMBLE, 1);
    ssSetDWorkDataType(     S, LEN_PREAMBLE, SS_INT32);
    ssSetDWorkComplexSignal(S, LEN_PREAMBLE, COMPLEX_NO);

    ssSetDWorkName(         S, LEN_POSTAMBLE, "PostambleLen");
    ssSetDWorkWidth(        S, LEN_POSTAMBLE, 1);
    ssSetDWorkDataType(     S, LEN_POSTAMBLE, SS_INT32);
    ssSetDWorkComplexSignal(S, LEN_POSTAMBLE, COMPLEX_NO);

    ssSetDWorkName(         S, CHANTAPS_IM, "ChannelTapImag");
    ssSetDWorkWidth(        S, CHANTAPS_IM, (chMem+1)*numSamp);
    ssSetDWorkDataType(     S, CHANTAPS_IM, SS_DOUBLE);
    ssSetDWorkComplexSignal(S, CHANTAPS_IM, COMPLEX_NO);

    ssSetDWorkName(         S, CHANTAPS_RE, "ChannelTapReal");
    ssSetDWorkWidth(        S, CHANTAPS_RE, (chMem+1)*numSamp);
    ssSetDWorkDataType(     S, CHANTAPS_RE, SS_DOUBLE);
    ssSetDWorkComplexSignal(S, CHANTAPS_RE, COMPLEX_NO);

    ssSetDWorkName(         S, NUM_STATES, "NumberOfStates");
    ssSetDWorkWidth(        S, NUM_STATES, 1);
    ssSetDWorkDataType(     S, NUM_STATES, SS_UINT32);
    ssSetDWorkComplexSignal(S, NUM_STATES, COMPLEX_NO);

    ssSetDWorkName(         S, NXT_STATES, "NextStates");
    ssSetDWorkWidth(        S, NXT_STATES, numStates*alpha);
    ssSetDWorkDataType(     S, NXT_STATES, SS_UINT32);
    ssSetDWorkComplexSignal(S, NXT_STATES, COMPLEX_NO);

    ssSetDWorkName(         S, OUTPUTS, "Output");
    ssSetDWorkWidth(        S, OUTPUTS, numStates*alpha);
    ssSetDWorkDataType(     S, OUTPUTS, SS_UINT32);
    ssSetDWorkComplexSignal(S, OUTPUTS, COMPLEX_NO);


} /* end of mdlSetWorkWidths */
#endif


/* Function: initStateMetric ============================================ */
static void initStateMetric(uint32_T numStates, real_T value, real_T *pStateMet)
{
    uint32_T indx;

    for(indx = 0 ; indx < numStates ; indx++)
       pStateMet[indx] = value;

}/* end of initStateMetric */


/* Function: rstInitCond ================================================= */
static void rstInitCond(const int_T alpha, int_T chMem,
                        const real_T *preamble,
                        int_T lenPreamble, real_T *pStateMet,
                        const int_T tbLen, uint32_T *pTbState,
                        uint32_T *pTbInput,uint32_T numStates)
{
    int_T     i, limit1;
    uint32_T  j, k, limit2, initState = 0;
    uint32_T  offset    = (uint32_T) pow(alpha,chMem - 1);

    if(lenPreamble <= 0)
    /* Set all state metrics to 0 */
    {
       initStateMetric(numStates, 0.0 , pStateMet);
    }
    else
    /* Map the preamble to state(s) and assign those state
     * metrics to 0. When the length of the preamble is
     * shorter than the channel length, the preamble would
     * map to more than one state and all those states
     * would receive a state metric of 0.
     */
    {
        initStateMetric(numStates, (real_T) MAX_int16_T, pStateMet);

        if(chMem > lenPreamble)
        {
            limit1 = lenPreamble;
            limit2 = (uint32_T) pow(alpha, chMem - lenPreamble);
        }
        else
        {
            limit1 = chMem;
            limit2 = (uint32_T)((chMem>0)?1:0);
        }

        /* Computing the starting state(s) from the preamble */
        for(i=0; i < limit1; i++)
        {
            initState+=(uint32_T) preamble[lenPreamble -1 -i] * offset;
            offset   /= alpha;
        }

        for(k=0; k < limit2 +1; k++)
        {
            pStateMet[k + initState] = 0.0;
        }


    } /* end if(pLenPreamble[0]<=0) */

    /* Set traceback memory to zero */
    for(j = 0; j < (numStates*(tbLen + 1)); j++)
    {
        pTbInput[j] = 0;
        pTbState[j] = 0;
    }
} /* end of rstInitCond */


/* Function: expOutputComp ================================== */
static void expOutputComp(const int_T     alpha,
                                int_T     chMem,
                                uint32_T  numStates,
                          const int_T     numSamp,
                          const real_T   *pConstRe,
                          const real_T   *pConstIm,
                                real_T   *pCtapsRe,
                                real_T   *pCtapsIm,
                                creal_T  *pExpOutput)
{
    /* Expected output is effectively complex multiplication of signal input
     * and channel coefficients.     */
    uint32_T  i, indx1, outIdx;
    int_T     indx2, indx3, sigIdx, chIdx, temp;

    /* Initialize the expected output vectors.*/
    for(i = 0; i < (numStates * alpha * numSamp); i++)
    {
        pExpOutput[i].re = 0.0;
        pExpOutput[i].im = 0.0;
    }

    /* Loop over the sampled channel length */
    for(indx1 = 0; indx1 < numStates*alpha; indx1++)
    {
        temp = indx1;

        /* Loop over the symbol spaced channel memory */
        for(indx2 = 0; indx2 < chMem+1; indx2++)
        {
            sigIdx = temp%alpha;


            /* Loop over all possible(numSamp) symbol spaced channels
             */
            for(indx3 = 0; indx3 < numSamp; indx3++)
            {
                /* Account for oversampling */

                outIdx = indx1 + (numSamp-1 -indx3) * numStates * alpha;
                chIdx  = (chMem+1)*numSamp-1 -indx3 - numSamp*indx2;

               pExpOutput[outIdx].re += CPLX_MULT_REAL(pConstRe[sigIdx], \
                     pConstIm[sigIdx], pCtapsRe[chIdx], pCtapsIm[chIdx]) ;

               pExpOutput[outIdx].im += CPLX_MULT_IMAG(pConstRe[sigIdx], \
                     pConstIm[sigIdx], pCtapsRe[chIdx], pCtapsIm[chIdx]) ;

            } /* end of for(indx3=0; indx3 < numSamp; indx3++) */

            temp /= alpha;

        } /* end of for(indx2=0; indx2<chMem+1; indx2++) */
    } /* end of for(indx1=0; indx1<numStates*alpha; indx1++) */
}  /* end of expOutputComp */


/* Function: mdlInitializeConditions ==================================== */
#define MDL_INITIALIZE_CONDITIONS
static void mdlInitializeConditions(SimStruct *S)
{
          int_T     j, k, chMem;
    const int_T     alpha    = (int_T)mxGetNumberOfElements(CONST_PTS_RE_ARG(S));
    const int_T     tbLen    = (int_T)mxGetPr(TB_ARG(S))[0];
    const int_T     numSamp  = (int_T)mxGetPr(SAMP_PER_SYM_ARG(S))[0];
    const real_T   *pConstRe = mxGetPr(CONST_PTS_RE_ARG(S));
    const real_T   *pConstIm = mxGetPr(CONST_PTS_IM_ARG(S));

    const boolean_T isContMode   = (boolean_T) IS_CONT_MODE(S);
    const boolean_T hasChanPort  = HAS_CHAN_PORT(S);
    const boolean_T hasPreamble  = (boolean_T) ((int_T)(mxGetPr(EN_PREAMBLE_ARG(S))[0] == MLSE_ENABLE)\
                                  && (!isContMode));
    const boolean_T hasPostamble = (boolean_T) ((int_T)(mxGetPr(EN_POSTAMBLE_ARG(S))[0] == MLSE_ENABLE)\
                                  && (!isContMode));

    const real_T   *preamble    = mxGetPr(PREAMBLE_ARG(S));

    int_T    *pLenPreamble  = (int_T *)   ssGetDWork(S, LEN_PREAMBLE);
    int_T    *pLenPostamble = (int_T *)   ssGetDWork(S, LEN_POSTAMBLE);
    real_T   *pCtapsIm      = (real_T *)  ssGetDWork(S, CHANTAPS_IM);
    real_T   *pCtapsRe      = (real_T *)  ssGetDWork(S, CHANTAPS_RE);
    real_T   *pStateMet     = (real_T *)  ssGetDWork(S, STATE_METRIC);
    uint32_T *pNumStates    = (uint32_T *)ssGetDWork(S, NUM_STATES);
    uint32_T *pNxtStates    = (uint32_T *)ssGetDWork(S, NXT_STATES);
    uint32_T *pOutputs      = (uint32_T *)ssGetDWork(S, OUTPUTS);
    uint32_T *pTbState      = (uint32_T *)ssGetDWork(S, TBSTATE);
    uint32_T *pTbInput      = (uint32_T *)ssGetDWork(S, TBINPUT);
    creal_T  *pExpOutput    = (creal_T *) ssGetDWork(S, EXP_OUTPUT);


    /* Setting channel memory and number of states
     * channel memory    = channel length -1;
     * number of states  = M^(channel memory);
     * where M= M-ary number.
     */
    chMem         = (hasChanPort)? CHMEM_PORT(S,numSamp) : CHMEM_MASK(S,numSamp);
    pNumStates[0] = (uint32_T)pow(alpha,chMem);

    pLenPreamble[0] = (hasPreamble)?(int_T) mxGetNumberOfElements(PREAMBLE_ARG(S)):0;
    pLenPostamble[0] = (hasPostamble)?(int_T) mxGetNumberOfElements(POSTAMBLE_ARG(S)):0;

    /* Initialize the channel tap vectors */
    for (j = 0; j < (chMem+1)*numSamp; j++) {
        pCtapsRe[j] = 0.0;
        pCtapsIm[j] = 0.0;
    }

    if(!hasChanPort) /* Channel Via Dialog */
    {

        const real_T *pChanRe  = mxGetPr(CHAN_COEFF_RE_ARG(S));
        const real_T *pChanIm  = mxGetPr(CHAN_COEFF_IM_ARG(S));

        for (j = 0; j < (chMem+1)*numSamp; j++)
        {
            pCtapsRe[j] = pChanRe[j];
            pCtapsIm[j] = pChanIm[j];
        }

        /* Expected Output Computation - required for the Branch Metric
         * Computation
         */
        expOutputComp(alpha, chMem, pNumStates[0], numSamp, pConstRe,
                      pConstIm, pCtapsRe, pCtapsIm, pExpOutput);
    }


    /* Compute next states and expected outputs for the equalizer trellis */
    for(k=0; k < (int_T)pNumStates[0]*alpha; k++)
    {
        pNxtStates[k] = (uint32_T) floor(k/alpha) ;
        pOutputs[k]   = (uint32_T) k ;

    }

    rstInitCond(alpha, chMem, preamble, pLenPreamble[0],
                pStateMet, tbLen, pTbState, pTbInput, pNumStates[0]);

} /* End mdlInitializeConditions */


/* Function: outputPreamble =============================== */
static void outputPreamble(const real_T *preamble,
                           int_T        lenPreamble,
                           const real_T *pConstRe,
                           const real_T *pConstIm,
                           creal_T      *thisBlockOutCplx)
{
    int_T i, temp;

    /* Save preamble data into the output vector */
    for(i = 0; i < lenPreamble; i++)
    {
        temp = (int_T) preamble[i];
        thisBlockOutCplx[i].re = pConstRe[temp];
        thisBlockOutCplx[i].im = pConstIm[temp];
    }
} /* end of outputPreamble */


/* Function: branchMetricComputation ==================================== */
static void branchMetricComp(const int_T  alpha,
                             uint32_T     numStates,
                             const int_T  numSamp,
                             creal_T     *pExpOutput,
                             real_T      *pBMet,
                             creal_T     *thisBlockInCplx)
{
    /* Branch Metric Computation computes the Euclidean distance
     * between the received signal and expected output.
     */
    uint32_T indx1, outIdx;
    int_T    indx2, inIdx;

    /* Loop over all branches */
    for(indx1 = 0; indx1 < numStates*alpha; indx1++)
    {
        pBMet[indx1] = 0.0;     /* Initialize the branch metrics */

        /* Account for Oversampling */
        for(indx2 = 0; indx2 < numSamp; indx2++)
        {
            inIdx = numSamp -1 -indx2;
            outIdx = indx1 + (inIdx)*numStates*alpha;

            pBMet[indx1] +=  \
                pow((thisBlockInCplx[inIdx].re - pExpOutput[outIdx].re),2) +
                pow((thisBlockInCplx[inIdx].im - pExpOutput[outIdx].im),2);
        }
    }
}   /* end of branchMetricComputation */

static uint32_T getPostambleState(int_T lenPostamble, int_T ib,
                                  int_T blockSize, int_T alpha,
                                  int_T chMem, const real_T *postamble,
                                  uint32_T minState)
{
    if (lenPostamble > 0 && ib == blockSize - 1)
    {
        int_T    i, limit1;
        uint32_T finState = 0;
        uint32_T offset   = (uint32_T) pow(alpha, chMem-1) ;

        if (chMem > lenPostamble)
        {
            limit1 = lenPostamble;
        }
        else
        {
            limit1 = chMem;
        }

        /* Computing the ending state from the postamble */
        for(i=0; i< limit1; i++)
        {
            finState += (uint32_T) postamble[lenPostamble -1 -i]\
                         *offset;
            offset   /= alpha;
        }

        minState = finState;

    }

    return minState;

} /* end of getPostambleState */


/* Function: mdlOutputs ================================================= */
static void mdlOutputs(SimStruct *S, int_T tid)
{
    /*  This is the main body of the MLSE Equalizer
     *
     *  The algorithm performs the follwing operations:
     *      1. Expected output computation
     *      2. Output preamble
     *      3. Branch metric computation
     *      4. State metric update - Helper file
     *      5. Traceback decoding  - Helper file
     */

    const int_T      alpha       = (int_T)mxGetNumberOfElements(CONST_PTS_RE_ARG(S));
    const int_T      tbLen       = (int_T)mxGetPr(TB_ARG(S))[0];
    const int_T      numSamp     = (int_T)mxGetPr(SAMP_PER_SYM_ARG(S))[0];

    const boolean_T  isContMode  = (boolean_T) IS_CONT_MODE(S);
    const real_T    *preamble    = mxGetPr(PREAMBLE_ARG(S));

    const boolean_T  hasRstPort  = HAS_RST_PORT(S);
    const boolean_T  hasChanPort = HAS_CHAN_PORT(S);

    int8_T           numInports  = (int8_T)(hasChanPort ? 2:1);
    int8_T           rstPortIdx  = numInports;

    real_T   *pStateMet    = (real_T *)  ssGetDWork(S, STATE_METRIC);
    uint32_T *pTbState     = (uint32_T *)ssGetDWork(S, TBSTATE);
    uint32_T *pTbInput     = (uint32_T *)ssGetDWork(S, TBINPUT);
    int_T    *pTbPtr       = (int_T *)   ssGetDWork(S, TBPTR);
    creal_T  *pExpOutput   = (creal_T *) ssGetDWork(S, EXP_OUTPUT);
    int_T    *pLenPreamble = (int_T *)   ssGetDWork(S, LEN_PREAMBLE);
    uint32_T *pNumStates   = (uint32_T *)ssGetDWork(S, NUM_STATES);
    uint32_T *pNxtStates   = (uint32_T *)ssGetDWork(S, NXT_STATES);
    uint32_T *pOutputs     = (uint32_T *)ssGetDWork(S, OUTPUTS);
    real_T   *pCtapsIm     = (real_T *)  ssGetDWork(S, CHANTAPS_IM);
    real_T   *pCtapsRe     = (real_T *)  ssGetDWork(S, CHANTAPS_RE);

    int_T  blockSize = ssGetInputPortWidth(S, INPORT_DATA)/numSamp - pLenPreamble[0];

    /* Complex constellation points */
    const real_T    *pConstRe = mxGetPr(CONST_PTS_RE_ARG(S));
    const real_T    *pConstIm = mxGetPr(CONST_PTS_IM_ARG(S));

    int_T           i, ib, chMem, tbWorkLastTb;
    uint32_T        minState =0 , minStateLastTb;

    /* Output pointers */
    creal_T  *sigOutCplx, *thisBlockOutCplx;
    sigOutCplx = (creal_T *)  ssGetOutputPortSignal(S, OUTPORT_DATA);

    /* Compute number of input ports */
    numInports = (int8_T)(hasRstPort ? numInports+1 : numInports);

    /* Setting channel memory */
    chMem      = hasChanPort? CHMEM_PORT(S,numSamp): CHMEM_MASK(S,numSamp);

    {
        /* Get reset value if reset port is present */
        real_T  *pRstIn   = (!hasRstPort) ? NULL : (real_T *) \
                                    ssGetInputPortSignal(S,(int_T)rstPortIdx);

        /* RESET EVERY FRAME mode represented by RST_FRAME: Reset
         * such that every frame is independent
         * CONTINUOUS mode represented by CONT: Reset if requested
         */
        if (!isContMode || (hasRstPort && pRstIn[0] != 0.0))
        {
            rstInitCond(alpha, chMem, preamble,
                        pLenPreamble[0], pStateMet, tbLen, pTbState,
                        pTbInput, pNumStates[0]);
        }
    }

    /* Initialize channel coefficients for via port case, via dialog has
     * been addressed earlier
     */
    if(hasChanPort)
    {
        if (IS_CHAN_CPLX_PORT(S)) /* complex channel coeeficients */
        {
            creal_T *pCtapsCplx = (creal_T *) ssGetInputPortSignal(S, INPORT_CHAN);

            for (i = 0; i < (chMem+1)*numSamp; i++)
            {
                pCtapsRe[i] = pCtapsCplx[i].re;
                pCtapsIm[i] = pCtapsCplx[i].im;
            }
        }
        else /* real channel coefficients */
        {
            real_T *pCtapsReal = (real_T *) ssGetInputPortSignal(S, INPORT_CHAN);

            for (i = 0; i < (chMem+1)*numSamp; i++)
            {
                pCtapsRe[i] = pCtapsReal[i];
                pCtapsIm[i] = 0.0;
            }
        }

        /* Expected Output Computation - required for
         * Branch Metric Computation
         */
        expOutputComp(alpha, chMem, pNumStates[0], numSamp, pConstRe, pConstIm,
                      pCtapsRe, pCtapsIm, pExpOutput);

    } /* end of if(hasChanPort) */

    /* Store preamble to the output vector using the values given
     * in the mask
     */
    thisBlockOutCplx = sigOutCplx ;
    outputPreamble(preamble, pLenPreamble[0], pConstRe, pConstIm,
                   thisBlockOutCplx);

    /* Loop for (frame length - preamble length) times */
    for(ib = 0; ib < blockSize; ++ib)
    {
        int_T    input, outOffset;
        int_T    inOffset = ib*numSamp;

        const real_T *postamble     = mxGetPr(POSTAMBLE_ARG(S));
        real_T       *pBMet         = (real_T *) ssGetDWork(S, BMETRIC);
        real_T       *pTempMet      = (real_T *) ssGetDWork(S, TEMP_METRIC);
        int_T        *pLenPostamble = (int_T *)  ssGetDWork(S, LEN_POSTAMBLE);

        creal_T  *sigIn = (creal_T *)  ssGetInputPortSignal(S, INPORT_DATA);
        creal_T  *thisBlockInCplx = sigIn  + inOffset + pLenPreamble[0]*numSamp;

        if(isContMode)
        {
            /* CONTINUOUS mode */
            outOffset        = ib + pLenPreamble[0];
        }
        else
        {   /* RESET EVERY FRAME mode
             *
             * Skip output indexing by (blockSize - tbLen) blocks.
             * Compute metrics and TB tables but do no decoding for
             * the blocks until the end of output buffer
             */
            outOffset         = ((ib - tbLen + pLenPreamble[0])%blockSize);
         }

        /* Branch Metric Computation */
        branchMetricComp(alpha, pNumStates[0], numSamp, pExpOutput,
                         pBMet, thisBlockInCplx);


        /* Add, Compare and Select - State metric update */
        minState = addCompareSelect(pNumStates[0], pTempMet, alpha,
                                    pBMet, pStateMet, pTbState,
                                    pTbInput, pTbPtr, pNxtStates, pOutputs);

        /* Initialize postamble state */
        minState = getPostambleState(pLenPostamble[0], ib, blockSize, alpha, chMem, postamble, minState);

        /* Traceback Decoding */
        input = tracebackDecoding(pTbPtr, minState, tbLen, pTbInput,
                                  pTbState, pNumStates[0]);


        /* Index into the constellation points array
         * and output constellation points
         */
        if((isContMode) || (ib >= tbLen ))
        {
            creal_T *thisBlockOutCplx = sigOutCplx + outOffset;
            thisBlockOutCplx[0].re = pConstRe[input];
            thisBlockOutCplx[0].im = pConstIm[input];
        }

    }   /* end of ib loop */


    /*
     * Capture starting minState and starting tbwork of the
     * last loop
     */
    minStateLastTb = minState;
    tbWorkLastTb   = (pTbPtr[0]!=0) ? pTbPtr[0]-1 : tbLen;

    /*
     * RESET EVERY FRAME mode :
     *
     * Fill the last tbLen output blocks using the same traceback
     * path, working our way back from the very last block.
     */
    if(!isContMode)
    {
        int_T indx1;

        for (indx1 = 0 ; indx1 < tbLen; indx1 ++)
        {
            creal_T *thisBlockOutCplx = 0;
            int_T input = pTbInput[minStateLastTb+\
                                  (tbWorkLastTb*pNumStates[0])];

            /* Extract the outputs from the traceback and
             * minState information stored
             */
            thisBlockOutCplx = sigOutCplx + pLenPreamble[0] + \
                               (blockSize -1 -indx1);
            thisBlockOutCplx[0].re = pConstRe[input];
            thisBlockOutCplx[0].im = pConstIm[input];

            /* Get the minState and traceback information for
             * previous time instant
             */
            minStateLastTb = pTbState[minStateLastTb + \
                                     (tbWorkLastTb*pNumStates[0])];
            tbWorkLastTb    = (tbWorkLastTb > 0) ? tbWorkLastTb-1: tbLen;
         }
    }

}  /*  end of mdlOutputs  */


/* Function: mdlTerminate =============================================== */
static void mdlTerminate(SimStruct *S)
{
}

/* Function: mdlSetInputPortFrameData =============================== */
#define MDL_SET_INPUT_PORT_FRAME_DATA
static void mdlSetInputPortFrameData(SimStruct *S,
                                     int_T     port,
                                     Frame_T   frameData)
{
       int_T       numInports, rstPortIdx ;

       const boolean_T hasChanPort = HAS_CHAN_PORT(S);
       const boolean_T hasRstPort  = HAS_RST_PORT(S);

       numInports = hasChanPort ? 2 : 1;
       numInports = hasRstPort  ? numInports+1 : numInports;
       rstPortIdx = numInports - 1;

       if( (hasRstPort) && (port == rstPortIdx) )
       {
           /* Set frameness for the reset input port */
           ssSetInputPortFrameData(S, port, frameData);
       }

}

/* Function: mdlSetInputPortDimensionInfo =============================== */
#ifdef MATLAB_MEX_FILE
#define MDL_SET_INPUT_PORT_DIMENSION_INFO
static void mdlSetInputPortDimensionInfo(SimStruct        *S,
                                         int_T             port,
                                         const DimsInfo_T *dimsInfo)

{
    /*
     * Only support column Frame-based signals [Nx1] where N >=1
     */
    int_T outCols, outRows;

    const int_T     numSamp    = (int_T) mxGetPr(SAMP_PER_SYM_ARG(S))[0];
    const int_T     tbLen      = (int_T) mxGetPr(TB_ARG(S))[0];
    const boolean_T isContMode = (boolean_T) IS_CONT_MODE(S);

    int8_T          chanPortIdx = 0;
    const boolean_T hasChanPort = HAS_CHAN_PORT(S);

    chanPortIdx = (int8_T) (hasChanPort ? chanPortIdx + 1 : chanPortIdx );

    /* Set the current port */
    if(!ssSetInputPortDimensionInfo(S, port, dimsInfo)) return;

    /* Check and set for the input port(s) and output port dimensions */
    {
        const boolean_T hasPreamble  = (boolean_T) ((int_T)(mxGetPr(EN_PREAMBLE_ARG(S))[0] == MLSE_ENABLE)\
                                  && (!isContMode));
        int_T lenPreamble  = (hasPreamble)?(int_T) mxGetNumberOfElements(PREAMBLE_ARG(S)):0;

        const int_T numDims = ssGetInputPortNumDimensions(S, port);
        const int_T inRows  = (numDims >= 1) ? dimsInfo->dims[0] : 0;
        const int_T inCols  = (numDims >= 2) ? dimsInfo->dims[1] : 0;

        if ( (numDims == 2) && (inCols != 1) )
        {
            THROW_ERROR(S, "Invalid dimensions are specified for the input "
                           "or output port(s). This block does not "
                           "support multi-channel signals.");
        }

        /* Set output port dimensions from the data input port */
        if(port == INPORT_DATA)
        {
            /* Integer number of symbols check */
            if (fmod(inRows, numSamp) != 0)
            {
                THROW_ERROR(S,"Invalid frame length specified for the data "
                              "input port. The input frame length must be an "
                              "integer multiple of the samples per symbol "
                              "parameter.");
            }

           /* -- Traceback depth error check -- */
            if ( (!isContMode) && (((tbLen + lenPreamble)*numSamp) > inRows) )
            {
               THROW_ERROR(S, "Invalid Traceback depth specified. The "
                              "sum of traceback depth parameter and "
                              "length of expected preamble parameter, "
                              "times the samples per symbol parameter "
                              "must be less than or equal to the "
                              "input frame length.");
            }

            /* To account for downsampling the upsampled signal */
            outRows = inRows/numSamp;
            outCols = inCols;

            if(ssGetOutputPortWidth(S, OUTPORT_DATA) == DYNAMICALLY_SIZED)
            {
                if(!ssSetOutputPortMatrixDimensions(S, OUTPORT_DATA,
                    outRows, outCols)) return;
            }
            else
            {
                if(ssGetOutputPortWidth(S, OUTPORT_DATA) != outRows)
                {
                    THROW_ERROR(S, "Invalid dimensions are specified for the "
                                   "input or output port(s).");
                }
            }
        } /* end if(port == INPORT_DATA) */

        /* Check the channel input port dimension */
        if((hasChanPort) && (port == chanPortIdx))
        {
            if (fmod(inRows, numSamp) != 0)
            {
                THROW_ERROR(S,"Invalid frame length specified for the channel "
                              "input port. The input frame length must be an "
                              "integer multiple of the samples per symbol "
                              "parameter.");
            }
        } /* end if((hasChanPort) && (port == chanPortIdx)) */
    }
} /* end of mdlSetInputPortDimensionInfo */

/* Function: mdlSetOutputPortDimensionInfo ============================== */
#define MDL_SET_OUTPUT_PORT_DIMENSION_INFO
static void mdlSetOutputPortDimensionInfo(SimStruct        *S,
                                          int_T            port,
                                          const DimsInfo_T *dimsInfo)
{

    int_T inCols, inRows;
    const int_T  numSamp   = (int_T) mxGetPr(SAMP_PER_SYM_ARG(S))[0];

    /* Set the output port */
    if(!ssSetOutputPortDimensionInfo(S, port, dimsInfo)) return;

    /* Check for output and set the input port dimensions */
    {
        const int_T  numDims = ssGetOutputPortNumDimensions(S, OUTPORT_DATA);
        const int_T  outRows = (numDims >= 1) ? dimsInfo->dims[0] : 0;
        const int_T  outCols = (numDims >= 2) ? dimsInfo->dims[1] : 0;

        if ( (numDims == 2) && (outCols != 1) )
        {
             THROW_ERROR(S, "Invalid dimensions are specified for the input "
                            "or output port(s). This block does not support "
                            "multi-channel signals.");
        }

        /* Setting the data input port dimensions from the output port */
        inCols = outCols;
        inRows = outRows*numSamp;

        if(ssGetInputPortWidth(S, INPORT_DATA) == DYNAMICALLY_SIZED)
        {
            if(!ssSetInputPortMatrixDimensions(S, INPORT_DATA, inRows, inCols))
            return;
        }
        else
        {
            if(ssGetInputPortWidth(S, INPORT_DATA) != inRows)
            {
                THROW_ERROR(S,"Invalid dimensions are specified for the input "
                              "or output port(s).");
            }
        }
    }
} /* end of mdlSetOutputPortDimensionInfo */


/* Function: mdlSetDefaultPortDimensionInfo ============================= */
#define MDL_SET_DEFAULT_PORT_DIMENSION_INFO
static void mdlSetDefaultPortDimensionInfo(SimStruct *S)
{
    /* Initialize a dynamically-dimensioned acceptable DimsInfo_T */
    DECL_AND_INIT_DIMSINFO(dInfo);
    int_T dims_out[2] = {1,1};
    dInfo.width       = 1;
    dInfo.numDims     = 2;
    dInfo.dims        = dims_out;

    /* Call the output port dimension function */
    if(ssGetOutputPortWidth(S, OUTPORT_DATA) == DYNAMICALLY_SIZED)
    {
        mdlSetOutputPortDimensionInfo(S, OUTPORT_DATA, &dInfo);
    }
} /* end of mdlSetDefaultPortDimensionInfo */
#endif

#ifdef  MATLAB_MEX_FILE
#include "simulink.c"
#else
#include "cg_sfun.h"
#endif
