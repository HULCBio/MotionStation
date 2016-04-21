/*
 *  dspbiquad_rt.h
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.4.4.2 $ $Date: 2004/04/12 23:11:39 $
 */

#ifndef DSPBIQUAD_RT_H
#define DSPBIQUAD_RT_H

#include "dsp_rt.h"

#ifdef DSPBIQUAD_EXPORTS
#define DSPBIQUAD_EXPORT EXPORT_FCN
#else
#define DSPBIQUAD_EXPORT MWDSP_IDECL
#endif

/* Biquad Transposed Direct Form II Filter Implementation
 * 
 * Biquad algorithm: Transposed Direct Form II Second Order Sections
 *       
 * For each time step, the output is calculated by looping over each section s
 * of the SOS (second-order section) matrix and performing:
 *   y[n]      = (D0[s,n] + x[n]*b_0) /  a_0       (output)
 *   D0[s,n+1] =  D1[s,n] + x[n]*b_1  -  y[n]*a_1  (delay         
 *   D1[s,n+1] =            x[n]*b_2  -  y[n]*a_2   updates)
 * For each section after the first, the output (y[n]) of the previous
 * section is used as the input (x[n]) of the next section:
 *   x[n]  = y[n];
 *
 * Notation used above:
 *   a_i  = denominator polynomial,             
 *   b_i  = numerator polynomial,
 *   D0/1 = delay buffer containing state memory for current channel 
 *   y    = output value                        
 *   x    = input value
 *   s    = index of current second-order section                         
 *
 *
 * Algorithm optimizations:
 *
 *  Biquad6: 1/a_0 is precomputed (by the caller), so that 
 *    multiplication is used instead of (expensive) division
 *
 *  Biquad5: normalized such that a_0 = 1; 
 *    (division by a_0 is omitted)
 *
 *  Biquad4: a_0 = 1 and b_0 = 1
 *    (division by a_0 and multiplication by b_0 are omitted)
 *
 *
 * State buffer storage:
 *   Channel 1:
 *   -------------------------------------
 *   |  SOS 0  |  SOS 1  |  SOS 2  |  ...
 *   | D0 | D1 | D0 | D1 | D0 | D1 |  ...
 *   -------------------------------------
 *   Channel 2:
 *   -------------------------------------
 *   |  SOS 0  |  SOS 1  |  SOS 2  |  ...
 *   | D0 | D1 | D0 | D1 | D0 | D1 |  ...
 *   -------------------------------------
 *   Channel 3:
 *   -------------------------------------
 *   |  SOS 0  |  SOS 1  |  SOS 2  |  ...
 *   | D0 | D1 | D0 | D1 | D0 | D1 |  ...
 *   -------------------------------------
 *   Channel ....
 *  The channels are stored in succession in memory
 *
 *
 * Coefficient Storage:
 *   ------------------------------------------------------------
 *   |  filter sec 0   |  filter sec 1   |  filter sec 2   | ...
 *   |b0|b1|b2|a0|a1|a2|b0|b1|b2|a0|a1|a2|b0|b1|b2|a0|a1|a2| ...
 *   ------------------------------------------------------------
 *   For biquad5, the value of a0 is assumed to be one.  Thus, there
 *     are only five coefficients per SOS.
 *   For biquad4, the values of both a0 and b0 are assumed to be one
 *     Thus, there are only four coefficients per SOS.
 *
 *
 * Function naming glossary
 * ---------------------------
 *
 * Function name: MWDSP_BQ{4|5|6}_DF2T_1fpf_{Sections}_{Data types}
 *
 * MWDSP     = MathWorks DSP
 * BQ{4|5|6} = Second-order section (biquad) filter with
 *             number of coefficients per sos
 * DF2T      = Direct-form II transpose structure
 * 1fpf      = One filter per frame
 *
 * Sections:
 *
 *   1sos = Single second-order section case
 *   Nsos = Multiple second-order sections case
 *
 * Data types - (describe inputs to functions, not outputs)
 *
 *   R = real single-precision
 *   C = complex single-precision
 *   D = real double-precision
 *   Z = complex double-precision
 *
 * Data type notes:
 * - First data letter refers to data type of input signal
 * - Second data letter refers to data type of coefficients
 * - Precision of input and coefficients must match
 *
 *
 * Function Arguments
 *   u            = pointer to input signal
 *   y            = pointer to output signal
 *   state        = pointer to state memory
 *   coeffs       = pointer to coefficients
 *   a0invs       = array of a0 inverses
 *   sampsPerChan = number of smaples per channel in input signal
 *   numChans     = number of channels in input signal
 *   numSections  = number of second-order sections in the SOS matrix
 *
 *  - numSections only appears in the *_Nsos_* functions
 *  - a0invs is an array of inverses for bq6/nsos, a single value
 *    for bq6/1sos
 */

