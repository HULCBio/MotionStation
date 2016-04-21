/* Copyright 1994-2002 The MathWorks, Inc.
 *
 * File: rt_matmultandincrc_sgl.c     $Revision: 1.3 $
 *
 * Abstract:
 *      Real-Time Workshop support routine for matrix multiplication
 *      and increment.
 *      Real multiplied by complex, single precision float operands
 *
 */

#include "rtlibsrc.h"

/*
 * Function: rt_MatMultAndIncRC_Sgl
 * Abstract:
 *      2-input matrix multiply and increment function
 *      Input 1: Real, single-precision
 *      Input 2: Complex, single-precision
 */
void rt_MatMultAndIncRC_Sgl(creal32_T       *y,
                            const real32_T  *A,
                            const creal32_T *B,
                            const int       dims[3])
{
  int k;
  for(k=dims[2]; k-- > 0; ) {
    const real32_T *A1 = A;
    int i;
    for(i=dims[0]; i-- > 0; ) {
      const real32_T *A2 = A1++;
      const creal32_T *B1 = B;
      creal32_T acc;
      int j;
      acc.re = (real32_T)0.0;
      acc.im = (real32_T)0.0;
      for(j=dims[1]; j-- > 0; ) {
        acc.re += *A2 * B1->re;
        acc.im += *A2 * (B1++)->im;
        A2 += dims[0];
      }
      y->re += acc.re;
      y->im += acc.im;
      y++;
    }
    B += dims[1];
  }
}

/* [EOF] rt_matmultandincrc_sgl.c */
