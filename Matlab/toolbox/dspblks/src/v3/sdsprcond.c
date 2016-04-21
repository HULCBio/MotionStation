/*
 * File: sdsprcond.c
 *
 * Abstract:
 *      DSP Blockset S-function for reciprocal condition number estimation.
 *
 * Copyright 1995-2002 The MathWorks, Inc.
 * $Revision: 1.13 $ $Date: 2002/04/14 20:44:13 $
 */
#define S_FUNCTION_NAME  sdsprcond
#define S_FUNCTION_LEVEL 2

#define DATA_TYPES_IMPLEMENTED

#include "dsp_sim.h"

enum {NUM_ARGS=0};
enum {INPORT_LU=0, INPORT_M1NORM, NUM_INPORTS};
enum {OUTPORT_RCOND=0, NUM_OUTPORTS};
enum {N_IDX=0, Z_IDX, NUM_DWORKS};

static void mdlInitializeSizes(SimStruct *S)
{
    ssSetNumSFcnParams(S, NUM_ARGS);
    
#if defined(MATLAB_MEX_FILE)
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) return;
#endif
    
    /* Define ports: */
    if (!ssSetNumInputPorts(S, NUM_INPORTS)) return;
    
    ssSetInputPortWidth(            S, INPORT_LU, DYNAMICALLY_SIZED);
    ssSetInputPortDirectFeedThrough(S, INPORT_LU, 1);
    ssSetInputPortComplexSignal(    S, INPORT_LU, COMPLEX_INHERITED);
    ssSetInputPortReusable(        S, INPORT_LU, 1);
    ssSetInputPortOverWritable(     S, INPORT_LU, 0);
    
    ssSetInputPortWidth(            S, INPORT_M1NORM, 1);
    ssSetInputPortDirectFeedThrough(S, INPORT_M1NORM, 1);
    ssSetInputPortComplexSignal(    S, INPORT_M1NORM, COMPLEX_NO);
    ssSetInputPortReusable(        S, INPORT_M1NORM, 1);
    ssSetInputPortOverWritable(     S, INPORT_M1NORM, 0);
    
    if (!ssSetNumOutputPorts(S, NUM_OUTPORTS)) return;
    
    ssSetOutputPortWidth(        S, OUTPORT_RCOND, 1);
    ssSetOutputPortComplexSignal(S, OUTPORT_RCOND, COMPLEX_NO);
    ssSetOutputPortReusable(    S, OUTPORT_RCOND, 1);
    
    if(!ssSetNumDWork(S, DYNAMICALLY_SIZED)) return;

    ssSetNumSampleTimes(S, 1);
    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE);
}


#define MDL_START
static void mdlStart(SimStruct *S)
{
    const int_T N2   = ssGetInputPortWidth(S,INPORT_LU);
    const int_T N    = (int_T) sqrt((real_T)N2);
    uint32_T   *Nptr = (uint32_T *)ssGetDWork(S, N_IDX);
    
    if (N*N != N2) {
        ssSetErrorStatus(S, "Input matrix must be square.");
        return;
    }
    
    *Nptr = N;
}

/*
 * Vector 1-norms, real and complex:
 */
static void v1norm_real(
                        real_T *V,
                        const int_T N,
                        real_T *v1norm
                        )
{
    int_T	i;
    real_T nrm = 0.0;
    real_T *vi = V;
    
    for(i=N; i-- > 0; ) {
        nrm += fabs(*vi++);
    }
    *v1norm = nrm;
}

static void v1norm_cplx(
                        creal_T *V,
                        const int_T N,
                        real_T *v1norm
                        )
{
    int_T	i;
    real_T nrm = 0.0;
    creal_T *vi = V;
    real_T cavi;
    
    for(i=N; i-- > 0; ) {
        CABS(*vi, cavi);
        nrm += cavi;
        vi++;
    }
    *v1norm = nrm;
}

/*
 * Reciprocal condition number estimators
 * for real and complex:
 */
