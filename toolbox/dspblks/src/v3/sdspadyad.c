/*
 * SDSPADYAD A SIMULINK dyadic FIR analysis multirate filter block.
 *   Uses an efficient polyphase implementation for the FIR decimation filters.
 *
 *  
 *  Copyright 1995-2002 The MathWorks, Inc.
 *  $Revision: 1.25 $  $Date: 2002/04/14 20:42:19 $
 */

#define S_FUNCTION_LEVEL 2
#define S_FUNCTION_NAME sdspadyad

#include "dsp_sim.h"

/* Defines for easy access of the input parameters */
enum {
    ARGC_LFilt = 0,
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

/* Only Dyadic (M = 2) is currently supported */
const int_T M_ADIC = 2;

/* An invalid number of channels is used to flag channel-based operation */
const int_T SAMPLE_BASED = -1;

/* The choices for the tree structure (from pop-up dialog box) */
enum { ASYMMETRIC=1, SYMMETRIC };

/* Port Index Enumerations */
enum { INPORT=0, NUM_INPORTS };

/* DWork indices */
enum {
    States=0,     /* Buffer for filter state-histories */
    PhaseIdx,     /* Phase index (counter) for efficient polyphase FIR implementation       */
    MemIdx,       /* Index of the filter state sample in use, referenced to States buffer   */
    OutIdx,       /* Index of current processed sample in OutputBuffer to be written out    */
    InIdx,        /* Index of current input, referenced to InputBuffer                      */
    I2Idx,        /* Counter used to determine if enough input samples available to process */
    PartialSums,  /* Used to store intermediate FIR filter sum results before OutputBuffer  */
    InputBuffer,  /* Common circular input sample buffer  */
    OutputBuffer, /* Common circular output sample buffer */
    FiltBuffer,   /* Linear buffer of FIR filter coefficients */
    WrBuff1,      /* Flag used to trigger the processing of output sample frames */
    NUM_DWORKS
};


static boolean_T ANY_UNCONNECTED_PORTS(SimStruct *S) 
{ 
    const int_T nInputs     = ssGetNumInputPorts(S);  
    const int_T nOutputs    = ssGetNumOutputPorts(S); 
    boolean_T   unconnected = 0;  /* Assume all ports connected */
    int_T       i;

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
    const int_T numChanArg = mxGetNumberOfElements(CHANS_ARG);

    /* Check number of levels parameter */
    if (!IS_FLINT_GE(LEVELS_ARG,1)) {
        THROW_ERROR(S,"The number of levels must be a positive integer");
    }

    /* Check filter parameters */
    if ( OK_TO_CHECK_VAR(S, LFILT_ARG) ) {
        if (mxGetN(LFILT_ARG) != M_ADIC) {
            THROW_ERROR(S,"Lowpass filter must be a polyphase matrix with the number of "
                "columns equal to two");
        }
    }

    if ( OK_TO_CHECK_VAR(S, HFILT_ARG) ) {
        if (mxGetN(HFILT_ARG) != M_ADIC) {
            THROW_ERROR(S,"Highpass filter must be a polyphase matrix with the number of "
                "columns equal to two");
        }
    }

    if ( OK_TO_CHECK_VAR(S, LFILT_ARG) && OK_TO_CHECK_VAR(S, HFILT_ARG) ) {
        if (mxIsComplex(LFILT_ARG) != mxIsComplex(HFILT_ARG)) {
            THROW_ERROR(S,"The two filters must either be both complex or both real");
        }
    }

    /* Check channels parameter */
    if ( OK_TO_CHECK_VAR(S, CHANS_ARG) ) {
        if ( (numChanArg != 1) || (*mxGetPr(CHANS_ARG) != (int_T) *mxGetPr(CHANS_ARG))
            || ( (*mxGetPr(CHANS_ARG) <= 0) && ((int_T) *mxGetPr(CHANS_ARG) != SAMPLE_BASED) ) ) {
            THROW_ERROR(S,"The number of channels must be an integer >= 1. "
                "If it is -1, the number of channels equals the input port width");
        }
    }

    /* Tree arg: Symmetric or Asymmetic */
    if (!IS_FLINT_IN_RANGE(TREE_ARG, ASYMMETRIC, SYMMETRIC)) {
        THROW_ERROR(S,"The choices for the tree structure are: 1=asymmetric or 2=symmetric");
    }
}
#endif


static void mdlInitializeSizes(SimStruct *S)
{
    int_T numOutputs;
    int_T numFiltersTotal;
    int_T i;
    
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
    
    if (!ssSetNumInputPorts(        S, NUM_INPORTS)) return;
    ssSetInputPortWidth(            S, INPORT, DYNAMICALLY_SIZED);
    ssSetInputPortComplexSignal(    S, INPORT, COMPLEX_INHERITED);
    ssSetInputPortSampleTime(       S, INPORT, INHERITED_SAMPLE_TIME);
    ssSetInputPortDirectFeedThrough(S, INPORT, 1);
    /* Ports on multirate blocks are not re-useable */
    ssSetInputPortReusable(         S, INPORT, 0);    
    ssSetInputPortOverWritable(     S, INPORT, 0);

    {   
        /* Calculate number of inputs and number of filters */
        const int_T numLevels = (int_T) *mxGetPr(LEVELS_ARG);

        if ( ( (int_T) *mxGetPr(TREE_ARG) ) == ASYMMETRIC ) {
            numOutputs      = numLevels + 1;
            numFiltersTotal = M_ADIC * numLevels;
        }
        else {
            numOutputs      = M_ADIC;
            numFiltersTotal = M_ADIC * M_ADIC;

            for (i=1; i < numLevels; i++) {
                numOutputs      *= M_ADIC;
                numFiltersTotal += numOutputs;
            }
        }
    }
    
    if ( !ssSetNumOutputPorts(S, numOutputs) ) return;

    for (i=0; i < numOutputs; i++) {
        ssSetOutputPortWidth(        S, i, DYNAMICALLY_SIZED);
        ssSetOutputPortComplexSignal(S, i, COMPLEX_INHERITED);
        ssSetOutputPortSampleTime(   S, i, INHERITED_SAMPLE_TIME);
        ssSetOutputPortReusable(     S, i, 1);
    }

    /* Pointers to filter coefficients */
    if (mxIsComplex(LFILT_ARG) || mxIsComplex(HFILT_ARG)) {
        /* xxx RTW really only needs (numFiltersTotal + 2) xxx */
        numFiltersTotal *= 2; /* Re + Im */
        ssSetNumPWork(S, numFiltersTotal);
    }
    else {
        /* xxx Two extra needed for RTW xxx */
        ssSetNumPWork(S, numFiltersTotal + 2);
    }

    if(!ssSetNumDWork(  S, DYNAMICALLY_SIZED)) return;

    ssSetNumSampleTimes(S, PORT_BASED_SAMPLE_TIMES);
    ssSetOptions(       S, SS_OPTION_EXCEPTION_FREE_CODE);
}


#define MDL_START
static void mdlStart (SimStruct *S)
{
#ifdef MATLAB_MEX_FILE
    const boolean_T complex    = (boolean_T)(mxIsComplex(LFILT_ARG) || mxIsComplex(HFILT_ARG) ||
                                    (ssGetInputPortComplexSignal(S, INPORT) == COMPLEX_YES));

    const int_T     portWidth  = ssGetInputPortWidth(S, INPORT);
    const int_T     numLevels  = (int_T) *mxGetPr(LEVELS_ARG);
    const int_T     numOutputs = ssGetNumOutputPorts(S);
    int_T           numChans   = (int_T) *mxGetPr(CHANS_ARG);
    int_T           frame;
    int_T           minFrame;
    int_T           outWidth;
    int_T           outputPortWidth;
    int_T           i;
    boolean_T       checkCmplx;

    if (numChans == SAMPLE_BASED)  {
        frame = 1;
        numChans = portWidth;
    }
    else {
        frame = portWidth / numChans;
    }

    /* Compute the minimum input frame size */
    minFrame = M_ADIC;
    for (i=1; i < numLevels; i++) {
        minFrame *= M_ADIC;
    }

    if ( ( ((int_T) *mxGetPr(CHANS_ARG)) != SAMPLE_BASED ) && ( (frame % minFrame) != 0 ) ) {
        THROW_ERROR(S,"The input frame size must be a multiple of "
            "2^(number of levels).");
    }

    if (numChans != SAMPLE_BASED && (ssGetInputPortWidth(S, INPORT) % numChans) != 0) {
        THROW_ERROR(S,"The port width must be a multiple of the number of channels.");
    }

    checkCmplx = (boolean_T)ssGetOutputPortComplexSignal(S, 0);
    for (i=1; i < numOutputs; i++) {
        if (checkCmplx != ssGetOutputPortComplexSignal(S, i)) {
            THROW_ERROR(S,"Output ports must either be all real or all complex.");
        }
    }

    /* Check the port widths */
    if ( ((int_T) *mxGetPr(CHANS_ARG)) != SAMPLE_BASED ) {  /* Frame-based inputs */
        if ( ((int_T) *mxGetPr(TREE_ARG)) == ASYMMETRIC ) {
            outWidth = portWidth;

            for (i=0; i < numOutputs; i++) {
                outputPortWidth = ssGetOutputPortWidth(S, i);

                if (i != numLevels) outWidth /= M_ADIC;

                if (outputPortWidth != outWidth) {
                    THROW_ERROR(S, "(Input port width)/(Output port width) "
                        "must equal the decimation factor at each output level.");
                }
            }
        }
        else { /* Symmetric tree */
            for (i=0; i < numOutputs; i++) {
                outputPortWidth = ssGetOutputPortWidth(S, i);

                if (minFrame*outputPortWidth != portWidth) {
                    THROW_ERROR(S, "Input port width must equal "
                        "2^(number of levels)*(output port width).");
                }
            }
        }
    }
    else { /* Sample-based inputs */
        for (i=0; i < numOutputs; i++) {
            outputPortWidth = ssGetOutputPortWidth(S, i);

            if (outputPortWidth != portWidth) {
                THROW_ERROR(S, "Input port width must equal output port width.");
            }
        }
    }

    if ( ( complex && (checkCmplx != COMPLEX_YES) ) ||
        ( !complex && (checkCmplx != COMPLEX_NO) ) ) {
        THROW_ERROR(S,"If the input or filter coefficients are complex "
            "then the output must be complex.");
    }
#endif
}


static void mdlInitializeSampleTimes(SimStruct *S)
{
    /* Check port sample times: */ 
    if( !ANY_UNCONNECTED_PORTS(S) ) { 

        const  real_T Tsi        = ssGetInputPortSampleTime(S, INPORT);
        const  int_T  numOutputs = ssGetNumOutputPorts(S);
        int_T         i;

        if (Tsi == INHERITED_SAMPLE_TIME) {
            THROW_ERROR(S,"Sample time propagation failed for dyadic filter input");
        }

        for (i=0; i < numOutputs; i++) {
            real_T Tso = ssGetOutputPortSampleTime(S, i);
            
            if (Tso == INHERITED_SAMPLE_TIME) {
                THROW_ERROR(S,"Sample time propagation failed for dyadic filter output");
            }
        }
    }
}


#define MDL_INITIALIZE_CONDITIONS
static void mdlInitializeConditions(SimStruct *S)
{
    const int_T     numInputs   = ssGetNumInputPorts(S);
    const int_T     numOutputs  = ssGetNumOutputPorts(S);
    const boolean_T filtComplex = (boolean_T)(mxIsComplex(LFILT_ARG) || mxIsComplex(HFILT_ARG));
    const int_T     numLevels   = (int_T) *mxGetPr(LEVELS_ARG);
    const int_T     lpLength    = mxGetNumberOfElements(LFILT_ARG);
    const int_T     hpLength    = mxGetNumberOfElements(HFILT_ARG);
    const int_T     tree        = (int_T) *mxGetPr(TREE_ARG);
    boolean_T      *wrBuff1     = ssGetDWork(S, WrBuff1);
    int_T          *outIdx      = ssGetDWork(S, OutIdx);
    int_T          *inIdx       = ssGetDWork(S, InIdx);
    int_T          *i2Idx       = ssGetDWork(S, I2Idx);
    int_T          *phaseIdx    = ssGetDWork(S, PhaseIdx);
    int_T          *memIdx      = ssGetDWork(S, MemIdx);
    int_T           numFiltersTotal;
    int_T           numFiltsTotDiv2;
    int_T           i;
    int_T           j;

    /* Compute number of filters */
    if (tree == ASYMMETRIC) {
        /* The asymmetric case simply has M_ADIC filters   */
        /* for each and every level of the tree structure. */
        numFiltersTotal = M_ADIC * numLevels;
    }
    else {
        /* The symmetric case has M_ADIC filters following each     */
        /* branch of the tree. The number of branches for each      */
        /* level is equal to the level number, so each level has    */
        /* 2^(level) number of filters. If we add each of these     */
        /* nums of "filters per level" together, we get the answer. */
        int_T numFiltsThisLevel = M_ADIC;

        numFiltersTotal = M_ADIC;

        for (i=1; i < numLevels; i++) {
            numFiltsThisLevel *= M_ADIC;
            numFiltersTotal   += numFiltsThisLevel;
        }
    }

    numFiltsTotDiv2 = numFiltersTotal >> 1; /* integer divide by 2 */


    /*******************************************************/
    /* Initialize pointers to filter coefficients so that  */
    /* they correspond to the last filter phase.           */
    /*******************************************************/
    for (i=0, j=0; i < numFiltsTotDiv2; i++) {
        /* High Pass coeffs */
        ssSetPWorkValue(     S, j++, mxGetPr(HFILT_ARG) + hpLength - hpLength/M_ADIC );

        if (filtComplex) {
            ssSetPWorkValue( S, j++, mxGetPi(HFILT_ARG) + hpLength - hpLength/M_ADIC );
        }

        /* Low Pass coeffs */
        ssSetPWorkValue(     S, j++, mxGetPr(LFILT_ARG) + lpLength - lpLength/M_ADIC );

        if (filtComplex) {
            ssSetPWorkValue( S, j++, mxGetPi(LFILT_ARG) + lpLength - lpLength/M_ADIC );
        }
    }


    /*********************************************************/
    /* Initialize all pointers to state indices of filters   */
    /*********************************************************/
    for (i=0; i < numFiltersTotal; i++) {
        memIdx[i] = 0;
    }


    /*********************************************************/
    /* Compute Latency, initialize indexes, and init buffers */
    /*********************************************************/
    if ( isBlockMultiRate(S,numInputs,numOutputs) ) {
        /* ------------------------------------------------------------------ */
        /* xxx                           xxx                              xxx */
        /* The MULTI-RATE cases which currently exhibit incorrect latency     */
        /* behavior are listed as follows:                                    */
        /*                                                                    */
        /* 1) Symmetric,  Multi-rate (sample-based), single-tasking           */
        /*    [Latency should be zero, currently is one sample of an IC]      */
        /*                                                                    */
        /* 2) Asymmetric, Multi-rate (sample-based), single-tasking           */
        /*    [Latency should be zero, currently is 2^(levels-1) IC samples]  */
        /*                                                                    */
        /* 3) Asymmetric, Multi-rate (sample-based), multi-tsaking            */
        /*    [Latency should be one sample, just like it is for Symmetric,   */
        /*     currently the latency is 2^(levels-1) IC samples]              */
        /*                                                                    */
        /* The appropriate logic for proper pointer alignment/initialization  */
        /* must be added here when the algorithm is fixed for these cases.    */
        /* xxx                           xxx                              xxx */
        /* ------------------------------------------------------------------ */
        if ( isModelMultiTasking(S) ) {
            /* -------------------------------------------------------- */
            /* MultiRate,MultiTasking has IC latency of ONE sample tick */
            /* -------------------------------------------------------- */
            
            const int_T     outBuffSize = ssGetDWorkWidth(S, OutputBuffer);
            
            const boolean_T outBuffCx   =
                (boolean_T) (ssGetDWorkComplexSignal(S,OutputBuffer)==COMPLEX_YES);
            
            const int_T     outBuffLoop =
                (outBuffCx) ? 2*outBuffSize : outBuffSize;
            
            real_T         *outBuff     = ssGetDWork(S, OutputBuffer);
            
            /* Load output buffer with Initial Conditions */
            for(i=0; i<outBuffLoop; i++) {
                *outBuff++ = 0.0;
            }
            
            /* xxx FIX ASYMMETRIC CASE, SYMMETRIC CASE ALREADY O.K. xxx */
            for (i=0; i < numLevels; i++) {
                inIdx[i] = 0;
                
                /* Start with the last phase at each level */
                phaseIdx[i] = M_ADIC - 1;
                
                if (tree == ASYMMETRIC) {
                    outIdx[i]  = 0;
                    wrBuff1[i] = true;
                }
            }
            
            if (tree == ASYMMETRIC) {
                outIdx[numLevels] = 0;
            }
            else {
                outIdx[0]  = 0;
                wrBuff1[0] = true;
            }
            
            *i2Idx = 0;
        }
        else {
            /* ---------------------------------------------------------- */
            /* MultiRate, SingleTasking has no latency (no ICs required). */
            /* ---------------------------------------------------------- */
            
            /* xxx BOTH FIX SYMMETRIC AND ASYMMETRIC CASES xxx */
            for (i=0; i < numLevels; i++) {
                inIdx[i] = 0;
                
                /* Start with the last phase at each level */
                phaseIdx[i] = M_ADIC - 1;
                
                if (tree == ASYMMETRIC) {
                    outIdx[i]  = 0;
                    wrBuff1[i] = true;
                }
            }
            
            if (tree == ASYMMETRIC) {
                outIdx[numLevels] = 0;
            }
            else {
                outIdx[0]  = 0;
                wrBuff1[0] = true;
            }
            
            *i2Idx = 0;
        } /* isModelMultiTasking */
    }
    else {
        /* --------------------------------------------------------- */
        /* SingleRate has no latency (and thus no ICs are required). */
        /* --------------------------------------------------------- */
        
        /* Initialize indexes and other state variables */
        for (i=0; i < numLevels; i++) {
            inIdx[i] = 0;
            
            /* Start with the last phase at each level */
            phaseIdx[i] = M_ADIC - 1;
            
            if (tree == ASYMMETRIC) {
                outIdx[i]  = 1;
                wrBuff1[i] = true;
            }
        }
        
        if (tree == ASYMMETRIC) {
            outIdx[numLevels] = 1;
        }
        else {
            outIdx[0]  = 1;
            wrBuff1[0] = true;
        }
        
        *i2Idx = 0;
    } /* isMultiRate */
}


static void doFilter(SimStruct *S, void *inBuff, void *outBuff, void *sums, void *memory,
                     const int_T numSamps, int_T *phaseIdx, int_T *memIdx, int_T *inIdx,
                     const real_T **cffRPPtr, const real_T **cffIPPtr, const int_T order,
                     const real_T *cffRBase, const real_T *cffIBase,
                     boolean_T *wrBuff1)
{
    const int_T     outBuffSize = ( ssGetDWorkWidth(S, OutputBuffer) >> 1 ); /* divide by 2 */
    const boolean_T filtComplex = (boolean_T)mxIsComplex(LFILT_ARG);
    const boolean_T inComplex   = (boolean_T)(ssGetInputPortComplexSignal(S, INPORT) == true);
    const int_T     oframe      = numSamps / M_ADIC;
    int_T           i;

    /*
     * The algorithm is documented for the real+real case.
     * The other three cases use the same algorithm.
     */
    if (inComplex || filtComplex) { /* Complex Data */
        creal_T      *in      = (creal_T *) inBuff;
        creal_T      *y0      = (creal_T *) outBuff;
        creal_T      *sum     = (creal_T *) sums;
        creal_T      *mem0    = (creal_T *) memory;
        const real_T *cffRPtr = *cffRPPtr;
            
        if (filtComplex) { /* Complex data, complex filter */
            const real_T *cffIPtr = *cffIPPtr;

            for (i=0; i < numSamps; i++) {
                creal_T	*start = (creal_T *) mem0 + *memIdx + 1;
                creal_T	*mem   = start;

                sum->re += in->re * (*cffRPtr  ) - in->im * (*cffIPtr  );
                sum->im += in->re * (*cffIPtr++) + in->im * (*cffRPtr++);

                while ((mem-=M_ADIC) >= mem0) {
                    sum->re += mem->re * (*cffRPtr  ) - mem->im * (*cffIPtr  );
                    sum->im += mem->re * (*cffIPtr++) + mem->im * (*cffRPtr++);
                }

                mem += (order + M_ADIC);

                while ((mem-=M_ADIC) >= start) {
                    sum->re += mem->re * (*cffRPtr  ) - mem->im * (*cffIPtr  );
                    sum->im += mem->re * (*cffIPtr++) + mem->im * (*cffRPtr++);
                }

                if (++*phaseIdx == M_ADIC) {
                    creal_T *y = y0 + *inIdx;

                    if (*wrBuff1) y += outBuffSize;

                    *y = *sum;

                    sum->re = 0.0;
                    sum->im = 0.0;

                    if (++(*inIdx) == oframe) {
                        *inIdx = 0;
                        *wrBuff1 = (boolean_T) ( !(*wrBuff1) );
                    }

                    *phaseIdx = 0;
                    cffRPtr   = cffRBase;
                    cffIPtr   = cffIBase;
                }

                if (++(*memIdx) == order) *memIdx = 0;

                *(mem0+(*memIdx)) = *in++;
            } /* frame */

            *cffRPPtr = cffRPtr;
            *cffIPPtr = cffIPtr;
        }
        else { /* Complex data, real filter */
            for (i=0; i < numSamps; i++) {
                creal_T	*start = (creal_T *) mem0 + *memIdx + 1;
                creal_T	*mem   = start;

                sum->re += in->re * (*cffRPtr  );
                sum->im += in->im * (*cffRPtr++);

                while ((mem-=M_ADIC) >= mem0) {
                    sum->re += mem->re * (*cffRPtr  );
                    sum->im += mem->im * (*cffRPtr++);
                }

                mem += (order + M_ADIC);

                while ((mem-=M_ADIC) >= start) {
                    sum->re += mem->re * (*cffRPtr  );
                    sum->im += mem->im * (*cffRPtr++);
                }

                if (++*phaseIdx == M_ADIC) {
                    creal_T *y = y0 + *inIdx;

                    if (*wrBuff1) y += outBuffSize;

                    *y = *sum;

                    sum->re = 0.0;
                    sum->im = 0.0;

                    if (++(*inIdx) == oframe) {
                        *inIdx   = 0;
                        *wrBuff1 = (boolean_T) ( !(*wrBuff1) );
                    }

                    *phaseIdx = 0;
                    cffRPtr   = cffRBase;
                }

                if (++(*memIdx) == order) *memIdx = 0;

                *(mem0+(*memIdx)) = (*in++);
            } /* frame */

            *cffRPPtr = cffRPtr;
        } /* Real Filter */
    }
    else { /* Real Data */
        real_T *in = (real_T *) inBuff;

        if (filtComplex) { /* Real data, complex filter */
            /* Not required */
        }
        else { /* Real data, real filter */
            /* Each channel uses the same filter phase but accesses
             * its own state memory and input.
             */
            real_T       *y0      = (real_T *) outBuff;
            real_T       *sum     = (real_T *) sums;
            real_T       *mem0    = (real_T *) memory;
            const real_T *cffRPtr = *cffRPPtr;

            for (i=0; i < numSamps; i++) {
                /* The pointer to state memory is set dFactor samples past the
                 * desired location.  This is because the memory pointer is
                 * pre-decremented in the convolution loops.
                 */
                real_T *start = mem0 + *memIdx + 1;
                real_T *mem   = start;

                *sum += *in * (*cffRPtr++);

                /* Perform the convolution for this phase (on every dFactor samples)
                 * until we reach the start of the (linear) state memory */
                while ((mem-=M_ADIC) >= mem0) {
                    *sum += *mem * (*cffRPtr++);
                }

                /* wrap the state memory pointer to the next element */
                mem += (order + M_ADIC);

                /* Finish the convolution for this phase */
                while ((mem-=M_ADIC) >= start) {
                    *sum += *mem * (*cffRPtr++);
                }

                /* Update the counters modulo their buffer size */
                if (++*phaseIdx == M_ADIC) {
                    real_T *y = y0 + *inIdx;

                    if (*wrBuff1) y += outBuffSize;

                    *y = *sum;

                    *sum = 0.0;

                    if (++(*inIdx) == oframe) {
                        *inIdx   = 0;
                        *wrBuff1 = (boolean_T)( !(*wrBuff1) );
                    }

                    *phaseIdx = 0;
                    cffRPtr   = cffRBase;
                }

                /* Save the current input value */
                if (++(*memIdx) == order) *memIdx = 0;

                *(mem0+(*memIdx)) = *in++;
            } /* frame */

            *cffRPPtr = cffRPtr;
        } /* Real Filter */
    } /* Real Data */

    if (inIdx && *inIdx == oframe) *inIdx = 0;
}


void cmplxSymm(SimStruct *S, creal_T *inBuff, creal_T *outBuff,
               creal_T **out, creal_T **sums, creal_T **mem0, int_T numSamps,
               const int_T chan, const int_T numChans)
{
    const boolean_T filtComplex = (boolean_T)(mxIsComplex(LFILT_ARG) || mxIsComplex(HFILT_ARG));
    const int_T     numLevels   = (int_T) *mxGetPr(LEVELS_ARG);
    const int_T     lpOrder     = mxGetNumberOfElements(LFILT_ARG) - 1;
    const int_T     hpOrder     = mxGetNumberOfElements(HFILT_ARG) - 1;
    boolean_T      *wrBuff1     = (boolean_T *) ssGetDWork(S, WrBuff1);
    boolean_T       tinBuff1    = false;
    int_T           pIdx        = 0;
    int_T           iIdx        = 0; 
    int_T           filtIdx     = 0;
    int_T           N           = 1;
    int_T           level;
    int_T           j;
    creal_T        *swap;
        
    for (level=0; level < numLevels; level++) {
        int_T   *phaseIdx  = (int_T *) ssGetDWork(S, PhaseIdx) + level;
        int_T   *inIdx     = (int_T *) ssGetDWork(S, InIdx) + level;
        int_T    numSamps2 = numSamps >> 1; /* integer divide by 2 */
        creal_T *iBuff     = inBuff;
        creal_T *oBuff     = outBuff;
        
        /* Process N pairs of filters for this level */
        for (j=0; j < N; j++) {
            int_T  *memIdx  = (int_T *) ssGetDWork(S, MemIdx) + filtIdx;
            const real_T *cffRPtr = (const real_T *) ssGetPWorkValue(S,filtIdx);
            const real_T *cffIPtr = NULL;
            int_T   mIdx    = *memIdx;

            pIdx = *phaseIdx;
            iIdx = *inIdx;

            /* Highpass filter*/
            if (level == numLevels-1) {
                oBuff    = *out;
                *out    += (numSamps >> 1); /* integer divide by 2 */
                tinBuff1 = *wrBuff1;
            }
            else {
                tinBuff1 = false;
                iIdx = 0;
            }

            if (filtComplex) {
                cffIPtr = (real_T *) ssGetPWorkValue(S,filtIdx+1);
                doFilter(S, iBuff, oBuff, (*sums)++, *mem0, numSamps, &pIdx, &mIdx, &iIdx,
                    &cffRPtr, &cffIPtr, hpOrder, mxGetPr(HFILT_ARG), mxGetPi(HFILT_ARG), &tinBuff1);
            }
            else {
                doFilter(S, iBuff, oBuff, (*sums)++, *mem0, numSamps, &pIdx, &mIdx, &iIdx,
                    &cffRPtr, NULL, hpOrder, mxGetPr(HFILT_ARG), NULL, &tinBuff1);
            }

            ssSetPWorkValue(S, filtIdx++, (void *)cffRPtr);
            if (filtComplex) ssSetPWorkValue(S, filtIdx++, (void *)cffIPtr);

            if (chan == numChans-1) *(memIdx) = mIdx;

            *mem0 += hpOrder;
            
            /* Lowpass Filter accesses the same inputs and has the same phase */
            memIdx = (int_T *) ssGetDWork(S, MemIdx) + filtIdx;
            pIdx = *phaseIdx;
            iIdx = *inIdx;
            mIdx = *(memIdx);
            cffRPtr = (real_T *) ssGetPWorkValue(S, filtIdx);

            if (level == numLevels-1) {
                oBuff    = *out;
                *out    += numSamps2;
                tinBuff1 = *wrBuff1;
            }
            else {
                oBuff   += numSamps2;
                tinBuff1 = false;
                iIdx     = 0;
            }

            if (filtComplex) {
                cffIPtr = (real_T *) ssGetPWorkValue(S,filtIdx+1);
                doFilter(S, iBuff, oBuff, (*sums)++, *mem0, numSamps, &pIdx, &mIdx, &iIdx,
                    &cffRPtr, &cffIPtr, lpOrder, mxGetPr(LFILT_ARG), mxGetPi(LFILT_ARG), &tinBuff1);
            }
            else {
                doFilter(S, iBuff, oBuff, (*sums)++, *mem0, numSamps, &pIdx, &mIdx, &iIdx,
                    &cffRPtr, NULL, lpOrder, mxGetPr(LFILT_ARG), NULL, &tinBuff1);
            }

            ssSetPWorkValue(S, filtIdx++, (void *)cffRPtr);

            if (filtComplex) ssSetPWorkValue(S, filtIdx++, (void *)cffIPtr);

            if (chan == numChans-1) *(memIdx) = mIdx;

            *mem0 += lpOrder;
            iBuff += numSamps;
            oBuff += numSamps2;
        }

        if (chan == numChans-1) {
            *phaseIdx = pIdx;
            *inIdx    = iIdx;
        }

        N *= M_ADIC;

        numSamps = numSamps2;
        swap     = inBuff;
        inBuff   = outBuff;
        outBuff  = swap;
    }

    /* Switch output buffers here */
    if (chan == numChans-1) *wrBuff1 = (boolean_T)(!(*wrBuff1));
}


void realSymm(SimStruct *S, real_T *inBuff, real_T *outBuff,
              real_T **out, real_T **sums, real_T **mem0, int_T numSamps,
              const int_T chan, const int_T numChans)
{
    const int_T numLevels = (int_T) *mxGetPr(LEVELS_ARG);
    const int_T lpOrder   = mxGetNumberOfElements(LFILT_ARG) - 1;
    const int_T hpOrder   = mxGetNumberOfElements(HFILT_ARG) - 1;
    boolean_T  *wrBuff1   = (boolean_T *) ssGetDWork(S, WrBuff1);
    boolean_T   tinBuff1  = false;
    int_T       pIdx      = 0;
    int_T       iIdx      = 0;
    int_T       filtIdx   = 0;
    int_T       N         = 1;
    int_T       level;
    int_T       j;
    real_T     *swap;
    
    for (level=0; level < numLevels; level++) {
        int_T  *phaseIdx  = (int_T *) ssGetDWork(S, PhaseIdx) + level;
        int_T  *inIdx     = (int_T *) ssGetDWork(S, InIdx) + level;
        int_T   numSamps2 = numSamps >> 1; /* integer divide by 2 */
        real_T *iBuff     = inBuff;
        real_T *oBuff     = outBuff;
        
        /* Process N pairs of filters for this level */
        for (j=0; j < N; j++) {
            int_T  *memIdx  = (int_T *) ssGetDWork(S, MemIdx) + filtIdx;
            const real_T *cffRPtr = (const real_T *) ssGetPWorkValue(S,filtIdx);
            int_T   mIdx    = *memIdx;

            pIdx = *phaseIdx;
            iIdx = *inIdx;

            /* Highpass filter*/
            if (level == numLevels-1) {
                oBuff    = *out;
                *out    += (numSamps >> 1); /* integer divide by 2 */
                tinBuff1 = *wrBuff1;
            }
            else {
                tinBuff1 = false;
                iIdx = 0;
            }

            doFilter(S, iBuff, oBuff, (*sums)++, *mem0, numSamps, &pIdx, &mIdx, &iIdx,
                &cffRPtr, NULL, hpOrder, mxGetPr(HFILT_ARG), NULL, &tinBuff1);

            ssSetPWorkValue(S, filtIdx++, (void *)cffRPtr);

            if (chan == numChans-1) *(memIdx) = mIdx;

            *mem0 += hpOrder;
            
            /* Lowpass Filter accesses the same inputs and has the same phase */
            memIdx = (int_T *) ssGetDWork(S, MemIdx) + filtIdx;
            pIdx = *phaseIdx;
            iIdx = *inIdx;
            mIdx = *(memIdx);
            cffRPtr = (real_T *) ssGetPWorkValue(S, filtIdx);

            if (level == numLevels-1) {
                oBuff    = *out;
                *out    += numSamps2;
                tinBuff1 = *wrBuff1;
            }
            else {
                oBuff   += numSamps2;
                tinBuff1 = false;
                iIdx     = 0;
            }

            doFilter(S, iBuff, oBuff, (*sums)++, *mem0, numSamps, &pIdx, &mIdx, &iIdx,
                &cffRPtr, NULL, lpOrder, mxGetPr(LFILT_ARG), NULL, &tinBuff1);

            ssSetPWorkValue(S, filtIdx++, (void *)cffRPtr);

            if (chan == numChans-1) *(memIdx) = mIdx;

            *mem0 += lpOrder;
            iBuff += numSamps;
            oBuff += numSamps2;
        } /* Filter pairs */

        if (chan == numChans-1) {
            *phaseIdx = pIdx;
            *inIdx    = iIdx;
        }

        N *= M_ADIC;

        numSamps = numSamps2;
        swap     = inBuff;
        inBuff   = outBuff;
        outBuff  = swap;
    } /* Levels */

    /* Switch output buffers here */
    if (chan == numChans-1) *wrBuff1 = (boolean_T)(!(*wrBuff1));
}


static void mdlOutputs(SimStruct *S, int_T tid)
{
    const boolean_T filtComplex = (boolean_T)mxIsComplex(LFILT_ARG);
    const boolean_T inComplex   = (boolean_T)(ssGetInputPortComplexSignal(S, INPORT) == COMPLEX_YES);
    const int_T     numOutputs  = ssGetNumOutputPorts(S);
    const int_T     tree        = (int_T) *mxGetPr(TREE_ARG);
    const int_T     numLevels   = (int_T) *mxGetPr(LEVELS_ARG);

    /* Update input and buffers */
    if (ssIsSampleHit(S, ssGetInputPortSampleTimeIndex(S, INPORT), tid)) {        
        const int_T     inPortWidth    = ssGetInputPortWidth(S, INPORT);
        const int_T     lpOrder        = mxGetNumberOfElements(LFILT_ARG) - 1;
        const int_T     hpOrder        = mxGetNumberOfElements(HFILT_ARG) - 1;
        const int_T     lpBuffSize     = ( ssGetDWorkWidth(S, FiltBuffer) >> 1 ); /* divide by 2 */
        const int_T     numInputs      = ssGetNumInputPorts(S);
        const boolean_T isMultiRate    = isBlockMultiRate(S,numInputs,numOutputs);
        int_T          *phaseIdx       = (int_T *) ssGetDWork(S, PhaseIdx);
        int_T          *memIdx         = (int_T *) ssGetDWork(S, MemIdx);
        int_T          *inIdx          = (int_T *) ssGetDWork(S, InIdx);
        int_T          *i2Idx          = (int_T *) ssGetDWork(S, I2Idx);
        int_T           numChans       = (int_T) *mxGetPr(CHANS_ARG);
        const boolean_T sampleBased    = (boolean_T) (numChans == SAMPLE_BASED);
        int_T           frame;
        int_T           i;
        int_T           k;

        if (sampleBased) {
            int_T	iIdx     = *i2Idx;
            int_T	minFrame = M_ADIC;

            numChans = inPortWidth;
            frame    = 1;

            /*
             * NOTE: We delay processing until we buffer the minimum number of
             * samples that are required to generate an entire output frame.
             * This may need to change for low-latency in single-tasking modes. xxx
             */

            for (i=1; i < numLevels; i++) minFrame *= M_ADIC;

            if (inComplex) {
                creal_T       *inBuff = (creal_T *) ssGetDWork(S, InputBuffer);
                InputPtrsType  uptr   = ssGetInputPortSignalPtrs(S, INPORT);

                for (k=0; k < numChans; k++) {
                    *(inBuff+iIdx) = *((creal_T *) *uptr++);
                    inBuff += minFrame;
                }
            }
            else {
                InputRealPtrsType uptr = ssGetInputPortRealSignalPtrs(S, INPORT);

                if (filtComplex) {
                    creal_T *inBuff = (creal_T *) ssGetDWork(S, InputBuffer);

                    for (k=0; k < numChans; k++) {
                        (inBuff+iIdx)->re = (**uptr++);
                        (inBuff+iIdx)->im = (real_T) 0.0;

                        inBuff += minFrame;
                    }
                }
                else {
                    real_T *inBuff = (real_T *) ssGetDWork(S, InputBuffer);
                    
                    for (k=0; k < numChans; k++) {
                        *(inBuff+iIdx) = (**uptr++);

                        inBuff += minFrame; /* xxx ??? 2*minFrame ??? xxx */
                    }
                }
            }

            if ( !( isModelMultiTasking(S) ) ) {
                /* "Multi-rate" currently only applies to sample-based configurations      */
                /* of the Dyadic Analysis block. In this special "single-tasking" case,    */
                /* there should be no latency - that is, the first output sample should    */
                /* be VALID based only on the filtered and resampled initial input sample. */
                /* If we are at this initial time, set the flags so that we will go to     */
                /* PROCESS_OUTPUTS immediately instead of waiting for "minFrame" samples.  */

                /* ------------------------------------------------------------------ */
                /* The cases which currently exhibit incorrect latency behavior are   */
                /* listed as follows:                                                 */
                /*                                                                    */
                /* 1) Symmetric,  Multi-rate (sample-based), single-tasking           */
                /*    [Latency should be zero, currently is one sample of an IC]      */
                /*                                                                    */
                /* 2) Asymmetric, Multi-rate (sample-based), single-tasking           */
                /*    [Latency should be zero, currently is 2^(levels-1) IC samples]  */
                /*                                                                    */
                /* 3) Asymmetric, Multi-rate (sample-based), multi-tsaking            */
                /*    [Latency should be one sample, just like it is for Symmetric,   */
                /*     currently the latency is 2^(levels-1) IC samples]              */
                /*                                                                    */
                /* The appropriate logic for proper pointer alignment/initialization  */
                /* must be added here when the algorithm is fixed for these cases.    */
                /* ------------------------------------------------------------------ */
                /* xxx need to modify i2Idx so that it doesn't skip the filtering (?) */
                /* xxx                     *i2Idx = minFrame;                     xxx */
                /* ------------------------------------------------------------------ */
            }

            if (++(*i2Idx) < minFrame) goto PROCESS_OUTPUTS; /* !!!NOTE JUMP IN CODE EXECUTION!!! */

            /* We have enough samples to process */
            frame = minFrame;
            *i2Idx = 0;
        } /* Sample-based */

        else { /* Frame-based operation */
            frame = inPortWidth / numChans;
        }


        /* ----------------------------------------------------------------------------- */
        /* Consider real data and a complex filter.  The output of the first level is    */
        /* complex, making the input to all subsequent levels complex.  For simplicity,  */
        /* we therefore treat the data at all levels as being complex.                   */
        /* ----------------------------------------------------------------------------- */


        /* The algorithm is fully documented for the real+real case.  The other
         * cases use the same algorithm.
         */
        if (inComplex || filtComplex) { 
            /* Complex Input */
            creal_T *lpBuff0 = ssGetDWork(S, FiltBuffer);
            creal_T *mem0    = ssGetDWork(S, States);
            creal_T *sums    = ssGetDWork(S, PartialSums);
            creal_T *out     = ssGetDWork(S, OutputBuffer);

            if (filtComplex) { /* Complex input, complex filter */
                InputPtrsType uptr = ssGetInputPortSignalPtrs(S, INPORT);

                for (k=0; k < numChans; k++) {
                    boolean_T *wrBuff1  = (boolean_T *) ssGetDWork(S, WrBuff1);
                    creal_T   *inBuff   = (creal_T *) ssGetDWork(S, InputBuffer);
                    int_T      numSamps = frame;
                    creal_T   *lpBuff   = lpBuff0;
                    int_T      pwIdx    = 0;
                    int_T      filtIdx  = 0;
                    int_T      i;

                    if (!sampleBased) {
                        if (inComplex) {
                            for (i=0; i < frame; i++) {
                                inBuff[i] = *((creal_T *) *uptr++);
                            }
                        }
                        else  {
                            for (i=0; i < frame; i++) {
                                inBuff[i].re = *(real_T *)*uptr++;
                                inBuff[i].im = (real_T) 0.0;
                            }
                        }
                    }
                    else inBuff += k*frame;

                    if (tree == SYMMETRIC) {
                        cmplxSymm(S, inBuff, lpBuff, &out, &sums, &mem0,
                            numSamps, k, numChans);
                    }
                    else {
                        for (i=0; i < numLevels; i++) {
                            int_T      pIdx     = phaseIdx[pwIdx];
                            int_T      iIdx     = inIdx[pwIdx];
                            int_T      mIdx     = memIdx[filtIdx];
                            const real_T *cffRPtr  = (const real_T *) ssGetPWorkValue(S, filtIdx);
                            const real_T *cffIPtr  = (const real_T *) ssGetPWorkValue(S, filtIdx+1);
                            boolean_T  tinBuff1 = *wrBuff1;
                            boolean_T  False    = false;

                            doFilter(S, inBuff, out, sums++, mem0, numSamps, &pIdx, &mIdx, &iIdx,
                                &cffRPtr, &cffIPtr, hpOrder, mxGetPr(HFILT_ARG), mxGetPi(HFILT_ARG), &tinBuff1);

                            if (k == numChans-1) memIdx[filtIdx] = mIdx;

                            ssSetPWorkValue(S, filtIdx++, (void *)cffRPtr);
                            ssSetPWorkValue(S, filtIdx++, (void *)cffIPtr);

                            mem0 += hpOrder;
                            pIdx = phaseIdx[pwIdx];
                            iIdx = inIdx[pwIdx];
                            mIdx = memIdx[filtIdx];

                            cffRPtr	= (real_T *) ssGetPWorkValue(S, filtIdx);
                            cffIPtr	= (real_T *) ssGetPWorkValue(S, filtIdx+1);

                            if (i == numLevels-1) {
                                out     += (numSamps >> 1);
                                tinBuff1 = *wrBuff1;

                                doFilter(S, inBuff, out, sums++, mem0, numSamps, &pIdx, &mIdx, &iIdx,
                                    &cffRPtr, &cffIPtr, lpOrder, mxGetPr(LFILT_ARG), mxGetPi(LFILT_ARG), &tinBuff1);
                            }
                            else doFilter(S, inBuff, lpBuff, sums++, mem0, numSamps, &pIdx, &mIdx, &iIdx,
                                &cffRPtr, &cffIPtr, lpOrder, mxGetPr(LFILT_ARG), mxGetPi(LFILT_ARG), &False);

                            if (k == numChans-1) {
                                phaseIdx[pwIdx] = pIdx;
                                inIdx[pwIdx]    = iIdx;
                                memIdx[filtIdx] = mIdx;
                                *wrBuff1        = tinBuff1;
                            }

                            ssSetPWorkValue(S, filtIdx++, (void *)cffRPtr);
                            ssSetPWorkValue(S, filtIdx++, (void *)cffIPtr);

                            inBuff = lpBuff;

                            if (lpBuff == lpBuff0) {
                                lpBuff = lpBuff0 + lpBuffSize;
                            }
                            else {
                                lpBuff = lpBuff0;
                            }

                            pwIdx++;
                            wrBuff1++;
                            mem0      += lpOrder;
                            numSamps >>= 1; /* integer divide by 2 */
                            out       += numSamps;
                        } /* Levels */
                    }
                } /* Channels */
            }
            else { /* Complex input, real filter */
                InputPtrsType uptr = ssGetInputPortSignalPtrs(S, INPORT);
                
                for (k=0; k < numChans; k++) {
                    boolean_T *wrBuff1  = (boolean_T *) ssGetDWork(S, WrBuff1);
                    creal_T   *inBuff   = (creal_T *) ssGetDWork(S, InputBuffer);
                    int_T      numSamps = frame;
                    creal_T   *lpBuff   = lpBuff0;
                    int_T      pwIdx    = 0;
                    int_T      filtIdx  = 0;
                    int_T      i;

                    if (!sampleBased) {
                        for (i=0; i < frame; i++) {
                            inBuff[i] = *((creal_T *) *uptr++);
                        }
                    }
                    else inBuff += k*frame;
                    
                    if (tree == SYMMETRIC) {
                        cmplxSymm(S, inBuff, lpBuff, &out, &sums, &mem0,
                            numSamps, k, numChans);
                    }
                    else {
                        for (i=0; i < numLevels; i++) {
                            int_T      pIdx     = phaseIdx[pwIdx];
                            int_T      iIdx     = inIdx[pwIdx];
                            int_T      mIdx     = memIdx[filtIdx];
                            const real_T *cffRPtr  = (const real_T *) ssGetPWorkValue(S, filtIdx);
                            boolean_T  tinBuff1 = *wrBuff1;
                            boolean_T  False    = false;
                            
                            doFilter(S, inBuff, out, sums++, mem0, numSamps, &pIdx, &mIdx, &iIdx,
                                &cffRPtr, NULL, hpOrder, mxGetPr(HFILT_ARG), NULL, &tinBuff1);

                            if (k == numChans-1) memIdx[filtIdx] = mIdx;

                            ssSetPWorkValue(S, filtIdx++, (void *)cffRPtr);
                            mem0 += hpOrder;
                            pIdx = phaseIdx[pwIdx];
                            iIdx = inIdx[pwIdx];
                            mIdx = memIdx[filtIdx];
                            cffRPtr	= (real_T *) ssGetPWorkValue(S, filtIdx);

                            if (i == numLevels-1) {
                                out     += (numSamps >> 1);
                                tinBuff1 = *wrBuff1;

                                doFilter(S, inBuff, out, sums++, mem0, numSamps, &pIdx, &mIdx, &iIdx,
                                    &cffRPtr, NULL, lpOrder, mxGetPr(LFILT_ARG), NULL, &tinBuff1);
                            }
                            else doFilter(S, inBuff, lpBuff, sums++, mem0, numSamps, &pIdx, &mIdx, &iIdx,
                                &cffRPtr, NULL, lpOrder, mxGetPr(LFILT_ARG), NULL, &False);

                            if (k == numChans-1) {
                                phaseIdx[pwIdx] = pIdx;
                                inIdx[pwIdx]    = iIdx;
                                memIdx[filtIdx] = mIdx;
                                *wrBuff1        = tinBuff1;
                            }

                            ssSetPWorkValue(S, filtIdx++, (void *)cffRPtr);

                            inBuff = lpBuff;

                            if (lpBuff == lpBuff0) {
                                lpBuff = lpBuff0 + lpBuffSize;
                            }
                            else {
                                lpBuff = lpBuff0;
                            }

                            ++pwIdx;
                            ++wrBuff1;
                            mem0      += lpOrder;
                            numSamps >>= 1; /* integer divide by 2 */
                            out       += numSamps;
                        } /* Levels */
                    }
                } /* Channels */
            } /* Real Filter */
        }
        else {
            real_T *mem0 = (real_T *) ssGetDWork(S, States);
            
            {
                /* Real Data, Complex Filter */
                /* This case does not occur since we set inComplex = true */
            }

            { 
                /* Real Data, Real Filter */
                real_T            *lpBuff0 = ssGetDWork(S, FiltBuffer);
                real_T            *out     = ssGetDWork(S, OutputBuffer);
                real_T            *sums    = ssGetDWork(S, PartialSums);
                InputRealPtrsType  uptr    = ssGetInputPortRealSignalPtrs(S, INPORT);
                
                for (k=0; k < numChans; k++) {
                    boolean_T *wrBuff1  = (boolean_T *) ssGetDWork(S, WrBuff1);
                    real_T    *inBuff   = (real_T *) ssGetDWork(S, InputBuffer);
                    int_T      numSamps = frame;
                    real_T    *lpBuff   = lpBuff0;
                    int_T      pwIdx    = 0;
                    int_T      filtIdx  = 0;
                    int_T      i;

                    /* If frame-based, fill buffer for level 0 */
                    if (!sampleBased) {
                        for (i=0; i < frame; i++) {
                            inBuff[i] = (**uptr++);
                        }
                    }
                    else {
                        /* Assume that inBuff is already full xxx */
                        inBuff += k * frame;
                    }
                    
                    if (tree == SYMMETRIC) {
                        /* The symmetric case */
                        realSymm(S, inBuff, lpBuff, &out, &sums, &mem0,
                            numSamps, k, numChans);
                    }
                    else {
                        for (i=0; i < numLevels; i++) {
                            int_T      pIdx     = phaseIdx[pwIdx];
                            int_T      iIdx     = inIdx[pwIdx];
                            int_T      mIdx     = memIdx[filtIdx];
                            const real_T *cffRPtr  = (const real_T *) ssGetPWorkValue(S, filtIdx);
                            boolean_T  tinBuff1 = *wrBuff1;
                            boolean_T  False    = false;

                            /* Highpass filter */
                            doFilter(S, inBuff, out, sums++, mem0, numSamps, &pIdx, &mIdx, &iIdx,
                                &cffRPtr, NULL, hpOrder, mxGetPr(HFILT_ARG), NULL, &tinBuff1);

                            if (k == numChans-1) memIdx[filtIdx] = mIdx;

                            ssSetPWorkValue(S, filtIdx++, (void *)cffRPtr);
                            mem0 += hpOrder;


                            /* Lowpass Filter accesses the same inputs and has the same phase */
                            pIdx    = phaseIdx[pwIdx];
                            iIdx    = inIdx[pwIdx];
                            mIdx    = memIdx[filtIdx];
                            cffRPtr = (const real_T *) ssGetPWorkValue(S, filtIdx);

                            if (i == numLevels-1) {
                                /* The last lowpass bank gets written out */
                                out     += (numSamps >> 1);
                                tinBuff1 = *wrBuff1;

                                doFilter(S, inBuff, out, sums++, mem0, numSamps, &pIdx, &mIdx, &iIdx,
                                    &cffRPtr, NULL, lpOrder, mxGetPr(LFILT_ARG), NULL, &tinBuff1);
                            }
                            else {
                                doFilter(S, inBuff, lpBuff, sums++, mem0, numSamps, &pIdx, &mIdx, &iIdx,
                                    &cffRPtr, NULL, lpOrder, mxGetPr(LFILT_ARG), NULL, &False);
                            }

                            if (k == numChans-1) {
                                /* Update the counters and the output buffer selector */
                                phaseIdx[pwIdx] = pIdx;
                                inIdx[pwIdx]    = iIdx;
                                memIdx[filtIdx] = mIdx;
                                *wrBuff1        = tinBuff1;
                            }

                            ssSetPWorkValue(S, filtIdx++, (void *)cffRPtr);


                            /* Next input frame is the output of the lowpass filter */
                            inBuff = lpBuff;

                            if (lpBuff == lpBuff0) {
                                lpBuff = lpBuff0 + lpBuffSize;
                            }
                            else {
                                lpBuff = lpBuff0;
                            }

                            ++pwIdx;
                            ++wrBuff1;
                            mem0      += lpOrder;
                            numSamps >>= 1; /* integer divide by 2 */
                            out       += numSamps;
                        } /* Levels */
                    }
                } /* Channels */
            } /* Real Filter */
        } /* Real Data */
    } /* ssIsSampleHit(inportTid) */


PROCESS_OUTPUTS:

    /****************************************************/
    /*                      Outputs                     */
    {
        const int_T     outBuffSize = ( ssGetDWorkWidth(S, OutputBuffer) >> 1 ); /* divide by 2 */
        int_T          *outIdx      = (int_T *) ssGetDWork(S, OutIdx);
        int_T           offset      = 0;
        int_T           numChans    = (int_T) *mxGetPr(CHANS_ARG);
        int_T           chanSize;
        int_T           frame;
        int_T           k;
        
        if (tree == ASYMMETRIC) {
            /* The iterative filtering routine has the outputs grouped by channel */
            if (numChans == SAMPLE_BASED) { /* Output ports have width=numChans but different sample times */
                frame = 1;

                for (k=1; k < numLevels; k++) frame *= M_ADIC;

                numChans = ssGetInputPortWidth(S, INPORT);
                chanSize = 2*frame;

                for (k=0; k < numOutputs; k++) {
                    if (ssIsSampleHit(S, ssGetOutputPortSampleTimeIndex(S, k), tid)) {
                        int_T	i;

                        if (inComplex || filtComplex) {
                            creal_T	*yout	= (creal_T *) ssGetOutputPortSignal(S, k);
                            creal_T	*y    = (creal_T *) ssGetDWork(S, OutputBuffer) + offset + *outIdx;

                            if (*outIdx >= frame) y += (outBuffSize - frame);

                            for (i=0; i < numChans; i++) {
                                *yout++  = *y;
                                y       += chanSize;
                            }
                        }
                        else {
                            real_T *yout = ssGetOutputPortRealSignal(S, k);
                            real_T *y    = (real_T *) ssGetDWork(S, OutputBuffer) + offset + *outIdx;

                            if (*outIdx >= frame) y += (outBuffSize - frame);

                            for (i=0; i < numChans; i++) {
                                *yout++  = *y;
                                y       += chanSize;
                            }
                        }

                        if (++(*outIdx) >= 2*frame) *outIdx = 0;
                    }

                    ++outIdx;
                    offset += frame;

                    if (k < numLevels-1) {
                        frame >>= 1; /* integer divide by 2 */
                    }
                }
            }
            else { /* Output ports have the same sample time but different widths */
                if (!ssIsSampleHit(S, ssGetOutputPortSampleTimeIndex(S, 0), tid)) return;

                frame    = ssGetOutputPortWidth(S, 0) / numChans;
                chanSize = frame*2;

                for (k=0; k < numOutputs; k++) {
                    const int_T outPortWidth = ssGetOutputPortWidth(S, k) / numChans;
                    int_T i, j;

                    if (inComplex || filtComplex) {
                        creal_T *yout = (creal_T *) ssGetOutputPortSignal(S, k);
                        creal_T *y    = (creal_T *) ssGetDWork(S, OutputBuffer) + offset;

                        if (*outIdx > 0) y += outBuffSize;

                        for (j=0; j < numChans; j++) {
                            for (i=0; i < outPortWidth; i++) *yout++ = *(y + i);

                            y += chanSize;
                        }
                    }
                    else {
                        real_T *yout = ssGetOutputPortRealSignal(S, k);
                        real_T *y    = (real_T *) ssGetDWork(S, OutputBuffer) + offset;

                        if (*outIdx > 0) y += outBuffSize;

                        for (j=0; j < numChans; j++) {
                            for (i=0; i < outPortWidth; i++) *yout++ = *(y + i);

                            y += chanSize;
                        }
                    }

                    if (*outIdx > 0) *outIdx = 0;
                    else *outIdx = 1;

                    ++outIdx;
                    offset += frame;

                    if (k < numLevels-1) frame >>= 1; /* integer divide by 2 */
                }
            }
        }
        else {
            /* Symmetric Tree: all output ports have same sample time and same width.
             * The iterative filtering routine has the outputs grouped by channel.
             */

            if (ssIsSampleHit(S, ssGetOutputPortSampleTimeIndex(S, 0), tid)) {

                const int_T     outPortWidth = ssGetOutputPortWidth(S, 0);
                const boolean_T sampleBased  = (boolean_T)(numChans == SAMPLE_BASED);
                int_T           i;
                int_T           j;
                
                if (sampleBased) numChans = ssGetInputPortWidth(S, INPORT);
                
                frame = outPortWidth / numChans;
                chanSize = numOutputs * frame;
                
                if (inComplex || filtComplex) {
                    for (k=0; k < numOutputs; k++) {
                        creal_T *yout = (creal_T *) ssGetOutputPortSignal(S, k);
                        creal_T *y    = (creal_T *) ssGetDWork(S, OutputBuffer) + offset;

                        if (*outIdx > 0) y += outBuffSize;

                        for (j=0; j < numChans; j++) {
                            if (sampleBased) {
                                *yout++  = *y;
                                y       += chanSize;
                            }
                            else {
                                for (i=0; i < frame; i++) *yout++ = *y++;

                                y += chanSize - frame;
                            }
                        }

                        offset += frame;
                    }
                }
                else {
                    for (k=0; k < numOutputs; k++) {
                        real_T *yout = ssGetOutputPortRealSignal(S, k);
                        real_T *y    = (real_T *) ssGetDWork(S, OutputBuffer) + offset;

                        if (*outIdx > 0) y += outBuffSize;

                        for (j=0; j < numChans; j++) {
                            if (sampleBased) {
                                *yout++ = *y;
                                y += chanSize;
                            }
                            else {
                                for (i=0; i < frame; i++) *yout++ = *y++;

                                y += chanSize - frame;
                            }
                        }

                        offset += frame;
                    }
                }

                if (*outIdx > 0) *outIdx = 0;
                else *outIdx = 1;
            }
        } /* Symmetric tree */
        
  } /* Outputs section */
} /* mdlOutput */


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
    const int_T numLevels = (int_T) *mxGetPr(LEVELS_ARG);
    const int_T numChans  = (int_T) *mxGetPr(CHANS_ARG);
    const int_T tree      = (int_T) *mxGetPr(TREE_ARG);
    int_T       numOutputs;
    int_T       i;
    
