/**********************/
/* 
 * lu_z_rt.c - Signal Processing Blockset LU Factorization run-time function 
 * 
 * Specifications: 
 * 
 * - Complex (double precision) Input
 * - Real (double precision) P Output
 * - Complex (double precision) LU Output
 * - Boolean (singularity status) Output
 * 
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.4.2.3 $  $Date: 2004/04/12 23:47:02 $ 
 */
#include "dsp_rt.h" 

EXPORT_FCN void MWDSP_lu_Z(
          creal_T   *A,       /* Input Pointer */ 
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
        const int_T  kn = k*n;
              int_T   p = k;
        
        /*
         * Scan the lower triangular part of this column only
         * Record row of largest value
         */
        {
            int_T  i;
            real_T Amax = CQABS(A[p+kn]);       /* approx mag-squared value */
            
            for (i = k+1; i < n; i++) {
                real_T q = CMAGSQ(A[i+kn]);
                if (q > Amax) {p = i; Amax = q;}
            }
        }
            
        /* swap rows if required */
        if (p != k) {
            int_T j;
            for (j = 0; j < n; j++) {
                creal_T c;
                const int_T pjn = p+j*n;
                const int_T kjn = k+j*n;
                
                c      = A[pjn];
                A[pjn] = A[kjn];
                A[kjn] = c;
            }
                
            /* Swap pivot row indices */
            {
                real_T t = piv[p]; piv[p] = piv[k]; piv[k] = t;
            }
        }
            
        /* column reduction */
        {
            real_T hztest=1.0;
            creal_T Adiag;
            int_T i, j;
        
            Adiag = A[k+kn];
        
            if (!( /* non-zero diagonal entry */
                 ((real_T)(hztest+Adiag.re) == hztest) && 
                 ((real_T)(hztest+Adiag.im) == hztest)
               ) ) 
            {
                /*
                 * divide lower triangular part of column by max
                 * First, form reciprocal of Adiag:
                 *          recip = conj(Adiag)/(|Adiag|^2)
                 */
                 CRECIP(Adiag, Adiag);
                        
                /* Multiply: A[i+kn] *= Adiag: */
                for (i = k+1; i < n; i++) {
                    real_T t   = CMULT_RE(A[i+kn], Adiag);
                    A[i+kn].im = CMULT_IM(A[i+kn], Adiag);
                    A[i+kn].re = t;
                }
                        
                /* subtract multiple of column from remaining columns */
                for (j = k+1; j < n; j++) {
                    int_T jn_temp = j*n;
                    for (i = k+1; i < n; i++) {
                        /* Multiply: c = A[i+kn] * A[k+jn_temp]: */
                        creal_T c;
                        c.re = CMULT_RE(A[i+kn], A[k+jn_temp]);
                        c.im = CMULT_IM(A[i+kn], A[k+jn_temp]);
                        
                        /* Subtract A[i+jn_temp] -= A[i+kn]*A[k+jn_temp]: */
                        A[i+jn_temp].re -= c.re;
                        A[i+jn_temp].im -= c.im;
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

/* [EOF] lu_z_rt.c */ 

