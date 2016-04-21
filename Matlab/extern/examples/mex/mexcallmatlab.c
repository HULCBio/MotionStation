/*=================================================================
 * mexcallmatlab.c
 *
 * mexcallmatlab takes no inputs.  This routine first forms and
 * displays the following matrix (in MATLAB notation):
 *
 *      hankel(1:4,4:-1:1) + sqrt(-1)*toeplitz(1:4,1:4)
 *
 * Next it finds the eigenvalues and eigenvectors (using the MATLAB
 * function EIG), and displays the eigenvalue matrix.  Then it
 * calculates the inverse of the eigenvalues to demonstrate manipulation
 * of MATLAB results and how to deal with complex arithemetic.  Finally,
 * the program displays the inverse values.
 *
 * Copyright 1984-2000 The MathWorks, Inc.
 * $Revision: 1.11 $
 *================================================================*/

#include <math.h>
#include "mex.h"

#define XR(i,j) xr[i+4*j]
#define XI(i,j) xi[i+4*j]

static void fill_array( double	*xr, double  *xi)
{
    double tmp;
    int i,j,jj;
    /* Remember, MATLAB stores matrices in their transposed form,
       i.e., columnwise, like FORTRAN. */
    
/* Fill real and imaginary parts of array. */
    for (j = 0; j < 4; j++) {
	for (i = 0; i <= j; i++) {
	    XR(i,j) = 4 + i - j;
	    XR(j,i) = XR(i,j);
	    XI(i,j) = j - i + 1;
	    XI(j,i) = XI(i,j);
	}
    }
    /* Reorder columns of xr. */
    for (j = 0; j < 2; j++) {
	for (i = 0; i < 4; i++) {
	    tmp = XR(i,j);
	    jj = 3 - j;
	    XR(i,j) = XR(i,jj);
	    XR(i,jj) = tmp;
	}
    }
}

/* Invert diagonal elements of complex matrix of order 4 */
static void invertd( double *xr, double *xi )
{
    double tmp;
    double *rx, *ix;
    int i;
    
    rx = xr;
    ix = xi;
    
    /* I know diagnonal elements of a 4 X 4 are 1:5:16 */
    for (i = 0; i < 16; i += 5, rx += 5, ix += 5) {
	tmp = *rx * *rx + *ix * *ix;
	*rx = *rx / tmp;
	*ix = - *ix / tmp;
    }		
}

void 
mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray	*prhs[])
{
    int m, n;
    mxArray *lhs[2], *x;
    
    m = n = 4;
    
    /* Check for proper number of input and output arguments */    
    if (nrhs != 0) {
	mexErrMsgTxt("No input arguments required.");
    } 
    if(nlhs > 1){
	mexErrMsgTxt("Too many output arguments.");
    } 
    
    /* Allocate x matrix */
    x =  mxCreateDoubleMatrix(m, n, mxCOMPLEX);
    
    /* create values in some arrays -- remember, MATLAB stores matrices
       column-wise */
    fill_array(mxGetPr(x), mxGetPi(x));
    
    /* print out initial matrix */
    mexCallMATLAB(0,NULL,1, &x, "disp");
    
    /* calculate eigenvalues and eigenvectors */
    mexCallMATLAB(2, lhs, 1, &x, "eig");
    
    /* print out eigenvalue matrix */
    mexCallMATLAB(0,NULL,1, &lhs[1], "disp");
    
    /* take inverse of complex eigenvalues, just on diagonal */
    invertd(mxGetPr(lhs[1]), mxGetPi(lhs[1]));
    
    /* and print these out */
    mexCallMATLAB(0,NULL,1, &lhs[1], "disp");
    
    /* Free allocated matrices */
    mxDestroyArray(x);
    mxDestroyArray(lhs[1]);
    plhs[0] = lhs[0];
}

