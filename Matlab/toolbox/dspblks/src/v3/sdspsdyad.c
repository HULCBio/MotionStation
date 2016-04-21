/*
* SDSPSDYAD A SIMULINK dyadic FIR synthesis multirate filter block.
*   Uses an efficient polyphase implementation for the FIR interpolation filters.
*
*   
*  Copyright 1995-2002 The MathWorks, Inc.
*  $Revision: 1.33 $  $Date: 2002/04/14 20:42:21 $
*/

#define S_FUNCTION_LEVEL 2
#define S_FUNCTION_NAME sdspsdyad

#include "dsp_sim.h"

/* Defines for easy access of the input parameters */
enum { ARGC_LFilt= 0, 
       ARGC_HFilt, 
       ARGC_Levels, 
       ARGC_Tree, 
       ARGC_NumChans, 
       NUM_ARGS
};

#define LFILT_ARG  ssGetSFcnParam(S, ARGC_LFilt)
#define HFILT_ARG  ssGetSFcnParam(S, ARGC_HFilt)
#define LEVELS_ARG ssGetSFcnParam(S, ARGC_Levels)
#define TREE_ARG   ssGetSFcnParam(S, ARGC_Tree)
#define CHANS_ARG  ssGetSFcnParam(S, ARGC_NumChans)

const int_T M_ADIC = 2;	/* Only Dyadic is supported */

/* An invalid number of channels is used to flag sample-based */
const int_T SAMPLE_BASED = -1;

/* The choices for the tree structure (from pop-up dialog box) */
enum {ASYMMETRIC=1, SYMMETRIC};

/* Port Index Enumerations */
enum {OUTPORT, NUM_OUTPORTS};

/* DWork indices */
enum {States, MemIdx, OutIdx, InputBuffer, OutputBuffer, 
      FiltBuffer, WrBuff1, I2Idx, InputCount, NUM_DWORKS};


static boolean_T ANY_UNCONNECTED_PORTS(SimStruct *S) 
{ 
	const int_T     nInputs     = ssGetNumInputPorts(S);  
	const int_T     nOutputs    = ssGetNumOutputPorts(S); 
	      boolean_T unconnected = 0;  /* Assume all ports connected */
		  int_T     i;

	for(i=0; i<nInputs; i++) {
		if(!ssGetInputPortConnected(S,i)) {
			unconnected = 1;
		}
	}
	for(i=0; i<nOutputs; i++) {
		if(!ssGetOutputPortConnected(S,i)) {
			unconnected = 1;
		}
	}
	return unconnected;
}


#ifdef MATLAB_MEX_FILE
#define MDL_CHECK_PARAMETERS
static void mdlCheckParameters(SimStruct *S) {
    const int_T	    numLFiltArg = mxGetNumberOfElements(LFILT_ARG);
    const int_T	    numHFiltArg = mxGetNumberOfElements(HFILT_ARG);
    const boolean_T runTime     = (boolean_T)(ssGetSimMode(S) != SS_SIMMODE_SIZES_CALL_ONLY);
	
    if (!IS_FLINT_GE(LEVELS_ARG,1)) {
        THROW_ERROR(S,"The number of levels must be a positive integer");
    }
	
    /* Check filter: */
    if (runTime || numLFiltArg >= 1) {
        if (mxGetN(LFILT_ARG) != M_ADIC) {
            THROW_ERROR(S,"Lowpass filter must be a polyphase matrix with the number of "
				"columns equal to two");
        }
    }
    if (runTime || numHFiltArg >= 1) {
        if (mxGetN(HFILT_ARG) != M_ADIC) {
            THROW_ERROR(S,"Highpass filter must be a polyphase matrix with the number of "
				"columns equal to two");
        }
    }
    if (runTime || (numLFiltArg >= 1 && numHFiltArg >= 1)) {
        if (mxIsComplex(LFILT_ARG) != mxIsComplex(HFILT_ARG)) {
            THROW_ERROR(S,"The two filters must either be both complex or both real");
        }
    }		

    /* Number of channels */
    /* If number of channels = -1, than number of channels = input width. */
    if (OK_TO_CHECK_VAR(S, CHANS_ARG) && ((int_T)mxGetPr(CHANS_ARG)[0] != SAMPLE_BASED)) {
        if (!IS_FLINT_GE(CHANS_ARG, 1)) {
            THROW_ERROR(S, "Number of channels must be a scalar greater than zero");
        }
    }

    /* Tree arg: Symmetric or Asymmetic */
    if (!IS_FLINT_IN_RANGE(TREE_ARG, 1, 2)) { 
        THROW_ERROR(S,"The choices for the tree structure are: 1=asymmetric or 2=symmetric");
    }
}
#endif


static void mdlInitializeSizes(SimStruct *S)
{
    int_T i, numInputs, numFilters;
	
    ssSetNumSFcnParams(S, NUM_ARGS);
	
#if defined(MATLAB_MEX_FILE)
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) return;
    mdlCheckParameters(S);
    if (ssGetErrorStatus(S) != NULL) return;
#endif
	
    ssSetSFcnParamNotTunable(S, ARGC_LFilt);
    ssSetSFcnParamNotTunable(S, ARGC_HFilt);
    ssSetSFcnParamNotTunable(S, ARGC_Levels);
    ssSetSFcnParamNotTunable(S, ARGC_Tree);
    ssSetSFcnParamNotTunable(S, ARGC_NumChans);
	
    {
        /* Calculate number of inputs and number of filters */
        const int_T numLevels   = (int_T) mxGetPr(LEVELS_ARG)[0];
		
        if ((int_T) mxGetPr(TREE_ARG)[0] == ASYMMETRIC) {
            numInputs = numLevels + 1;
            numFilters = M_ADIC*numLevels;
        } else {
            numInputs = M_ADIC;
            numFilters = M_ADIC*M_ADIC;
            for (i=1; i++ < numLevels;    ) {
				numInputs *= M_ADIC;
				numFilters += numInputs;
            }
        }
    }
	
    if (!ssSetNumInputPorts(S, numInputs)) return;
    for (i=0; i < numInputs; i++) {
        ssSetInputPortWidth(        S,	    i, DYNAMICALLY_SIZED);
        ssSetInputPortComplexSignal(S,      i, COMPLEX_INHERITED); 
        ssSetInputPortSampleTime(   S,      i, INHERITED_SAMPLE_TIME);
        ssSetInputPortDirectFeedThrough(S,  i, 1);
        ssSetInputPortReusable(         S,  i, 0); /* needs to be a test point,
												  * because the input signal
		* is read in mdlUpdate! */
    }
	
    if (!ssSetNumOutputPorts(S, NUM_OUTPORTS)) return;
    ssSetOutputPortWidth(        S,  OUTPORT, DYNAMICALLY_SIZED);
    ssSetOutputPortComplexSignal(S,  OUTPORT, COMPLEX_INHERITED); 
    ssSetOutputPortSampleTime(   S,  OUTPORT, INHERITED_SAMPLE_TIME);
    ssSetOutputPortReusable(     S,  OUTPORT, 0);
	
    /* Pointers to filter coefficients */
    if (mxIsComplex(LFILT_ARG) || mxIsComplex(HFILT_ARG)) {
        /* Pointers to Real and Imaginary parts of coeffs */
        /* Note: RTW really only needs numFilters + 2 */
        numFilters *= 2; 
        ssSetNumPWork(          S, numFilters);
    } else {
        /* Poiners to real coeffs */
        /* Note: Two extra needed for RTW */
        ssSetNumPWork(          S, numFilters + 2);
    }

    if(!ssSetNumDWork( S, DYNAMICALLY_SIZED)) return;

    ssSetNumSampleTimes(   S, PORT_BASED_SAMPLE_TIMES);
    ssSetOptions(          S, SS_OPTION_EXCEPTION_FREE_CODE);
}


