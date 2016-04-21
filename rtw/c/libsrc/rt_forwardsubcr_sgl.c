/* Copyright 1994-2003 The MathWorks, Inc.
 *
 * File: rt_forwardsubcr_sgl.c     $Revision: 1.3.4.2 $
 *
 * Abstract:
 *      Real-Time Workshop support routine which performs
 *      forward substitution: solving Lx=b
 *
 */

#include <math.h>
#include "rtlibsrc.h"

/* Function: rt_ForwardSubstitutionCR_Sgl ======================================
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
void rt_ForwardSubstitutionCR_Sgl(creal32_T   *pL,
                                  real32_T    *pb,
                                  creal32_T   *x,
                                  int_T     N,
                                  int_T     P,
                                  int32_T   *piv,
                                  boolean_T unit_lower)
{
  int_T i, k;

  for(k=0; k<P; k++) {
    creal32_T *pLcol = pL;
    for(i=0; i<N; i++) {
      creal32_T *xj = x + k*N;
      creal32_T s = {0.0F, 0.0F};
      creal32_T *pLrow = pLcol++;

      {
        int_T j = i;
        while(j-- > 0) {
          /* Compute: s += L * xj, in complex */
          creal32_T cL = *pLrow;
          pLrow += N;

          s.re += CMULT_RE(cL, *xj);
          s.im += CMULT_IM(cL, *xj);
          xj++;
        }
      }

      if (unit_lower) {
        const real32_T cb = pb[piv[i]];
        xj->re = cb - s.re;
        (xj++)->im = -s.im;
      } else {
        /* Complex divide: *xj = cdiff / *cL */
        const real32_T cb = pb[piv[i]];
        creal32_T cL = *pLrow;
        creal32_T cdiff;
        cdiff.re = cb - s.re;
        cdiff.im = -s.im;

        CDIVSGL(cdiff, cL, *xj);
        xj++;
      }
    }
    pb += N;
  }
}
#endif
/* [EOF] rt_forwardsubcr_sgl.c */
