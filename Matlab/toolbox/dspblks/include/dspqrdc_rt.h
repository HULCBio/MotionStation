/*
 *  dspqrdc_rt.h - DSP Blockset QR Factorization Run Time Functions
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.6.4.2 $ $Date: 2004/04/12 23:12:10 $
 */

#ifndef dspqrdc_rt_h
#define dspqrdc_rt_h

#include "dsp_rt.h"

#ifdef DSPQRDC_EXPORTS
#define DSPQRDC_EXPORT EXPORT_FCN
#else
#define DSPQRDC_EXPORT MWDSP_IDECL
#endif

/* Run-time functions for QR Factorization block */
DSPQRDC_EXPORT void MWDSP_QRE_D(int_T m, int_T n, real_T *q, real_T *r, real_T *e,
                  real_T *qraux, real_T *work, int_T *jpvt, real_T *s);
DSPQRDC_EXPORT void MWDSP_QRE_R(int_T m, int_T n, real32_T *q, real32_T *r, real32_T *e,
                  real32_T *qraux, real32_T *work, int_T *jpvt, real32_T *s);
DSPQRDC_EXPORT void MWDSP_QRE_C(int_T m, int_T n, creal32_T *q, creal32_T *r, real32_T *e,
                  creal32_T *qraux, creal32_T *work, int_T *jpvt, creal32_T *s);
DSPQRDC_EXPORT void MWDSP_QRE_Z(int_T m, int_T n, creal_T *q, creal_T *r, real_T *e,
                  creal_T *qraux, creal_T *work, int_T *jpvt, creal_T *s);

/* The following are the run-time functions used in QR Solver block */
DSPQRDC_EXPORT void MWDSP_qreslvD(int_T	m, int_T n, int_T p, real_T *qr, real_T *bx,
                          real_T *qraux, int_T *jpvt, real_T *x, real_T eps);
DSPQRDC_EXPORT void MWDSP_qreslvZ(int_T m, int_T n, int_T p, creal_T *qr,creal_T *bx,
                          creal_T *qraux,int_T *jpvt,creal_T *x, real_T eps);
DSPQRDC_EXPORT void MWDSP_qreslvR(int_T m, int_T n, int_T p, real32_T *qr, real32_T	*bx,
                          real32_T *qraux, int_T *jpvt, real32_T *x,real32_T eps);
DSPQRDC_EXPORT void MWDSP_qreslvC(int_T m, int_T n, int_T p, creal32_T *qr, creal32_T *bx,
                          creal32_T *qraux, int_T *jpvt, creal32_T *x, real32_T eps);
DSPQRDC_EXPORT void MWDSP_qreslvMixdZ(int_T m, int_T n, int_T p, real_T *qr, creal_T *bx,
                             real_T	*qraux, int_T *jpvt, creal_T *x, real_T eps);
DSPQRDC_EXPORT void MWDSP_qreslvMixdC(int_T m, int_T n, int_T p, real32_T *qr, creal32_T *bx,
                              real32_T *qraux, int_T *jpvt, creal32_T *x, real32_T eps);


/* Common run-time functions used by both QR Factorization and QR Solver */

/*
 * dspcompqy - compute q*y or q'*y in place over y 
 * Datatype - D -> Double precision real
 *            R -> Single precision real
 *            Z -> Double precision complex
 *            C -> Single precision complex
 *        MixdZ -> Both real and complex Double precision variables used in this function.
 *        MixdC -> Both real and complex Single precision variables used in this function.
 */
DSPQRDC_EXPORT void MWDSP_qrCompqyD(int_T n, int_T j, real_T *qr, real_T *qrauxj, real_T *y);
DSPQRDC_EXPORT void MWDSP_qrCompqyR(int_T n, int_T j, real32_T *qr, real32_T *qrauxj, real32_T *y);
DSPQRDC_EXPORT void MWDSP_qrCompqyZ(int_T n, int_T j, creal_T *qr, creal_T *qrauxj, creal_T *y);
DSPQRDC_EXPORT void MWDSP_qrCompqyC(int_T n, int_T j, creal32_T *qr, creal32_T *qrauxj, creal32_T *y);
DSPQRDC_EXPORT void MWDSP_qrCompqyMixdZ(int_T n, int_T j, real_T *qr, real_T *qrauxj, creal_T *y);
DSPQRDC_EXPORT void MWDSP_qrCompqyMixdC(int_T n, int_T j, real32_T *qr, real32_T *qrauxj, creal32_T *y);

/*
 * Compute the qr factorization of an m by n matrix x.
 * Information needed for the orthogonal matrix q is
 * overwritten in the lower triangle of x and in the
 * auxilliary array qraux.
 * r overwrites the upper triangle of x and its diagonal
 * entries are guaranteed to decrease in magnitude.
 * Column pivot information is stored in jpvt.
 * Datatypes - D -> Double precision real
 *             R -> Single precision real
 *             Z -> Double precision complex
 *             C -> Single precision complex
 */
DSPQRDC_EXPORT void MWDSP_qrdcD(int_T m, int_T	n, real_T *x, real_T *qraux, int_T *jpvt, real_T *work);
DSPQRDC_EXPORT void MWDSP_qrdcR(int_T m, int_T	n, real32_T *x, real32_T *qraux, int_T *jpvt, real32_T *work);
DSPQRDC_EXPORT void MWDSP_qrdcC(int_T m, int_T	n, creal32_T *x, creal32_T *qraux, int_T *jpvt, creal32_T *work);
DSPQRDC_EXPORT void MWDSP_qrdcZ(int_T m, int_T	n, creal_T *x, creal_T *qraux, int_T *jpvt, creal_T *work);


#endif /* dspqrdc_rt_h */

/* [EOF] dspqrdc_rt.c */
