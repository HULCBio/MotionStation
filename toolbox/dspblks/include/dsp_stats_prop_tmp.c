/* dsp_stats_prop_tmp.c 
 *
 *  This files is used for the Frame and Dimension
 *  propagation in the DSP Blockset Statistices Library.
 *  It will be use by sdspstdvar2, sdspmean2, sdsprms2.
 *  
 *  Eventually this file will be replaced with dsp_stats_prop.c
 *  which is currently used for the Min and Max S-functions.
 *
 *   NOTE: The S-function must define IS_RUNNING_STAT(S)
 * 
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.11.4.4 $  $Date: 2004/04/12 23:11:35 $
 */

/* Min, Max, Variance, Std Dev, RMS, and Mean
 *
 * Sample-based  
 *    matrix -- operate down the columns
 *    column -- collapse to a scalar
 *    row    -- collapse to a scalar
 *    1-D    -- collapse to a scalar
 *
 * Frame-based
 *   matrix  -- operate down the columns (channels)
 *   col     -- collapse to scalar output
 *   row     -- row output
 *
 * Running Sample-based 
 *    output size == input size  
 *    Operation done over time 
 *    Treating samples as independent channels
 *
 * Running Frame-based
 *   output size == input size
 *   Operation done over time 
 *   Treating columns as channels
 */


#define MDL_SET_INPUT_PORT_FRAME_DATA
static void cppmdlSetInputPortFrameData(SimStruct *S, 
                                        int_T port,
                                        Frame_T frameData)
{
    ssSetInputPortFrameData(S, port, frameData);

    if (port!=INPORT_RESET) {
        /* Propagate data port frame status to all output ports: */
        int_T i = ssGetNumOutputPorts(S);
        while(i-->0) {
            if ((int_T)ssGetOutputPortFrameData(S, i) == FRAME_INHERITED) {
                ssSetOutputPortFrameData(S, i, frameData);
            }
        }
    }
}


#define MDL_SET_INPUT_PORT_DIMENSION_INFO
static void cppmdlSetInputPortDimensionInfo(SimStruct *S,
                                           int_T port,
                                           const DimsInfo_T *dimsInfo)
{
    if (!ssSetInputPortDimensionInfo(S, port, dimsInfo)) return;

    if (port == INPORT_RESET) {
        if (dimsInfo->width != 1) { /* Check that input is a scalar, 1- or 2-D */
            THROW_ERROR(S, "Reset port must be a scalar.");
        }
    } else {
        /* port == INPORT_DATA */
        int_T outportNum;

        for (outportNum = 0; outportNum < ssGetNumOutputPorts(S); outportNum++) {
            if (isOutputDynamicallySized(S, outportNum)) {

                /* Only the running stat has output dim = input dim
                 * All other modes have collapsed dimensionality
                 */
                if (IS_RUNNING_STAT(S)) {
                    /* running stat - output dims = input dims */

                    if (!ssSetOutputPortDimensionInfo(S, outportNum, dimsInfo)) return;

                } else {
                    /* outputs are dim-collapsed */

                    if (isInputUnoriented(S, INPORT_DATA)) {
                        /* Outports are 1-D scalar: */
                        if(!ssSetOutputPortVectorDimension(S, outportNum, 1)) return;
                    } else {
                        /* Outport dims = 1xN */
                        int_T nSamps, nChans;
                        getInportSampsAndChans(S, INPORT_DATA, &nSamps, &nChans);
                        if (!ssSetOutputPortMatrixDimensions(S, outportNum, 1, nChans)) return;
                    }
                }

            } else {
                /* Outport already set by backprop function - check settings: */
                if (IS_RUNNING_STAT(S)) {
                    /* running stat - output dims are supposed to be = input dims */
                    if (!areInportAndOutportSameDims(S, INPORT_DATA, outportNum)) {
                        THROW_ERROR(S, "Input port dimensions are not valid based "
                            "on the current output port dimensions.");
                    }
                } else {
                    /* outputs are supposed to be dim-collapsed */
                    if (!areInportAndOutportCollapsedDims(S, INPORT_DATA, outportNum)) {
                        THROW_ERROR(S, "Input port dimensions are not valid based "
                            "on the current output port dimensions.");
                    }
                }
            }
        } /* outportNum loop */
    }  /* inport conditional */
}


