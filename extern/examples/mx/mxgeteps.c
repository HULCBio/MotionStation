/*=================================================================
 * mxgeteps.c 
 *
 * This is an example of how to use mxGetEps.  The function takes two
 * real double arrays and does an element-by-element compare of each
 * element for equality within eps. Eps is the distance from 1.0 to
 * the next largest floating point number and is used as the default
 * tolerance.  If all the elements are equal within eps, a 1 is returned.
 * If they are not all equal within eps, a 0 is returned.
 *
 * This is a MEX-file for MATLAB.  
 * Copyright 1984-2000 The MathWorks, Inc.
 * All rights reserved.
 *=================================================================*/
 /* $Revision: 1.2 $ */

#include "mex.h"
#include <math.h>

void
mexFunction(int nlhs,mxArray *plhs[],int nrhs,const mxArray *prhs[])
{
    
    const int  *dims_first, *dims_second;
    int c, elements, j;
    double *first_ptr, *second_ptr, eps;
    
    /* Check for proper number of input and output arguments */    
    if (nrhs != 2) {
	mexErrMsgTxt("Two input arguments required.");
    } 
    if (nlhs > 1) {
	mexErrMsgTxt("Too many output arguments.");
    }
    
    /* Check data type of first input argument */
    if (!mxIsDouble(prhs[0]) || !mxIsDouble(prhs[1]) 
	|| mxIsComplex(prhs[0]) ||mxIsComplex(prhs[1])) {
	mexErrMsgTxt("Input arguments must be real of type double.");
    }
    
    /* Check that dimensions are the same for input arguments. */
    if ( mxGetNumberOfDimensions(prhs[0]) != mxGetNumberOfDimensions(prhs[1])){
	mexErrMsgTxt("Inputs must have the same number of dimensions.\n");
    }

    dims_first = mxGetDimensions(prhs[0]);
    dims_second = mxGetDimensions(prhs[1]);
    
    /* Check that inputs have the same dimensions. */
    for (c=0; c<mxGetNumberOfDimensions(prhs[0]); c++){
	if (dims_first[c]!= dims_second[c]){
	    mexErrMsgTxt("Inputs must have the same dimensions.\n");
	}
    }
    
    /* Get the number of elements in the input argument */
    elements=mxGetNumberOfElements(prhs[0]);
    
    /* Get the input values */
    first_ptr = (double *)mxGetPr(prhs[0]);
    second_ptr = (double *)mxGetPr(prhs[1]);
    
    /* Create output */
    plhs[0]=mxCreateDoubleMatrix(1,1,mxREAL);
    
    /* Get the value of eps */
    eps= mxGetEps();

    /* Check for equality within eps */ 
    for(j=0; j<elements; j++){
	if((fabs(first_ptr[j] - second_ptr[j])) > (fabs(second_ptr[j] *eps))){
	    break; } 
    }

    if (j== elements){
	mxGetPr(plhs[0])[0]=1.0;
    }
}
  
