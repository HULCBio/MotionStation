/*=================================================================
* fulltosparse.c
* This example demonstrates how to populate a sparse
* matrix.  For the purpose of this example, you must pass in a
* non-sparse 2-dimensional argument of type double.

* Comment: You might want to modify this MEX-file so that you can use
* it to read large sparse data sets into MATLAB.
*
* This is a MEX-file for MATLAB.  
* Copyright 1984-2000 The MathWorks, Inc.
* All rights reserved.
*=================================================================*/

/* $Revision: 1.5 $ */

#include <math.h> /* Needed for the ceil() prototype */
#include "mex.h"

/* If you are using a compiler that equates NaN to be zero, you must
 * compile this example using the flag  -DNAN_EQUALS_ZERO. For example:
 *
 *     mex -DNAN_EQUALS_ZERO fulltosparse.c
 *
 * This will correctly define the IsNonZero macro for your C compiler.
 */

#if defined(NAN_EQUALS_ZERO)
#define IsNonZero(d) ((d)!=0.0 || mxIsNaN(d))
#else
#define IsNonZero(d) ((d)!=0.0)
#endif

void mexFunction(
		 int nlhs,       mxArray *plhs[],
		 int nrhs, const mxArray *prhs[]
		 )
{
    /* Declare variable */
    int j,k,m,n,nzmax,*irs,*jcs,cmplx,isfull;
    double *pr,*pi,*si,*sr;
    double percent_sparse;
    
    /* Check for proper number of input and output arguments */    
    if (nrhs != 1) {
	mexErrMsgTxt("One input argument required.");
    } 
    if(nlhs > 1){
	mexErrMsgTxt("Too many output arguments.");
    }
    
    /* Check data type of input argument  */
    if (!(mxIsDouble(prhs[0]))){
	mexErrMsgTxt("Input argument must be of type double.");
    }	
    
    if (mxGetNumberOfDimensions(prhs[0]) != 2){
	mexErrMsgTxt("Input argument must be two dimensional\n");
    }

    /* Get the size and pointers to input data */
    m  = mxGetM(prhs[0]);
    n  = mxGetN(prhs[0]);
    pr = mxGetPr(prhs[0]);
    pi = mxGetPi(prhs[0]);
    cmplx = (pi==NULL ? 0 : 1);
    
    /* Allocate space for sparse matrix 
     * NOTE:  Assume at most 20% of the data is sparse.  Use ceil
     * to cause it to round up. 
     */

    percent_sparse = 0.2;
    nzmax=(int)ceil((double)m*(double)n*percent_sparse);

    plhs[0] = mxCreateSparse(m,n,nzmax,cmplx);
    sr  = mxGetPr(plhs[0]);
    si  = mxGetPi(plhs[0]);
    irs = mxGetIr(plhs[0]);
    jcs = mxGetJc(plhs[0]);
    
    /* Copy nonzeros */
    k = 0; 
    isfull=0;
    for (j=0; (j<n ); j++) {
      int i;
      jcs[j] = k;
      for (i=0; (i<m ); i++) {
	if (IsNonZero(pr[i]) || (cmplx && IsNonZero(pi[i]))) {

	  /* Check to see if non-zero element will fit in 
	   * allocated output array.  If not, increase percent_sparse 
	   * by 10%, recalculate nzmax, and augment the sparse array
	   */
	  if (k>=nzmax){
	    int oldnzmax = nzmax;
	    percent_sparse += 0.1;
	    nzmax = (int)ceil((double)m*(double)n*percent_sparse);

	    /* make sure nzmax increases atleast by 1 */
	    if (oldnzmax == nzmax) 
	      nzmax++;

	    mxSetNzmax(plhs[0], nzmax); 
	    mxSetPr(plhs[0], mxRealloc(sr, nzmax*sizeof(double)));
	    if(si != NULL)
	      mxSetPi(plhs[0], mxRealloc(si, nzmax*sizeof(double)));
	    mxSetIr(plhs[0], mxRealloc(irs, nzmax*sizeof(int)));
	   
	    sr  = mxGetPr(plhs[0]);
	    si  = mxGetPi(plhs[0]);
	    irs = mxGetIr(plhs[0]);
	  }
	  sr[k] = pr[i];
	  if (cmplx){
	    si[k]=pi[i];
	  }
	  irs[k] = i;
	  k++;
        }    
      }
      pr += m;
      pi += m;
    }
    jcs[n] = k;
}
 
