
/*********************************************************************/
/*                        R C S  information                         */
/*********************************************************************/
/* $Revision: 1.20 $  
/*
 * $Log: learning.c,v $
 * Revision 1.20  2002/06/17 12:47:10  eyarrow
 * Update to current year for cprw
 *
 * Revision 1.20  2002/06/05 13:17:16  eyarrow
 * Update to current year for cprw
 *
 * Revision 1.19  2001/04/10 21:20:55  eyarrow
 * Copyright update
 * Code Reviewer: rsingh
 *
 * Revision 1.18  2001/03/22 15:10:52  nhickey
 * double was defined as DOUBLE which is either type double or typr real_Y
 * depending on application. This is related to geck 89752
 * Code Reviewer: pascal
 *
 * Revision 1.17  2001/02/07  19:03:30  nhickey
 * Ensure correct call to printf and calloc
 * Code Reviewer: pascal
 *
 * Revision 1.16  2000/09/18  22:01:45  greg
 * Fix log prefix
 * Related Records: CVS
 * Code Reviewer: marc, mmirman
 *
 * Revision 1.15  2000/06/15 13:40:13  eyarrow
 * Copyright update
 * Related Records:
 * Code Reviewer: greg
 *
 * Revision 1.14  2000/05/24 20:53:21  pascal
 * 1) Replace PARA and SUGENO_COEFF in MF data type (fis.h) by PARAMS/NPARAMS
 * fields 2) Fix geck 58789 (no assumption on the number of MF parameters) 3)
 * Protect against screwy constant MF (with empty params)
 * Related Records: 58789, 59702
 * Code Reviewer: eyarrow
 *
 * Revision 1.13  1999/01/12 17:30:14  joeya
 * Updated (c) Mathworks ==> (c) MathWorks
 *
 * Revision 1.12  1999/01/07  21:20:17  joeya
 * Updated ending cpyrt date
 *
 * Revision 1.11  1998/08/10  14:45:18  rob
 * updated HG calls to on off from yes no
 *
 * Related Records: 46062
 * Code Reviewer: Kelly Liu
 *
 * Revision 1.9  1998/04/17  16:44:02  kliu
 * use the old version for hibrid method
 * Related Records: 4116
 * Code Reviewer: roger
 *
 * Revision 1.3  1995/04/06  14:38:09  jang
 * Don't update parameters if gradient length == 0
 *
 * Revision 1.2  1994/10/25  20:38:51  jang
 * correct typos
 *
 * Revision 1.1  1994/09/14  21:55:01  jang
 * Initial revision
 * */
/*********************************************************************/
/*
 * Copyright 1994-2002 The MathWorks, Inc. 
 */

/* forward pass from node 'from' to node 'to' */
/* the input vector should have been dispatched */
static void anfisForward(FIS *fis, int from, int to)
{
	int i;

	if (from < fis->in_n || to >= fis->node_n)
		fisError("Node index out of bound!");

	/* forward calculation */
	for (i = from; i <= to ; i++)
		fis->node[i]->value =
			(*fis->node[i]->nodeFcn)(fis, i, "forward", -1);
	/*
	PRINT(from);
	PRINT(to);
	anfisPrintData(fis);
	*/
}

/* backward pass from node 'from' to node 'to' */
/* the de_do field of output nodes should have been set */
static void anfisBackward(FIS *fis, int from, int to)
{
	int i;

	if (from < fis->in_n || to >= fis->node_n)
		fisError("Node index out of bound!");

	/* backward calculation */
	for (i = from; i >= to; i--) {
		DOUBLE de_do, do_do;
		FAN *p, *q;
		int k;

		de_do = 0;
		for (p = fis->node[i]->fanout; p != NULL; p = p->next) {
			/* O_i is the k-th fanin of O_{p->index} --> find k */
			for (k = 0, q = fis->node[p->index]->fanin;
				q->index != i; q = q->next, k++);
			if (k >= fis->node[p->index]->fanin_n)
				fisError("Cannot find k in anfisBackward!");
			do_do = (*fis->node[p->index]->nodeFcn)
				(fis, p->index, "backward", k);
			/*
			printf("do%d_do%d = %lf\n", p->index, i, do_do);
			*/
			de_do += fis->node[p->index]->de_do*do_do;
		}
		/* update fis->node[i]->de_do */
		fis->node[i]->de_do = de_do;
	}
}

