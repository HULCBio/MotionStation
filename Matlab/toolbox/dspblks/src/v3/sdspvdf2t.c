/*
 *  SDSPVDF2T: SIMULINK multichannel IIR (Direct Form II Transposed) filter block.
 *  DSP Blockset S-Function for TIME_VARYING multichannel IIR filtering.
 *  Supports real or complex data and filters for parallel sample-based filtering
 *  or for frame-based filtering.
 *
 *   
 *  Copyright 1995-2002 The MathWorks, Inc.
 *  $Revision: 1.26 $  $Date: 2002/04/14 20:41:39 $
 */

#define S_FUNCTION_LEVEL 2
#define S_FUNCTION_NAME sdspvdf2t

#include "dsp_sim.h"


/* Argument list for a time-varying filter */
enum {ARGC_NUM_DEN, ARGC_IC, ARGC_CHECK, ARGC_CHANS, ARGC_FILT_PER_FRAME, NUM_ARGS};
#define NUM_DEN_ARG     ssGetSFcnParam(S,ARGC_NUM_DEN)/* Numerator? Denominator? */
#define IC_ARG          ssGetSFcnParam(S,ARGC_IC)    /* Initial Conditions */
#define CHECK_ARG       ssGetSFcnParam(S,ARGC_CHECK)    /* Check for non-normalized */
#define CHANS_ARG       ssGetSFcnParam(S,ARGC_CHANS) /* Number of Channels */

/* One filter per frame?, otherwise one filter per sample time */
#define FILT_PER_FRAME_ARG      ssGetSFcnParam(S,ARGC_FILT_PER_FRAME)
enum {UPDATE_EVERY_SAMPLE=1, UPDATE_EVERY_FRAME};

/* An invalid number of channels is used to flag sample-based operation */
const int_T SAMPLE_BASED = -1;

/* Values from NUM_ARG_DEN pop-up box */
enum {PoleZero=1, AllZero, AllPole};

/* Port index enumerations */
enum {InPort=0, CoeffPort1, CoeffPort2, MAX_NUM_INPORTS};
enum {OutPort=0, NUM_OUTPORTS};

/* Indices for DWork */
enum {Coeffs=0, DiscState, NUM_DWORKS};

/* Indices for the Flags */
enum {Num, Den, DataComplex, FiltComplex, NumComplex, DenComplex, NUM_FLAGS};
typedef struct {
    boolean_T   Flags[NUM_FLAGS];
    boolean_T   Normalized;
} SFcnCache;

#ifdef MATLAB_MEX_FILE
#define MDL_CHECK_PARAMETERS
static void mdlCheckParameters(SimStruct *S) {
    const boolean_T runTime = (ssGetSimMode(S) != SS_SIMMODE_SIZES_CALL_ONLY);
    
    if (runTime || !mxIsEmpty(CHANS_ARG)) {
        if ( mxGetNumberOfElements(CHANS_ARG) != 1 || mxGetPr(CHANS_ARG)[0] != (int_T)mxGetPr(CHANS_ARG)[0]
            || (mxGetPr(CHANS_ARG)[0] <= 0 && mxGetPr(CHANS_ARG)[0] != SAMPLE_BASED)) {
            THROW_ERROR(S, "The number of channels must be an integer >= 1. "
                         "If it is -1, the number of channels equals the input port width");
        }
    }

    /* The next two inputs are from pop-up dialogs so they SHOULD be valid */
    if ( mxGetNumberOfElements(FILT_PER_FRAME_ARG) != 1 || (mxGetPr(FILT_PER_FRAME_ARG)[0] != UPDATE_EVERY_SAMPLE 
        && mxGetPr(FILT_PER_FRAME_ARG)[0] != UPDATE_EVERY_FRAME)) {
        THROW_ERROR(S, "Filter update rate must be 1=update every sample, or 2=update every frame.");
    }
    
    if ( (mxGetNumberOfElements(NUM_DEN_ARG) != 1) ||
         (mxGetPr(NUM_DEN_ARG)[0] < 1)  ||
         (mxGetPr(NUM_DEN_ARG)[0] > 3) ||
         (mxGetPr(NUM_DEN_ARG)[0] != (int_T)mxGetPr(NUM_DEN_ARG)[0])
       ) {
        THROW_ERROR(S, "Filter structure must be 1=PoleZero, 2=FIR, or 3=AllPole.");
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

    ssSetSFcnParamNotTunable(S, ARGC_NUM_DEN);
    ssSetSFcnParamNotTunable(S, ARGC_IC);
    ssSetSFcnParamNotTunable(S, ARGC_CHECK);
    ssSetSFcnParamNotTunable(S, ARGC_CHANS);
    ssSetSFcnParamNotTunable(S, ARGC_FILT_PER_FRAME);

    ssSetNumSampleTimes(S, PORT_BASED_SAMPLE_TIMES);
    
    if ((int_T) mxGetPr(NUM_DEN_ARG)[0] == PoleZero) {
        /* CoeffPort1 = Numerator, CoeffPort2 = Denominator */
        if (!ssSetNumInputPorts(S, 3)) return;
        ssSetInputPortWidth(            S, CoeffPort2, DYNAMICALLY_SIZED);
        ssSetInputPortComplexSignal(    S, CoeffPort2, COMPLEX_INHERITED);
        ssSetInputPortDirectFeedThrough(S, CoeffPort2, 1);
        ssSetInputPortReusable(         S, CoeffPort2, 1);
        ssSetInputPortOverWritable(     S, CoeffPort2, 0);
        ssSetInputPortSampleTime(       S, CoeffPort2, INHERITED_SAMPLE_TIME);

    } else {
        /* Either AllZero or AllPole */
        if (!ssSetNumInputPorts(S, 2)) return;
    }
    ssSetInputPortWidth(            S, InPort, DYNAMICALLY_SIZED);
    ssSetInputPortComplexSignal(    S, InPort, COMPLEX_INHERITED);
    ssSetInputPortDirectFeedThrough(S, InPort, 1);
    ssSetInputPortReusable(         S, InPort, 1);
    ssSetInputPortOverWritable(     S, InPort, 0);
    ssSetInputPortSampleTime(       S, InPort, INHERITED_SAMPLE_TIME);

    ssSetInputPortWidth(            S, CoeffPort1, DYNAMICALLY_SIZED);
    ssSetInputPortComplexSignal(    S, CoeffPort1, COMPLEX_INHERITED);
    ssSetInputPortDirectFeedThrough(S, CoeffPort1, 1);
    ssSetInputPortReusable(         S, CoeffPort1, 1);
    ssSetInputPortOverWritable(     S, CoeffPort1, 0);
    ssSetInputPortSampleTime(       S, CoeffPort1, INHERITED_SAMPLE_TIME);
    
    if (!ssSetNumOutputPorts(S, NUM_OUTPORTS)) return;

    ssSetOutputPortWidth(        S, OutPort, DYNAMICALLY_SIZED);
    ssSetOutputPortComplexSignal(S, OutPort, COMPLEX_INHERITED);
    ssSetOutputPortReusable(     S, OutPort, 1);
    ssSetOutputPortSampleTime(   S, OutPort, INHERITED_SAMPLE_TIME);
    
    if(!ssSetNumDWork(S, DYNAMICALLY_SIZED)) return;
   
    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE);
}


