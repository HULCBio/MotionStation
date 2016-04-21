/*
 *  SCOMFSKMOD Communications Blockset S-Function for MFSK modulation.
 *
 *  Copyright 1996-2003 The MathWorks, Inc.
 *  $Revision: 1.12.4.2 $  $Date: 2004/04/12 23:03:24 $
 */

#define S_FUNCTION_NAME scomfskmod
#define S_FUNCTION_LEVEL 2

#include "comm_defs.h"

/* List input & output ports*/
enum {INPORT=0, NUM_INPORTS};
enum {OUTPORT=0, NUM_OUTPORTS};

/* List Work Vectors */
enum {INPUT_LOOKUP=0, OUTPUT_LOOKUP, PREV_PHASE, PHASE_INCREMENT, OSC_PHASE, OUTPUT_INDEX, NUM_DWORK};

/* List the mask parameters*/
enum {
		M_ARYC=0, 
        IN_TYPEC, 
        MAPPINGC, 
        FREQ_SEPC,
        PHASE_TYPEC,
        NUM_SAMPC,  
        NUM_ARGS
};

#define M_ARY                   (ssGetSFcnParam(S,M_ARYC))
#define IN_TYPE                 (ssGetSFcnParam(S,IN_TYPEC))
#define MAPPING                 (ssGetSFcnParam(S,MAPPINGC))
#define FREQ_SEP                (ssGetSFcnParam(S,FREQ_SEPC))
#define PHASE_TYPE              (ssGetSFcnParam(S,PHASE_TYPEC))
#define NUM_SAMP                (ssGetSFcnParam(S,NUM_SAMPC))


/*Define variables representing parameter values*/
enum {BIT_INPUT=1, INTEGER_INPUT};
enum {BINARY_MAP=1, GRAY_MAP};
enum {CONTINUOUS_PHASE=1, DISCONTINUOUS_PHASE};

#define IS_INTEGER_INPUT        ((int_T)mxGetPr(IN_TYPE)[0] == INTEGER_INPUT)
#define IS_BIT_INPUT            ((int_T)mxGetPr(IN_TYPE)[0] == BIT_INPUT)
#define IS_BINARY_MAP           ((int_T)mxGetPr(MAPPING)[0] == BINARY_MAP)
#define IS_GRAY_MAP             ((int_T)mxGetPr(MAPPING)[0] == GRAY_MAP)

#define OPERATION_MODE          (int_T)mxGetPr(FRAMING)[0]
#define INPUT_TYPE              (int_T)mxGetPr(IN_TYPE)[0]
#define PHASE_CONTINUITY        (int_T)mxGetPr(PHASE_TYPE)[0]

/* Function to compute the index for the input symbol */
static void setIndex(SimStruct *S)
{
    real_T                  *uin            = (real_T *)ssGetInputPortRealSignal(S, INPORT);
    int_T                   *lookup         = (int_T *)ssGetDWork(S, INPUT_LOOKUP);
    const int_T             inFramebased    = ssGetInputPortFrameData(S,INPORT);
    const int_T             SampPerSym      = (int_T)mxGetPr(NUM_SAMP)[0];
    const int_T             InPortWidth     = ssGetInputPortWidth(S, INPORT);
    const int_T             M               = (int_T)mxGetPr(M_ARY)[0];
    
    real_T u = 0.0, phase = 0.0; 
    int_T  i = 0, j = 0, nbits = 0, SamplesPerInputFrame = 0,SymbolIndex = 0;
    int_T uconv = 0, y1 = 0, y0 = 0; 
    frexp((real_T)M, &nbits);
    nbits = nbits - 1;      /* nbits now has a value of number of bits per symbol */
    
    SamplesPerInputFrame  = (IS_INTEGER_INPUT)  ? InPortWidth : InPortWidth/nbits;
    
    /* For each input sample, compute the index for the symbol mapping table
    *  For Bit input convert a vector of bits into an integer taking into 
    *  account Gray mapping.
    *  For Integer input the index equals the input values */
    for (i = 0; i < SamplesPerInputFrame; i++)
    {
        SymbolIndex = 0;
        switch (INPUT_TYPE) 
        {
        case BIT_INPUT: 
            {
            /* In case of Bit input, convert the bits 
                to a binary mapped integer. */
                int_T m;
                for (m = 0; m < nbits; m++)
                {
                    SymbolIndex<<=1;
                    u = *uin++;

#ifdef MATLAB_MEX_FILE
                    if((u != 0) && (u != 1))
                    {
                        THROW_ERROR(S,"Input must be binary.");
                    }
#endif
                    SymbolIndex+= (int32_T)u;
                }
                
                if (IS_GRAY_MAP)
                {
                    int_T g;
                    for (g = 1; g < nbits; g+=g)
                    {
                        SymbolIndex^=SymbolIndex>>g;
                    }
                }
            }
            break;
        case INTEGER_INPUT: /* Integer Input */
            {
                u         = *uin++;
#ifdef MATLAB_MEX_FILE
                if ((u != floor(u)) || (u > (M-1)) || (u < 0.0))
                {
                    THROW_ERROR(S,"Input must be an integer in the range of 0 to M-1.");
                }
#endif
                SymbolIndex = (int32_T)u;
            }
            break;
        default:
            THROW_ERROR(S,"Invalid input type.");   
        }
        *lookup++ = SymbolIndex;
    }
}