    ssSetInputPortSampleTime(S, portIdx, sampleTime);
    ssSetInputPortOffsetTime(S, portIdx, offsetTime);
  
    /* Only compute and check sample times if port is connected */
    if (ssGetInputPortConnected(S,portIdx)) {	
        
        if (sampleTime == CONTINUOUS_SAMPLE_TIME) { 
            THROW_ERROR(S,"Continuous output sample times not allowed for dyadic analysis."); 
        } 
        
        if (offsetTime != 0.0) {
            THROW_ERROR(S, "Non-zero sample time offsets not allowed.");
        }
        
        numOutputs = M_ADIC;
        for (i=1; i < numLevels; i++) numOutputs *= M_ADIC;
        
        if (tree == SYMMETRIC && numChans == SAMPLE_BASED) {
            sampleTime *= numOutputs;
        }
        if (tree == ASYMMETRIC) numOutputs = numLevels + 1;
        
        for (i=0; i < numOutputs; i++) {
            if (tree == ASYMMETRIC && numChans == SAMPLE_BASED && i != numLevels) sampleTime *= 2.0;
            ssSetOutputPortSampleTime(S, i, sampleTime);
            ssSetOutputPortOffsetTime(S, i, 0.0);
        }
    }
}


#define MDL_SET_OUTPUT_PORT_SAMPLE_TIME
static void mdlSetOutputPortSampleTime(SimStruct *S,
                                       int_T     portIdx,
                                       real_T    sampleTime,
                                       real_T    offsetTime)
{
    ssSetOutputPortSampleTime(S, portIdx, sampleTime);
    ssSetOutputPortOffsetTime(S, portIdx, 0.0);

    /* Only compute and check sample times if port is connected */
    if (ssGetOutputPortConnected(S,portIdx)) {	

        if (sampleTime == CONTINUOUS_SAMPLE_TIME) {
            THROW_ERROR(S,"Continuous sample times not allowed for dyadic analysis block.");
        }
        
        if (offsetTime != 0.0) {
            ssSetErrorStatus(S, "Non-zero sample time offsets not allowed.");
            return;
        }
    }
}
#endif


