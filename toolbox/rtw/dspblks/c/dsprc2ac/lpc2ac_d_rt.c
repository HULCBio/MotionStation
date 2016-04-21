/*
 *  lpc2ac_d_rt.c - Linear Prediction Polynomial (LPC) to autocorrelation sequence
 *  conversion block runtime helper function
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.2.4.2 $  $Date: 2004/04/12 23:48:45 $
 */

#include "dsprc2ac_rt.h"
EXPORT_FCN void MWDSP_Lpc2Ac_D(
        const real_T *lpc,     /* pointer to input port which points to LP coefficients */
        const real_T *perr,    /* pointer to input port pointing to prediction error */
        real_T       *ac,      /* pointer to output port pointing to the autocorrelation coefficients */
        real_T       *L,       /* Vector L which contains LPC of order 1 ... M , padded with zeros. */ 
        const int_T   M        /* Order of LPC polynomial */
       )
{
    int_T i,p, M1 = M+1, tmp = M1*M;
    real_T rc, E;

    /* Place the Mth order LPC polynomial at the end of the vector L in a reversed way.
     * For a 3rd order LPC poly. as the input , we have
     * L = [ 0 0 0 0 , 0 0 0 0. 0 0 0 0 , A(3,3) A(3,2) A(3,1) 1]
     */
    for (i = 0; i<=M; i++)
        L[tmp+i]  = lpc[M-i];

    /* Compute 1st, 2nd, 3rd, ...(M-1)th order LPC polynomial and put them
     * in a sequence (flipped) in the L vector. 
     * e.g.:- For a 3rd order LPC polynomial, we have L vector of the kind:-
     * L = [1 0 0 0 , A(1,1) 1 0 0,  A(2,2) A(2,1) 1 0 , A(3,3) A(3,2) A(3,1) 1];
     */
    for (p = M; p>=1; p--) {
        int_T indx = M1*p;
        rc = -L[indx];
        E = 1 - rc*rc;
        for (i=0; i<(p-1); i++) 
            L[indx-M1+i] = (L[indx+i+1] + rc * L[indx+p-1-i])/E;
        L[indx-M1+(p-1)] = 1;
    }

    /* Calculate Autcorrelation with zero lag (AC(0)), using the formula
     * AC(0) = Perr/( (1 - RC(1)^2) * (1 - RC(2)^2) * (1 - RC(3)^2) )
     * where Perr = Prediction error for the input LPC polynomial
     *       RC(i) = - A(i,i) = ith reflection coefficient
     */
    for (ac[0] = *perr, p = 1; p <= M; p++)
        ac[0] /= (1 - L[M1*p]*L[M1*p]);
    /* Other autocorrelation coefficients are found using the following formula
     *            p
     * AC(p) = - Sum A(p,i)*AC(p-i)   for p = 1, 2, 3 where 3 is the order of input LPC. 
     *           i=1
     */          
    for (p = 1; p <= M; p++) {
        for (ac[p]=0, i = 0; i<p; i++)
            ac[p] -= L[M1*p+i]*ac[i];
    }
    
}

/* [EOF] lpc2ac_d_rt.c */