/* Function: mdlCheckParameters ===============================================*/
#ifdef MATLAB_MEX_FILE
#define MDL_CHECK_PARAMETERS
static void mdlCheckParameters(SimStruct *S) 
{
    /*---Check to see if the Input type parameter is either 1 or 2 ------*/
    if (!IS_FLINT_IN_RANGE(IN_TYPE,1,2))
    {
        THROW_ERROR(S,"Input type parameter is outside of expected range.");
    }
    
    /*---Check to see if the Bit to symbol mapping parameter is either 1 or 2 ----*/
    if (!IS_FLINT_IN_RANGE(MAPPING,1,2))
    {
        THROW_ERROR(S,"Bit to symbol mapping parameter is outside of expected range.");
    }

	 /*---Check to see if the Phase continuity parameter is either 1 or 2 ----*/
    if (!IS_FLINT_IN_RANGE(PHASE_TYPE,1,2))
    {
        THROW_ERROR(S,"Phase continuity parameter is outside of expected range.");
    }
    
    /*---Check the M-ARY number parameter-----------*/
    /*---For bit input check if M is a scalar which is an integer power of 2---*/
    
    if (OK_TO_CHECK_VAR(S, M_ARY))
    {
		if (!mxIsEmpty(M_ARY))
		{
			int_T nbits = 0;
			const int_T M = (int_T) mxGetPr(M_ARY)[0];
        
			switch (INPUT_TYPE) 
			{
			case BIT_INPUT: /*For bit input check if M is a scalar which is an integer power of 2*/
				{
					if ((!IS_FLINT_GE(M_ARY, 2)) || (frexp((real_T)M, &nbits) != 0.5)
						|| (mxIsEmpty(M_ARY))) 
					{
						THROW_ERROR(S, "In case of Bit type input M-ary number parameter must be a scalar positive real integer value which is a non-zero power of two.");
					}
				}
				break;
			case INTEGER_INPUT: /*For integer input check if M is a positive scalar integer*/
				{
					if ((!IS_FLINT_GE(M_ARY,2)) || (mxIsEmpty(M_ARY)))
					{
						THROW_ERROR(S," M-ary number parameter must be a scalar positive integer value.");
					}
				}
				break;
			default:
				THROW_ERROR(S,"Invalid input type.");
			}
		}
		else
		{
			switch (INPUT_TYPE) 
			{
				case BIT_INPUT: 
					{
						THROW_ERROR(S, "In case of Bit type input M-ary number parameter must be a scalar positive real integer value which is a non-zero power of two.");
					}
					break;
				case INTEGER_INPUT:	
					{ 
						THROW_ERROR(S," M-ary number parameter must be a scalar positive integer value.");
					}
					break;
				default:
						THROW_ERROR(S,"Invalid input type.");
			}
		}
    }


	/* Check to see if the Frequency separation parameter is a positive integer value*/
    if (OK_TO_CHECK_VAR(S, FREQ_SEP)) 
    {
		if (!mxIsEmpty(FREQ_SEP))
		{
			if ((!IS_SCALAR_DOUBLE(FREQ_SEP)) || (mxIsEmpty(FREQ_SEP)))
			{
				THROW_ERROR(S, "Frequency separation parameter must be a scalar positive real value");
			}
		}
		else
		{
			THROW_ERROR(S, "Frequency separation parameter must be a scalar positive real value");
		}
    }
    
    
    /* Check to see if the Samples per symbol parameter is a positive integer value*/
    if (OK_TO_CHECK_VAR(S, NUM_SAMP)) 
    {
		if (!mxIsEmpty(NUM_SAMP))
		{
			if ((!IS_FLINT_GE(NUM_SAMP, 1)) || (mxIsEmpty(NUM_SAMP)))
			{
				THROW_ERROR(S, "Samples per symbol parameter must be a scalar positive real integer value");
			}
		}
		else
		{
			THROW_ERROR(S, "Samples per symbol parameter must be a scalar positive real integer value");
		}
    }
    
    /* end mdlCheckParameters */
}
#endif


