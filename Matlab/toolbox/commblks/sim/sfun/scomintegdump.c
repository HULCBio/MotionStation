/*
 * SCOMINTEGDUMP integrates a discrete input signal for a specified
 * number of samples. It can be configured to dump the integral
 * at the end of the integration period or output the integral
 * after every integration of a sample.
 *
 *   Copyright 1996-2003 The MathWorks, Inc.
 */
 
/* Handshake specfication for Integrate and dump blcok
 * Frame based             OutPort      InPort
 *          Frame      ==> Frame      = Frame;
 *          Complexity ==> Complex    = Complex
 *          SampleTime ==> Tfout      = Tfin;
 *  OutputMode : Dump
 *          Rows       ==> OutRows    = InRows/Integration period;
 *          Cols       ==> OutCols    = InCols;
 *  OutputMode : No dump
 *          Rows       ==> OutRows    = InRows;
 *          Cols       ==> OutCols    = InCols;
 *
 * Sample based
 *          Frame      ==> Sample     = Sample;
 *          Complexity ==> OutComplex = InComplex;
 *          Rows       ==> OutRows    = InRows;
 *          Cols       ==> OutCols    = InCols;
 *  OutputMode : Dump
 *          SampleTime ==> Tsout = Tsin * Integration period;
 *  OutputMode : NO dump
 *          SampleTime ==> Tsout = Tsin;
 *
 */


#define S_FUNCTION_NAME scomintegdump
#define S_FUNCTION_LEVEL 2

#include "scomintegdump.h"

/* Function: mdlCheckParameters ===============================================*/
#if defined(MATLAB_MEX_FILE)
#define MDL_CHECK_PARAMETERS
static void mdlCheckParameters(SimStruct *S)
{
    
    if(OK_TO_CHECK_VAR(S,INTEG_SAMPLES_ARG_PTR(S)))
    {
        real_T integPeriod  = mxGetPr(INTEG_SAMPLES_ARG_PTR(S))[0];;
        if( (!mxIsNumeric(INTEG_SAMPLES_ARG_PTR(S))) ||
            (mxIsComplex(INTEG_SAMPLES_ARG_PTR(S))) ||
            (!IS_SCALAR((INTEG_SAMPLES_ARG_PTR(S))) ||
            (integPeriod <= 1)) )
        {
            THROW_ERROR(S,"The integration period should be a positive real"
                            " scalar integer value greater than one.");
        }
        
        
        if((real_T)integPeriod != (int_T)integPeriod) 
        {
            THROW_ERROR(S, "The integration period should be a positive real"
                            " scalar integer value greater than one.");
        }

    }
    if(OK_TO_CHECK_VAR(S,OFFSET_SAMPLES_ARG_PTR(S)))
    {
        real_T offset;
        int_T elemCnt, numOffsetElements;
        if(IS_FULL_MATRIX(OFFSET_SAMPLES_ARG_PTR(S)))
        {
            THROW_ERROR(S,"Offset must be a scalar or a vector of size"
                            " equal to the number of input columns");
        }

        if((mxIsComplex(OFFSET_SAMPLES_ARG_PTR(S))))
        {
            THROW_ERROR(S," Offset must be a positive real integer value greater"
                            " than or equal to zero.");
        }

        numOffsetElements = mxGetNumberOfElements(OFFSET_SAMPLES_ARG_PTR(S));

        for (elemCnt = 0; elemCnt < numOffsetElements; elemCnt++)
        {
            offset = mxGetPr(OFFSET_SAMPLES_ARG_PTR(S))[elemCnt];

            if( (offset < 0) || ((real_T)offset != (int_T)offset) )
               
                THROW_ERROR(S," Offset must be a positive real integer value"
                               " greater than or equal to zero.");         
        }
       
    }
}
#endif

/* Function: mdlInitializeSizes ===============================================*/
static void mdlInitializeSizes(SimStruct *S)
{
    int_T arg;

    ssSetNumSFcnParams(S, NUM_ARGS);
    
    #if defined(MATLAB_MEX_FILE)
        if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) return;
        mdlCheckParameters(S);
        if (ssGetErrorStatus(S) != NULL) return;
    #endif

    ssSetNumSampleTimes(S, PORT_BASED_SAMPLE_TIMES);

    /* Input Port settings 
     */
    if (!ssSetNumInputPorts (           S, NUM_INPORTS)) return;
    if (!ssSetInputPortDimensionInfo(   S, INPORT, DYNAMIC_DIMENSION)) return;
    ssSetInputPortFrameData(            S, INPORT, FRAME_INHERITED);
    ssSetInputPortDirectFeedThrough(    S, INPORT, 1);
    ssSetInputPortComplexSignal(        S, INPORT, COMPLEX_INHERITED);
    ssSetInputPortReusable(		        S, INPORT, 0);
    ssSetInputPortRequiredContiguous(   S, INPORT, 1);
    ssSetInputPortSampleTime(           S, INPORT, INHERITED_SAMPLE_TIME);

    /* Output Port settings 
     */
    if (!(ssSetNumOutputPorts(          S, NUM_OUTPORTS))) return;
    if (!ssSetOutputPortDimensionInfo(  S, OUTPORT, DYNAMIC_DIMENSION)) return;
    ssSetOutputPortFrameData(           S, OUTPORT, FRAME_INHERITED);
    ssSetOutputPortComplexSignal(       S, OUTPORT, COMPLEX_INHERITED);
    ssSetOutputPortReusable(	        S, OUTPORT, 0);
    ssSetOutputPortSampleTime(          S, OUTPORT, INHERITED_SAMPLE_TIME);

    ssSetOptions( S, SS_OPTION_EXCEPTION_FREE_CODE);
    ssSetModelReferenceSampleTimeInheritanceRule(S, USE_DEFAULT_FOR_DISCRETE_INHERITANCE);
   
    for(arg = 0; arg < NUM_ARGS; arg++)
        ssSetSFcnParamTunable(S, arg, NOT_TUNABLE);

    if (!ssSetNumDWork( S, DYNAMICALLY_SIZED)) return;
}

#if defined(MATLAB_MEX_FILE) 
/* Corresponding #endif at the end of mdlSetOutputPortSampleTime()*/