/**************
 *  BIQUAD 6  *
 **************/
DSPBIQUAD_EXPORT void MWDSP_BQ6_DF2T_1fpf_1sos_DD(const real_T *u,
                                        real_T       *y,
                                        real_T       *state,
                                        const real_T *coeffs,
                                        const real_T  a0inv,
                                        const int_T   sampsPerChan,
                                        const int_T   numChans);

DSPBIQUAD_EXPORT void MWDSP_BQ6_DF2T_1fpf_1sos_DZ(const real_T  *u,
                                        creal_T       *y,
                                        creal_T       *state,
                                        const creal_T *coeffs,
                                        const creal_T  a0inv,
                                        const int_T    sampsPerChan,
                                        const int_T    numChans);

DSPBIQUAD_EXPORT void MWDSP_BQ6_DF2T_1fpf_1sos_ZD(const creal_T *u,
                                        creal_T       *y,
                                        creal_T       *state,
                                        const real_T  *coeffs,
                                        const real_T   a0inv,
                                        const int_T    sampsPerChan,
                                        const int_T    numChans);

DSPBIQUAD_EXPORT void MWDSP_BQ6_DF2T_1fpf_1sos_ZZ(const creal_T *u,
                                        creal_T       *y,
                                        creal_T       *state,
                                        const creal_T *coeffs,
                                        const creal_T  a0inv,
                                        const int_T    sampsPerChan,
                                        const int_T    numChans);
                                        
DSPBIQUAD_EXPORT void MWDSP_BQ6_DF2T_1fpf_1sos_RR(const real32_T *u,
                                        real32_T       *y,
                                        real32_T       *state,
                                        const real32_T *coeffs,
                                        const real32_T  a0inv,
                                        const int_T     sampsPerChan,
                                        const int_T     numChans);

DSPBIQUAD_EXPORT void MWDSP_BQ6_DF2T_1fpf_1sos_RC(const real32_T  *u,
                                        creal32_T       *y,
                                        creal32_T       *state,
                                        const creal32_T *coeffs,
                                        const creal32_T  a0inv,
                                        const int_T      sampsPerChan,
                                        const int_T      numChans);

DSPBIQUAD_EXPORT void MWDSP_BQ6_DF2T_1fpf_1sos_CR(const creal32_T *u,
                                        creal32_T       *y,
                                        creal32_T       *state,
                                        const real32_T  *coeffs,
                                        const real32_T   a0inv,
                                        const int_T      sampsPerChan,
                                        const int_T      numChans);

DSPBIQUAD_EXPORT void MWDSP_BQ6_DF2T_1fpf_1sos_CC(const creal32_T *u,
                                        creal32_T       *y,
                                        creal32_T       *state,
                                        const creal32_T *coeffs,
                                        const creal32_T  a0inv,
                                        const int_T      sampsPerChan,
                                        const int_T      numChans);

DSPBIQUAD_EXPORT void MWDSP_BQ6_DF2T_1fpf_Nsos_DD(const real_T *u,
                                        real_T       *y,
                                        real_T       *state,
                                        const real_T *coeffs,
                                        const real_T *a0invs,
                                        const int_T   sampsPerChan,
                                        const int_T   numChans,
                                        const int_T   numSections);

DSPBIQUAD_EXPORT void MWDSP_BQ6_DF2T_1fpf_Nsos_DZ(const real_T  *u,
                                        creal_T       *y,
                                        creal_T       *state,
                                        const creal_T *coeffs,
                                        const creal_T *a0invs,
                                        const int_T    sampsPerChan,
                                        const int_T    numChans,
                                        const int_T    numSections);

DSPBIQUAD_EXPORT void MWDSP_BQ6_DF2T_1fpf_Nsos_ZD(const creal_T *u,
                                        creal_T       *y,
                                        creal_T       *state,
                                        const real_T  *coeffs,
                                        const real_T  *a0invs,
                                        const int_T    sampsPerChan,
                                        const int_T    numChans,
                                        const int_T    numSections);

