/*
 * Copyright 1996-2004 The MathWorks, Inc.
 * $Revision: 1.18.4.4 $ $Date: 2004/02/09 06:37:59 $
 */

#define S_FUNCTION_LEVEL 2
#define S_FUNCTION_NAME scomcpmdemod

#include "comm_defs.h"
#include "scomcpmdemod.h"

/* memory management macro  */
#define CallocSFcnCacheNew(S, SFcnCache) (ssSetUserData(S, calloc(1,sizeof(SFcnCache))))


#define FreeSFcnCacheNew(S, SFcnCache) \
{                                   \
    free(ssGetUserData(S));       \
    ssSetUserData(S, NULL);         \
}


#ifdef MATLAB_MEX_FILE
#define MDL_CHECK_PARAMETERS

static void mdlCheckParameters(SimStruct *S) {

    const int_T     numIFArg    = mxGetNumberOfElements(SAMPLES_PER_SYMBOL_ARG);
    const int_T     numFiltArg  = mxGetNumberOfElements(FILT_ARG);
    const boolean_T runTime     = (boolean_T)(ssGetSimMode(S) != SS_SIMMODE_SIZES_CALL_ONLY);

    /* --- M                                             */
    /*     Integer scalar, greater than zero, power of 2 */
	if (OK_TO_CHECK_VAR(S, M_ARG)) {
	    if (!mxIsEmpty(M_ARG)) {

		    int_T nbits   = 0;
		    const int_T M = (int_T)mxGetPr(M_ARG)[0];

		    if ( (!IS_FLINT_GE(M_ARG, 2)) ||
		         (frexp((real_T)M, &nbits) != 0.5) ||
		          mxIsComplex(M_ARG) ||
		         (mxIsInf(mxGetPr(M_ARG)[0])) ) {
			    THROW_ERROR(S, "M-ary number must be a positive real integer scalar value which is a non-zero power of two.");
            }
        } else {
			THROW_ERROR(S, "M-ary number must be a positive real integer scalar value which is a non-zero power of two.");
        }
    }

    /* --- Input type */
	if (!IS_FLINT_IN_RANGE(INPUT_TYPE_ARG,1,2)) {
		THROW_ERROR(S,"Input type is outside of expected range.");
	}

    /* --- Mapping type */
	if (!IS_FLINT_IN_RANGE(MAPPING_TYPE_ARG,1,2)) {
		THROW_ERROR(S,"Mapping type is outside of expected range.");
	}

    /* --- Modulation index     */
    /*     Real scalar, >= zero */
    if (OK_TO_CHECK_VAR(S, MOD_IDX_ARG)) {
        if (!mxIsEmpty(MOD_IDX_ARG)) {
            if (!IS_SCALAR_DOUBLE_GE(MOD_IDX_ARG, 0.0) ||
                mxIsComplex(MOD_IDX_ARG) ||
                mxIsInf(mxGetPr(MOD_IDX_ARG)[0]) ) {
		        THROW_ERROR(S,"Modulation index must be a real non-negative scalar.");
            }
        } else {
		    THROW_ERROR(S,"Modulation index must be a real non-negative scalar.");
        }
    }

    /* --- Frequency pulse shape */
	if (!IS_FLINT_IN_RANGE(PULSE_SHAPE_ARG,1, NUM_FREQ_PULSE)) {
		THROW_ERROR(S,"Frequency pulse is outside of expected range.");
	}

    /* --- If the mode is Spectral Raised cosine (LSRC) then check the main lobe pulse length and the roll off parameter */
    /* --- Main lobe pulse length is an integer scalar, greater than zero */
    /* --- Roll off is a real scalar between 0 and 1 inclusive */  
	
    if ( (((int_T)mxGetPr(PULSE_SHAPE_ARG)[0]) - 1) == LSRC ) {
        if (OK_TO_CHECK_VAR(S, MAIN_LOBE_PULSE_LENGTH_ARG)) {
            if (!mxIsEmpty(MAIN_LOBE_PULSE_LENGTH_ARG)) {
                if (!IS_FLINT_GE(MAIN_LOBE_PULSE_LENGTH_ARG, 1) ||
                     mxIsComplex(MAIN_LOBE_PULSE_LENGTH_ARG) ||
                     mxIsInf(mxGetPr(MAIN_LOBE_PULSE_LENGTH_ARG)[0]) ) {
		             THROW_ERROR(S,"Spectral Raised Cosine main lobe pulse length must be a positive real integer scalar.");
		        }
		    } else {
		    THROW_ERROR(S,"Spectral Raised Cosine main lobe pulse length must be a positive real integer scalar.");
            }
        }        
        if (OK_TO_CHECK_VAR(S, ROLL_OFF_ARG)) {
            if (!mxIsEmpty(ROLL_OFF_ARG)) {
                if ( !IS_SCALAR_DOUBLE(ROLL_OFF_ARG) ||
                    mxIsComplex(ROLL_OFF_ARG) ||
                    !IS_SCALAR_DOUBLE_GE(ROLL_OFF_ARG, 0.0) ||
                    IS_SCALAR_DOUBLE_GREATER_THAN(ROLL_OFF_ARG, 1.0)
                  ) {
    		        THROW_ERROR(S,"Spectral Raised Cosine roll off must be a real scalar between 0 and 1 inclusive.");
                }
            } else {
                THROW_ERROR(S,"Spectral Raised Cosine roll off must be a real scalar between 0 and 1 inclusive.");
            }
        }
    }

    /* --- If the mode is Gaussian (GMSK) then check the BT parameter */
    if ( (((int_T)mxGetPr(PULSE_SHAPE_ARG)[0]) - 1) == GMSK ) {
        if (OK_TO_CHECK_VAR(S, BT_ARG)) {
            if (!mxIsEmpty(BT_ARG)) {
                if ( !IS_SCALAR_DOUBLE(BT_ARG) ||
                    mxIsComplex(BT_ARG) ||
                    !IS_SCALAR_DOUBLE_GE(BT_ARG, 0.0) ||
                    mxIsInf(mxGetPr(BT_ARG)[0]) )
                {
    		        THROW_ERROR(S,"Gaussian BT product must be a real positive scalar.");
                }
            } else {
    	        THROW_ERROR(S,"Gaussian BT product must be a real positive scalar.");
            }
        }
    }

    /* --- Pulse length                      */
    /*     Integer scalar, greater than zero */
    if (OK_TO_CHECK_VAR(S, PULSE_LENGTH_ARG)) {
        if(!mxIsEmpty(PULSE_LENGTH_ARG)) {

            if(!IS_FLINT_GE(PULSE_LENGTH_ARG, 1) ||
                mxIsComplex(PULSE_LENGTH_ARG) ||
                mxIsInf(mxGetPr(PULSE_LENGTH_ARG)[0]) ) {
		        THROW_ERROR(S,"Pulse Length must be a positive real integer scalar.");
            }
        } else {
            THROW_ERROR(S,"Pulse Length must be a positive real integer scalar.");
        }

    }

    /* --- Phase offset    */
    /*     Real scalar, not equal +/- Inf */
    if (OK_TO_CHECK_VAR(S, PHASE_OFFSET_ARG)) {
        if (!mxIsEmpty(PHASE_OFFSET_ARG)) {
            if (!IS_SCALAR_DOUBLE(PHASE_OFFSET_ARG) ||
                mxIsComplex(PHASE_OFFSET_ARG) ||
                mxIsInf(mxGetPr(PHASE_OFFSET_ARG)[0]) ) {
                THROW_ERROR(S,"Phase Offset must be a real scalar.");
            }
        } else {
           THROW_ERROR(S,"Phase Offset must be a real scalar.");
        }
    }

    /* --- Samples per symbol    */
    /*     Integer scalar, greater than zero */
    if (OK_TO_CHECK_VAR(S, SAMPLES_PER_SYMBOL_ARG)) {
        if (!mxIsEmpty(SAMPLES_PER_SYMBOL_ARG)) {
            if (!IS_FLINT_GE(SAMPLES_PER_SYMBOL_ARG, 1) ||
                mxIsComplex(SAMPLES_PER_SYMBOL_ARG) ||
                mxIsInf(mxGetPr(SAMPLES_PER_SYMBOL_ARG)[0]) ) {
		        THROW_ERROR(S,"Samples per Symbol must be a positive real integer scalar.");
            }
        } else {
		    THROW_ERROR(S,"Samples per Symbol must be a positive real integer scalar.");
        }
    }

    /* Check filter: */
    if (runTime || (numFiltArg >= 1 && numIFArg == 1)) {
        if ( mxIsEmpty(FILT_ARG) || ( mxGetN(FILT_ARG) != (*mxGetPr(SAMPLES_PER_SYMBOL_ARG)) ) ) {
            THROW_ERROR(S, "Pulse shaping filter must be a polyphase matrix with the number of "
	                 "columns equal to the number of samples per symbol.");
        }

        if ( numFiltArg <= ( (int_T) *mxGetPr(SAMPLES_PER_SYMBOL_ARG) ) ) {
            THROW_ERROR(S, "For proper operation, the number of filter coefficients "
                         "should be greater than the number of samples per symbol. "
                         "(The interpolation order is (filter length)/(samples per symbol) - 1).");
        }
    }

    /* Check output buffer initial conditions */
    if (OK_TO_CHECK_VAR(S, OUTBUF_INITCOND_ARG)) {
        if (!mxIsEmpty(OUTBUF_INITCOND_ARG)) {
            if (!mxIsNumeric(OUTBUF_INITCOND_ARG) || mxIsSparse(OUTBUF_INITCOND_ARG)) {
                THROW_ERROR(S,"Output buffer initial conditions must be numeric.");
            }
        } else {
            THROW_ERROR(S,"Output buffer initial conditions must be numeric.");
        }
    }

    /* --- Prehistory                      */
    /*     Integer scalar or vector (length = pulse length-1), greater than zero */
    if (    OK_TO_CHECK_VAR(S, INITIAL_FILTER_DATA_ARG) && OK_TO_CHECK_VAR(S, PULSE_LENGTH_ARG)) {

        if (!mxIsEmpty(INITIAL_FILTER_DATA_ARG) && !mxIsEmpty(PULSE_LENGTH_ARG)) {

            if ( !(IS_SCALAR(INITIAL_FILTER_DATA_ARG) || IS_VECTOR(INITIAL_FILTER_DATA_ARG)) ||
                  ((mxGetNumberOfElements(INITIAL_FILTER_DATA_ARG) > 1) && (mxGetNumberOfElements(INITIAL_FILTER_DATA_ARG) != (int_T)mxGetPr(PULSE_LENGTH_ARG)[0]-1)) ||
                  mxIsComplex(INITIAL_FILTER_DATA_ARG)) {
                    THROW_ERROR(S,"Prehistory must be a real integer scalar or vector.");
            } else {

                /* --- Check that the value(s) entered in the initial data field are valid    */
                /*     M may be used, as if it were wrong, this point in the code would not   */
                /*     have been reached                                                      */
                const int_T   numInitData = mxGetNumberOfElements(INITIAL_FILTER_DATA_ARG);
    	        const int_T   M = (int_T)mxGetPr(M_ARG)[0];
                const real_T *initialFilterData= (real_T *)mxGetPr(INITIAL_FILTER_DATA_ARG);
                int_T k;
                for (k=0; k < numInitData; k++) {
                    int_T symVal;

                    if(!IS_IDX_FLINT(INITIAL_FILTER_DATA_ARG,k)    ||
                        mxIsInf(mxGetPr(INITIAL_FILTER_DATA_ARG)[k]) ) {

                        THROW_ERROR(S,"Prehistory must be a real integer scalar or vector.");
                    }

                    symVal = (int_T)initialFilterData[k];

                    if( ((M - symVal - 1) % 2 != 0) || (fabs(symVal) > M-1)) {
                        THROW_ERROR(S, "Prehistory must be in the range +/- (M-2i-1), i=0,1, ..., (M/2)-1.");
                    }

                }

            }
        } else {
            THROW_ERROR(S,"Prehistory must be a real integer scalar or vector.");
        }
    }/* End of if(OK_TO_CHECK_VAR(S, INITIAL_FILTER_DATA_ARG)) */


    /* --- Traceback length */
    if (OK_TO_CHECK_VAR(S, TRACEBACK_LENGTH_ARG) ) {
        if (!mxIsEmpty(TRACEBACK_LENGTH_ARG)) {
            if (!IS_FLINT_GE(TRACEBACK_LENGTH_ARG, 0) ||
                mxIsComplex(TRACEBACK_LENGTH_ARG) ||
                mxIsInf(mxGetPr(TRACEBACK_LENGTH_ARG)[0]) ) {
		        THROW_ERROR(S,"Traceback length must be a positive real integer scalar.");
            }
        } else {
            THROW_ERROR(S,"Traceback length must be a positive real integer scalar.");
        }
    }

    /* --- Mod index numerator and denominator */
    if (OK_TO_CHECK_VAR(S, MOD_IDX_M_ARG)) {
        if (!mxIsEmpty(MOD_IDX_M_ARG)) {
            if (!IS_FLINT_GE(MOD_IDX_M_ARG, 1) ||
                mxIsComplex(MOD_IDX_M_ARG) ||
                mxIsInf(mxGetPr(MOD_IDX_M_ARG)[0]) ) {

                THROW_ERROR(S,"Modulation index numerator must be a positive real integer scalar.");
            }
        } else {
            THROW_ERROR(S,"Modulation index numerator must be a positive real integer scalar.");
        }
    }

    if (OK_TO_CHECK_VAR(S, MOD_IDX_P_ARG)) {
        if (!mxIsEmpty(MOD_IDX_P_ARG)) {
            if (!IS_FLINT_GE(MOD_IDX_P_ARG, 1) ||
                mxIsComplex(MOD_IDX_P_ARG) ||
                mxIsInf(mxGetPr(MOD_IDX_P_ARG)[0]) ) {
		        THROW_ERROR(S,"The Modulation index denominator must be a positive real integer scalar.");
            }
        } else {
            THROW_ERROR(S,"Modulation index denominator must be a positive real integer scalar.");
        }
    }
}
#endif

