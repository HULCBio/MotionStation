/*
 * SDSPREBUFF DSP Blockset rebuffer block
 *
 *  Copyright 1995-2002 The MathWorks, Inc.
 *  $Revision: 1.29 $  $Date: 2002/04/14 20:42:03 $
 */
#define S_FUNCTION_NAME sdsprebuff
#define S_FUNCTION_LEVEL 2

#include "dsp_sim.h"

enum {INPORT=0, NUM_INPORTS};
enum {OUTPORT=0, NUM_OUTPORTS};

enum {SPECIFY_OUT_WIDTH_ARGC=0,
      OUT_WIDTH_ARGC, 
      LAP_ARGC, 
      IC_ARGC, 
      FRAME_ARGC, 
      NCHANS_ARGC, 
      NUM_ARGS};
#define SPECIFY_OUT_WIDTH_ARG   ssGetSFcnParam(S, SPECIFY_OUT_WIDTH_ARGC)
#define OUT_WIDTH_ARG           ssGetSFcnParam(S, OUT_WIDTH_ARGC)
#define LAP_ARG                 ssGetSFcnParam(S, LAP_ARGC)
#define IC_ARG                  ssGetSFcnParam(S, IC_ARGC)
#define FRAME_ARG               ssGetSFcnParam(S, FRAME_ARGC)
#define NCHANS_ARG              ssGetSFcnParam(S, NCHANS_ARGC)


/*
 * All the following #define's are in support of NEED_ICS macro:
 */
#define IS_BUFFERING_WITH_NONSCALAR_OUTPUT       ((F==1) && (N>1))
#define IS_REBUFFERING                           ((F != 1) && (N != 1))
#define IS_DIFFERING_FRAME_SIZES                 (F != N)
#define IS_FRAME_UNBUFF_NOLAP_INDIVISIBLE_FRAMES ((F > N) && (V == 0) && (F%N != 0))
#define IS_FRAME_BUFF_NOLAP                      ((F < N) && (V == 0))
#define IS_OVERLAP                               (V > 0)

#define NEED_ICS(isMultiTasking, isMultiRate, F,N,V)                            \
           (    isMultiTasking &&                                               \
                          (isMultiRate ||                                       \
                           IS_DIFFERING_FRAME_SIZES                             \
                           )                                                    \
                ||                                                              \
                !isMultiTasking &&                                              \
                          ( IS_BUFFERING_WITH_NONSCALAR_OUTPUT ||               \
                            IS_REBUFFERING &&                                   \
                                  ( IS_FRAME_UNBUFF_NOLAP_INDIVISIBLE_FRAMES || \
                                    IS_FRAME_BUFF_NOLAP ||                      \
                                    IS_OVERLAP                                  \
                                   )                                            \
                           )                                                    \
           )

enum {UL_COUNT_IDX=0, NUM_IWORKS};
enum {CIRCBUF_IDX=0, NUM_DWORKS};
enum {OUTBUF_PTR=0, INBUF_PTR, NUM_PWORKS};
enum {SAMPLE_BASED=0, FRAME_BASED};  