static void rcond_cplx(
                       creal_T    **LU,
                       creal_T    *Z,
                       const int_T n,
                       real_T     *ynorm
                       )
{
    creal_T  ek, t, tt, wk, wkm, cs;
    creal_T *zk, *zj, **lukk, **lukj, **lujk;
    real_T   s, sm, ynrm, rs, rs1;
    const creal_T cOne = {1.0, 0.0};
    int_T    k;
    
    
    /* Initialize Z to zero. */
    zk=Z;
    {
        const creal_T cZero = {0.0, 0.0};
        for(k=n; k-- > 0; ) {
            *zk++ = cZero;
        }
    }
    
    /*
    * Solve U' * z1 = e for z1.  The components of e are chosen
    * to cause maximum local growth in the elements of z1.
    * z1 is stored in Z.
    */
    ek = cOne;
    zk = Z;
    lukk = LU;
    for(k=0; k<n; k++) {
        t.re = - (zk->re);
        t.im = - (zk->im);
        CABS(t, rs);
        if (rs != 0.0) {
            CABS(ek, rs1);
            rs = rs1 / rs;
            ek.re = t.re * rs;
            ek.im = t.im * rs;
        } else {
            CABS(ek, ek.re);
            ek.im = 0.0;
        }
        t.re += ek.re;
        t.im += ek.im;
        rs = CQABS(t);
        rs1 = CQABS(**lukk);
        if (rs > rs1) {
            s = rs1 / rs;
            /* Scale the whole vector. */
            zj = Z;
            {
                int_T j;
                for(j=n; j-- > 0; ) {
                    zj->re     *= s;
                    (zj++)->im *= s;
                }
            }
            ek.re *= s;
            ek.im *= s;
        }
        wk.re  =  ek.re - zk->re;
        wk.im  =  ek.im - zk->im;
        wkm.re = -ek.re - zk->re;
        wkm.im = -ek.im - zk->im;
        s  = CQABS(wk);
        sm = CQABS(wkm);
        if (rs1 != 0.0) {
            CCONJ(**lukk, t);
            CDIV(wk, t, wk);
            CDIV(wkm, t, wkm);
        } else {
            wk  = cOne;
            wkm = cOne;
        }
        /* Update the vector with the part of the row after the main diagonal. */
        zj = zk;
        lukj = lukk;
        {
            int_T j;
            for(j=k+1; j<n; j++) {
                lukj += n;
                CCONJ(**lukj, tt);
                t.re = CMULT_RE(wkm, tt) + (++zj)->re;
                t.im = CMULT_IM(wkm, tt) + zj->im;
                sm += CQABS(t);
                zj->re += CMULT_RE(wk, tt);
                zj->im += CMULT_IM(wk, tt);
                s += CQABS(*zj);
            }
        }
        if ((k+1 < n) && (s < sm)) {
            t.re  = wkm.re - wk.re;
            t.im  = wkm.im - wk.im;
            wk.re = wkm.re;
            wk.im = wkm.im;
            /* Update the vector with the part of the row after the main diagonal. */
            zj = zk;
            lukj = lukk;
            {
                int_T j;
                for(j=k+1; j<n; j++) {
                    lukj += n;
                    CCONJ(**lukj, tt);
                    (++zj)->re += CMULT_RE(t, tt);
                    zj->im     += CMULT_IM(t, tt);
                }
            }
        }
        *zk++ = wk;
        lukk += n+1;
    }
    /* Scale z1 by 1-norm. */
    v1norm_cplx(Z, n, &s);
    s = 1.0 / s;
    zk = Z;
    for(k=n; k-- > 0; ) {
        zk->re     *= s;
        (zk++)->im *= s;
    }
    
    /*
    * Solve L' * z2 = z1 for z2.
    * z1 is stored in Z and is overwriten by z2.
    */
    zk = Z + n-1;
    lukk = LU + n*n - 1;
    for(k=n-1; k>=0; k--) {
        if (k < n-1) {
            zj = zk;
            lujk = lukk;
            /* Update Z[k] using the subdiagonal part of column k. */
            {
                int_T j;
                for(j=k+1; j<n; j++) {
                    ++lujk;
                    ++zj;
                    CCONJ(**lujk,cs);
                    zk->re -= CMULT_RE(cs, *zj);
                    zk->im -= CMULT_IM(cs, *zj);
                }
            }
        }
        rs = CQABS(*zk);
        if (rs > 1.0) {
            s = 1.0 / rs;
            /* Scale the whole vector. */
            zj = Z;
            {
                int_T j;
                for(j=n; j-- > 0; ) {
                    zj->re     *= s;
                    (zj++)->im *= s;
                }
            }
        }
        lukk -= n+1;
        zk--;
    }
    /* Scale z2 by 1-norm. */
    v1norm_cplx(Z, n, &s);
    s = 1.0 / s;
    zk = Z;
    for(k=n; k-- > 0; ) {
        zk->re     *= s;
        (zk++)->im *= s;
    }
    
    /*
    * Solve L * z3 = z2 for z3.
    * z2 is stored in Z and is overwritten by z3.
    */
    ynrm = 1.0;
    zk = Z;
    lukk = LU;
    for(k=0; k<n; k++) {
        if (k < n-1) {
            /* Update the vector using the subdiagonal part of column k. */
            zj = zk;
            lujk = lukk;
            {
                int_T j;
                for(j=k+1; j<n; j++) {
                    ++lujk;
                    (++zj)->re -= CMULT_RE(*zk, **lujk);
                    zj->im     -= CMULT_IM(*zk, **lujk);
                }
            }
        }
        rs = CQABS(*zk);
        if (rs > 1.0) {
            s = 1.0 / rs;
            /* Scale the whole vector. */
            zj = Z;
            {
                int_T j;
                for(j=n; j-- > 0; ) {
                    zj->re     *= s;
                    (zj++)->im *= s;
                }
            }
            ynrm *= s;
        }
        lukk += n+1;
        zk++;
    }
    /* Scale z3 by 1-norm. */
    v1norm_cplx(Z, n, &s);
    s = 1.0 / s;
    zk = Z;
    for(k=n; k-- > 0; ) {
        zk->re     *= s;
        (zk++)->im *= s;
    }
    ynrm *= s;
    
    /*
    * Solve U * z = z3 for z.
    * z3 is stored in Z and is overwritten by z.
    */
    zk = Z + n-1;
    lukk = LU + (n-1)*(n+1);
    for(k=n-1; k>=0; k--) {
        rs  = CQABS(**lukk);
        rs1 = CQABS(*zk);	
        if (rs1 > rs) {
            s = rs / rs1;
            /* Scale the whole vector. */
            zj = Z;
            {
                int_T j;
                for(j=n; j-- > 0; ) {
                    zj->re     *= s;
                    (zj++)->im *= s;
                }
                ynrm *= s;
            }
        }
        if (rs == 0.0) {
            *zk = cOne;
        } else {
            CDIV(*zk,**lukk,*zk);
        }
        t.re = -(zk->re);
        t.im = -((zk--)->im);
        zj = Z;
        /* lujk ranges over superdiagonal entries in column k of LU. */
        lujk = lukk - k;
        {
            int_T j;
            for(j=k; j-- > 0; ) {
                zj->re     += CMULT_RE(t, **lujk);
                (zj++)->im += CMULT_IM(t, **lujk);
                lujk++;
            }
        }
        lukk -= n+1;
    }
    /* Compute the 1-norm of z. */
    v1norm_cplx(Z, n, &s);
    s = 1.0 / s;
    ynrm *= s;
    
    *ynorm = ynrm;
}


