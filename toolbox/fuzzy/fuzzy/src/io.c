/* Copyright 1994-2002 The MathWorks, Inc.  */
/* $Revision: 1.16 $  $Date: 2002/06/17 12:46:58 $  $Author: eyarrow $ */

static DOUBLE **fisGetFismatrix(char *filename, int *mp, int *np)
{
	DOUBLE **fismatrix;
	int element_n = 0, row_n = 0, col_n = 0, i, j;
	FILE *fp;
	char tmp_char;
	DOUBLE tmp_double;

	/* find the size of the data file */
	/* find row number */
	fp = fisOpenFile(filename, "r");
	while (fscanf(fp, "%c", &tmp_char) != EOF)
		if (tmp_char == '\n')
			row_n++;
	fclose(fp);

	/* find element number */
	fp = fopen(filename, "r");
	while (fscanf(fp, "%lf", &tmp_double) != EOF)
		element_n++;
	fclose(fp);
	col_n = element_n/row_n;
	/*
	printf("row_n = %d\n", row_n);
	printf("element_n = %d\n", element_n);
	printf("col_n = %d\n", col_n);
	*/

	fp = fisOpenFile(filename, "r");
	fismatrix = (DOUBLE **)fisCreateMatrix(row_n, col_n, sizeof(DOUBLE));
	for (i = 0; i < row_n; i++)
		for (j = 0; j < col_n; j++)
			fscanf(fp, "%lf", &fismatrix[i][j]);
	fclose(fp);
	*mp = row_n;
	*np = col_n;
	return(fismatrix);
}

/* move training or checking data to fis structure */
/* flag == 0 --> training data */
/* flag != 0 --> checking data */
static void anfisGetData(FIS *fis, char *data_file, int flag)
{
	int i, j;
	DOUBLE tmp;
	FILE *fp;
	int element_n, row_n, column_n;
	DOUBLE **destination;

	if (flag == 0) {	/* reading training data */
		PRINTF("Reading training data ...\n");
		fp = fisOpenFile(data_file, "r");
	}  else {		/* reading checking data */
		fp = fopen(data_file, "r");
		if (fp == NULL) {
			PRINTF("Cannot open %s --> no checking data\n", data_file);
			fis->chk_data_n = 0;
			return;
		} else
			PRINTF("Reading checking data ...\n");
	}

	element_n = 0;
	while (fscanf(fp, "%lf", &tmp) != EOF)
		element_n++;
	fclose(fp);

	column_n = fis->in_n + fis->out_n;
	row_n = element_n/column_n;

	if (flag == 0) {
		fis->trn_data = (DOUBLE **)
			fisCreateMatrix(row_n, column_n, sizeof(DOUBLE));
		fis->trn_data_n = row_n;
		destination = fis->trn_data;
	} else {
		fis->chk_data = (DOUBLE **)
			fisCreateMatrix(row_n, column_n, sizeof(DOUBLE));
		fis->chk_data_n = row_n;
		destination = fis->chk_data;
	}

	fp = fisOpenFile(data_file, "r");
	for (i = 0; i < row_n; i++)
		for (j = 0; j < column_n; j++)
			if (fscanf(fp, "%lf", &tmp) != EOF)
				destination[i][j] = tmp;
			else 
				fisError("Not enough data!");
	fclose(fp);
}

/* Inital message, for off-line only */
static void anfisInitialMessage(FIS *fis)
{
	if (!fis->display_anfis_info)
		return;

	PRINTF("\nANFIS info: \n");
	PRINTF("\tNumber of nodes: %d\n", fis->node_n);
	PRINTF("\tNumber of linear parameters: %d\n",
		((fis->order)*(fis->in_n)+1)*fis->rule_n);
	PRINTF("\tNumber of nonlinear parameters: %d\n", 
		fis->para_n-((fis->order)*(fis->in_n)+1)*fis->rule_n);
	PRINTF("\tTotal number of parameters: %d\n", fis->para_n);
	PRINTF("\tNumber of training data pairs: %d\n", fis->trn_data_n);
	PRINTF("\tNumber of checking data pairs: %d\n", fis->chk_data_n);
	PRINTF("\tNumber of fuzzy rules: %d\n\n", fis->rule_n);

	/*
	PRINT(fis->epoch_n);
	PRINT(fis->trn_error_goal);
	PRINT(fis->ss);
	PRINT(fis->ss_dec_rate);
	PRINT(fis->ss_inc_rate);

	PRINT(fis->display_anfis_info);
	PRINT(fis->display_error);
	PRINT(fis->display_ss);
	PRINT(fis->display_final_result);
	*/

	if (fis->trn_data_n < fis->para_n)
		PRINTF("Warning: number of data is smaller than number of modifiable parameters\n");
}

/* Initial message, for on-line only */
static void anfisInitialMessage1(FIS *fis)
{
	if (!fis->display_anfis_info)
		return;

	PRINTF("\nANFIS info: \n");
	PRINTF("\tNumber of nodes: %d\n", fis->node_n);
	PRINTF("\tNumber of output membership function parameters: %d\n",
		(fis->in_n+1)*fis->rule_n);
	PRINTF("\tNumber of input membership function parameters: %d\n", 
		fis->para_n-(fis->in_n+1)*fis->rule_n);
	PRINTF("\tTotal number of parameters: %d\n", fis->para_n);
	PRINTF("\tNumber of fuzzy rules: %d\n\n", fis->rule_n);
}
