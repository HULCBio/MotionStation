/*
 *  pad_rows_cols_rt.c - Pad runtime helper function
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.9.2.2 $  $Date: 2004/04/12 23:47:21 $
 */
#include "dsp_rt.h"

/* Extra rows and extra columns */
EXPORT_FCN void MWDSP_PadAlongRowsCols(
    const byte_T *u,         /* pointer to input array  (any data type, any complexity) */
    byte_T       *y,         /* pointer to output array (any data type, any complexity) */
    byte_T       *padValue,  /* pointer to value to pad output array
                              * (complexity must match complexity of y)
                              */
    int_T numInpCols,        /* number of columns in the input array  */
    int_T bytesPerInpCol,    /* number of bytes in each column of input array */
    int_T numExtraRows,      /* number of extra rows to pad in output array */
    int_T numExtraFullOutColSamps, /* number of extra column samples to pad in output array */
    int_T bytesPerElement    /* number of bytes in each sample */
    )
{
    int_T rowIdx;

    /* Copy and pad each column separately
     * (using the input columns in the loop index)
     */
    while (numInpCols--) {
        /* Copy full input column samples
         * to current output column
         */
        memcpy(y, u, bytesPerInpCol);
        u += bytesPerInpCol;
        y += bytesPerInpCol;

        /* Pad rest of current column */
        rowIdx = numExtraRows;
        while (rowIdx--) {
            memcpy(y, padValue, bytesPerElement);
            y += bytesPerElement;
        }
    }

    /* Fully pad the remaining output columns */
    while (numExtraFullOutColSamps--) {
        memcpy(y, padValue, bytesPerElement);
        y += bytesPerElement;
    }
}

/* [EOF] pad_rows_cols_rt.c */
