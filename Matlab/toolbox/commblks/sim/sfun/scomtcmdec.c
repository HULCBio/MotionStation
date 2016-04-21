/*
 *   SCOMTCMDEC Communications Blockset S-Function 
 *   for Trellis Coded Modulation(TCM) Decoder
 *
 *   Copyright 1996-2003 The MathWorks, Inc.
 *   $Revision: 1.1.6.3 $  $Date: 2003/12/01 19:00:21 $
 */


#define S_FUNCTION_NAME scomtcmdec
#define S_FUNCTION_LEVEL 2

#include "scomtcmdec.h"

#ifdef MATLAB_MEX_FILE 
/* Function: mdlCheckParameters ========================================= */
#define MDL_CHECK_PARAMETERS 
static void mdlCheckParameters(SimStruct *S) 
{         
    /* Error check in mask */    
    UNUSED_ARG(S);

}/* end of mdlCheckParameters */
#endif 

/* Function: mdlInitializeSizes ========================================= */
static void mdlInitializeSizes(SimStruct *S) 
{ 
    int_T i;

    /* Parameters: */ 
    ssSetNumSFcnParams(S, NUM_ARGS); 

    #if defined(MATLAB_MEX_FILE) 
        if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) return; 
        mdlCheckParameters(S); 
        if (ssGetErrorStatus(S) != NULL) return; 
    #endif 

    /* Cannot change params while running: */
    for( i = 0; i < NUM_ARGS; ++i){
        ssSetSFcnParamNotTunable(S, i);
    }
    
    ssSetNumSampleTimes(S, 1); /* Block-based */ 

    /* Inputs and Outputs */ 
    {
        /* Inputs: */ 
        const boolean_T rstPort = HAS_RST_PORT(S);

        int8_T numInports = (int8_T) rstPort ? 2 : 1;

        if (!ssSetNumInputPorts(S, numInports)) return;

        if(!ssSetInputPortDimensionInfo(S, INPORT_DATA, DYNAMIC_DIMENSION)) return;
        ssSetInputPortFrameData(        S, INPORT_DATA, FRAME_YES);
        ssSetInputPortDirectFeedThrough(S, INPORT_DATA, 1);
        ssSetInputPortReusable(         S, INPORT_DATA, 1);
        ssSetInputPortComplexSignal(    S, INPORT_DATA, COMPLEX_YES);
        ssSetInputPortRequiredContiguous(S, INPORT_DATA, 1);

        if (rstPort) 
        {
            ssSetInputPortMatrixDimensions(  S, INPORT_RESET, 1, 1);
            ssSetInputPortFrameData(         S, INPORT_RESET, FRAME_YES);
            ssSetInputPortDirectFeedThrough( S, INPORT_RESET, 1);
            ssSetInputPortReusable(          S, INPORT_RESET, 1);
            ssSetInputPortComplexSignal(     S, INPORT_RESET, COMPLEX_NO);
            ssSetInputPortRequiredContiguous(S, INPORT_RESET, 1);
        }

        /* Outputs: */ 
        if (!ssSetNumOutputPorts(S,1)) return; 
        if(!ssSetOutputPortDimensionInfo(S, OUTPORT_DATA, DYNAMIC_DIMENSION)) return;
        ssSetOutputPortFrameData(        S, OUTPORT_DATA, FRAME_YES);
        ssSetOutputPortComplexSignal(    S, OUTPORT_DATA, COMPLEX_NO);
        ssSetOutputPortReusable(         S, OUTPORT_DATA, 1);
        
        if (!ssSetNumDWork(S, DYNAMICALLY_SIZED)) return;
        
        ssSetOptions(       S, SS_OPTION_EXCEPTION_FREE_CODE |
                               SS_OPTION_REQ_INPUT_SAMPLE_TIME_MATCH);
    }
}


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
}

#ifdef MATLAB_MEX_FILE