#ifdef MATLAB_MEX_FILE
#define MDL_CHECK_PARAMETERS
static void mdlCheckParameters(SimStruct *S) {

    /* Checkbox to specify output WIDTH */
    if (!IS_FLINT_IN_RANGE(SPECIFY_OUT_WIDTH_ARG, 0, 1)) {
        THROW_ERROR(S, "Specify output size parameter can be only 0 (inherited) or 1 (user-specified).");
    }

    /* Defer checking output buffer size until frame check box is checked */

    /* Buffer overlap */
    if (OK_TO_CHECK_VAR(S, LAP_ARG)) { 
        if (!IS_FLINT(LAP_ARG)) {
            THROW_ERROR(S, "The buffer overlap must be a real scalar.");
        }
    }

    /* Defer checking of V < N until sample times */
    
    /* Initial conditions */
    if (OK_TO_CHECK_VAR(S, IC_ARG)) { 
        if (!mxIsNumeric(IC_ARG) || mxIsSparse(IC_ARG)) {
            THROW_ERROR(S, "Initial conditions must be a real or complex double.");
        }
    }
    
    /* Frame */
    if (!IS_FLINT_IN_RANGE(FRAME_ARG, 0, 1)) {
        THROW_ERROR(S, "Frame can be only 0 (non-frame based) or 1 (frame-based).");
    }

    /* Output buffer size: */
    /* Only check the output width if it is specified. */
    /* If the width is specified and inputs are frame-based, the output buffer
     * size needs to be checked now because it's used in intializeSizes.
     * Otherwise, only check it if it's compile time (ok_to_check_var)
     */
    if ( (mxGetPr(SPECIFY_OUT_WIDTH_ARG)[0] == 1.0) && 
         ( ((mxGetPr(FRAME_ARG)[0] == 1.0)) || 
           (OK_TO_CHECK_VAR(S, OUT_WIDTH_ARG)) 
         ) 
       ) {
        if (!IS_FLINT_GE(OUT_WIDTH_ARG,1)) {
            THROW_ERROR(S, "The output buffer size must be a real scalar > 0.");
        }
    }
    
    /* Number of channels - only check if frame-based: */
    if ( (mxGetPr(FRAME_ARG)[0] == 1.0) && 
         ( (mxGetPr(SPECIFY_OUT_WIDTH_ARG)[0] == 1.0) || (OK_TO_CHECK_VAR(S, NCHANS_ARG)) 
         ) 
       ) {
        if (!IS_FLINT_GE(NCHANS_ARG, 1)) {
            THROW_ERROR(S, "Number of channels must be a real, scalar integer > 0.");
        }
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
    
    ssSetSFcnParamNotTunable(S, SPECIFY_OUT_WIDTH_ARGC);
    ssSetSFcnParamNotTunable(S, OUT_WIDTH_ARGC);
    ssSetSFcnParamNotTunable(S, LAP_ARGC);
    ssSetSFcnParamNotTunable(S, IC_ARGC);
    ssSetSFcnParamNotTunable(S, FRAME_ARGC);
    ssSetSFcnParamNotTunable(S, NCHANS_ARGC);

    ssSetNumSampleTimes(S, PORT_BASED_SAMPLE_TIMES);
    
    if (!ssSetNumInputPorts(S, NUM_INPORTS)) return;
    ssSetInputPortWidth(            S, INPORT, DYNAMICALLY_SIZED);
    ssSetInputPortComplexSignal(    S, INPORT, COMPLEX_INHERITED);
    ssSetInputPortSampleTime(       S, INPORT, INHERITED_SAMPLE_TIME);
    ssSetInputPortDirectFeedThrough(S, INPORT, 1);
    ssSetInputPortReusable(         S, INPORT, 0);
    ssSetInputPortOverWritable(     S, INPORT, 0);
    
    if (!ssSetNumOutputPorts(S, NUM_OUTPORTS)) return;
    { 
        int_T width =  DYNAMICALLY_SIZED;
        const boolean_T isFrame           = (boolean_T)(mxGetPr(FRAME_ARG)[0] != 0.0);
        const boolean_T isInheritOutWidth = (boolean_T)(mxGetPr(SPECIFY_OUT_WIDTH_ARG)[0] == 0.0);

        if (isFrame && !isInheritOutWidth) {
            const int_T     nChans            = (int_T)(mxGetPr(NCHANS_ARG)[0]);
            const int_T     N                 = (int_T)(mxGetPr(OUT_WIDTH_ARG)[0]);
            
            width = N*nChans;
        }
        /* For sample-based inputs: Set to dynamic width for all cases
         *    because even if the output width is specified, the number
         *    of channels are not known.
         *
         * For frame-based inputs: 
         *   If not specifying output width, set to dynamic.
         *   If output width is specified, then we can set it now.
         *      We know the samples per frame and the number of channels.
         *      Total output width = spf*nchans
         */

        ssSetOutputPortWidth(S, OUTPORT, width);
    }
    ssSetOutputPortComplexSignal(S, OUTPORT, COMPLEX_INHERITED);
    ssSetOutputPortSampleTime(   S, OUTPORT, INHERITED_SAMPLE_TIME);
    ssSetOutputPortReusable(     S, OUTPORT, 0);

    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE | 
                 SS_OPTION_NONSTANDARD_PORT_WIDTHS |
                 SS_OPTION_USE_TLC_WITH_ACCELERATOR);
    
    if(!ssSetNumDWork(S, DYNAMICALLY_SIZED)) return;
    if (OK_TO_CHECK_VAR(S, LAP_ARG)) {
        /* No IWORK if no underlap: */
        ssSetNumIWork(S, (mxGetPr(LAP_ARG)[0] < 0) ? 1 : 0);
    }
    ssSetNumPWork(S, DYNAMICALLY_SIZED);
}


#if defined(MATLAB_MEX_FILE)
#define MDL_SET_INPUT_PORT_SAMPLE_TIME
static void mdlSetInputPortSampleTime(SimStruct *S,
                                      int_T     portIdx,
                                      real_T    sampleTime,
                                      real_T    offsetTime)
{
    /* Check that V is valid before setting sample times */
    const int_T     inWidth  = ssGetInputPortWidth(S, INPORT);  
    const int_T     outWidth = ssGetOutputPortWidth(S, OUTPORT);  
    const boolean_T isFrame  = (boolean_T)(mxGetPr(FRAME_ARG)[0] != 0.0);
    const int_T     nChans   = (isFrame) ? (int_T)(mxGetPr(NCHANS_ARG)[0]): inWidth;
    const int_T     F        = inWidth/nChans;
    const int_T     N        = outWidth/nChans;
    const int_T     V        = (int_T)(mxGetPr(LAP_ARG)[0]);    

    if (V >= N) {
        THROW_ERROR(S, "The buffer overlap must be less than the buffer size.");
    }
    
    if (sampleTime == CONTINUOUS_SAMPLE_TIME) {
        THROW_ERROR(S, "Continuous sample times not allowed for rebuffer block.");
    }
    if (offsetTime != 0.0) {
        THROW_ERROR(S, "Non-zero sample time offsets not allowed for rebuffer block.");
    }

    ssSetInputPortSampleTime(S, INPORT, sampleTime);
    ssSetInputPortOffsetTime(S, INPORT, 0.0);
    
    if (ssGetOutputPortSampleTime(S,OUTPORT) == INHERITED_SAMPLE_TIME) {
        /* Tso = ((N-V)/F)* Tsi */
        ssSetOutputPortSampleTime(S, OUTPORT, (sampleTime*(N-V))/F);
        ssSetOutputPortOffsetTime(S, OUTPORT, 0.0);

    } else {
        THROW_ERROR(S, "Error setting output sample time.");
    }
}


