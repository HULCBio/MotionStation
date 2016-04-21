/***********************************************************************
 Main functions for fuzzy inference 
 **********************************************************************/
/* Copyright 1994-2002 The MathWorks, Inc.  */
/* $Revision: $  $Date: $  */

/* Compute MF values for all input variables */
static void fisComputeInputMfValue(FIS *fis)
{
	int i, j;
	MF *mf_node;

	for (i = 0; i < fis->in_n; i++)
		for (j = 0; j < fis->input[i]->mf_n; j++) {
			mf_node = fis->input[i]->mf[j];
			if (!mf_node->userDefined)
				mf_node->value = (*mf_node->mfFcn)
					(fis->input[i]->value, mf_node->params);
			else {
#ifdef MATLAB_MEX_FILE
				mf_node->value =
					fisCallMatlabMf(fis->input[i]->value, mf_node->nparams, mf_node->params, mf_node->type);
#else
				PRINTF("Given MF %s is unknown.\n", mf_node->label);
				fisError("Exiting ...");
#endif
			}
		}
}

/* Compute rule output (for Sugeno model only) */
static void fisComputeTskRuleOutput(FIS *fis)
{
	int i, j, k;
	DOUBLE out;
	MF *mf_node;

	for (i = 0; i < fis->out_n; i++)
		for (j = 0; j < fis->output[i]->mf_n; j++) {
			mf_node = fis->output[i]->mf[j];
			out = 0;
			for (k = 0; k < fis->in_n; k++)
				out += (fis->input[k]->value)*(mf_node->params[k]);
			out = out + mf_node->params[fis->in_n];
			mf_node->value = out;
		}
}


/* Compute firing strengths */
static void fisComputeFiringStrength(FIS *fis)
{
	DOUBLE out = 0, mf_value;
	int i, j, which_mf;

	/* Compute original firing strengths via andFcn or orFcn */
	for (i = 0; i < fis->rule_n; i++) {
		if (fis->and_or[i] == 1) {	/* AND premise */
			for (j = 0; j < fis->in_n; j++) {
				which_mf = fis->rule_list[i][j];
				if (which_mf > 0)
					mf_value =fis->input[j]->mf[which_mf-1]->value;
				else if (which_mf == 0) /* Don't care */
					mf_value = 1;
				else		/* Linguistic hedge NOT */
					mf_value = 1 - fis->input[j]->mf[-which_mf-1]->value;
				fis->mfs_of_rule[j] = mf_value;
			}
			if (!fis->userDefinedAnd)
				out = fisArrayOperation(
					fis->mfs_of_rule, fis->in_n, fis->andFcn);
			else {
#ifdef MATLAB_MEX_FILE
				out = fisCallMatlabFcn(
					fis->mfs_of_rule, fis->in_n, fis->andMethod);
#else
				PRINTF("Given AND method %s is unknown.\n", fis->andMethod);
				fisError("Exiting ...");
#endif
			}
		} else {			/* OR premise */
			for (j = 0; j < fis->in_n; j++) {
				which_mf = fis->rule_list[i][j];
				if (which_mf > 0)
					mf_value =fis->input[j]->mf[which_mf-1]->value;
				else if (which_mf == 0) /* Don't care */
					mf_value = 0;
				else		/* Linguistic hedge NOT */
					mf_value = 1 - fis->input[j]->mf[-which_mf-1]->value;
				fis->mfs_of_rule[j] = mf_value;
			}
			if (!fis->userDefinedOr)
				out = fisArrayOperation(
					fis->mfs_of_rule, fis->in_n, fis->orFcn);
			else {
#ifdef MATLAB_MEX_FILE
				out = fisCallMatlabFcn(
					fis->mfs_of_rule, fis->in_n, fis->orMethod);
#else
				PRINTF("Given OR method %s is unknown.\n", fis->orMethod);
				fisError("Exiting ...");
#endif
			}
		}
		fis->firing_strength[i] = out;
	}

	/* Scale the original firing strength by rule_weight */
	for (i = 0; i < fis->rule_n; i++)
		fis->firing_strength[i] = 
			fis->rule_weight[i]*fis->firing_strength[i];
}

