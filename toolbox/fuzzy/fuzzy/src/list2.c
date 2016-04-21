/* Copyright 1994-2002 The MathWorks, Inc.  */
/* $Revision: $  $Date: $  */

/* copy string (the first 'length' characters) from array to target string */
static void fisGetString2(char *target, DOUBLE *array, int max_leng)
{
	int i;
	int actual_leng;

	/* Find the actual length of the string */
	/* If the string is not ended with 0, take max_leng */
	for (actual_leng = 0; actual_leng < max_leng; actual_leng++)
		if (array[actual_leng] == 0)
			break;

	if (actual_leng + 1 > STR_LEN) {
		PRINTF("actual_leng = %d\n", actual_leng);
		PRINTF("STR_LEN = %d\n", STR_LEN);
		fisError("String too long!");
	}
	for (i = 0; i < actual_leng; i++)
		target[i] = (char)array[i];
	target[actual_leng] = 0;
}

/* Check if there are abnormal situations is the FIS data structure */
/* Things being checked:
	1. MF indices out of bound.
	2. Rules with no premise part.
	3. Sugeno system with negated consequent.
	4. Sugeno system with zero consequent.
*/
void fisCheckDataStructure(FIS *fis)
{
	int i, j, mf_index;
	int found;

	/* check if MF indices are out of bound */
	for (i = 0; i < fis->rule_n; i++) {
		for (j = 0; j < fis->in_n; j++) {
			mf_index = fis->rule_list[i][j];
			if (ABS(mf_index) > fis->input[j]->mf_n) {
				PRINTF("MF index for input %d in rule %d is out of bound.\n", 
					j+1, i+1);
				fisFreeFisNode(fis);
				fisError("Exiting ...");
			}
		}
		for (j = 0; j < fis->out_n; j++) {
			mf_index = fis->rule_list[i][fis->in_n+j];
			if (ABS(mf_index) > fis->output[j]->mf_n) {
				PRINTF("MF index for output %d in rule %d is out of bound.\n", 
					j+1, i+1);
				fisFreeFisNode(fis);
				fisError("Exiting ...");
			}
		}
	}
	/* check if there is a rule whose premise MF indice are all zeros */ 
	for (i = 0; i < fis->rule_n; i++) {
		found = 1;
		for (j = 0; j < fis->in_n; j++) {
			mf_index = fis->rule_list[i][j];
			if (mf_index != 0) {
				found = 0;
				break;
			}
		}
		if (found == 1) {
			PRINTF("Rule %d has no premise part.\n", i+1);
			fisFreeFisNode(fis);
			fisError("Exiting ...");
		}
	}
	/* check if it's sugeno system with "NOT" consequent */
	if (strcmp(fis->type, "sugeno") == 0)
	for (i = 0; i < fis->rule_n; i++)
		for (j = 0; j < fis->out_n; j++) {
			mf_index = fis->rule_list[i][fis->in_n+j];
			if (mf_index < 0) {
				PRINTF("Rule %d has a 'NOT' consequent.\n", i+1);
				PRINTF("Sugeno fuzzy inference system does not allow this.\n");
				fisError("Exiting ...");
			}
		}
	/* check if it's sugeno system with zero consequent */
	if (strcmp(fis->type, "sugeno") == 0)
	for (i = 0; i < fis->rule_n; i++)
		for (j = 0; j < fis->out_n; j++) {
			mf_index = fis->rule_list[i][fis->in_n+j];
			if (mf_index == 0) {
				PRINTF("Warning: Output %d in rule %d has a zero MF index.\n", j+1, i+1);
				PRINTF("This output in the rule is assumed zero in subsequent calculation.\n\n");
			}
		}
}

