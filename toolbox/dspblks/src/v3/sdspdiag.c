/*
 * SDSPDIAG DSP Blockset S-Function for creating a diagonal matrix
 * from diagonal elements. Also, extract diagonal elements from a
 * full matrix. Full to diagonal, diagonal to full.
 *
 *  Copyright 1995-2002 The MathWorks, Inc.
 *  $Revision: 1.13 $  $Date: 2002/04/14 20:42:35 $
 */
#define S_FUNCTION_NAME sdspdiag
#define S_FUNCTION_LEVEL 2

#include "dsp_sim.h"

enum {INPORT=0}; 
enum {OUTPORT=0}; 
enum {NCOLS_ARGC=0, FCN_TYPE_ARGC, NUM_ARGS};

#define NCOLS_ARG (ssGetSFcnParam(S,NCOLS_ARGC))
#define FCN_TYPE_ARG (ssGetSFcnParam(S,FCN_TYPE_ARGC))

typedef enum {
    fcnDiag2Full = 1,
    fcnFull2Diag
} FcnType;


#ifdef MATLAB_MEX_FILE
#define MDL_CHECK_PARAMETERS
static void mdlCheckParameters(SimStruct *S) 
{
    /* Number of columns: */
    if (OK_TO_CHECK_VAR(S, NCOLS_ARG)) {
        real_T d;

        if (!IS_FLINT(NCOLS_ARG)) {
            THROW_ERROR(S, "Number of columns must be a real scalar");
        }

        d = mxGetPr(NCOLS_ARG)[0];
        if ((d<1) && (d != -1)) {
            THROW_ERROR(S, "Number of columns must be an integer value > 0");
        }
    }

    /* Function type: */
    if (!IS_FLINT_IN_RANGE(FCN_TYPE_ARG,1,2)) {
        THROW_ERROR(S, "Function type must be 1 (upper) or 2 (lower).");
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

    /* Inputs: */
    if (!ssSetNumInputPorts(S, 1)) return;
    ssSetInputPortWidth(            S, INPORT, DYNAMICALLY_SIZED);
    ssSetInputPortDirectFeedThrough(S, INPORT, 1);
    ssSetInputPortComplexSignal(    S, INPORT, COMPLEX_INHERITED);
    ssSetInputPortReusable(         S, INPORT, 1);
    ssSetInputPortOverWritable(     S, INPORT, 1);  /* although it will never happen due to size differences */

    /* Outputs: */
    if (!ssSetNumOutputPorts(S,1)) return;
    ssSetOutputPortWidth(        S, OUTPORT, DYNAMICALLY_SIZED);
    ssSetOutputPortComplexSignal(S, OUTPORT, COMPLEX_INHERITED);
    ssSetOutputPortReusable(     S, OUTPORT, 1);

    ssSetNumSampleTimes(   S, 1);
    ssSetOptions(          S, SS_OPTION_EXCEPTION_FREE_CODE |
                           SS_OPTION_USE_TLC_WITH_ACCELERATOR);
}


static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, 0.0);
}