#define MDL_SET_INPUT_PORT_FRAME_DATA
static void mdlSetInputPortFrameData(SimStruct *S,
                                      int_T portIdx,
                                      Frame_T frameData)
{    
    ssSetInputPortFrameData(S, portIdx, frameData);
      
    if(ssGetOutputPortFrameData(S, OUTPORT) == FRAME_INHERITED)
        ssSetOutputPortFrameData(S, OUTPORT, frameData);
    else if(ssGetOutputPortFrameData(S, OUTPORT) != frameData)
        THROW_ERROR(S, COMM_EMSG_INVALID_FRAME);
                      
}


#define MDL_SET_INPUT_PORT_DIMENSION_INFO
static void mdlSetInputPortDimensionInfo(SimStruct *S, int_T portIdx,
                                        const DimsInfo_T *inDimsInfo)
{
    int_T outCols, outRows;

    const boolean_T fb         = COMM_IS_INPORT_FRAME_BASED(S, INPORT);
    const boolean_T dumpOutput = IS_DUMP_OUTPUT;
    const int_T integPeriod    = INTEG_SAMPLES_ARG(S);
    
    const int_T     inCols     = inDimsInfo->dims[1];
    const int_T     inRows     = inDimsInfo->dims[0];
	
    /* Set input port dimensions
     */
    if(!ssSetInputPortDimensionInfo(S, portIdx, inDimsInfo)) return;

    /* Check the validity of the input port dimension
     */
    if( ssGetInputPortConnected(S,INPORT) )
    {
        if ((inDimsInfo->numDims != 1) && (inDimsInfo->numDims != 2))
            THROW_ERROR(S, COMM_EMSG_INVALID_DIMS);

        switch(fb)
        {
        case 0: /* Sample based */
            if(inDimsInfo->width != 1)
                THROW_ERROR(S, COMM_EMSG_SCALAR_INPUT);
            break;

        case 1: /* Frame based */
            if(inRows == 1)
                THROW_ERROR(S, "Integration for frames of size 1 not"
                                " allowed. In frame based mode, the block"
                                " accepts column vectors and matrices.");
            if(fmod(inRows, integPeriod) != 0)
                THROW_ERROR(S,"The input frame size must be an integer"
                                " multiple of integration period.");
            break;
        default:
            THROW_ERROR(S,COMM_EMSG_INVALID_FRAME);
        }
    }

    /* Calc the output dims 
     */
    outCols  = inCols;
    if((fb) && (dumpOutput)) /* Frame based dump mode */
    {
        outRows = inRows/integPeriod;
    }
    else /*SB dump and no dump, FB no dump*/
    {
        outRows = inRows;
    }
    		
    /* Set Output port dimensions. 
     */
    if (ssGetOutputPortWidth(S,OUTPORT) == DYNAMICALLY_SIZED) 
    {
        switch (inDimsInfo->numDims)
        {
        case 1: /* 1D signals*/
            if(!ssSetOutputPortVectorDimension(S,OUTPORT,outRows)) 
                return;
            break;
        case 2: /* 2D signals*/
            if(!ssSetOutputPortMatrixDimensions(S, OUTPORT, outRows, outCols)) 
                return;
            break;
        default:
            THROW_ERROR(S, COMM_EMSG_INVALID_DIMS);
        }
    }
    else  /* Verify the settings */
    { 
        const DimsInfo_T *outDimsInfo;
        outDimsInfo = (DimsInfo_T*)ssGetOutputPortDimensions(S,OUTPORT);

        if(outDimsInfo->numDims != inDimsInfo->numDims)
            THROW_ERROR(S, COMM_EMSG_INVALID_DIMS);

        /* Do the Column check for 2D signals
         */
        if(outDimsInfo->numDims  == 2)
        {
            if(outDimsInfo->dims[1] != inDimsInfo->dims[1])
                THROW_ERROR(S, COMM_EMSG_INVALID_DIMS);
        }
        /* Do the Row check for both 1D and 2D signals
         */
        if(outDimsInfo->dims[0] != inDimsInfo->dims[0])
                THROW_ERROR(S, COMM_EMSG_INVALID_DIMS);
   }

} /* End of mdlSetInputPortDimensionInfo() */


#define	MDL_SET_OUTPUT_PORT_DIMENSION_INFO
static void mdlSetOutputPortDimensionInfo(SimStruct *S,	int_T portIdx,
				                            const	DimsInfo_T *outDimsInfo)
{
    int_T inCols, inRows;
    int_T outCols = outDimsInfo->dims[1];
    int_T outRows = outDimsInfo->dims[0];

    const boolean_T fb         = COMM_IS_INPORT_FRAME_BASED(S, INPORT);
    const boolean_T dumpOutput = IS_DUMP_OUTPUT; 
  
    /* Set the given port dimension
     */
    if(!ssSetOutputPortDimensionInfo(S, portIdx, outDimsInfo)) return;
    
    /* Check the validity of the output port dimensions
     */
    if( ssGetOutputPortConnected(S,OUTPORT))
    {
	    if ( (outDimsInfo->numDims != 1) && (outDimsInfo->numDims != 2) )	
            THROW_ERROR(S, COMM_EMSG_INVALID_DIMS);
	
	    if((!fb) && (outDimsInfo->width != 1))
            THROW_ERROR(S, COMM_EMSG_SCALAR_OUTPUT);
    }

    /* Calc the input dimesnsions 
     */
    inCols	= outCols;

    if(fb && (dumpOutput)) 
        inRows	= outRows * INTEG_SAMPLES_ARG(S);
    else 
        inRows	= outRows;

    /* Set input port dimensions
     */
    if (ssGetInputPortWidth(S,INPORT) == DYNAMICALLY_SIZED)	
    {
        switch(outDimsInfo->numDims)
	    {
	    case 1: /* 1D signal*/
	        if(!ssSetInputPortVectorDimension(S, INPORT, inRows)) 
	    	    return;
	        break;
	    case 2: /* 2D signal */
	        if(! ssSetInputPortMatrixDimensions(S, INPORT, inRows, inCols)) 
	            return;
	        break;
	    default:
	        THROW_ERROR(S, COMM_EMSG_INVALID_DIMS);
	    }
    }
    else  /* Verify input port dimensions */
    {
        const DimsInfo_T *inDimsInfo;
        inDimsInfo = (DimsInfo_T*)ssGetInputPortDimensions(S, INPORT);
        if(inDimsInfo->numDims != outDimsInfo->numDims)
            THROW_ERROR(S, "PORT DIMENSION PROPAGATION FAILED.");
        
        /* Check input column value for 2D signals
         */

        if(inDimsInfo->numDims == 2)
        {
            if(inDimsInfo->dims[1] != outDimsInfo->dims[1])
                THROW_ERROR(S, COMM_EMSG_INVALID_DIMS);
        }

        /* Check input row value for 1D and 2D signals
         */
        if(inDimsInfo->dims[0] != outDimsInfo->dims[0])
                THROW_ERROR(S, COMM_EMSG_INVALID_DIMS);
     }

} /*end of mdlSetOutputPortDimensionInfo() */

