/* DANTZGMP QP optimizer - Source for generating Mex file */

/*    Author: N.L. Ricker, A. Bemporad 
    Copyright 1986-2003 The MathWorks, Inc. 
    $Revision: 1.1.6.1 $  $Date: 2003/12/04 01:37:52 $   
 */

/* MATLAB calling format: */

/*
  	[bas,ib,il,iter,tab]=qpsolver(tabi,basi,ibi,ili,maxiter)

    Inputs:
     tabi      : initial tableau
     basi      : initial basis
     ibi       : initial setting of ib
     ili       : initial setting of il
     maxiter   : max number of iteration (optional. Default=200)

    Outputs:
     bas       : final basis vector
     ib        : index vector for the variables -- see examples
     il        : index vector for the lagrange multipliers -- see examples
     iter      : iteration counter (if iter>maxiter, then max # iterations was exceeded)
     tab       : final tableau
*/

#include "math.h"
#include "mex.h"
#include "dantzgmp.h"

void mexFunction(int nlhs,mxArray *plhs[],int nrhs,const mxArray *prhs[])
{
	double *tabi, *basi, *ibi, *ili, *maxiter;
	int M, N, rows, cols, iret;
	int nuc=0;
	int i, j;
	int MN = 0;
	long len;
	mxArray *ptrs[5];
	double *bas, *ib, *il, *iter, *tab;
	integer *ibint, *ilint;
	integer buflen, *maxiterint;

	/* Verify correct number of input and output arguments. */
   	if (nrhs < 4) mexErrMsgTxt("You must supply at least 4 input arguments.\n");
	tabi = mxGetPr(prhs[0]);
	basi = mxGetPr(prhs[1]);
	ibi = mxGetPr(prhs[2]);
	ili = mxGetPr(prhs[3]);
	maxiter = mxGetPr(prhs[4]);
	
	if (nlhs < 3) mexErrMsgTxt("You must supply at least 3 output arguments.\n");

	/* Error checking on inputs */
	/* Checking TABI */
	M = mxGetM(prhs[0]);
	N = mxGetN(prhs[0]);
	if (M <= 0 || N <= 0)
		mexErrMsgTxt("TABI is empty.\n");
	/* Checking BASI */
	rows = mxGetM(prhs[1]);
	cols = mxGetN(prhs[1]);
	len = max(rows,cols);
	if (min(rows,cols) != 1 || len != M)
		mexErrMsgTxt("BASI must be a vector, length = number of rows in TABI.\n");
	/* Checking IBI */
	rows = mxGetM(prhs[2]);
	cols = mxGetN(prhs[2]);
	len = max(rows,cols);
	if (min(rows,cols) != 1 || len != M)
		mexErrMsgTxt("IBI must be a vector, length = number of rows in TABI.\n");
	/* Checking ILI */
	rows = mxGetM(prhs[3]);
	cols = mxGetN(prhs[3]);
	len = max(rows,cols);
	if (min(rows,cols) != 1 || len != M)
		mexErrMsgTxt("ILI must be a vector, length = number of rows in TABI.\n");


	/* Allocate space for output variables and define corresponding C pointers */
	ptrs[0] = mxCreateDoubleMatrix(M, 1, mxREAL);
	bas = mxGetPr(ptrs[0]);
	ptrs[1] = mxCreateDoubleMatrix(M, 1, mxREAL);
	ib = mxGetPr(ptrs[1]);
	ptrs[2] = mxCreateDoubleMatrix(M, 1, mxREAL);
	il = mxGetPr(ptrs[2]);
	ptrs[3] = mxCreateDoubleMatrix(1, 1, mxREAL);
	iter = mxGetPr(ptrs[3]);
	ptrs[4] = mxCreateDoubleMatrix(M, N, mxREAL);   
	tab = mxGetPr(ptrs[4]);
	/* We have to convert ib and il from double to integer and vice-versa. */
	/* Allocate arrays for storing the integer versions. */
	buflen = M * sizeof(*ibint);
	ibint = (integer *) mxMalloc(buflen);  /* Pointer to integer version of ib */
	ilint = (integer *) mxMalloc(buflen);  /* Pointer to integer version of il */
	maxiterint = (integer *) mxMalloc(sizeof(*maxiterint));  /* Pointer to integer version of maxiterint */

	if (nrhs>4) *maxiterint = (integer) *maxiter;
	else *maxiterint = 200;
	
	/* Initialization */

	for (i=0; i<M; i++) {
		bas[i] = basi[i];
		ibint[i] = (integer) ibi[i];
		ilint[i] = (integer) ili[i];
	}
	for (j=0; j<N; j++) {
		for (i=0; i<M; i++) {
			tab[MN] = tabi[MN];
			MN++;
		}
	}

	/* Call DANTZG for the calculations */

	iret = dantzg(tab, &N, &N, &nuc, bas, ibint, ilint, maxiterint);
	/* Store number of iterations. */
	*iter = (double) iret;

	/* Return results to MATLAB.  First convert integer versions */
	/* of ib and il back to real, then set pointers to outputs. */
	for (i=0; i<M; i++) {
		ib[i] = (double) ibint[i];
		il[i] = (double) ilint[i];
	}
	for (i=0; i<nlhs; i++) {
		plhs[i] = ptrs[i];
	}
	
	if (iret == N * -3) {
        mexPrintf("Unable to delete a variable from basis\n");
	    mexPrintf("basis=["); 
        for (i=0;i<M;i++) {
        	mexPrintf("%g",bas[i]); 
        	if (i<M-1)
        	    mexPrintf(",");
        }
        mexPrintf("]\n");
        mexErrMsgTxt("Fatal error in QP solver -- Closed-loop system may be unstable\n");
	    
	}
}
