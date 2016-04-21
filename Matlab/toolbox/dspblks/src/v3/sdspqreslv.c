/*
* File: sdspqreslv.c
*
* Abstract:
*      DSP Blockset S-function for QR Solve.
*
* Copyright 1995-2002 The MathWorks, Inc.
* $Revision: 1.24 $ $Date: 2002/04/14 20:44:49 $
*/
#define S_FUNCTION_NAME  sdspqreslv
#define S_FUNCTION_LEVEL 2

#define DATA_TYPES_IMPLEMENTED

#include "dsp_sim.h"
#include "dspqrdc_rt.h"

enum {QRAUX_IDX=0, WORK_IDX, QR_IDX, BX_IDX, MAX_NUM_DWORKS};
enum {JPVT_IDX, NUM_IWORKS};
enum {INPORT_A=0, INPORT_B, NUM_INPORTS};
enum {OUTPORT_X=0, NUM_OUTPORTS};
enum {NUM_PARAMS=0};


static void mdlInitializeSizes(SimStruct *S)
{
    /* Still need this, even though NUM_PARAMS is 0? */
    ssSetNumSFcnParams(S, NUM_PARAMS);
    
#if defined(MATLAB_MEX_FILE)
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) return;
    if (ssGetErrorStatus(S) != NULL) return;
#endif
    
    if (!ssSetNumInputPorts(S, NUM_INPORTS)) return;
    
    ssSetInputPortWidth(            S, INPORT_A, DYNAMICALLY_SIZED);
    ssSetInputPortDirectFeedThrough(S, INPORT_A, 1);
    ssSetInputPortComplexSignal(    S, INPORT_A, COMPLEX_INHERITED);
    ssSetInputPortReusable(        S, INPORT_A, 1);
    ssSetInputPortOverWritable(     S, INPORT_A, 1);
    ssSetInputPortDataType(         S, INPORT_A, SS_DOUBLE);
    
    ssSetInputPortWidth(            S, INPORT_B, DYNAMICALLY_SIZED);
    ssSetInputPortDirectFeedThrough(S, INPORT_B, 1);
    ssSetInputPortComplexSignal(    S, INPORT_B, COMPLEX_INHERITED);
    ssSetInputPortReusable(        S, INPORT_B, 1);
    ssSetInputPortOverWritable(     S, INPORT_B, 1);
    ssSetInputPortDataType(         S, INPORT_B, SS_DOUBLE);
    
    if (!ssSetNumOutputPorts(S, NUM_OUTPORTS)) return;
    
    ssSetOutputPortWidth(        S, OUTPORT_X, DYNAMICALLY_SIZED);
    ssSetOutputPortComplexSignal(S, OUTPORT_X, COMPLEX_INHERITED);
    ssSetOutputPortReusable(    S, OUTPORT_X, 1);
    ssSetOutputPortDataType(     S, OUTPORT_X, SS_DOUBLE);
    
    if(!ssSetNumDWork(S, DYNAMICALLY_SIZED)) return;
    
    ssSetNumIWork(S, DYNAMICALLY_SIZED);
    
    ssSetNumSampleTimes(S, 1);
    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE);
}


static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, 0.0);
}

/*
 * MWDSP_qrsl2D - use the qr factorization of a stored in qr and qraux
 * to operate on input b and compute q'*b and the solution x to
 * min(norm(b-q*r*x)) = min(norm(q'*b-r*x)) in place over b.
 *
 * a and its qr factorization stored in qr and qraux are real;
 * b is real.
 */

