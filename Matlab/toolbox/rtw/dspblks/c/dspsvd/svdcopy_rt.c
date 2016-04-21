/* $Revision: 1.2.2.4 $ */
/* 
 * SVDCOPY_RT - Signal Processing Blockset Singular Value Decomposition run-time helper functions
 *
 *  Copyright 1995-2004 The MathWorks, Inc.
 *
 * Abstract:
 *   Copies or transform copies source to dest
 *   Copies from temporary space to output
 */

#include "dspsvd_rt.h"

#define MWDSP_SVD_COPYGEN_REAL                          \
    int_T MN = M*N;                                     \
    if (M >= N) {                                       \
        /* Matrix is tall and skinny, copy as is. */    \
        while(MN--)                                     \
            *pX++ = *pA++;                              \
    }                                                   \
    else {                                              \
        /* Matrix is short and fat, so transpose it. */ \
        int i,j;                                        \
        for (i=0; i<M; i++)                             \
            for (j=0; j<N; j++)                         \
                *pX++ = *(pA + i + j*M);                \
    }


#define MWDSP_SVD_COPYGEN_CPLX                          \
    int_T MN = M*N;                                     \
    if (M >= N) {                                       \
        /* Matrix is tall and skinny, copy as is. */    \
        while(MN--)                                     \
            *pX++ = *pA++;                              \
    }                                                   \
    else {                                              \
        /* Matrix is short and fat, so transpose it. */ \
        int i,j;                                        \
        for (i=0; i<M; i++)                             \
            for (j=0; j<N; j++) {                       \
                /* HERMITIAN trans-> neg imag part */   \
                *pX = *(pA + i + j*M);                  \
                pX->im = -(pX->im);                     \
                pX++;                                   \
            }                                           \
    }


EXPORT_FCN void MWDSP_SVD_Copy_Z(const creal_T *pA, creal_T *pX, const int_T M, const int_T N)
{
    MWDSP_SVD_COPYGEN_CPLX
}


EXPORT_FCN void MWDSP_SVD_Copy_D(const real_T *pA, real_T *pX, const int_T M, const int_T N)
{
    MWDSP_SVD_COPYGEN_REAL
}


EXPORT_FCN void MWDSP_SVD_Copy_C(const creal32_T *pA, creal32_T *pX, const int_T M, const int_T N)
{
    MWDSP_SVD_COPYGEN_CPLX
}


EXPORT_FCN void MWDSP_SVD_Copy_R(const real32_T *pA, real32_T *pX, const int_T M, const int_T N)
{
    MWDSP_SVD_COPYGEN_REAL
}


EXPORT_FCN void MWDSP_SVD_CopyOutput_Z(real_T *pOS, creal_T *pS, int_T P)
{
    while(P--) {
        *pOS++ = pS->re;
        pS++;
    }
}


EXPORT_FCN void MWDSP_SVD_CopyOutput_D(real_T *pOS, real_T *pS, int_T P)
{
    while(P--)
        *pOS++ = *pS++;
}


EXPORT_FCN void MWDSP_SVD_CopyOutput_C(real32_T *pOS, creal32_T *pS, int_T P)
{
    while(P--) {
        *pOS++ = pS->re;
        pS++;
    }
}


EXPORT_FCN void MWDSP_SVD_CopyOutput_R(real32_T *pOS, real32_T *pS, int_T P)
{
    while(P--) 
        *pOS++ = *pS++;
}

/* [EOF] svdcopy_rt.c */
