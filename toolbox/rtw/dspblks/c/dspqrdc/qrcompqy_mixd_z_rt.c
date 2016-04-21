/*
 *  QRCOMPQY_MIXD_Z_RT Helper function for QR decomposition.
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.4.2.2 $  $Date: 2004/04/12 23:47:45 $
 */

#include "dspqrdc_rt.h"

/*
 * MWDSP_qrCompqyMixdZ - compute q*y or q'*y in place over y
 */
EXPORT_FCN void MWDSP_qrCompqyMixdZ(
    int_T	n,
    int_T	j,
    real_T	*qr,
    real_T	*qrauxj,
    creal_T	*y
    )
{
    if (fabs(*qrauxj) != 0.0) {
        int_T	nmj, i, pjj;
        real_T	temp, *pqr;
        creal_T	t, *py, Zero = {0.0, 0.0};
	nmj  = n - j;
	pjj  = j*(n+1);	/* offset for x(j,j) */
	pqr  = qr + pjj;	/* pointer to x(j,j) */
	temp = *pqr;
	*pqr  = *qrauxj;
	t = Zero;
	py = y;
	for(i=nmj; i-- > 0; ) {
	    t.re -= *pqr * py->re;
	    t.im -= *pqr * py->im;
	    pqr++;
	    py++;
	}
	pqr = qr + pjj;	/* reset to pointer to x(j,j) */
	t.re /= *pqr;
	t.im /= *pqr;
	py = y;
	for(i=nmj; i-- > 0; ) {
	    py->re += t.re * *pqr;
	    py->im += t.im * *pqr;
	    pqr++;
	    py++;
	}
	pqr = qr + pjj;	/* reset to pointer to x(j,j) */
	*pqr = temp;
    }
}

/* [EOF] qrcompqy_mixd_z_rt.c */


