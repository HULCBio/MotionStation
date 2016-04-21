/*
 * SDSPDLY A SIMULINK  integer sample delay block.
 * 
 * Note: you can only break algebraic loops if 
 *       (minimum delay) >= (frame size).
 *
 *   
 *  Copyright 1995-2002 The MathWorks, Inc.
 *  $Revision: 1.34 $  $Date: 2002/04/14 20:44:51 $
 */

#define S_FUNCTION_LEVEL 2
#define S_FUNCTION_NAME sdspdly

#include "dsp_sim.h"


/*
 * Defines for easy access of the input parameters
 */
enum {ARGC_DELAY=0, ARGC_IC, ARGC_CHANS, ARGC_DF, NUM_ARGS};
#define DLY_ARG	    ssGetSFcnParam(S,ARGC_DELAY)    /* Delays */
#define IC_ARG	    ssGetSFcnParam(S,ARGC_IC)	    /* Initial Conditions */
#define CHANS_ARG   ssGetSFcnParam(S,ARGC_CHANS)    /* Number of Channels */
#define DF_ARG      ssGetSFcnParam(S,ARGC_DF)       /* Frame-based Direct Feedthrough */

/* An invalid number of channels is used to flag sample-based operation */
const int_T SAMPLE_BASED = -1;

/* Input and output ports */
enum {InPort=0, NUM_INPORTS};
enum {OutPort=0, NUM_OUTPORTS};

 /* DWork indices */
enum {DelayElems=0, BufLenIdx, BufOffsetIdx, NUM_DWORKS};
const BuiltInDTypeId DWorkDataTypes[NUM_DWORKS] = {SS_DOUBLE, SS_INT32, SS_INT32};

typedef struct {
    int_T nIC1, nIC2;
} SFcnCache;

#ifdef MATLAB_MEX_FILE
#define MDL_CHECK_PARAMETERS
static void mdlCheckParameters(SimStruct *S) 
{
    const char      *msg        = NULL;
    const int_T	    numDlyArg   = mxGetNumberOfElements(DLY_ARG);
    const int_T	    numChanArg  = mxGetNumberOfElements(CHANS_ARG);
    const boolean_T runTime     = (boolean_T)(ssGetSimMode(S) != SS_SIMMODE_SIZES_CALL_ONLY);
    int_T           numChans    = 1;
    boolean_T       sampleBased = false;
    int_T           i, id;
    real_T          d;

    if (runTime || numChanArg >= 1) {
        if (numChanArg != 1) {
            msg = "Specify an integer number of channels";
            goto FCN_EXIT;
        }
        numChans = (int_T) mxGetPr(CHANS_ARG)[0];
        sampleBased = (boolean_T)(numChans == SAMPLE_BASED);
        if ((numChans <= 0 && !sampleBased)	|| (numChans != mxGetPr(CHANS_ARG)[0])) {
            msg = "Number of channels should be a positive scalar integer. "
	            "If it is -1, the number of channels equals the port width";
            goto FCN_EXIT;
        }
    }

    if (runTime || numDlyArg >= 1) {
        for (i=0; i < numDlyArg; i++) {
            d = mxGetPr(DLY_ARG)[i];
            id = (int_T)d;
            if ((id != d) || (d < 0)) {
                msg = "Delay must be a non-negative integer";
                goto FCN_EXIT;
            }
        }
    }

    FCN_EXIT:
        ssSetErrorStatus(S, msg);
}
#endif


static void mdlInitializeSizes(SimStruct *S)
{
    int_T     numDelays;
    boolean_T runTime;
    int_T     i, directFeedThrough;

    ssSetNumSFcnParams(S, NUM_ARGS);
#if defined(MATLAB_MEX_FILE)
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) return;
    mdlCheckParameters(S);
    if (ssGetErrorStatus(S) != NULL) return;
