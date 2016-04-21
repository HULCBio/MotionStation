/*
 *  DSPPAD_RT Runtime helper functions for DSP pad algorithms
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.13.4.2 $  $Date: 2004/04/12 23:12:06 $
 */

#ifndef dsppad_rt_h
#define dsppad_rt_h

#include "dsp_rt.h"

#ifdef DSPPAD_EXPORTS
#define DSPPAD_EXPORT EXPORT_FCN
#else
#define DSPPAD_EXPORT MWDSP_IDECL
#endif

/* FUNCTION MWDSP_PadAlongCols AND MWDSP_PadAlongColsMixed
 *
 * DESCRIPTION: (Post) pad along columns only.
 *
 * ASSUMES (MWDSP_PadAlongCols):      Input, pad value, and output all same complexity.
 * ASSUMES (MWDSP_PadAlongColsMixed): Real input, complex pad value, complex output.
 */
DSPPAD_EXPORT void MWDSP_PadAlongCols(
    const byte_T *u,         /* pointer to input array  (any data type, any complexity) */
    byte_T       *y,         /* pointer to output array (any data type, any complexity) */
    byte_T       *padValue,  /* pointer to value to pad output array
                              * (complexity must match complexity of y)
                              */
    int_T numInpCols,        /* number of columns in the input array */
    int_T bytesPerInpCol,    /* number of bytes in each column of input array */
    int_T numExtraRows,      /* number of additional rows in output array */
    int_T bytesPerElement    /* number of bytes in each sample */
);

DSPPAD_EXPORT void MWDSP_PadAlongColsMixed(
    const byte_T *u,         /* pointer to input array  (any data type, any complexity) */
    byte_T       *y,         /* pointer to output array (any data type, any complexity) */
    byte_T       *padValue,  /* pointer to value to pad output array
                              * (complexity must match complexity of y)
                              */
    byte_T       *zero,      /* pointer to data-typed "real zero" representation */
    int_T numInpRows,        /* number of rows in the input array    */
    int_T numInpCols,        /* number of columns in the input array */
    int_T numExtraRows,      /* number of additional rows in output array */
    int_T bytesPerRealElmt   /* number of bytes in each input sample */
);

/* FUNCTION MWDSP_PadAlongRows AND MWDSP_PadAlongRowsMixed
 *
 * DESCRIPTION: (Post) pad along rows only.
 *
 * ASSUMES (MWDSP_PadAlongRows):      Input, pad value, and output all same complexity.
 * ASSUMES (MWDSP_PadAlongRowsMixed): Real input, complex pad value, complex output.
 */
DSPPAD_EXPORT void MWDSP_PadAlongRows(
    const byte_T *u,         /* pointer to input array  (any data type, any complexity) */
    byte_T       *y,         /* pointer to output array (any data type, any complexity) */
    byte_T       *padValue,  /* pointer to value to pad output array
                              * (complexity must match complexity of y)
                              */
    int_T totalInputBytes,   /* total number of bytes in the input array */
    int_T totalSampsToPad,   /* total number of samples to pad */
    int_T bytesPerElement    /* number of bytes in each sample */
);

DSPPAD_EXPORT void MWDSP_PadAlongRowsMixed(
    const byte_T *u,         /* pointer to input array  (any data type, any complexity) */
    byte_T       *y,         /* pointer to output array (any data type, any complexity) */
    byte_T       *padValue,  /* pointer to value to pad output array
                              * (complexity must match complexity of y)
                              */
    byte_T       *zero,      /* pointer to data-typed "real zero" representation */
    int_T totalInputSamps,   /* total number of input samples */
    int_T totalSampsToPad,   /* total number of samples to pad */
    int_T bytesPerRealElmt   /* number of bytes in each input sample */
);

/* FUNCTION MWDSP_PadAlongRowsCols AND MWDSP_PadAlongRowsColsMixed
 *
 * DESCRIPTION: (Post) pad along rows AND columns.
 *
 * ASSUMES (MWDSP_PadAlongRowsCols):      Input, pad value, and output all same complexity.
 * ASSUMES (MWDSP_PadAlongRowsColsMixed): Real input, complex pad value, complex output.
 */
