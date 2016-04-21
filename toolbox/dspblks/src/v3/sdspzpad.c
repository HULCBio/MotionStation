/*
 * SDSPZPAD  S-function to increase the input length to the value specified
 *           by appending zeros.  If the vector is longer than the length
 *           parameter, the output is truncated if the truncation flag is set.
 *
 *   
 *  Copyright 1995-2002 The MathWorks, Inc.
 *  $Revision: 1.22 $  $Date: 2002/04/14 20:41:47 $
 */
#define S_FUNCTION_NAME  sdspzpad
#define S_FUNCTION_LEVEL 2

#include "dsp_sim.h"

enum {INPORT=0};
enum {OUTPORT=0};

enum {PAD_ARGC=0, TRUNC_ARGC, NCHANS_ARGC, NUM_ARGS};
#define PAD_ARG    (ssGetSFcnParam(S,PAD_ARGC))
#define TRUNC_ARG  (ssGetSFcnParam(S,TRUNC_ARGC))
#define NCHANS_ARG (ssGetSFcnParam(S,NCHANS_ARGC))

typedef struct {
    int_T padValue;
} SFcnCache;


#ifdef MATLAB_MEX_FILE
#define MDL_CHECK_PARAMETERS
static void mdlCheckParameters(SimStruct *S) 
{
    /* Pad */
    if (OK_TO_CHECK_VAR(S, PAD_ARG)) {
        real_T d;

        if (!IS_FLINT(PAD_ARG)) {
           THROW_ERROR(S, "Zero pad length must be a scalar integer value");
        }

        d = mxGetPr(PAD_ARG)[0];
        if ( (d < 1) && (d != -1) ) {
           THROW_ERROR(S, "Zero pad length must be > 0, or -1 to inherit input width.");
        }
    }

    /* Truncation */
    if (!IS_FLINT_IN_RANGE(TRUNC_ARG, 0, 1)) {
        THROW_ERROR(S, "Truncation must be 0 or 1 only.");
    }

    /* Number of channels: */
    if (OK_TO_CHECK_VAR(S, NCHANS_ARG)) {
        if (!IS_FLINT_GE(NCHANS_ARG, 1)) {
            THROW_ERROR(S, "Number of channels must be a real, scalar, integer value > 0.");
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

    ssSetSFcnParamNotTunable(S, PAD_ARGC); 
    ssSetSFcnParamNotTunable(S, TRUNC_ARGC);
    ssSetSFcnParamNotTunable(S, NCHANS_ARGC);

    /* Inputs: */
    if (!ssSetNumInputPorts(S, 1)) return;

    ssSetInputPortWidth(            S, INPORT, DYNAMICALLY_SIZED);
    ssSetInputPortDirectFeedThrough(S, INPORT, 1);
    ssSetInputPortComplexSignal(    S, INPORT, COMPLEX_INHERITED);   
    ssSetInputPortReusable(         S, INPORT, 1);

    /* The only situation where the outputs can overwrite the inputs is when
     * the pad length is equal to the input width itself.  This is an important
     * case programmatically.  We can generate good code (no code at all!) if
     * the outputs overwrite the inputs in this case.  Try to allow for it:
     */
    ssSetInputPortOverWritable(     S, INPORT, 1);

    /* Outputs: */
    if (!ssSetNumOutputPorts(S,1)) return;

    ssSetOutputPortWidth(        S, OUTPORT, DYNAMICALLY_SIZED);
    ssSetOutputPortComplexSignal(S, OUTPORT, COMPLEX_INHERITED);  
    ssSetOutputPortReusable(     S, OUTPORT, 1);
    /*
     * A NOTE REGARDING THE OUTPUT PORT REUSABLE SETTING:
     *
     * We could potentially set the output port as a test point, and
     * write out the pad zeros ONE TIME ONLY.  However, the next block
     * downstream would not be able to reuse the buffer, since it is
     * not reusable.
     *
     * It turns out that the most popular block to follow zero-pad is
     * the FFT, and that block would benefit greatly by allowing it to
     * reuse the input buffer.  The FFT would not have to copy the inputs
     * to a second output area prior to the transform, nor allocate the
     * second buffer.
     *
     * It's generally more efficient to write out the pad zeros each time
     * than it is for the FFT to copy the buffer.  We choose to allow the
     * output buffer to be reusable, and write the zeros each time.
     *
     * Plus, we can provide for the case of the outputs overwriting the inputs
     * when the pad length equals the input width.
     */

    ssSetNumSampleTimes(S, 1);
    ssSetOptions(       S, SS_OPTION_EXCEPTION_FREE_CODE);
}


static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, 0.0);
}


