/*
 * SDSPTRI DSP Blockset S-Function for extract lower/upper triangular part.
 *  Full to lower/upper triangular.
 *
 *  Copyright 1995-2002 The MathWorks, Inc.
 *  $Revision: 1.19 $  $Date: 2002/04/14 20:42:32 $
 */

#define S_FUNCTION_NAME sdsptri
#define S_FUNCTION_LEVEL 2

#include "dsp_sim.h"

enum {INPORT=0}; 
enum {OUTPORT=0}; 
enum {NCOLS_ARGC=0, FCN_TYPE_ARGC, NUM_ARGS};
#define NCOLS_ARG (ssGetSFcnParam(S,NCOLS_ARGC))
#define FCN_TYPE_ARG (ssGetSFcnParam(S,FCN_TYPE_ARGC))

typedef enum {
    fcnUpper = 1,
    fcnLower
} FcnType;

#ifdef MATLAB_MEX_FILE
#define MDL_CHECK_PARAMETERS
static void mdlCheckParameters(SimStruct *S) 
{
    /* Number of columns: */
    if (OK_TO_CHECK_VAR(S, NCOLS_ARG)) {
        if (!IS_FLINT_GE(NCOLS_ARG, 1)) {
            THROW_ERROR(S, "Number of columns must be a real, scalar, integer value > 0.");
        }
    }

    /* Function type: */
    if (!IS_FLINT_IN_RANGE(FCN_TYPE_ARG, 1, 2)) {
        THROW_ERROR(S, "Function type must be a scalar 1 (upper) or 2 (lower).");
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
    
    ssSetSFcnParamNotTunable(S,NCOLS_ARGC); 

    /* Not tunable in RTW generated code. */
    if ((ssGetSimMode(S) == SS_SIMMODE_EXTERNAL) || 
        (ssGetSimMode(S) == SS_SIMMODE_RTWGEN)) {    
        
        ssSetSFcnParamNotTunable(S, FCN_TYPE_ARGC);
    }


    /* Inputs: */
    if (!ssSetNumInputPorts(S, 1)) return;

    ssSetInputPortWidth(            S, INPORT, DYNAMICALLY_SIZED);
    ssSetInputPortComplexSignal(    S, INPORT, COMPLEX_INHERITED);
    ssSetInputPortDirectFeedThrough(S, INPORT, 1);
    ssSetInputPortReusable(         S, INPORT, 1);
    ssSetInputPortOverWritable(     S, INPORT, 1);

    /* Outputs: */
    if (!ssSetNumOutputPorts(S,1)) return;

    ssSetOutputPortWidth(        S, OUTPORT, DYNAMICALLY_SIZED);
    ssSetOutputPortComplexSignal(S, OUTPORT, COMPLEX_INHERITED);
    ssSetOutputPortReusable(     S, OUTPORT, 1);

    ssSetNumSampleTimes(S, 1);
    ssSetOptions(       S, SS_OPTION_EXCEPTION_FREE_CODE | 
                        SS_OPTION_USE_TLC_WITH_ACCELERATOR);
}


static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, 0.0);
}