static int_T MWDSP_qrsl2D(
    int_T	n,
    int_T	k,
    real_T	*qr,
    real_T	*qraux,
    real_T	*b
    )
{
	int_T	i, j, ju, info=0;
	real_T	t, *pqr, *pqraux, *pb, *pbj;

	ju = MIN(k,n-1);

	/* special action when n=1 */
	if (ju == 0) {
	    if (fabs(*qr) == 0.0) {
		info = 1;
	    }
	    else {
		*b /= *qr;
	    }
	    return(info);
	}

	/* compute q'*b in place over b */
	pqraux = qraux;
	pb = b;
	for (j=0; j<ju; j++) {
	    MWDSP_qrCompqyD(n, j, qr, pqraux++, pb++);
	}

	/* compute x, solution to min(norm(b-a*x)), in place over b */
	pbj = b + k-1;	/* pointer to b(j) */
	for (j=k-1; j>=0; j--) {
		pqr = qr + j * (n + 1);	/* pointer to qr(j,j) */
		if (fabs(*pqr) == 0.0){
			info = j + 1;
			break;
		}
		*pbj /= *pqr;
		if (j != 0) {
			t = -*pbj;
			pb = b;
			pqr -= j;
			for(i=j; i-- > 0; ) {
				*pb++ += t * *pqr++;
			}
		}
		pbj--;
	}

	return(info);
}

static int_T MWDSP_qrsl2MixdZ(
    int_T	n,
    int_T	k,
    real_T	*qr,
    real_T	*qraux,
    creal_T	*b
    )
{
	int_T	i, j, ju, info=0;
	real_T	*pqr, *pqraux;
	creal_T	t, *pb, *pbj;


	ju = MIN(k,n-1);

	/* special action when n=1 */
	if (ju == 0) {
		if (fabs(*qr) == 0.0) {
			info = 1;
		}
		else {
			b->re /= *qr;
			b->im /= *qr;
		}
		return(info);
	}

	/* compute q'*b in place over b */
	pqraux = qraux;
	pb = b;
	for (j=0; j<ju; j++) {
		MWDSP_qrCompqyMixdZ(n, j, qr, pqraux++, pb++);
	}

	/* compute x, solution to min(norm(b-a*x)), in place over b */
	pbj = b + k-1;	/* pointer to b(j) */
	for (j=k-1; j>=0; j--) {
		pqr = qr + j * (n + 1);	/* pointer to qr(j,j) */
		if (fabs(*pqr) == 0.0){
			info = j + 1;
			break;
		}
		pbj->re /= *pqr;
		pbj->im /= *pqr;
		if (j != 0) {
			t.re = -(pbj->re);
			t.im = -(pbj->im);
			pb = b;
			pqr -= j;
			for(i=j; i-- > 0; ) {
				pb->re += t.re * *pqr;
				pb->im += t.im * *pqr;
				pb++;
				pqr++;
			}
		}
		pbj--;
	}

	return(info);
}

