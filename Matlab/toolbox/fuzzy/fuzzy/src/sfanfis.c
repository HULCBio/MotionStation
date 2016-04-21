/* Copyright 1994-2002 The MathWorks, Inc.  */
/* $Revision: $  $Date: $  */

/*
 * Syntax  [sys,x0]=sffis(t,x,u,flag,FISMATRIX,LAMBDA_SS,SAMPLE_TIME)
 */

/* S function for ANFIS block - Developed as part of Fuzzy 2.0, but never shipped */

#define S_FUNCTION_NAME sfanfis

#include <stdio.h>     /* needed for declaration of sprintf */
#include <stdlib.h>	/* needed for declaration of calloc */

#ifdef MATLAB_MEX_FILE
#include "mex.h"      /* needed for declaration of mexErrMsgTxt */
#endif

/* for RTW */
#ifndef MATLAB_MEX_FILE
/*
 * The following only applies to MATLAB 4.2c and before.  Because 'cg_matrix.h'
 * was not up todate, these definitions were added.  Once the header file is
 * complete in V5, we shouldn't need these.  If for some reason these are
 * needed for V5, 'mxGetScalar is defined properly.  'mxCreateString' is not.
 * For one, 'mxCreateFull' doesn't exist and two even if it did, we don't
 * create strings in V5 this way anymore. 
 *
 * I've commented out the following so that this will compile under V5 strict
 * compliance.  Once this is resolved, this comment should be removed.
 *
 * 07-08-96 : rayn
 */
/* The followings are not supported by RTW. */
/* Definitions suggested by Rick Spada */
/*
#define mxGetScalar(mat)     mxGetPr(mat)[0]
#define mxCreateString(str)  (mxArray *)(mxSetPr(mxCreateFull(1,strlen(str),0),str)-2)
*/
#endif

/*
 * need to include simstruc.h for the definition of the SimStruct and
 * its associated macro definitions.
 */
#include "simstruc.h"

/* Include pertinent files */
#include "anfis.h"
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
#include "debug.c"
#include "io.c"
#include "kalman.c"
#include "stepsize.c"
#include "learning.c"
#include "fismat.c"
#include "c2matlab.c"

#define FISMATRIX	ssGetArg(S,0)
#define LAMBDA_SS	ssGetArg(S,1)	/* lambda and step size */
#define SAMPLE_TIME	ssGetArg(S,2)
#define OUT_FIS_NAME	ssGetArg(S,3)

/*
 * mdlInitializeSizes - initialize the sizes array
 */
static void
mdlInitializeSizes(SimStruct *S)
{
	DOUBLE *tmp;
	int in_n, out_n;

	/*
	mexPrintf("lambda = %g\n", mxGetPr(LAMBDA_SS)[0]);
	mexPrintf("ss = %g\n", mxGetPr(LAMBDA_SS)[1]);
	mexPrintf("sample time = %g\n", mxGetScalar(SAMPLE_TIME));
	*/
	if (ssGetNumArgs(S) == 4) {
		tmp = mxGetPr(FISMATRIX);
		in_n = tmp[2];
		out_n = tmp[2+mxGetM(FISMATRIX)];
		ssSetNumContStates(S, 0);	/* no. of continuous states */
		/* keep a dummy state */
		ssSetNumDiscStates(S, 1);	/* no. of discrete states */
		ssSetNumInputs(S, 2*in_n+out_n);/* no. of inputs */
		ssSetNumOutputs(S, out_n);	/* no. of outputs */
		ssSetDirectFeedThrough(S, 1);	/* direct feedthrough flag */
		ssSetNumSampleTimes(S, 1);	/* no. of sample times */
		ssSetNumInputArgs(S, 4);	/* no. of input arguments */
		ssSetNumRWork(S, 0);	/* no. of real work vector elements */
		ssSetNumIWork(S, 0);	/* no. of int. work vector elements */
		ssSetNumPWork(S, 1);	/* no. of ptr. work vector elements */
					/* This is the FIS pointer */
	} else {
#ifdef MATLAB_MEX_FILE
	    mexErrMsgTxt("Wrong number of additional inputs.");
#endif
	}
}

