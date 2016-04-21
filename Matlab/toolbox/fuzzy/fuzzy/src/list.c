/***********************************************************************
 Data structure: construction, printing, and destruction 
 **********************************************************************/
/* Copyright 1994-2002 The MathWorks, Inc.  */
/* $Revision: $  $Date: $  */

IO *fisBuildIoList(int node_n, int *mf_n)
{
	IO *io_list;
	int i, j;

	io_list = (IO *)fisCalloc(node_n, sizeof(IO));
	for (i = 0; i < node_n; i++) {
		io_list[i].mf_n = mf_n[i];
		io_list[i].mf = (MF **)fisCalloc(mf_n[i], sizeof(MF *));
		if (mf_n[i] > 0)	/* check if no MF at all */
			io_list[i].mf[0] = (MF *)fisCalloc(mf_n[i], sizeof(MF));
		for (j = 0; j < mf_n[i]; j++)
			io_list[i].mf[j] = io_list[i].mf[0] + j;
	}
	return(io_list);
}

/* Assign a MF pointer to each MF node based on the MF node's type */
void fisAssignMfPointer(FIS *fis)
{
	int i, j, k, mfTypeN = 13, found;
	MF *mf_node;
	struct command {
		char *mfType;
        DOUBLE (*mfFcn)(DOUBLE, DOUBLE *);
	} dispatch[] = {
		{ "trimf",	fisTriangleMf },
		{ "trapmf",	fisTrapezoidMf },
		{ "gaussmf",	fisGaussianMf },
		{ "gauss2mf",	fisGaussian2Mf },
		{ "sigmf",	fisSigmoidMf },
		{ "dsigmf",	fisDifferenceSigmoidMf },
		{ "psigmf",	fisProductSigmoidMf },
		{ "gbellmf",	fisGeneralizedBellMf },
		{ "smf",	fisSMf },
		{ "zmf",	fisZMf },
		{ "pimf",	fisPiMf },
		{ "linear",	NULL },
		{ "constant",	NULL }
	};

	/* input MF's */
	for (i = 0; i < fis->in_n; i++)
		for (j = 0; j < fis->input[i]->mf_n; j++) {
			mf_node = fis->input[i]->mf[j];
			found = 0;
			for (k = 0; k < mfTypeN-2; k++) {
				if (strcmp(mf_node->type, dispatch[k].mfType) == 0) {
					mf_node->mfFcn = dispatch[k].mfFcn;
					found = 1;
					break;
				}
			}
			if (found == 0) {
#ifdef MATLAB_MEX_FILE
			{
				DOUBLE function_type;
				function_type = fisCallMatlabExist(mf_node->type);
				if (function_type == 0) {
					PRINTF("MF '%s' does not exist!\n", mf_node->type);
					fisError("Exiting ...");
				}
				if (function_type == 1) {
					PRINTF("MF '%s' is a MATLAB variable!\n", mf_node->type);
					fisError("Exiting ...");
				}
				mf_node->userDefined = 1;
			}
#else
				PRINTF("MF type '%s' for input %d is unknown.\n",
					mf_node->type, i+1);
				PRINTF("Legal input MF types: ");
				for (i = 0; i < mfTypeN-2; i++)
					PRINTF("%s ", dispatch[i].mfType);
				fisError("\n");
#endif
			}
		}

	/* output MF's */
	for (i = 0; i < fis->out_n; i++)
		for (j = 0; j < fis->output[i]->mf_n; j++) {
			mf_node = fis->output[i]->mf[j];
			found = 0;
			for (k = 0; k < mfTypeN; k++) {
				if (strcmp(mf_node->type, dispatch[k].mfType) == 0) {
					mf_node->mfFcn = dispatch[k].mfFcn;
					found = 1;
					break;
				}
			}
			if (found == 0) {
#ifdef MATLAB_MEX_FILE
			{
				DOUBLE function_type;
				function_type = fisCallMatlabExist(mf_node->type);
				if (function_type == 0) {
					PRINTF("MATLAB function '%s' does not exist!\n", mf_node->type);
					fisError("Exiting ...");
				}
				if (function_type == 1) {
					PRINTF("'%s' is a MATLAB variable!\n", mf_node->type);
					fisError("Exiting ...");
				}
				mf_node->userDefined = 1;
			}
#else
				PRINTF("MF type '%s' for output %d is unknown.\n",
					mf_node->type, i+1);
				PRINTF("Legal output MF types: ");
				for (i = 0; i < mfTypeN-1; i++)
					PRINTF("%s ", dispatch[i].mfType);
				fisError("\n");
#endif
			}
		}
}