#define MDL_START
static void mdlStart (SimStruct *S)
{
#ifdef MATLAB_MEX_FILE
    const int_T	    portWidth	= ssGetOutputPortWidth(S, OUTPORT);
    const int_T	    numLevels	= (int_T)mxGetPr(LEVELS_ARG)[0];
    int_T	        numChans	= (int_T)mxGetPr(CHANS_ARG)[0];
    boolean_T	    complex     = (boolean_T)(mxIsComplex(LFILT_ARG) || mxIsComplex(HFILT_ARG) ||
		(ssGetInputPortComplexSignal(S, 0) == COMPLEX_YES));
    const int_T     numInputs	= ssGetNumInputPorts(S);
    boolean_T	    checkCmplx;
    int_T	    frame, minFrame, i, inWidth, inputPortWidth;
	
    if (numChans == SAMPLE_BASED)  {
		frame = 1;
		numChans = portWidth;
    } else {
		frame = portWidth / numChans;
    }
	
    /* Compute the minimum input frame size */
    minFrame = M_ADIC;
    for (i=1; i++ < numLevels;   ) minFrame *= M_ADIC;
	
    if ((int_T)mxGetPr(CHANS_ARG)[0] != SAMPLE_BASED && (frame % minFrame) != 0) {
        ssSetErrorStatus(S,"The output frame size must be a multiple of "
			"2^(number of levels)");
        return;
    }
    if (numChans != SAMPLE_BASED && (ssGetOutputPortWidth(S, OUTPORT) % numChans) != 0) {
        ssSetErrorStatus(S,"The output port width must be a multiple of the number of channels");
        return;
    }
	
    checkCmplx = (boolean_T)ssGetInputPortComplexSignal(S, 0);
    for (i=1; i < numInputs; i++) {
        if (checkCmplx != ssGetInputPortComplexSignal(S, i)) {
			ssSetErrorStatus(S,"Input ports must either be all real or all complex");
			return;
        }
    }
	
    /* Check the port widths */
    if ((int_T)mxGetPr(CHANS_ARG)[0] != SAMPLE_BASED) {  /* Frame-based inputs */
        if ((int_T) mxGetPr(TREE_ARG)[0] == ASYMMETRIC) {
			inWidth = portWidth;
			for (i=0; i < numInputs; i++) {
				inputPortWidth = ssGetInputPortWidth(S, i);
				if (i != numLevels) inWidth /= M_ADIC;
				if (inputPortWidth != inWidth) {
					ssSetErrorStatus (S, "(Output port width)/(Input port width) "
						"must equal the interpolation factor at each input level");
					return;
				}
			}
        } else { /* Symmetric tree */
			for (i=0; i < numInputs; i++) {
				inputPortWidth = ssGetInputPortWidth(S, i);
				if (minFrame*inputPortWidth != portWidth) {
                    ssSetErrorStatus (S, "Input port width must equal "
						"(output port width)/(2^(number of levels))");
					return;
				}
            }
        }
    } else { /* Sample-based inputs */
        for (i=0; i < numInputs; i++) {
			inputPortWidth = ssGetInputPortWidth(S, i);
			if (inputPortWidth != portWidth) {
				ssSetErrorStatus (S, "Input port width must equal output port width");
				return;
            }
        }
    }
	
    if ( (complex && ssGetOutputPortComplexSignal(S, OUTPORT) != COMPLEX_YES) ||
		(!complex && ssGetOutputPortComplexSignal(S, OUTPORT) != COMPLEX_NO)) {
        ssSetErrorStatus(S,"If the input or filter coefficients are complex "
			"then the output must be complex.  All inputs must have the same complexity");
        return;
    }
#endif
}


static void mdlInitializeSampleTimes(SimStruct *S) 
{ 
    /* Check port sample times: */ 
	if(!ANY_UNCONNECTED_PORTS(S)) { 

	    const real_T    Ts_o      = ssGetOutputPortSampleTime(S, OUTPORT);
        const int_T     numInputs = ssGetNumInputPorts(S);
        int_T  i;

        if (Ts_o == INHERITED_SAMPLE_TIME) { 
            THROW_ERROR(S,"Sample time propagation failed for dyadic filter output"); 
        } 
		
		for (i=0; i < numInputs; i++) { 
			real_T Ts_i = ssGetInputPortSampleTime(S, i);
            
            /* Make sure the sample rate have been set */
			if (Ts_i == INHERITED_SAMPLE_TIME) { 
				THROW_ERROR(S,"Sample time propagation failed for dyadic filter input"); 
			} 
		} 
    }
}


#define MDL_INITIALIZE_CONDITIONS
static void mdlInitializeConditions(SimStruct *S)
{
    const int_T     numInputs	   = ssGetNumInputPorts(S);
    const int_T     numOutputs     = ssGetNumOutputPorts(S);
    const boolean_T isMultiRate    = isBlockMultiRate(S,numInputs,numOutputs);
    const boolean_T isMultiTasking = isModelMultiTasking(S);
    const boolean_T sampleBased    = (boolean_T)(mxGetPr(CHANS_ARG)[0] == SAMPLE_BASED);
    
    const int_T numLevels	= (int_T) mxGetPr(LEVELS_ARG)[0];
    int_T       *memIdx		= (int_T *) ssGetDWork(S, MemIdx);
 
    const int_T tree		= (int_T) mxGetPr(TREE_ARG)[0];
    boolean_T   *wrBuff1	= (boolean_T *) ssGetDWork(S, WrBuff1);
    int_T       *outIdx		= (int_T *) ssGetDWork(S, OutIdx);
 
    boolean_T   filtComplex	= (boolean_T)(mxIsComplex(LFILT_ARG) || mxIsComplex(HFILT_ARG));
    int_T       i, j, numFilters;
	
    /* Compute number of filters */
    if (tree == ASYMMETRIC) {
        numFilters = M_ADIC*numLevels;
    } else {
		int_T filtLevel = M_ADIC;
		numFilters = M_ADIC;
		for (i=1; i++ < numLevels;    ) {
			filtLevel *= M_ADIC;
			numFilters += filtLevel;
		}
    }
	
    /************************************************/
    /* Initialize pointers to filter coefficients   */
    for (i=0,j=0; i < numFilters/2; i++) {

        /* Low pass  coeffs */
		ssSetPWorkValue(S, j++, mxGetPr(LFILT_ARG));
		if (filtComplex) {
            ssSetPWorkValue(S, j++, mxGetPi(LFILT_ARG));
		}
        /* High pass coeffs */
		ssSetPWorkValue(S, j++, mxGetPr(HFILT_ARG));
		if (filtComplex) {
            ssSetPWorkValue(S, j++, mxGetPi(HFILT_ARG));
		}
    }    
    
    /**************************************************/
    /* Initialize indexes and Init Conditions         */
    {
        const int_T	  OutBuffSize = ssGetDWorkWidth(S, OutputBuffer);
        const int_T	  OutBuffSize2 = OutBuffSize/2;
        
        if(!isMultiRate || !isMultiTasking) {
           /* Low latency modes are:
            *   SingleRate and SingleTasking
            *   SingleRate and MultiTasking
            *   Multirate  and SingleTasking
            */
            if(tree == SYMMETRIC) {
                /* Symmetric has No latency because there are only 2 rates */
                /* The second half of the output buffer is filled first */
                /* SingleRate is always framebased */
                int_T num = (sampleBased) ? ssGetOutputPortWidth(S, OUTPORT) : 1; 
                outIdx[0] = OutBuffSize2/num;  

            } else {

                /* SingleRate/Assymetric has NO latency by bumping the index by 2 
                 * because you skip one frame of latency this way.  No ICs needed.
                 * Due to cauality you need to wait until you have two sample of
                 * your slowest rate input.
                 */

                outIdx[0] = 2;   
               
                /* MultiRate/SingleTasking/Asymmetric can only decrease latency 
                 * by 2 samples because we have to wait for the fastet input to 
                 * have fired as many times as it can in during the slowest 
                 * inputs period.  There are ICs.  Latency = 2^(numLevels) - 2
                 */
                if(isMultiRate) {
                    real_T *out = ssGetDWork(S, OutputBuffer);  
                    int_T i;
                    
                    /* Initialize the DWORK output buffer to zeros */
                    for(i=0; i<OutBuffSize; i++) *out++ = 0.0;
                }

            }
        } else {
            /* MultiRate and MultiTasking 
             * Latency = 2^(numLevels) 
             */
            real_T *out = ssGetDWork(S, OutputBuffer);  
            int_T i;
                                    
            /* Initialize the DWORK output buffer to zeros */
            for(i=0; i<OutBuffSize; i++) *out++ = 0.0;

            /* Start at first half of output buffer, which is filled with ICs */
            outIdx[0]  =  0;
            
        }
    }
    /******************************************/
    /* Initiliaze below regardless of latency */
    for (i=0; i < numFilters;   ) memIdx[i++] = 0;
    
    wrBuff1[0] =  true;
    
    /* I2Idx only exists if Asymmetric and SampleBased */
    if (tree == ASYMMETRIC && sampleBased) {
        int_T  *i2Idx = ssGetDWork(S, I2Idx);
        int_T  *inputCount = ssGetDWork(S, InputCount);
        
        *inputCount = 0;
        for (i=0; i < numInputs; i++) i2Idx[i] = 0;

    }
}