static int_T MWDSP_qrsl2Z(
    int_T	n,
    int_T	k,
    creal_T	*qr,
    creal_T	*qraux,
    creal_T	*b
    )
{
	int_T	i, j, ju, info=0;
	creal_T	t, *pqr, *pqraux, *pb, *pbj;

	ju = MIN(k,n-1);

	/* special action when n=1 */
	if (ju == 0) {
		if (CQABS(*qr) == 0.0) {
			info = 1;
		}
		else {
			CDIV(*b, *qr, *b);
		}
		return(info);
	}

	/* compute q'*b in place over b */
	pqraux = qraux;
	pb = b;
	for (j=0; j<ju; j++) {
		MWDSP_qrCompqyZ(n, j, qr, pqraux++, pb++);
	}

	/* compute x, solution to min(norm(b-a*x)), in place over b */
	pbj = b + k-1; /* pointer to b(j) */
	for (j=k-1; j>=0; j--) {
		pqr = qr + j * (n + 1);	/* pointer to qr(j,j) */
		if (CQABS(*pqr) == 0.0){
			info = j + 1;
			break;
		}
		CDIV(*pbj, *pqr, *pbj);
		if (j != 0) {
			t.re = -(pbj->re);
			t.im = -(pbj->im);
			pb = b;
			pqr -= j;
			for(i=j; i-- > 0; ) {
				pb->re += CMULT_RE(t, *pqr);
				pb->im += CMULT_IM(t, *pqr);
				pb++;
				pqr++;
			}
		}
		pbj--;
	}

	return(info);
}
/*
* sdspqreslv accepts the qr factorization of a in qr, qraux and jpvt
* and a copy of b in bx and computes a minimum norm residual
* solution x to a*x=b in place in bx.
* If m>n, the first n entries of bx are copied to x at the end.
*/
static void sdspqreslv_real(
                            int_T	m,
                            int_T	n,
                            real_T *qr,
                            real_T	*bx,
                            real_T *qraux,
                            int_T	*jpvt,
                            real_T *x
                            )
{
    int_T   j, k, minmn, pjj;
    real_T  t, tol, *pbx, tmp, Zero = 0.0;
    
    
    k = -1;
    t = fabs(*qr);
    tol = ((real_T) MAX(m,n)) * mxGetEps() * t;
    minmn = MIN(m,n);
    for (j=0; j<minmn; j++) {
        pjj = j * (m + 1);
        t = fabs(*(qr+pjj));
        if (t > tol) {
            k = j;
        }
    }
    
    k++;
    
#ifdef MATLAB_MEX_FILE
    if (k < minmn) {
        char msg[256];
        sprintf(msg, "Rank deficient, rank=%d, tol=%13.4e",k,tol);
        mexWarnMsgTxt(msg);
    }
#endif
    
    /* Only use the first k columns of the qr factorization */
    MWDSP_qrsl2D(m, k, qr, qraux, bx);
    
    /* Zero the remaining n-k entries of the solution */
    pbx = bx + k;
    for (j=n-k; j-- > 0; ) {
        *pbx++ = Zero;
    }
    
    /* swap columns according to jpvt */
    for (j=0; j<n; j++) {		
        k = jpvt[j];
        while (k != j) {
            tmp = *(bx+j);
            *(bx+j) = *(bx+k);
            *(bx+k) = tmp;
            jpvt[j] = jpvt[k];
            jpvt[k] = k;
            k = jpvt[j];
        }
    }
    
    if (m>n) { /* Copy the first n entries of bx to x */
        real_T *px = x;
        
        pbx = bx;
        for(j=n; j-- >0; ) {
            *px++ = *pbx++;
        }
    }
    
}


static void sdspqreslv_cplx(
                            int_T   m,
                            int_T   n,
                            creal_T *qr,
                            creal_T *bx,
                            creal_T *qraux,
                            int_T   *jpvt,
                            creal_T *x
                            )
{
    int_T   j, k, minmn, pjj;
    real_T  t, tol;
    creal_T *pbx, ctmp, Zero = {0.0, 0.0};
    
    
    k = -1;
    t = CQABS(*qr);
    tol = ((real_T) MAX(m,n)) * mxGetEps() * t;
    minmn = MIN(m,n);
    for (j=0; j<minmn; j++) {
        pjj = j * (m + 1);
        t = CQABS(*(qr+pjj));
        if (t > tol) {
            k = j;
        }
    }
    
    k++;

#ifdef MATLAB_MEX_FILE
    if (k < minmn) {
        char msg[256];
        sprintf(msg, "Rank deficient, rank=%d, tol=%13.4e",k,tol);
        mexWarnMsgTxt(msg);
    }
#endif
    
    /* Only use the first k columns of the qr factorization */
    MWDSP_qrsl2Z(m, k, qr, qraux, bx);
    
    /* Zero the remaining n-k entries of the solution */
    pbx = bx + k;
    for (j=n-k; j-- > 0; ) {
        *pbx++ = Zero;
    }
    
    /* swap columns according to jpvt */
    for (j=0; j<n; j++) {		
        k = jpvt[j];
        while (k != j) {
            ctmp = *(bx+j);
            *(bx+j) = *(bx+k);
            *(bx+k) = ctmp;
            jpvt[j] = jpvt[k];
            jpvt[k] = k;
            k = jpvt[j];
        }
    }
    
    if (m>n) { /* Copy the first n entries of bx to x */
        creal_T *px = x;
        
        pbx = bx;
        for(j=n; j-- >0; ) {
            *px++ = *pbx++;
        }
    }
    
}