/* update de_dp of parameterized node from 'from' to 'to'. */
static void anfisUpdateDE_DP(FIS *fis, int from, int to)
{
	int i, j;
	for (i = from; i <= to; i++)
		for (j = 0; j < fis->node[i]->para_n; j++) {
			fis->node[i]->do_dp[j] = (*fis->node[i]->nodeFcn)
				(fis, i, "parameter", j);
			fis->node[i]->de_dp[j] +=
				fis->node[i]->de_do*fis->node[i]->do_dp[j];
		}
}

/* This is good for both on-line and off-line */
/* update parameters of nodes from 'from' to 'to' */
static void anfisUpdateParameter(FIS *fis, int from, int to)
{
	int i, j;
	DOUBLE length = 0;

	/* find the length of gradient vector */ 
	for (i = from; i <= to; i++)
		for (j = 0; j < fis->node[i]->para_n; j++)
			length += pow(fis->node[i]->de_dp[j], 2.0);
	length = sqrt(length);
	if (length == 0) {
		/*
		printf("gradient vector length == 0!\n");
		*/
		return;
	}

	/*
	printf("length = %lf\n", length);
	fisPrintArray(fis->de_dp, fis->para_n);
	fisPrintArray(fis->do_dp, fis->para_n);
	fisPrintArray(fis->para, fis->para_n);
	*/

	/* update parameters */
	for (i = from; i <= to; i++)
		for (j = 0; j < fis->node[i]->para_n; j++)
			fis->node[i]->para[j] -=
				fis->ss*fis->node[i]->de_dp[j]/length;
}

/* clear de_do */
/* do_dp is overwritten every time, so it needs not to be cleared */
static void anfisClearDerivative(FIS *fis)
{
	int i;
	for (i = 0; i < fis->para_n; i++)
		fis->de_dp[i] = 0;
}

/* compute training error */
static DOUBLE anfisComputeTrainingError(FIS *fis)
{
	int j, k;
	DOUBLE squared_error = 0;

	for (j = 0; j < fis->trn_data_n; j++) {
		/* dispatch inputs */
		for (k = 0; k < fis->in_n; k++)
			fis->node[k]->value = fis->trn_data[j][k];

		/* forward calculation */
		anfisForward(fis, fis->in_n, fis->node_n-1);

		/* calculate error measure */
		squared_error += pow(
			fis->trn_data[j][fis->in_n] -
			fis->node[fis->node_n-1]->value, 2.0);
	}
	return(sqrt(squared_error/fis->trn_data_n));
}

/* compute checking error */
static DOUBLE anfisComputeCheckingError(FIS *fis)
{
	int j, k;
	DOUBLE squared_error = 0;

	for (j = 0; j < fis->chk_data_n; j++) {
		/* dispatch inputs */
		for (k = 0; k < fis->in_n; k++)
			fis->node[k]->value = fis->chk_data[j][k];

		/* forward calculation */
		anfisForward(fis, fis->in_n, fis->node_n-1);

		/* calculate error measure */
		squared_error += pow(
			fis->chk_data[j][fis->in_n] -
			fis->node[fis->node_n-1]->value, 2.0);
	}
	return(sqrt(squared_error/fis->chk_data_n));
}

/* a single epoch with index i, using GD only */
static void anfisOneEpoch0(FIS *fis, int i)
{
	int j, k;
	DOUBLE squared_error;

	anfisClearDerivative(fis);
	squared_error = 0;
	for (j = 0; j < fis->trn_data_n; j++) {
		/* dispatch inputs */
		for (k = 0; k < fis->in_n; k++)
			fis->node[k]->value = fis->trn_data[j][k];

		/* forward calculation from layer 1 to layer 3 */
		anfisForward(fis, fis->in_n, fis->node_n-1);

		/* calculate error measure */
		squared_error += pow(
			fis->trn_data[j][fis->in_n] -
			fis->node[fis->node_n-1]->value, 2.0);

		/* dispatch de_do at outputs */
		fis->node[fis->node_n-1]->de_do =
			-2*(fis->trn_data[j][fis->in_n] -
			fis->node[fis->node_n-1]->value);

		/* backward calculation */
		anfisBackward(fis, fis->node_n-2, fis->in_n);

		/* update de_dp */
		anfisUpdateDE_DP(fis, fis->in_n, fis->node_n-1);

		/* print data for debugging */
		/*
		anfisPrintData(fis);
		*/
	}
	fis->trn_error[i] = sqrt(squared_error/fis->trn_data_n);
	if (fis->chk_data_n != 0)
		fis->chk_error[i] = anfisComputeCheckingError(fis);
}

