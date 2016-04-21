/*
 *  dspfir_rt.h
 *
 *  Abstract: Header file for DSP run-time library helper functions
 *  for FIR filters.
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.8.4.3 $ $Date: 2004/04/12 23:11:50 $
 */

#ifndef dspfir_rt_h
#define dspfir_rt_h

#include "dsp_rt.h"

#ifdef DSPFIR_EXPORTS
#define DSPFIR_EXPORT EXPORT_FCN
#else
#define DSPFIR_EXPORT MWDSP_IDECL
#endif

/* FIR Transposed Direct Form Filter Implementation
 * 
 * Algorithm: Transposed Direct Form 
 *
 *   y[n]    = x[n]*b0  + D0[n]   (output)       b[n] = numerator polynomial,
 *   D0[n+1] = x[n]*b1  + D1[n]   (delay         D[n] = delay buffer containing state memory
 *   D1[n+1] = x[n]*b2  + D2[n]    updates)      y    = output value
 *   ...                                         x    = input value
 *   DN[n+1] = x[n]*bN                           
 *
 * Buffer storage:
 *   ----------------------------------------------
 *   |    Channel 0     |     Channel 1      |  ...
 *   |D0 | D1 | D2 |... | D0 | D1 | D2 | ... |  ...
 *   ----------------------------------------------
 * For each channel, there are numDelays = 1+ordNUM state memories.
 * The last state memory value for each channel is always zero.  This extra 
 * zero-valued state greatly simplifies the algorithm.
 *
 * Note:
 * 1. Filter set 1 (cPtr1) points to the numerator filter coeffs.
 * 2. Filter set 2 (cPtr2) is unused.
 * 3. numStates holds the number of states per channel.
 * 4. In one filter per frame implementation, cPtr1 points to a
 *    single numerator filter coeff set.  This filter is applied to 
 *    every sample in the frame.
 * 5. In one filter per sample implementation, cPtr1 points to sampsPerChan
 *    numerator filter coeff sets (such that each sample will be filtered 
 *    by a separate filter coeff set).
 *
 * For the function naming conventions used below, see dspfilter_rt.h
 *
 */

/* Transposed direct-form FIR filters: double-precision */
DSPFIR_EXPORT void MWDSP_FIR_TDF_DD(const real_T         *u,
                             real_T               *y,
                             real_T * const       mem_base,
                             const int_T          numDelays,
                             const int_T          sampsPerChan,
                             const int_T          numChans,
                             const real_T * const num,
                             const int_T          ordNUM,
                             const boolean_T      one_fpf);

DSPFIR_EXPORT void MWDSP_FIR_TDF_DZ(const real_T          *u,
                             creal_T               *y,
                             creal_T * const       mem_base,
                             const int_T           numDelays,
                             const int_T           sampsPerChan,
                             const int_T           numChans,
                             const creal_T * const num,
                             const int_T           ordNUM,
                             const boolean_T       one_fpf);

DSPFIR_EXPORT void MWDSP_FIR_TDF_ZD(const creal_T         *u,
                             creal_T               *y,
                             creal_T * const       mem_base,
                             const int_T           numDelays,
                             const int_T           sampsPerChan,
                             const int_T           numChans,
                             const real_T * const  num,
                             const int_T           ordNUM,
                             const boolean_T       one_fpf);

DSPFIR_EXPORT void MWDSP_FIR_TDF_ZZ(const creal_T         *u,
                             creal_T               *y,
                             creal_T * const       mem_base,
                             const int_T           numDelays,
                             const int_T           sampsPerChan,
                             const int_T           numChans,
                             const creal_T * const num,
                             const int_T           ordNUM,
                             const boolean_T       one_fpf);


/* Transposed direct-form FIR filters: single-precision */
DSPFIR_EXPORT void MWDSP_FIR_TDF_RR(const real32_T         *u,
                             real32_T               *y,
                             real32_T * const       mem_base,
                             const int_T            numDelays,
                             const int_T            sampsPerChan,
                             const int_T            numChans,
                             const real32_T * const num,
                             const int_T            ordNUM,
                             const boolean_T        one_fpf);

DSPFIR_EXPORT void MWDSP_FIR_TDF_RC(const real32_T          *u,
                             creal32_T               *y,
                             creal32_T * const       mem_base,
                             const int_T             numDelays,
                             const int_T             sampsPerChan,
                             const int_T             numChans,
                             const creal32_T * const num,
                             const int_T             ordNUM,
                             const boolean_T         one_fpf);

DSPFIR_EXPORT void MWDSP_FIR_TDF_CR(const creal32_T         *u,
                             creal32_T               *y,
                             creal32_T * const       mem_base,
                             const int_T             numDelays,
                             const int_T             sampsPerChan,
                             const int_T             numChans,
                             const real32_T * const  num,
                             const int_T             ordNUM,
                             const boolean_T         one_fpf);

