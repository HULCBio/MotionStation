/*
 *  dspiir_rt.h
 *
 *  Abstract: Header file for DSP run-time library helper functions
 *  for IIR filters.
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.10.4.3 $ $Date: 2004/04/12 23:11:56 $
 */

#ifndef dspiir_rt_h
#define dspiir_rt_h

#include "dsp_rt.h"

#ifdef DSPIIR_EXPORTS
#define DSPIIR_EXPORT EXPORT_FCN
#else
#define DSPIIR_EXPORT MWDSP_IDECL
#endif

/* IIR DF2T IMPLEMENTATIONS
 * Algorithm: Direct Form-II Transposed
 *
 *   y[n]    = x[n]*b0           + D0[n]   (output)       b[n] = numerator polynomial,
 *   D0[n+1] = x[n]*b1 - y[n]*a1 + D1[n]   (delay         a[n] = denominator polynomial
 *   D1[n+1] = x[n]*b2 - y[n]*a2 + D2[n]   (updates)      D[n] = delay buffer containing state memory
 *   ...                                                  y    = output value
 *   DN[n+1] = x[n]*bN - y[n]*aN                          x    = input value
 *
 * Buffer storage:
 *   ----------------------------------------------
 *   |    Channel 0     |     Channel 1      |  ...
 *   |D0 | D1 | D2 |... | D0 | D1 | D2 | ... |  ...
 *   ----------------------------------------------
 * For each channel, there are numDelays = 1+max(ordNUM,ordDEN) state memories.
 * The last state memory value for each channel is always zero.  This extra 
 * zero-valued state greatly simplifies the algorithm.
 *
 * Note:
 * 1. Filter set 1 (cPtr1) points to the numerator coefficients.
 * 2. Filter set 2 (cPtr2) points to the denominator coefficients
 *    (the first filter coefficient a0 is assumed to be unity: 1.0).
 * 3. numStates holds the number of states per channel.
 * 4. In one filter per frame implementation, cPtr1 and cPtr2 point to a
 *    single filter coeff set.  cPtr1 is the num and cPtr2 is the den.
 *    This filter is applied to every sample in the frame.
 * 5. In one filter per sample implementation, cPtr1 and cPtr2 point to sampsPerChan
 *    filter coeff sets (such that each sample will be filtered by a separate filter
 *    coeff set).
 *
 * For the function naming conventions used below, see dspfilter_rt.h
 *
 */
/* DF2T functions: double-precision */
DSPIIR_EXPORT void MWDSP_IIR_DF2T_DD(const real_T         *u,
                              real_T               *y,
                              real_T * const       mem_base,
                              const int_T          numDelays,
                              const int_T          sampsPerChan,
                              const int_T          numChans,
                              const real_T * const num,
                              const int_T          ordNUM,
                              const real_T * const den,
                              const int_T          ordDEN,
                              const boolean_T      one_fpf);

DSPIIR_EXPORT void MWDSP_IIR_DF2T_DZ(const real_T          *u,
                              creal_T               *y,
                              creal_T * const       mem_base,
                              const int_T           numDelays,
                              const int_T           sampsPerChan,
                              const int_T           numChans,
                              const creal_T * const num,
                              const int_T           ordNUM,
                              const creal_T * const den,
                              const int_T           ordDEN,
                              const boolean_T       one_fpf);

DSPIIR_EXPORT void MWDSP_IIR_DF2T_ZD(const creal_T         *u,
                              creal_T               *y,
                              creal_T * const       mem_base,
                              const int_T           numDelays,
                              const int_T           sampsPerChan,
                              const int_T           numChans,
                              const real_T * const  num,
                              const int_T           ordNUM,
                              const real_T * const  den,
                              const int_T           ordDEN,
                              const boolean_T       one_fpf);

DSPIIR_EXPORT void MWDSP_IIR_DF2T_ZZ(const creal_T         *u,
                              creal_T               *y,
                              creal_T * const       mem_base,
                              const int_T           numDelays,
                              const int_T           sampsPerChan,
                              const int_T           numChans,
                              const creal_T * const num,
                              const int_T           ordNUM,
                              const creal_T * const den,
                              const int_T           ordDEN,
                              const boolean_T       one_fpf);


/* DF2T functions: single-precision */
DSPIIR_EXPORT void MWDSP_IIR_DF2T_RR(const real32_T         *u,
                              real32_T               *y,
                              real32_T * const       mem_base,
                              const int_T            numDelays,
                              const int_T            sampsPerChan,
                              const int_T            numChans,
                              const real32_T * const num,
                              const int_T            ordNUM,
                              const real32_T * const den,
                              const int_T            ordDEN,
                              const boolean_T        one_fpf);

