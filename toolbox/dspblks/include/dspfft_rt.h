/*
 *  dspfft_rt.h
 *
 *  Copyright 1995-2004 The MathWorks, Inc.
 *  $Revision: 1.14.4.4 $ $Date: 2004/04/12 23:11:48 $
 */

#ifndef dspfft_rt_h
#define dspfft_rt_h

#include "dsp_rt.h"

#ifdef DSPFFT_EXPORTS
#define DSPFFT_EXPORT EXPORT_FCN
#else
#define DSPFFT_EXPORT extern
#endif

/*
 * ====================================================
 * Prototypes for all FFT run-time source code
 * located in dspblks/src/rt/dspfft
 * ====================================================
 */


/*
 * Function naming glossary
 * ---------------------------
 *
 * MWDSP = MathWorks DSP Blockset
 * R2    = radix 2
 * DIF   = decimation-in-frequency
 * DIT   = decimation-in-time
 * BR    = bit reversal
 * DR    = digit reversal
 * TRIG  = trigonometric version
 * TBLM  = memory-optimized table lookup
 * TBLS  = speed-optimized table lookup
 * TBL   = general table lookup
 *         (not specific to -M or -S versions)
 *
 * Data types - (describe inputs to functions, not outputs)
 * R = real single-precision
 * C = complex single-precision
 * D = real double-precision
 * Z = complex double-precision
 */

/* Function naming convention
 * --------------------------
 *
 * MWDSP_(fft or ifft)_(block's purpose)_Input-datatype(br)_Output-datatype(br)_(Inplace or Outofplace)
 *
 *    1) MWDSP_ is a prefix used with all Mathworks runtime library functions
 *    2) The second field indicates whether this function is related to fft or ifft.
 *       There are some functions that can be either. They are labelled fft.
 *    3) The next field explains the purpose of this function. Examples: fft or addConjSignals.
 *    4) The next field enumerates the input data type from the above list. (Single/double precision
 *       and complexity are specified within a single letter.) An optional br trails the input
 *       datatype to indicate that the input is in bit-reversed order. The absence of br indicates
 *       that the data is in normal order.
 *    5) The next field enumerates the output data type and order in the same manner as 4) did
 *       for the input.
 *    6) One of the labels Inp or Oop to indicate in place, or out of place.
 *
 *    Examples:
 *       MWDSP_ifft_dbllen_trig_Dbr_Zbr_OOP is the ifft helper routine for processing
 *          double length conjugate symmetric signals (a length N signal with a length N/2 IFFT)
 *          with real double precision bit-reversed order data input and complex double precision
 *          bit-reversed order data output. It uses direct calls so sin() and cos() to evaluate
 *          trigonometric functions. The input and output buffers are distinct.
 */

/*
 * FFT run-time services
 */

DSPFFT_EXPORT void MWDSP_R2DIF_TRIG_Z(
    creal_T    *y,
    int_T       nChans,
    const int_T nRows,
    const int_T fftLen,
    const int_T isInverse
    );

DSPFFT_EXPORT void MWDSP_R2DIF_TRIG_C(
    creal32_T   *y,
    int_T        nChans,
    const int_T  nRows,
    const int_T  fftLen,
    const int_T  isInverse
    );

DSPFFT_EXPORT void MWDSP_R2DIF_TBLS_Z(
    creal_T      *y,
    int_T         nChans,
    const int_T   nRows,
    const int_T   fftLen,
    const real_T *twiddleTable,
    const int_T   twiddleStep,
    const int_T   isInverse
    );

DSPFFT_EXPORT void MWDSP_R2DIF_TBLS_AlongR_Z(
    creal_T      *y,
    int_T         nChans,
    const int_T   nRows,
    const int_T   fftLen,
    const real_T *twiddleTable,
    const int_T   twiddleStep,
    const int_T   isInverse
    );

DSPFFT_EXPORT void MWDSP_R2DIF_TBLS_C(
    creal32_T      *y,
    int_T           nChans,
    const int_T     nRows,
    const int_T     fftLen,
    const real32_T *twiddleTable,
    const int_T     twiddleStep,
    const int_T     isInverse
    );

DSPFFT_EXPORT void MWDSP_R2DIF_TBLM_Z(
    creal_T      *y,
    int_T         nChans,
    const int_T   nRows,
    const int_T   fftLen,
    const real_T *twiddleTable,
    const int_T   twiddleStep,
    const int_T   isInverse
    );