#define MDL_SET_INPUT_PORT_SAMPLE_TIME
static void mdlSetInputPortSampleTime(SimStruct *S, int_T portIdx,
				        real_T inSmplTime, real_T inOffset)
{   
    real_T outSmplTime;

    const boolean_T fb          = COMM_IS_INPORT_FRAME_BASED(S, INPORT);
    const boolean_T dumpOutput  = IS_DUMP_OUTPUT; 

    /* Set the given input port sample time
     */
    ssSetInputPortSampleTime(S, portIdx, inSmplTime);
    ssSetInputPortOffsetTime(S, portIdx, inOffset);


    
    /* Check the validity of the input port sample time.
     */
    if(ssGetInputPortConnected(S, INPORT))
    {
        if(inSmplTime == 0.0) 
            THROW_ERROR(S, COMM_EMSG_DISCRETE_SIGNALS);
        if(inOffset != 0.0)
            THROW_ERROR(S, COMM_EMSG_NONZERO_OFFSET_TIME);
    }

    /* Cal the output port sample time
     */

    if((!fb) && (dumpOutput))
        outSmplTime = inSmplTime * INTEG_SAMPLES_ARG(S);
    else
        outSmplTime = inSmplTime;

    /* Set output port
     */
    if(ssGetOutputPortSampleTime(S, OUTPORT) == INHERITED_SAMPLE_TIME)
    {
        ssSetOutputPortSampleTime(S, OUTPORT, outSmplTime);
        ssSetOutputPortOffsetTime(S, OUTPORT, 0.0);
    }
    else /*Output port sample time is already set. verify */
    {
        if((ssGetOutputPortSampleTime(S, OUTPORT) != outSmplTime) || 
                    (ssGetOutputPortOffsetTime(S, OUTPORT) != 0.0))
            THROW_ERROR(S, COMM_EMSG_INVALID_SAMPLE_TIME);
    }
}


#define MDL_SET_OUTPUT_PORT_SAMPLE_TIME
static void mdlSetOutputPortSampleTime(SimStruct *S, int_T portIdx,
				                        real_T outSmplTime, real_T outOffset)
{
    real_T inSmplTime;
    const boolean_T dumpOutput = IS_DUMP_OUTPUT; 
    const boolean_T fb         = COMM_IS_INPORT_FRAME_BASED(S, INPORT);
    const int_T integPeriod    = INTEG_SAMPLES_ARG(S);
   
    /* Set the given output port
     */
    ssSetOutputPortSampleTime(S, portIdx, outSmplTime);
    ssSetOutputPortOffsetTime(S, portIdx, outOffset);

    /* Check Output port sample time validity
     */
    if(ssGetOutputPortConnected(S, OUTPORT))
    {
        if(outSmplTime == 0.0) 
		    THROW_ERROR(S,COMM_EMSG_DISCRETE_SIGNALS);
        if(outOffset != 0.0)
            THROW_ERROR(S, COMM_EMSG_NONZERO_OFFSET_TIME);
	    
    } /* End output port setting validity check*/

    /* Calc the input port sample time
     */

    if((!fb) && (dumpOutput)) /*Sample based dump*/
    {
        inSmplTime = outSmplTime/integPeriod;
    }
    else/* Sample based dump all and frame based all oprs*/
    {
        inSmplTime = outSmplTime;
    }
    
    /*Set the input port*/
    if(ssGetInputPortSampleTime(S, INPORT) == INHERITED_SAMPLE_TIME)
    {
        ssSetInputPortSampleTime(S, INPORT, inSmplTime);
        ssSetInputPortOffsetTime(S, INPORT, 0.0);
    }
    else if((ssGetInputPortSampleTime(S, INPORT) != inSmplTime) || 
			(ssGetInputPortOffsetTime(S, INPORT) != 0.0))
	{
        	THROW_ERROR(S, COMM_EMSG_INVALID_SAMPLE_TIME);
    }
}

#endif /* Corresponds to #ifdef MATLAB_MEX_FILE */

/* Function: mdlInitializeSampleTimes =========================================*/
static void mdlInitializeSampleTimes(SimStruct *S)
{
    /* Not Used */
}


#if defined(MATLAB_MEX_FILE)
#define MDL_SET_INPUT_PORT_COMPLEX_SIGNAL
static void mdlSetInputPortComplexSignal(SimStruct *S, int_T portIdx,
                                        int_T complexity)
{
    ssSetInputPortComplexSignal(S, portIdx, complexity);

    if(ssGetOutputPortComplexSignal(S, OUTPORT) == COMPLEX_INHERITED)
        ssSetOutputPortComplexSignal(S, OUTPORT, complexity);
    else if(ssGetOutputPortComplexSignal(S, OUTPORT) != complexity)
        THROW_ERROR(S, COMM_EMSG_INVALID_COMPLEXITY);
}

#define MDL_SET_OUTPUT_PORT_COMPLEX_SIGNAL
static void mdlSetOutputPortComplexSignal(SimStruct *S, int_T portIdx,
                                        int_T complexity)
{
    ssSetOutputPortComplexSignal(S, portIdx, complexity);

    if(ssGetInputPortComplexSignal(S, INPORT) == COMPLEX_INHERITED)
        ssSetInputPortComplexSignal(S, INPORT, complexity);
    else if(ssGetInputPortComplexSignal(S, INPORT) != complexity)
        THROW_ERROR(S, COMM_EMSG_INVALID_COMPLEXITY);
}