DSPIIR_EXPORT void MWDSP_IIR_DF2T_RC(const real32_T          *u,
                              creal32_T               *y,
                              creal32_T * const       mem_base,
                              const int_T             numDelays,
                              const int_T             sampsPerChan,
                              const int_T             numChans,
                              const creal32_T * const num,
                              const int_T             ordNUM,
                              const creal32_T * const den,
                              const int_T             ordDEN,
                              const boolean_T         one_fpf);

DSPIIR_EXPORT void MWDSP_IIR_DF2T_CR(const creal32_T         *u,
                              creal32_T               *y,
                              creal32_T * const       mem_base,
                              const int_T             numDelays,
                              const int_T             sampsPerChan,
                              const int_T             numChans,
                              const real32_T * const  num,
                              const int_T             ordNUM,
                              const real32_T * const  den,
                              const int_T             ordDEN,
                              const boolean_T         one_fpf);

DSPIIR_EXPORT void MWDSP_IIR_DF2T_CC(const creal32_T         *u,
                              creal32_T               *y,
                              creal32_T * const       mem_base,
                              const int_T             numDelays,
                              const int_T             sampsPerChan,
                              const int_T             numChans,
                              const creal32_T * const num,
                              const int_T             ordNUM,
                              const creal32_T * const den,
                              const int_T             ordDEN,
                              const boolean_T         one_fpf);


/* DF2T functions: double-precision with 1/a0 scale factor in the case when 1st den. coeff. is non-unity */
DSPIIR_EXPORT void MWDSP_IIR_DF2T_A0Scale_DD(const real_T         *u,
                              real_T               *y,
                              real_T * const       mem_base,
                              const int_T          numDelays,
                              const int_T          sampsPerChan,
                              const int_T          numChans,
                              const real_T * const num,
                              const int_T          ordNUM,
                              const real_T * const den,
                              const int_T          ordDEN,
                              const boolean_T      one_fpf);

DSPIIR_EXPORT void MWDSP_IIR_DF2T_A0Scale_DZ(const real_T          *u,
                              creal_T               *y,
                              creal_T * const       mem_base,
                              const int_T           numDelays,
                              const int_T           sampsPerChan,
                              const int_T           numChans,
                              const creal_T * const num,
                              const int_T           ordNUM,
                              const creal_T * const den,
                              const int_T           ordDEN,
                              const boolean_T       one_fpf);

DSPIIR_EXPORT void MWDSP_IIR_DF2T_A0Scale_ZD(const creal_T         *u,
                              creal_T               *y,
                              creal_T * const       mem_base,
                              const int_T           numDelays,
                              const int_T           sampsPerChan,
                              const int_T           numChans,
                              const real_T * const  num,
                              const int_T           ordNUM,
                              const real_T * const  den,
                              const int_T           ordDEN,
                              const boolean_T       one_fpf);

DSPIIR_EXPORT void MWDSP_IIR_DF2T_A0Scale_ZZ(const creal_T         *u,
                              creal_T               *y,
                              creal_T * const       mem_base,
                              const int_T           numDelays,
                              const int_T           sampsPerChan,
                              const int_T           numChans,
                              const creal_T * const num,
                              const int_T           ordNUM,
                              const creal_T * const den,
                              const int_T           ordDEN,
                              const boolean_T       one_fpf);


/* DF2T functions: single-precision */
DSPIIR_EXPORT void MWDSP_IIR_DF2T_A0Scale_RR(const real32_T         *u,
                              real32_T               *y,
                              real32_T * const       mem_base,
                              const int_T            numDelays,
                              const int_T            sampsPerChan,
                              const int_T            numChans,
                              const real32_T * const num,
                              const int_T            ordNUM,
                              const real32_T * const den,
                              const int_T            ordDEN,
                              const boolean_T        one_fpf);

DSPIIR_EXPORT void MWDSP_IIR_DF2T_A0Scale_RC(const real32_T          *u,
                              creal32_T               *y,
                              creal32_T * const       mem_base,
                              const int_T             numDelays,
                              const int_T             sampsPerChan,
                              const int_T             numChans,
                              const creal32_T * const num,
                              const int_T             ordNUM,
                              const creal32_T * const den,
                              const int_T             ordDEN,
                              const boolean_T         one_fpf);

DSPIIR_EXPORT void MWDSP_IIR_DF2T_A0Scale_CR(const creal32_T         *u,
                              creal32_T               *y,
                              creal32_T * const       mem_base,
                              const int_T             numDelays,
                              const int_T             sampsPerChan,
                              const int_T             numChans,
                              const real32_T * const  num,
                              const int_T             ordNUM,
                              const real32_T * const  den,
                              const int_T             ordDEN,
                              const boolean_T         one_fpf);