/* Build FIS node and load parameter from fismatrix directly */
/* col_n is the number of columns of the fismatrix */
static void fisBuildFisNode(FIS *fis, DOUBLE **fismatrix, int col_n, int numofpoints)
{
	int i, j, k;
	int *in_mf_n, *out_mf_n;
	IO *io_list;
	int start;

	fisGetString2(fis->name, fismatrix[0], col_n);
	fisGetString2(fis->type, fismatrix[1], col_n);
	fis->in_n  = (int) fismatrix[2][0];
	fis->out_n = (int) fismatrix[2][1];

	/* create input node list */
	in_mf_n = (int *)fisCalloc(fis->in_n, sizeof(int));
	for (i = 0; i < fis->in_n; i++)
		in_mf_n[i] = (int) fismatrix[3][i];
	io_list = fisBuildIoList(fis->in_n, in_mf_n);
	FREE(in_mf_n);
	fis->input = (IO **)fisCalloc(fis->in_n, sizeof(IO *));
	for (i = 0; i < fis->in_n; i++)
		fis->input[i] = io_list+i;

	/* create output node list */
	out_mf_n = (int *)fisCalloc(fis->out_n, sizeof(int));
	for (i = 0; i < fis->out_n; i++)
		out_mf_n[i] = (int) fismatrix[4][i];
	io_list = fisBuildIoList(fis->out_n, out_mf_n);
	FREE(out_mf_n);
	fis->output = (IO **)fisCalloc(fis->out_n, sizeof(IO *));
	for (i = 0; i < fis->out_n; i++)
		fis->output[i] = io_list+i;

	fis->rule_n = (int) fismatrix[5][0];

	fisGetString2(fis->andMethod, fismatrix[6], col_n);
	fisGetString2(fis->orMethod, fismatrix[7], col_n);
	fisGetString2(fis->impMethod, fismatrix[8], col_n);
	fisGetString2(fis->aggMethod, fismatrix[9], col_n);
	fisGetString2(fis->defuzzMethod, fismatrix[10], col_n);

	start = 11;
	/* For efficiency, I/O names and MF labels are not stored */
	for (i = 0; i < fis->in_n; i++) {
		fis->input[i]->name[0] = '\0';
		for (j = 0; j < fis->input[i]->mf_n; j++)
			fis->input[i]->mf[j]->label[0] = '\0';
	}
	for (i = 0; i < fis->out_n; i++) {
		fis->output[i]->name[0] = '\0';
		for (j = 0; j < fis->output[i]->mf_n; j++)
			fis->output[i]->mf[j]->label[0] = '\0';
	}

	start = start + fis->in_n + fis->out_n;
	for (i = start; i < start + fis->in_n; i++) {
		fis->input[i-start]->bound[0] = fismatrix[i][0];
		fis->input[i-start]->bound[1] = fismatrix[i][1];
	}

	start = start + fis->in_n;
	for (i = start; i < start + fis->out_n; i++) {
		fis->output[i-start]->bound[0] = fismatrix[i][0];
		fis->output[i-start]->bound[1] = fismatrix[i][1];
	}

	/* update "start" to skip reading of MF labels */
	for (i = 0; i < fis->in_n; start += fis->input[i]->mf_n, i++);
	for (i = 0; i < fis->out_n; start += fis->output[i]->mf_n, i++);

	start = start + fis->out_n;
	for (i = 0; i < fis->in_n; i++)
		for (j = 0; j < fis->input[i]->mf_n; j++) {
			fisGetString2(fis->input[i]->mf[j]->type, fismatrix[start], col_n);
			start++;
		}

	for (i = 0; i < fis->out_n; i++)
		for (j = 0; j < fis->output[i]->mf_n; j++) {
			fisGetString2(fis->output[i]->mf[j]->type, fismatrix[start], col_n);
			start++;
		}

	fisAssignMfPointer(fis);
	fisAssignFunctionPointer(fis);

	/* get input MF parameters */
	for (i = 0; i < fis->in_n; i++) {
		for (j = 0; j < fis->input[i]->mf_n; j++) {
			fis->input[i]->mf[j]->nparams = MF_PARA_N;
			fis->input[i]->mf[j]->params = (DOUBLE *)fisCalloc(MF_PARA_N,sizeof(DOUBLE));
			for (k = 0; k < MF_PARA_N; k++)
				fis->input[i]->mf[j]->params[k] = fismatrix[start][k];
			start++;
		}
	}

	/* get Mamdani output MF parameters and compute MF value array */
	if (strcmp(fis->type, "mamdani") == 0) {
		for (i = 0; i < fis->out_n; i++)
			for (j = 0; j < fis->output[i]->mf_n; j++) {
				fis->output[i]->mf[j]->value_array =
					(DOUBLE *)fisCalloc(numofpoints, sizeof(DOUBLE));
				fis->output[i]->mf[j]->nparams = MF_PARA_N;
				fis->output[i]->mf[j]->params = 
					(DOUBLE *)fisCalloc(MF_PARA_N,sizeof(DOUBLE));
				for (k = 0; k < MF_PARA_N; k++)
					fis->output[i]->mf[j]->params[k] = fismatrix[start][k];
				start++;
			}
		fisComputeOutputMfValueArray(fis, numofpoints);
	/* get Sugeno output equation parameters */
	} else if (strcmp(fis->type, "sugeno") == 0) {
		for (i = 0; i < fis->out_n; i++)
			for (j = 0; j < fis->output[i]->mf_n; j++) {
				fis->output[i]->mf[j]->nparams = fis->in_n+1;
				fis->output[i]->mf[j]->params =
					(DOUBLE *)fisCalloc(fis->in_n+1, sizeof(DOUBLE));
				for (k = 0; k < fis->in_n+1; k++)
					fis->output[i]->mf[j]->params[k] = fismatrix[start][k];
				start++;
			}
	} else {
		PRINTF("fis->type = %s\n", fis->type);
		fisError("Unknown fis type!");
	}

	fis->rule_list = (int **)fisCreateMatrix
		(fis->rule_n, fis->in_n + fis->out_n, sizeof(int));
	fis->rule_weight = (DOUBLE *)fisCalloc(fis->rule_n, sizeof(DOUBLE));
	fis->and_or = (int *)fisCalloc(fis->rule_n, sizeof(int));
	for (i = 0; i < fis->rule_n; i++) {
		for (j = 0; j < fis->in_n + fis->out_n; j++)
			fis->rule_list[i][j] = (int)fismatrix[start][j];
		fis->rule_weight[i] = fismatrix[start][fis->in_n+fis->out_n];
		fis->and_or[i] = (int)fismatrix[start][fis->in_n+fis->out_n+1];
		start++;
	}

	fis->firing_strength = (DOUBLE *)fisCalloc(fis->rule_n, sizeof(DOUBLE));
	fis->rule_output = (DOUBLE *)fisCalloc(fis->rule_n, sizeof(DOUBLE));
	if (strcmp(fis->type, "mamdani") == 0) {
		fis->BigOutMfMatrix = (DOUBLE *)
			fisCalloc(fis->rule_n*numofpoints, sizeof(DOUBLE));
		fis->BigWeightMatrix = (DOUBLE *)
			fisCalloc(fis->rule_n*numofpoints, sizeof(DOUBLE));
	}
	fis->mfs_of_rule = (DOUBLE *)fisCalloc(fis->in_n, sizeof(DOUBLE));
	fisCheckDataStructure(fis);
}


