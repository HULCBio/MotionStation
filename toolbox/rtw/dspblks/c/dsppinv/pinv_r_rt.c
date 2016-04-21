/* $Revision: 1.2.2.2 $ */
/*
 * PINV_R_RT Moore-Penrose Pseudoinverse run-time functions
 *
 * Copyright 1995-2003 The MathWorks, Inc.
 * $Revision:
 * Abstract
 * tol = max(m,n) * S(1,1) * eps
 * rank = sum(S(1:min(m,n)) > tol)
 * X = V(:,1:rank)*diag(1./S(1:rank))*U(:,1:rand)';
 */

#include "dsppinv_rt.h"

EXPORT_FCN void MWDSP_PINV_R(real32_T *pS, real32_T *pU, real32_T *pV, real32_T *pX, int_T M, int_T N)
{
	real32_T *ppS;
    real32_T tol;
    int_T P;
    int_T rank = 0;
    int_T i;
	
    P = MIN(M, N);
    tol = (real32_T)MAX(M,N) * (*pS) * EPS_real32_T;
	ppS = pS+P-1;
	for(i=P; i>0; i--) 
    {
	    if (FABS32(*ppS) >= tol) 
        {
    		rank = i;
   	    	break;
	    }
        ppS--;
	}
	if (rank != 0) 
    {
	    real32_T *ppX, *ppU, *ppV;
	    int_T j,k;
	
	    ppX = pX;
        /* Initialize output array */
        for (i=0; i<N*M; i++) 
        {
	        *ppX++ = 0.0;
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
			        *ppX += *ppV * *ppU / *ppS++;
			        ppV += N;
			        ppU += M;
		        }
		        ppX++;
		    }
	    }
	}
}

/* [EOF] pinv_r_rt.c */
