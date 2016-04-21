/*
 *  SDSPVLAT: SIMULINK multichannel Lattce filter block.
 *  DSP Blockset S-Function for TIME_VARYING multichannel lattice filtering.
 *  Supports real or complex data and filters for parallel sample-based filtering
 *  or for frame-based filtering.
 *  Currently supports AR or MA.  There are some code stubs for ARMA.
 *
 *   
 *  Copyright 1995-2002 The MathWorks, Inc.
 *  $Revision: 1.17 $  $Date: 2002/04/14 20:41:43 $
 */

#define S_FUNCTION_LEVEL 2
#define S_FUNCTION_NAME sdspvlat

#include "dsp_sim.h"

/* Argument list for a time-varying filter */
enum {ARGC_AR_MA, ARGC_IC, ARGC_CHANS, ARGC_FILT_PER_FRAME, NUM_ARGS};
#define AR_MA_ARG     ssGetSFcnParam(S,ARGC_AR_MA)/* Numerator? Denominator? */
#define IC_ARG          ssGetSFcnParam(S,ARGC_IC)    /* Initial Conditions */
#define CHANS_ARG       ssGetSFcnParam(S,ARGC_CHANS) /* Number of Channels */

/* One filter per frame?, otherwise one filter per sample time */
#define FILT_PER_FRAME_ARG      ssGetSFcnParam(S,ARGC_FILT_PER_FRAME)
enum {UPDATE_EVERY_SAMPLE=1, UPDATE_EVERY_FRAME};

/* An invalid number of channels is used to flag sample-based operation */
const int_T SAMPLE_BASED = -1;

/* Values from NUM_AR_MA pop-up box */
enum {MA=1, AR, ARMA};

/* Port index enumerations */
enum {InPort, CoeffPort1, CoeffPort2, MAX_NUM_INPORTS};
enum {OutPort, NUM_OUTPORTS};

/* Indices for DWork */
enum {DiscState, Swapped, NUM_DWORKS};

/* Indices for the Flags */
enum {Zeros, Poles, DataComplex, FiltComplex, ZerosComplex, PolesComplex, NUM_FLAGS};
typedef struct {
    boolean_T   Flags[NUM_FLAGS];
    int_T order, frame, nChans;
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
        THROW_ERROR(S, "The choice for lattice coefficient update rate must be a one or a two.");
    }
    
    if ( mxGetNumberOfElements(AR_MA_ARG) != 1 || mxGetPr(AR_MA_ARG)[0] < 1 
        || mxGetPr(AR_MA_ARG)[0] > 3 || mxGetPr(AR_MA_ARG)[0] != (int_T)mxGetPr(AR_MA_ARG)[0]) {
        THROW_ERROR(S, "The choices for the lattice structure are 1=MA, 2=AR, 3=ARMA.");
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

    ssSetSFcnParamNotTunable(S, ARGC_AR_MA);
    ssSetSFcnParamNotTunable(S, ARGC_IC);
    ssSetSFcnParamNotTunable(S, ARGC_CHANS);
    ssSetSFcnParamNotTunable(S, ARGC_FILT_PER_FRAME);

    ssSetNumSampleTimes(S, PORT_BASED_SAMPLE_TIMES);

    if ((int_T) mxGetPr(AR_MA_ARG)[0] == ARMA) {
        /* CoeffPort1 = MA, Port2 = AR */
        if (!ssSetNumInputPorts(S, 3)) return;
        ssSetInputPortWidth(            S, CoeffPort2, DYNAMICALLY_SIZED);
        ssSetInputPortComplexSignal(    S, CoeffPort2, COMPLEX_INHERITED);
        ssSetInputPortDirectFeedThrough(S, CoeffPort2, 1);
        ssSetInputPortReusable(         S, CoeffPort2, 1);
        ssSetInputPortOverWritable(     S, CoeffPort2, 0);
        ssSetInputPortSampleTime(       S, CoeffPort2, INHERITED_SAMPLE_TIME);
    } else {
        /* Either MA or AR */
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
    
    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE | 
                 SS_OPTION_USE_TLC_WITH_ACCELERATOR);
}


/* Set all ports to the identical, discrete rates: */
#include "dsp_ctrl_ts.c"


