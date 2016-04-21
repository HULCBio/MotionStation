/*
 * Copyright 1996-2004 The MathWorks, Inc.
 * $Revision: 1.20.4.4 $ $Date: 2004/02/09 06:38:00 $
 */

#define S_FUNCTION_LEVEL 2
#define S_FUNCTION_NAME scomcpmmod

#include "comm_defs.h"

#ifdef COMMBLKS_SIM_SFCN
#include "dsp_ismultirate_sim.h"
#include "dsp_mtrx_sim.h"
#else
#include "dsp_ismultirate.c"
#include "dsp_mtrx.c"
#endif

#include "scomcpmmod.h"

/*  memory management macro  */
#define CallocSFcnCacheNew(S, SFcnCache) (ssSetUserData(S, calloc(1,sizeof(SFcnCache))))


#define FreeSFcnCacheNew(S, SFcnCache) \
{                                   \
    free(ssGetUserData(S));       \
    ssSetUserData(S, NULL);         \
}


/* --- The following defines how the block works in an enabled subsystem
*
*      When true, the block will re-initialize its internal states as if the
*      user selected initial data had been passed through
*
* NOTE: When included in a trigered sub-system, re-initialize only occurs
*      on the initial trigger.
*/
#define RESET_FILTER_ON_ENABLE true

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
                    mxIsInf(mxGetPr(BT_ARG)[0])
                  ) {
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
    ssSetInputPortComplexSignal(     S, INPORT, COMPLEX_INHERITED);
    ssSetInputPortSampleTime(        S, INPORT, INHERITED_SAMPLE_TIME);
    ssSetInputPortDirectFeedThrough( S, INPORT, 1);
    ssSetInputPortReusable(          S, INPORT, 0);
/*    ssSetInputPortOverWritable(      S, INPORT, 0); */
    ssSetInputPortRequiredContiguous(S, INPORT, 1);

    if (!ssSetNumOutputPorts(         S, NUM_OUTPORTS)) return;
    if (!ssSetOutputPortDimensionInfo(S, OUTPORT, DYNAMIC_DIMENSION)) return;
    ssSetOutputPortFrameData(         S, OUTPORT, FRAME_INHERITED);
    ssSetOutputPortComplexSignal(     S, OUTPORT, COMPLEX_YES);
    ssSetOutputPortSampleTime(        S, OUTPORT, INHERITED_SAMPLE_TIME);

    if(!ssSetNumDWork(S, DYNAMICALLY_SIZED)) return;
    ssSetNumPWork(    S, NUM_PWORKS);

/*    ssSetOptions(     S, SS_OPTION_EXCEPTION_FREE_CODE); */
    ssSetOptions(S, SS_OPTION_CALL_TERMINATE_ON_EXIT);
}


