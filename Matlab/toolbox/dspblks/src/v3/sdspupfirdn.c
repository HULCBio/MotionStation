/*
 * SDSPUPFIRDN A SIMULINK rate conversion FIR filter block.
 *        DSP Blockset S-Function for the efficient polyphase
 *        implementation of a FIR rational sampling rate conversion filter.
 *
 *   
 *  Copyright 1995-2002 The MathWorks, Inc.
 *  $Revision: 1.25 $  $Date: 2002/04/14 20:42:17 $
 */

#define S_FUNCTION_LEVEL 2
#define S_FUNCTION_NAME sdspupfirdn

#include "dsp_sim.h"

/*
 * Definitions for easy access of the input parameters
 */
enum {
    ARGC_FILT = 0,
    ARGC_IFACTOR,
    ARGC_DFACTOR,
    ARGC_N0,
    ARGC_N1,
    ARGC_NUM_CHANS,
    ARGC_INIT_COND_OUTBUF,
    NUM_ARGS
};

#define FILT_ARG        ssGetSFcnParam(S, ARGC_FILT)
#define IFACTOR_ARG     ssGetSFcnParam(S, ARGC_IFACTOR)
#define DFACTOR_ARG     ssGetSFcnParam(S, ARGC_DFACTOR)
#define N0_ARG          ssGetSFcnParam(S, ARGC_N0)
#define N1_ARG          ssGetSFcnParam(S, ARGC_N1)
#define CHANS_ARG       ssGetSFcnParam(S, ARGC_NUM_CHANS)
#define OUTINITCOND_ARG ssGetSFcnParam(S, ARGC_INIT_COND_OUTBUF )

/* An invalid (-1) number of channels is used to flag channel-based operation */
const int_T SAMPLE_BASED = -1;

/* Port Index Enumerations */
enum {INPORT  = 0, NUM_INPORTS};
enum {OUTPORT = 0, NUM_OUTPORTS};

/* If n1 > 0, all dworks are needed, otherwise, OutBuf is not needed */
enum {InPhaseIdx = 0, OutIdx, MemIdx, PartialSums, DiscState, OutBuf, MAX_NUM_DWORKS};

/* PWork indices */
enum {CffRPtr = 0, CffIPtr, NUM_PWORKS};


