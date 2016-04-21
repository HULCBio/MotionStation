/*
 *  pad_copy_io_trunc_cols_rt.c - Pad runtime helper function
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.10.2.2 $  $Date: 2004/04/12 23:47:13 $
 */
#include "dsp_rt.h"

EXPORT_FCN void MWDSP_PadCopyOnlyTruncAlongCols(
    const byte_T *u,       /* pointer to input array  (any data type, any complexity) */
    byte_T       *y,       /* pointer to output array (any data type, any complexity) */
    int_T bytesPerInpCol,  /* number of bytes in each column of input array */
    int_T bytesPerOutCol,  /* number of bytes in each column of output array */
    int_T numOutCols       /* number of columns in the output array  */
    )
{
    while (numOutCols--) {
        memcpy(y, u, bytesPerOutCol);
        y += bytesPerOutCol;
        u += bytesPerInpCol;
    }
}

/* [EOF] pad_copy_io_trunc_cols_rt.c */