static void doFilter(SimStruct *S, void *inBuff, void *outBuff, void *memory, 
					 const int_T numSamps, int_T *memIdx,
					 const real_T **cffRPPtr, const real_T **cffIPPtr, const int_T order,
					 const real_T *cffRBase, const real_T *cffIBase) 
{
    const int_T	    filter_length = order + 1;
    const int_T	    iFactor       = M_ADIC;
    const int_T     subOrder      = filter_length / iFactor - 1; /* Compute the order of the subfilters */
    const boolean_T filtComplex   = (boolean_T)mxIsComplex(LFILT_ARG);
    const boolean_T inComplex     = (boolean_T)(ssGetInputPortComplexSignal(S, 0) == COMPLEX_YES);
	
    int_T       thePhase = 0;
    int_T	    mIdx     = 0;
    
    /*
	* The algorithm is fully documented for the real+real case.
	* The other three cases use the same algorithm.
	*/
    
    if (inComplex || filtComplex) {	    /* Complex Data */
		
		if (filtComplex) { /* Complex data, complex filter */
			creal_T         *in         = (creal_T *) inBuff;
			creal_T         *mem0       = (creal_T *) memory;
            creal_T         *out        = (creal_T *) outBuff;
			const real_T    *cffRPtr    = *cffRPPtr;
			const real_T    *cffIPtr    = *cffIPPtr;
			int_T i;
			
			mIdx     = *memIdx;
			
			for (i=0; i++ < numSamps; ) {
				int_T m;
				creal_T u    = *in++;
				
				for (m=0; m++ < M_ADIC; ) { 
					int_T    j = 0;
					creal_T *mem = mem0 + mIdx;
					creal_T  sum, coef;
					
					coef.re = *cffRPtr++;
					coef.im = *cffIPtr++;
					
					sum.re = CMULT_RE(u, coef);
					sum.im = CMULT_IM(u, coef);
					
					if(filter_length > 2) {  /* Protect against having suborder of zero */
						
						for (j=0; j <= mIdx; j++) {
							coef.re = *cffRPtr++;
							coef.im = *cffIPtr++;
							
							sum.re += CMULT_RE(*mem, coef);
							sum.im += CMULT_IM(*mem, coef);
							mem--;
						}
						mem += subOrder;
						while(j++ < subOrder) {
							coef.re = *cffRPtr++;
							coef.im = *cffIPtr++;
							
							sum.re += CMULT_RE(*mem, coef);
							sum.im += CMULT_IM(*mem, coef);
							mem--;
						}
					}					
					*out++ = sum;
					++thePhase;
				}
				if (thePhase == iFactor) thePhase = 0;
				if (thePhase == 0) {
					if (++mIdx >= subOrder) mIdx = 0;
					mem0[mIdx] = u;
                    cffRPtr = cffRBase;
                    cffIPtr = cffIBase;
				}
			} /* frame */
			mem0 += subOrder;
			
		} else {
			/* Complex data, real filter */
			creal_T         *in         = (creal_T *) inBuff;
			creal_T         *out        = (creal_T *) outBuff;
			creal_T         *mem0       = (creal_T *) memory;
			const real_T    *cffRPtr    = *cffRPPtr;
            int_T   i;
			mIdx = *memIdx;
			
			for (i=0; i++ < numSamps; ) {
				creal_T u   = *in++;
				int_T m;
				
				for (m=0; m++ < iFactor; ) { 
					int_T j = 0;
					creal_T *mem = mem0 + mIdx;
					creal_T  sum;
					
					sum.re = u.re * *cffRPtr;
					sum.im = u.im * *cffRPtr++;

					if(filter_length > 2) {  /* Protect against having suborder of zero */
						
						for (j=0; j <= mIdx; j++) {
							sum.re += mem->re     * *cffRPtr;
							sum.im += (mem--)->im * *cffRPtr++;
						}
						mem += subOrder;
						while(j++ < subOrder) {
							sum.re += mem->re     * *cffRPtr;
							sum.im += (mem--)->im * *cffRPtr++;
						}
					}
					*out++ = sum;
					++thePhase;
				}
				if (thePhase == iFactor) thePhase = 0;
				if (thePhase == 0) {
					if (++mIdx >= subOrder) mIdx = 0;
					mem0[mIdx] = u;
                    cffRPtr = cffRBase;
				}
			} /* frame */
			mem0 += subOrder;
		} /* channel */
		
    } else {
		/* Real Data */
		
		if (filtComplex) { /* Real data, complex filter */
            /* Cannot occur */
			
		} else {
			/* Real data, real filter */
			real_T          *in         = (real_T *) inBuff;
			real_T          *mem0       = (real_T *) memory;
			real_T          *out        = (real_T *) outBuff;
			const real_T    *cffRPtr    = *cffRPPtr;
     		int_T i;
			
			mIdx = *memIdx;
			
			for (i=0; i++ < numSamps; ) {
				/* The filter coefficient have (hopefully) been re-ordered into phase order */
				real_T u = *in++;
				int_T        m;
				
				/* Generate the output samples */
				for (m=0; m++ < M_ADIC; ) { 
					int_T   j = 0;
					real_T *mem	= mem0 + mIdx;  /* Most recently saved input */
					real_T  sum	= u * *cffRPtr++;
					
					if(filter_length > 2) {  /* Protect against having suborder of zero */
						
		               /* Compute over the first part of the circular buffer
					    * (only one computation if filter does not wrap over
						* the buffer boundary)
						*/
						
						for (j=0; j <= mIdx; j++) {
							sum += *mem-- * *cffRPtr++;
						}
						
						/* mem was pointing at the -1th element.  Move to end. */
						mem += subOrder;
	                    /* Compute over the second part of the circular buffer
                         * (only needed if filter wraps beyond buffer allocation)
                         */
						while (j++ < subOrder) {
							sum += *mem-- * *cffRPtr++;
						}
					}

					*out++ = sum;
					++thePhase;
				}
				/* Update the counters modulo their buffer size */
				if (thePhase == iFactor) thePhase = 0;
				if (thePhase == 0) {
					if (++mIdx >= subOrder) mIdx = 0;
					/* Save the current input value */
					mem0[mIdx] = u;
                    cffRPtr = cffRBase;
				}
			} /* frame */
			mem0 += subOrder;
		} /* Real Filter */
    } /* Real Data */
    
    /* Update stored indices for the next time */
    *memIdx = mIdx;
}


