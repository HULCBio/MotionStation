/*
 *  copy_row_as_col_br_rc_rt.c - Signal Processing Blockset run-time library.
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.1.6.1 $  $Date: 2003/12/06 15:55:17 $
 */

#include "dspfft_rt.h"

/*
 * This function copies a real row from a matrix (indexed by rowIdx) into 
 * a complex column (with zero as the imaginary part) and bit-reverses
 * the data in the column. 
 */
EXPORT_FCN void MWDSP_CopyRowAsColBR_RC(
    creal32_T          *y,
    const real32_T     *x,
    const int_T       nCols,
    const int_T       nRows,
    const int_T       rowIdx
    )
{
    int_T i,indx=rowIdx, j=0;
    /* Be careful not to use "i<fftLen" for loop condition.
     * Although this would appear to work fine, there is
     * one optimization that we would miss, and one bug that
     * would occur:
     * optimization: no need to execute the bit-rev generator
     *               prior to final loop exit, since the final
     *               value isn't used when i hits fftLen-1
     * bug: the bit-rev code used here will create an infinite
     *               loop when trying to compute br(N-1).
     */
    for (i=0; i<nCols-1; i++) {
        y[j].re = x[indx]; /* Copy element into bit-rev position */
        y[j].im = 0.0F; /* Copy element into bit-rev position */
        {
            int_T bit = nCols;
            do {
                bit>>=1;
                j^=bit;
            } while (!(j & bit));
        }
        indx += nRows;
    }
    y[j].re = x[indx]; /* Copy final real element */
    y[j].im = 0.0;     /* Copy final imag element */
}


/* [EOF] copy_row_as_col_br_rc_rt.c */