#ifdef MATLAB_MEX_FILE
#define MDL_SET_INPUT_PORT_WIDTH
static void mdlSetInputPortWidth(SimStruct *S, int_T port, int_T inputPortWidth)
{
    const int_T numChans    = (int_T) *mxGetPr(CHANS_ARG);
    const int_T numLevels   = (int_T) *mxGetPr(LEVELS_ARG);
    const int_T tree        = (int_T) *mxGetPr(TREE_ARG);
    int_T       minWidth;
    int_T       outputPortWidth;
    int_T       numOutputs;
    int_T       i;
    
    ssSetInputPortWidth (S, port, inputPortWidth);
    
    minWidth = 2;
    for (i=1; i < numLevels; i++) minWidth *= 2;
    if (tree == ASYMMETRIC) numOutputs = numLevels + 1;
    else numOutputs = minWidth;
    
    if (numChans != SAMPLE_BASED) {
        /* Check if input port width is acceptable */
        if ((inputPortWidth % minWidth) != 0) {
            ssSetErrorStatus(S,"The input frame size must be a multiple of "
                "2^(number of levels)");
            return;
        }

        if (tree == ASYMMETRIC) minWidth = inputPortWidth;
        else minWidth = inputPortWidth / minWidth;
        
        for (i=0; i < numOutputs; i++) {
            outputPortWidth = ssGetOutputPortWidth(S, i);

            if (tree == ASYMMETRIC && i != numLevels) minWidth >>= 1; /* integer divide by 2 */

            if (outputPortWidth == DYNAMICALLY_SIZED && (inputPortWidth % minWidth) == 0) {
                ssSetOutputPortWidth(S, i, minWidth);
            }
            else if (outputPortWidth != minWidth) {
                ssSetErrorStatus (S, "(Input port width)/(Output port width) "
                    "must equal the decimation factor at each output level");
                return;
            }
        }
    }
    else {
        for (i=0; i < numOutputs; i++) {
            outputPortWidth = ssGetOutputPortWidth(S, i);

            if (outputPortWidth == DYNAMICALLY_SIZED) {
                ssSetOutputPortWidth(S, i, inputPortWidth);
            }
            else if (outputPortWidth != inputPortWidth) {
                ssSetErrorStatus (S, "Input port width must equal output port width");
                return;
            }
        }
    }
}


