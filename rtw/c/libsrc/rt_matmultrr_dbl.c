/* Copyright 1994-2002 The MathWorks, Inc.
 *
 * File: rt_matmultrr_dbl.c     $Revision: 1.3 $
 *
 * Abstract:
 *      Real-Time Workshop support routine for matrix multiplication
 *      of two real double precision float operands
 *
 */

#include "rtlibsrc.h"

/*
 * Function: rt_MatMultRR_Dbl
 * Abstract:
 *      2-input matrix multiply function
 *      Input 1: Real, double-precision
 *      Input 2: Real, double-precision
 */
void rt_MatMultRR_Dbl(real_T       *y, 
                   const real_T *A,
                   const real_T *B, 
                   const int    dims[3])
{
  int k;
  for(k=dims[2]; k-- > 0; ) {
    const real_T *A1 = A;
    int i;
    for(i=dims[0]; i-- > 0; ) {
      const real_T *A2 = A1++;
      const real_T *B1 = B;
      real_T acc = (real_T)0.0;
      int j;
      for(j=dims[1]; j-- > 0; ) {
        acc += *A2 * *B1++;
        A2 += dims[0];
      }
      *y++ = acc;
    }
    B += dims[1];
  }
}

/* [EOF] rt_matmultrr_dbl.c */