static void mdlInitializeSizes(SimStruct *S)
{
    int_T i;
    ssSetNumSFcnParams(S, NUM_ARGS);

#if defined(MATLAB_MEX_FILE)
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) return;
    mdlCheckParameters(S);
    if (ssGetErrorStatus(S) != NULL) return;
#endif

    /* Set parameters to be non-tunable */
    for (i = 0; i < NUM_ARGS; i++)
        ssSetSFcnParamTunable(S, i, 0);

    ssSetNumSampleTimes(S, PORT_BASED_SAMPLE_TIMES);

    if (!ssSetNumInputPorts(         S, NUM_INPORTS)) return;
    if (!ssSetInputPortDimensionInfo(S, INPORT, DYNAMIC_DIMENSION)) return;
    ssSetInputPortFrameData(         S, INPORT, FRAME_INHERITED);
    ssSetInputPortComplexSignal(     S, INPORT, COMPLEX_YES);
    ssSetInputPortSampleTime(        S, INPORT, INHERITED_SAMPLE_TIME);
    ssSetInputPortDirectFeedThrough( S, INPORT, 1);
    ssSetInputPortReusable(          S, INPORT, 0);
/*    ssSetInputPortOverWritable(      S, INPORT, 0); */
    ssSetInputPortRequiredContiguous(S, INPORT, 1);

    if (!ssSetNumOutputPorts(         S, NUM_OUTPORTS)) return;
    if (!ssSetOutputPortDimensionInfo(S, OUTPORT, DYNAMIC_DIMENSION)) return;
    ssSetOutputPortFrameData(         S, OUTPORT, FRAME_INHERITED);
    ssSetOutputPortComplexSignal(     S, OUTPORT, COMPLEX_NO);
    ssSetOutputPortSampleTime(        S, OUTPORT, INHERITED_SAMPLE_TIME);

    if(!ssSetNumDWork(S, DYNAMICALLY_SIZED)) return;
    ssSetNumPWork(    S, NUM_PWORKS);

    ssSetOptions(S, SS_OPTION_CALL_TERMINATE_ON_EXIT);
}


