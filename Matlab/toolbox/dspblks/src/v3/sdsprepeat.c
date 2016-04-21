/*
 * SDSPREPEAT  Repeat input samples N times. 
 *  Copyright 1995-2002 The MathWorks, Inc.
 *  $Revision: 1.19 $  $Date: 2002/04/14 20:41:54 $
 */
#define S_FUNCTION_NAME sdsprepeat
#define S_FUNCTION_LEVEL 2

#include "dsp_sim.h"

enum {COUNT_IDX=0, ITER_IDX, BUFF_IDX, SWAP_BUFF, NUM_DWORKS};
enum {INBUF_PTR, NUM_PWORKS};

enum {INPORT=0, NUM_INPORTS};
enum {OUTPORT=0, NUM_OUTPORTS};

enum {REPEAT_ARGC=0, IC_ARGC, FRAME_ARGC, NCHANS_ARGC, OUTMODE_ARGC, NUM_ARGS};

#define REPEAT_ARG  ssGetSFcnParam(S, REPEAT_ARGC)
#define IC_ARG      ssGetSFcnParam(S, IC_ARGC)
#define FRAME_ARG   ssGetSFcnParam(S, FRAME_ARGC)
#define NCHANS_ARG  ssGetSFcnParam(S, NCHANS_ARGC)
#define OUTMODE_ARG ssGetSFcnParam(S, OUTMODE_ARGC)

typedef enum {
    fcnEqualSizes = 1,
    fcnEqualRates
} FcnType;


#ifdef MATLAB_MEX_FILE
#define MDL_CHECK_PARAMETERS
static void mdlCheckParameters(SimStruct *S) {

    /* Repeat count */
    if OK_TO_CHECK_VAR(S, REPEAT_ARG) { 
        if (!IS_FLINT_GE(REPEAT_ARG,1)) {
            THROW_ERROR(S, "Repeat count must be a real, scalar integer > 0.");
        }
    }

    /* Initial conditions: */
    if OK_TO_CHECK_VAR(S, IC_ARG) { 
        if (!IS_VALID_IC(IC_ARG)) {
            THROW_ERROR(S, "Initial conditions must be numeric.");
        }
    }

    /* Frame */
    if (!IS_FLINT_IN_RANGE(FRAME_ARG, 0, 1)) {
        THROW_ERROR(S, "Frame can be only 0 (non-frame based) or 1 (frame-based).");
    }

    /* Number of channels */
    if OK_TO_CHECK_VAR(S, NCHANS_ARG) { 
        /* Check only if frame-based */
        if (mxGetPr(FRAME_ARG)[0] == 1.0) { 
            if (!IS_FLINT_GE(NCHANS_ARG, 1)) {
                THROW_ERROR(S, "Number of channels must be a real, scalar integer > 0.");
            }
        }
    }

    /* Function Mode */
    if (!IS_FLINT_IN_RANGE(OUTMODE_ARG, 1,2)) {
        THROW_ERROR(S, "Output mode must be maintain frame size (1) or frame rate (2).");
    }
}
#endif


static void mdlInitializeSizes(SimStruct *S)
{
    int_T numIC;

    ssSetNumSFcnParams(S, NUM_ARGS);
#if defined(MATLAB_MEX_FILE)
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) return;
    mdlCheckParameters(S);
    if (ssGetErrorStatus(S) != NULL) return;
