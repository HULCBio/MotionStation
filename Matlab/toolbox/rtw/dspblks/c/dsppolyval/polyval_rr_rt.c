/* 
 * polyval_rr_rt.c - Signal Processing Blockset Polynomial Evaluation run-time function 
 * 
 * Specifications: 
 * 
 * - Real (single precision) Inputs, 
 * - Real (single precision) Coefficients, 
 * - Real (single precision) Outputs.  
 *  
 * 
 *  Copyright 1995-2004 The MathWorks, Inc.
 *  $Revision: 1.3.2.4 $  $Date: 2004/04/12 23:47:39 $ 
 */ 
#include "dsp_rt.h" 

EXPORT_FCN void MWDSP_polyval_RR(
    const real32_T *u,         /* Input pointer */ 
          real32_T *y,         /* Output pointer */ 
    const real32_T *pCoeffs,   /* Pointer to coefficients */
    const int_T     N,         /* Number of coefficients */
    const int_T     n          /* Width of INPORT1*/
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
        register const real32_T *tmpReCoeffs = pCoeffs;
        register       real32_T  accum       = *tmpReCoeffs++;
        register       real32_T  x           = *u++;
        register       int_T     j;
        
        for (j = 1; j < N; j++) {
            accum *= x;
            accum += *tmpReCoeffs++;
        }
        
        *y++ = accum;
    }
}

/* [EOF] polyval_rr_rt.c */ 

