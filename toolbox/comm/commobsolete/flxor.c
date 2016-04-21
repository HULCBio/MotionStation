/* $Revision: 1.13 $ */
/* Wes Wang, Cleve Moler, 10/5/95
 * Copyright 1996-2002 The MathWorks, Inc.
 */
#include <math.h>

#ifdef MATLAB_MEX_FILE
#include "mex.h"
#endif

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
/*
 * FLXOR Flint bitwise exclusive or (vectorized).
 *    r = flxor(i,j)
 */
{
  int i,mi,ni,mj,nj,m,n,k,inci,incj;
  double *pi,*pj,*pr;

  for (i=0; i < nrhs; i++){
      if (mxIsChar(prhs[i]))
	mexErrMsgTxt("String is not correct input type! Use 'help flxor' to get started.");
  }
  if ( nrhs != 2 ){
      mexErrMsgTxt("Not enough input argument!");
      return;
  }

  mi = mxGetM(prhs[0]);
  ni = mxGetN(prhs[0]);
  mj = mxGetM(prhs[1]);
  nj = mxGetN(prhs[1]);
  if ((mi == 1) & (ni == 1) & (mj == 1) & (nj == 1)) {
    pr = mxGetPr(plhs[0] = mxCreateDoubleMatrix(1,1,mxREAL));
    pr[0] = (double) (((long)mxGetScalar(prhs[0])) ^ ((long)mxGetScalar(prhs[1])));
    return;
  } else if ((mi == mj) & (ni == nj)) {
    m = mi;
    n = ni;
    inci = 1;
    incj = 1;
  } else if ((mj == 1) & (nj == 1)) {
    m = mi;
    n = ni;
    inci = 1;
    incj = 0;
  } else if ((mi == 1) & (ni == 1)) {
    m = mj;
    n = nj;
    inci = 0;
    incj = 1;
  } else {
    mexErrMsgTxt("Matrix dimensions must agree.");
  }
  pi = mxGetPr(prhs[0]);
  pj = mxGetPr(prhs[1]);
  pr = mxGetPr(plhs[0] = mxCreateDoubleMatrix(m,n,mxREAL));
  for (k = 0; k < m*n; k++) {
    *pr++ = (double) (((long) *pi) ^ ((long) *pj));
    pi += inci;
    pj += incj;
  }
  return;
}
