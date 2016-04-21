/*
 *  dspallpole_rt.h
 *
 *  Abstract: Header file for DSP run-time library helper functions
 *  for Auto Regressive (all pole) filters.
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.9.4.3 $ $Date: 2004/04/12 23:11:38 $
 */

#ifndef dspallpole_rt_h
#define dspallpole_rt_h

#include "dsp_rt.h"

#ifdef DSPALLPOLE_EXPORTS
#define DSPALLPOLE_EXPORT EXPORT_FCN
#else
#define DSPALLPOLE_EXPORT MWDSP_IDECL
#endif

/* ALLPOLE TDF IMPLEMENTATIONS
 * Algorithm: Transposed Direct Form 
 *
 *   y[n]    = x[n]           + D0[n]   (output)       
 *   D0[n+1] =       -y[n]*a1 + D1[n]   (delay         a[n] = denominator polynomial
 *   D1[n+1] =       -y[n]*a2 + D2[n]    updates)      D[n] = delay buffer containing state memory
 *   ...                                               y    = output value
 *   DN[n+1] =      - y[n]*aN                          x    = input value
 *
 * Buffer storage:
 *   ----------------------------------------------
 *   |    Channel 0     |     Channel 1      |  ...
 *   |D0 | D1 | D2 |... | D0 | D1 | D2 | ... |  ...
 *   ----------------------------------------------
 * For each channel, there are numDelays = (1 + ordDEN) state memories.
 * The last state memory value for each channel is always zero.  This extra 
 * zero-valued state greatly simplifies the algorithm.
 *
 * Note:
 * 1. Filter set 1 (cPtr1) points to the denominator coefficients.
 *    (the first filter coefficient a0 is assumed to be unity: 1.0).
 * 2. Filter set 2 (cPtr2) is unused.
 * 3. numStates holds the number of states per channel.
 * 4. In one filter per frame implementation, cPtr1 points to a
 *    single denominator filter coeff set. This filter is applied to 
 *    every sample in the frame.
 * 5. In one filter per sample implementation, cPtr1 points to sampsPerChan
 *    denominator filter coeff sets (such that each sample will be filtered 
 *    by a separate filter coeff set).
 *
 * For the function naming conventions used below, see dspfilter_rt.h
 *
 */

/* Transposed direct-form all-pole filters: double-precision */
DSPALLPOLE_EXPORT void MWDSP_AllPole_TDF_DD(const real_T         *u,
                                 real_T               *y,
                                 real_T * const       mem_base,
                                 const int_T          numDelays,
                                 const int_T          sampsPerChan,
                                 const int_T          numChans,
                                 const real_T * const den,
                                 const int_T          ordDEN,
                                 const boolean_T      one_fpf);

DSPALLPOLE_EXPORT void MWDSP_AllPole_TDF_DZ(const real_T          *u,
                                 creal_T               *y,
                                 creal_T * const       mem_base,
                                 const int_T           numDelays,
                                 const int_T           sampsPerChan,
                                 const int_T           numChans,
                                 const creal_T * const den,
                                 const int_T           ordDEN,
                                 const boolean_T       one_fpf);

DSPALLPOLE_EXPORT void MWDSP_AllPole_TDF_ZD(const creal_T         *u,
                                 creal_T               *y,
                                 creal_T * const       mem_base,
                                 const int_T           numDelays,
                                 const int_T           sampsPerChan,
                                 const int_T           numChans,
                                 const real_T * const  den,
                                 const int_T           ordDEN,
                                 const boolean_T       one_fpf);

DSPALLPOLE_EXPORT void MWDSP_AllPole_TDF_ZZ(const creal_T         *u,
                                 creal_T               *y,
                                 creal_T * const       mem_base,
                                 const int_T           numDelays,
                                 const int_T           sampsPerChan,
                                 const int_T           numChans,
                                 const creal_T * const den,
                                 const int_T           ordDEN,
                                 const boolean_T       one_fpf);


