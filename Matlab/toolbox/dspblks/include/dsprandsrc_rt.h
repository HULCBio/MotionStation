/*
 *  dsprandsrc_rt.h
 *
 *  Abstract: Header file for run-time library functions
 *  that apply to both 64 bit and 32 bit versions
 *  of the random source random number generator
 *
 *  DO NOT INCLUDE THIS FILE DIRECTLY. IT IS INCLUDED BY
 *  dsprandsrc64bit_rt.h AND dsprandsrc32bit_rt.h FOR THE ONE FUNCTION THAT
 *  IS SHARED BY BOTH: MWDSP_RandSrcInitState_GZ
 *
 *  Copyright 1995-2004 The MathWorks, Inc.
 *  $Revision: 1.4.4.3 $ $Date: 2004/04/12 23:12:11 $
 */

#ifndef DSPRANDSRC_RT_H
#define DSPRANDSRC_RT_H

#include "dsp_rt.h"

#ifdef DSPRANDSRC_EXPORTS
#define DSPRANDSRC_EXPORT EXPORT_FCN
#else
#define DSPRANDSRC_EXPORT extern
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

/* MWDSP_RandSrcInitState_GZ
 * Gaussian/Ziggurat distribution
 * seeds = nChans uint_T elements
 * state = 2*nChans uint_T elements
 */
DSPRANDSRC_EXPORT void MWDSP_RandSrcInitState_GZ(const uint32_T* seeds,
                                      uint32_T*       state,
                                      int_T           nChans);

#endif /* DSPRANDSRC_RT_H */
