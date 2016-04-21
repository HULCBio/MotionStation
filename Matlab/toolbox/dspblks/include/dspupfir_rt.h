/*
 *  dspupfir_rt.h
 *
 *  Abstract: Header file for DSP run-time library helper functions
 *  for the FIR interpolation block.
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.3.4.3 $ $Date: 2004/04/12 23:12:18 $
 */

#ifndef dspupfir_rt_h
#define dspupfir_rt_h

#include "dsp_rt.h"

#ifdef DSPUPFIR_EXPORTS
#define DSPUPFIR_EXPORT EXPORT_FCN
#else
#define DSPUPFIR_EXPORT MWDSP_IDECL
#endif

/* FIR INTERPOLATION BLOCK IMPLEMENTATION
 * Description: 
 * This FIR interpolation block implements a FIR polyphase filter.
 *
 * Filter Coefficients (*filter):
 * Filter Coefficients are arranged into polyphase order
 * according to the interpolation commuter model.
 *
 * For example, if the decimation factor, dFactor, is 3 and
 * the FIR coefficients are [1 2 3 4 5 6], then the polyphase filters
 * are [1 4], [2 5] and [3 6] for the three phases.
 *
 * TapDelayBuffer:
 * This is implemented as a circular buffer to hold input sample (for each channel).
 * Its per channel length is equal to the length of one polyphase filter.  In the
 * above example, there are 3 polyphase filters, each of length 2. In this direct
 * form FIR implementation, TapDelayBuffer is convolved with each polyphase filter
 * to give a filter output for each interpolation phase.
 *
 * Output Buffer:
 * The output buffer is a double buffer.  This is necessary when the algorithm is
 * (multirate and frame-based) OR  (multirate and multitasking). In the run-time
 * functions, two ping-pong pointers (readBuf and wrtBuf) are defined to manage
 * this double buffer. Today, this algorithm is implemented with a double output buffer 
 * regardless of its necessity. Each one of the output buffers is of size 
 * Number of elements in the input port * interpolation factor.  The memory arrangement
 * of each output buffer is illustrated with an example:
 * In a case of 2 channels, each of frame size 2 and an interpolation factor 3,
 * the memory arrangement of each output buffer is
 *
 * Channel      Sample from frame           Output Buffer Memory Contents
 * -------      -----------------           -----------------------------
 *    1st              1st              filter output of 1st interpolation phase
 *                                      filter output of 2nd interpolation phase
 *                                      filter output of 3rd interpolation phase
 *                     2nd              filter output of 1st interpolation phase
 *                                      filter output of 2nd interpolation phase
 *                                      filter output of 3rd interpolation phase
 *    2nd              1st              filter output of 1st interpolation phase
 *                                      filter output of 2nd interpolation phase
 *                                      filter output of 3rd interpolation phase
 *                     2nd              filter output of 1st interpolation phase
 *                                      filter output of 2nd interpolation phase
 *                                      filter output of 3rd interpolation phase
 *
 * Buffer Memory Size:
 * TapDelayBuffer size  = numChans * length of one polyphase filter 
 * OutputBuffer size    = 2 * iFactor * number of input elements
 *                      = 2 * iFactor * numChans * inFrameSize (framebased)
 *
 * Algorithm: 
 * The run-time function MWDSP_FIRDn_DF_DblBuf_DD source code 
 * is fully documented to show the algorithm.
 *
 * Function naming conventions:
 *
 * FIRDn - FIR Decimation
 * UpFIR - FIR Interpolation
 *
 * DF  - direct form FIR polyphase implementation.
 * TDF - transposed direct form FIR polyphase implementation.
 *
 * DblBuf - uses double ("ping-pong") output buffer.
 *
 * Based on the data-types, we have:-
 * D = double-precision real data-type.
 * R = single-precision real data-type
 * Z = double-precision complex data-type.
 * C = single-precision complex data-type. 
 *
 * The first letter refers to the input port data type.
 * The second letter refers to filter coefficient data type.
 *
 * Function Usage:
 * The run-time functions MWDSP_UpFIR_DF_DblBuf_xx are designed to
 * accomodate a double buffer arrangement for *out.  However, 
 * they can also be used when out points to a single buffer.  To 
 * make this work, the caller has to pass a pointer to a boolean false 
 * to the 6th input parameter wrtBuf before each function call.  Note
 * that these run-time functions will change the boolean false to true
 * after each call.
 */

DSPUPFIR_EXPORT void MWDSP_UpFIR_CopyDataToOutPort(
    const byte_T *outBufBase,               
          byte_T *y,
          int32_T  *rdIdx,
    const int_T   outFrameSize,
    const int_T   numChans,
    const int_T   bytesPerElem,
    const int_T   bytesToCopy,
    const int_T   perChanOutBufElems,
    const int_T   perChanOutBufBytes,
    const int_T   outBufBaseOffsetInBytes,
    const int_T   rdIdxSpan
);

