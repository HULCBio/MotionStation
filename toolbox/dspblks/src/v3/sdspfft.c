/*
 * SDSPFFT  FFT S-function.
 * DSP Blockset S-Function to perform an FFT on real or complex inputs. 
 * The outputs are always complex.
 *
 * This SIMULINK S-function computes the FFT of the input vector; 
 * It uses a Cooley-Tukey radix-2, decimation-in-frequency FFT algorithm.
 *
 *  Copyright 1995-2002 The MathWorks, Inc.
 *  $Revision: 1.25 $  $Date: 2002/12/23 22:25:04 $
 */
#define S_FUNCTION_NAME sdspfft
#define S_FUNCTION_LEVEL 2

#define DATA_TYPES_IMPLEMENTED

#include "dsp_sim.h"
#include "dspfft_rt.h"

enum {INPORT=0, NUM_INPORTS}; 
enum {OUTPORT=0, NUM_OUTPORTS}; 
enum {NCHANS_ARGC=0, NUM_ARGS};
#define NCHANS_ARG (ssGetSFcnParam(S,NCHANS_ARGC))


#define MDL_CHECK_PARAMETERS
static void mdlCheckParameters(SimStruct *S)
{
#ifdef MATLAB_MEX_FILE
    real_T d;
    int_T  i;

    /* Number of channels */
    if OK_TO_CHECK_VAR(S, NCHANS_ARG) { 
        if ((mxGetNumberOfElements(NCHANS_ARG) != 1) || 
            !mxIsNumeric(NCHANS_ARG)  || 
            !mxIsDouble(NCHANS_ARG) || 
            mxIsEmpty(NCHANS_ARG)   ||
            mxIsComplex(NCHANS_ARG)) {
            THROW_ERROR(S, "Number of channels must be a scalar.");
        }

        d = mxGetPr(NCHANS_ARG)[0];
        i = (int_T)d;
        if ( (d != i) || (i < 1) ) {
            THROW_ERROR(S, "Number of channels must be an integer > 0");
        }
    }
#endif
}



static void mdlInitializeSizes(SimStruct *S)
{
    ssSetNumSFcnParams(S, NUM_ARGS);

#if defined(MATLAB_MEX_FILE)
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) return;
    mdlCheckParameters(S);
    if (ssGetErrorStatus(S) != NULL) return;
#endif

	/* Parameters */
    ssSetSFcnParamNotTunable(S, NCHANS_ARGC);
    
	/* Inputs: */
    if (!ssSetNumInputPorts(S, NUM_INPORTS)) return;
    ssSetInputPortWidth(             S, INPORT, DYNAMICALLY_SIZED);
    ssSetInputPortDirectFeedThrough( S, INPORT, 1);
    ssSetInputPortComplexSignal(     S, INPORT, COMPLEX_INHERITED);
    ssSetInputPortReusable(          S, INPORT, 1);
    ssSetInputPortOverWritable(      S, INPORT, 1); 
    ssSetInputPortRequiredContiguous(S, INPORT, 1);

    /* Outputs: */
    if (!ssSetNumOutputPorts(S,NUM_OUTPORTS)) return;
    ssSetOutputPortWidth(        S, OUTPORT, DYNAMICALLY_SIZED);
    ssSetOutputPortComplexSignal(S, OUTPORT, COMPLEX_YES);
    ssSetOutputPortReusable(     S, OUTPORT, 1);

    ssSetNumSampleTimes(S, 1);
    ssSetOptions(       S, SS_OPTION_EXCEPTION_FREE_CODE );
}


static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, FIXED_IN_MINOR_STEP_OFFSET);
}



#define MDL_START
static void mdlStart(SimStruct *S)
{
#ifdef MATLAB_MEX_FILE
    const int_T     nchans    = (int_T)mxGetPr(NCHANS_ARG)[0];
    const int_T     N         = ssGetInputPortWidth(S,INPORT) / nchans;
    int_T           dummy;

    if (ssGetSampleTime(S,0) == CONTINUOUS_SAMPLE_TIME) {
        THROW_ERROR(S, "Continuous sample times not allowed for FFT block.");
    }

    /* Check to make sure input size is a power of 2: */
    if (frexp((real_T)N, &dummy) != 0.5) {
        THROW_ERROR(S,"Width of input to FFT must be a power of 2");
    }
    if (N == 1) {
      mexWarnMsgTxt("Computing the FFT of a scalar input.\n");
    }
#endif
}


static void mdlOutputs(SimStruct *S, int_T tid)
{
    const boolean_T c0        = (boolean_T)(ssGetInputPortComplexSignal(S,INPORT) == COMPLEX_YES);
    const int_T     nchans    = (int_T)mxGetPr(NCHANS_ARG)[0];
    const int_T     N         = ssGetInputPortWidth(S,INPORT) / nchans;
    creal_T        *y         = (creal_T *)ssGetOutputPortSignal(S,OUTPORT);
    const boolean_T need_copy = (boolean_T)(ssGetInputPortBufferDstPort(S, INPORT) != OUTPORT);
    
    if (!c0) {
        /* Real */
        const real_T *uptr = ssGetInputPortSignal(S,INPORT);
        
        if(!need_copy) THROW_ERROR(S,"Real input cannot share buffer with complex output.");
        
        /* Scalar */
        if (N == 1) {
            int_T f;
            for (f = 0; f++ < nchans; ) {
                y->re = *uptr++;
                (y++)->im = 0.0;
            }
        } else {
            MWDSP_FFTInterleave_BR_D(y, uptr, nchans, N);
            if (nchans > 1) {
                MWDSP_R2DIT_TRIG_Z(y, nchans/2, N*2, N, 0);
                MWDSP_DblSig_Z(    y, nchans, N);
            }
            /*
             * The following conditional always executes for an odd number of channels,
             * even if the above conditional executes.  That is entirely expected and correct.
             */
            if (nchans & 0x01) {
                /* Double-length algorithm for last channel
                 * Compute one half-length FFT on last channel
                 */
                creal_T *lastCol = (creal_T *)y + N * (nchans-1);
                MWDSP_R2DIT_TRIG_Z( lastCol, 1, N, N/2, 0);
                MWDSP_DblLen_TRIG_Z(lastCol, N);
            }
        } /* end of else N > 1 case */
    } else {    /* Complex */
        const creal_T *uptr = ssGetInputPortSignal(S,INPORT);

        if (need_copy) {  /* Copy and bit-rev at one time */
            MWDSP_R2BR_Z_OOP(y, uptr, nchans, N, N);
        } else {                            /* Perform bit reverse in-place */
            MWDSP_R2BR_Z(y, nchans, N, N);
        }
        MWDSP_R2DIT_TRIG_Z(y, nchans, N, N, 0);
    }
}

static void mdlTerminate(SimStruct *S)
{
}


#ifdef	MATLAB_MEX_FILE
#include "simulink.c"
#else
#include "cg_sfun.h"
#endif
