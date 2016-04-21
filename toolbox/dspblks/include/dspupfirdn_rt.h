/*
 *  dspupfirdn_rt.h
 *
 *  Abstract: Header file for DSP run-time library helper functions
 *  for the FIR rate conversion block.
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.3.4.3 $ $Date: 2004/04/12 23:12:19 $
 */

#ifndef dspupfirdn_rt_h
#define dspupfirdn_rt_h

#include "dsp_rt.h"

#ifdef DSPUPFIRDN_EXPORTS
#define DSPUPFIRDN_EXPORT EXPORT_FCN
#else
#define DSPUPFIRDN_EXPORT MWDSP_IDECL
#endif

/* FIR RATE CONVERTER BLOCK (UPFIRDN) IMPLEMENTATION
 * Description: 
 * This rate converter block implicitly upsamples the input by iFactor and downsamples 
 * it by dFactor so that the new sample rate is iFactor/dFactor times the input sample
 * rate. This block only works for framebased inputs and the modules in this library 
 * require an input frame size (inFrameSize) that is an integer multiple of dFactor.
 *
 * Memory Architecture:
 * The input buffer, output buffer and partialSums buffer has the memory structure
 *   ----------------------------------------------
 *   |    Channel 0     |     Channel 1      |  ...
 *   |mem0 | mem1 |...  | mem0 | mem1 |   ...|  ...
 *   ---------------------------------------------- 
 *
 * Input buffer size  = numChans * ( length(filter)/iFactor + iFactor*n0 ) 
 * Output buffer size = numChans * iFactor * n1
 * PartialSums buffer size = numChans * iFactor
 * 
 * Filter Coefficients are arranged by the mask helper function dspblkupfirdn.m:
 * Filter coefficients are arranged into iFactor interpolation groups.  
 * Each interpolation group contains dFactor decimation polyphase subfilters; 
 * the order of these dFactor decimation subfilters is subOrder. 
 * There is a total of iFactor*dFactor polyphase sub-filters.
 * At every input sample, all of the iFactor interpolation filters are executed
 * while only 1 of the dFactor decimation sub-filters in each interpolation group
 * is executed.
 * The filter memory bank is arranged as follows:
 * 1. All coeffs from any one of the iFactor*dFactor subfilters belong to 
 *    the same column
 * 2. There are dFactor groups of columns.
 * 3. Each of the above dFactor groups of columns contains iFactor columns.
 * Using these memory arrangements, the coef pointer in the C code is incremented
 * once with each input sample and resets itself when all the polyphase subfilters 
 * are executed. 
 *
 * Algorithm:
 * The run-time function MWDSP_UpFIRDn_DD is fully documented to show the 
 * algorithm.
 * Reference: Multirate Digital Signal Processing, N.J.Fliege, 
 *            John Wiley & Sons, 1994, page 110.
 *
 */

DSPUPFIRDN_EXPORT void MWDSP_UpFIRDn_DD(const real_T *u,             /* input port*/
                                   real_T *y,             /* output port*/
                                   real_T *tap0,          /* points to input buffer start address per channel */
                                   real_T *sums,          /* points to output of each interp phase per channel */
                                   real_T *outBuf,        /* points to output buffer start address per channel */
                             const real_T * const filter, /* FIR coeff */
                                   int32_T  *tapIdx,        /* points to input buffer location to read in u */
                                   int32_T  *outIdx,        /* points to output buffer data for transfer to y */
                             const int_T  numChans,       /* number of channels */
                             const int_T  inFrameSize,    /* input frame size */
                             const int_T  iFactor,        /* interpolation factor */
                             const int_T  dFactor,        /* decimation factor */
                             const int_T  subOrder,       /* order of each iFactor*dFactor polyphase subfilter */
                             const int_T  memSize,        /* input buffer size per channel */
                             const int_T  outLen,         /* output buffer size per channel */
                             const int_T  n0,             /* inputs to each interpolation phase is separated by n0 samples */
                             const int_T  n1              /* outputs of each interpolation phase is separated by n1 samples */
                             );

DSPUPFIRDN_EXPORT void MWDSP_UpFIRDn_DZ(const real_T  *u, 
                                   creal_T *y, 
                                   real_T  *tap0,
                                   creal_T *sums,
                                   creal_T *outBuf,
                             const creal_T * const filter,
                                   int32_T  *tapIdx,
                                   int32_T  *outIdx,
                             const int_T  numChans,
                             const int_T  inFrameSize,
                             const int_T  iFactor,
                             const int_T  dFactor,
                             const int_T  subOrder,
                             const int_T  memSize,
                             const int_T  outLen,
                             const int_T  n0,
                             const int_T  n1);