/* Assign a other function pointers */
void fisAssignFunctionPointer(FIS *fis)
{
	/* assign andMethod function pointer */
	if (strcmp(fis->andMethod, "prod") == 0)
		fis->andFcn = fisProduct;
	else if (strcmp(fis->andMethod, "min") == 0)
		fis->andFcn = fisMin;
	else {
#ifdef MATLAB_MEX_FILE
	{
		DOUBLE function_type;
		function_type = fisCallMatlabExist(fis->andMethod);
		if (function_type == 0) {
			PRINTF("AND function '%s' does not exist!\n", fis->andMethod);
			fisError("Exiting ...");
		}
		if (function_type == 1) {
			PRINTF("AND function '%s' is a MATLAB variable!\n", fis->andMethod);
			fisError("Exiting ...");
		}
		fis->userDefinedAnd = 1;
	}
#else
		PRINTF("Given andMethod %s is unknown.\n", fis->andMethod);
		fisError("Legal andMethod: min, prod");
#endif
	}

	/* assign orMethod function pointer */
	if (strcmp(fis->orMethod, "probor") == 0)
		fis->orFcn = fisProbOr;
	else if (strcmp(fis->orMethod, "max") == 0)
		fis->orFcn = fisMax;
	else {
#ifdef MATLAB_MEX_FILE
	{
		DOUBLE function_type;
		function_type = fisCallMatlabExist(fis->orMethod);
		if (function_type == 0) {
			PRINTF("OR function '%s' does not exist!\n", fis->orMethod);
			fisError("Exiting ...");
		}
		if (function_type == 1) {
			PRINTF("OR function '%s' is a MATLAB variable!\n", fis->orMethod);
			fisError("Exiting ...");
		}
		fis->userDefinedOr = 1;
	}
#else
		PRINTF("Given orMethod %s is unknown.\n", fis->orMethod);
		fisError("Legal orMethod: max, probor");
#endif
	}

	/* assign impMethod function pointer */
	if (strcmp(fis->impMethod, "prod") == 0)
		fis->impFcn = fisProduct;
	else if (strcmp(fis->impMethod, "min") == 0)
		fis->impFcn = fisMin;
	else {
#ifdef MATLAB_MEX_FILE
	{
		DOUBLE function_type;
		function_type = fisCallMatlabExist(fis->impMethod);
		if (function_type == 0) {
			PRINTF("IMPLICATION function '%s' does not exist!\n", fis->impMethod);
			fisError("Exiting ...");
		}
		if (function_type == 1) {
			PRINTF("IMPLICATION function '%s' is a MATLAB variable!\n", fis->impMethod);
			fisError("Exiting ...");
		}
		fis->userDefinedImp = 1;
	}
#else
		PRINTF("Given impMethod %s is unknown.\n", fis->impMethod);
		fisError("Legal impMethod: min, prod");
#endif
	}

	/* assign aggMethod function pointer */
	if (strcmp(fis->aggMethod, "max") == 0)
		fis->aggFcn = fisMax;
	else if (strcmp(fis->aggMethod, "probor") == 0)
		fis->aggFcn = fisProbOr;
	else if (strcmp(fis->aggMethod, "sum") == 0)
		fis->aggFcn = fisSum;
	else {
#ifdef MATLAB_MEX_FILE
	{
		DOUBLE function_type;
		function_type = fisCallMatlabExist(fis->aggMethod);
		if (function_type == 0) {
			PRINTF("AGGREGATE function '%s' does not exist!\n", fis->aggMethod);
			fisError("Exiting ...");
		}
		if (function_type == 1) {
			PRINTF("AGGREGATE function '%s' is a MATLAB variable!\n", fis->aggMethod);
			fisError("Exiting ...");
		}
		fis->userDefinedAgg = 1;
	}
#else
		PRINTF("Given aggMethod %s is unknown.\n", fis->aggMethod);
		fisError("Legal aggMethod: max, probor, sum");
#endif
	}

	/* assign defuzzification function pointer */
	if (strcmp(fis->defuzzMethod, "centroid") == 0)
		fis->defuzzFcn = defuzzCentroid;
	else if (strcmp(fis->defuzzMethod, "bisector") == 0)
		fis->defuzzFcn = defuzzBisector;
	else if (strcmp(fis->defuzzMethod, "mom") == 0)
		fis->defuzzFcn = defuzzMeanOfMax;
	else if (strcmp(fis->defuzzMethod, "som") == 0)
		fis->defuzzFcn = defuzzSmallestOfMax;
	else if (strcmp(fis->defuzzMethod, "lom") == 0)
		fis->defuzzFcn = defuzzLargestOfMax;
	else if (strcmp(fis->defuzzMethod, "wtaver") == 0)
		;
	else if (strcmp(fis->defuzzMethod, "wtsum") == 0)
		;
	else {
#ifdef MATLAB_MEX_FILE
	{
		DOUBLE function_type;
		function_type = fisCallMatlabExist(fis->defuzzMethod);
		if (function_type == 0) {
			PRINTF("DEFUZZIFICATION function '%s' does not exist!\n", fis->defuzzMethod);
			fisError("Exiting ...");
		}
		if (function_type == 1) {
			PRINTF("DEFUZZIFICATION function '%s' is a MATLAB variable!\n", fis->defuzzMethod);
			fisError("Exiting ...");
		}
		fis->userDefinedDefuzz = 1;
	}
#else
		PRINTF("Given defuzzification method %s is unknown.\n", fis->defuzzMethod);
		fisError("Legal defuzzification methods: centroid, bisector, mom, som, lom, wtaver, wtsum");
#endif
	}
}

