/*
 *  QRCOMPQY_D_RT Helper function for QR decomposition.
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.12.2.2 $  $Date: 2004/04/12 23:47:43 $
 */

#include "dspqrdc_rt.h"

/*
 * dspcompqy - compute q*y or q'*y in place over y
 */
EXPORT_FCN void MWDSP_qrCompqyD (
    int_T	n,
    int_T	j,
    real_T	*qr,
    real_T	*qrauxj,
    real_T	*y
    )
{

    if (fabs(*qrauxj) != 0.0) {
        int_T	nmj, i, pjj;
        real_T	t, temp, *pqr, *py;

	nmj = n - j;
	pjj = j*(n+1); /* offset for qr(j,j) */
	pqr  = qr + pjj;
	temp = *pqr;
	*pqr = *qrauxj;
	t = 0.0;
	py = y;
	for(i=nmj; i-- > 0; ) {
	    t -= (*pqr) * (*py);
	    pqr++;
	    py++;
	}
	pqr = qr + pjj; /* reset to pointer to qr(j,j) */
	t /= *pqr;
	py = y;
	for(i=nmj; i-- > 0; ) {
	    *py += t * (*pqr);
	    pqr++;
	    py++;
	}
	pqr = qr + pjj; /* reset to pointer to qr(j,j) */
	*pqr = temp;
    }
}

/* [EOF] qrcompqy_d_rt.c */
