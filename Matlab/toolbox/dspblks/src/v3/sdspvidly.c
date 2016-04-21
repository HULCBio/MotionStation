/*
 * SDSPVIDLY A SIMULINK variable integer delay block.
 *
 *
 * maxDelay is the maximum sample delay to support.  If the requested delay
 * exceeds maxDelay, the maximum delay is substituted.
 *
 *   
 *  Copyright 1995-2004 The MathWorks, Inc.
 *  $Revision: 1.31.4.1 $  $Date: 2004/01/25 22:39:44 $
 *
 */
#define S_FUNCTION_LEVEL 2
#define S_FUNCTION_NAME sdspvidly

#include "dsp_sim.h"

/*
* Defines for easy access of the input parameters
*/
enum {ARGC_MAX_DELAY, ARGC_IC, ARGC_CHANS, NUM_ARGS};
#define DMAX_ARG    ssGetSFcnParam(S,ARGC_MAX_DELAY)
#define IC_ARG	    ssGetSFcnParam(S,ARGC_IC)
#define CHANS_ARG   ssGetSFcnParam(S,ARGC_CHANS)

/* An invalid number of channels is used to flag channel-based operation */
const int_T SAMPLE_BASED = -1;

enum {InPort=0, DelayPort, NUM_INPORTS};
enum {OutPort=0, NUM_OUTPORTS};

enum {BuffOff, DiscState, NUM_DWORKS};

typedef struct {
    int_T nIC1, nIC2;
    boolean_T updatePerSample;
} SFcnCache;