#define MDL_SET_OUTPUT_PORT_SAMPLE_TIME
static void mdlSetOutputPortSampleTime(SimStruct *S,
                                       int_T     portIdx,
                                       real_T    sampleTime,
                                       real_T    offsetTime)
{
    /* Check that V is valid before setting sample times */
    const int_T     inWidth  = ssGetInputPortWidth(S, INPORT);  
    const int_T     outWidth = ssGetOutputPortWidth(S, OUTPORT);  
    const boolean_T isFrame  = (boolean_T)(mxGetPr(FRAME_ARG)[0] != 0.0);
    const int_T     nChans   = (isFrame) ? (int_T)(mxGetPr(NCHANS_ARG)[0]): inWidth;
    const int_T     F        = inWidth/nChans;
    const int_T     N        = outWidth/nChans;
    const int_T     V        = (int_T)(mxGetPr(LAP_ARG)[0]);    

    if (V >= N) {
        THROW_ERROR(S, "The buffer overlap must be less than the buffer size.");
    }

    if (sampleTime == CONTINUOUS_SAMPLE_TIME) {
        THROW_ERROR(S, "Continuous sample times not allowed for rebuffer block.");
    }
    if (offsetTime != 0.0) {
        THROW_ERROR(S, "Non-zero sample time offsets not allowed.");
    }
    ssSetOutputPortSampleTime(S, OUTPORT, sampleTime);
    ssSetOutputPortOffsetTime(S, OUTPORT, 0.0);
    

    if (ssGetInputPortSampleTime(S,INPORT) == INHERITED_SAMPLE_TIME) {
        /* Tsi = (Tso*F)/(N-V) */
        ssSetInputPortSampleTime(S, INPORT, (sampleTime*F)/(N-V));
        ssSetInputPortOffsetTime(S, INPORT, 0.0);

        /* Check in mdlInitializeSampleTimes that we've set a valid 
         * sample time */
    } else {
        THROW_ERROR(S, "Error setting input sample time.");
    }
}
#endif


static void mdlInitializeSampleTimes(SimStruct *S)
{
    /* Check port sample times: */
    const real_T Tsi = ssGetInputPortSampleTime(S, INPORT);     
    const real_T Tso = ssGetOutputPortSampleTime(S, OUTPORT);   
                                                                
    if ((Tsi == INHERITED_SAMPLE_TIME)  ||                      
        (Tso == INHERITED_SAMPLE_TIME)   ) {                    
        THROW_ERROR(S, "Sample time propagation failed.");        
    }                                                           
    if ((Tsi == CONTINUOUS_SAMPLE_TIME)  ||                         
        (Tso == CONTINUOUS_SAMPLE_TIME)   ) {                       
        THROW_ERROR(S, "Continuous sample times are not allowed.");   
    }                                                               
}


#define MDL_START
static void mdlStart(SimStruct *S)
{
#ifdef MATLAB_MEX_FILE
        const int_T     inWidth = ssGetInputPortWidth(S, INPORT);  
        const int_T     outWidth = ssGetOutputPortWidth(S, OUTPORT);  
        const boolean_T isFrame = (boolean_T)(mxGetPr(FRAME_ARG)[0] != 0.0);
        const int_T     nChans  = (isFrame) ? (int_T)(mxGetPr(NCHANS_ARG)[0]): inWidth;
        const int_T     F       = inWidth/nChans;   
        const int_T     N       = outWidth/nChans;
        const int_T     V       = (int_T)(mxGetPr(LAP_ARG)[0]);    
    
    /* Check underlap 
     * (i.e. you can only underlap when buffering scalar inputs)  
     */
    if ((V<0) && (N<F)) {
        THROW_ERROR(S, "Underlap is not supported when unbuffering.");
    }
    if ((V<0) && (F != 1)) {
        THROW_ERROR(S, "Underlap is not supported for frame-based inputs.");
    }

#endif
}


