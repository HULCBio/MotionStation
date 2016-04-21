/*
 *  vfdly_fir_z_rt Run-time function for Variable Fractional Delay block.
 *
 *  This function implements the case of FIR interpolation mode, 
 *  Date-type is :- double-precision, complex 
 * 
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.3.2.2 $  $Date: 2004/04/12 23:49:42 $
 *
 *  
 */

#include "dspvfdly2_rt.h"

EXPORT_FCN void MWDSP_Vfdly_FIR_Z(
     const real_T  * const filtptr, 
     const int_T           filtlen, 
     const int_T           nphases ,
     const creal_T * const buffptr, 
     const int_T           buflen, 
     creal_T             **yptr, 
     int_T                 ti,
     const int_T           buffstart , 
     const real_T          frac)
{ 
    const creal_T *in_curr = buffptr;     /* Store new input samples: */
    int_T         phase    = (int_T) (nphases * frac + 0.5); 
    ti    += phase/nphases;
    phase %= nphases;

    /* Add offset to current input pos'n in buffer, backing up by the
     * integer number of delay samples then incrementing by half the
     * filter length.  If we've backed up too far past the start of the
     * buffer, wrap:
     */
    ti = buffstart - ti + (filtlen/2 - 1);
    if (ti < 0) ti += buflen;
    in_curr += ti; /* Get pointer into buffer */

    if (ti+1 >= filtlen) {
        /* Contiguous input samples in buffer: */
        /* Point to correct polyphase filter */
        int_T   kn;
        const real_T *filt = (const real_T *)(filtptr + phase * filtlen); 
        (*yptr)->re = (*yptr)->im = 0.0;
        for(kn=0; kn<filtlen; kn++) {
            (*yptr)->re += in_curr[-kn].re * *filt;
            (*yptr)->im += in_curr[-kn].im * *filt++;
        }
        ++(*yptr);
    } else {
        /* Discontiguous input samples in buffer: */
        const real_T *filt    = (const real_T *)(filtptr + phase * filtlen);
        const int_T   k1      = ti+1;
        const int_T   k2      = filtlen-k1;
        const creal_T *in_last = in_curr-ti+buflen-1;
        int_T kn;
        (*yptr)->re = (*yptr)->im = 0.0;
        for(kn=0; kn<k1; kn++) {
            (*yptr)->re += in_curr[-kn].re * *filt;
            (*yptr)->im += in_curr[-kn].im * *filt++;
        }
        for(kn=0; kn<k2; kn++) {
            (*yptr)->re += in_last[-kn].re * *filt;
            (*yptr)->im += in_last[-kn].im * *filt++;
        }
        ++(*yptr);
    }
}

/* [EOF] vfdly_fir_z_rt.c */

