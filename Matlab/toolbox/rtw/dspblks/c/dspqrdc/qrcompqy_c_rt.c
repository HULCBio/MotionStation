/*
 *  QRCOMPQY_C_RT Helper function for QR decomposition.
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.1.2.2 $  $Date: 2004/04/12 23:47:42 $
 */

#include "dspqrdc_rt.h"

/*
 * MWDSP_qrCompqyC - compute q*y or q'*y in place over y
 */
EXPORT_FCN void MWDSP_qrCompqyC (
    int_T	n,
    int_T	j,
    creal32_T	*qr,
    creal32_T	*qrauxj,
    creal32_T	*y
    )
{
    if (CQABS32(*qrauxj) != 0.0F) {
	int_T	nmj, i, pjj;
	creal32_T	t, temp, *pqr, *py, Zero = {0.0F, 0.0F};

	nmj  = n - j;
	pjj  = j*(n+1);	/* offset for x(j,j) */
	pqr   = qr + pjj;	/* pointer to x(j,j) */
	temp = *pqr;
	*pqr  = *qrauxj;
	t = Zero;
	py = y;
	for(i=nmj; i-- > 0; ) {
	    t.re -= CMULT_XCONJ_RE(*pqr, *py);
	    t.im -= CMULT_XCONJ_IM(*pqr, *py);
	    pqr++;
	    py++;
	}
	pqr = qr + pjj;	/* reset to pointer to qr(j,j) */
	CDIV32(t, *pqr, t);
	py = y;
	for(i=nmj; i-- > 0; ) {
	    py->re += CMULT_RE(t, *pqr);
	    py->im += CMULT_IM(t, *pqr);
	    pqr++;
	    py++;
	}
	pqr = qr + pjj;	/* reset to pointer to qr(j,j) */
	*pqr = temp;
    }
}

/* [EOF] qrcompqy_c_rt.c */


