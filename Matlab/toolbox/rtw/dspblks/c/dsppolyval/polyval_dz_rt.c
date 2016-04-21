/* 
 * polyval_dz_rt.c - Signal Processing Blockset Polynomial Evaluation run-time function 
 * 
 * Specifications: 
 * 
 * - Real (double precision) Inputs,     
 * - Complex (double precision) Coefficients,
 * - Complex (double precision) Outputs.
 *  
 * 
 *  Copyright 1995-2004 The MathWorks, Inc.
 *  $Revision: 1.3.2.4 $  $Date: 2004/04/12 23:47:37 $ 
 */
#include "dsp_rt.h" 

EXPORT_FCN void MWDSP_polyval_DZ(
    const real_T  *u,         /* Input pointer */ 
          creal_T *y,         /* Output pointer */ 
    const creal_T *pCoeffs,   /* Pointer to coefficients */
    const int_T    N,         /* Number of coefficients */
    const int_T    n          /* Width of INPORT1*/ 
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
            register const creal_T *tmpCplxCoeffs = pCoeffs;
            register       real_T   x = *u++;
            register       creal_T  accum;
            register       int_T    j;
            
            accum.re = tmpCplxCoeffs->re;
            accum.im = tmpCplxCoeffs++->im;
            
            for (j = 1; j < N; j++) {
                accum.re *= x;
                accum.im *= x;
                
                accum.re += tmpCplxCoeffs->re;
                accum.im += tmpCplxCoeffs++->im;
                                            }
            
            y->re   = accum.re;
            y++->im = accum.im;
                                   }
}

/* [EOF] polyval_dz_rt.c */ 