/* Function: mdlInitializeSizes ===============================================*/

static void mdlInitializeSizes(SimStruct *S)
{
    ssSetNumSFcnParams(S, NUM_ARGS);
    
#if defined(MATLAB_MEX_FILE)
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) return;
    mdlCheckParameters(S);
    if (ssGetErrorStatus(S) != NULL) return;
#endif
    
    ssSetNumSampleTimes(S, PORT_BASED_SAMPLE_TIMES);
    
    /* Input: */
    if (!ssSetNumInputPorts(S, NUM_INPORTS)) return;
    if (!ssSetInputPortDimensionInfo(S, INPORT, DYNAMIC_DIMENSION)) return;            
    ssSetInputPortFrameData(         S, INPORT, FRAME_INHERITED);
    ssSetInputPortDirectFeedThrough( S, INPORT, 1);
    ssSetInputPortComplexSignal(     S, INPORT, COMPLEX_NO);
    ssSetInputPortReusable(          S, INPORT, 0);
    ssSetInputPortRequiredContiguous(S, INPORT, 1);
    ssSetInputPortSampleTime(        S, INPORT,  INHERITED_SAMPLE_TIME);
    
    /* Output: */
    if (!ssSetNumOutputPorts(S,NUM_OUTPORTS)) return;
    if (!ssSetOutputPortDimensionInfo(S, OUTPORT, DYNAMIC_DIMENSION)) return;
    ssSetOutputPortFrameData(         S, OUTPORT, FRAME_INHERITED);
    ssSetOutputPortComplexSignal(     S, OUTPORT, COMPLEX_YES);
    ssSetOutputPortReusable(          S, OUTPORT, 0);
    ssSetOutputPortSampleTime(        S, OUTPORT, INHERITED_SAMPLE_TIME);
    
    if (!ssSetNumDWork(S, DYNAMICALLY_SIZED)) return;
    
    ssSetOptions( S, SS_OPTION_EXCEPTION_FREE_CODE);
    
    ssSetSFcnParamNotTunable(S, IN_TYPEC);
    ssSetSFcnParamNotTunable(S, M_ARYC);
    ssSetSFcnParamNotTunable(S, MAPPINGC);
    ssSetSFcnParamNotTunable(S, NUM_SAMPC);
    ssSetSFcnParamNotTunable(S, FREQ_SEPC);
    ssSetSFcnParamNotTunable(S, PHASE_TYPEC);
}
/* End of mdlInitializeSizes(SimStruct *S) */

/* Function: mdlInitializeSampleTimes =========================================*/
static void mdlInitializeSampleTimes(SimStruct *S)
{
#if defined(MATLAB_MEX_FILE)
    const real_T Tsi = ssGetInputPortSampleTime(S, INPORT);
    const real_T Tso = ssGetOutputPortSampleTime(S, OUTPORT);
    
    if ((Tsi == INHERITED_SAMPLE_TIME)  ||
        (Tso == INHERITED_SAMPLE_TIME)   ) 
    {
        THROW_ERROR(S,"Sample time propagation failed.");
    }
    
    if ((ssGetOutputPortWidth(S,OUTPORT) == DYNAMICALLY_SIZED)  ||
        (ssGetInputPortWidth( S,INPORT ) == DYNAMICALLY_SIZED)   ) 
    {
        THROW_ERROR(S,"Port width propagation failed.");
    }
    
    ssSetModelReferenceSampleTimeInheritanceRule(S,	DISALLOW_SAMPLE_TIME_INHERITANCE);

#endif
}