#endif

    numDelays   = mxGetNumberOfElements(DLY_ARG);
    runTime     = (boolean_T)(ssGetSimMode(S) != SS_SIMMODE_SIZES_CALL_ONLY);

    ssSetSFcnParamNotTunable(S, ARGC_DELAY);
    ssSetSFcnParamNotTunable(S, ARGC_IC);
    ssSetSFcnParamNotTunable(S, ARGC_CHANS);
    ssSetSFcnParamNotTunable(S, ARGC_DF);

    if (!ssSetNumInputPorts(S, NUM_INPORTS)) return;
    ssSetInputPortComplexSignal(S, InPort, COMPLEX_INHERITED);
    ssSetInputPortWidth(        S, InPort, DYNAMICALLY_SIZED);
    ssSetInputPortReusable(    S, InPort, 0);  /* Cannot un-test point the input since we read inputs during mdlUpdate */
    ssSetInputPortOverWritable( S, InPort, 0);  /* revisits inputs multiple times */

    /* Direct feedthrough should be set for delays less than one frame.
     * However, we don't have acess to the frame size yet.
     * For frame-based, we will use the value passed from the
     * mask dialog and check for consistency in mdlStart().
     */
    directFeedThrough = 1;
    if (runTime) {
        if ((int_T) mxGetPr(CHANS_ARG)[0] == SAMPLE_BASED) {
            directFeedThrough = 0;
	    for (i=0; i < numDelays; i++) {
		if ((int_T)mxGetPr(DLY_ARG)[i] < 1) {
		    directFeedThrough = 1;
		    break;
		}
	    }
        } else {
            directFeedThrough = (int_T) mxGetPr(DF_ARG)[0];
        }
    }
    ssSetInputPortDirectFeedThrough(S, InPort, directFeedThrough);

    if (!ssSetNumOutputPorts(S,	NUM_OUTPORTS)) return;
    ssSetOutputPortWidth(        S, OutPort, DYNAMICALLY_SIZED);
    ssSetOutputPortComplexSignal(S, OutPort, COMPLEX_INHERITED);
    ssSetOutputPortReusable(    S, OutPort, 1);

    if(!ssSetNumDWork( S, DYNAMICALLY_SIZED)) return;

    ssSetNumSampleTimes(S, 1);
    ssSetOptions(       S, SS_OPTION_EXCEPTION_FREE_CODE);
}

static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, FIXED_IN_MINOR_STEP_OFFSET);
}