#define MDL_INITIALIZE_CONDITIONS
static void mdlInitializeConditions(SimStruct *S)
{
    const int_T     numIC   = mxGetNumberOfElements(IC_ARG);
    const int_T     inWidth = ssGetInputPortWidth(S, INPORT);  
    const int_T     outWidth = ssGetOutputPortWidth(S, OUTPORT);  
    const boolean_T isFrame = (boolean_T)(mxGetPr(FRAME_ARG)[0] != 0.0);
    const int_T     nChans  = (isFrame) ? (int_T)(mxGetPr(NCHANS_ARG)[0]): inWidth;
    const int_T     F       = inWidth/nChans;   
    const int_T     N       = outWidth/nChans;
    const int_T     V       = (int_T)(mxGetPr(LAP_ARG)[0]);    
    const int_T     B       = (F<=N) ? N : ( ((F%N)==0) ? F : F+N-V);
    const int_T     bufLen  = (F<=N) ? N+B : F+B;
    
    const boolean_T isMultiTasking = isModelMultiTasking(S);
    const boolean_T isMultiRate    = isBlockMultiRate(S,INPORT,OUTPORT);
    const boolean_T needICs        = NEED_ICS(isMultiTasking,isMultiRate, F,N,V);

    /* Don't initialize IWork if it is not present (i.e., no underlap): */
    if (V < 0) {
        ssSetIWorkValue(S, UL_COUNT_IDX, 0);
    }
    
    if (!isMultiTasking && (F > 1) && (N == 1) && (V == 0) ) {
        /* Reset counter */
        *((int32_T *)ssGetDWork(S, CIRCBUF_IDX)) = 0;
    }

    if (needICs) {
        if (ssGetInputPortComplexSignal(S, INPORT) == COMPLEX_YES) {
            creal_T *inBuf;
            int_T    n;
        
            for (n=0; n<nChans; n++) {
                real_T *prIC = mxGetPr(IC_ARG);
                real_T *piIC = mxGetPi(IC_ARG);
                const boolean_T  ic_cplx = (boolean_T)(piIC != NULL);
            
                inBuf = ((creal_T *)ssGetDWork(S, CIRCBUF_IDX)) + (n*bufLen);
            
                if (numIC <= 1) {
                    /* Scalar */
                    creal_T ic;
                    int_T   i;
                
                    ic.re = (numIC == 0) ? 0.0 : *prIC;
                    ic.im = (numIC == 0) ? 0.0 : ( (ic_cplx) ? *piIC : 0.0 );
                    for (i=0; i++ < B; ) {
                        *inBuf++ = ic;
                    }
                
                } else if ( (numIC == F) || (numIC == N) ){
                    /* Vector */
                    int_T i;
                    for (i=0; i++ < B; ) {
                        inBuf->re = *prIC++;
                        (inBuf++)->im = (ic_cplx) ? *piIC++ : 0.0;
                    }
                
                } else {
                    /* Matrix */
                    int_T i;
                    prIC += n*((F<=N) ? N : F); 
                    if (ic_cplx) piIC += n*((F<=N) ? N : F);
                
                    for(i=0; i++ < B; ) {
                        inBuf->re = *prIC++;
                        (inBuf++)-> im = (ic_cplx) ? *piIC++ : 0.0;
                    }
                }
            }
        
            inBuf -= (nChans-1)*bufLen;
            ssSetPWorkValue(S, INBUF_PTR,  inBuf);
            ssSetPWorkValue(S, OUTBUF_PTR, (((creal_T *)ssGetDWork(S, CIRCBUF_IDX)) + ((V<0) ? 0 : V))); 
        
        } else {
            real_T *inBuf;
            int_T   n;
        
            for (n=0; n<nChans; n++) {
                real_T *pIC = mxGetPr(IC_ARG);
            
                inBuf = ((real_T *)ssGetDWork(S, CIRCBUF_IDX)) + (n*bufLen);
                if (numIC <= 1) {
                    /* Scalar */
                    real_T ic = (numIC == 0) ? (real_T)0.0 : *pIC;
                    int_T  i;
                    for (i=0; i++ < B; ) {
                        *inBuf++ = ic;
                    }
                
                } else if ( (numIC == F) || (numIC == N) ){
                    /* Vector */
                    int_T i;
                    for (i=0; i++ < B; ) {
                        *inBuf++ = *pIC++;
                    }
                
                } else {
                    /* Matrix */
                    int_T i;
                    pIC += n*((F<=N) ? N : F);
                    for(i=0; i++ < B; ) {
                        *inBuf++ = *pIC++;
                    }
                }
            }
            inBuf -= (nChans-1)*bufLen;
            ssSetPWorkValue(S, INBUF_PTR,  inBuf);
            ssSetPWorkValue(S, OUTBUF_PTR, (((real_T *)ssGetDWork(S, CIRCBUF_IDX)) + ((V<0) ? 0 : V))); 
        }
    }
}



#define output_SingleTasking_ICs(dtype)     \
    for (n=0; n<nChans; n++) {              \
        c = *cnt;                           \
        for (i=0; i<N; i++) {               \
            *y++ = *((dtype *)(uptr[n*F + c++])); \
            if (c == F) c = 0;              \
        }                                   \
    }                                       \
    *cnt = c;

#define output_SingleTasking_ICs_alg                                        \
    int32_T *cnt = (int32_T *)ssGetDWork(S, CIRCBUF_IDX);                   \
    int32_T  c;                                                             \
    int_T    i;                                                             \
                                                                            \
    if (cplx) {                                                             \
        creal_T       *y    = (creal_T *)ssGetOutputPortSignal(S,OUTPORT);  \
        InputPtrsType  uptr = ssGetInputPortSignalPtrs(S,INPORT);           \
                                                                            \
        output_SingleTasking_ICs(creal_T)                                   \
                                                                            \
    } else {                                                                \
        real_T             *y    = ssGetOutputPortRealSignal(S, OUTPORT);   \
        InputRealPtrsType   uptr = ssGetInputPortRealSignalPtrs(S, INPORT); \
                                                                            \
        output_SingleTasking_ICs(real_T)                                    \
    }                                                                       \


