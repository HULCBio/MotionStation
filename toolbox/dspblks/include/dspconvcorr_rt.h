/*
 * dspconvcorr_rt.h - DSP Blockset Convolution and Correlation Run Time Functions
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.4.4.2 $  $Date: 2004/04/12 23:11:44 $
 */

#ifndef dspconvcorr_rt_h
#define dspconvcorr_rt_h

#include "dsp_rt.h"
#include "dspfft_rt.h"

#ifdef DSPCONVCORR_EXPORTS
#define DSPCONVCORR_EXPORT EXPORT_FCN
#else
#define DSPCONVCORR_EXPORT MWDSP_IDECL
#endif

#ifdef __cplusplus
extern "C" {
#endif

/*
 * Utility Functions for Double Precision, Frequency Domain
 */
DSPCONVCORR_EXPORT void MWDSP_Copy_and_ZeroPad_DZ(const real_T *u, const int_T Nu, creal_T *y, const int_T Ny);
DSPCONVCORR_EXPORT void MWDSP_Copy_and_ZeroPad_ZZ(const creal_T *u, const int_T Nu, creal_T *y, const int_T Ny);

/*
 * Utility Functions for Single Precision, Frequency Domain
 */
DSPCONVCORR_EXPORT void MWDSP_Copy_and_ZeroPad_RC(const real32_T *u, const int_T Nu, creal32_T *y, const int_T Ny);
DSPCONVCORR_EXPORT void MWDSP_Copy_and_ZeroPad_CC(const creal32_T *u, const int_T Nu, creal32_T *y, const int_T Ny);


/*
 * Double Precision, Time Domain Convolution
 */
DSPCONVCORR_EXPORT void MWDSP_Conv_TD_DD(
    const real_T  *inPtrA,
    int_T         nRowsA,    /* number of rows in input A     */
    boolean_T     multiChanA,/* Boolean indicating whether A has more than 1 channel */

    const real_T  *inPtrB,
    int_T         nRowsB,    /* number of rows in input B     */
    boolean_T     multiChanB,/* Boolean indicating whether B has more than 1 channel */

    real_T        *outPtr,
    int_T         nRowsY,    /* number of rows in the output array    */
    int_T         nChansY   /* number of columns in the output array */
);

DSPCONVCORR_EXPORT void MWDSP_Conv_TD_DZ(
    const real_T  *inPtrA,
    int_T         nRowsA,    /* number of rows in input A     */
    boolean_T     multiChanA,/* Boolean indicating whether A has more than 1 channel */

    const creal_T *inPtrB,
    int_T         nRowsB,    /* number of rows in input B     */
    boolean_T     multiChanB,/* Boolean indicating whether B has more than 1 channel */

    creal_T       *outPtr,
    int_T         nRowsY,    /* number of rows in the output array    */
    int_T         nChansY   /* number of columns in the output array */
);

DSPCONVCORR_EXPORT void MWDSP_Conv_TD_ZZ(
    const creal_T *inPtrA,
    int_T         nRowsA,    /* number of rows in input A     */
    boolean_T     multiChanA,/* Boolean indicating whether A has more than 1 channel */

    const creal_T *inPtrB,
    int_T         nRowsB,    /* number of rows in input B     */
    boolean_T     multiChanB,/* Boolean indicating whether B has more than 1 channel */

    creal_T       *outPtr,
    int_T         nRowsY,    /* number of rows in the output array    */
    int_T         nChansY   /* number of columns in the output array */
);

/*
 * Single Precision, Time Domain Convolution
 */
DSPCONVCORR_EXPORT void MWDSP_Conv_TD_RR(
    const real32_T  *inPtrA,
    int_T           nRowsA,    /* number of rows in input A     */
    boolean_T       multiChanA,/* Boolean indicating whether A has more than 1 channel */

    const real32_T  *inPtrB,
    int_T           nRowsB,    /* number of rows in input B     */
    boolean_T       multiChanB,/* Boolean indicating whether B has more than 1 channel */

    real32_T        *outPtr,
    int_T           nRowsY,    /* number of rows in the output array    */
    int_T           nChansY   /* number of columns in the output array */
);

DSPCONVCORR_EXPORT void MWDSP_Conv_TD_RC(
    const real32_T  *inPtrA,
    int_T           nRowsA,    /* number of rows in input A     */
    boolean_T       multiChanA,/* Boolean indicating whether A has more than 1 channel */

    const creal32_T *inPtrB,
    int_T           nRowsB,    /* number of rows in input B     */
    boolean_T       multiChanB,/* Boolean indicating whether B has more than 1 channel */

    creal32_T       *outPtr,
    int_T           nRowsY,    /* number of rows in the output array    */
    int_T           nChansY   /* number of columns in the output array */
);

DSPCONVCORR_EXPORT void MWDSP_Conv_TD_CC(
    const creal32_T *inPtrA,
    int_T           nRowsA,    /* number of rows in input A     */
    boolean_T       multiChanA,/* Boolean indicating whether A has more than 1 channel */

    const creal32_T *inPtrB,
    int_T           nRowsB,    /* number of rows in input B     */
    boolean_T       multiChanB,/* Boolean indicating whether B has more than 1 channel */

    creal32_T       *outPtr,
    int_T           nRowsY,    /* number of rows in the output array    */
    int_T           nChansY   /* number of columns in the output array */
);

/*
 * Double Precision, Time Domain Correlation
 */
DSPCONVCORR_EXPORT void MWDSP_Corr_TD_DD(
    const real_T  *inPtrA,
    int_T         nRowsA,    /* number of rows in input A     */
    boolean_T     multiChanA,/* Boolean indicating whether A has more than 1 channel */

    const real_T  *inPtrB,
    int_T         nRowsB,    /* number of rows in input B     */
    boolean_T     multiChanB,/* Boolean indicating whether B has more than 1 channel */

    real_T        *outPtr,
    int_T         nRowsY,    /* number of rows in the output array    */
    int_T         nChansY   /* number of columns in the output array */
);

DSPCONVCORR_EXPORT void MWDSP_Corr_TD_DZ(
    const real_T  *inPtrA,
    int_T         nRowsA,    /* number of rows in input A     */
    boolean_T     multiChanA,/* Boolean indicating whether A has more than 1 channel */

    const creal_T *inPtrB,
    int_T         nRowsB,    /* number of rows in input B     */
    boolean_T     multiChanB,/* Boolean indicating whether B has more than 1 channel */

    creal_T       *outPtr,
    int_T         nRowsY,    /* number of rows in the output array    */
    int_T         nChansY   /* number of columns in the output array */
);

DSPCONVCORR_EXPORT void MWDSP_Corr_TD_ZD(
    const creal_T *inPtrA,
    int_T         nRowsA,    /* number of rows in input A     */
    boolean_T     multiChanA,/* Boolean indicating whether A has more than 1 channel */

    const real_T  *inPtrB,
    int_T         nRowsB,    /* number of rows in input B     */
    boolean_T     multiChanB,/* Boolean indicating whether B has more than 1 channel */

    creal_T       *outPtr,
    int_T         nRowsY,    /* number of rows in the output array    */
    int_T         nChansY   /* number of columns in the output array */
);

DSPCONVCORR_EXPORT void MWDSP_Corr_TD_ZZ(
    const creal_T *inPtrA,
    int_T         nRowsA,    /* number of rows in input A     */
    boolean_T     multiChanA,/* Boolean indicating whether A has more than 1 channel */

    const creal_T *inPtrB,
    int_T         nRowsB,    /* number of rows in input B     */
    boolean_T     multiChanB,/* Boolean indicating whether B has more than 1 channel */

    creal_T       *outPtr,
    int_T         nRowsY,    /* number of rows in the output array    */
    int_T         nChansY   /* number of columns in the output array */
);

/*
 * Single Precision, Time Domain Correlation
 */
DSPCONVCORR_EXPORT void MWDSP_Corr_TD_RR(
    const real32_T  *inPtrA,
    int_T           nRowsA,    /* number of rows in input A     */
    boolean_T       multiChanA,/* Boolean indicating whether A has more than 1 channel */

    const real32_T  *inPtrB,
    int_T           nRowsB,    /* number of rows in input B     */
    boolean_T       multiChanB,/* Boolean indicating whether B has more than 1 channel */

    real32_T        *outPtr,
    int_T           nRowsY,    /* number of rows in the output array    */
    int_T           nChansY   /* number of columns in the output array */
);

DSPCONVCORR_EXPORT void MWDSP_Corr_TD_RC(
    const real32_T  *inPtrA,
    int_T           nRowsA,    /* number of rows in input A     */
    boolean_T       multiChanA,/* Boolean indicating whether A has more than 1 channel */

    const creal32_T *inPtrB,
    int_T           nRowsB,    /* number of rows in input B     */
    boolean_T       multiChanB,/* Boolean indicating whether B has more than 1 channel */

    creal32_T       *outPtr,
    int_T           nRowsY,    /* number of rows in the output array    */
    int_T           nChansY   /* number of columns in the output array */
);

DSPCONVCORR_EXPORT void MWDSP_Corr_TD_CR(
    const creal32_T *inPtrA,
    int_T           nRowsA,    /* number of rows in input A     */
    boolean_T       multiChanA,/* Boolean indicating whether A has more than 1 channel */

    const real32_T  *inPtrB,
    int_T           nRowsB,    /* number of rows in input B     */
    boolean_T       multiChanB,/* Boolean indicating whether B has more than 1 channel */

    creal32_T       *outPtr,
    int_T           nRowsY,    /* number of rows in the output array    */
    int_T           nChansY   /* number of columns in the output array */
);

DSPCONVCORR_EXPORT void MWDSP_Corr_TD_CC(
    const creal32_T *inPtrA,
    int_T           nRowsA,    /* number of rows in input A     */
    boolean_T       multiChanA,/* Boolean indicating whether A has more than 1 channel */

    const creal32_T *inPtrB,
    int_T           nRowsB,    /* number of rows in input B     */
    boolean_T       multiChanB,/* Boolean indicating whether B has more than 1 channel */

    creal32_T       *outPtr,
    int_T           nRowsY,    /* number of rows in the output array    */
    int_T           nChansY   /* number of columns in the output array */
);

#ifdef MWDSP_INLINE_DSPRTLIB
#include "dspconvcorr/conv_td_cc_rt.c"
#include "dspconvcorr/conv_td_dd_rt.c"
#include "dspconvcorr/conv_td_dz_rt.c"
#include "dspconvcorr/conv_td_rc_rt.c"
#include "dspconvcorr/conv_td_rr_rt.c"
#include "dspconvcorr/conv_td_zz_rt.c"
#include "dspconvcorr/copy_and_zpad_cc_rt.c"
#include "dspconvcorr/copy_and_zpad_dz_rt.c"
#include "dspconvcorr/copy_and_zpad_rc_rt.c"
#include "dspconvcorr/copy_and_zpad_zz_rt.c"
#include "dspconvcorr/corr_td_cc_rt.c"
#include "dspconvcorr/corr_td_cr_rt.c"
#include "dspconvcorr/corr_td_dd_rt.c"
#include "dspconvcorr/corr_td_dz_rt.c"
#include "dspconvcorr/corr_td_rc_rt.c"
#include "dspconvcorr/corr_td_rr_rt.c"
#include "dspconvcorr/corr_td_zd_rt.c"
#include "dspconvcorr/corr_td_zz_rt.c"
#endif

#ifdef __cplusplus
} // close brace for extern C from above
#endif

#endif /* dspconvcorr_rt_h */