#define MDL_START
static void mdlStart(SimStruct *S)
{
#ifdef MATLAB_MEX_FILE
    const int_T      nchans  = (int_T)(mxGetPr(NCHANS_ARG)[0]);
    const int_T      inWidth =  ssGetInputPortWidth(S,INPORT);
    const int_T      N       = inWidth / nchans;
    const boolean_T  trunc   = (boolean_T)mxGetPr(TRUNC_ARG)[0];
    int_T            pad     = (int_T)mxGetPr(PAD_ARG)[0];

    SFcnCache *cache;
    CallocSFcnCache(S, SFcnCache);
    cache = ssGetUserData(S);

    if (inWidth % nchans != 0) {
        THROW_ERROR(S, "The port width must be a multiple of the number of channels.");
    }
    
    /*
     * Pad==-1 indicates pass-thru: no padding or truncation.
     *    -> Set pad length equal to input length.
     *
     * If truncation disallowed, minimum pad is set to the input width.
     */
    if ((pad == -1) || (!trunc && (pad < N))) {
	pad = N;
    }
    cache->padValue = pad;
#endif
}


static void mdlOutputs(SimStruct *S, int_T tid)
{
    /*
     * We won't need to make a copy of the input data ONLY IF the output
     * width = input width, in which case there's nothing to be done!
     */
    const boolean_T need_copy = (boolean_T)(ssGetInputPortBufferDstPort(S, INPORT) != OUTPORT);

    if (need_copy) {
        const SFcnCache *cache   = (SFcnCache *)ssGetUserData(S);
        const boolean_T  c0      = (boolean_T)(ssGetInputPortComplexSignal(S,INPORT) == COMPLEX_YES);
        const int_T      nchans  = (int_T)(mxGetPr(NCHANS_ARG)[0]);
        const int_T      inWidth =  ssGetInputPortWidth(S,INPORT);
        const int_T      N       = inWidth / nchans;

        if (!c0) {
            /*
             * Real:
             */
    	    InputRealPtrsType uptr = ssGetInputPortRealSignalPtrs(S,INPORT);
	    real_T           *y    = ssGetOutputPortRealSignal(S,OUTPORT);
            int_T             c;

            for (c=0; c++ < nchans; ) {  /* frame loop */
                int_T i;

                /* Copy input data: */
                for(i = MIN(N, cache->padValue); i-- > 0; ) {
                    *y++ = **(uptr++);			
	        }

                /* Pad with zeros, only if there's any to add.
                 * There may not be, if truncation is occurring:
                 */
                for (i = cache->padValue - N; i-- > 0; ) {
	            *y++ = (real_T)0.0;
	        }

                /* Only execute if multiple channels, AND if truncation occurring,
                 * so that uptr points to start of next channel of data:
                 */
                if ((nchans > 1) && (N > cache->padValue)) {
                    uptr += N - cache->padValue;
                }
            }
    
        } else {
            /*
             * Complex:
             */
            InputPtrsType  uptr = ssGetInputPortSignalPtrs(S,INPORT);
            creal_T	  *y    = (creal_T *)ssGetOutputPortSignal(S,OUTPORT);
            int_T          c;

            for (c=0; c++ < nchans; ) {  /* frame loop */
                int_T i;

                /* Copy input data: */
                for(i = MIN(N, cache->padValue); i-- > 0; ) {
                    *y++ = *((creal_T *)(*uptr++));
                }

                /* Pad with zeros, only if there's any to add.
                 * There may not be, if truncation is occurring:
                 */
                for (i = cache->padValue - N; i-- > 0; ) {
                    y->re     = (real_T)0.0;
                    (y++)->im = (real_T)0.0;
                }

                /* Only execute if multiple channels, AND if truncation occurring,
                 * so that uptr points to start of next channel of data:
                 */
                if ((nchans > 1) && (N > cache->padValue)) {
                    uptr += N - cache->padValue;
                }
            }
        }
    }
}