DSPPAD_EXPORT void MWDSP_PadAlongRowsCols(
    const byte_T *u,         /* pointer to input array  (any data type, any complexity) */
    byte_T       *y,         /* pointer to output array (any data type, any complexity) */
    byte_T       *padValue,  /* pointer to value to pad output array
                              * (complexity must match complexity of y)
                              */
    int_T numInpCols,        /* number of columns in the input array  */
    int_T bytesPerInpCol,    /* number of bytes in each column of input array */
    int_T numExtraRows,      /* number of extra rows to pad in output array */
    int_T numExtraFullOutColSamps, /* total number of samples in new full columns
                                    * in output array (numOutRows * numExtraCols)
                                    */
    int_T bytesPerElement    /* number of bytes in each sample */
);

DSPPAD_EXPORT void MWDSP_PadAlongRowsColsMixed(
    const byte_T *u,         /* pointer to input array  (any data type, any complexity) */
    byte_T       *y,         /* pointer to output array (any data type, any complexity) */
    byte_T       *padValue,  /* pointer to value to pad output array
                              * (complexity must match complexity of y)
                              */
    byte_T       *zero,      /* pointer to data-typed "real zero" representation */
    int_T numInpRows,        /* number of rows in the input array     */
    int_T numInpCols,        /* number of columns in the input array  */
    int_T numExtraRows,      /* number of additional rows in output array    */
    int_T numExtraFullOutColSamps, /* total number of samples in new full columns
                                    * in output array (numOutRows * numExtraCols)
                                    */
    int_T bytesPerRealElmt   /* number of bytes in each input sample */
);

/* FUNCTION MWDSP_PadPreAlongCols AND MWDSP_PadPreAlongColsMixed
 *
 * DESCRIPTION: (Pre) pad along columns only.
 *
 * ASSUMES (MWDSP_PadPreAlongCols):      Input, pad value, and output all same complexity.
 * ASSUMES (MWDSP_PadPreAlongColsMixed): Real input, complex pad value, complex output.
 */
DSPPAD_EXPORT void MWDSP_PadPreAlongCols(
    const byte_T *u,         /* pointer to input array  (any data type, any complexity) */
    byte_T       *y,         /* pointer to output array (any data type, any complexity) */
    byte_T       *padValue,  /* pointer to value to pad output array
                              * (complexity must match complexity of y)
                              */
    int_T numInpCols,        /* number of columns in the input array  */
    int_T bytesPerInpCol,    /* number of bytes in each column of input array */
    int_T numExtraRows,      /* number of additional rows in output array    */
    int_T bytesPerElement    /* number of bytes in each sample */
);

DSPPAD_EXPORT void MWDSP_PadPreAlongColsMixed(
    const byte_T *u,         /* pointer to input array  (any data type, any complexity) */
    byte_T       *y,         /* pointer to output array (any data type, any complexity) */
    byte_T       *padValue,  /* pointer to value to pad output array
                              * (complexity must match complexity of y)
                              */
    byte_T       *zero,      /* pointer to data-typed "real zero" representation */
    int_T numInpRows,        /* number of rows in the input array    */
    int_T numInpCols,        /* number of columns in the input array */
    int_T numExtraRows,      /* number of additional rows in output array */
    int_T bytesPerRealElmt   /* number of bytes in each input sample */
);

/* FUNCTION MWDSP_PadPreAlongRows AND MWDSP_PadPreAlongRowsMixed
 *
 * DESCRIPTION: (Pre) pad along rows only.
 *
 * ASSUMES (MWDSP_PadPreAlongRows):      Input, pad value, and output all same complexity.
 * ASSUMES (MWDSP_PadPreAlongRowsMixed): Real input, complex pad value, complex output.
 */
DSPPAD_EXPORT void MWDSP_PadPreAlongRows(
    const byte_T *u,         /* pointer to input array  (any data type, any complexity) */
    byte_T       *y,         /* pointer to output array (any data type, any complexity) */
    byte_T       *padValue,  /* pointer to value to pad output array
                              * (complexity must match complexity of y) */
    int_T totalInputBytes,   /* total number of bytes in the input array */
    int_T totalSampsToPad,   /* total number of samples to pad */
    int_T bytesPerElement    /* number of bytes in each sample */
);

DSPPAD_EXPORT void MWDSP_PadPreAlongRowsMixed(
    const byte_T *u,         /* pointer to input array  (any data type, any complexity) */
    byte_T       *y,         /* pointer to output array (any data type, any complexity) */
    byte_T       *padValue,  /* pointer to value to pad output array
                              * (complexity must match complexity of y)
                              */
    byte_T       *zero,      /* pointer to data-typed "real zero" representation */
    int_T totalInputSamps,   /* total number of input samples */
    int_T totalSampsToPad,   /* total number of samples to pad */
    int_T bytesPerRealElmt   /* number of bytes in each input sample */
);