/* load parameters and rule list from given fismatrix */
static void fisLoadParameter(FIS *fis, DOUBLE **fismatrix, int numofpoints)
{
	int start;
	int i, j, k;

	start = 11 + 2*(fis->in_n + fis->out_n);
	for (i = 0; i < fis->in_n; start += fis->input[i]->mf_n, i++);
	for (i = 0; i < fis->out_n; start += fis->output[i]->mf_n, i++);
	for (i = 0; i < fis->in_n; start += fis->input[i]->mf_n, i++);
	for (i = 0; i < fis->out_n; start += fis->output[i]->mf_n, i++);

	/* get input MF parameters */
	for (i = 0; i < fis->in_n; i++) {
		for (j = 0; j < fis->input[i]->mf_n; j++) {
			fis->input[i]->mf[j]->nparams = MF_PARA_N;
			fis->input[i]->mf[j]->params = (DOUBLE *)fisCalloc(MF_PARA_N,sizeof(DOUBLE));
			for (k = 0; k < MF_PARA_N; k++)
				fis->input[i]->mf[j]->params[k] = fismatrix[start][k];
			start++;
		}
	}

	/* get Mamdani output MF parameters */
	if (strcmp(fis->type, "mamdani") == 0) {
		for (i = 0; i < fis->out_n; i++)
			for (j = 0; j < fis->output[i]->mf_n; j++) {
				fis->output[i]->mf[j]->nparams = MF_PARA_N;
				fis->output[i]->mf[j]->params = 
					(DOUBLE *)fisCalloc(MF_PARA_N,sizeof(DOUBLE));
				for (k = 0; k < MF_PARA_N; k++)
					fis->output[i]->mf[j]->params[k] =
						fismatrix[start][k];
				start++;
			}
		fisComputeOutputMfValueArray(fis, numofpoints);

	/* get Sugeno output equation parameters */
	} else if (strcmp(fis->type, "sugeno") == 0) {
		for (i = 0; i < fis->out_n; i++)
			for (j = 0; j < fis->output[i]->mf_n; j++) {
				fis->output[i]->mf[j]->nparams = fis->in_n+1;
				fis->output[i]->mf[j]->params =
					(DOUBLE *)fisCalloc(fis->in_n+1, sizeof(DOUBLE));
				for (k = 0; k < fis->in_n+1; k++)
					fis->output[i]->mf[j]->params[k] =
						fismatrix[start][k];
				start++;
			}
	} else {
		PRINTF("fis->type = %s\n", fis->type);
		fisError("Unknown fis type!");
	}

	for (i = 0; i < fis->rule_n; i++) {
		for (j = 0; j < fis->in_n + fis->out_n; j++)
			fis->rule_list[i][j] = (int)fismatrix[start][j];
		fis->rule_weight[i] = fismatrix[start][fis->in_n+fis->out_n];
		fis->and_or[i] = (int)fismatrix[start][fis->in_n+fis->out_n+1];
		start++;
	}
}

