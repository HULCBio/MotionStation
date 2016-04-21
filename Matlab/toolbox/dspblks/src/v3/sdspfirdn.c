/*
 * SDSPFIRDN A SIMULINK decimating FIR filter block.
 *        DSP Blockset S-Function for the efficient polyphase
 *        implementation of a FIR decimation filter.
 *
 *   
 *  Copyright 1995-2002 The MathWorks, Inc.
 *  $Revision: 1.27 $  $Date: 2002/04/14 20:42:13 $
 */

#define S_FUNCTION_LEVEL 2
#define S_FUNCTION_NAME sdspfirdn

#include "dsp_sim.h"


/*
 * Defines for easy access of the input parameters
 */
enum {
    ARGC_FILT = 0,
    ARGC_DFACTOR,
    ARGC_NUMCHANS,
    ARGC_FRAMING,
    ARGC_INIT_COND_OUTBUF,
    NUM_ARGS
};

#define FILT_ARG            ssGetSFcnParam(S, ARGC_FILT)
#define DFACTOR_ARG         ssGetSFcnParam(S, ARGC_DFACTOR)
#define NCHANS_ARG          ssGetSFcnParam(S, ARGC_NUMCHANS)
#define FRAMING_ARG         ssGetSFcnParam(S, ARGC_FRAMING)
#define OUTBUF_INITCOND_ARG ssGetSFcnParam(S, ARGC_INIT_COND_OUTBUF)

/* For frame-based processing, you can select either:
 * 1) the output frame rate equal to the input frame rate (output frame size is smaller).
 * 2) the output frame size equal to the input frame size (output frame rate is slower).
 */
enum {CONST_SIZE_FRAMING=1, CONST_RATE_FRAMING};

/* An invalid number of channels (-1) is used to flag channel-based operation.
 * CHANNEL_BASED = Sample-based inputs OR frame-based with constant frame size.
 */
const int_T CHANNEL_BASED = -1;

/* Port Index Enumerations */
enum {INPORT  = 0, NUM_INPORTS};
enum {OUTPORT = 0, NUM_OUTPORTS};

/* DWork indices */
enum {
    PhaseIdx = 0,
    TapDelayIndex,
    OutIdx,
    PartialSums,
    OutputBuffer,
    InBuff1,
    OutBuff1,
    TapDelayLineBuff,
    NUM_DWORKS
};

/* PWork indices */
enum {CffRPtr = 0, CffIPtr, NUM_PWORKS};


#ifdef MATLAB_MEX_FILE
#define MDL_CHECK_PARAMETERS
static void mdlCheckParameters(SimStruct *S) {
    const int_T     numDFArg     = mxGetNumberOfElements(DFACTOR_ARG);
    const int_T     numFiltArg   = mxGetNumberOfElements(FILT_ARG);
    const boolean_T runTime      = (ssGetSimMode(S) != SS_SIMMODE_SIZES_CALL_ONLY);


    /* Decimation factor */
    if (OK_TO_CHECK_VAR(S, DFACTOR_ARG)) {
        if (!IS_FLINT_GE(DFACTOR_ARG, 1)) {
            THROW_ERROR(S, "Decimation factor must be a real, scalar integer > 0.");
        }
    }

    /* Check filter coefficients */
    if (runTime || (numFiltArg >= 1 && numDFArg == 1)) {
        if (mxIsEmpty(FILT_ARG) || mxGetN(FILT_ARG) != mxGetPr(DFACTOR_ARG)[0]) {
            THROW_ERROR(S,"Decimation filter must be a polyphase matrix with the number of "
                    "columns equal to the decimation factor.");
        }

        if (mxGetNumberOfElements(FILT_ARG) < 2) {
            THROW_ERROR(S,"For proper operation, the number of filter coefficients "
                  "in the polyphase matrix must be at least two.  Use a decimation "
                  "factor >= 2 or increase the filter order.");
        }
    }

    /* Number of channels - only check if frame-based: */
    if (OK_TO_CHECK_VAR(S, NCHANS_ARG)) { 
        if ( !IS_FLINT_GE(NCHANS_ARG, 1) && ((!IS_FLINT(NCHANS_ARG)) || (mxGetPr(NCHANS_ARG)[0] != -1)) ) {
            /* -1 is set in the mask but not by the user */
            THROW_ERROR(S, "Number of channels must be a real, scalar integer > 0."
                         "If it is -1, the number of channels equals the input port width.");
        }
    }

    /* Check output buffer initial conditions */
    if (OK_TO_CHECK_VAR(S, OUTBUF_INITCOND_ARG)) {
        if (!mxIsNumeric(OUTBUF_INITCOND_ARG) || mxIsSparse(OUTBUF_INITCOND_ARG)) {
            THROW_ERROR(S,"Output buffer initial conditions must be numeric.");
        }
    }

    /* Check framing method */
    if (!IS_FLINT_IN_RANGE(FRAMING_ARG, CONST_SIZE_FRAMING, CONST_RATE_FRAMING)) {
        THROW_ERROR(S, "The valid choices for output framing are 1 and 2.");
    }
}
#endif


static void mdlInitializeSizes(SimStruct *S)
{
    ssSetNumSFcnParams(S, NUM_ARGS);

#if defined(MATLAB_MEX_FILE)
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) return;
    mdlCheckParameters(S);
    if (ssGetErrorStatus(S) != NULL) return;
