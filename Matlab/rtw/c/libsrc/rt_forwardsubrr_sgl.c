/* Copyright 1994-2002 The MathWorks, Inc.
 *
 * File: rt_forwardsubrr_sgl.c     $Revision: 1.2 $
 *
 * Abstract:
 *      Real-Time Workshop support routine which performs
 *      forward substitution: solving Lx=b
 *
 */

#include "rtlibsrc.h"

/* Function: rt_ForwardSubstitutionRR_Sgl ======================================
 * Abstract: Forward substitution: solving Lx=b 
 *           L: Real, double
 *           b: Real, double
 *           L is a lower (or unit lower) triangular full matrix.
 *           The entries in the upper triangle are ignored.
 *           L is a NxN matrix
 *           X is a NxP matrix
 *           B is a NxP matrix
 */
void rt_ForwardSubstitutionRR_Sgl(real32_T    *pL,
                               real32_T    *pb,
                               real32_T    *x,
                               int_T     N,
                               int_T     P,
                               int32_T   *piv,
                               boolean_T unit_lower)
{
  /* Real inputs: */
  int_T i, k;
  for(k=0; k<P; k++) {
    real32_T *pLcol = pL;
    for(i=0; i<N; i++) {
      real32_T *xj = x + k*N;
      real32_T s = 0.0;
      real32_T *pLrow = pLcol++;          /* access current row of L */

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

/* [EOF] rt_forwardsubrr_sgl.c */