/* Transposed direct-form all-pole filters: single-precision */
DSPALLPOLE_EXPORT void MWDSP_AllPole_TDF_RR(const real32_T         *u,
                                 real32_T               *y,
                                 real32_T * const       mem_base,
                                 const int_T            numDelays,
                                 const int_T            sampsPerChan,
                                 const int_T            numChans,
                                 const real32_T * const den,
                                 const int_T            ordDEN,
                                 const boolean_T        one_fpf);

DSPALLPOLE_EXPORT void MWDSP_AllPole_TDF_RC(const real32_T          *u,
                                 creal32_T               *y,
                                 creal32_T * const       mem_base,
                                 const int_T             numDelays,
                                 const int_T             sampsPerChan,
                                 const int_T             numChans,
                                 const creal32_T * const den,
                                 const int_T             ordDEN,
                                 const boolean_T         one_fpf);

DSPALLPOLE_EXPORT void MWDSP_AllPole_TDF_CR(const creal32_T         *u,
                                 creal32_T               *y,
                                 creal32_T * const       mem_base,
                                 const int_T             numDelays,
                                 const int_T             sampsPerChan,
                                 const int_T             numChans,
                                 const real32_T * const  den,
                                 const int_T             ordDEN,
                                 const boolean_T         one_fpf);

DSPALLPOLE_EXPORT void MWDSP_AllPole_TDF_CC(const creal32_T         *u,
                                 creal32_T               *y,
                                 creal32_T * const       mem_base,
                                 const int_T             numDelays,
                                 const int_T             sampsPerChan,
                                 const int_T             numChans,
                                 const creal32_T * const den,
                                 const int_T             ordDEN,
                                 const boolean_T         one_fpf);


/* Transposed direct-form all-pole filters: double-precision with 1/a0 scale 
 * factor in the case of non-unity first den. coeff. 
 */
DSPALLPOLE_EXPORT void MWDSP_AllPole_TDF_A0Scale_DD(const real_T         *u,
                                 real_T               *y,
                                 real_T * const       mem_base,
                                 const int_T          numDelays,
                                 const int_T          sampsPerChan,
                                 const int_T          numChans,
                                 const real_T * const den,
                                 const int_T          ordDEN,
                                 const boolean_T      one_fpf);

DSPALLPOLE_EXPORT void MWDSP_AllPole_TDF_A0Scale_DZ(const real_T          *u,
                                 creal_T               *y,
                                 creal_T * const       mem_base,
                                 const int_T           numDelays,
                                 const int_T           sampsPerChan,
                                 const int_T           numChans,
                                 const creal_T * const den,
                                 const int_T           ordDEN,
                                 const boolean_T       one_fpf);

DSPALLPOLE_EXPORT void MWDSP_AllPole_TDF_A0Scale_ZD(const creal_T         *u,
                                 creal_T               *y,
                                 creal_T * const       mem_base,
                                 const int_T           numDelays,
                                 const int_T           sampsPerChan,
                                 const int_T           numChans,
                                 const real_T * const  den,
                                 const int_T           ordDEN,
                                 const boolean_T       one_fpf);

DSPALLPOLE_EXPORT void MWDSP_AllPole_TDF_A0Scale_ZZ(const creal_T         *u,
                                 creal_T               *y,
                                 creal_T * const       mem_base,
                                 const int_T           numDelays,
                                 const int_T           sampsPerChan,
                                 const int_T           numChans,
                                 const creal_T * const den,
                                 const int_T           ordDEN,
                                 const boolean_T       one_fpf);


/* Transposed direct-form all-pole filters: single-precision */
DSPALLPOLE_EXPORT void MWDSP_AllPole_TDF_A0Scale_RR(const real32_T         *u,
                                 real32_T               *y,
                                 real32_T * const       mem_base,
                                 const int_T            numDelays,
                                 const int_T            sampsPerChan,
                                 const int_T            numChans,
                                 const real32_T * const den,
                                 const int_T            ordDEN,
                                 const boolean_T        one_fpf);