static void mdlOutputs(SimStruct *S, int_T tid)
{
    const int_T     inWidth = ssGetInputPortWidth(S, INPORT);  
    const int_T     outWidth = ssGetOutputPortWidth(S, OUTPORT);  
    const boolean_T isFrame = (boolean_T)(mxGetPr(FRAME_ARG)[0] != 0.0);
    const int_T     nChans  = (isFrame) ? (int_T)(mxGetPr(NCHANS_ARG)[0]): inWidth;
    const int_T     F       = inWidth/nChans;   
    const int_T     N       = outWidth/nChans;
    const int_T     V       = (int_T)(mxGetPr(LAP_ARG)[0]);    
    const boolean_T cplx           = (boolean_T)(ssGetInputPortComplexSignal(S, INPORT) == COMPLEX_YES);

    const boolean_T isMultiTasking = isModelMultiTasking(S);
    const boolean_T isMultiRate    = isBlockMultiRate(S,INPORT,OUTPORT);
    const boolean_T needICs        = NEED_ICS(isMultiTasking,isMultiRate, F,N,V);

    const int_T     OutportTid     = ssGetOutputPortSampleTimeIndex(S, OUTPORT);
    const int_T     InportTid      = ssGetInputPortSampleTimeIndex(S, INPORT);

    int_T    n;

    if (needICs) {
        const int_T numIC  = mxGetNumberOfElements(IC_ARG);
        const int_T B      = (F<=N) ? N : ( ((F%N)==0) ? F : F+N-V);
        const int_T bufLen = (F<=N) ? N+B : F+B;

    
        if (ssIsSampleHit(S, OutportTid, tid)) {
        
            if (cplx) {
                creal_T *y = (creal_T *)ssGetOutputPortSignal(S,OUTPORT);
                creal_T *outBuf;
            
                for (n=0; n<nChans; n++) {
                    creal_T *topBuf = ((creal_T *)ssGetDWork(S, CIRCBUF_IDX)) + (n*bufLen);
                    creal_T *endBuf = topBuf + bufLen;
                
                    const int_T V_tmp  = (V<0) ? 0 : V;
                
                    /* Get the original output pointer relative to this channel
                    * and back it up V samples: 
                    */
                    outBuf = ((creal_T *)ssGetPWorkValue(S, OUTBUF_PTR)) + (n*bufLen);
                    outBuf = ((outBuf-V_tmp) < topBuf) ? (endBuf-(topBuf-(outBuf-V_tmp))) : (outBuf-V_tmp);
                
                    /* Read N samples: */
                    {
                        const int_T nSampsAtBot = (endBuf-outBuf);
                        int_T       nSamps = N;
                        int_T       i;
                    
                        if ( nSampsAtBot <= N ) {
                            /* Need to wrap pointer */
                            /* Copy all samples left in buffer before wrapping pointer */
                            for (i=0; i++ <nSampsAtBot; ) {
                                *y++ = *outBuf++;
                            }
                            outBuf = topBuf;       /* Wrap outBuf to beginning of buffer*/
                            nSamps -= nSampsAtBot; /* Left over samples to copy from top of buffer */
                        } 
                    
                        for(i=0; i++ < nSamps; ) {
                            *y++ = *outBuf++;
                        }
                    }
                }
            
                /* Update outBuf pointer relative to the first channel */
                outBuf -= (nChans-1)*bufLen;
                ssSetPWorkValue(S, OUTBUF_PTR, outBuf);
            
            } else {
                real_T *y = ssGetOutputPortRealSignal(S, OUTPORT);
                real_T *outBuf;
            
                for (n=0; n<nChans; n++) {
                    real_T *topBuf = ((real_T *)ssGetDWork(S, CIRCBUF_IDX)) + (n*bufLen);
                    real_T *endBuf = topBuf + bufLen;
                
                    const int_T V_tmp  = (V<0) ? 0 : V;
                
                    /* Get the original output pointer relative to this channel
                    * and back it up V samples: 
                    */
                    outBuf = ((real_T *)ssGetPWorkValue(S, OUTBUF_PTR)) + (n*bufLen);
                    outBuf = ((outBuf-V_tmp) < topBuf) ? (endBuf-(topBuf-(outBuf-V_tmp))) : (outBuf-V_tmp);
                
                    /* Read N samples: */
                    {
                        const int_T nSampsAtBot = (endBuf-outBuf);
                        int_T       nSamps = N;
                        int_T       i;
                    
                        if ( nSampsAtBot <= N ) {
                            /* Need to wrap pointer */
                            /* Copy all samples left in buffer before wrapping pointer */
                            for (i=0; i++ <nSampsAtBot; ) {
                                *y++ = *outBuf++;
                            }
                            outBuf = topBuf;       /* Wrap outBuf to beginning of buffer*/
                            nSamps -= nSampsAtBot; /* Left over samples to copy from top of buffer */
                        } 
                    
                        for(i=0; i++ < nSamps; ) {
                            *y++ = *outBuf++;
                        }
                    }
                }
            
                /* Update outBuf pointer relative to the first channel */
                outBuf -= (nChans-1)*bufLen;
                ssSetPWorkValue(S, OUTBUF_PTR, outBuf);
            }
        }
    
        if (ssIsSampleHit(S, InportTid, tid)) {

            /* Underlap: only works when buffering scalar inputs */
            if (V < 0)  {
                /* Underlap case: */
                const int_T     inWidth = ssGetInputPortWidth(S, INPORT);  
                const int_T     outWidth = ssGetOutputPortWidth(S, OUTPORT);  
                const boolean_T isFrame = (boolean_T)(mxGetPr(FRAME_ARG)[0] != 0.0);
                const int_T     nChans  = (isFrame) ? (int_T)(mxGetPr(NCHANS_ARG)[0]): inWidth;
                const int_T     N       = outWidth/nChans;
                int_T       *ul_count = ssGetIWork(S) + UL_COUNT_IDX;

                ++(*ul_count);
            
                /* Skip this sample because of negative overlap */
                if (*ul_count > N) {
                    if (*ul_count == N-V) {
                        *ul_count = 0;
                    }
                    return; /* Skip acquisition */
                }
            }
        
            if (cplx) {
                InputPtrsType  uptr = ssGetInputPortSignalPtrs(S,INPORT);
                creal_T       *inBuf;
            
                for (n=0; n<nChans; n++) {
                    creal_T *topBuf = ((creal_T *)ssGetDWork(S, CIRCBUF_IDX)) + (n*bufLen);
                    creal_T *endBuf = topBuf + bufLen;
                
                    /* Get the original input pointer relative to this channel */
                    inBuf = ((creal_T *)ssGetPWorkValue(S, INBUF_PTR)) + (n*bufLen);
                
                    /* Copy F samples */
                    {
                        const int_T nSampsAtBot = (endBuf-inBuf);
                        int_T       nSamps = F;
                        int_T       i;
                    
                        if ( nSampsAtBot <= nSamps) {
                            /* Need to wrap inBuf pointer */
                            for (i=0; i++ < nSampsAtBot; ) {
                                *inBuf++ = *((creal_T *)(*uptr++));
                            }
                            inBuf = topBuf;
                            nSamps -= nSampsAtBot;
                        }
                        for (i=0; i++ < nSamps; ) {
                            *inBuf++ = *((creal_T *)(*uptr++));
                        }
                    }
                }
                /* Update inBuf pointer relative to the first channel */
                inBuf -= (nChans-1)*bufLen;
                ssSetPWorkValue(S, INBUF_PTR, inBuf);
            
            } else {
                InputRealPtrsType  uptr = ssGetInputPortRealSignalPtrs(S, INPORT);
                real_T            *inBuf;
            
                for (n=0; n<nChans; n++) {
                    real_T *topBuf = ((real_T *)ssGetDWork(S, CIRCBUF_IDX)) + (n*bufLen);
                    real_T *endBuf = topBuf + bufLen;
                
                    /* Get the original input pointer relative to this channel */
                    inBuf = ((real_T *)ssGetPWorkValue(S, INBUF_PTR)) + (n*bufLen);
                
                    /* Copy F samples */
                    {
                        const int_T nSampsAtBot = (endBuf-inBuf);
                        int_T       nSamps = F;
                        int_T       i;
                    
                        if ( nSampsAtBot <= nSamps) {
                            /* Need to wrap inBuf pointer */
                            for (i=0; i++ < nSampsAtBot; ) {
                                *inBuf++ = **uptr++;
                            }
                            inBuf = topBuf;
                            nSamps -= nSampsAtBot;
                        }
                        for (i=0; i++ < nSamps; ) {
                            *inBuf++ = **uptr++;
                        }
                    }
                }
            
                /* Update inBuf pointer relative to the first channel */
                inBuf -= (nChans-1)*bufLen;
                ssSetPWorkValue(S, INBUF_PTR, inBuf);
            }
        }

    } else {
        /* No ICs:  */
        const boolean_T tsRatio    = (boolean_T)((N-V) > F);
        
        if ( !isMultiRate ||
                ssIsSampleHit(S, InportTid,  tid) &&  tsRatio || 
                ssIsSampleHit(S, OutportTid, tid) && !tsRatio
           ) {

            if ( (F == 1) && (N == 1) ) {
                if (cplx) {
                    creal_T       *y    = (creal_T *)ssGetOutputPortSignal(S,OUTPORT);
                    InputPtrsType  uptr = ssGetInputPortSignalPtrs(S,INPORT);
                                                                        
                    for (n=0; n<nChans; n++) {
                        *y++ = *((creal_T *)(*uptr++));
                    }

                } else {
                    real_T             *y    = ssGetOutputPortRealSignal(S, OUTPORT);
                    InputRealPtrsType   uptr = ssGetInputPortRealSignalPtrs(S, INPORT);
                                                                        
                    for (n=0; n<nChans; n++) {
                        *y++ = **uptr++;
                    }
                }
            } else {
                output_SingleTasking_ICs_alg;
            }
        }
    }
}

