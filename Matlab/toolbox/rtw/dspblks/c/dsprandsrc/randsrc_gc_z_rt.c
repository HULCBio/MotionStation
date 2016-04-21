/*
 *  randsrc_gc_z_rt.c
 *  DSP Random Source Run-Time Library Helper Function
 *
 *  Copyright 1995-2004 The MathWorks, Inc.
 *  $Revision: 1.2.4.3 $ $Date: 2004/04/12 23:48:29 $
 */

#include "dsprandsrc64bit_rt.h"
#include <math.h>

/* This routine calculates an approximate Gaussian variable from 
 * a sample of Uniform variates.  If we have n uniform variates 
 * X_1,...,X_n from the U(0,1) distribution (i.e., mean=0.5, 
 * var=sqrt(1/12)), then the distribution of the variate Z defined
 * by
 *    Z = sqrt(n)/sigma*(sum(X_i)/n - mean)
 * or, for the U(0,1) distribution
 *    Z = sqrt(12*n)*(sum(X_i)/n - 0.5)
 * approaches the N(0,1) distribution as n -> infinity.
 * We can scale this variable by the input mean and variance to get:
 *    Y = mean + sqrt(var)*Z
 * or 
 *    Y = mean + sqrt(12*var*n)*(sum(x_i)/n - 0.5)
 */

/* Note that the STANDARD DEVIATION input vector 'std' is assumed to be 
 * transformed by a factor of sqrt(6.0 * cltLen) (to account for the split
 * between real and imaginary components as well as the transformation above:
 * 12*var*n/2=6*var*n) prior to the call to this function
 */

EXPORT_FCN void MWDSP_RandSrc_GC_Z(creal64_T *y,           /* output signal */
                        const creal64_T *mean,  /* vector of means */
                        int_T meanLen,          /* length of mean vector */
                        const real64_T *std,    /* vector of xformed-std-devs*/
                        int_T stdLen,           /* length of std vector */    
                        real64_T *state,        /* state vectors */    
                        int_T nChans,           /* number of channels */
                        int_T nSamps,           /* number of samples per chan*/
                        real64_T* cltVec,       /* work space for uniform 
                                                 * variates */
                        int_T cltLen)           /* length of clt vector */  
 {
    /* Treat real and imag parts as separate samples; that is,
     * samps = 2*nSamps, fill real and imag parts of output separately
     * Mean and std vector elements apply to both parts.
     */
    real64_T *yPtr = (real64_T *)y;
    const real64_T *meanPtr = (const real64_T*)mean;
    int_T newNSamps = 2*nSamps;
    real64_T min = 0.0;
    real64_T max = 1.0;
    real64_T sum;
    int_T i;

    while (nChans--) {
        int_T nS = newNSamps;
        while (nS--) {
            i = cltLen;
            sum = 0.0;
            /* generate uniform variates */
            MWDSP_RandSrc_U_D(cltVec, &min, 1, &max, 1, state, 1, cltLen);
            /* transform to approximate Gaussian variate and scale */
            while (i--) {
                sum += cltVec[i];
            }
            *yPtr++ = meanPtr[1-(nS&1)] + (*std * (sum/cltLen - 0.5));
        }
        /* advance state, mean, std */
        state += 35;
        if (meanLen > 1) meanPtr += 2;
        if (stdLen > 1) std++;
    }
}

/* [EOF] randsrc_gc_z_rt.c */