#define MDL_SET_OUTPUT_PORT_WIDTH
static void mdlSetOutputPortWidth(SimStruct *S, int_T port, int_T outputPortWidth)
{
    const int_T numLevels   = (int_T) *mxGetPr(LEVELS_ARG);
    const int_T numChans    = (int_T) *mxGetPr(CHANS_ARG);
    const int_T tree        = (int_T) *mxGetPr(TREE_ARG);
    int_T       inWidth	    = outputPortWidth;
    int_T       minWidth;
    int_T       i;

    if (numChans != SAMPLE_BASED) {
        if (tree == ASYMMETRIC) {
            for (i=port; i >= 0; i--) inWidth *= 2;

            if (port == numLevels) inWidth >>= 1; /* integer divide by 2 */
        }
        else {
            for (i=0; i < numLevels; i++) inWidth *= 2;
        }
    }
    
    if (ssGetInputPortWidth(S, INPORT) == DYNAMICALLY_SIZED) {
        ssSetInputPortWidth (S, INPORT, inWidth);
    }
    
    if (numChans != SAMPLE_BASED) {
        if (tree == ASYMMETRIC ) {
            minWidth = inWidth;
        }
        else {
            minWidth = outputPortWidth;
        }

        for (i=0; i <= numLevels; i++) {
            outputPortWidth = ssGetOutputPortWidth(S, i);

            if (tree == ASYMMETRIC && i != numLevels) minWidth >>= 1; /* integer divide by 2 */

            if (outputPortWidth == DYNAMICALLY_SIZED && (inWidth % minWidth) == 0) {
                ssSetOutputPortWidth(S, port, minWidth);
            }
            else if (outputPortWidth != minWidth) {
                ssSetErrorStatus (S, "(Input port width)/(Output port width) "
                    "must equal the decimation factor at each output level");
                return;
            }
        }
    }
    else {
        for (i=0; i <= numLevels; i++) {
            outputPortWidth = ssGetOutputPortWidth(S, i);

            if (outputPortWidth == DYNAMICALLY_SIZED) {
                ssSetOutputPortWidth(S, i, inWidth);
            }
            else if (outputPortWidth != inWidth) {
                ssSetErrorStatus (S, "Input port width must equal output port width");
                return;
            }
        }
    }
}