DSPUPFIR_EXPORT void MWDSP_UpFIR_DF_DblBuf_DD(
    const real_T    *u,                 /* input port*/
          real_T    *out,               /* double length output buffer to hold filter output */
          real_T    *tap0,              /* points to input TapDelayBuffer start address per channel */
    const real_T    *filter,            /* FIR coeff */
          int32_T     *tapIdx,            /* points to input TapDelayBuffer location to read in u */
          boolean_T *wrtBuf,            /* determines which one of the two double buffer to store out */
    const int_T     numChans,           /* number of channels */
    const int_T     inFrameSize,        /* input frame size */
    const int_T     iFactor,            /* interpolation factor */
    const int_T     polyphaseFiltLen,   /* length of each polyphase filter */
    const int_T     singleOutBufSize    /* number of elements in each one of the double output buffer */
);

DSPUPFIR_EXPORT void MWDSP_UpFIR_DF_DblBuf_DZ(
    const real_T    *u,
          creal_T   *out,
          real_T    *tap0,
    const creal_T   *filter,
          int32_T     *tapIdx,
          boolean_T *wrtBuf,
    const int_T     numChans,
    const int_T     inFrameSize,
    const int_T     iFactor,
    const int_T     polyphaseFiltLen,
    const int_T     singleOutBufSize
);

DSPUPFIR_EXPORT void MWDSP_UpFIR_DF_DblBuf_ZD(
    const creal_T   *u,
          creal_T   *out,
          creal_T   *tap0,
    const real_T    *filter,
          int32_T     *tapIdx,
          boolean_T *wrtBuf,
    const int_T     numChans,
    const int_T     inFrameSize,
    const int_T     iFactor,
    const int_T     polyphaseFiltLen,
    const int_T     singleOutBufSize
);

DSPUPFIR_EXPORT void MWDSP_UpFIR_DF_DblBuf_ZZ(
    const creal_T   *u,
          creal_T   *out,
          creal_T   *tap0,
    const creal_T   *filter,
          int32_T     *tapIdx,
          boolean_T *wrtBuf,
    const int_T     numChans,
    const int_T     inFrameSize,
    const int_T     iFactor,
    const int_T     polyphaseFiltLen,
    const int_T     singleOutBufSize
);

DSPUPFIR_EXPORT void MWDSP_UpFIR_DF_DblBuf_RR(
    const real32_T    *u,
          real32_T    *out,
          real32_T    *tap0,
    const real32_T    *filter,
          int32_T     *tapIdx,
          boolean_T *wrtBuf,
    const int_T     numChans,
    const int_T     inFrameSize,
    const int_T     iFactor,
    const int_T     polyphaseFiltLen,
    const int_T     singleOutBufSize
);

DSPUPFIR_EXPORT void MWDSP_UpFIR_DF_DblBuf_RC(
    const real32_T    *u,
          creal32_T   *out,
          real32_T    *tap0,
    const creal32_T   *filter,
          int32_T     *tapIdx,
          boolean_T *wrtBuf,
    const int_T     numChans,
    const int_T     inFrameSize,
    const int_T     iFactor,
    const int_T     polyphaseFiltLen,
    const int_T     singleOutBufSize
);

DSPUPFIR_EXPORT void MWDSP_UpFIR_DF_DblBuf_CR(
    const creal32_T   *u,
          creal32_T   *out,
          creal32_T   *tap0,
    const real32_T    *filter,
          int32_T     *tapIdx,
          boolean_T *wrtBuf,
    const int_T     numChans,
    const int_T     inFrameSize,
    const int_T     iFactor,
    const int_T     polyphaseFiltLen,
    const int_T     singleOutBufSize
);

DSPUPFIR_EXPORT void MWDSP_UpFIR_DF_DblBuf_CC(
    const creal32_T   *u,
          creal32_T   *out,
          creal32_T   *tap0,
    const creal32_T   *filter,
          int32_T     *tapIdx,
          boolean_T *wrtBuf,
    const int_T     numChans,
    const int_T     inFrameSize,
    const int_T     iFactor,
    const int_T     polyphaseFiltLen,
    const int_T     singleOutBufSize
);

#ifdef MWDSP_INLINE_DSPRTLIB
#include "dspupfir/upfir_copydata_rt.c"
#include "dspupfir/upfir_df_dblbuf_cc_rt.c"
#include "dspupfir/upfir_df_dblbuf_cr_rt.c"
#include "dspupfir/upfir_df_dblbuf_dd_rt.c"
#include "dspupfir/upfir_df_dblbuf_dz_rt.c"
#include "dspupfir/upfir_df_dblbuf_rc_rt.c"
#include "dspupfir/upfir_df_dblbuf_rr_rt.c"
#include "dspupfir/upfir_df_dblbuf_zd_rt.c"
#include "dspupfir/upfir_df_dblbuf_zz_rt.c"
#endif

#endif  /* dspupfir_rt_h */

/* [EOF] dspupfir_rt.h */
