/*
 * ifft_addcssignals_z_zbr_oop_rt.c - Signal Processing Blockset IFFT run-time library components.
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.6.2.3 $  $Date: 2004/04/12 23:44:01 $
 */

#include "dspfft_rt.h"

/*
 * Add conjugate symmetric signals for double signal IFFT
 * Works only for out-of-place.
 * 
 * 
 */
EXPORT_FCN void MWDSP_Ifft_AddCSSignals_Z_Zbr_OOP(
    creal_T *y,
    const creal_T *u,
    const int_T   nChans,
    const int_T   nRows
    )
{
    /*
     * Combine two conjugate symmetric signals for double signal algorithm
     */
    int_T i = nChans >> 1;  /* Loop over channel pairs */

    while(i--) {
        int_T    j=nRows-2, jbr=nRows>>1; /* Start BR counter at 1 (bit-reversed) */

        y[0].re = u->re;           /* Handle DC case separately - it is real. */
        y[0].im = (u + nRows)->re;
        u++;

        while (j--) {
            /* 
             * Add sqrt(-1)*col_2i+1 to col_2i
             */
            y[jbr].re = u->re - (u + nRows)->im;
            y[jbr].im = u->im + (u + nRows)->re;
            u++;
            {
                int_T bit = nRows;
                do { bit>>=1; jbr^=bit; } while (!(jbr & bit));
            }
        }
        /* Move last element */
        y[nRows-1].re = u->re - (u + nRows)->im;
        y[nRows-1].im = u->im + (u + nRows)->re;
        u++;
        
        u += nRows;
        y += nRows;
    }
}

/* [EOF] ifft_addcssignals_z_zbr_oop_rt.c */
