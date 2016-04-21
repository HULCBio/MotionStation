/*
 * SDSPWINDOW DSP Blockset CMEX S-Function to compute/apply window functions.
 *
 *   
 *  Copyright 1995-2002 The MathWorks, Inc.
 *  $Revision: 1.18 $  $Date: 2002/04/14 20:41:45 $
 */
#define S_FUNCTION_NAME sdspwindow
#define S_FUNCTION_LEVEL 2

#include "dsp_sim.h"

enum {OUTFCN_ARGC, WINTYPE_ARGC, LENGTH_ARGC, RIPPLE_ARGC, BETA_ARGC, SAMPLING_ARGC, NCHANS_ARGC, NUM_PARAMS};

#define OUTFCN_ARG   (ssGetSFcnParam(S,OUTFCN_ARGC))
#define WINTYPE_ARG  (ssGetSFcnParam(S,WINTYPE_ARGC))
#define LENGTH_ARG   (ssGetSFcnParam(S,LENGTH_ARGC))
#define RIPPLE_ARG   (ssGetSFcnParam(S,RIPPLE_ARGC))
#define BETA_ARG     (ssGetSFcnParam(S,BETA_ARGC))
#define SAMPLING_ARG (ssGetSFcnParam(S,SAMPLING_ARGC))
#define NCHANS_ARG   (ssGetSFcnParam(S,NCHANS_ARGC))

/*
 * NOTE: Sampling must be implemented using "popup evaluate" and not "popup literal",
 *       The literal is preferred, since we can just pass the input mxArray to the
 *       mexCallMATLAB() fcn.  Unfortunately, Simulink does not allow a change in the
 *       width of parameters
 */
enum {SAMPLING_SYMMETRIC=1, SAMPLING_PERIODIC};

enum {OUTFCN_APPLY=1, OUTFCN_GENERATE, OUTFCN_BOTH};  /* must match popup */

enum {WINTYPE_BARTLETT=1, WINTYPE_BLACKMAN, WINTYPE_BOXCAR,
      WINTYPE_CHEBYSHEV, WINTYPE_HAMMING, WINTYPE_HANN, WINTYPE_HANNING,
      WINTYPE_KAISER, WINTYPE_TRIANG};

enum {CACHE_IDX=0, NUM_DWORKS};

/* Return port number corresponding to the "Generate" output port: */
static int_T GenOutport(SimStruct *S)
{
    int_T outfcn = (int_T)(mxGetPr(OUTFCN_ARG)[0]);
    switch(outfcn) {
	case OUTFCN_GENERATE:
	    return(0);
	    break;
	case OUTFCN_BOTH:
	    return(1);
	    break;
	default:
	    return(INVALID_PORT_IDX);
	    break;
    }
}

/* Return port number corresponding to the "Apply" output port: */
static int_T ApplyOutport(SimStruct *S)
{
    int_T outfcn = (int_T)(mxGetPr(OUTFCN_ARG)[0]);
    switch(outfcn) {
	case OUTFCN_APPLY:
	case OUTFCN_BOTH:
	    return(0);
	    break;
	default:
	    return(INVALID_PORT_IDX);
	    break;
    }
}


/* Return window function name from WINTYPE enumeration: */
static const char *GetWindowType(SimStruct *S)
{
    int_T wintype = (int_T)(mxGetPr(WINTYPE_ARG)[0]);
    switch(wintype) {
    case WINTYPE_BARTLETT:
	return("bartlett");
	break;
    case WINTYPE_BLACKMAN:
	return("blackman");
	break;
    case WINTYPE_BOXCAR:
	return("boxcar");
	break;
    case WINTYPE_CHEBYSHEV:
	return("chebwin");
	break;
    case WINTYPE_HAMMING:
	return("hamming");
	break;
    case WINTYPE_HANN:
	return("hann");
	break;
    case WINTYPE_HANNING:
	return("hanning");
	break;
    case WINTYPE_KAISER:
	return("kaiser");
	break;
    case WINTYPE_TRIANG:
	return("triang");
	break;
    default:
	ssSetErrorStatus(S, "Unsupported window type enumeration");
        return("");
	break;
    }
}