#define MDL_START
static void mdlStart (SimStruct *S)
{

    /* --- Create the parameter structure and store in user data */
    CallocSFcnCacheNew(S, userData_T);

	{
        userData_T   *userData          = ssGetUserData(S);
	const int_T   frameBased        = ssGetInputPortFrameData(S, INPORT);
        const int_T   inWidth           = ssGetInputPortWidth(S, INPORT);
        const int_T   outWidth          = ssGetOutputPortWidth(S, OUTPORT);
        const int_T   inputType         = (int_T) *mxGetPr(INPUT_TYPE_ARG);
        const int_T   M                 = (int_T) *mxGetPr(M_ARG);
        const int_T   samplesPerSymbol  = (int_T) *mxGetPr(SAMPLES_PER_SYMBOL_ARG);

        const int_T   pulseLength       = (int_T) *mxGetPr(PULSE_LENGTH_ARG);

        const real_T *preHistoryArg     = mxGetPr(INITIAL_FILTER_DATA_ARG);
        const int_T   preHistoryArgLen  = (int_T)mxGetNumberOfElements(INITIAL_FILTER_DATA_ARG);
        real_T       *preHistoryVector  = NULL;
        int_T         preHistoryLength  = 0;

        const real_T  initialPhase		= (real_T) *mxGetPr(PHASE_OFFSET_ARG);

        const real_T *filterPtr         = mxGetPr(FILT_ARG);
        const int_T   filterLength      = (int_T)mxGetNumberOfElements(FILT_ARG);
        const int_T   modIdxM           = (int_T) *mxGetPr(MOD_IDX_M_ARG);
        const int_T   modIdxP           = (int_T) *mxGetPr(MOD_IDX_P_ARG);

        const int_T   tbLen             = (int_T) *mxGetPr(TRACEBACK_LENGTH_ARG);
        const int_T   initSize          = (frameBased) ? (tbLen) : (tbLen+1);

        buff_T       *inputBuff, *outputBuff;   /* Buffer objects */
        decoder_T    *decoderObj;               /* Decoder object */

        real_T       *initCondPtr       = NULL;
        int_T         initIdx;
        int_T         startingState = 0;
        real_T       *tempOutputSymbols = NULL;

        phaseOffset_T *phaseOffsets = NULL;

        stateStruct_T *stateObj = NULL;

        int_T numBits = 1;
        int_T numOutSymbols = outWidth;

        if (inputType == BINARY_INPUT) {
            frexp((real_T)M, &numBits); /* Determine the no. of bits per symbol */
            numBits -= 1;               /* Actual no. of bits per symbol */
            numOutSymbols /= numBits;
        }

        /* initial conditions allocation */
        initCondPtr       = (real_T *)calloc(MAX(initSize,1), sizeof(real_T));
        if(initCondPtr == NULL) {
            THROW_ERROR(S, "Failed to allocate memory for initial conditions.");
        }

        /* temporary symbols allocation */
        if(inputType == BINARY_INPUT){
            tempOutputSymbols = (real_T *)calloc(numOutSymbols, sizeof(real_T));
            if(tempOutputSymbols == NULL) {
                free(initCondPtr);
                THROW_ERROR(S, "Failed to allocate memory for temporary output symbols.");
            }
        }

        /* --- Expand prehistory argument if it is a scalar */
        if((preHistoryArgLen == 1) && (pulseLength > 1)) {
            int idx;
            preHistoryVector = calloc(pulseLength-1, sizeof(real_T));
            if(NULL == preHistoryVector)
            {
                free(initCondPtr);
                free(tempOutputSymbols);
                THROW_ERROR(S, "Cannot expand prehistory vector.");
            }

            /* --- Copy the data from the prehistory argument to the prehistory vector */
            for(idx = 0; idx < pulseLength-1; idx++) {
                preHistoryVector[idx] = *preHistoryArg;
            }
            /* preHistoryLength is now the length of the expanded scalar (L-1) */
            preHistoryLength = idx;
        }
        else
        {
            /* assign the prehistory vector to the argument */
            preHistoryVector = (real_T *)preHistoryArg;
            preHistoryLength = preHistoryArgLen;
        }

        /* --- Create the trellis structure */
        phaseOffsets = createPhaseOffsets(S,
                                          M,
                                          pulseLength,
                                          samplesPerSymbol,
                                          filterPtr,
                                          filterLength,
                                          preHistoryVector,
                                          initialPhase);

		if(NULL == phaseOffsets)
		{
			THROW_ERROR(S, "Decoder phase offsets not properly computed.");
		}

        stateObj = createPhaseTrellis(S,
                                      M,
                                      pulseLength,
                                      modIdxM,
                                      modIdxP,
                                      samplesPerSymbol,
                                      filterPtr,
                                      filterLength,
                                      phaseOffsets);
		if(NULL == stateObj)
		{
            free(phaseOffsets->phase);
            free(phaseOffsets);
            free(preHistoryVector);
			THROW_ERROR(S, "Decoder phase trellis not properly computed.");
		}

        /* phase offsets are only used in the createPhaseTrellis routine, so free memory */
        if(NULL!=phaseOffsets->phase){
			free(phaseOffsets->phase);
		}
        if(NULL!=phaseOffsets){
			free(phaseOffsets);
		}

        if(pulseLength>1){
            base2dec(preHistoryVector,              /* Input vector        */
                M,                                  /* Input base          */
                pulseLength-1,                      /* Input ELEMENT size  */
                1,                                  /* Input length        */
                REAL_T_VEC,                         /* Input type          */
                &startingState,                     /* Output data         */
                INT_T_VEC,                          /* Output type         */
                1);                                 /* Map to symbol values*/
        }

        decoderObj = createDecoderObject(S, stateObj, tbLen, startingState, SCALING_ON);

        /* --- Create the initial conditions due to the traceback delay */
        for (initIdx=0;  initIdx<initSize; initIdx++) {
            initCondPtr[initIdx] = (real_T)OUTPUT_DURING_TRACEBACK;
        }

        /* --- Create the buffers */
        inputBuff  = createBuffer(S,      inWidth, samplesPerSymbol, sizeof(creal_T),        0,        NULL);
        outputBuff = createBuffer(S, MAX(tbLen,1),    numOutSymbols,  sizeof(real_T), initSize, initCondPtr);

        /* --- create userData */
        userData->decoderObj        = decoderObj;
        userData->inputBuff         = inputBuff;
        userData->outputBuff        = outputBuff;
        userData->tempOutputSymbols = tempOutputSymbols;

        /* --- Free temporary memory */
		if(NULL!=initCondPtr){
			free(initCondPtr);
		}
        if((preHistoryArgLen == 1) && (pulseLength > 1) && (NULL!=preHistoryVector)){
            free(preHistoryVector);
        }
    }
}

