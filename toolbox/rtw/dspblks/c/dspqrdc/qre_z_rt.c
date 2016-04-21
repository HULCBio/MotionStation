/* 
 *  QRDC_D_RT Helper function for QR decomposition.
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.2.2.2 $  $Date: 2004/04/12 23:47:55 $
 */

#include "dspqrdc_rt.h"

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

EXPORT_FCN void MWDSP_QRE_Z(int_T m, int_T n, creal_T *q, creal_T *r, real_T *e,
        creal_T *qraux, creal_T *work, int_T *jpvt, creal_T *s)
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

/* [EOF] qre_z_rt.c */

