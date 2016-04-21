/*
 * Syntax:  [Q, R] = gfdeconv(B, A, P)
 *
 * GFDECONV Polynomial deconvolution in GF(P) or GF(P^M).
 *   A, B are row vector polynomials (can be of unequal sizes).
 *   P is a prime scalar (for GF(P)) or a matrix (for GF(P^M)).
 *   When P is a scalar, A, B, Q, R are vectors in coefficient polynomial
 *   format, else they are in exponential format.
 * 
 * Copyright 1996-2002 The MathWorks, Inc.
 * $Revision: 1.16 $ $Date: 2002/03/27 00:07:26 $
 */

#include "gflib.h"

void mexFunction(int_T nlhs, mxArray *plhs[], int_T nrhs, const mxArray *prhs[])
{
    int_T     mb, nb, ma, na, mp, np, len_b, len_a, len_p, len_q, len_r, i;
    int_T     *pbb, *paa, *pp, *pqq, *prr, *Iwork;
    double  *pb, *pa, *p, *pq, *pr;

	/* Check inputs */
    for (i=0; i < nrhs; i++){
       	if ( mxIsChar(prhs[i]) || mxIsEmpty(prhs[i]) || mxIsComplex(prhs[i]) )
	        mexErrMsgTxt("Invalid input arguments."); 
    }
    if ( nrhs < 2 ){
    	mexErrMsgTxt("Not enough input arguments.");
    }else if ( nrhs == 2 ){
        p = (double *)mxCalloc(1, sizeof(double));
        p[0] = 2;
    	mp = 1;
    	np = 1;
    }else if ( nrhs == 3 ){
	    p = mxGetPr(prhs[2]);
	    mp= mxGetM(prhs[2]);
	    np= mxGetN(prhs[2]);
    }else if (nrhs > 3){
        mexErrMsgTxt("Too many input arguments.");
    }
    
    /* Get input arguments */
    pb = mxGetPr(prhs[0]);
    pa = mxGetPr(prhs[1]);
    mb = mxGetM(prhs[0]);
    nb = mxGetN(prhs[0]);
    ma = mxGetM(prhs[1]);
    na = mxGetN(prhs[1]);
    len_b = mb*nb;
    len_a = ma*na;
    len_p = mp*np;

	/* Validate inputs */
	if ( (mb != 1) || (ma != 1) )
    	mexErrMsgTxt("The input polynomials must be row vectors.");
    if ( (mp == 1) && (np != 1) ) 
        mexErrMsgTxt("The field parameter must either be a scalar or a matrix.");

    gfargchk(pb, mb, nb, pa, ma, na, p, mp, np);
    
    /* Input variable type conversion */
    pbb = (int_T *)mxCalloc(len_b, sizeof(int_T));
    paa = (int_T *)mxCalloc(len_a, sizeof(int_T));
    pp  = (int_T *)mxCalloc(len_p, sizeof(int_T));
    for (i=0; i < len_b; i++) {
        if (pb[i]<0) {
            pbb[i] = -1;
        } else {
            pbb[i] = (int_T) pb[i];
        }
    }
    for (i=0; i < len_a; i++) {
        if (pa[i]<0) {
            paa[i] = -1;
        } else {
            paa[i] = (int_T) pa[i];
        }
    }
	for (i=0; i < len_p; i++)
	    pp[i] = (int_T) p[i];

    /* Truncate inputs */
    gftrunc(pbb, &len_b, len_p);
    gftrunc(paa, &len_a, len_p); 
    
    /* Computation */
    if(len_a > len_b){ /* trivial case */

    	len_q = 1;
	    len_r = len_b;

	    pqq = (int_T *)mxCalloc(len_q, sizeof(int_T));
	    prr = (int_T *)mxCalloc(len_r, sizeof(int_T));

	    if (len_p == 1){ /* GF(P) */	
    	    pqq[0] = 0;
    	} else { /* GF(P^M)*/
    	    pqq[0] = -1;
    	}
    	    
	    for(i=0; i<len_r; i++)
	        prr[i] = pbb[i];

    }else{ /* typical case */

    	len_q = len_b - len_a + 1;
	    len_r = len_b;

    	pqq = (int_T *)mxCalloc(len_q, sizeof(int_T));
	    prr = (int_T *)mxCalloc(len_r, sizeof(int_T));

	    if (len_p == 1){ /* GF(P) */
	        Iwork = (int_T *)mxCalloc(2*len_b+2, sizeof(int_T));
	        /* call gfdeconv() in gflib.c */
	        gfdeconv(pbb, len_b, paa, len_a, *pp, pqq, len_q, prr, &len_r, Iwork);
	    } else { /* GF(P^M)*/
	        Iwork = (int_T *)mxCalloc(3*np+1, sizeof(int_T));
	        /* call gfpdeconv() in gflib.c */
	        gfpdeconv(pbb, len_b, paa, len_a, pp, mp, np, pqq, prr, &len_r, Iwork);
	    }
    }

    /* Output variable type conversion */
    pq = mxGetPr(plhs[0]=mxCreateDoubleMatrix(1, len_q, mxREAL));
    for(i=0; i < len_q; i++) {
    	if (pqq[i] < 0) { 
	        pq[i] = -mxGetInf();
	    } else {
	        pq[i] = (double)pqq[i];
        }
    }
    pr = mxGetPr(plhs[1]=mxCreateDoubleMatrix(1, len_r, mxREAL));
    for(i=0; i < len_r; i++) {
	    if (prr[i] < 0) {
	        pr[i] = -mxGetInf();
	    } else {
	        pr[i] = (double)prr[i];
        }
    }
    
    return;
}

/*[EOF]*/