static void mdlInitializeSampleTimes(SimStruct *S)
{
    /* Check port sample times: */
    const real_T Tsi = ssGetInputPortSampleTime(S, INPORT);
    const real_T Tso = ssGetOutputPortSampleTime(S, OUTPORT);

    if ((Tsi == INHERITED_SAMPLE_TIME)  ||
        (Tso == INHERITED_SAMPLE_TIME)   ) {
        THROW_ERROR(S, "Sample time propagation failed for CPM modulator.");
    }
    if ((Tsi == CONTINUOUS_SAMPLE_TIME) ||
        (Tso == CONTINUOUS_SAMPLE_TIME)  ) {
        THROW_ERROR(S, "Continuous sample times not allowed for CPM modulator.");
    }
    
    ssSetModelReferenceSampleTimeInheritanceRule(S, USE_DEFAULT_FOR_DISCRETE_INHERITANCE);
}


#define MDL_INITIALIZE_CONDITIONS
static void mdlInitializeConditions(SimStruct *S)
{
}


static void mdlOutputs(SimStruct *S, int_T tid)
{
    userData_T     *userData      = ssGetUserData(S);
    const int_T     inportTid     = ssGetInputPortSampleTimeIndex(S, INPORT);
    const int_T     outportTid    = ssGetOutputPortSampleTimeIndex(S, OUTPORT);
    const boolean_T inportHit     = (const boolean_T) ssIsSampleHit(S, inportTid, tid);
    const boolean_T outportHit    = (const boolean_T) ssIsSampleHit(S, outportTid, tid);

    creal_T        *inputPtr      = (creal_T *)ssGetInputPortRealSignal(S, INPORT);
    real_T         *outputPtr     = (real_T *)ssGetOutputPortSignal(S, OUTPORT);

    const int_T     inWidth       = ssGetInputPortWidth(S, INPORT);
    const int_T     outWidth      = ssGetOutputPortWidth(S, OUTPORT);
    const int_T     inputType     = (int_T) *mxGetPr(INPUT_TYPE_ARG);
    const int_T     mappingType   = (int_T) *mxGetPr(MAPPING_TYPE_ARG);
    const int_T     M             = (int_T) *mxGetPr(M_ARG);

    static char* emsg = NULL;   /* Ensure that the error message is reset */

    int_T numBits = 1;
    int_T numOutSymbols = outWidth;

    if (inputType == BINARY_INPUT) {
        frexp((real_T)M, &numBits); /* Determine the no. of bits per symbol */
        numBits -= 1;               /* Actual no. of bits per symbol */
        numOutSymbols /= numBits;
    }

    if (inportHit) {
        writeBuffer(userData->inputBuff, (void *)inputPtr, inWidth);

        /* --- Add in the error checking, which was in decodeSymbols.  */
        /*     Currently, this will not throw an error.                */ 

        emsg = decodeSymbols( userData->decoderObj,
                              userData->inputBuff,
                              userData->outputBuff,
                              DECODE_ENTIRE_BUFFER);

        if(emsg != NULL) {
            THROW_ERROR(S,emsg);
        }
    }
    if (outportHit) {

        if (inputType == BINARY_INPUT) {
            readBuffer(userData->outputBuff, (void *)userData->tempOutputSymbols, numOutSymbols);

            dec2base(  (void *)userData->tempOutputSymbols, /* Decimal data        */
                        M,                                  /* Input base          */
                        numOutSymbols,                      /* Input length        */
                        REAL_T_VEC,                         /* Input type          */
                        1,                                  /* Demap input         */
                        (mappingType == GRAY_CODE),         /* Demap from Gray code*/
                        (void *)outputPtr,                  /* Output vector       */
                        2,                                  /* Output base         */
                        numBits,                            /* Output ELEMENT size */
                        REAL_T_VEC,                         /* Output type         */
                        0);                                 /* Map to symbol values*/

        } else {
            readBuffer(userData->outputBuff, (void *)outputPtr, numOutSymbols);
        }

    }

}

