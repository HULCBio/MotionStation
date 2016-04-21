/*
 * SDSPMSQR DSP Blockset matrix square block
 *            Computes Y = U'*U
 *
 * NOTE: This is more efficient than UU', due to column-major ordering.
 *
 *   
 *  Copyright 1995-2002 The MathWorks, Inc.
 *  $Revision: 1.11 $  $Date: 2002/04/14 20:42:41 $
 */
#define S_FUNCTION_NAME  sdspmsqr
#define S_FUNCTION_LEVEL 2

#include "dsp_sim.h"

enum {ACOLS_IDX=0, NUM_ARGS};
#define ACOLS (ssGetSFcnParam(S, ACOLS_IDX))

enum {INPORT};
enum {OUTPORT};

#ifdef MATLAB_MEX_FILE
#define MDL_CHECK_PARAMETERS
static void mdlCheckParameters(SimStruct *S) 
{
    if (!IS_FLINT_GE(ACOLS, 1)) {
        THROW_ERROR(S, "Columns in A must be an integer-valued scalar > 0.");
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
    
    /* Inputs: */
    if (!ssSetNumInputPorts(S, 1)) return;
    
    ssSetInputPortWidth(            S, INPORT, DYNAMICALLY_SIZED);
    ssSetInputPortDirectFeedThrough(S, INPORT, 1);
    ssSetInputPortComplexSignal(    S, INPORT, COMPLEX_INHERITED);
    ssSetInputPortReusable(         S, INPORT, 1);
    ssSetInputPortOverWritable(     S, INPORT, 0); /* Must revisit input elements */
    
    /* Outputs: */
    if (!ssSetNumOutputPorts(S,1)) return;
    
    ssSetOutputPortWidth(        S, OUTPORT, DYNAMICALLY_SIZED);
    ssSetOutputPortComplexSignal(S, OUTPORT, COMPLEX_INHERITED);
    ssSetOutputPortReusable(     S, OUTPORT, 1);
	
    /*
     * Parameter ACOLS_IDX is not tunable
     * because it affects output width
     */
    ssSetSFcnParamNotTunable(S, ACOLS_IDX);
    
    ssSetNumSampleTimes(S, 1);
    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE);	
    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE |
                 SS_OPTION_USE_TLC_WITH_ACCELERATOR);
}


static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, 0.0);
}


