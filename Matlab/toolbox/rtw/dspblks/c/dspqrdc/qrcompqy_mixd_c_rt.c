/*
 *  QRCOMPQY_MIXD_C_RT Helper function for QR decomposition.
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.1.2.2 $  $Date: 2004/04/12 23:47:44 $
 */

#include "dspqrdc_rt.h"

/*
 * MWDSP_qrCompqyMixdC - compute q*y or q'*y in place over y
 */
EXPORT_FCN void MWDSP_qrCompqyMixdC(
    int_T	n,
    int_T	j,
    real32_T	*qr,
    real32_T	*qrauxj,
    creal32_T	*y
    )
{
    if ((real32_T)fabs((real_T)*qrauxj) != 0.0F) {
        int_T	nmj, i, pjj;
        real32_T	temp, *pqr;
        creal32_T	t, *py, Zero = {0.0F, 0.0F};
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

/* [EOF] qrcompqy_mixd_c_rt.c */