/* Function: mdlInitializeConditions ========================================*/

#define MDL_INITIALIZE_CONDITIONS
static void mdlInitializeConditions(SimStruct *S)
{
    /* Initialize the phase of all M oscillators to zero*/
    const int_T     SampPerSym      = ( int_T)mxGetPr(NUM_SAMP)[0];
    const int_T     M               = ( int_T)mxGetPr(M_ARY)[0];
    const real_T    freqSep         = (real_T)mxGetPr(FREQ_SEP)[0];
    
    real_T          *prevPhase      = (real_T *)ssGetDWork(S, PREV_PHASE);
    real_T          *phaseIncr      = (real_T *)ssGetDWork(S, PHASE_INCREMENT);
    real_T          *oscPhase       = (real_T *)ssGetDWork(S, OSC_PHASE);
    int_T           *outIdx         = ( int_T *)ssGetDWork(S, OUTPUT_INDEX);
    real_T          sampletime      = (real_T)ssGetInputPortSampleTime(S, INPORT);
    const int_T     InPortWidth     = ssGetInputPortWidth(S, INPORT);
    const int_T     inFramebased    = ssGetInputPortFrameData(S,INPORT);
    

    int_T   i1,nbits=0;
    
	frexp((real_T)M, &nbits);
	nbits = nbits - 1;    

    if (inFramebased)
    {   
        sampletime = sampletime / InPortWidth;

      if (IS_BIT_INPUT)
      {
          sampletime = sampletime * nbits;
      }

    }
  
    for (i1 = 0; i1 < M; i1++)
    {
        *oscPhase++ = 0.0;
        *phaseIncr++ = DSP_PI*freqSep*sampletime*((real_T) -M+1+2*i1)/(real_T) SampPerSym;
    }
    
    *prevPhase = 0.0;
    *outIdx = 0;    
}

/* Function: mdlProcessParameters ===========================================*/
#define MDL_PROCESS_PARAMETERS   
static void mdlProcessParameters(SimStruct *S)
{
}

/* Function: mdlStart =======================================================*/

#define MDL_START
static void mdlStart (SimStruct *S)
{
}
/* End of mdlStart (SimStruct *S) */

