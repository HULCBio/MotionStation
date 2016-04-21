/*
 * File: matmult_cc_rt.c
 * Abstract:
 *      2-input matrix multiply function
 *      Input 1: Complex, single-precision
 *      Input 2: Complex, single-precision
 *
 * Copyright 1995-2003 The MathWorks, Inc.
 * $Revision: 1.5.2.2 $ $Date: 2004/04/12 23:47:03 $
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

EXPORT_FCN void MWDSP_MatMult_CC(
    creal32_T *y,
    const creal32_T *A,
    const creal32_T *B,
    const int dims[3])
{
    int k;
    for(k=dims[2]; k-- > 0; ) {
        const creal32_T *A1 = A;
        int i;
        for(i=dims[0]; i-- > 0; ) {
            const creal32_T *A2 = A1++;
            const creal32_T *B1 = B;	
            creal32_T  acc;
            int j;
            acc.re = (real32_T)0.0;
            acc.im = (real32_T)0.0;
            for(j=dims[1]; j-- > 0; ) {
                creal32_T A2_val = *A2;
                creal32_T B1_val = *B1++;
                acc.re += CMULT_RE(A2_val, B1_val);
                acc.im += CMULT_IM(A2_val, B1_val);
                A2 += dims[0];
            }
            *y++ = acc;
        }
        B += dims[1];
    }
}

/* [EOF] matmult_cc_rt.c */