DSPBIQUAD_EXPORT void MWDSP_BQ6_DF2T_1fpf_Nsos_ZZ(const creal_T *u,
                                        creal_T       *y,
                                        creal_T       *state,
                                        const creal_T *coeffs,
                                        const creal_T *a0invs,
                                        const int_T    sampsPerChan,
                                        const int_T    numChans,
                                        const int_T    numSections);
                                        
DSPBIQUAD_EXPORT void MWDSP_BQ6_DF2T_1fpf_Nsos_RR(const real32_T *u,
                                        real32_T       *y,
                                        real32_T       *state,
                                        const real32_T *coeffs,
                                        const real32_T *a0invs,
                                        const int_T     sampsPerChan,
                                        const int_T     numChans,
                                        const int_T     numSections);

DSPBIQUAD_EXPORT void MWDSP_BQ6_DF2T_1fpf_Nsos_RC(const real32_T  *u,
                                        creal32_T       *y,
                                        creal32_T       *state,
                                        const creal32_T *coeffs,
                                        const creal32_T *a0invs,
                                        const int_T      sampsPerChan,
                                        const int_T      numChans,
                                        const int_T      numSections);

DSPBIQUAD_EXPORT void MWDSP_BQ6_DF2T_1fpf_Nsos_CR(const creal32_T *u,
                                        creal32_T       *y,
                                        creal32_T       *state,
                                        const real32_T  *coeffs,
                                        const real32_T  *a0invs,
                                        const int_T      sampsPerChan,
                                        const int_T      numChans,
                                        const int_T      numSections);

DSPBIQUAD_EXPORT void MWDSP_BQ6_DF2T_1fpf_Nsos_CC(const creal32_T *u,
                                        creal32_T       *y,
                                        creal32_T       *state,
                                        const creal32_T *coeffs,
                                        const creal32_T *a0invs,
                                        const int_T      sampsPerChan,
                                        const int_T      numChans,
                                        const int_T      numSections);


/**************
 *  BIQUAD 5  *
 **************/
DSPBIQUAD_EXPORT void MWDSP_BQ5_DF2T_1fpf_1sos_DD(const real_T *u,
                                        real_T       *y,
                                        real_T       *state,
                                        const real_T *coeffs,
                                        const int_T   sampsPerChan,
                                        const int_T   numChans);

DSPBIQUAD_EXPORT void MWDSP_BQ5_DF2T_1fpf_1sos_DZ(const real_T  *u,
                                        creal_T       *y,
                                        creal_T       *state,
                                        const creal_T *coeffs,
                                        const int_T    sampsPerChan,
                                        const int_T    numChans);

DSPBIQUAD_EXPORT void MWDSP_BQ5_DF2T_1fpf_1sos_ZD(const creal_T *u,
                                        creal_T       *y,
                                        creal_T       *state,
                                        const real_T  *coeffs,
                                        const int_T    sampsPerChan,
                                        const int_T    numChans);

DSPBIQUAD_EXPORT void MWDSP_BQ5_DF2T_1fpf_1sos_ZZ(const creal_T *u,
                                        creal_T       *y,
                                        creal_T       *state,
                                        const creal_T *coeffs,
                                        const int_T    sampsPerChan,
                                        const int_T    numChans);
                                        
DSPBIQUAD_EXPORT void MWDSP_BQ5_DF2T_1fpf_1sos_RR(const real32_T *u,
                                        real32_T       *y,
                                        real32_T       *state,
                                        const real32_T *coeffs,
                                        const int_T     sampsPerChan,
                                        const int_T     numChans);

DSPBIQUAD_EXPORT void MWDSP_BQ5_DF2T_1fpf_1sos_RC(const real32_T  *u,
                                        creal32_T       *y,
                                        creal32_T       *state,
                                        const creal32_T *coeffs,
                                        const int_T      sampsPerChan,
                                        const int_T      numChans);

DSPBIQUAD_EXPORT void MWDSP_BQ5_DF2T_1fpf_1sos_CR(const creal32_T *u,
                                        creal32_T       *y,
                                        creal32_T       *state,
                                        const real32_T  *coeffs,
                                        const int_T      sampsPerChan,
                                        const int_T      numChans);