/* load parameters contain in the given parameter array */
/* (Note that the array is compact, no zero padding */
static void fisLoadParameter1(FIS *fis, DOUBLE *para_array, int numofpoints)
{
	int start = 0;
	int paraN;
	int i, j, k;

	/* get input MF parameters */
	for (i = 0; i < fis->in_n; i++)
		for (j = 0; j < fis->input[i]->mf_n; j++) {
			paraN = fisGetMfParaN(fis->input[i]->mf[j]->type);
			fis->input[i]->mf[j]->nparams = paraN;
			fis->input[i]->mf[j]->params = 
				(DOUBLE *)fisCalloc(MF_PARA_N,sizeof(DOUBLE));
			for (k = 0; k < paraN; k++)
				fis->input[i]->mf[j]->params[k] = para_array[start++];
		}

	/* get Mamdani output MF parameters */
	if (strcmp(fis->type, "mamdani") == 0) {
		for (i = 0; i < fis->out_n; i++)
			for (j = 0; j < fis->output[i]->mf_n; j++) {
				paraN = fisGetMfParaN(fis->input[i]->mf[j]->type);
				fis->output[i]->mf[j]->nparams = paraN;
				fis->output[i]->mf[j]->params = 
					(DOUBLE *)fisCalloc(MF_PARA_N,sizeof(DOUBLE));
				for (k = 0; k < paraN; k++)
					fis->output[i]->mf[j]->params[k] = para_array[start++];
			}
		fisComputeOutputMfValueArray(fis, numofpoints);
	/* get Sugeno output equation parameters */
	} else if (strcmp(fis->type, "sugeno") == 0) {
		for (i = 0; i < fis->out_n; i++)
			for (j = 0; j < fis->output[i]->mf_n; j++)
				fis->output[i]->mf[j]->nparams = fis->in_n+1;
				fis->output[i]->mf[j]->params =
					(DOUBLE *)fisCalloc(fis->in_n+1, sizeof(DOUBLE));
				for (k = 0; k < fis->in_n+1; k++)
					fis->output[i]->mf[j]->params[k] =
						para_array[start++];
	} else {
		PRINTF("fis->type = %s\n", fis->type);
		fisError("Unknown fis type!");
	}
}

/* Returns a FIS pointer if there is a match; otherwise signals error */
static FIS *fisMatchHandle(FIS *head, int handle)
{
	FIS *p;

	for (p = head; p != NULL; p = p->next)
		if (p->handle == handle)
			break;
	if (p == NULL) {
		PRINTF("Given handle is %d.\n", handle);
		fisError("Cannot find an FIS with this handle.");
	}
	return(p);
}

/* Returns the FIS handle that matches a given name */
/* If more than two are qualified, the largest handle is returned.  */
static FIS *fisMatchName(FIS *head, char *name)
{
	FIS *p, *matched_p = NULL;

	for (p = head; p != NULL; p = p->next)
		if (strcmp(p->name, name) == 0)
			matched_p = p;
	return(matched_p);
}

static int fisFindMaxHandle(FIS *head)
{
	FIS *p;
	int max_handle = 0;

	if (head == NULL)
		return(0);

	for (p = head; p != NULL; p = p->next)
		if (p->handle > max_handle)
			max_handle = p->handle;
	return(max_handle);
}
