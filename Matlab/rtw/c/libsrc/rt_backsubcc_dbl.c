/* Copyright 1994-2003 The MathWorks, Inc.
 *
 * File: rt_backsubcc_dbl.c     $Revision: 1.4.4.2 $
 *
 * Abstract:
 *      Real-Time Workshop support routine which performs
 *      backward substitution: solving Ux=b for complex
 *      double precision float operands
 *
 */

#include <math.h>
#include "rtlibsrc.h"

/* Function: rt_BackwardSubstitutionCC_Dbl =====================================
 * Abstract: Backward substitution: Solving Ux=b 
 *           U: complex, double
 *           b: complex, double
 *           U is an upper (or unit upper) triangular full matrix.
 *           The entries in the lower triangle are ignored.
 *           U is a NxN matrix
 *           X is a NxP matrix
 *           B is a NxP matrix
 */
#ifdef CREAL_T
void rt_BackwardSubstitutionCC_Dbl(creal_T   *pU,
                                   creal_T   *pb,
                                   creal_T   *x,
                                   int_T     N,
                                   int_T     P,
                                   boolean_T unit_upper)
{
  int_T i, k;

  for(k=P; k>0; k--) {
    creal_T *pUcol = pU;
    for(i=0; i<N; i++) {
      creal_T *xj = x + k*N-1;
      creal_T s = {0.0, 0.0};
      creal_T *pUrow = pUcol--;

      {
        int_T j = i;
        while(j-- > 0) {
          /* Compute: s += L * xj, in complex */
          creal_T cU = *pUrow;
          pUrow -= N;

          s.re += CMULT_RE(cU, *xj);
          s.im += CMULT_IM(cU, *xj);
          xj--;
        }
      }

      if (unit_upper) {
        creal_T cb = *pb--;
        xj->re = cb.re - s.re;
        (xj--)->im = cb.im - s.im;
      } else {
        /* Complex divide: *xj = cdiff / *cL */
        creal_T cb = *pb--;
        creal_T cU = *pUrow;
        creal_T cdiff;
        cdiff.re = cb.re - s.re;
        cdiff.im = cb.im - s.im;

        CDIV(cdiff, cU, *xj);
        xj--;
      }
    }
  }
}
#endif
/* [EOF] rt_backsubcc_dbl.c */