#ifndef NO_PRINTF
static void fisPrintData(FIS *fis)
{
	int i, j, k;

	if (fis == NULL)
		fisError("Given fis pointer is NULL, no data to print!");

	PRINTF("fis_name = %s\n", fis->name);
	PRINTF("fis_type = %s\n", fis->type);
	PRINTF("in_n = %d\n", fis->in_n);
	PRINTF("out_n = %d\n", fis->out_n);

	PRINTF("in_mf_n: ");
	for (i = 0; i < fis->in_n; i++)
		PRINTF("%d ", fis->input[i]->mf_n);
	PRINTF("\n");

	PRINTF("out_mf_n: ");
	for (i = 0; i < fis->out_n; i++)
		PRINTF("%d ", fis->output[i]->mf_n);
	PRINTF("\n");

	PRINTF("rule_n = %d\n", fis->rule_n);

	PRINTF("andMethod = %s\n", fis->andMethod);
	PRINTF("orMethod = %s\n", fis->orMethod);
	PRINTF("impMethod = %s\n", fis->impMethod);
	PRINTF("aggMethod = %s\n", fis->aggMethod);
	PRINTF("defuzzMethod = %s\n", fis->defuzzMethod);

	/*
	for (i = 0; i < fis->in_n; i++) {
		printf("Input variable %d = %s\n", i+1, fis->input[i]->name);
		for (j = 0; j < fis->input[i]->mf_n; j++)
			printf("\t Label for MF %d = %s\n", j+1, fis->input[i]->mf[j]->label);
	}

	for (i = 0; i < fis->out_n; i++) {
		printf("Output variable %d = %s\n", i+1, fis->output[i]->name);
		for (j = 0; j < fis->output[i]->mf_n; j++)
			printf("\t Label for MF %d = %s\n", j+1, fis->output[i]->mf[j]->label);
	}
	*/

	for (i = 0; i < fis->in_n; i++)
		PRINTF("Bounds for input variable %d: [%6.3f %6.3f]\n", i+1,
			fis->input[i]->bound[0], fis->input[i]->bound[1]);

	for (i = 0; i < fis->out_n; i++)
		PRINTF("Bounds for output variable %d: [%6.3f %6.3f]\n", i+1,
			fis->output[i]->bound[0], fis->output[i]->bound[1]);

	for (i = 0; i < fis->in_n; i++) {
		PRINTF("MF for input variable %d (%s):\n", i+1, fis->input[i]->name);
		for (j = 0; j < fis->input[i]->mf_n; j++)
			PRINTF("\t Type for MF %d = %s\n", j+1, fis->input[i]->mf[j]->type);
	}

	for (i = 0; i < fis->out_n; i++) {
		PRINTF("MF for output variable %d (%s):\n", i+1, fis->output[i]->name);
		for (j = 0; j < fis->output[i]->mf_n; j++)
			PRINTF("\t Type for MF %d = %s\n", j+1, fis->output[i]->mf[j]->type);
	}

	PRINTF("Rule list:\n");
	for (i = 0; i < fis->rule_n; i++) {
		for (j = 0; j < fis->in_n + fis->out_n; j++)
			PRINTF("%d ", fis->rule_list[i][j]);
		PRINTF("\n");
	}

	PRINTF("Rule weights:\n");
	for (i = 0; i < fis->rule_n; i++)
		PRINTF("%f\n", fis->rule_weight[i]);

	PRINTF("AND-OR indicator:\n");
	for (i = 0; i < fis->rule_n; i++)
		PRINTF("%d\n", fis->and_or[i]);

	for (i = 0; i < fis->in_n; i++) {
		PRINTF("MF parameters for input variable %d (%s):\n",
			i+1, fis->input[i]->name);
		for (j = 0; j < fis->input[i]->mf_n; j++) {
			PRINTF("\tParameters for MF %d (%s) (%s): ",
				j+1, fis->input[i]->mf[j]->label,
				fis->input[i]->mf[j]->type);
			for (k = 0; k < fis->input[i]->mf[j]->nparams; k++)
				PRINTF("%6.3f ", fis->input[i]->mf[j]->params[k]);
			PRINTF("\n");
		}
	}

	for (i = 0; i < fis->out_n; i++) {
		PRINTF("MF parameters for output variable %d (%s):\n",
				i+1, fis->output[i]->name);
			for (j = 0; j < fis->output[i]->mf_n; j++) {
				PRINTF("\tParameters for MF %d (%s) (%s): ",
					j+1, fis->output[i]->mf[j]->label,
					fis->output[i]->mf[j]->type);
				for (k = 0; k < fis->output[i]->mf[j]->nparams; k++)
					PRINTF("%6.3f ", fis->output[i]->mf[j]->params[k]);
				PRINTF("\n");
			}
	}
}
#endif


