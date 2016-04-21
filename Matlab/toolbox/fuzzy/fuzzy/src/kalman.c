/* Copyright 1994-2002 The MathWorks, Inc.  */
/* $Revision: 1.13 $  $Date: 2002/06/17 12:46:59 $  $Author: eyarrow $ */

/* get the data to be used in kalman filter algorithm */
/* off-line only */
static void anfisGetKalmanDataPair(FIS *fis, int which_data)
{
	/* ========== */
	int linear_para_n = ((fis->order)*(fis->in_n)+1)*fis->rule_n;

	/* 'first' is the index of the first node in layer 3 */
	int first = fis->layer[3]->index;
	DOUBLE total_firing_strength = 0;
	int i, j, k;

	for (i = first; i < first + fis->rule_n; i++)
		total_firing_strength += fis->node[i]->value;

	j = 0;
	for (i = first; i < first + fis->rule_n; i++) {
		/* ========== */
		if (fis->order == 1) {
			for (k = 0; k < fis->in_n; k++) 
				fis->kalman_io_pair[j++] =
					(fis->node[i]->value)*
					(fis->node[k]->value);
			fis->kalman_io_pair[j++] = fis->node[i]->value;
		} else {
			fis->kalman_io_pair[j++] = fis->node[i]->value;
		}
	}

	for (i = 0; i < linear_para_n; i++)
		fis->kalman_io_pair[i] /= total_firing_strength;

	for (i = 0; i < fis->out_n; i++)
		fis->kalman_io_pair[linear_para_n+i] =
			fis->trn_data[which_data][fis->in_n+i];
}


/* get the data to be used in ML algorithm */
/* off-line only */
static void anfisGetKalmanDataPair2(FIS *fis, int which_data)
{
	/* ========== */

	/* 'first' is the index of the first node in layer 3 */
	int first = fis->layer[1]->index;
	int i, j, k;

	j = 0;
        for (k=fis->in_n; k<fis->node_n-1; k++)
          for (i = 0; i < fis->node[k]->para_n; i++)
		fis->kalman_io_pair[j++] = fis->node[k]->de_dp[i];

	for (i = 0; i < fis->out_n; i++)
	  fis->kalman_io_pair[fis->para_n+i] =
	   (fis->trn_data[which_data][fis->in_n+i]-fis->node[fis->node_n-1]->value);
}


/* get the data to be used in kalman filter algorithm */
/* on-line only */
static void anfisGetKalmanDataPair1(FIS *fis, DOUBLE *u)
{
	int linear_para_n = (fis->in_n+1)*fis->rule_n;
	/* 'first' is the index of the first node in layer 3 */
	int first = fis->layer[3]->index;
	DOUBLE total_firing_strength = 0;
	int i, j, k;

	for (i = first; i < first + fis->rule_n; i++)
		total_firing_strength += fis->node[i]->value;
	/*
	PRINT(total_firing_strength);
	*/

	j = 0;
	for (i = first; i < first + fis->rule_n; i++) {
		for (k = 0; k < fis->in_n; k++) 
			fis->kalman_io_pair[j++] = (fis->node[i]->value)*
				(fis->node[k]->value);
		fis->kalman_io_pair[j++] = fis->node[i]->value;
	}

	for (i = 0; i < linear_para_n; i++)
		fis->kalman_io_pair[i] /= total_firing_strength;

	for (i = 0; i < fis->out_n; i++)
		fis->kalman_io_pair[linear_para_n+i] = u[fis->in_n+i];

	/*
	PRINT(linear_para_n);
	PRINTARRAY(u, fis->in_n + fis->out_n);
	PRINTARRAY(fis->kalman_io_pair, linear_para_n+1);
	*/
}

/* put the parameters identified by kalman filter algorithm back into ANFIS */
static void anfisPutKalmanParameter(FIS *fis)
{
	/* 'first' is the index of the first node in layer 4 */
	int first = fis->layer[4]->index;
	int i, j, k;

	k = 0;
	for (i = first; i < first + fis->rule_n; i++) 
		for (j = 0; j < fis->node[i]->para_n; j++)
			fis->node[i]->para[j] = fis->kalman_para[k++][0];
}

/* put the parameters identified by LM algorithm back into ANFIS */
static void anfisPutKalmanParameter2(FIS *fis)
{
	/* 'first' is the index of the first node in layer 4 */
	int first = fis->layer[1]->index;
	int i, j, k;

	k = 0;
        for (i=fis->in_n; i<fis->node_n-1; i++)
	  for (j = 0; j < fis->node[i]->para_n; j++)
	      fis->node[i]->para[j] += fis->kalman_para[k++][0];
}


/* matrix plus matrix */
static void anfisMplusM(DOUBLE **m1, DOUBLE **m2, int row, int col, DOUBLE **out)
{
	int i, j;
	for (i = 0; i < row; i++)
		for (j = 0; j < col; j++)
			out[i][j] = m1[i][j] + m2[i][j];
}

