/* Copyright 1994-2002 The MathWorks, Inc.  */
/* $Revision: 1.6 $ */

mxArray *c2matlabStr(FIS *fis, int flag){
    DOUBLE *source;
    mxArray *fisresult;

    int i, j, k, param_n, mfindex;
    DOUBLE *real_data_ptr, *antecedent, *consequent;
    mxArray *field_value;
    mxArray *in_field, *out_field, *mf_field;
    const char *field_names[]={"name", "type", "andMethod", "orMethod", "defuzzMethod",
                               "impMethod", "aggMethod", "input", "output", "rule"};
    const char *in_field_names[]={"name", "range", "mf"};
    const char *mf_field_names[]={"name", "type", "params"};
    const char *rule_field_names[]={"antecedent", "consequent", "weight", "connection"};

    int dims[2]={1, 1}, new_prm_index=0;

    source = flag == 0? fis->trn_best_para:fis->chk_best_para;
/*==============output mapping==============*/
        antecedent=(DOUBLE *)fisCalloc(fis->in_n, sizeof(DOUBLE));
        consequent=(DOUBLE *)fisCalloc(fis->out_n, sizeof(DOUBLE));
        fisresult = mxCreateStructArray(2, dims, 10, field_names);
        field_value=mxCreateString(fis->name);


	mxSetField(fisresult, 0, "name", field_value);
        field_value=mxCreateString(fis->type);
	mxSetField(fisresult, 0, "type", field_value);
        field_value=mxCreateString(fis->andMethod);
	mxSetField(fisresult, 0, "andMethod", field_value);
        field_value=mxCreateString(fis->orMethod);
	mxSetField(fisresult, 0, "orMethod", field_value);
        field_value=mxCreateString(fis->defuzzMethod);
	mxSetField(fisresult, 0, "defuzzMethod", field_value);
        field_value=mxCreateString(fis->impMethod);
	mxSetField(fisresult, 0, "impMethod", field_value);
        field_value=mxCreateString(fis->aggMethod);
	mxSetField(fisresult, 0, "aggMethod", field_value);

/*========input=============*/
        dims[1]=fis->in_n;
        in_field=mxCreateStructArray(2, dims, 3, in_field_names); 
        for (i=0; i<fis->in_n; i++){
            field_value=mxCreateString(fis->input[i]->name);
	    mxSetField(in_field, i, "name", field_value);
            field_value=mxCreateDoubleMatrix(1,2,mxREAL);
            real_data_ptr = (DOUBLE *)mxGetPr(field_value);
            memcpy(real_data_ptr, fis->input[i]->bound, 2 * sizeof(DOUBLE) );

	    mxSetField(in_field, i, "range", field_value);
            dims[1]=fis->input[i]->mf_n;
            mf_field=mxCreateStructArray(2, dims, 3, mf_field_names); 
            for (j=0; j<dims[1]; j++){
                field_value=mxCreateString(fis->input[i]->mf[j]->label);
	        mxSetField(mf_field, j, "name", field_value);
                field_value=mxCreateString(fis->input[i]->mf[j]->type);
	        mxSetField(mf_field, j, "type", field_value);
                param_n=fisGetMfParaN(fis->input[i]->mf[j]->type);
                field_value=mxCreateDoubleMatrix(1,param_n,mxREAL);
                real_data_ptr = (DOUBLE *)mxGetPr(field_value);
                for (k=0; k<param_n; k++)
                 *real_data_ptr++=source[new_prm_index++];
/*                memcpy(real_data_ptr, fis->input[i]->mf[j]->para, param_n * sizeof(double) );*/
       	        mxSetField(mf_field, j, "params", field_value);
            }    
            mxSetField(in_field, i, "mf", mf_field); 	
         }
        mxSetField(fisresult, 0, "input", in_field); 

 
/*=============output==============*/  
        dims[1]=fis->out_n;
        out_field=mxCreateStructArray(2, dims, 3, in_field_names); 
        for (i=0; i<fis->out_n; i++){
            field_value=mxCreateString(fis->output[i]->name);
	    mxSetField(out_field, i, "name", field_value);
            field_value=mxCreateDoubleMatrix(1,2,mxREAL);
            real_data_ptr = (DOUBLE *)mxGetPr(field_value);
            memcpy(real_data_ptr, fis->output[i]->bound, 2 * sizeof(DOUBLE) );

	    mxSetField(out_field, i, "range", field_value);
            dims[1]=fis->output[i]->mf_n;
            mf_field=mxCreateStructArray(2, dims, 3, mf_field_names); 
/*            for (j=0; j<fis->output[i]->mf_n; j++){*/
            for (j=0; j<fis->rule_n; j++){
                mfindex = fis->rule_list[j][fis->in_n]-1;
/*                printf("mfindex: %d\n", mfindex);*/
/*                field_value=mxCreateString(fis->output[i]->mf[j]->label);*/
                field_value=mxCreateString(fis->output[i]->mf[mfindex]->label);
/*	        mxSetField(mf_field, j, "name", field_value);*/
	        mxSetField(mf_field, mfindex, "name", field_value);
/*                field_value=mxCreateString(fis->output[i]->mf[j]->type);*/
			field_value=mxCreateString(fis->output[i]->mf[mfindex]->type);
/*	        mxSetField(mf_field, j, "type", field_value);*/
	        mxSetField(mf_field, mfindex, "type", field_value);

			if (fis->order == 1)
				param_n=fis->in_n+1;
			else
				param_n=1;
			field_value = mxCreateDoubleMatrix(1,param_n,mxREAL);
			real_data_ptr = (DOUBLE *)mxGetPr(field_value);
			if (fis->order == 1) 
				for (k=0; k<param_n; k++)
                   *real_data_ptr++ = source[new_prm_index++];
                else
                   *real_data_ptr = source[new_prm_index++];  
       	        mxSetField(mf_field, mfindex, "params", field_value);
            }    
            mxSetField(out_field, i, "mf", mf_field); 	
         }
        mxSetField(fisresult, 0, "output", out_field); 
/*==========rules=============*/
        dims[1]=fis->rule_n;
        out_field=mxCreateStructArray(2, dims, 4, rule_field_names); 
        for (i=0; i<fis->rule_n; i++){
            for (j=0; j<fis->in_n; j++)
               antecedent[j]=fis->rule_list[i][j];
            field_value=mxCreateDoubleMatrix(1,fis->in_n,mxREAL);
            real_data_ptr = (DOUBLE *)mxGetPr(field_value);
            memcpy(real_data_ptr, antecedent, fis->in_n * sizeof(DOUBLE) );
            mxSetField(out_field, i, "antecedent", field_value);
            for (j=0; j<fis->out_n; j++)
               consequent[j]=fis->rule_list[i][fis->in_n+j];            
            field_value=mxCreateDoubleMatrix(1,fis->out_n,mxREAL);
            real_data_ptr = (DOUBLE *)mxGetPr(field_value);
            memcpy(real_data_ptr, consequent, fis->out_n * sizeof(DOUBLE) );
            mxSetField(out_field, i, "consequent", field_value);           
            field_value=mxCreateDoubleMatrix(1,1,mxREAL);
            real_data_ptr = (DOUBLE *)mxGetPr(field_value);
            *real_data_ptr = fis->rule_weight[i];
            mxSetField(out_field, i, "weight", field_value);
            dims[1]=1;
            field_value=mxCreateDoubleMatrix(1,1,mxREAL);
            real_data_ptr = (DOUBLE *)mxGetPr(field_value);
            *real_data_ptr = fis->and_or[i];
            mxSetField(out_field, i, "connection", field_value);
           } 	   
        mxSetField(fisresult, 0, "rule", out_field); 
        return(fisresult);
}



/* transform C matrix to matlab matrix */
static mxArray *
c2matlab(DOUBLE **cmat, int row_n, int col_n)
{
	mxArray *OUT = mxCreateDoubleMatrix(row_n, col_n, mxREAL);
	DOUBLE *out = mxGetPr(OUT);
	int i, j;

	for (i = 0; i < row_n; i++)
		for (j = 0; j < col_n; j++)
			out[j*row_n+i] = cmat[i][j];
	return(OUT);
}
