/* 
 *  QRDC_Z_RT Helper function for QR decomposition.
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.4.2.2 $  $Date: 2004/04/12 23:47:51 $
 */

#include "dspqrdc_rt.h"

/*
 * Vector 2-norm, complex:
 */
static void MWDSP_qrV2normZ(
    creal_T	*V,
    int_T	N,
    real_T	*v2norm
    )
{
    real_T nrm = 0.0;
    creal_T *vi = V;
    
    while(N--) {
        CHYPOT(nrm, vi->re, nrm);
		CHYPOT(nrm, vi->im, nrm);
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
EXPORT_FCN void MWDSP_qrdcZ(
    int_T		m,		/* rows in x */
    int_T		n,		/* columns in x */
    creal_T	*x,		/* input matrix */				
    creal_T	*qraux,	/* auxilliary vector */
    int_T		*jpvt,	/* pivot info */
    creal_T	*work	/* work vector */
    )
{
	int_T	i, j, jp, l, maxj, pl, pu, mml, *jpvtp, swapj;
	creal_T	t, nrmxl, ctmp, ctmp2, *px, *px2, tst;
	creal_T	Zero={0.0, 0.0}, One={1.0, 0.0};
	real_T	maxnrm, tt, tmp, tmp2;
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
					ctmp = *px;
					*px = *px2;
					*px2 = ctmp;
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
					ctmp = *px;
					*px = *px2;
					*px2 = ctmp;
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
		MWDSP_qrV2normZ(x+p1j, m, &tmp);
		work[j].re = qraux[j].re = tmp;
		work[j].im = qraux[j].im = 0.0;
	}

	/*
	 * perform the householder reduction of x
	 */
	for (l=0; l<MIN(m,n); l++) {
		mml = m - l;

		/*
		 * locate the column of largest
		 * norm and bring it into the pivot position
		 */
		if (l >= pl && l < pu) {
			maxnrm = 0.0;
			maxj = l;
			for (j=l; j<=pu; j++) {
				if (qraux[j].re > maxnrm) {
					maxnrm = qraux[j].re;
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
					ctmp = *px;
					*px = *px2;
					*px2 = ctmp;
					px++;
					px2++;
				}
				qraux[maxj].re = qraux[l].re;
				work[maxj].re  = work[l].re;
				qraux[maxj].im = qraux[l].im;
				work[maxj].im = work[l].im;
				jp = jpvt[maxj];
				jpvt[maxj] = jpvt[l];
				jpvt[l] = jp;
			}
		}
		qraux[l] = Zero;

		if (l == (m-1)) {
			continue;
		}

		/*
		 * compute the householder transformation for column l
		 */
		pll = l * (m + 1);		/* offset for x(l,l)  */
		px = x + pll;			/* pointer to x(l,l) */
		MWDSP_qrV2normZ(px, mml, &nrmxl.re);
		nrmxl.im = 0.0;
		if (CQABS(nrmxl) == 0.0) {
			continue;
		}
		if (CQABS(*px) != 0.0) {
			/* nrmxl = nrmxl * sign(*px) */
			CABS(*px,tmp);
			if (tmp != 0.0) {
				CABS(nrmxl,tmp2);
				tmp = tmp2 / tmp;
				nrmxl.re = px->re * tmp;
				nrmxl.im = px->im * tmp;
			} else {
				nrmxl.re = fabs(nrmxl.re);
			}
		}

		/*
		 * Check if it's safe to multiply by 1/nrmxl
		 * instead of dividing by nrmxl
		 */
		px2 = px;
		tst.re = 5.0e-20 * nrmxl.re;
		tst.im = 5.0e-20 * nrmxl.im;
		if ((tst.re != 0.0) | (tst.im != 0.0)) {
			CDIV(One, nrmxl, ctmp);
			for(i=mml; i-- > 0; ) {
				ctmp2.re = CMULT_RE(*px2, ctmp);
				ctmp2.im = CMULT_IM(*px2, ctmp);
				*px2++ = ctmp2;
			}
		} else {
			for(i=mml; i-- > 0; ) {
				CDIV(*px2, nrmxl, *px2);
				px2++;
			}
		}

		px->re += 1.0;

		/* 
		 * apply the transformation to the remaining 
		 * columns, updating the norms.
		 */
		for (j=l+1; j<n; j++) {
			plj = j * m + l;	/* offset for x(l,j)  */
			px2 = x + plj;		/* pointer to x(l,j) */
			t = Zero;
			for(i=mml; i-- > 0; ) {
				t.re -= CMULT_XCONJ_RE(*px, *px2);
				t.im -= CMULT_XCONJ_IM(*px, *px2);
				px++;
				px2++;
			}
			px = x + pll;	/* reset px to pointer to x(l,l) */
			px2 = x + plj;	/* reset px2 to pointer to x(l,j) */
			CDIV(t,*px,t);
			for(i=mml; i-- > 0; ) {
				px2->re += CMULT_RE(t, *px);
				px2->im += CMULT_IM(t, *px);
				px++;
				px2++;
			}
			px = x + pll;	/* reset px to pointer to x(l,l) */
			px2 = x + plj;	/* reset px2 to pointer to x(l,j) */
			if (j < pl || j > pu || CQABS(qraux[j]) == 0.0) {
				continue;
			}
			CABS(*px2,tmp);
			tt = 1.0 - pow((tmp / qraux[j].re), 2.0);
			if (tt < 0.0) tt = 0.0;
			t.re = tt;
			tt = 1.0 + 0.05 * tt * pow((qraux[j].re / work[j].re), 2.0);
			if (tt != 1.0) {
				tmp = sqrt(t.re);
				qraux[j].re *= tmp;
				qraux[j].im *= tmp;
			} else {
				MWDSP_qrV2normZ(++px2, mml-1, &tmp);
				work[j].re = qraux[j].re = tmp;
				qraux[j].im = work[j].im  = 0.0;
			}
		}

		/*
		 * save the transformation.
		 */
		qraux[l] = *px;
		px->re = -nrmxl.re;
		px->im = -nrmxl.im;
	}

	return;
}

/* [EOF] qrdc_z_rt.c */