#define MDL_SET_WORK_WIDTHS
static void mdlSetWorkWidths(SimStruct *S)
{
    int_T *inDims           = ssGetInputPortDimensions(S, INPORT);
    int_T *outDims          = ssGetOutputPortDimensions(S, OUTPORT);
    const boolean_T cmplx   = COMM_IS_INPORT_CMPLX(S, INPORT);
    const boolean_T fb      = COMM_IS_INPORT_FRAME_BASED(S, INPORT);
 
    /* Set dims[1] = 1 for 1D signals.
     */

    if(ssGetInputPortNumDimensions(S,INPORT) == 1)
        inDims[1] = 1;

    /* 7 DWork Vectors used in the code.
     * CUMSUM           => Stores the integral at every integration step for 
     *                     the duration of the integration. 
     *                     Size in Frame based operation : integration period;
     *                     Size in Sample based operation : 1.
     *                     This is used only in dump mode due to the extra
     *                      delay thats introduced.
     * LAST_INTEGRAL    => Stores the last integral from the previous  
     *                     mdlOutput() call for a given channel. 
     *                     In frame based operations, it is used to 
     *                     integrate over frames in case of offsets 
     *                     Size : Number of channels.
     *                     In sample based operations, it is used to remeber
     *                     the last dump value. This is to accomodate the one
     *                     sample delay in multirate mode.
     *                     Size : 1(since, numChannls = 1)
     * INTEG_CTR        => Conter to track the number of samples integrated.
     *                     Size : Number of channels.
     * OFFSET_CTR       => Counter to track the number of samples discarded as .
     *                     offset.
     *                     Size : Number of channels.
     * FRAMES_OFFSET    => Tracks the number of frames discarded as offset
     *                     for a given channel.
     *                     Size : Number of channels.
     * SAMPLES_OFFSETS     => Specifies the number of delays to be introduced 
     *                     before begining integration in a given channel. 
     *                     This delay is apart from the delay introduced by.
     *                     FRAMES_OFFSET 
     *                     Size : Number of channels.
     *
     * CHANNEL_OFFSETS  => Vector to store the channel offset information
     *                     from the mask. If the Offset feild size in the mask
     *                     is one, then all elements of the vector is 
     *                     Size : Num channels. 
     */

     /* Frame based : uses all the 6 DWork vectors
      * Sample based : uses the firt 4 DWork vectors
      */

	 if(fb)
	 {
		 ssSetNumDWork(S,7);
         /* Set Width for FB specific work vectors*/
         ssSetDWorkWidth(S, CUMSUM, INTEG_SAMPLES_ARG(S));
		 ssSetDWorkWidth(S, FRAMES_OFFSET, inDims[1]);
         ssSetDWorkWidth(S, SAMPLES_OFFSETS, inDims[1]);
         ssSetDWorkWidth(S, CHANNEL_OFFSETS, inDims[1]);

         ssSetDWorkComplexSignal(S, FRAMES_OFFSET, COMPLEX_NO);
         ssSetDWorkComplexSignal(S, SAMPLES_OFFSETS, COMPLEX_NO);
         ssSetDWorkComplexSignal(S, CHANNEL_OFFSETS, COMPLEX_NO);
		 
         /*Set Data type for FB specific work vectors*/
		 ssSetDWorkDataType(S, FRAMES_OFFSET, SS_INT32);
         ssSetDWorkDataType(S, SAMPLES_OFFSETS, SS_INT32); 
         ssSetDWorkDataType(S, CHANNEL_OFFSETS,SS_INT32);
	}
	else /* SB*/
	{
		 ssSetNumDWork(S,4);
         ssSetDWorkWidth(S, CUMSUM, 1);
    }

    /* Set Complexity for common work vectors
     */
    if(cmplx)
    {
	    ssSetDWorkComplexSignal(S, CUMSUM, COMPLEX_YES);
		ssSetDWorkComplexSignal(S, LAST_INTEGRAL, COMPLEX_YES);
    }
	else
	{
	    ssSetDWorkComplexSignal(S, CUMSUM, COMPLEX_NO);
		ssSetDWorkComplexSignal(S, LAST_INTEGRAL, COMPLEX_NO);
    }

    /* Set Width for common work vectors 
     */
    ssSetDWorkWidth(S, INTEG_CTR , inDims[1]);
    ssSetDWorkWidth(S, OFFSET_CTR , inDims[1]);
    ssSetDWorkWidth(S, LAST_INTEGRAL, inDims[1]);

    /*Set Complexity for common work vectors */
    ssSetDWorkComplexSignal(S, INTEG_CTR , COMPLEX_NO);
    ssSetDWorkComplexSignal(S, OFFSET_CTR , COMPLEX_NO);

    /* Set Data type for common work vectors */
	ssSetDWorkDataType(S, CUMSUM, SS_DOUBLE); 
    ssSetDWorkDataType(S, INTEG_CTR , SS_INT32);
    ssSetDWorkDataType(S, OFFSET_CTR , SS_INT32);
    ssSetDWorkDataType(S, LAST_INTEGRAL, SS_DOUBLE);

} /* End of mdlSetWorkWidths() */

#endif /*Corresponds to #if defined MATLAB_MEX_FILE */

/*=============================================================================

/* Helper Functions to initialize DWork vectors in Frame based.
 */

/* Function/Macro       : initFbCmplxWorkVecs(SimStruct *S, int_T cumSumWidth,
 *                                              int_T numChannels)
 * Description          : Initializes the complex work vectors CUMSUM 
 *                      and LAST_INTEGRAL.
 *
 */
static void initFbCmplxWorkVecs(SimStruct *S, int_T cumSumWidth, 
                                int_T numChannels)
{
    
    creal_T *cumSum             = (creal_T*) ssGetDWork(S, CUMSUM);
    creal_T *lastIntegral       = (creal_T*) ssGetDWork(S, LAST_INTEGRAL);
   
    
    for( ; cumSumWidth > 0; cumSumWidth--, cumSum++)
        RESET_CREAL_PTR(cumSum);

  
    for( ; numChannels > 0; numChannels--, lastIntegral++)
        RESET_CREAL_PTR(lastIntegral);

}

/* Function/Macro   : initFbRealWorkVecs(SimStruct *S, int_T cumSumWidth,
 *                                              int_T numChannels)
 * Description      : Initializes the real work vectors CUMSUM and 
 *                    LAST_INTEGRAL
 *
 */
static void initFbRealWorkVecs(SimStruct *S, int_T cumSumWidth, int_T numChannels)
{
    real_T *cumSum           = (real_T*) ssGetDWork(S, CUMSUM);
    real_T *lastIntegral     = (real_T*) ssGetDWork(S, LAST_INTEGRAL);

    for( ; cumSumWidth > 0; cumSumWidth--, cumSum++)
         *cumSum = 0.0;
          
    for( ; numChannels > 0; numChannels--,lastIntegral++ )
       *lastIntegral = 0.0;
 
}