DSPIIR_EXPORT void MWDSP_IIR_DF2T_A0Scale_CC(const creal32_T         *u,
                              creal32_T               *y,
                              creal32_T * const       mem_base,
                              const int_T             numDelays,
                              const int_T             sampsPerChan,
                              const int_T             numChans,
                              const creal32_T * const num,
                              const int_T             ordNUM,
                              const creal32_T * const den,
                              const int_T             ordDEN,
                              const boolean_T         one_fpf);

/* IIR filter type DF2 filter structure run-time functions */

DSPIIR_EXPORT void MWDSP_IIR_DF1T_DD(const real_T         *u,
                                    real_T               *y,
                                    real_T * const       mem_base,
                                    const int_T          numDelays,
                                    const int_T          sampsPerChan,
                                    const int_T          numChans,
                                    const real_T * const num,
                                    const int_T          ordNUM,
                                    const real_T * const den,
                                    const int_T          ordDEN,
                                    const boolean_T      one_fpf);

DSPIIR_EXPORT void MWDSP_IIR_DF1T_DZ(const real_T         *u,
                                    creal_T               *y,
                                    creal_T * const       mem_base,
                                    const int_T          numDelays,
                                    const int_T          sampsPerChan,
                                    const int_T          numChans,
                                    const creal_T * const num,
                                    const int_T          ordNUM,
                                    const creal_T * const den,
                                    const int_T          ordDEN,
                                    const boolean_T      one_fpf);

DSPIIR_EXPORT void MWDSP_IIR_DF1T_ZD(const creal_T         *u,
                                    creal_T               *y,
                                    creal_T * const       mem_base,
                                    const int_T          numDelays,
                                    const int_T          sampsPerChan,
                                    const int_T          numChans,
                                    const real_T * const num,
                                    const int_T          ordNUM,
                                    const real_T * const den,
                                    const int_T          ordDEN,
                                    const boolean_T      one_fpf);

DSPIIR_EXPORT void MWDSP_IIR_DF1T_ZZ(const creal_T         *u,
                                    creal_T               *y,
                                    creal_T * const       mem_base,
                                    const int_T          numDelays,
                                    const int_T          sampsPerChan,
                                    const int_T          numChans,
                                    const creal_T * const num,
                                    const int_T          ordNUM,
                                    const creal_T * const den,
                                    const int_T          ordDEN,
                                    const boolean_T      one_fpf);

DSPIIR_EXPORT void MWDSP_IIR_DF1T_RR(const real32_T         *u,
                                    real32_T               *y,
                                    real32_T * const       mem_base,
                                    const int_T          numDelays,
                                    const int_T          sampsPerChan,
                                    const int_T          numChans,
                                    const real32_T * const num,
                                    const int_T          ordNUM,
                                    const real32_T * const den,
                                    const int_T          ordDEN,
                                    const boolean_T      one_fpf);

DSPIIR_EXPORT void MWDSP_IIR_DF1T_RC(const real32_T         *u,
                                    creal32_T               *y,
                                    creal32_T * const       mem_base,
                                    const int_T          numDelays,
                                    const int_T          sampsPerChan,
                                    const int_T          numChans,
                                    const creal32_T * const num,
                                    const int_T          ordNUM,
                                    const creal32_T * const den,
                                    const int_T          ordDEN,
                                    const boolean_T      one_fpf);

DSPIIR_EXPORT void MWDSP_IIR_DF1T_CR(const creal32_T         *u,
                                    creal32_T               *y,
                                    creal32_T * const       mem_base,
                                    const int_T          numDelays,
                                    const int_T          sampsPerChan,
                                    const int_T          numChans,
                                    const real32_T * const num,
                                    const int_T          ordNUM,
                                    const real32_T * const den,
                                    const int_T          ordDEN,
                                    const boolean_T      one_fpf);

DSPIIR_EXPORT void MWDSP_IIR_DF1T_CC(const creal32_T         *u,
                                    creal32_T               *y,
                                    creal32_T * const       mem_base,
                                    const int_T          numDelays,
                                    const int_T          sampsPerChan,
                                    const int_T          numChans,
                                    const creal32_T * const num,
                                    const int_T          ordNUM,
                                    const creal32_T * const den,
                                    const int_T          ordDEN,
                                    const boolean_T      one_fpf);

/* IIR filter type DF1T filter structure run-time functions, which assumed non-unity first den. coeff.  */

DSPIIR_EXPORT void MWDSP_IIR_DF1T_A0Scale_DD(const real_T         *u,
                                    real_T               *y,
                                    real_T * const       mem_base,
                                    const int_T          numDelays,
                                    const int_T          sampsPerChan,
                                    const int_T          numChans,
                                    const real_T * const num,
                                    const int_T          ordNUM,
                                    const real_T * const den,
                                    const int_T          ordDEN,
                                    const boolean_T      one_fpf);

