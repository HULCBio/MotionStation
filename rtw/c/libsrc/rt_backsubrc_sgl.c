/* Copyright 1994-2003 The MathWorks, Inc.
 *
 * File: rt_backsubrc_dbl.c     $Revision: 1.2.4.2 $
 *
 * Abstract:
 *      Real-Time Workshop support routine which performs
 *      backward substitution: solving Ux=b
 *
 */

#include "rtlibsrc.h"

/* Function: rt_BackwardSubstitutionRC_Sgl =====================================
 * Abstract: Backward substitution: Solving Ux=b 
 *           U: real, double
 *           b: complex, double
 *           U is an upper (or unit upper) triangular full matrix.
 *           The entries in the lower triangle are ignored.
 *           U is a NxN matrix
 *           X is a NxP matrix
 *           B is a NxP matrix
 */
#ifdef CREAL_T
void rt_BackwardSubstitutionRC_Sgl(real32_T    *pU,
                                   creal32_T   *pb,
                                   creal32_T   *x,
                                   int_T     N,
                                   int_T     P,
                                   boolean_T unit_upper)
{
  int_T i,k;

  for(k=P; k>0; k--) {
    real32_T *pUcol = pU;
    for(i=0; i<N; i++) {
      creal32_T *xj = x + k*N-1;
      creal32_T s = {0.0, 0.0};
      real32_T *pUrow = pUcol--;          /* access current row of U */

      {
        int_T j = i;
        while(j-- > 0) {
          s.re += *pUrow * xj->re;
          s.im += *pUrow * (xj--)->im;
          pUrow -= N;
        }
      }

      if (unit_upper) {
        creal32_T cb = (*pb--);
        xj->re = cb.re - s.re;
        (xj--)->im = cb.im - s.im;
      } else {
        creal32_T cb = (*pb--);
        xj->re = (cb.re - s.re) / *pUrow;
        (xj--)->im = (cb.im - s.im) / *pUrow;
      }
    }
  }
}
#endif
/* [EOF] rt_backsubrc_dbl.c */