static void mdlOutputs(SimStruct *S, int_T tid)
{
    /* Inputs are u, Outputs are y */
    const int_T     Awidth = ssGetInputPortWidth(S, INPORT);
    const int_T     Ac     = (int_T)(mxGetPr(ACOLS)[0]);
    const int_T     Ar     = Awidth/Ac;
    const boolean_T cplx   = (boolean_T)(ssGetInputPortComplexSignal(S,INPORT) == COMPLEX_YES);
            


    if (Ac==1) {
        /* A is a column vector
         * u'u => inner product
         *     => sum of squares
         *
         * Output is purely real
         */

        if (!cplx) {
            /* Real sum-of-squares */

            real_T acc = 0.0;
            {
                int_T i;
                InputRealPtrsType A = ssGetInputPortRealSignalPtrs(S, INPORT);
                for (i=0; i<Ar; i++) {
                    real_T t = **A++;
                    acc += t*t;
                }
            }
            {
                real_T *y = ssGetOutputPortRealSignal(S, OUTPORT);
                *y = acc;
            }

        } else {
            /* Complex sum-of-squares */

            real_T acc = 0.0;
            {
                InputPtrsType A = ssGetInputPortSignalPtrs(S, INPORT);
                int_T i;
                for (i=0; i<Ar; i++) {
                    creal_T t = *((creal_T *)(*A++));
                    acc += t.re * t.re;
                    acc += t.im * t.im;
                }
            }
            {
                real_T *y = ssGetOutputPortRealSignal(S, OUTPORT);
                *y = acc;
            }
        }

    } else if (Ar==1) {
        /* A is a row vector
         * u'u => outer product
         *     => symmetric scaling
         * It's cheaper to compute the whole matrix than to compute half and
         * perform out-of-place memory accessess to fill in symmetric half.
         */
        if (!cplx) {
            /* Real outer product */
#if 0
            /* Compute symmetric half */
            int_T i;
            InputRealPtrsType A = ssGetInputPortRealSignalPtrs(S, INPORT);
            real_T *yy = ssGetOutputPortRealSignal(S, OUTPORT);
            real_T *y = yy;

            for (i=0; i<Ac; i++) {
                InputRealPtrsType A1 = A++;
                y += i;
                {
                    const real_T scale = **A1;
                    InputRealPtrsType A2 = A1;
                    int_T j;
                    for (j=i; j<Ac; j++) {
                        *y = scale * **A2++;;
                        yy[i+j*Ac] = *y++;
                    }
                }
            }
#else
            /* Compute whole matrix */
            InputRealPtrsType A = ssGetInputPortRealSignalPtrs(S, INPORT);
            real_T *y = ssGetOutputPortRealSignal(S, OUTPORT);
            int_T i;
            for (i=0; i<Ac; i++) {
                const real_T scale = *A[i];
                int_T j;
                for (j=0; j<Ac; j++) {
                    *y++ = scale * *A[j];
                }
            }
#endif
        } else {
            /* Complex outer product */

            InputPtrsType A = ssGetInputPortSignalPtrs(S, INPORT);
            creal_T *y = (creal_T *)ssGetOutputPortSignal(S, OUTPORT);
            int_T i;
            for (i=0; i<Ac; i++) {
                const creal_T scale = *((creal_T *)(A[i]));
                int_T j;
                for (j=0; j<Ac; j++) {
                    creal_T A2_val = *((creal_T *)(A[j]));
                    y->re   = CMULT_XCONJ_RE(scale, A2_val);
                    y++->im =-CMULT_XCONJ_IM(scale, A2_val);
                }
            }
        }

    } else {

        /* A is a matrix, y = A' * A */

        if (!cplx) {
            /* Real A */

            real_T            *y = ssGetOutputPortRealSignal(S, OUTPORT);
            InputRealPtrsType  A = ssGetInputPortRealSignalPtrs(S, INPORT);
            InputRealPtrsType  B = A;
            int_T              k = Ac;
            
            /* Compute real matrix multiply.
             * See sdspmmult.c for details.
             *
             * Mapping of the ii,jj,kk variables of the general
             * matrix-mult to the actual matrix sizes used here:
             *  iixjj * jjxkk => AcxAr * ArxAc
             *  ii=Ac, jj=Ar, kk=Ac
             */
            while(k-- > 0) {
                InputRealPtrsType A1 = A;
                int_T i = Ac;
                while(i-- > 0) {
                    InputRealPtrsType A2 = A1;
                    InputRealPtrsType B2 = B;
                    real_T  acc = 0.0;
                    int_T   j = Ar;
                    while(j-- > 0) acc += (**A2++) * (**B2++);
                    *y++ = acc;
                    A1 += Ar;
                }
                B += Ar;
            }
            
        } else {
            /* Input is Complex */

            creal_T       *y = (creal_T *)ssGetOutputPortSignal(S, OUTPORT);
            InputPtrsType  A = ssGetInputPortSignalPtrs(S, INPORT);
            InputPtrsType  B = A;
            int_T          k = Ac;
            
            /* Compute real matrix multiply.
            *  Algorithm initializes output memory to zero
            *    before adding to it.
            */
            while(k-- > 0) {
                InputPtrsType A1 = A;
                int_T i = Ac;
                while(i-- > 0) {
                    InputPtrsType A2 = A1;
                    InputPtrsType B2 = B;
                    creal_T acc = {0.0, 0.0};
                    int_T   j = Ar;
                    while(j-- > 0) {
                        const creal_T  A2_val = *((creal_T *)(*A2++));
                        const creal_T  B2_val = *((creal_T *)(*B2++));
                        acc.re += CMULT_XCONJ_RE(A2_val, B2_val);
                        acc.im += CMULT_XCONJ_IM(A2_val, B2_val);
                    }
                    *y++ = acc;
                    A1 += Ar;
                }
                B += Ar;
            }
        }
    } /* scalar vs. non-scalar A */
}


