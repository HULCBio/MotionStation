/*=================================================================
 * mxisfinite.c 
 *
 * mxisfinite takes one input argument of type double. It returns one
 * output argument of type integer (32 bits) with equivalent values.
 * Values greater than the integer maximum or less than the integer
 * minimum are stored as INT_MAX/INT_MIN respectively.  NaNs in the
 * input argument are flagged as a warning and stored as zero.
 *
 * This is a MEX-file for MATLAB.  
 * Copyright 1984-2000 The MathWorks, Inc.
 * All rights reserved.
 *=================================================================*/
/* $Revision: 1.2 $ */
#include <limits.h>
#include "mex.h"

/* Function that converts double to int32 */
static int dtoi32(double d)
{
    int i=0;
    
    if(mxIsFinite(d)) {
	if(d < (double)INT_MAX && d > (double)INT_MIN) {
	    i = (int) d;
	} else {
	    i =  ((d > 0) ? INT_MAX : INT_MIN);
	}	    
    } else if(mxIsInf(d)) {
	i = ( (d > 0) ? INT_MAX : INT_MIN);
	/* NOTE: Test for NaN is here for illustration only.  If a double is
	   not finite and is not infinity, then it is a NaN */
    } else if(mxIsNaN(d)) {
	mexWarnMsgTxt("dtoi32: NaN detected.  Translating to 0.\n");
	i = 0;
    }
    return i;
}

void mexFunction(
		 int nlhs,       mxArray *plhs[],
                 int nrhs, const mxArray *prhs[]
		 )
{
    int i, n;
    double *pr, *pi;
    int *pri32, *pii32;
    
    
    /* Check for proper number of input and output arguments */    
    if (nrhs != 1) {
	mexErrMsgTxt("One input argument required.");
    } 
    if(nlhs > 1){
	mexErrMsgTxt("Too many output arguments.");
    }
    
    /* Check data type of input argument  */
    if (!(mxIsDouble(prhs[0]))){
	mexErrMsgTxt("Input argument must be of type double.");
    }	

    if(mxIsEmpty(prhs[0])) {
	mexWarnMsgTxt("Input argument is empty\n");
    }

    pr = mxGetPr(prhs[0]);
    pi = mxGetPi(prhs[0]);
    n = mxGetNumberOfElements(prhs[0]);

    /* Create numeric array of class mxINT32 */
    plhs[0] = mxCreateNumericArray(mxGetNumberOfDimensions(prhs[0]), mxGetDimensions(prhs[0]),
        mxINT32_CLASS, (mxIsComplex(prhs[0]) ? mxCOMPLEX : mxREAL));
    pri32 = mxGetData(plhs[0]);
    pii32 = mxGetImagData(plhs[0]);

    /* Convert each element of the real part of the input argument to
       a INT32 */
    for(i=0; i < n; i++) {
	pri32[i] = dtoi32(pr[i]);
    }
    
    /* If there is an imaginary part of the input, convert each
       element of the imaginary part of the input argument to a INT32. */
    if(pii32 != NULL) { 
	/* Initial assumption is that imaginary part might be empty */
	bool empty_image_data = true;
	for(i=0; i < n; i++) {
	    pii32[i] = dtoi32(pi[i]);
	    if(pii32[i] != 0) {
		empty_image_data = false;
	    }
	}
	/* If imaginary part is empty, free the memory and set the
           data to NULL. */
	if (empty_image_data) {
	    mxFree(pii32);
	    mxSetImagData(plhs[0], NULL);
	}
    }
}