DSPBIQUAD_EXPORT void MWDSP_BQ5_DF2T_1fpf_1sos_CC(const creal32_T *u,
                                        creal32_T       *y,
                                        creal32_T       *state,
                                        const creal32_T *coeffs,
                                        const int_T      sampsPerChan,
                                        const int_T      numChans);

DSPBIQUAD_EXPORT void MWDSP_BQ5_DF2T_1fpf_Nsos_DD(const real_T *u,
                                        real_T       *y,
                                        real_T       *state,
                                        const real_T *coeffs,
                                        const int_T   sampsPerChan,
                                        const int_T   numChans,
                                        const int_T   numSections);

DSPBIQUAD_EXPORT void MWDSP_BQ5_DF2T_1fpf_Nsos_DZ(const real_T  *u,
                                        creal_T       *y,
                                        creal_T       *state,
                                        const creal_T *coeffs,
                                        const int_T    sampsPerChan,
                                        const int_T    numChans,
                                        const int_T    numSections);

DSPBIQUAD_EXPORT void MWDSP_BQ5_DF2T_1fpf_Nsos_ZD(const creal_T *u,
                                        creal_T       *y,
                                        creal_T       *state,
                                        const real_T  *coeffs,
                                        const int_T    sampsPerChan,
                                        const int_T    numChans,
                                        const int_T    numSections);

DSPBIQUAD_EXPORT void MWDSP_BQ5_DF2T_1fpf_Nsos_ZZ(const creal_T *u,
                                        creal_T       *y,
                                        creal_T       *state,
                                        const creal_T *coeffs,
                                        const int_T    sampsPerChan,
                                        const int_T    numChans,
                                        const int_T    numSections);
                                        
DSPBIQUAD_EXPORT void MWDSP_BQ5_DF2T_1fpf_Nsos_RR(const real32_T *u,
                                        real32_T       *y,
                                        real32_T       *state,
                                        const real32_T *coeffs,
                                        const int_T     sampsPerChan,
                                        const int_T     numChans,
                                        const int_T     numSections);

DSPBIQUAD_EXPORT void MWDSP_BQ5_DF2T_1fpf_Nsos_RC(const real32_T  *u,
                                        creal32_T       *y,
                                        creal32_T       *state,
                                        const creal32_T *coeffs,
                                        const int_T      sampsPerChan,
                                        const int_T      numChans,
                                        const int_T      numSections);

DSPBIQUAD_EXPORT void MWDSP_BQ5_DF2T_1fpf_Nsos_CR(const creal32_T *u,
                                        creal32_T       *y,
                                        creal32_T       *state,
                                        const real32_T  *coeffs,
                                        const int_T      sampsPerChan,
                                        const int_T      numChans,
                                        const int_T      numSections);

DSPBIQUAD_EXPORT void MWDSP_BQ5_DF2T_1fpf_Nsos_CC(const creal32_T *u,
                                        creal32_T       *y,
                                        creal32_T       *state,
                                        const creal32_T *coeffs,
                                        const int_T      sampsPerChan,
                                        const int_T      numChans,
                                        const int_T      numSections);

/**************
 *  BIQUAD 4  *
 **************/
DSPBIQUAD_EXPORT void MWDSP_BQ4_DF2T_1fpf_1sos_DD(const real_T *u,
                                        real_T       *y,
                                        real_T       *state,
                                        const real_T *coeffs,
                                        const int_T   sampsPerChan,
                                        const int_T   numChans);

DSPBIQUAD_EXPORT void MWDSP_BQ4_DF2T_1fpf_1sos_DZ(const real_T  *u,
                                        creal_T       *y,
                                        creal_T       *state,
                                        const creal_T *coeffs,
                                        const int_T    sampsPerChan,
                                        const int_T    numChans);

DSPBIQUAD_EXPORT void MWDSP_BQ4_DF2T_1fpf_1sos_ZD(const creal_T *u,
                                        creal_T       *y,
                                        creal_T       *state,
                                        const real_T  *coeffs,
                                        const int_T    sampsPerChan,
                                        const int_T    numChans);

DSPBIQUAD_EXPORT void MWDSP_BQ4_DF2T_1fpf_1sos_ZZ(const creal_T *u,
                                        creal_T       *y,
                                        creal_T       *state,
                                        const creal_T *coeffs,
                                        const int_T    sampsPerChan,
                                        const int_T    numChans);
                                        
