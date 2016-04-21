/*
 * Syntax:  C = gfconv(A, B, P)
 *
 * GFCONV Polynomial convolution in GF(P) or GF(P^M).
 *   A, B are row vector polynomials (can be of unequal sizes).
 *   P is a prime scalar (for GF(P)) or a matrix (for GF(P^M)).
 *   When P is a scalar, A, B, C are vectors in coefficient polynomial
 *   format, else they are in exponential format.
 * 
 * Copyright 1996-2002 The MathWorks, Inc.
 * $Revision: 1.16 $ $Date: 2002/03/27 00:07:17 $
 */
 
#include "gflib.h"

void mexFunction(int_T nlhs, mxArray *plhs[], int_T nrhs, const mxArray *prhs[])
{
    int_T     ma, na, mb, nb, nc, mp, np, len_a, len_b, len_p, i, j, k;
    int_T     *paa, *pbb, *pp, *pcc, *Iwork;
    double  *pa, *pb, *p, *pc;
    
	/* Check inputs */
    for ( i=0; i < nrhs; i++ ){
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
	    mp = mxGetM(prhs[2]);
	    np = mxGetN(prhs[2]);
    }else if (nrhs > 3){
        mexErrMsgTxt("Too many input arguments.");
    }

    /* Get input arguments */
    pa = mxGetPr(prhs[0]);
    pb = mxGetPr(prhs[1]);
    ma = mxGetM(prhs[0]);
    na = mxGetN(prhs[0]);
    mb = mxGetM(prhs[1]);
    nb = mxGetN(prhs[1]);
    len_a = ma*na;
    len_b = mb*nb;
	len_p = mp*np;

	/* Validate inputs */
	if ( (ma != 1) || (mb != 1) )
    	mexErrMsgTxt("The input polynomials must be row vectors.");
    if ( (mp == 1) && (np != 1) ) 
        mexErrMsgTxt("The field parameter must either be a scalar or a matrix.");

    gfargchk(pa, ma, na, pb, mb, nb, p, mp, np);
    
    /* Input variable type conversion */
    paa = (int_T *)mxCalloc(len_a, sizeof(int_T));
    pbb = (int_T *)mxCalloc(len_b, sizeof(int_T));
    pp  = (int_T *)mxCalloc(len_p, sizeof(int_T));
    for (i=0; i < len_a; i++) {
        if (pa[i]<0){
            paa[i] = -1;
        } else {
            paa[i] = (int_T) pa[i];
        }
    }
    for (i=0; i < len_b; i++) {
        if (pb[i]<0){
            pbb[i] = -1;
        } else {
            pbb[i] = (int_T) pb[i];
        }
    }
	for (i=0; i < len_p; i++)
	    pp[i] = (int_T) p[i];
    
    /* Truncate inputs */
    gftrunc(paa,&len_a,len_p); 
    gftrunc(pbb,&len_b,len_p); 
    
    /* Computation */    
    nc = len_a+len_b-1;
    pcc = (int_T *)mxCalloc(nc, sizeof(int_T));
    if (len_p == 1){ /* GF(P) */
	    /* call gfconv() in gflib.c */
	    Iwork = (int_T *)mxCalloc(nc+1, sizeof(int_T));        
	    gfconv(paa, len_a, pbb, len_b, *pp, pcc, Iwork);
    } else { /* GF(P^M)*/
    	/* call gfpconv() in gflib.c */
	    Iwork = (int_T *)mxCalloc(5+3*(mp+np), sizeof(int_T));        
	    gfpconv(paa, len_a, pbb, len_b, pp, mp, np, pcc, Iwork);
    }

    /* Output variable type conversion */
    pc = mxGetPr(plhs[0]=mxCreateDoubleMatrix(1, nc, mxREAL));
    for(i=0; i < nc; i++){
	    if(pcc[i] < 0) {
	        pc[i] = -mxGetInf();
	    } else {
	        pc[i] = (double)pcc[i];
        }
    }
    
    return;
}

/*[EOF]*/
