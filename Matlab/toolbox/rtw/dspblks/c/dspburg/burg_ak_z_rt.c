/* 
 * burg_ak_z_rt - Signal Processing Blockset Burg AR Estimation run-time function 
 * 
 * Specifications: 
 * 
 * - Complex Double precision inputs/outputs 
 * - {A and K} output.
 * 
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.5.2.3 $  $Date: 2004/04/12 23:42:19 $ 
 */ 

#include "dsp_rt.h"

EXPORT_FCN void MWDSP_Burg_AK_Z(const int_T    N,             /* Input array length */
                     const int_T    order,         /* Order of estimation */
                     const creal_T *u,             /* Input pointer */
                           creal_T *ef,            /* Intermediate variable */
                           creal_T *eb,            /* Intermediate variable */
                           creal_T *anew,          /* Intermediate AR coeffients */
                           creal_T *Acoef,         /* A - Output pointer */
                           creal_T *Kcoef,         /* A - Output pointer */
                           real_T  *Error
                     )
{
    real_T E = 0.0;                    /* Error */
    int_T  k;                          /* Local variable */


    /* Preset AR coefficients: */
    {
        creal_T *a = Acoef;
        a->re      = 1.0;          /* First AR coefficient is 1 */
        (a++)->im  = 0.0;
    }
    
    /* Copy inputs and compute initial prediction error: */
    for (k=0; k<N; k++) {
        creal_T x = *u++;
        ef[k] = eb[k] = x;
        E += CMAGSQ(x);
    }
    E /= N;
    
    for(k=1; k<=order; k++) {
        int_T   n;
        creal_T KK;

        /* Calculate reflection coefficient: */
        {
            creal_T *efp = ef+k;
            creal_T *ebp = eb+k-1;
            creal_T  num = {0.0, 0.0};
            real_T   den = 0.0;
            
            for (n=k; n <= N-1; n++) {
                const creal_T v1 = *efp++;
                const creal_T v2 = *ebp++;
                den    += CMAGSQ(v1) + CMAGSQ(v2);
                num.re += CMULT_YCONJ_RE(v1, v2);
                num.im += CMULT_YCONJ_IM(v1, v2);
            }
            KK.re = -2 * num.re / den;
            KK.im = -2 * num.im / den;
        }

        Kcoef[k-1] = KK;

        /* Update AR polynomial: */
        {
            int_T    i;
            creal_T *a    = Acoef;
            for (i=1; i <= k-1; i++) {
                creal_T Ka;
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
            creal_T t;

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
        E *= (1.0 - CMAGSQ(KK));
    }
    *(real_T *)Error = E;
}

/* [EOF] burg_ak_z_rt.c */

