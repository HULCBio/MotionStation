/*
 * SDSPUPSAMP  S-function which increases the sampling rate 
 *     of a signal by inserting zeros into the signal.
 * DSP Blockset S-Function for zero filling input.
 *
 *  Copyright 1995-2002 The MathWorks, Inc.
 *  $Revision: 1.22 $  $Date: 2002/04/14 20:41:57 $
 */
#define S_FUNCTION_NAME sdspupsamp
#define S_FUNCTION_LEVEL 2

#include "dsp_sim.h"

enum {COUNT_IDX=0, INPUT_IDX, BUFF_IDX, NUM_DWORKS};
enum {OUTBUF_PTR=0, INBUF_PTR, NUM_PWORKS};

enum {INPORT=0, NUM_INPORTS};
enum {OUTPORT=0, NUM_OUTPORTS};

enum {CONVFACTOR_ARGC=0, PHASE_ARGC, IC_ARGC, FRAME_ARGC, NCHANS_ARGC, OUTMODE_ARGC, NUM_ARGS};
#define CONVFACTOR_ARG ssGetSFcnParam(S, CONVFACTOR_ARGC)
#define PHASE_ARG      ssGetSFcnParam(S, PHASE_ARGC)
#define IC_ARG         ssGetSFcnParam(S, IC_ARGC)
#define FRAME_ARG      ssGetSFcnParam(S, FRAME_ARGC)
#define NCHANS_ARG     ssGetSFcnParam(S, NCHANS_ARGC)
#define OUTMODE_ARG    ssGetSFcnParam(S, OUTMODE_ARGC)

typedef enum {
    fcnEqualSizes = 1,
    fcnEqualRates
} FcnType;