static void mdlOutputs(SimStruct *S, int_T tid)
{
    const int_T      Nin   = ssGetInputPortWidth(S,INPORT);
    const int_T      Nout  = ssGetOutputPortWidth(S,OUTPORT);
    const FcnType    ftype = (FcnType)((int_T)mxGetPr(FCN_TYPE_ARG)[0]);
    const boolean_T  c0    = (ssGetInputPortComplexSignal(S,INPORT) == COMPLEX_YES);
    
    switch(ftype) {
        case fcnDiag2Full:
        {
            if (!c0) {
                /* Real: */
                InputRealPtrsType  uptr = ssGetInputPortRealSignalPtrs(S,INPORT);
                real_T            *y    = ssGetOutputPortRealSignal(S,OUTPORT);
                int_T              nc = 0;

                while (nc++ < Nin) {
                    int_T nr = 0;
                    while (nr++ < Nin) {
                        *y++ = (nr == nc) ? **uptr++ : 0.0;
                    }
                }

            } else {
                /* Complex: */
                InputPtrsType  uptr = ssGetInputPortSignalPtrs(S,INPORT);
                creal_T       *y    = (creal_T *)ssGetOutputPortSignal(S,OUTPORT);
                creal_T        z    = {0.0, 0.0};
                int_T          nc   = 0;

                while (nc++ < Nin) {
                    int_T nr = 0;
                    while (nr++ < Nin) {
                        *y++ = (nr == nc) ? *((creal_T *)(*uptr++)) : z;
                    }
                }
            }
        }
        break;

        case fcnFull2Diag:
        {
            const int_T ncols = (int_T)mxGetPr(NCOLS_ARG)[0];
            const int_T nrows = (ncols == -1) ? Nout : Nin / ncols;
            const int_T Nmin  = (ncols == -1) ? nrows : MIN(ncols,nrows);

            /* Ncols may not represent the actual number of columns
             * since it may be -1 (for square matrices)
             */

            if (!c0) {
                /* Real: */
                InputRealPtrsType  uptr = ssGetInputPortRealSignalPtrs(S,INPORT);
                real_T            *y    = ssGetOutputPortRealSignal(S,OUTPORT);
                int_T              i    = Nmin;
                
                while (i-- > 0) {
                    *y++ = **uptr;
                    uptr += (nrows+1);
                }

            } else {
                /* Complex: */
                InputPtrsType  uptr = ssGetInputPortSignalPtrs(S,INPORT);
                creal_T       *y    = (creal_T *)ssGetOutputPortSignal(S,OUTPORT);
                int_T          i    = Nmin;
 
                while (i-- > 0) {
                    *y++ = *((creal_T *)(*uptr));
                    uptr += (nrows+1);
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
    const FcnType ftype = (FcnType)((int_T)mxGetPr(FCN_TYPE_ARG)[0]);

    ssSetInputPortWidth(S,port,inputPortWidth);

    if (ftype == fcnFull2Diag) {
        int_T ncols = (int_T)mxGetPr(NCOLS_ARG)[0];
        
        /* If number of columns == -1, then the input matrix
         * is a square
         */
        if (ncols == -1) {
            ncols = (int_T)sqrt((real_T)inputPortWidth);
        }

        /* Check that the input width and number of columns are valid */
        if (inputPortWidth % ncols != 0) {
            THROW_ERROR(S,"Input width is not consistent with number of columns");
        }
    
        if (ssGetOutputPortWidth(S,OUTPORT) == DYNAMICALLY_SIZED) {
            /* The output width is the minimum of the number 
             * of rows and columns 
             */
            ssSetOutputPortWidth(S, OUTPORT, MIN(ncols, inputPortWidth/ncols) );
        }
    } else {
        /* Diag2Full:
         * Output is always a square matrix with 
         *     ncols = nrows = number of elements in input vector 
         */
        ssSetOutputPortWidth(S, OUTPORT, inputPortWidth*inputPortWidth);
    }
}

# define MDL_SET_OUTPUT_PORT_WIDTH
static void mdlSetOutputPortWidth(SimStruct *S, int_T port,
                                     int_T outputPortWidth)
{
    const FcnType ftype = (FcnType)((int_T)mxGetPr(FCN_TYPE_ARG)[0]);

    ssSetOutputPortWidth(S, OUTPORT, outputPortWidth);
    
    if (ftype == fcnFull2Diag) {
        const int_T ncols = (int_T)mxGetPr(NCOLS_ARG)[0];

        if (ncols == -1) {
            /* Input matrix is a square */
            ssSetInputPortWidth(S, INPORT, outputPortWidth*outputPortWidth);
        
        } else {

            if (outputPortWidth != ncols) {
                /* Then we know that the nrows = outputPortWidth 
                 * because outputPortWidth = MIN(ncols,nrows)
                 */
                /* Check that the nrows < ncols */
                if (outputPortWidth >= ncols) {
                    THROW_ERROR(S,"Invalid output port width propagation call");
                }
                ssSetInputPortWidth(S, INPORT, ncols*outputPortWidth);
            }
            /* if (outputPortWdith == ncols), there's not enough
             * information to set the input port width (since
             * nrows could be >= outputportwidth)
             */
        }

    } else {
        /* fcnDiag2Full: 
         * Output is always a square matrix with 
         *     ncols = nrows = square root of number of elements in output vector
         */
        /* Check that the output width is a squared value: */
        const int_T nrows = (int_T)sqrt((real_T)outputPortWidth);
        if ( (outputPortWidth % nrows) != 0) {
            THROW_ERROR(S,"Invalid output port width for diagonal to full mode");
        }
        ssSetInputPortWidth(S, INPORT, nrows);
    }
}
#endif

#include "dsp_cplxhs11.c"

#ifdef  MATLAB_MEX_FILE
#include "simulink.c"
#else
#include "cg_sfun.h"
#endif

/* [EOF] sdspdiag.c */