/* Set all ports to identical, discrete rates: */
#include "dsp_ctrl_ts.c"


#define MDL_START
static void mdlStart (SimStruct *S)
{
#ifdef MATLAB_MEX_FILE
    const int_T coeffPort1Width     = ssGetInputPortWidth(S, CoeffPort1);
    const int_T numIC               = mxGetNumberOfElements(IC_ARG);
    int_T       numChans            = (int_T) mxGetPr(CHANS_ARG)[0];
    const int_T portWidth           = ssGetInputPortWidth(S, InPort);
    int_T       NumDen              = (int_T) mxGetPr(NUM_DEN_ARG)[0];
    boolean_T   oneFilterPerFrame   = ((int_T)mxGetPr(FILT_PER_FRAME_ARG)[0] == UPDATE_EVERY_FRAME);
    boolean_T   coeffPort1Complex   = (ssGetInputPortComplexSignal(S, CoeffPort1) == COMPLEX_YES);
    boolean_T   outputComplex       = (ssGetOutputPortComplexSignal(S, OutPort) == COMPLEX_YES);
    int_T       numEle, numDelays, frame, coeffPort2Width = 0;
    boolean_T   resultComplex, *flags;

    SFcnCache *cache;
    CallocSFcnCache(S, SFcnCache);
    cache = ssGetUserData(S);

    cache->Normalized = false;
    flags = cache->Flags;
    
    /* Initialize the flags */
    switch (NumDen) {
    case PoleZero:
        flags[Num] = true;
        flags[Den] = true;
        coeffPort2Width   = ssGetInputPortWidth(S, CoeffPort2);
        flags[NumComplex] = coeffPort1Complex;
        flags[DenComplex] = (boolean_T)(ssGetInputPortComplexSignal(S, CoeffPort2) == COMPLEX_YES);
        break;

    case AllZero:
        flags[Num] = true;
        flags[Den] = false;
        flags[NumComplex] = coeffPort1Complex;
        flags[DenComplex] = false;
        break;

    case AllPole:
        flags[Num] = false;
        flags[Den] = true;
        flags[NumComplex] = false;
        flags[DenComplex] = coeffPort1Complex;
        break;

    default:
        THROW_ERROR(S, "Invalid Numerator/Denominator selection from mask.");
    }

    flags[FiltComplex] = flags[NumComplex] | flags[DenComplex];
    flags[DataComplex] = (boolean_T)(ssGetInputPortComplexSignal(S, InPort) == COMPLEX_YES);
    
    /* Consistency check to see if the output port complexity is correct */
    resultComplex = flags[FiltComplex] | flags[DataComplex];
    if (outputComplex != resultComplex) {
        THROW_ERROR(S, "The output port should be complex only if "
                     "the filter coefficients or the input are complex.");
    }
    
    numDelays = MAX(coeffPort1Width, coeffPort2Width);
    
    if (numChans == SAMPLE_BASED) { /* Channel based */
        frame = 1;
        numChans = portWidth;
    } else if (oneFilterPerFrame) { /* Frame based, one filter per frame */
        frame = portWidth / numChans;
    } else { /* Frame based, one filter per sample time */
        frame = portWidth / numChans; /* Samples per frame */
        /* This test avoids a possible divide by zero.  The error that
        causes it (portWidth < numChans) is detected below. */
        if (frame > 0) {
            numDelays = numDelays / frame;
        }
    }
    if ((portWidth % numChans) != 0) {
        THROW_ERROR(S, "The input port width must be a multiple of the number of channels");
    }
    numEle = numChans * numDelays;
    
    if (frame > 1 && !oneFilterPerFrame && 
        (coeffPort1Width % frame != 0 || (NumDen == PoleZero && coeffPort2Width % frame != 0))) {
        THROW_ERROR(S, "The filter coefficient ports must have one filter for each sample in the frame.\n"
                     "These coefficients should be concatenated into one vector per time step.");
    }
    if ((numIC != 0) && (numIC != 1)
        && (numIC != numDelays-1)
        && (numIC != numEle-numChans)) {
        THROW_ERROR(S, "Initial condition vector has incorrect dimensions");
    }

    if (mxIsComplex(IC_ARG) && !(flags[FiltComplex] || flags[DataComplex])) {
        THROW_ERROR(S,"Use real initial conditions for real data "
            "and real filter coefficients.\n"
            "If you really want to use complex initial conditions, "
            "make either the data or the coefficients complex");
    }
#endif
}