#define MDL_START
static void mdlStart (SimStruct *S)
{
#ifdef MATLAB_MEX_FILE
    const int_T coeffPort1Width     = ssGetInputPortWidth(S, CoeffPort1);
    const int_T numIC               = mxGetNumberOfElements(IC_ARG);
    int_T       numChans            = (int_T) mxGetPr(CHANS_ARG)[0];
    const int_T portWidth           = ssGetInputPortWidth(S, InPort);
    int_T       ArMa                = (int_T) mxGetPr(AR_MA_ARG)[0];
    boolean_T   oneFilterPerFrame   = ((int_T)mxGetPr(FILT_PER_FRAME_ARG)[0] == UPDATE_EVERY_FRAME);
    boolean_T   coeffPort1Complex   = (ssGetInputPortComplexSignal(S, CoeffPort1) == COMPLEX_YES);
    boolean_T   outputComplex       = (ssGetOutputPortComplexSignal(S, OutPort) == COMPLEX_YES);
    int_T       numEle, order, frame, coeffPort2Width = 0;
    boolean_T   resultComplex, *flags;

    SFcnCache *cache;
    CallocSFcnCache(S, SFcnCache);
    cache = ssGetUserData(S);

    flags = cache->Flags;
    
    /* Initialize the flags */
    switch (ArMa) {
    case ARMA:
        flags[Zeros] = true;  flags[Poles] = true;
        coeffPort2Width = ssGetInputPortWidth(S, CoeffPort2);
        if (coeffPort1Complex) flags[ZerosComplex] = true;
        else flags[ZerosComplex] = false;
        if (ssGetInputPortComplexSignal(S, CoeffPort2) == COMPLEX_YES) flags[PolesComplex] = true;
        else flags[PolesComplex] = false;
        if (flags[ZerosComplex] != flags[PolesComplex]) {
            THROW_ERROR(S, "The coeffient ports must be both real or both complex.");
        }
        break;
    case MA:
        flags[Zeros] = true;  flags[Poles] = false;
        if (coeffPort1Complex) flags[ZerosComplex] = true;
        else flags[ZerosComplex] = false;
        flags[PolesComplex] = false;
        break;
    case AR:
        flags[Zeros] = false; flags[Poles] = true;
        if (coeffPort1Complex) flags[PolesComplex] = true;
        else flags[PolesComplex] = false;
        flags[ZerosComplex] = false;
        break;
    default:
        THROW_ERROR(S, "Invalid lattice structure selection from mask.");
    }
    if (ssGetInputPortComplexSignal(S, InPort) == COMPLEX_YES) flags[DataComplex] = true;
    else flags[DataComplex] = false;
    flags[FiltComplex] = flags[ZerosComplex] || flags[PolesComplex];
    
    /* Consistency check to see if the output port complexity is correct */
    resultComplex = flags[FiltComplex] | flags[DataComplex];
    if (outputComplex != resultComplex) {
        THROW_ERROR(S, "The output port should be complex only if "
            "the lattice coefficients or the input are complex.");
    }
    
    cache->order = order = coeffPort1Width;
    
    if (numChans == SAMPLE_BASED) { /* Channel based */
        frame = 1;
        numChans = portWidth;
    } else if (oneFilterPerFrame) { /* Frame based, one filter per frame */
        frame = portWidth / numChans;
    } else { /* Frame based, one filter per sample time */
        frame = portWidth / numChans; /* Samples per frame */
        /* This test avoids a possible divide by zero.  The error that
        causes it (portWidth < numChans) is detected below. */
        if (frame > 0) cache->order = order = order / frame;
    }
    if ((portWidth % numChans) != 0) {
        ssSetErrorStatus (S, "The input port width must be a multiple of the number of channels");
        return;
    }
    cache->frame = frame;
    cache->nChans = numChans;
    numEle = numChans * order;
    
    if ( (frame > 1) && !oneFilterPerFrame && 
         (coeffPort1Width % frame != 0 || (ArMa == ARMA && coeffPort2Width % frame != 0))
       ) {
        THROW_ERROR(S, "The filter coefficient ports must have one filter for each sample in the frame.\n"
                     "These coefficients should be concatenated into one vector per time step.");
    }
    if ((numIC != 0) && (numIC != 1)
        && (numIC != order)
        && (numIC != numEle)) {
        THROW_ERROR(S, "Initial condition vector has incorrect dimensions");
    }
    
    if (ssGetSampleTime(S,0) == CONTINUOUS_SAMPLE_TIME) {
        THROW_ERROR(S,"Input to block must have a discrete sample time");
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
    const int_T numIC               = mxGetNumberOfElements(IC_ARG);
    int_T       numChans            = (int_T) mxGetPr(CHANS_ARG)[0];
    boolean_T   *swapped            = ssGetDWork(S, Swapped);
    SFcnCache   *cache              = (SFcnCache *)ssGetUserData(S);
    boolean_T   *flags              = cache->Flags;
    boolean_T   oneFilterPerFrame   = ((int_T)(mxGetPr(FILT_PER_FRAME_ARG)[0]) == UPDATE_EVERY_FRAME);
    boolean_T   isComplex           = flags[FiltComplex] || flags[DataComplex];
    int_T       i, j, numDelays;

    numDelays = cache->order;
    numChans = cache->nChans;


    /* The MA lattice uses swapped state memory banks */
    *swapped = false;

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
                for (j=0; j < numDelays; j++) *DlyBuf++ = ic;
            }
        }
        else {
            real_T ici = (pICI) ? *pICI : (real_T) 0.0;
            for (i=0; i < numChans; i++) {
                for (j=0; j < numDelays; j++) { *DlyBuf++ = ic; *DlyBuf++ = ici; }
            }
        }
    }
    else if (numIC == numDelays) {
        /* Same IC's for every channel: */
        if (!isComplex) {
            for (i=0; i < numChans; i++) {
                for (j=0; j < numDelays; j++) *DlyBuf++ = pIC[j];
            }
        }
        else {
            for (i=0; i < numChans; i++) {
                if (pICI) for (j=0; j < numDelays; j++) { 
                    *DlyBuf++ = pIC[j]; *DlyBuf++ = pICI[j]; 
                }
                else for (j=0; j < numDelays; j++) { 
                    *DlyBuf++ = pIC[j]; *DlyBuf++ = (real_T)0.0; 
                }
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
                for (j=0; j < numDelays; j++) *DlyBuf++ = *pIC++;
            }
        }
        else {
            for (i=0; i < numChans; i++) {
                if (pICI) for (j=0; j < numDelays; j++) { 
                    *DlyBuf++ = *pIC++; *DlyBuf++ = *pICI++; 
                }
                else for (j=0; j < numDelays; j++) { 
                    *DlyBuf++ = *pIC++; *DlyBuf++ = (real_T)0.0; 
                }
            }
        }
    }
}


