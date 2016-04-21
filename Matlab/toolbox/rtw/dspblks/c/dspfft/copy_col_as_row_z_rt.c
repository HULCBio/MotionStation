/*
 *  copy_col_as_row_z_rt.c - Signal Processing Blockset run-time library.
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.1.6.1 $  $Date: 2003/12/06 15:55:13 $
 */

#include "dspfft_rt.h"

/*
 * This function copies a column to a row offset by rowIdx in a matrix. 
 * Essentially copying contiguous memory location into non-contiguous
 * memory location (offset by a regular amount). 
 */
EXPORT_FCN void MWDSP_CopyColAsRow_Z(
    creal_T          *y,
    const creal_T    *x,
    const int_T       nCols,
    const int_T       nRows,
    const int_T       rowIdx
    )
{
    int_T indx;
    y += rowIdx;
    for (indx=0; indx < nCols; indx++) {
        *y   = *x++;
         y  +=  nRows;
    }
}

/* [EOF] copy_col_as_row_z_rt.c */
