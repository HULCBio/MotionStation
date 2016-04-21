/*
 *  FIR_Lat_DZ_RT.C - Filter block runtime helper function
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.2.2.2 $  $Date: 2004/04/12 23:44:43 $
 */
#include "dsp_rt.h"

EXPORT_FCN void MWDSP_FIR_Lat_DZ(const real_T          *u,
                      creal_T               *y,
                      creal_T *             mem_base,
                      const int_T           sampsPerChan,
                      const int_T           numChans,
                      const creal_T * const K_first,
                      const int_T           ordK,
                      const boolean_T       one_fpf)
{
    int_T k;
    const int_T ordKMinusOne = ordK - 1;

    /* Loop over each channel */
    for (k=0; k < numChans; k++) {
        int_T          i  = sampsPerChan;
        const creal_T  *K = K_first;

        /* Loop over each sample */
        while (i--) {
            creal_T  *g   = mem_base;
            int_T    j    = ordKMinusOne;
            creal_T  f, g_prev;
            creal_T  g_current = {(real_T)0.0, (real_T)0.0};

            f.re   = *u++;
            f.im   = 0.0;
            g_prev = f;
            /* Loop over ordKMinusOne stages */
            while(j--) {
                g_current.re  = g->re + CMULT_XCONJ_RE(*K, f);
                g_current.im  = g->im + CMULT_XCONJ_IM(*K, f);
                f.re  += CMULT_RE(*g, *K);
                f.im  += CMULT_IM(*g, *K);
                ++K;
                *g++ = g_prev;
                g_prev   = g_current;
            }
            y->re     = f.re + CMULT_RE(*K, *g);
            (y++)->im = f.im + CMULT_IM(*K, *g);
            ++K;
            *g = g_current;
            if (one_fpf) K = K_first;
        }
        mem_base += ordK;
    } /* channel loop */
}

/* [EOF] FIR_Lat_DZ_rt.c */

