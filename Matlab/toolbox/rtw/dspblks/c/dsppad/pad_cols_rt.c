/*
 *  pad_cols_rt.c - Pad runtime helper function
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.8.2.2 $  $Date: 2004/04/12 23:47:12 $
 */
#include "dsp_rt.h"

/* Extra rows (longer output cols) only */
EXPORT_FCN void MWDSP_PadAlongCols(
    const byte_T *u,         /* pointer to input array  (any data type, any complexity) */
    byte_T       *y,         /* pointer to output array (any data type, any complexity) */
    byte_T       *padValue,  /* pointer to value to pad output array
                              * (complexity must match complexity of y)
                              */
    int_T numInpCols,        /* number of columns in the input array  */
    int_T bytesPerInpCol,    /* number of bytes in each column of input array */
    int_T numExtraRows,      /* number of extra rows to pad in output array */
    int_T bytesPerElement    /* number of bytes in each sample */
    )
{
    int_T extraRowIdx;

    while(numInpCols--) {
        /* Copy current input column to
         * current output column, and
         * update current sample ptrs.
         */
        memcpy(y, u, bytesPerInpCol);
        u += bytesPerInpCol;
        y += bytesPerInpCol;

        /* Pad remaining samples for current
         * output column, and update current
         * output sample ptr.
         */
        extraRowIdx = numExtraRows;
        while(extraRowIdx--) {
            memcpy(y, padValue, bytesPerElement);
            y += bytesPerElement;
        }
    }
}

/* [EOF] pad_cols_rt.c */