static void rcond_real(
                       real_T     **LU,
                       real_T     *Z,
                       const int_T n,
                       real_T     *ynorm
                       )
{
    real_T  ek, t, tt, s, sm, wk, wkm, ynrm;
    real_T *zk, *zj, **lukk, **lukj, **lujk;
    int_T   k;
    
    
    /* Initialize Z to zero. */
    zk=Z;
    for(k=n; k-- > 0; ) {
        *zk++ = 0.0;
    }
    
    /*
    * Solve U' * z1 = e for z1.  The components of e are chosen
    * to cause maximum local growth in the elements of z1.
    * z1 is stored in Z.
    */
    ek = 1.0;
    zk = Z;
    lukk = LU;
    for(k=0; k<n; k++) {
        t = -(*zk);
        ek = (t >= 0) ? fabs(ek) : -fabs(ek);
        t += ek;
        tt = fabs(**lukk);
        if (fabs(t) > tt) {
            s = tt / fabs(t);
            /* Scale the whole vector. */
            zj = Z;
            {
                int_T j;
                for(j=n; j-- > 0; ) {
                    *zj++ *= s;
                }
            }
            ek *= s;
        }
        wk  =  ek - *zk;
        wkm = -ek - *zk;
        s = fabs(wk);
        sm = fabs(wkm);
        if (tt != 0.0) {
            t = **lukk;
            wk  /= t;
            wkm /= t;
        } else {
            wk  = 1.0;
            wkm = 1.0;
        }
        /* Update the vector with the part of the row after the main diagonal. */
        zj = zk;
        lukj = lukk;
        {
            int_T j;
            for(j=k+1; j<n; j++) {
                lukj += n;
                tt = **lukj;
                t = wkm * tt + *(++zj);
                sm += fabs(t);
                *zj += wk * tt;
                s += fabs(*zj);
            }
        }
        if ((k+1 < n) && (s < sm)) {
            t = wkm - wk;
            wk = wkm;
            /* Update the vector with the part of the row after the main diagonal. */
            zj = zk;
            lukj = lukk;
            {
                int_T j;
                for(j=k+1; j<n; j++) {
                    lukj += n;
                    tt = **lukj;
                    *(++zj) += t * tt;
                }
            }
        }
        *zk++ = wk;
        lukk += n+1;
    }
    /* Scale z1 by 1-norm. */
    v1norm_real(Z, n, &s);
    s = 1.0 / s;
    zk = Z;
    for(k=n; k-- > 0; ) {
        *zk++ *= s;
    }
    
    /*
    * Solve L' * z2 = z1 for z2.
    * z1 is stored in Z and is overwriten by z2.
    */
    zk = Z + n-1;
    lukk = LU + n*n - 1;
    for(k=n-1; k>=0; k--) {
        if (k < n-1) {
            zj = zk;
            lujk = lukk;
            /* Update Z[k] using the subdiagonal part of column k. */
            {
                int_T j;
                for(j=k+1; j<n; j++) {
                    *zk -= **(++lujk) * *(++zj);
                }
            }
        }
        if (fabs(*zk) > 1.0) {
            s = 1.0 / fabs(*zk);
            /* Scale the whole vector. */
            zj = Z;
            {
                int_T j;
                for(j=n; j-- > 0; ) {
                    *zj++ *= s;
                }
            }
        }
        lukk -= n+1;
        zk--;
    }
    /* Scale z2 by 1-norm. */
    v1norm_real(Z, n, &s);
    s = 1.0 / s;
    zk = Z;
    for(k=n; k-- > 0; ) {
        *zk++ *= s;
    }
    
    /*
    * Solve L * z3 = z2 for z3.
    * z2 is stored in Z and is overwritten by z3.
    */
    ynrm = 1.0;
    zk = Z;
    lukk = LU;
    for(k=0; k<n; k++) {
        if (k < n-1) {
            /* Update the vector using the subdiagonal part of column k. */
            zj = zk;
            lujk = lukk;
            {
                int_T j;
                for(j=k+1; j<n; j++) {
                    *(++zj) -= *zk * **(++lujk);
                }
            }
        }
        if (fabs(*zk) > 1.0) {
            s = 1.0 / fabs(*zk);
            /* Scale the whole vector. */
            zj = Z;
            {
                int_T j;
                for(j=n; j-- > 0; ) {
                    *zj++ *= s;
                }
            }
            ynrm *= s;
        }
        lukk += n+1;
        zk++;
    }
    /* Scale z3 by 1-norm. */
    v1norm_real(Z, n, &s);
    s = 1.0 / s;
    zk = Z;
    for(k=n; k-- > 0; ) {
        *zk++ *= s;
    }
    ynrm *= s;
    
    /*
    * Solve U * z = z3 for z.
    * z3 is stored in Z and is overwritten by z.
    */
    zk = Z + n-1;
    lukk = LU + (n-1)*(n+1);
    for(k=n-1; k>=0; k--) {
        t  = fabs(**lukk);
        tt = fabs(*zk);
        if (tt > t) {
            s = t / tt;
            /* Scale the whole vector. */
            zj = Z;
            {
                int_T j;
                for(j=n; j-- > 0; ) {
                    *zj++ *= s;
                }
            }
            ynrm *= s;
        }
        if (t == 0.0) {
            *zk = 1.0;
        } else {
            *zk /= **lukk;
        }
        t = -(*zk--);
        zj = Z;
        /* lujk ranges over superdiagonal entries in column k of LU. */
        lujk = lukk - k;
        {
            int_T j;
            for(j=k; j-- > 0; ) {
                *zj++ += **lujk++ * t;
            }
        }
        lukk -= n+1;
    }
    /* Compute the 1-norm of z. */
    v1norm_real(Z, n, &s);
    s = 1.0 / s;
    ynrm *= s;
    
    *ynorm = ynrm;
    
}