#endif

    ssSetSFcnParamNotTunable(S, ARGC_FILT);
    ssSetSFcnParamNotTunable(S, ARGC_DFACTOR);
    ssSetSFcnParamNotTunable(S, ARGC_NUMCHANS);
    ssSetSFcnParamNotTunable(S, ARGC_FRAMING);
    ssSetSFcnParamNotTunable(S, ARGC_INIT_COND_OUTBUF);

    ssSetNumSampleTimes(S, PORT_BASED_SAMPLE_TIMES);

    if (!ssSetNumInputPorts(        S, NUM_INPORTS)) return;
    ssSetInputPortWidth(            S, INPORT, DYNAMICALLY_SIZED);
    ssSetInputPortComplexSignal(    S, INPORT, COMPLEX_INHERITED); 
    ssSetInputPortSampleTime(       S, INPORT, INHERITED_SAMPLE_TIME);
    ssSetInputPortDirectFeedThrough(S, INPORT, 1);
    ssSetInputPortReusable(         S, INPORT, 0);
    ssSetInputPortOverWritable(     S, INPORT, 0); /* revisits inputs multiple times */

    if (!ssSetNumOutputPorts(    S, NUM_OUTPORTS)) return;
    ssSetOutputPortWidth(        S, OUTPORT, DYNAMICALLY_SIZED);
    ssSetOutputPortComplexSignal(S, OUTPORT, COMPLEX_INHERITED); 
    ssSetOutputPortSampleTime(   S, OUTPORT, INHERITED_SAMPLE_TIME);
    ssSetOutputPortReusable(     S, OUTPORT, 0);

    if(!ssSetNumDWork(  S, DYNAMICALLY_SIZED)) return;
    ssSetNumPWork(      S, NUM_PWORKS);
    ssSetOptions(       S, SS_OPTION_EXCEPTION_FREE_CODE);
}


#define MDL_START
static void mdlStart (SimStruct *S)
{
#ifdef MATLAB_MEX_FILE
    const int_T portWidth   = ssGetInputPortWidth(S, INPORT);
    const int_T dFactor     = (int_T) *mxGetPr(DFACTOR_ARG);
    int_T       numChans    = (int_T) *mxGetPr(NCHANS_ARG);
    int_T       framing     = (int_T) *mxGetPr(FRAMING_ARG);
    boolean_T   complex     = mxIsComplex(FILT_ARG) ||
                            (ssGetInputPortComplexSignal(S, INPORT) == COMPLEX_YES);
    int_T       frame;

    if (numChans == CHANNEL_BASED)  {
        frame = 1;
        numChans = portWidth;
    }
    else {
        frame = portWidth / numChans;
    }


    if ((int_T) *mxGetPr(NCHANS_ARG) != CHANNEL_BASED && framing == CONST_RATE_FRAMING && (frame % dFactor) != 0) {
        THROW_ERROR(S,"The input frame size must be a multiple of "
                           "the decimation factor.");
    }
    
    if (numChans != CHANNEL_BASED && (ssGetInputPortWidth(S, INPORT) % numChans)) {
        THROW_ERROR(S,"The port width must be a multiple of the number of channels.");
    }
    
    if (ssGetSampleTime(S, 0) == CONTINUOUS_SAMPLE_TIME) {
        THROW_ERROR(S,"Input to block must have a discrete sample time.");
    }

    if ((complex  && ssGetOutputPortComplexSignal(S, OUTPORT) != COMPLEX_YES) ||
        (!complex && ssGetOutputPortComplexSignal(S, OUTPORT) != COMPLEX_NO)) {
        THROW_ERROR(S, "If the input or filter coefficients are complex "
                     "then the output must be complex.");
    }	 
#endif
}


static void mdlInitializeSampleTimes(SimStruct *S) 
{ 
    /* Check port sample times: */ 
    const real_T Tsi = ssGetInputPortSampleTime(S, INPORT); 
    const real_T Tso = ssGetOutputPortSampleTime(S, OUTPORT); 

    if ((Tsi == INHERITED_SAMPLE_TIME)  || 
        (Tso == INHERITED_SAMPLE_TIME)   ) { 
        THROW_ERROR(S, "Sample time propagation failed for decimation filter.");
    } 

    if ((Tsi == CONTINUOUS_SAMPLE_TIME) || 
        (Tso == CONTINUOUS_SAMPLE_TIME)  ) {
        THROW_ERROR(S, "Continuous sample times not allowed for decimation filter.");
    }
}


