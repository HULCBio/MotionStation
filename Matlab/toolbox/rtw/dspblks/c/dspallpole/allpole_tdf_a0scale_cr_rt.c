/*
 *  ALLPOLE_TDF_A0SCALE_CR_RT.C - Filter block runtime helper function
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.2.2.2 $  $Date: 2004/04/12 23:41:09 $
 */
#include "dsp_rt.h"

EXPORT_FCN void MWDSP_AllPole_TDF_A0Scale_CR(const creal32_T         *u,
                                  creal32_T               *y,
                                  creal32_T * const       mem_base,
                                  const int_T             numDelays,
                                  const int_T             sampsPerChan,
                                  const int_T             numChans,
                                  const real32_T * const  den,
                                  const int_T             ordDEN,
                                  const boolean_T         one_fpf)
{
    int_T k;

    /* Loop over each input channel: */
    for (k=0; k < numChans; k++) {
        const real32_T  *dentmp = den;
        int_T            i = sampsPerChan;
        real32_T         invA0;
        invA0 = 1 / *dentmp;
        while (i--) {
            creal32_T *filt_mem  = mem_base + k * numDelays; /* state memory for this channel */
            creal32_T *next_mem  = filt_mem + 1;	
            int_T   j            = ordDEN;
            creal32_T sum;

            if (one_fpf) dentmp = den;
            else         invA0 = 1 / *dentmp;
            
            /* Compute the output value
             * y[n] = x[n] + D0[n]*(1/a0)
             */
            sum.re    =   u->re + filt_mem->re;
            sum.im    =  (u++)->im + filt_mem->im;
            y->re     = sum.re *  invA0;
            y->im     = sum.im *  invA0;
            dentmp++;

            /* Update filter states
             *   D0[n+1] = D1[n] - y[n]*a1
             *   D1[n+1] = D2[n] - y[n]*a2
             *   ...
             */
            while (j--) {
                filt_mem->re     = next_mem->re     - y->re * *dentmp;
                (filt_mem++)->im = (next_mem++)->im - y->im * *dentmp++;
            }

            y++;

        } /* frame loop */
    } /* channel loop */
}

/* [EOF] allpole_tdf_a0scale_cr_rt.c */

