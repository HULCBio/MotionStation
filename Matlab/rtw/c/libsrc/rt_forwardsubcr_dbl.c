/* Copyright 1994-2003 The MathWorks, Inc.
 *
 * File: rt_forwardsubcr_dbl.c     $Revision: 1.4.4.2 $
 *
 * Abstract:
 *      Real-Time Workshop support routine which performs
 *      forward substitution: solving Lx=b
 *
 */

#include <math.h>
#include "rtlibsrc.h"

/* Function: rt_ForwardSubstitutionCR_Dbl ======================================
 * Abstract: Forward substitution: solving Lx=b 
 *           L: Complex, double
 *           b: Real,    double
 *           L is a lower (or unit lower) triangular full matrix.
 *           The entries in the upper triangle are ignored.
 *           L is a NxN matrix
 *           X is a NxP matrix
 *           B is a NxP matrix
 */
#ifdef CREAL_T
void rt_ForwardSubstitutionCR_Dbl(creal_T   *pL,
                                  real_T    *pb,
                                  creal_T   *x,
                                  int_T     N,
                                  int_T     P,
                                  int32_T   *piv,
                                  boolean_T unit_lower)
{
  int_T i, k;

  for(k=0; k<P; k++) {
    creal_T *pLcol = pL;
    for(i=0; i<N; i++) {
      creal_T *xj = x + k*N;
      creal_T s = {0.0, 0.0};
      creal_T *pLrow = pLcol++;

      {
        int_T j = i;
        while(j-- > 0) {
          /* Compute: s += L * xj, in complex */
          creal_T cL = *pLrow;
          pLrow += N;

          s.re += CMULT_RE(cL, *xj);
          s.im += CMULT_IM(cL, *xj);
          xj++;
        }
      }

      if (unit_lower) {
        const real_T cb = pb[piv[i]];
        xj->re = cb - s.re;
        (xj++)->im = -s.im;
      } else {
        /* Complex divide: *xj = cdiff / *cL */
        const real_T cb = pb[piv[i]];
        creal_T cL = *pLrow;
        creal_T cdiff;
        cdiff.re = cb - s.re;
        cdiff.im = -s.im;

        CDIV(cdiff, cL, *xj);
        xj++;
      }
    }
    pb += N;
  }
}
#endif
/* [EOF] rt_forwardsubcr_dbl.c */