#ifdef MATLAB_MEX_FILE
#define MDL_CHECK_PARAMETERS
static void mdlCheckParameters(SimStruct *S)
{
    if(OK_TO_CHECK_VAR(S, NCHANS_ARG)) {
	if(!IS_FLINT_GE(NCHANS_ARG,1)){
	    THROW_ERROR(S, "Number of channels must be scalar integer value > 0.");
	}
    }

    if (!IS_FLINT_IN_RANGE(OUTFCN_ARG, 1, OUTFCN_BOTH)) {
	THROW_ERROR(S, "Output function enumeration value out of range.");
    }
    if (!IS_FLINT_IN_RANGE(WINTYPE_ARG, 1, WINTYPE_TRIANG)) {
	THROW_ERROR(S, "Window type enumeration value out of range.");
    }
    if (!IS_FLINT_IN_RANGE(SAMPLING_ARG, 1, 2)) {
	THROW_ERROR(S, "Sampling enumeration value out of range.");
    }

    /* Ripple, Beta, and Length are edit boxes: */
    if (OK_TO_CHECK_VAR(S, RIPPLE_ARG)) {
	if (!IS_SCALAR_DOUBLE(RIPPLE_ARG)) {
	    THROW_ERROR(S, "Stopband ripple must be a scalar double.");
	}
    }
    if (OK_TO_CHECK_VAR(S, BETA_ARG)) {
	if (!IS_SCALAR_DOUBLE(BETA_ARG)) {
	    THROW_ERROR(S, "Beta must be a scalar double.");
	}
    }

    /*
     * Don't check length if not in generate-only mode,
     * since it is not needed otherwise
     */
    {
	const int_T outfcn = (int_T)(mxGetPr(OUTFCN_ARG)[0]);
	if (outfcn == OUTFCN_GENERATE) {
	    if (OK_TO_CHECK_VAR(S, LENGTH_ARG)) {
		if (!IS_FLINT_GE(LENGTH_ARG, 1)) {
		    THROW_ERROR(S, "Length must be a scalar double > 0.");
		}
	    }
	}
    }
}
#endif /* MDL_CHECK_PARAMETERS */


static void mdlInitializeSizes(SimStruct *S)
{
    int_T outfcn, num_ports;

    ssSetNumSFcnParams(S, NUM_PARAMS);
    
#if defined(MATLAB_MEX_FILE)
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) return;
    mdlCheckParameters(S);
    if (ssGetErrorStatus(S) != NULL) return;
#endif

    /* Set tunable state of all input args: */
    if (ssGetSimMode(S) == SS_SIMMODE_EXTERNAL ||
        ssGetSimMode(S) == SS_SIMMODE_RTWGEN) {
        /* 
         * Parameters which affect the actual window values cannot be
	 * changed during execution in RTW and EXTERNAL mode because
	 * the window values have been statically written.
         */
        ssSetSFcnParamNotTunable(S,WINTYPE_ARGC);
        ssSetSFcnParamNotTunable(S,RIPPLE_ARGC);
        ssSetSFcnParamNotTunable(S,BETA_ARGC);
        ssSetSFcnParamNotTunable(S,SAMPLING_ARGC);
    }
    ssSetSFcnParamNotTunable(S,OUTFCN_ARGC);   /* apply/generate/both       */
    ssSetSFcnParamNotTunable(S,LENGTH_ARGC);   /* length of generate window */
    ssSetSFcnParamNotTunable(S,NCHANS_ARGC);   /* number of channels        */

    
    /* Inputs: */
    outfcn    = (int_T)(mxGetPr(OUTFCN_ARG)[0]);
    num_ports = (outfcn == OUTFCN_GENERATE) ? 0 : 1;  /* # inports */

    if (!ssSetNumInputPorts(S, num_ports)) return;
    if (num_ports > 0) {
	/* Data input port: */
	ssSetInputPortWidth(            S, 0, DYNAMICALLY_SIZED);
	ssSetInputPortComplexSignal(    S, 0, COMPLEX_INHERITED);
	ssSetInputPortDirectFeedThrough(S, 0, 1);
	ssSetInputPortReusable(         S, 0, 1);
	ssSetInputPortOverWritable(     S, 0, 1);
    }

    /* Outputs:
     *
     * Apply window: not test-pointed
     * Generate window: test-pointed to preserve values
     */
    num_ports = (mxGetPr(OUTFCN_ARG)[0] == OUTFCN_BOTH) ? 2 : 1;  /* # outports */
    if (!ssSetNumOutputPorts(S,num_ports)) return;

    if (GenOutport(S) != INVALID_PORT_IDX) {
	if (outfcn == OUTFCN_GENERATE) {
	    /* Generate-only: use window length argument */
		int_T len;
		if (OK_TO_CHECK_VAR(S, LENGTH_ARG)) {
		    len = (int_T)(mxGetPr(LENGTH_ARG)[0]);
		} else {
		    len = 1;  /* Default width is 1 while window length   
			       * argument is undefined to prevent seg fault.
			       */
		}
            ssSetOutputPortWidth(S, GenOutport(S), len);
	} else {
	    /* Must be generate and apply: */
            ssSetOutputPortWidth(S, GenOutport(S), DYNAMICALLY_SIZED);
	}
	ssSetOutputPortComplexSignal(S, GenOutport(S), COMPLEX_NO);
	ssSetOutputPortReusable(     S, GenOutport(S), 0);
    }

    if (ApplyOutport(S) != INVALID_PORT_IDX) {
        ssSetOutputPortWidth(        S, ApplyOutport(S), DYNAMICALLY_SIZED);
	ssSetOutputPortComplexSignal(S, ApplyOutport(S), COMPLEX_INHERITED);
	ssSetOutputPortReusable(     S, ApplyOutport(S), 1);
    }

    if (!ssSetNumDWork(S, DYNAMICALLY_SIZED)) return;

    ssSetNumSampleTimes(S, 1);
    ssSetOptions(       S, SS_OPTION_USE_TLC_WITH_ACCELERATOR);
}


