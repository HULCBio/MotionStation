/* 
 * polyval_dd_rt.c - Signal Processing Blockset Polynomial Evaluation run-time function 
 * 
 * Specifications: 
 * 
 * - Real (double precision) Inputs,   
 * - Real (double precision) Coefficients,
 * - Real (double precision) Outputs.
 *  
 * 
 *  Copyright 1995-2004 The MathWorks, Inc.
 *  $Revision: 1.3.2.4 $  $Date: 2004/04/12 23:47:36 $ 
 */
#include "dsp_rt.h" 

EXPORT_FCN void MWDSP_polyval_DD(
    const real_T *u,            /* Input pointer */
          real_T *y,            /* Output pointer */ 
    const real_T *pCoeffs,      /* Pointer to coefficients */
    const int_T   N,            /* Number of coefficients */
    const int_T   n             /* Width of INPORT1*/ 
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
    for (i = 0; i < n; i++) {
        register const real_T *tmpReCoeffs = pCoeffs;
        register       real_T  accum       = *tmpReCoeffs++;
        register       real_T  x           = *u++;
        register       int_T   j;
        
        for (j = 1; j < N; j++) {
	    accum *= x;
            accum += *tmpReCoeffs++;
        }
        *y++ = accum;
    }
}

/* [EOF] polyval_dd_rt.c */ 