DSPUPFIRDN_EXPORT void MWDSP_UpFIRDn_ZD(const creal_T *u, 
                                   creal_T *y, 
                                   creal_T *tap0,
                                   creal_T *sums,
                                   creal_T *outBuf,
                             const real_T * const filter,
                                   int32_T  *tapIdx,
                                   int32_T  *outIdx,
                             const int_T  numChans,
                             const int_T  inFrameSize,
                             const int_T  iFactor,
                             const int_T  dFactor,
                             const int_T  subOrder,
                             const int_T  memSize,
                             const int_T  outLen,
                             const int_T  n0,
                             const int_T  n1);

DSPUPFIRDN_EXPORT void MWDSP_UpFIRDn_ZZ(const creal_T *u, 
                                   creal_T *y, 
                                   creal_T *tap0,
                                   creal_T *sums,
                                   creal_T *outBuf,
                             const creal_T * const filter,
                                   int32_T  *tapIdx,
                                   int32_T  *outIdx,
                             const int_T  numChans,
                             const int_T  inFrameSize,
                             const int_T  iFactor,
                             const int_T  dFactor,
                             const int_T  subOrder,
                             const int_T  memSize,
                             const int_T  outLen,
                             const int_T  n0,
                             const int_T  n1);

DSPUPFIRDN_EXPORT void MWDSP_UpFIRDn_RR(const real32_T *u,             /* input port*/
                                   real32_T *y,             /* output port*/
                                   real32_T *tap0,          /* points to input buffer start address per channel */
                                   real32_T *sums,          /* points to output of each interp phase per channel */
                                   real32_T *outBuf,        /* points to output buffer start address per channel */
                             const real32_T * const filter, /* FIR coeff */
                                   int32_T  *tapIdx,        /* points to input buffer location to read in u */
                                   int32_T  *outIdx,        /* points to output buffer data for transfer to y */
                             const int_T  numChans,       /* number of channels */
                             const int_T  inFrameSize,    /* input frame size */
                             const int_T  iFactor,        /* interpolation factor */
                             const int_T  dFactor,        /* decimation factor */
                             const int_T  subOrder,       /* order of each iFactor*dFactor polyphase subfilter */
                             const int_T  memSize,        /* input buffer size per channel */
                             const int_T  outLen,         /* output buffer size per channel */
                             const int_T  n0,             /* inputs to each interpolation phase is separated by n0 samples */
                             const int_T  n1              /* outputs of each interpolation phase is separated by n1 samples */
                             );

DSPUPFIRDN_EXPORT void MWDSP_UpFIRDn_RC(const real32_T  *u, 
                                   creal32_T *y, 
                                   real32_T  *tap0,
                                   creal32_T *sums,
                                   creal32_T *outBuf,
                             const creal32_T * const filter,
                                   int32_T  *tapIdx,
                                   int32_T  *outIdx,
                             const int_T  numChans,
                             const int_T  inFrameSize,
                             const int_T  iFactor,
                             const int_T  dFactor,
                             const int_T  subOrder,
                             const int_T  memSize,
                             const int_T  outLen,
                             const int_T  n0,
                             const int_T  n1);

DSPUPFIRDN_EXPORT void MWDSP_UpFIRDn_CR(const creal32_T *u, 
                                   creal32_T *y, 
                                   creal32_T *tap0,
                                   creal32_T *sums,
                                   creal32_T *outBuf,
                             const real32_T * const filter,
                                   int32_T  *tapIdx,
                                   int32_T  *outIdx,
                             const int_T  numChans,
                             const int_T  inFrameSize,
                             const int_T  iFactor,
                             const int_T  dFactor,
                             const int_T  subOrder,
                             const int_T  memSize,
                             const int_T  outLen,
                             const int_T  n0,
                             const int_T  n1);

DSPUPFIRDN_EXPORT void MWDSP_UpFIRDn_CC(const creal32_T *u, 
                                   creal32_T *y, 
                                   creal32_T *tap0,
                                   creal32_T *sums,
                                   creal32_T *outBuf,
                             const creal32_T * const filter,
                                   int32_T  *tapIdx,
                                   int32_T  *outIdx,
                             const int_T  numChans,
                             const int_T  inFrameSize,
                             const int_T  iFactor,
                             const int_T  dFactor,
                             const int_T  subOrder,
                             const int_T  memSize,
                             const int_T  outLen,
                             const int_T  n0,
                             const int_T  n1);

#ifdef MWDSP_INLINE_DSPRTLIB
#include "dspupfirdn/upfirdn_cc_rt.c"
#include "dspupfirdn/upfirdn_cr_rt.c"
#include "dspupfirdn/upfirdn_dd_rt.c"
#include "dspupfirdn/upfirdn_dz_rt.c"
#include "dspupfirdn/upfirdn_rc_rt.c"
#include "dspupfirdn/upfirdn_rr_rt.c"
#include "dspupfirdn/upfirdn_zd_rt.c"
#include "dspupfirdn/upfirdn_zz_rt.c"
#endif

#endif  /* dspupfirdn_rt_h */

/* [EOF] dspupfirdn_rt.h */
