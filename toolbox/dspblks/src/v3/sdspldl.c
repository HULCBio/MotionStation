/*
 * File: sdspldl.c
 *
 * Abstract:
 *      S-function for LDL factorization
 *
 * Copyright 1995-2002 The MathWorks, Inc.
 * $Revision: 1.20 $
 * $Date: 2002/04/14 20:43:55 $
 */
#define S_FUNCTION_NAME  sdspldl
#define S_FUNCTION_LEVEL 2

#define DATA_TYPES_IMPLEMENTED

#include "dsp_sim.h"

enum {V_IDX=0, NUM_DWORKS};

enum {INPORT_A=0, NUM_INPORTS};
enum {OUTPORT_LDL=0, NUM_OUTPORTS};

enum {NUM_PARAMS=0};

static void ldl_cplx(
    creal_T    *A,
    creal_T    *V,
    const int_T n
)
{
    int_T j;
    for(j=0; j<n; j++) {
        creal_T *Aji = A+j;
        creal_T *Vi = V;
        {
            creal_T *Aii = A;
            int_T   i;
            for (i=j; i-- > 0; ) {
                Vi->re     = CMULT_XCONJ_RE(*Aji, *Aii);
                (Vi++)->im = CMULT_XCONJ_IM(*Aji, *Aii);
                Aii += n+1;
                Aji += n;
            }
        }
        {
            /* At this point, Aji points to A[j,j], vi points to v[j] */
            creal_T *Vj  = Vi;
            Vi  = V;
            *Vj = *Aji;
            Aji = A+j;  /* Point to A[j,i] for i=1 */
            {
                creal_T Vjsum = *Vj;
                int_T  i;
                for(i=j; i-- > 0; ) {
                    Vjsum.re -= CMULT_RE(*Aji, *Vi);
                    Vjsum.im -= CMULT_IM(*Aji, *Vi);
                    Vi++;
                    Aji += n;
                }
                *Vj = Vjsum;
            }

            /* At this point, Aji points to A[j,j] */
            *Aji = *Vj;
            {
                creal_T *Ajpki = A+j+1;
                int_T   i;
                Vi = V;
                for (i=j; i-- > 0; ) {
                    creal_T *Ajik = Aji;  /* init to subdiagonal */
                    const creal_T Vi_val = *Vi++;
                    int_T k;
                    for (k=n-j-1; k-- > 0; ) {
                        (++Ajik)->re -= CMULT_RE(*Ajpki, Vi_val);
                        Ajik->im     -= CMULT_IM(*Ajpki, Vi_val);
                        Ajpki++;
                    }
                    /* At this point, Ajpki points to A[1, i+1]
                     * Increment so Ajpki points to A[j+1, i+1]
                     */
                    Ajpki += j+1;
                }
            }
            {
                creal_T *Ajik = Aji;
                int_T k;
#if 1
                /* Better accuracy: */
                const creal_T Vjval = *Vj;
                for (k=n-j-1; k-- > 0; ) {
                    creal_T Ajik_val;
                    Ajik_val = *(++Ajik);
                    CDIV(Ajik_val, Vjval, *Ajik);
                }
#else
                /* More efficient: */
                const creal_T Vjrecip = CRECIP(*Vj);
                for (k=n-j-1; k-- > 0; ) {
                    creal_T Ajik_val;
                    Ajik_val = *(++Ajik);
                    Ajik->re = CMULT_RE(Ajik_val, Vjrecip);
                    Ajik->im = CMULT_IM(Ajik_val, Vjrecip);
                }
#endif
            }
        }
    } /* j loop */

    /* Transpose and copy upper subtriang to lower */
    {
        int_T c;
        for (c=0; c<n; c++) {
            int_T r;
            for (r=c; r<n; r++) {
                A[r*n+c].re =  A[c*n+r].re;
                A[r*n+c].im = -A[c*n+r].im; /* Hermitian transpose */
            }
        }
    }
}