static void mdlOutputs(SimStruct *S, int_T tid)
{		
    SFcnCache       *cache              = (SFcnCache *)ssGetUserData(S);
    boolean_T       *flags              = cache->Flags;
    boolean_T       oneFilterPerFrame   = ((int_T)(mxGetPr(FILT_PER_FRAME_ARG)[0]) == UPDATE_EVERY_FRAME);
    int_T           structure           = (int_T) mxGetPr(AR_MA_ARG)[0];
    int_T           order               = cache->order;
    int_T           frame               = cache->frame;
    int_T           numChans            = cache->nChans;
    int_T           j, i, k;
    
    if (flags[FiltComplex]) { /* COMPLEX FILTER */
        creal_T         *y          = (creal_T *) ssGetOutputPortSignal(S,0);
        InputPtrsType       uptr;
        InputRealPtrsType   rptr;

        if (flags[DataComplex]) {
            uptr = ssGetInputPortSignalPtrs(S, InPort);
        } else {
            rptr = ssGetInputPortRealSignalPtrs(S, InPort);
        }

        if (structure == MA) {
            /* The MA algorithm starts at the first coefficient */
            InputPtrsType   MAport  =  ssGetInputPortSignalPtrs(S, CoeffPort1);
            /* Start of state memory buffer */ 
            boolean_T   *swapped    = ssGetDWork(S, Swapped);
            creal_T     *then_base  = ssGetDWork(S, DiscState);
            creal_T     *now_base   = then_base;
            creal_T     x           = {(real_T) 0.0, (real_T) 0.0};
            creal_T     *swap;
            InputPtrsType   ma;

#define     Vma *((creal_T *) *ma)

            /* Dual state memories are used for maximum speed */
            if (*swapped) then_base += numChans * order;
            else          now_base  += numChans * order;
        
            /* Loop over each channel */
            for (k=0; k < numChans; k++) {
                creal_T  *then0  = then_base;
                creal_T  *now0   = now_base;

                /* Move to first coefficient of first filter for this sample time */
                if (!oneFilterPerFrame)  ma = MAport;

                /* Loop over each sample time */
                for (i=0; i < frame; i++) {
                    creal_T *then   = then0;
                    creal_T *now    = now0;
                    creal_T sum;

                    /* Move to first reflection coefficient */
                    if (oneFilterPerFrame) ma = MAport;

                    if (flags[DataComplex]) {
                        sum = *((creal_T *) *uptr++);
                    } else {
                        x.re = **rptr++;
                        sum = x;
                    }

                    *now++ = sum;
                    for (j=1; j < order; j++) {
                        now->re     = then->re + CMULT_XCONJ_RE(Vma, sum);
                        (now++)->im = then->im + CMULT_XCONJ_IM(Vma, sum);
                        sum.re  += CMULT_RE(Vma, *then);
                        sum.im  += CMULT_IM(Vma, *then);
                        ++ma; ++then;
                    }
                    y->re     = sum.re + CMULT_RE(Vma, *then);
                    (y++)->im = sum.im + CMULT_IM(Vma, *then);
                    ++ma;
                    
                    /* Swap state memories */
                    swap = then0;  then0 = now0;  now0 = swap;
                }
                then_base += order;
                now_base += order;
            } /* channel loop */
            /* If the frame size is odd, the buffers have been swapped */
            if (frame & 1) *swapped = !(*swapped);

        } else if (structure == AR) {

            /* The AR algorithm starts at the last coefficient */
            InputPtrsType   ARport =  ssGetInputPortSignalPtrs(S, CoeffPort1) + order - 1;
            /* End of state memory buffer */ 
            creal_T         *mem_base   = (creal_T *) ssGetDWork(S, DiscState) + order - 1;
            InputPtrsType   ar;

#define     Var *((creal_T *) *ar)

            /* Loop over each sample time */
            for (k=0; k < numChans; k++) {
                /* Move to last coefficient of first filter for this sample time */
                if (!oneFilterPerFrame)  ar = ARport;

                /* Loop over each sample time */
                for (i=0; i < frame; i++) {
                    creal_T *filt_mem   = mem_base;
                    creal_T x           = {(real_T) 0.0, (real_T) 0.0};
                    creal_T sum;

                    /* Move to last reflection coefficient */
                    if (oneFilterPerFrame) ar = ARport;

                    if (flags[DataComplex]) {
                        sum = *((creal_T *) *uptr++);
                    } else {
                        x.re = **rptr++;
                        sum = x;
                    }

                    sum.re = sum.re - CMULT_RE(Var, *filt_mem);
                    sum.im = sum.im - CMULT_IM(Var, *filt_mem);
                    --ar;
                    for (j=1; j < order; j++) {
                        --filt_mem;
                        sum.re -= CMULT_RE(Var, *filt_mem);
                        sum.im -= CMULT_IM(Var, *filt_mem);
                        (filt_mem + 1)->re = CMULT_YCONJ_RE(sum, Var) + filt_mem->re;
                        (filt_mem + 1)->im = CMULT_YCONJ_IM(sum, Var) + filt_mem->im;
                        --ar;
                    }
                    *y++ = *filt_mem = sum;
                    
                    /* Go to last coefficient in next set */
                    if (!oneFilterPerFrame)  ar += 2*order;
                }
                mem_base += order;
            } /* channel loop */
        } /* structure */
        
    } else {  /* REAL FILTER */
        
        if (flags[DataComplex]) { 
            InputPtrsType   uptr    = ssGetInputPortSignalPtrs(S, InPort);
            creal_T         *y      = (creal_T *) ssGetOutputPortSignal(S, OutPort);

            if (structure == MA) {
                /* The MA algorithm starts at the first coefficient */
                InputRealPtrsType   MAport  =  ssGetInputPortRealSignalPtrs(S, CoeffPort1);
                /* Start of state memory buffer */ 
                boolean_T   *swapped    = ssGetDWork(S, Swapped);
                creal_T     *then_base  = (creal_T *) ssGetDWork(S, DiscState);
                creal_T     *now_base   = then_base;
                creal_T     *swap;
                InputRealPtrsType   ma;

#define         Vma *((creal_T *) *ma)

                /* Dual state memories are used for maximum speed */
                if (*swapped) then_base += numChans * order;
                else          now_base  += numChans * order;
            
                /* Loop over each sample time */
                for (k=0; k < numChans; k++) {
                    creal_T *then0  = then_base;
                    creal_T *now0   = now_base;

                    /* Move to last coefficient of first filter for this sample time */
                    if (!oneFilterPerFrame)  ma = MAport;

                    /* Loop over each sample time */
                    for (i=0; i < frame; i++) {
                        creal_T *then   = then0;
                        creal_T *now    = now0;
                        creal_T sum;

                        /* Move to first reflection coefficient */
                        if (oneFilterPerFrame) ma = MAport;

                        sum = *now++ = *((creal_T *) *uptr++);
                        for (j=1; j < order; j++) {
                            now->re     = then->re + **ma * sum.re;
                            (now++)->im = then->im + **ma * sum.im;
                            sum.re += then->re     * **ma;
                            sum.im += (then++)->im * **ma++;
                        }
                        y->re     = sum.re + **ma   * then->re;
                        (y++)->im = sum.im + **ma++ * then->im;
                        
                        /* Swap state memories */
                        swap = then0;  then0 = now0;  now0 = swap;
                    }
                    then_base += order;
                    now_base += order;
                } /* channel loop */
                /* If the frame size is odd, the buffers have been swapped */
                if (frame & 1) *swapped = !(*swapped);
            } else if (structure == AR) {
                /* The AR algorithm starts at the last coefficient */
                InputRealPtrsType   ARport =  ssGetInputPortRealSignalPtrs(S, CoeffPort1) + order - 1;
                /* End of state memory buffer */ 
                creal_T             *mem_base   = (creal_T *) ssGetDWork(S, DiscState) + order - 1;
                InputRealPtrsType   ar;

                /* Loop over each sample time */
                for (k=0; k < numChans; k++) {
                    /* Move to last coefficient of first filter for this sample time */
                    if (!oneFilterPerFrame)  ar = ARport;

                    /* Loop over each sample time */
                    for (i=0; i < frame; i++) {
                        creal_T *filt_mem   = mem_base;
                        creal_T sum         = *((creal_T *) *uptr++);

                        /* Move to last reflection coefficient */
                        if (oneFilterPerFrame) ar = ARport;

                        sum.re = sum.re - **ar   * filt_mem->re;
                        sum.im = sum.im - **ar-- * filt_mem->im;
                        for (j=1; j < order; j++) {
                            sum.re -= **ar * (--filt_mem)->re;
                            sum.im -= **ar * filt_mem->im;
                            (filt_mem+1)->re = sum.re * **ar   + filt_mem->re;
                            (filt_mem+1)->im = sum.im * **ar-- + filt_mem->im;
                        }
                        *y++ = *filt_mem = sum;
                        
                        /* Go to last coefficient in next set */
                        if (!oneFilterPerFrame)  ar += 2*order;
                    }
                    mem_base += order;
                } /* channel loop */
            } /* structure */

        }
        else { /* Real data, real filter */
            InputRealPtrsType   uptr    = ssGetInputPortRealSignalPtrs(S, InPort);
            real_T              *y      = ssGetOutputPortRealSignal(S, OutPort);

            if (structure == MA) {
                /* The MA algorithm starts at the first coefficient */
                InputRealPtrsType   MAport  =  ssGetInputPortRealSignalPtrs(S, CoeffPort1);
                /* Start of state memory buffer */ 
                boolean_T   *swapped    = ssGetDWork(S, Swapped);
                real_T      *then_base  = ssGetDWork(S, DiscState);
                real_T      *now_base   = then_base;
                real_T      *swap;
                InputRealPtrsType   ma;

                /* Dual state memories are used for maximum speed */
                if (*swapped) then_base += numChans * order;
                else          now_base  += numChans * order;
            
                /* Loop over each sample time */
                for (k=0; k < numChans; k++) {
                    real_T  *then0  = then_base;
                    real_T  *now0   = now_base;

                    /* Move to last coefficient of first filter for this sample time */
                    if (!oneFilterPerFrame)  ma = MAport;

                    /* Loop over each sample time */
                    for (i=0; i < frame; i++) {
                        real_T  *then   = then0;
                        real_T  *now    = now0;
                        real_T  sum;

                        /* Move to first reflection coefficient */
                        if (oneFilterPerFrame) ma = MAport;

                        sum = *now++ = **uptr++;
                        for (j=1; j < order; j++) {
                            *now++ = *then + **ma * sum;
                            sum   += *then++ * **ma++;
                        }
                        *y++ = sum + **ma++ * *then;
                        
                        /* Swap state memories */
                        swap = then0;  then0 = now0;  now0 = swap;
                    }
                    then_base += order;
                    now_base += order;
                } /* channel loop */
                /* If the frame size is odd, the buffers have been swapped */
                if (frame & 1) *swapped = !(*swapped);
            } else if (structure == AR) {
                /* The AR algorithm starts at the last coefficient */
                InputRealPtrsType   ARport =  ssGetInputPortRealSignalPtrs(S, CoeffPort1) + order - 1;
                /* End of state memory buffer */ 
                real_T              *mem_base   = (real_T *) ssGetDWork(S, DiscState) + order - 1;
                InputRealPtrsType   ar;

                /* Loop over each channel */
                for (k=0; k < numChans; k++) {
                    /* Move to last coefficient of first filter for this sample time */
                    if (!oneFilterPerFrame)  ar = ARport;

                    /* Loop over each sample time */
                    for (i=0; i < frame; i++) {
                        real_T  *filt_mem   = mem_base;
                        real_T  sum;

                        /* Move to last reflection coefficient */
                        if (oneFilterPerFrame) ar = ARport;

                        sum = **uptr++ - **ar-- * *filt_mem;
                        for (j=1; j < order; j++) {
                            sum -= **ar * *(--filt_mem);
                            *(filt_mem + 1) = sum * **ar-- + *filt_mem;
                        }
                        *y++ = *filt_mem = sum;
                        
                        /* Go to last coefficient in next set */
                        if (!oneFilterPerFrame)  ar += 2*order;
                    }
                    mem_base += order;
                } /* channel loop */
            } /* structure */
        } /* Real, Real */
    }
}


