/*
 *  copy_adjrow_intcol_br_z_rt.c - Signal Processing Blockset run-time library.
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.1.6.1 $  $Date: 2003/12/06 15:55:09 $
 */

#include "dspfft_rt.h"

/*
 * This function takes the rows at 'rowIdx' and 'rowIdx+1', converts them into columns with 
 * interleaving between them and bit-reverses at the same time. 
 */

EXPORT_FCN void MWDSP_copyAdjRowsIntColBR_Z(
     creal_T *y, 
     const real_T *x,
     const int_T nCols,
     const int_T nRows,
     const int_T rowIdx)
{
    int_T j =0,i=rowIdx;
    int_T totalCt = (nCols-1) * nRows;
    for (; i<totalCt; i+=nRows) {
        y[j].re = x[i]; /* Copy element into bit-rev position */
        y[j].im = x[i+1];
        {
            int_T bit = nCols;
            do {
                bit>>=1;
                j^=bit;
            } while (!(j & bit));
        }
    }
    y[j].re = x[i]; /* Copy final element */
    y[j].im = x[i+1]; /* Copy final element */
}
/* [EOF] copy_adjrow_intcol_br_c_rt.c */