static void ldl_real(
    real_T     *A,
    real_T     *V,
    const int_T n
)
{
    int_T j;
    for(j=0; j<n; j++) {
        real_T *Aji = A+j;
        real_T *Vi = V;
        {
            real_T *Aii = A;
            int_T   i;
            for (i=j; i-- > 0; ) {
                *Vi++ = *Aji * *Aii;  /* conj(Aji) */
                Aii += n+1;
                Aji += n;
            }
        }
        {
            /* At this point, Aji points to A[j,j], vi points to v[j] */
            real_T *Vj  = Vi;
            Vi  = V;
            *Vj = *Aji;
            Aji = A+j;  /* Point to A[j,i] for i=1 */
            {
                real_T Vjsum = *Vj;
                int_T  i;
                for(i=j; i-- > 0; ) {
                    Vjsum -= *Aji * *Vi++;
                    Aji += n;
                }
                *Vj = Vjsum;
            }

            /* At this point, Aji points to A[j,j] */
            *Aji = *Vj;
            {
                real_T *Ajpki = A+j+1;
                int_T   i;
                Vi = V;
                for (i=j; i-- > 0; ) {
                    real_T *Ajik = Aji;  /* init to subdiagonal */
                    const real_T Vi_val = *Vi++;
                    int_T k;
                    for (k=n-j-1; k-- > 0; ) {
                        *(++Ajik) -= *Ajpki++ * Vi_val;
                    }
                    /* At this point, Ajpki points to A[1, i+1]
                     * Increment so Ajpki points to A[j+1, i+1]
                     */
                    Ajpki += j+1;
                }
            }
            {
                real_T *Ajik = Aji;
                int_T k;
#if 1
                /* Better accuracy: */
                const real_T Vjval = *Vj;
                for (k=n-j-1; k-- > 0; ) {
                    *(++Ajik) /= Vjval;
                }
#else
                /* More efficient: */
                const real_T Vjrecip = 1.0 / *Vj;
                for (k=n-j-1; k-- > 0; ) {
                    *(++Ajik) *= Vjrecip;
                }
#endif
            }
        }
    } /* j loop */

    /* Transpose and copy upper subtriang to lower */
    {
        int_T c;
        for (c=0; c<n; c++) {
            int_T r;
            for (r=c; r<n; r++) {
                A[r*n+c] = A[c*n+r];
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
        
    if (!ssSetNumInputPorts(S, NUM_INPORTS)) return;
    
    ssSetInputPortWidth(            S, INPORT_A, DYNAMICALLY_SIZED);
    ssSetInputPortDirectFeedThrough(S, INPORT_A, 1);
    ssSetInputPortComplexSignal(    S, INPORT_A, COMPLEX_INHERITED);
    ssSetInputPortReusable(        S, INPORT_A, 1);
    ssSetInputPortOverWritable(     S, INPORT_A, 1);
    ssSetInputPortDataType(         S, INPORT_A, SS_DOUBLE);

    if (!ssSetNumOutputPorts(S, NUM_OUTPORTS)) return;
    
    ssSetOutputPortWidth(        S, OUTPORT_LDL, DYNAMICALLY_SIZED);  
    ssSetOutputPortComplexSignal(S, OUTPORT_LDL, COMPLEX_INHERITED);
    ssSetOutputPortReusable(    S, OUTPORT_LDL, 1);
    ssSetOutputPortDataType(     S, OUTPORT_LDL, SS_DOUBLE);

    if(!ssSetNumDWork(S, DYNAMICALLY_SIZED)) return;

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
        const boolean_T need_copy = (boolean_T)(ssGetInputPortBufferDstPort(S, INPORT_A) != OUTPORT_LDL);
        if (need_copy) {
            int_T i = ssGetInputPortWidth(S, INPORT_A);

            if (cA) {
                InputPtrsType pA = ssGetInputPortSignalPtrs(S, INPORT_A);
                creal_T      *y  = (creal_T *)ssGetOutputPortSignal(S, OUTPORT_LDL);
                while(i-- > 0) {
                    *y++ = *((creal_T *)(*pA++));
                }
            } else {
                InputRealPtrsType pA = ssGetInputPortRealSignalPtrs(S, INPORT_A);
                real_T           *y  = ssGetOutputPortRealSignal(S, OUTPORT_LDL);
                while(i-- > 0) {
                    *y++ = **pA++;
                }
            }
        }
    }
    
    /* Compute LDL decomposition: */
    {
        const int_T N    = (int_T) sqrt((real_T)ssGetOutputPortWidth(S, OUTPORT_LDL));
        void       *pLDL = ssGetOutputPortSignal(S, OUTPORT_LDL);
        void       *V    = ssGetDWork(S, V_IDX);
        if (cA) {
            ldl_cplx((creal_T *)pLDL, (creal_T *)V, N);
        } else {
            ldl_real((real_T  *)pLDL, (real_T *)V,  N);
        }
    }
}


static void mdlTerminate(SimStruct *S)
{
}


#ifdef MATLAB_MEX_FILE
#define MDL_SET_INPUT_PORT_WIDTH
static void mdlSetInputPortWidth(SimStruct *S, int_T port,
                                 int_T portWidth)
{
    ssSetInputPortWidth( S, INPORT_A,    portWidth);
    ssSetOutputPortWidth(S, OUTPORT_LDL, portWidth);
}

# define MDL_SET_OUTPUT_PORT_WIDTH
static void mdlSetOutputPortWidth(SimStruct *S, int_T port,
                                     int_T portWidth)
{
    ssSetInputPortWidth( S, INPORT_A,    portWidth);
    ssSetOutputPortWidth(S, OUTPORT_LDL, portWidth);
}

#define MDL_SET_WORK_WIDTHS
static void mdlSetWorkWidths(SimStruct *S)
{
    const int_T N2   = ssGetOutputPortWidth(S, OUTPORT_LDL);
    const int_T N    = (int_T)sqrt((real_T)N2);
    CSignal_T   Cplx = ssGetOutputPortComplexSignal(S, OUTPORT_LDL);

    if (N*N != N2) {
        ssSetErrorStatus(S, "Invalid port widths - input must be square.");
        return;
    }
    
    if(!ssSetNumDWork(      S, NUM_DWORKS)) return;
    ssSetDWorkWidth(        S, V_IDX, N);
    ssSetDWorkDataType(     S, V_IDX, SS_DOUBLE);
    ssSetDWorkComplexSignal(S, V_IDX, Cplx);
}
#endif


#include "dsp_cplxhs11.c"

#include "dsp_trailer.c"

/* [EOF] sdspldl.c */