/* Function: mdlSetWorkWidths =========================================== */
#define MDL_SET_WORK_WIDTHS
static void mdlSetWorkWidths(SimStruct *S)
{        
/*
     *  This is where we allocate work variables
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
     * NXTST        : Stores the next states matrix for the 
     *                trellis
     *               "nxtSt" units of storage
     * OUTPUTS      : Stores the outputs matrix for the trellis
     *               "nxtSt" units of storage
     *
     */
    
    const int32_T  n          = (int32_T)(mxGetPr(TRELLIS_OUT_NUMBITS_ARG(S))[0]);          
    const int_T    tbLen      = (int_T)(mxGetPr(TB_ARG(S))[0]);
    const uint32_T numStates  = (uint32_T)(mxGetPr(TRELLIS_NUM_STATES_ARG(S))[0]);
    const uint32_T nxtSt      = (uint32_T) mxGetNumberOfElements(TRELLIS_NEXT_STATE_ARG(S));
    
    ssSetNumDWork(S, NUM_DWORK);
    
    ssSetDWorkWidth(        S, BMETRIC, 1<<n);
    ssSetDWorkDataType(     S, BMETRIC, SS_DOUBLE);
    ssSetDWorkComplexSignal(S, BMETRIC, COMPLEX_NO);

    ssSetDWorkWidth(        S, STATE_METRIC, numStates);
    ssSetDWorkDataType(     S, STATE_METRIC, SS_DOUBLE);
    ssSetDWorkComplexSignal(S, STATE_METRIC, COMPLEX_NO);

    ssSetDWorkWidth(        S, TEMP_METRIC, numStates);
    ssSetDWorkDataType(     S, TEMP_METRIC, SS_DOUBLE);
    ssSetDWorkComplexSignal(S, TEMP_METRIC, COMPLEX_NO);

    ssSetDWorkWidth(        S, TBSTATE, numStates*(tbLen + 1));
    ssSetDWorkDataType(     S, TBSTATE, SS_UINT32);
    ssSetDWorkComplexSignal(S, TBSTATE, COMPLEX_NO);

    ssSetDWorkWidth(        S, TBINPUT, numStates*(tbLen + 1));
    ssSetDWorkDataType(     S, TBINPUT, SS_UINT32);
    ssSetDWorkComplexSignal(S, TBINPUT, COMPLEX_NO);

    ssSetDWorkWidth(        S, TBPTR, 1);
    ssSetDWorkDataType(     S, TBPTR, SS_INT32);
    ssSetDWorkComplexSignal(S, TBPTR, COMPLEX_NO);

    ssSetDWorkWidth(        S, NXTST, nxtSt);
    ssSetDWorkDataType(     S, NXTST, SS_UINT32);
    ssSetDWorkComplexSignal(S, NXTST, COMPLEX_NO);

    ssSetDWorkWidth(        S, ENCOUT, nxtSt);
    ssSetDWorkDataType(     S, ENCOUT, SS_UINT32);
    ssSetDWorkComplexSignal(S, ENCOUT, COMPLEX_NO);


}
#endif
  
/* Function: rstInitCond ================================================= */
static void rstInitCond(uint32_T    numStates, 
                        real_T     *pStateMet,
                        uint32_T   *pTbState,
                        uint32_T   *pTbInput,
                        int_T       tbLen)
{

    uint32_T i;
    /*
     * Set all state metrics equal to zero
     */
    for(i = 0; i <numStates ; i++) 
    {
        pStateMet[i] = 0.0;
    }
    
    /* Set traceback memory to zero */
    for(i = 0; i < numStates*((int_T) tbLen + 1); i++) 
    {
        pTbInput[i] = 0;
        pTbState[i] = 0;
    }

}

/* Function: mdlInitializeConditions ==================================== */
#define MDL_INITIALIZE_CONDITIONS
static void mdlInitializeConditions(SimStruct *S)
{ 

    uint32_T i;
    int_T    tbLen          = (int_T) mxGetPr(TB_ARG(S))[0];
    uint32_T numStates      = (uint32_T)(mxGetPr(TRELLIS_NUM_STATES_ARG(S))[0]);
    const uint32_T nxtStEl  = (uint32_T) mxGetNumberOfElements(TRELLIS_NEXT_STATE_ARG(S));

    const real_T *pNxtStMask  =  mxGetPr(TRELLIS_NEXT_STATE_ARG(S));
    const real_T *pEncOutMask =  mxGetPr(TRELLIS_OUTPUT_ARG(S));
        
    real_T    *pStateMet = (real_T *) ssGetDWork(S, STATE_METRIC);
    uint32_T  *pNxtSt    = (uint32_T *) ssGetDWork(S, NXTST);
    uint32_T  *pEncOut   = (uint32_T *) ssGetDWork(S, ENCOUT);
    uint32_T  *pTbState  = (uint32_T *) ssGetDWork(S, TBSTATE);
    uint32_T  *pTbInput  = (uint32_T *) ssGetDWork(S, TBINPUT);

    /* Initialize the work vectors */
    rstInitCond(numStates, pStateMet, pTbState, pTbInput, tbLen); 
    
    /* Initialize next states and encoded outputs work vectors*/
    for(i=0; i<nxtStEl; i++)
    {
        pNxtSt[i]  = (uint32_T) pNxtStMask[i];
        pEncOut[i] = (uint32_T) pEncOutMask[i];
    }
    
}


