/*
 *  pad_rows_cols_mixed_rt.c - Pad runtime helper function
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.9.2.2 $  $Date: 2004/04/12 23:47:20 $
 */
#include "dsp_rt.h"

/* Extra rows and extra columns */
EXPORT_FCN void MWDSP_PadAlongRowsColsMixed(
    const byte_T *u,         /* pointer to input array  (any data type, any complexity) */
    byte_T       *y,         /* pointer to output array (any data type, any complexity) */
    byte_T       *padValue,  /* pointer to value to pad output array
                              * (complexity must match complexity of y) */
    byte_T       *zero,      /* pointer to data-typed "real zero" representation */

    int_T numInpRows,              /* number of rows in the input array     */
    int_T numInpCols,              /* number of columns in the input array  */
    int_T numExtraRows,            /* number of extra rows to pad in output array */
    int_T numExtraFullOutColSamps, /* number of extra column samples to pad in output array */
    int_T bytesPerRealElement      /* number of bytes in each input sample */
    )
{
    const int_T bytesPerComplexElement = bytesPerRealElement << 1;
    int_T       rowIdx;

    /* Copy and pad each column separately */
    while (numInpCols--) {
        /* Copy real inputs to complex outputs in current column.
         * Interleave of zero imaginary parts in output.
         */
        rowIdx = numInpRows;
        while (rowIdx--) {
            memcpy(y, u, bytesPerRealElement);
            u += bytesPerRealElement;
            y += bytesPerRealElement;
            memcpy(y, zero, bytesPerRealElement);
            y += bytesPerRealElement;
        }

        /* Pad rest of current column */
        rowIdx = numExtraRows;
        while (rowIdx--) {
            memcpy(y, padValue, bytesPerComplexElement);
            y += bytesPerComplexElement;
        }
    }

    /* Fully pad the remaining output columns */
    while (numExtraFullOutColSamps--) {
        memcpy(y, padValue, bytesPerComplexElement);
        y += bytesPerComplexElement;
    }
}

/* [EOF] pad_rows_cols_mixed_rt.c */