#ifdef MATLAB_MEX_FILE
/* Returns the n-th value of combined m-th output MF. */
/* (n is the index into the MF value arrays of the m-th output.) */
/* Both m and n are zero-offset */
/* (for Mamdani's model only */
/* This is used in mexFunction() of evalfis.c only */
static DOUBLE fisFinalOutputMf(FIS *fis, int m, int n)
{
	int i, which_mf;
	DOUBLE mf_value, out;

	/* The following should not be based on t-conorm */
	for (i = 0; i < fis->rule_n; i++) {
		/* rule_list is 1-offset */
		which_mf = fis->rule_list[i][fis->in_n+m];
		if (which_mf > 0)
			mf_value = fis->output[m]->mf[which_mf-1]->value_array[n];
		else if (which_mf == 0)	/* Don't care */
			mf_value = 0;
		else
			mf_value = 1-fis->output[m]->mf[-which_mf-1]->value_array[n];
		if (!fis->userDefinedImp)
			fis->rule_output[i] = (*fis->impFcn)(mf_value,
				fis->firing_strength[i]);
		else {
			DOUBLE tmp[2];
			tmp[0] = mf_value;
			tmp[1] = fis->firing_strength[i];
			fis->rule_output[i] = fisCallMatlabFcn(tmp, 2, fis->impMethod);
		}
	}
	if (!fis->userDefinedAgg)
		out = fisArrayOperation(fis->rule_output, fis->rule_n, fis->aggFcn);
	else
		out = fisCallMatlabFcn(fis->rule_output, fis->rule_n, fis->aggMethod);
	return(out);
}
#endif


/* Returns the aggregated MF aggMF of the m-th output variable . */
/* (for Mamdani's model only */
static void fisFinalOutputMf2(FIS *fis, int m, DOUBLE *aggMF, int numofpoints)
{
	int i, j, which_mf;

	/* fill in BigOutMfMatrix */
	/* The following should not be based on t-conorm */
	for (i = 0; i < fis->rule_n; i++) {
		which_mf = fis->rule_list[i][fis->in_n+m];
		if (which_mf > 0)
			for (j = 0; j < numofpoints; j++)
				/*
				fis->BigOutMfMatrix[i][j] = 
					fis->output[m]->mf[which_mf-1]->value_array[j];
				*/
				fis->BigOutMfMatrix[j*fis->rule_n+i] = 
					fis->output[m]->mf[which_mf-1]->value_array[j];
		else if (which_mf < 0)
			for (j = 0; j < numofpoints; j++)
				/*
				fis->BigOutMfMatrix[i][j] = 
					1-fis->output[m]->mf[-which_mf-1]->value_array[j];
				*/
				fis->BigOutMfMatrix[j*fis->rule_n+i] = 
					1 - fis->output[m]->mf[-which_mf-1]->value_array[j];
		else	/* which_mf == 0 */
			for (j = 0; j < numofpoints; j++)
				fis->BigOutMfMatrix[j*fis->rule_n+i] = 0; 
	}

	/* fill in BigWeightMatrix */
	for (i = 0; i < fis->rule_n; i++)
		for (j = 0; j < numofpoints; j++)
				fis->BigWeightMatrix[j*fis->rule_n+i] = 
					fis->firing_strength[i];

	/* apply implication operator */
	if (!fis->userDefinedImp)
		for (i = 0; i < (fis->rule_n)*numofpoints; i++)
			fis->BigOutMfMatrix[i] = (*fis->impFcn)(
				fis->BigWeightMatrix[i], fis->BigOutMfMatrix[i]);
	else {
#ifdef MATLAB_MEX_FILE
		fisCallMatlabFcn2(fis->BigWeightMatrix, fis->BigOutMfMatrix,
			fis->rule_n, numofpoints, fis->impMethod, fis->BigOutMfMatrix);
#else
				PRINTF("Given IMP method %s is unknown.\n", fis->impMethod);
				fisError("Exiting ...");
#endif
	}
	
	/* apply MATLAB aggregate operator */
	if (!fis->userDefinedAgg)
		for (i = 0; i < numofpoints; i++)
			aggMF[i] = fisArrayOperation(
			fis->BigOutMfMatrix+i*fis->rule_n,
			fis->rule_n, fis->aggFcn);
	else {
#ifdef MATLAB_MEX_FILE
		fisCallMatlabFcn1(fis->BigOutMfMatrix, fis->rule_n,
			numofpoints, fis->aggMethod, aggMF);
#else
		PRINTF("Given AGG method %s is unknown.\n", fis->aggMethod);
		fisError("Exiting ...");
#endif
	}
}

/***********************************************************************
 Evaluate the constructed FIS based on given input vector 
 **********************************************************************/