static void mdlTerminate(SimStruct *S)
{
}



#if defined(MATLAB_MEX_FILE)
#define MDL_SET_INPUT_PORT_WIDTH
static void mdlSetInputPortWidth(SimStruct *S, int_T port,
                                 int_T inputPortWidth)
{
    const boolean_T isInheritOutWidth = (boolean_T)(mxGetPr(SPECIFY_OUT_WIDTH_ARG)[0] == 0.0);
    const boolean_T isFrame           = (boolean_T)(mxGetPr(FRAME_ARG)[0] != 0.0);
    const int_T     nChans            = (isFrame) ? (int_T)(mxGetPr(NCHANS_ARG)[0]) : inputPortWidth;

    ssSetInputPortWidth(S,  port, inputPortWidth);

    if (!isFrame) {
        /* For sample-based inputs, 
         *  If the output width is specified, we can set it because we know
         *  the number of channels now (nChans = inputPortWidth).
         */
        if (!isInheritOutWidth && (ssGetOutputPortWidth(S,OUTPORT) == DYNAMICALLY_SIZED) ) {
            const int_T N = (int_T)(mxGetPr(OUT_WIDTH_ARG)[0]);

            ssSetOutputPortWidth(S, port, N*nChans);
        }
    } 
}


#define MDL_SET_OUTPUT_PORT_WIDTH
static void mdlSetOutputPortWidth(SimStruct *S, int_T port,
                                  int_T outputPortWidth)
{
    const boolean_T isInheritOutWidth = (boolean_T)(mxGetPr(SPECIFY_OUT_WIDTH_ARG)[0] == 0.0);
    const boolean_T isFrame           = (boolean_T)(mxGetPr(FRAME_ARG)[0] != 0.0);
    int_T           nChans            = (int_T)(mxGetPr(NCHANS_ARG)[0]);
    
    ssSetOutputPortWidth(S, port, outputPortWidth);

    if (!isFrame) {
        /* Sample-based inputs */

        if (!isInheritOutWidth) {        
            /* Specified output width */
            const int_T N = (int_T)(mxGetPr(OUT_WIDTH_ARG)[0]);

            if ( (outputPortWidth % N) != 0) {
                THROW_ERROR(S,"Specified output width and propagated width does not match for"
                    " sample-based inputs.");
            }

        }

        {
            const int_T inWidth = ssGetInputPortWidth(S,INPORT);
        
            if ( inWidth != DYNAMICALLY_SIZED) {
                /* Check that the number of channels are valid: 
                */
                if ( ( (inWidth > outputPortWidth) && ((inWidth % outputPortWidth) != 0) ) ||
                     ( (inWidth < outputPortWidth) && ((outputPortWidth % inWidth) != 0) )
                   ) {
                    THROW_ERROR(S,"Invalid number of channels computed for sample-based inputs in rebuffer block.");
                }
            }
        }

    } else {
        if (!isInheritOutWidth) {
            /* For frame-based inputs, if output width was specified, it was set in mdlInitializeSizes.
             * There shouldn't be a call here.
             */
            THROW_ERROR(S,"Invalid call to output port width propagation call for rebuffer block.");
        }

        /* Check that number of channels is valid */
        if ( (isFrame) && (outputPortWidth % nChans) ) {
            THROW_ERROR(S, "The outport width must be a multiple of the number of channels.");
        }
    }
}