/* Function: branchMetricComp ============================================ */
static void branchMetricComp(const int32_T  n,      
                                   real_T  *pBMet, 
                             const real_T  *sigReal, 
                             const real_T  *sigImag,
                                   creal_T *thisBlockIn)
{
    uint32_T indx1;
    /* 
	 * Compute the Euclidean distance between the received signal and all the possible 
     * constellation points (number of constellation points = 1 << n)
     * specified in mask 
     */
    for(indx1=0; indx1<(uint32_T)(1<<n); indx1++) 
    {
        pBMet[indx1] = pow(sigReal[indx1]-thisBlockIn[0].re,2)+pow(sigImag[indx1]-thisBlockIn[0].im,2);
    }


}

/* Function: mdlOutputs ================================================= */
static void mdlOutputs(SimStruct *S, int_T tid)
{
/*  This is the main body of the TCM Decoder
 *  
 *  The algorithm has three main steps:
 *      1.  Branch metric computation
 *      2.  State metric update (ACS)
 *      3.  Traceback decoding
 *
 */
    const boolean_T rstPort    = HAS_RST_PORT(S);
    const uint32_T  numStates  = (uint32_T)(mxGetPr(TRELLIS_NUM_STATES_ARG(S))[0]);
    const int32_T   k          = (int32_T)(mxGetPr(TRELLIS_IN_NUMBITS_ARG(S))[0]);
    const int32_T   n          = (int32_T)(mxGetPr(TRELLIS_OUT_NUMBITS_ARG(S))[0]);
    const int_T     tbLen      = (int_T) mxGetPr(TB_ARG(S))[0];
    const int_T     opmode     = (int_T) mxGetPr(OPMODE_ARG(S))[0];
    const boolean_T isContMode = (boolean_T) IS_CONT_MODE(S);

          
    const real_T    *sigReal   = mxGetPr(REAL_SIG_PTS_ARG(S));
    const real_T    *sigImag   = mxGetPr(IMAG_SIG_PTS_ARG(S));

    real_T          *y         = (real_T *) ssGetOutputPortSignal(S,0); 
    real_T          *pBMet     = (real_T *) ssGetDWork(S, BMETRIC);
    real_T          *pTempMet  = (real_T *) ssGetDWork(S, TEMP_METRIC);
    real_T          *pStateMet = (real_T *) ssGetDWork(S, STATE_METRIC);
    uint32_T        *pTbState  = (uint32_T *) ssGetDWork(S, TBSTATE);
    uint32_T        *pTbInput  = (uint32_T *) ssGetDWork(S, TBINPUT);
    uint32_T        *pNxtSt    = (uint32_T *) ssGetDWork(S, NXTST);
    uint32_T        *pEncOut   = (uint32_T *) ssGetDWork(S, ENCOUT);
    
    int_T           *pTbPtr    = (int_T *) ssGetDWork(S, TBPTR);

    creal_T         *rec_sig   = (creal_T *) ssGetInputPortSignal(S,0); 

	
    /* Number of symbols in each input frame */
    int_T    blockSize  = ssGetInputPortWidth(S, INPORT_DATA); 

    /* Get reset value if reset port is present */
    real_T   *pRstIn    = (!rstPort) ? NULL :
                          (real_T *) ssGetInputPortSignal(S,INPORT_RESET);

    uint32_T minStateLastTB, minState=0;
    int_T    tbWorkLastTB, ib;


    /* 
     * TRUNC and TERM modes : Reset such that every frame is independent 
     * CONT mode :            Reset if requested
     */
    if (!isContMode || (rstPort && pRstIn[0] != 0.0))
    { 
        rstInitCond(numStates, pStateMet, pTbState, pTbInput, tbLen);
    }

    /*
     * Branch metric computation 
     */

    for(ib = 0; ib < blockSize; ++ib)
    {
        int_T    indx1; 
        real_T   *thisBlockOut;
        int_T    alpha = (1<<k);
        creal_T  *thisBlockIn;
        int_T    input;
        int_T    cOffset       =  ib;
        int_T    uOffset;
              
        if(isContMode)
        {   /* CONTINUOUS mode */
            uOffset   = ib  * k;
        }
        else
        {  /* TRUNCATED or TERMINATED modes */
            /* 
             * Skip output indexing by (blockSize - tbLen) blocks.
             * Compute metrics and TB tables but do no decoding for 
             * the blocks until the end of output buffer
             */
            uOffset   = ((ib - tbLen)%blockSize)*k;
        }

        /* thisBlockIn is a temporary pointer pointing to an 
         * offset of the input vector pointer, thisBlockOut is 
         * a temporary pointer pointing to an offset of the 
         * output vector pointer
         */
        thisBlockIn  = rec_sig  + cOffset;
        thisBlockOut = y + uOffset;

        branchMetricComp(n, pBMet, sigReal, sigImag, thisBlockIn);
	
        minState = addCompareSelect(numStates, pTempMet, alpha, pBMet,
                                    pStateMet, pTbState, pTbInput,
                                    pTbPtr, pNxtSt, pEncOut);

        /* TERMINATED mode : */
        /* Start the final traceback path at the zero state for teminated mode */
        if (opmode == TERM && ib == blockSize - 1)
        {		
            minState = 0;					
        }
       
        input = tracebackDecoding(pTbPtr, minState,
                                  tbLen, pTbInput, pTbState, numStates);

        /* Store the output if its Continuous mode or if ib > tbLen
         * Truncated, Terminated and Continuous mode store the exact
         * values in thisBlockOut for ib >= tbLen
         */
        if ((isContMode) || (ib >= tbLen))
        {
            /* Converts integer to binary */
            for(indx1=0; indx1<k; indx1++) 
            {
                thisBlockOut[k-1-indx1] = input&01;
                input >>= 1;
            }
        }

    } /* end of ib loop */

    /* 
     * Capture starting minState and starting tbwork of the 
     * last ib loop. minStateLastTB stores the current minState,
     * tbWorkLastTB points to pTbPtr which points to the 
     * column location of the pTbState in the traceback decoding
     * pTbState can be thought os as a matrix with numStates number
     * of rows and tbLen number of columns
     */
    minStateLastTB = minState;
    tbWorkLastTB   = (pTbPtr[0]!=0) ? pTbPtr[0]-1 : tbLen;

    /* 
     * Truncated or Teminated mode :
     * 
     * The output vector has been filled from the beginning till tbLen*k
     * locations. The tbLen*k locations will get filled in this block of code
     * working our way back from the very last location and moving upwards. 
     */
    if(!isContMode)
    {
        int_T  indx1, indx2, input;
        real_T *thisBlockOut;


        for (indx1 = 0; indx1 < tbLen; indx1 ++)
        {
            thisBlockOut = y + (blockSize-1-indx1)*k;
            input        = pTbInput[minStateLastTB+(tbWorkLastTB*numStates)];
            
            /* Converts integer to binary */
            for (indx2=0; indx2<k; indx2++) 
            {
                thisBlockOut[k-1-indx2] = input&01;		
                input >>= 1;
            }
            minStateLastTB = pTbState[minStateLastTB+(tbWorkLastTB*numStates)];
            tbWorkLastTB = (tbWorkLastTB > 0) ? tbWorkLastTB-1 : tbLen;
        }
    }  

}  /*  end of mdlOutputs  */


