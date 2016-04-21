/* Copyright 1994-2002 The MathWorks, Inc.  */
/* $Revision: 1.10 $ */

#ifdef MATLAB_MEX_FILE

FIS *matlab2cStr(const mxArray *matlabmat, int numofpoints)
{
	int i, j, k, param_size, data_size, status, buflen=100;
    mxArray *fispointer, *inputpointer, *mfpointer;
	FIS *fis;
    DOUBLE *real_data_ptr;
	int *in_mf_n, *out_mf_n;
	IO *io_list;

	/*----------- Create FIS node -------------------*/
	/* allocate space for FIS structure */
	fis = (FIS *)fisCalloc(1, sizeof(FIS));
    if (fis == NULL)  return(NULL); 
    /* get fis name, type, ....*/
    fispointer=mxGetField(matlabmat, 0,"name");
    status=mxGetString(fispointer, fis->name, buflen);
    /* fis->type */
    fispointer=mxGetField(matlabmat, 0,"type");
    status=mxGetString(fispointer, fis->type, buflen);
    if (status!=0) fisError("Can not get fis type");
    /* fis->andMethod */
    fispointer=mxGetField(matlabmat, 0,"andMethod");
    status=mxGetString(fispointer, fis->andMethod, buflen);
    if (status!=0) fisError("Can not get fis andMethod");
    /* fis->orMethod */
    fispointer=mxGetField(matlabmat, 0,"orMethod");
    status=mxGetString(fispointer, fis->orMethod, buflen);
    if (status!=0) fisError("Can not get fis orMethod");
    /* fis->defuzzMethod */
    fispointer=mxGetField(matlabmat, 0,"defuzzMethod");
    status=mxGetString(fispointer, fis->defuzzMethod, buflen);
    if (status!=0) fisError("Can not get fis defuzzMethod");
    /* fis->impMethod */
    fispointer=mxGetField(matlabmat, 0,"impMethod");
    status=mxGetString(fispointer, fis->impMethod, buflen);
    if (status!=0) fisError("Can not get fis impMethod");
    /* fis->aggMethod */
    fispointer=mxGetField(matlabmat, 0,"aggMethod");
    status=mxGetString(fispointer, fis->aggMethod, buflen);
    if (status!=0) fisError("Can not get fis aggMethod");

	/* inputs */
    fispointer = mxGetField(matlabmat, 0,"input");
	fis->in_n = mxGetN(fispointer);
       
	/* create input node list, each in_mf_n's element containts the number of mf */
	in_mf_n = (int *)fisCalloc(fis->in_n, sizeof(int));
	for (i = 0; i < fis->in_n; i++){
        inputpointer = mxGetField(fispointer, i, "mf"); 
        if (inputpointer!=NULL)
            in_mf_n[i] = mxGetN(inputpointer);
        else
            in_mf_n[i] = 0;
        }
	io_list = fisBuildIoList(fis->in_n, in_mf_n);
    FREE(in_mf_n);

	/* allocate memory for input list */
	/* REVISIT: why using a **IO for fis->input as opposed to a *IO ?? */
	fis->input = (IO **)fisCalloc(fis->in_n, sizeof(IO *));
	for (i = 0; i < fis->in_n; i++)
		fis->input[i] = io_list+i;
    /*finished input memory allocation */

	for(i=0; i<fis->in_n; i++){
		inputpointer=mxGetField(fispointer, i, "name");
		status=mxGetString(inputpointer, fis->input[i]->name, buflen);

		inputpointer = mxGetField(fispointer, i, "range");
		real_data_ptr = (DOUBLE *)mxGetPr(inputpointer);
		fis->input[i]->bound[0] = real_data_ptr[0];
		fis->input[i]->bound[1] = real_data_ptr[1];

		inputpointer=mxGetField(fispointer, i, "mf");
		if (inputpointer!=NULL)
			fis->input[i]->mf_n = mxGetN(inputpointer);
		else
			fis->input[i]->mf_n = 0;

		for(j=0; j<fis->input[i]->mf_n; j++){
            mfpointer = mxGetField(inputpointer, j, "name");
            status = mxGetString(mfpointer, fis->input[i]->mf[j]->label, buflen);
            mfpointer = mxGetField(inputpointer, j, "type");
            status = mxGetString(mfpointer, fis->input[i]->mf[j]->type, buflen);
            mfpointer = mxGetField(inputpointer, j, "params");
            param_size = mxGetN(mfpointer);
			fis->input[i]->mf[j]->nparams = param_size;	
			fis->input[i]->mf[j]->params = (DOUBLE *)fisCalloc(param_size,sizeof(DOUBLE));
            real_data_ptr = (DOUBLE *)mxGetPr(mfpointer);
            for(k=0; k<param_size; k++) 
				fis->input[i]->mf[j]->params[k] = (*real_data_ptr++);
		}
	}

	/* outputs */
    fispointer=mxGetField(matlabmat, 0,"output");
	fis->out_n = mxGetN(fispointer);

	/* create output node list, each in_mf_n's element containts the number of mf */
	out_mf_n = (int *)fisCalloc(fis->out_n, sizeof(int));
	for (i = 0; i < fis->out_n; i++){
        inputpointer=mxGetField(fispointer, i, "mf"); 
        if (inputpointer!=NULL)
			out_mf_n[i] = mxGetN(inputpointer);
		else
			out_mf_n[i] = 0;
        }
	io_list = fisBuildIoList(fis->out_n, out_mf_n);
	FREE(out_mf_n); 

	/* allocate memory for input list */
	fis->output = (IO **)fisCalloc(fis->out_n, sizeof(IO *));
	for (i = 0; i < fis->out_n; i++)
		fis->output[i] = io_list+i;
    /*finished output memory allocation */
	
	for(i=0; i<fis->out_n; i++){
		inputpointer=mxGetField(fispointer, i, "name");
		status=mxGetString(inputpointer, fis->output[i]->name, buflen);

		inputpointer=mxGetField(fispointer, i, "range");
		real_data_ptr=(DOUBLE *)mxGetPr(inputpointer);
		fis->output[i]->bound[0] = real_data_ptr[0];
		fis->output[i]->bound[1] = real_data_ptr[1];

		inputpointer=mxGetField(fispointer, i, "mf");
		if (inputpointer!=NULL)
           fis->output[i]->mf_n=mxGetN(inputpointer);
		else
           fis->output[i]->mf_n=0;

        for(j=0; j<fis->output[i]->mf_n; j++){
			mfpointer=mxGetField(inputpointer, j, "name");
            status=mxGetString(mfpointer, fis->output[i]->mf[j]->label, buflen);
            mfpointer=mxGetField(inputpointer, j, "type");
            status=mxGetString(mfpointer, fis->output[i]->mf[j]->type, buflen);
            mfpointer=mxGetField(inputpointer, j, "params");
			real_data_ptr = (DOUBLE *)mxGetPr(mfpointer);

			if (strcmp(fis->type, "sugeno") == 0) {
				/* For Sugeno: in the MATLAB structure, length(mf.params) is
				     * 1      for mf.type = 'constant'
					 * in_n+1 for mf.type = 'linear'
				   In the C structure, this is converted to a vector of length in_n+1 with the 
				   constant part of the MF function as last entry,
				*/
				param_size = fis->in_n+1;
				data_size = mxGetM(mfpointer)*mxGetN(mfpointer);
				fis->output[i]->mf[j]->nparams = param_size;
				fis->output[i]->mf[j]->params = (DOUBLE *)fisCalloc(param_size,sizeof(DOUBLE));
				if (data_size > 0) {
					/* Protect about [] data for backward compatibility */
					if (strcmp(fis->output[i]->mf[j]->type, "constant") == 0) {
						/* Constant output MF for Sugeno system */
						if (data_size != 1)
							fisError("Invalid FIS. PARAMS field of constant output MF must contain a scalar.");
						for(k=0; k<fis->in_n; k++)
							fis->output[i]->mf[j]->params[k] = 0.0;
						fis->output[i]->mf[j]->params[fis->in_n] = real_data_ptr[0];
					}
					else {
						/* Linear output MF for Sugeno system */
						if (data_size != param_size)
							fisError("Invalid FIS. PARAMS field of linear output MF has incorrect length.");
						for(k=0; k<param_size; k++)
							fis->output[i]->mf[j]->params[k] = *(real_data_ptr++);
					}
				}
			}
			else if (strcmp(fis->type, "mamdani") == 0) {
				/* Mamdani system */
				param_size = mxGetM(mfpointer)*mxGetN(mfpointer);
				fis->output[i]->mf[j]->nparams = param_size;	
				fis->output[i]->mf[j]->params = (DOUBLE *)fisCalloc(param_size,sizeof(DOUBLE));
				for(k=0; k<param_size; k++)
					fis->output[i]->mf[j]->params[k] = *(real_data_ptr++);
				/* Allocate MF value array */
				fis->output[i]->mf[j]->value_array =(DOUBLE *)fisCalloc(numofpoints, sizeof(DOUBLE)); 
			}
		}
	}

           
	/* rules */
    fispointer=mxGetField(matlabmat, 0,"rule");
    if (fispointer==NULL)
        fis->rule_n=0;
    else
		fis->rule_n = mxGetN(fispointer);

	fis->rule_list = (int **)fisCreateMatrix(fis->rule_n, fis->in_n + fis->out_n, sizeof(int));
	fis->rule_weight = (DOUBLE *)fisCalloc(fis->rule_n, sizeof(DOUBLE));
	fis->and_or = (int *)fisCalloc(fis->rule_n, sizeof(int));
	
	for (i = 0; i < fis->rule_n; i++) {
        inputpointer=mxGetField(fispointer, i, "antecedent");
        real_data_ptr = (DOUBLE *)mxGetPr(inputpointer);
	    for (j = 0; j < fis->in_n ; j++)
			fis->rule_list[i][j] = (int)(*real_data_ptr++);

		inputpointer=mxGetField(fispointer, i, "consequent");
		real_data_ptr = (DOUBLE *)mxGetPr(inputpointer);
	    for (j = 0; j < fis->out_n ; j++)
			fis->rule_list[i][j+fis->in_n] = (int)(*real_data_ptr++);
           
		inputpointer=mxGetField(fispointer, i, "weight");
		real_data_ptr = (DOUBLE *)mxGetPr(inputpointer);
	    fis->rule_weight[i] = *real_data_ptr;

		inputpointer=mxGetField(fispointer, i, "connection");
		real_data_ptr = (DOUBLE *)mxGetPr(inputpointer);
	    fis->and_or[i] = (int)(*real_data_ptr); 
	}
		
	fisAssignMfPointer(fis);
	fisAssignFunctionPointer(fis); 
	fis->firing_strength = (DOUBLE *)fisCalloc(fis->rule_n, sizeof(DOUBLE));
	fis->rule_output = (DOUBLE *)fisCalloc(fis->rule_n, sizeof(DOUBLE));

	if (strcmp(fis->type, "mamdani") == 0) {
		fis->BigOutMfMatrix = (DOUBLE *)
			fisCalloc(fis->rule_n*numofpoints, sizeof(DOUBLE));
		fis->BigWeightMatrix = (DOUBLE *)
			fisCalloc(fis->rule_n*numofpoints, sizeof(DOUBLE));
	}

	fis->mfs_of_rule = (DOUBLE *)fisCalloc(fis->in_n, sizeof(DOUBLE));
	if (strcmp(fis->type, "mamdani") == 0) {
		for (i = 0; i < fis->out_n; i++)
         	fisComputeOutputMfValueArray(fis, numofpoints);
	} 
	fisCheckDataStructure(fis);

	/*----------finished setting fis structure-------------------*/
	fis->next = NULL;
	return(fis);
}

#else
# define matlab2cStr(matlabmat, numofpoints)  NULL
#endif



/* transform matlab matrix to C matrix */
static DOUBLE **matlab2c(const mxArray *matlabmat)
{
	int m = mxGetM(matlabmat);
	int n = mxGetN(matlabmat);
	const DOUBLE *mat = mxGetPr(matlabmat);
	DOUBLE **out = (DOUBLE **)fisCreateMatrix(m, n, sizeof(DOUBLE));
	int i, j;

	for (i = 0; i < m; i++)
		for(j = 0; j < n; j++)
			out[i][j] = mat[j*m + i];
	return(out);
}
