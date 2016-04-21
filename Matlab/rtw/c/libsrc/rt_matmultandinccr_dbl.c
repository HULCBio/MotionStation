/* Copyright 1994-2002 The MathWorks, Inc.
 *
 * File: rt_matmultandinccr_dbl.c     $Revision: 1.3 $
 *
 * Abstract:
 *      Real-Time Workshop support routine for matrix multiplication
 *      and increment.
 *      Complex muliplied by real, double precision float operands
 *
 */

#include "rtlibsrc.h"

/*
 * Function: rt_MatMultAndIncCR_Dbl
 * Abstract:
 *      2-input matrix multiply and increment function
 *      Input 1: Complex, double-precision
 *      Input 2: Real, double-precision
 */
void rt_MatMultAndIncCR_Dbl(creal_T       *y,
                            const creal_T *A,
                            const real_T  *B,
                            const int     dims[3])
{
  int k;
  for(k=dims[2]; k-- > 0; ) {
    const creal_T *A1 = A;
    int i;
    for(i=dims[0]; i-- > 0; ) {
      const creal_T *A2 = A1++;
      const real_T *B1 = B;
      creal_T acc;
      int j;
      acc.re = (real_T)0.0;
      acc.im = (real_T)0.0;
      for(j=dims[1]; j-- > 0; ) {
        acc.re += A2->re * *B1;
        acc.im += A2->im * *B1++;
        A2 += dims[0];
      }
      y->re += acc.re;
      y->im += acc.im;
      y++;
    }
    B += dims[1];
  }
}

/* [EOF] rt_matmultandinccr_dbl.c */