/* Function: mdlTerminate =============================================== */
static void mdlTerminate(SimStruct *S)
{
     UNUSED_ARG(S);
}


#ifdef MATLAB_MEX_FILE
/* Function: mdlSetInputPortDimensionInfo =============================== */
#define MDL_SET_INPUT_PORT_DIMENSION_INFO
static void mdlSetInputPortDimensionInfo(SimStruct        *S, 
                                         int_T            port,
                                         const DimsInfo_T *dimsInfo)
{
    
    if(!ssSetInputPortDimensionInfo(S, port, dimsInfo))
        return;
    {
        /*Check for input port dimension and set output port dimension */
        const int_T numDims = ssGetInputPortNumDimensions(S, port);
        const int_T inRows  = (numDims >= 1) ? dimsInfo->dims[0] : 0;
        const int_T inCols  = (numDims >= 2) ? dimsInfo->dims[1] : 0;

        if ( (numDims == 2) && (inCols != 1) )
        {
            THROW_ERROR(S, "Invalid dimensions are specified for the input "
                           "or output port(s). This block does not "
                           "support matrix signals having multiple columns.");
        }
   
        if(port == INPORT_DATA)
        {
        
            int_T outCols, outRows;

            int_T alpha      = mxGetNumberOfElements(REAL_SIG_PTS_ARG(S));
            int_T alphaBase2 = (int_T) (log10(alpha)/log10(2));

            /* The number of input(coded and uncoded) and output bits 
             * are derived from the  trellis and refer to n & k respectively
             */
            const int32_T numOutBits  = (int)(mxGetPr(TRELLIS_OUT_NUMBITS_ARG(S))[0]);
            const int32_T numInBits   = (int)(mxGetPr(TRELLIS_IN_NUMBITS_ARG(S))[0]);

            int_T blockSize  = (int_T) ssGetInputPortWidth(S, INPORT_DATA)/numOutBits;
           
            const int_T    tbLen       = (int_T)(mxGetPr(TB_ARG(S))[0]);
            const boolean_T isContMode = (boolean_T) IS_CONT_MODE(S);

            if(fmod(inRows, (numOutBits/alphaBase2))!=0)
            {
                THROW_ERROR(S,"Invalid frame length specified for the data "
                              "input port. The input frame length must be an "
                              "integer multiple of the number of output bits "
                              "specified in the trellis description.");
            }

            /* Error checking for traceback depth -- not to exceed number of symbols */  
            if(!isContMode && tbLen > blockSize)
            {   /* if trunc or term modes */
                
                THROW_ERROR(S, "The Traceback depth parameter "
                               "cannot exceed the number "
                               "of symbols in the input frame.");
      
                
            }

            /* The output dimension depends on input dimension and input 
             * number of bits into the Convolutional Encoder 
             */
            outRows = inRows*numInBits;
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
                    THROW_ERROR(S, "Invalid dimensions are specified for the input "
                                   "or output port(s).");
                }
            }
        } /* end if(port == INPORT_DATA) */

     
    }/* end of scope */

}