#define MDL_INITIALIZE_CONDITIONS
static void mdlInitializeConditions(SimStruct *S)
{
    int_T          *phasePtr       = (int_T *) ssGetDWork(S, PhaseIdx);
    int_T          *memPtr         = (int_T *) ssGetDWork(S, TapDelayIndex);
    int_T          *outPtr         = (int_T *) ssGetDWork(S, OutIdx);
    const int_T     dFactor        = (int_T) *mxGetPr(DFACTOR_ARG);
    const int_T     length         = (int_T) mxGetNumberOfElements(FILT_ARG);
    const boolean_T cplxInp        = (boolean_T)(ssGetInputPortComplexSignal(S, INPORT) == COMPLEX_YES);
    const boolean_T filtComplex    = mxIsComplex(FILT_ARG);
    const int_T     numICs         = mxGetNumberOfElements(OUTBUF_INITCOND_ARG);
    const int_T     outputBufLen   = ssGetDWorkWidth(S, OutputBuffer);
    boolean_T      *inBuff1        = (boolean_T *) ssGetDWork(S, InBuff1);
    boolean_T      *outBuff1       = (boolean_T *) ssGetDWork(S, OutBuff1);
    int_T          *outIdx         = (int_T *) ssGetDWork(S, OutIdx);
    const boolean_T multiRateBlock = isBlockMultiRate(S,INPORT,OUTPORT);
    const boolean_T isMultiTasking = isModelMultiTasking(S);
    const int_T     numChans       = (int_T) *mxGetPr(NCHANS_ARG);

    *memPtr = *outIdx = *outPtr = 0;
    *outBuff1 = true;
    
    /* Assume that the inputs are always available on first time sample hit */
    *inBuff1 =  true;

    if ( isMultiTasking && multiRateBlock )
    {
        /* We cannot be guaranteed that the inputs are always available on */
        /* the first time sample hit in this mode (depending on the model  */
        /* signal arrival times - remember that this mode is both time-    */
        /* based AND task-based, so nothing is guaranteed with respect to  */
        /* data arrival, unlike an interrupt-based hardware system!!!).    */
        /* By setting this flag to false, a single output-width delay is   */
        /* always inserted in this mode for consistent behavior.           */
        *inBuff1 =  false;
    }
    else if ( (numChans != CHANNEL_BASED)
              && ((mxGetPr(FRAMING_ARG)[0]) == CONST_SIZE_FRAMING)
              && multiRateBlock )
    {
        /* When the block is FRAME-BASED with MAINTAIN FRAME SIZE chosen as     */
        /* the framing mode while in a SINGLETASKING OR MULTITASKING mode such  */
        /* that the block is also MULTIRATE (i.e. input port faster than output */
        /* if the decimation factor is greater than one) then there will be     */
        /* INHERENT LATENCY due to causality (the fact that NOT enough samples  */
        /* will be available on the first sample hit to fill an entire frame).  */
        /*                                                                      */
        /* By setting this flag to false, a single output-width delay is        */
        /* always inserted in this mode for consistent (causal!!!) behavior.    */
        *inBuff1 =  false;
    }

    /* Start with the last phase so that output agrees with MATLAB's upfirdn */
    *phasePtr = dFactor - 1;

    /* xxx !!! EXPLAIN WHERE THE HELL THESE NUMBERS COME FROM !!!  xxx */
    ssSetPWorkValue(S, CffRPtr, mxGetPr(FILT_ARG) + length - length/dFactor);
    ssSetPWorkValue(S, CffIPtr, mxGetPi(FILT_ARG) + length - length/dFactor);

    /* ********************************************************************** */
    /* Initialize output buffer with appropriate ICs. The output initial      */
    /* conditions are passed into the S-fcn and must be either length zero,   */
    /* one, or length equal to the output buffer size (ICs are used ONLY for  */
    /* output buffer latency in certain situations where outputs are required */
    /* by Simulink before enough input sample processing has occured).        */
    /*                                                                        */
    /* For the FIR filter, leave states set to zero until we decide that this */
    /* is a useful extra feature. It gets a little more difficult since the   */
    /* input could be real but the coeffs can be complex, making the FIR ICs  */
    /* not matching the input complexity...this is not worth the extra code   */
    /* at this point in time (wait until someone asks for this!).             */
    /* ********************************************************************** */

    if ( (numICs < 0) || ( (numICs > 1) && (numICs != outputBufLen) ) ) {
        THROW_ERROR(S, "Output initial conditions vector has incorrect dimensions.");
    }

    if ((!cplxInp) && (!filtComplex) && mxIsComplex(OUTBUF_INITCOND_ARG)) {
        THROW_ERROR(S, "Complex output initial conditions are not allowed with real outputs.");
    }

    if ( (!cplxInp) && (!filtComplex) ) {
        /* Real input signal and real filter -> real output buffer ICs */
        real_T *pIC    = mxGetPr(OUTBUF_INITCOND_ARG);
        real_T *outBuf = (real_T *) ssGetDWork( S, OutputBuffer);

        if (numICs <= 1) {
            /* Scalar expansion, or no IC's given: */
            uint_T i;
            real_T ic = (numICs == 0) ? (real_T)0.0 : *pIC;

            for(i = 0; i < outputBufLen; i++) {
                *outBuf++ = ic;
            }
        }
        
        else {
            /* Multiple ICs - NOTE length of ICs MUST equal buffer length. */
            memcpy(outBuf, pIC, outputBufLen * sizeof(real_T));
        }
    }

    else {
        /* Complex input signal or complex filter -> complex output buff ICs */
        real_T          *prIC    = mxGetPr(OUTBUF_INITCOND_ARG);
        real_T          *piIC    = mxGetPi(OUTBUF_INITCOND_ARG);
        const boolean_T  ic_cplx = (boolean_T)(piIC != NULL);
        creal_T         *outBuf  = (creal_T *) ssGetDWork(S, OutputBuffer);

        if (numICs <= 1) {
            /* Scalar expansion, or no IC's given: */
            creal_T ic;
            uint_T  i;

            /* Special case for empty ICs */
            if (numICs == 0) {
                ic.re = 0.0;
                ic.im = 0.0;
            }

            else {
                ic.re = *prIC;
                ic.im = (ic_cplx) ? *piIC : 0.0;
            }

            for(i = 0; i < outputBufLen; i++) {
                *outBuf++ = ic;
            }
        }

        else {
            /* Multiple ICs */
            uint_T i;

            if (ic_cplx) {
                for(i = 0; i < outputBufLen; i++) {
                    outBuf->re     = *prIC++;
                    (outBuf++)->im = *piIC++;
                }
    	     }
            
            else {
                for(i = 0; i < outputBufLen; i++) {
                    outBuf->re     = *prIC++;
                    (outBuf++)->im = 0.0;
                }
            }
        }
    }
}