DSPBIQUAD_EXPORT void MWDSP_BQ4_DF2T_1fpf_1sos_RR(const real32_T *u,
                                        real32_T       *y,
                                        real32_T       *state,
                                        const real32_T *coeffs,
                                        const int_T     sampsPerChan,
                                        const int_T     numChans);

DSPBIQUAD_EXPORT void MWDSP_BQ4_DF2T_1fpf_1sos_RC(const real32_T  *u,
                                        creal32_T       *y,
                                        creal32_T       *state,
                                        const creal32_T *coeffs,
                                        const int_T      sampsPerChan,
                                        const int_T      numChans);

DSPBIQUAD_EXPORT void MWDSP_BQ4_DF2T_1fpf_1sos_CR(const creal32_T *u,
                                        creal32_T       *y,
                                        creal32_T       *state,
                                        const real32_T  *coeffs,
                                        const int_T      sampsPerChan,
                                        const int_T      numChans);

DSPBIQUAD_EXPORT void MWDSP_BQ4_DF2T_1fpf_1sos_CC(const creal32_T *u,
                                        creal32_T       *y,
                                        creal32_T       *state,
                                        const creal32_T *coeffs,
                                        const int_T      sampsPerChan,
                                        const int_T      numChans);

DSPBIQUAD_EXPORT void MWDSP_BQ4_DF2T_1fpf_Nsos_DD(const real_T *u,
                                        real_T       *y,
                                        real_T       *state,
                                        const real_T *coeffs,
                                        const int_T   sampsPerChan,
                                        const int_T   numChans,
                                        const int_T   numSections);

DSPBIQUAD_EXPORT void MWDSP_BQ4_DF2T_1fpf_Nsos_DZ(const real_T  *u,
                                        creal_T       *y,
                                        creal_T       *state,
                                        const creal_T *coeffs,
                                        const int_T    sampsPerChan,
                                        const int_T    numChans,
                                        const int_T    numSections);

DSPBIQUAD_EXPORT void MWDSP_BQ4_DF2T_1fpf_Nsos_ZD(const creal_T *u,
                                        creal_T       *y,
                                        creal_T       *state,
                                        const real_T  *coeffs,
                                        const int_T    sampsPerChan,
                                        const int_T    numChans,
                                        const int_T    numSections);

DSPBIQUAD_EXPORT void MWDSP_BQ4_DF2T_1fpf_Nsos_ZZ(const creal_T *u,
                                        creal_T       *y,
                                        creal_T       *state,
                                        const creal_T *coeffs,
                                        const int_T    sampsPerChan,
                                        const int_T    numChans,
                                        const int_T    numSections);
                                                      
DSPBIQUAD_EXPORT void MWDSP_BQ4_DF2T_1fpf_Nsos_RR(const real32_T *u,
                                        real32_T       *y,
                                        real32_T       *state,
                                        const real32_T *coeffs,
                                        const int_T     sampsPerChan,
                                        const int_T     numChans,
                                        const int_T     numSections);

DSPBIQUAD_EXPORT void MWDSP_BQ4_DF2T_1fpf_Nsos_RC(const real32_T  *u,
                                        creal32_T       *y,
                                        creal32_T       *state,
                                        const creal32_T *coeffs,
                                        const int_T      sampsPerChan,
                                        const int_T      numChans,
                                        const int_T      numSections);

DSPBIQUAD_EXPORT void MWDSP_BQ4_DF2T_1fpf_Nsos_CR(const creal32_T *u,
                                        creal32_T       *y,
                                        creal32_T       *state,
                                        const real32_T  *coeffs,
                                        const int_T      sampsPerChan,
                                        const int_T      numChans,
                                        const int_T      numSections);

DSPBIQUAD_EXPORT void MWDSP_BQ4_DF2T_1fpf_Nsos_CC(const creal32_T *u,
                                        creal32_T       *y,
                                        creal32_T       *state,
                                        const creal32_T *coeffs,
                                        const int_T      sampsPerChan,
                                        const int_T      numChans,
                                        const int_T      numSections);