static void mdlTerminate(SimStruct *S)
{
#ifdef MATLAB_MEX_FILE
    FreeSFcnCache(S, SFcnCache);
#endif
}


#if defined(MATLAB_MEX_FILE) || defined(NRT)
#define MDL_RTW
static void mdlRTW(SimStruct *S)
{
    /*
     * Write to the RTW file parameters which do not change during execution:
     *    pad length and number of channels
     */
    {
        SFcnCache     *cache = (SFcnCache *)ssGetUserData(S);
        const int32_T nchans = (int32_T)mxGetPr(NCHANS_ARG)[0];

        if (!ssWriteRTWParamSettings(S, 2,
                                     SSWRITE_VALUE_DTYPE_NUM, "PadLength", 
                                     &cache->padValue,
                                     DTINFO(SS_INT32,0),

                                     SSWRITE_VALUE_DTYPE_NUM, "NumChans", 
                                     &nchans,
                                     DTINFO(SS_INT32,0))) {
            return;
        }
    }
}
#endif


#if defined(MATLAB_MEX_FILE)
# define MDL_SET_INPUT_PORT_WIDTH
static void mdlSetInputPortWidth(SimStruct *S, int_T port,
                                    int_T inputPortWidth)
{
    const boolean_T trunc  = (boolean_T)(mxGetPr(TRUNC_ARG)[0]);
    int_T           pad    = (int_T)(mxGetPr(PAD_ARG)[0]);
    const int_T     nchans = (int_T)(mxGetPr(NCHANS_ARG)[0]);
    const int_T     N      = inputPortWidth / nchans;

    ssSetInputPortWidth(S, port, inputPortWidth);
    /*
     * Pad==-1 indicates pass-thru: no padding or truncation.
     *    -> Set pad length equal to input length.
     *
     * If truncation disallowed, minimum pad is set to the input width.
     */
    if ((pad == -1) || (!trunc && (pad < N))) {
        ssSetOutputPortWidth(S, OUTPORT, inputPortWidth);
    } else {
        ssSetOutputPortWidth(S, OUTPORT, pad * nchans);
    }
}


# define MDL_SET_OUTPUT_PORT_WIDTH
static void mdlSetOutputPortWidth(SimStruct *S, int_T port,
                                     int_T outputPortWidth)
{
    int_T           pad   = (int_T)(mxGetPr(PAD_ARG)[0]);
    const boolean_T trunc = (boolean_T)(mxGetPr(TRUNC_ARG)[0]);
    const int_T     nchans = (int_T)(mxGetPr(NCHANS_ARG)[0]);

    ssSetOutputPortWidth(S, port, outputPortWidth);

    /*
     * Pad==-1 indicates pass-thru: no padding or truncation.
     *    -> Set pad length equal to input length.
     *
     * If truncation disallowed, minimum pad is set to the input width.
     */


    if (pad == -1) {
        /* We know the input port width is equal to the output width: */
        ssSetInputPortWidth(S,port,outputPortWidth);

    } else if (trunc) {
        /* The user allowed us to truncate.  Therefore, the output width
         * should be equal to the pad value (times the number of channels)
         * in all cases.
         *
         * Check the output width against pad.
         * NOTE: We do NOT know the input width, since it can be less than,
         *       equal to, or greater than the pad size.
         */
        if (pad * nchans != outputPortWidth) {
            THROW_ERROR(S, "Output port width not equal to the desired pad length.");
        }

    } else {
        /* No truncation will occur, so a pad value < input width will cause output width = input width.
         * All we know is that the input width will always be greater than or equal to the pad length
         * The output width is at least the pad size, or greater.
         */
        if (outputPortWidth < pad * nchans) {
            THROW_ERROR(S, "Output port width cannot be less than the "
                         "pad length when truncation is disallowed");
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

/* [EOF] sdspzpad.c */