DSPIIR_EXPORT void MWDSP_IIR_DF1T_A0Scale_DZ(const real_T         *u,
                                    creal_T               *y,
                                    creal_T * const       mem_base,
                                    const int_T          numDelays,
                                    const int_T          sampsPerChan,
                                    const int_T          numChans,
                                    const creal_T * const num,
                                    const int_T          ordNUM,
                                    const creal_T * const den,
                                    const int_T          ordDEN,
                                    const boolean_T      one_fpf);

DSPIIR_EXPORT void MWDSP_IIR_DF1T_A0Scale_ZD(const creal_T         *u,
                                    creal_T               *y,
                                    creal_T * const       mem_base,
                                    const int_T          numDelays,
                                    const int_T          sampsPerChan,
                                    const int_T          numChans,
                                    const real_T * const num,
                                    const int_T          ordNUM,
                                    const real_T * const den,
                                    const int_T          ordDEN,
                                    const boolean_T      one_fpf);

DSPIIR_EXPORT void MWDSP_IIR_DF1T_A0Scale_ZZ(const creal_T         *u,
                                    creal_T               *y,
                                    creal_T * const       mem_base,
                                    const int_T          numDelays,
                                    const int_T          sampsPerChan,
                                    const int_T          numChans,
                                    const creal_T * const num,
                                    const int_T          ordNUM,
                                    const creal_T * const den,
                                    const int_T          ordDEN,
                                    const boolean_T      one_fpf);

DSPIIR_EXPORT void MWDSP_IIR_DF1T_A0Scale_RR(const real32_T         *u,
                                    real32_T               *y,
                                    real32_T * const       mem_base,
                                    const int_T          numDelays,
                                    const int_T          sampsPerChan,
                                    const int_T          numChans,
                                    const real32_T * const num,
                                    const int_T          ordNUM,
                                    const real32_T * const den,
                                    const int_T          ordDEN,
                                    const boolean_T      one_fpf);

DSPIIR_EXPORT void MWDSP_IIR_DF1T_A0Scale_RC(const real32_T         *u,
                                    creal32_T               *y,
                                    creal32_T * const       mem_base,
                                    const int_T          numDelays,
                                    const int_T          sampsPerChan,
                                    const int_T          numChans,
                                    const creal32_T * const num,
                                    const int_T          ordNUM,
                                    const creal32_T * const den,
                                    const int_T          ordDEN,
                                    const boolean_T      one_fpf);

DSPIIR_EXPORT void MWDSP_IIR_DF1T_A0Scale_CR(const creal32_T         *u,
                                    creal32_T               *y,
                                    creal32_T * const       mem_base,
                                    const int_T          numDelays,
                                    const int_T          sampsPerChan,
                                    const int_T          numChans,
                                    const real32_T * const num,
                                    const int_T          ordNUM,
                                    const real32_T * const den,
                                    const int_T          ordDEN,
                                    const boolean_T      one_fpf);

DSPIIR_EXPORT void MWDSP_IIR_DF1T_A0Scale_CC(const creal32_T         *u,
                                    creal32_T               *y,
                                    creal32_T * const       mem_base,
                                    const int_T          numDelays,
                                    const int_T          sampsPerChan,
                                    const int_T          numChans,
                                    const creal32_T * const num,
                                    const int_T          ordNUM,
                                    const creal32_T * const den,
                                    const int_T          ordDEN,
                                    const boolean_T      one_fpf);

/* IIR filter type DF2 filter structure run-time functions */

DSPIIR_EXPORT void MWDSP_IIR_DF2_DD( const real_T      *u,
                           real_T               *y,
                           real_T        * const mem_base,
                           int32_T                *offset_mem,
                           const int_T           numDelays,
                           const int_T           sampsPerChan,
                           const int_T           numChans,
                           const real_T  * const b, 
                           const int_T           ordNUM,
                           const real_T  * const a,
                           const int_T           ordDEN, 
                           const boolean_T       one_fpf);

DSPIIR_EXPORT void MWDSP_IIR_DF2_DZ( const real_T      *u,
                           creal_T               *y,
                           creal_T        * const mem_base,
                           int32_T                *offset_mem,
                           const int_T           numDelays,
                           const int_T           sampsPerChan,
                           const int_T           numChans,
                           const creal_T  * const b, 
                           const int_T           ordNUM,
                           const creal_T  * const a,
                           const int_T           ordDEN, 
                           const boolean_T       one_fpf);

DSPIIR_EXPORT void MWDSP_IIR_DF2_ZD( const creal_T      *u,
                           creal_T               *y,
                           creal_T        * const mem_base,
                           int32_T                *offset_mem,
                           const int_T           numDelays,
                           const int_T           sampsPerChan,
                           const int_T           numChans,
                           const real_T  * const b, 
                           const int_T           ordNUM,
                           const real_T  * const a,
                           const int_T           ordDEN, 
                           const boolean_T       one_fpf);