#define MDL_START
static void mdlStart (SimStruct *S)
{
#ifdef MATLAB_MEX_FILE
    const int_T     numDelays   = mxGetNumberOfElements(DLY_ARG);
    const real_T    *delays     = (real_T *) mxGetPr(DLY_ARG);
    int_T           nChans      = (int_T) mxGetPr(CHANS_ARG)[0];
    const int_T     portWidth   = ssGetInputPortWidth(S, InPort);
    int_T           i, nDims, nIC1, nIC2, maxDelay;
    const int_T     *dims;

    CallocSFcnCache(S, SFcnCache);

    if (ssGetSampleTime(S,0) == CONTINUOUS_SAMPLE_TIME) {
        ssSetErrorStatus(S,"Inputs to block must have discrete sample times");
        return;
    }	
    if (nChans == SAMPLE_BASED) {
        nChans = portWidth;
    } else if (ssGetInputPortDirectFeedThrough(S, InPort) == 0) {
        int_T frame = portWidth / nChans;
        for (i=0; i < numDelays; i++) {
            if ((int_T) delays[0] < frame) {
                ssSetErrorStatus(S,"For direct feedthrough to be off, "
	                "the minimum delay cannot be smaller than the frame size");
                return;
            }
        }
    }

    if (numDelays > 1 && numDelays != nChans) {
        ssSetErrorStatus(S,"Specify one delay or one delay per channel");
        return;
    }
    maxDelay = (int_T) delays[0];
    for (i=1; i < numDelays; i++) {
        maxDelay = ((int_T)delays[i] > maxDelay ? (int_T)delays[i] : maxDelay);
    }

    /* For our initial conditions, we require that the last dimension is either
     * one or the maximum of the delays.  We also require that the product of the
     * preceding dimensions is equal to one or the number of channels.
     * We also support a single, scalar-expanded IC.
     */
    if (!mxIsNumeric(IC_ARG)) {
        ssSetErrorStatus(S,"The initial conditions must be numeric.  No strings, cell arrays, etc");
        return;
    }
    nDims = mxGetNumberOfDimensions(IC_ARG);
    if (nDims > 3) {
        ssSetErrorStatus(S,"The maximum dimensionality for the initial condition "
                        "matrix is three");
        return;
    }
    dims = mxGetDimensions(IC_ARG);
    if (mxGetNumberOfElements(IC_ARG) <= 1) {  /* Single or empty IC, scalar expand */
        nIC1 = nIC2 = 1;
    } else if (dims[0]*dims[1] == nChans) { /* vector or 2-D matrix of IC's per time step */
        nIC1 = nChans;
        if (nDims < 3) nIC2 = 1;
        else {
            nIC2 = dims[2];  /* An array of IC's per time step */
            if (nIC2 != maxDelay) {
                ssSetErrorStatus(S,"The third dimension of the IC's must equal the maximum delay");
                return;
            }
        }
    } else { /* Vector of IC's per time step.  Number of rows must equal nChans */
        nIC1 = dims[0];
        nIC2 = dims[1];
        if (nIC1 != nChans || nIC2 != maxDelay) {
            if (nIC1 == 1 || nIC2 == 1) {
                ssSetErrorStatus(S, "For vector initial conditions, the number of elements must equal "
                    "one or the number of channels");
            } else {
                ssSetErrorStatus(S, "For array initial conditions, the last dimension of the matrix must "
                "be either one or the maximum delay.  The product of the preceding dimensions must "
                "equal the number of channels");
            }
            return;
        }
    }

    {
        SFcnCache *cache = ssGetUserData(S);
        cache->nIC1 = nIC1;
        cache->nIC2 = nIC2;
    }

    if (mxIsComplex(IC_ARG) && ssGetInputPortComplexSignal(S, InPort) != COMPLEX_YES) {
        ssSetErrorStatus(S,"Use real initial conditions with real data");
        return;
    }
#endif
}