/* matrix minus matrix */
static void anfisMminusM(DOUBLE **m1, DOUBLE **m2, int row, int col, DOUBLE **out)
{
	int i, j;
	for (i = 0; i < row; i++)
		for (j = 0; j < col; j++)
			out[i][j] = m1[i][j] - m2[i][j];
}

/* matrix times matrix */
static void anfisMtimesM(DOUBLE **m1, DOUBLE **m2, int row1, int col1, int col2, DOUBLE **out)
{
	int i, j, k;
	for (i = 0; i < row1; i++)
		for (j = 0; j < col2; j++) {
			out[i][j] = 0;
			for (k = 0; k < col1; k++)
				out[i][j] += m1[i][k]* m2[k][j];
		}
}

/* scalar times matrix */
static void anfisStimesM(DOUBLE c, DOUBLE **m, int row, int col, DOUBLE **out)
{
	int i, j;
	for (i = 0; i < row; i++)
		for (j = 0; j < col; j++)
			out[i][j] = c*m[i][j];
}

/* matrix transpose */
static void transposeM(DOUBLE **m, int row, int col, DOUBLE **m_t)
{
	int i, j;
	for (i = 0; i < row; i++)
		for (j = 0; j < col; j++)
			m_t[j][i] = m[i][j];
}

/* matrix L-2 norm */
DOUBLE matrixNorm(DOUBLE **m, int row, int col)
{
	int i, j;
	DOUBLE total = 0;

	for (i = 0; i < col; i++)
		for (j = 0; j < row; j++)
			total += m[i][j]*m[i][j];
	return(sqrt(total));
}

/* same as kalman(), but with forgetting factor lambda */
/* reset != 0 --> reset matrices S and P */
static void anfisKalman(FIS *fis, int reset, DOUBLE alpha)
{
	DOUBLE **S, **P, **a, **b, **a_t, **b_t;
	DOUBLE **tmp1, **tmp2, **tmp3, **tmp4;
	DOUBLE **tmp5, **tmp6, **tmp7;

	/* ========== */
	int in_n;
	int out_n = fis->out_n;

	int i, j;
	DOUBLE denom;
        
	if (fis->method==1)
		in_n = ((fis->order)*(fis->in_n)+1)*fis->rule_n;
	else
		in_n = fis->para_n;
 
	S = fis->S;
	P = fis->P;
	a = fis->a;
	b = fis->b;
	a_t = fis->a_t;
	b_t = fis->b_t;
	tmp1 = fis->tmp1;
	tmp2 = fis->tmp2;
	tmp3 = fis->tmp3;
	tmp4 = fis->tmp4;
	tmp5 = fis->tmp5;
	tmp6 = fis->tmp6;
	tmp7 = fis->tmp7;

	/* reset S[][] and P[][] */
	if (reset != 0) {
/*======  already defined in param passed in
		double alpha;

                if (fis->method==1)
                     alpha = 1e6;
                else
                     alpha = 1e-1;           =======*/
		for (i = 0; i < in_n; i++)
			for (j = 0; j < out_n; j++)
				P[i][j] = 0;
		for (i = 0; i < in_n; i++)
			for (j = 0; j < in_n; j++)
				if (i == j)
					S[i][j] = alpha; 
				else
					S[i][j] = 0;
		return;
	}

	/* reset == 0, normal operation */
	for (i = 0; i < in_n; i++)
		a[i][0] = fis->kalman_io_pair[i];
	for (i = 0; i < out_n; i++)
		b[i][0] = fis->kalman_io_pair[i+in_n];

	transposeM(a, in_n, 1, a_t);
	transposeM(b, out_n, 1, b_t);

	/* recursive formulas for S, covariance matrix */
	anfisMtimesM(S, a, in_n, in_n, 1, tmp1);
	anfisMtimesM(a_t, tmp1, 1, in_n, 1, tmp2);
	denom = fis->lambda + tmp2[0][0];
	anfisMtimesM(a_t, S, 1, in_n, in_n, tmp3);
	anfisMtimesM(tmp1, tmp3, in_n, 1, in_n, tmp4);
	anfisStimesM(1/denom, tmp4, in_n, in_n, tmp4);
	anfisMminusM(S, tmp4, in_n, in_n, S);
	anfisStimesM(1/fis->lambda, S, in_n, in_n, S);

	/* recursive formulas for P, the estimated parameter matrix */
	anfisMtimesM(a_t, P, 1, in_n, out_n, tmp5);
	anfisMminusM(b_t, tmp5, 1, out_n, tmp5);
	anfisMtimesM(a, tmp5, in_n, 1, out_n, tmp6);
	anfisMtimesM(S, tmp6, in_n, in_n, out_n, tmp7);
	anfisMplusM(P, tmp7, in_n, out_n, P);

	for (i = 0; i < in_n; i++)
		for (j = 0; j < out_n; j++)
			fis->kalman_para[i][j] = P[i][j];
}