#define MDL_SET_OUTPUT_PORT_DIMENSION_INFO
static void cppmdlSetOutputPortDimensionInfo(SimStruct *S,
                                             int_T port,
                                             const DimsInfo_T *dimsInfo)
{
    if(!ssSetOutputPortDimensionInfo(S, port, dimsInfo)) return;
    /*
     * Set other outport dims:
     */
    if (ssGetNumOutputPorts(S) > 1) {
        /* VAL and IDX ports present; they always have the same dimensionality */
        int otherPort = 1 - port;
        if (isOutputDynamicallySized(S, otherPort)) {
            if (!ssSetOutputPortDimensionInfo(S, otherPort, dimsInfo)) return;
        }
    }
    /*
     * Set other inport dims:
     *
     * For cases where the output has been collapsed one dimension,
     *   we do not have sufficient information to set any input port dims.
     *
     * The only case where the output dims are the same as the input dims
     *   is when in running mode, non-frame based.  In that case, copy
     *   the dims to the inport.  No need to check the dims, since we should
     *   never find the situation where the inport was set but the outport
     *   was not (eg, we're here setting the outport dims, and checking against
     *   a known inport dim ... the outport would have been set by the forward
     *   prop function immediately.)
     */
    if (isInputFrameDataInherited(S, INPORT_DATA)) {
        THROW_ERROR(S, "Frame data should have been propagated prior to dimension data.");
    }
    if (!isInputFrameDataOn(S, INPORT_DATA) && IS_RUNNING_STAT(S)) {
        if (isInputDynamicallySized(S, INPORT_DATA)) {
            if (!ssSetInputPortDimensionInfo(S, INPORT_DATA, dimsInfo)) return;
        }
    }
}