DSPALLPOLE_EXPORT void MWDSP_AllPole_TDF_A0Scale_RC(const real32_T          *u,
                                 creal32_T               *y,
                                 creal32_T * const       mem_base,
                                 const int_T             numDelays,
                                 const int_T             sampsPerChan,
                                 const int_T             numChans,
                                 const creal32_T * const den,
                                 const int_T             ordDEN,
                                 const boolean_T         one_fpf);

DSPALLPOLE_EXPORT void MWDSP_AllPole_TDF_A0Scale_CR(const creal32_T         *u,
                                 creal32_T               *y,
                                 creal32_T * const       mem_base,
                                 const int_T             numDelays,
                                 const int_T             sampsPerChan,
                                 const int_T             numChans,
                                 const real32_T * const  den,
                                 const int_T             ordDEN,
                                 const boolean_T         one_fpf);

DSPALLPOLE_EXPORT void MWDSP_AllPole_TDF_A0Scale_CC(const creal32_T         *u,
                                 creal32_T               *y,
                                 creal32_T * const       mem_base,
                                 const int_T             numDelays,
                                 const int_T             sampsPerChan,
                                 const int_T             numChans,
                                 const creal32_T * const den,
                                 const int_T             ordDEN,
                                 const boolean_T         one_fpf);

/* AllPole Lattice Form Filter Implementation
 *
 * State Memory Structure:
 *   ----------------------------------------------
 *   |    Channel 0     |     Channel 1      |  ...
 *   |mem0 | mem1 | ... | mem0 | mem1 |  ... |  ...
 *   ----------------------------------------------
 * For each channel, the number of state memory is equal to the filter order m.
 * (which equals the number of reflection coefficients).
 * At time step t[0], state memories mem0, mem1, mem2, ... , mem[m-1]
 *                    contain initial conditions.  The caller has to put 
 *                    the initial conditions in mem array before first call.
 * At time step t[n], state memories mem0, mem1, mem2, ... , mem[m-1]
 *                    contain g0[n-1]=y[n-1], g1[n-1], g2[n-1] ... , gm-1[n-1]
 *                    
 * Upon returning from the run-time function call, mem contains the current filter states.
 *
 * Algorithm:
 *
 * At time step t[n] :
 * first stage
 *   fm-1[n]  = x[n] - Km*mem[m-1]
 * (loop begins)
 * next stage
 *   fm-2[n]  = fm-1[n] - Km-1 * mem[m-2]
 *   mem[m-1] = fm-1[n] * conj(Km-1) + mem[m-1]
 *
 * ...
 *
 * final stage
 *   f0[n]    = f1[n] + K1*mem0
 *   mem1     = f1[n] * conj(K1) + mem0
 * (loop ends)
 *
 * Output 
 *   y[n]     = f0[n]
 *   mem0     = y[n]
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
/* Lattice all-pole filters: double-precision */
DSPALLPOLE_EXPORT void MWDSP_AllPole_Lat_DD(const real_T         *u,
                                 real_T               *y,
                                 real_T               *mem_first,
                                 const int_T          sampsPerChan,
                                 const int_T          numChans,
                                 const real_T * const K_first,
                                 const int_T          ordK,
                                 const boolean_T      one_fpf);

DSPALLPOLE_EXPORT void MWDSP_AllPole_Lat_DZ(const real_T          *u,
                                 creal_T               *y,
                                 creal_T               *mem_first,
                                 const int_T           sampsPerChan,
                                 const int_T           numChans,
                                 const creal_T * const K_first,
                                 const int_T           ordK,
                                 const boolean_T       one_fpf);

