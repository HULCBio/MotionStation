/*
 * dspacf_rt.h - DSP Blockset Convolution and Correlation Run Time Functions
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.4.4.2 $  $Date: 2004/04/12 23:11:37 $
 */


#ifndef dspacf_rt_h
#define dspacf_rt_h

#include "dsp_rt.h"
#include "dspfft_rt.h"

#ifdef DSPACF_EXPORTS
#define DSPACF_EXPORT EXPORT_FCN
#else
#define DSPACF_EXPORT MWDSP_IDECL
#endif

/*
 * These routines compute the autocorrelation of a potentially multichannel signal.
 * As there is only one input, and the output has the same data type as the input,
 * each routine has a single identifying letter to indicate complexity and precision:
 *
 *  D for real double precision
 *  Z for complex double precision
 *  R for real single precision
 *  C for complex single precision
 *
 * There are time domain and frequency domain implementations. These are identified
 * via TD (time domain) or FD (frequency domain).
 *
 * There are also 4 helper functions that copy signals from the input to
 * a temporary buffer (dwork) for frequency domain processing. The complex
 * versions  MWDSP_Copy_and_ZeroPad_ZZ_Nchan and MWDSP_Copy_and_ZeroPad_CC_Nchan
 * simply copy from input to output with zero padding at the end of each channel.
 * The real versions (MWDSP_ACF_FFTInterleave_ZPad_D and MWDSP_ACF_FFTInterleave_ZPad_R) copy and
 * interleave for the real FFT.
 */

/*
 * Time Domain Autocorrelation
 */
DSPACF_EXPORT void MWDSP_ACF_TD_D(
    const real_T  *inPtr,    /* Pointer to input port buffer */
    int_T         inRows,    /* number of rows in input     */

    real_T        *outPtr,
    int_T         outRows,    /* number of rows in the output array    */
    int_T         outChans    /* number of columns in the output array */
);

DSPACF_EXPORT void MWDSP_ACF_TD_Z(
    const creal_T *inPtr,
    int_T         inRows,    /* number of rows in input     */

    creal_T       *outPtr,
    int_T         outRows,    /* number of rows in the output array    */
    int_T         outChans    /* number of columns in the output array */
);

DSPACF_EXPORT void MWDSP_ACF_TD_R(
    const real32_T  *inPtr,
    int_T           inRows,    /* number of rows in input     */

    real32_T        *outPtr,
    int_T           outRows,    /* number of rows in the output array    */
    int_T           outChans    /* number of columns in the output array */
);

DSPACF_EXPORT void MWDSP_ACF_TD_C(
    const creal32_T *inPtr,
    int_T           inRows,    /* number of rows in input     */

    creal32_T       *outPtr,
    int_T           outRows,    /* number of rows in the output array    */
    int_T           outChans    /* number of columns in the output array */
);

/*
 * Frequency Domain Autocorrelation
 */
DSPACF_EXPORT void MWDSP_ACF_FD_D(
    const real_T *inPtr,
    int_T         inRows,    /* number of rows in input     */

    real_T       *outPtr,
    int_T         outRows,    /* number of rows in the output array    */
    int_T         outChans,   /* number of columns in the output array */
    int_T         N,         /* Length of FFT to be used */
    creal_T      *fftbuff,   /* DWork temp for FFT output */
    const real_T *twidtbl    /* Twiddle table */
);

DSPACF_EXPORT void MWDSP_ACF_FD_Z(
    const creal_T *inPtr,
    int_T         inRows,    /* number of rows in input     */

    creal_T       *outPtr,
    int_T         outRows,    /* number of rows in the output array    */
    int_T         outChans,   /* number of columns in the output array */
    int_T         N,         /* Length of FFT to be used */
    creal_T      *fftbuff,   /* DWork temp for FFT output */
    const real_T *twidtbl    /* Twiddle table */
);

DSPACF_EXPORT void MWDSP_ACF_FD_R(
    const real32_T  *inPtr,
    int_T           inRows,    /* number of rows in input     */

    real32_T        *outPtr,
    int_T           outRows,    /* number of rows in the output array    */
    int_T           outChans,   /* number of columns in the output array */
    int_T           N,         /* Length of FFT to be used */
    creal32_T      *fftbuff,   /* DWork temp for FFT output */
    const real32_T *twidtbl    /* Twiddle table */
);

DSPACF_EXPORT void MWDSP_ACF_FD_C(
    const creal32_T *inPtr,
    int_T           inRows,    /* number of rows in input     */

    creal32_T       *outPtr,
    int_T           outRows,    /* number of rows in the output array    */
    int_T           outChans,   /* number of columns in the output array */
    int_T           N,         /* Length of FFT to be used */
    creal32_T      *fftbuff,   /* DWork temp for FFT output */
    const real32_T *twidtbl    /* Twiddle table */
);

/*
 * Helper functions for copying from input to dwork with zero padding
 */

DSPACF_EXPORT void MWDSP_Copy_and_ZeroPad_ZZ_Nchan(
    const creal_T *u,     /* Pointer to input */                       
    const int_T Nu,       /* How many points in each input channel */  
    creal_T *y,           /* Pointer to dwork buffer */                
    const int_T Ny,       /* Number of points in each FFT */           
    int_T Nchan           /* Number of channels */                     
);

DSPACF_EXPORT void MWDSP_Copy_and_ZeroPad_CC_Nchan(
    const creal32_T *u,
    const int_T Nu,
    creal32_T *y,
    const int_T Ny,
    int_T Nchan
);

DSPACF_EXPORT void MWDSP_ACF_FFTInterleave_ZPad_D(
    const real_T *inPtr,     /* Pointer to input */                       
    int_T         inRows,    /* How many points in each input channel */  
    creal_T       *buff,     /* Pointer to dwork buffer */                
    int_T         N,         /* Number of points in each FFT */           
    int_T         outChans   /* Number of channels */
);

DSPACF_EXPORT void MWDSP_ACF_FFTInterleave_ZPad_R(
    const real32_T *inPtr,
    int_T         inRows,
    creal32_T       *buff,
    int_T         N,
    int_T         outChans
);

#ifdef MWDSP_INLINE_DSPRTLIB
#include "dspacf/acf_td_c_rt.c"
#include "dspacf/acf_td_d_rt.c"
#include "dspacf/acf_td_r_rt.c"
#include "dspacf/acf_td_z_rt.c"
#include "dspacf/acf_fft_interleave_zpad_d_rt.c"
#include "dspacf/acf_fft_interleave_zpad_r_rt.c"
#include "dspacf/copy_and_zero_pad_cc_nchan_rt.c"
#include "dspacf/copy_and_zero_pad_zz_nchan_rt.c"
#endif

#endif /* dspacf_rt_h */
