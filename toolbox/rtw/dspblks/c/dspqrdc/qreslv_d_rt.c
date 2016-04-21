/*
 *  QRESLV_D_RT Helper function for QR decomposition.
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.2.2.2 $  $Date: 2004/04/12 23:47:57 $
 */
#include "dspqrdc_rt.h"

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

/*
* sdspqreslv accepts the qr factorization of a in qr, qraux and jpvt
* and a copy of b in bx and computes a minimum norm residual
* solution x to a*x=b in place in bx.
* If m>n, the first n entries of bx are copied to x at the end.
* Note: b, and hence x, may have more than one column.
*/

EXPORT_FCN void MWDSP_qreslvD(
                int_T	 m,
                int_T	 n,
			    int_T	 p,
                real_T	*qr,
                real_T	*bx,
                real_T	*qraux,
                int_T	*jpvt,
                real_T	*x,
                real_T   epsval)
{
    int_T   i, j, k, minmn, maxmn, pjj;
    real_T  t, tol, *pbx, tmp, Zero = 0.0;
    
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
	    MWDSP_qrsl2D(m, k, qr, qraux, bx+i*maxmn);
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
				tmp = *(bx+i*maxmn+j);
				*(bx+i*maxmn+j) = *(bx+i*maxmn+k);
				*(bx+i*maxmn+k) = tmp;
			}
			jpvt[j] = jpvt[k];
            jpvt[k] = k;
            k = jpvt[j];
        }
    }
    
    if (m>n) { /* Copy the first n entries of bx to x */
        real_T *px = x;
        
		for(j=0; j<p; j++) {
	        pbx = bx + j*maxmn;
	        for(i=n; i-- >0; ) {
	            *px++ = *pbx++;
	        }
		}
    }
}

/* [EOF] qreslv_d_rt.c */

