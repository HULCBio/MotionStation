/*
 *  pad_pre_rows_mixed_rt.c - Pad runtime helper function
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.5.2.2 $  $Date: 2004/04/12 23:47:18 $
 */
#include "dsp_rt.h"

/* Extra columns (longer output rows) only */
EXPORT_FCN void MWDSP_PadPreAlongRowsMixed(
    const byte_T *u,          /* pointer to input array  (any data type, any complexity) */
    byte_T       *y,          /* pointer to output array (any data type, any complexity) */
    byte_T       *padValue,   /* pointer to value to pad output array
                               * (complexity must match complexity of y)
                               */
    byte_T       *zero,       /* pointer to data-typed "real zero" representation */
    int_T totalInputSamps,    /* total number of input samples */
    int_T totalSampsToPad,    /* total number of samples to pad */
    int_T bytesPerRealElement /* number of bytes per input sample */
    )
{
    const int_T bytesPerComplexElement = bytesPerRealElement << 1;

    /* Pad initial outputs */
    while (totalSampsToPad--) {
        memcpy(y, padValue, bytesPerComplexElement);
        y += bytesPerComplexElement;
    }

    /* Copy remaining real inputs
     * to complex outputs,
     * interleaving imag zeros
     */
    while (totalInputSamps--) {
        memcpy(y, u, bytesPerRealElement);
        u += bytesPerRealElement;
        y += bytesPerRealElement;
        memcpy(y, zero, bytesPerRealElement);
        y += bytesPerRealElement;
    }
}

/* [EOF] pad_pre_rows_mixed_rt.c */