static void mdlTerminate(SimStruct *S)
{
    userData_T *userData = NULL;
    userData = ssGetUserData(S);
    if(userData != NULL)
    {
        /* --- Free buffers and structures */

        if (userData->inputBuff != NULL) {
            freeBuffer(userData->inputBuff);
	    }
        if (userData->outputBuff != NULL) {
            freeBuffer(userData->outputBuff);
	    }

        if (userData->decoderObj != NULL) {
		    freeDecoderObject(userData->decoderObj);
	    }

        if (userData->tempOutputSymbols != NULL) {
            free(userData->tempOutputSymbols);
        }
        FreeSFcnCacheNew(S, userData_T);
    }

}

/*  P = samplesPerSymbol
 *
 * Forward Propagation
 *
 *   Input dimension | Frame | Output mode | Output            | To/Ti | Comment
 *  -----------------|-------|-------------|-------------------|-------|----------------------
 *      1            | No    | Int         | 1                 |  P/1  | Sample based
 *      [1x1]        | No    | Int         | [1x1]             |  P/1  | Sample based
 *                   |       |             |                   |       |
 *      1            | No    | Bit         | log2(M)           |  P/1  | Sample based
 *      [1x1]        | No    | Bit         | log2(M)           |  P/1  | Sample based
 *                   |       |             |                   |       |
 *      [Nx1]        | Yes   | Int         | [N/P x 1]         |  1    | Frame based
 *                   |       |             |                   |       | N/P must be an integer
 *                   |       |             |                   |       |
 *      [Nx1]        | Yes   | Bit         | [log2(M)*N/P x 1] |  1    | Frame based
 *                   |       |             |                   |       | N/P must be an integer
 *
 * Back Propagation
 *
 *  Output dimension  | Frame | Output mode | Input             | To/Ti | Comment
 *  ------------------|-------|-------------|-------------------|-------|----------------------
 *  1                 | No    | Int         | 1                 |  P/1  | Sample based
 *  [1x1]             | No    | Int         | [1x1]             |  P/1  | Sample based
 *                    |       |             |                   |       |
 *  log2(M)           | No    | Bit         | 1                 |  P/1  | Sample based
 *                    |       |             |                   |       |
 *  [N/P x 1]         | Yes   | Int         | [Nx1]             |  1    | Frame based
 *                    |       |             |                   |       | N/P must be an integer
 *                    |       |             |                   |       |
 *  [log2(M)*N/P x 1] | Yes   | Bit         | [Nx1]             |  1    | Frame based
 *                    |       |             |                   |       | N/P must be an integer
 */

