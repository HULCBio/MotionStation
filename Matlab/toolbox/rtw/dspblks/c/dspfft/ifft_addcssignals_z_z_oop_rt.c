/*
 * ifft_addcssignals_z_z_oop_rt.c - Signal Processing Blockset IFFT run-time library components.
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.7.2.3 $  $Date: 2004/04/12 23:44:00 $
 */

#include "dspfft_rt.h"

/*
 * Add conjugate symmetric signals for double signal IFFT
 * Works for out-of-place.
 */
EXPORT_FCN void MWDSP_Ifft_AddCSSignals_Z_Z_OOP(
    creal_T *y,
    const creal_T *u,
    const int_T   nChans,
    const int_T   nRows
    )
{
    /*
     * Interleave for double real-signal algorithm
     */
    int_T i = ((uint_T)nChans) >> 1;  /* Loop over channel pairs */

    while(i--) {
        int_T    j = nRows-1;

        y->re = u->re;           /* Handle DC case separately - it is real. */
        (y++)->im = (u++ + nRows)->re;

        while(j--) {
            /* 
             * Add sqrt(-1)*col_2i+1 to col_2i
             */
            y->re     = u->re - (u + nRows)->im;
            (y++)->im = u->im + (u + nRows)->re;
            u++;
        }
        u += nRows;
    }
}

/* [EOF] ifft_addcssignals_z_z_oop_rt.c */
