/*
 * File : sfun_frmdft.c
 * Abstract:
 *    A block which implements a multi-channel frame-based Discrete-Fourier
 *    transform (and its inverse).
 *
 *    To build:
 *         mex sfun_frmdft.c sfun_frmdft_wrapper.c
 *
 *    To configure for Real-Time Workshop:
 *      1) S-function needs to have following specified:
 *         set_param(gcb,'SFunctionModules','sfun_frmdft_wrapper')
 *
 *      2) See the template makefile for specifying location to
 *         the sfun_frmdft_wrapper.c and sfun_frmdft_wrapper.h files.
 *         The easiest way to do this is to copy them to your local
 *         working directory. The next option is to modify your
 *         template makefile to point to the location of where these
 *         files live.
 *
 * Copyright 1990-2004 The MathWorks, Inc.
 * $Revision: 1.6.4.4 $
 */
#define S_FUNCTION_LEVEL 2
#define S_FUNCTION_NAME sfun_frmdft

#include <math.h>
#include "simstruc.h"
#include "sfun_frmdft_wrapper.h"


/*
 * Defines for easy access of the input parameters
 */
enum {ARGC_FCNARG=0, ARGC_DFTSIZE, NUM_ARGS};
#define DFT_ARG(S)  ssGetSFcnParam(S,ARGC_DFTSIZE) 
#define FCN_ARG(S)  ssGetSFcnParam(S,ARGC_FCNARG) 

enum {DFT_FCN=1, IDFT_FCN};

/* Input and output ports */
enum {INPORT=0, NUM_INPORTS};
enum {OUTPORT=0, NUM_OUTPORTS};

#define OK_TO_CHECK_VAR(S, ARG) (ssGetSimMode(S) != SS_SIMMODE_SIZES_CALL_ONLY)
                      
#define SET_ERROR(S,MSG)  {ssSetErrorStatus(S,MSG); return;}

#define IS_SCALAR(X)        (mxGetNumberOfElements(X) == 1)
#define IS_DOUBLE(X)        (!mxIsComplex(X) && !mxIsSparse(X) && mxIsDouble(X) && mxIsNumeric(X) && !mxIsLogical(X) && !mxIsEmpty(X))
#define IS_SCALAR_DOUBLE(X) (IS_DOUBLE(X) && IS_SCALAR(X))

#ifdef MATLAB_MEX_FILE
#define MDL_CHECK_PARAMETERS
static void mdlCheckParameters(SimStruct *S) 
{
    real_T fcn = 0.0;
    if (OK_TO_CHECK_VAR(S, FCN_ARG(S))) {
        if ( !IS_SCALAR_DOUBLE(FCN_ARG(S)) ) {
            SET_ERROR(S, "Function argument must be 1 (DFT) or 2 (IDFT).");
        }

        fcn = mxGetPr(FCN_ARG(S))[0];
        if (((int_T) fcn != DFT_FCN) && ((int_T)fcn != IDFT_FCN)) {
            SET_ERROR(S, "Function argument must be 1 (DFT) or 2 (IDFT).");
        }
    } else {
        if ( !IS_SCALAR_DOUBLE(FCN_ARG(S)) ) {
            SET_ERROR(S, "Function argument must be 1 (DFT) or 2 (IDFT).");
        }
    }

    if ((int_T) fcn == DFT_FCN) {
        real_T dftSize; 
        if (OK_TO_CHECK_VAR(S, DFT_ARG(S))) {
            if (!IS_SCALAR_DOUBLE(DFT_ARG(S))) {
                SET_ERROR(S,"DFT size must be a double scalar.");
            }
        }
 
        dftSize = (mxGetPr(DFT_ARG(S)))[0];
        if ((dftSize != floor(dftSize)) || (dftSize <= 1)) {
            SET_ERROR(S,"DFT size must be a positive integer > 1.");
        }
    } else {
        if (!IS_SCALAR_DOUBLE(DFT_ARG(S))) {
           SET_ERROR(S,"DFT size must be a double scalar.");
        }
    }
}
#endif