#endif

    numIC = (int_T)mxGetNumberOfElements(IC_ARG);

    ssSetSFcnParamNotTunable(S, REPEAT_ARGC);
    if (numIC <= 1) ssSetSFcnParamNotTunable(S, IC_ARGC);
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
    ssSetOutputPortReusable(     S, OUTPORT, 1);

    if (!ssSetNumDWork(S, DYNAMICALLY_SIZED)) return;
    ssSetNumPWork(S, DYNAMICALLY_SIZED);

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
    if (sampleTime == CONTINUOUS_SAMPLE_TIME) {
        THROW_ERROR(S, "Continuous sample times not allowed.");
    }  

    if (offsetTime != 0.0) {
        THROW_ERROR(S, "Non-zero sample time offsets not allowed.");
    }
    ssSetInputPortSampleTime(S, INPORT, sampleTime);
    ssSetInputPortOffsetTime(S, INPORT, 0.0);

    {
        const int_T     N                 = (int_T) (mxGetPr(REPEAT_ARG)[0]);
        const FcnType   ftype             = (FcnType)((int_T)mxGetPr(OUTMODE_ARG)[0]);
        const boolean_T isInputFrameBased = (boolean_T)(mxGetPr(FRAME_ARG)[0] != 0.0);
        const real_T    Tso               = ((isInputFrameBased) && (ftype == fcnEqualRates)) ? sampleTime 
                                                                                              : sampleTime/N;
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
    if (sampleTime == CONTINUOUS_SAMPLE_TIME) {
        THROW_ERROR(S, "Continuous sample times not allowed.");
    }

    if (offsetTime != 0.0) {
        THROW_ERROR(S, "Non-zero sample time offsets not allowed.");
    }
    ssSetOutputPortSampleTime(S, OUTPORT, sampleTime);
    ssSetOutputPortOffsetTime(S, OUTPORT, 0.0);

    {
        const int_T     N                 = (int_T) (mxGetPr(REPEAT_ARG)[0]);
        const FcnType   ftype             = (FcnType)((int_T)mxGetPr(OUTMODE_ARG)[0]);
        const boolean_T isInputFrameBased = (boolean_T)(mxGetPr(FRAME_ARG)[0] != 0.0);
        const real_T    Tsi               = ((isInputFrameBased) && (ftype == fcnEqualRates)) ? sampleTime
                                                                                              : sampleTime*N;
        ssSetInputPortSampleTime(S, INPORT, Tsi);
    }
    ssSetInputPortOffsetTime(S, INPORT, 0.0);
}
#endif


static void mdlInitializeSampleTimes(SimStruct *S)
{
#if 0
    /* Check port sample times: */
    const real_T Tsi = ssGetInputPortSampleTime( S, INPORT);
    const real_T Tso = ssGetOutputPortSampleTime(S, OUTPORT);

    if ((Tsi == INHERITED_SAMPLE_TIME) || (Tso == INHERITED_SAMPLE_TIME)) {
        THROW_ERROR(S, "Sample time propagation failed for repeat block.");
    }
#endif
}


#define MDL_START
static void mdlStart(SimStruct *S)
{
#ifdef MATLAB_MEX_FILE
    const boolean_T frame   = (boolean_T)(mxGetPr(FRAME_ARG)[0] != 0.0);
    const int_T     nchans  = (int_T)(mxGetPr(NCHANS_ARG)[0]);
    const int_T     width   = ssGetInputPortWidth(S, INPORT);

    if (frame && (width % nchans != 0)) {
        THROW_ERROR(S, "Size of input matrix does not match number of channels");
    }
#endif
}