DSPALLPOLE_EXPORT void MWDSP_AllPole_Lat_ZD(const creal_T        *u,
                                 creal_T              *y,
                                 creal_T              *mem_first,
                                 const int_T          sampsPerChan,
                                 const int_T          numChans,
                                 const real_T * const K_first,
                                 const int_T          ordK,
                                 const boolean_T      one_fpf);

DSPALLPOLE_EXPORT void MWDSP_AllPole_Lat_ZZ(const creal_T         *u,
                                 creal_T               *y,
                                 creal_T *             mem_first,
                                 const int_T           sampsPerChan,
                                 const int_T           numChans,
                                 const creal_T * const K_first,
                                 const int_T           ordK,
                                 const boolean_T       one_fpf);


/* Lattice all-pole filters: single-precision */
DSPALLPOLE_EXPORT void MWDSP_AllPole_Lat_RR(const real32_T         *u,
                                 real32_T               *y,
                                 real32_T               *mem_first,
                                 const int_T            sampsPerChan,
                                 const int_T            numChans,
                                 const real32_T * const K_first,
                                 const int_T            ordK,
                                 const boolean_T        one_fpf);

DSPALLPOLE_EXPORT void MWDSP_AllPole_Lat_RC(const real32_T          *u,
                                 creal32_T               *y,
                                 creal32_T               *mem_first,
                                 const int_T             sampsPerChan,
                                 const int_T             numChans,
                                 const creal32_T * const K_first,
                                 const int_T             ordK,
                                 const boolean_T         one_fpf);

DSPALLPOLE_EXPORT void MWDSP_AllPole_Lat_CR(const creal32_T        *u,
                                 creal32_T              *y,
                                 creal32_T              *mem_first,
                                 const int_T            sampsPerChan,
                                 const int_T            numChans,
                                 const real32_T * const K_first,
                                 const int_T            ordK,
                                 const boolean_T        one_fpf);

DSPALLPOLE_EXPORT void MWDSP_AllPole_Lat_CC(const creal32_T         *u,
                                 creal32_T               *y,
                                 creal32_T               *mem_first,
                                 const int_T             sampsPerChan,
                                 const int_T             numChans,
                                 const creal32_T * const K_first,
                                 const int_T             ordK,
                                 const boolean_T         one_fpf);

/******************************************************************************/
/* ALLPOLE DF IMPLEMENTATIONS */
/******************************************************************************/

DSPALLPOLE_EXPORT void MWDSP_AllPole_DF_DD( 
                       const real_T         *u,
                       real_T               *y,
                       real_T  * const       mem_base,
                       int32_T                *offset_mem,
                       const int_T           numDelays,
                       const int_T           sampsPerChan,
                       const int_T           numChans,
                       const real_T  * const a,
                       const boolean_T       one_fpf);

DSPALLPOLE_EXPORT void MWDSP_AllPole_DF_DZ( 
                       const real_T         *u,
                       creal_T              *y,
                       creal_T       * const mem_base,
                       int32_T                *offset_mem,
                       const int_T           numDelays,
                       const int_T           sampsPerChan,
                       const int_T           numChans,
                       const creal_T  * const a,
                       const boolean_T       one_fpf);

DSPALLPOLE_EXPORT void MWDSP_AllPole_DF_ZD(
                       const creal_T        *u,
                       creal_T              *y,
                       creal_T       * const mem_base,
                       int32_T                *offset_mem,
                       const int_T           numDelays,
                       const int_T           sampsPerChan,
                       const int_T           numChans,
                       const real_T  * const a,
                       const boolean_T       one_fpf);

DSPALLPOLE_EXPORT void MWDSP_AllPole_DF_ZZ(
                       const creal_T        *u,
                       creal_T              *y,
                       creal_T       * const mem_base,
                       int32_T                *offset_mem,
                       const int_T           numDelays,
                       const int_T           sampsPerChan,
                       const int_T           numChans,
                       const creal_T  * const a,
                       const boolean_T       one_fpf);

