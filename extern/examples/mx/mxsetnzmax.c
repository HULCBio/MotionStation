/*=================================================================
 * mxsetnzmax.c 
 *
 * mxsetnzmax takes a sparse matrix for an input. If the actual number
 * of non-zeros is not equal to the non-zero maximum for this sparse
 * matrix, it re-allocates the smaller amount of memory for the
 * sparse matrix. It then resets the values of pr, pi,ir and nzmax.
 *
 * This is a MEX-file for MATLAB.  
 * Copyright 1984-2000 The MathWorks, Inc.
 * All rights reserved.
 *=================================================================*/

#include "mex.h"

void mexFunction(
                 int nlhs,       mxArray *plhs[],
                 int nrhs, const mxArray *prhs[]
		 )
{
    int actual_number_of_non_zeros;
   
    /* Check for proper number of input and output arguments */    
    if (nrhs != 1) {
        mexErrMsgTxt("One input argument required.");
    } 
    if(nlhs > 1){
        mexErrMsgTxt("Too many output arguments.");
    }
        
    if(!mxIsSparse(prhs[0])) {
	mexErrMsgTxt("Input argument must be sparse\n");
    }
    plhs[0] = mxDuplicateArray(prhs[0]);
    actual_number_of_non_zeros = mxGetJc(plhs[0])[mxGetN(plhs[0])];
    if(mxGetNzmax(plhs[0]) == actual_number_of_non_zeros) {
	mexWarnMsgTxt("The actual number of non-zeros is already equal to the non-zero maximum for this sparse matrix.\n");
    } else {
	
	double *ptr;
	void *newptr;
	int *ir;
	int nbytes;

	nbytes = actual_number_of_non_zeros * sizeof(*ptr);
	ptr = mxGetPr(plhs[0]);
	newptr = mxRealloc(ptr, nbytes);
	mxSetPr(plhs[0], newptr);
	ptr = mxGetPi(plhs[0]);
	if(ptr != NULL) {
	    newptr = mxRealloc(ptr, nbytes);
	    mxSetPi(plhs[0], newptr);
	}
	nbytes = actual_number_of_non_zeros * sizeof(*ir);
	ir = mxGetIr(plhs[0]);
	newptr = mxRealloc(ir, nbytes);
	mxSetIr(plhs[0], newptr);
	mxSetNzmax(plhs[0],actual_number_of_non_zeros);
    }
}
