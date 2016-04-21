#include "mex.h"

/*
 * timestwoalt.c - example found in API guide
 *
 * use mxGetScalar to return the values of scalars instead of pointers
 * to copies of scalar variables.
 *
 * This is a MEX-file for MATLAB.
 * Copyright 1984-2000 The MathWorks, Inc.
 */
 
/* $Revision: 1.6 $ */

void timestwo_alt(double *y, double x)
{
  *y = 2.0*x;
}

void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{
  double *y;
  double  x;

    /* Check arguments */
    
  if (nrhs != 1) { 
    mexErrMsgTxt("One input argument required."); 
  } else if (nlhs > 1) {
    mexErrMsgTxt("Too many output arguments."); 
  } else if (!mxIsNumeric(prhs[0])) {
    mexErrMsgTxt("Argument must be numeric.");
  } else if (mxGetNumberOfElements(prhs[0]) != 1 || mxIsComplex(prhs[0])) {
    mexErrMsgTxt("Argument must be non-complex scalar.");
  }
  /* create a 1-by-1 matrix for the return argument */
  plhs[0] = mxCreateDoubleMatrix(1,1,mxREAL);

  /* get the scalar value of the input x */
  /* note: mxGetScalar returns a value, not a pointer */
  x = mxGetScalar(prhs[0]);

  /* assign a pointer to the output */
  y = mxGetPr(plhs[0]);
  
  /* call the timestwo_alt subroutine */
  timestwo_alt(y,x);
}