#define MDL_INITIALIZE_CONDITIONS
static void mdlInitializeConditions(SimStruct *S)
{
    real_T	    *delays     = (real_T *) mxGetPr(DLY_ARG);
    const int_T	    numDelays   = mxGetNumberOfElements(DLY_ARG);
    int_T           *bufLen     = (int_T *) ssGetDWork(S, BufLenIdx);
    int_T           *bufOffset  = (int_T *) ssGetDWork(S, BufOffsetIdx);
    const int_T     portWidth   = ssGetInputPortWidth(S, InPort);
    int_T           nChans      = (int_T) mxGetPr(CHANS_ARG)[0];
    const boolean_T cplx        = (boolean_T) (ssGetDWorkComplexSignal(S, DelayElems) == COMPLEX_YES);
    SFcnCache       *cache      = ssGetUserData(S);
    int_T           nIC1        = cache->nIC1;
    int_T           nIC2        = cache->nIC2;
    int_T	    i, j, extra;

    if (nChans == SAMPLE_BASED) nChans = portWidth;

    /* If direct feedthrough is off, we need to buffer an entire frame of data
     * in addition to the samples required for the delay.  This is so that
     * ALL samples in the input frame can be delayed by the specified amount.
     * Otherwise, we need only to buffer one input sample rather than the whole frame.
     */
    if (ssGetInputPortDirectFeedThrough(S, InPort)) {
        extra = 1;
    } else {
        extra = portWidth / nChans;
    }

    for (i=0; i < numDelays; i++) {
        bufLen[i]  = (int_T) delays[i] + extra;
        bufOffset[i] = (int_T) delays[i] - 1;
    }

    if (nIC1*nIC2 == 1) { /* Use a single IC for all states */
        int_T numElements = ssGetDWorkWidth(S, DelayElems);
        if (cplx) {
            creal_T	*buff = (creal_T *) ssGetDWork(S, DelayElems);
            creal_T	 ic;

            ic.re = (mxGetPr(IC_ARG) == NULL) ? (real_T) 0.0 : mxGetPr(IC_ARG)[0];
            ic.im = (mxGetPi(IC_ARG) == NULL) ? (real_T) 0.0 : mxGetPi(IC_ARG)[0];

            for (j=0; j++ < numElements;    ) *buff++ = ic;

        } else {
            real_T  *buff   = (real_T *) ssGetDWork(S, DelayElems);
            real_T  ic      = (mxGetPr(IC_ARG) == NULL) ? (real_T) 0.0 : mxGetPr(IC_ARG)[0];
            for (j=0; j++ < numElements;    ) *buff++ = ic;
        }
    } else if (nIC2 == 1) { /* nIC1 == nChans */
	/* For each channel, use a single IC for every delay element */
        if (cplx) {
            creal_T	*buff	= (creal_T *) ssGetDWork(S, DelayElems);
            real_T	*re	= mxGetPr(IC_ARG);
            real_T	*im	= mxGetPi(IC_ARG);

            for (i=0; i < nChans; i++) {
                int_T   delay   = (numDelays > 1 ? (int_T)delays[i] : (int_T)delays[0]);
                creal_T	ic;

                ic.re = *re++;
                ic.im = (im == NULL) ? (real_T) 0.0 : *im++;
                for (j=0; j++ < delay;    ) *buff++ = ic;
                buff += extra;
            }
        } else {
            real_T  *buff   = (real_T *) ssGetDWork(S, DelayElems);
            real_T  *ic     = mxGetPr(IC_ARG);
            for (i=0; i < nChans; i++) {
                int_T   delay   = (numDelays > 1 ? (int_T)delays[i] : (int_T)delays[0]);

                for (j=0; j++ < delay;   ) *buff++ = *ic;
                buff += extra;
                ++ic;
            }
        }
    } else { /* Matrix of IC's */

        if (cplx) {
            creal_T	*buff	= (creal_T *) ssGetDWork(S, DelayElems);

            for (i=0; i < nChans; i++) {
                real_T  *re     = mxGetPr(IC_ARG) + i;
                real_T  *im     = mxGetPi(IC_ARG);
                int_T   delay   = (numDelays > 1 ? (int_T)delays[i] : (int_T)delays[0]);
                creal_T	ic;

                if(im != NULL) im += i;

                for (j=0; j++ < delay;    ) {
                    ic.re = *re;
                    ic.im = (im == NULL) ? (real_T) 0.0 : *im;
                    *buff++ = ic;
                    re += nChans;  
                    im += (im == NULL ? 0 : nChans);
                }
                buff += extra;
            }
        } else {
            real_T  *buff   = (real_T *) ssGetDWork(S, DelayElems);
            for (i=0; i < nChans; i++) {
                real_T  *ic = mxGetPr(IC_ARG) + i;
                int_T   delay   = (numDelays > 1 ? (int_T)delays[i] : (int_T)delays[0]);

                for (j=0; j++ < delay;    ) {
                    *buff++ = *ic;
                    ic += nChans;
                }
                buff += extra;
            }
        }
    }
}