static void sdspqreslv_mixd(
                            int_T	 m,
                            int_T	 n,
                            real_T  *qr,
                            creal_T *bx,
                            real_T	 *qraux,
                            int_T	 *jpvt,
                            creal_T *x
                            )
{
    int_T   j, k, minmn, pjj;
    real_T  t, tol;
    creal_T *pbx, ctmp, Zero = {0.0, 0.0};
    
    
    k = -1;
    t = fabs(*qr);
    tol = ((real_T) MAX(m,n)) * mxGetEps() * t;
    minmn = MIN(m,n);
    for (j=0; j<minmn; j++) {
        pjj = j * (m + 1);
        t = fabs(*(qr+pjj));
        if (t > tol) {
            k = j;
        }
    }
    
    k++;
    
#ifdef MATLAB_MEX_FILE
    if (k < minmn) {
        char msg[256];
        sprintf(msg, "Rank deficient, rank=%d, tol=%13.4e",k,tol);
        mexWarnMsgTxt(msg);
    }
#endif
    
    /* Only use the first k columns of the qr factorization */
    MWDSP_qrsl2MixdZ(m, k, qr, qraux, bx);
    
    /* Zero the remaining n-k entries of the solution */
    pbx = bx + k;
    for (j=n-k; j-- > 0; ) {
        *pbx++ = Zero;
    }
    
    /* swap columns according to jpvt */
    for (j=0; j<n; j++) {		
        k = jpvt[j];
        while (k != j) {
            ctmp = *(bx+j);
            *(bx+j) = *(bx+k);
            *(bx+k) = ctmp;
            jpvt[j] = jpvt[k];
            jpvt[k] = k;
            k = jpvt[j];
        }
    }
    
    if (m>n) { /* Copy the first n entries of bx to x */
        creal_T *px = x;
        
        pbx = bx;
        for(j=n; j-- >0; ) {
            *px++ = *pbx++;
        }
    }
}

