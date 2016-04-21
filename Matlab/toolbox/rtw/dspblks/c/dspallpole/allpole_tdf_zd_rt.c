/*
 *  ALLPOLE_TDF_ZD_RT.C - Filter block runtime helper function
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.2.2.2 $  $Date: 2004/04/12 23:41:22 $
 */
#include "dsp_rt.h"

EXPORT_FCN void MWDSP_AllPole_TDF_ZD(const creal_T         *u,
                          creal_T               *y,
                          creal_T * const       mem_base,
                          const int_T           numDelays,
                          const int_T           sampsPerChan,
                          const int_T           numChans,
                          const real_T * const  den,
                          const int_T           ordDEN,
                          const boolean_T       one_fpf)
{
    int_T k;

    /* Loop over each input channel: */
    for (k=0; k < numChans; k++) {
        const real_T  *dentmp = den;
        int_T            i = sampsPerChan;
        while (i--) {
            creal_T *filt_mem  = mem_base + k * numDelays; /* state memory for this channel */
            creal_T *next_mem  = filt_mem + 1;	
            int_T   j          = ordDEN;

            dentmp++;  /* All denominator coeffs are assumed to be normalized
                       so that the algorithm starts at a[1] */

            /* Compute the output value
             * y[n] = x[n] + D0[n]
             */
            y->re     = u->re     + filt_mem->re;
            y->im     = (u++)->im + filt_mem->im;

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
            if (one_fpf) dentmp = den;

        } /* frame loop */
    } /* channel loop */
}

/* [EOF] allpole_tdf_ZD_rt.c */