static void mdlInitializeSampleTimes(SimStruct *S)
{
    /*
     * In GENERATE ONLY mode, we do not inherit sample times.
     * Set block to continuous time (use constant sample time?).
     */
    const int_T outfcn = (int_T)(mxGetPr(OUTFCN_ARG)[0]);
    if (outfcn == OUTFCN_GENERATE) {
	ssSetSampleTime(S, 0, CONTINUOUS_SAMPLE_TIME);
	ssSetOffsetTime(S, 0, FIXED_IN_MINOR_STEP_OFFSET);
    } else {
	ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
	ssSetOffsetTime(S, 0, 0.0);
    }
}


/* Return pointer to the window cache: */
static real_T *GetWindowPtr(SimStruct *S)
{
    const int_T outfcn = (int_T)(mxGetPr(OUTFCN_ARG)[0]);
    if (outfcn == OUTFCN_APPLY) {
        return((real_T *)ssGetDWork(S,CACHE_IDX));
    } else {
	return(ssGetOutputPortRealSignal(S, GenOutport(S)));
    }
}


#if defined(MATLAB_MEX_FILE)
#define MDL_PROCESS_PARAMETERS
static void mdlProcessParameters(SimStruct *S)
{
    /*
     * Compute and cache the window values:
     */
    const int_T outfcn   = (int_T)(mxGetPr(OUTFCN_ARG)[0]);
    const int_T nChans   = (outfcn == OUTFCN_GENERATE) ? 1 : (int_T)(mxGetPr(NCHANS_ARG)[0]);
    const int_T N        = ssGetOutputPortWidth(S,0) / nChans;
    mxArray    *output_array[1];

    /* Call MATLAB to compute new window: */
    {
	const int_T wintype       = (int_T)(mxGetPr(WINTYPE_ARG)[0]);
	int_T       nrhs          = 1;
        boolean_T   free_in1      = 0;  /* flag: don't need to destroy input_array[1] */
	mxArray     *input_array[2];

        const char_T *wintype_str = GetWindowType(S);
        if (ssGetErrorStatus(S) != NULL) return;

        /* Construct additional matrix arguments, f required: */
        switch(wintype) {
        case WINTYPE_BLACKMAN:
	case WINTYPE_HAMMING:
	case WINTYPE_HANN:
	case WINTYPE_HANNING:
            {
                input_array[1] = mxCreateString(
                                 (mxGetPr(SAMPLING_ARG)[0] == SAMPLING_PERIODIC)
                                 ? "periodic" : "symmetric");
                nrhs = 2;
                free_in1 = 1;  /* flag to indicate that input_array[1] will need to be destroyed */
            }
            break;
        case WINTYPE_CHEBYSHEV:
	    input_array[1] = (mxArray *)RIPPLE_ARG;
	    nrhs = 2;
            break;
        case WINTYPE_KAISER:
	    input_array[1] = (mxArray *)BETA_ARG;
	    nrhs = 2;
            break;
        default:
            break;
        }

    
        /* Setup window-width argument: */
	input_array[0] = mxCreateDoubleMatrix(1,1,mxREAL);
	*mxGetPr(input_array[0]) = (real_T)N;

        /* Call MATLAB window function, and cleanup: */
	mexCallMATLAB(1, output_array, nrhs, input_array, wintype_str);
	mxDestroyArray(input_array[0]);  /* cleanup */
        if (free_in1) mxDestroyArray(input_array[1]);

	/* Check output_array: */
	if ((output_array[0] == NULL)     ||
            !(IS_DOUBLE(output_array[0])) ||
	    (mxGetNumberOfElements(output_array[0]) != N)) {
	    /* Failure: */
	    if (output_array[0] != NULL) {
		mxDestroyArray(output_array[0]);
	    }
	    THROW_ERROR(S,"Window function call returned invalid results.");
	}
    }

    /* Copy output_array to cache: */
    {
	real_T *x      = mxGetPr(output_array[0]);
        real_T *window = GetWindowPtr(S);
	int_T   i;
	for (i=0; i++ < N; ) {
	    *window++ = *x++;
	}
    }
    mxDestroyArray(output_array[0]);
}
#endif /* MDL_PROCESS_PARAMETERS */