#define MDL_INITIALIZE_CONDITIONS
static void mdlInitializeConditions(SimStruct *S)
{
    real_T      *pIC                = mxGetPr(IC_ARG);   /* Initial Conditions vector */
    real_T      *pICI               = mxGetPi(IC_ARG);   /* Initial Conditions vector */
    real_T      *DlyBuf             = ssGetDWork(S, DiscState); /* Delay buffer storage */
    const int_T coeffPort1Width     = ssGetInputPortWidth(S, CoeffPort1);
    const int_T numIC               = mxGetNumberOfElements(IC_ARG);
    int_T       numChans            = (int_T) mxGetPr(CHANS_ARG)[0];
    const int_T portWidth           = ssGetInputPortWidth(S, InPort);
    SFcnCache   *cache              = (SFcnCache *)ssGetUserData(S);
    boolean_T   *flags              = cache->Flags;
    boolean_T   oneFilterPerFrame   = ((int_T)(mxGetPr(FILT_PER_FRAME_ARG)[0]) == UPDATE_EVERY_FRAME);
    boolean_T   isComplex           = flags[FiltComplex] || flags[DataComplex];
    int_T       coeffPort2Width     = (flags[Num] && flags[Den] ? ssGetInputPortWidth(S, CoeffPort2) : 0);
    int_T       i, j, frame, numDelays;

    numDelays = MAX(coeffPort1Width, coeffPort2Width);

    if (numChans == SAMPLE_BASED) { /* Channel based */
        numChans = portWidth;
    } else if (!oneFilterPerFrame) { /* Frame based, one filter per sample time */
        frame = portWidth / numChans; /* Samples per frame */
        numDelays = numDelays / frame;
    }
    
    /*
    * Initialize the state buffers with initial conditions.
    * There is one extra memory element for each channel that is set
    * to zero.  It simplifies the filtering algorithm.
    */
    if (numIC <= 1) {
        /* Scalar expansion, or no IC's given: */
        real_T ic = (numIC == 0) ? (real_T)0.0 : *pIC;
        if (!isComplex) {
            for (i=0; i < numChans; i++) {
                for (j=0; j < numDelays-1; j++) *DlyBuf++ = ic;
                *DlyBuf++ = (real_T)0.0;  /* Extra state is zero */
            }
        }
        else {
            real_T ici = (pICI) ? *pICI : (real_T) 0.0;
            for (i=0; i < numChans; i++) {
                for (j=0; j < numDelays-1; j++) { *DlyBuf++ = ic; *DlyBuf++ = ici; }
                *DlyBuf++ = (real_T)0.0;  *DlyBuf++ = (real_T)0.0;
            }
        }
    }
    else if (numIC == numDelays-1) {
        /* Same IC's for all channels: */
        if (!isComplex) {
            for (i=0; i < numChans; i++) {
                memcpy((void *)DlyBuf, (void *)pIC, (numDelays-1)*sizeof(real_T));
                DlyBuf += numDelays;
                *(DlyBuf-1) = (real_T)0.0;  /* Extra state is zero */
            }
        }
        else {
            for (i=0; i < numChans; i++) {
                if (pICI) for (j=0; j < numDelays-1; j++) { 
                    *DlyBuf++ = pIC[j]; *DlyBuf++ = pICI[j]; 
                }
                else for (j=0; j < numDelays-1; j++) { 
                    *DlyBuf++ = pIC[j]; *DlyBuf++ = (real_T)0.0; 
                }
                *DlyBuf++ = (real_T)0.0;  *DlyBuf++ = (real_T)0.0;
            }
        }
    }
    else {
    /*
    * Matrix of IC's:
    * Assume numDelays rows and numChans columns
        */
        if (!isComplex) {
            for (i=0; i < numChans; i++) {
                memcpy((void *)DlyBuf, (void *)(pIC+i*(numDelays-1)), (numDelays-1)*sizeof(real_T));
                DlyBuf += numDelays;
                *(DlyBuf-1) = (real_T)0.0;  /* Last state is zero */
            }
        }
        else {
            for (i=0; i < numChans; i++) {
                if (pICI) for (j=0; j < numDelays-1; j++) { 
                    *DlyBuf++ = *pIC++; *DlyBuf++ = *pICI++; 
                }
                else for (j=0; j < numDelays-1; j++) { 
                    *DlyBuf++ = *pIC++; *DlyBuf++ = (real_T)0.0; 
                }
                *DlyBuf++ = (real_T)0.0;  *DlyBuf++ = (real_T)0.0;
            }
        }
    }
}


/*
 * Copy the coefficients into local storage.  This simplifies the rest of the code
 * for the case where only one of the numerator and denominator is complex.
 */