static void mdlOutputs(SimStruct *S, int_T tid) 
{
    /* Update inputs */
    {
        const int_T     numInputs	= ssGetNumInputPorts(S);
        const int_T	    outPortWidth= ssGetOutputPortWidth(S, OUTPORT);
        const int_T	    numLevels	= (int_T) mxGetPr(LEVELS_ARG)[0];
        const int_T	    lpOrder	    = mxGetNumberOfElements(LFILT_ARG) - 1;
        const int_T	    hpOrder	    = mxGetNumberOfElements(HFILT_ARG) - 1;
        const int_T	    tree	    = (int_T) mxGetPr(TREE_ARG)[0];
        const boolean_T filtComplex = (boolean_T)mxIsComplex(LFILT_ARG);
        const boolean_T	inComplex	= (boolean_T)(ssGetInputPortComplexSignal(S, 0) == true);
        int_T	        numChans    = (int_T) mxGetPr(CHANS_ARG)[0];
        
        int_T           *memIdx	    = (int_T *) ssGetDWork(S, MemIdx);
        boolean_T       *wrBuff1	= (boolean_T *) ssGetDWork(S, WrBuff1);
        const int_T	    outBuffSize = ssGetDWorkWidth(S, OutputBuffer) / 2;
        const boolean_T sampleBased	= (boolean_T)((int_T) mxGetPr(CHANS_ARG)[0] == SAMPLE_BASED);
        int_T	    i, k, j, frame;
        
        if (numChans == SAMPLE_BASED) {
            numChans = outPortWidth;
            frame = 1;
        } else {
            frame = outPortWidth / numChans;
        }
        
        if (sampleBased && tree == ASYMMETRIC) {
            
            /* The inputs have different sample times!! */
                        
            /* We delay processing until we buffer the minimum number of samples
            * that are required to generate an output value.
            * For asymmetric trees, this time is when we have a hit from 
            * input port zero (the lowest-rate port).
            * For symmetric trees, the input times are all the same and we 
            * don't need to store the input data.
            *
            * The data is grouped by channel, lowest rate data first.
            */
            int_T      *i2Idx	    = (int_T *) ssGetDWork(S, I2Idx);
            int_T      *inputCount  = (int_T *) ssGetDWork(S, InputCount);
            int_T       offset      = 0;
            int_T	    minFrame    = 1;
            int_T       wholeFrame  = M_ADIC;
            
            /* wholeframe = 2^numlevels */
            for (i=1; i++ < numLevels;   ) wholeFrame *= M_ADIC;
            
            for (k=0; k < numInputs; k++) {
                if (ssIsSampleHit(S, ssGetInputPortSampleTimeIndex(S, numInputs-k-1), tid)) {
                    
                    if (inComplex) {
                        creal_T         *inBuff	= (creal_T *) ssGetDWork(S, InputBuffer) + offset + i2Idx[k];
                        InputPtrsType   uptr	= ssGetInputPortSignalPtrs(S, numInputs-k-1);
                        for (i=0; i++ < numChans;  ) {
                            *inBuff = *((creal_T *) *uptr++);
                            inBuff += wholeFrame;
                        }
                    } else {
                        InputRealPtrsType   uptr    = ssGetInputPortRealSignalPtrs(S, numInputs-k-1);
                        if (filtComplex) {
                            creal_T *inBuff	= (creal_T *) ssGetDWork(S, InputBuffer) + offset + i2Idx[k];
                            for (i=0; i++ < numChans;  ) {
                                inBuff->re = **uptr++;
                                inBuff->im = (real_T) 0.0;
                                inBuff += wholeFrame;
                            }
                        } else {
                            real_T  *inBuff	= (real_T *) ssGetDWork(S, InputBuffer) + offset + i2Idx[k];
                            for (i=0; i++ < numChans;  ) {
                                *inBuff = **uptr++;
                                inBuff += wholeFrame;
                            }
                        }
                    }
                    if (++i2Idx[k] == minFrame) i2Idx[k] = 0;
                    
                    (*inputCount)++;  /* Input sample counter */
                }
                offset += minFrame;
                if (k > 0) minFrame *= M_ADIC;
            }
            
            /* Check if we have enough samples to process */
            if (*inputCount >= wholeFrame) {
                frame = wholeFrame;
                *inputCount = 0;  /* Reset sample counter to zero */
                
            } else {
                
                /* Wait for next update because we need more input */
                goto PROCESS_OUTPUTS;
            }
        } else {
            
            /* All inputs have the SAME sample times */
            
            /* The last input is the slowest sample time.  If the last input is hit,
            * then we are ready to process the data.  Otherwise wait for next input hit.
            * This relies on the fact that the input ports get processed in order (0  to N-1).
            */
            if (!ssIsSampleHit(S, ssGetInputPortSampleTimeIndex(S, numInputs-1), tid)) {
                
                /* Wait for next update because we need more input */
                goto PROCESS_OUTPUTS;
            }
        }
        
        /* Consider real data and a complex filter.  The output of the first level is
        * complex, making the input to all subsequent levels complex.  For simplicity,
        * we therefore treat the data at all levels as being complex.
        */
        
        /* The algorithm is fully documented for the real+real case.  The other
        * cases use the same algorithm.
        */
        
        if (inComplex || filtComplex) { /* Complex Input */
            creal_T *mem0       = (creal_T *) ssGetDWork(S, States);
            creal_T *sumBuff0   = (creal_T *) ssGetDWork(S, FiltBuffer);
            creal_T *out        = ssGetDWork(S, OutputBuffer);
            creal_T *inBuff0    = (creal_T *) ssGetDWork(S, InputBuffer);
            
            if (*wrBuff1) out += outBuffSize;
            
            for (k=0; k < numChans; k++) {
                creal_T     *sumBuff    = sumBuff0;
                int_T       pwIdx       = 0;
                int_T       filtIdx     = 0;
                int_T       numSamps    = ssGetInputPortWidth(S, numInputs-1) / numChans;
                creal_T     *inBuff     = inBuff0;
                int_T       i;
                
                if (!sampleBased) {
                    creal_T *inPtr  = inBuff0;
                    int_T   aframe  = numSamps;
                    if (inComplex) {
                        for (j=0; j < numInputs; j++) {
                            InputPtrsType uptr = ssGetInputPortSignalPtrs(S, numInputs-j-1) + k*aframe;
                            for (i=0; i++ < aframe;    ) *inPtr++ = *((creal_T *) *uptr++);
                            if (tree == ASYMMETRIC && j > 0) aframe = aframe*2;
                        }
                    } else {
                        for (j=0; j < numInputs; j++) {
                            InputRealPtrsType uptr = ssGetInputPortRealSignalPtrs(S, numInputs-j-1) + k*aframe;
                            for (i=0; i++ < aframe;    ) {
                                inPtr->re     = **uptr++;
                                (inPtr++)->im = (real_T) 0.0;
                            }
                            if (tree == ASYMMETRIC && j > 0) aframe = aframe*2;
                        }
                    }
                } else if (tree == SYMMETRIC) {
                    creal_T *inPtr = inBuff0;
                    if (inComplex) {
                        for (j=0; j < numInputs; j++) {
                            InputPtrsType uptr = ssGetInputPortSignalPtrs(S, numInputs-j-1) + k;
                            *inPtr++ = *((creal_T *) *uptr);
                        }
                    } else {
                        for (j=0; j < numInputs; j++) {
                            InputRealPtrsType   uptr = ssGetInputPortRealSignalPtrs(S, numInputs-j-1) + k;
                            inPtr->re     = **uptr;
                            (inPtr++)->im = (real_T) 0.0;
                        }
                    }
                }
                else inBuff = inBuff0 + k*frame;
                
                if (tree == SYMMETRIC) {
                    int_T       numFiltPairs    = numInputs / M_ADIC;
                    
                    for (i=0; i < numLevels; i++) {
                        int_T       numSamps2   = M_ADIC * numSamps;
                        
                        inBuff     = (creal_T *) ssGetDWork(S, InputBuffer);
                        sumBuff    = sumBuff0;
                        
                        for (j=0; j < numFiltPairs; j++) {
                            int_T           mIdx        = memIdx[filtIdx];
                            const real_T    *cffRPtr    = (real_T *) ssGetPWorkValue(S, filtIdx);
                            const real_T    *cffIPtr;
                            
                            if (filtComplex) {
                                cffIPtr = (real_T *) ssGetPWorkValue(S, filtIdx+1);
                                doFilter(S, inBuff, sumBuff, mem0, numSamps, &mIdx,
                                    &cffRPtr, &cffIPtr, lpOrder, mxGetPr(LFILT_ARG), mxGetPi(LFILT_ARG));
                                if (k == numChans-1) memIdx[filtIdx] = mIdx;
                                filtIdx++;
                                filtIdx++;
                            } else {
                                doFilter(S, inBuff, sumBuff, mem0, numSamps, &mIdx,
                                    &cffRPtr, NULL, lpOrder, mxGetPr(LFILT_ARG), NULL);
                                if (k == numChans-1) memIdx[filtIdx] = mIdx;
                                filtIdx++;
                            }
                            mem0 += lpOrder;
                            
                            mIdx = memIdx[filtIdx];
                            cffRPtr = (real_T *) ssGetPWorkValue(S, filtIdx);
                            if (filtComplex) {
                                cffIPtr = (real_T *) ssGetPWorkValue(S, filtIdx+1);
                                doFilter(S, inBuff+numSamps, sumBuff+numSamps2, mem0, numSamps, &mIdx,
                                    &cffRPtr, &cffIPtr, hpOrder, mxGetPr(HFILT_ARG), mxGetPi(HFILT_ARG));
                                if (k == numChans-1) {
                                    /* Update the counters and the output buffer selector */
                                    memIdx[filtIdx] = mIdx;
                                }
                                filtIdx++;
                                filtIdx++;
                            } else {
                                doFilter(S, inBuff+numSamps, sumBuff+numSamps2, mem0, numSamps, &mIdx,
                                    &cffRPtr, NULL, hpOrder, mxGetPr(HFILT_ARG), NULL);
                                if (k == numChans-1) memIdx[filtIdx] = mIdx;
                                filtIdx++;
                            }
                            mem0 += hpOrder;
                            ++pwIdx;
                            
                            /* Next LP input frame is the sum of the two filter outputs */
                            if (i == numLevels-1) {
                                int_T   m;
                                for (m=0; m < numSamps2; m++) {
                                    out->re     = sumBuff[m].re + sumBuff[m+numSamps2].re;
                                    (out++)->im = sumBuff[m].im + sumBuff[m+numSamps2].im;
                                }
                            } else {
                                int_T   m;
                                for (m=0; m < numSamps2; m++) {
                                    inBuff[m].re = sumBuff[m].re + sumBuff[m+numSamps2].re;
                                    inBuff[m].im = sumBuff[m].im + sumBuff[m+numSamps2].im;
                                }
                                inBuff += numSamps2;
                            }
                        } /* Filter Pairs */
                        numSamps = numSamps2;
                        numFiltPairs /= M_ADIC;
                    } /* Levels */
                } else { /* Asymmetric */
                    for (i=0; i < numSamps; i++) sumBuff[i] = inBuff[i];
                    inBuff += numSamps;
                    
                    for (i=0; i < numLevels; i++) {
                        int_T           mIdx        = memIdx[filtIdx];
                        const real_T    *cffRPtr    = (real_T *) ssGetPWorkValue(S, filtIdx);
                        
                        if (filtComplex) {
                            const real_T    *cffIPtr    = (real_T *) ssGetPWorkValue(S, filtIdx+1);
                            doFilter(S, sumBuff, sumBuff+M_ADIC*numSamps, mem0, numSamps, &mIdx,
                                &cffRPtr, &cffIPtr, lpOrder, mxGetPr(LFILT_ARG), mxGetPi(LFILT_ARG));
                            if (k == numChans-1) memIdx[filtIdx] = mIdx;
                            filtIdx++;
                            filtIdx++;
                        } else {
                            doFilter(S, sumBuff, sumBuff+M_ADIC*numSamps, mem0, numSamps, &mIdx,
                                &cffRPtr, NULL, lpOrder, mxGetPr(LFILT_ARG), NULL);
                            if (k == numChans-1) memIdx[filtIdx] = mIdx;
                            filtIdx++;
                        }
                        mem0 += lpOrder;
                        
                        mIdx = memIdx[filtIdx];
                        cffRPtr = (real_T *) ssGetPWorkValue(S, filtIdx);
                        if (filtComplex) {
                            const real_T    *cffIPtr    = (real_T *) ssGetPWorkValue(S, filtIdx+1);
                            doFilter(S, inBuff, sumBuff, mem0, numSamps, &mIdx,
                                &cffRPtr, &cffIPtr, hpOrder, mxGetPr(HFILT_ARG), mxGetPi(HFILT_ARG));
                            mem0 += hpOrder;
                            if (k == numChans-1) {
                                memIdx[filtIdx] = mIdx;
                            }
                            filtIdx++;
                            filtIdx++;
                        } else {
                            doFilter(S, inBuff, sumBuff, mem0, numSamps, &mIdx,
                                &cffRPtr, NULL, hpOrder, mxGetPr(HFILT_ARG), NULL);
                            mem0 += hpOrder;
                            if (k == numChans-1) {
                                memIdx[filtIdx] = mIdx;
                            }
                            filtIdx++;
                        }
                        inBuff += numSamps;
                        ++pwIdx;
                        
                        numSamps *= M_ADIC;
                        if (i == numLevels-1) {
                            for (j=0; j < numSamps; j++) {
                                out->re     = sumBuff[j].re + sumBuff[j+numSamps].re;
                                (out++)->im = sumBuff[j].im + sumBuff[j+numSamps].im;
                            }
                        } else {
                            for (j=0; j < numSamps; j++) {
                                sumBuff[j].re += sumBuff[j+numSamps].re;
                                sumBuff[j].im += sumBuff[j+numSamps].im;
                            }
                        }
                    } /* Levels */
                } /* Asymmetric */
        } /* Channels */
    } else { /* Real Data */
        real_T  *mem0   = (real_T *) ssGetDWork(S, States);
        
        /* Real Data, Complex Filter */
        /* This case does not occur since we set inComplex = true */
        
        
        /* Real Data, Real Filter */
        real_T  *sumBuff0   = (real_T *) ssGetDWork(S, FiltBuffer);
        real_T  *out        = (real_T *) ssGetDWork(S, OutputBuffer);
        real_T  *inBuff0    = (real_T *) ssGetDWork(S, InputBuffer);
        
        if (*wrBuff1) out += outBuffSize;
        
        for (k=0; k < numChans; k++) {
            real_T      *sumBuff    = sumBuff0;
            int_T       pwIdx       = 0;
            int_T       filtIdx     = 0;
            int_T       numSamps    = ssGetInputPortWidth(S, numInputs-1) / numChans;
            real_T      *inBuff     = inBuff0;
            int_T       i;
            
            /* Fill the input buffer with this channel, lowest-rate data first */
            if (!sampleBased) {
                real_T  *inPtr  = inBuff = inBuff0;
                int_T   aframe  = numSamps;
                for (j=0; j < numInputs; j++) {
                    InputRealPtrsType uptr = ssGetInputPortRealSignalPtrs(S, numInputs-j-1) + k*aframe;
                    for (i=0; i++ < aframe;    ) *inPtr++ = **uptr++;
                    if (tree == ASYMMETRIC && j > 0) aframe = aframe*2;
                }
            } else if (tree == SYMMETRIC) {
                real_T  *inPtr = inBuff = inBuff0;
                for (j=0; j < numInputs; j++) {
                    InputRealPtrsType uptr = ssGetInputPortRealSignalPtrs(S, numInputs-j-1) + k;
                    *inPtr++ = **uptr;
                }
            }
            else inBuff = inBuff0 + k*frame;
            
            if (tree == SYMMETRIC) {
                int_T       numFiltPairs    = numInputs / M_ADIC;
                
                for (i=0; i < numLevels; i++) {
                    int_T       numSamps2   = M_ADIC * numSamps;
                    
                    inBuff     = (real_T *) ssGetDWork(S, InputBuffer);
                    sumBuff    = sumBuff0;
                    
                    for (j=0; j < numFiltPairs; j++) {
                        int_T           mIdx        = memIdx[filtIdx];
                        const real_T    *cffRPtr    = (real_T *) ssGetPWorkValue(S, filtIdx);
                        
                        /* Lowpass filter */
                        doFilter(S, inBuff, sumBuff, mem0, numSamps, &mIdx,
                            &cffRPtr, NULL, lpOrder, mxGetPr(LFILT_ARG), NULL);
                        if (k == numChans-1) memIdx[filtIdx] = mIdx;
                        filtIdx++;
                        mem0 += lpOrder;
                        
                        /* Highpass Filter */
                        mIdx = memIdx[filtIdx];
                        cffRPtr = (real_T *) ssGetPWorkValue(S, filtIdx);
                        doFilter(S, inBuff+numSamps, sumBuff+numSamps2, mem0, numSamps, &mIdx,
                            &cffRPtr, NULL, hpOrder, mxGetPr(HFILT_ARG), NULL);
                        
                        
                        if (k == numChans-1) memIdx[filtIdx] = mIdx;
                        filtIdx++;
                        mem0 += hpOrder;
                        ++pwIdx;
                        
                        if (i == numLevels-1) {
                            int_T m;
                            /* Write to the output buffer */
                            for (m=0; m < numSamps2; m++) {
                                *out++ = sumBuff[m] + sumBuff[m+numSamps2];
                            }
                        } else {
                        /* Next input frame is the sum of the two filter outputs.
                        * We can overwrite the input data since we are done with it
                        * and it has exactly the same number of samples as the input.
                            */
                            int_T m;
                            for (m=0; m < numSamps2; m++) {
                                inBuff[m] = sumBuff[m] + sumBuff[m+numSamps2];
                            }
                            inBuff += numSamps2;
                        }
                    } /* Filter Pairs */
                    numSamps = numSamps2;
                    numFiltPairs /= M_ADIC;
                } /* Levels */
            } else { /* Asymmetric Structure */

                /* Initialize the sum buffer with the low-rate lowpass input data */
                for (i=0; i < numSamps; i++) {
                    sumBuff[i] = inBuff[i];
                }
                inBuff += numSamps;
                
                for (i=0; i < numLevels; i++) {
                    int_T           mIdx        = memIdx[filtIdx];
                    const real_T    *cffRPtr    = (real_T *) ssGetPWorkValue(S, filtIdx);
                    
                    /* Lowpass filter */
                    doFilter(S, sumBuff, sumBuff+M_ADIC*numSamps, mem0, numSamps, &mIdx,
                        &cffRPtr, NULL, lpOrder, mxGetPr(LFILT_ARG), NULL);
                    mem0 += lpOrder;
                    
                    if (k == numChans-1) memIdx[filtIdx] = mIdx;
                    filtIdx++; 
                    
                    /* Highpass Filter accesses the same inputs and has the same phase */
                    mIdx = memIdx[filtIdx];
                    cffRPtr = (real_T *) ssGetPWorkValue(S, filtIdx);
                    
                    doFilter(S, inBuff, sumBuff, mem0, numSamps, &mIdx,
                        &cffRPtr, NULL, hpOrder, mxGetPr(HFILT_ARG), NULL);
                    mem0 += hpOrder;
                    
                    if (k == numChans-1) memIdx[filtIdx] = mIdx;
                    filtIdx++;
                    
                    inBuff += numSamps;
                    ++pwIdx;
                    
                    numSamps *= M_ADIC;
                    if (i == numLevels-1) {
                        /* Write to the output buffer */
                        for (j=0; j < numSamps; j++) {
                            *out++ = sumBuff[j] + sumBuff[j+numSamps];
                        }
                    } else {
                        /* Next LP input frame is the sum of the two filter outputs */
                        for (j=0; j < numSamps; j++) {
                            sumBuff[j] += sumBuff[j+numSamps];
                        }
                    }
                    
                } /* Levels */
            } /* Asymmetric */
        } /* Channels */
    } /* Real Data */
    
    *wrBuff1 = (boolean_T)!(*wrBuff1);
  }

    /* *********************************************** */
    /* Output the next processed sample when requested */
    /* *********************************************** */

PROCESS_OUTPUTS:

    if (ssIsSampleHit(S, ssGetOutputPortSampleTimeIndex(S, OUTPORT), tid)) {

        const int_T     OutPortWidth = ssGetOutputPortWidth(S, OUTPORT);
        const int_T     OutBuffSize  = ssGetDWorkWidth(S, OutputBuffer) / 2;

        const boolean_T inComplex    = (boolean_T)(ssGetInputPortComplexSignal(S, 0) == true);
        const boolean_T filtComplex  = (boolean_T)mxIsComplex(LFILT_ARG);

        int_T           *out1        = (int_T *) ssGetDWork(S, OutIdx);
        int_T           numChans     = (int_T) mxGetPr(CHANS_ARG)[0];
        int_T           k;
		
        /* Output values in the buffer are grouped by channel */
        if (numChans == SAMPLE_BASED) {
            int_T   OutFrameSize    = OutBuffSize / OutPortWidth;

            if (inComplex || filtComplex) {
				creal_T	*y	  = (creal_T *) ssGetDWork(S, OutputBuffer) + *out1;
				creal_T	*yout = (creal_T *) ssGetOutputPortSignal(S, OUTPORT);

                if (*out1 >= OutFrameSize) y += (OutBuffSize - OutFrameSize);

                for (k=0; k < OutPortWidth; k++)  {
                    *yout++ = *y;
                    y += OutFrameSize;
                }
            } else {
				real_T	*y    = (real_T *) ssGetDWork(S, OutputBuffer) + *out1;
				real_T	*yout = ssGetOutputPortRealSignal(S, OUTPORT);

                if (*out1 >= OutFrameSize) y += (OutBuffSize - OutFrameSize);

                for (k=0; k < OutPortWidth; k++)  {
                    *yout++ = *y;
                    y += OutFrameSize;
                }
            }
            if (++(*out1) >= 2*OutFrameSize) *out1 = 0;

        } else { /* Frame-based outputs */
            if (inComplex || filtComplex) {
				creal_T	*y	  = (creal_T *) ssGetDWork(S, OutputBuffer);
				creal_T	*yout = (creal_T *) ssGetOutputPortSignal(S, OUTPORT);

                if (*out1 > 0) y += OutBuffSize;

                for (k=0; k++ < OutPortWidth;    )  *yout++ = *y++;

            } else {
				real_T	*y    = (real_T *) ssGetDWork(S, OutputBuffer);
				real_T	*yout = ssGetOutputPortRealSignal(S, OUTPORT);

                if (*out1 > 0) y += OutBuffSize;

                for (k=0; k++ < OutPortWidth;    )  *yout++ = *y++;
            }
            if (*out1 > 0) *out1 = 0;
            else *out1 = 1;
        }
    }
}

