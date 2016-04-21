/*=================================================================
 * mxsetdimensions.c 
 *
 * mxsetdimensions reshapes your input array according to the the new
 * dimensions specified as input. For example,
 * mxsetdimensions(X,M,N,P,...) returns an N-D array with the same
 * elements as X but reshaped to have the size M-by-N-by-P-by-...
 * M*N*P*... must contain the same number of elements as X.
 *
 * This is a MEX-file for MATLAB.  
 * Copyright 1984-2000 The MathWorks, Inc.
 * All rights reserved.
 *=================================================================*/

/* $Revision: 1.8 $ */
#include <string.h>
#include "mex.h"

void
mexFunction(int nlhs,mxArray *plhs[],int nrhs,const mxArray *prhs[])
{
    
    int number_new_dims, number_input_elements, number_new_elements, i;
    int *new_dims;  
    
    /* Check for proper number of input and output arguments */    
    if (nrhs < 3) {
        mexErrMsgTxt("At least 3 input arguments required.");
    } 
    if(nlhs > 1){
        mexErrMsgTxt("Too many output arguments.");
    }
    number_new_dims = nrhs-1;
    if (mxIsSparse(prhs[0]) && number_new_dims != 2){
	mexErrMsgTxt("Multidimensional sparse arrays are not supported.\n");
    }

    number_input_elements = mxGetNumberOfElements(prhs[0]); 
    
    /* Allocate memory for the new_dims array on the fly */
    new_dims = mxMalloc(number_new_dims * sizeof(*new_dims)); 

    /* Create the dimensions array and check to make sure total number of
       elements for the input array is the same for the reshaped array. */
    number_new_elements=1;
    for (i=0; i< number_new_dims;i++){
	const mxArray *pa;
	pa = prhs[i+1];
	if(mxGetNumberOfElements(pa) != 1) {
	    /* Free allocated memory */
	    mxFree(new_dims);
	    mexErrMsgTxt("Size arguments must be integer scalars.");
	}
	new_dims[i] = (int)mxGetScalar(pa);
	number_new_elements = new_dims[i]*number_new_elements; 
    }
    if (number_new_elements != number_input_elements){
	/* Free allocated memory */
	mxFree(new_dims);
	mexErrMsgTxt("Total number of elements in the new array, must equal number of elements in input array.\n");
    } 
    /* Duplicate the array */
    plhs[0] = mxDuplicateArray(prhs[0]); 
    
    /* If array is sparse, use the sparse routine to reshape,
       otherwise, use mxSetDimensions. */
    if (mxIsSparse(plhs[0])){ 
	int mold; /* old number of rows */ 
	int nold; /* old number of columns */ 
	int *jcold; /*old jc array */ 
	int *ir; /* ir array that is modified in place */ 
	int mnew; /* new number of rows */ 
	int nnew; /* new number of columns */
	int *jcnew; /* new jc array */  
	int j, offset, offset1;
		
	/* Allocate space for new jc. */	
	jcnew = ((int*)mxCalloc(new_dims[1]+1, sizeof(int)));

	mnew = new_dims[0];
	nnew = new_dims[1];
		
	/* Get M, N, Ir and Jc of input array. */
	mold = mxGetM(plhs[0]);
	nold = mxGetN(plhs[0]);
	jcold = mxGetJc(plhs[0]);
	ir = mxGetIr(plhs[0]);
	
	/* First change ir so it acts like one long column vector */
	for (i=1, offset=mold; i < nold; i++, offset+=mold){
	    for (j=jcold[i]; j < jcold[i+1]; j++){
		ir[j] += offset;
	    }
	}
	/* Then fix ir and jcnew for new m and n */
	for (i=0, j=0, offset=mnew-1, offset1=0; i < jcold[nold]; ) {
	    if (ir[i] > offset) {
		jcnew[++j] = i;
		offset  += mnew;
		offset1 += mnew;
	    } else {
		ir[i++] -= offset1;
	    }
	}
	for (j++; j <= nnew; j++){
	    jcnew[j]=jcold[nold];
	}

	/* Free the old Jc, set the new Jc, M, and N. */
	mxFree(mxGetJc(plhs[0]));
	mxSetJc(plhs[0],jcnew);
	mxSetM(plhs[0],mnew);
	mxSetN(plhs[0],nnew);
    }
    else{
	/* Set the new dimensions. */
	mxSetDimensions(plhs[0],new_dims, number_new_dims);
    }

/* Free allocated memory*/
    mxFree(new_dims);
}