#ifdef MATLAB_MEX_FILE
#define MDL_CHECK_PARAMETERS
static void mdlCheckParameters(SimStruct *S) {
    const char     *msg         = NULL;
    const int_T	  numFiltArg  = mxGetNumberOfElements(FILT_ARG);
    const int_T	  numDFArg    = mxGetNumberOfElements(DFACTOR_ARG);
    const int_T	  numIFArg    = mxGetNumberOfElements(IFACTOR_ARG);
    const int_T	  numChansArg = mxGetNumberOfElements(CHANS_ARG);
    const boolean_T runTime     = (ssGetSimMode(S) != SS_SIMMODE_SIZES_CALL_ONLY);

    if (runTime || !mxIsEmpty(DFACTOR_ARG)) {
        if (numDFArg != 1 || mxGetPr(DFACTOR_ARG)[0] < 1 ||
            mxGetPr(DFACTOR_ARG)[0] != (int_T) mxGetPr(DFACTOR_ARG)[0]) {
            msg = "Decimation factor must be a positive integer >= 1";
            goto FCN_EXIT;
        }
    }

    if (runTime || !mxIsEmpty(IFACTOR_ARG)) {
        if (numIFArg != 1 || mxGetPr(IFACTOR_ARG)[0] < 1 ||
            mxGetPr(IFACTOR_ARG)[0] != (int_T) mxGetPr(IFACTOR_ARG)[0]) {
            msg = "Interpolation factor must be a positive integer >= 1";
            goto FCN_EXIT;
        }
    }

    /* Check filter: */
    if (runTime || !mxIsEmpty(FILT_ARG)) {
        if (mxIsEmpty(FILT_ARG) || mxGetN(FILT_ARG) != (mxGetPr(IFACTOR_ARG)[0] * mxGetPr(DFACTOR_ARG)[0])) {
            msg = "Filter coefficients must be a polyphase matrix with the number of "
                "columns equal to (interpolation factor)*(decimation factor).";
            goto FCN_EXIT;
        }

        if (numFiltArg < 2) {
            msg = "For proper operation, the number of filter coefficients "
                "in the polyphase matrix must be at least two.  Use a decimation "
                "factor >= 2 or increase the filter order.";
            goto FCN_EXIT;
        }
    }

    if (runTime || !mxIsEmpty(CHANS_ARG)) {
        if (numChansArg != 1 || (mxGetPr(CHANS_ARG)[0] <= 0 && mxGetPr(CHANS_ARG)[0] != SAMPLE_BASED)) {
            msg = "The number of channels must be an integer >= 1. ";
            /*"If it is -1, the number of channels equals the input port width.";*/
            goto FCN_EXIT;
        }
    }

    /* Check output buffer initial conditions */
    if (OK_TO_CHECK_VAR(S, OUTINITCOND_ARG)) {
        if (!mxIsNumeric(OUTINITCOND_ARG) || mxIsSparse(OUTINITCOND_ARG)) {
            THROW_ERROR(S,"Output buffer initial conditions must be numeric.");
        }
    }

    /* Temporary check */
    if (mxGetPr(CHANS_ARG)[0] == SAMPLE_BASED) {
        msg = "Channel based operation is not yet supported.  You can use a buffer block on "
            "input and an unbuffer block on output for channel-based use.";
        goto FCN_EXIT;
    }


FCN_EXIT:
    if (msg != NULL) {
        ssSetErrorStatus(S,msg);
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
    ssSetSFcnParamNotTunable(S, ARGC_IFACTOR);
    ssSetSFcnParamNotTunable(S, ARGC_NUM_CHANS);
    ssSetSFcnParamNotTunable(S, ARGC_N0);
    ssSetSFcnParamNotTunable(S, ARGC_N1);
    ssSetSFcnParamNotTunable(S, ARGC_INIT_COND_OUTBUF);

    if (!ssSetNumInputPorts(        S, NUM_INPORTS)) return;
    ssSetInputPortWidth(            S, INPORT, DYNAMICALLY_SIZED);
    ssSetInputPortComplexSignal(    S, INPORT, COMPLEX_INHERITED);
    ssSetInputPortDirectFeedThrough(S, INPORT, 1);
    /* The TestPoint must be set to 1 when multiple sample times are added */
    ssSetInputPortReusable(         S, INPORT, 0);
    ssSetInputPortOverWritable(     S, INPORT, 0);  /* revisits inputs multiple times */

    if (!ssSetNumOutputPorts(    S, NUM_OUTPORTS)) return;
    ssSetOutputPortWidth(        S, OUTPORT, DYNAMICALLY_SIZED);
    ssSetOutputPortComplexSignal(S, OUTPORT, COMPLEX_INHERITED);

    if(!ssSetNumDWork(  S, DYNAMICALLY_SIZED)) return;
    ssSetNumSampleTimes(S, 1);
    ssSetNumPWork(      S, NUM_PWORKS);
    ssSetOptions(       S, SS_OPTION_EXCEPTION_FREE_CODE);
}


#define MDL_START
static void mdlStart (SimStruct *S)
{
#ifdef MATLAB_MEX_FILE
    const int_T portWidth = ssGetInputPortWidth(S, INPORT);
    const int_T dFactor   = (int_T) *mxGetPr(DFACTOR_ARG);
    int_T       numChans  = (int_T) *mxGetPr(CHANS_ARG);
    boolean_T   complex   = mxIsComplex(FILT_ARG) ||
                                ( ssGetInputPortComplexSignal(S, INPORT) == COMPLEX_YES );
    int_T       frame;

    if (numChans == SAMPLE_BASED) {
        numChans = portWidth;
        frame = 1;
    }
    else frame = (portWidth / numChans);

    if ((int_T) *mxGetPr(CHANS_ARG) != SAMPLE_BASED && (frame % dFactor) != 0) {
        THROW_ERROR(S, "The input frame size must be a multiple of "
            "the decimation factor");
    }

    if (numChans != SAMPLE_BASED && (ssGetInputPortWidth(S, INPORT) % numChans)) {
        THROW_ERROR(S, "The port width must be a multiple of the number of channels");
    }

    if (ssGetSampleTime(S, 0) == CONTINUOUS_SAMPLE_TIME) {
        THROW_ERROR(S,"Input to block must have a discrete sample time");
    }

    if ((complex  && ssGetOutputPortComplexSignal(S, OUTPORT) != COMPLEX_YES) ||
        (!complex && ssGetOutputPortComplexSignal(S, OUTPORT) != COMPLEX_NO)) {
        THROW_ERROR(S,"If the input or filter coefficients are complex "
            "then the output must be complex");
    }	 
#endif
}


static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, FIXED_IN_MINOR_STEP_OFFSET);
}


