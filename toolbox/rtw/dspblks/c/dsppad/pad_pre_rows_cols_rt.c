/*
 *  pad_pre_rows_cols_rt.c - Pad runtime helper function
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.5.2.2 $  $Date: 2004/04/12 23:47:17 $
 */
#include "dsp_rt.h"

/* Extra rows and extra columns */
EXPORT_FCN void MWDSP_PadPreAlongRowsCols(
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

    /* Fully pad the initial output columns */
    while (numExtraFullOutColSamps--) {
        memcpy(y, padValue, bytesPerElement);
        y += bytesPerElement;
    }

    /* Pad and copy each remaining column separately */
    while (numInpCols--) {
        /* Pad initial part of current column */
        rowIdx = numExtraRows;
        while (rowIdx--) {
            memcpy(y, padValue, bytesPerElement);
            y += bytesPerElement;
        }

        /* Copy full input column samples
         * to current output column (remaining)
         */
        memcpy(y, u, bytesPerInpCol);
        u += bytesPerInpCol;
        y += bytesPerInpCol;
    }
}

/* [EOF] pad_pre_rows_cols_rt.c */