#define MDL_START
static void mdlStart(SimStruct *S)
{
#ifdef MATLAB_MEX_FILE
    /* Check number of channels: */
    {
        const int_T outfcn = (int_T)(mxGetPr(OUTFCN_ARG)[0]);
        if (outfcn != OUTFCN_GENERATE) {
            const int_T inWidth = ssGetInputPortWidth(S, 0);
            const int_T nChans  = (int_T)(mxGetPr(NCHANS_ARG)[0]);
            if (inWidth % nChans != 0) {
                THROW_ERROR(S,"The port width must be a multiple of the number of channels.");
            }
        }
    }
#endif

    /*
     * Compute and cache the window values:
     */
    mdlProcessParameters(S);
}


static void mdlOutputs(SimStruct *S, int_T tid)
{
    const int_T outfcn = (int_T)(mxGetPr(OUTFCN_ARG)[0]);

    /* For generate window only, the test-pointed output data is already present,
     * and no additional output fcn is needed:
     */
    if (outfcn != OUTFCN_GENERATE) {
	const boolean_T  cplx   = (ssGetOutputPortComplexSignal(S, ApplyOutport(S)) == COMPLEX_YES);
        int_T            nchans = (int_T)(mxGetPr(NCHANS_ARG)[0]);
	const int_T      N      = ssGetOutputPortWidth(S, 0) / nchans;

	/* Apply window: */
	if (cplx) {
            InputPtrsType  uptr = ssGetInputPortSignalPtrs(S,0);
	    creal_T       *y    = (creal_T *)ssGetOutputPortSignal(S,0);  /* apply port */

            while(nchans-- > 0) {
	        real_T *w = GetWindowPtr(S);
                int_T   i = N;
	        while(i-- > 0) {
		    y->re     = ((creal_T *)(*uptr  ))->re * *w;
		    (y++)->im = ((creal_T *)(*uptr++))->im * *w++;
	        }
            }

	} else {
	    InputRealPtrsType uptr = ssGetInputPortRealSignalPtrs(S,0);
	    real_T            *y   = ssGetOutputPortRealSignal(S,0);

            while(nchans-- > 0) {
	        real_T *w = GetWindowPtr(S);
                int_T   i = N;
	        while(i-- > 0) {
		    *y++ = **uptr++ * *w++;
	        }
            }
	}
    }
}


static void mdlTerminate(SimStruct *S)
{
}


#if defined(MATLAB_MEX_FILE)
# define MDL_SET_INPUT_PORT_WIDTH
static void mdlSetInputPortWidth(SimStruct *S, int_T port,
                                    int_T width)
{
    const int_T outfcn = (int_T)(mxGetPr(OUTFCN_ARG)[0]);
    const int_T nChans = (outfcn == OUTFCN_GENERATE) ? 1 : (int_T)(mxGetPr(NCHANS_ARG)[0]);
    const int_T N      = width / nChans;

    /* Must be apply, or apply & generate */
    ssSetInputPortWidth(S, port, width);

    if (ApplyOutport(S) != 0) THROW_ERROR(S,"Input port width propagation error.");
    ssSetOutputPortWidth(S, 0, width);

    if (GenOutport(S) != -1) {
	if (GenOutport(S) != 1) THROW_ERROR(S, "Input port width propagation error.");
	ssSetOutputPortWidth(S, GenOutport(S), N);  /* Generate port is one channel only */
    }
}

# define MDL_SET_OUTPUT_PORT_WIDTH
static void mdlSetOutputPortWidth(SimStruct *S, int_T port,
                                     int_T width)
{
    const int_T outfcn = (int_T)(mxGetPr(OUTFCN_ARG)[0]);
    const int_T nChans = (outfcn == OUTFCN_GENERATE) ? 1 : (int_T)(mxGetPr(NCHANS_ARG)[0]);
    const int_T N      = width / nChans;

    /* Must be apply, or apply & generate */
    ssSetOutputPortWidth(S, port, width);
    /* Must be apply port: */
    if (port != 0) THROW_ERROR(S,"Output port width propagation error.");

    if (ssGetNumOutputPorts(S) == 2) {
	ssSetOutputPortWidth(S, 1, N);  /* Generate port is one channel only */
    }
    if (ssGetNumInputPorts(S) > 0) {
	ssSetInputPortWidth(S, 0, width);
    }
}

