/*
 *  poly2lsp_r_rt.c - Poly2Lsf block runtime helper function
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.3.2.2 $  $Date: 2004/04/12 23:47:33 $
 */

#include "dsppoly2lsp_rt.h"

static real32_T MWDSP_Poly2Lsp_chebysolve_R(real32_T *b, real32_T x, real32_T *f, int_T N)
{
    real32_T returnval;
    int_T k;
    b[N] = 0;
    b[N-1] = 1;
    for (k = N-2; k >= 0; k--) {
        b[k] = 2*x*b[k+1] - b[k+2] + f[N-k-1];
    }
    returnval = x*b[0] - b[1] + f[N]/2;
    return returnval;
}


EXPORT_FCN int_T MWDSP_Poly2Lsp_R(
        real32_T      *lsp,       /* pointer to output port LSP/LSFr/LSFn */
        real32_T      *G1,        /* pointer to D_work G1 */
        real32_T      *G2,        /* pointer to D_Work G2 */
        const int_T    NSteps,    /* Number of root search steps */
        const int_T    NBisects,  /* Number of bisections for root refinement */
        const int_T    M1,        /* Order of the de-convolved symmetric polynomial G1*/
        const int_T    M2,        /* Order of the de-convolved symmetric polynomial G2*/
        real32_T      *bptr       /* pointer to one of the D-works, used within cheby_poly_solve */
       )

{
    int_T    nf   = 0;   /* number of found frequencies */
    int_T    ip   = 0;   /* indicator for f1 or f2      */
    int_T    indx = 0;
    real32_T j    = 1;
    real32_T *coef= G1;
    const real32_T delta  = (real32_T)(2.0 / (real32_T)NSteps);
    real32_T xlow, ylow;

    xlow = 1;
    ylow = MWDSP_Poly2Lsp_chebysolve_R(bptr, xlow, coef, M1);
    while ( (nf < 2*M1) && (indx < NSteps) )
    {
        real32_T xhigh, yhigh, temp;
        j    -= delta;
        indx += 1;
        xhigh = xlow;
        yhigh = ylow;
        xlow  = j;
        ylow  = (ip == 0) ? MWDSP_Poly2Lsp_chebysolve_R(bptr,xlow, coef,M1) : MWDSP_Poly2Lsp_chebysolve_R(bptr,xlow, coef, M2);
        temp  = ylow*yhigh;
        if (temp < 0) {
            /* this indicates that there exists a root between xlow and xhigh
             * sub-divide this interval futher and find out exact root
             */
            int_T i;
            real32_T xint;
            for (i = 0; i < NBisects; i++) {
                real32_T xmid = (xlow + xhigh)/2;
                real32_T ymid = (ip == 0) ? MWDSP_Poly2Lsp_chebysolve_R(bptr,xmid, coef, M1) : MWDSP_Poly2Lsp_chebysolve_R(bptr,xmid, coef, M2);
                real32_T temp1 = ylow*ymid;
                if (temp1 <= 0) {
                    yhigh = ymid;
                    xhigh = xmid;
                }
                else {
                    ylow = ymid;
                    xlow = xmid;
                }
            }
            /*-------------------------------------------------------------*
             * Linear interpolation                                        *
             *    xint = xlow - ylow*(xhigh-xlow)/(yhigh-ylow);            *
             *-------------------------------------------------------------*/
            if ((yhigh - ylow) == 0) {
                xint = xlow;
            } else {
                xint = xlow - ylow*((xhigh-xlow)/(yhigh - ylow));
            }
            lsp[nf] = xint;
            nf++;
            xlow    = xint;
            if (ip == 0) {
                ip = 1;
                coef = G2;
            } else {
                ip = 0;
                coef = G1;
            }
            ylow = (ip == 0) ? MWDSP_Poly2Lsp_chebysolve_R(bptr,xlow, coef, M1) : MWDSP_Poly2Lsp_chebysolve_R(bptr,xlow, coef, M2);
        }
    }
    return(nf);
}


/* [EOF] poly2lsp_r_rt.c */

