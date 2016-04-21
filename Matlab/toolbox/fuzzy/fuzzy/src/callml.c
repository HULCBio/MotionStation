/* Copyright 1994-2002 The MathWorks, Inc.  */
/* $Revision: $  $Date: $  */

#ifdef MATLAB_MEX_FILE
/***********************************************************************
 MATLAB function calls 
 **********************************************************************/

/* V4 --> v5
mxFreeMatrix --> mxDestroyArray
Matrix --> mxArray;
mxCreateFull(*, *, 0) --> mxCreateDoubleMatrix(*, *, mxREAL)
mexCallMATLAB(*, *, prhs, *) --> mexCallMATLAB(*, *, (mxArray **)prhs, *)
*/

/* execute MATLAB MF function, scalar version */
static DOUBLE fisCallMatlabMf(DOUBLE x, int nparams, DOUBLE *params, char *mf_type)
{
	int i;
	mxArray *PARA = mxCreateDoubleMatrix(nparams, 1, mxREAL);
	mxArray *X = mxCreateDoubleMatrix(1, 1, mxREAL);
	mxArray *OUT;
	DOUBLE out;
	mxArray *prhs[2];

	/* data transfer */
	for (i = 0; i < nparams; i++)
		mxGetPr(PARA)[i] = params[i];
	mxGetPr(X)[0] = x;

	prhs[0] = X; prhs[1] = PARA;
	
	/* call matlab MF function */
	mexCallMATLAB(1, &OUT, 2, (mxArray **)prhs, mf_type);
	out = mxGetScalar(OUT);

	/* free allocated matrix */
	mxDestroyArray(X);
	mxDestroyArray(PARA);
	mxDestroyArray(OUT);

	/* return output */
	return(out);
}


/* execute MATLAB MF function, vector version */
/* this is used in fisComputeOutputMfValueArray() */ 
static void fisCallMatlabMf2(DOUBLE *x, int nparams, DOUBLE *params, char *mf_type, int leng, DOUBLE *out)
{
	int i;
	mxArray *PARA = mxCreateDoubleMatrix(nparams, 1, mxREAL);
	mxArray *X = mxCreateDoubleMatrix(leng, 1, mxREAL);
	mxArray *OUT;
	mxArray *prhs[2];

	/* transfer data in */
	for (i = 0; i < nparams; i++)
		mxGetPr(PARA)[i] = params[i];
	for (i = 0; i < leng; i++)
		mxGetPr(X)[i] = x[i];

	prhs[0] = X; prhs[1] = PARA;
	/* call matlab MF function */
	mexCallMATLAB(1, &OUT, 2, (mxArray **)prhs, mf_type);

	/* transfer data out */
	for (i = 0; i < leng; i++)
		out[i] = mxGetPr(OUT)[i]; 

	/* free allocated matrix */
	mxDestroyArray(X);
	mxDestroyArray(PARA);
	mxDestroyArray(OUT);
}


/* use MATLAB 'exist' to check the type of a variable or function */
static DOUBLE fisCallMatlabExist(char *variable)
{
	DOUBLE out;
	mxArray *VARIABLE = mxCreateString(variable);
	mxArray *OUT;

	/* call matlab 'exist' */
	mexCallMATLAB(1, &OUT, 1, &VARIABLE, "exist");
	out = mxGetScalar(OUT);

	/* free allocated matrix */
	mxDestroyArray(VARIABLE);
	mxDestroyArray(OUT);

	/* return output */
	return(out);
}


/* execute MATLAB function with a vector input */
/* qualified MATLAB functions are min, sum, max, etc */
static DOUBLE fisCallMatlabFcn(DOUBLE *x, int leng, char *func)
{
	DOUBLE out;
	mxArray *X = mxCreateDoubleMatrix(leng, 1, mxREAL);
	mxArray *OUT;
	int i;

	/* transfer data */
	for (i = 0; i < leng; i++)
		mxGetPr(X)[i] = x[i];

	/* call matlab function */
	mexCallMATLAB(1, &OUT, 1, &X, func);
	out = mxGetScalar(OUT);

	/* free allocated matrix */
	mxDestroyArray(X);
	mxDestroyArray(OUT);

	/* return output */
	return(out);
}


