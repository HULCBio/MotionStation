/*
 * SDSPUPFIR A SIMULINK interpolating FIR filter block.
 *        DSP Blockset S-Function for the efficient multirate
 *        implementation of a FIR interpolation filter.
 *
 *  Note that the filter coefficient vector MUST be re-ordered into phase
 *  order and may also require zero-padding before calling this function.
 *  The block's helper function dspblkupfir.m performs these tasks.
 *
 *   
 *  Copyright 1995-2002 The MathWorks, Inc.
 *  $Revision: 1.28 $  $Date: 2002/04/14 20:42:15 $
 */

#define S_FUNCTION_LEVEL 2
#define S_FUNCTION_NAME sdspupfir

#include "dsp_sim.h"

/*
 * Defines for easy access of the input parameters
 */
enum {
    ARGC_FILT = 0,
    ARGC_IFACTOR,
    ARGC_NUMCHANS,
    ARGC_FRAMING,
    ARGC_INIT_COND_OUTBUF,
    NUM_ARGS
};

#define FILT_ARG            ssGetSFcnParam( S, ARGC_FILT             )
#define IFACTOR_ARG         ssGetSFcnParam( S, ARGC_IFACTOR          )
#define NCHANS_ARG          ssGetSFcnParam( S, ARGC_NUMCHANS         )
#define FRAMING_ARG         ssGetSFcnParam( S, ARGC_FRAMING          )
#define OUTBUF_INITCOND_ARG ssGetSFcnParam( S, ARGC_INIT_COND_OUTBUF )

/* For frame-based processing, you can select either:
 * 1) the output frame rate equal to the input frame rate (output frame size is larger).
 * 2) the output frame size equal to the input frame size (output frame rate is faster).
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
    TapDelayIndex = 0, /* Index into the input tap-delay line buffer         */
    OutputBuff,        /* Interpolated and filtered output sample buffer     */
    WriteIdx,          /* Index to write to in the output sample buffer      */
    ReadIdx,           /* Index to read from in the output sample buffer     */
    TapDelayLineBuff,  /* Raw input sample (Direct-Form II) tap delay buffer */
    NUM_DWORKS
};

/* PWork indices (used by RTW) */
enum {CffPtr = 0, NUM_PWORKS};


