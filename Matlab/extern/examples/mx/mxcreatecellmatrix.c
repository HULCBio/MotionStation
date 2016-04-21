/*=================================================================
 * mxcreatecellmatrix.c 
 *
 * mxcreatecellmatrix takes the input arguments and places them in a
 * cell. It then displays the contents of the cell through a
 * mexCallMATLAB call.
 *
 *
 * This is a MEX-file for MATLAB.  
 * Copyright 1984-2000 The MathWorks, Inc.
 * All rights reserved.
*=================================================================*/

/* $Revision: 1.4 $ */
#include "mex.h"

void
mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    
    mxArray *cell_array_ptr, *rhs[1];
    int i;
    
    /* Check for proper number of input and output arguments */    
    if (nrhs < 1) {
        mexErrMsgTxt("At least one input argument required.");
    } 
    if(nlhs > 1){
        mexErrMsgTxt("Too many output arguments.");
    }

    /* Create a nrhs x 1 cell mxArray. */ 
    cell_array_ptr = mxCreateCellMatrix(nrhs,1);
    
    /* Fill cell matrix with input arguments */
    for( i=0; i<nrhs; i++){
	mxSetCell(cell_array_ptr,i,mxDuplicateArray(prhs[i]));
    }
    
    rhs[0] = cell_array_ptr;
    
    /* Call mexCallMATLAB to display the cell */
    mexPrintf("\nThe contents of the created cell is:\n\n");
    mexCallMATLAB(0,NULL,1,rhs,"disp");
}
    
