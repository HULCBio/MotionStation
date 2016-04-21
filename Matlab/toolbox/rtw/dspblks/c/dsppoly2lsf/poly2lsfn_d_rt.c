/*
 *  poly2lsfn_d_rt.c - Poly2Lsf block runtime helper function
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.2.2.2 $  $Date: 2004/04/12 23:47:28 $
 */

#include "dsppoly2lsp_rt.h"

EXPORT_FCN int_T MWDSP_Poly2Lsfn_D(
        real_T      *lsp,       /* pointer to output port LSP/LSFr/LSFn */
        real_T      *G1,        /* pointer to D_work G1 */
        real_T      *G2,        /* pointer to D_Work G2 */
        const int_T NSteps,     /* Number of root search steps */
        const int_T NBisects,   /* Number of bisections for root refinement */
        const int_T M1,         /* Order of the de-convolved symmetric polynomial G1*/
        const int_T M2,         /* Order of the de-convolved symmetric polynomial G2*/
        real_T      *bptr,      /* pointer to one of the D-works, used within cheby_poly_solve */
        const int_T P           /* Order of LPC polynomial */
       )
{
    int_T nf    = MWDSP_Poly2Lsp_D(lsp,G1,G2,NSteps,NBisects,M1,M2,bptr);
    int_T i;
    for (i = 0; i < P; i++) {
        lsp[i] = acos(lsp[i])/DSP_TWO_PI;
    }
    return(nf);
}

/* [EOF] poly2lsfn_d_rt.c */
