/* Copyright 1994-2002 The MathWorks, Inc.  */
/* $Revision: 1.11 $  $Date: 2002/06/17 12:47:18 $  $Author: eyarrow $ */

#ifdef WIN32
#ifdef INCLUDE_ANFIS
#include "anfis.h"
#else
#include "fis.h"
#endif
#include "mf.c"
#endif

/* Functions for generating FIS matrix from training data */

/* conversion of string to array of double */
static void
anfisString2Array(DOUBLE *destination, char *source, int n)
{
	int i;
	for (i = 0; i < n; i++)
		destination[i] = (DOUBLE)source[i];
}

/* find the min. or max. of a column of a given matrix */
static DOUBLE
anfisMatrixColLimit(DOUBLE **matrix, int which_col, int row_n, char *action)
{
	DOUBLE extreme = matrix[0][which_col];
	int i;

	if (strcmp(action, "min") == 0) {
		DOUBLE min = matrix[0][which_col];
		for (i = 0; i < row_n; i++) {
			if (matrix[i][which_col] < min)
				min = matrix[i][which_col];
		}
		return(min);
	}
	if (strcmp(action, "max") == 0) {
		DOUBLE max = matrix[0][which_col];
		for (i = 0; i < row_n; i++) {
			if (matrix[i][which_col] > max)
				max = matrix[i][which_col];
		}
		return(max);
	}
	fisError("Unknown action in anfisMatLimit()!");
	return(0.0);	/* for supressing compiler's warning */
}

/* generate a fismatrix according to trn_data */
static void
anfisGenFisMat(DOUBLE **trn_data, int in_n, int data_n, DOUBLE *in_mf_n, DOUBLE **fismatrix)
{
	int i, j, k, start;
	int rule_n, total_in_mf_n;
	char tmp_str[100];
	int out_n = 1;
	int tmp;

	rule_n = 1;
	total_in_mf_n = 0;
	for (i = 0; i < in_n; i++) {
		rule_n *= in_mf_n[i];
		total_in_mf_n += in_mf_n[i];
	}

	/* name */
	anfisString2Array(fismatrix[0], "anfis", 5);
	/* type */
	anfisString2Array(fismatrix[1], "sugeno", 6);
	/* input and output numbers */
	fismatrix[2][0] = in_n;
	fismatrix[2][1] = out_n;
	/* input MF numbers */
	for (i = 0; i < in_n; i++)
		fismatrix[3][i] = in_mf_n[i];
	/* output MF number */
	for (i = 0; i < out_n; i++)
		fismatrix[4][i] = rule_n;
	/* rule number */
	fismatrix[5][0] = rule_n;
	/* and method */
	anfisString2Array(fismatrix[6], "prod", 4);
	/* or method */
	anfisString2Array(fismatrix[7], "max", 3);
	/* imp method */
	anfisString2Array(fismatrix[8], "prod", 4);
	/* agg method */
	anfisString2Array(fismatrix[9], "max", 3);
	/* defuzz method */
	anfisString2Array(fismatrix[10], "wtaver", 6);
	/* input labels */
	start = 11;
	for (i = 0; i < in_n; i++) {
		sprintf(tmp_str, "in%d", i+1);
		anfisString2Array(fismatrix[start+i], tmp_str, 3);
	}
	/* output labels */
	start += in_n;
	for (i = 0; i < out_n; i++) {
		sprintf(tmp_str, "out%d", i+1);
		anfisString2Array(fismatrix[start+i], tmp_str, 4);
	}
	/* input bounds */
	start += out_n;
	for (i = 0; i < in_n; i++) {
		fismatrix[start+i][0] =
			anfisMatrixColLimit(trn_data, i, data_n, "min");
		fismatrix[start+i][1] =
			anfisMatrixColLimit(trn_data, i, data_n, "max");
	}
	/* output bounds */
	start += in_n;
	for (i = 0; i < out_n; i++) {
		fismatrix[start+i][0] =
			anfisMatrixColLimit(trn_data, in_n+i, data_n, "min");
		fismatrix[start+i][1] =
			anfisMatrixColLimit(trn_data, in_n+i, data_n, "max");
	}
	/* input MF labels */
	start += out_n;
	for (i = 0; i < in_n; i++)
		for (j = 0; j < in_mf_n[i]; j++) {
			sprintf(tmp_str, "in%dmf%d", i+1, j+1);
			anfisString2Array(fismatrix[start], tmp_str, 6);
			start++;
		}
	/* output MF labels */
	for (i = 0; i < out_n; i++)
		for (j = 0; j < rule_n; j++) {
			sprintf(tmp_str, "out%dmf%d", i+1, j+1);
			anfisString2Array(fismatrix[start], tmp_str, 7);
			start++;
		}
	/* input MF types */
	for (i = 0; i < in_n; i++)
		for (j = 0; j < in_mf_n[i]; j++) {
			anfisString2Array(fismatrix[start], "gbellmf", 7);
			start++;
		}
	/* output MF types */
	for (i = 0; i < out_n; i++)
		for (j = 0; j < rule_n; j++) {
			anfisString2Array(fismatrix[start], "linear", 6);
			start++;
		}
	/* input MF parameters */
	for (i = 0; i < in_n; i++) {
		DOUBLE min = anfisMatrixColLimit(trn_data, i, data_n, "min");
		DOUBLE max = anfisMatrixColLimit(trn_data, i, data_n, "max");
		DOUBLE range = max - min;
		DOUBLE a = range/(2*in_mf_n[i]-2);
		DOUBLE b = 2.0;
		DOUBLE c;
		for (j = 0; j < in_mf_n[i]; j++) {
			c = min + j*range/(in_mf_n[i]-1);
			fismatrix[start][0] = a;
			fismatrix[start][1] = b;
			fismatrix[start][2] = c;
			start++;
		}
	}
	/* output MF parameters */
	/* output MF parameters are set at zeros */
	start += rule_n;
	/* rule list */
	for (i = 0; i < rule_n; i++) {
		tmp = i;
		for (j = in_n-1; j >= 0; j--) {
			fismatrix[start][j] = 
				(tmp % (int)in_mf_n[j]) + 1;
			tmp = (int)(tmp/in_mf_n[j]);
		}
		fismatrix[start][in_n] = i+1;
		fismatrix[start][in_n+1] = 1;
		fismatrix[start][in_n+2] = 1;
		start++;
	}
}

