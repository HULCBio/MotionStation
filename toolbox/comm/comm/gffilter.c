/*
 * Syntax:  y = gffilter(b, a, x, p)
 * GFFILTER GF(P) polynomial filter computation.
 *   Y = FILTER(B, A, X) filters the data in vector X with the
 *   filter described by vectors B and A to create the filtered
 *   data Y in GF(2).
 *
 *   Y = FILTER(B, A, X, P) filters the data in GF(P).
 *
 * Copyright 1996-2002 The MathWorks, Inc.
 * $Revision: 1.15 $ $Date: 2002/03/27 00:07:35 $
 */
 
#include "gflib.h"

void mexFunction(int_T nlhs, mxArray *plhs[], int_T nrhs, const mxArray *prhs[])
{
    int_T     mb, nb, ma, na, mx, nx, len_b, len_a, len_x, p, i;
    int_T     *pxx, *pyy, *pbb, *paa;
    double  *pb, *pa, *px, *py;
    double  pp;

	/* Check inputs */    
    for (i=0; i < nrhs; i++){
        if ( mxIsChar(prhs[i]) || mxIsEmpty(prhs[i]) || mxIsComplex(prhs[i]) )      
            mexErrMsgTxt("Invalid input arguments."); 
    }
    if ( nrhs < 3 ){
	    mexErrMsgTxt("Not enough input arguments.");
    } else if ( nrhs == 3 ){
    	pp = 2;
    } else if ( nrhs == 4 ){
	    pp = mxGetScalar(prhs[3]);
    } else if (nrhs > 4){
        mexErrMsgTxt("Too many input arguments.");
    }
    
    pb = mxGetPr(prhs[0]);
    pa = mxGetPr(prhs[1]);
    px = mxGetPr(prhs[2]);    
    mb = mxGetM(prhs[0]);
    nb = mxGetN(prhs[0]);
    ma = mxGetM(prhs[1]);
    na = mxGetN(prhs[1]);
    mx = mxGetM(prhs[2]);
    nx = mxGetN(prhs[2]);
    
    /* variable assignment. */
    len_b = mb*nb;
    len_a = ma*na;   	
    len_x = mx*nx;
    
    /* Validate inputs */
    if ( (mb >1) || (ma >1) || (mx >1) )
        mexErrMsgTxt("The input arguments must be row vectors.");
        
    gfargchk(pb, mb, nb, pa, ma, na, &pp, 1, 1);

    for (i=0; i < len_x; i++){
	    if (px[i] < 0 || px[i] != floor(px[i]) || px[i] >= pp){
    	    if (pp==2) {
    	        mexErrMsgTxt("The input data must be binary.");
            } else {
	            mexErrMsgTxt("The input data must be integers between 0 and P-1.");
            }
        }
    }
    
    /* Input variable type conversion */
    pbb = (int_T *)mxCalloc(len_b, sizeof(int_T));
    paa = (int_T *)mxCalloc(len_a, sizeof(int_T));
    pxx = (int_T *)mxCalloc(len_x, sizeof(int_T));
    for (i=0; i < len_b; i++)
        pbb[i] = (int_T) pb[i];        
    for (i=0; i < len_a; i++)
        paa[i] = (int_T) pa[i];
    for (i=0; i < len_x; i++)
        pxx[i] = (int_T) px[i];
    p = (int_T) pp;
    
    /* Truncate input */
    gftrunc(pbb, &len_b, 1); 
    gftrunc(paa, &len_a, 1); 
    
    /* assign (int_T *)pyy for output */
    pyy = (int_T *)mxCalloc(len_x, sizeof(int_T));

    /* call function gffilter() in gflib.c */
    gffilter(pbb, len_b, paa, len_a, pxx, len_x, p, pyy);
    
    /* Output variable type conversion */
    py = mxGetPr(plhs[0] = mxCreateDoubleMatrix(1, len_x, mxREAL));
    for (i=0; i < len_x; i++)
        py[i] = (double)pyy[i];
    
    return;
}

/* [EOF] */