/* execute MATLAB function with a matrix input */
/* qualified MATLAB functions are min, sum, max, etc */
static void fisCallMatlabFcn1(DOUBLE *x, int m, int n, char *func, DOUBLE *out)
{
	mxArray *X, *OUT;
	int i;

	/* allocate memory */
	X = mxCreateDoubleMatrix(m, n, mxREAL);

	/* transfer data in */
	for (i = 0; i < m*n; i++)
		mxGetPr(X)[i] = x[i];

	/* call matlab function */
	mexCallMATLAB(1, &OUT, 1, &X, func);

	/* transfer data out */
	if (m == 1)
		out[0] = mxGetScalar(OUT);
	else
		for (i = 0; i < n; i++)
			out[i] = mxGetPr(OUT)[i]; 

	/* free allocated matrix */
	mxDestroyArray(X);
	mxDestroyArray(OUT);
}


/* execute MATLAB function with two matrix inputs */
/* qualified MATLAB functions are min, sum, max, etc */
static void fisCallMatlabFcn2(DOUBLE *x, DOUBLE *y, int m, int n, char *func, DOUBLE *out)
{
	mxArray *X, *Y, *OUT, *prhs[2];
	int i;

	/* allocate memory */
	X = mxCreateDoubleMatrix(m, n, mxREAL);
	Y = mxCreateDoubleMatrix(m, n, mxREAL);
	prhs[0] = X;
	prhs[1] = Y;

	/* transfer data in */
	for (i = 0; i < m*n; i++) {
		mxGetPr(X)[i] = x[i];
		mxGetPr(Y)[i] = y[i];
	}

	/* call matlab function */
	mexCallMATLAB(1, &OUT, 2, (mxArray **)prhs, func);

	/* transfer data out */
	for (i = 0; i < m*n; i++)
			out[i] = mxGetPr(OUT)[i]; 

	/* free allocated matrix */
	mxDestroyArray(X);
	mxDestroyArray(Y);
	mxDestroyArray(OUT);
}


/* execute MATLAB function for defuzzification */
static DOUBLE fisCallMatlabDefuzz(DOUBLE *x, DOUBLE *mf, int leng, char *defuzz_fcn)
{
	DOUBLE out;
	mxArray *X = mxCreateDoubleMatrix(leng, 1, mxREAL);
	/* MF is used as type word in fis.h */
	/* gcc is ok with MF being used here, but cc needs a different name */
	mxArray *MF_ = mxCreateDoubleMatrix(leng, 1, mxREAL);
	mxArray *OUT;
	mxArray *prhs[2];
	int i;

	/* transfer data */
	for (i = 0; i < leng; i++) {
		mxGetPr(X)[i] = x[i];
		mxGetPr(MF_)[i] = mf[i];
	}

	/* call matlab function */
	prhs[0] = X;
	prhs[1] = MF_;
	mexCallMATLAB(1, &OUT, 2, (mxArray **)prhs, defuzz_fcn);
	out = mxGetScalar(OUT);

	/* free allocated matrix */
	mxDestroyArray(X);
	mxDestroyArray(MF_);
	mxDestroyArray(OUT);

	/* return output */
	return(out);
}
#else

# define fisCallMatlabMf(x,nparams,params,mf_type)               /* do nothing */
# define fisCallMatlabMf2(x,nparams,params, mf_type, leng, out) /* do nothing */
# define fisCallMatlabExist(variable)                  /* do nothing */
# define fisCallMatlabFcn(x, leng, func)               /* do nothing */
# define fisCallMatlabFcn1(x, m, n, func, out)         /* do nothing */
# define fisCallMatlabFcn2(x, y, m, n, func, out)      /* do nothing */
# define fisCallMatlabDefuzz(x, mf, leng, defuzz_fcn)  /* do nothing */

#endif /* MATLAB_MEX_FILE */
