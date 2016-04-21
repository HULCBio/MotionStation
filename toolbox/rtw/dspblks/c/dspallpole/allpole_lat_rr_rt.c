/*
 *  AllPole_Lat_RR_RT.C - Filter block runtime helper function
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.2.2.2 $  $Date: 2004/04/12 23:41:05 $
 */
#include "dsp_rt.h"

EXPORT_FCN void MWDSP_AllPole_Lat_RR(const real32_T         *u,
                          real32_T               *y,
                          real32_T               *mem_first,
                          const int_T            sampsPerChan,
                          const int_T            numChans,
                          const real32_T * const K_first,
                          const int_T            ordK,
                          const boolean_T        one_fpf)
{
    const int_T     ordKMinusOne = ordK - 1;
    real32_T       *mem_last     = (real32_T *)mem_first + ordKMinusOne;
    const real32_T *K_last       = (const real32_T *)K_first + ordKMinusOne; 
    int_T           k;

    /* Loop over each channel */
    for (k=0; k < numChans; k++) {
        int_T          i  = sampsPerChan;
        const real32_T *K = K_last;

        /* Loop over each sample */
        while (i--) {
            real32_T  *g = mem_last;
            real32_T  f  = (*u++) - (*K--) * (*g);
            int_T     j  = ordKMinusOne;

            while(j--) {
                f -= *K * *(--g);
                *(g + 1) = f * (*K--) + (*g);
            }
            *y++ = *g = f;

            /* points to last coefficient in next filter set */
            if (one_fpf) K  = K_last;
            else         K += 2*ordK;
        }
        mem_last += ordK;
    } /* channel loop */
}

/* [EOF] AllPole_Lat_RR_rt.c */

