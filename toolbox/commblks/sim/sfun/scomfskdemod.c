/*
 * SCOMFSKDEMOD Communications Blockset S-Function for demodulating
 * MFSK input signal.
 *
 *  Copyright 1996-2003 The MathWorks, Inc.
 *  $Revision: 1.13.4.2 $  $Date: 2004/04/12 23:03:23 $
 */

#define S_FUNCTION_NAME scomfskdemod
#define S_FUNCTION_LEVEL 2

#include "comm_defs.h"

/* List input & output ports*/
enum {INPORT=0, NUM_INPORTS};
enum {OUTPORT=0, NUM_OUTPORTS};
 /* Define Work Vectors*/
enum {SYMBOLOUT, COUNT, U_CORR, MAX_CORR, PHASE, PHASE_INCREMENT, NUM_DDWORK};

/* List the mask parameters*/
enum {
	M_ARYC=0, 
	OUT_TYPEC, 
	MAPPINGC, 
	FREQ_SEPC,
	NUM_SAMPC,
	NUM_ARGS
};
#define M_ARY					(ssGetSFcnParam(S,M_ARYC))
#define OUT_TYPE				(ssGetSFcnParam(S,OUT_TYPEC))
#define MAPPING					(ssGetSFcnParam(S,MAPPINGC))
#define FREQ_SEP                (ssGetSFcnParam(S,FREQ_SEPC))
#define NUM_SAMP				(ssGetSFcnParam(S,NUM_SAMPC))



/*Define variables representing parameter values*/
enum {BIT_OUTPUT=1, INTEGER_OUTPUT};
enum {BINARY_DEMAP=1, GRAY_DEMAP};

#define IS_INTEGER_OUTPUT		((int_T)mxGetPr(OUT_TYPE)[0] == INTEGER_OUTPUT)
#define IS_BIT_OUTPUT			((int_T)mxGetPr(OUT_TYPE)[0] == BIT_OUTPUT)
#define IS_BINARY_DEMAP			((int_T)mxGetPr(MAPPING)[0] == BINARY_DEMAP)
#define IS_GRAY_DEMAP			((int_T)mxGetPr(MAPPING)[0] == GRAY_DEMAP)

#define OUTPUT_TYPE				(int_T)mxGetPr(OUT_TYPE)[0]

#define BLOCK_BASED_SAMPLE_TIME 1

/* --- Function prototypes --- */
/* Function to compute the index for the symbol demapping table */
static void setIndex(SimStruct *S)
{
	creal_T		    *u_corr	  	= (creal_T *)ssGetDWork( S, U_CORR);
	real_T          *Corr       = (real_T *)ssGetDWork(S, MAX_CORR);
	int32_T			*SymbolOut		= (int32_T *)ssGetDWork(S, SYMBOLOUT);
	const int_T		M               = (int_T)mxGetPr(M_ARY)[0] ;
	
	real_T maxCorr = 0.0;
	int_T  j = 0, m = 0, nbits = 0, maxIndx;
	int_T  inc = -1, bit_count; 
	frexp((real_T)M, &nbits);
	nbits = nbits - 1;

	*SymbolOut = (int32_T)0;

	/* Find max. of the correlation */

	CABS(u_corr[0],Corr[0]);
	maxCorr = Corr[0];
	maxIndx = 0;
	for (j = 1; j < M; j++)
	{
		CABS(u_corr[j],Corr[j]);
		if (Corr[j] >  maxCorr) 
		{
			maxCorr = Corr[j];
			maxIndx = j;
		}
	}

			
	switch (OUTPUT_TYPE) 
	{
		case BIT_OUTPUT: /* Bit input */
			{
				bit_count = nbits - 1;

				if (IS_GRAY_DEMAP)
				{
					maxIndx^= (int_T)floor(maxIndx/2);
				}
				
				
				for (m = 0; m < nbits; m++)
				{
					SymbolOut[bit_count] = (int32_T)maxIndx%2;
					maxIndx = maxIndx/2;
					bit_count += inc; /* inc = -1*/
				}
				
			}
			break;
		case INTEGER_OUTPUT: /* Integer Output */
			{
				*SymbolOut = (int32_T)maxIndx;
			}
			break;
		default:
			THROW_ERROR(S,"Invalid output type.");	
	}
}