#define MDL_UPDATE
static void mdlUpdate(SimStruct *S, int_T tid) {
    /*
     * In, this mode, we only support a direct feedthrough of 0 where
     * none of the delays can be zero.
     * This allows simulink to break algebraic loops.
     */

    if (ssGetInputPortDirectFeedThrough(S, InPort) == 0) {

        const int_T    *buflen      = (int_T *) ssGetDWork(S, BufLenIdx);
        int_T	       *bufoff      = (int_T *) ssGetDWork(S, BufOffsetIdx);
        const int_T     numDelays   = mxGetNumberOfElements(DLY_ARG);
        const int_T     portWidth   = ssGetInputPortWidth(S, InPort);
        int_T	        nChans      = (int_T) mxGetPr(CHANS_ARG)[0];
        const boolean_T chanDelays  = (boolean_T)(numDelays > 1);
        int_T	        i, k, frame;

        if (nChans == SAMPLE_BASED) nChans = portWidth;
        frame = portWidth / nChans;

        if (ssGetInputPortComplexSignal(S, InPort) == COMPLEX_YES) {
            /* COMPLEX DATA */
            InputPtrsType   uptr    = ssGetInputPortSignalPtrs(S, InPort);
            creal_T         *buff   = (creal_T *) ssGetDWork(S, DelayElems);
            int_T           buffstart;
	            
            for (i=0; i++ < nChans;   ) {
                buffstart = *bufoff;
                for (k=0; k++ < frame;    ) {
                    /* Rotate the circular buffer */
                    if (++buffstart == *buflen) buffstart = 0;
                    *(buff+buffstart) = *((creal_T *)*uptr++);
                }
                buff += *buflen;
                if (chanDelays) {
                    /* Update the per-channel buffer offsets */
                    *bufoff += frame;
                    while (*bufoff >= *buflen) *bufoff -= *buflen;
                    ++bufoff; ++buflen;
                }
            }
        } else {
            /* REAL DATA */
            InputRealPtrsType   uptr    = ssGetInputPortRealSignalPtrs(S, InPort);
            real_T              *buff   = ssGetDWork(S, DelayElems);
            int_T               buffstart;

            for (i=0; i++ < nChans;    ) {
                buffstart = *bufoff;
                for (k=0; k++ < frame;     ) {
                    /* Rotate the circular buffer */
                    if (++buffstart == *buflen) buffstart = 0;
                    *(buff + buffstart) = **(uptr++);
                }
                buff += *buflen;
                if (chanDelays) {
                    /* Update the per-channel buffer offsets */
                    *bufoff += frame;
                    /* The "while" is needed in case the frame length exceeds the delay */
                    while (*bufoff >= *buflen) *bufoff -= *buflen;
                    ++bufoff; ++buflen;
                }
            }
        }
        if (!chanDelays) {
            /* Update the "global" buffer offset */
            *bufoff += frame;
            /* The "while" is needed in case the frame length exceeds the delay */
            while (*bufoff >= *buflen) *bufoff -= *buflen;
        }
    }
}


