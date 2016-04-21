/* 
 * burg_k_r_rt - Signal Processing Blockset Burg AR Estimation run-time function 
 * 
 * Specifications: 
 * 
 * - Real Single precision inputs/outputs 
 * - {K} output.
 * 
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.5.2.3 $  $Date: 2004/04/12 23:42:22 $ 
 */ 

#include "dsp_rt.h"

EXPORT_FCN void MWDSP_Burg_K_R(const int_T     N,             /* Input array length */
                    const int_T     order,         /* Order of estimation */
                    const real32_T *u,             /* Input pointer */
                          real32_T *ef,            /* Intermediate variable */
                          real32_T *eb,            /* Intermediate variable */
                          real32_T *Kcoef,         /* A - Output pointer */
                          real32_T *Error
                    )
{
    real32_T E = 0.0F;                       /* Error */
    int_T    k;                              /* Local variable */

    /* Copy inputs and compute initial prediction error: */
    for (k=0; k<N; k++) {
        real32_T x = *u++;
        ef[k] = eb[k] = x;
        E += x*x;
    }
    E /= N;
    
    for(k=1; k<=order; k++) {
        int_T   n;
        real32_T KK;

        /* Calculate reflection coefficient: */
        {
            real32_T *efp = ef+k;
            real32_T *ebp = eb+k-1;
            real32_T  num = 0.0F;
            real32_T  den = 0.0F;
            
            for (n=k; n <= N-1; n++) {
                const real32_T v1 = *efp++;
                const real32_T v2 = *ebp++;
                den    += v1*v1 + v2*v2;
                num    += v1*v2;
            }
            KK = -2 * num / den;
        }

        Kcoef[k-1] = KK;

        /* Update prediction error terms: */
        for (n=N-1; n >= k+1; n--) {
            ef[n] += KK * eb[n-1];
            eb[n-1] = eb[n-2] + KK * ef[n-1];
        }
        
        /* Update prediction error: */
        E *= (1.0F - KK*KK);
    }
    *(real32_T *)Error = E;
}

/* [EOF] burg_k_r_rt.c */