/* Function: mdlCheckParameters ===============================================*/
#ifdef MATLAB_MEX_FILE
#define MDL_CHECK_PARAMETERS
static void mdlCheckParameters(SimStruct *S) 
{
	/*---Check to see if the Output type parameter is either 1 or 2 ------*/
	if (!IS_FLINT_IN_RANGE(OUT_TYPE,1,2))
	{
		THROW_ERROR(S,"Output type parameter is outside of expected range.");
	}

	/*---Check to see if the Symbol to bit demapping parameter is either 1 or 2 ----*/
	if (!IS_FLINT_IN_RANGE(MAPPING,1,2))
	{
		THROW_ERROR(S,"Symbol to bit demapping parameter is outside of expected range.");
	}

	/*---Check the M-ARY number parameter-----------*/
	/*---For bit input check if M is a scalar which is an integer power of 2---*/
	
	if (OK_TO_CHECK_VAR(S, M_ARY))
	{
		if (!mxIsEmpty(M_ARY))
		{
			int_T nbits = 0;
			const int_T M                  = mxGetPr(M_ARY)[0];
			
			switch (OUTPUT_TYPE) 
			{
			case BIT_OUTPUT: /*For bit output check if M is a scalar which is an integer power of 2*/
				{
					if ((!IS_FLINT_GE(M_ARY, 2)) || (frexp((real_T)M, &nbits) != 0.5)
						|| (mxIsEmpty(M_ARY))) 
					{
						THROW_ERROR(S, "In case of Bit type output M-ary number parameter must be a scalar positive real integer value which is a non-zero power of two.");
					}
				}
				break;
			case INTEGER_OUTPUT: /*For integer output check if M is a positive scalar integer*/
				{
					if ((!IS_FLINT_GE(M_ARY,2)) || (mxIsEmpty(M_ARY)))
					{
						THROW_ERROR(S," M-ary number parameter must be a scalar positive integer value.");
					}
				}
				break;
			default:
					THROW_ERROR(S,"Invalid output type.");
			}
		}
		else
		{
			switch (OUTPUT_TYPE) 
			{
				case BIT_OUTPUT: 
					{
						THROW_ERROR(S, "In case of Bit type output M-ary number parameter must be a scalar positive real integer value which is a non-zero power of two.");
					}
					break;
				case INTEGER_OUTPUT:	
					{ 
						THROW_ERROR(S," M-ary number parameter must be a scalar positive integer value.");
					}
					break;
				default:
						THROW_ERROR(S,"Invalid output type.");
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

	/* Check to see if the Number of samples per symbol parameter is a positive integer value*/
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
	if (!ssSetNumInputPorts(         S, NUM_INPORTS)) return;
    if (!ssSetInputPortDimensionInfo(S, INPORT, DYNAMIC_DIMENSION)) return; 
	ssSetInputPortFrameData(		 S, INPORT, FRAME_INHERITED);
    ssSetInputPortDirectFeedThrough( S, INPORT, 1);
    ssSetInputPortComplexSignal(     S, INPORT, COMPLEX_YES);
	ssSetInputPortReusable(		     S, INPORT, 0);
	ssSetInputPortRequiredContiguous(S, INPORT, 0);
	ssSetInputPortSampleTime(        S, INPORT,  INHERITED_SAMPLE_TIME);

    /* Output: */
	if (!ssSetNumOutputPorts(         S, NUM_OUTPORTS)) return;
	if (!ssSetOutputPortDimensionInfo(S, OUTPORT, DYNAMIC_DIMENSION)) return; 
    ssSetOutputPortFrameData(	      S, OUTPORT, FRAME_INHERITED);
    ssSetOutputPortComplexSignal(     S, OUTPORT, COMPLEX_NO);
	ssSetOutputPortReusable(	      S, OUTPORT, 0);
	ssSetOutputPortSampleTime(        S, OUTPORT, INHERITED_SAMPLE_TIME);

	if (!ssSetNumDWork(S, DYNAMICALLY_SIZED)) return;

	ssSetOptions( S, SS_OPTION_EXCEPTION_FREE_CODE);

	ssSetSFcnParamNotTunable(S, OUT_TYPEC);
	ssSetSFcnParamNotTunable(S, M_ARYC);
	ssSetSFcnParamNotTunable(S, MAPPINGC);
	ssSetSFcnParamNotTunable(S, FREQ_SEPC);
	ssSetSFcnParamNotTunable(S, NUM_SAMPC);
	
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
    
    ssSetModelReferenceSampleTimeInheritanceRule(S,	DISALLOW_SAMPLE_TIME_INHERITANCE);

#endif	
}
/* End of mdlInitializeSampleTimes(SimStruct *S) */


/* Function: mdlInitializeConditions ========================================*/
#define MDL_INITIALIZE_CONDITIONS
static void mdlInitializeConditions(SimStruct *S)
{

	/* Initialize the phase of all M oscillators to zero*/
    const int_T     SampPerSym      = ( int_T)mxGetPr(NUM_SAMP)[0];
    const int_T     M               = ( int_T)mxGetPr(M_ARY)[0];
    const real_T    freqSep         = (real_T)mxGetPr(FREQ_SEP)[0];
    
    real_T          *phaseIncr      = (real_T *)ssGetDWork(S, PHASE_INCREMENT);
	real_T          *phase          = (real_T *)ssGetDWork(S, PHASE);
	creal_T		    *u_corr	  	    = (creal_T *)ssGetDWork( S, U_CORR);
    real_T          sampletime      = (real_T)ssGetOutputPortSampleTime(S,OUTPORT);
	const int_T     outFramebased   = ssGetOutputPortFrameData(S,OUTPORT);
	const int_T		OutPortWidth    = ssGetOutputPortWidth(S, OUTPORT);

    int_T   i1,nbits=0;
    
	frexp((real_T)M, &nbits);
	nbits = nbits - 1;

    if(outFramebased)
    {
        sampletime = sampletime / OutPortWidth;
    
        if (IS_BIT_OUTPUT)
        {
            sampletime = sampletime * nbits;
        }

     }
    
       
    for (i1 = 0; i1 < M; i1++)
    {
		phase[i1] = 0.0;
		u_corr[i1].re = 0.0;
		u_corr[i1].im = 0.0;
        *phaseIncr++ = DSP_PI*freqSep*sampletime*((real_T) -M+1+2*i1)/(real_T) SampPerSym;
    }
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
	int32_T			*SymbolOut		= (int32_T *)ssGetDWork(S, SYMBOLOUT);
	real_T          *phaseIncr      = (real_T *)ssGetDWork(S, PHASE_INCREMENT);
	real_T          *phase          = (real_T *)ssGetDWork(S, PHASE);
	real_T			*count	        = (real_T *)ssGetDWork( S, COUNT);
	creal_T		    *u_corr	  	    = (creal_T *)ssGetDWork( S, U_CORR);
	const int_T     inFramebased    = ssGetInputPortFrameData(S,INPORT);
	const int_T		InPortWidth		= ssGetInputPortWidth(S, INPORT);
	const int_T     M               = (int_T)mxGetPr(M_ARY)[0] ;
	const int_T		nSamp           = (inFramebased) ? (int_T)mxGetPr(NUM_SAMP)[0] : 1;
	const int_T		SampPerSym      = (int_T)mxGetPr(NUM_SAMP)[0];

	const int_T     OutportTid     = ssGetOutputPortSampleTimeIndex(S, OUTPORT);
	const int_T     InportTid      = ssGetInputPortSampleTimeIndex(S, INPORT);

	int_T   SamplesPerInputFrame  = InPortWidth;
	int_T   i1 = 0, i2 = 0, i3 = 0, i4 = 0, j = 0, nbits = 0, temp = 0, bit_zero = 0;
	int_T   delay_count = 0;
	real_T  x1 = 0.0, y1 = 0.0;
	creal_T cplx_freq; 
	frexp((real_T)M, &nbits);
	nbits = nbits - 1;

	if (!inFramebased) /*---Sample-based discrete inputs---*/
	{
		/* Generate index to look up the demapping table
		*  This is done by accumulating and then averaging 
		*  the samples for every symbol at every input sample 
		*  time hit and calling the setIndex function at every
		*  output sample time hit */	
		if(ssIsSampleHit(S, InportTid, tid))
		{
			InputPtrsType   uptr    = ssGetInputPortSignalPtrs(S,INPORT);

			const creal_T   *u    = (creal_T *)(*uptr++);
			for (i3 = 0; i3 < M; i3++)
			{
				cplx_freq.re = cos(phase[i3]);
				cplx_freq.im = sin(phase[i3]);
				x1 = CMULT_YCONJ_RE(*u, cplx_freq); 
				y1 = CMULT_YCONJ_IM(*u, cplx_freq);  
				u_corr[i3].re = u_corr[i3].re + x1;
				u_corr[i3].im = u_corr[i3].im + y1;
				phase[i3] = phase[i3] + phaseIncr[i3];
			}
			*count = *count + 1.0;
			
			if (*count == (real_T)SampPerSym)
			{
				/* Determine output based on correlation values*/
				setIndex(S);

				/* Reset work vectors for the next symbol */
				*count = 0.0;
				for (i4 = 0; i4 < M; i4++)
				{
					phase[i4] = 0;
					u_corr[i4].re = 0.0;
					u_corr[i4].im = 0.0;
				}
			}		
		}
		
		/* Look up the demapping table at output sample-time hit*/
		if(ssIsSampleHit(S, OutportTid, tid))	
		{
		real_T	*y	= (real_T *)ssGetOutputPortRealSignal(S, OUTPORT);
		
			switch (OUTPUT_TYPE) 
			{
				case BIT_OUTPUT: /* Bit input */
				{
					for (j = 0; j < nbits; j++)
					{
						*y++   = *SymbolOut++;
					}
				}
				break;
				case INTEGER_OUTPUT:
				{
					*y++   = *SymbolOut;
				}
				break;
				default:
					THROW_ERROR(S,"Invalid output type.");	
			}
		}
	}
	else	/*---Frame-based inputs---*/
	{
		/* Generate index to look up the demapping table
		*  This is done by accumulating and then averaging 
		*  the samples for every symbol and then calling the 
		*  setIndex function */	
		InputPtrsType   uptr = ssGetInputPortSignalPtrs(S,INPORT);
		real_T	*y	= (real_T *)ssGetOutputPortRealSignal(S, OUTPORT);


		for (i1 = 0; i1 < (SamplesPerInputFrame/SampPerSym); i1++)
		{
			/* For every symbol */
			for (i2 = 0; i2 < SampPerSym; i2++)
			{
				const creal_T   *u    = (creal_T *)(*uptr++);
				for (i3 = 0; i3 < M; i3++)
				{
					cplx_freq.re = cos(phase[i3]);
					cplx_freq.im = sin(phase[i3]);
					x1 = CMULT_YCONJ_RE(*u, cplx_freq); 
					y1 = CMULT_YCONJ_IM(*u, cplx_freq);  
					u_corr[i3].re = u_corr[i3].re + x1;
					u_corr[i3].im = u_corr[i3].im + y1;
					phase[i3] = phase[i3] + phaseIncr[i3];
				}
				
				if (i2 == (SampPerSym-1))
				{
					/* Determine output based on correlation values*/
					setIndex(S);

					/* Reset work vectors for the next symbol */
					for (i4 = 0; i4 < M; i4++)
					{
						phase[i4] = 0;
						u_corr[i4].re = 0.0;
						u_corr[i4].im = 0.0;
					}


					/* Assign output values */
					switch (OUTPUT_TYPE) 
					{
						case BIT_OUTPUT: /* Bit output */
						{
							for (j = 0; j < nbits; j++)
							{
								*y++   = SymbolOut[j];
							}
						}
						break;
						case INTEGER_OUTPUT:
						{
							*y++   = *SymbolOut;
						}
						break;
						default:
							THROW_ERROR(S,"Invalid output type.");	
					}
				}
			}
		}
	}
}
/* End of mdlOutputs (SimStruct *S, int_T tid) */


/* Function: mdlSetWorkWidths ===============================================*/
#ifdef MATLAB_MEX_FILE
#define MDL_SET_WORK_WIDTHS
static void mdlSetWorkWidths(SimStruct *S)
{   
	const int_T     inFramebased    = ssGetInputPortFrameData(S,INPORT);
	const int_T		nSamp           = (inFramebased) ? (int_T)mxGetPr(NUM_SAMP)[0] : 1;
	const int_T		SampPerSym      = (int_T)mxGetPr(NUM_SAMP)[0];
	const int_T     M               = mxGetPr(M_ARY)[0];
	const int_T		InPortWidth     = ssGetInputPortWidth(S, INPORT);

	int_T  nbits = 0, LEN = 0, COMPLEXITY;
	frexp((real_T)M, &nbits);  /*---Compute log2(M) for bit input---*/
	nbits = nbits - 1;
	LEN = (IS_INTEGER_OUTPUT) ? InPortWidth/nSamp : (InPortWidth*nbits)/nSamp;

	ssSetNumDWork(          S, NUM_DDWORK);
	
	ssSetDWorkWidth(        S, SYMBOLOUT, LEN);
	ssSetDWorkDataType(     S, SYMBOLOUT, SS_INT32);
	ssSetDWorkComplexSignal(S, SYMBOLOUT, COMPLEX_NO);

	ssSetDWorkWidth(        S, COUNT, 1);
	ssSetDWorkDataType(     S, COUNT, SS_DOUBLE);
	ssSetDWorkComplexSignal(S, COUNT, COMPLEX_NO);

	ssSetDWorkWidth(        S, MAX_CORR, M);
	ssSetDWorkDataType(     S, MAX_CORR, SS_DOUBLE);
	ssSetDWorkComplexSignal(S, MAX_CORR, COMPLEX_NO);

	ssSetDWorkWidth(        S, U_CORR, M);
	ssSetDWorkDataType(     S, U_CORR, SS_DOUBLE);
	ssSetDWorkComplexSignal(S, U_CORR, COMPLEX_YES);
	
	ssSetDWorkWidth(        S, PHASE_INCREMENT, M);
	ssSetDWorkDataType(     S, PHASE_INCREMENT, SS_DOUBLE);
	ssSetDWorkComplexSignal(S, PHASE_INCREMENT, COMPLEX_NO);

	ssSetDWorkWidth(        S, PHASE, M);
	ssSetDWorkDataType(     S, PHASE, SS_DOUBLE);
	ssSetDWorkComplexSignal(S, PHASE, COMPLEX_NO);

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
	const int_T    M    = mxGetPr(M_ARY)[0] ;
						
	int_T outCols, outRows, nbits;
	frexp((real_T)M, &nbits);  /*---Compute log2(M) for bit input---*/
	nbits = nbits - 1;/* This is the value of the no. of bits per symbol*/

	nbits = (IS_BIT_OUTPUT) ? nbits : 1;

    if(!ssSetInputPortDimensionInfo(S, port, dimsInfo)) return;

    if(ssGetInputPortConnected(S,INPORT)) 
	{
                                                                                     
        /* Port info */
        const boolean_T framebased = (boolean_T)ssGetInputPortFrameData(S,INPORT);
        const int_T     inCols     = dimsInfo->dims[1];
        const int_T     inRows     = dimsInfo->dims[0];
		const int_T     dataPortWidth  = ssGetInputPortWidth(S, INPORT);
		const int_T     numDims        = ssGetInputPortNumDimensions(S, INPORT);
		const int_T		nSamp           = (framebased) ? (int_T)mxGetPr(NUM_SAMP)[0] : 1;

		if ((numDims != 1) && (numDims != 2))
		{
			THROW_ERROR(S, "Input must be 1-D or 2-D.");
		}

		if (!framebased)
		{
			if (dataPortWidth != 1)
			{
        		THROW_ERROR(S,"In sample-based mode, the input must be a scalar.");
			}
			/* [1 x 1] -> [1 x 1], integer case */
			/* [1 x 1] -> [nbits] */
			/* [1] -> [nbits] */
			outRows = inRows * nbits; 
		}
		else /* Frame-based */
		{
            if (inCols != 1)
			{
				THROW_ERROR(S,"In frame-based mode, inputs must be scalars or column vectors.");
			}
			if (inRows % nSamp != 0)
			{
				THROW_ERROR(S,"The input length must be a multiple of the number of samples per symbol.");
			}

			outRows = inRows/nSamp * nbits;
		}

        /* Determine if Outport need setting */
        if (ssGetOutputPortWidth(S,OUTPORT) == DYNAMICALLY_SIZED) 
		{
            if ((numDims == 1) || ((!framebased) && (numDims == 2) && (IS_BIT_OUTPUT)))
			{ 
                if(!ssSetOutputPortVectorDimension(S,OUTPORT,outRows)) return;
            } 
			else 
			{
                if(!ssSetOutputPortMatrixDimensions(S, OUTPORT, outRows, 1)) return;
            }        
        } 
		else /* Output has been set, so do error checking. */
		{ 
            const int_T *outDims    = ssGetOutputPortDimensions(S, OUTPORT);
            const int_T  outRowsSet = outDims[0];
   
            if(outRowsSet != outRows ) 
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
	const int_T    M    = mxGetPr(M_ARY)[0] ;
	int_T inCols, inRows, nbits;
	frexp((real_T)M, &nbits);  /*---Compute log2(M) for bit input---*/
	nbits = nbits - 1;/* This is the value of the no. of bits per symbol*/

	nbits = (IS_BIT_OUTPUT) ? nbits : 1;
 
	if(!ssSetOutputPortDimensionInfo(S, port, dimsInfo)) return;
	
    if(ssGetOutputPortConnected(S,OUTPORT)) 
	{    
        /* Port info */
        const boolean_T framebased = (boolean_T)(ssGetInputPortFrameData(S,INPORT) == FRAME_YES);
        const int_T     outCols = dimsInfo->dims[1];
        const int_T     outRows = dimsInfo->dims[0];
		const int_T     dataPortWidth  = ssGetOutputPortWidth(S, OUTPORT);
		const int_T     numDims        = ssGetOutputPortNumDimensions(S, OUTPORT);
		const int_T	    nSamp          = (framebased) ? (int_T)mxGetPr(NUM_SAMP)[0] : 1;

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
			if ( (IS_BIT_OUTPUT) && (outRows % nbits != 0) )
			{
				THROW_ERROR(S,"In frame-based bit output mode, the output width must be a multiple of the number of bits per symbol.");
			}
			
			inRows = outRows * nSamp/nbits;
		}
		else /* Sample-based */
		{
		    if ( (numDims !=1) && (outRows*outCols !=1) )
            {
                THROW_ERROR(S,"In sample-based mode, outputs must be scalar or 1-D.");
			}
			
			if (dataPortWidth != nbits)
			{
				if (IS_INTEGER_OUTPUT)
				{	
					THROW_ERROR(S,"In sample-based integer output mode, the output must be a scalar.");
				}
				else /* BIT_INPUT */
				{
					THROW_ERROR(S,"In sample-based bit output mode, the output must be a vector whose width equals the number of bits per symbol.");
				}
			}
				
			inRows = outRows/nbits;
		}

		/* Determine if inport need setting */
        if (ssGetInputPortWidth(S,INPORT) == DYNAMICALLY_SIZED) 
        { 
			if (numDims == 1)
			{
				if(!ssSetInputPortVectorDimension(S, INPORT, inRows)) return;
			}
            else 
			{
                if(!ssSetInputPortMatrixDimensions(S, INPORT, inRows, 1)) return;
            }
        } 
		else /* Input has been set, so do error checking. */ 
		{
            const int_T *inDims = ssGetInputPortDimensions(S, INPORT);
            const int_T  inRowsSet = inDims[0];
            
			if (inRowsSet != inRows)
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
		outSampleTime = sampleTime * numSamp;
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
	const int_T  numSamp = (int_T)mxGetPr(NUM_SAMP)[0];
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
		inSampleTime = sampleTime/numSamp;
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
