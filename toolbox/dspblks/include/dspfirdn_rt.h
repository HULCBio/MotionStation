/*
 *  dspfirdn_rt.h
 *
 *  Abstract: Header file for DSP run-time library helper functions
 *  for the FIR decimation block.
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.3.4.3 $ $Date: 2004/04/12 23:11:51 $
 */

#ifndef dspfirdn_rt_h
#define dspfirdn_rt_h

#include "dsp_rt.h"

#ifdef DSPFIRDN_EXPORTS
#define DSPFIRDN_EXPORT EXPORT_FCN
#else
#define DSPFIRDN_EXPORT MWDSP_IDECL
#endif

/* FIR DECIMATION BLOCK IMPLEMENTATION
 * Description: 
 * This FIR decimation block implements a FIR polyphase filter.
 *
 * Filter Coefficients (*filter):
 * Filter Coefficients are arranged into polyphase order
 * according to the decimation commuter model.
 *
 * For example, if the decimation factor, dFactor, is 3 and
 * the FIR coefficients are [1 2 3 4 5 6], then the polyphase filters
 * are [1 4], [2 5] and [3 6].
 *
 * To use these functions, the client must arrange the filter coefficients into
 * the phase order, i.e. [3 6 2 5 1 4] for this example. The phaseIndex is initialized
 * to the value dFactor-1, i.e. 2 for this example.  The coefficient pointer, cffPtr,
 * is initialized to point to the last
 * polyphase filter set, i.e. [1 4].  The phaseIndex is incremented in the run-time
 * algorithms so that the polyphase filter appears in the order [1 4], [3 6] 
 * [2 5].  This ordering is consistent with the counter clockwise movement 
 * described in the commuter model.
 *
 * TapDelayBuffer:
 * This is implemented as a circular buffer to hold input sample (for each channel).
 * Its per channel length is equal to FIR filter length.
 *
 * PartialSums Buffer:
 * There is one scalar partial sum per channel stored in the partialSums buffer.
 * This is used for holding the intermediate sum in FIR direct form implementation.
 *
 * Output Buffer:
 * The output buffer is a double buffer.  This is necessary when the algorithm is
 * (multirate and frame-based) OR  (multirate and multitasking). In the run-time
 * functions, two ping-pong pointers (readBuf and wrtBuf) are defined to manage
 * this double buffer. Today, this algorithm is implemented with a double output buffer 
 * regardless of its necessity.
 *
 * Memory Architecture:
 * The TapDelayBuffer, OutputBuffer and PartialSumsBuffer are implemented 
 * as contiguous arrays and they have the following memory structure
 *
 *   ----------------------------------------------
 *   |    Channel 0     |     Channel 1      |  ...
 *   |val0 | val1 |...  | val0 | val1 |   ...|  ...
 *   ---------------------------------------------- 
 *
 * TapDelayBuffer size  = numChans * length(FIR filter) 
 * OutputBuffer size    = 2 * number of output port elements (double length buffer)
 * PartialSums buffer size = numChans
 * 
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
 */

DSPFIRDN_EXPORT void MWDSP_FIRDn_DF_DblBuf_DD(
    const real_T    *u,                 /* input port*/
          real_T    *yout,              /* double length output buffer */
          real_T    *tap0,              /* points to input buffer start address per channel */
          real_T    *sums,              /* points to sums of FIR filter, one per channel */
    const real_T    *filter,            /* FIR coeff */
    const real_T   **cffPtr,            /* filter coeff pointer */
          int32_T     *tapIdx,            /* points to input TapDelayBuffer location to read in u */
          int32_T     *outIdx,            /* points to output buffer data for transfer to y */
          int32_T     *phaseIdx,          /* active polyphase index */
          boolean_T *wrtBuf,            /* determines which one of the  two double buffer to store yout */
    const int_T     filtLen,            /* length of FIR filter */
    const int_T     numChans,           /* number of channels */
    const int_T     inFrameSize,        /* input frame size */
    const int_T     outFrameSize,       /* output frame size */
    const int_T     dFactor,            /* decimation factor */
    const int_T     polyphaseFiltLen,   /* length of each polyphase filter */
    const int_T     outElem             /* number of output elements */
);

DSPFIRDN_EXPORT void MWDSP_FIRDn_DF_DblBuf_DZ(
    const real_T    *u,
          creal_T   *yout,
          real_T    *tap0,
          creal_T   *sums,
    const creal_T   *filter,
    const creal_T  **cffPtr,
          int32_T     *tapIdx,
          int32_T     *outIdx,
          int32_T     *phaseIdx,
          boolean_T *wrtBuf,
    const int_T     filtLen,
    const int_T     numChans,
    const int_T     inFrameSize,
    const int_T     outFrameSize,
    const int_T     dFactor,
    const int_T     polyphaseFiltLen,
    const int_T     outElem
);

