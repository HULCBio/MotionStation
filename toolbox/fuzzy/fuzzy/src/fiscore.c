/* Copyright 1994-2000 The MathWorks, Inc.  */
/* $Revision: $  $Date: $  */

#include "mex.h"

#include "fis.h"
#include "lib.c"
#include "mf.c"
#include "t_norm.c"
#include "defuzz.c"
#include "callml.c"
#include "list.c"
#include "list2.c"
#include "evaluate.c"

/***********************************************************************
 Main routine 
 **********************************************************************/

#define	HANDLE	prhs[0]		/* handle of FIS */
#define	ACTION	prhs[1]		/* action string */
#define	DATA	prhs[2]		/* data array */
#define	OUTPUT	plhs[0]		/* output */

static void
fisAtExit()
{
	int nlhs = 0;
	int nrhs = 3;
	mxArray **plhs = NULL;
	mxArray **prhs;

	prhs = (mxArray **)mxCalloc(nrhs, sizeof(mxArray *));
	HANDLE = mxCreateDoubleMatrix(1, 1, mxREAL);
	ACTION = mxCreateString("at_exit");
	DATA = mxCreateDoubleMatrix(1, 1, mxREAL);
	mexFunction(nlhs, plhs, nrhs, prhs);
}

void
mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
	double	*output, *input;
	unsigned int m ,n;
	int i, j, handle, data_n;
	FIS *p, *fis; 
	char action[STR_LEN], fisName[STR_LEN];
	static FIS *head = NULL, *curr_fis = NULL;
	static int initialized = 0;	/* for mexAtExit() */

	if (initialized == 0) {
		mexAtExit(fisAtExit);
		initialized = 1;
	}

	if (nrhs != 3)
		mexErrMsgTxt("Needs 3 arguments.");
	if (mxGetM(HANDLE) != 1 || mxGetN(HANDLE)!= 1)
		mexErrMsgTxt("The first argument must be a scalar.");
	if (!mxIsChar(ACTION))
		mexErrMsgTxt("The second argument must be an action string.");

	mxGetString(ACTION, action, mxGetN(ACTION)+1);
	handle = mxGetScalar(HANDLE);

	/* Evaluate the output of the FIS with the given handle*/
	/* If handle <= 0, use current FIS */
	if (strcmp(action, "evaluate") == 0) {
		fis = handle > 0 ? fisMatchHandle(head, handle): curr_fis;
		if (curr_fis == NULL)
			mexErrMsgTxt("No FIS in memory!");

		/* Check the dimensions of input vector */
		/* This is permissive - granted as long as enough inputs
		   are there. So the user can pass the original training data
		   directly */
		m = mxGetM(DATA);
		n = mxGetN(DATA);
		if (!((n >= fis->in_n) || ((n == 1) && (m >= fis->in_n)))) {
			mexPrintf("Input vector is of size %d by %d.\n", m, n);
			mexPrintf("Number of input variables should be %d.\n", fis->in_n);
			mexErrMsgTxt("Input vector has a wrong size!");
		}



		if ((n == 1) && (m == fis->in_n))
			data_n = 1;
		else
			data_n = m;

		/* Create a matrix for the return argument */
		OUTPUT = mxCreateDoubleMatrix(data_n, fis->out_n, mxREAL);

		for (i = 0; i < data_n; i++) {
			/* Assign pointers to the various parameters */
			output = mxGetPr(OUTPUT);
			input = mxGetPr(DATA);

			/* Dispatch the inputs */
			for (j = 0; j < fis->in_n; j++)
				fis->input[j]->value = input[j*data_n+i];
			/* Compute the output */
			fisEvaluate(fis);
			/* Collect the output */
			for (j = 0; j < fis->out_n; j++)
				output[j*data_n+i] = fis->output[j]->value;
		}
	}

	/* Load parameters (from another fismat) to FIS */
	else if (strcmp(action, "load_param") == 0) {
		double **fismatrix;
		int m, n;

		if (!mxIsNumeric(DATA))
			mexErrMsgTxt("The second argument must be a numeric data.");

		/* put fismatrix into proper format */
		m = mxGetM(DATA);
		n = mxGetN(DATA);
		fismatrix = (double **)fisCreateMatrix(m, n, sizeof(double));
		for (i = 0; i < m; i++)
			for (j = 0; j < n; j++)
				fismatrix[i][j] = mxGetPr(DATA)[j*m + i];

		/* Set FIS if handle > 0, otherwise use the original curr. FIS */
		fis = handle > 0 ? fisMatchHandle(head, handle): curr_fis;
		fisLoadParameter(fis, fismatrix);

		/* Free fismatrix */
		fisFreeMatrix((void **)fismatrix, m);
	}

	/* Load parameters (from an array) to FIS */
	else if (strcmp(action, "load_param1") == 0) {
		if (!mxIsNumeric(DATA))
			mexErrMsgTxt("The second argument must be a numeric data.");

		/* Set FIS if handle > 0, otherwise use the original curr. FIS */
		fis = handle > 0 ? fisMatchHandle(head, handle): curr_fis;
		fisLoadParameter1(fis, mxGetPr(DATA));
	}

	/* Build a new FIS node, add it to the end, and make it current */
	/* Build a new FIS node, add it to the end, and make it current */
	/* Name clash is not checked */
	else if (strcmp(action, "build") == 0) {
		double **fismatrix;
		int m, n;

		if (!mxIsNumeric(DATA))
			mexErrMsgTxt("The second argument must be a numeric data.");
		/* put fismatrix into proper format */
		m = mxGetM(DATA);
		n = mxGetN(DATA);
		fismatrix = (double **)fisCreateMatrix(m, n, sizeof(double));
		for (i = 0; i < m; i++)
			for (j = 0; j < n; j++)
				fismatrix[i][j] = mxGetPr(DATA)[j*m + i];

		/* Create FIS node */
		fis = (FIS *)calloc(1, sizeof(FIS));
		fisBuildFisNode(fis, fismatrix, n);
		fis->handle = fisFindMaxHandle(head) + 1;
		fis->next = NULL;

		/* Free fismatrix */
		fisFreeMatrix((void **)fismatrix, m);

		/* Create a matrix for the return argument */
		OUTPUT = mxCreateDoubleMatrix(1, 1, mxREAL);
		/* output[0] is equal to the handle of newly created FIS */
		output = mxGetPr(OUTPUT);

		if (head == NULL) {
			head = fis;
		} else {
			/* Find p as the tail of the FIS list */
			/* Also find the handle for this new node */
			for (p = head; p->next != NULL; p = p->next);
			p->next = fis;
		}
		/* curr_fis is the newly created fis */
		curr_fis = fis;
		output[0] = fis->handle;
	}

	/* Delete the current FIS, change the current FIS to head */
	/* If there is a valid handle, delete the FIS with that handle */
	else if (strcmp(action, "delete") == 0) {
		if (head  == NULL) {
			mexPrintf("No FIS in memory!\n");
			return;
		}

		/* Delete FIS with given valid handle. */
		/* If given handle is unvalid, delete the curretn FIS */
		fis = handle > 0 ? fisMatchHandle(head, handle): curr_fis;
		if (fis == head)
			head = head->next;
		else {
			/* find p such p->next == fis */
			for (p = head; p->next != fis; p = p->next);
			p->next = fis->next;
		}
		/* Change  current FIS to head if it is deleted */
		if (fis == curr_fis)
			curr_fis = head;
		fisFreeFisNode(fis);
	}

	/* Delete all data structure */
	/* This is used in mexAtExit only */
	else if (strcmp(action, "at_exit") == 0) {
		FIS *next, *now = head;
		/*
		if (head != NULL)
			mexPrintf("Destroying FIS data structures ...\n");
		*/
		while (now != NULL) {
			mexPrintf("Deleting %s FIS data structure...\n", now->name);
			next = now->next;
			fisFreeFisNode(now);
			now = next;
		}
	}

	/* Print the FIS with given handle. DATA is not used. */
	else if (strcmp(action, "print_fis_data") == 0) {
		fis = fisMatchHandle(head, handle);
		fisPrintData(fis);
	}

	/* Set current FIS by handle if handle > 0, otherwise by name */
	else if (strcmp(action, "set_current") == 0) {
		if (head == NULL)
			mexErrMsgTxt("No FIS is in memory!\n");
		if (handle <= 0) { /* by namee */
			if (!mxIsChar(DATA))
				mexErrMsgTxt("The third argument must be a string.");
			/* Create the fisName string */
			mxGetString(DATA, fisName, mxGetN(DATA)+1);

			fis = fisMatchName(head, fisName);
			if (fis == NULL)
				mexErrMsgTxt("Cannot find an FIS with the given name!");
		} else /* by handle */
			fis = fisMatchHandle(head, handle);
		curr_fis = fis;
	}

	/* Return the handle of the current FIS if DATA == [] */
	/* (Return 0 if the current FIS is NULL) */
	/* If DATA is not [], return handle with that name. */
	else if (strcmp(action, "return_handle") == 0) {
		OUTPUT = mxCreateDoubleMatrix(1, 1, mxREAL);
		if (mxIsNumeric(DATA) && (mxGetM(DATA) == 0) && (mxGetN(DATA) == 0))
			*(mxGetPr(OUTPUT)) = curr_fis == NULL ? 0:curr_fis->handle;
		else { /* return handle with given name */
			if (!mxIsChar(DATA))
				mexErrMsgTxt("The third argument must be a string.");
			/* Create the fisName string */
			mxGetString(DATA, fisName, mxGetN(DATA)+1);

			fis = fisMatchName(head, fisName);
			if (fis == NULL)
				mexErrMsgTxt("Cannot find an FIS with the given name!");
			*(mxGetPr(OUTPUT)) = fis == NULL ? 0:fis->handle;
		}
	}

	else if (strcmp(action, "print_name") == 0) {
		/* print name of FIS with given handle */
		if (head == NULL)
			mexErrMsgTxt("No FIS is in memory.");
		fis = handle > 0 ? fisMatchHandle(head, handle): curr_fis;
		mexPrintf("%s\n", fis->name);
	}

	else if (strcmp(action, "list_all") == 0) {
		if (head == NULL) {
			mexPrintf("No FIS is in memory.\n");
			return;
		}
		for (p = head; p != NULL; p = p->next) {
			/*
			mexPrintf("p = %d\t", p);
			mexPrintf("p->next = %d\n", p->next);
			*/
			mexPrintf("\t%d\t%s\n", p->handle, p->name);
		}
		mexPrintf("\n");
	}

	/* Unrecognized action string */
	else {
		mexPrintf("The action string %s is not recognized!\n", action);
		return;
	}
}
