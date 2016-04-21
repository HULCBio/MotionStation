/* Copyright 1994-2002 The MathWorks, Inc.  */
/* $Revision: 1.15 $  $Date: 2002/06/17 12:47:06 $  $Author: eyarrow $ */

/* V4 --> v5
mxFreeMatrix --> mxDestroyArray
Matrix --> mxArray;
mxCreateFull(*, *, 0) --> mxCreateDoubleMatrix(*, *, mxREAL)
REAL --> mxREAL
mexFunction(*, *, *, mxArray *prhs[]) --> mexFunction(*, *, *, const mxArray *prhs[])
*/

#include "mex.h"	/* This contains declaration of mxCalloc */
#include "anfis.h"
	/* anfis.h contains declaration of calloc, thus
	   it shouldn't be included below the following two lines */

#include "lib.c"
#include "mf.c"
#include "t_norm.c"
#include "defuzz.c"
#include "callml.c"
#include "list.c"
#include "list2.c"
#include "evaluate.c"
#include "dmf_dp.c"
#include "nodefun.c"
#include "datstruc.c"
/*
#include "debug.c"
*/
#include "io.c"
#include "kalman.c"
#include "stepsize.c"
#include "learning.c"
/*#include "fismat.c"*/
#include "matlab2c.c"
#include "c2matlab.c"


/* alias for input arguments */
#define	TRN_DATA	prhs[0]		/* training data */
#define	IN_FISMAT	prhs[1]		/* FIS matrix */
#define	TP		prhs[2]		/* training parameters */
#define	DP		prhs[3]		/* display parameters */
#define	CHK_DATA	prhs[4]		/* checking data */
#define METHOD          prhs[5]         /* which training method */

/* alias for output arguments */
#define	TRN_OUT_FISMAT	plhs[0]		/* returned FIS matrix */
#define	TRN_ERROR	plhs[1]		/* training error */
#define	STEP_SIZE	plhs[2]		/* step size */
#define	CHK_OUT_FISMAT	plhs[3]		/* returned FIS matrix */
#define	CHK_ERROR	plhs[4]		/* checking error */

/* void */
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
	FIS *fis;
	int i;

	if (nrhs != 6)
		mexErrMsgTxt("Needs 6 input arguments.");
	fis = matlab2cStr(prhs[1],MF_POINT_N);
	/* check if the FIS is suitable for learning */
	anfisCheckFisForLearning(fis);
	/* build ANFIS */
	anfisBuildAnfis(fis);
	anfisAssignForwardFunction(fis);
	fis->trn_data = matlab2c(TRN_DATA);
	fis->trn_data_n = mxGetM(TRN_DATA);
	if (nlhs == 5) {
		fis->chk_data = matlab2c(CHK_DATA);
		fis->chk_data_n = mxGetM(CHK_DATA);
	}

	/* get training parameters */
	fis->epoch_n =		mxGetPr(TP)[0];
	fis->trn_error_goal =	mxGetPr(TP)[1];
	fis->ss =		mxGetPr(TP)[2];
	fis->ss_dec_rate =	mxGetPr(TP)[3];
	fis->ss_inc_rate =	mxGetPr(TP)[4];
        
	/* get display parameters */
	fis->display_anfis_info =	(int) mxGetPr(DP)[0];
	fis->display_error =		(int) mxGetPr(DP)[1];
	fis->display_ss =		(int) mxGetPr(DP)[2];
	fis->display_final_result =	(int) mxGetPr(DP)[3];
        fis->method = (int) mxGetPr(METHOD)[0];

	anfisSetVariable(fis);
	anfisInitialMessage(fis);
	anfisLearning(fis);

/*	if (fis->display_final_result) {
	printf("Minimal training RMSE = %lf\n", fis->min_trn_error);
	if (fis->chk_data_n != 0)
		printf("Minimal checking RMSE = %g\n", fis->min_chk_error);
	}*/

	/* create TRN_OUT_FISMAT */
	if (nlhs >= 1) {
               TRN_OUT_FISMAT =c2matlabStr(fis, 0);
	}
	/* create TRN_ERROR */
	if (nlhs >= 2) {
		TRN_ERROR = mxCreateDoubleMatrix(fis->epoch_n, 1, mxREAL);
		for (i = 0; i < fis->epoch_n; i++)
			mxGetPr(TRN_ERROR)[i] = fis->trn_error[i];
	}

	/* create STEP_SIZE */
	if (nlhs >= 3) {
		STEP_SIZE = mxCreateDoubleMatrix(fis->epoch_n, 1, mxREAL);
		for (i = 0; i < fis->epoch_n; i++)
			mxGetPr(STEP_SIZE)[i] = fis->ss_array[i];
	}

	/* create CHK_OUT_FISMAT */
	if (nlhs >= 4) {
		if (fis->chk_data_n != 0) {
                        CHK_OUT_FISMAT =c2matlabStr(fis, 1);
		} else
			CHK_OUT_FISMAT = mxCreateDoubleMatrix(0, 0, mxREAL);
	}

	/* create CHK_ERROR */
	if (nlhs >= 5) {
		if (fis->chk_data_n != 0) {
			CHK_ERROR = mxCreateDoubleMatrix(fis->epoch_n, 1, mxREAL);
			for (i = 0; i < fis->epoch_n; i++)
				mxGetPr(CHK_ERROR)[i] = fis->chk_error[i];
		} else
			CHK_ERROR = mxCreateDoubleMatrix(0, 0, mxREAL);
	}

	/* free memory */
/*	FREEMAT((void **)in_fismat,      mxGetM(IN_FISMAT));
	FREEMAT((void **)trn_out_fismat, mxGetM(IN_FISMAT));
	if (fis->chk_data_n != 0)
		FREEMAT((void **)chk_out_fismat, mxGetM(IN_FISMAT));   */


	anfisFreeAnfis(fis);
	fisFreeFisNode(fis);


}
