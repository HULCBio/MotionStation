/* 
 *  QRDC_D_RT Helper function for QR Factorization.
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.2.2.2 $  $Date: 2004/04/12 23:47:53 $
 */

#include "dspqrdc_rt.h"

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

EXPORT_FCN void MWDSP_QRE_D(int_T m, int_T n, real_T *q, real_T *r, real_T *e,
        real_T *qraux, real_T *work, int_T *jpvt, real_T *s)
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

/* [EOF] qre_d_rt.c */