static void mdlOutputs(SimStruct *S, int_T tid)
{
    const int_T      inPortWidth  = ssGetInputPortWidth(S, INPORT);
    const int_T      outPortWidth = ssGetOutputPortWidth(S, OUTPORT);
    const int_T      order        = mxGetNumberOfElements(FILT_ARG) - 1;
    const boolean_T  filtComplex  = mxIsComplex(FILT_ARG);
    int_T            numChans     = (int_T) *mxGetPr(NCHANS_ARG);
    const int_T      dFactor      = (int_T) *mxGetPr(DFACTOR_ARG);
    const boolean_T  inComplex    = (ssGetInputPortComplexSignal(S, INPORT) == true);
    int_T           *phaseIdx     = (int_T *) ssGetDWork(S, PhaseIdx);
    int_T           *tapIdx       = (int_T *) ssGetDWork(S, TapDelayIndex);
    int_T           *outIdx       = (int_T *) ssGetDWork(S, OutIdx);
    boolean_T       *inBuff1      = (boolean_T *) ssGetDWork(S, InBuff1);
    real_T          *cffRPtr      = (real_T *) ssGetPWorkValue(S, CffRPtr);
    real_T          *cffIPtr      = (real_T *) ssGetPWorkValue(S, CffIPtr);
    const int_T      inportTid    = ssGetInputPortSampleTimeIndex(S, INPORT);
    const int_T      outportTid   = ssGetOutputPortSampleTimeIndex(S, OUTPORT);
    boolean_T       *outBuff1     = (boolean_T *) ssGetDWork(S, OutBuff1);
    boolean_T        iBuff1;
    int_T            i, k, frame, curPhaseIdx, curTapIdx, curOutBufIdx, oframe;


    /* ********************************* */
    /* INPUT POLYPHASE FIR FILTER UPDATE */
    /* ********************************* */

    /* Perform input computations only if new input sample is available.  */
    /* Skip this code section if this is NOT an input sample time hit.    */
    /* This can ONLY happen in certain instances when in the Simulink     */
    /* Multi-rate AND Multi-tasking simulation mode. Otherwise there is   */
    /* ALWAYS and input sample hit available when mdlOutputs() is called. */
    if ( isModelMultiTasking(S) && isBlockMultiRate(S,INPORT,OUTPORT)
                                && (!ssIsSampleHit(S, inportTid, tid)) )
    {
        goto OUTPUT_PORT_SAMPLE_PROCESSING; /* SKIP INPUT CALCULATION SECTION */
    }

    if (numChans == CHANNEL_BASED) {
        numChans = inPortWidth;
        frame = 1;
    }
    else {
        frame = inPortWidth / numChans;
    }

    oframe = outPortWidth / numChans;


    /* The algorithm is fully documented for
     * the real+real case. The other three
     * cases use the same algorithm.
     */
    if (inComplex) { /* Complex Data */
        InputPtrsType  uptr   = ssGetInputPortSignalPtrs(S, INPORT);
        creal_T       *tap0   = (creal_T *) ssGetDWork(S, TapDelayLineBuff);
        creal_T       *sums   = (creal_T *) ssGetDWork(S, PartialSums);
        creal_T       *y0     = (creal_T *) ssGetDWork(S, OutputBuffer);

        if (filtComplex) {
            /* Complex data, complex filter */
            real_T *cffr, *cffi;

            for (k=0; k < numChans; k++) {
                iBuff1       = *inBuff1;
                curPhaseIdx  = *phaseIdx;
                curTapIdx    = *tapIdx;
                cffr         =  cffRPtr;
                cffi         =  cffIPtr;
                curOutBufIdx = *outIdx;

                for (i=0; i < frame; i++) {
                    creal_T	*u	= (creal_T *) *uptr++;
                    creal_T	*start	= tap0 + curTapIdx + 1;
                    creal_T	*mem	= start;
                    real_T	rsum	= sums->re;
                    real_T	isum	= sums->im;
                    rsum += (u->re) * (*cffr)   - (u->im) * (*cffi);
                    isum += (u->im) * (*cffr++) + (u->re) * (*cffi++);

                    while ((mem-=dFactor) >= tap0) {
                        rsum += (mem->re) * (*cffr)   - (mem->im) * (*cffi);
                        isum += (mem->im) * (*cffr++) + (mem->re) * (*cffi++);
                    }

                    mem += (order + dFactor);

                    while ((mem-=dFactor) >= start) {
                        rsum += (mem->re) * (*cffr)   - (mem->im) * (*cffi);
                        isum += (mem->im) * (*cffr++) + (mem->re) * (*cffi++);
                    }

                    sums->re = rsum;
                    sums->im = isum;

                    if ( (++curPhaseIdx) >= dFactor ) {
                        creal_T *y = y0 + curOutBufIdx;

                        if (iBuff1) y += outPortWidth;

                        *y++ = *sums;
                        sums->re = sums->im = 0.0;

                        if ( (++curOutBufIdx) == oframe ) {
                            curOutBufIdx = 0;
                            iBuff1       = !iBuff1;
                        }

                        curPhaseIdx = 0;
                        cffr        = mxGetPr(FILT_ARG);
                        cffi        = mxGetPi(FILT_ARG);
                    }

                    if ( (++curTapIdx) >= order ) curTapIdx = 0;

                    *(tap0 + curTapIdx) = *u;
                } /* frame */

                ++sums;
                tap0 += order;
                y0 += oframe;
            } /* channel */

            cffRPtr = cffr;
            cffIPtr = cffi;
        }
        
        else {
            /* Complex data, real filter */
            real_T *cff;

            for (k=0; k < numChans; k++) {
                iBuff1       = *inBuff1;
                curPhaseIdx  = *phaseIdx;
                curTapIdx    = *tapIdx;
                cff          =  cffRPtr;
                curOutBufIdx = *outIdx;
            
                for (i=0; i < frame; i++) {
                    creal_T	*u		= (creal_T *) *uptr++;
                    creal_T	*start	= tap0 + curTapIdx + 1;
                    creal_T	*mem	= start;
                    real_T	rsum	= sums->re;
                    real_T	isum	= sums->im;

                    rsum += (u->re) * (*cff);
                    isum += (u->im) * (*cff++);
                
                    while ((mem-=dFactor) >= tap0) {
                        rsum += (mem->re) * (*cff);
                        isum += (mem->im) * (*cff++);
                    }
                    
                    mem += (order + dFactor);
                    
                    while ((mem-=dFactor) >= start) {
                        rsum += (mem->re) * (*cff);
                        isum += (mem->im) * (*cff++);
                    }
                    
                    sums->re = rsum;
                    sums->im = isum;
                    
                    if ( (++curPhaseIdx) >= dFactor ) {
                        creal_T *y = y0 + curOutBufIdx;
                    
                        if (iBuff1) y += outPortWidth;
                        
                        *y++ = *sums;
                        sums->re = sums->im = 0.0;
                        
                        if ( (++curOutBufIdx) >= oframe ) {
                            curOutBufIdx = 0;
                            iBuff1       = !iBuff1;
                        }
                        
                        curPhaseIdx = 0;
                        cff         = mxGetPr(FILT_ARG);
                    }
                    
                    if ( (++curTapIdx) >= order ) curTapIdx = 0;
                    
                    *(tap0 + curTapIdx) = *u;
                } /* frame */
                
                ++sums;
                tap0 += order;
                y0 += oframe;
            } /* channel */
            cffRPtr = cff;
        } /* Real Filter */

    }

    else { /* Real Data */
        InputRealPtrsType uptr = ssGetInputPortRealSignalPtrs(S, INPORT);

        if (filtComplex) {
            /* Real data, complex filter */
            real_T  *tap0   = (real_T *)  ssGetDWork(S, TapDelayLineBuff);
            creal_T *sums   = (creal_T *) ssGetDWork(S, PartialSums);
            creal_T *y0     = (creal_T *) ssGetDWork(S, OutputBuffer);
            real_T  *cffr, *cffi;

            for (k=0; k < numChans; k++) {
                iBuff1       = *inBuff1;
                curPhaseIdx  = *phaseIdx;
                curTapIdx    = *tapIdx;
                cffr         =  cffRPtr;
                cffi         =  cffIPtr;
                curOutBufIdx = *outIdx;
            
                for (i=0; i < frame; i++) {
                    real_T  in      = **uptr++;
                    real_T  *start  = tap0 + curTapIdx + 1;
                    real_T  *mem    = start;
                    /* The temporary variables rsum and isum are needed due to
                     * a bug in the Visual C compiler level 2 optimization */
                    real_T  rsum    = sums->re;
                    real_T  isum    = sums->im;
                    
                    rsum += in * (*cffr++);
                    isum += in * (*cffi++);
                
                    while ((mem-=dFactor) >= tap0) {
                        rsum += (*mem) * (*cffr++);
                        isum += (*mem) * (*cffi++);
                    }
                    
                    mem += (order + dFactor);
                    
                    while ((mem-=dFactor) >= start) {
                        rsum += (*mem) * (*cffr++);
                        isum += (*mem) * (*cffi++);
                    }
                    
                    sums->re = rsum;
                    sums->im = isum;
                    
                    if ( (++curPhaseIdx) >= dFactor ) {
                        creal_T *y = y0 + curOutBufIdx;
                    
                        if (iBuff1) y += outPortWidth;
                        
                        *y++ = *sums;
                        sums->re = sums->im = 0.0;
                        
                        if ( (++curOutBufIdx) >= oframe ) {
                            curOutBufIdx = 0;
                            iBuff1       = !iBuff1;
                        }
                        
                        curPhaseIdx = 0;
                        cffr        = mxGetPr(FILT_ARG);
                        cffi        = mxGetPi(FILT_ARG);
                    }

                    if ( (++curTapIdx) == order ) curTapIdx = 0;
                    
                    *(tap0 + curTapIdx) = in;
                } /* frame */

                ++sums;
                tap0 += order;
                y0 += oframe;
            } /* channel */

            cffRPtr = cffr;
            cffIPtr = cffi;
        }

        else {
            /* Real data, real filter */
            real_T  *tap0   = (real_T *) ssGetDWork(S, TapDelayLineBuff);
            real_T  *sums   = (real_T *) ssGetDWork(S, PartialSums);
            real_T  *y0     = (real_T *) ssGetDWork(S, OutputBuffer);
            real_T  *cff;

            for (k=0; k < numChans; k++) {
                iBuff1 = *inBuff1;
                /* Each channel uses the same filter phase but accesses
                 * its own state memory and input.
                 */
                curPhaseIdx  = *phaseIdx;
                curTapIdx    = *tapIdx;
                cff          =  cffRPtr;
                curOutBufIdx = *outIdx;

                for (i=0; i < frame; i++) {
                    real_T	in	= **uptr++;
                    /* The pointer to state memory is set dFactor samples past the
                     * desired location.  This is because the memory pointer is
                     * pre-decremented in the convolution loops.
                     */
                    real_T	*start	= tap0 + curTapIdx + 1;
                    real_T	*mem	= start; 
                
                    *sums += in * (*cff++);
                    
                    /* Perform the convolution for this phase (on every dFactor samples)
                     * until we reach the start of the (linear) state memory */
                    while ((mem-=dFactor) >= tap0) {
                        *sums += (*mem) * (*cff++);
                    }
                    
                    /* wrap the state memory pointer to the next element */
                    mem += (order + dFactor);
                    
                    /* Finish the convolution for this phase */
                    while ((mem-=dFactor) >= start) {
                        *sums += (*mem) * (*cff++);
                    }
                    
                    /* Update the counters modulo their buffer size */
                    if ( (++curPhaseIdx) >= dFactor ) {
                        real_T *y = y0 + curOutBufIdx;
                    
                        if (iBuff1) y += outPortWidth;
                        
                        *y++ = *sums;
                        *sums = 0.0;
                        
                        if ( (++curOutBufIdx) >= oframe ) {
                            curOutBufIdx = 0;
                            iBuff1       = !iBuff1;
                        }
                        
                        curPhaseIdx = 0;
                        cff         = mxGetPr(FILT_ARG);
                    }

                    /* Save the current input value */
                    if ( (++curTapIdx) >= order ) curTapIdx = 0;

                    *(tap0 + curTapIdx) = in;
                } /* frame */

                ++sums;
                tap0 += order;
                y0 += oframe;
            } /* channel */
            
            cffRPtr = cff;

        } /* Real Filter */
    } /* Real Data */

    /* Update stored indices for next time */
    *phaseIdx = curPhaseIdx;
    *tapIdx   = curTapIdx;
    ssSetPWorkValue(S, CffRPtr, cffRPtr);
    ssSetPWorkValue(S, CffIPtr, cffIPtr);

    if (curOutBufIdx == oframe) curOutBufIdx = 0;
    
    *outIdx  = curOutBufIdx;
    *inBuff1 = iBuff1;


OUTPUT_PORT_SAMPLE_PROCESSING:

    /* ******************************************************************** */
    /* Only provide the next output sample if this is an output sample hit. */
    /* Skip this code if this is NOT an output sample hit.                  */
    /* ******************************************************************** */
    if (ssIsSampleHit(S, outportTid, tid)) {
        if (inComplex || filtComplex) {
            creal_T *yout = (creal_T *) ssGetOutputPortSignal(S, OUTPORT);
            creal_T *y    = (creal_T *) ssGetDWork(S, OutputBuffer);

            if (*outBuff1)
                y += outPortWidth;
            
            for (i=0; i < outPortWidth; i++)
                *yout++ = *y++;
        }        

        else {
            real_T  *yout = ssGetOutputPortRealSignal(S, OUTPORT);
            real_T  *y    = (real_T *) ssGetDWork(S, OutputBuffer);
        
            if (*outBuff1)
                y += outPortWidth;
            
            for (i=0; i < outPortWidth; i++)
                *yout++ = *y++;
        }

        *outBuff1 = !(*outBuff1);
    }
}