/*
 * mdlInitializeSampleTimes - initialize the sample times array
 *
 * This function is used to specify the sample time(s) for your S-function.
 * If your S-function is continuous, you must specify a sample time of 0.0.
 * Sample times must be registered in ascending order.
 */
static void
mdlInitializeSampleTimes(SimStruct *S)
{
	/* argument right after S is the index */
	ssSetSampleTimeEvent(S, 0, mxGetScalar(SAMPLE_TIME));
	ssSetOffsetTimeEvent(S, 0, 0.0);
}

/*
 * mdlInitializeConditions - initialize the states
 *
 * In this function, you should initialize the continuous and discrete
 * states for your S-function block.  The initial states are placed
 * in the x0 variable.  You can also perform any other initialization
 * activities that your S-function may require.
 */
static void
mdlInitializeConditions(DOUBLE *x0, SimStruct *S)
{
	static int count = 0;
	DOUBLE **fismatrix;
	int m, n, i, j;
	FIS *fis;

	/* put FISMATRIX into proper format */
	m = mxGetM(FISMATRIX);
	n = mxGetN(FISMATRIX);
	fismatrix = (DOUBLE **)fisCreateMatrix(m, n, sizeof(DOUBLE));
	for (i = 0; i < m; i++)
		for (j = 0; j < n; j++)
			fismatrix[i][j] = mxGetPr(FISMATRIX)[j*m + i]; 

	/* Create FIS node */
	fis = (FIS *)fisCalloc(1, sizeof(FIS));
	fisBuildFisNode(fis, fismatrix, n);

	/* Place fismatrix in the data strucutre */
	/* This is good for spit final output FISMAT */
	fis->in_fismat = fismatrix;
	fis->m = m;
	fis->n = n;

	/* check if the FIS is suitable for learning */
	anfisCheckFisForLearning(fis);

	/* build ANFIS */
	mexPrintf("Build ANFIS ...\n");
	anfisBuildAnfis(fis);
	anfisAssignForwardFunction(fis);
	fis->next = NULL;

	/* get training parameters */
	fis->lambda =	mxGetPr(LAMBDA_SS)[0];
	fis->ss =	mxGetPr(LAMBDA_SS)[1];

	anfisSetVariable1(fis);
	anfisInitialMessage1(fis);
	anfisKalman(fis, 1);	/* reset matrices used in kalman */

	/* Set fis as the Pwork for this S function */
	ssGetPWork(S)[0] = fis;

	/* dummy state */
	x0[0] = 0;
}

/*
 * mdlOutputs - compute the outputs (y)
 */
static void
mdlOutputs(DOUBLE *y, DOUBLE *x, DOUBLE *u, SimStruct *S, int tid)
{
	FIS *fis = (FIS *)ssGetPWork(S)[0]; /* obtained from Pwork */
	int j;
	/*
	mexPrintf("In mdlOutputs!\n");
	*/

	/* To get mdlUpdate called, this is the solution 
		suggested by John Ciolfi. */
	/*
	if (ssIsSampleHitEvent(S, 0, tid))
		mdlUpdate(x, u, S, tid);
	*/

	/* Dispatch the inputs */
	for (j = 0; j < fis->in_n; j++)
		fis->node[j]->value = u[j];
	/* ==========
	PRINTARRAY(u, fis->in_n + fis->out_n);
	*/
	/* Compute the output */
	anfisForward(fis, fis->in_n, fis->node_n-1);
	/* Collect the output */
	for (j = 0; j < fis->out_n; j++)
		y[j] = fis->node[fis->node_n-fis->out_n+j]->value;
	/* ==========
	PRINT(fis->node[fis->node_n-1]->value);
	*/
}

/*
 * mdlUpdate - perform action at major integration time step
 *
 * This function is called once for every major integration time step.
 * Discrete states are typically updated here, but this function is useful
 * for performing any tasks that should only take place once per integration
 * step.
 */