DSPALLPOLE_EXPORT void MWDSP_AllPole_DF_RR(
                       const real32_T      *u,
                       real32_T            *y,
                       real32_T     * const mem_base,
                       int32_T               *offset_mem,
                       const int_T          numDelays,
                       const int_T          sampsPerChan,
                       const int_T          numChans,
                       const real32_T  * const a,
                       const boolean_T      one_fpf);

DSPALLPOLE_EXPORT void MWDSP_AllPole_DF_RC(
                       const real32_T      *u,
                       creal32_T           *y,
                       creal32_T    * const mem_base,
                       int32_T               *offset_mem,
                       const int_T          numDelays,
                       const int_T          sampsPerChan,
                       const int_T          numChans,
                       const creal32_T  * const a,
                       const boolean_T      one_fpf);

DSPALLPOLE_EXPORT void MWDSP_AllPole_DF_CR( 
                       const creal32_T      *u,
                       creal32_T            *y,
                       creal32_T  * const    mem_base,
                       int32_T                *offset_mem,
                       const int_T           numDelays,
                       const int_T           sampsPerChan,
                       const int_T           numChans,
                       const real32_T  * const a,
                       const boolean_T       one_fpf);

DSPALLPOLE_EXPORT void MWDSP_AllPole_DF_CC( 
                       const creal32_T      *u,
                       creal32_T            *y,
                       creal32_T * const    mem_base,
                       int32_T                *offset_mem,
                       const int_T           numDelays,
                       const int_T           sampsPerChan,
                       const int_T           numChans,
                       const creal32_T  * const a,
                       const boolean_T       one_fpf);
                       

DSPALLPOLE_EXPORT void MWDSP_AllPole_DF_A0Scale_DD( 
                       const real_T      *u,
                       real_T            *y,
                       real_T     * const mem_base,
                       int32_T             *offset_mem,
                       const int_T        numDelays,
                       const int_T        sampsPerChan,
                       const int_T        numChans,
                       const real_T  * const a,
                       const boolean_T    one_fpf);

DSPALLPOLE_EXPORT void MWDSP_AllPole_DF_A0Scale_DZ( 
                       const real_T         *u,
                       creal_T              *y,
                       creal_T       * const mem_base,
                       int32_T                *offset_mem,
                       const int_T           numDelays,
                       const int_T           sampsPerChan,
                       const int_T           numChans,
                       const creal_T  * const a,
                       const boolean_T       one_fpf);
                       
DSPALLPOLE_EXPORT void MWDSP_AllPole_DF_A0Scale_ZD(
                       const creal_T         *u,
                       creal_T               *y,
                       creal_T        * const mem_base,
                       int32_T                 *offset_mem,
                       const int_T            numDelays,
                       const int_T            sampsPerChan,
                       const int_T            numChans,
                       const real_T  * const a,
                       const boolean_T        one_fpf);
                       
DSPALLPOLE_EXPORT void MWDSP_AllPole_DF_A0Scale_ZZ(
                       const creal_T        *u,
                       creal_T              *y,
                       creal_T       * const mem_base,
                       int32_T                *offset_mem,
                       const int_T           numDelays,
                       const int_T           sampsPerChan,
                       const int_T           numChans,
                       const creal_T  * const a,
                       const boolean_T       one_fpf);
                       
DSPALLPOLE_EXPORT void MWDSP_AllPole_DF_A0Scale_RR(
                       const real32_T      *u,
                       real32_T            *y,
                       real32_T     * const mem_base,
                       int32_T               *offset_mem,
                       const int_T          numDelays,
                       const int_T          sampsPerChan,
                       const int_T          numChans,
                       const real32_T  * const a,
                       const boolean_T      one_fpf);

DSPALLPOLE_EXPORT void MWDSP_AllPole_DF_A0Scale_RC( 
                       const real32_T      *u,
                       creal32_T           *y,
                       creal32_T    * const mem_base,
                       int32_T               *offset_mem,
                       const int_T          numDelays,
                       const int_T          sampsPerChan,
                       const int_T          numChans,
                       const creal32_T  * const a,
                       const boolean_T      one_fpf);