DSPFIRDN_EXPORT void MWDSP_FIRDn_DF_DblBuf_ZD(
    const creal_T   *u,
          creal_T   *yout,
          creal_T   *tap0,
          creal_T   *sums,
    const real_T    *filter,
    const real_T   **cffPtr,
          int32_T     *tapIdx,
          int32_T     *outIdx,
          int32_T     *phaseIdx,
          boolean_T *wrtBuf,
    const int_T     filtLen,
    const int_T     numChans,
    const int_T     inFrameSize,
    const int_T     outFrameSize,
    const int_T     dFactor,
    const int_T     polyphaseFiltLen,
    const int_T     outElem
);

DSPFIRDN_EXPORT void MWDSP_FIRDn_DF_DblBuf_ZZ(
    const creal_T   *u,
          creal_T   *yout,
          creal_T   *tap0,
          creal_T   *sums,
    const creal_T   *filter,
    const creal_T   **cffPtr,
          int32_T     *tapIdx,
          int32_T     *outIdx,
          int32_T     *phaseIdx,
          boolean_T *wrtBuf,
    const int_T     filtLen,
    const int_T     numChans,
    const int_T     inFrameSize,
    const int_T     outFrameSize,
    const int_T     dFactor,
    const int_T     polyphaseFiltLen,
    const int_T     outElem
);

DSPFIRDN_EXPORT void MWDSP_FIRDn_DF_DblBuf_RR(
    const real32_T    *u,
          real32_T    *yout,
          real32_T    *tap0,
          real32_T    *sums,
    const real32_T    *filter,
    const real32_T   **cffPtr,
          int32_T     *tapIdx,
          int32_T     *outIdx,
          int32_T     *phaseIdx,
          boolean_T *wrtBuf,
    const int_T     filtLen,
    const int_T     numChans,
    const int_T     inFrameSize,
    const int_T     outFrameSize,
    const int_T     dFactor,
    const int_T     polyphaseFiltLen,
    const int_T     outElem
);

DSPFIRDN_EXPORT void MWDSP_FIRDn_DF_DblBuf_RC(
    const real32_T    *u,
          creal32_T   *yout,
          real32_T    *tap0,
          creal32_T   *sums,
    const creal32_T   *filter,
    const creal32_T  **cffPtr,
          int32_T     *tapIdx,
          int32_T     *outIdx,
          int32_T     *phaseIdx,
          boolean_T *wrtBuf,
    const int_T     filtLen,
    const int_T     numChans,
    const int_T     inFrameSize,
    const int_T     outFrameSize,
    const int_T     dFactor,
    const int_T     polyphaseFiltLen,
    const int_T     outElem
);

DSPFIRDN_EXPORT void MWDSP_FIRDn_DF_DblBuf_CR(
    const creal32_T   *u,
          creal32_T   *yout,
          creal32_T   *tap0,
          creal32_T   *sums,
    const real32_T    *filter,
    const real32_T   **cffPtr,
          int32_T     *tapIdx,
          int32_T     *outIdx,
          int32_T     *phaseIdx,
          boolean_T *wrtBuf,
    const int_T     filtLen,
    const int_T     numChans,
    const int_T     inFrameSize,
    const int_T     outFrameSize,
    const int_T     dFactor,
    const int_T     polyphaseFiltLen,
    const int_T     outElem
);

DSPFIRDN_EXPORT void MWDSP_FIRDn_DF_DblBuf_CC(
    const creal32_T   *u,
          creal32_T   *yout,
          creal32_T   *tap0,
          creal32_T   *sums,
    const creal32_T   *filter,
    const creal32_T   **cffPtr,
          int32_T     *tapIdx,
          int32_T     *outIdx,
          int32_T     *phaseIdx,
          boolean_T *wrtBuf,
    const int_T     filtLen,
    const int_T     numChans,
    const int_T     inFrameSize,
    const int_T     outFrameSize,
    const int_T     dFactor,
    const int_T     polyphaseFiltLen,
    const int_T     outElem
);

#ifdef MWDSP_INLINE_DSPRTLIB
#include "dspfirdn/firdn_df_dblbuf_cc_rt.c"
#include "dspfirdn/firdn_df_dblbuf_cr_rt.c"
#include "dspfirdn/firdn_df_dblbuf_dd_rt.c"
#include "dspfirdn/firdn_df_dblbuf_dz_rt.c"
#include "dspfirdn/firdn_df_dblbuf_rc_rt.c"
#include "dspfirdn/firdn_df_dblbuf_rr_rt.c"
#include "dspfirdn/firdn_df_dblbuf_zd_rt.c"
#include "dspfirdn/firdn_df_dblbuf_zz_rt.c"
#endif

#endif /* dspfirdn_rt_h */

/* [EOF] dspfirdn_rt.h */
