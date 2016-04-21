/*=================================================================
 * mxgetinf.c 
 *
 * mxgetinf takes one input argument of type double floating
 * integers.  For this example, zero values are used to indicate missing
 * data.  It replaces all zeros with NaN.  Values greater than equal to
 * INT_MAX are replaced with infinity.  Values less than or equal to
 * INT_MIN are replaced with minus infinity.  mxgetinf returns the data
 * with the replaced values.
 *
 * This is a MEX-file for MATLAB.  
 * Copyright 1984-2000 The MathWorks, Inc.
 * All rights reserved.
 *=================================================================*/
/* $Revision: 1.4 $ */

#include <limits.h>
#include "mex.h"

void 
mexFunction( int nlhs, mxArray *plhs[],  int nrhs, const mxArray *prhs[])
{
    int i, n;
    double *pr, *pi;
    double inf, nan;
    
    /* Check for proper number of input and output arguments */    
    if (nrhs != 1) {
	mexErrMsgTxt("One input argument required.");
    } 
    if(nlhs > 1){
	mexErrMsgTxt("Too many output arguments.");
    }
    
    /* Check data type of input argument  */
    if (!mxIsDouble(prhs[0]) || mxIsComplex(prhs[0])) {
	mexErrMsgTxt("Input argument must be of type real double.");
    }	
    
    /* Duplicate input array */
    plhs[0]=mxDuplicateArray(prhs[0]);
    
    pr = mxGetPr(plhs[0]);
    pi = mxGetPi(plhs[0]);
    n = mxGetNumberOfElements(plhs[0]);
    inf = mxGetInf();
    nan=mxGetNaN();

    /* Check for 0, in real part of data, if the data is zero, replace
       with NaN.  Also check for INT_MAX and INT_MIN and replace with
       INF/-INF respectively.  */
    for(i=0; i < n; i++) {
	if (pr[i] == 0){
	    pr[i]=nan;
	}
	else if ( pr[i]>= INT_MAX){
	    pr[i]=inf;
	}
	else if (pr[i]<= INT_MIN){
	    pr[i]=-(inf);
	}
    }
}