/* Function: mdlSetOutputPortDimensionInfo =============================== */
# define MDL_SET_OUTPUT_PORT_DIMENSION_INFO
static void mdlSetOutputPortDimensionInfo(SimStruct        *S, 
                                          int_T            port,
                                          const DimsInfo_T *dimsInfo)
{

    int_T inCols, inRows;
        
   /* The number of input(coded and uncoded) and output bits 
    * are derived from the  trellis and refer to n & k respectively
    */
    const int32_T numInBits   = (int)(mxGetPr(TRELLIS_IN_NUMBITS_ARG(S))[0]);

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

        if(fmod(outRows, numInBits)!=0)
        {
            THROW_ERROR(S,"Invalid frame length specified for the "
                          "output port. The output frame length must be an "
                          "integer multiple of the number of input bits "
                          "specified in the trellis description.");
        }

        
        /* The output dimension depends on input dimension and input 
         * number of bits into the Convolutional Encoder 
         */
        inCols = outCols;
        inRows = outRows/numInBits;

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

    } /* end of scope */

} /* end of mdlSetOutputPortDimensionInfo */    

/* Function: mdlSetDefaultPortDimensionInfo =============================== */
#define MDL_SET_DEFAULT_PORT_DIMENSION_INFO
static void mdlSetDefaultPortDimensionInfo(SimStruct *S)
{
    const int32_T numInBits   = (int32_T)(mxGetPr(TRELLIS_IN_NUMBITS_ARG(S))[0]);
    /* Initialize a dynamically-dimensioned acceptable DimsInfo_T */
    DECL_AND_INIT_DIMSINFO(dInfo);
    int_T dimsOut[2];
	dimsOut[1] = numInBits;
	dimsOut[2] = 1;

	dInfo.width       = 1;
    dInfo.numDims     = 2;
    dInfo.dims        = dimsOut;

    /* Call the output port dimension function */
    if(ssGetOutputPortWidth(S, OUTPORT_DATA) == DYNAMICALLY_SIZED)
    {
        mdlSetOutputPortDimensionInfo(S, OUTPORT_DATA, &dInfo);
    }
}

#endif

#ifdef  MATLAB_MEX_FILE    
#include "simulink.c"      
#else
#include "cg_sfun.h"       
#endif


