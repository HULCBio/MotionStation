/*
 * ifft_addcssignals_d_z_oop_rt.c - Signal Processing Blockset IFFT run-time library components.
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.6.2.3 $  $Date: 2004/04/12 23:43:56 $
 */

#include "dspfft_rt.h"

/*
 * Add conjugate symmetric signals for double signal IFFT
 * Out-of-place.
 * 
 * 
 */
EXPORT_FCN void MWDSP_Ifft_AddCSSignals_D_Z_Oop(
    creal_T *y,
    const real_T *u,
    const int_T   nChans,
    const int_T   nRows
    )
{
    /*
     * Interleave for double real-signal algorithm
     */
    int_T i = ((uint_T)nChans) >> 1;  /* Loop over channel pairs */

    while(i--) {
        int_T    j    = nRows;

        while(j--) {
            /* 
             * Add sqrt(-1)*col_2i+1 to col_2i
             */
            y->re     = *u;
            (y++)->im = *(u++ + nRows);
        }
        u += nRows;
    }
}

/* [EOF] ifft_addcssignals_d_z_oop_rt.c */
