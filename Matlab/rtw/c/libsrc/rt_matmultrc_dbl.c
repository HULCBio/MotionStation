/* Copyright 1994-2003 The MathWorks, Inc.
 *
 * File: rt_matmultrc_dbl.c     $Revision: 1.3.4.2 $
 *
 * Abstract:
 *      Real-Time Workshop support routine for matrix multiplication.
 *      Real multiplied by complex, double precision float operands
 *
 */

#include "rtlibsrc.h"

/*
 * Function: rt_MatMultRC_Dbl
 * Abstract:
 *      2-input matrix multiply function
 *      Input 1: Real, double-precision
 *      Input 2: Complex, double-precision
 */
#ifdef CREAL_T
void rt_MatMultRC_Dbl(creal_T       *y, 
                      const real_T  *A,
                      const creal_T *B,
                      const int     dims[3])
{
  int k;
  for(k=dims[2]; k-- > 0; ) {
    const real_T *A1 = A;
    int i;
    for(i=dims[0]; i-- > 0; ) {
      const real_T *A2 = A1++;
      const creal_T *B1 = B;
      creal_T acc;
      int j;
      acc.re = (real_T)0.0;
      acc.im = (real_T)0.0;
      for(j=dims[1]; j-- > 0; ) {
        acc.re += *A2 * B1->re;
        acc.im += *A2 * (B1++)->im;
        A2 += dims[0];
      }
      *y++ = acc;
    }
    B += dims[1];
  }
}
#endif
/* [EOF] rt_matmultrc_dbl.c */
