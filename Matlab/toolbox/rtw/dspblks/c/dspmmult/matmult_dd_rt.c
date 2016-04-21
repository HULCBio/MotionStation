/*
 * File: matmult_dd_rt.c
 * Abstract:
 *      2-input matrix multiply function
 *      Input 1: Real, double-precision
 *      Input 2: Real, double-precision
 *
 * Copyright 1995-2003 The MathWorks, Inc.
 * $Revision: 1.5.2.2 $ $Date: 2004/04/12 23:47:05 $
 *
 * Multiply two input matrices (A and B), recording the result in y.
 * A has size i-by-j
 * B has size j-by-k
 * y has size i-by-k
 * dims[] contains the i,j,k dimensions as follows:
 *    dims[0] = i
 *    dims[1] = j
 *    dims[2] = k
 *
 * All of our matrix multiplies are of the "kij" type, that is,
 * they order their loops with the j-loop as the innermost loop.
 */

#include "dsp_rt.h"

EXPORT_FCN void MWDSP_MatMult_DD(
    real_T *y,
    const real_T *A,
    const real_T *B,
    const int dims[3])
{
    int k;
    for(k=dims[2]; k-- > 0; ) {
        const real_T *A1 = A;
        int i;
        for(i=dims[0]; i-- > 0; ) {
            const real_T *A2 = A1++;
            const real_T *B1 = B;
            real_T  acc = (real_T)0.0;
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

/* [EOF] matmult_dd_rt.c */
