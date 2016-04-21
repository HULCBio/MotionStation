/* 
 * burg_a_c_rt - Signal Processing Blockset Burg AR Estimation run-time function 
 * 
 * Specifications: 
 * 
 * - Complex Single precision inputs/outputs 
 * - {A} output only 
 * 
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.5.2.3 $  $Date: 2004/04/12 23:42:12 $ 
 */ 

#include "dsp_rt.h"

EXPORT_FCN void MWDSP_Burg_A_C(const int_T      N,             /* Input array length */
                    const int_T      order,         /* Order of estimation */
                    const creal32_T *u,             /* Input pointer */
                          creal32_T *ef,            /* Intermediate variable */
                          creal32_T *eb,            /* Intermediate variable */
                          creal32_T *anew,          /* Intermediate AR coeffients */
                          creal32_T *Acoef,         /* A - Output pointer */
                          real32_T  *Error
                    )
{
    real32_T E = 0.0F;                       /* Error */
    int_T    k;                              /* Local variable */

    /* Preset AR coefficients: */
    {
        creal32_T *a = Acoef;
        a->re      = 1.0F;          /* First AR coefficient is 1 */
        (a++)->im  = 0.0F;
    }
    
    /* Copy inputs and compute initial prediction error: */
    for (k=0; k<N; k++) {
        creal32_T x = *u++;
        ef[k] = eb[k] = x;
        E += CMAGSQ(x);
    }
    E /= N;
    
    for(k=1; k<=order; k++) {
        int_T   n;
        creal32_T KK;

        /* Calculate reflection coefficient: */
        {
            creal32_T *efp = ef+k;
            creal32_T *ebp = eb+k-1;
            creal32_T  num = {0.0F, 0.0F};
            real32_T   den = 0.0F;
            
            for (n=k; n <= N-1; n++) {
                const creal32_T v1 = *efp++;
                const creal32_T v2 = *ebp++;
                den    += CMAGSQ(v1) + CMAGSQ(v2);
                num.re += CMULT_YCONJ_RE(v1, v2);
                num.im += CMULT_YCONJ_IM(v1, v2);
            }
            KK.re = -2 * num.re / den;
            KK.im = -2 * num.im / den;
        }

        /* Update AR polynomial: */
        {
            int_T    i;
            creal32_T *a    = Acoef;
            for (i=1; i <= k-1; i++) {
                creal32_T Ka;
                Ka.re = CMULT_YCONJ_RE(KK, a[k-i]);
                Ka.im = CMULT_YCONJ_IM(KK, a[k-i]);
                anew[i].re = a[i].re + Ka.re;
                anew[i].im = a[i].im + Ka.im;
            }
            anew[k] = KK;

            /* Update polynomial for next iteration: */
            for (i=1; i <= k; i++) {
                a[i] = anew[i];
            }
        }
        
        /* Update prediction error terms: */
        for (n=N-1; n >= k+1; n--) {
            creal32_T t;

            /* ef[j] += K * eb[n-1]; */
            t.re = CMULT_RE(KK, eb[n-1]);
            t.im = CMULT_IM(KK, eb[n-1]);
            ef[n].re += t.re;
            ef[n].im += t.im;

            /* eb[j]  = eb[n-1] + K * ef_old; */
            t.re = CMULT_XCONJ_RE(KK, ef[n-1]);
            t.im = CMULT_XCONJ_IM(KK, ef[n-1]);
            eb[n-1].re = eb[n-2].re + t.re;
            eb[n-1].im = eb[n-2].im + t.im;
        }
        
        /* Update prediction error: */
        E *= (1.0F - CMAGSQ(KK));
    }
    *(real32_T *)(Error) = E;
}

/* [EOF] burg_a_c_rt.c */
