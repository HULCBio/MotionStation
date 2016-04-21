/*
 *  pad_rows_rt.c - Pad runtime helper function
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.8.2.2 $  $Date: 2004/04/12 23:47:23 $
 */
#include "dsp_rt.h"

/* Extra columns (longer output rows) only */
EXPORT_FCN void MWDSP_PadAlongRows(
    const byte_T *u,         /* pointer to input array  (any data type, any complexity) */
    byte_T       *y,         /* pointer to output array (any data type, any complexity) */
    byte_T       *padValue,  /* pointer to value to pad output array
                              * (complexity must match complexity of y)
                              */
    int_T totalInputBytes,   /* total number of bytes in the input array */
    int_T totalSampsToPad,   /* total number of samples to pad */
    int_T bytesPerElement    /* number of bytes in each sample */
    )
{
    /* Copy inputs to outputs */
    memcpy(y, u, totalInputBytes);
    y += totalInputBytes;

    /* Pad remaining outputs */
    while (totalSampsToPad--) {
        memcpy(y, padValue, bytesPerElement);
        y += bytesPerElement;
    }
}

/* [EOF] pad_rows_rt.c */
