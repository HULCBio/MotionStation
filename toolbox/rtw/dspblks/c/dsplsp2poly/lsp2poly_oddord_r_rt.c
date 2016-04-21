/*
 *  lsp2poly_oddord_r_rt.c - Lsp2Poly block runtime helper function
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.3.2.2 $  $Date: 2004/04/12 23:46:58 $
 */

#include "dsplsp2poly_rt.h"

static void Lsp2Poly_getlsppol_R(const real32_T *lsp, real32_T *f, const int_T P)
{
    real32_T b;
    int_T i,j;

    f[0] = 1;
    f[1] = -2 * lsp[0];

    for (i = 2; i <= P/2 ; i++) {
        b = -2 * lsp[2*i - 2];
        f[i] = b * f[i - 1] + 2*f[i-2];

        for (j = (i-1) ; j > 1; j--) {
            f[j] += b*f[j-1] + f[j-2];
        }
        f[1] += b;
    }
    return;
}

EXPORT_FCN void MWDSP_Lsp2Poly_Oddord_R(const real32_T *lsp, const int_T P, real32_T *g1, real32_T *g2, real32_T *Az)
{
    int_T i,j;

    Lsp2Poly_getlsppol_R(&lsp[0], g1, P+1);
    Lsp2Poly_getlsppol_R(&lsp[1], g2, P);

    for (i = P/2; i > 1; i--) {
        g2[i] -= g2[i-2];
    }
    g2[(P+1)/2] = 0.0F;


    Az[0] = 1.0F;
    for (i = 1, j = P; i <= P/2; i++, j--) {
        Az[i] = 0.5F * (g1[i] + g2[i]);
        Az[j] = 0.5F * (g1[i] - g2[i]);
    }
    Az[(P+1)/2] = 0.5F * g1[(P+1)/2];
}

/* [EOF] lsp2poly_oddord_r_rt.c */