DSPFFT_EXPORT void MWDSP_R2DIF_TBLM_AlongR_Z(
    creal_T      *y,
    const int_T         nChans,
    const int_T   nRows,
    const int_T   fftLen,
    const real_T *twiddleTable,
    const int_T   twiddleStep,
    const int_T   isInverse
    );


DSPFFT_EXPORT void MWDSP_R2DIF_TBLM_C(
    creal32_T      *y,
    int_T           nChans,
    const int_T     nRows,
    const int_T     fftLen,
    const real32_T *twiddleTable,
    const int_T     twiddleStep,
    const int_T     isInverse
    );

DSPFFT_EXPORT void MWDSP_R2DIT_TRIG_Z(
    creal_T    *y,
    int_T       nChans,
    const int_T nRows,
    const int_T fftLen,
    const int_T isInverse
    );

DSPFFT_EXPORT void MWDSP_R2DIT_TRIG_C(
    creal32_T    *y,
    int_T         nChans,
    const int_T   nRows,
    const int_T   fftLen,
    const int_T   isInverse
    );

DSPFFT_EXPORT void MWDSP_R2DIT_TBLS_Z(
    creal_T      *y,
    int_T         nChans,
    const int_T   nRows,
    const int_T   fftLen,
    const real_T *twiddleTable,
    const int_T   twiddleStep,
    const int_T   isInverse
    );

/* xxx */
DSPFFT_EXPORT void MWDSP_R2DIT_TBLS_AlongR_Z(
    creal_T      *y,
    int_T         nChans,
    const int_T   nRows,
    const int_T   fftLen,
    const real_T *twiddleTable,
    const int_T   twiddleStep,
    const int_T   isInverse
    );

DSPFFT_EXPORT void MWDSP_R2DIT_TBLS_C(
    creal32_T      *y,
    int_T           nChans,
    const int_T     nRows,
    const int_T     fftLen,
    const real32_T *twiddleTable,
    const int_T     twiddleStep,
    const int_T     isInverse
    );

DSPFFT_EXPORT void MWDSP_R2DIT_TBLM_Z(
    creal_T      *y,
    int_T         nChans,
    const int_T   nRows,
    const int_T   fftLen,
    const real_T *twiddleTable,
    const int_T   twiddleStep,
    const int_T   isInverse
    );

DSPFFT_EXPORT void MWDSP_R2DIT_TBLM_AlongR_Z(
    creal_T      *y,
    int_T         nChans,
    const int_T   nRows,
    const int_T   fftLen,
    const real_T *twiddleTable,
    const int_T   twiddleStep,
    const int_T   isInverse
    );

DSPFFT_EXPORT void MWDSP_R2DIT_TBLM_C(
    creal32_T      *y,
    int_T           nChans,
    const int_T     nRows,
    const int_T     fftLen,
    const real32_T *twiddleTable,
    const int_T     twiddleStep,
    const int_T     isInverse
    );

DSPFFT_EXPORT void MWDSP_R2BR_Z(
    creal_T    *y,
    int_T       nChans,
    const int_T nRows,
    const int_T fftLen
    );

/* xxx */
DSPFFT_EXPORT void MWDSP_R2BR_AlongR_Z(
    creal_T    *y,
    const int_T       nChans,
    int_T nRows,
    const int_T fftLen
    );


DSPFFT_EXPORT void MWDSP_R2BR_C(
    creal32_T  *y,
    int_T       nChans,
    const int_T nRows,
    const int_T fftLen
    );

DSPFFT_EXPORT void MWDSP_R2BR_Z_OOP(
    creal_T       *y,
    const creal_T *x,
    int_T          nChans,
    const int_T    nRows,
    const int_T    fftLen
    );

DSPFFT_EXPORT void MWDSP_R2BR_AlongR_Z_OOP(
    creal_T       *y,
    const creal_T *x,
    int_T          nChans,
    const int_T    nRows,
    const int_T    fftLen
    );

DSPFFT_EXPORT void MWDSP_R2BR_C_OOP(
    creal32_T       *y,
    const creal32_T *x,
    int_T            nChans,
    const int_T      nRows,
    const int_T      fftLen
    );

DSPFFT_EXPORT void MWDSP_R2BR_DZ_OOP(
    creal_T       *y,
    const  real_T *x,
    int_T          nChans,
    const int_T    nRows,
    const int_T    fftLen
    );

DSPFFT_EXPORT void MWDSP_R2BR_RC_OOP(
    creal32_T       *y,
    const  real32_T *x,
    int_T            nChans,
    const int_T      nRows,
    const int_T      fftLen
    );