/*
* Compute the minimum norm residual solution X to A*X=B using
* the economy-sized qr (with col pivoting) of m-by-n input A:
* MATLAB equivalent:
* [Q,R,E] = qr(A,0);
* QTB = Q'*B;
* X(E,:) = R \ QTB(1:n);
* A is copied to DWORK QR.
* If m>n, B is copied to DWORK BX, X is computed in place
* and at the end its first n entries are copied to output X.
* If m<=n, B is copied to the first m entries of output X
* where X is computed in place.
*/
static void mdlOutputs(SimStruct *S, int_T tid)
{
    boolean_T cA = (boolean_T)(ssGetInputPortComplexSignal(S,INPORT_A) == COMPLEX_YES);
    boolean_T cB = (boolean_T)(ssGetInputPortComplexSignal(S,INPORT_B) == COMPLEX_YES);
    boolean_T cX = (cA || cB);
    int_T MN	 = ssGetInputPortWidth(S, INPORT_A);
    int_T M		 = ssGetInputPortWidth(S, INPORT_B);
    int_T N		 = ssGetOutputPortWidth(S, OUTPORT_X);
    
    
    /* Copy input A to DWORK QR to be overwritten by its QR factorization. */
    {
        if (cA) {
            InputPtrsType pA = ssGetInputPortSignalPtrs(S, INPORT_A);
            creal_T *pQR     = (creal_T *)(ssGetDWork(S, QR_IDX));
            
            while(MN-- > 0) {
                *pQR++ = *((creal_T *)(*pA++));
            }
        } else {
            InputRealPtrsType pA = ssGetInputPortRealSignalPtrs(S, INPORT_A);
            real_T *pQR          = (real_T *)(ssGetDWork(S, QR_IDX));
            
            while(MN-- > 0) {
                *pQR++ = **pA++;
            }
        }
    }
    
    /* May possibly overwrite INPORT_B with OUTPORT_X. */
    {
        boolean_T need_copy = (boolean_T)(ssGetInputPortBufferDstPort(S, INPORT_B) != OUTPORT_X);
        
        if (need_copy) {
            int_T i = M;
            
            if (cX) {
                creal_T *pBX = (creal_T *)((M>N) ? ssGetDWork(S, BX_IDX) : ssGetOutputPortSignal(S, OUTPORT_X));
                if (cB) { /* X is initialized to a complex copy of complex B */
                    InputPtrsType pB = ssGetInputPortSignalPtrs(S, INPORT_B);
                    
                    while(i-- > 0) {
                        *pBX++ = *((creal_T *)(*pB++));
                    }
                } else { /* X is initialized to a complex copy of real B */
                    InputRealPtrsType pB = ssGetInputPortRealSignalPtrs(S, INPORT_B);
                    
                    while(i-- > 0) {
                        pBX->re = *((real_T *)(*pB++));
                        pBX->im = 0.0;
                        pBX++;
                    }
                }
            } else { /* X is initialized to a real copy of real B */
                InputRealPtrsType pB = ssGetInputPortRealSignalPtrs(S, INPORT_B);
                real_T *pBX = (real_T *)((M>N) ? ssGetDWork(S, BX_IDX) : ssGetOutputPortSignal(S, OUTPORT_X));
                
                while(i-- > 0) {
                    *pBX++ = **pB++;
                }
            }
        }
    }
    
    /* Find a minimum norm residual solution to A*X=B. */
    {
        void  *pQR    = ssGetDWork(S, QR_IDX);
        void  *pBX    = (M>N) ? ssGetDWork(S, BX_IDX) : ssGetOutputPortSignal(S, OUTPORT_X);
        void  *pqraux = ssGetDWork(S, QRAUX_IDX);
        void  *pwork  = ssGetDWork(S, WORK_IDX);
        int_T *pjpvt  = ssGetIWork(S);
        void  *pX     = (M>N) ? ssGetOutputPortSignal(S, OUTPORT_X) : (void *)0;
        
        /* Reset the pivot indices: */
        memset(pjpvt, 0, N * sizeof(int_T));

        if (cA) {
            /* Overwrite QR with the complex qr factorization of complex A. */
            MWDSP_qrdcZ(M, N, (creal_T *)pQR,
                (creal_T *)pqraux, pjpvt, (creal_T *)pwork);
            /* A is complex => X is complex, even if B is real */
            sdspqreslv_cplx(M, N, (creal_T *)pQR, (creal_T *)pBX,
                (creal_T *)pqraux, pjpvt, (creal_T *)pX);
        } else {
            /* Overwrite QR with the real qr factorization of real A. */
            MWDSP_qrdcD(M, N, (real_T *)pQR,
                (real_T *)pqraux, pjpvt, (real_T *)pwork);
            if (cB) { /* A is real and B is complex => X is complex */
                sdspqreslv_mixd(M, N, (real_T *)pQR, (creal_T *)pBX,
                    (real_T *)pqraux, pjpvt, (creal_T *)pX);
            } else { /* A and B are both real => X is real */
                sdspqreslv_real(M, N, (real_T *)pQR, (real_T *)pBX,
                    (real_T *)pqraux, pjpvt, (real_T *)pX);
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
    int_T M, N, MN;
    
    ssSetInputPortWidth( S, port, portWidth);
    
    if (port == INPORT_A) {
        MN = portWidth;
        M = ssGetInputPortWidth(S, INPORT_B);
        N = ssGetOutputPortWidth(S, OUTPORT_X);
        if ((M != DYNAMICALLY_SIZED) && (N != DYNAMICALLY_SIZED)){
            /* M and N are known and must match MN */
            if (M*N != MN) {
                ssSetErrorStatus(S, "Invalid port widths.");
            }
        } else if (M != DYNAMICALLY_SIZED) {
            /* N is unknown and can be computed from M and MN */
            N = MN / M;
            if (M*N == MN) {
                ssSetOutputPortWidth(S, OUTPORT_X, N);
            } else {
                ssSetErrorStatus(S, "Invalid port widths.");
            }
        } else if (N != DYNAMICALLY_SIZED) {
            /* M is unknown and can be computed from N and MN */
            M = MN / N;
            if (M*N == MN) {
                ssSetInputPortWidth(S, INPORT_B, M);
            } else{
                ssSetErrorStatus(S, "Invalid port widths.");
            }
        } /* else { both M and N are unknown: can't do anything } */
    } else if (port == INPORT_B) {
        M = portWidth;
        MN = ssGetInputPortWidth(S, INPORT_A);
        N = ssGetOutputPortWidth(S, OUTPORT_X);
        if ((MN != DYNAMICALLY_SIZED) && (N != DYNAMICALLY_SIZED)){
            /* MN and N are known and must match M */
            if (M*N != MN) {
                ssSetErrorStatus(S, "Invalid port widths.");
            }
        } else if (N != DYNAMICALLY_SIZED) {
            /* MN is unknown and can be computed from M and N */
            ssSetInputPortWidth(S, INPORT_A, M*N);
        } else if (MN != DYNAMICALLY_SIZED) {
            /* N is unknown and can be computed from M and MN */
            N = MN / M;
            if (M*N == MN) {
                ssSetOutputPortWidth(S, OUTPORT_X, N);
            } else {
                ssSetErrorStatus(S, "Invalid port widths.");
            }
        } /* else { both MN and N are unknown: can't do anything } */
    } else {
        ssSetErrorStatus(S, "Invalid port number for input port width propagation.");
        return;
    }
    
    
}

# define MDL_SET_OUTPUT_PORT_WIDTH
static void mdlSetOutputPortWidth(SimStruct *S, int_T port,
                                  int_T portWidth)
{
    
    ssSetOutputPortWidth(S, port, portWidth);
    
    if (port == OUTPORT_X) {
        int_T N  = portWidth;
        int_T MN = ssGetInputPortWidth(S, INPORT_A);
        int_T M  = ssGetInputPortWidth(S, INPORT_B);
        
        if ((M != DYNAMICALLY_SIZED) && (MN != DYNAMICALLY_SIZED)) {
            /* M and MN are known and must match N */
            if (M*N != MN) {
                ssSetErrorStatus(S, "Invalid port widths.");
            }
        } else if (MN != DYNAMICALLY_SIZED) {
            /* M is unknown and can be computed from MN and N */
            M = MN / N;
            if (M*N == MN) {
                ssSetInputPortWidth(S, INPORT_B, M);
            } else {
                ssSetErrorStatus(S, "Invalid port widths.");
            }
        } else if (M != DYNAMICALLY_SIZED) {
            /* MN is unknown and can be computed from M and N */
            ssSetInputPortWidth(S, INPORT_A, M*N);
        } /* else { MN and M are both unknown: can't do anything } */
    } else {
        ssSetErrorStatus(S, "Invalid port number for output port width propagation.");
        return;
    }
}


#define MDL_SET_WORK_WIDTHS
static void mdlSetWorkWidths(SimStruct *S)
{
    const int_T M = ssGetInputPortWidth(S, INPORT_B);
    const int_T N = ssGetOutputPortWidth(S, OUTPORT_X);
    const int_T N_DWORKS = (M > N) ? MAX_NUM_DWORKS : MAX_NUM_DWORKS-1;
    CSignal_T cA = ssGetInputPortComplexSignal(S, INPORT_A);
    CSignal_T cX = (cA || ssGetInputPortComplexSignal(S, INPORT_B));
    
    if(!ssSetNumDWork(      S, N_DWORKS)) return;
    
    ssSetDWorkWidth(        S, QRAUX_IDX, N);
    ssSetDWorkDataType(     S, QRAUX_IDX, SS_DOUBLE);
    ssSetDWorkComplexSignal(S, QRAUX_IDX, cA);
    
    ssSetDWorkWidth(        S, WORK_IDX, N);
    ssSetDWorkDataType(     S, WORK_IDX, SS_DOUBLE);
    ssSetDWorkComplexSignal(S, WORK_IDX, cA);
    
    ssSetDWorkWidth(        S, QR_IDX, M*N);
    ssSetDWorkDataType(     S, QR_IDX, SS_DOUBLE);
    ssSetDWorkComplexSignal(S, QR_IDX, cA);
    
    if (N_DWORKS == MAX_NUM_DWORKS) {
        ssSetDWorkWidth(        S, BX_IDX, MAX(M,N));
        ssSetDWorkDataType(     S, BX_IDX, SS_DOUBLE);
        ssSetDWorkComplexSignal(S, BX_IDX, cX);
    }
    
    ssSetNumIWork(S, N);
    
}

#include "dsp_cplxhs21.c"

#endif

#include "dsp_trailer.c"

/* [EOF] sdspqreslv.c */