/* Function: mdlOutputs =======================================================*/
static void mdlOutputs(SimStruct *S, int_T tid)
{
    const int_T     inFramebased    = ssGetInputPortFrameData(S,INPORT);
    const int_T     SampPerSym      = (int_T)mxGetPr(NUM_SAMP)[0];
    const int_T     InPortWidth     = ssGetInputPortWidth(S, INPORT);
    const int_T     M               = (int_T)mxGetPr(M_ARY)[0];
    int_T i = 0, nbits = 0;
    int_T SamplesPerInputFrame;
    int_T  *inSym      = (int_T *)ssGetDWork(S, INPUT_LOOKUP);
    creal_T *outSamp   = (creal_T *)ssGetDWork(S, OUTPUT_LOOKUP);
    real_T  *prevPhase = (real_T *)ssGetDWork(S, PREV_PHASE);
    real_T  *phaseIncr = (real_T *)ssGetDWork(S, PHASE_INCREMENT);
    real_T  *oscPhase  = (real_T *)ssGetDWork(S, OSC_PHASE);
    int_T i1,i2,i3;
    real_T initPhase, phase_inc, phase;
    
    
    frexp((real_T)M, &nbits);  /*---Compute log2(M) for bit input---*/
    nbits = nbits - 1;/* This is the value of the number of bits per symbol*/
    
    SamplesPerInputFrame            = (IS_INTEGER_INPUT) ? InPortWidth : InPortWidth/nbits;
    
    if (!inFramebased)   /*---Sample based inputs---*/
    {
        const int_T     OutportTid     = ssGetOutputPortSampleTimeIndex(S, OUTPORT);
        const int_T     InportTid      = ssGetInputPortSampleTimeIndex(S, INPORT);
        
        if(ssIsSampleHit(S, InportTid, tid))
        {   
            
            setIndex(S);
            
            switch (PHASE_CONTINUITY)
            {
            case CONTINUOUS_PHASE:
                initPhase = *prevPhase;
                break;
            case DISCONTINUOUS_PHASE: 
                initPhase = oscPhase[*inSym];
                break;
            default:
                THROW_ERROR(S,"Invalid option.");                
            }
            
            phase = initPhase;
            phase_inc = phaseIncr[*inSym];
            
            for (i2 = 0; i2 < SampPerSym; i2++)
            {
            (outSamp)->re   = cos(phase);
            (outSamp++)->im = sin(phase);
            phase += phase_inc;
            }
       
            /* update ending phase for all M oscillators */
            for (i3 = 0; i3 < M; i3++)
            {
            oscPhase[i3] += phaseIncr[i3] * SampPerSym;
            if(oscPhase[i3] >= DSP_TWO_PI) oscPhase[i3] -= DSP_TWO_PI;
            }
            
            /* update initial phase for next symbol */
            switch (PHASE_CONTINUITY)
            {
            case CONTINUOUS_PHASE:
                initPhase = phase;
            	break;
            case DISCONTINUOUS_PHASE:
                initPhase = oscPhase[*inSym];
            	break;
            default:
                THROW_ERROR(S,"Invalid option.");                
            }
            *prevPhase = phase;
        }
        
        if(ssIsSampleHit(S, OutportTid, tid)) 
        {
            creal_T  *y   = (creal_T *)ssGetOutputPortSignal(S, OUTPORT);
            creal_T  *outSamp = (creal_T *)ssGetDWork(S, OUTPUT_LOOKUP);
            int_T    *idx = (int_T *)ssGetDWork(S, OUTPUT_INDEX);
            
            /* increment pointer to current output sample */
            outSamp += *idx;
            
            /* output current complex sample */
            (y)->re = outSamp->re;
            (y)->im = outSamp->im;
            
            /* increment output sample index modulo number of samples per symbol */
            *idx = *idx+1;
            if(*idx==(SamplesPerInputFrame * SampPerSym)) *idx = 0;
        }
        
    }
    else   /* Frame-based inputs */
    {
        creal_T  *y       = (creal_T *)ssGetOutputPortSignal(S, OUTPORT);
        creal_T  *out_sym = (creal_T *)ssGetDWork(S, OUTPUT_LOOKUP);
        
        setIndex(S);    
        
            switch (PHASE_CONTINUITY)
            {
            case CONTINUOUS_PHASE:
                initPhase = *prevPhase;
                break;
            case DISCONTINUOUS_PHASE: 
                initPhase = oscPhase[*inSym];
                break;
            default:
                THROW_ERROR(S,"Invalid option.");                
            }
            
            for (i1 = 0; i1 < SamplesPerInputFrame; i1++)
            { 
                phase = initPhase;
                phase_inc = phaseIncr[*inSym];
                
                for (i2 = 0; i2 < SampPerSym; i2++)
                {
                    (outSamp)->re   = cos(phase);
                    (outSamp++)->im = sin(phase);
                    phase += phase_inc;
                }
                /* increment input symbol pointer */
                inSym++;
                
                /* update ending phase for all M oscillators */
                for (i3 = 0; i3 < M; i3++)
                {
                    oscPhase[i3] += phaseIncr[i3] * SampPerSym;
                    if(oscPhase[i3] >= DSP_TWO_PI) oscPhase[i3] -= DSP_TWO_PI;
                }
                
                /* update initial phase for next symbol */
                switch (PHASE_CONTINUITY)
                {
				case CONTINUOUS_PHASE:
					initPhase = phase;
					break;
				case DISCONTINUOUS_PHASE:
					initPhase = oscPhase[*inSym];
					break;
                default:
                    THROW_ERROR(S,"Invalid option.");                
                }
            }
            *prevPhase = phase;

        for (i = 0; i < (SamplesPerInputFrame * SampPerSym); i++)
        {
            (y)->re   = (out_sym)->re;
            (y++)->im = (out_sym++)->im;
        }
    }
}
/* End of mdlOutputs */


/* Function: mdlSetWorkWidths ===============================================*/