#ifdef MATLAB_MEX_FILE
#define MDL_CHECK_PARAMETERS
static void mdlCheckParameters(SimStruct *S) {
    const int_T     numIFArg    = mxGetNumberOfElements(IFACTOR_ARG);
    const int_T     numFiltArg  = mxGetNumberOfElements(FILT_ARG);
    const boolean_T runTime     = (ssGetSimMode(S) != SS_SIMMODE_SIZES_CALL_ONLY);

    /* Interpolation factor */
    if (OK_TO_CHECK_VAR(S, IFACTOR_ARG)) {
        if (!IS_FLINT_GE(IFACTOR_ARG, 1)) {
            THROW_ERROR(S, "Decimation factor must be a real, scalar integer > 0.");
        }
    }

    /* Check filter: */
    if (runTime || (numFiltArg >= 1 && numIFArg == 1)) {
        if ( mxIsEmpty(FILT_ARG) || ( mxGetN(FILT_ARG) != (*mxGetPr(IFACTOR_ARG)) ) ) {
            THROW_ERROR(S, "Interpolation filter must be a polyphase matrix with the number of "
	                 "columns equal to the interpolation factor.");
        }	

        if ( numFiltArg <= ( (int_T) *mxGetPr(IFACTOR_ARG) ) ) {
            THROW_ERROR(S, "For proper interpolation, the number of filter coefficients "
                         "should be greater than the interpolation factor. "
                         "(The interpolation order is (filter length)/(interpolation factor) - 1).");
        }
    }

    /* Number of channels - only check if frame-based: */
    if (OK_TO_CHECK_VAR(S, NCHANS_ARG)) { 
        if ( !IS_FLINT_GE(NCHANS_ARG, 1) && ((!IS_FLINT(NCHANS_ARG)) || ( (*mxGetPr(NCHANS_ARG)) != -1 ) ) ) {
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
    ssSetSFcnParamNotTunable(S, ARGC_IFACTOR);
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

    if(!ssSetNumDWork(S, DYNAMICALLY_SIZED)) return;
    ssSetNumPWork(    S, NUM_PWORKS);
    ssSetOptions(     S, SS_OPTION_EXCEPTION_FREE_CODE);
}


#define MDL_START
static void mdlStart (SimStruct *S)
{
#ifdef MATLAB_MEX_FILE
    boolean_T   complex     = mxIsComplex(FILT_ARG) ||
                                  (ssGetInputPortComplexSignal(S, INPORT) == COMPLEX_YES);
    const int_T portWidth   = ssGetInputPortWidth(S, INPORT);
    const int_T iFactor     = (int_T) *mxGetPr(IFACTOR_ARG);
    int_T       numChans    = (int_T) *mxGetPr(NCHANS_ARG);

    if (numChans == CHANNEL_BASED) {
        numChans = portWidth;
    }

    /* Check the input port width */
    if ( (( (int_T) *mxGetPr(NCHANS_ARG) ) != CHANNEL_BASED) && (ssGetInputPortWidth(S, INPORT) % numChans)) {
        THROW_ERROR(S, "The port width must be a multiple of the number of channels.");
    }

    /* Check that the output port's complexity is correct. */
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
        THROW_ERROR(S, "Sample time propagation failed for interpolation filter.");
    } 
    if ((Tsi == CONTINUOUS_SAMPLE_TIME) || 
        (Tso == CONTINUOUS_SAMPLE_TIME)  ) { 
        THROW_ERROR(S, "Continuous sample times not allowed for interpolation blocks.");
    }
}


#define MDL_INITIALIZE_CONDITIONS
static void mdlInitializeConditions(SimStruct *S)
{
    const int_T     inportWidth    = ssGetInputPortWidth(S, INPORT);
    const int_T     outportWidth   = ssGetOutputPortWidth(S, OUTPORT);
    const int_T     iFactor        = (int_T) *mxGetPr(IFACTOR_ARG);
    const int_T     numICs         = mxGetNumberOfElements(OUTBUF_INITCOND_ARG);
    const boolean_T cplxInp        = (boolean_T)(ssGetInputPortComplexSignal(S, INPORT) == COMPLEX_YES);
    const boolean_T filtComplex    = mxIsComplex(FILT_ARG);
    const boolean_T isMultiRateBlk = isBlockMultiRate(S,INPORT,OUTPORT);
    const boolean_T isMultiTasking = isModelMultiTasking(S);
    const uint_T    outBufWidth    = ssGetDWorkWidth(S, OutputBuff);

    int_T *tapIdx   = (int_T *) ssGetDWork(S, TapDelayIndex);
    int_T *rdIdx    = (int_T *) ssGetDWork(S, ReadIdx);
    int_T *wrIdx    = (int_T *) ssGetDWork(S, WriteIdx);
    int_T  numChans = (int_T)  *mxGetPr(NCHANS_ARG);

    /* **************************************** */
    /* Initialize indices into internal buffers */
    /* **************************************** */

    *wrIdx  = 0;
    *tapIdx = 0;

    if ( !(isMultiRateBlk && isMultiTasking) ) {
        /*
         * SingleRate && SingleTasking
         * SingleRate && MultiTasking
         * MultiRate  && SingleTasking
         *
         * We will only output one frame of IC's at startup in MULTI-RATE, MULTI-TASKING
         * mode. In all other modes, this block has a guaranteed full set of inputs at
         * the initial sample time, so there is NO need for any additional latency.
         *
         * NO latency is necessary since inputs are guaranteed to be there
         * at the first sample time -> initialize all indices to zero. and
         * just skip filling in any ICs in the output buffer since not used.
         */
        *rdIdx  = 0;
    }
    else  {
        /*
         * MultiRate && MultiTasking
         * 
         * When latency IS necessary (i.e. only in multi-rate, multi-tasking mode):
         *
         *     Initial output sample number = (2 * "phases"), due to double buffer
         */
        if (numChans == CHANNEL_BASED) {
            numChans = inportWidth;
        }

        /* xxx EXPLAIN WHERE THE HELL THIS NUMBER COMES FROM xxx */
        *rdIdx  = ( (2*iFactor*inportWidth) - (outportWidth) ) / numChans;

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

        if ( (numICs < 0) || ( (numICs > 1) && (numICs != outBufWidth) ) ) {
            THROW_ERROR(S, "Output initial conditions vector has incorrect dimensions.");
        }

        if ((!cplxInp) && (!filtComplex) && mxIsComplex(OUTBUF_INITCOND_ARG)) {
            THROW_ERROR(S, "Complex output initial conditions are not allowed with real outputs.");
        }

        if ( (!cplxInp) && (!filtComplex) ) {
            /* Real input signal and real filter -> real output buffer ICs */
            real_T *pIC    = mxGetPr(OUTBUF_INITCOND_ARG);
            real_T *outBuf = (real_T *) ssGetDWork( S, OutputBuff);
            
            if (numICs <= 1) {
                /* Scalar expansion, or no IC's given: */
                real_T ic = (numICs == 0) ? (real_T)0.0 : *pIC;
                uint_T i;
                
                for(i = 0; i < outBufWidth; i++) {
                    *outBuf++ = ic;
                }
            }            
            else {
                /* Multiple ICs - NOTE length of ICs MUST equal buffer length. */
                memcpy(outBuf, pIC, outBufWidth * sizeof(real_T));
            }
        }        
        else {
            /* Complex input signal or complex filter -> complex output buff ICs */
            real_T          *prIC    = mxGetPr(OUTBUF_INITCOND_ARG);
            real_T          *piIC    = mxGetPi(OUTBUF_INITCOND_ARG);
            const boolean_T  ic_cplx = (boolean_T)(piIC != NULL);
            creal_T         *outBuf  = (creal_T *) ssGetDWork(S, OutputBuff);
            
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
                
                for(i = 0; i < outBufWidth; i++) {
                    *outBuf++ = ic;
                }
            }
            else {
                /* Multiple ICs */
                uint_T i;
                
                if (ic_cplx) {
                    for(i = 0; i < outBufWidth; i++) {
                        outBuf->re     = *prIC++;
                        (outBuf++)->im = *piIC++;
                    }
                }
                else {
                    for(i = 0; i < outBufWidth; i++) {
                        outBuf->re     = *prIC++;
                        (outBuf++)->im = 0.0;
                    }
                }
            } /* Multiple ICs */
        } /* Complex ICs */
    } /* Multirate AND Multitasking */
}


