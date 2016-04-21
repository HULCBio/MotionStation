/*
 *  dsprandsrc64bit_rt.h
 *
 *  Abstract: Header file for double precision (64 bit) run-time library functions
 *  for the random source random number generator
 *
 *  Copyright 2004 The MathWorks, Inc.
 *  $Revision $ $Date: 2004/02/09 06:39:34 $
 */

#ifndef DSPRANDSRC64BIT_RT_H
#define DSPRANDSRC64BIT_RT_H

#include "dsp_rt.h"
#include "dsprandsrc_rt.h"

#ifdef DSPRANDSRC64BIT_EXPORTS
#define DSPRANDSRC64BIT_EXPORT EXPORT_FCN
#else
#define DSPRANDSRC64BIT_EXPORT extern
#endif


/* Random Source Random Number Generator Implementation
 *
 * Function naming glossary:
 *
 * All number generation functions are of the form:
 *
 *   MWDSP_RandSrc_{U|GC|GZ}_{R|C|D|Z}
 *
 *  where:
 *   MWDSP     = MathWorks DSP
 *   RandSrc   = Random Source identifier
 *   {U|GZ|GC} = Random Number distribution:
 *                U : Uniform
 *                GZ: Gaussian, Ziggurat algorithm
 *                GC: Gaussian, using central limit theorem
 *                    (see below)
 *   {R|C|D|Z} = Output datatype (see below)
 *
 *  The Gaussian/Central Limit Theorem generator uses the
 *  corresponding Uniform generator to create a vector of
 *  uniformly distributed values, which are then used to
 *  calculate a Gaussian variate according to the CLT.  The
 *  number of uniform values to employ is user-definable.
 *
 *  Data types - (describes output)
 *
 *   R = real single-precision
 *   C = complex single-precision
 *   D = real double-precision
 *   Z = complex double-precision
 *
 * RandSrc function arguments:
 *   y      = pointer to output signal
 *   param1 = pointer to vector of mins (U) or means (G)
 *   len1   = length of param1 vector
 *   param2 = pointer to vector of maxs (U) or transformed
 *            standard deviations (see below) (G)
 *   len2   = length of param2 vector
 *   state  = pointer to random number generator state
 *            always real-valued (see note below)
 *   nChans = number of channels in output signal
 *   nSamps = number of samples/rows in each output channel
 *   cltVec = (GC only) vector workspace for uniform samples
 *   cltLen = (GC only) number of uniform samples to use to
 *            generate approximate Gaussian distribution
 *
 *   param vectors must have length equal to one or nChans.  Length
 *   one param vectors are "scalar expanded" to each channel.
 *
 *   Note on standard deviations:  for performance reasons, the
 *   standard deviation vectors are assumed to be transformed prior
 *   to the function call according to the table below:
 *
 *   Type        : Transformation Factor
 *   -----------------------------------
 *   GZ, real    : no transformation
 *   GZ, complex : 1/sqrt(2.0)
 *   GC, real    : sqrt(12.0 * ctlLen)
 *   GC, complex : sqrt(6.0 * ctlLen)
 *
 * Random Number Generator State:
 *  The state vector must consist of a known number of elements,
 *  depending on the random distribution.
 *    Uniform:           35*nChans real{64|32}_T elements
 *    Gaussian/Ziggurat:  2*nChans uint32_T elements
 *    Gaussian/CLT:      35*nChans real{64|32}_T elements
 *
 * All state initialization functions are of the form:
 *
 *   MWDSP_RandSrcInitStateU_32
 *   MWDSP_RandSrcInitStateU_64
 *   MWDSP_RandSrcInitStateGZ
 *   MWDSP_RandSrcInitStateGC_32
 *   MWDSP_RandSrcInitStateGC_64
 *
 *  where U and G have the same meaning as above, and 32 or 64
 *  refers to the precision (32 = single precision, 64 = double)
 *
 * RandSrcInitState function arguments:
 *
 *   seeds  = length nChans vector of initial seeds
 *   state  = pointer to state vector to be initialized
 *   nChans = number of channels in state
 *
 *  Seed values must be unsigned integers.
 *
 *************************************
 *  NOTE ON STATE VECTOR DATA TYPES  *
 *************************************
 *
 * For the UNIFORM and GAUSSIAN/CLT distribution functions, the
 * state vector *MUST* be real32_T or real64_T, *NOT* real_T.  The
 * algorithms are inherently single- or double-precision (32 or 64
 * bit); using real_T and redefining real_T to the wrong precision
 * would break this code. Similarly, for the GAUSSIAN/ZIGGURAT
 * distribution functions, the state vector *MUST* be uint32_T to
 * guarantee 32 unsigned bits in each state element.
 *
 * There are also two utility functions:
 *  MWDSP_RandSrcCreateSeeds{32|64}
 * with arguments:
 *   initSeed  = the "seed seed" - used to initialize a temporary state
 *               vector
 *   seedArray = output seed array (already alloc'd)
 *   numSeeds  = length of seed array
 * These functions will create a vector of random seeds that can be used
 * to initialize a multi-channel output.  It creates many seeds out of
 * one seed.  The 64 version uses the double-precision uniform generation
 * functions internally; the 32 version uses the single-precision ones.
*/