static void getRealFilter(SimStruct *S, real_T *num, real_T *den, const int_T ordNUM, const int_T ordDEN, 
                             InputRealPtrsType *numPortP, InputRealPtrsType *denPortP)	
{
    SFcnCache   *cache  = (SFcnCache *)ssGetUserData(S);
    boolean_T   *flags  = cache->Flags;
    InputRealPtrsType   numPort = *numPortP;
    InputRealPtrsType   denPort = *denPortP;
    int_T       i; 
    
    if (flags[Num]) {
        numPort	= *numPortP;
        for (i=0; i <= ordNUM; i++) *num++ = **numPort++;
        *numPortP = numPort;
    } else {
        *num = 1.0;
    } 
    if (flags[Den]) {
        denPort	= *denPortP;
        for (i=0; i <= ordDEN; i++) *den++ = **denPort++;
        *denPortP = denPort;
    } else {
        *den = 1.0;
    }
}

static void getComplexFilter(SimStruct *S, creal_T *num, creal_T *den, const int_T ordNUM, const int_T ordDEN, 
                             InputPtrsType *numPortP, InputPtrsType *denPortP)
{
    SFcnCache   *cache  = (SFcnCache *)ssGetUserData(S);
    boolean_T   *flags  = cache->Flags;
    int_T       i;
    
    if (flags[Num]) {
        if (flags[NumComplex]) {
            InputPtrsType uptr = *numPortP;
            for (i=0; i <= ordNUM; i++) {
                creal_T  *u = (creal_T *) *uptr++;
                *num++ = *u;
            }
            *numPortP = uptr;
        } else  {
            InputRealPtrsType uptr = (InputRealPtrsType) (*numPortP);
            for (i=0; i <= ordNUM; i++) { 
                num->re = **uptr++;  (num++)->im = (real_T) 0.0; 
            }
            *numPortP = (InputPtrsType) uptr;
        }
    } else {
        num->re = 1.0;  num->im = 0.0;
    }
    if (flags[Den]) {
        if (flags[DenComplex]) {
            InputPtrsType uptr = *denPortP;
            for (i=0; i <= ordDEN; i++) { 
                creal_T  *u = (creal_T *) *uptr++;
                *den++ = *u;
            }
            *denPortP = uptr;
        } else  {
            InputRealPtrsType uptr = (InputRealPtrsType) (*denPortP);
            for (i=0; i <= ordDEN; i++) { 
                den->re = **uptr++; (den++)->im = (real_T) 0.0; 
            }
            *denPortP = (InputPtrsType) uptr;
        }
    } else {
        den->re = 1.0;  den->im = 0.0;
    }
}