static void mdlTerminate(SimStruct *S)
{
}


#if defined(MATLAB_MEX_FILE) 
#define MDL_SET_INPUT_PORT_SAMPLE_TIME 
static void mdlSetInputPortSampleTime(SimStruct *S, 
                                      int_T     portIdx, 
                                      real_T    sampleTime, 
                                      real_T    offsetTime) 
{ 
    if (sampleTime == CONTINUOUS_SAMPLE_TIME) {
        THROW_ERROR(S, "Continuous sample times not allowed for decimation filter.");
    }

    if (offsetTime != 0.0) { 
        THROW_ERROR(S, "Non-zero sample time offsets not allowed."); 
    } 

    ssSetInputPortSampleTime(S, INPORT, sampleTime); 
    ssSetInputPortOffsetTime(S, INPORT, 0.0); 
 
    if (ssGetOutputPortSampleTime(S, OUTPORT) == INHERITED_SAMPLE_TIME) {
        const int_T	dFactor	= (int_T) mxGetPr(DFACTOR_ARG)[0];
        const int_T	framing	= (int_T) mxGetPr(FRAMING_ARG)[0];

        if (framing == CONST_RATE_FRAMING) {
            ssSetOutputPortSampleTime(S, OUTPORT, sampleTime);
        }
        else {
            ssSetOutputPortSampleTime(S, OUTPORT, sampleTime * dFactor);
        }
        
        ssSetOutputPortOffsetTime(S, OUTPORT, 0.0); 
    }
}


