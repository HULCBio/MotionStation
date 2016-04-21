/*
 *  lsp2poly_oddord_d_rt.c - Lsp2Poly block runtime helper function
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.2.2.2 $  $Date: 2004/04/12 23:46:57 $
 */

#include "dsplsp2poly_rt.h"

static void Lsp2Poly_getlsppol_D(const real_T *lsp, real_T *f, const int_T P)
{
    real_T b;
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


EXPORT_FCN void MWDSP_Lsp2Poly_Oddord_D(const real_T *lsp, const int_T P, real_T *g1, real_T *g2, real_T *Az)
{
    int_T i,j;

    Lsp2Poly_getlsppol_D(&lsp[0], g1, P+1);
    Lsp2Poly_getlsppol_D(&lsp[1], g2, P);

    for (i = P/2; i > 1; i--) {
        g2[i] -= g2[i-2];
    }
    g2[(P+1)/2] = 0;


    Az[0] = 1;
    for (i = 1, j = P; i <= P/2; i++, j--) {
        Az[i] = 0.5 * (g1[i] + g2[i]);
        Az[j] = 0.5 * (g1[i] - g2[i]);
    }
    Az[(P+1)/2] = 0.5 * g1[(P+1)/2];
}

/* [EOF] lsp2poly_oddord_d_rt.c */


