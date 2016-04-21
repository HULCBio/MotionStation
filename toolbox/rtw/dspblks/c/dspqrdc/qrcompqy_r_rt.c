/*
 *  QRCOMPQY_R_RT Helper function for QR decomposition.
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.1.2.2 $  $Date: 2004/04/12 23:47:46 $
 */

#include "dspqrdc_rt.h"

/*
 * MWDSP_qrCompqyR - compute q*y or q'*y in place over y
 */

EXPORT_FCN void MWDSP_qrCompqyR (
    int_T	n,
    int_T	j,
    real32_T	*qr,
    real32_T	*qrauxj,
    real32_T	*y
    )
{

    if (FABS32(*qrauxj) != 0.0F) {
        int_T	nmj, i, pjj;
        real32_T	t, temp, *pqr, *py;

	nmj = n - j;
	pjj = j*(n+1); /* offset for qr(j,j) */
	pqr  = qr + pjj;
	temp = *pqr;
	*pqr = *qrauxj;
	t = 0.0F;
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

/* [EOF] qrcompqy_r_rt.c */