DSPIIR_EXPORT void MWDSP_IIR_DF2_ZZ( const creal_T      *u,
                           creal_T               *y,
                           creal_T        * const mem_base,
                           int32_T                *offset_mem,
                           const int_T           numDelays,
                           const int_T           sampsPerChan,
                           const int_T           numChans,
                           const creal_T  * const b, 
                           const int_T           ordNUM,
                           const creal_T  * const a,
                           const int_T           ordDEN, 
                           const boolean_T       one_fpf);

DSPIIR_EXPORT void MWDSP_IIR_DF2_RR( const real32_T      *u,
                           real32_T               *y,
                           real32_T        * const mem_base,
                           int32_T                *offset_mem,
                           const int_T           numDelays,
                           const int_T           sampsPerChan,
                           const int_T           numChans,
                           const real32_T  * const b, 
                           const int_T           ordNUM,
                           const real32_T  * const a,
                           const int_T           ordDEN, 
                           const boolean_T       one_fpf);

DSPIIR_EXPORT void MWDSP_IIR_DF2_RC( const real32_T      *u,
                           creal32_T               *y,
                           creal32_T        * const mem_base,
                           int32_T                *offset_mem,
                           const int_T           numDelays,
                           const int_T           sampsPerChan,
                           const int_T           numChans,
                           const creal32_T  * const b, 
                           const int_T           ordNUM,
                           const creal32_T  * const a,
                           const int_T           ordDEN, 
                           const boolean_T       one_fpf);

DSPIIR_EXPORT void MWDSP_IIR_DF2_CR( const creal32_T      *u,
                           creal32_T               *y,
                           creal32_T        * const mem_base,
                           int32_T                *offset_mem,
                           const int_T           numDelays,
                           const int_T           sampsPerChan,
                           const int_T           numChans,
                           const real32_T  * const b, 
                           const int_T           ordNUM,
                           const real32_T  * const a,
                           const int_T           ordDEN, 
                           const boolean_T       one_fpf);

DSPIIR_EXPORT void MWDSP_IIR_DF2_CC( const creal32_T      *u,
                           creal32_T               *y,
                           creal32_T        * const mem_base,
                           int32_T                *offset_mem,
                           const int_T           numDelays,
                           const int_T           sampsPerChan,
                           const int_T           numChans,
                           const creal32_T  * const b, 
                           const int_T           ordNUM,
                           const creal32_T  * const a,
                           const int_T           ordDEN, 
                           const boolean_T       one_fpf);

/* IIR filter type DF2 filter structure run-time functions, which assumed non-unity first den. coeff.  */
DSPIIR_EXPORT void MWDSP_IIR_DF2_A0Scale_DD( const real_T      *u,
                           real_T               *y,
                           real_T        * const mem_base,
                           int32_T                *offset_mem,
                           const int_T           numDelays,
                           const int_T           sampsPerChan,
                           const int_T           numChans,
                           const real_T  * const b, 
                           const int_T           ordNUM,
                           const real_T  * const a,
                           const int_T           ordDEN, 
                           const boolean_T       one_fpf);

DSPIIR_EXPORT void MWDSP_IIR_DF2_A0Scale_DZ( const real_T      *u,
                           creal_T               *y,
                           creal_T        * const mem_base,
                           int32_T                *offset_mem,
                           const int_T           numDelays,
                           const int_T           sampsPerChan,
                           const int_T           numChans,
                           const creal_T  * const b, 
                           const int_T           ordNUM,
                           const creal_T  * const a,
                           const int_T           ordDEN, 
                           const boolean_T       one_fpf);

DSPIIR_EXPORT void MWDSP_IIR_DF2_A0Scale_ZD( const creal_T      *u,
                           creal_T               *y,
                           creal_T        * const mem_base,
                           int32_T                *offset_mem,
                           const int_T           numDelays,
                           const int_T           sampsPerChan,
                           const int_T           numChans,
                           const real_T  * const b, 
                           const int_T           ordNUM,
                           const real_T  * const a,
                           const int_T           ordDEN, 
                           const boolean_T       one_fpf);

DSPIIR_EXPORT void MWDSP_IIR_DF2_A0Scale_ZZ( const creal_T      *u,
                           creal_T               *y,
                           creal_T        * const mem_base,
                           int32_T                *offset_mem,
                           const int_T           numDelays,
                           const int_T           sampsPerChan,
                           const int_T           numChans,
                           const creal_T  * const b, 
                           const int_T           ordNUM,
                           const creal_T  * const a,
                           const int_T           ordDEN, 
                           const boolean_T       one_fpf);