/* transfer parameters from fis data structure to a fismatrix */
static void
anfisFis2FisMat(FIS *fis, DOUBLE **fismatrix)
{
	int i, j, k;
	int in_n = fis->in_n;
	int out_n = fis->out_n;
	int total_in_mf_n = fis->total_in_mf_n;
	int rule_n = fis->rule_n;
	int start = 11+2*in_n+2*out_n+2*total_in_mf_n+2*rule_n;

	for (i = 0; i < in_n; i++)
		for (j = 0; j < fis->input[i]->mf_n; j++) {
			for (k = 0; k < 4; k++)
				fismatrix[start][k] =
					fis->input[i]->mf[j]->params[k];
			start++;
		}
	for (i = 0; i < rule_n; i++) {
		for (j = 0; j < in_n+1; j++)
			fismatrix[start][j] = fis->output[0]->mf[i]->params[j];
		start++;
	}
}

/* transfer parameters from anfis data structure to a fismatrix */
/* flag == 0 --> get parameter from fis->trn_best_para */
/* flag != 0 --> get parameter from fis->chk_best_para */
static void
anfisAnfis2FisMat(FIS *fis, DOUBLE **fismatrix, int flag)
{
	int i, j, k;
	int in_n = fis->in_n;
	int out_n = fis->out_n;
	int total_in_mf_n = fis->total_in_mf_n;
	int rule_n = fis->rule_n;
	int start = 11+2*in_n+2*out_n+2*total_in_mf_n+2*rule_n;
	int tmp;
	char *mf_type;
	DOUBLE *source;

	source = flag == 0? fis->trn_best_para:fis->chk_best_para;

	tmp = 0;
        for (i = 0; i < fis->in_n; i++)
                for (j = 0; j < fis->input[i]->mf_n; j++) {
                        mf_type = fis->input[i]->mf[j]->type;
                        for (k = 0; k < fisGetMfParaN(mf_type); k++)
				fismatrix[start][k] = source[tmp++];
			start++;
                }

        /* copy output parameters */
        for (i = 0; i < fis->out_n; i++) {
                for (j = 0; j < fis->output[i]->mf_n; j++) {
                        for (k = 0; k < fis->in_n+1; k++)
				fismatrix[start][k] = source[tmp++];
			start++;
                }
        }
}
