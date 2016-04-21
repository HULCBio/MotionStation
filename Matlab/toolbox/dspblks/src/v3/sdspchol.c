/*
 * File: sdspchol.c
 *
 * Abstract:
 *      S-function for Cholesky decomposition
 *
 * Copyright 1995-2002 The MathWorks, Inc.
 * $Revision: 1.23 $
 * $Date: 2002/04/14 20:43:49 $
 */

#define S_FUNCTION_NAME  sdspchol
#define S_FUNCTION_LEVEL 2

#include "dsp_sim.h"

enum {INPORT_A=0, NUM_INPORTS};
enum {OUTPORT_L=0, NUM_OUTPORTS};

enum {ERR_ARGC=0, NUM_ARGS};
#define ERR_ARG (ssGetSFcnParam(S,ERR_ARGC))

typedef enum {ERR_IGNORE=1, ERR_WARNING, ERR_ERROR} ErrMode;

#define MDL_CHECK_PARAMETERS
static void mdlCheckParameters(SimStruct *S) {
#ifdef MATLAB_MEX_FILE
    
    if (!IS_FLINT_IN_RANGE(ERR_ARG,1,3)) {
        THROW_ERROR(S, "Error mode must be 1=IGNORE, 2=WARNING, or 3=ERROR");
    }
#endif
}



/*
 *  Decompose A into L*L'
 *  Put L on lower triangle, and L' on upper.
 */
static boolean_T chol_cplx(
    creal_T     *A,
    const int_T  n
)
{
    int_T j;
    creal_T *A_jn = A;

    for (j=0; j<n; j++) {
	real_T   s = 0.0;
	creal_T *A_kn = A;
	int_T    k;

	for (k=0; k<j; k++) {
	    creal_T t = {0.0, 0.0};
	    {
                /* Inner product */
		creal_T *x1 = A_kn;
		creal_T *x2 = A_jn;
		int_T   kk = k;
		while(kk-- > 0) {
		    t.re += CMULT_XCONJ_RE(*x1, *x2);
		    t.im += CMULT_XCONJ_IM(*x1, *x2);
		    x1++; x2++;
		}
	    }
	    t.re = A_jn[k].re - t.re;
	    t.im = A_jn[k].im - t.im;
	    CDIV(t, A_kn[k], t);
	    A_jn[k] = t;

	    /* Copy transpose of upper triangle (Hermitian) to lower triangle: */
	    A_kn[j].re =  t.re;
	    A_kn[j].im = -t.im;

	    s += CMAGSQ(t);
	    A_kn += n;
	}
	s = A_jn[j].re - s;

	/* Establish a tolerance on allowable non-zero imag component: */
	if ( (s <= 0.0) ||
	     (fabs(A_jn[j].im) > fabs(A_jn[j].re) * 1e-12) ) {
	    return((boolean_T)1);  /* Return with error flag set */
	}

	A_jn[j].re = sqrt(s);
        A_jn += n;
    }
    return((boolean_T)0);
}


static boolean_T chol_real(
    real_T     *A,
    const int_T n
)
{
    int_T   j;
    real_T *A_jn = A;

    for (j=0; j<n; j++) {
	real_T s = 0.0;
	int_T   k;
        real_T *A_kn = A;

        for (k=0; k<j; k++) {
	    real_T t = 0.0;
	    {
                /* Inner product */
		real_T *x1 = A_kn;
		real_T *x2 = A_jn;
		int_T   kk = k;
		while(kk-- > 0) {
		    t += *x1++ * *x2++;
		}
	    }
            t = (A_jn[k] - t) / A_kn[k];
	    A_jn[k] = t;
	    A_kn[j] = t;  /* Copy upper triangle to lower */
	    s += t*t;
            A_kn += n;
	}
	s = A_jn[j] - s;
	if (s <= 0.0) {
	    return((boolean_T)(1));
	}
	A_jn[j] = sqrt(s);
        A_jn += n;
    }
    return((boolean_T)0);
}

  
static void mdlInitializeSizes(SimStruct *S)
{
    ssSetNumSFcnParams(S, NUM_ARGS);
    
#if defined(MATLAB_MEX_FILE)
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) return;
    mdlCheckParameters(S);
    if (ssGetErrorStatus(S) != NULL) return;