#ifdef MATLAB_MEX_FILE
#define MDL_SET_WORK_WIDTHS
static void mdlSetWorkWidths(SimStruct *S)
{   
    const int_T           M = (int_T) mxGetPr(M_ARY)[0];
    const int_T InPortWidth = ssGetInputPortWidth(S, INPORT);
    const int_T SampPerSym  = (int_T)mxGetPr(NUM_SAMP)[0];
    
    int_T  nbits = 0, IN_LEN, OUT_LEN;
    
    frexp((real_T)M, &nbits);  /*---Compute log2(M) for bit input---*/
    nbits = nbits - 1;
    
    IN_LEN = (IS_INTEGER_INPUT) ? InPortWidth : InPortWidth/nbits;
    OUT_LEN = IN_LEN*SampPerSym;
    
    ssSetNumDWork(          S, NUM_DWORK);
    
    ssSetDWorkWidth(        S, INPUT_LOOKUP, IN_LEN);
    ssSetDWorkDataType(     S, INPUT_LOOKUP, SS_INT32);
    ssSetDWorkComplexSignal(S, INPUT_LOOKUP, COMPLEX_NO);
    
    ssSetDWorkWidth(        S, OUTPUT_LOOKUP, OUT_LEN);
    ssSetDWorkDataType(     S, OUTPUT_LOOKUP, SS_DOUBLE);
    ssSetDWorkComplexSignal(S, OUTPUT_LOOKUP, COMPLEX_YES);
    
    ssSetDWorkWidth(        S, PREV_PHASE, 1);
    ssSetDWorkDataType(     S, PREV_PHASE, SS_DOUBLE);
    ssSetDWorkComplexSignal(S, PREV_PHASE, COMPLEX_NO);
    
    ssSetDWorkWidth(        S, PHASE_INCREMENT, M);
    ssSetDWorkDataType(     S, PHASE_INCREMENT, SS_DOUBLE);
    ssSetDWorkComplexSignal(S, PHASE_INCREMENT, COMPLEX_NO);
    
    ssSetDWorkWidth(        S, OSC_PHASE, M);
    ssSetDWorkDataType(     S, OSC_PHASE, SS_DOUBLE);
    ssSetDWorkComplexSignal(S, OSC_PHASE, COMPLEX_NO);
    
    ssSetDWorkWidth(        S, OUTPUT_INDEX, 1);
    ssSetDWorkDataType(     S, OUTPUT_INDEX, SS_INT32);
    ssSetDWorkComplexSignal(S, OUTPUT_INDEX, COMPLEX_NO);
}
#endif

static void mdlTerminate(SimStruct *S)
{
}