DSPFIR_EXPORT void MWDSP_FIR_TDF_CC(const creal32_T         *u,
                             creal32_T               *y,
                             creal32_T * const       mem_base,
                             const int_T             numDelays,
                             const int_T             sampsPerChan,
                             const int_T             numChans,
                             const creal32_T * const num,
                             const int_T             ordNUM,
                             const boolean_T         one_fpf);


/* FIR Lattice Form Filter Implementation
 * 
 *
 * State Memory Structure:
 *   ----------------------------------------------
 *   |    Channel 0     |     Channel 1      |  ...
 *   |mem0 | mem1 | ... | mem0 | mem1 |  ... |  ...
 *   ----------------------------------------------
 * For each channel, the number of state memory is equal to the filter order m.
 * (which equals the number of reflection coefficients).
 * At time step t[0], state memories mem0, mem1, mem2, ... , mem[m-1]
 *                    contain initial conditions.   The caller has to put 
 *                    the initial conditions in mem array before first call.
 * At time step t[n], state memories mem0, mem1, mem2, ... , mem[m-1]
 *                    contain x[n-1], g1[n-1], g2[n-1] ... , gm-1[n-1]
 *
 * Upon returning from the run-time function call, mem contains the current filter states.
 *
 * Algorithm: 
 * At t[n] :
 * g_prev = f0[n] = x[n]
 * (loop begins)
 * 1st stage
 *   g_current = conj(K1)*f0 + mem0          calculate g_current = g1[n]
 *   f1        = f0 + K1*mem0                calculate f1[n]
 *   mem0      = g_prev                      store g_prev = x[n] into mem[0]
 *   g_prev    = g_current                   store g_current = g1[n] in g_prev
 *
 * 2nd stage
 *   g_current = conj(K2)*f1 + mem1          calculate g_current = g2[n]
 *   f2        = f1 + K2*mem1                calculate f2[n]
 *   mem1      = g_prev                      store g_prev = g1[n] into mem[1]
 *   g_prev    = g_current                   store g_current = g2[n] in g_prev
 *
 * ...
 *
 * (loop ends)
 * mth (last) stage
 * y = fm = fm-1 + Km*mem[m-1]             output y[n]
 *
 * Note:
 * 1. Filter set 1 (cPtr1) points to reflection coeffs (Km).
 * 2. Filter set 2 (cPtr2) is unused.
 * 3. numStates is unused.
 * 4. In one filter per frame implementation, cPtr1 points to a
 *    single reflection coeff set.  This filter is applied to 
 *    every sample in the frame (channel).
 * 5. In one filter per sample implementation, cPtr1 points to sampsPerChan
 *    reflection coeff sets (such that each sample will be filtered 
 *    by a separate filter coeff set).
 *
 * For the function naming conventions used below, see dspfilter_rt.h
 *
 */
/* Lattice FIR filters: double-precision */
DSPFIR_EXPORT void MWDSP_FIR_Lat_DD(const real_T         *u,
                             real_T               *y,
                             real_T *             mem_base,
                             const int_T          sampsPerChan,
                             const int_T          numChans,
                             const real_T * const K_first,
                             const int_T          ordK,
                             const boolean_T      one_fpf);

DSPFIR_EXPORT void MWDSP_FIR_Lat_DZ(const real_T          *u,
                             creal_T               *y,
                             creal_T *             mem_base,
                             const int_T           sampsPerChan,
                             const int_T           numChans,
                             const creal_T * const K_first,
                             const int_T           ordK,
                             const boolean_T       one_fpf);

DSPFIR_EXPORT void MWDSP_FIR_Lat_ZD(const creal_T        *u,
                             creal_T              *y,
                             creal_T *            mem_base,
                             const int_T          sampsPerChan,
                             const int_T          numChans,
                             const real_T * const K_first,
                             const int_T          ordK,
                             const boolean_T      one_fpf);

DSPFIR_EXPORT void MWDSP_FIR_Lat_ZZ(const creal_T         *u,
                             creal_T               *y,
                             creal_T *             mem_base,
                             const int_T           sampsPerChan,
                             const int_T           numChans,
                             const creal_T * const K_first,
                             const int_T           ordK,
                             const boolean_T       one_fpf);


/* Lattice FIR filters: single-precision */
DSPFIR_EXPORT void MWDSP_FIR_Lat_RR(const real32_T         *u,
                             real32_T               *y,
                             real32_T *             mem_base,
                             const int_T            sampsPerChan,
                             const int_T            numChans,
                             const real32_T * const K_first,
                             const int_T            ordK,
                             const boolean_T        one_fpf);

DSPFIR_EXPORT void MWDSP_FIR_Lat_RC(const real32_T          *u,
                             creal32_T               *y,
                             creal32_T *             mem_base,
                             const int_T             sampsPerChan,
                             const int_T             numChans,
                             const creal32_T * const K_first,
                             const int_T             ordK,
                             const boolean_T         one_fpf);

DSPFIR_EXPORT void MWDSP_FIR_Lat_CR(const creal32_T        *u,
                             creal32_T              *y,
                             creal32_T *            mem_base,
                             const int_T            sampsPerChan,
                             const int_T            numChans,
                             const real32_T * const K_first,
                             const int_T            ordK,
                             const boolean_T        one_fpf);

