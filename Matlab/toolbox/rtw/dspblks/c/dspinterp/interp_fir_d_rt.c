/*
 *  INTERP_FIR_D_RT Helper function for window block.
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.7.2.2 $  $Date: 2004/04/12 23:46:25 $
 */
#include "dspinterp_rt.h"

EXPORT_FCN void MWDSP_Interp_FIR_D(real_T *y, const real_T * const u, const real_T *iptr, const int_T nSamps, 
                        int_T nChans, const int_T nSampsI, const int_T nChansI, 
                        const real_T * const filt, const int_T filtlen, const int_T nphases)
{
    int_T offset = 0;
    int_T hlen = filtlen/2;  /* half-length filt length */

    while(nChans-- > 0) {         /* Loop over channels in input data */
        int_T nSampsI_tmp = nSampsI;
        while(nSampsI_tmp-- > 0) {    /* Loop over interp points in channel */
            const real_T *uptr = u;
            real_T        t  = *iptr++;
            int_T ti;
            if (t < 1.0) {
                t = 1.0;
            } else if (t > nSamps) {
                t = (real_T)nSamps;
            }
            ti = (int_T)t;  /* Integer part of interpolation index value */

            if ((ti < hlen) || ((nSamps-ti) < hlen)) {
                /* Linear Interpolation Mode*/
                if (ti == nSamps) {
                    *y++ = uptr[offset + ti - 1];
                } else {
                    real_T frac = t - ti;
                    *y++ = uptr[offset + ti-1] * (1-frac)
                              + uptr[offset + ti  ] * frac;
                }
            }
            else {
                /* FIR Interpolation Mode
                 *   phase must be in the semi-open interval [0, nphases)
                 *   t-ti = fractional part of delay time
                 */
                const int_T  phase = (int_T) (nphases * (t-ti));
                const real_T *filtptr  = filt + phase * filtlen;
                int_T        kn    = filtlen;

                uptr += (ti-hlen) + offset;
                *y = 0.0;
                while(kn-- > 0) {
                    *y += *uptr++ * *filtptr++;
                }
                y++;  /* align for next channel of data */
            }
        }  /* sample loop */

        if (nChansI == 1) iptr -= nSampsI;
        offset += nSamps;  /* next channel of input data */

    } /* channel loop */
}

/* [EOF] interp_fir_d_rt.c */
