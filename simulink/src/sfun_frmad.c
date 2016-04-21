/*
 * File : sfun_frmad.c
 * Abstract:
 *    An example of a frame-based A/D converter. During simulation,
 *    this S-function produces a multi-channel sinusoid with 
 *    additive sinusoidal noise.
 *    To build:
 *         mex sfun_frmad.c sfun_frmad_wrapper.c
 *
 *    To configure for Real-Time Workshop:
 *      1) S-function needs to have following specified:
 *         set_param(gcb,'SFunctionModules','sfun_frmad_wrapper')
 *
 *      2) See the template makefile for specifying location to
 *         the sfun_frmad_wrapper.c and sfun_frmad_wrapper.h files.
 *         The easiest way to do this is to copy them to your local
 *         working directory. The next option is to modify your
 *         template makefile to point to the location of where these
 *         files live.
 *
 * Copyright 1990-2004 The MathWorks, Inc.
 * $Revision: 1.7.4.3 $
 */

#define S_FUNCTION_NAME sfun_frmad
#define S_FUNCTION_LEVEL 2

/*
 * Need to include simstruc.h for the definition of the SimStruct and
 * its associated macro definitions.
 */
#include <string.h>
#include <math.h>
#include "simstruc.h"
#include "sfun_frmad_wrapper.h"

enum {NUM_INPORTS=0};
enum {OUTPORT=0, NUM_OUTPORTS};

/* Parameters */
enum {FCN_ARGC = 0, AMP_ARGC, FREQ_ARGC, TS_ARGC, 
      FRMSIZE_ARGC, NOISAMP_ARGC, NOISFREQ_ARGC, NUM_ARGS};

#define FCN_ARG(S)     (ssGetSFcnParam(S,FCN_ARGC))
#define AMP_ARG(S)     (ssGetSFcnParam(S,AMP_ARGC))
#define FREQ_ARG(S)    (ssGetSFcnParam(S,FREQ_ARGC))
#define TS_ARG(S)      (ssGetSFcnParam(S,TS_ARGC))
#define FRMSIZE_ARG(S) (ssGetSFcnParam(S,FRMSIZE_ARGC))
#define NOISAMP_ARG(S) (ssGetSFcnParam(S,NOISAMP_ARGC))
#define NOISFREQ_ARG(S) (ssGetSFcnParam(S,NOISFREQ_ARGC))

#define GET_FRMSIZE(S) (mxGetPr(FRMSIZE_ARG(S)))[0]

/* Definition of some useful macros */
#define OK_TO_CHECK_VAR(S, ARG) ((ssGetSimMode(S) != SS_SIMMODE_SIZES_CALL_ONLY) \
                                 || !mxIsEmpty(ARG))
#define IS_SCALAR(X)        (mxGetNumberOfElements(X) == 1)
#define IS_VECTOR(X)        ((mxGetM(X) == 1) || (mxGetN(X) == 1))
#define IS_DOUBLE(X)        (!mxIsComplex(X) && !mxIsSparse(X) && mxIsDouble(X))
#define IS_SCALAR_DOUBLE(X) (IS_DOUBLE(X) && IS_SCALAR(X))
#define IS_VECTOR_DOUBLE(X) (IS_DOUBLE(X) && IS_VECTOR(X))
#define THROW_ERROR(S,MSG)  {ssSetErrorStatus(S,MSG); return;}
#define PI 3.14159265358979

#undef MAX /* undefining MAX in case it was already defined somewhere else*/
#define MAX(a,b) (((a) >= (b)) ? (a) : (b))