DSPFIR_EXPORT void MWDSP_FIR_Lat_CC(const creal32_T         *u,
                             creal32_T               *y,
                             creal32_T *             mem_base,
                             const int_T             sampsPerChan,
                             const int_T             numChans,
                             const creal32_T * const K_first,
                             const int_T             ordK,
                             const boolean_T         one_fpf);

/* Direct Form implementation of FIR filter. */

DSPFIR_EXPORT void MWDSP_FIR_DF_DD( const real_T         *u,
                             real_T               *y,
                             real_T * const       mem_base,
                             int32_T                *offset_mem,
                             const int_T          numDelays,
                             const int_T          sampsPerChan,
                             const int_T          numChans,
                             const real_T * const num,
                             const boolean_T      one_fpf);

DSPFIR_EXPORT void MWDSP_FIR_DF_DZ(const real_T          *u,
                             creal_T               *y,
                             creal_T * const       mem_base,
                             int32_T                *offset_mem,
                             const int_T           numDelays,
                             const int_T           sampsPerChan,
                             const int_T           numChans,
                             const creal_T * const num,
                             const boolean_T       one_fpf);

DSPFIR_EXPORT void MWDSP_FIR_DF_ZD(const creal_T         *u,
                             creal_T               *y,
                             creal_T * const       mem_base,
                             int32_T                *offset_mem,
                             const int_T           numDelays,
                             const int_T           sampsPerChan,
                             const int_T           numChans,
                             const real_T * const  num,
                             const boolean_T       one_fpf);

DSPFIR_EXPORT void MWDSP_FIR_DF_ZZ(const creal_T         *u,
                             creal_T               *y,
                             creal_T * const       mem_base,
                             int32_T                *offset_mem,
                             const int_T           numDelays,
                             const int_T           sampsPerChan,
                             const int_T           numChans,
                             const creal_T * const num,
                             const boolean_T       one_fpf);


/* Transposed direct-form FIR filters: single-precision */
DSPFIR_EXPORT void MWDSP_FIR_DF_RR(const real32_T         *u,
                             real32_T               *y,
                             real32_T * const       mem_base,
                             int32_T                *offset_mem,
                             const int_T            numDelays,
                             const int_T            sampsPerChan,
                             const int_T            numChans,
                             const real32_T * const num,
                             const boolean_T        one_fpf);

DSPFIR_EXPORT void MWDSP_FIR_DF_RC(const real32_T          *u,
                             creal32_T               *y,
                             creal32_T * const       mem_base,
                             int32_T                  *offset_mem,
                             const int_T             numDelays,
                             const int_T             sampsPerChan,
                             const int_T             numChans,
                             const creal32_T * const num,
                             const boolean_T         one_fpf);

DSPFIR_EXPORT void MWDSP_FIR_DF_CR(const creal32_T         *u,
                             creal32_T               *y,
                             creal32_T * const       mem_base,
                             int32_T                  *offset_mem,
                             const int_T             numDelays,
                             const int_T             sampsPerChan,
                             const int_T             numChans,
                             const real32_T * const  num,
                             const boolean_T         one_fpf);

DSPFIR_EXPORT void MWDSP_FIR_DF_CC(const creal32_T         *u,
                             creal32_T               *y,
                             creal32_T * const       mem_base,
                             int32_T                  *offset_mem,
                             const int_T             numDelays,
                             const int_T             sampsPerChan,
                             const int_T             numChans,
                             const creal32_T * const num,
                             const boolean_T         one_fpf);


#ifdef MWDSP_INLINE_DSPRTLIB
#include "dspfir/fir_df_cc_rt.c"
#include "dspfir/fir_df_cr_rt.c"
#include "dspfir/fir_df_dd_rt.c"
#include "dspfir/fir_df_dz_rt.c"
#include "dspfir/fir_df_rc_rt.c"
#include "dspfir/fir_df_rr_rt.c"
#include "dspfir/fir_df_zd_rt.c"
#include "dspfir/fir_df_zz_rt.c"
#include "dspfir/fir_lat_cc_rt.c"
#include "dspfir/fir_lat_cr_rt.c"
#include "dspfir/fir_lat_dd_rt.c"
#include "dspfir/fir_lat_dz_rt.c"
#include "dspfir/fir_lat_rc_rt.c"
#include "dspfir/fir_lat_rr_rt.c"
#include "dspfir/fir_lat_zd_rt.c"
#include "dspfir/fir_lat_zz_rt.c"
#include "dspfir/fir_tdf_cc_rt.c"
#include "dspfir/fir_tdf_cr_rt.c"
#include "dspfir/fir_tdf_dd_rt.c"
#include "dspfir/fir_tdf_dz_rt.c"
#include "dspfir/fir_tdf_rc_rt.c"
#include "dspfir/fir_tdf_rr_rt.c"
#include "dspfir/fir_tdf_zd_rt.c"
#include "dspfir/fir_tdf_zz_rt.c"
#endif

#endif /* dspfir_rt_h */

/* [EOF] dspfir_rt.h */