/* Function: mdlInitializeConditions ========================================*/
#define MDL_INITIALIZE_CONDITIONS
static void mdlInitializeConditions(SimStruct *S)
{
    
    int_T *numSmplsInteg        = (int_T*) ssGetDWork(S, INTEG_CTR);
    int_T *numSmplsOffset       = (int_T*) ssGetDWork(S, OFFSET_CTR);
    int_T cumSumWidth           = ssGetDWorkWidth(S, CUMSUM);
 
    const boolean_T cmplx   = COMM_IS_INPORT_CMPLX(S, INPORT);
    const boolean_T fb      = COMM_IS_INPORT_FRAME_BASED(S, INPORT);
    int_T numOffsetElements = mxGetNumberOfElements(OFFSET_SAMPLES_ARG_PTR(S));
    
    if(fb)
    {
        int numMoreSmplsToDiscard, i;
        int_T *numFramesToDiscard   = (int_T*) ssGetDWork(S, FRAMES_OFFSET);
        int_T *numMoreDelays        = (int_T*) ssGetDWork(S, SAMPLES_OFFSETS);
        int_T *thisChannelOffset    = (int_T*) ssGetDWork(S, CHANNEL_OFFSETS);
        int_T *tmpChannelOffset     = thisChannelOffset;
        int_T *inDims               = ssGetInputPortDimensions(S, INPORT);
        int_T numChannels           = inDims[1];
        int_T inRows                = inDims[0];
        int_T offset                = OFFSET_SAMPLES_ARG(S);
        int_T integPeriod           = INTEG_SAMPLES_ARG(S);
        const boolean_T dumpOutput  = IS_DUMP_OUTPUT;
              
        /* check if the mask Offsets vector length is equal to 1 or number of
         * input channels
         */
        if((numOffsetElements != 1) && (numOffsetElements != inDims[1]) )
        {
            THROW_ERROR(S, "Offset must be a scalar or a vector of"
                           " size equal to the number of input columns");
        }
        /* Initialize channel offset vectors from the mask. 
         * If only one offset is specified, then intialize
         * the vector to this value. Offset across all channels
         * is the same.
         */
        if(numOffsetElements == 1)
        {
            for(i = 0; i < numChannels ; i++, thisChannelOffset++)
                *thisChannelOffset = offset;
        }
        else
        {
            for(i = 0; i< numChannels; i++, thisChannelOffset++)
                *thisChannelOffset = ((int_T)mxGetPr(OFFSET_SAMPLES_ARG_PTR(S))[i]);
        }
    
        if(cmplx)
             initFbCmplxWorkVecs(S, cumSumWidth, numChannels);
        else /*real fb*/
            initFbRealWorkVecs(S, cumSumWidth, numChannels);
        
        /* Reset ptr to its head
         */
        thisChannelOffset = tmpChannelOffset;

        while(numChannels)
        {
            *numSmplsInteg = 0;
            *numSmplsOffset = 0;
            *numFramesToDiscard = (int_T) (*thisChannelOffset/inRows);
            numMoreSmplsToDiscard = (*thisChannelOffset - 
                                            *numFramesToDiscard * inRows);
            if(dumpOutput)
            {
                *numMoreDelays = (int_T)numMoreSmplsToDiscard/integPeriod;
	            if(fmod(numMoreSmplsToDiscard, integPeriod) != 0)
                    (*numMoreDelays)++;
               
            }
            else
            {
                *numMoreDelays = numMoreSmplsToDiscard;
            }
            numMoreDelays++;
            numSmplsInteg++;
            numSmplsOffset++;
            numFramesToDiscard++;
            thisChannelOffset++;
            numChannels--;
        }
    } /* FB ends */
    else /* SB */
    {
        /* check if the mask Offsets vector length is equal to 1 
         */
        if(numOffsetElements != 1) 
        {
            THROW_ERROR(S, "In sample based operation Offset vector length"
                            " must be a scalar.");
        }

        *numSmplsInteg = 0;
        *numSmplsOffset = 0;

        if(cmplx)
        {
            creal_T *cumSum         = (creal_T*) ssGetDWork(S, CUMSUM);
            creal_T *lastIntegral   = (creal_T*) ssGetDWork(S, LAST_INTEGRAL);

            RESET_CREAL_PTR(cumSum);
            RESET_CREAL_PTR(lastIntegral);
        }
        else /* SB real */
        {
            real_T *cumSum          = (real_T*) ssGetDWork(S, CUMSUM);
            real_T *lastIntegral    = (real_T*) ssGetDWork(S, LAST_INTEGRAL);
            *cumSum         = 0.0;
            *lastIntegral   = 0.0;
                
        } 
    } /* SB ends */
    
} /*End of mdlInitializeConditions()*/


/* Fucntions to do FB processing */

/* NOTE :   		
 * The algorithm for frame based can be broken into 3 parts.
 * 1st part : Discard away any offset samples. This may extend over
 *            one frame.
 * 2nd part : Compute if any integration segments are available 
 *            after the offset samples are discarded.Integrate 
 *            the input signal for each of the 
 *            integration segments. At the end of the integration output
 *            appropriately.
 * 3rd part : Walk through the rest of the frame and store the last 
 *            integral for use in the next mdlOutput() call.
 * Repeat these steps for every channel in the input signal.
 */