static void mdlTerminate(SimStruct *S)
{
}

#if defined(MATLAB_MEX_FILE) 
#define MDL_SET_OUTPUT_PORT_SAMPLE_TIME 
static void mdlSetOutputPortSampleTime(SimStruct *S, 
									   int_T     portIdx, 
									   real_T    sampleTime, 
									   real_T    offsetTime) 
{ 
    const int_T numLevels   = (int_T) mxGetPr(LEVELS_ARG)[0];
    const int_T numChans    = (int_T) mxGetPr(CHANS_ARG)[0];
    const int_T tree        = (int_T) mxGetPr(TREE_ARG)[0];
    const int_T numInputs   =  ssGetNumInputPorts(S);
    int_T       i;
	
	/* Always set sample times to values passed */
    ssSetOutputPortSampleTime(S, portIdx, sampleTime); 
    ssSetOutputPortOffsetTime(S, portIdx, offsetTime);
	
	/* Only compute and check sample times if port is connected */
	if (ssGetOutputPortConnected(S,portIdx)) {
		
        if (sampleTime == CONTINUOUS_SAMPLE_TIME) { 
            THROW_ERROR(S,"Continuous output sample times not allowed for dyadic synthesis."); 
        } 

		if (offsetTime != 0.0) { 
			ssSetErrorStatus(S, "Non-zero sample time offsets not allowed for dyadic synthesis."); 
			return; 
		} 
		
		if (tree == SYMMETRIC && numChans == SAMPLE_BASED) {
			sampleTime *= numInputs;
		}

        /* Set INPUT sample times */
        if(tree == ASYMMETRIC && numChans == SAMPLE_BASED) {
            for (i=0; i < numInputs; i++) {
                real_T Ts_i = ssGetInputPortSampleTime(S, i);

                if(i != numLevels) sampleTime *= 2.0;          /* if not last input */

                if (Ts_i == INHERITED_SAMPLE_TIME) {
                    ssSetInputPortSampleTime(S, i, sampleTime);
                    ssSetInputPortOffsetTime(S, i, 0.0);
                } else if(Ts_i != sampleTime) {
                    THROW_ERROR(S,"Input sample times must be a factor of 2");
                }
            }

        } else { /* SYMMETRIC || FRAMEBASED */
            
            for (i=0; i < numInputs; i++) {
                real_T Ts_i = ssGetInputPortSampleTime(S, i);
                
                if (Ts_i == INHERITED_SAMPLE_TIME) {
                    ssSetInputPortSampleTime(S, i, sampleTime);
                    ssSetInputPortOffsetTime(S, i, 0.0);
                } else if(Ts_i !=sampleTime) {
                    THROW_ERROR(S,"Input sample times must all be equal");
                }
            }
        }
	}
} 