#ifdef  MATLAB_MEX_FILE
#define MDL_SET_INPUT_PORT_DIMENSION_INFO
static void mdlSetInputPortDimensionInfo(SimStruct *S, int_T port,
                                         const DimsInfo_T *dimsInfo)
{
    const int_T    M    = (int_T) mxGetPr(M_ARY)[0];
    
    int_T outCols, outRows, nbits;
    frexp((real_T)M, &nbits);  /*---Compute log2(M) for bit input---*/
    nbits = nbits - 1;/* This is the value of the number of bits per symbol*/
    
    nbits = (IS_BIT_INPUT) ? nbits : 1;
    
    if(!ssSetInputPortDimensionInfo(S, port, dimsInfo)) return;
    
    if(ssGetInputPortConnected(S,INPORT)) 
    {
        
        /* Port info */
        const boolean_T framebased = (boolean_T)ssGetInputPortFrameData(S,INPORT);
        const int_T     inCols     = dimsInfo->dims[1];
        const int_T     inRows     = dimsInfo->dims[0];
        const int_T     dataPortWidth  = ssGetInputPortWidth(S, INPORT);
        const int_T     numDims        = ssGetInputPortNumDimensions(S, INPORT);
        const int_T     nSamp          = (framebased) ? (int_T)mxGetPr(NUM_SAMP)[0] : 1;
        
        
        if ((numDims != 1) && (numDims != 2))
        {
            THROW_ERROR(S, "Input must be 1-D or 2-D.");
        }
        
        if (!framebased)
        {
            if (IS_INTEGER_INPUT) 
            {
                if (dataPortWidth != 1)
                {
        			THROW_ERROR(S,"In sample-based integer input mode, the input must be a scalar.");
                }
                else { outRows = inRows; }
            }
            else /* BIT_INPUT */
            {
                if((dataPortWidth != nbits) || ((numDims == 2) && (inCols!=1) && (inRows!=1)))
                {
    				THROW_ERROR(S,"In sample-based bit input mode, the input must be a vector whose width equals the number of bits per symbol.");
                }
                
                if ((numDims == 2) && (inCols > 1)) /* [1 x N_BIT] -> [1 x 1] */
                {
                    outCols = inCols/nbits;
                }
                /* [N_BIT x 1], [N_BIT]  -> [1 x 1], [1]*/
                else  {outRows = inRows/nbits;}
            }
        }
        else /* Frame-based */
        {
            if (inCols != 1)
            {
				THROW_ERROR(S,"In frame-based mode, inputs must be scalars or column vectors.");
            }
            else if ((inRows % nbits) != 0)
            {
				THROW_ERROR(S,"In frame-based bit input mode, the width of the input vector must be an integer multiple of the number of bits per symbol.");
            }
            else
            {
                outRows = (inRows/nbits * nSamp);
            }
        }
        
        /* Determine if Outport need setting */
        if (ssGetOutputPortWidth(S,OUTPORT) == DYNAMICALLY_SIZED) 
        {
            
            if (numDims == 1)  
            { 
                if(!ssSetOutputPortVectorDimension(S,OUTPORT,outRows)) return;
            } 
            else if ((framebased) || ((!framebased) && (inCols == 1)))
            {
                if(!ssSetOutputPortMatrixDimensions(S, OUTPORT, outRows, 1)) return;
            }
            else 
            {
                if(!ssSetOutputPortMatrixDimensions(S, OUTPORT, 1, outCols)) return;
            }
        } 
        else /* Output has been set, so do error checking. */
        { 
            const int_T *outDims    = ssGetOutputPortDimensions(S, OUTPORT);
            const int_T  outRowsSet = outDims[0];
            const int_T  outColsSet = outDims[1];
            
            if((!framebased) && (inCols > 1)  /* [1 x N_BIT] -> [1 x 1] */ 
                && (outColsSet != outCols)) 
            {
                THROW_ERROR(S, "Port width propagation failed.");
            }
            else if (outRowsSet != outRows)
            {
                THROW_ERROR(S, "Port width propagation failed.");
            }
        }
    }
}



#define MDL_SET_OUTPUT_PORT_DIMENSION_INFO
static void mdlSetOutputPortDimensionInfo(SimStruct *S, int_T port,
                                          const DimsInfo_T *dimsInfo)
{
    const int_T    M    = (int_T) mxGetPr(M_ARY)[0];
    int_T inRows, nbits;
    frexp((real_T)M, &nbits);  /*---Compute log2(M) for bit input---*/
    nbits = nbits - 1;/* This is the value of the number of bits per symbol*/
    
    nbits = (IS_BIT_INPUT) ? nbits : 1;
    
    if(!ssSetOutputPortDimensionInfo(S, port, dimsInfo)) return;
    
    if(ssGetOutputPortConnected(S,OUTPORT)) 
    {    
        /* Port info */
        const boolean_T framebased = (boolean_T)(ssGetInputPortFrameData(S,INPORT) == FRAME_YES);
        const int_T     outCols = dimsInfo->dims[1];
        const int_T     outRows = dimsInfo->dims[0];
        const int_T     dataPortWidth  = ssGetOutputPortWidth(S, OUTPORT);
        const int_T     numDims        = ssGetOutputPortNumDimensions(S, OUTPORT);
        const int_T     nSamp          = (framebased) ? (int_T)mxGetPr(NUM_SAMP)[0] : 1;
        
        if ((numDims != 1) && (numDims != 2))
        {
            THROW_ERROR(S, "Outputs must be 1-D or 2-D.");
        }
        
        if (framebased)
        {
            if (outCols != 1)
            {
				THROW_ERROR(S,"In frame-based mode, outputs must be scalars or column vectors.");
            }
            
            if (outRows % nSamp !=0)
			{
			    THROW_ERROR(S,"The output length must be a multiple of the number of samples per symbol.");
			}
			
            inRows = (outRows/nSamp * nbits);
        }
        else /* Sample-based */
        {
			if (dataPortWidth != 1)
			{	
				THROW_ERROR(S,"In sample-based mode, the output must be a scalar.");
			}
            
            if ((IS_INTEGER_INPUT) || ((IS_BIT_INPUT) && (numDims == 1)))
            {
                inRows = outRows * nbits;
            }
        }
        
        /* Determine if inport need setting. */
			if (ssGetInputPortWidth(S,INPORT) == DYNAMICALLY_SIZED) 
			{ 
				if (numDims == 1)
				{
					if(!ssSetInputPortVectorDimension(S, INPORT, inRows)) return;
				}
				else if ((framebased) || ((!framebased) && (IS_INTEGER_INPUT)))
				{
					/* Oriented sample-based Integer inputs and frame-based signals */ 
					if(!ssSetInputPortMatrixDimensions(S, INPORT, inRows, 1)) return;
				} 
				else if ((!framebased) && (IS_BIT_INPUT))
				{
					/* Sample-based bit inputs */
					if(!ssSetInputPortVectorDimension(S, INPORT, (outRows * nbits))) return;
				}
			} 
			else /* Input has been set, so do error checking. */ 
			{
				const int_T *inDims = ssGetInputPortDimensions(S, INPORT);
				const int_T  inRowsSet = inDims[0];
				
				if (((framebased) || ((!framebased) 
					&& ((IS_INTEGER_INPUT) || ((IS_BIT_INPUT) && (numDims == 1)))))
					&& (inRowsSet != inRows))
				{
					THROW_ERROR(S, "Port width propagation failed.");
				}
			}
    }    
}
#endif



