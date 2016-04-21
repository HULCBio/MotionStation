/* $Revision: 1.4.2.3 $ */
/*
 * chol_z_rt.c - Signal Processing Blockset Cholesky factorization run-time function
 * This function decomposes a positive definite matrix A into LL' where L is a
 * lower triangular matrix.
 * 
 * Specifications: 
 * 
 * Double precision complex data types and return EXPORT_FCN void type.
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

EXPORT_FCN void MWDSP_Chol_Z(creal_T *A, int_T n)
{
    int_T j;
    creal_T *A_jn = A;

    for (j=0; j<n; j++) {
        real_T      s = 0.0;
        creal_T *A_kn = A;
        int_T k;

        A_jn[j].im = 0.0;   /* Remove imaginary part on diagonal since */
                            /* this matrix is supposed to be Hermitian. */

        for (k=0; k<j; k++) {
            creal_T t = {0.0, 0.0};
            {
                /* Inner product */
                creal_T *x1 = A_kn;
                creal_T *x2 = A_jn;
                int_T    kk = k;
                while(kk--) {
                    t.re += CMULT_XCONJ_RE(*x1, *x2);
                    t.im += CMULT_XCONJ_IM(*x1, *x2);
                    x1++;
                    x2++;
                }
            }
            t.re    = A_jn[k].re - t.re;
            t.im    = A_jn[k].im - t.im;
            t.re   /= A_kn[k].re;               /* Diagonal elements A_kn[k] are real */
            t.im   /= A_kn[k].re;
            A_jn[k] = t;
            /* Copy transpose of upper triangle (Hermitian) to lower triangle: */
            A_kn[j].re = t.re;
            A_kn[j].im = -t.im;
            s         += CMAGSQ(t);
            A_kn      += n;
        }
        s          = A_jn[j].re - s;
        A_jn[j].re = sqrt(s);
        A_jn      += n;
    }
}

/* [EOF] chol_z_rt.c */

