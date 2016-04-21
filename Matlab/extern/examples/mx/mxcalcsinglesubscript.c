/*=================================================================
 * mxcalcsinglesubscript.c 
 *
 * This is an example of how to use mxCalcSingleSubscript.  To run
 * this example, you pass in a N-dimensional array of doubles and
 * MATLAB indices to the element you would like returned. It will
 * return the element you selected. The number of indices you pass in
 * must match the number of dimensions in your array. The array must
 * consist of real values.  This example demonstrates that MATLAB uses
 * 1 based indexing and C uses 0 based indexing.  It details how to
 * convert from MATLAB to vector *indexing.
 *
 * This is a MEX-file for MATLAB.  
 * Copyright 1984-2000 The MathWorks, Inc.
 * All rights reserved.
 *=================================================================*/
 /* $Revision: 1.2 $ */

#include "mex.h"

void
mexFunction(int nlhs,mxArray *plhs[],int nrhs,const mxArray *prhs[])
{
    int     nsubs, index, x; 
    double  *temp;
    int     *subs;
      
    /* Check for proper number of input and output arguments */    
    if (nrhs != 2) {
	mexErrMsgTxt("Two input arguments required.");
    } 
    if (nlhs > 1) {
	mexErrMsgTxt("Too many output arguments.");
    }
        
    /* Check data type of first input argument */
    if (!mxIsDouble(prhs[0])) {
	mexErrMsgTxt("First input argument must be a double.");
    }
    /* Check data type of first second argument */
    if (!mxIsDouble(prhs[0]) || mxIsComplex(prhs[0])) {
	mexErrMsgTxt("Second input argument must be a real double.");
    }
    /* Get the number of dimensions in array */
    nsubs=mxGetNumberOfDimensions(prhs[0]);
      
    /* Check for the correct number of indices  */
    if (mxGetNumberOfElements(prhs[1]) != nsubs){
	mexErrMsgTxt("You must specify an index for each dimension.");
    }

    /* Allocate memory for the subs array on the fly */
    subs=mxCalloc(nsubs,sizeof(int));
      
    /* Get the indices and account for the fact that MATLAB is 1
       based and C is zero based.  While doing this, check to make
       sure that an index was not specified that is larger than size
       of input array */

    temp=mxGetPr(prhs[1]);
       
    for (x=0;x<nsubs;x++){
	subs[x]=(int)temp[x]-1;
	if (temp[x]> ((mxGetDimensions(prhs[0]))[x]) ){
	    mxFree(subs);
	    mexErrMsgTxt("You indexed above the size of the array.");
	}
    }

    /* Find the index of location selected.  Note, for example, that
       (3,4) in MATLAB corresponds to (2,3) in C. */
    index = mxCalcSingleSubscript(prhs[0], nsubs, subs);
      
    /* Create the output array */
    plhs[0] = mxCreateDoubleMatrix(1, 1, mxIsComplex(prhs[0]) ? mxCOMPLEX : mxREAL);
      
    /* Free allocated memory*/
    mxFree(subs);
      
    /* Assign value in C based array to plhs. */
    mxGetPr(plhs[0])[0]= mxGetPr(prhs[0])[index];
    if (mxIsComplex(prhs[0])) {
	mxGetPi(plhs[0])[0]= mxGetPi(prhs[0])[index];
    }
}
