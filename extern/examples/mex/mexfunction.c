/*=================================================================
 * mexfunction.c 
 *
 * This example demonstrates how to use mexFunction.  It returns
 * the number of elements for each input argument, providing the 
 * function is called with the same number of output arguments
 * as input arguments.
 
 * This is a MEX-file for MATLAB.  
 * Copyright 1984-2000 The MathWorks, Inc.
 * All rights reserved.
 *=================================================================*/
/* $Revision: 1.5 $ */
#include "mex.h"

void
mexFunction(int nlhs,mxArray *plhs[],int nrhs,const mxArray *prhs[])
{
    int        i;
       
    /* Examine input (right-hand-side) arguments. */
    mexPrintf("\nThere are %d right-hand-side argument(s).", nrhs);
    for (i=0; i<nrhs; i++)  {
	mexPrintf("\n\tInput Arg %i is of type:\t%s ",i,mxGetClassName(prhs[i]));
    }
    
    /* Examine output (left-hand-side) arguments. */
    mexPrintf("\n\nThere are %d left-hand-side argument(s).\n", nlhs);
    if (nlhs > nrhs)
      mexErrMsgTxt("Cannot specify more outputs than inputs.\n");
    for (i=0; i<nlhs; i++)  {
	plhs[i]=mxCreateDoubleMatrix(1,1,mxREAL);
	*mxGetPr(plhs[i])=mxGetNumberOfElements(prhs[i]);
    }
}