#define MDL_SET_INPUT_PORT_DATA_TYPE
static void cppmdlSetInputPortDataType(SimStruct *S,
                                       int_T      portIndex,    
                                       DTypeId    inDataType)
{
    /* if portIndex is NOT the reset port, set all ports (except the reset) to
     * the input data type; else set only the reset port
     */
    if (portIndex != INPORT_RESET) { 
        const int_T fcn = GET_STAT_FCN(S);
        int_T i;

        /* Set all input ports except reset port */
        for (i=0; i<ssGetNumInputPorts(S); i++) {
            if (i != INPORT_RESET) ssSetInputPortDataType(S, i, inDataType);
        }
        if ((fcn == FCN_STD) || (fcn == FCN_RMS)) {
            ErrorIfInputIsNotFloat(S, portIndex);
        }

        /* Set all output ports */
        if ((fcn == FCN_STD) || (fcn == FCN_RMS)) {
            assignAllOutputPortDataTypes(S, inDataType);

        } else if ((fcn == FCN_MEAN) || (fcn == FCN_VAR)) {
            if ((inDataType == SS_DOUBLE) || (inDataType == SS_SINGLE)) {
                assignAllOutputPortDataTypes(S, inDataType);
            } else {
                // Fixed point
                ssSetInputPortDataType(S, portIndex, inDataType);
                ErrorIfInputIsBoolean( S, portIndex);
                if (!isInputPortSignedUnitSlopeZeroBiasFixpt(S, portIndex)) {
                    THROW_ERROR(S, "Fixed-point data types for this block must be signed, and must have power-of-two slope and zero bias.");
                }

                // Set output port data type (forward propagation)
                if (ssGetOutputPortDataType(S, OUTPORT_DATA) == DYNAMICALLY_TYPED)
                {
                    uint_T outputWordLen = 0;
                    int_T  outputFracLen = 0;

                    switch (outputMode(S)) {
                    case DT_MODE_SPECIFIED_BY_USER:
                        outputWordLen = outputWordLength(S);
                        outputFracLen = outputFracLength(S);
                        break;

                    case DT_MODE_SAME_AS_ACCUM:
                        initAccumAttributes(S, outputWordLen, outputFracLen);
                        break;

                    case DT_MODE_SAME_AS_PROD_OUTPUT:
                        initProdOutputAttributes(S, outputWordLen, outputFracLen);
                        break;

                    case DT_MODE_SAME_AS_INPUT:
                        outputWordLen = dspGetInputPortWordLength(S,INPORT_DATA);
                        outputFracLen = dspGetInputPortFracLength(S,INPORT_DATA);
                        break;

                    default:
                        THROW_ERROR(S, "Unable to resolve fixed-point output port data type.");
                    }

                    dspSetOutputPortFixpt(S, OUTPORT_DATA, outputWordLen, outputFracLen, SIGNED_YES);
                }
            }

        } else {
            /* Minimum or Maximum may have an Idx port which should be
             * uint32 (except for when input data port is double, in
             * that case the Idx output should also be double for
             * backward compatibility reasons only
             */
            const int_T run_arg         = (int_T)mxGetPr(RUN_ARG)[0];
            const int_T hasIndexOutport = (run_arg==0 || run_arg==3) ? 1 : 0;
            const DTypeId idxOutDataType = isInputDouble(S, 0) ?
                SS_DOUBLE : SS_UINT32;
            const DTypeId out0Type = ssGetOutputPortDataType(S, 0);
            const int_T hasValueOutport  = (run_arg < 3) ? 1 : 0;

            // Set/check output port 0
            if (out0Type == DYNAMICALLY_TYPED) {
                if (hasValueOutport) {
                    ssSetOutputPortDataType(S, 0, inDataType);
                }
                else {
                    ssSetOutputPortDataType(S, 0, idxOutDataType);
                }
            }
            else {
                if (hasValueOutport) {
                    if (out0Type != inDataType) {
                        THROW_ERROR(S, "Output value and input-data types must"
                                    " match.");
                    }
                }
                else {
                    if (out0Type != idxOutDataType) {
                        THROW_ERROR(S, "Idx output port data-type must be"
                                    " double for double precision input and"
                                    " uint32 for all other input types.");
                    }
                }
            }

            // Set/check output port 1, if it exists
            if (hasIndexOutport && hasValueOutport) {
                const DTypeId out1Type = ssGetOutputPortDataType(S, 1);
                if (out1Type == DYNAMICALLY_TYPED) {
                    ssSetOutputPortDataType(S, 1, idxOutDataType);
                }
                else {
                    if (out1Type != idxOutDataType) {
                        THROW_ERROR(S, "Idx output port data-type must be"
                                    " double for double precision input and"
                                    " uint32 for all other input types.");
                    }
                }
            }
        }
    } else {
        if (!ssSetInputPortDataType(S, portIndex, inDataType)) return;
        if (inDataType >= SS_NUM_BUILT_IN_DTYPE) {
            THROW_ERROR(S, "Reset port must have a built-in data type.");
        }
    }
}