#ifdef MATLAB_MEX_FILE
#define MDL_SET_INPUT_PORT_FRAME_DATA
static void mdlSetInputPortFrameData(SimStruct *S,
                                      int_T port,
                                      Frame_T frameData)
{
    ssSetInputPortFrameData(S, port, frameData);
    if (port == INPORT) ssSetOutputPortFrameData(S, OUTPORT, frameData);
}

#define MDL_SET_INPUT_PORT_DIMENSION_INFO
static void mdlSetInputPortDimensionInfo(SimStruct *S,
                                         int_T port,
                                         const DimsInfo_T *dimsInfo)
{
    const int_T M                = (int_T) *mxGetPr(M_ARG);
    const int_T inputType        = (int_T) *mxGetPr(INPUT_TYPE_ARG);
    const int_T samplesPerSymbol = (int_T) *mxGetPr(SAMPLES_PER_SYMBOL_ARG);

    const int_T inRows           = dimsInfo->dims[0];
    const int_T inCols           = dimsInfo->dims[1];
    const int_T inWidth          = dimsInfo->width;

    int_T numBits = 1;
    if (inputType == BINARY_INPUT) {
        frexp((real_T)M, &numBits); /* Determine the no. of bits per symbol */
        numBits -= 1;               /* Actual no. of bits per symbol */
    }

    if (!ssSetInputPortDimensionInfo(S, port, dimsInfo)) return;

    if( isInputFrameDataOn(S, port)) {
        int_T outRows;

        if( !(isInputColVector(S, port) || (isInputScalar(S, port) && isInput2D(S,port)) )) {
            THROW_ERROR(S, "In frame-based mode, inputs must be scalars or column vectors.");
        }

        if(inRows % samplesPerSymbol != 0) {
            THROW_ERROR(S,"The input length must be a multiple of the number of samples per symbol.");
        }

        outRows = (inRows*numBits)/samplesPerSymbol;

        if (!ssSetOutputPortMatrixDimensions(S, OUTPORT, outRows, inCols)) return;

    } else {
        int_T outWidth;

        if( !isInputScalar(S, port) ) {
            THROW_ERROR(S, "In sample-based mode, the input must be a scalar.");
        }

        outWidth = inWidth*numBits;

        /* --- Set the output port*/
        if (inputType == BINARY_INPUT) {
            ssSetOutputPortVectorDimension(S, OUTPORT, outWidth);
        } else {
            if (isInput2D(S,port)) {
                if (!ssSetOutputPortMatrixDimensions(S, OUTPORT, outWidth, 1)) return;
            } else {
                ssSetOutputPortVectorDimension(S, OUTPORT, outWidth);
            }
        }
    }
}

