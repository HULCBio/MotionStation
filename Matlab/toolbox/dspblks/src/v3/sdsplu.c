/*
 * File: sdsplu.c
 *
 * Abstract:
 *      S-function for LU decomposition
 *
 * Copyright 1995-2002 The MathWorks, Inc.
 * $Revision: 1.18 $
 * $Date: 2002/04/14 20:44:01 $
 */

#define S_FUNCTION_NAME  sdsplu
#define S_FUNCTION_LEVEL 2

#define DATA_TYPES_IMPLEMENTED

#include "dsp_sim.h"

enum {INPORT_A=0, NUM_INPORTS};
enum {OUTPORT_LU=0, OUTPORT_P, NUM_OUTPORTS};

enum {NUM_PARAMS=0};

static void lu_cplx(
    creal_T    *A,
    const int_T n,
    real_T     *piv
)
{
    int_T k;
    
    /* initialize row-pivot indices: */
    for (k = 0; k < n; k++) {
        piv[k] = (real_T)(k+1);
    }
    
    /* Loop over each column: */
    for (k = 0; k < n; k++) {
        const int_T kn = k*n;
        int_T	p = k;
        
        /*
         * Scan the lower triangular part of this column only
         * Record row of largest value
         */
        {
            int_T  i;
            real_T Amax = CQABS(A[p+kn]);	/* approx mag-squared value */
            
            for (i = k+1; i < n; i++) {
                real_T q = CMAGSQ(A[i+kn]);
                if (q > Amax) {p = i; Amax = q;}
            }
        }
            
        /* swap rows if required */
        if (p != k) {
            int_T j;
            for (j = 0; j < n; j++) {
                creal_T c;
                const int_T pjn = p+j*n;
                const int_T kjn = k+j*n;
                
                c      = A[pjn];
                A[pjn] = A[kjn];
                A[kjn] = c;
            }
                
            /* Swap pivot row indices */
            {
                real_T t = piv[p]; piv[p] = piv[k]; piv[k] = t;
            }
        }
            
        /* column reduction */
        {
            creal_T Adiag;
            int_T i, j;
        
            Adiag = A[k+kn];
        
            if (!((Adiag.re == 0.0) && (Adiag.im == 0.0))) {	/* non-zero diagonal entry */
                /*
                 * divide lower triangular part of column by max
                 * First, form reciprocal of Adiag:
                 *	    recip = conj(Adiag)/(|Adiag|^2)
                 */
                 CRECIP(Adiag, Adiag);
                        
                /* Multiply: A[i+kn] *= Adiag: */
                for (i = k+1; i < n; i++) {
                    real_T t   = CMULT_RE(A[i+kn], Adiag);
                    A[i+kn].im = CMULT_IM(A[i+kn], Adiag);
                    A[i+kn].re = t;
                }
                        
                /* subtract multiple of column from remaining columns */
                for (j = k+1; j < n; j++) {
                    int_T jn = j*n;
                    for (i = k+1; i < n; i++) {
                        /* Multiply: c = A[i+kn] * A[k+jn]: */
                        creal_T c;
                        c.re = CMULT_RE(A[i+kn], A[k+jn]);
                        c.im = CMULT_IM(A[i+kn], A[k+jn]);
                        
                        /* Subtract A[i+jn] -= A[i+kn]*A[k+jn]: */
                        A[i+jn].re -= c.re;
                        A[i+jn].im -= c.im;
                    }
                }
            }
        }
    }
}

static void lu_real(
    real_T     *A,
    const int_T n,
    real_T     *piv
)
{
    int_T k;
    
    /* initialize row-pivot indices: */
    for (k = 0; k < n; k++) {
        piv[k] = (real_T)(k+1);
    }
    
    /* Loop over each column: */
    for (k = 0; k < n; k++) {
        const int_T kn = k*n;
        int_T p = k;
        
        /* Scan the lower triangular part of this column only
         * Record row of largest value
         */
        {
            int_T i;
            real_T Amax = fabs(A[p+kn]); /* assume diag is max */
            for (i = k+1; i < n; i++) {
                real_T q = fabs(A[i+kn]);
                if (q > Amax) {p = i; Amax = q;}
            }
        }
            
        /* swap rows if required */
        if (p != k) {
            int_T j;
            real_T t;
            for (j = 0; j < n; j++) {
                const int_T jn = j*n;
                t = A[p+jn]; A[p+jn] = A[k+jn]; A[k+jn] = t;
            }
            /* swap pivot row indices */
            t = piv[p]; piv[p] = piv[k]; piv[k] = t;
        }
            
        /* column reduction */
        {
            real_T Adiag = A[k+kn];
            int_T i,j;
            if (Adiag != 0.0) {  /* non-zero diagonal entry */
                    
                /* divide lower triangular part of column by max */
                Adiag = 1.0/Adiag;
                for (i = k+1; i < n; i++) {
                    A[i+kn] *= Adiag;
                }
                    
                /* subtract multiple of column from remaining columns */
                for (j = k+1; j < n; j++) {
                    int_T jn = j*n;
                    for (i = k+1; i < n; i++) {
                        A[i+jn] -= A[i+kn]*A[k+jn]; 
                    }
                }
            }
        }
    }
}