DSPIIR_EXPORT void MWDSP_IIR_DF2_A0Scale_RR( const real32_T      *u,
                           real32_T               *y,
                           real32_T        * const mem_base,
                           int32_T                *offset_mem,
                           const int_T           numDelays,
                           const int_T           sampsPerChan,
                           const int_T           numChans,
                           const real32_T  * const b, 
                           const int_T           ordNUM,
                           const real32_T  * const a,
                           const int_T           ordDEN, 
                           const boolean_T       one_fpf);

DSPIIR_EXPORT void MWDSP_IIR_DF2_A0Scale_RC( const real32_T      *u,
                           creal32_T               *y,
                           creal32_T        * const mem_base,
                           int32_T                *offset_mem,
                           const int_T           numDelays,
                           const int_T           sampsPerChan,
                           const int_T           numChans,
                           const creal32_T  * const b, 
                           const int_T           ordNUM,
                           const creal32_T  * const a,
                           const int_T           ordDEN, 
                           const boolean_T       one_fpf);

DSPIIR_EXPORT void MWDSP_IIR_DF2_A0Scale_CR( const creal32_T      *u,
                           creal32_T               *y,
                           creal32_T        * const mem_base,
                           int32_T                *offset_mem,
                           const int_T           numDelays,
                           const int_T           sampsPerChan,
                           const int_T           numChans,
                           const real32_T  * const b, 
                           const int_T           ordNUM,
                           const real32_T  * const a,
                           const int_T           ordDEN, 
                           const boolean_T       one_fpf);

DSPIIR_EXPORT void MWDSP_IIR_DF2_A0Scale_CC( const creal32_T      *u,
                           creal32_T               *y,
                           creal32_T        * const mem_base,
                           int32_T                *offset_mem,
                           const int_T           numDelays,
                           const int_T           sampsPerChan,
                           const int_T           numChans,
                           const creal32_T  * const b, 
                           const int_T           ordNUM,
                           const creal32_T  * const a,
                           const int_T           ordDEN, 
                           const boolean_T       one_fpf);

/* IIR filter type DF1 filter structure run-time functions */

DSPIIR_EXPORT void MWDSP_IIR_DF1_DD( const real_T      *u,
                           real_T               *y,
                           real_T        * const mem_base,
                           int32_T                *offset_mem,
                           const int_T           numDelays,
                           const int_T           sampsPerChan,
                           const int_T           numChans,
                           const real_T  * const b, 
                           const int_T           ordNUM,
                           const real_T  * const a,
                           const int_T           ordDEN, 
                           const boolean_T       one_fpf);

DSPIIR_EXPORT void MWDSP_IIR_DF1_DZ( const real_T      *u,
                           creal_T               *y,
                           creal_T        * const mem_base,
                           int32_T                *offset_mem,
                           const int_T           numDelays,
                           const int_T           sampsPerChan,
                           const int_T           numChans,
                           const creal_T  * const b, 
                           const int_T           ordNUM,
                           const creal_T  * const a,
                           const int_T           ordDEN, 
                           const boolean_T       one_fpf);

DSPIIR_EXPORT void MWDSP_IIR_DF1_ZD( const creal_T      *u,
                           creal_T               *y,
                           creal_T        * const mem_base,
                           int32_T                *offset_mem,
                           const int_T           numDelays,
                           const int_T           sampsPerChan,
                           const int_T           numChans,
                           const real_T  * const b, 
                           const int_T           ordNUM,
                           const real_T  * const a,
                           const int_T           ordDEN, 
                           const boolean_T       one_fpf);

DSPIIR_EXPORT void MWDSP_IIR_DF1_ZZ( const creal_T      *u,
                           creal_T               *y,
                           creal_T        * const mem_base,
                           int32_T                *offset_mem,
                           const int_T           numDelays,
                           const int_T           sampsPerChan,
                           const int_T           numChans,
                           const creal_T  * const b, 
                           const int_T           ordNUM,
                           const creal_T  * const a,
                           const int_T           ordDEN, 
                           const boolean_T       one_fpf);

DSPIIR_EXPORT void MWDSP_IIR_DF1_RR( const real32_T      *u,
                           real32_T               *y,
                           real32_T        * const mem_base,
                           int32_T                *offset_mem,
                           const int_T           numDelays,
                           const int_T           sampsPerChan,
                           const int_T           numChans,
                           const real32_T  * const b, 
                           const int_T           ordNUM,
                           const real32_T  * const a,
                           const int_T           ordDEN, 
                           const boolean_T       one_fpf);

DSPIIR_EXPORT void MWDSP_IIR_DF1_RC( const real32_T      *u,
                           creal32_T               *y,
                           creal32_T        * const mem_base,
                           int32_T                *offset_mem,
                           const int_T           numDelays,
                           const int_T           sampsPerChan,
                           const int_T           numChans,
                           const creal32_T  * const b, 
                           const int_T           ordNUM,
                           const creal32_T  * const a,
                           const int_T           ordDEN, 
                           const boolean_T       one_fpf);

