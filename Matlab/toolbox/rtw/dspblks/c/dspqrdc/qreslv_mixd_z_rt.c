/*
 *  QRESLV_MIXD_Z_RT Helper function for QR decomposition.
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.2.2.2 $  $Date: 2004/04/12 23:47:59 $
 */
#include "dspqrdc_rt.h"

/*
 * MWDSP_qrsl2MixdZ - use the qr factorization of a stored in qr and qraux
 * to operate on input b and compute q'*b and the solution x to
 * min(norm(b-q*r*x)) = min(norm(q'*b-r*x)) in place over b.
 *
 * a and its qr factorization stored in qr and qraux are real;
 * b is complex.
 */

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


EXPORT_FCN void MWDSP_qreslvMixdZ(
                    int_T	 m,
                    int_T	 n,
			        int_T	 p,
                    real_T      *qr,
                    creal_T     *bx,
                    real_T	*qraux,
                    int_T	*jpvt,
                    creal_T     *x,
                    real_T epsval)
{
    int_T   i, j, k, minmn, maxmn, pjj;
    real_T  t, tol;
    creal_T *pbx, ctmp, Zero = {0.0, 0.0};
    
    
    minmn = MIN(m,n);
	maxmn = MAX(m,n);
    k = -1;
    t = fabs(*qr);
    tol = ((real_T) maxmn) * epsval * t;
    for (j=0; j<minmn; j++) {
        pjj = j * (m + 1);
        t = fabs(*(qr+pjj));
        if (t > tol) {
            k = j;
        }
    }
    
    k++;
	for (i=0; i<p; i++) {
	    /* Only use the first k columns of the qr factorization */
	    MWDSP_qrsl2MixdZ(m, k, qr, qraux, bx+i*maxmn);
	}
    
	for(i=0; i<p; i++) {
	    /* Zero the remaining n-k entries of the solution */
	    pbx = bx + i*maxmn + k;
	    for (j=n-k; j-- > 0; ) {
	        *pbx++ = Zero;
	    }
	}

	/* swap rows of solution according to matrix column pivot jpvt */
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

/* [EOF] qreslv_mixd_z_rt.c */