DSPALLPOLE_EXPORT void MWDSP_AllPole_DF_A0Scale_CR( 
                       const creal32_T      *u,
                       creal32_T            *y,
                       creal32_T  *const     mem_base,
                       int32_T                *offset_mem,
                       const int_T           numDelays,
                       const int_T           sampsPerChan,
                       const int_T           numChans,
                       const real32_T  * const a,
                       const boolean_T       one_fpf);

DSPALLPOLE_EXPORT void MWDSP_AllPole_DF_A0Scale_CC( 
                       const creal32_T      *u,
                       creal32_T            *y,
                       creal32_T  * const    mem_base,
                       int32_T                *offset_mem,
                       const int_T           numDelays,
                       const int_T           sampsPerChan,
                       const int_T           numChans,
                       const creal32_T  * const a,
                       const boolean_T       one_fpf);

#ifdef MWDSP_INLINE_DSPRTLIB
#include "dspallpole/allpole_df_a0scale_cc_rt.c"
#include "dspallpole/allpole_df_a0scale_cr_rt.c"
#include "dspallpole/allpole_df_a0scale_dd_rt.c"
#include "dspallpole/allpole_df_a0scale_dz_rt.c"
#include "dspallpole/allpole_df_a0scale_rc_rt.c"
#include "dspallpole/allpole_df_a0scale_rr_rt.c"
#include "dspallpole/allpole_df_a0scale_zd_rt.c"
#include "dspallpole/allpole_df_a0scale_zz_rt.c"
#include "dspallpole/allpole_df_cc_rt.c"
#include "dspallpole/allpole_df_cr_rt.c"
#include "dspallpole/allpole_df_dd_rt.c"
#include "dspallpole/allpole_df_dz_rt.c"
#include "dspallpole/allpole_df_rc_rt.c"
#include "dspallpole/allpole_df_rr_rt.c"
#include "dspallpole/allpole_df_zd_rt.c"
#include "dspallpole/allpole_df_zz_rt.c"
#include "dspallpole/allpole_lat_cc_rt.c"
#include "dspallpole/allpole_lat_cr_rt.c"
#include "dspallpole/allpole_lat_dd_rt.c"
#include "dspallpole/allpole_lat_dz_rt.c"
#include "dspallpole/allpole_lat_rc_rt.c"
#include "dspallpole/allpole_lat_rr_rt.c"
#include "dspallpole/allpole_lat_zd_rt.c"
#include "dspallpole/allpole_lat_zz_rt.c"
#include "dspallpole/allpole_tdf_a0scale_cc_rt.c"
#include "dspallpole/allpole_tdf_a0scale_cr_rt.c"
#include "dspallpole/allpole_tdf_a0scale_dd_rt.c"
#include "dspallpole/allpole_tdf_a0scale_dz_rt.c"
#include "dspallpole/allpole_tdf_a0scale_rc_rt.c"
#include "dspallpole/allpole_tdf_a0scale_rr_rt.c"
#include "dspallpole/allpole_tdf_a0scale_zd_rt.c"
#include "dspallpole/allpole_tdf_a0scale_zz_rt.c"
#include "dspallpole/allpole_tdf_cc_rt.c"
#include "dspallpole/allpole_tdf_cr_rt.c"
#include "dspallpole/allpole_tdf_dd_rt.c"
#include "dspallpole/allpole_tdf_dz_rt.c"
#include "dspallpole/allpole_tdf_rc_rt.c"
#include "dspallpole/allpole_tdf_rr_rt.c"
#include "dspallpole/allpole_tdf_zd_rt.c"
#include "dspallpole/allpole_tdf_zz_rt.c"
#endif

#endif /* dspallpole_rt_h */

/* [EOF] dspallpole_rt.h */