#define MDL_START
static void mdlStart (SimStruct *S)
{
    /* --- Create the parameter structure and store in user data */
    CallocSFcnCacheNew(S, block_op_data_T);
    {
        block_op_data_T *blockData = ssGetUserData(S);
        populateUserData(S,&(blockData->BD),&(blockData->BP));
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
	if(ssIsFirstInitCond(S) || RESET_FILTER_ON_ENABLE) {
        block_op_data_T *blockData = ssGetUserData(S);

        initFilter(&(blockData->BD),&(blockData->BP));
        initCPMMod(&(blockData->BD),&(blockData->BP));
    }
}


static void mdlOutputs(SimStruct *S, int_T tid)
{
    const int_T inportTid      = ssGetInputPortSampleTimeIndex(S, INPORT);
    const int_T outportTid     = ssGetOutputPortSampleTimeIndex(S, OUTPORT);
    const boolean_T inportHit  = ssIsSampleHit(S, inportTid, tid);
    const boolean_T outportHit = ssIsSampleHit(S, outportTid, tid);

    real_T  *inputPtr  = (real_T *)ssGetInputPortRealSignal(S, INPORT);
    creal_T	*outputPtr = (creal_T *)ssGetOutputPortSignal(S, OUTPORT);

    const int_T  inputType   = (int_T) *mxGetPr(INPUT_TYPE_ARG);
    const int_T  mappingType = (int_T) *mxGetPr(MAPPING_TYPE_ARG);

    const real_T *binPtr = (inputType == BINARY_INPUT ? inputPtr : NULL);
    real_T       *symPtr = (inputType == BINARY_INPUT ? (real_T *)ssGetDWork(S, BIN2INT_VECTOR) : inputPtr);

    /* --- Get the block configuration data */
    block_op_data_T *blockData = ssGetUserData(S);
    block_dims_T   *BD = &(blockData->BD);
    block_params_T *BP = &(blockData->BP);

    static char* emsg;
    emsg = NULL;    /* Ensure that the error message is reset */

    if(inportHit) {
        /* --- Get the parameter structure*/
        const int_T  M = (int_T) *mxGetPr(M_ARG);

              int_T symVecLen = BD->inElem;
        /* --- Check for the range of the inputs */
        {
            int_T i;
            for (i = 0; i < symVecLen; i++)
            {
                if (inputType == BINARY_INPUT)
                {
                    int_T       numBits = 0;
                    int_T       bitIdx;
                    real_T      bitVal;
                    int32_T     symVal = 0;
        
                    frexp((real_T)M, &numBits); /* Determine the no. of bits per symbol */
                    numBits -= 1;               /* Actual no. of bits per symbol */
        
                    for(bitIdx=0; bitIdx < numBits ; bitIdx++) {
                        bitVal = (real_T)binPtr[numBits*i+bitIdx];  /* Index from MSB first */
                        if(bitVal != 0 && bitVal != 1) {
                            THROW_ERROR(S, "In bit input mode, the input values must be scalars or vectors containing only 1 or 0.");
                        }
                    }
                } else if (inputType==INTEGER_INPUT) 
                {
                    /* --- Integer inputs must be +/- (M-2i-1), i=0,1, ..., M/2 -1 */
                    /*     So, i = (M-x-1)/2 must be an integer                    */
                    /*     So, (M-x-1) must be even                                */
                    if( ((M - (int_T)symPtr[i] - 1) % 2 != 0) || (abs((int_T)symPtr[i]) > M-1) ) {
                        THROW_ERROR(S, "For integer inputs, the input values must be in the range +/- (M-2i-1), i=0,1, ..., (M/2)-1.");
                    }
                }
            }  /* End of for (i = 0; i < symVecLen; i++) */
        }

        /* --- then Convert only */
        emsg = convertAndCheck(binPtr, symPtr , BD->inElem, M, inputType, mappingType);

        if(emsg != NULL) { 
            THROW_ERROR(S, emsg);
        } 

    }

    if(inportHit || outportHit) {
        modulate(BD, BP, inportHit, outportHit, (inportHit ? symPtr : NULL) );
    }
    if(outportHit) {
        integrate(BD, outputPtr);
    }

}

static void mdlTerminate(SimStruct *S)
{
    FreeSFcnCacheNew(S, block_op_data_T);
}

/* Forward propagation
 *
 *   Input dimension | Input mode | Frame | Comment              | Output         | To/Ti
 *  -----------------|------------|-------|----------------------|----------------|-------
 *      1            | Int        | No    | Sample based         | 1              |  1/P
 *      [1x1]        | Int        | No    | Sample based         | [1x1]          |  1/P
 *                   |            |       |                      |                |
 *      1            | Bit        | No    | Sample based         | 1              |  1/P
 *      [1x1]        | Bit        | No    | Sample based         | [1x1]          |  1/P
 *      log2(M)      | Bit        | No    | Sample based         | 1              |  1/P
 *      [1xlog2(M)]  | Bit        | No    | Sample based         | [1x1]          |  1/P
 *      [log2(M)x1]  | Bit        | No    | Sample based         | [1x1]          |  1/P
 *                   |            |       |                      |                |
 *      [1x1]        | Int        | Yes   | Frame based          | [Px1]          |  1
 *      [Nx1]        | Int        | Yes   | Frame based          | [NPx1]         |  1
 *                   |            |       |                      |                |
 *      [1x1]        | Bit        | Yes   | Frame based          | [Px1]          |  1
 *      [Nx1]        | Bit        | Yes   | Frame based          | [P*sym(N,M)x1] |  1
 *                   |            |       | N % log2(M) == 0     |                |
 * Back propagation
 *
 *  Output dimension | Input mode | Frame | Comment              | Input          | To/Ti
 *  -----------------|------------|-------|----------------------|----------------|-------
 *    1              | Int        | No    | Sample based         | 1              |  1/P
 *    [1x1]          | Int        | No    | Sample based         | [1x1]          |  1/P
 *                   |            |       |                      |                |
 *    1              | Bit        | No    | Sample based         | log2(M)        |  1/P
 *    [1x1]          | Bit        | No    | Sample based         | log2(M)        |  1/P
 *                   |            |       |                      |                |
 *    [Px1]          | Int        | Yes   | Frame based          | [1x1]          |  1
 *    [NPx1]         | Int        | Yes   | Frame based          | [Nx1]          |  1
 *                   |            |       |                      |                |
 *    [Px1]          | Bit        | Yes   | Frame based          | [1x1]          |  1
 *    [P*sym(N,M)x1] | Bit        | Yes   | Frame based          | [Nx1]          |  1
 *
 *
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

        if(inputType == BINARY_INPUT) {
            if(inRows % numBits != 0) {
                THROW_ERROR(S,"In frame-based bit input mode, the input length must be a multiple of the number of bits per symbol.");
            }
        }

        outRows = (inRows*samplesPerSymbol)/numBits;

        if (!ssSetOutputPortMatrixDimensions(S, OUTPORT, outRows, inCols)) return;

    } else {

        if( isInputFullMatrix(S, port) ) {
            THROW_ERROR(S, "In sample-based mode, inputs may not be full matrices.");
        }

        if( inWidth != numBits) {
			if(inputType == BINARY_INPUT) {
				THROW_ERROR(S, "In sample-based bit input mode, the input must be a vector whose width equals the number of bits per symbol.");
			} else {
				THROW_ERROR(S, "In sample-based integer input mode, the input must be a scalar.");
			}
        }

		/* --- Set the output port - the output is a scalar */
		if(isInput2D(S,port)) {
			if (!ssSetOutputPortMatrixDimensions(S, OUTPORT, 1, 1)) return;
		} else {
			ssSetOutputPortVectorDimension(S, OUTPORT, 1);
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

    if ( isOutputFrameDataOn(S, port)) {
        int_T inRows;

        if ( !(isOutputColVector(S, port) || (isOutputScalar(S, port) && isOutput2D(S,port)) )) {
            THROW_ERROR(S, "In frame-based mode, outputs must be scalars or column vectors.");
        }

        if (outRows % samplesPerSymbol != 0) {
            THROW_ERROR(S,"The output length must be a multiple of the number of samples per symbol.");
        }

        inRows = (outRows*numBits)/samplesPerSymbol;

        if (!ssSetInputPortMatrixDimensions(S, INPORT, inRows, outCols)) return;

    } else {

        if( outWidth != 1)  {
            THROW_ERROR(S, "In sample-based mode, the output must be a scalar.");
        }

        /* --- Set the input port*/
        if (inputType == BINARY_INPUT) {
            /* --- Binary inputs are always 1-D */
            int_T inWidth = outWidth*numBits;
            ssSetInputPortVectorDimension(S, INPORT, inWidth);
        } else {
            /* --- Binary inputs are always scalar with the same number of dimensions as the output */
            if (isOutput2D(S,port)) {
                if (!ssSetInputPortMatrixDimensions(S, INPORT, 1, 1)) return;
            } else {
                ssSetInputPortVectorDimension(S, INPORT, 1);
            }
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

        ssSetOutputPortSampleTime(S, OUTPORT, sampleTime/samplesPerSymbol);
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

        ssSetInputPortSampleTime(S, INPORT, sampleTime*samplesPerSymbol);
        ssSetInputPortOffsetTime(S, INPORT, offsetTime);

    } /* End of if(isInputFrameDataOn(S, port)) */
}
#endif

#ifdef MATLAB_MEX_FILE
#define MDL_SET_WORK_WIDTHS
static void mdlSetWorkWidths(SimStruct *S)
{

    /* --- The buffers are allocated based upon the number of symbols that */
    /*     will be filtered, i.e. not just on the width                    */
    const int_T inputType   = (int_T) *mxGetPr(INPUT_TYPE_ARG);
    const int_T mappingType = (int_T) *mxGetPr(MAPPING_TYPE_ARG);
    const int_T M           = (int_T) *mxGetPr(M_ARG);

    /* Matrix info */
    const int_T    *inDims  = ssGetInputPortDimensions(S, INPORT);
    const int_T     inRows  = inDims[0];
    const int_T     inCols  = inDims[1];
    const int_T     inWidth = inRows * inCols;

    /* Frame info */
    const int_T     inFramebased    = ssGetInputPortFrameData(S,INPORT);

    /* Non frame-based multiple channels are not supported */
    const int_T     numChans        = inFramebased ? inCols : 1;

    const real_T    iFactorf        = *mxGetPr(SAMPLES_PER_SYMBOL_ARG);
    const int_T     order           = mxGetNumberOfElements(FILT_ARG) - 1;
    const boolean_T inputComplex    = (boolean_T) (ssGetInputPortComplexSignal(S, INPORT) == COMPLEX_YES);
    const boolean_T filtComplex     = (boolean_T) mxIsComplex(FILT_ARG);
    const int_T     numICs          = mxGetNumberOfElements(OUTBUF_INITCOND_ARG);

    int_T numBits         = 1;
    int_T samplesPerFrame = 0;
    int_T outputBufLen    = 0;

    if (inputType == BINARY_INPUT) {
        frexp((real_T)M, &numBits); /* Determine the no. of bits per symbol */
        numBits -= 1;               /* Actual no. of bits per symbol */
    }
    /* inWidth is used when non-frame based as only a row or column is permitted */
    samplesPerFrame = (inFramebased ? inRows : inWidth)/numBits;

    outputBufLen    = samplesPerFrame * numChans * ((int_T)iFactorf)*2; /* Note: double-buffered */

    /* Check number of Output Buffer ICs */
    if ( (numICs != 0) && (numICs != 1) && (numICs != outputBufLen) ) {
        /* Initial conditions must be either length zero, one, or */
        /* equal to the length of the output buffer. Otherwise we */
        /* cannot understand how to fill the output buffer!!!     */
        THROW_ERROR(S,"Invalid number of output buffer initial conditions.");
    }

    if(!ssSetNumDWork(S, (inputType == BINARY_INPUT) ? NUM_DWORKS : NUM_DWORKS-1)) return;

    /* Memory Index (accumulated FIR sum) */
    ssSetDWorkWidth(        S, TapDelayIndex,     1);
    ssSetDWorkDataType(     S, TapDelayIndex,     SS_INT32);
    ssSetDWorkName(         S, TapDelayIndex,     "TapDelayIndex");

    /* Output Buffer */
    ssSetDWorkWidth(        S, OutputBuff, outputBufLen);
    ssSetDWorkDataType(     S, OutputBuff, SS_DOUBLE);
    ssSetDWorkName(         S, OutputBuff, "OutBuff");
    ssSetDWorkComplexSignal(S, OutputBuff, ((inputComplex || filtComplex) ? COMPLEX_YES : COMPLEX_NO) );

    /* Output Buffer Write Index (sample location to write coming from the interpolation output) */
    ssSetDWorkWidth(        S, WriteIdx,   1);
    ssSetDWorkDataType(     S, WriteIdx,   SS_INT32);
    ssSetDWorkName(         S, WriteIdx,   "WriteIdx");

    /* Output Buffer Read Index (sample location to read going to the output port) */
    ssSetDWorkWidth(        S, ReadIdx,    1);
    ssSetDWorkDataType(     S, ReadIdx,    SS_INT32);
    ssSetDWorkName(         S, ReadIdx,    "ReadIdx");

    /*
     * Discrete State (FIR filter):
     *
     * Since there are "virtual" zeros inserted into the input sequence,
     * we only need to store ceil(order / iFactor) actual input samples.
     *
     * numChans > 0, order > 1, iFactorf > 0
     *
     */

    ssSetDWorkWidth(        S, TapDelayLineBuff, (int_T)(numChans*ceil(order/iFactorf)));
    ssSetDWorkDataType(     S, TapDelayLineBuff, SS_DOUBLE);
    ssSetDWorkName(         S, TapDelayLineBuff, "TapDelayBuff");
    ssSetDWorkComplexSignal(S, TapDelayLineBuff, (inputComplex ? COMPLEX_YES : COMPLEX_NO) );
    ssSetDWorkUsedAsDState( S, TapDelayLineBuff, 1);

    ssSetDWorkWidth(        S, PHASE_STATE, numChans);
    ssSetDWorkDataType(     S, PHASE_STATE, SS_DOUBLE);
    ssSetDWorkName(         S, PHASE_STATE, "phaseState");
    ssSetDWorkComplexSignal(S, PHASE_STATE, COMPLEX_NO );

    ssSetDWorkWidth(        S, PHASE_VECTOR, outputBufLen);
    ssSetDWorkDataType(     S, PHASE_VECTOR, SS_DOUBLE);
    ssSetDWorkName(         S, PHASE_VECTOR, "phaseVector");
    ssSetDWorkComplexSignal(S, PHASE_VECTOR, COMPLEX_NO );

    if(inputType == BINARY_INPUT) {
        ssSetDWorkWidth(        S, BIN2INT_VECTOR, samplesPerFrame * numChans);
        ssSetDWorkDataType(     S, BIN2INT_VECTOR, SS_DOUBLE);
        ssSetDWorkName(         S, BIN2INT_VECTOR, "bin2intVector");
        ssSetDWorkComplexSignal(S, BIN2INT_VECTOR, COMPLEX_NO );
    }

}
#endif


/* ******************************************************************** */
/* Function: populateUserData                                           */
/* Purpose:  Populate the user data structure with the parameters that  */
/*           would have to be computed at each time step.               */
/*           This is primarily because the block is capable of dealing  */
/*           with non-frame vectors as frames and the fact that one of  */
/*           the input modes is bit requiring that the number of symbols*/
/*           in the input be computed each time.                        */
/*                                                                      */
/* Passed in: SimStruct      *S                                         */
/*            block_dims_T   *BD                                        */
/*            block_params_T *BP                                        */
/*                                                                      */
/* Passed out: void                                                     */
/* ******************************************************************** */
void populateUserData(SimStruct *S, block_dims_T *P, block_params_T *BP)
{
    const int_T  *inDims   = ssGetInputPortDimensions(S, INPORT);
    const int_T   inRows   = inDims[0];
    const int_T   inCols   = inDims[1];
    const int_T   inWidth  = ssGetInputPortWidth(S, INPORT);

    const int_T   *outDims = ssGetOutputPortDimensions(S, OUTPORT);
    const int_T   outRows  = outDims[0];
    const int_T   outCols  = outDims[1];
    const int_T   outWidth = ssGetOutputPortWidth(S, OUTPORT);

    const int_T   inputPortFramebased = ssGetInputPortFrameData(S,INPORT);
    const int_T   inputPortOriented   = isInputOriented(S,INPORT);
    const int_T   outputPortOriented  = isOutputOriented(S,OUTPORT);

    const int_T   inputType         = (int_T) *mxGetPr(INPUT_TYPE_ARG);
    const int_T   mappingType       = (int_T) *mxGetPr(MAPPING_TYPE_ARG);
    const int_T   M                 = (int_T) *mxGetPr(M_ARG);
    const int_T   samplesPerSymbol  = (int_T) *mxGetPr(SAMPLES_PER_SYMBOL_ARG);

    const boolean_T isMultiRateBlk = isBlockMultiRate(S,INPORT,OUTPORT);
    const boolean_T isMultiTasking = isModelMultiTasking(S);
    int_T  *tapIdx = (int_T *)  ssGetDWork(S, TapDelayIndex);
    int_T  *rdIdx  = (int_T *)  ssGetDWork(S, ReadIdx);
    int_T  *wrIdx  = (int_T *)  ssGetDWork(S, WriteIdx);
    real_T *outBuf = (real_T *) ssGetDWork(S, OutputBuff);
    real_T *tapDelayLineBuff = (real_T *)ssGetDWork(S, TapDelayLineBuff);

    int_T paramsSet = 0;

    int_T numBits = 1;
    if (inputType == BINARY_INPUT) {
        frexp((real_T)M, &numBits); /* Determine the no. of bits per symbol */
        numBits -= 1;               /* Actual no. of bits per symbol */
    }

    /* --- Set any common parameters */
    P->numBits = numBits;
    P->isMultiRateBlk = isMultiRateBlk;
    P->isMultiTasking = isMultiTasking;

    P->tapDelayLineBuff = tapDelayLineBuff;
    P->tapIdx = tapIdx;
    P->rdIdx  = rdIdx;
    P->wrIdx  = wrIdx;
    P->outBuf = outBuf;

    P->phaseState  = (real_T *)ssGetDWork(S, PHASE_STATE);
    P->phaseVector = (real_T *)ssGetDWork(S, PHASE_VECTOR);

    /* --- There are some specific case which have different configurations */
    /*     Check for these first.                                           */

    /* Input:     Oriented scalar                       */
    /* Output:    Unoriented vector                     */
    /* Mode:      Integer                               */
    /* Frame bit: Off                                   */
    /* Frame based - ambiguity in output dimensions.    */

    if(    (isInputScalar(S,INPORT) && isInputOriented(S, INPORT))
        && (isOutputUnoriented(S,OUTPORT) && isOutputVector(S,OUTPORT))
        && (inputType == INTEGER_INPUT)
        && (!inputPortFramebased)
      )
    {
        P->inFramebased = 1;

        P->inFrameSize  = 1;
        P->numChans     = 1;

        P->inElem       = 1;

        P->outElem      = outRows*outCols;
        P->outFrameSize = P->outElem;

        paramsSet       = 1;
    }

    /* Input:     Oriented scalar                       */
    /* Output:    Unoriented vector                     */
    /* Mode:      Bit                                   */
    /* Frame bit: Off                                   */
    /* Frame based - ambiguity in output dimensions.    */
    if(    (isInputScalar(S,INPORT) && isInputOriented(S, INPORT))
        && (isOutputUnoriented(S,OUTPORT) && isOutputVector(S,OUTPORT))
        && (inputType == BINARY_INPUT)
        && (!inputPortFramebased)
      )
    {
        P->inFramebased = 1;

        P->inFrameSize  = 1;
        P->numChans     = 1;

        P->inElem       = 1;

        P->outElem      = outWidth;
        P->outFrameSize = P->outElem;

        paramsSet       = 1;
    }

    /* Input:     Unoriented vector, length = numBits   */
    /* Output:    Oriented scalar                       */
    /* Mode:      Bit                                   */
    /* Frame bit: Off                                   */
    /* Samples per symbol = 1                           */
    /* Frame based - ambiguity in input dimensions.     */
    if(    (isInputUnoriented(S,INPORT) && isInputVector(S,INPORT) && (inRows*inCols == numBits))
        && (isOutputScalar(S,OUTPORT) && isOutputOriented(S, OUTPORT))
        && (inputType == BINARY_INPUT)
        && (!inputPortFramebased)
        && (samplesPerSymbol == 1)
      )
    {
        P->inFramebased = 1;

        P->inFrameSize  = 1;
        P->numChans     = 1;

        P->inElem       = 1;

        P->outElem      = 1;
        P->outFrameSize = 1;

        paramsSet       = 1;
    }

    /* --- General cases */
    if(!paramsSet) {
        /* values set assuming multiple channel operation
         * even though the rest of the sfun does not support it */
        if(inputPortFramebased) {
            /* frame based mode inputs - accept [1x1] (in Integer mode),
             * and [Nx1] where N = X * log2(M) and X, N are integers
             * (in Binary Mode)
             */
            P->inFramebased = 1;

            P->inFrameSize  = inRows/numBits;
            P->numChans     = inCols;

            P->inElem       = P->inFrameSize*P->numChans;

            P->outElem      = outWidth;
            P->outFrameSize = P->outElem;
        } else {
            /* sample based mode inputs - accept 1, 1x1 (Integer mode),
             * and N, Nx1 or 1xN where N = X * log2(M) and X, N are
             * integers (in Binary Mode)
             */
            P->inFramebased = 0;

            P->inFrameSize  = inWidth/numBits;
            P->numChans     = 1;

            P->inElem       = P->inFrameSize;

            P->outElem      = outWidth;
            P->outFrameSize = P->outElem;

        }       /* End of if(inputPortFramebased) {} else {} */

    }           /* End of if(~paramsSet) {} else {} */


    /* --- Populate the parameter structure */

    BP->pulseLength       = (int_T) *mxGetPr(PULSE_LENGTH_ARG);
    BP->samplesPerSymbol  = samplesPerSymbol;

    BP->numInitData = mxGetNumberOfElements(INITIAL_FILTER_DATA_ARG);
    BP->initialFilterData = (real_T *)mxGetPr(INITIAL_FILTER_DATA_ARG);

    BP->bufferWidth = ssGetDWorkWidth(S, TapDelayLineBuff)/P->numChans;

    BP->numOffsets  = mxGetNumberOfElements(PHASE_OFFSET_ARG);

    BP->phaseOffset = (real_T *)mxGetPr(PHASE_OFFSET_ARG);

    BP->filterArg    = (real_T *)mxGetPr(FILT_ARG);
    BP->filterLength = (int_T)mxGetNumberOfElements(FILT_ARG);

    BP->initialPhaseSwitch = INITIAL_PHASE_AFTER_PREHISTORY;

}   /* End of populateUserData() */

#ifdef  MATLAB_MEX_FILE    
#include "simulink.c"      
#else
#include "cg_sfun.h"       
#endif

/* -- EOF -- */
