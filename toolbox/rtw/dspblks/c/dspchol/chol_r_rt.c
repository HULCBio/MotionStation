/* $Revision: 1.5.2.3 $ */
/*
 * chol_r_rt.c - Signal Processing Blockset Cholesky factorization run-time function
 * This function decomposes a positive definite matrix A into LL' where L is a
 * lower triangular matrix.
 * 
 * Specifications: 
 * 
 * Single precision real data types and return EXPORT_FCN void type.
 * 
 * The algorithm used is "Bordered Form Cholesky Factorization".
 * See Exercise 1.5.13 in "Fundamentals of Matrix Computations", by
 *  David S. Watkins, '91, Wiley and Sons.
 *
 * The basic idea of the algorithm is to square root successively
 *  larger prinicipal sub-matrices, starting with the 1x1 in the
 *  upper left corner. This cholesky factorization is embedded in
 *  the larger factorization and grows from 1x1, to 2x2, etc. At
 *  each stage a triangular linear system must be solved for the
 *  update.
 * 
 * Copyright 1995-2003 The MathWorks, Inc.
 *
 */

#include "dsp_rt.h"

EXPORT_FCN void MWDSP_Chol_R(real32_T *A, int_T n)
{
    int_T j;
    real32_T *A_jn = A;

    for (j=0; j<n; j++) {
        real32_T     s = 0.0F;
        real32_T *A_kn = A;
        int_T k;

        for (k=0; k<j; k++) {
            real32_T t = 0.0F;
            {
                /* Inner product */
                real32_T *x1 = A_kn;
                real32_T *x2 = A_jn;
                int_T     kk = k;
                while(kk--) {
                    t += *x1++ * *x2++;
                }
            }
            t       = (A_jn[k] - t) / A_kn[k];
            A_jn[k] = t;
            A_kn[j] = t;                      /* Copy upper triangle to lower */
            s      += t*t;
            A_kn   += n;
        }
        s       = A_jn[j] - s;
        A_jn[j] = sqrtf(s);
        A_jn   += n;
    }
}

/* [EOF] chol_r_rt.c */