DSPFFT_EXPORT void MWDSP_FFTInterleave_D(
    creal_T      *y,
    const real_T *u,
    const int_T   nChans,
    const int_T   nRows
    );

DSPFFT_EXPORT void MWDSP_FFTInterleave_R(
    creal32_T      *y,
    const real32_T *u,
    const int_T     nChans,
    const int_T     nRows
    );

DSPFFT_EXPORT void MWDSP_FFTInterleave_BR_D(
    creal_T      *y,
    const real_T *u,
    const int_T   nChans,
    const int_T   nRows
    );

DSPFFT_EXPORT void MWDSP_FFTInterleave_BR_R(
    creal32_T      *y,
    const real32_T *u,
    const int_T     nChans,
    const int_T     nRows
    );

DSPFFT_EXPORT void MWDSP_DblSig_Z(
    creal_T    *y,
    int_T       nChans,
    const int_T nRows
    );

DSPFFT_EXPORT void MWDSP_DblSig_C(
    creal32_T  *y,
    int_T       nChans,
    const int_T nRows
    );

DSPFFT_EXPORT void MWDSP_DblSig_BR_Z(
    creal_T    *y,
    int_T       nChans,
    const int_T nRows
    );

DSPFFT_EXPORT void MWDSP_DblSig_BR_C(
    creal32_T  *y,
    int_T       nChans,
    const int_T nRows
    );

DSPFFT_EXPORT void MWDSP_DblLen_TRIG_Z(
    creal_T    *y,
    const int_T nRows
    );

DSPFFT_EXPORT void MWDSP_DblLen_TRIG_C(
    creal32_T    *y,
    const int_T   nRows
    );

DSPFFT_EXPORT void MWDSP_DblLen_TBL_Z(
    creal_T      *y,
    const int_T   nRows,
    const real_T *twiddleTable,
    const int_T   twiddleStep
    );

DSPFFT_EXPORT void MWDSP_DblLen_TBL_C(
    creal32_T      *y,
    const int_T     nRows,
    const real32_T *twiddleTable,
    const int_T     twiddleStep
    );

DSPFFT_EXPORT void MWDSP_ScaleData_DZ(
    creal_T     *cplxData,
    int_T        cnt,
    const real_T scaleFactor
    );

DSPFFT_EXPORT void MWDSP_ScaleData_RC(
    creal32_T     *cplxData,
    int_T          cnt,
    const real32_T scaleFactor
    );

DSPFFT_EXPORT void MWDSP_ScaleData_DD(
    real_T      *realData,
    int_T        cnt,
    const real_T scaleFactor
    );

DSPFFT_EXPORT void MWDSP_ScaleData_RR(
    real32_T      *realData,
    int_T          cnt,
    const real32_T scaleFactor
    );

/*
 * Combine two conjugate symmetric signals for simultaneous IFFT via sig1 + sqrt(-1)*sig2
 * Those routines that mix complexity cannot go in-place. Those that don't mix complexity
 * will work in-place or out.
 */
DSPFFT_EXPORT void MWDSP_Ifft_AddCSSignals_Z_Z_OOP(
    creal_T *y,
    const creal_T *u,
    const int_T   nChans,
    const int_T   nRows
    );

DSPFFT_EXPORT void MWDSP_Ifft_AddCSSignals_Z_Z(
    creal_T *y,
    const int_T   nChans,
    const int_T   nRows
    );

DSPFFT_EXPORT void MWDSP_Ifft_AddCSSignals_C_C_OOP(
    creal32_T *y,
    const creal32_T *u,
    const int_T   nChans,
    const int_T   nRows
    );
DSPFFT_EXPORT void MWDSP_Ifft_AddCSSignals_C_C(
    creal32_T *y,
    const int_T   nChans,
    const int_T   nRows
    );

DSPFFT_EXPORT void MWDSP_Ifft_AddCSSignals_Z_Zbr_OOP(
    creal_T *y,
    const creal_T *u,
    const int_T   nChans,
    const int_T   nRows
    );

DSPFFT_EXPORT void MWDSP_Ifft_AddCSSignals_Z_Zbr(
    creal_T *y,
    const int_T   nChans,
    const int_T   nRows
    );

DSPFFT_EXPORT void MWDSP_Ifft_AddCSSignals_C_Cbr_OOP(
    creal32_T *y,
    const creal32_T *u,
    const int_T   nChans,
    const int_T   nRows
    );