#ifdef MATLAB_MEX_FILE
#define MDL_CHECK_PARAMETERS
static void mdlCheckParameters(SimStruct *S) 
{
    const int_T	    numDlyArg       = mxGetNumberOfElements(DMAX_ARG);
    const int_T	    numChanArg      = mxGetNumberOfElements(CHANS_ARG);
    const int_T	    numICArg        = mxGetNumberOfElements(IC_ARG);
    const boolean_T runTime         = (ssGetSimMode(S) != SS_SIMMODE_SIZES_CALL_ONLY);
    boolean_T       sampleBased     = false;
    int_T           id, numChans;
    real_T d;
    
    if (runTime || numChanArg >= 1) {
        if (numChanArg != 1) {
            THROW_ERROR(S, "Specify an integer number of channels");
        }
        numChans = (int_T) mxGetPr(CHANS_ARG)[0];
        sampleBased = (numChans == SAMPLE_BASED);
        if ((numChans <= 0 && !sampleBased)	|| (numChans != mxGetPr(CHANS_ARG)[0])) {
            THROW_ERROR(S, "Number of channels should be a positive scalar integer. "
                "If it is -1, the number of channels equals the port width");
        }
    }

    /* Check max delay: */
    if (runTime || numDlyArg > 0) {
        if (numDlyArg != 1) { 
            THROW_ERROR(S, "Specify one positive integer maximum delay");
        }
        d = mxGetPr(DMAX_ARG)[0];
        id = (int_T)d;
        if ((id != d) || (d <= 0)) {
            THROW_ERROR(S, "Maximum delay must be a positive scalar integer");
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
    
    ssSetSFcnParamNotTunable(S, ARGC_MAX_DELAY);
    ssSetSFcnParamNotTunable(S, ARGC_IC);
    ssSetSFcnParamNotTunable(S, ARGC_CHANS);

    ssSetNumSampleTimes(S, PORT_BASED_SAMPLE_TIMES);

    if (!ssSetNumInputPorts(S, NUM_INPORTS)) return;

    ssSetInputPortComplexSignal(    S, InPort, COMPLEX_INHERITED);
    ssSetInputPortWidth(            S, InPort, DYNAMICALLY_SIZED);
    ssSetInputPortDirectFeedThrough(S, InPort, 1); /* Zero delay is allowed */
    ssSetInputPortReusable(         S, InPort, 1);
    ssSetInputPortOverWritable(     S, InPort, 0);
    ssSetInputPortSampleTime(       S, InPort, INHERITED_SAMPLE_TIME);

    ssSetInputPortComplexSignal(    S, DelayPort, COMPLEX_NO);
    ssSetInputPortWidth(            S, DelayPort, DYNAMICALLY_SIZED);
    ssSetInputPortDirectFeedThrough(S, DelayPort, 1); /* Most recent delay value is used */
    ssSetInputPortReusable(         S, DelayPort, 1);
    ssSetInputPortOverWritable(     S, DelayPort, 0);
    ssSetInputPortSampleTime(       S, DelayPort, INHERITED_SAMPLE_TIME);

    if (!ssSetNumOutputPorts(S, NUM_OUTPORTS)) return;

    ssSetOutputPortWidth(        S, OutPort, DYNAMICALLY_SIZED);
    ssSetOutputPortComplexSignal(S, OutPort, COMPLEX_INHERITED);
    ssSetOutputPortReusable(     S, OutPort, 1);
    ssSetOutputPortSampleTime(   S, OutPort, INHERITED_SAMPLE_TIME);

    if(!ssSetNumDWork(S, DYNAMICALLY_SIZED)) return;

    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE);
}


/* Set all ports to the identical, discrete rates: */
#include "dsp_ctrl_ts.c"


#define MDL_START
static void mdlStart (SimStruct *S)
{
#ifdef MATLAB_MEX_FILE
    int_T       maxDly      = (int_T) mxGetPr(DMAX_ARG)[0];
    const int_T nDims       = mxGetNumberOfDimensions(IC_ARG);
    const int_T *dims       = mxGetDimensions(IC_ARG);
    const int_T delayWidth  = ssGetInputPortWidth(S, DelayPort);
    int_T       nChans      = (int_T) mxGetPr(CHANS_ARG)[0];
    int_T       nIC1, nIC2, frame;
    
    SFcnCache *cache;
    CallocSFcnCache(S, SFcnCache);
    cache = ssGetUserData(S);

    if (ssGetSampleTime(S,0) == CONTINUOUS_SAMPLE_TIME) {
        THROW_ERROR(S,"Inputs to block must have discrete sample times");
    }	
 
    if (nChans == SAMPLE_BASED) {
        nChans = ssGetInputPortWidth(S, InPort);
        frame = 1;
    } else {
        frame = ssGetInputPortWidth(S, InPort) / nChans;
    }

    if (delayWidth != frame && delayWidth != 1) {
        THROW_ERROR(S,"The width of the delay port must equal one or the frame size");
    }

    cache->updatePerSample = (boolean_T)(delayWidth != 1);

    /* For our initial conditions, we require that the last dimension is either
     * one or the maximum of the delays.  We also require that the product of the
     * preceding dimensions is equal to one or the number of channels.
     * We also support a single, scalar-expanded IC.
     */
    if (!mxIsNumeric(IC_ARG)) {
        ssSetErrorStatus(S,"The initial conditions must be numeric.  No strings, cell arrays, etc");
        return;
    }
    if (nDims > 3) {
        ssSetErrorStatus(S,"The maximum dimensionality for the initial condition "
                        "matrix is three");
        return;
    }
    if (mxGetNumberOfElements(IC_ARG) <= 1) {  /* Single or empty IC, scalar expand */
        nIC1 = nIC2 = 1;
    } else if (dims[0]*dims[1] == nChans) { /* vector or 2-D matrix of IC's per time step */
        nIC1 = nChans;
        if (nDims < 3) nIC2 = 1;
        else {
            nIC2 = dims[2];  /* An array of IC's per time step */
            if (nIC2 != maxDly) {
                ssSetErrorStatus(S,"The third dimension of the IC's must equal the maximum delay");
                return;
            }
        }
    } else { /* Vector of IC's per time step.  Number of rows must equal nChans */
        nIC1 = dims[0];
        nIC2 = dims[1];
        if (nIC1 != nChans || nIC2 != maxDly) {
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
    cache->nIC1 = nIC1;
    cache->nIC2 = nIC2;

    if (mxIsComplex(IC_ARG) && !ssGetInputPortComplexSignal(S, InPort)) {
        THROW_ERROR(S,"Use real initial conditions with real data");
    }
#endif
}


#define MDL_INITIALIZE_CONDITIONS
static void mdlInitializeConditions(SimStruct *S)
{
    const int_T     dmax        = (int_T) mxGetPr(DMAX_ARG)[0];
    int_T           *buffOff    = (int_T *) ssGetDWork(S, BuffOff);
    const int_T     portWidth   = ssGetInputPortWidth(S, InPort);
    const int_T     nRows       = mxGetM(IC_ARG);
    const int_T     nCols       = mxGetN(IC_ARG);
    const int_T     nElems      = mxGetNumberOfElements(IC_ARG);
    int_T           nChans      = (int_T) *mxGetPr(CHANS_ARG);
    const int_T     nDims       = mxGetNumberOfDimensions(IC_ARG);
    const int_T     *dims       = mxGetDimensions(IC_ARG);
    const boolean_T cplx        = (ssGetInputPortComplexSignal(S, InPort) == COMPLEX_YES);
    SFcnCache       *cache      = ssGetUserData(S);
    int_T           nIC1        = cache->nIC1;
    int_T           nIC2        = cache->nIC2;
    int_T           i, j;
    
    *buffOff = dmax - 1;
    
    if (nChans == SAMPLE_BASED) nChans = portWidth;

    if (nIC1*nIC2 == 1) { /* Use a single IC for all states */
        int_T numElements = ssGetDWorkWidth(S, DiscState);
        if (cplx) {
            creal_T *buff   = (creal_T *) ssGetDWork(S, DiscState);
            creal_T ic;

            ic.re = (mxGetPr(IC_ARG) == NULL) ? (real_T) 0.0 : mxGetPr(IC_ARG)[0];
            ic.im = (mxGetPi(IC_ARG) == NULL) ? (real_T) 0.0 : mxGetPi(IC_ARG)[0];

            for (j=0; j++ < numElements;    ) *buff++ = ic;

        } else {
            real_T  *buff   = (real_T *) ssGetDWork(S, DiscState);
            real_T  ic      = (mxGetPr(IC_ARG) == NULL) ? (real_T) 0.0 : mxGetPr(IC_ARG)[0];
            for (j=0; j++ < numElements;    ) *buff++ = ic;
        }

    } else if (nIC2 == 1) { /* nIC1 == nChans */
        /* For each channel, use a single IC for every delay element */
        if (cplx) {
            creal_T	*buff	= (creal_T *) ssGetDWork(S, DiscState);
            real_T	*re	= mxGetPr(IC_ARG);
            real_T	*im	= mxGetPi(IC_ARG);

            for (i=0; i < nChans; i++) {
                creal_T	ic;

                ic.re = *re++;
                ic.im = (im == NULL) ? (real_T) 0.0 : *im++;
                for (j=0; j++ < dmax;    ) *buff++ = ic;
                ++buff;
            }
        } else {
            real_T	*buff	= (real_T *) ssGetDWork(S, DiscState);
            real_T	*ic		= mxGetPr(IC_ARG);
            for (i=0; i < nChans; i++) {
                for (j=0; j++ < dmax;   ) *buff++ = *ic;
                ++ic;
                ++buff;  /* Skip the first (input) memory element */
            }
        }
    } else { /* Matrix of IC's */

        if (cplx) {
            creal_T	*buff	= (creal_T *) ssGetDWork(S, DiscState);

            for (i=0; i < nChans; i++) {
                real_T	*re = mxGetPr(IC_ARG) + i;
                real_T	*im = mxGetPi(IC_ARG);
                creal_T  ic;

                if (im != NULL) {
                    im = im + i;
                }

                for (j=0; j++ < dmax;    ) {
                    ic.re = *re;
                    ic.im = (im == NULL) ? (real_T) 0.0 : *im;
                    *buff++ = ic;
                    re += nChans;  
                    im += (im == NULL ? 0 : nChans);
                }
                ++buff;
            }
        } else {
            real_T	*buff	= (real_T *) ssGetDWork(S, DiscState);
            for (i=0; i < nChans; i++) {
                real_T	*ic	= mxGetPr(IC_ARG) + i;
                for (j=0; j++ < dmax;    ) {
                    *buff++ = *ic;
                    ic += nChans;
                }
                ++buff;
            }
        }
    }
}


static void mdlOutputs(SimStruct *S, int_T tid)
{
    const int_T         portWidth   = ssGetInputPortWidth(S, InPort);
    const int_T         buflen      = (int_T) mxGetPr(DMAX_ARG)[0] + 1;
    InputRealPtrsType   delayPort   = ssGetInputPortRealSignalPtrs(S, DelayPort);
    int_T               nChans      = (int_T) mxGetPr(CHANS_ARG)[0];
    int_T               *bufoff     = (int_T *) ssGetDWork(S, BuffOff);
    SFcnCache           *cache      = ssGetUserData(S);
    const int_T         dmax        = buflen - 1;
    InputRealPtrsType   dtmp;
    int_T               i, dly, ti, frame, k;
    
    if (nChans == SAMPLE_BASED) { /* Channel mode */
        nChans = portWidth;
        frame = 1;
    } else {  /* Frame mode */
        frame = portWidth / nChans;
    }

    if (!(cache->updatePerSample)) {
        dly = (int_T) (**delayPort + 0.5);	/* Get rounded delay time */
        /* Clip delay time to legal range: [0,dmax] */
        dly = (dly < 0 ? 0 : (dly > dmax ? dmax : dly));
    }
    
    if (ssGetInputPortComplexSignal(S, InPort) == COMPLEX_YES) {
        /* COMPLEX DATA */

        InputPtrsType	uptr	= ssGetInputPortSignalPtrs(S, InPort);
        creal_T		*y	= (creal_T *) ssGetOutputPortSignal(S, OutPort);
        creal_T		*buff	= ssGetDWork(S, DiscState);
        int_T		buffstart;

        for (i=0; i < nChans; i++) {   /* Get input samples from channels */
            buffstart = *bufoff;
            dtmp = delayPort;
            for (k=0; k < frame; k++) {
                /* Rotate circular buffer */
                if (++buffstart == buflen) buffstart = 0;
                *(buff + buffstart) = *((creal_T *) *uptr++);

                if (cache->updatePerSample) {
                    dly = (int_T) (**dtmp++ + 0.5);	/* Get rounded delay time */
                    /* Clip delay time to legal range: [0,dmax] */
                    dly = (dly < 0 ? 0 : (dly > dmax ? dmax : dly));
                }
                ti = buffstart - dly;
                if (ti < 0) ti += buflen;
                /* Get required delayed value for output */
                *y++ = *(buff + ti);
            }
            buff += buflen;
        }

    } else {
        /* REAL DATA */

        InputRealPtrsType   uptr    = ssGetInputPortRealSignalPtrs(S, InPort);
        real_T              *y      = ssGetOutputPortRealSignal(S, OutPort);
        real_T              *buff   = ssGetDWork(S, DiscState);
        int_T               buffstart;

        for (i=0; i < nChans; i++) {   /* Record input samples */
            buffstart = *bufoff;
            dtmp      = delayPort;
            for (k=0; k < frame; k++) {
                /* Rotate the circular buffer */
                if (++buffstart == buflen) buffstart = 0;
                *(buff + buffstart)  = **(uptr++);

                if (cache->updatePerSample) {
                    dly = (int_T) (**dtmp++ + 0.5);	/* Get rounded delay time */
                    /* Clip delay time to legal range: [0,dmax] */
                    dly = (dly < 0 ? 0 : (dly > dmax ? dmax : dly));
                }
                ti = buffstart - dly;
                if (ti < 0) ti += buflen;
                *y++ = *(buff + ti);
            }
            buff += buflen;
        }
    }
    *bufoff += frame;
    while (*bufoff >= buflen) *bufoff -= buflen;
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
   /*
    * Extend buffer to allow delays up to DMAX without
    * having to fall back to linear interpolation.
    */
    const int_T dmax        = (int_T) mxGetPr(DMAX_ARG)[0];
    const int_T portWidth   = ssGetInputPortWidth(S, InPort);
    int_T       nChans      = (int_T) *mxGetPr(CHANS_ARG);
    
    if (nChans == SAMPLE_BASED) nChans = portWidth;
    
    if(!ssSetNumDWork( S, NUM_DWORKS)) return;
    ssSetDWorkWidth(   S, BuffOff, 1);
    ssSetDWorkDataType(S, BuffOff, SS_INT32);
 
    ssSetDWorkWidth(S, DiscState, (dmax + 1) * nChans);
    if (ssGetInputPortComplexSignal(S, InPort) == COMPLEX_YES) {
        ssSetDWorkComplexSignal(S, DiscState, COMPLEX_YES);
    }
    
}


#define MDL_SET_INPUT_PORT_WIDTH
static void mdlSetInputPortWidth(SimStruct *S, int_T port, int_T inputPortWidth)
{
    if (port == InPort) {
        int_T outputPortWidth = ssGetOutputPortWidth(S, OutPort);
        int_T nChans          = (int_T) mxGetPr(CHANS_ARG)[0];
    
        if (nChans != SAMPLE_BASED && (inputPortWidth % nChans) != 0) {
            ssSetErrorStatus (S, "Input port width must be a multiple of the number of channels");
            return;
        }

        ssSetInputPortWidth (S, port, inputPortWidth);
        if (outputPortWidth == DYNAMICALLY_SIZED) {
            ssSetOutputPortWidth(S, OutPort, inputPortWidth);
        } else if (outputPortWidth != inputPortWidth) {
            THROW_ERROR(S, "Input/Output port pairs must have the same width");
        }
    } else if (port == DelayPort) {
        ssSetInputPortWidth (S, port, inputPortWidth);
    } 
}

#define MDL_SET_OUTPUT_PORT_WIDTH
static void mdlSetOutputPortWidth(SimStruct *S, int_T port, int_T outputPortWidth)
{
    int_T   inputPortWidth  = ssGetInputPortWidth(S, port);
    int_T   nChans          = (int_T) mxGetPr(CHANS_ARG)[0];
    
    if (nChans != SAMPLE_BASED && (outputPortWidth % nChans) != 0) {
        THROW_ERROR(S, "Output port width must be a multiple of the number of channels");
    }
    
    ssSetOutputPortWidth (S, port, outputPortWidth);
    if (inputPortWidth == DYNAMICALLY_SIZED) {
        ssSetInputPortWidth(S, port, outputPortWidth);

    } else if (ssGetInputPortWidth(S, port) != outputPortWidth) {
        THROW_ERROR(S, "Input/Output port pairs must have the same width");
    }
}


/* Port complexity handshake */
#include "dsp_cplxhs11.c"

#endif /* MATLAB_MEX_FILE */


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
        const int_T     *dims       = mxGetDimensions(IC_ARG);
        const int_T     nDims       = mxGetNumberOfDimensions(IC_ARG);
        const real_T    *ICr        = mxGetPr(IC_ARG);
        const real_T    *ICi        = mxGetPi(IC_ARG);
        int_T           numIC       = mxGetNumberOfElements(IC_ARG);
        SFcnCache       *cache      = ssGetUserData(S);
        int32_T         nIC1        = cache->nIC1;
        int32_T         nIC2        = cache->nIC2;
        real_T          dummy       = 0.0;
        int32_T         nChansSetting = (int32_T)mxGetPr(CHANS_ARG)[0];
	int32_T         i32MaxDelay   = (int32_T)mxGetPr(DMAX_ARG)[0];
        
        if (numIC == 0) {
            /* SSWRITE_VALUE_*_VECT does not support empty vectors */
            nIC1 = nIC2 = 1;
            ICr = ICi = &dummy;
            numIC = 1;
        }
               
        if (!ssWriteRTWParamSettings(S, 6,
                                     SSWRITE_VALUE_DTYPE_NUM,  "maxDelay",
				     &i32MaxDelay,
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
                                     DTINFO(SS_INT32,0),

                                     SSWRITE_VALUE_DTYPE_NUM,  "UpdatePerSample",
                                     &(cache->updatePerSample),
                                     DTINFO(SS_BOOLEAN,0))) {
            return;
        }
    }
}
#endif

#ifdef	MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-File interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif

/* [EOF] sdspvidly.c */
