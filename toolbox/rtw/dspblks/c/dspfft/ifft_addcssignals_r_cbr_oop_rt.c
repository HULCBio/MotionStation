/*
 * ifft_addcssignals_r_cbr_oop_rt.c - Signal Processing Blockset IFFT run-time library components.
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.5.2.3 $  $Date: 2004/04/12 23:43:59 $
 */

#include "dspfft_rt.h"

/*
 * Add conjugate symmetric signals for double signal IFFT
 * Out-of-place.
 * 
 */
EXPORT_FCN void MWDSP_Ifft_AddCSSignals_R_Cbr_Oop(
    creal32_T *y,
    const real32_T *u,
    const int_T   nChans,
    const int_T   nRows
    )
{
    /*
     * Combine two conjugate symmetric signals for double signal algorithm
     */
    int_T i = nChans >> 1;  /* Loop over channel pairs */

    while(i--) {
        int_T    j=nRows-1, jbr=0;

        while (j--) {
            /* 
             * Add sqrt(-1)*col_2i+1 to col_2i
             */
            y[jbr].re = *u;
            y[jbr].im = *(u++ + nRows);
            {
                int_T bit = nRows;
                do { bit>>=1; jbr^=bit; } while (!(jbr & bit));
            }
        }
        /* Move last element */
        y[nRows-1].re = *u;
        y[nRows-1].im = *(u++ + nRows);
        
        u += nRows;
        y += nRows;
    }
}

/* [EOF] ifft_addcssignals_r_cbr_oop_rt.c */