DSPFFT_EXPORT void MWDSP_Ifft_AddCSSignals_C_Cbr(
    creal32_T *y,
    const int_T   nChans,
    const int_T   nRows
    );

DSPFFT_EXPORT void MWDSP_Ifft_AddCSSignals_D_Z_Oop(
    creal_T *y,
    const real_T *u,
    const int_T   nChans,
    const int_T   nRows
    );

DSPFFT_EXPORT void MWDSP_Ifft_AddCSSignals_R_C_Oop(
    creal32_T *y,
    const real32_T *u,
    const int_T   nChans,
    const int_T   nRows
    );

DSPFFT_EXPORT void MWDSP_Ifft_AddCSSignals_D_Zbr_Oop(
    creal_T *y,
    const real_T *u,
    const int_T   nChans,
    const int_T   nRows
    );

DSPFFT_EXPORT void MWDSP_Ifft_AddCSSignals_R_Cbr_Oop(
    creal32_T *y,
    const real32_T *u,
    const int_T   nChans,
    const int_T   nRows
    );

/*
 * Separate each length N complex signal into two length N real signals.
 *   Real part goes into sig1, imag part into sig2.
 */
DSPFFT_EXPORT void MWDSP_Ifft_Deinterleave_D_D_Inp(
    real_T *array,
    const int_T nChansby2,
    const int_T Ntimes2,
    real_T *tmp
    );

DSPFFT_EXPORT void MWDSP_Ifft_Deinterleave_R_R_Inp(
    real32_T *array,
    const int_T nChansby2,
    const int_T Ntimes2,
    real32_T *tmp
    );

/*
 * Dbl length preprocessing for conjugate symmetric IFFT
 *   Direct trig function evaluation
 *   Input is in length N normal order
 *   Output is in length N/2 bit reversed order
 */
DSPFFT_EXPORT void MWDSP_Ifft_DblLen_TRIG_Z_Zbr_Oop(
    creal_T       *y,
    const creal_T *x,
    const int_T    fftLen
    );
DSPFFT_EXPORT void MWDSP_Ifft_DblLen_TRIG_C_Cbr_Oop(
    creal32_T       *y,
    const creal32_T *x,
    const int_T      fftLen
    );
DSPFFT_EXPORT void MWDSP_Ifft_DblLen_TRIG_D_Zbr_Oop(
    creal_T       *y,
    const real_T  *x,
    const int_T    fftLen
    );
DSPFFT_EXPORT void MWDSP_Ifft_DblLen_TRIG_R_Cbr_Oop(
    creal32_T       *y,
    const real32_T  *x,
    const int_T      fftLen
    );
DSPFFT_EXPORT void MWDSP_Ifft_DblLen_TBL_Z_Zbr_Oop(
    creal_T       *y,
    const creal_T *x,
    const int_T    fftLen,
    const real_T  *twiddleTable,
    const int_T    twiddleStep
    );

DSPFFT_EXPORT void MWDSP_Ifft_DblLen_TBL_D_Zbr_Oop(
    creal_T       *y,
    const real_T *x,
    const int_T    fftLen,
    const real_T  *twiddleTable,
    const int_T    twiddleStep
    );

DSPFFT_EXPORT void MWDSP_Ifft_DblLen_TBL_Zbr_Zbr_Oop(
    creal_T       *y,
    const creal_T *x,
    const int_T    fftLen,
    const real_T  *twiddleTable,
    const int_T    twiddleStep
    );

DSPFFT_EXPORT void MWDSP_Ifft_DblLen_TBL_Cbr_Cbr_Oop(
    creal32_T       *y,
    const creal32_T *x,
    const int_T      fftLen,
    const real32_T  *twiddleTable,
    const int_T      twiddleStep
    );

DSPFFT_EXPORT void MWDSP_Ifft_DblLen_TBL_Dbr_Zbr_Oop(
    creal_T       *y,
    const real_T *x,
    const int_T    fftLen,
    const real_T  *twiddleTable,
    const int_T    twiddleStep
    );

DSPFFT_EXPORT void MWDSP_Ifft_DblLen_TBL_Rbr_Cbr_Oop(
    creal32_T       *y,
    const real32_T  *x,
    const int_T      fftLen,
    const real32_T  *twiddleTable,
    const int_T      twiddleStep
    );

DSPFFT_EXPORT void MWDSP_Ifft_DblLen_TBL_C_Cbr_Oop(
    creal32_T       *y,
    const creal32_T *x,
    const int_T      fftLen,
    const real32_T  *twiddleTable,
    const int_T      twiddleStep
    );

