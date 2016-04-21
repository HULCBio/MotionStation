/*
 * dsp_fft_sim - DSP Blockset 1-D FFT simulation support
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.13.4.2 $  $Date: 2004/04/12 23:11:18 $
 */

#ifndef dsp_fft_sim_h
#define dsp_fft_sim_h

#include "dsp_fft_common_sim.h"

#ifdef __cplusplus
extern "C" {
#endif

/*
 * FFT functions for simulation use only
 */
extern void copy_inputs_if_needed(            MWDSP_FFTArgsCache *args, boolean_T cplx);
extern void copy_real_input_to_complex_output(MWDSP_FFTArgsCache *args);
extern void copy_complex_input_to_real_output(MWDSP_FFTArgsCache *args);
extern void copy_and_R2BR_Z(                  MWDSP_FFTArgsCache *args);
extern void copy_and_R2BR_DZ(                 MWDSP_FFTArgsCache *args);
extern void copy_and_R2BR_C(                  MWDSP_FFTArgsCache *args);
extern void copy_and_R2BR_RC(                 MWDSP_FFTArgsCache *args);
extern void copy_and_R2BR_AlongR_Z(           MWDSP_FFTArgsCache *args);

/* NOP = No operation */
extern void dspfft_NOP(MWDSP_FFTArgsCache *args);

/* Radix-2, Bit-reversed outputs: */
extern void dspfft_R2_BR_TRIG_D(MWDSP_FFTArgsCache *args); /* Cplx double out, Real double in, trig fcn           */
extern void dspfft_R2_BR_TRIG_R(MWDSP_FFTArgsCache *args); /* Cplx single out, Real single in, trig fcn           */
extern void dspfft_R2_BR_TBLM_D(MWDSP_FFTArgsCache *args); /* Cplx double out, Real double in, table (memory opt) */
extern void dspfft_R2_BR_TBLM_R(MWDSP_FFTArgsCache *args); /* Cplx single out, Real single in, table (memory opt) */
extern void dspfft_R2_BR_TBLS_D(MWDSP_FFTArgsCache *args); /* Cplx double out, Real double in, table (speed opt)  */
extern void dspfft_R2_BR_TBLS_R(MWDSP_FFTArgsCache *args); /* Cplx single out, Real single in, table (speed opt)  */
extern void dspfft_R2_BR_TBLM_2D_FIRSTC_D(MWDSP_FFTArgsCache *args); /* Cplx double out, Real double in, table (memory opt) */
extern void dspfft_R2_BR_TBLM_2D_FIRSTC_R(MWDSP_FFTArgsCache *args); /* Cplx single out, Real single in, table (memory opt) */
extern void dspfft_R2_BR_TBLS_2D_FIRSTC_D(MWDSP_FFTArgsCache *args); /* Cplx double out, Real double in, table (speed opt)  */
extern void dspfft_R2_BR_TBLS_2D_FIRSTC_R(MWDSP_FFTArgsCache *args); /* Cplx single out, Real single in, table (speed opt)  */
extern void dspfft_R2_BR_TBLM_2D_FIRSTR_D(MWDSP_FFTArgsCache *args); /* Cplx double out, Real double in, table (memory opt) */
extern void dspfft_R2_BR_TBLM_2D_FIRSTR_R(MWDSP_FFTArgsCache *args); /* Cplx single out, Real single in, table (memory opt) */
extern void dspfft_R2_BR_TBLS_2D_FIRSTR_D(MWDSP_FFTArgsCache *args); /* Cplx double out, Real double in, table (speed opt)  */
extern void dspfft_R2_BR_TBLS_2D_FIRSTR_R(MWDSP_FFTArgsCache *args); /* Cplx single out, Real single in, table (speed opt)  */

extern void dspfft_R2_BR_TRIG_Z(MWDSP_FFTArgsCache *args); /* Cplx double out, Cplx double in, trig fcn           */
extern void dspfft_R2_BR_TRIG_C(MWDSP_FFTArgsCache *args); /* Cplx single out, Cplx single in, trig fcn           */
extern void dspfft_R2_BR_TBLM_Z(MWDSP_FFTArgsCache *args); /* Cplx double out, Cplx double in, table (memory opt) */
extern void dspfft_R2_BR_TBLM_C(MWDSP_FFTArgsCache *args); /* Cplx single out, Cplx single in, table (memory opt) */
extern void dspfft_R2_BR_TBLS_Z(MWDSP_FFTArgsCache *args); /* Cplx double out, Cplx double in, table (speed opt)  */
extern void dspfft_R2_BR_TBLS_C(MWDSP_FFTArgsCache *args); /* Cplx single out, Cplx single in, table (speed opt)  */
extern void dspfft_R2_BR_TBLM_2D_Z(MWDSP_FFTArgsCache *args); /* Cplx double out, Cplx double in, table (memory opt) */
extern void dspfft_R2_BR_TBLM_2D_C(MWDSP_FFTArgsCache *args); /* Cplx single out, Cplx single in, table (memory opt) */
extern void dspfft_R2_BR_TBLS_2D_Z(MWDSP_FFTArgsCache *args); /* Cplx double out, Cplx double in, table (speed opt)  */
extern void dspfft_R2_BR_TBLS_2D_C(MWDSP_FFTArgsCache *args); /* Cplx single out, Cplx single in, table (speed opt)  */

/* Radix-2, Linear outputs: */
extern void dspfft_R2_TRIG_D(MWDSP_FFTArgsCache *args); /* Cplx double out, Real double in, trig fcn           */
extern void dspfft_R2_TRIG_R(MWDSP_FFTArgsCache *args); /* Cplx single out, Real single in, trig fcn           */
extern void dspfft_R2_TBLM_D(MWDSP_FFTArgsCache *args); /* Cplx double out, Real double in, table (memory opt) */
extern void dspfft_R2_TBLM_R(MWDSP_FFTArgsCache *args); /* Cplx single out, Real single in, table (memory opt) */
extern void dspfft_R2_TBLS_D(MWDSP_FFTArgsCache *args); /* Cplx double out, Real double in, table (speed opt)  */
extern void dspfft_R2_TBLS_R(MWDSP_FFTArgsCache *args); /* Cplx single out, Real single in, table (speed opt)  */
extern void dspfft_R2_TBLM_2D_FIRSTC_D(MWDSP_FFTArgsCache *args); /* Cplx double out, Real double in, table (memory opt) */
extern void dspfft_R2_TBLM_2D_FIRSTC_R(MWDSP_FFTArgsCache *args); /* Cplx single out, Real single in, table (memory opt) */
extern void dspfft_R2_TBLS_2D_FIRSTC_D(MWDSP_FFTArgsCache *args); /* Cplx double out, Real double in, table (speed opt)  */
extern void dspfft_R2_TBLS_2D_FIRSTC_R(MWDSP_FFTArgsCache *args); /* Cplx single out, Real single in, table (speed opt)  */
extern void dspfft_R2_TBLM_2D_FIRSTR_D(MWDSP_FFTArgsCache *args); /* Cplx double out, Real double in, table (memory opt) */
extern void dspfft_R2_TBLM_2D_FIRSTR_R(MWDSP_FFTArgsCache *args); /* Cplx single out, Real single in, table (memory opt) */
extern void dspfft_R2_TBLS_2D_FIRSTR_D(MWDSP_FFTArgsCache *args); /* Cplx double out, Real double in, table (speed opt)  */
extern void dspfft_R2_TBLS_2D_FIRSTR_R(MWDSP_FFTArgsCache *args); /* Cplx single out, Real single in, table (speed opt)  */

extern void dspfft_R2_TRIG_Z(MWDSP_FFTArgsCache *args); /* Cplx double out, Cplx double in, trig fcn           */
extern void dspfft_R2_TRIG_C(MWDSP_FFTArgsCache *args); /* Cplx single out, Cplx single in, trig fcn           */
extern void dspfft_R2_TBLM_Z(MWDSP_FFTArgsCache *args); /* Cplx double out, Cplx double in, table (memory opt) */
extern void dspfft_R2_TBLM_C(MWDSP_FFTArgsCache *args); /* Cplx single out, Cplx single in, table (memory opt) */
extern void dspfft_R2_TBLS_Z(MWDSP_FFTArgsCache *args); /* Cplx double out, Cplx double in, table (speed opt)  */
extern void dspfft_R2_TBLS_C(MWDSP_FFTArgsCache *args); /* Cplx single out, Cplx single in, table (speed opt)  */
extern void dspfft_R2_TBLM_2D_Z(MWDSP_FFTArgsCache *args); /* Cplx double out, Cplx double in, table (speed opt)  */
extern void dspfft_R2_TBLS_2D_Z(MWDSP_FFTArgsCache *args); /* Cplx double out, Cplx double in, table (speed opt)  */
extern void dspfft_R2_TBLM_2D_C(MWDSP_FFTArgsCache *args); /* Cplx double out, Cplx double in, table (speed opt)  */
extern void dspfft_R2_TBLS_2D_C(MWDSP_FFTArgsCache *args); /* Cplx double out, Cplx double in, table (speed opt)  */

/* Scalar cases: */
extern void dspfft_scalar_Z(MWDSP_FFTArgsCache *args);
extern void dspfft_scalar_D(MWDSP_FFTArgsCache *args);
extern void dspfft_scalar_C(MWDSP_FFTArgsCache *args);
extern void dspfft_scalar_R(MWDSP_FFTArgsCache *args);

#ifdef __cplusplus
} // close brace for extern C from above
#endif

#endif /* dsp_fft_sim_h */

/* [EOF] dsp_fft_sim.h */