static void fbCmplxProcess(int_T* smplsInteg, int_T integPeriod, 
                           int_T currSize, int_T offset, 
                           boolean_T dumpOutput, creal_T *cumSumCmplx,
                           creal_T *prevFrameIntegral, creal_T *thisFrameInSig, 
                           creal_T *thisFrameOutSig
                          )
{
    int_T integSegs;
    creal_T tmpSum;
    int_T tmpIntegPeriod    =  integPeriod;
    creal_T *tmpCumSumHead  =  cumSumCmplx; 
    

	tmpSum.re = prevFrameIntegral->re;
	tmpSum.im = prevFrameIntegral->im;			    
	
   
    while(tmpIntegPeriod)
    {
        RESET_CREAL_PTR(cumSumCmplx);
        cumSumCmplx++;
        tmpIntegPeriod--;
    }
    
    cumSumCmplx = tmpCumSumHead;

    /* PArt 2: Determine the number of integration segments.
     * May be less than (int_T) inRows/integPeriod
     * for the frame where the first
     * integration begins after covering offset.
     * For all following frames it is (int_T)inRows/integPeriod.
     * Integrate the signal over the integration segments.
     */
	integSegs = (int_T) currSize/integPeriod;
	
    while(integSegs > 0) 
	{
        /* This is needed to generalize the code for integration
         * with offsets, offset covered and no offset scenarios.
         */
	    int_T smplsNeeded = integPeriod - *smplsInteg;
	
        while(*smplsInteg < integPeriod)
	    {
	        cumSumCmplx->re = tmpSum.re + thisFrameInSig->re;
	        cumSumCmplx->im = tmpSum.im + thisFrameInSig->im;
	        
	        tmpSum.re = cumSumCmplx->re;
	        tmpSum.im = cumSumCmplx->im;

            (*smplsInteg)++;
            thisFrameInSig++;
            cumSumCmplx++;
            currSize--;
		}

	    /* Output the integral. 
         */
	    if(dumpOutput)
	    {
            SET_CREAL_PTR(thisFrameOutSig, (--cumSumCmplx)->re, cumSumCmplx->im);
            thisFrameOutSig++; 
	        cumSumCmplx++;
		}
	    else /* output intermediate integrals*/
	    {
	         cumSumCmplx -= smplsNeeded; 
	         while(smplsNeeded)
             {
                 SET_CREAL_PTR(thisFrameOutSig, cumSumCmplx->re, cumSumCmplx->im);
	             thisFrameOutSig++; 
	             cumSumCmplx++;
	             smplsNeeded--;
             }
	    }

	    /* reset integration, cumSum, tmpSum
	     * To walk through cumSum, first reset it to its
	     * head position with tmpCumSumHead.
         */
	    tmpIntegPeriod       = integPeriod;
	    cumSumCmplx          = tmpCumSumHead;
	    while(tmpIntegPeriod)
	    {
            RESET_CREAL_PTR(cumSumCmplx);
	        cumSumCmplx++;
	        tmpIntegPeriod--;
	    }
	    
	    *smplsInteg = 0;
	    tmpSum.re   = 0.0;
	    tmpSum.im   = 0.0;
        integSegs--;
        /* move cumSum back to its original head.
         */
	    cumSumCmplx      = tmpCumSumHead; 
	}

    /* Part 3: Integrate the rest of the input sig 
     * to carry over to the next frame
     */
	if(currSize != 0)
    {
        int_T leftOverSmpls = currSize;
        while(currSize != 0)
        {
            cumSumCmplx->re = tmpSum.re + thisFrameInSig->re;
            cumSumCmplx->im = tmpSum.im + thisFrameInSig->im;

            tmpSum.re = cumSumCmplx->re;
            tmpSum.im = cumSumCmplx->im;

            (*smplsInteg)++;
            cumSumCmplx++;
            thisFrameInSig++;
            currSize--;
        }
        /* Reset cumSum to its head position
         */
        cumSumCmplx = tmpCumSumHead;
        if(!dumpOutput)
        {
            while(leftOverSmpls)
            {
                SET_CREAL_PTR(thisFrameOutSig,cumSumCmplx->re,cumSumCmplx->im);
                thisFrameOutSig++;
                cumSumCmplx++;
                leftOverSmpls--;
            }
            cumSumCmplx = tmpCumSumHead;
        }
    }

    /* Determine whether to store the 
     * last integral or not.
     */
	if(fmod(offset,integPeriod) != 0)
	{
	    prevFrameIntegral->re = tmpSum.re;
		prevFrameIntegral->im = tmpSum.im;			        
	    tmpSum.re = 0.0;
	    tmpSum.im = 0.0;
	}
    tmpCumSumHead = 0;

} /* end of fbCmplxProcess() */

static void fbRealProcess(int_T* smplsInteg, int_T integPeriod, 
                          int_T inRows, int_T offset,
                          boolean_T dumpOutput, real_T *cumSum,  
                          real_T *prevFrameIntegral, real_T *thisFrameInSig, 
                          real_T *thisFrameOutSig
                         )
{ 
    /* temporary variables to help walking through the frame
     */
    int_T integSegs;
    int_T tmpInRows         = inRows;
    real_T *tmpCumSumHead    = cumSum;
    real_T tmpSum            = *prevFrameIntegral;
    int_T tmpIntegPeriod    = integPeriod;
    
    while(tmpIntegPeriod)
    {
        *cumSum++ = 0.0;
        tmpIntegPeriod--;
    }
    cumSum = tmpCumSumHead;
    
    

    /* Determine the number of integration segments.
     * May be less than (int_T)inRows/integPeriod
     * for the frame where the first integration
     * begins after covering offset.
     * For all following frames it is inRows/integPeriod.
     */
	integSegs = (int_T) tmpInRows/integPeriod;
	
	while(integSegs > 0) 
	{
	    /* This is needed to generalize the code for integration
         * with offsets, offset covered and no offset scenarios.
         */
	    int_T smplsNeeded = integPeriod - *smplsInteg;
	    while(*smplsInteg < integPeriod)
	    {
	        *cumSum = tmpSum + *thisFrameInSig;
	        tmpSum  = *cumSum;
            (*smplsInteg)++;
            thisFrameInSig++;
            cumSum++;
            tmpInRows--;
		}

	    /* Output the integral. Tried my best to do this out side
         * after all integration is over. But that required more
         * memory and indexing into this memory for dumping became 
         * more complicated than necessary. 
         * PS: Will edit this comment before check in ;)
         */
	    if(dumpOutput)
	    {
	        *thisFrameOutSig++ = *(--cumSum);  
	        cumSum++;
		}
	    else /* output intermediate integrals*/
	    {
	        cumSum -= smplsNeeded; 
	        while(smplsNeeded)
	        {
	            *thisFrameOutSig++ = *cumSum;
	            cumSum++;
	            smplsNeeded--;
	        }
	    }
	    /* reset integration, cumSum, tmpSum
	     * To walk through cumSum, reset it to its
	     * head position first with tmpCumSumHead
         */
	    tmpIntegPeriod  = integPeriod;
	    cumSum          = tmpCumSumHead;
	    while(tmpIntegPeriod)
	    {
	        *cumSum++ = 0.0;
	        tmpIntegPeriod--;
	    }
	    *smplsInteg = 0;
	    tmpSum      = 0.0;
        integSegs--;
        cumSum = tmpCumSumHead;
	}
  
    /* Integrate the rest of the input sig 
     * to carry over to the next frame
     */
    if(tmpInRows!= 0)
    {
        int_T leftOverSmpls = tmpInRows;
        cumSum = tmpCumSumHead;
        tmpSum = 0.0;
        while(tmpInRows != 0)
	    {
	        *cumSum = tmpSum + *thisFrameInSig;
            tmpSum  = *cumSum;
            (*smplsInteg)++;
            thisFrameInSig++;
            cumSum++;
            tmpInRows--;
        }
        /* Reset cumSum to its head position
        */
        cumSum = tmpCumSumHead;

        /* Output if output intermediate values is checked
         */
        if(!dumpOutput)
        {
            while(leftOverSmpls)
            {
                *thisFrameOutSig = *cumSum;
                cumSum++;
                thisFrameOutSig++;
                leftOverSmpls--;
            }           
            cumSum = tmpCumSumHead;
        }
	} /* end of integration*/

     /* Determine whether to store the 
      * last integral or not.
      */
	 if(fmod(offset,integPeriod) != 0)
	 { 
	 	*prevFrameIntegral = tmpSum;
	     tmpSum = 0.0;
	 }
 	tmpCumSumHead = 0;

} /* End of fbRealProcess() */