/* compute outputs and put them into output nodes */
void fisEvaluate(FIS *fis, int numofpoints)
{
	DOUBLE out = 0;
	DOUBLE total_w, total_wf;
	int i, j, k, which_mf;

	if (fis == NULL) {
		PRINTF("FIS data structure has not been built yet.\n");
		fisError("Exiting ...");
	}
	
	fisComputeInputMfValue(fis);
	fisComputeFiringStrength(fis);
	total_w = fisArrayOperation(fis->firing_strength, fis->rule_n, fisSum);
	if (total_w == 0) {
#ifdef SS_SFCN /* Do not generate warning for S-function */
		PRINTF("Warning: no rule is fired for input [");
		for (i = 0; i < fis->in_n; i++)
			PRINTF("%f ", fis->input[i]->value);
		PRINTF("]\n");
		PRINTF("Average of the range for each output variable is used as default output.\n\n");
#endif
		for (i = 0; i < fis->out_n; i++)
			fis->output[i]->value = (fis->output[i]->bound[0] +
				fis->output[i]->bound[1])/2;
		return;
	}

	if (strcmp(fis->type, "sugeno") == 0) {
	fisComputeTskRuleOutput(fis);
	/* Find each rule's output */
	for (i = 0; i < fis->out_n; i++) {
		for (j = 0; j < fis->rule_n; j++) {
			which_mf = fis->rule_list[j][fis->in_n + i] - 1;
			if (which_mf == -1)	/* don't_care consequent */
				fis->rule_output[j] = 0;
			else
				fis->rule_output[j] = fis->output[i]->mf[which_mf]->value;
		}
		/* Weighted average to find the overall output*/
		total_wf = 0;
		for (k = 0; k < fis->rule_n; k++)
			total_wf += (fis->firing_strength[k]*
				fis->rule_output[k]);

		if (strcmp(fis->defuzzMethod, "wtaver") == 0)
			fis->output[i]->value = total_wf/total_w;
		else if (strcmp(fis->defuzzMethod, "wtsum") == 0)
			fis->output[i]->value = total_wf;
		else {
			PRINTF("Unknown method (%s) for Sugeno model!", fis->defuzzMethod);
			fisError("Legal methods: wtaver, wtsum");
		}
	}
	}
	else if (strcmp(fis->type, "mamdani") == 0)
	for (i = 0; i < fis->out_n; i++) {
	/*	double aggMF[MF_POINT_N];
		double X[MF_POINT_N];*/
		DOUBLE *aggMF;
		DOUBLE *X;

		DOUBLE min = fis->output[i]->bound[0];
		DOUBLE max = fis->output[i]->bound[1];
		DOUBLE step = (max - min)/(numofpoints - 1);

                X = (DOUBLE *)fisCalloc(numofpoints, sizeof(DOUBLE));
                aggMF = (DOUBLE *)fisCalloc(numofpoints, sizeof(DOUBLE));      
                
		for (j = 0; j < numofpoints; j++)
			X[j] = min + step*j;
		/* fill in aggMF */
		fisFinalOutputMf2(fis, i, aggMF, numofpoints);
		/* defuzzification */
		if (!fis->userDefinedDefuzz)
			out = (*fis->defuzzFcn)(fis, i, aggMF, numofpoints);
		else {	/* user defined defuzzification */
#ifdef MATLAB_MEX_FILE
			out = fisCallMatlabDefuzz(X, aggMF, numofpoints, fis->defuzzMethod);
#else
			PRINTF("Given defuzzification method %s is unknown.\n", fis->defuzzMethod);
			fisError("Exiting ...");
#endif
		}
		fis->output[i]->value = out;
                FREE(X);
                FREE(aggMF);
	}
	else {
	PRINTF("Given FIS %s is unknown.\n", fis->name);
	fisError("Exiting ...");
	}
}

/* given input vector and FIS data structure, return output */
/* this is a wrap-up on fisEvaluate () */  
/* used in fismain() only */
static void getFisOutput(DOUBLE *input, FIS *fis, DOUBLE *output)
{
	int i;

	/* dispatch input */
	for (i = 0; i < fis->in_n; i++)
		fis->input[i]->value = input[i];

	/* evaluate FIS */
	fisEvaluate(fis, 101);

	/* dispatch output */
	for (i = 0; i < fis->out_n; i++)
		output[i] = fis->output[i]->value;
}
