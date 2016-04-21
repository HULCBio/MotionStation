/* Copyright 1994-2003 The MathWorks, Inc.
 *
 * File: rt_lu_cplx.c     $Revision: 1.3.4.2 $
 *
 * Abstract:
 *      Real-Time Workshop support routine for lu_cplx
 *
 */

#include <math.h>
#include "rtlibsrc.h"

/* Function: rt_lu_cplx ========================================================
 * Abstract: A is complex.
 *
 */
#ifdef CREAL_T
void rt_lu_cplx_sgl(creal32_T *A,     /* in and out                         */
                const int_T n,  /* number or rows = number of columns */
                int32_T *piv)   /* pivote vector                      */
{
  int_T k;

  /* initialize row-pivot indices: */
  for (k = 0; k < n; k++) {
    piv[k] = k;
  }

  /* Loop over each column: */
  for (k = 0; k < n; k++) {
    const int_T kn = k*n;
    int_T p = k;

    /*
     * Scan the lower triangular part of this column only
     * Record row of largest value
     */
    {
      int_T i;
      real32_T Amax = CQABSSGL(A[p+kn]);     /* approx mag-squared value */

      for (i = k+1; i < n; i++) {
        real32_T q = CMAGSQ(A[i+kn]);
        if (q > Amax) {p = i; Amax = q;}
      }
    }

    /* swap rows if required */
    if (p != k) {
      int_T j;
      for (j = 0; j < n; j++) {
        creal32_T c;
        const int_T pjn = p+j*n;
        const int_T kjn = k+j*n;

        c = A[pjn];
        A[pjn] = A[kjn];
        A[kjn] = c;
      }

      /* Swap pivot row indices */
      {
        int32_T t = piv[p]; piv[p] = piv[k]; piv[k] = t;
      }
    }

    /* column reduction */
    {
      creal32_T Adiag;
      int_T i, j;

      Adiag = A[k+kn];

      if (!((Adiag.re == 0.0F) && (Adiag.im == 0.0F))) {
        /* non-zero diagonal entry */
        /*
         * divide lower triangular part of column by max
         * First, form reciprocal of Adiag:
         *	    recip = conj(Adiag)/(|Adiag|^2)
         */
        CRECIPSGL(Adiag, Adiag);

        /* Multiply: A[i+kn] *= Adiag: */
        for (i = k+1; i < n; i++) {
          real32_T t = CMULT_RE(A[i+kn], Adiag);
          A[i+kn].im = CMULT_IM(A[i+kn], Adiag);
          A[i+kn].re = t;
        }

        /* subtract multiple of column from remaining columns */
        for (j = k+1; j < n; j++) {
          int_T j_n = j*n;
          for (i = k+1; i < n; i++) {
            /* Multiply: c = A[i+kn] * A[k+j_n]: */
            creal32_T c;
            c.re = CMULT_RE(A[i+kn], A[k+j_n]);
            c.im = CMULT_IM(A[i+kn], A[k+j_n]);

            /* Subtract A[i+j_n] -= A[i+kn]*A[k+j_n]: */
            A[i+j_n].re -= c.re;
            A[i+j_n].im -= c.im;
          }
        }
      }
    }
  }
}
#endif
/* [EOF] rt_lu_cplx_sgl.c */