static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, 0.0);
}


static void mdlOutputs(SimStruct *S, int_T tid)
{
    const boolean_T cLU   = (boolean_T)(ssGetInputPortComplexSignal(S,INPORT_LU) == COMPLEX_YES);
    const real_T    anorm = **ssGetInputPortRealSignalPtrs(S, INPORT_M1NORM);
    const int_T     N     = *((uint32_T *)ssGetDWork(S, N_IDX));
    real_T         *y     = ssGetOutputPortRealSignal(S, OUTPORT_RCOND);
    void           *Z     = ssGetDWork(S, Z_IDX);
    
    if (anorm == 0.0) {
        *y = 0.0;
        return;
    }
    
    if (cLU) {
    /*
    * Complex input:
        */
        InputPtrsType pLU = ssGetInputPortSignalPtrs(S, INPORT_LU);
        rcond_cplx((creal_T **)pLU, (creal_T *)Z, N, y);
        *y /= anorm;
        
    } else {
    /*
    * Real input: 
        */
        InputRealPtrsType pLU = ssGetInputPortRealSignalPtrs(S, INPORT_LU);
        rcond_real((real_T **)pLU, (real_T *)Z, N, y);
        *y /= anorm;
    }
}


static void mdlTerminate(SimStruct *S)
{
}