#define MDL_SET_OUTPUT_PORT_DATA_TYPE
static void cppmdlSetOutputPortDataType(SimStruct *S,
                                       int_T       portIndex,    
                                       DTypeId     outDataType)
{
    const int_T fcn = GET_STAT_FCN(S);
    int_T i;

    if ((fcn == FCN_STD) || (fcn == FCN_RMS)) {
        /* Set all output ports */
        assignAllOutputPortDataTypes(S, outDataType);

        ErrorIfOutputIsNotFloat(S, portIndex);

        /* Set all input ports except reset port */
        for (i=0; i<ssGetNumInputPorts(S); i++) {
            if (i != INPORT_RESET) ssSetInputPortDataType(S, i, outDataType);
        }

    } else if ((fcn == FCN_MEAN) || (fcn == FCN_VAR)) {

        if ((outDataType == SS_DOUBLE) || (outDataType == SS_SINGLE)) {
            if (!checkAndSetAllPortsToDblOrSngl(S, outDataType)) return;
        }
        else {
            // Fixed-point
            ssSetOutputPortDataType(S, portIndex, outDataType);
            ErrorIfOutputIsBoolean( S, portIndex);
            if (!isOutputPortSignedUnitSlopeZeroBiasFixpt(S, portIndex)) {
                THROW_ERROR(S, "Fixed-point data types for this block must be signed, and must have power-of-two slope and zero bias.");
            }

            {
                const uint_T totalBitsActual = dspGetDataTypeWordLength(S, outDataType);
                const int_T  fracBitsActual  = dspGetDataTypeFracLength(S, outDataType);

                if (outputMode(S) == DT_MODE_SAME_AS_INPUT) {
                    // Back propagate to input
                    dspSetInputPortFixpt(S, INPORT_DATA, totalBitsActual, fracBitsActual, SIGNED_YES);
                } else {
                    // Data type is user-defined OR "Same as..."
                    // Check output port versus mask specifications here.
                    uint_T outputWordLenMask = 0;
                    int_T  outputFracLenMask = 0;

                    switch (outputMode(S)) {
                    case DT_MODE_SPECIFIED_BY_USER:
                        outputWordLenMask = outputWordLength(S);
                        outputWordLenMask = outputFracLength(S);
                        break;

                    case DT_MODE_SAME_AS_ACCUM:
                        initAccumAttributes(S, outputWordLenMask, outputFracLenMask);
                        break;

                    case DT_MODE_SAME_AS_PROD_OUTPUT:
                        initProdOutputAttributes(S, outputWordLenMask, outputFracLenMask);
                        break;

                    default:
                        THROW_ERROR(S, "Unable to resolve fixed-point output port data type.");
                    }

                    if ((outputWordLenMask != totalBitsActual) || (outputFracLenMask != fracBitsActual)) {
                        THROW_ERROR(S, "Back-propagated output port fixed-point data type attributes do not match specifications in block mask.");
                    }
                }
            }
        }

    } else {
        /* Minimum or Maximum may have an Idx port which should be
         * uint32 (except for when input data port is double, in
         * that case the Idx output should also be double for
         * backward compatibility reasons only
         */
        const int_T run_arg = (int_T)mxGetPr(RUN_ARG)[0];
        const int_T    hasValueOutport = (run_arg < 3) ? 1 : 0;
        const bool hasIndexOutportOnly =  (run_arg == 3);

        ssSetOutputPortDataType(S, portIndex, outDataType);

        if (portIndex == 0 && hasValueOutport) { // Backprop from value port
            for (i=0; i<ssGetNumInputPorts(S); i++) {
                if (i != INPORT_RESET) ssSetInputPortDataType(S, i, outDataType);
            }
            if (ssGetNumOutputPorts(S) > 1) { // index out port also
                const DTypeId idxOutDataType = (outDataType == SS_DOUBLE)?
                                                SS_DOUBLE :
                                                SS_UINT32;
                ssSetOutputPortDataType(S, 1, idxOutDataType);
            }
        }
        else { // this is index port
            if (outDataType != SS_UINT32 && outDataType != SS_DOUBLE) {
                THROW_ERROR(S, "Index (Idx) output port must be uint32 or double.");
            }
            if (outDataType == SS_DOUBLE) { // Can back prop from Idx in this case only
                if (hasValueOutport) {
                    ssSetOutputPortDataType(S, 0, SS_DOUBLE); // Set value port
                }
                /* Set all input ports except reset port */
                for (i=0; i<ssGetNumInputPorts(S); i++) {
                    if (i != INPORT_RESET) ssSetInputPortDataType(S, i, outDataType);
                }
            }
        }
    }
}

/* [EOF]  dsp_stats_prop_tmp.c */