static void mdlOutputs(SimStruct *S, int_T tid)
{

    /*
     * Algorithm: Direct Form-II Transposed
     *
     *   y  = x*b0        + D0   (output)       b# = numerator polynomial,
     *   D0 = x*b1 - y*a1 + D1   (delay         a# = denominator polynomial,
     *   D1 = x*b2 - y*a2 + D2    updates)      D# = delay buffers
     *   ...                                    y  = output value
     *   DN = x*bN - y*aN                       x  = input value
     *
     * Implementation:
     *   *y++  = x * *b++             + *DR++;
     *   *DL++ = x * *b++ - y * *a+++ + *DR++;
     *   *DL++ = x * *b++ - y * *a+++ + *DR++;
     *   ...
     *   *DL++ = x * *b   - y * *a;
     *
     * Buffer storage:
     *   ----------------------------------------------
     *   |    Channel 0     |     Channel 1      |  ...
     *   |D0 | D1 | D2 |... | D0 | D1 | D2 | ... |  ...
     *   ----------------------------------------------
     */

    const int_T     portWidth           = ssGetInputPortWidth(S, InPort);
    int_T           numChans            = (int_T) mxGetPr(CHANS_ARG)[0];
    boolean_T       filtCheck           = (boolean_T) mxGetPr(CHECK_ARG)[0];
    SFcnCache       *cache              = (SFcnCache *)ssGetUserData(S);
    boolean_T       *flags              = cache->Flags;
    boolean_T       oneFilterPerFrame   = ((int_T)(mxGetPr(FILT_PER_FRAME_ARG)[0]) == UPDATE_EVERY_FRAME);
    InputPtrsType   numPortStart, denPortStart;
    int_T           i, j, k, frame, ordNUM, ordDEN, numDelays, lenMIN;
    
    if (flags[Num]) {
        ordNUM = ssGetInputPortWidth (S, CoeffPort1) - 1;
        numPortStart = ssGetInputPortSignalPtrs(S, CoeffPort1);
        if (flags[Den]) {
            /* Poles and Zeros */

            ordDEN = ssGetInputPortWidth (S, CoeffPort2) - 1;
            denPortStart = ssGetInputPortSignalPtrs(S, CoeffPort2);
        }
        else {
            /* FIR */

            ordDEN = 0;
            denPortStart = NULL;
        }

    } else {
        /* All-Pole */

        ordDEN = ssGetInputPortWidth (S, CoeffPort1) - 1;
        denPortStart = ssGetInputPortSignalPtrs(S, CoeffPort1);
        ordNUM = 0;
        numPortStart = NULL;
    }
    
    if (numChans == SAMPLE_BASED) {
        numChans = portWidth;
        frame = 1;
    } else if (oneFilterPerFrame) { /* Frame based, one filter per frame */
        frame = portWidth / numChans; /* Samples per frame */
    } else { /* Frame based, one filter per sample time */
        frame = portWidth / numChans; /* Samples per frame */
        ordNUM = ordNUM / frame;
        ordDEN = ordDEN / frame;
    }

    lenMIN = MIN(ordNUM, ordDEN);
    numDelays	= MAX(ordNUM, ordDEN) + 1;
    
    if (flags[DataComplex]) { /* COMPLEX DATA */

        InputPtrsType   uptr        = ssGetInputPortSignalPtrs(S, InPort);
        creal_T         *mem_base   = (creal_T *) ssGetDWork(S, DiscState); /* Start of state memory buffer */
        creal_T         *y          = (creal_T *) ssGetOutputPortSignal(S,0);
        
        if (flags[FiltComplex]) { /* Complex data, complex filter */
            creal_T         *num, *den;
            InputPtrsType   numPort, denPort;
            /* Get a filter for this frame of input */
            if (oneFilterPerFrame) {
                numPort = numPortStart;
                denPort = denPortStart;
                num = (creal_T *) ssGetDWork(S, Coeffs);
                den = num + ordNUM + 1;
                getComplexFilter(S, num, den, ordNUM, ordDEN, &numPort, &denPort);
            }
            /* Loop across the channels */
            for (k=0; k < numChans; k++) {
                /* Start with the first filter for this sample time */
                if (!oneFilterPerFrame) {
                    numPort = numPortStart;
                    denPort = denPortStart;
                }
                /* Loop over each input frame: */
                for (i=0; i < frame; i++) {
                    creal_T *u          = (creal_T *) *uptr++;  /* Get next channel input sample */
                    creal_T *filt_mem   = mem_base;
                    creal_T *next_mem   = filt_mem + 1;
                    creal_T out;
                    
                    num = (creal_T *) ssGetDWork(S, Coeffs);
                    den = num + ordNUM + 1; /* Start at a(1) */
                    
                    if (!oneFilterPerFrame) getComplexFilter(S, num, den, ordNUM, ordDEN, &numPort, &denPort);
                    
                    /* Compute the output value */
                    out.re = CMULT_RE(*u, *num) + filt_mem->re;
                    out.im = CMULT_IM(*u, *num) + filt_mem->im;
                    ++num;
                    if (filtCheck) {
                        if ( den->re == 0.0 && den->im == 0 ) {
                            out.im = out.re = 0.0;
#ifdef MATLAB_MEX_FILE
                            mexWarnMsgTxt("Leading denominator coefficient is 0.  Setting output to 0.");
#endif
                        } else if (den->re != 1.0 || den->im != 0.0) {
                            /* Scale filter output by leading denominator coefficient */
                            creal_T tmp = out;
                            CDIV(tmp, *den, out);
                            cache->Normalized = true;
                        }
                    }
                    ++den;
                    *y++ = out;
                    
                    /* Update states having both numerator and denominator coeffs */
                    for (j=0; j < lenMIN; j++) {
                        filt_mem->re = next_mem->re + CMULT_RE(*u, *num) - CMULT_RE(out, *den);
                        filt_mem->im = next_mem->im + CMULT_IM(*u, *num) - CMULT_IM(out, *den);
                        ++filt_mem;  ++next_mem;
                        ++num;  ++den;
                    }
                    /* Update the rest of the states. At most one of these two statements
                    * will execute
                    */
                    for (   ; j < ordNUM; j++) {
                        filt_mem->re = next_mem->re + CMULT_RE(*u, *num);
                        filt_mem->im = next_mem->im + CMULT_IM(*u, *num);
                        ++filt_mem;  ++next_mem;
                        ++num;
                    }
                    for (   ; j < ordDEN; j++) {
                        filt_mem->re = next_mem->re - CMULT_RE(out, *den);
                        filt_mem->im = next_mem->im - CMULT_IM(out, *den);
                        ++filt_mem;  ++next_mem;
                        ++den;
                    }
                } /* frame loop */
                mem_base += numDelays;
            } /* channel loop */

        } else {   /* Complex data, real filter */

            real_T              *num, *den;
            InputRealPtrsType   numPort, denPort;
            /* Get a filter for this frame of input */
            if (oneFilterPerFrame) {
                numPort = (InputRealPtrsType) numPortStart;
                denPort = (InputRealPtrsType) denPortStart;
                num = ssGetDWork(S, Coeffs);
                den = num + ordNUM + 1;
                getRealFilter(S, num, den, ordNUM, ordDEN, &numPort, &denPort);
            }
            
            /* Loop over each sample time */
            for (k=0; k < numChans; k++) {
                /* Get a new filter for this sample time */
                if (!oneFilterPerFrame) {
                    numPort = (InputRealPtrsType) numPortStart;
                    denPort = (InputRealPtrsType) denPortStart;
                }
                /* Loop over each sample time */
                for (i=0; i < frame; i++) {
                    creal_T *u          = (creal_T *) *uptr++;  /* Get next channel input sample */
                    creal_T *filt_mem   = mem_base;
                    creal_T *next_mem   = filt_mem + 1;
                    creal_T out;
                    
                    num = ssGetDWork(S, Coeffs);
                    den = num + ordNUM + 1;  /* Start at a(1) */
                    
                    if (!oneFilterPerFrame) getRealFilter(S, num, den, ordNUM, ordDEN, &numPort, &denPort);
                    
                    /* Compute the output value */
                    out.re = u->re * *num   + filt_mem->re;
                    out.im = u->im * *num++ + filt_mem->im;
                    if (filtCheck) {
                        if ( *den == 0.0 ) {
#ifdef MATLAB_MEX_FILE
                        mexWarnMsgTxt("Leading denominator coefficient is 0.  Setting output to 0.");
#endif
                            out.im = out.re = 0.0;
                        } else if (*den != 1.0) {
                            /* Scale filter output by leading denominator coefficient */
                            real_T normalize = 1.0 / *den;
                            out.re *= normalize;
                            out.im *= normalize;
                            cache->Normalized = true;
                        }
                    }
                    ++den;
                    *y++ = out;
                    
                    /* Update states having both numerator and denominator coeffs */
                    for (j=0; j < lenMIN; j++) {
                        filt_mem->re = next_mem->re + u->re * *num   - out.re * *den;
                        filt_mem->im = next_mem->im + u->im * *num++ - out.im * *den++;
                        ++filt_mem;  ++next_mem;
                    }
                    /* Update the rest of the states. At most one of these two statements
                    * will execute
                    */
                    for (   ; j < ordNUM; j++) {
                        filt_mem->re = next_mem->re + u->re  * *num;
                        filt_mem->im = next_mem->im + u->im  * *num++;
                        ++filt_mem;  ++next_mem;
                    }
                    for (   ; j < ordDEN; j++) {
                        filt_mem->re = next_mem->re - out.re * *den;
                        filt_mem->im = next_mem->im - out.im * *den++;
                        ++filt_mem;  ++next_mem;
                    }
                } /* frame loop */
                mem_base += numDelays;
            } /* channel loop */
        }

    } else {  /* REAL DATA */

            InputRealPtrsType   uptr    = ssGetInputPortRealSignalPtrs(S, InPort);
            
            if (flags[FiltComplex]) { /* Real data, complex filter */
                creal_T         *mem_base   = (creal_T *) ssGetDWork(S, DiscState); /* Start of state memory buffer */
                creal_T         *y          = (creal_T *) ssGetOutputPortSignal(S,OutPort);
                creal_T         *num, *den;
                InputPtrsType   numPort, denPort;
                /* Get a filter for this frame of input */
                if (oneFilterPerFrame) {
                    numPort = numPortStart;
                    denPort = denPortStart;
                    num = (creal_T *) ssGetDWork(S, Coeffs);
                    den = num + ordNUM + 1;
                    getComplexFilter(S, num, den, ordNUM, ordDEN, &numPort, &denPort);
                }
                /* Loop across the channels */
                for (k=0; k < numChans; k++) {
                    /* Start with the first filter for this sample time */
                    if (!oneFilterPerFrame) {
                        numPort = numPortStart;
                        denPort = denPortStart;
                    }
                    /* Loop over each input frame: */
                    for (i=0; i < frame; i++) {
                        real_T  in          = **uptr++;  /* Get next channel input sample */
                        creal_T *filt_mem   = mem_base;
                        creal_T *next_mem   = filt_mem + 1;
                        creal_T out;
                        
                        num = (creal_T *) ssGetDWork(S, Coeffs);
                        den = num + ordNUM + 1; /* Start at a(1) */
                        
                        if (!oneFilterPerFrame) getComplexFilter(S, num, den, ordNUM, ordDEN, &numPort, &denPort);
                        
                        /* Compute the output value */
                        out.re = in * num->re     + filt_mem->re;
                        out.im = in * (num++)->im + filt_mem->im;
                        if (filtCheck) {
                            if ( den->re == 0.0 && den->im == 0.0 ) {
                                out.im = out.re = 0.0;
#ifdef MATLAB_MEX_FILE
                                mexWarnMsgTxt("Leading denominator coefficient is 0.  Setting output to 0.");
#endif
                            } else if (den->re != 1.0 || den->im != 0.0) {
                                /* Scale filter output by leading denominator coefficient */
                                creal_T tmp = out;
                                CDIV(tmp, *den, out);
                                cache->Normalized = true;
                            }
                        }
                        ++den;
                        *y++ = out;
                        
                        /* Update states having both numerator and denominator coeffs */
                        for (j=0; j < lenMIN; j++) {
                            filt_mem->re = next_mem->re + in * num->re     - CMULT_RE(out, *den);
                            filt_mem->im = next_mem->im + in * (num++)->im - CMULT_IM(out, *den);
                            ++filt_mem;  ++next_mem;
                            ++den;
                        }
                        /* Update the rest of the states. At most one of these two statements
                        * will execute
                        */
                        for (   ; j < ordNUM; j++) {
                            filt_mem->re = next_mem->re + in  * num->re;
                            filt_mem->im = next_mem->im + in  * (num++)->im;
                            ++filt_mem;  ++next_mem;
                        }
                        for (   ; j < ordDEN; j++) {
                            filt_mem->re = next_mem->re - CMULT_RE(out, *den);
                            filt_mem->im = next_mem->im - CMULT_IM(out, *den);
                            ++filt_mem;  ++next_mem;
                            ++den;
                        }
                    } /* frame loop */
                    mem_base += numDelays;
                } /* channel loop */

            } else { /* Real data, real filter */

                real_T              *mem_base   = ssGetDWork(S, DiscState); /* Start of state memory buffer */
                real_T              *y          = ssGetOutputPortRealSignal(S, OutPort);
                InputRealPtrsType   numPort, denPort;
                real_T              *num, *den;
                
                /* Get a filter for this frame of input */
                if (oneFilterPerFrame) {
                    numPort = (InputRealPtrsType) numPortStart;
                    denPort = (InputRealPtrsType) denPortStart;
                    num  = ssGetDWork(S, Coeffs);
                    den  = num + ordNUM + 1;
                    getRealFilter(S, num, den, ordNUM, ordDEN, &numPort, &denPort);
                }
                
                /* Loop over each sample time */
                for (k=0; k < numChans; k++) {
                    /* Get a new filter for this sample time */
                    if (!oneFilterPerFrame) {
                        numPort = (InputRealPtrsType) numPortStart;
                        denPort = (InputRealPtrsType) denPortStart;
                    }
                    /* Loop over each sample time */
                    for (i=0; i < frame; i++) {
                        real_T  in          = **uptr++;  /* Get next channel input sample */
                        real_T  *filt_mem   = mem_base;
                        real_T  *next_mem   = filt_mem + 1;
                        real_T  out;
                        
                        num = ssGetDWork(S, Coeffs);
                        den = num + ordNUM + 1;  /* Start at a(1) */
                        
                        if (!oneFilterPerFrame) getRealFilter(S, num, den, ordNUM, ordDEN, &numPort, &denPort);
                        
                        /* Compute the output value */
                        out = in * *num++ + *filt_mem;
                        if (filtCheck) {
                            if ( *den == 0.0 ) {
                                out = 0.0;
#ifdef MATLAB_MEX_FILE
                                mexWarnMsgTxt("Leading denominator coefficient is 0.  Setting output to 0.");
#endif
                            } else if (*den != 1.0) {
                                /* Scale filter output by leading denominator coefficient */
                                out /= *den;
                                cache->Normalized = true;
                            }
                        }
                        ++den;
                        *y++ = out;
                        
                        /* Update states having both numerator and denominator coeffs */
                        for (j=0; j < lenMIN; j++) *filt_mem++ = *next_mem++ + in * *num++ - out * *den++;
                        /* Update the rest of the states. At most one of these two statements
                        * will execute
                        */
                        for (   ; j < ordNUM; j++) *filt_mem++ = *next_mem++ + in  * *num++;
                        for (   ; j < ordDEN; j++) *filt_mem++ = *next_mem++ - out * *den++;
                    } /* frame loop */
                    mem_base += numDelays;
                } /* channel loop */
            }
        }
        /* Note:  If you modify this code, make sure that the last state memory
         * value for each channel is always zero.  This extra zero-valued state
         * greatly simplifies the algorithm.
         */
}


