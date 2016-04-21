/* 
 *  QRDC_D_RT Helper function for QR decomposition.
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.10.2.2 $  $Date: 2004/04/12 23:47:49 $
 */

#include "dspqrdc_rt.h"

/*
 * Vector 2-norm, complex:
 */

static void MWDSP_qrV2normD(
    real_T	*V,
    int_T	N,
    real_T	*v2norm
    )
{
    real_T nrm = 0.0;
    real_T *vi = V;
    
    while(N--) {
        CHYPOT(nrm, *vi, nrm); 
		vi++;
    }
	*v2norm = nrm;
}

/*
 * Compute the qr factorization of an m by n matrix x.
 * Information needed for the orthogonal matrix q is
 * overwritten in the lower triangle of x and in the
 * auxilliary array qraux.
 * r overwrites the upper triangle of x and its diagonal
 * entries are guaranteed to decrease in magnitude.
 * Column pivot information is stored in jpvt.
 */

EXPORT_FCN void MWDSP_qrdcD(
    int_T	m,		/* rows in x */
    int_T	n,		/* columns in x */
    real_T	*x,		/* input matrix */
    real_T	*qraux,	/* auxilliary vector */
    int_T	*jpvt,	/* pivot info */
    real_T	*work	/* work vector */
    )
{
	int_T	i, j, jp, l, maxj, pl, pu, mml, *jpvtp, swapj;
	real_T	t, nrmxl, maxnrm, tt, tmp, *px, *px2, tst;
	int_T	p1k, p1j, p1l, pll, plj;

	pl =  0;
	pu = -1;

	/*
	 * Rearrange the columns according to jpvt.
	 */
	for (j=0; j<n; j++) {
		jpvtp = &jpvt[j];	/* pointer to jpvt[j] */
		swapj = (*jpvtp > 0);
		*jpvtp = (*jpvtp < 0) ? -j : j;
		if (swapj) {
			if (j != pl) {
				/* Swap columns pl and j */
				p1k = pl * m;	/* offset for x(1,pl) */
				p1j = j  * m;	/* offset for x(1,j)  */
				px = x + p1k;
				px2 = x + p1j;
				for(i=m; i-- > 0; ) {
					tmp = *px;
					*px = *px2;
					*px2 = tmp;
					px++;
					px2++;
				}
			}
			*jpvtp = jpvt[pl];
			jpvt[pl++] = j;
		}
	}
	pu = n - 1;
	for (j=pu; j>=0; j--) {
		if (*(jpvtp = &jpvt[j]) < 0) {
			*jpvtp = -*jpvtp;
			if (j != pu) {
				/* Swap columns pu and j */
				p1k = pu * m;	/* offset for x(1,pu) */
				p1j = j  * m;	/* offset for x(1,j)  */
				px = x + p1k;
				px2 = x + p1j;
				for(i=m; i-- > 0; ) {
					tmp = *px;
					*px = *px2;
					*px2 = tmp;
					px++;
					px2++;
				}
				jp = jpvt[pu];
				jpvt[pu] = *jpvtp;
				*jpvtp = jp;
			}
			pu--;
		}
	}

	/*
	 * compute the norms of the free columns
	 */
	for (j=pl; j<=pu; j++) {
		p1j = j * m;		/* offset for x(1,j)  */
		MWDSP_qrV2normD(x+p1j, m, &tmp);
		work[j] = qraux[j] = tmp;
	}

	/*
	 * perform the householder reduction of x
	 */
	for (l=0; l< MIN(m,n); l++) {
        mml = m - l;
		/*
		 * locate the column of largest
		 * norm and bring it into the pivot position
		 */
		if (l >= pl && l < pu) {
			maxnrm = 0.0;
			maxj = l;
			for (j=l; j<=pu; j++) {
				if (qraux[j] > maxnrm) {
					maxnrm = qraux[j];
					maxj = j;
				}
			}

			if (maxj != l) {
				/* Swap columns l and maxj */
				p1l = l * m;	/* offset for x(1,l)  */
				p1j = maxj * m;	/* offset for x(1,maxj)  */
				px = x + p1l;
				px2 = x + p1j;

                for(i=m; i-- > 0; ) {
					tmp = *px;
					*px = *px2;
					*px2 = tmp;
					px++;
					px2++;
				}
				qraux[maxj] = qraux[l];
				work[maxj]  = work[l];
				jp = jpvt[maxj];
				jpvt[maxj] = jpvt[l];
				jpvt[l] = jp;
			}
		}
		qraux[l] = 0.0;

        if (l == (m-1)) {
			continue;
		}

        /*
		 * compute the householder transformation for column l
		 */
		pll = l * (m + 1);		/* offset for x(l,l)  */
		px = x + pll;			/* pointer to x(l,l) */
		MWDSP_qrV2normD(px, mml, &nrmxl);
		if (fabs(nrmxl) == 0.0) {
			continue;
		}
		if (fabs(*px) != 0.0) {
			/* nrmxl = nrmxl * sign(*px) */
			nrmxl = (*px >= 0.0) ? fabs(nrmxl) : -fabs(nrmxl);
		}
		px2 = px;
		tst = 5.0e-20 * nrmxl;
		if (tst != 0.0) {
			tmp = 1.0 / nrmxl;
			for(i=mml; i-- > 0; ) {
				*px2 *= tmp;
				px2++;
			}
		} else {
			for(i=mml; i-- > 0; ) {
				*px2 /= nrmxl;
				px2++;
			}
		}

		*px += 1.0;

		/* 
		 * apply the transformation to the remaining 
		 * columns, updating the norms.
		 */
		for (j=l+1; j<n; j++) {
			plj = j * m + l;	/* offset for x(l,j)  */
			px2 = x + plj;		/* pointer to x(l,j) */
			t = 0.0;
			for(i=mml; i-- > 0; ) {
				t -= (*px) * (*px2);
				px++;
				px2++;
			}
			px = x + pll;	/* reset px to pointer to x(l,l) */
			px2 = x + plj;	/* reset px2 to pointer to x(l,j) */
			t /= *px;
			for(i=mml; i-- > 0; ) {
				*px2 += t * (*px);
				px++;
				px2++;
			}
			px = x + pll;	/* reset px to pointer to x(l,l) */
			px2 = x + plj;	/* reset px2 to pointer to x(l,j) */
			if (j < pl || j > pu || fabs(qraux[j]) == 0.0) {
				continue;
			}
			tt = 1.0 - pow((fabs(*px2) / qraux[j]), 2.0);
			if (tt < 0.0) tt = 0.0;
			t = tt;
			tt = 1.0 + 0.05 * tt * pow((qraux[j] / work[j]), 2.0);
			if (tt != 1.0) {
				tmp = sqrt(t);
				qraux[j] *= tmp;
			} else {
				MWDSP_qrV2normD(++px2, mml-1, &tmp);
				work[j] = qraux[j] = tmp;
			}
		}

		/*
		 * save the transformation.
		 */
		qraux[l] = *px;
		*px = -nrmxl;
	}
	return;
}


/* [EOF] qrdc_d_rt.c */
