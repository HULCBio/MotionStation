/* $Revision: 1.2.2.2 $ */
/*
 * PINV_C_RT Moore-Penrose Pseudoinverse run-time functions
 *
 * Copyright 1995-2003 The MathWorks, Inc.
 * $Revision:
 * Abstract
 * tol = max(m,n) * S(1,1) * eps
 * rank = sum(S(1:min(m,n)) > tol)
 * X = V(:,1:rank)*diag(1./S(1:rank))*U(:,1:rand)';
 */

#include "dsppinv_rt.h"

EXPORT_FCN void MWDSP_PINV_C(creal32_T *pS, creal32_T *pU, creal32_T *pV, creal32_T *pX, int_T M, int_T N)
{
	creal32_T *ppS;
    real32_T tol;
    real32_T cabsS;
    int_T P;
    int_T rank = 0;
    int_T i;
	
    P = MIN(M, N);
	tol = (real32_T)MAX(M,N) * (pS->re) * EPS_real32_T;
	ppS = pS+P-1;
	for(i=P; i>0; i--) 
    {
    	CABS32(*ppS,cabsS);
    	ppS--;
	    if (cabsS >= tol) 
        {
		    rank = i;
		    break;
	    }
	}
	if (rank != 0) 
    {
	    creal32_T *ppX, *ppU, *ppV, temp;
	    int_T j,k;
	    
	    ppX = pX;

        /* Initialize output array */
        for (i=0; i<N*M; i++) 
        {
	        ppX->re = 0.0;
	        ppX->im = 0.0;
            ppX++;
	    }
	    ppX = pX;

	    for(j=0; j<M; j++) 
        {
		    for(i=0; i<N; i++) 
            {
		        ppV = pV+i;
		        ppU = pU+j;
		        ppS = pS;
		        for(k=0; k<rank; k++) 
                {
			        temp.re = CMULT_YCONJ_RE(*ppV,*ppU);
			        temp.im = CMULT_YCONJ_IM(*ppV,*ppU);
			        CDIV32(temp,*ppS,temp);
			        ppX->re += temp.re;
			        ppX->im += temp.im;
			        ppS++;
			        ppV += N;
			        ppU += M;
		        }
		        ppX++;
		    }
	    }
	}
}


/* [EOF] pinv_c_rt.c */