static void mdlTerminate(SimStruct *S)
{
#ifdef MATLAB_MEX_FILE
    SFcnCache *cache = (SFcnCache *)ssGetUserData(S);
    if (cache->Normalized) {
        mexWarnMsgTxt("Some denominator coefficients needed to be normalized.  "
                      "This could be computationally expensive.");
    }
    FreeSFcnCache(S, SFcnCache);
#endif
}


#ifdef MATLAB_MEX_FILE
#define MDL_SET_WORK_WIDTHS
static void mdlSetWorkWidths(SimStruct *S)
{
    /* Allocate delay buffer.
    *
    * The delay buffer has numChans "segments", each with numDelays
    * indices for each filter channel, for storing the delay values
    * for each IIR filter.
    */

    const int_T coeffPort1Width     = ssGetInputPortWidth(S, CoeffPort1);
    const int_T portWidth           = ssGetInputPortWidth(S, InPort);
    int_T       numChans            = (int_T) mxGetPr(CHANS_ARG)[0];
    boolean_T   FiltComplex         = (ssGetInputPortComplexSignal(S, CoeffPort1) == COMPLEX_YES);
    boolean_T   oneFilterPerFrame   = ((int_T)(mxGetPr(FILT_PER_FRAME_ARG)[0]) == UPDATE_EVERY_FRAME);
    int_T       numDelays, numCoeffs, numEle, coeffPort2Width;
    int_T       frame = 1;
    
    if (numChans == SAMPLE_BASED) { /* Channel based */
        numChans = portWidth;
    } else if (!oneFilterPerFrame) { /* Frame based, one filter per sample time */
        frame = portWidth / numChans; /* Samples per frame */
        if (frame < 1) {
            THROW_ERROR(S, "The input frame size must be >= 1");
        }
    }
    if ((portWidth % numChans) != 0) {
        THROW_ERROR(S, "The input port width must be a multiple of the number of channels");
    }
    if (coeffPort1Width == 0 || (coeffPort1Width % frame) != 0) {
        THROW_ERROR(S, "The coefficient port width must be a multiple frame size");
    }
    numDelays = numCoeffs = coeffPort1Width / frame;
    if (ssGetNumInputPorts(S) == 3) { /* PoleZero Filter */
        FiltComplex = FiltComplex || (ssGetInputPortComplexSignal(S, CoeffPort1) == COMPLEX_YES);
        if (ssGetInputPortWidth(S, CoeffPort2) == 0 
                    || (ssGetInputPortWidth(S, CoeffPort2) % frame) != 0) {
            THROW_ERROR(S, "The denominator port width must be a multiple frame size");
        }
        coeffPort2Width = ssGetInputPortWidth(S, CoeffPort2) / frame;
        numDelays = MAX(numDelays, coeffPort2Width);
        numCoeffs += coeffPort2Width;
    }
    else {
    /* We have an AllZero or AllPole filter and need storage for 
    * a 1.0 for either the numerator or the denominator.
        */
        ++numCoeffs;
    }
    numEle    = numChans * numDelays;
    
    if(!ssSetNumDWork( S, NUM_DWORKS)) return;
    
    ssSetDWorkWidth(   S, Coeffs, numCoeffs);
    ssSetDWorkDataType(S, Coeffs, SS_DOUBLE);
    if (FiltComplex) {
        ssSetDWorkComplexSignal(S, Coeffs, COMPLEX_YES);
    }
    
    /* numEle must be greater than zero */
    ssSetDWorkWidth(S, DiscState, numEle);
    if (FiltComplex || ssGetInputPortComplexSignal(S,0) == COMPLEX_YES) {
        ssSetDWorkComplexSignal(S, DiscState, COMPLEX_YES);
    }
    
}
#endif