static void mdlInitializeSizes(SimStruct *S)
{
    int_T fcn;
    ssSetNumSFcnParams(S, NUM_ARGS);
#if defined(MATLAB_MEX_FILE)
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) return;
    mdlCheckParameters(S);
    if (ssGetErrorStatus(S) != NULL) return;
#endif

    ssSetSFcnParamNotTunable(S, ARGC_FCNARG);
    ssSetSFcnParamNotTunable(S, ARGC_DFTSIZE);

    /* Input: */
    fcn = (int_T) (mxGetPr(FCN_ARG(S))[0]);
    if (!ssSetNumInputPorts(S, NUM_INPORTS)) return;
    ssSetInputPortMatrixDimensions(  S, INPORT, DYNAMICALLY_SIZED, DYNAMICALLY_SIZED);
    ssSetInputPortFrameData(         S, INPORT, FRAME_YES);
    ssSetInputPortComplexSignal(     S, INPORT, (fcn == DFT_FCN) ? COMPLEX_NO : 
                                                COMPLEX_YES);
    ssSetInputPortOptimOpts(         S, INPORT, SS_REUSABLE_AND_LOCAL);

    ssSetInputPortDirectFeedThrough( S, INPORT, 1);
    ssSetInputPortOverWritable(      S, INPORT, 1);
    ssSetInputPortRequiredContiguous(S, INPORT, 1); 

    /* Output: */
    if (!ssSetNumOutputPorts(S,	NUM_OUTPORTS)) return;
    ssSetOutputPortMatrixDimensions(S, OUTPORT, DYNAMICALLY_SIZED, DYNAMICALLY_SIZED);
    ssSetOutputPortFrameData(       S, OUTPORT, FRAME_YES); 
    ssSetOutputPortComplexSignal(   S, OUTPORT, (fcn == DFT_FCN) ? COMPLEX_YES : 
                                                COMPLEX_NO);
    ssSetOutputPortOptimOpts(       S, OUTPORT, SS_REUSABLE_AND_LOCAL);

    ssSetNumSampleTimes(S, 1);
    ssSetOptions(S,
                 SS_OPTION_WORKS_WITH_CODE_REUSE |
                 SS_OPTION_EXCEPTION_FREE_CODE);
}

static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, 0.0);
    ssSetModelReferenceSampleTimeDefaultInheritance(S);
}

static void mdlOutputs(SimStruct *S, int_T tid)
{
    int_T   fcn     = (int_T) (mxGetPr(FCN_ARG(S))[0]);
    int_T   *dims   = ssGetInputPortDimensions(S, 0);
    int_T   frmSize = dims[0];
    int_T   nChans  = dims[1];
    int_T   dftSize = (fcn == DFT_FCN) ? (int_T) mxGetPr(DFT_ARG(S))[0] : 
                      frmSize;
    
    if (fcn == DFT_FCN) {
        real_T  *x = (real_T *)ssGetInputPortSignal(S,INPORT);
        creal_T *y = (creal_T *)ssGetOutputPortSignal(S,OUTPORT);

        sfun_frm_dft_wrapper(x,y,frmSize,nChans,dftSize);

    } else {

        creal_T *x = (creal_T *)ssGetInputPortSignal(S,INPORT);
        real_T  *y = (real_T *)ssGetOutputPortSignal(S,OUTPORT);

        sfun_frm_idft_wrapper(x,y,frmSize,nChans,dftSize);
    }
}
    
