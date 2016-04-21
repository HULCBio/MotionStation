/*
 *  dspfilter_rt.h
 *
 *  Abstract: Header file for convenient inclusion of all necessary
 *  run-time library functions for the DSP Blockset filter block.
 *
 *  Copyright 1995-2002 The MathWorks, Inc.
 *  $Revision: 1.6 $ $Date: 2002/04/14 20:36:24 $
 */

#ifndef dspfilter_rt_h
#define dspfilter_rt_h

/*
 * ====================================================
 * Naming conventions for DSP run-time filter functions
 * ====================================================
 *
 * The factors determining which function should be called are:
 *
 * 1) filter type
 * 2) filter structure
 * 3) filter operation (1 filter per frame time vs. 1 filter per sample time)
 * 4) input and coefficient data types
 *
 * Combinations of these four criteria will map to one function.  Not every
 * combination of possible options for the above criteria is supported,
 * e.g., biquad filter types (BQ4, BQ5, and BQ6) do not operate in 1 filter per
 * sample time mode.
 *
 * Correspondingly, functions in this library are named as follows.
 *
 * Format : MWDSP_{AllPole|FIR|IIR|BQn}_{FilterStructure}_{1fpf|1fps}_{InputAndCoeffDataTypes}
 *
 * Details:
 *
 * 1) MWDSP indicates it is a MathWorks DSP run-time library
 * 2) The second field describes the filter transfer function H(z)
 *    AllPole : H(z) has denominator only
 *    FIR     : H(z) has numerator only
 *    IIR     : H(z) has both numerator and denominator
 *    BQn     : H(z) - a cascade of second-order sections
 *            : BQ6  - each section has non-normalized num and den coeffs
 *            : BQ5  - each section has normalized den coeffs
 *            : BQ4  - each section has normalized num AND den coeffs
 * 3) The FilterStructure field indicates the filter structure
 *    (e.g. DF2T, DF2, DF1T, DF1, TDF, DF, LATC ...)
 * 4) The next field (either "1fpf" or "1fps") indicates
 *    "1 filter per frame time" or "1 filter per sample time", respectively.
 *    Refer to the DSP Blockset documentation for more details.
 * 5) The InputAndCoeffDataTypes field indicates the input and
 *    coefficient data types (e.g. DDD, DZD, CRC, ...).  The first
 *    letter refers to the input signal.  The second letter refers
 *    to the first coefficient set.  The third letter is required
 *    only when there is a second coefficient set.  
 *
 *    The abbreviations used for these data types are as follows:
 * 
 *    R = real single-precision
 *    C = complex single-precision
 *    D = real double-precision
 *    Z = complex double-precision
 *
 * As an example, consider a function for the following filter:
 *
 * 1) IIR filter
 * 2) Direct-Form II Transpose
 * 3) 1 filter per frame time
 * 4) Complex single precision input
 *    Real single precision numerator coefficients
 *    Complex single precision denominator coefficients
 *
 * The filter function for this example would be:
 *
 *    void MWDSP_IIR_DF2T_1fpf_CRC 
 */

#include "dspallpole_rt.h" /* All-pole (AR)   filters */
#include "dspfir_rt.h"     /* FIR      (MA)   filters */
#include "dspiir_rt.h"     /* IIR      (ARMA) filters */
#include "dspbiquad_rt.h"  /* IIR BiQuad (cascaded second-order sections) filters */

/*
 *  The following macros normalize elements in a vector s[i] by a scalar 
 *  element k.  The fundamental operation being performed is:
 *
 *  for (i = 0; i < numElems; i++ ) {d[i] = s[i] / k;}
 *
 *  The datatype and complexity of the scalar k is assumed to be the
 *  same as that of the source vector s[i].  The macros have names
 *  that are of the following form:
 *
 *  MWDSP_NormalizeVector_{R|C|D|Z}
 *
 *  The last field of the name is a single-letter suffix that serves to
 *  identify the datatype/complexity of the elements being normalized:
 *    D - s[i] is double-precision floating-point, real-valued only
 *    Z - s[i] is double-precision floating-point, complex-valued
 *    R - s[i] is single-precision floating-point, real-valued only
 *    C - s[i] is single-precision floating-point, complex-valued
 *
 *  Each macro has the following arguments:
 *
 *  (kPtr, dstPtr, srcPtr, numElems)
 *
 *  where:
 *    - kPtr is a pointer to the normalizing scalar k (assumed non-zero)
 *    - dstPtr is a pointer to the destination vector d[i]
 *    - srcPtr is a pointer to the source vector s[i]
 *    - numElems is the number of elements in s[i] to be normalized
 */

#define MWDSP_NormalizeVector_D(kPtr, dstPtr, srcPtr, numElems) \
    {                                                           \
      real_T  kinv = 1.0 / *((real_T *) (kPtr));                \
      real_T *src  = (real_T *) (srcPtr);                       \
      real_T *dst  = (real_T *) (dstPtr);                       \
      int_T   n    = (numElems);                                \
                                                                \
      while (n--) { *dst++ = *src++ * kinv; }                   \
    }


#define MWDSP_NormalizeVector_Z(kPtr, dstPtr, srcPtr, numElems)   \
    {                                                             \
      creal_T *src = (creal_T *) (srcPtr);                        \
      creal_T *dst = (creal_T *) (dstPtr);                        \
      int_T    n   = (numElems);                                  \
      creal_T  kinv;                                              \
                                                                  \
      CRECIP((*((creal_T *) (kPtr))), kinv); /* kinv = 1.0 / k */ \
      while (n--) {                                               \
          creal_T tmpSrc = (*src++);                              \
          (*dst).re = CMULT_RE((tmpSrc), kinv);                   \
          (*dst).im = CMULT_IM((tmpSrc), kinv);                   \
          dst++;                                                  \
      }                                                           \
    }


#define MWDSP_NormalizeVector_R(kPtr, dstPtr, srcPtr, numElems) \
    {                                                           \
      real32_T  kinv = 1.0F / *((real32_T *) (kPtr));           \
      real32_T *src  = (real32_T *) (srcPtr);                   \
      real32_T *dst  = (real32_T *) (dstPtr);                   \
      int_T     n    = (numElems);                              \
                                                                \
      while (n--) { *dst++ = *src++ * kinv; }                   \
    }


#define MWDSP_NormalizeVector_C(kPtr, dstPtr, srcPtr, numElems)        \
    {                                                                  \
      creal32_T *src = (creal32_T *) (srcPtr);                         \
      creal32_T *dst = (creal32_T *) (dstPtr);                         \
      int_T      n   = (numElems);                                     \
      creal32_T  kinv;                                                 \
                                                                       \
      CRECIP32((*((creal32_T *) (kPtr))), kinv); /* kinv = 1.0F / k */ \
      while (n--) {                                                    \
          creal32_T tmpSrc = (*src++);                                 \
          (*dst).re = CMULT_RE((tmpSrc), kinv);                        \
          (*dst).im = CMULT_IM((tmpSrc), kinv);                        \
          dst++;                                                       \
      }                                                                \
    }


#endif /* dspfilter_rt_h */

/* [EOF] dspfilter_rt.h */
