/* 
 * polyval_cr_rt.c - Signal Processing Blockset Polynomial Evaluation run-time function 
 * 
 * Specifications: 
 * 
 * - Complex (single precision) Inputs,
 * - Real (single precision) Coefficients,
 * - Complex (single precision) Outputs. 
 *  
 * 
 *  Copyright 1995-2004 The MathWorks, Inc.
 *  $Revision: 1.3.2.4 $  $Date: 2004/04/12 23:47:35 $ 
 */
#include "dsp_rt.h" 

EXPORT_FCN void MWDSP_polyval_CR(
    const creal32_T *u,       /* Input pointer */ 
          creal32_T *y,       /* Output pointer */ 
    const real32_T  *pCoeffs, /* Pointer to coefficients */
    const int_T      N,       /* Number of coefficients */  
    const int_T      n        /* Width of INPORT1*/ 
    )
{
    register int_T    i;
    /* Using Horner's Method to evaluate polynomial.
     *
     * This method is the most efficient in terms of
     * multiplies and adds (it also loops nicely):
     *
     *     y = ax^4 + bx^3 + cx^2 + dx + e
     *
     * becomes
     *
     *     y = e + x*( d + x( c + x*( b + x*a ) ) )
     */
    for (i = 0; i < n; i++) { /* loop over inputs */
        register const real32_T  *tmpReCoeffs = pCoeffs;
        register       creal32_T  accum;
        register       creal32_T  x;
        register       int_T      j;

        accum.re = *tmpReCoeffs++;
        accum.im =  0.0;

        x.re = u->re;
        x.im = (u++)->im;

        for (j = 1; j < N; j++) {
            volatile real32_T reInputProduct; /* volatile to fix MSV5 compiler bug */
            volatile real32_T imInputProduct; /* volatile to fix MSV5 compiler bug */
                
            reInputProduct = CMULT_RE(accum, x);
            imInputProduct = CMULT_IM(accum, x);
                
            accum.re = reInputProduct;
            accum.im = imInputProduct;

            accum.re += *tmpReCoeffs++;
        }
         
        y->re   = accum.re;
        y++->im = accum.im;
    }
}

/* [EOF] polyval_cr_rt.c */ 

