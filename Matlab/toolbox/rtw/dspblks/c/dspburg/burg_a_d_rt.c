/* 
 * burg_a_d_rt - Signal Processing Blockset Burg AR Estimation run-time function 
 * 
 * Specifications: 
 * 
 * - Real Double precision inputs/outputs 
 * - {A} output only 
 * 
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.5.2.3 $  $Date: 2004/04/12 23:42:13 $ 
 */ 

#include "dsp_rt.h"

EXPORT_FCN void MWDSP_Burg_A_D(const int_T  N,             /* Input array length */
                    const int_T  order,         /* Order of estimation */
                    const real_T *u,            /* Input pointer */
                          real_T *ef,           /* Intermediate variable */
                          real_T *eb,           /* Intermediate variable */
                          real_T *anew,         /* Intermediate AR coeffients */
                          real_T *Acoef,        /* A - Output pointer */
                          real_T *Error
                    )
{
    real_T E = 0.0;                    /* Error */
    int_T  k;                          /* Local variable */

    /* Preset AR coefficients: */
    {
        real_T *a = Acoef;
        *a++ = 1.0;             /* First AR coefficient is 1 */
    }
    
    /* Copy inputs and compute initial prediction error: */
    for (k=0; k<N; k++) {
        real_T x = *u++;
        ef[k] = eb[k] = x;
        E += x*x;
    }
    E /= N;
    
    for(k=1; k<=order; k++) {
        int_T   n;
        real_T KK;

        /* Calculate reflection coefficient: */
        {
            real_T *efp = ef+k;
            real_T *ebp = eb+k-1;
            real_T  num = 0.0;
            real_T  den = 0.0;
            
            for (n=k; n <= N-1; n++) {
                const real_T v1 = *efp++;
                const real_T v2 = *ebp++;
                den    += v1*v1 + v2*v2;
                num    += v1*v2;
            }
            KK = -2 * num / den;
        }

        /* Update AR polynomial: */
        {
            int_T   i;
            real_T *a    = Acoef;
            for (i=1; i <= k-1; i++) {
                anew[i]= a[i] + KK * a[k-i];
            }
            anew[k] = KK;

            /* Update polynomial for next iteration: */
            for (i=1; i <= k; i++) {
                a[i] = anew[i];
            }
        }
        
        /* Update prediction error terms: */
        for (n=N-1; n >= k+1; n--) {
            ef[n] += KK * eb[n-1];
            eb[n-1] = eb[n-2] + KK * ef[n-1];
        }
        
        /* Update prediction error: */
        E *= (1.0 - KK*KK);
    }
    *(real_T *)Error = E;
}

/* [EOF] burg_a_d_rt.c */

