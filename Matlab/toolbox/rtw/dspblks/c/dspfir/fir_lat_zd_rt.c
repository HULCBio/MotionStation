/*
 *  FIR_Lat_ZD_RT.C - Filter block runtime helper function
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.2.2.2 $  $Date: 2004/04/12 23:44:46 $
 */
#include "dsp_rt.h"

EXPORT_FCN void MWDSP_FIR_Lat_ZD(const creal_T        *u,
                      creal_T              *y,
                      creal_T *            mem_base,
                      const int_T          sampsPerChan,
                      const int_T          numChans,
                      const real_T * const K_first,
                      const int_T          ordK,
                      const boolean_T      one_fpf)
{
    int_T k;
    const int_T ordKMinusOne = ordK - 1;

    /* Loop over each channel */
    for (k=0; k < numChans; k++) {
        int_T         i  = sampsPerChan;
        const real_T  *K = K_first;

        /* Loop over each sample */
        while (i--) {
            creal_T  *g = mem_base;
            int_T     j = ordKMinusOne;
            creal_T   f, g_prev;
            creal_T   g_current = {(real_T) 0.0, (real_T) 0.0};

            f = g_prev = *u++;
            /* Loop over ordKMinusOne stages */
            while(j--) {
                g_current.re = g->re + *K * f.re;
                g_current.im = g->im + *K * f.im;
                f.re         = f.re + g->re * *K;
                f.im         = f.im + g->im * *K++;
                *g++         = g_prev;
                g_prev       = g_current;
            }
            y->re     = f.re + *K * g->re;
            (y++)->im = f.im + *K++ * g->im;
            *g = g_current;
            if (one_fpf) K = K_first;
        }
        mem_base += ordK;
    } /* channel loop */
}

/* [EOF] FIR_Lat_ZD_rt.c */

