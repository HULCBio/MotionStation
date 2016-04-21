/*
 *  QRESLV_Z_RT Helper function for QR decomposition.
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.1.2.2 $  $Date: 2004/04/12 23:48:01 $
 */
#include "dspqrdc_rt.h"

/*
 * MWDSP_qrsl2Z - use the qr factorization of a stored in qr and qraux
 * to operate on input b and compute q'*b and the solution x to
 * min(norm(b-q*r*x)) = min(norm(q'*b-r*x)) in place over b.
 *
 * a and its qr factorization stored in qr and qraux are complex;
 * b is complex.
 */
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
EXPORT_FCN void MWDSP_qreslvZ(
                int_T    m,
                int_T    n,
			    int_T    p,
                creal_T  *qr,
                creal_T  *bx,
                creal_T  *qraux,
                int_T    *jpvt,
                creal_T  *x,
                real_T    epsval)
{
    int_T   i, j, k, minmn, maxmn, pjj;
    real_T  t, tol;
    creal_T *pbx, ctmp, Zero = {0.0, 0.0};
    
    
    minmn = MIN(m,n);
	maxmn = MAX(m,n);
    k = -1;
    t = CQABS(*qr);
    tol = ((real_T) maxmn) * epsval * t;
    for (j=0; j<minmn; j++) {
        pjj = j * (m + 1);
        t = CQABS(*(qr+pjj));
        if (t > tol) {
            k = j;
        }
    }
    
    k++;

	for (i=0; i<p; i++) {
	    /* Only use the first k columns of the qr factorization */
	    MWDSP_qrsl2Z(m, k, qr, qraux, bx+i*maxmn);
	}
    
	for(i=0; i<p; i++) {
	    /* Zero the remaining n-k entries of the solution */
	    pbx = bx + i*maxmn + k;
	    for (j=n-k; j-- > 0; ) {
	        *pbx++ = Zero;
	    }
	}

	/* swap columns according to jpvt */
    for (j=0; j<n; j++) {		
        k = jpvt[j];
        while (k != j) {
			for(i=0; i<p; i++) {
				ctmp = *(bx+i*maxmn+j);
				*(bx+i*maxmn+j) = *(bx+i*maxmn+k);
				*(bx+i*maxmn+k) = ctmp;
			}
			jpvt[j] = jpvt[k];
            jpvt[k] = k;
            k = jpvt[j];
        }
    }
    
    if (m>n) { /* Copy the first n entries of bx to x */
        creal_T *px = x;
        
		for(j=0; j<p; j++) {
	        pbx = bx + j*maxmn;
	        for(i=n; i-- >0; ) {
	            *px++ = *pbx++;
	        }
		}
    }
}

/* [EOF] qreslv_z_rt.c */