/* MWDSP_RandSrcInitState_U_64
 * Uniform distribution
 * seeds = nChans uint_T elements
 * state = 35*nChans real64_T elements
 */
DSPRANDSRC64BIT_EXPORT void MWDSP_RandSrcInitState_U_64(const uint32_T *seeds,
                                        real64_T       *state,
                                        int_T           nChans);

/* MWDSP_RandSrc_U_D
 * double-precision real output, uniform distribution
 * y       = nChans*nSamps real64_T elements
 * min,max = nChans real64_T elements (or 1 element)
 * state   = 35*nChans real64_T elements
 */
DSPRANDSRC64BIT_EXPORT void MWDSP_RandSrc_U_D(real64_T *y,  const real64_T *min,
                              int_T minLen, const real64_T *max,
                              int_T maxLen, real64_T       *state,
                              int_T nChans, int_T           nSamps);

/* MWDSP_RandSrc_U_Z
 * double-precision complex output, uniform distribution
 * y       = nChans*nSamps creal64_T elements
 * min,max = nChans real64_T elements (or 1 element)
 * state   = 35*nChans real64_T elements
 */
DSPRANDSRC64BIT_EXPORT void MWDSP_RandSrc_U_Z(creal64_T *y, const real64_T *min,
                              int_T minLen, const real64_T *max,
                              int_T maxLen, real64_T       *state,
                              int_T nChans, int_T           nSamps);

/* MWDSP_RandSrc_GZ_D
 * double-precision real output, Gaussian distribution
 * y       = nChans*nSamps real64_T elements
 * mean    = nChans real64_T elements (or 1 element)
 * xstd    = nChans real64_T elements (or 1 element)
 * state   = 2*nChans uint_T elements
 */
DSPRANDSRC64BIT_EXPORT void MWDSP_RandSrc_GZ_D(real64_T *y,   const real64_T *mean,
                               int_T meanLen, const real64_T *xstd,
                               int_T xstdLen, uint32_T       *state,
                               int_T nChans,  int_T           nSamps);

/* MWDSP_RandSrc_GZ_Z
 * double-precision complex output, Gaussian distribution
 * y       = nChans*nSamps creal64_T elements
 * mean    = nChans creal64_T elements (or 1 element)
 * xstd    = nChans real64_T elements (or 1 element)
 * state   = 2*nChans uint_T elements
 */
DSPRANDSRC64BIT_EXPORT void MWDSP_RandSrc_GZ_Z(creal64_T *y,  const creal64_T *mean,
                               int_T meanLen, const real64_T *xstd,
                               int_T xstdLen, uint32_T       *state,
                               int_T nChans,  int_T           nSamps);


/* MWDSP_RandSrcInitState_GC_64
 * Gaussian/CLT distribution
 * seeds = nChans uint_T elements
 * state = 35*nChans real64_T elements
 *
 * This function is a wrapper around
 * MWDSP_RandSrcInitState_U_64
 */
DSPRANDSRC64BIT_EXPORT void MWDSP_RandSrcInitState_GC_64(const uint32_T *seeds,
                                         real64_T       *state,
                                         int_T           nChans);

/* MWDSP_RandSrc_GC_D
 * double-precision real output, Gaussian distribution
 * y       = nChans*nSamps real64_T elements
 * mean    = nChans real64_T elements (or 1 element)
 * xstd    = nChans real64_T elements (or 1 element)
 * state   = 35*nChans real64_T elements
 * cltVec  = cltLen real64_T element array for holding uniform values
 * cltLen  = scalar, number of uniform variates used to
 *           construct Gaussian variate
 */
DSPRANDSRC64BIT_EXPORT void MWDSP_RandSrc_GC_D(real64_T *y,       const real64_T *mean,
                               int_T     meanLen, const real64_T *xstd,
                               int_T     xstdLen, real64_T       *state,
                               int_T     nChans,  int_T           nSamps,
                               real64_T *cltVec,  int_T           cltLen);

/* MWDSP_RandSrc_GC_Z
 * double-precision complex output, Gaussian distribution
 * y       = nChans*nSamps creal64_T elements
 * mean    = nChans creal64_T elements (or 1 element)
 * xstd    = nChans real64_T elements (or 1 element)
 * state   = 35*nChans real64_T elements
 * cltVec  = cltLen real64_T element array for holding uniform values
 * cltLen  = scalar, number of uniform variates used to
 *           construct Gaussian variate
 */
DSPRANDSRC64BIT_EXPORT void MWDSP_RandSrc_GC_Z(creal64_T *y,       const creal64_T *mean,
                               int_T      meanLen, const real64_T *xstd,
                               int_T      xstdLen, real64_T       *state,
                               int_T      nChans,  int_T           nSamps,
                               real64_T  *cltVec,  int_T           cltLen);


/* MWDSP_RandSrcCreateSeeds_64
 * seed creation utility function (uses double-precision
 * functions MWDSP_RandSrcInitState_64 and MWDSP_RandSrc_U_D)
 * seedArray = numSeeds uint32_T elements
 */
DSPRANDSRC64BIT_EXPORT void MWDSP_RandSrcCreateSeeds_64(uint32_T  initSeed,
                                        uint32_T *seedArray,
                                        uint32_T  numSeeds);

#endif /* DSPRANDSRC64BIT_RT_H */