#if defined(MATLAB_MEX_FILE)

#define MDL_SET_WORK_WIDTHS
static void mdlSetWorkWidths(SimStruct *S)
{
    const int_T N2 = ssGetInputPortWidth(S,INPORT_LU);
    const int_T N  = (int_T) sqrt((real_T)N2);

    if(!ssSetNumDWork(S, NUM_DWORKS)) return;

    ssSetDWorkWidth(        S, N_IDX, 1);
    ssSetDWorkDataType(     S, N_IDX, SS_UINT32);
    ssSetDWorkComplexSignal(S, N_IDX, COMPLEX_NO);
    
    ssSetDWorkWidth(        S, Z_IDX, N);
    ssSetDWorkDataType(     S, Z_IDX, SS_DOUBLE);
    ssSetDWorkComplexSignal(S, Z_IDX, ssGetInputPortComplexSignal(S,INPORT_LU));
}


# define MDL_SET_INPUT_PORT_WIDTH
static void mdlSetInputPortWidth(SimStruct *S, int_T port,
                                 int_T inputPortWidth)
{
    ssSetInputPortWidth(S, port, inputPortWidth);
}

# define MDL_SET_OUTPUT_PORT_WIDTH
static void mdlSetOutputPortWidth(SimStruct *S, int_T port,
                                  int_T outputPortWidth)
{
    ssSetErrorStatus(S, "Invalid output port propagation call");
}

#endif


#ifdef  MATLAB_MEX_FILE
#include "simulink.c"   /* MEX Interface Mechanism   */
#else
#include "cg_sfun.h"    /* RTW Registration Function */
#endif


/* EOF: sdsprcond.c */
