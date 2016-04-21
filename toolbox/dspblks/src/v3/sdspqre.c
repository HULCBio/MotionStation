/*
* File: sdspqre.c
*
* Abstract:
*      DSP Blockset S-function for Economy-sized QR factorization with column pivoting
*
* Copyright 1995-2002 The MathWorks, Inc.
* $Revision: 1.17 $ $Date: 2002/04/14 20:44:46 $
*/
#define S_FUNCTION_NAME  sdspqre
#define S_FUNCTION_LEVEL 2

#include "dsp_sim.h"
#include "dspqrdc_rt.h"


enum {QRAUX_IDX=0, WORK_IDX, S_IDX, MAX_NUM_DWORKS};
enum {JPVT_IDX, NUM_IWORKS};
enum {INPORT_A=0, NUM_INPORTS};
enum {OUTPORT_Q=0, OUTPORT_R, OUTPORT_E, NUM_OUTPORTS};
enum {N_ARGC=0, NUM_PARAMS};
#define N_ARG ssGetSFcnParam(S, N_ARGC)


#ifdef MATLAB_MEX_FILE
#define MDL_CHECK_PARAMETERS
static void mdlCheckParameters(SimStruct *S) {
    
    if (OK_TO_CHECK_VAR(S, N_ARG)) {
        if (!IS_FLINT_GE(N_ARG, 1)) {
            THROW_ERROR(S, "Number of columns must be a real, scalar integer > 0.");
        }
    }
}
#endif


static void mdlInitializeSizes(SimStruct *S)
{
    int_T N;
    
    ssSetNumSFcnParams(S, NUM_PARAMS);
    
#if defined(MATLAB_MEX_FILE)
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) return;
    mdlCheckParameters(S);
    if (ssGetErrorStatus(S) != NULL) return;
#endif
    
    ssSetSFcnParamNotTunable(S, N_ARGC);

    if (!ssSetNumInputPorts(S, NUM_INPORTS)) return;
    
    ssSetInputPortWidth(            S, INPORT_A, DYNAMICALLY_SIZED);
    ssSetInputPortDirectFeedThrough(S, INPORT_A, 1);
    ssSetInputPortComplexSignal(    S, INPORT_A, COMPLEX_INHERITED);
    ssSetInputPortReusable(         S, INPORT_A, 1);
    ssSetInputPortOverWritable(     S, INPORT_A, 1);
    ssSetInputPortDataType(         S, INPORT_A, SS_DOUBLE);
    
    if (!ssSetNumOutputPorts(S, NUM_OUTPORTS)) return;
    
    ssSetOutputPortWidth(        S, OUTPORT_Q, DYNAMICALLY_SIZED);
    ssSetOutputPortComplexSignal(S, OUTPORT_Q, COMPLEX_INHERITED);
    ssSetOutputPortReusable(     S, OUTPORT_Q, 1);
    ssSetOutputPortDataType(     S, OUTPORT_Q, SS_DOUBLE);
    
    ssSetOutputPortWidth(        S, OUTPORT_R, DYNAMICALLY_SIZED);
    ssSetOutputPortComplexSignal(S, OUTPORT_R, COMPLEX_INHERITED);
    ssSetOutputPortReusable(     S, OUTPORT_R, 1);
    ssSetOutputPortDataType(     S, OUTPORT_R, SS_DOUBLE);
    
    N = (int_T)(*(mxGetPr(N_ARG)));
    ssSetOutputPortWidth(        S, OUTPORT_E, N);
    ssSetOutputPortComplexSignal(S, OUTPORT_E, COMPLEX_NO);
    ssSetOutputPortReusable(     S, OUTPORT_E, 1);
    ssSetOutputPortDataType(     S, OUTPORT_E, SS_DOUBLE);
    
    if(!ssSetNumDWork(S, DYNAMICALLY_SIZED)) return;
    
    ssSetNumIWork(S, N);
    
    ssSetNumSampleTimes(S, 1);
    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE);
}


static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, 0.0);
}

