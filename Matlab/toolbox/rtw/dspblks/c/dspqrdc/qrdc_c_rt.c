/* 
 *  QRDC_C_RT Helper function for QR decomposition.
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.2.2.2 $  $Date: 2004/04/12 23:47:48 $
 */

#include "dspqrdc_rt.h"

static void MWDSP_qrV2normC(
    creal32_T	*V,
    int_T	N,
    real32_T	*v2norm
    )
{
    real32_T nrm = 0.0F;
    creal32_T *vi = V;
    
    while(N--) {
        CHYPOT32(nrm, vi->re, nrm);
		CHYPOT32(nrm, vi->im, nrm);
        vi++;
    }
    *v2norm = nrm;
}

EXPORT_FCN void MWDSP_qrdcC(
    int_T		m,		/* rows in x */
    int_T		n,		/* columns in x */
    creal32_T	*x,		/* input matrix */				
    creal32_T	*qraux,	/* auxilliary vector */
    int_T		*jpvt,	/* pivot info */
    creal32_T	*work	/* work vector */
    )
{
	int_T	i, j, jp, l, maxj, pl, pu, mml, *jpvtp, swapj;
	creal32_T	t, nrmxl, ctmp, ctmp2, *px, *px2, tst;
	creal32_T	Zero={0.0F, 0.0F}, One={1.0F, 0.0F};
	real32_T	maxnrm, tt, tmp, tmp2;
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
		MWDSP_qrV2normC(x+p1j, m, &tmp);
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
		MWDSP_qrV2normC(px, mml, &nrmxl.re);
		nrmxl.im = 0.0;
		if (CQABS32(nrmxl) == 0.0) {
			continue;
		}
		if (CQABS32(*px) != 0.0) {
			/* nrmxl = nrmxl * sign(*px) */
			CABS32(*px,tmp);
			if (tmp != 0.0) {
				CABS32(nrmxl,tmp2);
				tmp = tmp2 / tmp;
				nrmxl.re = px->re * tmp;
				nrmxl.im = px->im * tmp;
			} else {
				nrmxl.re = FABS32(nrmxl.re);
			}
		}

		/*
		 * Check if it's safe to multiply by 1/nrmxl
		 * instead of dividing by nrmxl
		 */
		px2 = px;
		tst.re = (real32_T)5.0e-20 * nrmxl.re;
		tst.im = (real32_T)5.0e-20 * nrmxl.im;
		if ((tst.re != 0.0F) | (tst.im != 0.0F)) {
			CDIV32(One, nrmxl, ctmp);
			for(i=mml; i-- > 0; ) {
				ctmp2.re = CMULT_RE(*px2, ctmp);
				ctmp2.im = CMULT_IM(*px2, ctmp);
				*px2++ = ctmp2;
			}
		} else {
			for(i=mml; i-- > 0; ) {
				CDIV32(*px2, nrmxl, *px2);
				px2++;
			}
		}

		px->re += 1.0F;

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
			CDIV32(t,*px,t);
			for(i=mml; i-- > 0; ) {
				px2->re += CMULT_RE(t, *px);
				px2->im += CMULT_IM(t, *px);
				px++;
				px2++;
			}
			px = x + pll;	/* reset px to pointer to x(l,l) */
			px2 = x + plj;	/* reset px2 to pointer to x(l,j) */
			if (j < pl || j > pu || CQABS32(qraux[j]) == 0.0F) {
				continue;
			}
			CABS32(*px2,tmp);
			tt = 1.0F - (real32_T)pow((real_T)(tmp / qraux[j].re), 2.0F);
			if (tt < 0.0F) tt = 0.0F;
			t.re = tt;
			tt = 1.0F + 0.05F * tt * (real32_T)pow((real_T)(qraux[j].re / work[j].re), 2.0F);
			if (tt != 1.0) {
				tmp = (real32_T)sqrt((real_T)t.re);
				qraux[j].re *= tmp;
				qraux[j].im *= tmp;
			} else {
				MWDSP_qrV2normC(++px2, mml-1, &tmp);
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



/* [EOF] qrdc_c_rt.c */