static void mdlOutputs(SimStruct *S, int_T tid)
{
    const FcnType    ftype     = (FcnType)((int_T)mxGetPr(FCN_TYPE_ARG)[0]);
    const int_T      N         = ssGetInputPortWidth(S,INPORT);
    const int_T      ncols     = (int_T)mxGetPr(NCOLS_ARG)[0];
    const int_T      nrows     = N/ncols;
    const boolean_T  c0        = (ssGetInputPortComplexSignal(S,INPORT) == COMPLEX_YES);
    const boolean_T  need_copy = (boolean_T)(ssGetInputPortBufferDstPort(S, INPORT) != OUTPORT);

    switch (ftype) {
        case fcnUpper:
        {
            /* Zero out the lower triangle: */
            if (!c0) {
                /* Real: */
                real_T *y = ssGetOutputPortRealSignal(S,OUTPORT);

                if (need_copy) {
                    /* Need to copy input data to output space: */
                    InputRealPtrsType uptr = ssGetInputPortRealSignalPtrs(S,INPORT);
                    int_T nc;
                    for (nc=0; nc++ < ncols; ) {
                        int_T nr;
                        for (nr=0; nr++ < nrows; ) {
                            *y++ = (nr > nc) ? 0.0 : **uptr;
                            uptr++;
                        }
                    }
                } else {
                    /* Input data is already in output space: */
                    int_T c;
                    int_T mincols = MIN(ncols,nrows);
                    for(c=0; c < mincols; c++) {
                        int_T r;
                        y += c+1;
                        for (r=c+1; r++ < nrows; ) {
                            *y++ = 0.0;
                        }
                    }
                }

            } else {
                /* Complex: */
                creal_T *y  = (creal_T *)ssGetOutputPortSignal(S,OUTPORT);

                if (need_copy) {
                    /* Need to copy input data to output space: */
                    InputPtrsType uptr = ssGetInputPortSignalPtrs(S,INPORT);
                    int_T nc;
                    for (nc=0; nc++ < ncols; ) {
                        int_T nr;
                        for (nr=0; nr++ < nrows; ) {
                            if (nr > nc) {
                                y->re     = (real_T)0.0;
                                (y++)->im = (real_T)0.0;
                            } else {
                                *y++ = *((creal_T *)(*uptr));
                            }
                            uptr++;
                        }
                    }
                } else {
                    /* Input data is already in output space: */
                    int_T c;
                    int_T mincols = MIN(ncols,nrows);
                    for(c=0; c < mincols; c++) {
                        int_T r;
                        y += c+1;
                        for (r=c+1; r++ < nrows; ) {
                            y->re     = (real_T)0.0;
                            (y++)->im = (real_T)0.0;
                        }
                    }
                }
            }
        }
        break;

        case fcnLower:
        {
            if (!c0) {
                /* Real: */
                real_T *y = ssGetOutputPortRealSignal(S,OUTPORT);

                if (need_copy) {
                    /* Need to copy input data to output space: */
                    InputRealPtrsType uptr = ssGetInputPortRealSignalPtrs(S,INPORT);
                    int_T nc;
                    for(nc=0; nc++ < ncols; ) {
                        int_T nr;
                        for (nr=0; nr++ < nrows; ) {
                            *y++ = (nr<nc) ? 0.0 : **uptr;
                            uptr++;
                        }
                    }
                } else {
                    /* Input data is already in output space: */
                    int_T c;
                    y += nrows;
                    for(c=1; c < ncols; c++) {
                        int_T r;
                        int_T cc = MIN(c, nrows);
                        for (r=0; r++ < cc; ) {
                            *y++ = 0.0;
                        }
                        y += (nrows-cc);
                    }
                }

            } else {
                /* Complex: */
                creal_T      *y = (creal_T *)ssGetOutputPortSignal(S,OUTPORT);

                if (need_copy) {
                    /* Need to copy input data to output space: */
                    InputPtrsType uptr = ssGetInputPortSignalPtrs(S,INPORT);
                    int_T         nc;
                    for (nc=0; nc++ < ncols; ) {
                        int_T nr;
                        for (nr=0; nr++ < nrows; ) {
                            if (nr < nc) {
                                y->re     = (real_T)0.0;
                                (y++->im) = (real_T)0.0;
                            } else {
                                *y++ = *((creal_T *)(*uptr));
                            }
                            uptr++;
                        }
                    }
                } else {
                    /* Input data is already in output space: */
                    int_T c;
                    y += nrows;
                    for(c=1; c < ncols; c++) {
                        int_T r;
                        int_T cc = MIN(c, nrows);
                        for (r=0; r++ < cc; ) {
                            y->re     = (real_T)0.0;
                            (y++)->im = (real_T)0.0;
                        }
                        y += (nrows-cc);
                    }
                }
            }
        }
        break;
    }
}


static void mdlTerminate(SimStruct *S)
{
}


#if defined(MATLAB_MEX_FILE)
# define MDL_SET_INPUT_PORT_WIDTH
static void mdlSetInputPortWidth(SimStruct *S, int_T port,
                                    int_T inputPortWidth)
{
    const int_T ncols = (int_T)mxGetPr(NCOLS_ARG)[0];

    ssSetInputPortWidth(S,port,inputPortWidth);

    if (inputPortWidth % ncols != 0) {
        THROW_ERROR(S,"Input width is not consistent with number of columns.");
    }
    ssSetOutputPortWidth(S, OUTPORT, inputPortWidth);
}


# define MDL_SET_OUTPUT_PORT_WIDTH
static void mdlSetOutputPortWidth(SimStruct *S, int_T port,
                                     int_T outputPortWidth)
{
    const int_T ncols = (int_T)mxGetPr(NCOLS_ARG)[0];

    ssSetOutputPortWidth(S, port, outputPortWidth);

    if (outputPortWidth % ncols != 0) {
        THROW_ERROR(S,"Output width is not consistent with number of columns.");
    }
    ssSetInputPortWidth(S, INPORT, outputPortWidth);
}
#endif


#include "dsp_cplxhs11.c"


#ifdef  MATLAB_MEX_FILE
#include "simulink.c"
#else
#include "cg_sfun.h"
#endif

/* [EOF] sdsptri.c */
