/*
 * copy_row_as_col_z_rt.c - Signal Processing Blockset run-time library.
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.1.6.1 $  $Date: 2003/12/06 15:55:22 $
 */

#include "dspfft_rt.h"

/*
 * This function copies a row from within a matrix into a column. 
 * Essentially copying non-contiguous memory (by a regular offset) into
 * contiguous memory location. 
 * The last parameter of this function controls which row from the input 
 * matrix is being copied into a column. 
 */
EXPORT_FCN void MWDSP_CopyRowAsCol_Z(
    creal_T          *y,
    const creal_T    *x,
    const int_T       nCols,
    const int_T       nRows,
    const int_T       rowIdx
    )
{
    int_T indx;
    x += rowIdx; 
    for (indx=0; indx < nCols; indx++) {
        *y++  = *x;
         x   +=  nRows;
    }
}

/* [EOF] copy_row_as_col_z_rt.c */
