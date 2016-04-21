/* 
 * polyval_cc_rt.c - Signal Processing Blockset Polynomial Evaluation run-time function 
 * 
 * Specifications: 
 * 
 * - Complex (single precision) Inputs, 
 * - Complex (single precision) Coefficients, 
 * - Complex (single precision) Outputs. 
 *  
 * 
 *  Copyright 1995-2004 The MathWorks, Inc.
 *  $Revision: 1.3.2.4 $  $Date: 2004/04/12 23:47:34 $ 
 */ 
#include "dsp_rt.h" 

EXPORT_FCN void MWDSP_polyval_CC(
    const creal32_T *u,          /* Input pointer */ 
          creal32_T *y,          /* Output pointer */ 
    const creal32_T *pCoeffs,    /* Pointer to coefficients */
    const int_T      N,          /* Number of coefficients */
    const int_T      n           /* Width of INPORT1*/ 
    )
{
     register int_T   i;
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
            register const creal32_T *tmpCplxCoeffs = pCoeffs;
            register       creal32_T  x;
            register       creal32_T  accum;
            register       int_T      j;
            
            accum.re = tmpCplxCoeffs->re;
            accum.im = tmpCplxCoeffs++->im;
            
            x.re = u->re;
            x.im = (u++)->im;

            for (j = 1; j < N; j++) {
                volatile real32_T reInputProduct;
                volatile real32_T imInputProduct;
                
                reInputProduct = CMULT_RE(accum, x);
                imInputProduct = CMULT_IM(accum, x);
                
                accum.re = reInputProduct;
                accum.im = imInputProduct;
                
                accum.re += tmpCplxCoeffs->re;
                accum.im += tmpCplxCoeffs++->im;
                        }
          
            y->re   = accum.re;
            y++->im = accum.im;
                }
}

/* [EOF] polyval_cc_rt.c */ 