#if defined(MATLAB_MEX_FILE)
#define MDL_SET_INPUT_PORT_SAMPLE_TIME
static void mdlSetInputPortSampleTime(SimStruct *S,
                                      int_T     portIdx,
                                      real_T    sampleTime,
                                      real_T    offsetTime)
{
    /* This function is executed only in the case of Sample-based inputs*/
    const int_T  numSamp = (int_T)mxGetPr(NUM_SAMP)[0];
    const int_T  inFramebased = ssGetInputPortFrameData(S,INPORT);
    real_T outSampleTime = 0.0;
    
    ssSetInputPortSampleTime(S, portIdx, sampleTime);
    ssSetInputPortOffsetTime(S, portIdx, offsetTime);
    
    if (sampleTime == CONTINUOUS_SAMPLE_TIME) 
    {
        THROW_ERROR(S,"Input signal must be discrete.");
    }
    if (offsetTime != 0.0) 
    {
        THROW_ERROR(S,"Non-zero sample time offsets not allowed.");
    }
    
    if (inFramebased)
    {
        outSampleTime = sampleTime;
    }
    else /* Sample-based*/
    {
        outSampleTime = (sampleTime/numSamp);
    }
    
    ssSetOutputPortSampleTime(S, OUTPORT, outSampleTime);
    ssSetOutputPortOffsetTime(S, OUTPORT, 0.0);
}

#define MDL_SET_OUTPUT_PORT_SAMPLE_TIME
static void mdlSetOutputPortSampleTime(SimStruct *S,
                                       int_T     portIdx,
                                       real_T    sampleTime,
                                       real_T    offsetTime)
{
    /* This function is executed only in the case of Sample-based inputs*/
    const int_T  numSamp =      (int_T)mxGetPr(NUM_SAMP)[0];
    const int_T  inFramebased = ssGetInputPortFrameData(S,INPORT);
    real_T inSampleTime = 0.0;
    
    ssSetOutputPortSampleTime(S, portIdx, sampleTime);
    ssSetOutputPortOffsetTime(S, portIdx, offsetTime);
    
    if (sampleTime == CONTINUOUS_SAMPLE_TIME) 
    {
        THROW_ERROR(S,"Output signal must be discrete.");
    }
    if (offsetTime != 0.0) 
    {
        THROW_ERROR(S,"Non-zero sample time offsets not allowed.");
    }
    
    if (inFramebased)
    {
        inSampleTime = sampleTime;
    }
    else /* Sample-based*/
    {
        inSampleTime = (sampleTime*numSamp);
    }
    
    ssSetInputPortSampleTime(S, INPORT, inSampleTime);
    ssSetInputPortOffsetTime(S, INPORT, 0.0);
}
#endif



#ifdef  MATLAB_MEX_FILE    
#include "simulink.c"      
#else
#include "cg_sfun.h"       
#endif