#define MDL_INITIALIZE_CONDITIONS
static void mdlInitializeConditions(SimStruct *S)
{
    const boolean_T isMultiRate    = isBlockMultiRate(S,INPORT,OUTPORT);
    const boolean_T isMultiTasking = isModelMultiTasking(S);    

    /* Reset counters */
    *((int32_T *)ssGetDWork(S, COUNT_IDX)) = 0;
    *((int32_T *)ssGetDWork(S, ITER_IDX)) = 0;
    
    if (isMultiRate && isMultiTasking) {

        const boolean_T isInputCmplx  = (boolean_T)(ssGetInputPortComplexSignal(S, INPORT) == COMPLEX_YES);
        const int_T     numIC         = mxGetNumberOfElements(IC_ARG);
        const int_T     inWidth       = ssGetInputPortWidth(S, INPORT);
        int_T           i;

        /* Reset counter - only needed in multi-rate, multi-tasking case */
        *((boolean_T *)ssGetDWork(S, SWAP_BUFF)) = false;

        /* Fill top buffer with initial conditions: */
        if (!isInputCmplx) {
            /* Real */
            real_T *outBuf = (real_T *)ssGetDWork(S, BUFF_IDX);
            real_T *pIC    = mxGetPr(IC_ARG);

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
    }
}


static void mdlOutputs(SimStruct *S, int_T tid)
{
    const int_T     OutportTid     = ssGetOutputPortSampleTimeIndex(S, OUTPORT);
    const boolean_T isMultiRate    = isBlockMultiRate(S,INPORT,OUTPORT);
    const boolean_T isMultiTasking = isModelMultiTasking(S);

    if (ssIsSampleHit(S, OutportTid, tid)) {
        const boolean_T  isInputCmplx          = (boolean_T)(ssGetInputPortComplexSignal(S, INPORT) == COMPLEX_YES);
        const int_T      inWidth               = ssGetInputPortWidth(S, INPORT);
        const int_T      outWidth              = ssGetOutputPortWidth(S, OUTPORT);
        const boolean_T  isInputFrameBased     = (boolean_T)(mxGetPr(FRAME_ARG)[0] != 0.0);
        const int_T      nChans                = (isInputFrameBased) ? (int_T)(mxGetPr(NCHANS_ARG)[0]) : inWidth;
        const int_T      SamplesPerInputFrame  = inWidth / nChans;
        const int_T      SamplesPerOutputFrame = outWidth / nChans;
        const int_T      N                     = (int_T) (mxGetPr(REPEAT_ARG)[0]);
        int32_T         *count                 = (int32_T *)ssGetDWork(S, COUNT_IDX);
        int32_T         *iter                  = (int32_T *)ssGetDWork(S, ITER_IDX);
        int_T            n,Input_repeat_cnt,Iteration_cnt; 

        /* "Input_repeat_cnt" keeps track how many times an input element has been repeated
         * "Iteration_cnt" keeps track how many elements in the current buffer have been 
         *      repeated N times. When each element has been repeated N times, 
         *      then set the flag to swap buffers. 
         * "swapBuff" keeps track on when to swap buffers.
         */
        if ( !(isMultiTasking && isMultiRate) ) {
            if (!isInputCmplx) {
                InputRealPtrsType uptr = ssGetInputPortRealSignalPtrs(S, OUTPORT);
                real_T           *y    = ssGetOutputPortRealSignal(S, OUTPORT);
                for (n = 0; n < nChans; n++) {
                    int_T k;
                
                    if (n != 0) {
                        uptr += SamplesPerInputFrame; 
                    }
                    /* Reset counters for each channel */
                    Iteration_cnt = *iter; 
                    Input_repeat_cnt = *count; 

                    for (k=0; k++ < SamplesPerOutputFrame; ) {
                        *y++ = *(*uptr + Iteration_cnt); 

                        if (++Input_repeat_cnt == N) {          /* increments Input_repeat_cnt if doesn't equal N */
                            Input_repeat_cnt = 0;
                            if (++Iteration_cnt == SamplesPerInputFrame) {
                                Iteration_cnt = 0;
                            }
                        }
                    }
                }
            } else {
                creal_T      *y    = (creal_T *)ssGetOutputPortSignal(S, OUTPORT);
                InputPtrsType uptr = ssGetInputPortSignalPtrs(S, OUTPORT);

                for (n = 0; n < nChans; n++) {
                    /* Point to next channel: */
                    int_T k;
                
                    if (n != 0) {
                        uptr += SamplesPerInputFrame; 
                    }

                    /* Reset counters for each channel */
                    Iteration_cnt = *iter; 
                    Input_repeat_cnt = *count; 

                    for (k=0; k++ < SamplesPerOutputFrame; ) {
                        *y++ = *((creal_T *)*uptr + Iteration_cnt);

                        if (++Input_repeat_cnt == N){
                            Input_repeat_cnt = 0;
                            if (++Iteration_cnt == SamplesPerInputFrame) {
                                Iteration_cnt = 0;
                            }
                        }
                    }
                }
            }
            /* Update counters */
            *iter = Iteration_cnt;
            *count = Input_repeat_cnt;

        } else {
            /* Multi-rate,Multi-Tasking */
            int32_T   *iter        = (int32_T *)ssGetDWork(S, ITER_IDX);
            boolean_T *swapBuffers = (boolean_T *)ssGetDWork(S, SWAP_BUFF);
            boolean_T  swapBuff    = false;     /* Initialize local flag for swapping buffers */
            int_T      Iteration_cnt;

            if (!isInputCmplx) {
                real_T *y      = ssGetOutputPortRealSignal(S, OUTPORT);
                real_T *outBuf = (real_T *)ssGetDWork(S, BUFF_IDX);
            
                if (*swapBuffers) {
                    /* Point to bottom buffer */
                    outBuf += inWidth;
                }

                for (n = 0; n < nChans; n++) {
                    /* Point to next channel: */
                    real_T *out = outBuf + n*SamplesPerInputFrame; 
                    int_T k;

                    /* Reset counters for each channel */
                    Iteration_cnt = *iter;  
                    Input_repeat_cnt = *count; 

                    for (k=0; k++ < SamplesPerOutputFrame; ) {
                        *y++ = *(out + Iteration_cnt);

                        if (++Input_repeat_cnt == N){
                            Input_repeat_cnt = 0;
                            if (++Iteration_cnt == SamplesPerInputFrame) {
                                Iteration_cnt = 0;
                                swapBuff = true;
                            }
                        }
                    }
                }

            } else {
                creal_T *y      = (creal_T *)ssGetOutputPortSignal(S, OUTPORT);
                creal_T *outBuf = (creal_T *)ssGetDWork(S, BUFF_IDX);
            
                if (*swapBuffers) {
                    /* Point to bottom buffer */
                    outBuf += inWidth;
                }

                for (n = 0; n < nChans; n++) {
                    /* Point to next channel: */
                    creal_T *out = outBuf + n*SamplesPerInputFrame; 
                    int_T k;

                    /* Reset counters for each channel */
                    Iteration_cnt = *iter;  
                    Input_repeat_cnt = *count; 

                    for (k=0; k++ < SamplesPerOutputFrame; ) {
                        *y++ = *(out + Iteration_cnt);

                        if (++Input_repeat_cnt == N){
                            Input_repeat_cnt = 0;
                            if (++Iteration_cnt == SamplesPerInputFrame) {
                                Iteration_cnt = 0;
                                swapBuff = true;
                            }
                        }
                    }
                }
            }
            /* Update counters */
            *iter = Iteration_cnt;
            *count = Input_repeat_cnt;

            if (swapBuff) {
                *swapBuffers = (boolean_T)!(*swapBuffers);
            }
        }
    }

    /*
     * Only needed for Multi-rate & Multi-tasking
     */
    if (isMultiRate && isMultiTasking) {
        const int_T InportTid = ssGetInputPortSampleTimeIndex(S, INPORT);
        if (ssIsSampleHit(S, InportTid, tid)) {
            const boolean_T isInputCmplx = (boolean_T)(ssGetInputPortComplexSignal(S, INPORT) == COMPLEX_YES);

            if (!isInputCmplx) {
                /* Real */
                InputRealPtrsType  uptr  = ssGetInputPortRealSignalPtrs(S,INPORT);
                const int_T        width = ssGetInputPortWidth(S,INPORT);
                real_T            *inBuf = (real_T *)ssGetPWorkValue(S, INBUF_PTR);
                int_T              i     = width;

                while (i-- > 0) {
                    *inBuf++ = **uptr++;
                }
                {
                    real_T *aBuf = (real_T *)ssGetDWork(S, BUFF_IDX);
                    if (inBuf == aBuf + 2*width) {
                        inBuf = aBuf;
                    }
                    ssSetPWorkValue(S, INBUF_PTR, inBuf);
                }

            } else {
                /* Complex */
	        InputPtrsType  uptr  = ssGetInputPortSignalPtrs(S,INPORT);
                int_T          width = ssGetInputPortWidth(S,INPORT);
                creal_T       *inBuf = (creal_T *)ssGetPWorkValue(S, INBUF_PTR);
                int_T          i     = width;

                while (i-- > 0) {
                    *inBuf++ = *((creal_T *)(*uptr++));
                }
                {
                    creal_T *aBuf = (creal_T *)ssGetDWork(S, BUFF_IDX);
                    if (inBuf == aBuf + 2*width) {
                        inBuf = aBuf;
                    }
                    ssSetPWorkValue(S, INBUF_PTR, inBuf);
                }
            }
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
    const int_T     inWidth        = ssGetInputPortWidth(S, INPORT);
    const CSignal_T cplx           = ssGetInputPortComplexSignal(S, INPORT);
    const boolean_T isMultiRate    = isBlockMultiRate(S,INPORT,OUTPORT);
    const boolean_T isMultiTasking = isModelMultiTasking(S);  
    const boolean_T isMultiMulti   = isMultiRate && isMultiTasking;

    /* Only need 4 buffers if in Multi-rate, Multi-tasking mode */
    ssSetNumDWork(S, isMultiMulti ? NUM_DWORKS : NUM_DWORKS-2);

    /* Track number of times each element is repeated */
    ssSetDWorkWidth(        S, COUNT_IDX, 1);
    ssSetDWorkDataType(     S, COUNT_IDX, SS_INT32);
    ssSetDWorkComplexSignal(S, COUNT_IDX, COMPLEX_NO);
    ssSetDWorkName(         S, COUNT_IDX, "REPEAT_CNT");
    /* ssSetDWorkUsedAsDState( S, COUNT_IDX, 1); */

    /* Track number of elements in input that have been visited */
    ssSetDWorkWidth(        S, ITER_IDX, 1);
    ssSetDWorkDataType(     S, ITER_IDX, SS_INT32);
    ssSetDWorkComplexSignal(S, ITER_IDX, COMPLEX_NO);
    ssSetDWorkName(         S, ITER_IDX, "ITERATION_CNT");
    /* ssSetDWorkUsedAsDState( S, ITER_IDX, 1); */

    if (isMultiMulti) {

        ssSetNumPWork(S, NUM_PWORKS);
        
        /* Track when to swap buffers */
        ssSetDWorkWidth(        S, SWAP_BUFF, 1);
        ssSetDWorkDataType(     S, SWAP_BUFF, SS_BOOLEAN);
        ssSetDWorkComplexSignal(S, SWAP_BUFF, COMPLEX_NO);
        ssSetDWorkName(         S, SWAP_BUFF, "SwapBuff");
        ssSetDWorkUsedAsDState( S, SWAP_BUFF, 1);

        /* Create 2 buffers- one used to read data from and the other
         * to write data two. The buffers are stacked on top of each other
         */
        ssSetDWorkWidth(        S, BUFF_IDX, 2*inWidth);
        ssSetDWorkDataType(     S, BUFF_IDX, SS_DOUBLE);
        ssSetDWorkComplexSignal(S, BUFF_IDX, cplx);
        ssSetDWorkName(         S, BUFF_IDX, "Buffer");
        ssSetDWorkUsedAsDState( S, BUFF_IDX, 1);
    }
    
    {
        const int_T numIC = mxGetNumberOfElements(IC_ARG);

        if ((numIC != 0) && (numIC != 1) && (numIC != inWidth)) {
            THROW_ERROR(S, "Initial condition vector has incorrect dimensions.");
        }

        if ((cplx == COMPLEX_NO) && mxIsComplex(IC_ARG)) {
	    THROW_ERROR(S, "Complex initial conditions are not allowed with real inputs.");
        }
    }
}

# define MDL_SET_INPUT_PORT_WIDTH
static void mdlSetInputPortWidth(SimStruct *S, int_T port,
                                 int_T inputPortWidth)
{
    const FcnType   ftype             = (FcnType)((int_T)mxGetPr(OUTMODE_ARG)[0]);
    const boolean_T isInputFrameBased = (boolean_T)(mxGetPr(FRAME_ARG)[0] != 0.0);
    const int_T     N                 = (int_T) (mxGetPr(REPEAT_ARG)[0]);
    const int_T     outWidth          = ((isInputFrameBased) && (ftype == fcnEqualRates)) ? inputPortWidth*N
                                                                                          : inputPortWidth;
    
    ssSetInputPortWidth(S, port, inputPortWidth);
    ssSetOutputPortWidth(S, OUTPORT, outWidth);   
}

# define MDL_SET_OUTPUT_PORT_WIDTH
static void mdlSetOutputPortWidth(SimStruct *S, int_T port,
                                  int_T outputPortWidth)
{
    const FcnType   ftype             = (FcnType)((int_T)mxGetPr(OUTMODE_ARG)[0]);
    const boolean_T isInputFrameBased = (boolean_T)(mxGetPr(FRAME_ARG)[0] != 0.0);
    const int_T     N                 = (int_T) (mxGetPr(REPEAT_ARG)[0]);
          int_T     inWidth           = ((isInputFrameBased) && (ftype == fcnEqualRates)) ? outputPortWidth/N 
                                                                                          : outputPortWidth;
    if(inWidth < 1) {
        ssSetErrorStatus(S, "Output port width cannot be smaller than the repeat factor "
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
    int_T   numIC   = (mxIsEmpty(IC_ARG)) ? 1 : mxGetNumberOfElements(IC_ARG); 
    real_T  zero    = 0;
    real_T  *IC_re  = &zero;
    real_T  *IC_im  = NULL;
    int32_T icRows  = (int32_T)mxGetM(IC_ARG);
    int32_T icCols  = (int32_T)mxGetN(IC_ARG);
    int32_T repeat  = (int32_T)mxGetPr(REPEAT_ARG)[0];
    int32_T outmode = (int32_T)mxGetPr(OUTMODE_ARG)[0];
    int32_T frame   = (int32_T)mxGetPr(FRAME_ARG)[0];
    int32_T nChans  = (int32_T)mxGetPr(NCHANS_ARG)[0];
    
    const boolean_T isMultiRate    = isBlockMultiRate(S,INPORT,OUTPORT);
    const boolean_T isMultiTasking = isModelMultiTasking(S);  
    const boolean_T isMultiMulti   = (isMultiRate && isMultiTasking);
    /* empty and scalar ICs are not tunable */
    char *ICIsTuneStr = (numIC == 1) ? "No" : "Yes";

    if(!mxIsEmpty(IC_ARG)) {
        IC_re = mxGetPr(IC_ARG);
        IC_im = mxGetPi(IC_ARG);
    }
    
    if (isMultiMulti) {
        if (!ssWriteRTWWorkVect(S, "PWork", 1,
            "InBuf", 1
            )) {
            return;
        }
    }

    if (numIC == 1) {
        /* Non-tunable parameters */
        /* Everything is non-tunable */
        if (!ssWriteRTWParamSettings(S, 8,
                                 SSWRITE_VALUE_DTYPE_ML_VECT, "IC", IC_re, 
                                 IC_im, numIC, 
                                 DTINFO(SS_DOUBLE, mxIsComplex(IC_ARG)),

                                 SSWRITE_VALUE_QSTR, "ICIsTune", ICIsTuneStr,

                                 SSWRITE_VALUE_DTYPE_NUM,  "IC_ROWS",
                                 &icRows,
                                 DTINFO(SS_INT32,0),

                                 SSWRITE_VALUE_DTYPE_NUM,  "IC_COLS",
                                 &icCols,
                                 DTINFO(SS_INT32,0),

                                 SSWRITE_VALUE_DTYPE_NUM,  "REPEAT",
                                 &repeat,
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
    } else {
        /* Only ICs are tunable */
        if (!ssWriteRTWParamSettings(S, 7,

                                 SSWRITE_VALUE_QSTR, "ICIsTune", ICIsTuneStr,

                                 SSWRITE_VALUE_DTYPE_NUM,  "IC_ROWS",
                                 &icRows,
                                 DTINFO(SS_INT32,0),

                                 SSWRITE_VALUE_DTYPE_NUM,  "IC_COLS",
                                 &icCols,
                                 DTINFO(SS_INT32,0),

                                 SSWRITE_VALUE_DTYPE_NUM,  "REPEAT",
                                 &repeat,
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
        if (!ssWriteRTWParameters(S,1,
            SSWRITE_VALUE_DTYPE_ML_VECT, "IC", "", 
                                 IC_re, IC_im,
                                 numIC,
                                 DTINFO(SS_DOUBLE, mxIsComplex(IC_ARG))
           )) {
           return; 
        }
    }
}
#endif


#include "dsp_cplxhs11.c"

#ifdef	MATLAB_MEX_FILE
#include "simulink.c"
#else
#include "cg_sfun.h"
#endif

/* [EOF] sdsprepeat.c */