#ifdef MATLAB_MEX_FILE
#define MDL_CHECK_PARAMETERS
static void mdlCheckParameters(SimStruct *S) 
{
    real_T fcn;
    if (OK_TO_CHECK_VAR(S, FCN_ARG(S))) {
        if (!IS_SCALAR_DOUBLE(FCN_ARG(S))) {
            THROW_ERROR(S, "Function argument must be 1 (for constant) or 2 (for sine wave).");
        }
        {
            fcn = mxGetPr(FCN_ARG(S))[0];
            if (fcn != 1.0 && fcn != 2.0) {
                THROW_ERROR(S, "Function argument must be 1 (for constant) or 2 (for sine wave).");
            }
        }
    }

    if (OK_TO_CHECK_VAR(S, AMP_ARG(S))) {
        if (!IS_VECTOR_DOUBLE(AMP_ARG(S))) {
            THROW_ERROR(S, "Amplitude must be a real vector.");
        }
    }

    if (fcn == 2.0) {
        if (OK_TO_CHECK_VAR(S, FREQ_ARG(S))) {
            if (!IS_VECTOR_DOUBLE(FREQ_ARG(S))) {
                THROW_ERROR(S, "Frequency must be a real vector.");
            }
            
            /* Check frequency > 0: */
            {
                real_T *freq    = mxGetPr(FREQ_ARG(S));
                int_T  i;
                for (i = 0; i < mxGetNumberOfElements(FREQ_ARG(S)); i++) {
                    if (freq[i] <= 0.0) {
                        THROW_ERROR(S, "Frequencies must be > 0.");
                    }
                }
            }
            
            if ((mxGetNumberOfElements(FREQ_ARG(S)) > 1) && 
                (mxGetNumberOfElements(AMP_ARG(S)) > 1) &&
                (mxGetNumberOfElements(FREQ_ARG(S)) != 
                 mxGetNumberOfElements(AMP_ARG(S)))) {
                THROW_ERROR(S, "Amplitude and Frequency vectors must be of same length");
            }
        }
    }

    if (OK_TO_CHECK_VAR(S, TS_ARG(S))) {
        if (!IS_SCALAR_DOUBLE(TS_ARG(S))) {
            THROW_ERROR(S, "Sample time must be a real scalar.");
        }
        /* Check Ts > 0: */
        {
            real_T ts = mxGetPr(TS_ARG(S))[0];
            if (ts <= 0.0) {
                THROW_ERROR(S, "Sample time must be > 0.");
            }
        }
    }

    if (OK_TO_CHECK_VAR(S, FRMSIZE_ARG(S))) {
        if (!IS_SCALAR_DOUBLE(FRMSIZE_ARG(S))) {
            THROW_ERROR(S, "Frame size must be a positive integer scalar.");
        }
            /* Check FrameSize is positive int */
        {
            real_T fsize = mxGetPr(FRMSIZE_ARG(S))[0];
            if (fsize <= 0.0 || (fsize != floor(fsize))) {
                THROW_ERROR(S, "Frame size must be a positive integer scalar.");
            }
        }
    }

    if (OK_TO_CHECK_VAR(S, NOISAMP_ARG(S))) {
        if (!IS_SCALAR_DOUBLE(NOISAMP_ARG(S))) {
            THROW_ERROR(S, "Noise amplitude must be a real scalar.");
        }
    }

    if (OK_TO_CHECK_VAR(S, NOISFREQ_ARG(S))) {
        if (!IS_SCALAR_DOUBLE(NOISFREQ_ARG(S))) {
            THROW_ERROR(S, "Noise frequency must be a real scalar.");
        }
        /* Check Ts > 0: */
        {
            real_T noisF = mxGetPr(NOISFREQ_ARG(S))[0];
            if (noisF <= 0.0) {
                THROW_ERROR(S, "Noise frequency must be > 0.");
            }
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

    /* Non-tunable */
    ssSetSFcnParamTunable(S,FCN_ARGC,     0);
    ssSetSFcnParamTunable(S,AMP_ARGC,     1);
    ssSetSFcnParamTunable(S,FREQ_ARGC,    1);
    ssSetSFcnParamTunable(S,TS_ARGC,      0);
    ssSetSFcnParamTunable(S,FRMSIZE_ARGC, 0);
    ssSetSFcnParamTunable(S,NOISAMP_ARGC, 0);
    ssSetSFcnParamTunable(S,NOISFREQ_ARGC,0);
    
    /* Inputs: */
    if (!ssSetNumInputPorts(S, NUM_INPORTS)) return;

    /* Outputs: */
    if (!ssSetNumOutputPorts(S,NUM_OUTPORTS)) return;

    /* Set output */
    {
        int frmSize = (int) GET_FRMSIZE(S);
        int fcn     = (int) (mxGetPr(FCN_ARG(S))[0]);
        int nAmps   = mxGetNumberOfElements(AMP_ARG(S));
        int nFreqs  = mxGetNumberOfElements(AMP_ARG(S));
        int nChans  = (fcn == 1) ? nAmps : MAX(nAmps, nFreqs);

        if (frmSize > 1) {
            ssSetOutputPortMatrixDimensions(S, OUTPORT, frmSize, nChans);
        } else {
            DECL_AND_INIT_DIMSINFO(oDims);
            int_T dims = nChans;

            oDims.width   = nChans;
            oDims.numDims = 1;
            oDims.dims    = &dims;
            ssSetOutputPortDimensionInfo(S, OUTPORT, &oDims);
        }
        ssSetOutputPortFrameData(    S, OUTPORT, (frmSize==1) ? FRAME_NO : FRAME_YES);
        ssSetOutputPortComplexSignal(S, OUTPORT, COMPLEX_NO);
        ssSetOutputPortOptimOpts(     S, OUTPORT, SS_REUSABLE_AND_LOCAL);
    }

    ssSetNumIWork(S, 1);

    ssSetNumSampleTimes(S, 1);
    ssSetOptions(S,
                 SS_OPTION_WORKS_WITH_CODE_REUSE |
                 SS_OPTION_EXCEPTION_FREE_CODE);
}


static void mdlInitializeSampleTimes(SimStruct *S)
{
    const real_T Ts      = mxGetPr(TS_ARG(S))[0];
    const real_T frmSize = GET_FRMSIZE(S);

    ssSetSampleTime(S, 0, Ts*frmSize);
    ssSetOffsetTime(S, 0, 0.0);
    ssSetModelReferenceSampleTimeDisallowInheritance(S);
}


#define MDL_PROCESS_PARAMETERS
static void mdlProcessParameters(SimStruct *S)
{
    ssUpdateAllTunableParamsAsRunTimeParams(S);   
}


#define MDL_START
static void mdlStart(SimStruct *S)
{
#ifdef MATLAB_MEX_FILE
    int *count = ssGetIWork(S);
    *count = 0;
#endif
}


static void mdlOutputs(SimStruct *S, int_T tid)
{
    int_T  frmSize = (int) GET_FRMSIZE(S);
    real_T *y      = ssGetOutputPortSignal(S, OUTPORT);
    real_T *amps   = mxGetPr(AMP_ARG(S));
    real_T *freqs  = mxGetPr(FREQ_ARG(S));
    int_T  fcn     = (int) (mxGetPr(FCN_ARG(S))[0]);
    real_T ts      = mxGetPr(TS_ARG(S))[0];
    int_T  *count  = ssGetIWork(S);
    int_T  nAmps   = mxGetNumberOfElements(AMP_ARG(S));
    int_T  nFreqs  = mxGetNumberOfElements(FREQ_ARG(S));
    real_T noisA   = mxGetPr(NOISAMP_ARG(S))[0];
    real_T noisF   = mxGetPr(NOISFREQ_ARG(S))[0];

    if (fcn == 1) {
        sfun_frmad_const_wrapper(y, frmSize, ts, *count,
                                 nAmps, amps, noisA, noisF);
    } else {
        sfun_frmad_sine_wrapper(y, frmSize, ts, *count,
                                nAmps, amps, nFreqs, freqs,
                                noisA, noisF);
    }
    (*count) += frmSize;
}


static void mdlTerminate(SimStruct *S)
{
#ifdef MATLAB_MEX_FILE
#endif
}


#if defined(MATLAB_MEX_FILE)
#define MDL_SET_WORK_WIDTHS
static void mdlSetWorkWidths(SimStruct *S)
{
    const char_T    *rtParamNames[] = {"Amplitude","Frequency"};
    ssRegAllTunableParamsAsRunTimeParams(S, rtParamNames);   
}
#endif


#if defined(MATLAB_MEX_FILE)
#define MDL_RTW
/* Function: mdlRTW ===========================================================
 * Abstract:
 *      Write out frame size
 */
static void mdlRTW(SimStruct *S)
{
    real_T  noisA = mxGetPr(NOISAMP_ARG(S))[0];
    real_T  noisF = mxGetPr(NOISFREQ_ARG(S))[0];
    real_T  ts    = mxGetPr(TS_ARG(S))[0];
    int_T   fcn   = (int) (mxGetPr(FCN_ARG(S))[0]);
    int32_T fsize = mxGetPr(FRMSIZE_ARG(S))[0];
    if (!ssWriteRTWParamSettings(S, 5,
                                 SSWRITE_VALUE_STR,
                                 "Function", 
                                 (fcn == 1) ? "Constant" : "Sine",
                                 SSWRITE_VALUE_NUM,
                                 "Ts", ts,
                                 SSWRITE_VALUE_DTYPE_NUM,
                                 "FrameSize",&fsize,
                                 DTINFO(SS_INT32, COMPLEX_NO),
                                 SSWRITE_VALUE_NUM,
                                 "NoiseAmp",noisA,
                                 SSWRITE_VALUE_NUM,
                                 "NoiseFreq",noisF)) {
        return; /* An error occurred which will be reported by SL */
    }
}
#endif /* MDL_RTW */

#ifdef	MATLAB_MEX_FILE    
#include "simulink.c"      
#else
#include "cg_sfun.h"       
#endif


/* [EOF] sfun_frmad.c */