static void mdlOutputs(SimStruct *S, int_T tid)
{
    /* Get work vectors 
     */
    int_T *smplsInteg           = (int_T*) ssGetDWork(S, INTEG_CTR);
    int_T *smplsDiscarded       = (int_T*) ssGetDWork(S, OFFSET_CTR);
    const boolean_T dumpOutput  = IS_DUMP_OUTPUT; 
    int_T integPeriod           = INTEG_SAMPLES_ARG(S);
    const boolean_T cmplx  = COMM_IS_INPORT_CMPLX(S, INPORT);
    const boolean_T fb     = COMM_IS_INPORT_FRAME_BASED(S, INPORT);
     
    if(fb)
    {
        int_T j, currSize, inFrameSize, outFrameSize;
        const int_T *inDims         = ssGetInputPortDimensions(S, INPORT);
        const int_T *outDims        = ssGetOutputPortDimensions(S, OUTPORT);
        int_T *numMoreDelays        = (int_T*) ssGetDWork(S, SAMPLES_OFFSETS);
        int_T *numFramesToDiscard   = (int_T*) ssGetDWork(S, FRAMES_OFFSET);
        int_T *thisChannelOffset    = (int_T*) ssGetDWork(S, CHANNEL_OFFSETS);
        int_T numChannels           = inDims[1];
               
         	    
        if(cmplx) /*Frame based Complex begins*/
        {
        	creal_T *inSig		= (creal_T*) ssGetInputPortSignal(S, INPORT);
    		creal_T *outSig     = (creal_T*) ssGetOutputPortSignal(S, OUTPORT);
    		creal_T *prevFrameIntegral = (creal_T*)ssGetDWork(S,LAST_INTEGRAL);

            creal_T *thisFrameInSig = 0, *thisFrameOutSig = 0;
            
            creal_T *cumSum = (creal_T*) ssGetDWork(S,CUMSUM);
            creal_T *tmpCumSumHead = cumSum;

            int_T tmpIntegPeriod;
           
    		for(j = 0; j < numChannels; j++, smplsDiscarded++, numFramesToDiscard++, 
                                        smplsInteg++,prevFrameIntegral++, 
                                        numMoreDelays++, thisChannelOffset++)
			{
                thisFrameInSig     = inSig + (j * inDims[0]);
                thisFrameOutSig    = outSig + (j * outDims[0]);
                tmpIntegPeriod     = integPeriod;
                inFrameSize        = inDims[0];
                currSize           = inFrameSize;
                outFrameSize       = outDims[0];
                cumSum             = tmpCumSumHead;

                /* Part 1: Discard offset samples. This can span to number of frames.
                 */
                if(*numFramesToDiscard != 0)
	            {
                    /* Discard this frame.
                     */
	                *smplsDiscarded += inFrameSize;
	                (*numFramesToDiscard)--;
	    
                    /* output 0.0 at the outport
                     */
	                while(outFrameSize)
	                {
	                    /*thisFrameOutSig->re = 0.0;
			            thisFrameOutSig->im = 0.0;
                        */
                        RESET_CREAL_PTR(thisFrameOutSig);
			            thisFrameOutSig++;			            
	                    outFrameSize--;
	                }
	                continue; /*To the next channel*/
	            }
                if(*numMoreDelays != 0)
                {
                    /* Some smpls from this frame have to be thrown.
                     * Increment the numSmplsCounter, inSig ptr.
                     */
   	                int_T smplsToDiscard = *thisChannelOffset - *smplsDiscarded; 
                    currSize             -= smplsToDiscard;
	                thisFrameInSig       += smplsToDiscard;
	                *smplsDiscarded      += smplsToDiscard;
	    
	                /* output necessary delay.
                     */
	                while(*numMoreDelays)
	                {
	                    RESET_CREAL_PTR(thisFrameOutSig);
			            thisFrameOutSig++;
	                    (*numMoreDelays)--;
	                }

                }
                               
                fbCmplxProcess(	smplsInteg, /* integrated smpls ctr */ 
               					integPeriod, /* integration period */
                                currSize,  /* in rows */
                                *thisChannelOffset, /*offset for this channel*/
                                dumpOutput, /* dump or no dump from mask*/
                                cumSum, /* ptr to vector to store integrals within an
                                					integ period*/
                                prevFrameIntegral, /* integral for this channel 
                                					from last mdlOutput call */
                                thisFrameInSig, /* input sig for this channel */                           
                                thisFrameOutSig /* output sig for this channel */
                             );

           } /* for(j) ends*/
            thisFrameInSig = 0;
            thisFrameInSig = 0;
            tmpCumSumHead  = 0;

        }/* Frame based Complex ends*/
        else /*Frame based real begins*/
        {
            
            real_T *inSig  = (real_T*) ssGetInputPortSignal(S, INPORT);
    		real_T *outSig = (real_T*) ssGetOutputPortSignal(S, OUTPORT);
    		real_T *cumSum = (real_T*) ssGetDWork(S,CUMSUM); 
            
    		real_T *prevFrameIntegral = (real_T*) ssGetDWork(S, LAST_INTEGRAL);

            real_T *thisFrameInSig = 0, *thisFrameOutSig = 0;
            real_T *tmpCumSumHead = cumSum;
            int_T tmpIntegPeriod;
                		
			for(j = 0; j < numChannels; j++, smplsDiscarded++, numFramesToDiscard++, 
                                        smplsInteg++,prevFrameIntegral++ ,
                                        numMoreDelays++, thisChannelOffset++)
			{
                thisFrameInSig  = inSig + (j* inDims[0]);
                thisFrameOutSig = outSig + (j* outDims[0]);
                tmpIntegPeriod  = integPeriod;
                inFrameSize     = inDims[0];
                currSize        = inFrameSize;
                outFrameSize    = outDims[0];

                /* Discard offset samples. This can span to number of frames.
                 */
	            if(*numFramesToDiscard != 0)
	            {
	                /*Discard this frame*/
	                *smplsDiscarded += inFrameSize;
	                (*numFramesToDiscard)--;
        
                    /* output 0.0 at the outport
                     */
	                while(outFrameSize)
	                {
	                    *thisFrameOutSig++ = 0.0;
	                    outFrameSize--;
	                }
	                continue; /*To the next channel*/
	            }
	            else if(*smplsDiscarded < *thisChannelOffset)
	            {
	                /* Some smpls from this frame have to be Discarded.
                     * Increment the splsCounter, inSig ptr.
                     */
	                int_T smplsToDiscard = *thisChannelOffset - *smplsDiscarded; 
	                currSize            -= smplsToDiscard;
	                thisFrameInSig      += smplsToDiscard;
	                *smplsDiscarded     += smplsToDiscard;
	    
	                /* output necessary delay
                     */      
	                while(*numMoreDelays)
	                {
	                    *thisFrameOutSig++ = 0.0;
	                    (*numMoreDelays)--;
	                }
	            }

                fbRealProcess( 	smplsInteg, 
                			    integPeriod, 
                                currSize, 
                                *thisChannelOffset, 
                                dumpOutput, 
                                cumSum, 
                                prevFrameIntegral, 
                                thisFrameInSig,
                                thisFrameOutSig
                             ); 
			} /* For(j) ends*/
            thisFrameInSig = 0;
            thisFrameInSig = 0;
            tmpCumSumHead  = 0;

        }/*FB real ends*/

    } /*if FB ends*/
    else /* SB begins*/
    {
        /* NOTE:
         * In MULTIRATE  : When output port hit, output the value 
         *                 in the last integral to accomadate the one sample
         *                 delay.
         */

        const int_T inPrtSmplIdx    = ssGetInputPortSampleTimeIndex(S, INPORT);
        const int_T outPrtSmplIdx   = ssGetOutputPortSampleTimeIndex(S, OUTPORT);

        int_T offset          = OFFSET_SAMPLES_ARG(S);
        int_T *smplsDiscarded = (int_T*)ssGetDWork(S, OFFSET_CTR);                       
        int_T *smplsInteg     = (int_T*)ssGetDWork(S, INTEG_CTR);

        if(cmplx)/*SB Complex begins*/
        {
            creal_T *inSigCmplx     = (creal_T*)ssGetInputPortSignal(S, INPORT);
            creal_T *outSigCmplx    = (creal_T*)ssGetOutputPortSignal(S, OUTPORT);
            creal_T *cumSumCmplx    = (creal_T*)ssGetDWork(S, CUMSUM);

            creal_T *lastIntegralCmplx = (creal_T*) ssGetDWork(S, LAST_INTEGRAL);

            if(dumpOutput) /* CMPLX MULTIRATE*/
            {
                if(ssIsSampleHit(S, inPrtSmplIdx, tid) )
                {
                    if(++(*smplsDiscarded) > offset)                                                                                                
                        INTEG_CMPLX_INPUT(smplsInteg,cumSumCmplx,inSigCmplx);                                                                   
                                                                                  
                    if(*smplsInteg == integPeriod)
                       RESET_CMPLX_INTEG(cumSumCmplx, lastIntegralCmplx, smplsInteg);
                }
                /*Do outport process*/
                if(ssIsSampleHit(S, outPrtSmplIdx, tid) )
                     PROCESS_CMPLX_OUTPUT(lastIntegralCmplx, outSigCmplx);
            }
            else /*CMPLX SINGLE_RATE*/
            {
                if(++(*smplsDiscarded) > offset)
                    INTEG_CMPLX_INPUT(smplsInteg,cumSumCmplx , inSigCmplx);
                               
                PROCESS_CMPLX_OUTPUT(cumSumCmplx, outSigCmplx);
                
                if(*smplsInteg == integPeriod)
                    RESET_CMPLX_INTEG(cumSumCmplx, lastIntegralCmplx, smplsInteg);
                       
            }
        }/* SB Complex ends*/
        else /*SB Real begins */
        { 
            real_T* inSigReal    = (real_T*)ssGetInputPortSignal(S, INPORT);
            real_T* outSigReal   = (real_T*)ssGetOutputPortSignal(S, OUTPORT);
            real_T* cumSumReal   = (real_T*) ssGetDWork(S,CUMSUM);

            real_T *lastIntegralReal = (real_T*) ssGetDWork(S, LAST_INTEGRAL);

            if(dumpOutput)/* REAL MULTIRATE*/
            {
                if(ssIsSampleHit(S, inPrtSmplIdx, tid) )
                {
                    if(++(*smplsDiscarded) > offset)
                        INTEG_REAL_INPUT(smplsInteg,cumSumReal,inSigReal);
                   
                   if(*smplsInteg == integPeriod)
                        RESET_REAL_INTEG(cumSumReal,lastIntegralReal, smplsInteg);
                } 
                
                if(ssIsSampleHit(S, outPrtSmplIdx, tid) )
                    PROCESS_REAL_OUTPUT(lastIntegralReal, outSigReal);
                    
            }
            else /*REAL SINGLE_RATE*/
            {
                if(++(*smplsDiscarded) > offset)
                    INTEG_REAL_INPUT(smplsInteg,cumSumReal,inSigReal);
            	
                PROCESS_REAL_OUTPUT(cumSumReal, outSigReal);
                
                if(*smplsInteg == integPeriod)
                    RESET_REAL_INTEG(cumSumReal, lastIntegralReal, smplsInteg);

            }/* end of Real SB Singlerate Processing*/

        }/*end of Real SB processing*/

    } /*End of SB processing*/

}/*end of mdlOutputs*/

static void mdlTerminate(SimStruct *S)
{
    /* Not Used */
}
 
#ifdef  MATLAB_MEX_FILE
#include "simulink.c"
#else
#include "cg_sfun.h"
#endif