#endif
	
    if (!ssSetNumInputPorts(S, NUM_INPORTS)) return;
    
    ssSetInputPortWidth(            S, INPORT_A, DYNAMICALLY_SIZED);
    ssSetInputPortComplexSignal(    S, INPORT_A, COMPLEX_INHERITED);
    ssSetInputPortDataType(         S, INPORT_A, SS_DOUBLE);
    ssSetInputPortDirectFeedThrough(S, INPORT_A, 1);
    ssSetInputPortReusable(        S, INPORT_A, 1);
    ssSetInputPortOverWritable(     S, INPORT_A, 1);

    if (!ssSetNumOutputPorts(S, NUM_OUTPORTS)) return;
    
    ssSetOutputPortWidth(        S, OUTPORT_L, DYNAMICALLY_SIZED);  
    ssSetOutputPortComplexSignal(S, OUTPORT_L, COMPLEX_INHERITED);
    ssSetOutputPortDataType(     S, OUTPORT_L, SS_DOUBLE);
    ssSetOutputPortReusable(    S, OUTPORT_L, 1);
        
    ssSetNumSampleTimes(S, 1);
    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE);
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
    const int_T N2   = ssGetInputPortWidth(S, INPORT_A);
    const int_T N    = (int_T)sqrt((real_T)N2);

    if (N*N != N2) {
        THROW_ERROR(S, "Input must be a square matrix.");
    }
#endif
}


static void mdlOutputs(SimStruct *S, int_T tid)
{
    boolean_T     cA       = (boolean_T)(ssGetInputPortComplexSignal(S,INPORT_A) == COMPLEX_YES);
    const ErrMode err_mode = (ErrMode)((int_T)(mxGetPr(ERR_ARG)[0]));

    /* Copy input elements to output storage area: */
    {
        const boolean_T need_copy = (boolean_T)(ssGetInputPortBufferDstPort(S, INPORT_A) != OUTPORT_L);
        if (need_copy) {
            int_T i = ssGetInputPortWidth(S, INPORT_A);

            if (cA) {
                InputPtrsType uPtrs = ssGetInputPortSignalPtrs(S, INPORT_A);
                creal_T      *y     = (creal_T *)ssGetOutputPortSignal(S, OUTPORT_L);
                while(i-- > 0) {
                    *y++ = *((creal_T *)(*uPtrs++));
                }
            } else {
                InputRealPtrsType uPtrs = ssGetInputPortRealSignalPtrs(S, INPORT_A);
                real_T           *y     = ssGetOutputPortRealSignal(S, OUTPORT_L);
                while(i-- > 0) {
                    *y++ = **uPtrs++;
                }
            }
        }
    }
    
    /* Compute Cholesky decomposition: */
    {
        const int_T N  = (int_T) sqrt((real_T)ssGetOutputPortWidth(S, OUTPORT_L));
        void       *pA = ssGetOutputPortSignal(S, OUTPORT_L);
	boolean_T   err;

        if (cA) {
            err = chol_cplx((creal_T *)pA, N);
        } else {
            err = chol_real((real_T  *)pA, N);
        }

#ifdef MATLAB_MEX_FILE
	if (err) {
            /* Input matrix not positive definite */
            static char msg[] = "Input matrix not positive definite.";
            if (err_mode == ERR_WARNING) {
                mexWarnMsgTxt(msg);
            } else if (err_mode == ERR_ERROR) {
                ssSetErrorStatus(S, msg);
            }
	}
#endif
    }
}


static void mdlTerminate(SimStruct *S)
{
}


#if defined(MATLAB_MEX_FILE)
#define MDL_SET_INPUT_PORT_WIDTH
static void mdlSetInputPortWidth(SimStruct *S, int_T port,
                                 int_T inputPortWidth)
{
    ssSetInputPortWidth( S, INPORT_A,  inputPortWidth);
    ssSetOutputPortWidth(S, OUTPORT_L, inputPortWidth);
}

# define MDL_SET_OUTPUT_PORT_WIDTH
static void mdlSetOutputPortWidth(SimStruct *S, int_T port,
                                     int_T outputPortWidth)
{
    ssSetOutputPortWidth(S, OUTPORT_L, outputPortWidth);
    ssSetInputPortWidth( S, INPORT_A,  outputPortWidth);
}
#endif


#include "dsp_cplxhs11.c"

#include "dsp_trailer.c"
/* [EOF] sdspchol.c */