#ifdef MATLAB_MEX_FILE
#define MDL_SET_INPUT_PORT_WIDTH
static void mdlSetInputPortWidth(SimStruct *S, int_T port, int_T inputPortWidth)
{
    ssSetInputPortWidth (S, port, inputPortWidth);

    if (port == InPort) {
        int_T   outputPortWidth = ssGetOutputPortWidth(S, port);

        if (outputPortWidth == DYNAMICALLY_SIZED) {
            ssSetOutputPortWidth(S, port, inputPortWidth);
        } else if (ssGetOutputPortWidth(S, port) != inputPortWidth) {
            THROW_ERROR(S, "Input/Output port pairs must have the same width");
        }
    }
}


#define MDL_SET_OUTPUT_PORT_WIDTH
static void mdlSetOutputPortWidth(SimStruct *S, int_T port, int_T outputPortWidth)
{
    if (port != OutPort) {
        THROW_ERROR(S,"Invalid call to output port width propagation.");
    }

    ssSetOutputPortWidth (S, port, outputPortWidth);
    {
        int_T   inputPortWidth  = ssGetInputPortWidth(S, port);
        
        if (inputPortWidth == DYNAMICALLY_SIZED) {
            ssSetInputPortWidth(S, port, outputPortWidth);
        } else if (ssGetInputPortWidth(S, port) != outputPortWidth) {
            THROW_ERROR(S, "Input/Output port pairs must have the same width");
        }
    }
}