#define MDL_SET_OUTPUT_PORT_DIMENSION_INFO
static void mdlSetOutputPortDimensionInfo(SimStruct *S,
                                         int_T port,
                                         const DimsInfo_T *dimsInfo)
{

    const int_T M                = (int_T) *mxGetPr(M_ARG);
    const int_T inputType        = (int_T) *mxGetPr(INPUT_TYPE_ARG);
    const int_T samplesPerSymbol = (int_T) *mxGetPr(SAMPLES_PER_SYMBOL_ARG);

    const int_T outRows          = dimsInfo->dims[0];
    const int_T outCols          = dimsInfo->dims[1];
    const int_T outWidth         = dimsInfo->width;

    int_T numBits = 1;
    if (inputType == BINARY_INPUT) {
        frexp((real_T)M, &numBits); /* Determine the no. of bits per symbol */
        numBits -= 1;               /* Actual no. of bits per symbol */
    }

    if (!ssSetOutputPortDimensionInfo(S, port, dimsInfo)) return;

    if( isOutputFrameDataOn(S, port)) {
        int_T inRows;

        if( !(isOutputColVector(S, port) || (isOutputScalar(S, port) && isOutput2D(S,port)) )) {
            THROW_ERROR(S, "In frame-based mode, outputs must be scalars or column vectors.");
        }

        if(inputType == BINARY_INPUT) {
            if(outRows % numBits != 0) {
                THROW_ERROR(S,"In frame-based bit output mode, the output width must be a multiple of the number of bits per symbol.");
            }
        }

        inRows = (outRows*samplesPerSymbol)/numBits;

        if (!ssSetInputPortMatrixDimensions(S, INPORT, inRows, outCols)) return;

    } else {
        int_T inWidth;

        if ( !(isOutputScalar(S, port) || isOutputUnoriented(S, port)) ) {
            THROW_ERROR(S, "In sample-based mode, outputs must be scalar or 1-D.");
        }

        if (outWidth != numBits) {
			if (inputType == BINARY_INPUT) {
				THROW_ERROR(S, "In sample-based bit output mode, the output must be a vector whose width equals the number of bits per symbol.");
			} else {
				THROW_ERROR(S, "In sample-based integer output mode, the output must be a scalar.");
			}
        }

        inWidth = outWidth/numBits;

        if (isOutput2D(S,port)) {
            if (!ssSetInputPortMatrixDimensions(S, INPORT, 1, inWidth)) return;
        } else {
            ssSetInputPortVectorDimension(S, INPORT, inWidth);
        }
    }
}



