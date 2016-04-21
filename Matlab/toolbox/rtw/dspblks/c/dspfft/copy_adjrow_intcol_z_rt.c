/*
 *  copy_adjrow_intcol_z_rt.c - Signal Processing Blockset run-time library.
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.1.6.1 $  $Date: 2003/12/06 15:55:11 $
 */

#include "dspfft_rt.h"

/*
 * This function takes the rows at 'rowIdx' and 'rowIdx+1', converts them into columns with 
 * interleaving between them. 
 */

EXPORT_FCN void MWDSP_copyAdjRowsIntCol_Z(
     creal_T *y, 
     const real_T *x,
     const int_T nCols,
     const int_T nRows,
     const int_T rowIdx)
{
    int_T j =0,i=rowIdx;
    int_T totalCt = nCols * nRows;
    for (; i<totalCt; i+=nRows) {
        y[j].re = x[i]; /* Copy element into real-part of output */
        y[j++].im = x[i+1];/* Copy next element into imaginary-part of output */
    }
}
/* [EOF] copy_adjrow_intcol_z_rt.c */