#define MDL_SET_INPUT_PORT_SAMPLE_TIME 
static void mdlSetInputPortSampleTime(SimStruct *S, 
                                      int_T     portIdx, 
                                      real_T    sampleTime, 
                                      real_T    offsetTime) 
{
    const int_T numLevels   = (int_T) mxGetPr(LEVELS_ARG)[0];
    const int_T numChans    = (int_T) mxGetPr(CHANS_ARG)[0];
    const int_T tree        = (int_T) mxGetPr(TREE_ARG)[0];
    const int_T numInputs   =  ssGetNumInputPorts(S);
    int_T       i;

	/* Always set sample times to values passed */
    ssSetInputPortSampleTime(S, portIdx, sampleTime); 
    ssSetInputPortOffsetTime(S, portIdx, offsetTime);

	/* Only compute and check sample times if port is connected */
	if (ssGetInputPortConnected(S,portIdx)) {	
        
        if (sampleTime == CONTINUOUS_SAMPLE_TIME) {
            THROW_ERROR(S,"Continuous sample times not allowed for dyadic synthesis block.");
        }
		if (offsetTime != 0.0) { 
			ssSetErrorStatus(S, "Non-zero sample time offsets not allowed."); 
			return; 
		} 
		
        /* Set OUTPUT sample times */
		if (tree == SYMMETRIC) {

            if (ssGetOutputPortSampleTime(S, OUTPORT) == INHERITED_SAMPLE_TIME) {

                real_T OutSampTime = (numChans == SAMPLE_BASED) ? sampleTime/numInputs : sampleTime;

                ssSetOutputPortSampleTime(S, OUTPORT, OutSampTime); 
                ssSetOutputPortOffsetTime(S, OUTPORT, 0.0);
            }
        } else { /* ASYMMETRIC */

			/* Compute the output rate for a sample-based block */
			if (numChans == SAMPLE_BASED) {
				if (portIdx != numLevels) ++portIdx;
                /* Calculate what the first input sample time should be and dived it by two */
				while (portIdx--) sampleTime /= M_ADIC;
			}
			if (ssGetOutputPortSampleTime(S, OUTPORT) == INHERITED_SAMPLE_TIME) {
				ssSetOutputPortSampleTime(S, OUTPORT, sampleTime); 
				ssSetOutputPortOffsetTime(S, OUTPORT, 0.0);
			}
		}
		
        /* Set INPUT sample times */
        if(tree == ASYMMETRIC && numChans == SAMPLE_BASED) {
            for (i=0; i < numInputs; i++) {
                real_T Ts_i = ssGetInputPortSampleTime(S, i);

                if(i != numLevels) sampleTime *= 2.0;          /* if not last input */

                if (Ts_i == INHERITED_SAMPLE_TIME) {
                    ssSetInputPortSampleTime(S, i, sampleTime);
                    ssSetInputPortOffsetTime(S, i, 0.0);
                } else if(Ts_i != sampleTime) {
                    THROW_ERROR(S,"Input sample times must be a factor of 2");
                }
            }

        } else { /* SYMMETRIC || FRAMEBASED */
            
            for (i=0; i < numInputs; i++) {
                real_T Ts_i = ssGetInputPortSampleTime(S, i);
                
                if (Ts_i == INHERITED_SAMPLE_TIME) {
                    ssSetInputPortSampleTime(S, i, sampleTime);
                    ssSetInputPortOffsetTime(S, i, 0.0);
                } else if(Ts_i !=sampleTime) {
                    THROW_ERROR(S,"Input sample times must all be equal");
                }
            }
        }
    } /* if input port connected */
} 
#endif 