#define MDL_SET_OUTPUT_PORT_SAMPLE_TIME 
static void mdlSetOutputPortSampleTime(SimStruct *S, 
                                      int_T     portIdx, 
                                      real_T    sampleTime, 
                                      real_T    offsetTime) 
{ 
    if (sampleTime == CONTINUOUS_SAMPLE_TIME) {
        THROW_ERROR(S, "Continuous sample times not allowed for decimation filter.");
    }

    if (offsetTime != 0.0) { 
        THROW_ERROR(S, "Non-zero sample time offsets not allowed."); 
    } 
    
    ssSetOutputPortSampleTime(S, OUTPORT, sampleTime); 
    ssSetOutputPortOffsetTime(S, OUTPORT, 0.0); 

    if (ssGetInputPortSampleTime(S, INPORT) == INHERITED_SAMPLE_TIME) {
        const int_T	dFactor	= (int_T) *mxGetPr(DFACTOR_ARG);
        const int_T	framing	= (int_T) *mxGetPr(FRAMING_ARG); 

        if (framing == CONST_RATE_FRAMING) {
            ssSetInputPortSampleTime(S, INPORT, sampleTime);
        }
        else {
            ssSetInputPortSampleTime(S, INPORT, sampleTime / dFactor);
        } 

        ssSetInputPortOffsetTime(S, INPORT, 0.0); 
    }
} 
#endif 