#define MDL_SET_WORK_WIDTHS
static void mdlSetWorkWidths(SimStruct *S)
{
    
    const boolean_T cplx     = (boolean_T)(ssGetInputPortComplexSignal(S, INPORT) == COMPLEX_YES);
    const int_T     numIC    = mxGetNumberOfElements(IC_ARG);
    const int_T     inWidth  = ssGetInputPortWidth(S, INPORT);  
    const int_T     outWidth = ssGetOutputPortWidth(S, OUTPORT);  
    const boolean_T isFrame  = (boolean_T)(mxGetPr(FRAME_ARG)[0] != 0.0);
    const int_T     nChans   = (isFrame) ? (int_T)(mxGetPr(NCHANS_ARG)[0]): inWidth;
    const int_T     F        = inWidth/nChans;   
    const int_T     N        = outWidth/nChans;
    const int_T     V        = (int_T)(mxGetPr(LAP_ARG)[0]);    
    const int_T     B        = (F<=N) ? N : ( ((F%N)==0) ? F : F+N-V);

    const boolean_T isMultiTasking = isModelMultiTasking(S);
    const boolean_T isMultiRate    = isBlockMultiRate(S,INPORT,OUTPORT);

    const boolean_T needNoWorkVect = (!isMultiTasking && (N == 1) && (F == 1) );
    const boolean_T needICs        = NEED_ICS(isMultiTasking,isMultiRate, F,N,V);

    /* Set PWork: 
     * PWorks are only needed in multi-tasking mode.
     */
    if (needICs) ssSetNumPWork(S, NUM_PWORKS); 
    else         ssSetNumPWork(S, NUM_PWORKS-2);

    /* Set DWork: */
    if (needNoWorkVect) {
        if(!ssSetNumDWork(S, NUM_DWORKS-1)) return;     /* No DWork */

    } else {
        /* DWorks: 
         *
         * For Multi-Tasking Mode:
         * Need to allocate a buffer that is at the most (per channel)
         * F+B for unbuffer and N+B for buffer,
         *         where N = number of samples per output frame (buffer size)
         *               V = number of overlapped/repeated samples per frame
         *               F = samples per input frame
         *               B is the offset of the input and output pointers
         *                 = N, (buffer)
         *                 = F, (unbuffer) if F and N are multiples of each other or, 
         *                 = F+N-V (unbuffer)
         *
         * For Single-Tasking Mode:
         * One DWork is needed as a counter to keep track of which input to start reading: 
         *   ( !isMultiTasking && 
         *     ( (F>N) && (N==1) && (V==0) ) || 
         *     ( (F>N) && (F!=1) && (N!=1) && (V==0) && (F%N==0) ) 
         *   );
         */
        if(!ssSetNumDWork(      S, NUM_DWORKS)) return;
        ssSetDWorkWidth(        S, CIRCBUF_IDX, (needICs) ? (nChans*((F<=N) ? (N+B) : (F+B))) : 1);
        ssSetDWorkDataType(     S, CIRCBUF_IDX, (needICs) ? SS_DOUBLE : SS_INT32);
        ssSetDWorkComplexSignal(S, CIRCBUF_IDX, (needICs) ? cplx : COMPLEX_NO);
        ssSetDWorkName(         S, CIRCBUF_IDX, "CircBuff");
        ssSetDWorkUsedAsDState( S, CIRCBUF_IDX, 1);
    }

    if (needICs) {
        /* Check initial conditions 
         *      Valid for any case: numIC = [],1:
         *      Special cases: Unbuffer (N = 1), IC = F,inWidth
         *                     Buffer   (F = 1), IC = N,outWidth (=N*nChans);
         */
    
        if ((numIC != 0) && (numIC != 1)) {
            if ( !((N==1) && ((numIC==F) || (numIC==inWidth))) &&
                 !((F==1) && ((numIC==N) || (numIC==N*nChans))) ) {
                THROW_ERROR(S, "Initial condition vector has incorrect dimensions.");
            }
        }

        if (!cplx && mxIsComplex(IC_ARG)) {
            THROW_ERROR(S, "Complex initial conditions are not allowed with real inputs.");
        }
    }
}
#endif 


