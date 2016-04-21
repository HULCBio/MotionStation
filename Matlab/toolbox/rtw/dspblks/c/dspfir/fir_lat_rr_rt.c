/*
 *  FIR_Lat_RR_RT.C - Filter block runtime helper function
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.2.2.2 $  $Date: 2004/04/12 23:44:45 $
 */
#include "dsp_rt.h"

EXPORT_FCN void MWDSP_FIR_Lat_RR(const real32_T         *u,
                      real32_T               *y,
                      real32_T *             mem_base,
                      const int_T            sampsPerChan,
                      const int_T            numChans,
                      const real32_T * const K_first,
                      const int_T            ordK,
                      const boolean_T        one_fpf)
{
    int_T k;
    const int_T ordKMinusOne = ordK - 1;

    /* Loop over each channel */
    for (k=0; k < numChans; k++) {
        int_T           i  = sampsPerChan;
        const real32_T  *K = K_first;

        /* Loop over each sample */
        while (i--) {
            real32_T  *g    = mem_base;
            int_T      j    = ordKMinusOne;
            real32_T  f, g_prev, g_current=0;

            f = g_prev = *u++;
            /* Loop over ordKMinusOne stages */
            while(j--) {
                g_current  = *g + *K * f;
                f         += *g * *K++;
                *g++       = g_prev;
                g_prev     = g_current;
            }
            *y++ = f + *K++ * *g;
            *g        = g_current;
            if (one_fpf) K = K_first;
        }
        mem_base += ordK;
    } /* channel loop */
}

/* [EOF] FIR_Lat_RR_rt.c */