DSPIIR_EXPORT void MWDSP_IIR_DF1_CR( const creal32_T      *u,
                           creal32_T               *y,
                           creal32_T        * const mem_base,
                           int32_T                *offset_mem,
                           const int_T           numDelays,
                           const int_T           sampsPerChan,
                           const int_T           numChans,
                           const real32_T  * const b, 
                           const int_T           ordNUM,
                           const real32_T  * const a,
                           const int_T           ordDEN, 
                           const boolean_T       one_fpf);

DSPIIR_EXPORT void MWDSP_IIR_DF1_CC( const creal32_T      *u,
                           creal32_T               *y,
                           creal32_T        * const mem_base,
                           int32_T                *offset_mem,
                           const int_T           numDelays,
                           const int_T           sampsPerChan,
                           const int_T           numChans,
                           const creal32_T  * const b, 
                           const int_T           ordNUM,
                           const creal32_T  * const a,
                           const int_T           ordDEN, 
                           const boolean_T       one_fpf);

/* IIR filter type DF1 filter structure run-time functions, which assumed non-unity first den. coeff.  */
DSPIIR_EXPORT void MWDSP_IIR_DF1_A0Scale_DD( const real_T      *u,
                           real_T               *y,
                           real_T        * const mem_base,
                           int32_T                *offset_mem,
                           const int_T           numDelays,
                           const int_T           sampsPerChan,
                           const int_T           numChans,
                           const real_T  * const b, 
                           const int_T           ordNUM,
                           const real_T  * const a,
                           const int_T           ordDEN, 
                           const boolean_T       one_fpf);

DSPIIR_EXPORT void MWDSP_IIR_DF1_A0Scale_DZ( const real_T      *u,
                           creal_T               *y,
                           creal_T        * const mem_base,
                           int32_T                *offset_mem,
                           const int_T           numDelays,
                           const int_T           sampsPerChan,
                           const int_T           numChans,
                           const creal_T  * const b, 
                           const int_T           ordNUM,
                           const creal_T  * const a,
                           const int_T           ordDEN, 
                           const boolean_T       one_fpf);

DSPIIR_EXPORT void MWDSP_IIR_DF1_A0Scale_ZD( const creal_T      *u,
                           creal_T               *y,
                           creal_T        * const mem_base,
                           int32_T                *offset_mem,
                           const int_T           numDelays,
                           const int_T           sampsPerChan,
                           const int_T           numChans,
                           const real_T  * const b, 
                           const int_T           ordNUM,
                           const real_T  * const a,
                           const int_T           ordDEN, 
                           const boolean_T       one_fpf);

DSPIIR_EXPORT void MWDSP_IIR_DF1_A0Scale_ZZ( const creal_T      *u,
                           creal_T               *y,
                           creal_T        * const mem_base,
                           int32_T                *offset_mem,
                           const int_T           numDelays,
                           const int_T           sampsPerChan,
                           const int_T           numChans,
                           const creal_T  * const b, 
                           const int_T           ordNUM,
                           const creal_T  * const a,
                           const int_T           ordDEN, 
                           const boolean_T       one_fpf);

DSPIIR_EXPORT void MWDSP_IIR_DF1_A0Scale_RR( const real32_T      *u,
                           real32_T               *y,
                           real32_T        * const mem_base,
                           int32_T                *offset_mem,
                           const int_T           numDelays,
                           const int_T           sampsPerChan,
                           const int_T           numChans,
                           const real32_T  * const b, 
                           const int_T           ordNUM,
                           const real32_T  * const a,
                           const int_T           ordDEN, 
                           const boolean_T       one_fpf);

DSPIIR_EXPORT void MWDSP_IIR_DF1_A0Scale_RC( const real32_T      *u,
                           creal32_T               *y,
                           creal32_T        * const mem_base,
                           int32_T                *offset_mem,
                           const int_T           numDelays,
                           const int_T           sampsPerChan,
                           const int_T           numChans,
                           const creal32_T  * const b, 
                           const int_T           ordNUM,
                           const creal32_T  * const a,
                           const int_T           ordDEN, 
                           const boolean_T       one_fpf);

DSPIIR_EXPORT void MWDSP_IIR_DF1_A0Scale_CR( const creal32_T      *u,
                           creal32_T               *y,
                           creal32_T        * const mem_base,
                           int32_T                *offset_mem,
                           const int_T           numDelays,
                           const int_T           sampsPerChan,
                           const int_T           numChans,
                           const real32_T  * const b, 
                           const int_T           ordNUM,
                           const real32_T  * const a,
                           const int_T           ordDEN, 
                           const boolean_T       one_fpf);