static void mdlTerminate(SimStruct *S)
{
}


#if defined(MATLAB_MEX_FILE) || defined(NRT)
#define MDL_RTW
static void mdlRTW(SimStruct *S)
{
    int16_T Ac = (int16_T)mxGetPr(ACOLS)[0];

    if (!ssWriteRTWParamSettings(S, 1,
             SSWRITE_VALUE_DTYPE_NUM, "ACOLS",
             &Ac,
             DTINFO(SS_INT16,0)
             )) {
        return;
    }
}
#endif


#if defined(MATLAB_MEX_FILE)
#define MDL_SET_INPUT_PORT_WIDTH
static void mdlSetInputPortWidth(SimStruct *S, int_T port,
                                 int_T inputPortWidth)
{
    const int_T Ac = (int_T)(mxGetPr(ACOLS)[0]);
    const int_T Ar = inputPortWidth / Ac;
    const int_T WidthY = ssGetOutputPortWidth(S, OUTPORT);
    
    ssSetInputPortWidth(S, port, inputPortWidth);

    if(inputPortWidth != (Ar*Ac)) {
        THROW_ERROR(S, "Input port width does not match sizes specified for the block.");
    }
    if(WidthY == DYNAMICALLY_SIZED) {
        ssSetOutputPortWidth(S,OUTPORT, Ac*Ac);
    }
}

# define MDL_SET_OUTPUT_PORT_WIDTH
static void mdlSetOutputPortWidth(SimStruct *S, int_T port,
                                  int_T outputPortWidth)
{
    ssSetOutputPortWidth(S,port, outputPortWidth);

    if (outputPortWidth == 1) {
        const int_T WidthA = ssGetInputPortWidth(S, INPORT);
        if (WidthA == DYNAMICALLY_SIZED) {
            ssSetInputPortWidth(S, 0, 1);
        } else {
            const int_T Ac = (int_T)(mxGetPr(ACOLS)[0]);
            const int_T Ar = WidthA / Ac;
            if ((Ar != 1) || ((Ar*Ac) != 1)) {
                THROW_ERROR(S, "Input port width does not match output port size.");
            }
        }
    }
}
#endif


#if defined(MATLAB_MEX_FILE)
#define MDL_SET_INPUT_PORT_COMPLEX_SIGNAL
static void mdlSetInputPortComplexSignal(SimStruct *S,
					 int_T port,
					 CSignal_T portComplex)
{
    const int_T Ac = (int_T)(mxGetPr(ACOLS)[0]);

    ssSetInputPortComplexSignal(S, port, portComplex);

    if (Ac==1) { /* inner product -> output is purely real */
        if (ssGetOutputPortComplexSignal(S, OUTPORT) == COMPLEX_INHERITED) {
            ssSetOutputPortComplexSignal(S, OUTPORT, COMPLEX_NO);
        }
    } else {
        ssSetOutputPortComplexSignal(S, OUTPORT, portComplex);
    }
}

#define MDL_SET_OUTPUT_PORT_COMPLEX_SIGNAL
static void mdlSetOutputPortComplexSignal(SimStruct *S,
					  int_T port,
					  CSignal_T portComplex)
{
    const int_T Ac = (int_T)(mxGetPr(ACOLS)[0]);

    ssSetOutputPortComplexSignal(S, port, portComplex);

    if (Ac==1) { /* inner product -> output is purely real */
        if (portComplex) {
            THROW_ERROR(S, "Output port is complex, but inner product produces a real result.");
        }
        /* Cannot set input port complexity - could be real OR complex */
    } else {
        ssSetInputPortComplexSignal(S, port, portComplex);
    }
}
#endif


#ifdef	MATLAB_MEX_FILE   
#include "simulink.c"      
#else
#include "cg_sfun.h"       
#endif

/* [EOF] sdspmsqr.c */
