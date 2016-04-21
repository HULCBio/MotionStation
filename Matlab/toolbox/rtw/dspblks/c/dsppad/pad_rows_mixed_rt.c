/*
 *  pad_rows_mixed_rt.c - Pad runtime helper function
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.9.2.2 $  $Date: 2004/04/12 23:47:22 $
 */
#include "dsp_rt.h"

/* Extra columns (longer output rows) only */
EXPORT_FCN void MWDSP_PadAlongRowsMixed(
    const byte_T *u,          /* pointer to input array  (any data type, any complexity) */
    byte_T       *y,          /* pointer to output array (any data type, any complexity) */
    byte_T       *padValue,   /* pointer to value to pad output array
                               * (complexity must match complexity of y)
                               */
    byte_T       *zero,       /* pointer to data-typed "real zero" representation */
    int_T totalInputSamps,    /* total number of samples in the input array */
    int_T totalSampsToPad,    /* total number of samples to pad */
    int_T bytesPerRealElement /* number of bytes per input sample */
    )
{
    /* Copy real inputs to complex outputs,
     * interleaving imag zeros
     */
    while (totalInputSamps--) {
        memcpy(y, u, bytesPerRealElement);
        u += bytesPerRealElement;
        y += bytesPerRealElement;
        memcpy(y, zero, bytesPerRealElement);
        y += bytesPerRealElement;
    }

    /* Pad remaining outputs */
    bytesPerRealElement <<= 1; /* NOTE: using as "bytes per complex element" below */
    while (totalSampsToPad--) {
        memcpy(y, padValue, bytesPerRealElement);
        y += bytesPerRealElement;
    }
}

/* [EOF] pad_rows_mixed_rt.c */