DSPIIR_EXPORT void MWDSP_IIR_DF1_A0Scale_CC( const creal32_T      *u,
                           creal32_T               *y,
                           creal32_T        * const mem_base,
                           int32_T                *offset_mem,
                           const int_T           numDelays,
                           const int_T           sampsPerChan,
                           const int_T           numChans,
                           const creal32_T  * const b, 
                           const int_T           ordNUM,
                           const creal32_T  * const a,
                           const int_T           ordDEN, 
                           const boolean_T       one_fpf);

#ifdef MWDSP_INLINE_DSPRTLIB
#include "dspiir/iir_df1_a0scale_cc_rt.c"
#include "dspiir/iir_df1_a0scale_cr_rt.c"
#include "dspiir/iir_df1_a0scale_dd_rt.c"
#include "dspiir/iir_df1_a0scale_dz_rt.c"
#include "dspiir/iir_df1_a0scale_rc_rt.c"
#include "dspiir/iir_df1_a0scale_rr_rt.c"
#include "dspiir/iir_df1_a0scale_zd_rt.c"
#include "dspiir/iir_df1_a0scale_zz_rt.c"
#include "dspiir/iir_df1_cc_rt.c"
#include "dspiir/iir_df1_cr_rt.c"
#include "dspiir/iir_df1_dd_rt.c"
#include "dspiir/iir_df1_dz_rt.c"
#include "dspiir/iir_df1_rc_rt.c"
#include "dspiir/iir_df1_rr_rt.c"
#include "dspiir/iir_df1_zd_rt.c"
#include "dspiir/iir_df1_zz_rt.c"
#include "dspiir/iir_df1t_a0scale_cc_rt.c"
#include "dspiir/iir_df1t_a0scale_cr_rt.c"
#include "dspiir/iir_df1t_a0scale_dd_rt.c"
#include "dspiir/iir_df1t_a0scale_dz_rt.c"
#include "dspiir/iir_df1t_a0scale_rc_rt.c"
#include "dspiir/iir_df1t_a0scale_rr_rt.c"
#include "dspiir/iir_df1t_a0scale_zd_rt.c"
#include "dspiir/iir_df1t_a0scale_zz_rt.c"
#include "dspiir/iir_df1t_cc_rt.c"
#include "dspiir/iir_df1t_cr_rt.c"
#include "dspiir/iir_df1t_dd_rt.c"
#include "dspiir/iir_df1t_dz_rt.c"
#include "dspiir/iir_df1t_rc_rt.c"
#include "dspiir/iir_df1t_rr_rt.c"
#include "dspiir/iir_df1t_zd_rt.c"
#include "dspiir/iir_df1t_zz_rt.c"
#include "dspiir/iir_df2_a0scale_cc_rt.c"
#include "dspiir/iir_df2_a0scale_cr_rt.c"
#include "dspiir/iir_df2_a0scale_dd_rt.c"
#include "dspiir/iir_df2_a0scale_dz_rt.c"
#include "dspiir/iir_df2_a0scale_rc_rt.c"
#include "dspiir/iir_df2_a0scale_rr_rt.c"
#include "dspiir/iir_df2_a0scale_zd_rt.c"
#include "dspiir/iir_df2_a0scale_zz_rt.c"
#include "dspiir/iir_df2_cc_rt.c"
#include "dspiir/iir_df2_cr_rt.c"
#include "dspiir/iir_df2_dd_rt.c"
#include "dspiir/iir_df2_dz_rt.c"
#include "dspiir/iir_df2_rc_rt.c"
#include "dspiir/iir_df2_rr_rt.c"
#include "dspiir/iir_df2_zd_rt.c"
#include "dspiir/iir_df2_zz_rt.c"
#include "dspiir/iir_df2t_a0scale_cc_rt.c"
#include "dspiir/iir_df2t_a0scale_cr_rt.c"
#include "dspiir/iir_df2t_a0scale_dd_rt.c"
#include "dspiir/iir_df2t_a0scale_dz_rt.c"
#include "dspiir/iir_df2t_a0scale_rc_rt.c"
#include "dspiir/iir_df2t_a0scale_rr_rt.c"
#include "dspiir/iir_df2t_a0scale_zd_rt.c"
#include "dspiir/iir_df2t_a0scale_zz_rt.c"
#include "dspiir/iir_df2t_cc_rt.c"
#include "dspiir/iir_df2t_cr_rt.c"
#include "dspiir/iir_df2t_dd_rt.c"
#include "dspiir/iir_df2t_dz_rt.c"
#include "dspiir/iir_df2t_rc_rt.c"
#include "dspiir/iir_df2t_rr_rt.c"
#include "dspiir/iir_df2t_zd_rt.c"
#include "dspiir/iir_df2t_zz_rt.c"
#endif

#endif /* dspiir_rt_h */

/* [EOF] dspiir_rt.h */