#ifdef MATLAB_MEX_FILE
#define MDL_SET_INPUT_PORT_WIDTH
static void mdlSetInputPortWidth(SimStruct *S, int_T port, int_T inputPortWidth)
{
    const int_T	dFactor         = (int_T) *mxGetPr(DFACTOR_ARG);
    const int_T	numChans        = (int_T) *mxGetPr(NCHANS_ARG);
    const int_T	outputPortWidth = ssGetOutputPortWidth(S, port);
          int_T framing         = (int_T) *mxGetPr(FRAMING_ARG);

    if (numChans == CHANNEL_BASED) framing = CONST_SIZE_FRAMING;

    ssSetInputPortWidth (S, port, inputPortWidth);

    if (framing == CONST_RATE_FRAMING) {
        if (outputPortWidth == DYNAMICALLY_SIZED && (inputPortWidth % dFactor) == 0) {
            ssSetOutputPortWidth(S, port, inputPortWidth / dFactor);
        }
        else if (outputPortWidth != inputPortWidth / dFactor) {
            THROW_ERROR (S, "(Input port width)/(Output port width) "
                "must equal the decimation factor.");
        }
    }
    else {
        if (outputPortWidth == DYNAMICALLY_SIZED) {
            ssSetOutputPortWidth(S, port, inputPortWidth);
        }
        else if (outputPortWidth != inputPortWidth) {
            THROW_ERROR (S, "Input port width must equal output port width.");
        }
    }
}


#define MDL_SET_OUTPUT_PORT_WIDTH
static void mdlSetOutputPortWidth(SimStruct *S, int_T port, int_T outputPortWidth)
{
    const int_T	dFactor        = (int_T) *mxGetPr(DFACTOR_ARG);
    const int_T	numChans       = (int_T) *mxGetPr(NCHANS_ARG);
    const int_T inputPortWidth = ssGetInputPortWidth(S, port);
          int_T framing        = (int_T) *mxGetPr(FRAMING_ARG);

    if (numChans == CHANNEL_BASED) framing = CONST_SIZE_FRAMING;

    ssSetOutputPortWidth (S, port, outputPortWidth);

    if (framing == CONST_RATE_FRAMING) {
        if (inputPortWidth == DYNAMICALLY_SIZED) {
            ssSetInputPortWidth(S, port, outputPortWidth*dFactor);
        }
        else if (inputPortWidth != outputPortWidth*dFactor) {
            THROW_ERROR (S, "(Input port width)/(Output port width) "
                "must equal the decimation factor");
        }
    }
    else {
        if (inputPortWidth == DYNAMICALLY_SIZED) {
            ssSetInputPortWidth(S, port, outputPortWidth);
        }
        else if (inputPortWidth != outputPortWidth*dFactor) {
            THROW_ERROR (S, "Input port width must equal output port width");
        }
    }
}


#define MDL_SET_INPUT_PORT_COMPLEX_SIGNAL
static void mdlSetInputPortComplexSignal(SimStruct *S, int_T portIdx,
                                         CSignal_T      iPortComplexSignal)
{
    ssSetInputPortComplexSignal(S, portIdx, iPortComplexSignal);

    if (ssGetOutputPortComplexSignal(S, OUTPORT) == COMPLEX_INHERITED) {
        ssSetOutputPortComplexSignal(S, OUTPORT, (mxIsComplex(FILT_ARG)) ? COMPLEX_YES : iPortComplexSignal);
    }
}


#define MDL_SET_OUTPUT_PORT_COMPLEX_SIGNAL
static void mdlSetOutputPortComplexSignal(SimStruct *S, int_T portIdx,
                                          CSignal_T      oPortComplexSignal)
{
    ssSetOutputPortComplexSignal(S, portIdx, oPortComplexSignal);		
}
#endif


