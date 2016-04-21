/* Copyright 1994-2003 The MathWorks, Inc.
 *
 * File: rt_forwardsubrc_dbl.c     $Revision: 1.4.4.2 $
 *
 * Abstract:
 *      Real-Time Workshop support routine which performs
 *      forward substitution: solving Lx=b
 *
 */

#include "rtlibsrc.h"

/* Function: rt_ForwardSubstitutionRC_Dbl =====================================
 * Abstract: Forward substitution: solving Lx=b 
 *           L: Real,    double
 *           b: Complex, double
 *           L is a lower (or unit lower) triangular full matrix.
 *           The entries in the upper triangle are ignored.
 *           L is a NxN matrix
 *           X is a NxP matrix
 *           B is a NxP matrix
 */
#ifdef CREAL_T
void rt_ForwardSubstitutionRC_Dbl(real_T    *pL,
                                  creal_T   *pb,
                                  creal_T   *x,
                                  int_T     N,
                                  int_T     P,
                                  int32_T   *piv,
                                  boolean_T unit_lower)
{
  int_T i, k;

  for(k=0; k<P; k++) {
    real_T *pLcol = pL;
    for(i=0; i<N; i++) {
      creal_T *xj = x + k*N;
      creal_T s = {0.0, 0.0};
      real_T *pLrow = pLcol++;          /* access current row of L */

      {
        int_T j = i;
        while(j-- > 0) {
          s.re += *pLrow * xj->re;
          s.im += *pLrow * (xj++)->im;
          pLrow += N;
        }
      }

      if (unit_lower) {
        creal_T cb = *(pb+piv[i]);
        xj->re = cb.re - s.re;
        (xj++)->im = cb.im - s.im;
      } else {
        creal_T cb = *(pb+piv[i]);
        xj->re = (cb.re - s.re) / *pLrow;
        (xj++)->im = (cb.im - s.im) / *pLrow;
      }
    }
    pb += N;
  }
}
#endif
/* [EOF] rt_forwardsubrc_dbl.c */
