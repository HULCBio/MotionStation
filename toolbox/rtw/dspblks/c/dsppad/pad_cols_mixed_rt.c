/*
 *  pad_cols_mixed_rt.c - Pad runtime helper function
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.8.2.2 $  $Date: 2004/04/12 23:47:11 $
 */
#include "dsp_rt.h"

/* Extra rows (longer output cols) only */
EXPORT_FCN void MWDSP_PadAlongColsMixed(
    const byte_T *u,          /* pointer to input array  (any data type, any complexity) */
    byte_T       *y,          /* pointer to output array (any data type, any complexity) */
    byte_T       *padValue,   /* pointer to value to pad output array
                               * (complexity must match complexity of y)
                               */
    byte_T       *zero,       /* pointer to data-typed "real zero" representation */
    int_T numInpRows,         /* number of rows in the input array     */
    int_T numInpCols,         /* number of columns in the input array  */
    int_T numExtraRows,       /* number of extra rows to pad in output array */
    int_T bytesPerRealElement /* number of bytes per input sample */
    )
{
    const int_T bytesPerComplexElement = bytesPerRealElement << 1;
    int_T       rowIdx;

    while(numInpCols--) {
        /* Copy current input column to
         * current output column, and
         * update current output sample ptr.
         * Make sure to interleave zeros in
         * output (input is real, output complex).
         */
        rowIdx = numInpRows;
        while(rowIdx--) {
            memcpy(y, u, bytesPerRealElement);
            u += bytesPerRealElement;
            y += bytesPerRealElement;
            memcpy(y, zero, bytesPerRealElement);
            y += bytesPerRealElement;
        }

        /* Pad remaining samples for current
         * output column, and update current
         * output sample ptr.
         */
        rowIdx = numExtraRows;
        while(rowIdx--) {
            memcpy(y, padValue, bytesPerComplexElement);
            y += bytesPerComplexElement;
        }
    }
}

/* [EOF] pad_cols_mixed_rt.c */