#define MDL_INITIALIZE_CONDITIONS
static void mdlInitializeConditions(SimStruct *S)
{
    const int_T n1 = (int_T) *mxGetPr(N1_ARG);

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
    if (n1 > 0) {
        const int_T     numICs      = mxGetNumberOfElements(OUTINITCOND_ARG);
        const boolean_T cplxInp     = (boolean_T)(ssGetInputPortComplexSignal(S, INPORT) == COMPLEX_YES);
        const boolean_T filtComplex = mxIsComplex(FILT_ARG);
        const uint_T    outBufWidth = ssGetDWorkWidth(S, OutBuf);

        /* ---------------------------------------------------------------------- */
        /* If n1 > 0, all DWorks needed, otherwise OutBuf (and thus ICs) not used */
        /* ---------------------------------------------------------------------- */

        if ( (numICs < 0) || ( (numICs > 1) && (numICs != outBufWidth) ) ) {
            THROW_ERROR(S, "Output initial conditions vector has incorrect dimensions.");
        }

        if ((!cplxInp) && (!filtComplex) && mxIsComplex(OUTINITCOND_ARG)) {
            THROW_ERROR(S, "Complex output initial conditions are not allowed with real outputs.");
        }

        if ( (!cplxInp) && (!filtComplex) ) {
            /* Real input signal and real filter -> real output buffer ICs */
            real_T *pIC    = mxGetPr(OUTINITCOND_ARG);
            real_T *outBuf = (real_T *) ssGetDWork( S, OutBuf);
            
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
            real_T          *prIC    = mxGetPr(OUTINITCOND_ARG);
            real_T          *piIC    = mxGetPi(OUTINITCOND_ARG);
            const boolean_T  ic_cplx = (boolean_T)(piIC != NULL);
            creal_T         *outBuf  = (creal_T *) ssGetDWork(S, OutBuf);
            
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
    } /* (n1 > 0) */


    /* Set initial pointer indices here */
    {
        int_T *inPhaseIdx = (int_T *) ssGetDWork(S, InPhaseIdx);
        int_T *tapIdx     = (int_T *) ssGetDWork(S, MemIdx);
        int_T *outIdx     = (int_T *) ssGetDWork(S, OutIdx);

        *inPhaseIdx = 0;
        *outIdx     = 0;
        *tapIdx     = 0;

        ssSetPWorkValue(S, CffRPtr, mxGetPr(FILT_ARG));
        ssSetPWorkValue(S, CffIPtr, mxGetPi(FILT_ARG));
    }
}


static void mdlOutputs(SimStruct *S, int_T tid)
{
    const int_T      dFactor           = (int_T) *mxGetPr(DFACTOR_ARG);
    const int_T      iFactor           = (int_T) *mxGetPr(IFACTOR_ARG);
    const int_T      n0                = (int_T) *mxGetPr(N0_ARG);
    const int_T      n1                = (int_T) *mxGetPr(N1_ARG);
    const int_T      portWidth         = ssGetInputPortWidth(S, INPORT);
    const int_T      length            = mxGetNumberOfElements(FILT_ARG);
    const int_T      subOrder          = mxGetM(FILT_ARG);
    const boolean_T  filtComplex       = (boolean_T) mxIsComplex(FILT_ARG);
    const boolean_T  inComplex         = (boolean_T) (ssGetInputPortComplexSignal(S, INPORT) == true);
    int_T            numChans          = (int_T)    *mxGetPr(CHANS_ARG);
    const real_T     outSigNormScaling = 1.0 / ( (real_T) iFactor );
    int_T           *inPhaseIdx        = (int_T *)   ssGetDWork(S, InPhaseIdx);
    int_T           *tapIdx            = (int_T *)   ssGetDWork(S, MemIdx);
    int_T           *outIdx            = (int_T *)   ssGetDWork(S, OutIdx);
    real_T          *cffRPtr           = (real_T *)  ssGetPWorkValue(S, CffRPtr);
    real_T          *cffIPtr           = (real_T *)  ssGetPWorkValue(S, CffIPtr);
    int_T            i, j, k, m, frame, inIdx, mIdx, oIdx, memSize, memStride, outLen;
    
    if (numChans == SAMPLE_BASED) {
        numChans = portWidth;
        frame = 1;
    }
    else frame = (portWidth / numChans);

    memSize   = ssGetDWorkWidth(S, DiscState) / numChans;
    memStride = (memSize - n0);
    outLen    = n1*iFactor;

    /* The algorithm is fully documented for the real+real case.  The other three
     * cases use the same algorithm.
     */
    if (inComplex) { /* Complex Data */
        InputPtrsType  uptr   = ssGetInputPortSignalPtrs(S, INPORT);
        creal_T       *tap0   = (creal_T *) ssGetDWork(S, DiscState);
        creal_T       *sums   = (creal_T *) ssGetDWork(S, PartialSums);
        creal_T       *outBuf = (creal_T *) ssGetDWork(S, OutBuf);
        creal_T       *y      = (creal_T *) ssGetOutputPortSignal(S, OUTPORT);

        if (filtComplex) { /* Complex data, complex filter */
            real_T *cffr;
            real_T *cffi;

            for (k=0; k < numChans; k++) {
                inIdx = *inPhaseIdx;
                mIdx  = *tapIdx;
                oIdx  = *outIdx;
                cffr  =  cffRPtr;
                cffi  =  cffIPtr;

                for (i=0; i < frame; i++) {
                    *(tap0+mIdx) = *((creal_T *) (*uptr++));

                    for (j=0; j < iFactor; j++) {
                        /* The temporary variables rsum and isum are needed due to
                         * a bug in the Visual C compiler level 2 optimization */
                        real_T   rsum   = sums[j].re;
                        real_T   isum   = sums[j].im;
                        creal_T *tap    = tap0 + mIdx - ( (iFactor-j)*n0 );
                        creal_T *stop;

                        while (tap < tap0) tap += memSize;
                        stop = tap - memStride;
                        if (stop < tap0) stop += memSize;

                        m    = 0;
                        tap += dFactor;

                        while ((tap-=dFactor) >= tap0 && ++m <= subOrder) {
                            rsum += (tap->re) * (*cffr  ) - (tap->im) * (*cffi  );
                            isum += (tap->im) * (*cffr++) + (tap->re) * (*cffi++);
                        }

                        tap += (memSize + dFactor);

                        while (++m <= subOrder) {
                            tap -= dFactor;
                            rsum += (tap->re) * (*cffr  ) - (tap->im) * (*cffi  );
                            isum += (tap->im) * (*cffr++) + (tap->re) * (*cffi++);
                        }

                        sums[j].re = rsum;
                        sums[j].im = isum;
                    }

                    if (++inIdx == dFactor) {
                        for (j=0; j < iFactor; j++) {
                            creal_T normCplxOutput;
                            real_T  normRealOutput;
                            real_T  normImagOutput;

                            outBuf[(j*n1+oIdx) % outLen] = sums[j];

                            /* Output the current samples, NORMALIZED by the Interpolation */
                            /* Factor in order to preserve input signal scaling. Note that */
                            /* this is done here once at the end of the computation (i.e.  */
                            /* just before the output gets sent out) in order to preserve  */
                            /* as much signal numerical precision as possible.             */

                            normCplxOutput    = outBuf[(j+oIdx) % outLen]; /* not normalized yet */

                            normRealOutput    = normCplxOutput.re * outSigNormScaling;
                            normCplxOutput.re = normRealOutput;

                            normImagOutput    = normCplxOutput.im * outSigNormScaling;
                            normCplxOutput.im = normImagOutput;

                            *y++ = normCplxOutput;

                            sums[j].re = 0.0;
                            sums[j].im = 0.0;
                        }

                        if ((oIdx += iFactor) >= outLen) oIdx = 0;
                        inIdx = 0;
                        cffr = mxGetPr(FILT_ARG);
                        cffi = mxGetPi(FILT_ARG);
                    }

                    if (++mIdx >= memSize) mIdx = 0;
                } /* frame */

                sums   += iFactor;
                tap0   += memSize;
                outBuf += outLen;
            } /* channel */

            cffRPtr = cffr;
            cffIPtr = cffi;
        }
        else { /* Complex data, real filter */
            real_T  *cff;

            for (k=0; k < numChans; k++) {
                inIdx = *inPhaseIdx;
                mIdx  = *tapIdx;
                oIdx  = *outIdx;
                cff   =  cffRPtr;

                for (i=0; i < frame; i++) {
                    *(tap0+mIdx) = *((creal_T *) (*uptr++));

                    for (j=0; j < iFactor; j++) {
                        /* The temporary variables rsum and isum are needed due to
                         * a bug in the Visual C compiler level 2 optimization */
                        real_T   rsum = sums[j].re;
                        real_T   isum = sums[j].im;
                        creal_T *tap  = tap0 + mIdx - (iFactor-j)*n0;
                        creal_T *stop;

                        while (tap < tap0) tap += memSize;
                        stop = tap - memStride;
                        if (stop < tap0) stop += memSize;

                        m=0;
                        tap += dFactor;

                        while ((tap-=dFactor) >= tap0 && ++m <= subOrder) {
                            rsum += (tap->re) * (*cff  );
                            isum += (tap->im) * (*cff++);
                        }

                        tap += (memSize + dFactor);

                        while (++m <= subOrder) {
                            rsum += ((tap -= dFactor)->re) * (*cff);
                            isum += (tap->im) * (*cff++);
                        }

                        sums[j].re = rsum;
                        sums[j].im = isum;
                    }
                    if (++inIdx == dFactor) {
                        for (j=0; j < iFactor; j++) {
                            creal_T normCplxOutput;
                            real_T  normRealOutput;
                            real_T  normImagOutput;

                            outBuf[(j*n1+oIdx) % outLen] = sums[j];

                            /* Output the current samples, NORMALIZED by the Interpolation */
                            /* Factor in order to preserve input signal scaling. Note that */
                            /* this is done here once at the end of the computation (i.e.  */
                            /* just before the output gets sent out) in order to preserve  */
                            /* as much signal numerical precision as possible.             */

                            normCplxOutput    = outBuf[(j+oIdx) % outLen]; /* not normalized yet */

                            normRealOutput    = normCplxOutput.re * outSigNormScaling;
                            normCplxOutput.re = normRealOutput;

                            normImagOutput    = normCplxOutput.im * outSigNormScaling;
                            normCplxOutput.im = normImagOutput;

                            *y++ = normCplxOutput;

                            sums[j].re = 0.0;
                            sums[j].im = 0.0;
                        }

                        if ((oIdx += iFactor) >= outLen) oIdx = 0;
                        inIdx = 0;
                        cff   = mxGetPr(FILT_ARG);
                    }

                    if (++mIdx >= memSize) mIdx = 0;
                } /* frame */

                sums   += iFactor;
                tap0   += memSize;
                outBuf += outLen;
            } /* channel */

            cffRPtr = cff;
        } /* Real Filter */
    }
    else { /* Real Data */
        InputRealPtrsType uptr = ssGetInputPortRealSignalPtrs(S, INPORT);

        if (filtComplex) { /* Real data, complex filter */
            real_T  *tap0   = (real_T *)  ssGetDWork(S, DiscState);
            creal_T *sums   = (creal_T *) ssGetDWork(S, PartialSums);
            creal_T *outBuf = (creal_T *) ssGetDWork(S, OutBuf);
            creal_T *y      = (creal_T *) ssGetOutputPortSignal(S, OUTPORT);
            real_T  *cffr;
            real_T  *cffi;

            for (k=0; k < numChans; k++) {
                inIdx = *inPhaseIdx;
                mIdx = *tapIdx;
                oIdx = *outIdx;
                cffr = cffRPtr;
                cffi = cffIPtr;

                for (i=0; i < frame; i++) {
                    *(tap0+mIdx) = (**uptr++);

                    for (j=0; j < iFactor; j++) {
                        /* The temporary variables rsum and isum are needed due to
                         * a bug in the Visual C compiler level 2 optimization */
                        real_T	rsum = sums[j].re;
                        real_T	isum = sums[j].im;
                        real_T  *tap  = tap0 + mIdx - (iFactor-j)*n0;
                        real_T  *stop;

                        while (tap < tap0) tap += memSize;
                        stop	= tap - memStride;
                        if (stop < tap0) stop += memSize;

                        m=0;
                        tap += dFactor;

                        while ( ((tap-=dFactor) >= tap0) && (++m <= subOrder) ) {
                            rsum += *tap * (*cffr++);
                            isum += *tap * (*cffi++);
                        }

                        tap += (memSize + dFactor);

                        while (++m <= subOrder) {
                            rsum += *(tap -= dFactor) * (*cffr++);
                            isum += *tap              * (*cffi++);
                        }

                        sums[j].re = rsum;
                        sums[j].im = isum;
                    }
                    if (++inIdx == dFactor) {
                        for (j=0; j < iFactor; j++) {
                            creal_T normCplxOutput;
                            real_T  normRealOutput;
                            real_T  normImagOutput;

                            outBuf[(j*n1+oIdx) % outLen] = sums[j];

                            /* Output the current samples, NORMALIZED by the Interpolation */
                            /* Factor in order to preserve input signal scaling. Note that */
                            /* this is done here once at the end of the computation (i.e.  */
                            /* just before the output gets sent out) in order to preserve  */
                            /* as much signal numerical precision as possible.             */

                            normCplxOutput    = outBuf[(j+oIdx) % outLen]; /* not normalized yet */

                            normRealOutput    = normCplxOutput.re * outSigNormScaling;
                            normCplxOutput.re = normRealOutput;

                            normImagOutput    = normCplxOutput.im * outSigNormScaling;
                            normCplxOutput.im = normImagOutput;

                            *y++ = normCplxOutput;

                            sums[j].re = 0.0;
                            sums[j].im = 0.0;
                        }

                        if ((oIdx+=iFactor) >= outLen) oIdx = 0;
                        inIdx = 0;
                        cffr = mxGetPr(FILT_ARG);
                        cffi = mxGetPi(FILT_ARG);
                    }

                    if (++mIdx >= memSize) mIdx = 0;
                } /* frame */

                sums   += iFactor;
                tap0   += memSize;
                outBuf += outLen;
            } /* channel */

            cffRPtr = cffr;
            cffIPtr = cffi;
        }
        else { /* Real data, real filter */
            real_T  *tap0   = (real_T *) ssGetDWork(S, DiscState);
            real_T  *sums   = (real_T *) ssGetDWork(S, PartialSums);
            real_T  *outBuf = (real_T *) ssGetDWork(S, OutBuf);
            real_T  *y      = ssGetOutputPortRealSignal(S, OUTPORT);
            real_T  *cff;

            for (k=0; k < numChans; k++) {
                /* Each channel uses the same filter phase but accesses
                 * its own state memory and input.
                 */
                inIdx = *inPhaseIdx;
                mIdx  = *tapIdx;
                oIdx  = *outIdx;
                cff   =  cffRPtr;

                for (i=0; i < frame; i++) {
                    *(tap0+mIdx) = (**uptr++);

                    /* Compute partial sums for each interpolation phase */
                    for (j=0; j < iFactor; j++) {
                        real_T  *tap = tap0 + mIdx - (iFactor-j)*n0;
                        real_T  *stop;

                        while (tap < tap0) tap += memSize;
                        stop = tap - memStride;
                        if (stop < tap0) stop += memSize;

                        /* Perform the convolution for this phase (on every dFactor samples)
                         * until we reach the start of the (linear) state memory */
                        m    = 0;
                        tap += dFactor;

                        while ( ((tap -= dFactor) >= tap0) && (++m <= subOrder) ) {
                            sums[j] += *tap * (*cff++);
                        }

                        /* wrap the state memory pointer to the next element */
                        tap += (memSize + dFactor);

                        /* Finish the convolution for this phase */
                        while (++m <= subOrder) {
                            sums[j] += *(tap -= dFactor) * (*cff++);
                        }
                    }
                    /* Output and update the counters modulo their buffer size */
                    if (++inIdx == dFactor) {
                        for (j=0; j < iFactor; j++) {
                            /* Put values in their appropriate locations in the output buffer */
                            outBuf[(j*n1+oIdx) % outLen] = sums[j];

                            /* Output the current samples, NORMALIZED by the Interpolation */
                            /* Factor in order to preserve input signal scaling. Note that */
                            /* this is done here once at the end of the computation (i.e.  */
                            /* just before the output gets sent out) in order to preserve  */
                            /* as much signal numerical precision as possible.             */
                            *y++ = ( outBuf[(j+oIdx) % outLen] ) * outSigNormScaling;

                            sums[j] = 0.0;
                        }

                        if ((oIdx+=iFactor) >= outLen) oIdx = 0;
                        inIdx = 0;
                        cff = mxGetPr(FILT_ARG);
                    }

                    if (++mIdx >= memSize) mIdx = 0;
                } /* frame */

                sums   += iFactor;
                tap0   += memSize;
                outBuf += outLen;
            } /* channel */

            cffRPtr = cff;
        } /* Real Filter */
    } /* Real Data */

    /* Update stored indices for next time */
    *inPhaseIdx = inIdx;
    *tapIdx     = mIdx;
    *outIdx     = oIdx;

    ssSetPWorkValue(S, CffRPtr, cffRPtr);
    ssSetPWorkValue(S, CffIPtr, cffIPtr);
}


static void mdlTerminate(SimStruct *S)
{
}


#ifdef MATLAB_MEX_FILE
#define MDL_SET_INPUT_PORT_WIDTH
static void mdlSetInputPortWidth(SimStruct *S, int_T port, int_T inputPortWidth)
{
    const int_T dFactor         = (int_T) *mxGetPr(DFACTOR_ARG);
    const int_T iFactor         = (int_T) *mxGetPr(IFACTOR_ARG);
    const int_T numChans        = (int_T) *mxGetPr(CHANS_ARG);
    const int_T outputPortWidth = ssGetOutputPortWidth(S, port);

    ssSetInputPortWidth (S, port, inputPortWidth);

    if ( (outputPortWidth == DYNAMICALLY_SIZED) && ((inputPortWidth % dFactor) == 0) ) {
        ssSetOutputPortWidth(S, port, (inputPortWidth * iFactor) / dFactor);
    }
    else if ( outputPortWidth != ((inputPortWidth * iFactor) / dFactor) ) {
        THROW_ERROR(S, "(Input port width)/(Output port width) "
            "must equal the (decimation factor)/(interpolation factor)");
    }
}


#define MDL_SET_OUTPUT_PORT_WIDTH
static void mdlSetOutputPortWidth(SimStruct *S, int_T port, int_T outputPortWidth)
{
    const int_T dFactor         = (int_T) *mxGetPr(DFACTOR_ARG);
    const int_T iFactor         = (int_T) *mxGetPr(IFACTOR_ARG);
    const int_T numChans        = (int_T) *mxGetPr(CHANS_ARG);
    const int_T inputPortWidth  = ssGetInputPortWidth(S, port);

    ssSetOutputPortWidth (S, port, outputPortWidth);

    if (inputPortWidth == DYNAMICALLY_SIZED && (outputPortWidth % iFactor) == 0) {
        ssSetInputPortWidth(S, port, ((outputPortWidth*dFactor) / iFactor) );
    }
    else if (inputPortWidth != (outputPortWidth*dFactor)/iFactor) {
        THROW_ERROR(S, "(Input port width)/(Output port width) "
            "must equal the (decimation factor)/(interpolation factor)");
    }
}


#define MDL_SET_INPUT_PORT_COMPLEX_SIGNAL
static void mdlSetInputPortComplexSignal(SimStruct *S, int_T portIdx,
                                         CSignal_T      iPortComplexSignal)
{
    ssSetInputPortComplexSignal(S, portIdx, iPortComplexSignal);

    if (ssGetOutputPortComplexSignal(S, OUTPORT) == COMPLEX_INHERITED) {
        if (mxIsComplex(FILT_ARG)) {
            ssSetOutputPortComplexSignal(S, OUTPORT, COMPLEX_YES);
        }
        else {
            ssSetOutputPortComplexSignal(S, OUTPORT, iPortComplexSignal);
        }
    }
}


#define MDL_SET_OUTPUT_PORT_COMPLEX_SIGNAL
static void mdlSetOutputPortComplexSignal(SimStruct *S, int_T portIdx,
                                         CSignal_T      oPortComplexSignal)
{
    ssSetOutputPortComplexSignal(S, portIdx, oPortComplexSignal);		
}

#endif /* MATLAB_MEX_FILE */


#ifdef MATLAB_MEX_FILE
#define MDL_SET_WORK_WIDTHS
static void mdlSetWorkWidths(SimStruct *S)
{
    const int_T portWidth    = ssGetInputPortWidth(S, INPORT);
    const int_T length       = mxGetNumberOfElements(FILT_ARG);
    const int_T dFactor      = (int_T) *mxGetPr(DFACTOR_ARG);
    const int_T iFactor      = (int_T) *mxGetPr(IFACTOR_ARG);
    const int_T n0           = (int_T) *mxGetPr(N0_ARG);
    const int_T n1           = (int_T) *mxGetPr(N1_ARG);
    int_T       numChans     = (int_T) *mxGetPr(CHANS_ARG);
    int_T       nDWorks      = (n1 > 0)? MAX_NUM_DWORKS:(MAX_NUM_DWORKS - 1);
    boolean_T   inputComplex = (boolean_T) (ssGetInputPortComplexSignal(S, INPORT) == COMPLEX_YES);
    boolean_T   filtComplex  = (boolean_T) mxIsComplex(FILT_ARG);
    int_T       subLen;

    if (numChans == SAMPLE_BASED) {
        numChans = portWidth;
    }

    subLen = length / iFactor;

    /* Set number of DWorks */
    if(!ssSetNumDWork(S, nDWorks)) return;

    ssSetDWorkWidth(   S, InPhaseIdx, 1);
    ssSetDWorkDataType(S, InPhaseIdx, SS_INT32);

    ssSetDWorkWidth(   S, OutIdx, 1);
    ssSetDWorkDataType(S, OutIdx, SS_INT32);

    ssSetDWorkWidth(   S, MemIdx, 1);
    ssSetDWorkDataType(S, MemIdx, SS_INT32);

    ssSetDWorkWidth(   S, PartialSums, numChans*iFactor);
    ssSetDWorkDataType(S, PartialSums, SS_DOUBLE);
    if (inputComplex || filtComplex)
        ssSetDWorkComplexSignal(S, PartialSums, COMPLEX_YES);

    /* If n1 > 0, all dworks are needed, otherwise, OutBuf is not needed */
    if (n1 > 0) {
        ssSetDWorkWidth(   S, OutBuf, (numChans*iFactor*n1));
        ssSetDWorkDataType(S, OutBuf, SS_DOUBLE);
        if (inputComplex || filtComplex)
            ssSetDWorkComplexSignal(S, OutBuf, COMPLEX_YES);
    }

    /* Set dwork associated to discrete states */
    ssSetDWorkWidth(   S, DiscState, numChans*(subLen + (iFactor)*n0));
    ssSetDWorkDataType(S, DiscState, SS_DOUBLE);
    if (inputComplex)
        ssSetDWorkComplexSignal(S, DiscState, COMPLEX_YES);
}
#endif


#if defined(MATLAB_MEX_FILE) || defined(NRT)
#define MDL_RTW
static void mdlRTW(SimStruct *S)
{
    int32_T iFactor      = (int32_T)mxGetPr(IFACTOR_ARG)[0];
    int32_T dfactor      = (int32_T)mxGetPr(DFACTOR_ARG)[0];
    int32_T numChans     = (int32_T)mxGetPr(CHANS_ARG)[0];
    int32_T n0           = (int32_T)mxGetPr(N0_ARG)[0];
    int32_T n1           = (int32_T)mxGetPr(N1_ARG)[0];
    const int32_T icRows = (int32_T)mxGetM(OUTINITCOND_ARG);
    const int32_T icCols = (int32_T)mxGetN(OUTINITCOND_ARG);
    const real_T  zero   = 0;
    int_T         numIC  = 1; 
    const real_T *IC_re  = &zero;  /* init for empty IC case */
    const real_T *IC_im  = NULL;

    if(!mxIsEmpty(OUTINITCOND_ARG)) {
        numIC = mxGetNumberOfElements(OUTINITCOND_ARG);
        IC_re = mxGetPr(OUTINITCOND_ARG);
        IC_im = mxGetPi(OUTINITCOND_ARG);
    }

    if (!ssWriteRTWParamSettings(S, 9,
                                 SSWRITE_VALUE_DTYPE_ML_VECT, "FILTER",
                                 mxGetPr(FILT_ARG), mxGetPi(FILT_ARG), 
                                 mxGetM(FILT_ARG)  *mxGetN(FILT_ARG),
                                 DTINFO(SS_DOUBLE,  mxIsComplex(FILT_ARG)),

                                 SSWRITE_VALUE_DTYPE_NUM,  "IFACTOR",
                                 &iFactor,
                                 DTINFO(SS_INT32,0),

                                 SSWRITE_VALUE_DTYPE_NUM,  "DFACTOR",
                                 &dfactor,
                                 DTINFO(SS_INT32,0),

                                 SSWRITE_VALUE_DTYPE_NUM,  "NUM_CHANS",
                                 &numChans,
                                 DTINFO(SS_INT32,0),

                                 SSWRITE_VALUE_DTYPE_NUM,  "N0",
                                 &n0,
                                 DTINFO(SS_INT32,0),
                                 
                                 SSWRITE_VALUE_DTYPE_NUM,  "N1",
                                 &n1,
                                 DTINFO(SS_INT32,0),

                                 SSWRITE_VALUE_DTYPE_ML_VECT, "IC",
                                 IC_re, IC_im, numIC,
                                 DTINFO(SS_DOUBLE, mxIsComplex(OUTINITCOND_ARG)),

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


#include "dsp_trailer.c"

/* [EOF] sdspupfirdn.c */