#ifdef MATLAB_MEX_FILE
#define MDL_SET_OUTPUT_PORT_WIDTH
static void mdlSetOutputPortWidth(SimStruct *S, int_T port, int_T outputPortWidth)
{
    const int_T	numChans    = (int_T) mxGetPr(CHANS_ARG)[0];
    const int_T	numLevels   = (int_T) mxGetPr(LEVELS_ARG)[0];
    const int_T	tree        = (int_T) mxGetPr(TREE_ARG)[0];
    const int_T numInputs   =  ssGetNumInputPorts(S);
    int_T       minWidth, i, inputPortWidth; 
	
    ssSetOutputPortWidth (S, port, outputPortWidth);    
	
    /* Only set the port widths if the port is connected. */
    if (ssGetOutputPortConnected(S,port)) {
		
		minWidth = M_ADIC;
		for (i=1; i++ < numLevels;   ) minWidth *= M_ADIC;
	
		if (numChans != SAMPLE_BASED) {
			/* Check if output port width is acceptable */
			if ((outputPortWidth % minWidth) != 0) {
				ssSetErrorStatus(S,"The output frame size must be a multiple of "
					"2^(number of levels)");
				return;
			}
			if (tree == ASYMMETRIC) minWidth = outputPortWidth;
			else minWidth = outputPortWidth / minWidth;
			
			for (i=0; i < numInputs; i++) {
				inputPortWidth = ssGetInputPortWidth(S, i);
				if (tree == ASYMMETRIC && i != numLevels) minWidth /= 2;
				if (inputPortWidth == DYNAMICALLY_SIZED && (outputPortWidth % minWidth) == 0) {
					ssSetInputPortWidth(S, i, minWidth);
				} else if (inputPortWidth != minWidth) {
					ssSetErrorStatus (S, "(Output port width)/(Input port width) "
						"must equal the interpolation factor at each input level");
					return;
				}
			}
		} else {
			for (i=0; i < numInputs; i++) {
				inputPortWidth = ssGetInputPortWidth(S, i);
				if (inputPortWidth == DYNAMICALLY_SIZED) {
					ssSetInputPortWidth(S, i, outputPortWidth);
				} else if (outputPortWidth != inputPortWidth) {
					ssSetErrorStatus (S, "Input port width must equal output port width");
					return;
				}
			}
		}
	}
}

#define MDL_SET_INPUT_PORT_WIDTH
static void mdlSetInputPortWidth(SimStruct *S, int_T port, int_T inputPortWidth)
{
    const int_T	numLevels   = (int_T) mxGetPr(LEVELS_ARG)[0];
    const int_T	numChans    = (int_T) mxGetPr(CHANS_ARG)[0];
    const int_T	tree        = (int_T) mxGetPr(TREE_ARG)[0];
    int_T       outWidth    = inputPortWidth;
    const int_T numInputs   =  ssGetNumInputPorts(S);
    int_T       i, minWidth;
	
	ssSetInputPortWidth(S, port, inputPortWidth);
	
    /* Only set the port widths if the port is connected. */
    if (ssGetInputPortConnected(S,port)) {
		
		if (numChans != SAMPLE_BASED) {
			if (tree == ASYMMETRIC) {
				for (i=port; i-- >= 0;    ) outWidth *= 2;
				if (port == numLevels) outWidth /= 2;
			} else {
				for (i=0; i++ < numLevels;    ) outWidth *= 2;
			}
		}
		
		if (ssGetOutputPortWidth(S, OUTPORT) == DYNAMICALLY_SIZED) {
			ssSetOutputPortWidth (S, OUTPORT, outWidth);
		}
		
		if (numChans != SAMPLE_BASED) {
			if (tree == ASYMMETRIC ) {
				minWidth = outWidth;
			} else {
				minWidth = inputPortWidth;
			}
			for (i=0; i < numInputs; i++) {
				inputPortWidth = ssGetInputPortWidth(S, i);
				if (tree == ASYMMETRIC && i != numLevels) minWidth /= 2;

				/* Protect against integer division by zero */
				if (minWidth == 0) THROW_ERROR(S, "Port widths must all be a multiple of 2");
				
				if (inputPortWidth == DYNAMICALLY_SIZED && (outWidth % minWidth) == 0) {
					ssSetInputPortWidth(S, i, minWidth);
				} else if (inputPortWidth != minWidth) {
					ssSetErrorStatus (S, "(Output port width)/(Input port width) "
						"must equal the interpolation factor at each input level");
					return;
				}
			}
		} else {
			for (i=0; i < numInputs; i++) {
				inputPortWidth = ssGetInputPortWidth(S, i);
				if (inputPortWidth == DYNAMICALLY_SIZED) {
					ssSetInputPortWidth(S, i, outWidth);
				} else if (inputPortWidth != outWidth) {
					ssSetErrorStatus (S, "Input port width must equal output port width");
					return;
				}
			}
		}
	}
}

#define MDL_SET_OUTPUT_PORT_COMPLEX_SIGNAL
static void mdlSetOutputPortComplexSignal(SimStruct *S, int_T portIdx,
                                          CSignal_T      oPortComplexSignal)
{    
    /* Consistency check is in mdlStart() */
    ssSetOutputPortComplexSignal(S, portIdx, oPortComplexSignal ? COMPLEX_YES : COMPLEX_NO);
}

#define MDL_SET_INPUT_PORT_COMPLEX_SIGNAL
static void mdlSetInputPortComplexSignal(SimStruct *S, int_T portIdx,
                                         CSignal_T      iPortComplexSignal)
{
    const boolean_T complex     = (boolean_T) (iPortComplexSignal ? COMPLEX_YES : COMPLEX_NO);
    const int_T     numInputs   =  ssGetNumInputPorts(S);
          int_T     i;
	
    /* Always set the complexity of the port that Simulink propagates */
    ssSetInputPortComplexSignal(S, portIdx, complex);

    /* All inputs must have the same complexity */
    for (i=0; i < numInputs; i++) {
		if (ssGetInputPortComplexSignal(S, i) == COMPLEX_INHERITED) {
			ssSetInputPortComplexSignal(S, i, complex);
		}
    }
	
    if (mxIsComplex(LFILT_ARG) || mxIsComplex(HFILT_ARG)) {
		ssSetOutputPortComplexSignal(S, OUTPORT, COMPLEX_YES);
    } else {
		ssSetOutputPortComplexSignal(S, OUTPORT, complex);
    }
}
#endif


