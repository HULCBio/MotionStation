/*
 * SDSPIFFT  IFFT S-function.  
 * DSP Blockset S-Function to perform an IFFT on complex inputs. 
 * Output either real or complex data. In real output mode, the input
 * data is assumed to be conjugate symmetric. It computes the length N FFT
 * of conjugate-symmetric data using a length N/2 complex FFT.
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.26.4.2 $  $Date: 2004/04/12 23:13:05 $
 */
#define S_FUNCTION_NAME sdspifft
#define S_FUNCTION_LEVEL 2

#include "dsp_sim.h"
#include "dspfft_rt.h"

enum {INPORT=0, NUM_INPORTS}; 
enum {OUTPORT=0, NUM_OUTPORTS}; 
enum {BUFF_IDX=0, MAX_NUM_DWORKS};

enum {FCN_TYPE_ARGC=0, NCHANS_ARGC, NUM_ARGS};
#define FCN_TYPE_ARG (ssGetSFcnParam(S,FCN_TYPE_ARGC))
#define NCHANS_ARG   (ssGetSFcnParam(S,NCHANS_ARGC))

typedef enum {
    fcnOutputReal = 1,
    fcnOutputComplex,
    fcnOutputConjSym
} FcnType;

#define EDIT_OK(S, ARG) ((ssGetSimMode(S) != SS_SIMMODE_SIZES_CALL_ONLY) || !mxIsEmpty(ARG)) 