static void mdlOutputs(SimStruct *S, int_T tid)
{
    const int_T inportTid  = ssGetInputPortSampleTimeIndex(S, INPORT);
    const int_T outportTid = ssGetOutputPortSampleTimeIndex(S, OUTPORT);

    /* ******************************************************************** */
    /* If new input sample is currently available, first perform upsampling */
    /* and update the polyphase (multirate) filter at the upsampled rate.   */
    /* ******************************************************************** */
    if (ssIsSampleHit(S, inportTid, tid)) {
        const int_T      portWidth   = ssGetInputPortWidth(S, INPORT);
        const int_T      length      = mxGetNumberOfElements(FILT_ARG);
        const int_T      iFactor     = (int_T) *mxGetPr(IFACTOR_ARG);
        const int_T      subOrder    = length / iFactor - 1; /* Compute the order of the subfilters */
        const boolean_T	 filtComplex = mxIsComplex(FILT_ARG);
        const boolean_T	 inComplex   = (ssGetInputPortComplexSignal(S, INPORT) == true);
        int_T            numChans    = (int_T) *mxGetPr(NCHANS_ARG);
        const int_T      frame       = (numChans == CHANNEL_BASED) ? 1 : portWidth/numChans;
        int_T            *tapIdx     = (int_T *) ssGetDWork(S, TapDelayIndex);
        int_T            *wrIdx      = (int_T *) ssGetDWork(S, WriteIdx);

        int_T curTapIdx, curPhaseIdx;

        if (numChans == CHANNEL_BASED) numChans = portWidth;

        /*
         * The algorithm is fully documented for the real+real case.
         * The other three cases use the same algorithm.
         */

        if (inComplex) {
            /* Complex Data */
            InputPtrsType  uptr = ssGetInputPortSignalPtrs(S, INPORT);
            creal_T       *tap0 = (creal_T *) ssGetDWork(S, TapDelayLineBuff);
            creal_T       *out  = (creal_T *) ssGetDWork(S, OutputBuff);
    
            if (filtComplex) { /* Complex data, complex filter */
                int_T k;

                for (k = 0; k < numChans; k++) {
                    int_T i;

                    curTapIdx   = *tapIdx;
                    curPhaseIdx =  0;
    
                    for (i = 0; i < frame; i++) {
                        int_T m;
                        real_T        *cffr = mxGetPr(FILT_ARG);
                        real_T        *cffi = mxGetPi(FILT_ARG);
                        const creal_T  u    = *((creal_T *)(*uptr++));

                        for (m = 0; m < iFactor; m++) {
                            int_T    j;
                            creal_T *mem = tap0 + curTapIdx;
                            creal_T  sum, coef;
    
                            coef.re = *cffr++;
                            coef.im = *cffi++;
    
                            sum.re = CMULT_RE(u, coef);
                            sum.im = CMULT_IM(u, coef);
    
                            for (j=0; j <= curTapIdx; j++) {
                                coef.re = *cffr++;
                                coef.im = *cffi++;

                                sum.re += CMULT_RE(*mem, coef);
                                sum.im += CMULT_IM(*mem, coef);
                                mem--;
                            }

                            mem += subOrder;

                            while(j++ < subOrder) {
                                coef.re = *cffr++;
                                coef.im = *cffi++;

                                sum.re += CMULT_RE(*mem, coef);
                                sum.im += CMULT_IM(*mem, coef);
                                mem--;
                            }

                            *(out + (*wrIdx)++) = sum;
                            ++curPhaseIdx;
                        }

                        if (curPhaseIdx >= iFactor) curPhaseIdx = 0;

                        if (curPhaseIdx == 0) {
                            if ( (++curTapIdx) >= subOrder ) curTapIdx = 0;

                            tap0[curTapIdx] = u;
                        }
                    } /* frame */

                    tap0 += subOrder;

                } /* channel */
            }
            else {
                /* Complex data, real filter */
                int_T k;

                for (k=0; k++ < numChans; ) {
                    int_T i;

                    curTapIdx   = *tapIdx;
                    curPhaseIdx =  0;

                    for (i = 0; i < frame; i++) {
                        const creal_T  u   = *((creal_T *)(*uptr++));
                        real_T        *cff = mxGetPr(FILT_ARG);
                        int_T          m;

                        for (m = 0; m < iFactor; m++) { 
                            int_T j;
                            creal_T *mem = tap0 + curTapIdx;
                            creal_T  sum;

                            sum.re = u.re * *cff;
                            sum.im = u.im * *cff++;

                            for (j=0; j <= curTapIdx; j++) {
                                sum.re += (  mem->re    ) * (*cff  );
                                sum.im += ( (mem--)->im ) * (*cff++);
                            }

                            mem += subOrder;

                            while(j++ < subOrder) {
                                sum.re += (  mem->re)     * (*cff  );
                                sum.im += ( (mem--)->im ) * (*cff++);
                            }

                            *(out + (*wrIdx)++) = sum;
                            ++curPhaseIdx;
                        }

                        if (curPhaseIdx >= iFactor) curPhaseIdx = 0;

                        if (curPhaseIdx == 0) {
                            if ( (++curTapIdx) >= subOrder ) curTapIdx = 0;

                            tap0[curTapIdx] = u;
                        }
                    } /* frame */

                    tap0 += subOrder;

                } /* channel */
            } /* Real Filter */
        }
        else {
            /* Real Data */
            InputRealPtrsType uptr = ssGetInputPortRealSignalPtrs(S, INPORT);
    
            if (filtComplex) { /* Real data, complex filter */
                int_T    k;
                real_T	*tap0 = ssGetDWork(S, TapDelayLineBuff);
                creal_T	*out  = (creal_T *) ssGetDWork(S, OutputBuff);

                for (k = 0; k < numChans; k++) {
                    int_T i;

                    curTapIdx   = *tapIdx;
                    curPhaseIdx =  0;

                    for (i = 0; i < frame; i++) {
                        const real_T u = **uptr++;
                        real_T *cffr = mxGetPr(FILT_ARG);
                        real_T *cffi = mxGetPi(FILT_ARG);
                        int_T   m;

                        for (m = 0; m < iFactor; m++) { 
                            int_T    j;
                            real_T  *mem = tap0 + curTapIdx;
                            creal_T  sum;

                            sum.re = u * *cffr++;
                            sum.im = u * *cffi++;

                            for (j=0; j <= curTapIdx; j++) {
                                sum.re += (*mem  ) * (*cffr++);
                                sum.im += (*mem--) * (*cffi++);
                            }

                            mem += subOrder;

                            while (j++ < subOrder) {
                                sum.re += (*mem  ) * (*cffr++);
                                sum.im += (*mem--) * (*cffi++);
                            }

                            *(out + (*wrIdx)++) = sum;
                            ++curPhaseIdx;
                        }

                        if (curPhaseIdx >= iFactor) curPhaseIdx = 0;

                        if (curPhaseIdx == 0) {
                            if ( (++curTapIdx) >= subOrder ) curTapIdx = 0;

                            tap0[curTapIdx] = u;
                        }
                    } /* frame */

                    tap0 += subOrder;

                } /* channel */
	        
            }
            else {
                /* Real data, real filter */
                int_T   k;
                real_T *tap0 = ssGetDWork(S, TapDelayLineBuff);
                real_T *out  = (real_T *) ssGetDWork(S, OutputBuff);

                for (k = 0; k < numChans; k++) {
                    /* Each channel starts with the same filter phase but accesses
                     * its own state memory and input.
                     */
                    int_T i;

                    curTapIdx   = *tapIdx;
                    curPhaseIdx =  0;

                    for (i = 0; i < frame; i++) {
                        /* The filter coefficient have (hopefully) been re-ordered into phase order */
                        real_T	    *cff = mxGetPr(FILT_ARG);
                        const real_T  u   = **uptr++;
                        int_T         m;

                        /* Generate the output samples */
                        for (m = 0; m < iFactor; m++) { 
                            int_T   j;
                            real_T *mem	= tap0 + curTapIdx;  /* Most recently saved input */
                            real_T  sum	= u * (*cff++);

                            for (j = 0; j <= curTapIdx; j++) {
                                sum += (*mem--) * (*cff++);
                            }

                            /* mem was pointing at the -1th element.  Move to end. */
                            mem += subOrder;

                            while(j++ < subOrder) {
                                sum += (*mem--) * (*cff++);
                            }

                            *(out + (*wrIdx)++) = sum;
                            ++curPhaseIdx;
                        }

                        /* Update the counters modulo their buffer size */
                        if (curPhaseIdx >= iFactor) curPhaseIdx = 0;

                        if (curPhaseIdx == 0) {
                            if ( (++curTapIdx) >= subOrder ) curTapIdx = 0;

                            /* Save the current input value */
                            tap0[curTapIdx] = u;
                        }
                    } /* frame */

                    tap0 += subOrder;

                } /* channel */
            } /* Real Filter */
        } /* Real Data */

        /* Update stored indices */
        *tapIdx = curTapIdx;

        if (*wrIdx >= 2*portWidth*iFactor) *wrIdx = 0;
    }


    /* *********************************************** */
    /* Output the next processed sample when requested */
    /* *********************************************** */
    if (ssIsSampleHit(S, outportTid, tid)) {
        const int_T      inportWidth       = ssGetInputPortWidth(S, INPORT);
        const int_T      outportWidth      = ssGetOutputPortWidth(S, OUTPORT);
        const boolean_T  filtComplex       = mxIsComplex(FILT_ARG);
        const boolean_T  inComplex         = (ssGetInputPortComplexSignal(S, INPORT) == COMPLEX_YES);
        const int_T      iFactor           = (int_T) *mxGetPr(IFACTOR_ARG);
        const real_T     outSigNormScaling = 1.0 / ( (real_T) iFactor );
        int_T            numChans          = (int_T) *mxGetPr(NCHANS_ARG);
        int_T            framing           = (int_T) *mxGetPr(FRAMING_ARG);
        int_T           *rdIdx             = (int_T *) ssGetDWork(S, ReadIdx);
        int_T            frame, outFrame, sizeOfFrame;

        if (numChans == CHANNEL_BASED) numChans = inportWidth;

        frame    = inportWidth  / numChans;
        outFrame = outportWidth / numChans;

        if (filtComplex || inComplex) {
            /* Complex output */
            creal_T      *out               = (creal_T *) ssGetDWork(S, OutputBuff);
            creal_T      *y                 = (creal_T *) ssGetOutputPortSignal(S, OUTPORT);
            int_T         halfFrmBufWidth   = frame*iFactor;
            int_T         interpBufferWidth = inportWidth*iFactor;
            int_T         k;

            if (*rdIdx >= halfFrmBufWidth) out += (interpBufferWidth - halfFrmBufWidth);

            sizeOfFrame = interpBufferWidth / numChans;

            for (k=0; k < numChans; k++) {
                int_T rIdx = k*sizeOfFrame;
                int_T i;

                for (i=0; i++ < outFrame;   ) {
                    /* Output the current samples, NORMALIZED by the Interpolation */
                    /* Factor in order to preserve input signal scaling. Note that */
                    /* this is done here once at the end of the computation (i.e.  */
                    /* just before the output gets sent out) in order to preserve  */
                    /* as much signal numerical precision as possible.             */
                    const real_T normRealOutput =
                        ( (out + (*rdIdx) + (rIdx  ))->re ) * outSigNormScaling;

                    const real_T normImagOutput =
                        ( (out + (*rdIdx) + (rIdx++))->im ) * outSigNormScaling;

                    creal_T normCplxOutput;

                    normCplxOutput.re = normRealOutput;
                    normCplxOutput.im = normImagOutput;

                    *y++ = normCplxOutput;
                }
            }
        }
        else {
            /* Real output */
            real_T *out               = (real_T *) ssGetDWork(S, OutputBuff);
            real_T *y                 = ssGetOutputPortRealSignal(S, OUTPORT);
            int_T   halfFrmBufWidth   = frame*iFactor;
            int_T   interpBufferWidth = inportWidth*iFactor;
            int_T   k;
    
            /* Move to the second half of the buffer? */
            if ( *rdIdx >= halfFrmBufWidth ) {
                out += interpBufferWidth - halfFrmBufWidth;
            }

            sizeOfFrame = interpBufferWidth / numChans;
    
            for (k=0; k < numChans; k++) {
                int_T rIdx = k*sizeOfFrame;
                int_T i;

                for (i=0; i < outFrame; i++) {
                    /* Output the current samples, NORMALIZED by the Interpolation */
                    /* Factor in order to preserve input signal scaling. Note that */
                    /* this is done here once at the end of the computation (i.e.  */
                    /* just before the output gets sent out) in order to preserve  */
                    /* as much signal numerical precision as possible.             */
                    *y++ = ( *(out + (*rdIdx) + (rIdx++)) ) * outSigNormScaling;
                }
            }
        }

        if ( (*rdIdx += outFrame) >= 2*frame*iFactor ) *rdIdx = 0;
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
        THROW_ERROR(S, "Continuous sample times not allowed for interpolation block.");
    }

    if (offsetTime != 0.0) { 
        THROW_ERROR(S, "Non-zero sample time offsets not allowed."); 
    } 

    ssSetInputPortSampleTime(S, INPORT, sampleTime); 
    ssSetInputPortOffsetTime(S, INPORT, 0.0); 
    
    if (ssGetOutputPortSampleTime(S, OUTPORT) == INHERITED_SAMPLE_TIME) {
        const int_T	iFactor	= (int_T) *mxGetPr(IFACTOR_ARG);
        const int_T	framing	= (int_T) *mxGetPr(FRAMING_ARG);
        
        if (framing == CONST_RATE_FRAMING) {
            ssSetOutputPortSampleTime(S, OUTPORT, sampleTime);
        }
        else {
            ssSetOutputPortSampleTime(S, OUTPORT, sampleTime / iFactor);
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
        THROW_ERROR(S, "Continuous sample times not allowed for interpolation block.");
    }

    if (offsetTime != 0.0) { 
        THROW_ERROR(S, "Non-zero sample time offsets not allowed."); 
    }
    
    ssSetOutputPortSampleTime(S, OUTPORT, sampleTime); 
    ssSetOutputPortOffsetTime(S, OUTPORT, 0.0); 
    
    if (ssGetInputPortSampleTime(S, INPORT) == INHERITED_SAMPLE_TIME) {
        const int_T	iFactor	= (int_T) *mxGetPr(IFACTOR_ARG);
        const int_T	framing	= (int_T) *mxGetPr(FRAMING_ARG);

        if (framing == CONST_RATE_FRAMING) {
            ssSetInputPortSampleTime(S, INPORT, sampleTime);
        }
        else {
            ssSetInputPortSampleTime(S, INPORT, sampleTime * iFactor);
        }
        
        ssSetInputPortOffsetTime(S, INPORT, 0.0); 
    }
} 
#endif 


#ifdef MATLAB_MEX_FILE
#define MDL_SET_INPUT_PORT_WIDTH
static void mdlSetInputPortWidth(SimStruct *S, int_T port, int_T inputPortWidth)
{
    const int_T iFactor         = (int_T) *mxGetPr(IFACTOR_ARG);
    const int_T numChans        = (int_T) *mxGetPr(NCHANS_ARG);
    const int_T outputPortWidth = ssGetOutputPortWidth(S, port);
          int_T framing         = (int_T) *mxGetPr(FRAMING_ARG);

    ssSetInputPortWidth (S, port, inputPortWidth);

    if (numChans == CHANNEL_BASED) {
        framing = CONST_SIZE_FRAMING;
    }

    if (framing == CONST_RATE_FRAMING) {
        if (outputPortWidth == DYNAMICALLY_SIZED) {
            ssSetOutputPortWidth(S, port, inputPortWidth * iFactor);
        }
        else if (outputPortWidth != inputPortWidth * iFactor) {
            THROW_ERROR(S, "(Output port width)/(Input port width) "
                         "must equal the interpolation factor.");
        }
    }
    else {
        if (outputPortWidth == DYNAMICALLY_SIZED) {
            ssSetOutputPortWidth(S, port, inputPortWidth);
        }
        else if (outputPortWidth != inputPortWidth) {
            THROW_ERROR(S, "Input port width must equal output port width.");
        }
    }
}



#define MDL_SET_OUTPUT_PORT_WIDTH
static void mdlSetOutputPortWidth(SimStruct *S, int_T port, int_T outputPortWidth)
{
    const int_T iFactor        = (int_T) *mxGetPr(IFACTOR_ARG);
    const int_T numChans       = (int_T) *mxGetPr(NCHANS_ARG);
    const int_T inputPortWidth = ssGetInputPortWidth(S, port);
    int_T       framing        = (int_T) *mxGetPr(FRAMING_ARG);

    ssSetOutputPortWidth (S, port, outputPortWidth);

    if (numChans == CHANNEL_BASED) {
        framing = CONST_SIZE_FRAMING;
    }

    if (framing == CONST_RATE_FRAMING) {
        if (inputPortWidth == DYNAMICALLY_SIZED && (outputPortWidth % iFactor) == 0) {
            ssSetInputPortWidth(S, port, outputPortWidth/iFactor);
        }
        else if (inputPortWidth != outputPortWidth/iFactor) {
            THROW_ERROR(S, "(Output port width)/(Input port width) "
	                 "must equal the interpolation factor.");
        }
    }
    else {
        if (inputPortWidth == DYNAMICALLY_SIZED) {
            ssSetInputPortWidth(S, port, outputPortWidth);
        }
        else if (inputPortWidth != outputPortWidth) {
            THROW_ERROR(S, "Input port width must equal output port width.");
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
    const int_T     inportWidth   = ssGetInputPortWidth(S, INPORT);
    const real_T    iFactorf      = *mxGetPr(IFACTOR_ARG);
    const int_T     order         = mxGetNumberOfElements(FILT_ARG) - 1;
    const boolean_T inputComplex  = (boolean_T) (ssGetInputPortComplexSignal(S, INPORT) == COMPLEX_YES);
    const boolean_T filtComplex   = (boolean_T) mxIsComplex(FILT_ARG);
    const int_T     numICs        = mxGetNumberOfElements(OUTBUF_INITCOND_ARG);
    const int_T     outputBufLen  = inportWidth*((int_T)iFactorf)*2; /* Note: double-buffered */
    int_T           numChans      = (int_T) *mxGetPr(NCHANS_ARG);

    if (numChans == CHANNEL_BASED) numChans = inportWidth;

    /* Check number of Output Buffer ICs */
    if ( (numICs != 0) && (numICs != 1) && (numICs != outputBufLen) ) {
        /* Initial conditions must be either length zero, one, or */
        /* equal to the length of the output buffer. Otherwise we */
        /* cannot understand how to fill the output buffer!!!     */
        THROW_ERROR(S,"Invalid number of output buffer initial conditions.");
    }

    if(!ssSetNumDWork(S, NUM_DWORKS)) return;

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
}
#endif


#define MDL_RTW
#if defined(MATLAB_MEX_FILE) || defined(NRT)
static void mdlRTW(SimStruct *S)
{
    const int32_T iFactor  = (int32_T) *mxGetPr(IFACTOR_ARG);
    const int32_T numChans = (int32_T) *mxGetPr(NCHANS_ARG);
    const int32_T framing  = (int32_T) *mxGetPr(FRAMING_ARG);
    const int32_T icRows   = (int32_T)  mxGetM(OUTBUF_INITCOND_ARG);
    const int32_T icCols   = (int32_T)  mxGetN(OUTBUF_INITCOND_ARG);
    const real_T  zero     = 0;
    int_T         numIC    = 1; 
    const real_T *IC_re    = &zero;  /* init for empty IC case */
    const real_T *IC_im    = NULL;


    if(!mxIsEmpty(OUTBUF_INITCOND_ARG)) {
        numIC = mxGetNumberOfElements(OUTBUF_INITCOND_ARG);
        IC_re = mxGetPr(OUTBUF_INITCOND_ARG);
        IC_im = mxGetPi(OUTBUF_INITCOND_ARG);
    }


    if (!ssWriteRTWParamSettings(S, 7,

                                 SSWRITE_VALUE_DTYPE_ML_VECT, "FILTER", 
                                 mxGetPr(FILT_ARG), mxGetPi(FILT_ARG), 
                                 mxGetNumberOfElements(FILT_ARG),
                                 DTINFO(SS_DOUBLE, mxIsComplex(FILT_ARG)),
                                 
                                 SSWRITE_VALUE_DTYPE_NUM,     "IFACTOR",
                                 &iFactor,
                                 DTINFO(SS_INT32,0),

                                 SSWRITE_VALUE_DTYPE_NUM,     "NUM_CHANS",
                                 &numChans,
                                 DTINFO(SS_INT32,0),

                                 SSWRITE_VALUE_DTYPE_NUM,     "FRAMING",
                                 &framing,
                                 DTINFO(SS_INT32,0),

                                 SSWRITE_VALUE_DTYPE_ML_VECT, "IC",
                                 IC_re, IC_im, numIC,
                                 DTINFO(SS_DOUBLE, mxIsComplex(OUTBUF_INITCOND_ARG)),

                                 SSWRITE_VALUE_DTYPE_NUM,     "IC_ROWS",
                                 &icRows,
                                 DTINFO(SS_INT32,0),

                                 SSWRITE_VALUE_DTYPE_NUM,     "IC_COLS",
                                 &icCols,
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