static void mdlTerminate(SimStruct *S)
{
#ifdef MATLAB_MEX_FILE
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
    * indices for each filter channel, for storing the state values
    * for each lattice section.
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
            ssSetErrorStatus (S, "The input frame size must be >= 1");
            return;
        }
    }
    if ((portWidth % numChans) != 0) {
        ssSetErrorStatus (S, "The input port width must be a multiple of the number of channels");
        return;
    }
    if (coeffPort1Width == 0 || (coeffPort1Width % frame) != 0) {
        ssSetErrorStatus (S, "The coefficient port width must be a multiple frame size");
        return;
    }
    numDelays = numCoeffs = coeffPort1Width / frame;
    if (ssGetNumInputPorts(S) == 3) { /* ARMA Lattice */
        FiltComplex = FiltComplex || (ssGetInputPortComplexSignal(S, CoeffPort1) == COMPLEX_YES);
        if (ssGetInputPortWidth(S, CoeffPort2) == 0 
                    || (ssGetInputPortWidth(S, CoeffPort2) % frame) != 0) {
            ssSetErrorStatus (S, "The AR coefficient port width must be a multiple frame size");
            return;
        }
        coeffPort2Width = ssGetInputPortWidth(S, CoeffPort2) / frame;
        numDelays = MAX(numDelays, coeffPort2Width);
        numCoeffs += coeffPort2Width;
    }

    
    if(!ssSetNumDWork( S, NUM_DWORKS)) return;
    
    /* numEle must be greater than zero */
    numEle = numChans * numDelays;
    /* Trade memory for speed in the MA lattice */
    if ((int_T) mxGetPr(AR_MA_ARG)[0] == MA) numEle *= 2;
    ssSetDWorkWidth(S, Swapped, 1);
    ssSetDWorkDataType(S, Swapped, SS_BOOLEAN);

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
    const int_T   numChans        = (int_T) mxGetPr(CHANS_ARG)[0];
    
    ssSetInputPortWidth (S, port, inputPortWidth);
    if (port == InPort) {
        const int_T   outputPortWidth = ssGetOutputPortWidth(S, OutPort);
        if (outputPortWidth == DYNAMICALLY_SIZED) {
            ssSetOutputPortWidth(S, port, inputPortWidth);
        } else if (outputPortWidth != inputPortWidth) {
            THROW_ERROR(S, "Input/Output port pairs must have the same width");
        }

    } else if (inputPortWidth < 1) {
        THROW_ERROR(S, "Filter order must be at least one");
    }

    if (ssGetNumInputPorts(S) == MAX_NUM_INPORTS) {
        /* Make sure that the AR and MA vectors have the same order */
        int_T width;
        if ( (port == CoeffPort1 && (width=ssGetInputPortWidth(S, CoeffPort2)) != -1 &&
              width != inputPortWidth) || (port == CoeffPort2 &&
              (width=ssGetInputPortWidth(S, CoeffPort1)) != -1 && width != inputPortWidth)
           ) {
            THROW_ERROR(S, "Coefficient ports must have the same width");
        }
    }
}