#define MDL_SET_INPUT_PORT_COMPLEX_SIGNAL
static void mdlSetInputPortComplexSignal(SimStruct *S, int_T portIdx,
                                         CSignal_T      iPortComplexSignal)
{
    const int_T numLevels   = (int_T) *mxGetPr(LEVELS_ARG);
    int_T       i, numOutputs;

    ssSetInputPortComplexSignal(S, portIdx, iPortComplexSignal ? COMPLEX_YES : COMPLEX_NO);
    
    if ( ((int_T) *mxGetPr(TREE_ARG)) == ASYMMETRIC ) {
        numOutputs = numLevels + 1;
    }
    else {
        numOutputs = M_ADIC;

        for (i=1; i < numLevels; i++) numOutputs *= M_ADIC;
    }
    
    for (i=0; i < numOutputs; i++) {
        if (ssGetOutputPortComplexSignal(S, i) == COMPLEX_INHERITED) {
            if (mxIsComplex(LFILT_ARG) || mxIsComplex(HFILT_ARG)) {
                ssSetOutputPortComplexSignal(S, i, COMPLEX_YES);
            }
            else {
                ssSetOutputPortComplexSignal(S, i, iPortComplexSignal ? COMPLEX_YES : COMPLEX_NO);
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
#endif


#ifdef MATLAB_MEX_FILE
#define MDL_SET_WORK_WIDTHS
static void mdlSetWorkWidths(SimStruct *S)
{
    const boolean_T inputComplex = (boolean_T)(ssGetInputPortComplexSignal(S, INPORT) == COMPLEX_YES);
    const boolean_T filtComplex  = (boolean_T)(mxIsComplex(LFILT_ARG) || mxIsComplex(HFILT_ARG));
    const int_T     inPortWidth  = ssGetInputPortWidth(S, INPORT);
    const int_T     numLevels    = (int_T) *mxGetPr(LEVELS_ARG);
    const int_T     tree         = (int_T) *mxGetPr(TREE_ARG);
    const int_T     lpOrder      = mxGetNumberOfElements(LFILT_ARG) - 1;
    const int_T     hpOrder      = mxGetNumberOfElements(HFILT_ARG) - 1;
    const int_T     numOutputs   = ssGetNumOutputPorts(S);
    int_T           numChans     = (int_T) *mxGetPr(CHANS_ARG);
    int_T           minFrame     = M_ADIC;
    int_T           numFiltersTotal;
    int_T           i;
    
    if (numChans == SAMPLE_BASED) {
        numChans = inPortWidth;
    }
    
    /* Compute the minimum input frame size */
    if ( ((int_T) *mxGetPr(CHANS_ARG)) == SAMPLE_BASED ) {
        for (i=1; i < numLevels; i++) {
            minFrame *= M_ADIC;  /* M^(numLevels-1) xxx  M^numLevels */
        }
    }
    else {
        minFrame = inPortWidth / numChans;
    }
    
    /* Compute the number of filters */
    if (tree == ASYMMETRIC) {
        /* The asymmetric case simply has M_ADIC filters   */
        /* for each and every level of the tree structure. */
        numFiltersTotal = M_ADIC*numLevels;
    }
    else {
        /* The symmetric case has M_ADIC filters following each     */
        /* branch of the tree. The number of branches for each      */
        /* level is equal to the level number, so each level has    */
        /* 2^(level) number of filters. If we add each of these     */
        /* nums of "filters per level" together, we get the answer. */
        int_T numFiltsThisLevel = M_ADIC;

        numFiltersTotal = M_ADIC;

        for (i=1; i < numLevels; i++) {
            numFiltsThisLevel *= M_ADIC;
            numFiltersTotal   += numFiltsThisLevel;
        }
    }
    
    ssSetNumDWork(S, NUM_DWORKS);
    
    /* Set up output port double buffer */
    ssSetDWorkWidth(   S,   OutputBuffer, 2*minFrame*numChans);
    ssSetDWorkDataType(S,   OutputBuffer, SS_DOUBLE);
    ssSetDWorkName(    S,   OutputBuffer, "OutBuff");

    /* Filter buffer */
    ssSetDWorkWidth(   S,   FiltBuffer,   minFrame);
    ssSetDWorkDataType(S,   FiltBuffer,   SS_DOUBLE);
    ssSetDWorkName(    S,   FiltBuffer,   "FiltBuff");
    
    ssSetDWorkWidth(   S,   States,       numChans * (lpOrder + hpOrder) * (numFiltersTotal >> 1) );
    ssSetDWorkDataType(S,   States,       SS_DOUBLE);
    ssSetDWorkName(    S,   States,       "States");
    
    ssSetDWorkWidth(   S,   PartialSums,  numFiltersTotal*numChans);
    ssSetDWorkDataType(S,   PartialSums,  SS_DOUBLE);
    ssSetDWorkName(    S,   PartialSums,  "PartialSums");

    if ( ((int_T) *mxGetPr(CHANS_ARG)) == SAMPLE_BASED ) {
        /* Need to buffer the input from all channels */
        ssSetDWorkWidth(S,  InputBuffer,  numChans*minFrame);
    }
    else {
        ssSetDWorkWidth(S,  InputBuffer, minFrame);
    }
    ssSetDWorkDataType( S,  InputBuffer, SS_DOUBLE);
    ssSetDWorkName(     S,  InputBuffer, "InBuff");

    if (inputComplex || filtComplex) {
        ssSetDWorkComplexSignal(S,  States,         COMPLEX_YES);
        ssSetDWorkComplexSignal(S,  OutputBuffer,   COMPLEX_YES);
        ssSetDWorkComplexSignal(S,  FiltBuffer,     COMPLEX_YES);
        ssSetDWorkComplexSignal(S,  PartialSums,    COMPLEX_YES);
        ssSetDWorkComplexSignal(S,  InputBuffer,    COMPLEX_YES);

        ssSetDWorkWidth(        S,  MemIdx,         2*numFiltersTotal);
    }
    else { 
        ssSetDWorkWidth(        S,  MemIdx, numFiltersTotal); /* MemIdx: filter state history index */
    }

    ssSetDWorkDataType(         S,  MemIdx, SS_INT32);
    ssSetDWorkName(             S,  MemIdx, "MemIdx");
    
    if (tree == ASYMMETRIC) {
        ssSetDWorkWidth(S,      OutIdx,     numOutputs);
        ssSetDWorkWidth(S,      WrBuff1,    numLevels);
    }
    else {
        ssSetDWorkWidth(S,      OutIdx,     1);
        ssSetDWorkWidth(S,      WrBuff1,    1);
    }
    ssSetDWorkDataType(S,       OutIdx,     SS_INT32);
    ssSetDWorkDataType(S,       WrBuff1,    SS_BOOLEAN);
    ssSetDWorkName(    S,       OutIdx,    "OutIdx");
    ssSetDWorkName(    S,       WrBuff1,    "WrBuff1");
    
    ssSetDWorkWidth(   S,       PhaseIdx,   numLevels);
    ssSetDWorkDataType(S,       PhaseIdx,   SS_INT32);
    ssSetDWorkName(    S,       PhaseIdx,   "PhaseIdx");

    ssSetDWorkWidth(   S,       InIdx,      numLevels);
    ssSetDWorkDataType(S,       InIdx,      SS_INT32);
    ssSetDWorkName(    S,       InIdx,      "InIdx");

    ssSetDWorkWidth(   S,       I2Idx,      1);
    ssSetDWorkDataType(S,       I2Idx,      SS_INT32);
    ssSetDWorkName(    S,       I2Idx,      "I2Idx");
}
#endif


#define MDL_RTW
#if defined(MATLAB_MEX_FILE) || defined(NRT)
static void mdlRTW(SimStruct *S)
{
    int32_T levels   = (int32_T) *mxGetPr(LEVELS_ARG);
    int32_T tree     = (int32_T) *mxGetPr(TREE_ARG);
    int32_T numChans = (int32_T) *mxGetPr(CHANS_ARG);
    
    if (!ssWriteRTWParamSettings(S, 5,
        SSWRITE_VALUE_DTYPE_ML_VECT, "LFILT",
        mxGetPr(LFILT_ARG), mxGetPi(LFILT_ARG),
        mxGetNumberOfElements(LFILT_ARG),
        DTINFO(SS_DOUBLE, mxIsComplex(LFILT_ARG)),
        
        SSWRITE_VALUE_DTYPE_ML_VECT, "HFILT",
        mxGetPr(HFILT_ARG), mxGetPi(HFILT_ARG),
        mxGetNumberOfElements(HFILT_ARG),
        DTINFO(SS_DOUBLE, mxIsComplex(HFILT_ARG)),
        
        SSWRITE_VALUE_DTYPE_NUM, "LEVELS",
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