/*
 * MWDSP_qrsl1Z - use the qr factorization stored in qr and qraux
 * to operate on y and compute q*y in place over y
 */
static int_T MWDSP_qrsl1Z(
    int_T		n,
    int_T		k,
    creal_T	*qr,
    creal_T	*qraux,
    creal_T	*y
    )
{
    int_T	j, info=0;
    creal_T	*pqraux, *py;

    j = MIN(k,n-1);

    /* special action when n=1 */
    if (j == 0) {
	return(info);
    }

    /* compute qy */
    pqraux = qraux + j-1;
    py = y + j-1;
    while (j--) {
	    MWDSP_qrCompqyZ(n, j, qr, pqraux--, py--);
    }
    return(info);
}

/*
 * MWDSP_qrsl1D - use the qr factorization stored in qr and qraux
 * to operate on y and compute q*y in place over y
 */
static int_T MWDSP_qrsl1D(
    int_T	n,
    int_T	k,
    real_T	*qr,
    real_T	*qraux,
    real_T	*y
    )
{
    int_T	j, info=0;
    real_T	*pqraux, *py;

    j = MIN(k,n-1);

    /* special action when n=1 */
    if (j == 0) {
	return(info);
    }

    /* compute qy */
    pqraux = qraux + j-1;
    py = y + j-1;
    while (j--) {
	MWDSP_qrCompqyD(n, j, qr, pqraux--, py--);
    }
    return(info);
}


/*
* sdspqre accepts a copy of A in the m-by-n R and returns
* its QR factorization in Q, R and the permutation vector E.
* qraux, work and jpvt are used as auxilliary work vectors.
* If the system is overdetermined, the n-by-n economy-sized
* upper triangular version of R is copied into S.
*/
static void sdspqre_real(
    int_T	m,
    int_T	n,
    real_T *q,
    real_T	*r,
    real_T	*e,
    real_T *qraux,
    real_T	*work,
    int_T	*jpvt,
    real_T	*s
    )
{
    int_T	i, j, minmn, *pjpvt;
    real_T	*pq, *pr, *ps, *pe, Zero = 0.0, One = 1.0;
    
    MWDSP_qrdcD(m, n, r, qraux, jpvt, work);
    
    /* explicitly form q by manipulating identity */
    minmn = MIN(m,n);
    pq = q;
    for(j=m*minmn; j-- > 0; ) {
        *pq++ = Zero;
    }
    pq = q;	/* pointer to q(j,j) */
    for(j=minmn; j-- > 0; ) {
        *pq = One;
        pq += m+1;
    }
    /*
    * Convert cols of identity into cols of q.
    * sdspqrsl1 uses info stored in lower triangle of r and in
    * vector qraux to work on columns of identity matrix I and
    * transform them into q*I(:,j) i.e. the columns of q.
    */
    pq = q;	/* pointer to q(1,j) */
    for (j=minmn; j-- > 0; ) {
        MWDSP_qrsl1D(m, n, r, qraux, pq);
        pq += m;
    }
    
    if (m > n) { /* Copy upper triangle of r to s */
        pr = r;	/* pointer to r(1:j,j) */
        ps = s;	/* pointer to s(1:j,j) */
        for (j=0; j < n; j++) {
            for(i=0; i <= j; i++) {
                *ps++ = *pr++;
            }
            pr += m-j-1;
            ps += n-j-1;
        }
    } else { /* Zero strict lower triangle of r */
        pr = r + (m-1)*m - 1; /* pointer to r(j:end,j-1) */
        for(j=m-1; j-->0; ) {
            for(i=m; i-- > j+1; ) {
                *pr-- = Zero;
            }
            pr -= (j+1);
        }
    }
    
    /* form permutation vector e */
    pe = e;			/* pointer to e(j) */
    pjpvt = jpvt;	/* pointer to jpvt(j) */
    for (j=n; j-- > 0; ) {
        *pe = (real_T)(*pjpvt) + 1;
        pe++;
        pjpvt++;
    }
}