#define MDL_SET_OUTPUT_PORT_WIDTH
static void mdlSetOutputPortWidth(SimStruct *S, int_T port, int_T outputPortWidth)
{
    const int_T   inputPortWidth  = ssGetInputPortWidth(S, InPort);
    const int_T   numChans        = (int_T) mxGetPr(CHANS_ARG)[0];
    
    ssSetOutputPortWidth (S, port, outputPortWidth);
    if (inputPortWidth == DYNAMICALLY_SIZED) {
        ssSetInputPortWidth(S, InPort, outputPortWidth);

    } else if (inputPortWidth != outputPortWidth) {
        THROW_ERROR(S, "Input/Output port pairs must have the same width");
    }
}

#define MDL_SET_INPUT_PORT_COMPLEX_SIGNAL
static void mdlSetInputPortComplexSignal(SimStruct *S, int_T portIdx,
                                         CSignal_T      iPortComplexSignal)
{
    ssSetInputPortComplexSignal(S, portIdx, iPortComplexSignal ? COMPLEX_YES : COMPLEX_NO);
    /* If any of the input signal or coeffients are complex, output is complex */
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
    SFcnCache       *cache            = (SFcnCache *)ssGetUserData(S);
    boolean_T       *flags            = cache->Flags;
    int_T           numIC             = mxGetNumberOfElements(IC_ARG);
    const char      *names[NUM_FLAGS] = {"Zeros", "Poles", "DataComplex", 
                                         "FiltComplex", "ZerosComplex", 
                                         "PolesComplex"};
    real_T          *ICr              = mxGetPr(IC_ARG);
    real_T          *ICi              = mxGetPi(IC_ARG);
    real_T          dummy             = 0.0;
    int32_T         chans             = (int32_T)mxGetPr(CHANS_ARG)[0];
    int32_T         filtPerFrame      = (mxGetPr(FILT_PER_FRAME_ARG)[0] == 
                                         UPDATE_EVERY_FRAME);


    if (numIC == 0) {
        /* SSWRITE_VALUE_*_VECT does not support empty vectors */
        numIC = 1;
        ICr = ICi = &dummy;
    }

    if (!ssWriteRTWParamSettings(S, (int_T) NUM_FLAGS + 3,

                                 SSWRITE_VALUE_DTYPE_ML_VECT, "IC", ICr, ICi,
                                 numIC, 
                                 DTINFO(SS_DOUBLE, mxIsComplex(IC_ARG)),

                                 SSWRITE_VALUE_DTYPE_NUM, "Chans",
                                 &chans,
                                 DTINFO(SS_INT32,0),

                                 SSWRITE_VALUE_DTYPE_NUM, "FiltPerFrame", 
                                 &filtPerFrame,
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

/* [EOF] sdspvlat.c */