#define MDL_SET_INPUT_PORT_COMPLEX_SIGNAL
static void mdlSetInputPortComplexSignal(SimStruct *S,
					 int_T port,
					 int_T portComplex)
{
    /* Must be apply, or apply & generate */
    CSignal_T complexity = portComplex ? COMPLEX_YES : COMPLEX_NO;

    ssSetInputPortComplexSignal(S, port, complexity);

    if (ApplyOutport(S) != 0) THROW_ERROR(S, "Input port complexity propagation error.");
    ssSetOutputPortComplexSignal(S, 0, complexity);
}

#define MDL_SET_OUTPUT_PORT_COMPLEX_SIGNAL
static void mdlSetOutputPortComplexSignal(SimStruct *S,
					  int_T port,
					  int_T portComplex)
{
    /* Must be apply, or apply & generate */
    CSignal_T complexity = portComplex ? COMPLEX_YES : COMPLEX_NO;

    if(port != 0) THROW_ERROR(S,"Output port complexity propagation error");
    ssSetOutputPortComplexSignal(S, port, complexity);

    if (ssGetNumInputPorts(S) != 1) THROW_ERROR(S,"Output port complexity propagation error");
    ssSetInputPortComplexSignal(S, 0, complexity);
}

#define MDL_SET_WORK_WIDTHS
static void mdlSetWorkWidths(SimStruct *S)
{
    const int_T outfcn = (int_T)(mxGetPr(OUTFCN_ARG)[0]);

    if (outfcn == OUTFCN_APPLY) {
        const int_T nChans = (int_T)(mxGetPr(NCHANS_ARG)[0]);
        int_T       N      = ssGetOutputPortWidth(S, 0) / nChans;  /* guarantee at least one output port */

        if (!ssSetNumDWork(S, NUM_DWORKS)) return;

        /* Window cache: */
        ssSetDWorkName(         S, CACHE_IDX, "Samples");
        ssSetDWorkUsedAsDState( S, CACHE_IDX, 1);
        ssSetDWorkWidth(        S, CACHE_IDX, N);
        ssSetDWorkDataType(     S, CACHE_IDX, SS_DOUBLE);
        ssSetDWorkComplexSignal(S, CACHE_IDX, COMPLEX_NO);

    } else {
        if (!ssSetNumDWork(S, 0)) return;
    }
}

#endif


#if defined(MATLAB_MEX_FILE) | defined(NRT)
#define MDL_RTW
static void mdlRTW(SimStruct *S)
{
    /*
     * Write to the RTW file parameters which do not change during execution:
     */
    {
        const int_T   outfcn     = (int_T)(mxGetPr(OUTFCN_ARG)[0]);
        const int_T   nChans     = (outfcn == OUTFCN_GENERATE ? 1 : 
                                    (int_T)(mxGetPr(NCHANS_ARG)[0]));
        const int_T   N          = ssGetOutputPortWidth(S,0) / nChans;
        char_T       *outfcn_str = NULL;  /* Silence compiler warnings */
        int32_T      numChannels = (int32_T)mxGetPr(NCHANS_ARG)[0];

        switch(outfcn) {
          case OUTFCN_APPLY:
            outfcn_str = "ApplyOnly";
            break;
          case OUTFCN_GENERATE:
            outfcn_str = "GenerateOnly";
            break;
          case OUTFCN_BOTH:
            outfcn_str = "ApplyAndGenerate";
            break;
        }
        if (!ssWriteRTWParamSettings(S, 4,
                                     SSWRITE_VALUE_QSTR,  "OutputMode", 
                                     outfcn_str,

                                     SSWRITE_VALUE_DTYPE_NUM,  "NumChannels",
                                     &numChannels,
                                     DTINFO(SS_INT32,0),

                                     SSWRITE_VALUE_QSTR,  "WindowType",
                                     GetWindowType(S),

                                     SSWRITE_VALUE_VECT, "Samples",
                                     GetWindowPtr(S), N)) {
            return;
        }
    }
}
#endif


#ifdef	MATLAB_MEX_FILE  
#include "simulink.c"    
#else
#include "cg_sfun.h"     
#endif

/* [EOF] sdspwindow.c */