/* FUNCTION MWDSP_PadPreAlongRowsCols AND MWDSP_PadPreAlongRowsColsMixed
 *
 * DESCRIPTION: (Pre) pad along rows AND columns.
 *
 * ASSUMES (MWDSP_PadPreAlongRowsCols):      Input, pad value, and output all same complexity.
 * ASSUMES (MWDSP_PadPreAlongRowsColsMixed): Real input, complex pad value, complex output.
 */
DSPPAD_EXPORT void MWDSP_PadPreAlongRowsCols(
    const byte_T *u,         /* pointer to input array  (any data type, any complexity) */
    byte_T       *y,         /* pointer to output array (any data type, any complexity) */
    byte_T       *padValue,  /* pointer to value to pad output array
                              * (complexity must match complexity of y)
                              */
    int_T numInpCols,        /* number of columns in the input array  */
    int_T bytesPerInpCol,    /* number of bytes in each column of input array */
    int_T numExtraRows,      /* number of extra rows to pad in output array */
    int_T numExtraFullOutColSamps, /* total number of samples in new full columns
                                    * in output array (numOutRows * numExtraCols)
                                    */
    int_T bytesPerElement    /* number of bytes in each sample */
);

DSPPAD_EXPORT void MWDSP_PadPreAlongRowsColsMixed(
    const byte_T *u,         /* pointer to input array  (any data type, any complexity) */
    byte_T       *y,         /* pointer to output array (any data type, any complexity) */
    byte_T       *padValue,  /* pointer to value to pad output array
                              * (complexity must match complexity of y)
                              */
    byte_T       *zero,      /* pointer to data-typed "real zero" representation */
    int_T numInpRows,        /* number of rows in the input array     */
    int_T numInpCols,        /* number of columns in the input array  */
    int_T numExtraRows,      /* number of extra rows to pad in output array */
    int_T numExtraFullOutColSamps, /* total number of samples in new full columns
                                    * in output array (numOutRows * numExtraCols)
                                    */
    int_T bytesPerRealElmt   /* number of bytes in each input sample */
);

/* FUNCTION MWDSP_PadCopyOnlyTruncAlongRows AND MWDSP_PadCopyOnlyTruncAlongCols
 *
 * DESCRIPTION: Copy inputs to outputs, including possible
 *              truncation along either rows or columns.
 *
 * MWDSP_PadCopyOnlyTruncAlongRows is truncation along row dimension.
 * That is, the number of rows (or length of each column) stays constant from
 * input to output.  However there may be fewer columns in the output
 * (i.e. row lengths may get truncated).
 *
 * MWDSP_PadCopyOnlyTruncAlongCols is truncation along column dimension.
 * That is, the number of columns (or length of each row) stays constant from
 * input to output.  However there may be fewer rows in the output
 * (i.e. column lengths may get truncated).
 *
 * ASSUMES: Input and output both have same complexity.
 *          (note: pad value and pad value complexity is ignored)
 */
#define MWDSP_PadCopyOnlyTruncAlongRows(u, y, totalOutputBytes) memcpy(y, u, totalOutputBytes)

DSPPAD_EXPORT void MWDSP_PadCopyOnlyTruncAlongCols(
    const byte_T *u,      /* pointer to input array  (any data type, any complexity) */
    byte_T       *y,      /* pointer to output array (any data type, any complexity) */
    int_T bytesPerInpCol, /* number of bytes in each column of input array */
    int_T bytesPerOutCol, /* number of bytes in each column of output array */
    int_T numOutCols      /* number of columns in the output array  */
);

#ifdef MWDSP_INLINE_DSPRTLIB
#include "dsppad/pad_cols_mixed_rt.c"
#include "dsppad/pad_cols_rt.c"
#include "dsppad/pad_copy_io_trunc_cols_rt.c"
#include "dsppad/pad_pre_cols_mixed_rt.c"
#include "dsppad/pad_pre_cols_rt.c"
#include "dsppad/pad_pre_rows_cols_mixed_rt.c"
#include "dsppad/pad_pre_rows_cols_rt.c"
#include "dsppad/pad_pre_rows_mixed_rt.c"
#include "dsppad/pad_pre_rows_rt.c"
#include "dsppad/pad_rows_cols_mixed_rt.c"
#include "dsppad/pad_rows_cols_rt.c"
#include "dsppad/pad_rows_mixed_rt.c"
#include "dsppad/pad_rows_rt.c"
#endif

#endif /* dsppad_rt_h */

/* [EOF] dsppad_rt.h */