#ifdef MATLAB_MEX_FILE
#define MDL_SET_WORK_WIDTHS
static void mdlSetWorkWidths(SimStruct *S)
{
    const int_T	 outPortWidth  = ssGetOutputPortWidth(S, OUTPORT);
    const int_T  numLevels     = (int_T) mxGetPr(LEVELS_ARG)[0];
    const int_T  lpOrder       = mxGetNumberOfElements(LFILT_ARG) - 1;
    const int_T  hpOrder       = mxGetNumberOfElements(HFILT_ARG) - 1;
    const int_T	 numInputs     = ssGetNumInputPorts(S);
          int_T  numChans      = (int_T) mxGetPr(CHANS_ARG)[0];


    const boolean_T  symmetric     = (boolean_T)(mxGetPr(TREE_ARG)[0] == SYMMETRIC);
    const boolean_T	 inputComplex  = (boolean_T)(ssGetInputPortComplexSignal(S, 0) == COMPLEX_YES);
    const boolean_T	 filtComplex   = (boolean_T)(mxIsComplex(LFILT_ARG) || mxIsComplex(HFILT_ARG));
    const boolean_T  sampleBased   = (boolean_T)(numChans == SAMPLE_BASED);

    int_T	     minFrame      = M_ADIC;
    int_T	     i, numFilters;
	
    if (sampleBased) {
		numChans = outPortWidth;
    }
	
    /* Compute the minimum output frame size */
    if ((int_T) mxGetPr(CHANS_ARG)[0] == SAMPLE_BASED) {
        for (i=1; i++ < numLevels;   ) minFrame *= M_ADIC;
    } else {
        minFrame = outPortWidth / numChans;
    }
	
    /* Compute the number of filters */
    if (!symmetric) {
        numFilters = M_ADIC*numLevels;
    } else {
		int_T filtLevel = M_ADIC;
		numFilters = M_ADIC;
		for (i=1; i++ < numLevels;    ) {
			filtLevel *= M_ADIC;
			numFilters += filtLevel;
		}
    }
	
    /* Compute number of DWORKS */
    {
        int_T numDWorks = NUM_DWORKS;
        if(!sampleBased || symmetric) numDWorks -= 2;

        ssSetNumDWork(S, numDWorks);
    }

    /* Set up output port double buffer */
    ssSetDWorkWidth(   S, OutputBuffer, 2*minFrame*numChans);
    ssSetDWorkDataType(S, OutputBuffer, SS_DOUBLE);
    ssSetDWorkName(    S, OutputBuffer, "OutBuff");
    /* Filter buffer */
    ssSetDWorkWidth(   S, FiltBuffer,   2*minFrame);
    ssSetDWorkDataType(S, FiltBuffer,   SS_DOUBLE);
    ssSetDWorkName(    S, FiltBuffer,   "FiltBuff");
	
    ssSetDWorkWidth(   S, States,       numFilters/2*numChans*(lpOrder+hpOrder));
    ssSetDWorkName(    S, States,       "States");
    ssSetDWorkDataType(S, States,       SS_DOUBLE);
	
    if ((int_T) mxGetPr(CHANS_ARG)[0] == SAMPLE_BASED) {
		/* Need to buffer the input */
        ssSetDWorkWidth (S, InputBuffer,    numChans*minFrame);
    } else {
        ssSetDWorkWidth(S,  InputBuffer,    minFrame);
    }
    ssSetDWorkDataType(S,   InputBuffer,    SS_DOUBLE);
    ssSetDWorkName(S,       InputBuffer,    "InBuff");
	
    if (inputComplex || filtComplex) {
        ssSetDWorkComplexSignal(S,  States,         COMPLEX_YES);
        ssSetDWorkComplexSignal(S,  OutputBuffer,   COMPLEX_YES);
        ssSetDWorkComplexSignal(S,  FiltBuffer,     COMPLEX_YES);
        ssSetDWorkComplexSignal(S,  InputBuffer,    COMPLEX_YES);
        ssSetDWorkWidth(S,          MemIdx,         2*numFilters);
    } else {
        ssSetDWorkWidth(S,          MemIdx,         numFilters);
    }
    ssSetDWorkDataType(S,       MemIdx,     SS_INT32);
    ssSetDWorkName(S,           MemIdx,     "MemIdx");
	
    ssSetDWorkWidth(   S,   WrBuff1,    1);
    ssSetDWorkDataType(S,	WrBuff1,    SS_BOOLEAN);
    ssSetDWorkName(    S,   WrBuff1,    "WrBuff1");
    ssSetDWorkWidth(   S,	OutIdx,     1);
    ssSetDWorkDataType(S,	OutIdx,     SS_INT32);
    ssSetDWorkName(    S,   OutIdx,     "OutIdx");
    
    if (sampleBased && !symmetric) {
        ssSetDWorkWidth(   S,	I2Idx,      numInputs);
        ssSetDWorkDataType(S,	I2Idx,      SS_INT32);
        ssSetDWorkName(    S,   I2Idx,      "I2Idx");

        ssSetDWorkWidth(   S,	InputCount, 1);
        ssSetDWorkDataType(S,	InputCount, SS_INT32);
        ssSetDWorkName(    S,   InputCount, "InputCount");
    } 

}
#endif


#define MDL_RTW
#if defined(MATLAB_MEX_FILE) || defined(NRT)
static void mdlRTW(SimStruct *S)
{
    int32_T levels   = (int32_T)mxGetPr(LEVELS_ARG)[0];
    int32_T tree     = (int32_T)mxGetPr(TREE_ARG)[0];
    int32_T numChans = (int32_T)mxGetPr(CHANS_ARG)[0];
	
	
	/* The length of the pwork varies with the number of inputs,
	* symmetry, and complexity.
	*/
	
    int_T i, numInputs, numFilters, numLevels;
	
	numLevels   = (int_T) mxGetPr(LEVELS_ARG)[0];
	
	if ((int_T) mxGetPr(TREE_ARG)[0] == ASYMMETRIC) {
		numInputs = numLevels + 1;
		numFilters = M_ADIC*numLevels;
	} else {
		numInputs = M_ADIC;
		numFilters = M_ADIC*M_ADIC;
		for (i=1; i++ < numLevels;    ) {
			numInputs *= M_ADIC;
			numFilters += numInputs;
		}
	}
	
    /* Pointers to filter coefficients */
    if (mxIsComplex(LFILT_ARG) || mxIsComplex(HFILT_ARG)) {
        /* RTW really only needs numFilters + 2 */
        numFilters *= 2; /* Re + Im */
    } else {
        /* Two extra needed for RTW */
        numFilters += 2;
    }
	
	/* NOTE: A bug in ../simulink/inlcude/simulink.c prevents
	 *       us from writing our a vector of PWorks.  The bug
	 *       is fixed in the R12 source code.
	 *
	 * Write out the PWork record to the RTW file.
	 * 
     * if(!ssWriteRTWWorkVect(S, "PWork", 1, "pfilt", numFilters)) {
	 *	 return;  
     * }
	 */
			
    if (!ssWriteRTWParamSettings(S, 5,
		
		SSWRITE_VALUE_DTYPE_ML_VECT, "LFILT", 
		mxGetPr(LFILT_ARG), mxGetPi(LFILT_ARG), 
		mxGetNumberOfElements(LFILT_ARG),
		DTINFO(SS_DOUBLE, mxIsComplex(LFILT_ARG)),
		
		SSWRITE_VALUE_DTYPE_ML_VECT, "HFILT",
		mxGetPr(HFILT_ARG), mxGetPi(HFILT_ARG), 
		mxGetNumberOfElements(HFILT_ARG),
		DTINFO(SS_DOUBLE, mxIsComplex(HFILT_ARG)),
		
		SSWRITE_VALUE_DTYPE_NUM,  "LEVELS",
		&levels,
		DTINFO(SS_INT32,0),
		
		SSWRITE_VALUE_DTYPE_NUM,  "TREE",
		&tree,
		DTINFO(SS_INT32,0),
		
		SSWRITE_VALUE_DTYPE_NUM,  "NUM_CHANS",
		&numChans,
		DTINFO(SS_INT32,0))) {
        return;
    }
}
#endif

#ifdef	MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-File interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif
