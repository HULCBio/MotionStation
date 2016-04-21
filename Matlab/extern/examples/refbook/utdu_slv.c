/* $Revision: 1.2.6.1 $ $Date: 2002/10/31 10:49:30 $ */
/*=========================================================
 * utdu_slv.c
 * example for illustrating how to use LAPACK within a C
 * MEX-file on HP700, IBM_RS and PC.  This differs from the
 * other platforms in that the LAPACK symbols are not defined
 * exported with underscores e.g. dsysvx instead of dsysvx_
 *
 * UTDU_SLV Solves the symmetric indefinite system of linear 
 * equations A*X=B for X.
 * X = UTDU_SLV(A,B) computes a symmetric (Hermitian) indefinite 
 * factorization of A and returns the result X such that A*X is B. 
 * B must have as many rows as A.
 *
 * This is a MEX-file for MATLAB.
 * Copyright 1984-2000 The MathWorks, Inc.
 *=======================================================*/
#include "mex.h"
#include "fort.h"

#if !defined(WIN32) && !defined(ARCH_IBM_RS) && !defined(ARCH_HP700) && !defined(ARCH_HPUX)
#define zhesvx zhesvx_
#define dsysvx dsysvx_
#endif

void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[] )
{

	/* mex interface to LAPACK functions dsysvx and zhesvx */

    char *fact = "N", *uplo = "U", msg[101];
    int cplx, n, nrhsb, lda, ldaf, *ipiv, ldb, ldx, lwork, *iwork, info;
    double *A, *AF, *b, *x, rcond, *ferr, *berr, *work1, *work, *rwork;
	
    if ((nlhs > 1) || (nrhs != 2)) {
      mexErrMsgTxt("Expect 2 input arguments and return 1 output argument");
    }

    n = mxGetN(prhs[0]);
    nrhsb = mxGetN(prhs[1]);
    lda = mxGetM(prhs[0]);
    if (lda != n) {
      mexErrMsgTxt("Matrix must be square and symmetric");
    }
    cplx = (mxGetPi(prhs[0]) || mxGetPi(prhs[1]));
    if (cplx) {
      A = mat2fort(prhs[0],lda,n);
      AF = (double *)mxCalloc(2*lda*n,sizeof(double));
    } else {
      A = mxGetPr(prhs[0]);
      AF = (double *)mxCalloc(lda*n,sizeof(double));
    }
    ldaf = lda;
    ipiv = (int *)mxCalloc(n,sizeof(int));
    ldb = mxGetM(prhs[1]);
    if (lda != ldb) {
      mexErrMsgTxt("A and b must have the same number of rows");
    }
    ldx = ldb;
    ferr = (double *)mxCalloc(nrhsb,sizeof(double));
    berr = (double *)mxCalloc(nrhsb,sizeof(double));
    lwork = -1;
    info = 0;
    if (cplx) {
      b = mat2fort(prhs[1],ldb,nrhsb);
      x = (double *)mxCalloc(2*ldb*nrhsb,sizeof(double));
      work1 = (double *)mxCalloc(2,sizeof(double));
      rwork = (double *)mxCalloc(n,sizeof(double));
      /* Query zhesvx on the value of lwork */
      zhesvx ( fact, uplo, &n, &nrhsb, A, &lda, AF, &ldaf, ipiv, b, &ldb,
        x, &ldx, &rcond, ferr, berr, work1, &lwork, rwork, &info );
        if (info < 0) {
          sprintf(msg, "Input %d to zhesvx had an illegal value",-info);
          mexErrMsgTxt(msg);
        }
      lwork = (int)(work1[0]);
      work = (double *)mxCalloc(2*lwork,sizeof(double));
        zhesvx ( fact, uplo, &n, &nrhsb, A, &lda, AF, &ldaf, ipiv, b, &ldb,
          x, &ldx, &rcond, ferr, berr, work, &lwork, rwork, &info );
        if (info < 0) {
          sprintf(msg, "Input %d to zhesvx had an illegal value",-info);
          mexErrMsgTxt(msg);
        }
    } else {
      b = mxGetPr(prhs[1]);
      x = (double *)mxCalloc(ldb*nrhsb,sizeof(double));
      work1 = (double *)mxCalloc(1,sizeof(double));
      iwork = (int *)mxCalloc(n,sizeof(int));
      /* Query dsysvx on the value of lwork */
      dsysvx ( fact, uplo, &n, &nrhsb, A, &lda, AF, &ldaf, ipiv, b, &ldb,
        x, &ldx, &rcond, ferr, berr, work1, &lwork, iwork, &info );
        if (info < 0) {
          sprintf(msg, "Input %d to dsysvx had an illegal value",-info);
          mexErrMsgTxt(msg);
        }
      lwork = (int)(work1[0]);
      work = (double *)mxCalloc(lwork,sizeof(double));
        dsysvx ( fact, uplo, &n, &nrhsb, A, &lda, AF, &ldaf, ipiv, b, &ldb,
          x, &ldx, &rcond, ferr, berr, work, &lwork, iwork, &info );
        if (info < 0) {
          sprintf(msg, "Input %d to dsysvx had an illegal value",-info);
          mexErrMsgTxt(msg);
        }
    }

    if (rcond == 0) {
      sprintf(msg,"Matrix is singular to working precision.");
      mexErrMsgTxt(msg);
    } else if (rcond < mxGetEps()) {
      sprintf(msg,"Matrix is close to singular or badly scaled.\n"
        "         Results may be inaccurate. RCOND = %g",rcond);
      mexWarnMsgTxt(msg);
    }

    if (cplx) {
      plhs[0] = fort2mat(x,ldx,ldx,nrhsb);
      mxFree(A);
      mxFree(b);
      mxFree(rwork);
    } else {
      plhs[0] = mxCreateDoubleMatrix(ldx,nrhsb,0);
      mxSetPr(plhs[0],x);
      mxFree(iwork);
    }

    mxFree(AF);
    mxFree(ipiv);
    mxFree(ferr);
    mxFree(berr);
    mxFree(work1);
    mxFree(work);

}
