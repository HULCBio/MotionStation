/*
 * Syntax:  c = gftrunc(a)
 * GFTRUNC Truncates redundant part of a GF(P) polynomial.
 *         It does not support coefficients in exponential format.  
 *
 * Copyright 1996-2002 The MathWorks, Inc.
 * $Revision: 1.14 $ $Date: 2002/03/27 00:08:20 $ 
 */

#include <math.h>
#ifdef MATLAB_MEX_FILE
#include "mex.h"
#endif

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
	int     len_a, len_c, ma, na, i;
	double  *pa, *pc;

	for (i=0; i < nrhs; i++){
		if (mxIsChar(prhs[i]))
			mexErrMsgTxt("String is not correct input type."); 
	}
	if ( nrhs < 1 ){
		mexErrMsgTxt("Not enough input arguments.");
		return;
	}
	if ( nrhs > 1 ){
		mexErrMsgTxt("Too many input arguments.");
		return;
	}
	
	pa = mxGetPr(prhs[0]);
    ma = mxGetM(prhs[0]);
    na = mxGetN(prhs[0]);
	len_a = ma*na;
    
    if (ma > 1)
        mexErrMsgTxt("The input must be a row vector.");

	for (i=0; i < len_a; i++){
	    if ( pa[i] != floor(pa[i]) || pa[i]<0  )
            mexErrMsgTxt("The polynomial coefficients must be nonnegative integers.");
	}
		
	len_c = 1;
	for (i=1; i < len_a; i++){
    	if (pa[i]> 0) len_c = i+1;
	}
	
	if (len_a !=0){
		pc = mxGetPr(plhs[0] = mxCreateDoubleMatrix(1, len_c, mxREAL));
        for(i=0; i < len_c; i++)
			pc[i] = pa[i];
	}
	else
		pc = mxGetPr(plhs[0] = mxCreateDoubleMatrix(mxGetM(prhs[0]), mxGetN(prhs[0]), mxREAL));
	
	return;
}

/* [EOF] */