DSPFFT_EXPORT void MWDSP_Ifft_DblLen_TBL_R_Cbr_Oop(
    creal32_T       *y,
    const real32_T  *x,
    const int_T      fftLen,
    const real32_T  *twiddleTable,
    const int_T      twiddleStep
    );

DSPFFT_EXPORT void MWDSP_Ifft_DblLen_TRIG_Zbr_Zbr_Oop(
    creal_T       *y,
    const creal_T *x,
    const int_T    fftLen
    );
DSPFFT_EXPORT void MWDSP_Ifft_DblLen_TRIG_Cbr_Cbr_Oop(
    creal32_T       *y,
    const creal32_T *x,
    const int_T      fftLen
    );
DSPFFT_EXPORT void MWDSP_Ifft_DblLen_TRIG_Dbr_Zbr_Oop(
    creal_T       *y,
    const real_T  *x,
    const int_T    fftLen
    );
DSPFFT_EXPORT void MWDSP_Ifft_DblLen_TRIG_Rbr_Cbr_Oop(
    creal32_T       *y,
    const real32_T  *x,
    const int_T      fftLen
    );
DSPFFT_EXPORT void MWDSP_CopyColAsRow_Z(
    creal_T          *y,
    const creal_T    *x,
    const int_T       nCols,
    const int_T       nRows,
    const int_T       rowIdx
    );
DSPFFT_EXPORT void MWDSP_CopyRowAsCol_Z(
    creal_T          *y,
    const creal_T    *x,
    const int_T       nCols,
    const int_T       nRows,
    const int_T       rowIdx
    );
DSPFFT_EXPORT void MWDSP_CopyRowAsCol_DZ(
    creal_T          *y,
    const real_T     *x,
    const int_T       nCols,
    const int_T       nRows,
    const int_T       rowIdx
    );
DSPFFT_EXPORT void MWDSP_CopyColAsRow_C(
    creal32_T          *y,
    const creal32_T    *x,
    const int_T         nCols,
    const int_T         nRows,
    const int_T         rowIdx
    ); 
DSPFFT_EXPORT void MWDSP_CopyRowAsCol_C(
    creal32_T          *y,
    const creal32_T    *x,
    const int_T         nCols,
    const int_T         nRows,
    const int_T         rowIdx
    );
DSPFFT_EXPORT void MWDSP_CopyRowAsCol_RC(
    creal32_T          *y,
    const real32_T     *x,
    const int_T         nCols,
    const int_T         nRows,
    const int_T         rowIdx
    );
DSPFFT_EXPORT void MWDSP_CopyRowAsColBR_Z(
    creal_T          *y,
    const creal_T    *x,
    const int_T       nCols,
    const int_T       nRows,
    const int_T       rowIdx
    );
DSPFFT_EXPORT void MWDSP_CopyRowAsColBR_DZ(
    creal_T          *y,
    const real_T     *x,
    const int_T       nCols,
    const int_T       nRows,
    const int_T       rowIdx
    );

DSPFFT_EXPORT void MWDSP_CopyRowAsColBR_C(
    creal32_T          *y,
    const creal32_T    *x,
    const int_T         nCols,
    const int_T         nRows,
    const int_T         rowIdx
    );
DSPFFT_EXPORT void MWDSP_CopyRowAsColBR_RC(
    creal32_T          *y,
    const real32_T     *x,
    const int_T         nCols,
    const int_T         nRows,
    const int_T         rowIdx
    );

DSPFFT_EXPORT void MWDSP_copyAdjRowsIntColBR_C(
     creal32_T *y, 
     const real32_T *x,
     const int_T nCols,
     const int_T nRows,
     const int_T rowIdx);
DSPFFT_EXPORT void MWDSP_copyAdjRowsIntColBR_Z(
     creal_T *y, 
     const real_T *x,
     const int_T nCols,
     const int_T nRows,
     const int_T rowIdx);
DSPFFT_EXPORT void MWDSP_copyAdjRowsIntCol_C(
     creal32_T *y, 
     const real32_T *x,
     const int_T nCols,
     const int_T nRows,
     const int_T rowIdx);
DSPFFT_EXPORT void MWDSP_copyAdjRowsIntCol_Z(
     creal_T *y, 
     const real_T *x,
     const int_T nCols,
     const int_T nRows,
     const int_T rowIdx);
#endif /* dspfft_rt_h */

/* [EOF] dspfft_rt.h */

