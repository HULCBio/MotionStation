/* Copyright 1994-2002 The MathWorks, Inc.
 *
 * File: rt_matmultandincrr_sgl.c     $Revision: 1.3 $
 *
 * Abstract:
 *      Real-Time Workshop support routine for matrix multiplication
 *      of two real single precision float operands
 *
 */

#include "rtlibsrc.h"

/*
 * Function: rt_MatMultAndIncRR_Sgl
 * Abstract:
 *      2-input matrix multiply function
 *      Input 1: Real, single-precision
 *      Input 2: Real, single-precision
 */
void rt_MatMultAndIncRR_Sgl(real32_T       *y,
                            const real32_T *A,
                            const real32_T *B,
                            const int      dims[3])
{
  int k;
  for(k=dims[2]; k-- > 0; ) {
    const real32_T *A1 = A;
    int i;
    for(i=dims[0]; i-- > 0; ) {
      const real32_T *A2 = A1++;
      const real32_T *B1 = B;
      real32_T acc = (real32_T)0.0;
      int j;
      for(j=dims[1]; j-- > 0; ) {
        acc += *A2 * *B1++;
        A2 += dims[0];
      }
      *y++ += acc;
    }
    B += dims[1];
  }
}

/* [EOF] rt_matmultandincrr_sgl.c */
