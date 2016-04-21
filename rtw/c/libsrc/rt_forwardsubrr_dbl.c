/* Copyright 1994-2002 The MathWorks, Inc.
 *
 * File: rt_forwardsubrr_dbl.c     $Revision: 1.3 $
 *
 * Abstract:
 *      Real-Time Workshop support routine which performs
 *      forward substitution: solving Lx=b
 *
 */

#include "rtlibsrc.h"

/* Function: rt_ForwardSubstitutionRR_Dbl ======================================
 * Abstract: Forward substitution: solving Lx=b 
 *           L: Real, double
 *           b: Real, double
 *           L is a lower (or unit lower) triangular full matrix.
 *           The entries in the upper triangle are ignored.
 *           L is a NxN matrix
 *           X is a NxP matrix
 *           B is a NxP matrix
 */
void rt_ForwardSubstitutionRR_Dbl(real_T    *pL,
                               real_T    *pb,
                               real_T    *x,
                               int_T     N,
                               int_T     P,
                               int32_T   *piv,
                               boolean_T unit_lower)
{
  /* Real inputs: */
  int_T i, k;
  for(k=0; k<P; k++) {
    real_T *pLcol = pL;
    for(i=0; i<N; i++) {
      real_T *xj = x + k*N;
      real_T s = 0.0;
      real_T *pLrow = pLcol++;          /* access current row of L */

      {
        int_T j = i;
        while(j-- > 0) {
          s += *pLrow * *xj++;
          pLrow += N;
        }
      }

      if (unit_lower) {
        *xj++ = pb[piv[i]] - s;
      } else {
        *xj++ = (pb[piv[i]] - s) / *pLrow;
      }
    }
    pb += N;
  }
}

/* [EOF] rt_forwardsubrr_dbl.c */