#define MDL_SET_INPUT_PORT_SAMPLE_TIME
static void mdlSetInputPortSampleTime(SimStruct *S,
                                      int_T     port,
                                      real_T    sampleTime,
                                      real_T    offsetTime)
{
    ssSetInputPortSampleTime(S, port, sampleTime);
    ssSetInputPortOffsetTime(S, port, offsetTime);

    if(isInputFrameDataOn(S, port) ) {
        ssSetOutputPortSampleTime(S, OUTPORT, sampleTime);
        ssSetOutputPortOffsetTime(S, OUTPORT, offsetTime);
    } else {
        const int_T samplesPerSymbol = (int_T)mxGetPr(SAMPLES_PER_SYMBOL_ARG)[0];

        ssSetOutputPortSampleTime(S, OUTPORT, sampleTime*samplesPerSymbol);
        ssSetOutputPortOffsetTime(S, OUTPORT, offsetTime);

    } /* End of if(isInputFrameDataOn(S, port)) */
}


#define MDL_SET_OUTPUT_PORT_SAMPLE_TIME
static void mdlSetOutputPortSampleTime(SimStruct *S,
                                       int_T     port,
                                       real_T    sampleTime,
                                       real_T    offsetTime)
{
    ssSetOutputPortSampleTime(S, port, sampleTime);
    ssSetOutputPortOffsetTime(S, port, offsetTime);

    if(isOutputFrameDataOn(S, port) ) {
        ssSetInputPortSampleTime(S, INPORT, sampleTime);
        ssSetInputPortOffsetTime(S, INPORT, offsetTime);
    } else {
        const int_T samplesPerSymbol = (int_T)mxGetPr(SAMPLES_PER_SYMBOL_ARG)[0];

        ssSetInputPortSampleTime(S, INPORT, sampleTime/samplesPerSymbol);
        ssSetInputPortOffsetTime(S, INPORT, offsetTime);

    } /* End of if(isInputFrameDataOn(S, port)) */
}

#endif

#ifdef MATLAB_MEX_FILE
#define MDL_SET_WORK_WIDTHS
static void mdlSetWorkWidths(SimStruct *S)
{
	if(!ssSetNumDWork(S, NUM_DWORKS)) return;
}
#endif

#ifdef  MATLAB_MEX_FILE    
#include "simulink.c"      
#else
#include "cg_sfun.h"       
#endif

/* -- EOF -- */
