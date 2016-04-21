/*
 *  randsrc_gc_r_rt.c
 *  DSP Random Source Run-Time Library Helper Function
 *
 *  Copyright 1995-2004 The MathWorks, Inc.
 *  $Revision: 1.3.4.3 $ $Date: 2004/04/12 23:48:28 $
 */

#include "dsprandsrc32bit_rt.h"
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
 * transformed by a factor of sqrt(12.0 * ctlLen) (to account for the
 * transformation above: 12*var*n/2=6*var*n) prior to the call to this function
 */

EXPORT_FCN void MWDSP_RandSrc_GC_R(real32_T *y,          /* output signal */          
                        const real32_T *mean, /* vector of means */        
                        int_T meanLen,        /* length of mean vector */     
                        const real32_T *std,  /* vector of xformed-std-devs */
                        int_T stdLen,         /* length of std vector */    
                        real32_T *state,      /* state vectors */           
                        int_T nChans,         /* number of channels */      
                        int_T nSamps,         /* number of samples per chan*/  
                        real32_T* cltVec,     /* work space for uniform 
                                               * variates */
                        int_T cltLen)         /* length of clt vector */
{
    real32_T min = 0.0F;
    real32_T max = 1.0F;
    real32_T sum;
    int_T i;

    while (nChans--) {
        int_T nS = nSamps;
        while (nS--) {
            i = cltLen;
            sum = 0.0F;
            /* generate uniform variates */
            MWDSP_RandSrc_U_R(cltVec, &min, 1, &max, 1, state, 1, cltLen);
            /* transform to approximate Gaussian variate and scale */
            while (i--) {
                sum += cltVec[i];
            }
            *y++ = *mean + (*std * (sum/cltLen - 0.5F));
        }
        /* advance state, mean, std */
        state += 35;
        if (meanLen > 1) min++;
        if (stdLen > 1) std++;
    }

}

/* [EOF] randsrc_gc_r_rt.c */