/* a single epoch with index i, using both GD and LSE */
static void anfisOneEpoch1(FIS *fis, int i)
{
	int j, k;
	DOUBLE squared_error;

	anfisClearDerivative(fis);
	squared_error = 0;
	anfisKalman(fis, 1, 1e6);	/* reset matrices used in kalman */
	for (j = 0; j < fis->trn_data_n; j++) {
		/* dispatch inputs */
		for (k = 0; k < fis->in_n; k++)
			fis->node[k]->value = fis->trn_data[j][k];

		/* forward calculation from layer 1 to layer 3 */
		anfisForward(fis, fis->in_n, fis->layer[4]->index-1);

		/* store node outputs from layer 0 to 3 */
		for (k = 0; k < fis->layer[4]->index; k++)
			fis->tmp_node_output[j][k]=fis->node[k]->value;
		anfisGetKalmanDataPair(fis, j);
		anfisKalman(fis, 0, 1e6);	/* normal operation */
	}
	anfisPutKalmanParameter(fis);
	for (j = 0; j < fis->trn_data_n; j++) {
		/* restore node outputs from layer 0 to 3 */
		for (k = 0; k < fis->layer[4]->index; k++)
			fis->node[k]->value=fis->tmp_node_output[j][k];

		/* forward pass from layer 4 to 6 */
		anfisForward(fis, fis->layer[4]->index, fis->node_n-1);

		/* calculate error measure */
		squared_error += pow(
			fis->trn_data[j][fis->in_n] -
			fis->node[fis->node_n-1]->value, 2.0);

		/* dispatch de_do at outputs */
		fis->node[fis->node_n-1]->de_do =
			-2*(fis->trn_data[j][fis->in_n] -
			fis->node[fis->node_n-1]->value);

		/* backward calculation */
		anfisBackward(fis, fis->node_n-2, fis->in_n);

		/* update de_dp of layer 1*/
		anfisUpdateDE_DP(fis, fis->in_n,fis->layer[2]->index-1);

		/* print data for debugging */
		/*
		anfisPrintData(fis);
		*/
	}
	fis->trn_error[i] = sqrt(squared_error/fis->trn_data_n);
	if (fis->chk_data_n != 0)
		fis->chk_error[i] = anfisComputeCheckingError(fis);
}

/* main loop for learning */
static void anfisLearning(FIS *fis)
{
	int i, k;

	if (fis->display_error)
		PRINTF("\nStart training ANFIS ...\n\n");

	for (i = 0; i < fis->epoch_n; i++) {
		/* GD only */
		if (fis->method==0){
        		anfisOneEpoch0(fis, i);
		        anfisUpdateParameter(fis, fis->in_n, fis->node_n-1);

                }else
                {
		/* GD + LSE */
		        anfisOneEpoch1(fis, i);
                }
		/* update min. training error if necessary */
		if (fis->trn_error[i] < fis->min_trn_error) {
			fis->min_trn_error = fis->trn_error[i];
			/* record best parameters so far */
			for (k = 0; k < fis->para_n; k++)
				fis->trn_best_para[k] = fis->para[k];
		}


		/* update min. checking error if necessary */
		if (fis->chk_data_n != 0)
			if (fis->chk_error[i] < fis->min_chk_error) {
				fis->min_chk_error = fis->chk_error[i];
				/* record best parameters so far */
				for (k = 0; k < fis->para_n; k++)
					fis->chk_best_para[k] = fis->para[k];
			}

		if (fis->display_error)
		if (fis->chk_data_n != 0)
			PRINTF("%4d \t %g \t %g\n", i+1,
				fis->trn_error[i], fis->chk_error[i]);
		else
			PRINTF("%4d \t %g\n", i+1,
				fis->trn_error[i]);

		/* stop training if error goal is reached */
		if (fis->min_trn_error <= fis->trn_error_goal) {
			fis->actual_epoch_n = i+1;
			if (fis->display_error)
			PRINTF("\nError goal (%g) reached --> ANFIS training completed at epoch %d.\n\n", fis->trn_error_goal, fis->actual_epoch_n);
			return;
		}

		/* update parameters */
                if (fis->method==1)
		 anfisUpdateParameter(fis, fis->in_n,fis->layer[2]->index-1);

		/* update step size */
		fis->ss_array[i] = fis->ss;	/* record step size */
		anfisUpdateStepSize(fis, i);	/* update step size */
	}
	if (fis->display_error)
	PRINTF("\nDesignated epoch number reached --> ANFIS training completed at epoch %d.\n\n", fis->epoch_n);
}