static void
mdlUpdate(DOUBLE *x, DOUBLE *u, SimStruct *S, int tid)
{
	FIS *fis = (FIS *)ssGetPWork(S)[0]; /* obtained from Pwork */
	int j;
	/*
	mexPrintf("In mdlUpdate!\n\n");
	*/

	/* dispatch inputs */
	for (j = 0; j < fis->in_n; j++)
		fis->node[j]->value = u[fis->in_n+j];
	/*
	PRINTARRAY(u, 2*(fis->in_n) + fis->out_n);
	*/
	
	/* forward calculation from layer 1 to layer 3 */
	/* The following can be commented out when mdlOutputs is
	called before mdlUpdate, which is usually true in SIMULINK */
	/* For safety, we restored it here */
	anfisForward(fis, fis->in_n, fis->layer[4]->index-1);

	/* prepare i/o pair for RLSE */
	/* The training data pair starts from position fis->in_n */
	anfisGetKalmanDataPair1(fis, u+fis->in_n);

	/* RLSE */
	anfisKalman(fis, 0);	/* normal operation */

	/* put RLSE identified parameters back into ANFIS */
	anfisPutKalmanParameter(fis);

	/* forward pass from layer 4 to 6 */
	anfisForward(fis, fis->layer[4]->index, fis->node_n-1);

	/* dispatch de_do at outputs */
	fis->node[fis->node_n-1]->de_do =
		-2*(u[2*(fis->in_n)] - fis->node[fis->node_n-1]->value);

	/* backward calculation */
	anfisBackward(fis, fis->node_n-2, fis->in_n);

	/* clear up de_dp */
	/* de_do is always cleared in anfisBackward */
	anfisClearDerivative(fis);

	/* update de_dp of layer 1*/
	anfisUpdateDE_DP(fis, fis->in_n,fis->layer[2]->index-1);

	/* update parameters in layer 1*/
	anfisUpdateParameter(fis, fis->in_n, fis->layer[2]->index-1);

	/* dummy update */
	x[0] = u[0];
}

/*
 * mdlDerivatives - compute the derivatives (dx)
 */
static void
mdlDerivatives(DOUBLE *dx, DOUBLE *x, DOUBLE *u, SimStruct *S, int tid)
{
}

/*
 * mdlTerminate - called when the simulation is terminated.
 */
static void
mdlTerminate(SimStruct *S)
{
	FIS *fis = (FIS *)ssGetPWork(S)[0];	/* obtained from Pwork */
	{
	DOUBLE **out_fismat;
	mxArray *OUT_FISMAT;
/*	mxArray *parray; */
	char *out_fis_name;
	int out_fis_name_leng;
	int k;
/*	int ret_val; */
	
	/* redirect parameters */
	/* fis->trn_best_para was used by anfisAnfis2FisMat */
	for (k = 0; k < fis->para_n; k++)
		fis->trn_best_para[k] = fis->para[k];
	out_fismat = fisCopyMatrix(fis->in_fismat, fis->m, fis->n);
	anfisAnfis2FisMat(fis, out_fismat, 0);
	OUT_FISMAT = c2matlab(out_fismat, fis->m, fis->n);
	out_fis_name_leng = mxGetN(OUT_FIS_NAME) + 1;
	out_fis_name = fisCalloc(out_fis_name_leng, sizeof(char));
	mxGetString(OUT_FIS_NAME, out_fis_name, out_fis_name_leng);
	mexPrintf("Write the FIS matrix %s to workspace ...\n", out_fis_name);
	if (mexPutVariable("caller", out_fis_name, OUT_FISMAT) != 0)
		fisError("Cannot create output FIS matrix!\n");
	mxFree(out_fis_name);
	mxDestroyArray(OUT_FISMAT);
	/*
	parray=mxCreateDoubleMatrix(0, 0, mxREAL)
	mxSetM(parray, fis->m);
	mxSetN(parray, fis->n);
	mxSetPr(parray, mxGetPr(OUT_FISMAT);
	mxSetName(parray, "SL_FISMAT");
	ret_val=mexPutArray(parray, "caller");
	mxFree(parray);
	fisFreeMatrix((void **)out_fismat, fis->m);
	mxFree(mxGetPr(OUT_FISMAT));
	*/
	}
	mexPrintf("Destroy ANFIS ...\n");
	fisFreeMatrix((void **)fis->in_fismat, fis->m);
	anfisFreeAnfis(fis);
	fisFreeFisNode(fis);
}

#ifdef	MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif

