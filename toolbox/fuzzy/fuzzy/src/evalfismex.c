/* Copyright 1994-2002 The MathWorks, Inc.  */
/* $Revision: 1.12 $ */

#include "mex.h" 
#include "fis.h"

#if (defined(MATLAB_MEX_FILE) && !defined(__SIMSTRUC__))
# define FREE mxFree
#else
# define FREE free
#endif


#include "lib.c"
#include "mf.c"
#include "t_norm.c"
#include "defuzz.c"
#include "callml.c"
#include "list.c"
#include "list2.c"
#include "evaluate.c"
#include "matlab2c.c"

#define	INPUT		prhs[0]		/* input of FIS */
#define	FISMATRIX	prhs[1]		/* FIS matrix */
#define NUMOFPOINT      prhs[2]         /* number of points */
#define	OUTPUT		plhs[0]		/* output */
#define	IRR		plhs[1]		/* input mf matrix */
#define	ORR		plhs[2]		/* output mf matrix */
#define	ARR		plhs[3]		/* aggregated output mf */

/* void */
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
	DOUBLE *input, *output, *irr, *orr, *arr;
	int i, j, m, n, data_n, in_n, numofpoints;
	FIS *fis;

    DOUBLE *numofpointPt;
	int which_rule, which_output, which_mf;
	DOUBLE tmp, tmp_vec[2], mf_value;

	if (nrhs != 3)
	mexErrMsgTxt("Needs 3 input arguments.");
    if (!mxIsDouble(INPUT))
	mexErrMsgTxt("The first input must be a defined DOUBLE matrix");

    if (!mxIsStruct(FISMATRIX))
	mexErrMsgTxt("The Second input must be a structure.");


	/* Check the dimensions of input vector */
	/* This is permissive - granted as long as enough inputs
	   are there. So the user can pass the original training data
	   directly */
    m=mxGetM(NUMOFPOINT);
    numofpointPt=mxGetPr(NUMOFPOINT);
    if (m > 0 && numofpointPt[0] > 101)  numofpoints=(int)numofpointPt[0];
    else  numofpoints=101;

	m = mxGetM(INPUT);
	n = mxGetN(INPUT);

/*=====================*/
    fis=matlab2cStr(prhs[1], numofpoints);
/*=====================*/
	if (!((n >= fis->in_n) || ((n == 1) && (m >= fis->in_n)))) {
		mexPrintf("The input vector is of size %dx%d,", m, n);
		mexPrintf("while expected input vector size is %d.\n", fis->in_n);
		mexErrMsgTxt("Exiting ...");
	}
	if ((n == 1) && (m == fis->in_n))
		data_n = 1;
	else
		data_n = m;

	/* signal error if multiple input vectors and mutiple output arguments */
	/*
	if ((data_n > 1) && (nlhs > 1))
		mexErrMsgTxt("Multiple output arguments can only be used with a single input vector.");
	*/


	/* Create matrices for returned arguments */
	OUTPUT = mxCreateDoubleMatrix(data_n, fis->out_n, mxREAL);

	for (i = 0; i < data_n; i++) {
	    /* Assign pointers to the various parameters */
		output = mxGetPr(OUTPUT);
		input = mxGetPr(INPUT);

		/* Dispatch the inputs */
		for (j = 0; j < fis->in_n; j++)
			fis->input[j]->value = input[j*data_n+i];
		/* Compute the output */
		fisEvaluate(fis, numofpoints);
		/* Collect the output */
		for (j = 0; j < fis->out_n; j++)
			output[j*data_n+i] = fis->output[j]->value;
	}

	/* take care of additonal output arguments */
	if (nlhs >= 2) {
		IRR = mxCreateDoubleMatrix(fis->rule_n, fis->in_n, mxREAL);
		irr = mxGetPr(IRR);
		for (i = 0; i < fis->rule_n; i++)
			for (j = 0; j < fis->in_n; j++) {
				which_mf = fis->rule_list[i][j];
				if (which_mf > 0)
					mf_value = fis->input[j]->mf[which_mf-1]->value;
				else if (which_mf == 0) {
				/* Don't care; mf_value depends on AND or OR */
					if (fis->and_or[i] == 1)	/* AND */
						mf_value = 1;
					else
						mf_value = 0;
					}
				else            /* Linguistic hedge NOT */
					mf_value = 1 - fis->input[j]->mf[-which_mf-1]->value;
				irr[j*fis->rule_n+i] = mf_value;
			}
	}

	if (nlhs >= 3) {
		if (strcmp(fis->type, "mamdani") == 0) {
			ORR = mxCreateDoubleMatrix(numofpoints, (fis->rule_n)*(fis->out_n), mxREAL);
			orr = mxGetPr(ORR);
			for (i = 0; i < numofpoints; i++)
				for (j = 0; j < (fis->rule_n)*(fis->out_n); j++) {
					which_rule = j%(fis->rule_n);	/* zero offset */
					which_output = j/(fis->rule_n);	/* zero offset */
					which_mf = fis->rule_list[which_rule][fis->in_n+which_output];
					if (which_mf > 0)
						tmp = fis->output[which_output]->mf[which_mf-1]->value_array[i];
					else if (which_mf == 0)
						tmp = 0;
					else
						tmp = 1-fis->output[which_output]->mf[-which_mf-1]->value_array[i];
					/*
					mexPrintf("rule = %d, output = %d, mf = %d\n", which_rule,
						which_output, which_mf);
					*/
					if (!fis->userDefinedImp) 
						orr[j*numofpoints+i] = (*fis->impFcn)(tmp,
							fis->firing_strength[which_rule]);
					else {
						tmp_vec[0] = tmp;
						tmp_vec[1] = fis->firing_strength[which_rule];
						orr[j*numofpoints+i] = 
							fisCallMatlabFcn(tmp_vec, 2, fis->impMethod);
        			}
				}
		}
		if (strcmp(fis->type, "sugeno") == 0) {
			ORR = mxCreateDoubleMatrix(fis->rule_n, fis->out_n, mxREAL);
			orr = mxGetPr(ORR);
			for (i = 0; i < fis->rule_n; i++)
				for (j = 0; j < fis->out_n; j++) {
					which_mf = fis->rule_list[i][fis->in_n+j]-1;
					/*
					mexPrintf("mf = %d\n", which_mf);
					*/
					if (which_mf == -1)	/* don't_care consequent */
						orr[j*fis->rule_n+i] = 0;
					else
						orr[j*fis->rule_n+i] = fis->output[j]->mf[which_mf]->value;
				}
		}
	}

	if (nlhs >= 4) {
		if (strcmp(fis->type, "mamdani") == 0) {
			ARR = mxCreateDoubleMatrix(numofpoints, fis->out_n, mxREAL);
			arr = mxGetPr(ARR);
			for (i = 0; i < numofpoints; i++)
				for (j = 0; j < fis->out_n; j++)
					arr[j*numofpoints+i] = fisFinalOutputMf(fis, j, i);
		}
		if (strcmp(fis->type, "sugeno") == 0) {
			ARR = mxCreateDoubleMatrix(fis->rule_n, fis->out_n, mxREAL);
			arr = mxGetPr(ARR);
			for (i = 0; i < fis->rule_n; i++)
				for (j = 0; j < fis->out_n; j++)
					arr[j*fis->rule_n+i] = fis->firing_strength[i];
		}
	}

	/* destroy FIS data structure */
	fisFreeFisNode(fis);
}