static void fisFreeMfList(MF *mf_list, int n)
{
	int i;

	for (i = 0; i < n; i++) {
		FREE(mf_list[i].params);
		FREE(mf_list[i].value_array);
	}
	FREE(mf_list);
}


static void fisFreeIoList(IO *io_list, int n)
{
	int i;
	for (i = 0; i < n; i++) {
		if (io_list[i].mf_n > 0)	/* check if no MF at all */
			fisFreeMfList(io_list[i].mf[0], io_list[i].mf_n);
		FREE(io_list[i].mf);
	}
	FREE(io_list);
}

void fisFreeFisNode(FIS *fis)
{
	if (fis == NULL)
		return;
	fisFreeIoList(fis->input[0], fis->in_n);
	FREE(fis->input);
	fisFreeIoList(fis->output[0], fis->out_n);
	FREE(fis->output);
#ifdef FREEMAT
	FREEMAT((void **)fis->rule_list, fis->rule_n);
#else
	fisFreeMatrix((void **)fis->rule_list, fis->rule_n);
#endif
	FREE(fis->rule_weight);
	FREE(fis->and_or);
	FREE(fis->firing_strength);
	FREE(fis->rule_output);
	FREE(fis->BigOutMfMatrix);
	FREE(fis->BigWeightMatrix);
	FREE(fis->mfs_of_rule);
	FREE(fis);
}

/* Compute arrays of MF values (for Mamdani model only) */
/* This is done whenever new parameters are loaded */
void fisComputeOutputMfValueArray(FIS *fis, int numofpoints)
{
	int i, j, k;
	DOUBLE x, lx, ux, dx;
	MF *mf_node;
	for (i = 0; i < fis->out_n; i++) {
		lx = fis->output[i]->bound[0];
		ux = fis->output[i]->bound[1];
		dx = (ux - lx)/(numofpoints - 1);
		for (j = 0; j < fis->output[i]->mf_n; j++) {
			mf_node = fis->output[i]->mf[j];
			if (!mf_node->userDefined)
				for (k = 0; k < numofpoints; k++) {
					x = lx + k*dx;
					mf_node->value_array[k] =
					(*mf_node->mfFcn)(x, mf_node->params);
				}
			else { 	/* user defined MF */
#ifdef MATLAB_MEX_FILE
				/* this is vector version */
				{
					DOUBLE *X;
					X = (DOUBLE *)fisCalloc(numofpoints, sizeof(DOUBLE));
					/*	double X[numofpoints]; */
					for (k = 0; k < numofpoints; k++)
						X[k] = lx + k*dx;
					fisCallMatlabMf2(X, mf_node->nparams, mf_node->params, 
						mf_node->type, numofpoints, mf_node->value_array);
					FREE(X);
				}
#else
				PRINTF("Cannot find MF type %s!\n", mf_node->type);
				fisError("Exiting ...");
#endif
			}
		}
	}
}