#define MDL_RTW
#if defined(MATLAB_MEX_FILE) || defined(NRT)
static void mdlRTW(SimStruct *S)
{
    const int_T     inWidth  = ssGetInputPortWidth(S, INPORT);  
    const int_T     outWidth = ssGetOutputPortWidth(S, OUTPORT);  
    const boolean_T isFrame  = (boolean_T)(mxGetPr(FRAME_ARG)[0] != 0.0);
    const int_T     numChans = (isFrame) ? (int_T)(mxGetPr(NCHANS_ARG)[0]): inWidth;
    const int_T     F        = inWidth/numChans;   
    const int_T     N        = outWidth/numChans;
    const int_T     V        = (int_T)(mxGetPr(LAP_ARG)[0]);    
    const boolean_T isMultiTasking = isModelMultiTasking(S);
    const boolean_T isMultiRate    = isBlockMultiRate(S,INPORT,OUTPORT);
    const boolean_T needICs        = NEED_ICS(isMultiTasking,isMultiRate, F,N,V);

    int32_T bufSize = (int32_T)mxGetPr(OUT_WIDTH_ARG)[0];
    int32_T overlap = (int32_T)mxGetPr(LAP_ARG)[0];
    int32_T frame   = (int32_T)mxGetPr(FRAME_ARG)[0];
    int32_T nChans  = (int32_T)mxGetPr(NCHANS_ARG)[0];

    if (!needICs) {
        if (!ssWriteRTWParamSettings(S, 4,
             SSWRITE_VALUE_DTYPE_NUM,  "BUF_SIZE",
             &bufSize,
             DTINFO(SS_INT32,0),

             SSWRITE_VALUE_DTYPE_NUM,  "OVERLAP",
             &overlap,
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
        /* If the IC parameter is an empty matrix we'll assign it to be zero,
         * so that ssWriteRTWParamSettings will not error out.  Setting IC to
         * zero when it is specified as an empty matrix is consistent with the
         * functionality of the rebuffer block.
         */
        int_T   numIC   = 1; 
        real_T  zero    = 0;
        real_T  *IC_re  = &zero;
        real_T  *IC_im  = NULL;
        int32_T icRows  = (int32_T)mxGetM(IC_ARG);
        int32_T icCols  = (int32_T)mxGetN(IC_ARG);

        if(!mxIsEmpty(IC_ARG)) {
            numIC = mxGetNumberOfElements(IC_ARG);
            IC_re = mxGetPr(IC_ARG);
            IC_im = mxGetPi(IC_ARG);
        }

        if (!ssWriteRTWParamSettings(S, 7,
                 SSWRITE_VALUE_DTYPE_ML_VECT, "IC", IC_re, 
                 IC_im, numIC, 
                 DTINFO(SS_DOUBLE, mxIsComplex(IC_ARG)),

                 SSWRITE_VALUE_DTYPE_NUM,  "IC_ROWS",
                 &icRows,
                 DTINFO(SS_INT32,0),

                 SSWRITE_VALUE_DTYPE_NUM,  "IC_COLS",
                 &icCols,
                 DTINFO(SS_INT32,0),

                 SSWRITE_VALUE_DTYPE_NUM,  "BUF_SIZE",
                 &bufSize,
                 DTINFO(SS_INT32,0),

                 SSWRITE_VALUE_DTYPE_NUM,  "OVERLAP",
                 &overlap,
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
}
#endif


#include "dsp_cplxhs11.c"

#ifdef  MATLAB_MEX_FILE
#include "simulink.c"
#else
#include "cg_sfun.h"
#endif

/* [EOF] sdsprebuff.c */