static void sdspqre_cplx(
    int_T	 m,
    int_T	 n,
    creal_T *q,
    creal_T *r,
    real_T	 *e,
    creal_T *qraux,
    creal_T *work,
    int_T	 *jpvt,
    creal_T *s
    )
{
    int_T	i, j, minmn, *pjpvt;
    creal_T	*pq, *pr, *ps, Zero = {0.0, 0.0}, One = {1.0, 0.0};
    real_T	*pe;
    
    
    MWDSP_qrdcZ(m, n, r, qraux, jpvt, work);
    
    /* explicitly form q by manipulating identity */
    minmn = MIN(m,n);
    pq = q;
    for(j=m*minmn; j-- > 0; ) {
        *pq++ = Zero;
    }
    pq = q;	/* pointer to q(j,j) */
    for(j=minmn; j-- > 0; ) {
        *pq = One;
        pq += m+1;
    }
    
    /*
    * Convert cols of identity into cols of q.
    * sdspqrsl1 uses info stored in lower triangle of r and in vector qraux
    * to work on columns of identity matrix I and transform them into
    * q*I(:,j) i.e. the columns of q.
    */
    pq = q;	/* pointer to q(1,j) */
    for (j=minmn; j-- > 0; ) {
       MWDSP_qrsl1Z(m, n, r, qraux, pq);
        pq += m;
    }
    
    if (m > n) { /* Copy upper triangle of r to s */
        pr = r;	/* pointer to r(1:j,j) */
        ps = s;	/* pointer to s(1:j,j) */
        for (j=0; j < n; j++) {
            for(i=0; i <= j; i++) {
                *ps++ = *pr++;
            }
            pr += m-j-1;
            ps += n-j-1;
        }
    } else { /* Zero strict lower triangle of r */
        pr = r + (m-1)*m - 1; /* pointer to r(j:end,j-1) */
        for(j=m-1; j-->0; ) {
            for(i=m; i-- > j+1; ) {
                *pr-- = Zero;
            }
            pr -= (j+1);
        }
    }
    
    /* form permutation vector e */
    pe = e;			/* pointer to e(j) */
    pjpvt = jpvt;	/* pointer to jpvt(j) */
    for (j=n; j-- > 0; ) {
        *pe++ = (real_T)(*pjpvt++) + 1;
    }
    
    /*
    * At this point, MATLAB checks whether Q and R have all-zero
    * imaginary parts in which case it frees that memory.
    * Is there an S-Function equivalent?
    */
}


/*
* Compute the economy-sized qr of m-by-n input A:
* MATLAB command: [Q,R,E] = qr(A,0);
* Q is m-by-min(m,n), R is min(m,n)-by-n and E is 1-by-n
* Q and R have the complexity of A; E is always real.
* qraux and work are length n and have A's complexity.
* If m>n then A is copied to m-by-n work matrix S and
* at the end its n-by-n upper triangle is copied to R.
* If m<=n then A is copied directly to m-by-n output R
* and work matrix S need not be allocated.
*/
static void mdlOutputs(SimStruct *S, int_T tid)
{
    boolean_T cA	= (boolean_T)(ssGetInputPortComplexSignal(S,INPORT_A) == COMPLEX_YES);
    const int_T N	= (int_T)(*(mxGetPr(N_ARG)));
    int_T MN		= ssGetInputPortWidth(S, INPORT_A);
    const int_T M	= MN / N;
    
    const boolean_T need_copy = (boolean_T)(ssGetInputPortBufferDstPort(S, INPORT_A) != OUTPORT_R);
    {
        if (need_copy) {
            if (cA) {
                InputPtrsType pA = ssGetInputPortSignalPtrs(S, INPORT_A);
                if (M > N) {
                    creal_T *pS = (creal_T *)(ssGetDWork(S, S_IDX));
                    while(MN-- > 0) {
                        *pS++ = *((creal_T *)(*pA++));
                    }
                } else {
                    creal_T *pR = (creal_T *)(ssGetOutputPortSignal(S, OUTPORT_R));
                    while(MN-- > 0) {
                        *pR++ = *((creal_T *)(*pA++));
                    }
                }
            } else {
                InputRealPtrsType pA = ssGetInputPortRealSignalPtrs(S, INPORT_A);
                if (M > N) {
                    real_T *pS = (real_T *)(ssGetDWork(S, S_IDX));
                    while(MN-- > 0) {
                        *pS++ = **pA++;
                    }
                } else {
                    real_T *pR = (real_T *)(ssGetOutputPortSignal(S, OUTPORT_R));
                    while(MN-- > 0) {
                        *pR++ = **pA++;
                    }
                }
            }
        }
    }
    
    /* Compute the qr factorization */
    {
        void  *pQ     = ssGetOutputPortSignal(S, OUTPORT_Q);
        void  *pR     = ssGetOutputPortSignal(S, OUTPORT_R);
        void  *pE     = ssGetOutputPortSignal(S, OUTPORT_E);
        void  *pqraux = ssGetDWork(S, QRAUX_IDX);
        void  *pwork  = (creal_T *)ssGetDWork(S, WORK_IDX);
        int_T *pjpvt  = ssGetIWork(S);
        void  *pS     = (M > N) ? ssGetDWork(S, S_IDX) : (void *)0;
        

        /* Reset the pivot indices: */
        memset(pjpvt, 0, N * sizeof(int_T));

        if (cA) {
            if (M > N) {
                sdspqre_cplx(M, N, (creal_T *)pQ, (creal_T *)pS, (real_T *)pE,
                    (creal_T *)pqraux, (creal_T *)pwork, pjpvt, (creal_T *)pR);
            } else {
                sdspqre_cplx(M, N, (creal_T *)pQ, (creal_T *)pR, (real_T *)pE,
                    (creal_T *)pqraux, (creal_T *)pwork, pjpvt, (creal_T *)pS);
            }
        } else {
            if (M > N) {
                sdspqre_real(M, N, (real_T *)pQ, (real_T *)pS, (real_T *)pE,
                    (real_T *)pqraux, (real_T *)pwork, pjpvt, (real_T *)pR);
            } else {
                sdspqre_real(M, N, (real_T *)pQ, (real_T *)pR, (real_T *)pE,
                    (real_T *)pqraux, (real_T *)pwork, pjpvt, (real_T *)pS);
            }
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
    int_T M, N, P, pW;
    
    
    ssSetInputPortWidth( S, port, portWidth);
    
    N = (int_T)(mxGetPr(N_ARG)[0]);
    M = portWidth / N;
    if (M*N != portWidth) {
        THROW_ERROR(S, "Invalid port width.");
    }
    
    P = MIN(M,N);
    
    pW = ssGetOutputPortWidth(S, OUTPORT_Q);
    if (pW == DYNAMICALLY_SIZED) {
        ssSetOutputPortWidth(S, OUTPORT_Q, M*P);
    } else if (pW != M*P) {
        THROW_ERROR(S, "Invalid port width.");
    } /* else { OUTPORT_Q was already set to the correct portWidth } */
    
    
    pW = ssGetOutputPortWidth(S, OUTPORT_R);
    if (pW == DYNAMICALLY_SIZED) {
        ssSetOutputPortWidth(S, OUTPORT_R, P*N);
    } else if (pW != P*N) {
        THROW_ERROR(S, "Invalid port width.");
    } /* else { OUTPORT_R was already set to the correct portWidth } */
    
}

# define MDL_SET_OUTPUT_PORT_WIDTH
static void mdlSetOutputPortWidth(SimStruct *S, int_T port,
                                  int_T portWidth)
{
    int_T M, N, MN, P, pWR, pWQ;
    
    
    ssSetOutputPortWidth(S, port, portWidth);
    
    N = (int_T)(*(mxGetPr(N_ARG)));
    
    if (port == OUTPORT_Q) {
        
        if ((MN = ssGetInputPortWidth(S, INPORT_A)) == DYNAMICALLY_SIZED) {
            pWR = ssGetOutputPortWidth(S, OUTPORT_R);
            if (pWR == DYNAMICALLY_SIZED) {
                M = portWidth / N;
                if (M*N != portWidth) {
                    M = (int_T)(sqrt((real_T)portWidth));
                    if (M*M != portWidth) {
                        THROW_ERROR(S, "Invalid port widths.");
                    }
                }
                P = MIN(M,N);
                ssSetOutputPortWidth(S, OUTPORT_R, P*N);
            } else {
                P = pWR / N;
                if (P*N != pWR) {
                    THROW_ERROR(S, "Invalid port widths.");
                }
                M = portWidth / P;
                if (P*M != portWidth) {
                    THROW_ERROR(S, "Invalid port widths.");
                }
            }
            ssSetInputPortWidth(S, INPORT_A, M*N);
        } else {
            M = MN / N;
            P = MIN(M,N);
            if ((M*N != MN) || (M*P != portWidth)) {
                THROW_ERROR(S, "Invalid port widths.");
            }
            pWR = ssGetOutputPortWidth(S, OUTPORT_R);
            if (pWR == DYNAMICALLY_SIZED) {
                ssSetOutputPortWidth(S, OUTPORT_R, P*N);
            } else if (pWR != P*N) {
                THROW_ERROR(S, "Invalid port widths.");
            }
        }
        
    } else if (port == OUTPORT_R) {
        
        P = portWidth / N;
        if (P*N != portWidth) {
            THROW_ERROR(S, "Invalid port widths.");
        }
        MN = ssGetInputPortWidth(S, INPORT_A);
        if ((pWQ = ssGetOutputPortWidth(S, OUTPORT_Q)) == DYNAMICALLY_SIZED) {
            if (MN == DYNAMICALLY_SIZED) {
                if (P != N) {
                    M = P;
                    ssSetInputPortWidth(S, INPORT_A, M*N);
                    ssSetOutputPortWidth(S, OUTPORT_Q, M*P);
                }
            } else {
                M = MN / N;
                if ((M*N != MN) || (P != MIN(M,N))) {
                    THROW_ERROR(S, "Invalid port widths.");
                }
                ssSetOutputPortWidth(S, OUTPORT_Q, M*P);
            }
        } else {
            M = pWQ / P;
            if ((M*P != pWQ) || (P != MIN(M,N))) {
                THROW_ERROR(S, "Invalid port widths.");
            }
            if (MN == DYNAMICALLY_SIZED) {
                ssSetInputPortWidth(S, INPORT_A, M*N);
            } else if (M*N != MN) {
                THROW_ERROR(S, "Invalid port widths.");
            }
        }
        
    } else {
        THROW_ERROR(S, "Invalid port number for output port width propagation.");
    }
}


#define MDL_SET_WORK_WIDTHS
static void mdlSetWorkWidths(SimStruct *S)
{
    const int_T N = (int_T)(*(mxGetPr(N_ARG)));
    const int_T MN = ssGetInputPortWidth( S, INPORT_A);
    const int_T M =  MN / N;
    const int_T N_DWORKS = (M > N) ? MAX_NUM_DWORKS : MAX_NUM_DWORKS-1;
    CSignal_T Cplx = ssGetInputPortComplexSignal(S, INPORT_A);
    
    if(!ssSetNumDWork(      S, N_DWORKS)) return;
    
    ssSetDWorkWidth(        S, QRAUX_IDX, N);
    ssSetDWorkDataType(     S, QRAUX_IDX, SS_DOUBLE);
    ssSetDWorkComplexSignal(S, QRAUX_IDX, Cplx);
    
    ssSetDWorkWidth(        S, WORK_IDX, N);
    ssSetDWorkDataType(     S, WORK_IDX, SS_DOUBLE);
    ssSetDWorkComplexSignal(S, WORK_IDX, Cplx);
    
    if (N_DWORKS == MAX_NUM_DWORKS) {
        ssSetDWorkWidth(        S, S_IDX, MN);
        ssSetDWorkDataType(     S, S_IDX, SS_DOUBLE);
        ssSetDWorkComplexSignal(S, S_IDX, Cplx);
    }
}
#endif


#include "dsp_trailer.c"

/* [EOF] sdspqre.c */