#ifdef MATLAB_MEX_FILE
#define MDL_CHECK_PARAMETERS
static void mdlCheckParameters(SimStruct *S) {
    
    /* Upsample factor */
    if (OK_TO_CHECK_VAR(S, CONVFACTOR_ARG)) {
        if (!IS_FLINT_GE(CONVFACTOR_ARG, 1)) {
            THROW_ERROR(S, "Sample rate conversion factor must be an integer > 0");
        }
    }
    
    /* Sample offset */
    if ((OK_TO_CHECK_VAR(S, PHASE_ARG))&& (OK_TO_CHECK_VAR(S, CONVFACTOR_ARG)) ){
        int_T convfactor = (int_T) mxGetPr(CONVFACTOR_ARG)[0];
        if (!IS_FLINT_IN_RANGE(PHASE_ARG, 0, convfactor - 1)) {
            THROW_ERROR(S, "Sample offset must be an integer in the range [0:N-1]");
        }
    }
    
    /* Initial conditions: */
    if (OK_TO_CHECK_VAR(S, IC_ARG)) {
        if (!mxIsNumeric(IC_ARG) || mxIsSparse(IC_ARG) ) {
            THROW_ERROR(S,"Initial conditions must be numeric");
        }
    }
    
    /* Frame */
    if (!IS_FLINT_IN_RANGE(FRAME_ARG,0,1)) {
        THROW_ERROR(S,"Frame can be only 0 (non-frame based) or 1 (frame-based)");
    }
    
    /* Number of channels */
    if (OK_TO_CHECK_VAR(S, NCHANS_ARG)) {
        if (!IS_FLINT_GE(NCHANS_ARG, 1)) {
            THROW_ERROR(S, "Number of channels must be a scalar greater than zero");
        }
    }
    
    /* Function Mode */
    if (!IS_FLINT_IN_RANGE(OUTMODE_ARG, 1, 2)) { 
        THROW_ERROR(S,"Output mode must be a scalar in the range [0,1]");
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

    ssSetSFcnParamNotTunable(S, CONVFACTOR_ARGC);
    ssSetSFcnParamNotTunable(S, PHASE_ARGC);
    ssSetSFcnParamNotTunable(S, IC_ARGC);
    ssSetSFcnParamNotTunable(S, FRAME_ARGC);
    ssSetSFcnParamNotTunable(S, NCHANS_ARGC);
    ssSetSFcnParamNotTunable(S, OUTMODE_ARGC);
    
    ssSetNumSampleTimes(S, PORT_BASED_SAMPLE_TIMES);

    if (!ssSetNumInputPorts(S, NUM_INPORTS)) return;
    ssSetInputPortWidth(            S, INPORT, DYNAMICALLY_SIZED);
    ssSetInputPortComplexSignal(    S, INPORT, COMPLEX_INHERITED);
    ssSetInputPortSampleTime(       S, INPORT, INHERITED_SAMPLE_TIME);
    ssSetInputPortDirectFeedThrough(S, INPORT, 1); 
    
    if (!ssSetNumOutputPorts(S, NUM_OUTPORTS)) return;
    ssSetOutputPortWidth(        S, OUTPORT, DYNAMICALLY_SIZED);
    ssSetOutputPortComplexSignal(S, OUTPORT, COMPLEX_INHERITED);
    ssSetOutputPortSampleTime(   S, OUTPORT, INHERITED_SAMPLE_TIME);
     
    if (!ssSetNumDWork(S, DYNAMICALLY_SIZED)) return;
    ssSetNumPWork(S, NUM_PWORKS);
    ssSetOptions( S, SS_OPTION_EXCEPTION_FREE_CODE | 
                  SS_OPTION_USE_TLC_WITH_ACCELERATOR);
}


#if defined(MATLAB_MEX_FILE)
#define MDL_SET_INPUT_PORT_SAMPLE_TIME
static void mdlSetInputPortSampleTime(SimStruct *S,
                                      int_T     portIdx,
                                      real_T    sampleTime,
                                      real_T    offsetTime)
{
    ssSetInputPortSampleTime(S, portIdx, sampleTime);
    ssSetInputPortOffsetTime(S, portIdx, offsetTime);

    if (sampleTime == CONTINUOUS_SAMPLE_TIME) {
		THROW_ERROR(S,"Continuous sample times not allowed for upsample blocks.");
	}

    if (offsetTime != 0.0) {
        ssSetErrorStatus(S, "Non-zero sample time offsets not allowed.");
        return;
    }

    {
        const boolean_T isInputFrameBased = (boolean_T)(mxGetPr(FRAME_ARG)[0] != 0.0);
        const FcnType   ftype      = (FcnType)((int_T)mxGetPr(OUTMODE_ARG)[0]);
        const int_T     convfactor = (int_T) (mxGetPr(CONVFACTOR_ARG)[0]);
        const real_T    Tso        = ((isInputFrameBased) && (ftype == fcnEqualRates)) ? sampleTime 
                                                                                       : sampleTime/convfactor; 
        ssSetOutputPortSampleTime(S, OUTPORT, Tso);
    }
    ssSetOutputPortOffsetTime(S, OUTPORT, 0.0);
}


#define MDL_SET_OUTPUT_PORT_SAMPLE_TIME
static void mdlSetOutputPortSampleTime(SimStruct *S,
                                      int_T     portIdx,
                                      real_T    sampleTime,
                                      real_T    offsetTime)
{
    ssSetOutputPortSampleTime(S, portIdx, sampleTime);
    ssSetOutputPortOffsetTime(S, portIdx, offsetTime);

    if (sampleTime == CONTINUOUS_SAMPLE_TIME) {
		THROW_ERROR(S,"Continuous sample times not allowed for upsample blocks.");
	}

    if (offsetTime != 0.0) {
        ssSetErrorStatus(S, "Non-zero sample time offsets not allowed.");
        return;
    }

    {
        const boolean_T isInputFrameBased = (boolean_T)(mxGetPr(FRAME_ARG)[0] != 0.0);
        const FcnType ftype      = (FcnType)((int_T)mxGetPr(OUTMODE_ARG)[0]);
        const int_T   convfactor = (int_T) (mxGetPr(CONVFACTOR_ARG)[0]);
        const real_T  Tsi        = ((isInputFrameBased) && (ftype == fcnEqualRates)) ? sampleTime 
                                                                                     : sampleTime*convfactor;
        ssSetInputPortSampleTime(S, INPORT, Tsi);
    }
    ssSetInputPortOffsetTime(S, INPORT, 0.0);
}
#endif


static void mdlInitializeSampleTimes(SimStruct *S)
{
    /* Check port sample times: */
	const real_T Tsi = ssGetInputPortSampleTime(S, INPORT);
	const real_T Tso = ssGetOutputPortSampleTime(S, OUTPORT);
	
	if ((Tsi == INHERITED_SAMPLE_TIME)  ||
		(Tso == INHERITED_SAMPLE_TIME)   ) {
		THROW_ERROR(S,"Sample time propagation failed for upsample block.");
	}
}


#define MDL_START
static void mdlStart(SimStruct *S)
{
#ifdef MATLAB_MEX_FILE
    const boolean_T frame   = (boolean_T)(mxGetPr(FRAME_ARG)[0] != 0.0);
    const int_T     nchans  = (int_T)(mxGetPr(NCHANS_ARG)[0]);
    const int_T     width   = ssGetInputPortWidth(S, INPORT);

    if (frame && (width % nchans != 0)) {
        THROW_ERROR(S,"Size of input matrix does not match number of channels");
    }
#endif
}


#define MDL_INITIALIZE_CONDITIONS
static void mdlInitializeConditions(SimStruct *S)
{
    const boolean_T isMultiRate    = isBlockMultiRate(S,INPORT,OUTPORT);
    const boolean_T isMultiTasking = isModelMultiTasking(S);
    const int32_T   phase          = (int32_T)(mxGetPr(PHASE_ARG)[0]);
    const int_T     convfactor     = (int_T) (mxGetPr(CONVFACTOR_ARG)[0]);
    
    /* Reset counter */
    *((int32_T *)ssGetDWork(S, COUNT_IDX)) = (phase == 0) ? 0 : convfactor - phase;
    
    if (isMultiRate) {
        /* Reset index into input */
        *((int32_T *)ssGetDWork(S, INPUT_IDX)) = 0;
        
        if (isMultiTasking) {
            /* Multi-Rate, Multi-Tasking */
            const boolean_T c0      = (boolean_T)(ssGetInputPortComplexSignal(S, INPORT) == COMPLEX_YES);
            const int_T     numIC   = mxGetNumberOfElements(IC_ARG);
            const int_T     inWidth = ssGetInputPortWidth(S, INPORT);
            int_T           i;
            
            /* Initialize buffer */
            if (!c0) {
                /* Real */
                real_T *outBuf = (real_T *)ssGetDWork(S, BUFF_IDX);
                real_T *pIC    = mxGetPr(IC_ARG);
                
                ssSetPWorkValue(S, OUTBUF_PTR, outBuf);
                ssSetPWorkValue(S, INBUF_PTR,  outBuf + inWidth);
                
                if (numIC <= 1) {
                    /* Scalar expansion, or no IC's given: */
                    real_T ic = (numIC == 0) ? (real_T)0.0 : *pIC;
                    for(i = 0; i < inWidth; i++) {
                        *outBuf++ = ic;
                    }
                } else {
                    memcpy(outBuf, pIC, inWidth * sizeof(real_T));
                }
            } else {
                /* Complex */
                real_T          *prIC    = mxGetPr(IC_ARG);
                real_T          *piIC    = mxGetPi(IC_ARG);
                creal_T         *outBuf  = (creal_T *)ssGetDWork(S, BUFF_IDX);
                const boolean_T  ic_cplx = (boolean_T)(piIC != NULL);
                
                ssSetPWorkValue(S, OUTBUF_PTR, outBuf);
                ssSetPWorkValue(S, INBUF_PTR,  outBuf + inWidth);
                
                if (numIC <= 1) {
                    /* Scalar expansion, or no IC's given: */
                    creal_T ic;
                    if (numIC == 0) {
                        ic.re = 0.0;
                        ic.im = 0.0;
                    } else {
                        ic.re = *prIC;
                        ic.im = (ic_cplx) ? *piIC : 0.0;
                    }
                    
                    for(i = 0; i < inWidth; i++) {
                        *outBuf++ = ic;
                    }
                    
                } else {
                    if (ic_cplx) {
                        for(i = 0; i < inWidth; i++) {
                            outBuf->re     = *prIC++;
                            (outBuf++)->im = *piIC++;
                        }
                    } else {
                        for(i = 0; i < inWidth; i++) {
                            outBuf->re     = *prIC++;
                            (outBuf++)->im = 0.0;
                        }
                    }
                }
            }
        } /* if(isMultiTasking) */
    } /* if(isMultiRate) */
}


/* Update Output pointer buffer */
#define UpdateBufferPtr(dtype,BUF_PTR,Buf)          \
{                                                   \
    dtype *aBuf = (dtype *)ssGetDWork(S, BUFF_IDX); \
    if (Buf == aBuf + 2*inWidth) {                  \
        Buf = aBuf ;                                \
    }                                               \
    ssSetPWorkValue(S, BUF_PTR, Buf);               \
}


static void mdlOutputs(SimStruct *S, int_T tid)
{

    const boolean_T isMultiRate    = isBlockMultiRate(S,INPORT,OUTPORT);
    
    int32_T         *count      = (int32_T *)ssGetDWork(S, COUNT_IDX);
    const int_T      convfactor = (int_T) (mxGetPr(CONVFACTOR_ARG)[0]);

    const boolean_T  c0                = (boolean_T)(ssGetInputPortComplexSignal(S, INPORT) == COMPLEX_YES);
    const boolean_T  isInputFrameBased = (boolean_T)(mxGetPr(FRAME_ARG)[0] != 0.0);
    const int_T      inWidth           = ssGetInputPortWidth(S, INPORT);
    const int_T      outWidth          = ssGetOutputPortWidth(S, OUTPORT);
    const int_T      nChans            = (isInputFrameBased) ? (int_T)(mxGetPr(NCHANS_ARG)[0]) : inWidth;
    const int_T      SamplesPerOutputFrame = outWidth /nChans;

    int_T n;
    int32_T c = 0;

    if (!isMultiRate) {
        /* Single-Rate*/
        if (!c0) {
            /* Real input */
            real_T            *y   = ssGetOutputPortRealSignal(S, OUTPORT);
            InputRealPtrsType uptr = ssGetInputPortRealSignalPtrs(S,INPORT);

            for (n = 0; n < nChans; n++) {
                int_T i;
                c = *count; /* Reset counter for each channel */

                for (i=0; i<SamplesPerOutputFrame; i++) {
                    if (c++ == 0)   *y++ = **uptr++;
                    else            *y++ = 0.0;

                    if (c == convfactor) c = 0;
                }

            }
            *count = c; /* Update counter for next sample hit */

        } else {
            /* Complex input */
            creal_T        *y      = (creal_T *)ssGetOutputPortSignal(S, OUTPORT);
	        InputPtrsType  uptr    = ssGetInputPortSignalPtrs(S,INPORT);

            for (n = 0; n++ < nChans; ) {
                int_T i;
                c = *count; /* Reset counter for each channel */

                for (i=0; i<SamplesPerOutputFrame; i++) {
                    if (c++ == 0)   *y++ = *((creal_T *)(*uptr++));
                    else {            
                        y->re = 0.0;
                        (y++)->im = 0.0;
                    }

                    if (c == convfactor) c = 0;
                }
            }
            *count = c; /* Update counter for next sample hit */
        }
    } else {
        /* Multi-Rate */
        const boolean_T isMultiTasking = isModelMultiTasking(S);

        real_T          *y             = ssGetOutputPortRealSignal(S, OUTPORT);
        const int_T     OutportTid     = ssGetOutputPortSampleTimeIndex(S, OUTPORT);
        const int_T     InportTid      = ssGetInputPortSampleTimeIndex(S, INPORT);

        if (isMultiTasking) {
            /* Multi-Rate, Multi-Tasking */
            if (ssIsSampleHit(S, OutportTid, tid)) {
                int32_T  *inputIdx = (int32_T *)ssGetDWork(S, INPUT_IDX);
                int32_T   inCnt    = 0;

                if (!c0) {
                    /* Real */
                    real_T *outBuf  = (real_T *)ssGetPWorkValue(S, OUTBUF_PTR);

                    for (n = 0; n < nChans; n++) {
                        real_T *Buf = outBuf + n*SamplesPerOutputFrame;
                        int_T i;

                        c     = *count; /* Reset counter for each channel */
                        inCnt = *inputIdx; /* Reset input indexfor each channel */

                        for (i=0; i<SamplesPerOutputFrame; i++) {
                            if (c++ == 0) {
                                *y++ = Buf[inCnt++];
                            }
                            else            *y++ = 0.0;
                            if (c == convfactor) c = 0;
                        }

                    }
                    *count = c; /* Update counter for next sample hit */
                    
                    /* Update input index for next sample hit */
                    if (inCnt == SamplesPerOutputFrame) {
                        inCnt = 0;
                        outBuf += inWidth;
                    }
                    *inputIdx = inCnt;

                    UpdateBufferPtr(real_T,OUTBUF_PTR,outBuf)


                } else {
                    creal_T *y      = (creal_T *)ssGetOutputPortSignal(S, OUTPORT);
                    creal_T *outBuf = (creal_T *)ssGetPWorkValue(S, OUTBUF_PTR);

                    for (n = 0; n < nChans; n++) {
                        creal_T *Buf = outBuf + n*SamplesPerOutputFrame;
                        int_T i;

                        c = *count; /* Reset counter for each channel */
                        inCnt = *inputIdx;

                        for (i=0; i<SamplesPerOutputFrame; i++) {
                            if (c++ == 0) *y++ = Buf[inCnt++];
                            else {
                                y->re = 0.0;
                                (y++)->im = 0.0;
                            }
                            
                            if (c == convfactor)  c = 0;
                        }
                    }
                    /* Update counter for next sample hit */
                    *count = c;

                    if (inCnt == SamplesPerOutputFrame) {
                        inCnt = 0;
                        outBuf += inWidth;
                    }
                    *inputIdx = inCnt;

                    UpdateBufferPtr(creal_T,OUTBUF_PTR,outBuf)

                }
            } /* if(ssIsSampleHit(S, OutportTid, tid)) */

            if (ssIsSampleHit(S, InportTid, tid)) {
                if (!c0) {
                    /* Real input */
                    InputRealPtrsType  uptr    = ssGetInputPortRealSignalPtrs(S,INPORT);
                    real_T            *inBuf   = (real_T *)ssGetPWorkValue(S, INBUF_PTR);
                    int_T              i       = inWidth;

                    while (i-- > 0) {
                        *inBuf++ = **uptr++;
                    }

                    UpdateBufferPtr(real_T,INBUF_PTR,inBuf)

                } else {
                    /* Complex Input */
	                InputPtrsType  uptr    = ssGetInputPortSignalPtrs(S,INPORT);
                    creal_T       *inBuf   = (creal_T *)ssGetPWorkValue(S, INBUF_PTR);
                    const int_T    inWidth = ssGetInputPortWidth(S, INPORT);
                    int_T          i       = inWidth;

                    while (i-- > 0) {
                        *inBuf++ = *((creal_T *)(*uptr++));
                    }

                    UpdateBufferPtr(creal_T,INBUF_PTR,inBuf)
                }
            }

        } else {
            /* Multi-Rate, Single-Tasking */
                
            if (ssIsSampleHit(S, OutportTid, tid)) {
                int32_T           *inputIdx = (int32_T *)ssGetDWork(S, INPUT_IDX);
                int32_T            inCnt = 0;

                if (!c0) {
                    /* Real Inputs */
                    real_T          *y          = ssGetOutputPortRealSignal(S, OUTPORT);
                    InputRealPtrsType  uptr     = ssGetInputPortRealSignalPtrs(S,INPORT);


                    for (n = 0; n < nChans; n++) {
                        int_T i;
                        int_T currentChannel = n*SamplesPerOutputFrame;

                        c     = *count;       /* Reset counter for each channel */
                        inCnt = *inputIdx;

                        for (i=0; i<SamplesPerOutputFrame; i++) {
                            if (c++ == 0) *y++ = *uptr[currentChannel + inCnt++];
                            else          *y++ = 0.0;
                            if (c == convfactor) c = 0;
                        }

                    }
                    *count = c;        /* Update counter for next sample hit */

                    if (inCnt >= SamplesPerOutputFrame) inCnt = 0;

                    *inputIdx = inCnt;

                } else {
                    /* Complex input */
                    creal_T       *y   = (creal_T *)ssGetOutputPortSignal(S, OUTPORT);
	                InputPtrsType uptr = ssGetInputPortSignalPtrs(S,INPORT);

                    for (n = 0; n < nChans; n++) {
                        int_T i;
                        int_T currentChannel = n*SamplesPerOutputFrame;

                        c     = *count;       /* Reset counter for each channel */
                        inCnt = *inputIdx;

                        for (i=0; i<SamplesPerOutputFrame; i++) {
                            if (c++ == 0) *y++ = *((creal_T *)(uptr[currentChannel + inCnt++]));
                            else {
                                y->re = 0.0;
                                (y++)->im = 0.0;
                            }
                            if (c == convfactor) c = 0;
                        }
                    }
                    *count = c;        /* Update counter for next sample hit */

                    if (inCnt >= SamplesPerOutputFrame) inCnt = 0;

                    *inputIdx = inCnt;
                }
            } /* if(ssIsSampleHit(S, OutportTid, tid)) */
        }
    }
}


static void mdlTerminate(SimStruct *S)
{
}



#if defined(MATLAB_MEX_FILE)
#define MDL_SET_WORK_WIDTHS
static void mdlSetWorkWidths(SimStruct *S)
{
    const boolean_T isMultiRate    = isBlockMultiRate(S,INPORT,OUTPORT);
    const boolean_T isMultiTasking = isModelMultiTasking(S);

    const int_T     inWidth = ssGetInputPortWidth(S, INPORT);
    const boolean_T cplx    = (boolean_T)(ssGetInputPortComplexSignal(S, INPORT) == COMPLEX_YES);

    if (isMultiRate) {
        if (isMultiTasking) { if (!ssSetNumDWork(S, NUM_DWORKS))   return;  /* 3 DWorks */
        } else {              if (!ssSetNumDWork(S, NUM_DWORKS-1)) return;  /* 2 DWorks */
        }
    } else {                  if (!ssSetNumDWork(S, NUM_DWORKS-2)) return;  /* 1 DWork  */
    }

    ssSetDWorkWidth(        S, COUNT_IDX, 1);
    ssSetDWorkDataType(     S, COUNT_IDX, SS_INT32);
    ssSetDWorkComplexSignal(S, COUNT_IDX, COMPLEX_NO);
    ssSetDWorkName(         S, COUNT_IDX, "Count");
    ssSetDWorkUsedAsDState( S, COUNT_IDX, 0);

    if (isMultiRate) {
        ssSetDWorkWidth(        S, INPUT_IDX, 1);
        ssSetDWorkDataType(     S, INPUT_IDX, SS_INT32);
        ssSetDWorkComplexSignal(S, INPUT_IDX, COMPLEX_NO);
        ssSetDWorkName(         S, INPUT_IDX, "InputIdx");
        ssSetDWorkUsedAsDState( S, INPUT_IDX, 0);    

        if (isMultiTasking) {
            ssSetDWorkWidth(        S, BUFF_IDX, 2*inWidth);
            ssSetDWorkDataType(     S, BUFF_IDX, SS_DOUBLE);
            ssSetDWorkComplexSignal(S, BUFF_IDX, cplx ? COMPLEX_YES : COMPLEX_NO);
            ssSetDWorkName(         S, BUFF_IDX, "Buffer");
            ssSetDWorkUsedAsDState( S, BUFF_IDX, 1);    
        }
    }

    /* IC checking */
    {
        const int_T numIC = mxGetNumberOfElements(IC_ARG);

        if ((numIC != 0) && (numIC != 1)
            && (numIC != inWidth)) {
                THROW_ERROR(S, "Initial condition vector has incorrect dimensions");
        }

        if (!cplx && mxIsComplex(IC_ARG)) {
	        THROW_ERROR(S, "Complex initial conditions are not allowed with real inputs.");
        }
    }

}

# define MDL_SET_INPUT_PORT_WIDTH
static void mdlSetInputPortWidth(SimStruct *S, int_T port,
                                 int_T inputPortWidth)
{
    const boolean_T isInputFrameBased = (boolean_T)(mxGetPr(FRAME_ARG)[0] != 0.0);
    const FcnType ftype      = (FcnType)((int_T)mxGetPr(OUTMODE_ARG)[0]);
    const int_T   convfactor = (int_T) (mxGetPr(CONVFACTOR_ARG)[0]);
    const int_T   outWidth   = ((isInputFrameBased) && (ftype == fcnEqualRates)) ? inputPortWidth*convfactor 
                                                                                 : inputPortWidth;

    ssSetInputPortWidth(S, port, inputPortWidth);
    ssSetOutputPortWidth(S, OUTPORT, outWidth);   
}

# define MDL_SET_OUTPUT_PORT_WIDTH
static void mdlSetOutputPortWidth(SimStruct *S, int_T port,
                                  int_T outputPortWidth)
{
    const boolean_T isInputFrameBased = (boolean_T)(mxGetPr(FRAME_ARG)[0] != 0.0);
    const FcnType   ftype      = (FcnType)((int_T)mxGetPr(OUTMODE_ARG)[0]);
    const int_T     convfactor = (int_T) (mxGetPr(CONVFACTOR_ARG)[0]);
          int_T     inWidth    = ((isInputFrameBased) && (ftype == fcnEqualRates)) ? outputPortWidth/convfactor 
                                                                                   : outputPortWidth;

    if(inWidth < 1) {
        ssSetErrorStatus(S, "Output port width cannot be smaller than the conversion factor "
                    "when the mode is set to equal rates.");
        inWidth = 1;   /* Default to width one in order to avoid simulink seg fault. */
    }
    ssSetOutputPortWidth(S, port, outputPortWidth);   
    ssSetInputPortWidth(S, INPORT, inWidth);   
}
#endif


#define MDL_RTW
#if defined(MATLAB_MEX_FILE) || defined(NRT)
static void mdlRTW(SimStruct *S)
{
    /* If the IC parameter is an empty matrix we'll assign it to be zero,
     * so that ssWriteRTWParamSettings will not error out.  Setting IC to
     * zero when it is specified as an empty matrix is consistent with the
     * functionality of the rebuffer block.
     */
    int_T   numIC       = 1; 
    real_T  zero        = 0;
    real_T  *IC_re      = &zero;
    real_T  *IC_im      = NULL;
    int32_T icRows      = (int32_T)mxGetM(IC_ARG);
    int32_T icCols      = (int32_T)mxGetN(IC_ARG);
    int32_T convfactor  = (int32_T)mxGetPr(CONVFACTOR_ARG)[0];
    int32_T phase       = (int32_T)mxGetPr(PHASE_ARG)[0];
    int32_T outmode     = (int32_T)mxGetPr(OUTMODE_ARG)[0];
    int32_T frame       = (int32_T)mxGetPr(FRAME_ARG)[0];
    int32_T nChans      = (int32_T)mxGetPr(NCHANS_ARG)[0];

	/* Write out the PWork record to the RTW file. */ 
	if(!ssWriteRTWWorkVect(S, "PWork", 2, "pOutBuf", 1, "pInBuf", 1 )) { 
		return;   
	} 

	if(!mxIsEmpty(IC_ARG)) {
        numIC = mxGetNumberOfElements(IC_ARG);
        IC_re = mxGetPr(IC_ARG);
        IC_im = mxGetPi(IC_ARG);
    }
    
    if (!ssWriteRTWParamSettings(S, 8,
                                 SSWRITE_VALUE_DTYPE_ML_VECT, "IC", IC_re, 
                                 IC_im, numIC, 
                                 DTINFO(SS_DOUBLE, mxIsComplex(IC_ARG)),

                                 SSWRITE_VALUE_DTYPE_NUM,  "IC_ROWS",
                                 &icRows,
                                 DTINFO(SS_INT32,0),

                                 SSWRITE_VALUE_DTYPE_NUM,  "IC_COLS",
                                 &icCols,
                                 DTINFO(SS_INT32,0),

                                 SSWRITE_VALUE_DTYPE_NUM,  "CONVFACTOR",
                                 &convfactor,
                                 DTINFO(SS_INT32,0),

                                 SSWRITE_VALUE_DTYPE_NUM,  "PHASE",
                                 &phase,
                                 DTINFO(SS_INT32,0),

                                 SSWRITE_VALUE_DTYPE_NUM,  "OUTMODE",
                                 &outmode,
                                 DTINFO(SS_INT32,0),
                                 
                                 SSWRITE_VALUE_DTYPE_NUM,  "FRAME",
                                 &frame,
                                 DTINFO(SS_INT32,0),

                                 SSWRITE_VALUE_DTYPE_NUM,  "NCHANS",
                                 &nChans,
                                 DTINFO(SS_INT32,0))) {
        return;
    }
}
#endif


#include "dsp_cplxhs11.c"


#ifdef	MATLAB_MEX_FILE
#include "simulink.c"
#else
#include "cg_sfun.h"
#endif