#define MDL_CHECK_PARAMETERS
static void mdlCheckParameters(SimStruct *S) 
{
#ifdef MATLAB_MEX_FILE
    real_T d;
    int_T  i;

    /* Function type: */
    if ( !mxIsDouble(FCN_TYPE_ARG)                  || 
         (mxGetNumberOfElements(FCN_TYPE_ARG) != 1) || 
         ((mxGetPr(FCN_TYPE_ARG)[0] < 1.0) && 
         (mxGetPr(FCN_TYPE_ARG)[0] > 3.0)) ) {
        THROW_ERROR(S,"Function type must be a scalar:"
            "1 (complex output), 2 (real output) or 3 (conjugate symmetric)");
    }

    /* Number of channels */
    if EDIT_OK(S, NCHANS_ARG) { 
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

    /* Inputs: */
    if (!ssSetNumInputPorts(S, NUM_INPORTS)) return;
    ssSetInputPortWidth(             S, INPORT, DYNAMICALLY_SIZED);
    ssSetInputPortDirectFeedThrough( S, INPORT, 1);
    ssSetInputPortComplexSignal(     S, INPORT, COMPLEX_YES);
    ssSetInputPortReusable(          S, INPORT, 1);
    ssSetInputPortRequiredContiguous(S, INPORT, 1);


    /* Input is overwritable only if the user has requested a complex output
     * (i.e. real or complex mode, NOT conjugate symmetric mode): 
     */
    ssSetInputPortOverWritable(     S, INPORT, 1);

    /* Outputs: */
    if (!ssSetNumOutputPorts(S,NUM_OUTPORTS)) return;
    ssSetOutputPortWidth(S, OUTPORT, DYNAMICALLY_SIZED);
    {
        /* Note: Both real and complex modes generate complex results
         * Only conjugate symmetric generates real output 
         * In real mode, this block is followed by a "Real" block for efficiency
         */
        const FcnType ftype = (FcnType)((int_T)mxGetPr(FCN_TYPE_ARG)[0]);
        ssSetOutputPortComplexSignal(S, OUTPORT, (ftype == fcnOutputConjSym) ? COMPLEX_NO 
                                                                             : COMPLEX_YES);
        ssSetOutputPortReusable(    S, OUTPORT, 1);
    }

    if(!ssSetNumDWork(  S, DYNAMICALLY_SIZED)) return;

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
    const int_T   nchans = (int_T)mxGetPr(NCHANS_ARG)[0];
    const int_T   N      = ssGetInputPortWidth(S,INPORT) / nchans;
    int_T dummy;

    if (ssGetSampleTime(S,0) == CONTINUOUS_SAMPLE_TIME) {
        THROW_ERROR(S, "Continuous sample times not allowed for IFFT block.");
    }

    /* Check to make sure input size is a power of 2: */
    if (frexp((real_T)N, &dummy) != 0.5) {
        THROW_ERROR(S,"Width of input to IFFT must be a power of 2");
    }
    if (N == 1) {
      mexWarnMsgTxt("Computing the IFFT of a scalar input.\n");
    }
#endif
}


static void mdlOutputs(SimStruct *S, int_T tid)
{
    const FcnType ftype = (FcnType)((int_T)mxGetPr(FCN_TYPE_ARG)[0]);
    const creal_T *uptr = (creal_T *) ssGetInputPortSignal(S,INPORT);
    const int_T   nchans = (int_T)mxGetPr(NCHANS_ARG)[0];
    const int_T   N      = ssGetInputPortWidth(S,INPORT) / nchans;

    switch(ftype) {
        case fcnOutputComplex:
        case fcnOutputReal:
        {
            creal_T *y  = (creal_T *)ssGetOutputPortSignal(S,OUTPORT);
            const boolean_T need_copy = (boolean_T)(ssGetInputPortBufferDstPort(S, INPORT) != OUTPORT);
            int_T f;

            if (N == 1) {
                for (f = 0; f++ < nchans; ) {
                    /* Scalar input - output is the input */
                    if (need_copy) {
                        *y++ = *uptr++;
                    }
                }
            } else {
                  if (need_copy) {  /* Copy and bit-rev at one time */
                      MWDSP_R2BR_Z_OOP(y, uptr, nchans, N, N);
                  } else {                            /* Perform bit reverse in-place */
                      MWDSP_R2BR_Z(y, nchans, N, N);
                  }
                  MWDSP_R2DIT_TRIG_Z(y, nchans, N, N, 1);
                  MWDSP_ScaleData_DZ(y, nchans * N, 1.0 / N);
            }
        }
        break;

        case fcnOutputConjSym:
        {
            real_T *y = ssGetOutputPortRealSignal(S,OUTPORT);
            int_T f;

            if (N == 1) {
                for (f = 0; f++ < nchans; ) {

                    /* Scalar input - output is just the real element */
                    *y++ = (uptr++)->re;
                }
            } else {
                if (nchans > 1) {
                    real_T *wkspace = (real_T *)ssGetDWork(S, BUFF_IDX);
                    MWDSP_Ifft_AddCSSignals_Z_Zbr_OOP((creal_T *)y, uptr, nchans, N);
                    MWDSP_R2DIT_TRIG_Z((creal_T *)y, nchans/2, N, N, 1);
                    MWDSP_Ifft_Deinterleave_D_D_Inp(y, nchans/2, 2*N, wkspace);
                }
                if (nchans & 0x01) {
                    real_T *lastColOut = y + N * (nchans-1);
                    const creal_T *lastColIn  = (const creal_T *)uptr + N * (nchans-1);
                    MWDSP_Ifft_DblLen_TRIG_Z_Zbr_Oop((creal_T *)lastColOut, lastColIn, N);
                    MWDSP_R2DIT_TRIG_Z((creal_T *)lastColOut, 1, N/2, N/2, 1);
                }
                MWDSP_ScaleData_DD(y, nchans * N, 1.0 / N);
            }
        }
        break;
    }
}


static void mdlTerminate(SimStruct *S)
{
}


#if defined(MATLAB_MEX_FILE)
#define MDL_SET_WORK_WIDTHS
static void mdlSetWorkWidths(SimStruct *S)
{
    const FcnType ftype   = (FcnType)((int_T)mxGetPr(FCN_TYPE_ARG)[0]);
    const int_T   nchans  = (int_T)mxGetPr(NCHANS_ARG)[0];
    const int_T   NC2     = nchans / 2;
    const int_T   nDWorks = ( (ftype == fcnOutputConjSym) && (NC2 > 0) )
                             ? MAX_NUM_DWORKS : 0;

    if(!ssSetNumDWork(S, nDWorks)) return;

    if (nDWorks > 0){
        ssSetDWorkWidth(        S, BUFF_IDX, NC2);
        ssSetDWorkDataType(     S, BUFF_IDX, SS_DOUBLE);
        ssSetDWorkComplexSignal(S, BUFF_IDX, COMPLEX_YES);
    
    }
}
#endif

#ifdef MATLAB_MEX_FILE
#include "simulink.c"
#else
#include "cg_sfun.h"
#endif

/* [EOF] sdspifft.c */

