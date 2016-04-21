/* $Revision: 1.8 $ */
/*=========================================================
 * convec.c
 * example for illustrating how to use pass complex data 
 * from MATLAB to C and back again
 *
 * convolves  two complex input vectors
 *
 * This is a MEX-file for MATLAB.
 * Copyright 1984-2000 The MathWorks, Inc.
 *=======================================================*/
#include "mex.h"

/* computational subroutine */
void convec( double *xr, double *xi, int nx,
             double *yr, double *yi, int ny,
             double *zr, double *zi)
{
    int i,j;
  
    zr[0]=0.0;
    zi[0]=0.0;
    /* perform the convolution of the complex vectors */
    for(i=0; i<nx; i++) {
	for(j=0; j<ny; j++) {
	    *(zr+i+j) = *(zr+i+j) + *(xr+i) * *(yr+j) - *(xi+i) * *(yi+j);
	    *(zi+i+j) = *(zi+i+j) + *(xr+i) * *(yi+j) + *(xi+i) * *(yr+j);
	}
    }
}

/* The gateway routine. */
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{
    double  *xr, *xi, *yr, *yi, *zr, *zi;
    int     rows, cols, nx, ny;
    
    /* check for the proper number of arguments */
    if(nrhs != 2)
      mexErrMsgTxt("Two inputs required.");
    if(nlhs > 1)
      mexErrMsgTxt("Too many output arguments.");
    /*Check that both inputs are row vectors*/
    if( mxGetM(prhs[0]) != 1 || mxGetM(prhs[1]) != 1 )
      mexErrMsgTxt("Both inputs must be row vectors.");
    rows = 1; 
    /* Check that both inputs are complex*/
    if( !mxIsComplex(prhs[0]) || !mxIsComplex(prhs[1]) )
      mexErrMsgTxt("Inputs must be complex.\n");
  
    /* get the length of each input vector */
    nx = mxGetN(prhs[0]);
    ny = mxGetN(prhs[1]);


    /* get pointers to the real and imaginary parts of the inputs */
    xr = mxGetPr(prhs[0]);
    xi = mxGetPi(prhs[0]);
    yr = mxGetPr(prhs[1]);
    yi = mxGetPi(prhs[1]);
  
    /* create a new array and set the output pointer to it */
    cols = nx + ny - 1;
    plhs[0] = mxCreateDoubleMatrix(rows, cols, mxCOMPLEX);
    zr = mxGetPr(plhs[0]);
    zi = mxGetPi(plhs[0]);

    /* call the C subroutine */
    convec(xr, xi, nx, yr, yi, ny, zr, zi);

    return;
}