#ifdef MATLAB_MEX_FILE
#define MDL_SET_WORK_WIDTHS
static void mdlSetWorkWidths(SimStruct *S)
{
    const int_T     inPortWidth  = ssGetInputPortWidth( S, INPORT);
    const int_T     outPortWidth = ssGetOutputPortWidth(S, OUTPORT);
    const int_T     outputBufLen = 2*outPortWidth; /* Output port is double-buffered */
    const int_T     order        = mxGetNumberOfElements(FILT_ARG) - 1;
    const int_T     numICs       = mxGetNumberOfElements(OUTBUF_INITCOND_ARG);
    const boolean_T inputComplex = (ssGetInputPortComplexSignal(S, INPORT) == COMPLEX_YES);
    const boolean_T filtComplex  = mxIsComplex(FILT_ARG);
          int_T     numChans     = (int_T) *mxGetPr(NCHANS_ARG);

    if (numChans == CHANNEL_BASED) numChans = inPortWidth;

    /* Check ICs */
    if ( (numICs != 0) && (numICs != 1) && (numICs != outputBufLen) ) {
        /* Initial conditions must be either length zero, one, or */
        /* equal to the length of the output buffer. Otherwise we */
        /* cannot understand how to fill the output buffer!!!     */
        THROW_ERROR(S,"Invalid number of output buffer initial conditions.");
    }

    if(!ssSetNumDWork( S, NUM_DWORKS)) return;

    /* Output Buffer */
    ssSetDWorkWidth(        S,   OutputBuffer, outputBufLen);
    ssSetDWorkDataType(     S,   OutputBuffer, SS_DOUBLE);
    ssSetDWorkComplexSignal(S,   OutputBuffer, (inputComplex || filtComplex) ? COMPLEX_YES : COMPLEX_NO);
    ssSetDWorkName(         S,   OutputBuffer, "OutBuff");

    /* Phase Index */
    ssSetDWorkWidth(   S,   PhaseIdx, 1);
    ssSetDWorkDataType(S,   PhaseIdx, SS_INT32);
    ssSetDWorkName(    S,   PhaseIdx, "PhaseIdx");

    /* Memory Index (accumulated FIR sum) */
    ssSetDWorkWidth(   S,   TapDelayIndex, 1);
    ssSetDWorkDataType(S,   TapDelayIndex, SS_INT32);
    ssSetDWorkName(    S,   TapDelayIndex, "TapDelayIndex");

    /* Output Index */
    ssSetDWorkWidth(   S, OutIdx, 1);
    ssSetDWorkDataType(S, OutIdx, SS_INT32);
    ssSetDWorkName(    S, OutIdx, "OutIdx");

    /* Partial Sums */
    ssSetDWorkWidth(        S, PartialSums, numChans);
    ssSetDWorkDataType(     S, PartialSums, SS_DOUBLE);
    ssSetDWorkComplexSignal(S, PartialSums, (inputComplex || filtComplex) ? COMPLEX_YES : COMPLEX_NO);
    ssSetDWorkName(         S, PartialSums, "Sums");

    /* Input buffer toggle */
    ssSetDWorkWidth(   S, InBuff1, 1);
    ssSetDWorkDataType(S, InBuff1, SS_BOOLEAN);
    ssSetDWorkName(    S, InBuff1, "InBuff1");

    /* Output buffer toggle */
    ssSetDWorkWidth(   S, OutBuff1, 1);
    ssSetDWorkDataType(S, OutBuff1, SS_BOOLEAN);
    ssSetDWorkName(    S, OutBuff1, "OutBuff1");

    /* Discrete State (FIR filter) */
    ssSetDWorkWidth(        S, TapDelayLineBuff, numChans*order); /* numChans > 0 , order > 0 */
    ssSetDWorkDataType(     S, TapDelayLineBuff, SS_DOUBLE);
    ssSetDWorkComplexSignal(S, TapDelayLineBuff, (inputComplex) ? COMPLEX_YES : COMPLEX_NO);
    ssSetDWorkName(         S, TapDelayLineBuff, "TapDelayBuff");
    ssSetDWorkUsedAsDState( S, TapDelayLineBuff, 1);
}
#endif



#define MDL_RTW
#if defined(MATLAB_MEX_FILE) || defined(NRT)
static void mdlRTW(SimStruct *S)
{
    const int32_T defactor = (int32_T)mxGetPr(DFACTOR_ARG)[0];
    const int32_T numChans = (int32_T)mxGetPr(NCHANS_ARG)[0];
    const int32_T framing  = (int32_T)mxGetPr(FRAMING_ARG)[0];
    const int32_T icRows   = (int32_T)mxGetM(OUTBUF_INITCOND_ARG);
    const int32_T icCols   = (int32_T)mxGetN(OUTBUF_INITCOND_ARG);
    const real_T  zero     = 0;
    const real_T  *IC_re   = &zero;
    const real_T  *IC_im   = NULL;
    int_T          numIC   = 1; 


    if(!mxIsEmpty(OUTBUF_INITCOND_ARG)) {
        numIC = mxGetNumberOfElements(OUTBUF_INITCOND_ARG);
        IC_re = (const real_T *)mxGetPr(OUTBUF_INITCOND_ARG);
        IC_im = (const real_T *)mxGetPi(OUTBUF_INITCOND_ARG);
    }


    if (!ssWriteRTWParamSettings(S, 7,

                                 SSWRITE_VALUE_DTYPE_ML_VECT, "IC",
                                 IC_re, IC_im, numIC,
                                 DTINFO(SS_DOUBLE, mxIsComplex(OUTBUF_INITCOND_ARG)),

                                 SSWRITE_VALUE_DTYPE_NUM,     "IC_ROWS",
                                 &icRows,
                                 DTINFO(SS_INT32,0),

                                 SSWRITE_VALUE_DTYPE_NUM,     "IC_COLS",
                                 &icCols,
                                 DTINFO(SS_INT32,0),

                                 SSWRITE_VALUE_DTYPE_ML_VECT, "FILTER", 
                                 mxGetPr(FILT_ARG), mxGetPi(FILT_ARG), 
                                 mxGetNumberOfElements(FILT_ARG), 
                                 DTINFO(SS_DOUBLE, mxIsComplex(FILT_ARG)),

                                 SSWRITE_VALUE_DTYPE_NUM,     "DFACTOR",
                                 &defactor,
                                 DTINFO(SS_INT32,0),

                                 SSWRITE_VALUE_DTYPE_NUM,     "NUM_CHANS",  
                                 &numChans,
                                 DTINFO(SS_INT32,0),

                                 SSWRITE_VALUE_DTYPE_NUM,     "FRAMING",
                                 &framing,
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