static void mdlInitializeSizes(SimStruct *S)
{
    ssSetNumSFcnParams(S, NUM_PARAMS);
    
#if defined(MATLAB_MEX_FILE)
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) return;
#endif
        
    {
        if (!ssSetNumInputPorts(S, 1)) return;
        
        ssSetInputPortWidth(            S, INPORT_A, DYNAMICALLY_SIZED);
        ssSetInputPortDirectFeedThrough(S, INPORT_A, 1);
        ssSetInputPortComplexSignal(    S, INPORT_A, COMPLEX_INHERITED);
        ssSetInputPortReusable(        S, INPORT_A, 1);
        ssSetInputPortOverWritable(     S, INPORT_A, 1);
        ssSetInputPortDataType(         S, INPORT_A, SS_DOUBLE);

        if (!ssSetNumOutputPorts(S,2)) return;
        
        ssSetOutputPortWidth(        S, OUTPORT_LU, DYNAMICALLY_SIZED);  
        ssSetOutputPortComplexSignal(S, OUTPORT_LU, COMPLEX_INHERITED);
        ssSetOutputPortReusable(    S, OUTPORT_LU, 1);
        ssSetOutputPortDataType(     S, OUTPORT_LU, SS_DOUBLE);

        ssSetOutputPortWidth(        S, OUTPORT_P, DYNAMICALLY_SIZED);
        ssSetOutputPortComplexSignal(S, OUTPORT_P, COMPLEX_NO);
        ssSetOutputPortReusable(    S, OUTPORT_P, 1);
        ssSetOutputPortDataType(     S, OUTPORT_P, SS_DOUBLE);
    }
        
    ssSetNumSampleTimes(S, 1);
    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE);
}


static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, 0.0);
}


static void mdlOutputs(SimStruct *S, int_T tid)
{
    boolean_T cA = (boolean_T)(ssGetInputPortComplexSignal(S,INPORT_A) == COMPLEX_YES);

    /* Copy input elements to output storage area: */
    {
        const boolean_T need_copy = (boolean_T)(ssGetInputPortBufferDstPort(S, INPORT_A) != OUTPORT_LU);
        if (need_copy) {
            int_T i = ssGetInputPortWidth(S, INPORT_A);

            if (cA) {
                InputPtrsType uPtrs = ssGetInputPortSignalPtrs(S, INPORT_A);
                creal_T      *y     = (creal_T *)ssGetOutputPortSignal(S, OUTPORT_LU);
                while(i-- > 0) {
                    *y++ = *((creal_T *)(*uPtrs++));
                }
            } else {
                InputRealPtrsType uPtrs = ssGetInputPortRealSignalPtrs(S, INPORT_A);
                real_T           *y     = ssGetOutputPortRealSignal(S, OUTPORT_LU);
                while(i-- > 0) {
                    *y++ = **uPtrs++;
                }
            }
        }
    }
    
    /* Compute LU decomposition: */
    {
        int_T   N = ssGetOutputPortWidth(     S, OUTPORT_P );
        real_T *p = ssGetOutputPortRealSignal(S, OUTPORT_P );
        void   *u = ssGetOutputPortSignal(    S, OUTPORT_LU);
        if (cA) {
            lu_cplx((creal_T *)u, N, p);
        } else {
            lu_real((real_T  *)u, N, p);
        }
    }
}


static void mdlTerminate(SimStruct *S)
{
}

#if defined(MATLAB_MEX_FILE)
static void SetPortWidths(SimStruct *S, int_T port, int_T portWidth, int_T caller)
{
    int_T NLU, NP, NA;

    if (caller == 1) {
        /* Output called */
        if (port == OUTPORT_LU) {
            /* NLU known */
            NLU = portWidth;
            NA  = NLU;
            NP = (int_T)(sqrt((real_T)NLU));
        } else {
            /* NP known */
            NP = portWidth;
            NA = NP*NP;
            NLU = NA;
        }
    } else {
        /* Input called */
        NA = portWidth;
        NLU = NA;
        NP = (int_T)(sqrt((real_T)NLU));
    }

    if (NP*NP != NLU) {
        ssSetErrorStatus(S, "Invalid size of output matrix LU");
        return;
    }

    ssSetOutputPortWidth(S, OUTPORT_LU, NLU);
    ssSetOutputPortWidth(S, OUTPORT_P,  NP);
    ssSetInputPortWidth( S, INPORT_A,   NA);
}

#define MDL_SET_INPUT_PORT_WIDTH
static void mdlSetInputPortWidth(SimStruct *S, int_T port,
                                 int_T inputPortWidth)
{
    SetPortWidths(S, port, inputPortWidth, 0);
}

# define MDL_SET_OUTPUT_PORT_WIDTH
static void mdlSetOutputPortWidth(SimStruct *S, int_T port,
                                     int_T outputPortWidth)
{
    SetPortWidths(S, port, outputPortWidth, 1);
}
#endif


#include "dsp_cplxhs11.c"

#include "dsp_trailer.c"
