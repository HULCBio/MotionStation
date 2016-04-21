/*=================================================================
 * mxcreatecharmatrixfromstr.c
 * 
 * This example takes MATLAB strings as inputs.  It returns a
 * vertically concatenated matrix of the input strings.  If the
 * example is compiled as follows:
 *
 *   mex mxcreatecharmatrixfromstr.c -DSPACE_PADDING
 *
 * it will create a matrix with space padding.  If it is compiled
 * without the flag, the matrix of strings that is created will have
 * NULL padding.
 *
 * This is a MEX-file for MATLAB.  
 * Copyright 1984-2000 The MathWorks, Inc.
 * All rights reserved.
 *=================================================================*/

/* $Revision: 1.6 $ */
#include "mex.h"

void
mexFunction(int nlhs,mxArray *plhs[],int nrhs,const mxArray *prhs[])
{
    int i;
    char *str[100];

    /* Check for proper number of input and output arguments */    
    if (nrhs < 2) {
	mexErrMsgTxt("At least two input arguments required.");
    } 
    if(nlhs > 1){
	mexErrMsgTxt("Too many output arguments.");
    }
    
    for (i=0; i<nrhs; i++){
	/* Check input to be sure it is of type char. */
	if(!mxIsChar(prhs[i])){
	    mexErrMsgTxt("Input must be of type char.");
	}
	/* Copy the string data from prhs and place it into str. */ 
        str[i] = mxArrayToString(prhs[i]); 
    }
    
    /* Create a 2-Dimensional string mxArray with NULL padding. */
    plhs[0]= mxCreateCharMatrixFromStrings(nrhs, (const char **)str); 

    /* If compile with -DSPACE_PADDING, convert NULLs to spaces */
#if defined(SPACE_PADDING)
    {
        int nelem = mxGetNumberOfElements(plhs[0]);
        mxChar *charData = (mxChar *)mxGetData(plhs[0]);
	for(i=0; i < nelem; i++) {
	    if(charData[i] == (mxChar) 0) {
	        charData[i] = (mxChar) ' ';
	    }
	}
    }
#endif
    /* Free the allocated memory */
    for (i=0; i<nrhs; i++){
        mxFree(str[i]); 
    }
}

