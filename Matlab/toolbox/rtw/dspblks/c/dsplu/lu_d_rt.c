/**********************/
/* 
 * lu_d_rt.c - Signal Processing Blockset LU Factorization run-time function 
 * 
 * Specifications: 
 * 
 * - Real (double precision) Input
 * - Real (double precision) P Output
 * - Real (double precision) LU Output
 * - Boolean (singularity status) Output
 * 
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.4.2.3 $  $Date: 2004/04/12 23:47:00 $ 
 */
#include "dsp_rt.h" 

EXPORT_FCN void MWDSP_lu_D(
          real_T    *A,       /* Input Pointer */ 
          real_T    *piv,     /* Ouyput (P) Pointer */
    const int_T      n,       /* P-port width */ 
          boolean_T *singular /* Singularity of input */
    )
{
    int_T k;
    *singular = (boolean_T)0; /* Initialize assuming non-singular input matrix */
    
    /* initialize row-pivot indices: */
    for (k = 0; k < n; k++) {
        piv[k] = (real_T)(k+1);
    }
    
    /* Loop over each column: */
    for (k = 0; k < n; k++) {
        const int_T kn = k*n;
        int_T p = k;
        
        /* Scan the lower triangular part of this column only
         * Record row of largest value
         */
        {
            int_T i;
            real_T Amax = fabs(A[p+kn]); /* assume diag is max */
            for (i = k+1; i < n; i++) {
                real_T q = fabs(A[i+kn]);
                if (q > Amax) {p = i; Amax = q;}
            }
        }
            
        /* swap rows if required */
        if (p != k) {
            int_T j;
            real_T t;
            for (j = 0; j < n; j++) {
                const int_T jn_temp = j*n;
                t = A[p+jn_temp]; A[p+jn_temp] = A[k+jn_temp]; A[k+jn_temp] = t;
            }
            /* swap pivot row indices */
            t = piv[p]; piv[p] = piv[k]; piv[k] = t;
        }
            
        /* column reduction */
        {
            real_T hztest = 1.0;
            real_T Adiag = A[k+kn];
            int_T i,j;
            if ((real_T)(hztest + Adiag) != hztest) {  /* non-zero diagonal entry */
                    
                /* divide lower triangular part of column by max */
                Adiag = 1.0/Adiag;
                for (i = k+1; i < n; i++) {
                    A[i+kn] *= Adiag;
                }
                    
                /* subtract multiple of column from remaining columns */
                for (j = k+1; j < n; j++) {
                    int_T jn_temp = j*n;
                    for (i = k+1; i < n; i++) {
                        A[i+jn_temp] -= A[i+kn]*A[k+jn_temp]; 
                    }
                }
            }
            else {
                /* If any diagonal element is zero, input matrix is singular */
                *singular = (boolean_T) 1;
            }
        }
    }
}

/* [EOF] lu_d_rt.c */ 