#define MDL_SET_INPUT_PORT_DIMENSION_INFO
#if defined(MDL_SET_INPUT_PORT_DIMENSION_INFO) && defined(MATLAB_MEX_FILE)
static void mdlSetInputPortDimensionInfo(SimStruct        *S, 
                                         int_T            port, 
                                         const DimsInfo_T *dimsInfo)
{
    int_T fcn = (int_T) (mxGetPr(FCN_ARG(S))[0]);
    if (!ssSetInputPortDimensionInfo(S, port, dimsInfo)) return;
    
    if (fcn == DFT_FCN) {
        if (dimsInfo->dims[1] != DYNAMICALLY_SIZED) {
            DECL_AND_INIT_DIMSINFO(oDims);
            int_T new_dims[2];
            int_T dftSize = (int_T) mxGetPr(DFT_ARG(S))[0];
            
            new_dims[1]   = dimsInfo->dims[1];
            new_dims[0]   = dftSize;
            oDims.width   = new_dims[0] * new_dims[1];
            oDims.numDims = 2;
            oDims.dims    = new_dims;
            if (!ssSetOutputPortDimensionInfo(S, OUTPORT, &oDims)) return;
        }
    } else {
        if (!ssSetOutputPortDimensionInfo(S, OUTPORT, dimsInfo)) return;   
    }
}
#endif

#define MDL_SET_OUTPUT_PORT_DIMENSION_INFO
#if defined(MDL_SET_OUTPUT_PORT_DIMENSION_INFO) && defined(MATLAB_MEX_FILE)
static void mdlSetOutputPortDimensionInfo(SimStruct        *S, 
                                          int_T            port, 
                                          const DimsInfo_T *dimsInfo)
{
    int_T fcn = (int_T) (mxGetPr(FCN_ARG(S))[0]);
    if (fcn == DFT_FCN) {
        int_T dftSize = (int_T) mxGetPr(DFT_ARG(S))[0];
        if (dimsInfo->dims[0] != DYNAMICALLY_SIZED &&
            dimsInfo->dims[0] != dftSize) {
            SET_ERROR(S, "Output dimensions must match DFT Size.");
        }
        if (!ssSetOutputPortDimensionInfo(S, port, dimsInfo)) return;
        
        if (dimsInfo->dims[1] != DYNAMICALLY_SIZED) {
            DECL_AND_INIT_DIMSINFO(iDims);
            int_T *origDims = ssGetInputPortDimensions(S, INPORT);
            int_T new_dims[2];
            new_dims[0]   = origDims[0];
            new_dims[1]   = dimsInfo->dims[1];
            if ((new_dims[0] != DYNAMICALLY_SIZED &&
                 new_dims[1] != DYNAMICALLY_SIZED) ||
                (new_dims[1] == 1)) {
                if ((new_dims[0] != DYNAMICALLY_SIZED &&
                     new_dims[1] != DYNAMICALLY_SIZED)) {
                    iDims.width = new_dims[0] * new_dims[1];
                } else {
                    iDims.width = DYNAMICALLY_SIZED;
                }
                iDims.numDims = 2;
                iDims.dims    = new_dims;
                if (!ssSetInputPortDimensionInfo(S, INPORT, &iDims)) return;
            }
        }
    } else {
        if (!ssSetOutputPortDimensionInfo(S, port, dimsInfo)) return;
        if (!ssSetInputPortDimensionInfo(S, INPORT, dimsInfo)) return;
    }
} 
#endif

#if defined(MATLAB_MEX_FILE) || defined(NRT)
#define MDL_RTW
static void mdlRTW(SimStruct *S)
{
    int_T fcn = (int_T) (mxGetPr(FCN_ARG(S))[0]);
    if (fcn == DFT_FCN) {
        int_T dftSize = (int_T) mxGetPr(DFT_ARG(S))[0];
        if (!ssWriteRTWParamSettings(S, 2,
                                     SSWRITE_VALUE_STR,
                                     "Inverse", "no",
                                     SSWRITE_VALUE_DTYPE_NUM,
                                     "DFTSize",&dftSize,
                                     DTINFO(SS_INT32, COMPLEX_NO))) {
            return; /* An error occurred which will be reported by SL */
        }
    } else {
        if (!ssWriteRTWParamSettings(S, 1,
                                     SSWRITE_VALUE_STR,
                                     "Inverse", "yes")) {
            return; /* An error occurred which will be reported by SL */
        }
    }
}
#endif

static void mdlTerminate(SimStruct *S)
{
}

#ifdef	MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-File interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif

/* [EOF] sfun_frmdft.c */