static void mdlOutputs(SimStruct *S, int_T tid)
{
    const int_T	    portWidth   = ssGetInputPortWidth(S, InPort);
    const real_T   *delays      = (real_T *) mxGetPr(DLY_ARG);
    int_T          *bufoff      = (int_T *) ssGetDWork(S, BufOffsetIdx);
    const int_T	    numDelays   = mxGetNumberOfElements(DLY_ARG);
    const boolean_T chanDelays  = (boolean_T)(numDelays > 1);
    int_T          *buflen      = (int_T *) ssGetDWork(S, BufLenIdx);
    int_T           nChans      = (int_T) mxGetPr(CHANS_ARG)[0];
    int_T           direct      = ssGetInputPortDirectFeedThrough(S, InPort);
    int_T           i, ti, frame, k;

    if (nChans == SAMPLE_BASED) nChans = portWidth;

    /* Frame mode or sample mode with direct feedthrough.
     * inputs and outputs are serviced in mdlOutputs() 
     */
    frame = portWidth / nChans;
    if (ssGetInputPortComplexSignal(S, InPort) == COMPLEX_YES) { /* COMPLEX DATA */
        creal_T         *y      = (creal_T *) ssGetOutputPortSignal(S, OutPort);
        creal_T         *buff   = (creal_T *) ssGetDWork(S, DelayElems);
        InputPtrsType   uptr;
        if (direct) {
            uptr = ssGetInputPortSignalPtrs(S, InPort);
        }

        for (i=0; i++ < nChans;   ) {
            int_T buffstart = *bufoff;
            for (k=0; k++ < frame;   ) {
                if (direct) {
                    if (++buffstart == *buflen) buffstart = 0;
                    *(buff+buffstart) = *((creal_T *)*uptr++);
                    ti = buffstart - (int_T) *delays;
                } else {
                    ti = buffstart - (int_T) *delays + k;
                }
                if (ti < 0) ti += *buflen;
                *y++ = *(buff+ti);
            }
            buff += *buflen;
            if (chanDelays) {
                if (direct) {
                    *bufoff += frame;
                    while (*bufoff >= *buflen) *bufoff -= *buflen;
                }
                ++bufoff; ++buflen; ++delays;
            }
        } /* Channels */

    } else {  /* REAL DATA */
        real_T              *y      = (real_T *) ssGetOutputPortRealSignal(S, OutPort);
        real_T              *buff   = (real_T *) ssGetDWork(S, DelayElems);
        InputRealPtrsType   uptr;
        if (direct) {
            uptr = ssGetInputPortRealSignalPtrs(S, InPort);
        }

        for (i=0; i++ < nChans;    ) {
            int_T buffstart = *bufoff;
            for (k=0; k++ < frame;    ) {
                /* Rotate the circular buffer */
                if (direct) {
                    if (++buffstart == *buflen) buffstart = 0;
                    *(buff + buffstart)  = **(uptr++);
                    ti = buffstart - (int_T) *delays;
                } else {
                    ti = buffstart - (int_T) *delays + k;
                }
                if (ti < 0) ti += *buflen;
                *y++ = *(buff + ti);
            }
            buff += *buflen;
            if (chanDelays) {
                if (direct) {
                    /* Update the per-channel buffer offset */
                    *bufoff += frame;
                    while (*bufoff >= *buflen) *bufoff -= *buflen;
                }
                ++bufoff; ++buflen; ++delays;
            }
        } /* Channels */
    } /* Real Data */

    if (!chanDelays && direct) {
        /* Update the "global" buffer offset */
        *bufoff += frame;
        /* The "while" is needed in case the frame length exceeds the delay */
        while (*bufoff >= *buflen) *bufoff -= *buflen;
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
    const real_T    *delays     = (real_T *) mxGetPr(DLY_ARG);
    const int_T     portWidth   = ssGetInputPortWidth(S, InPort);
    const int_T     numDelays   = mxGetNumberOfElements(DLY_ARG);
    int_T           nChans      = (int_T) (mxGetPr(CHANS_ARG)[0]);
    int_T           total       = 0;
    int_T           i, extra;

    if (nChans == SAMPLE_BASED) nChans = portWidth;
    if (ssGetInputPortDirectFeedThrough(S, InPort)) {
        extra = 1;
    } else {
        extra = portWidth / nChans;
    }

    if (numDelays > 1) {
        for (i=0; i < numDelays; i++) {
            total += (int_T)delays[i] + extra;
        }
    } else {
        total = ((int_T)delays[0] + extra) * nChans;
    }

    /* DWorks: */
    if(!ssSetNumDWork( S, NUM_DWORKS)) return;

    ssSetDWorkWidth(   S, DelayElems,   total);
    ssSetDWorkDataType(S, DelayElems,   DWorkDataTypes[DelayElems]);
    ssSetDWorkComplexSignal(S, DelayElems, ssGetInputPortComplexSignal(S, InPort));

    ssSetDWorkWidth(   S, BufLenIdx,    numDelays);
    ssSetDWorkDataType(S, BufLenIdx,    DWorkDataTypes[BufLenIdx]);

    ssSetDWorkWidth(   S, BufOffsetIdx, numDelays);
    ssSetDWorkDataType(S, BufOffsetIdx, DWorkDataTypes[BufOffsetIdx]);
}


#define MDL_SET_INPUT_PORT_WIDTH
static void mdlSetInputPortWidth(SimStruct *S, int_T port, int_T inputPortWidth)
{
    int_T   outputPortWidth = ssGetOutputPortWidth(S, OutPort);
    int_T   nChans          = (int_T) mxGetPr(CHANS_ARG)[0];

    if (nChans != SAMPLE_BASED && (inputPortWidth % nChans) != 0) {
        ssSetErrorStatus (S, "Input port width must be a multiple of the number of channels");
        return;
    }

    ssSetInputPortWidth (S, port, inputPortWidth);
    if (outputPortWidth == DYNAMICALLY_SIZED) {
        ssSetOutputPortWidth(S, port, inputPortWidth);
    } else if (ssGetOutputPortWidth(S, port) != inputPortWidth) {
        ssSetErrorStatus (S, "Input/Output port pairs must have the same width");
        return;
    }
}

#define MDL_SET_OUTPUT_PORT_WIDTH
static void mdlSetOutputPortWidth(SimStruct *S, int_T port, int_T outputPortWidth)
{
    int_T   inputPortWidth  = ssGetInputPortWidth(S, InPort);
    int_T   nChans          = (int_T) mxGetPr(CHANS_ARG)[0];

    if (nChans != SAMPLE_BASED && (outputPortWidth % nChans) != 0) {
        ssSetErrorStatus (S, "Output port width must be a multiple of the number of channels");
        return;
    }

    ssSetOutputPortWidth (S, port, outputPortWidth);
    if (inputPortWidth == DYNAMICALLY_SIZED) {
        ssSetInputPortWidth(S, port, outputPortWidth);
    } else if (ssGetInputPortWidth(S, port) != outputPortWidth) {
        ssSetErrorStatus (S, "Input/Output port pairs must have the same width");
        return;
    }
}

/* Port complexity handshake */
#include "dsp_cplxhs11.c"
#endif

#define MDL_RTW
#if defined(MATLAB_MEX_FILE) || defined(NRT)
static void mdlRTW(SimStruct *S)
{
    /*
     * Write to the RTW file parameters which are unavailable during execution
     * Since we allow 3-D IC's and TLC does not support 3-D matrices, we
     * need to write out the IC's as a single vector.
     */
    {
        int_T           i;
        int32_T         *delays;
        const real_T    *delaysArg    = (real_T *) mxGetPr(DLY_ARG);
        int_T           nDelays       = mxGetNumberOfElements(DLY_ARG);
        const real_T    *ICr          = mxGetPr(IC_ARG);
        const real_T    *ICi          = mxGetPi(IC_ARG);
        int_T           numIC         = mxGetNumberOfElements(IC_ARG);
        SFcnCache       *cache        = ssGetUserData(S);
        int_T           nIC1          = cache->nIC1;
        int_T           nIC2          = cache->nIC2;
        real_T          dummy         = 0.0;
        int32_T         nChansSetting = (int32_T)mxGetPr(CHANS_ARG)[0];

        
        if (numIC == 0) {
            /* SSWRITE_VALUE_*_VECT does not support empty vectors */
            nIC1 = nIC2 = 1;
            ICr = ICi = &dummy;
            numIC = 1;
        }

        if ((delays=malloc(nDelays*sizeof(delays[0]))) == NULL) {
            THROW_ERROR(S,"memory alloc error");
        }

        for (i = 0; i < nDelays; i++) {
            delays[i] = (int32_T)delaysArg[i];
        }

        if (!ssWriteRTWParamSettings(S, 5,
                                     SSWRITE_VALUE_DTYPE_VECT, "Delays",
                                     delays,
                                     nDelays,
                                     DTINFO(SS_INT32,0),

                                     SSWRITE_VALUE_DTYPE_ML_VECT, "IC",
                                     ICr, ICi, numIC, 
                                     DTINFO(SS_DOUBLE, mxIsComplex(IC_ARG)),

                                     SSWRITE_VALUE_DTYPE_NUM,  "nChans",
                                     &nChansSetting,
                                     DTINFO(SS_INT32,0),

                                     SSWRITE_VALUE_DTYPE_NUM,  "nIC1",
                                     &nIC1,
                                     DTINFO(SS_INT32,0),

                                     SSWRITE_VALUE_DTYPE_NUM,  "nIC2",
                                     &nIC2,
                                     DTINFO(SS_INT32,0))) {
            free(delays);
            return;
        }

        free(delays);
    }
}
#endif

#ifdef	MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-File interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif

/* [EOF] sdspdly.c */
