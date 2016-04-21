/*=================================================================
 * mxislogical.c 
 * This example demonstrates how to use mexIsGlobal, mexGetArrayPtr,
 * mxIsLogical.  You pass in the name of a variable in the caller
 * workspace.  It then gets the pointer to that variable and returns
 * a two element logical array.  The first element indicates whether
 * the named variable is a logical, the second whether it is a global.
 *
 * This is a MEX-file for MATLAB.  
 * Copyright 1984-2000 The MathWorks, Inc. 
 *=================================================================*/
/* $Revision: 1.8 $ */

#include "mex.h"

void
mexFunction(int nlhs,mxArray *plhs[],int nrhs,const mxArray *prhs[])
{
    const mxArray  *array_ptr;
    char     *variable;
    mxLogical *pl;

    /* Check for proper number of input and output arguments */    
    if (nrhs != 1) {
	mexErrMsgTxt("One input argument required.");
    } 
    if(nlhs > 1){
	mexErrMsgTxt("Too many output arguments.");
    }

    /* Check to be sure input argument is a string. */
    if (!(mxIsChar(prhs[0]))){
	mexErrMsgTxt("Input must be of type string.");
    }
    
    /* Get input variable */
    variable= mxArrayToString(prhs[0]);
    array_ptr = mexGetVariablePtr("caller", variable);
    if (array_ptr == NULL){
	mexErrMsgTxt("Could not get variable.\n");
    }

    plhs[0] = mxCreateLogicalMatrix(1,2);
    pl = mxGetLogicals(plhs[0]);

    pl[0] = mxIsLogical(array_ptr);
    pl[1] = mexIsGlobal(array_ptr);

    mxFree(variable);
}