#ifdef MWDSP_INLINE_DSPRTLIB
#include "dspbiquad/bq4_df2t_1fpf_1sos_cc_rt.c"
#include "dspbiquad/bq4_df2t_1fpf_1sos_cr_rt.c"
#include "dspbiquad/bq4_df2t_1fpf_1sos_dd_rt.c"
#include "dspbiquad/bq4_df2t_1fpf_1sos_dz_rt.c"
#include "dspbiquad/bq4_df2t_1fpf_1sos_rc_rt.c"
#include "dspbiquad/bq4_df2t_1fpf_1sos_rr_rt.c"
#include "dspbiquad/bq4_df2t_1fpf_1sos_zd_rt.c"
#include "dspbiquad/bq4_df2t_1fpf_1sos_zz_rt.c"
#include "dspbiquad/bq4_df2t_1fpf_nsos_cc_rt.c"
#include "dspbiquad/bq4_df2t_1fpf_nsos_cr_rt.c"
#include "dspbiquad/bq4_df2t_1fpf_nsos_dd_rt.c"
#include "dspbiquad/bq4_df2t_1fpf_nsos_dz_rt.c"
#include "dspbiquad/bq4_df2t_1fpf_nsos_rc_rt.c"
#include "dspbiquad/bq4_df2t_1fpf_nsos_rr_rt.c"
#include "dspbiquad/bq4_df2t_1fpf_nsos_zd_rt.c"
#include "dspbiquad/bq4_df2t_1fpf_nsos_zz_rt.c"
#include "dspbiquad/bq5_df2t_1fpf_1sos_cc_rt.c"
#include "dspbiquad/bq5_df2t_1fpf_1sos_cr_rt.c"
#include "dspbiquad/bq5_df2t_1fpf_1sos_dd_rt.c"
#include "dspbiquad/bq5_df2t_1fpf_1sos_dz_rt.c"
#include "dspbiquad/bq5_df2t_1fpf_1sos_rc_rt.c"
#include "dspbiquad/bq5_df2t_1fpf_1sos_rr_rt.c"
#include "dspbiquad/bq5_df2t_1fpf_1sos_zd_rt.c"
#include "dspbiquad/bq5_df2t_1fpf_1sos_zz_rt.c"
#include "dspbiquad/bq5_df2t_1fpf_nsos_cc_rt.c"
#include "dspbiquad/bq5_df2t_1fpf_nsos_cr_rt.c"
#include "dspbiquad/bq5_df2t_1fpf_nsos_dd_rt.c"
#include "dspbiquad/bq5_df2t_1fpf_nsos_dz_rt.c"
#include "dspbiquad/bq5_df2t_1fpf_nsos_rc_rt.c"
#include "dspbiquad/bq5_df2t_1fpf_nsos_rr_rt.c"
#include "dspbiquad/bq5_df2t_1fpf_nsos_zd_rt.c"
#include "dspbiquad/bq5_df2t_1fpf_nsos_zz_rt.c"
#include "dspbiquad/bq6_df2t_1fpf_1sos_cc_rt.c"
#include "dspbiquad/bq6_df2t_1fpf_1sos_cr_rt.c"
#include "dspbiquad/bq6_df2t_1fpf_1sos_dd_rt.c"
#include "dspbiquad/bq6_df2t_1fpf_1sos_dz_rt.c"
#include "dspbiquad/bq6_df2t_1fpf_1sos_rc_rt.c"
#include "dspbiquad/bq6_df2t_1fpf_1sos_rr_rt.c"
#include "dspbiquad/bq6_df2t_1fpf_1sos_zd_rt.c"
#include "dspbiquad/bq6_df2t_1fpf_1sos_zz_rt.c"
#include "dspbiquad/bq6_df2t_1fpf_nsos_cc_rt.c"
#include "dspbiquad/bq6_df2t_1fpf_nsos_cr_rt.c"
#include "dspbiquad/bq6_df2t_1fpf_nsos_dd_rt.c"
#include "dspbiquad/bq6_df2t_1fpf_nsos_dz_rt.c"
#include "dspbiquad/bq6_df2t_1fpf_nsos_rc_rt.c"
#include "dspbiquad/bq6_df2t_1fpf_nsos_rr_rt.c"
#include "dspbiquad/bq6_df2t_1fpf_nsos_zd_rt.c"
#include "dspbiquad/bq6_df2t_1fpf_nsos_zz_rt.c"
#endif

#endif /* dspbiquad_rt_h */

/* [EOF] dspbiquad_rt.h */