#define MDL_SET_INPUT_PORT_COMPLEX_SIGNAL
static void mdlSetInputPortComplexSignal(SimStruct *S, int_T portIdx,
                                         CSignal_T      iPortComplexSignal)
{
    ssSetInputPortComplexSignal(S, portIdx, iPortComplexSignal ? COMPLEX_YES : COMPLEX_NO);
    /* If any of the input signal, the numerator, or denominator are complex, output is complex */
    if (iPortComplexSignal) {
        ssSetOutputPortComplexSignal(S, OutPort, COMPLEX_YES);
    }
}

#define MDL_SET_OUTPUT_PORT_COMPLEX_SIGNAL
static void mdlSetOutputPortComplexSignal(SimStruct *S, int_T portIdx,
                                          CSignal_T      oPortComplexSignal)
{
    /* The consistency of this assignment is checked in mdlStart(). */
    ssSetOutputPortComplexSignal(S, OutPort, oPortComplexSignal ? COMPLEX_YES : COMPLEX_NO);		
}
#endif

#define MDL_RTW
#if defined(MATLAB_MEX_FILE) || defined(NRT)
static void mdlRTW(SimStruct *S)
{
    SFcnCache       *cache  = (SFcnCache *)ssGetUserData(S);
    boolean_T       *flags  = cache->Flags;
    int_T           numIC   = mxGetNumberOfElements(IC_ARG);
    const char      *names[NUM_FLAGS] = {"Num", "Den", "DataComplex", 
                                         "FiltComplex", "NumComplex", 
                                         "DenComplex"};
    real_T          *ICr    = mxGetPr(IC_ARG);
    real_T          *ICi    = mxGetPi(IC_ARG);
    real_T          dummy   = 0.0;

    int32_T         chans        = (int32_T)mxGetPr(CHANS_ARG)[0];
    int32_T         filtPerFrame = (int32_T)(mxGetPr(FILT_PER_FRAME_ARG)[0] == 
                                             UPDATE_EVERY_FRAME);
    int32_T         filtCheck    = (int32_T)mxGetPr(CHECK_ARG)[0];

    if (numIC == 0) {
        /* SSWRITE_VALUE_*_VECT does not support empty vectors */
        numIC = 1;
        ICr = ICi = &dummy;
    }

    if (!ssWriteRTWParamSettings(S, (int_T) NUM_FLAGS + 4,
                                 SSWRITE_VALUE_DTYPE_ML_VECT, "IC", ICr, ICi,
                                 numIC, DTINFO(SS_DOUBLE, mxIsComplex(IC_ARG)),

                                 SSWRITE_VALUE_DTYPE_NUM, "Chans",
                                 &chans,
                                 DTINFO(SS_INT32,0),

                                 SSWRITE_VALUE_DTYPE_NUM, "FiltPerFrame",
                                 &filtPerFrame,
                                 DTINFO(SS_INT32,0),

                                 SSWRITE_VALUE_DTYPE_NUM, "FiltCheck",
                                 &filtCheck,
                                 DTINFO(SS_INT32,0),

                                 SSWRITE_VALUE_DTYPE_NUM, names[0], 
                                 &flags[0],
                                 DTINFO(SS_BOOLEAN,0),

                                 SSWRITE_VALUE_DTYPE_NUM, names[1], 
                                 &flags[1],
                                 DTINFO(SS_BOOLEAN,0),

                                 SSWRITE_VALUE_DTYPE_NUM, names[2], 
                                 &flags[2],
                                 DTINFO(SS_BOOLEAN,0),

                                 SSWRITE_VALUE_DTYPE_NUM, names[3], 
                                 &flags[3],
                                 DTINFO(SS_BOOLEAN,0),

                                 SSWRITE_VALUE_DTYPE_NUM, names[4],
                                 &flags[4],
                                 DTINFO(SS_BOOLEAN,0),

                                 SSWRITE_VALUE_DTYPE_NUM, names[5],
                                 &flags[5],
                                 DTINFO(SS_BOOLEAN,0))) {
        return;
    }
}
#endif


#ifdef	MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-File interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif

/* [EOF] sdspdf2tv.c */
