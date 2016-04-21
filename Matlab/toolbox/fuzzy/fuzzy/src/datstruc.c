/* Copyright 1994-2002 The MathWorks, Inc.  */
/* $Revision: 1.17 $  $Date: 2002/06/17 12:47:03 $  $Author: eyarrow $ */

/***********************************************************************
 Data structure: construction, printing, and destruction 
 **********************************************************************/

/* action = "fanin" --> add j at the end of node i's fanin list */
/* action = "fanout" --> add j at the end of node i's fanout list */
static void fisAddFan(FIS *fis, int i, int j, char *action)
{
	FAN *p, *new;

	new = (FAN *)fisCalloc(1, sizeof(FAN));
	new->index = j;
	new->next = NULL;

	if (strcmp(action, "fanin") == 0) {
		p = fis->node[i]->fanin;
		if (p == NULL)
			fis->node[i]->fanin = new;
		else {
			while (p->next != NULL)
				p = p->next;
			p->next = new;
		}
		(fis->node[i]->fanin_n)++;
	} else if (strcmp(action, "fanout") == 0) {
		p = fis->node[i]->fanout;
		if (p == NULL)
			fis->node[i]->fanout = new;
		else {
			while (p->next != NULL)
				p = p->next;
			p->next = new;
		}
		(fis->node[i]->fanout_n)++;
	} else
		fisError("Unknown action in fisAddFan()!");
}

/* find the input the give node index (layer 1) belongs to */
/* also fill ll_index */
static int fisGetMfInput(FIS *fis, int index)
{
	int i;
	int tmp = fis->layer[1]->index;

	if ((index < tmp) || (index > tmp + fis->layer_size[1]-1))
		fisError("Error in fisGetMfInput() --> index out of bound!");

	tmp = index - fis->in_n;
	for (i = 0; i < fis->in_n; i++) {
		tmp -= fis->in_mf_n[i];
		if (tmp < 0) {
			fis->node[index]->ll_index = tmp + fis->in_mf_n[i];
			break;
		}
	}
	return(i);
}

/* Build fanin and fanout list of each node of ANFIS */
static void fisBuildFanList(FIS *fis)
{
	int i, j;
	int layer_index, node_index;
	int start, stop, start1, stop1;
	int which_input, which_mf, inv_node_n;
	NODE *p;

	/* layer 0 (INPUT) */
	layer_index = 0;
	start = fis->layer[layer_index]->index;
	stop = start + fis->layer_size[layer_index] - 1;
	for (i = start; i <= stop; i++) {
		p = fis->node[i];
		p->l_index = i - start;
		p->layer = layer_index;
		p->para_n = 0;
		p->fanin = NULL;

		start1 = fis->in_n;
		for (j = 0; j < i; j++)
			start1 += fis->in_mf_n[j];
		stop1 = start1 + fis->in_mf_n[i] - 1;
		for (j = start1; j <= stop1; j++) {
			fisAddFan(fis, i, j, "fanout");
			fisAddFan(fis, j, i, "fanin");
		}
		/* fanout to layer 4 */
		for (j = fis->layer[4]->index;
			j <= fis->layer[4]->index+fis->rule_n-1; j++) {
			fisAddFan(fis, i, j, "fanout");
			fisAddFan(fis, j, i, "fanin");
		}
	}

	/* layer 1 (MF) */
	layer_index = 1;
	start = fis->layer[layer_index]->index;
	stop = start + fis->layer_size[layer_index] - 1;
	inv_node_n = 0;
	for (i = start; i <= stop; i++) {
		p = fis->node[i];
		p->l_index = i - start;
		p->layer = layer_index;
		/* the following fills ll_index also */
		which_input = fisGetMfInput(fis, i);
		which_mf = fis->node[i]->ll_index;
		p->para_n = fisGetMfParaN(fis->input[which_input]->
			mf[which_mf]->type);

		/* build fanout to layer 2 (INV) */
		node_index = fis->layer_size[1] + i;
		fisAddFan(fis, i, node_index, "fanout");
		fisAddFan(fis, node_index, i, "fanin");

		/* build fanout to layer 3 */
		for (j = 0; j < fis->rule_n; j++) {
			if (fis->rule_list[j][which_input]-1 ==
				fis->node[i]->ll_index) {
				node_index = fis->layer_size[0] +
					fis->layer_size[1] +
					fis->layer_size[2] + j;
				fisAddFan(fis, i, node_index, "fanout");
				fisAddFan(fis, node_index, i, "fanin");
			}
		}
	}

	/* layer 2 (INV) */
	layer_index = 2;
	start = fis->layer[layer_index]->index;
	stop = start + fis->layer_size[layer_index] - 1;
	for (i = start; i <= stop; i++) {
		p = fis->node[i];
		p->l_index = i - start;
		p->layer = layer_index;
		p->para_n = 0;
		p->ll_index = fis->node[i-fis->total_in_mf_n]->ll_index;

		which_input = fisGetMfInput(fis, p->fanin->index);
		/* build fanout to layer 3 */
		for (j = 0; j < fis->rule_n; j++) {
			if (-fis->rule_list[j][which_input]-1 ==
				fis->node[i]->ll_index) {
				node_index = fis->layer_size[0] +
					fis->layer_size[1] +
					fis->layer_size[2] + j;
				fisAddFan(fis, i, node_index, "fanout");
				fisAddFan(fis, node_index, i, "fanin");
			}
		}
	}

	/* layer 3 (Firing-Strength) */
	layer_index = 3;
	start = fis->layer[layer_index]->index;
	stop = start + fis->layer_size[layer_index] - 1;
	for (i = start; i <= stop; i++) {
		p = fis->node[i];
		p->l_index = i - start;
		p->layer = layer_index;
		p->para_n = 0;

		/* build fanout to layer 4 */
		fisAddFan(fis, i, i + fis->rule_n, "fanout");
		fisAddFan(fis, i + fis->rule_n, i, "fanin");

		/* build fanout to layer 5 */
		fisAddFan(fis, i, fis->node_n - 2, "fanout");
		fisAddFan(fis, fis->node_n - 2, i, "fanin");
	}

	/* layer 4 (w*f) */
	layer_index = 4;
	start = fis->layer[layer_index]->index;
	stop = start + fis->layer_size[layer_index] - 1;
	for (i = start; i <= stop; i++) {
		p = fis->node[i];
		p->l_index = i - start;
		p->layer = layer_index;
		/* ========== */
		p->para_n = (fis->order)*(fis->in_n)+1;

		/* build fanout to layer 5 */
		fisAddFan(fis, i, fis->layer[5]->index, "fanout");
		fisAddFan(fis, fis->layer[5]->index, i, "fanin");
	}

	/* layer 5 (Summation) */
	layer_index = 5;
	start = fis->layer[layer_index]->index;
	stop = start + fis->layer_size[layer_index] - 1;
	for (i = start; i <= stop; i++) {
		p = fis->node[i];
		p->l_index = i - start;
		p->layer = layer_index;
		p->para_n = 0;
		fisAddFan(fis, i, fis->node_n-1, "fanout");
		fisAddFan(fis, fis->node_n-1, i, "fanin");
	}

	/* layer 6 (Output node) */
	layer_index = 6;
	start = fis->layer[layer_index]->index;
	stop = start + fis->layer_size[layer_index] - 1;
	for (i = start; i <= stop; i++) {
		p = fis->node[i];
		p->l_index = i - start;
		p->layer = layer_index;
		p->para_n = 0;
		p->fanout = NULL;
	}
}

/* find if given node index (layer 1) is connected to INV */
static int fisFindInvMf(FIS *fis, int index)
{
	int i;
	int tmp = fis->layer[1]->index;
	int which_input;

	if ((index < tmp) || (index > tmp + fis->layer_size[1]-1))
		fisError("Error in fisFindInvMf() --> index out of bound!");
	which_input = fisGetMfInput(fis, index);
	for (i = 0; i < fis->rule_n; i++)
		if (-fis->rule_list[i][which_input] ==
			(fis->node[index]->ll_index+1))
			return(1);
	return(0);
}

/* Build additional data strucutre for ANFIS */
static void anfisBuildAnfis(FIS *fis)
{
	int i, j, k, start, tmp;
	char *mf_type;
	NODE *node_list;

	
	/*PRINTF("Building ANFIS data structure ...\n");*/
	

	/* ========== */
	/* determine the order of ANFIS */
	if (!strcmp(fis->output[0]->mf[0]->type, "linear"))
		fis->order = 1;
	else
		fis->order = 0;


	/* build fis->in_mf_n */
	fis->in_mf_n = (int *)fisCalloc(fis->in_n, sizeof(int));
	for (i = 0; i < fis->in_n; i++)
		fis->in_mf_n[i] = fis->input[i]->mf_n;

	/* build fis->out_mf_n */
	fis->out_mf_n = (int *)fisCalloc(fis->out_n, sizeof(int));
	for (i = 0; i < fis->out_n; i++)
		fis->out_mf_n[i] = fis->output[i]->mf_n;

	/* calculate total mf number */
	for (tmp = 0, i = 0; i < fis->in_n; tmp += fis->in_mf_n[i], i++);
	fis->total_in_mf_n = tmp;

	/* calculate total node number */
	fis->node_n = fis->in_n + 2*fis->total_in_mf_n + 2*fis->rule_n + 2 + 1;

	/* fill the number of nodes in each layer */
	fis->layer_size[0] = fis->in_n;
	fis->layer_size[1] = fis->total_in_mf_n;
	fis->layer_size[2] = fis->total_in_mf_n;
	fis->layer_size[3] = fis->rule_n;
	fis->layer_size[4] = fis->rule_n;
	fis->layer_size[5] = 2;
	fis->layer_size[6] = 1;		/* for single output only */

	/* build each node */
	node_list = (NODE *)fisCalloc(fis->node_n, sizeof(NODE));

	/* fill fis->node and fis->node[i]->index */
	fis->node = (NODE **)fisCalloc(fis->node_n, sizeof(NODE *));
	for (i = 0; i < fis->node_n; i++) {
		fis->node[i] = node_list + i;
		fis->node[i]->index = i;
	}

	/* calculate fis->layer */
	start = 0;
	for (i = 0; i < 7; i++) {
		fis->layer[i] = fis->node[start];
		start += fis->layer_size[i];
	}

	/* fill fanin and fanout list and other housekeepin stuff */
	fisBuildFanList(fis);

	/* find total number of parameters */
	/* (Each node's number of parameters is specified in
           fisBuildFanList.) */
	fis->para_n = 0;
	for (i = 0; i < fis->node_n; i++)
		fis->para_n += fis->node[i]->para_n;

	/* allocate memory for parameter related arrays */
	fis->para = (DOUBLE *)fisCalloc(fis->para_n, sizeof(DOUBLE));
	fis->trn_best_para = (DOUBLE *)fisCalloc(fis->para_n, sizeof(DOUBLE));
	fis->chk_best_para = (DOUBLE *)fisCalloc(fis->para_n, sizeof(DOUBLE));
	fis->de_dp = (DOUBLE *)fisCalloc(fis->para_n, sizeof(DOUBLE));
	fis->do_dp = (DOUBLE *)fisCalloc(fis->para_n, sizeof(DOUBLE));
	/* assign parameter pointer for each node */
	tmp = 0;
	for (i = 0; i < fis->node_n; i++) {
		if (fis->node[i]->para_n == 0)
			continue;
		fis->node[i]->para = fis->para + tmp;
		fis->node[i]->de_dp = fis->de_dp + tmp;
		fis->node[i]->do_dp = fis->do_dp + tmp;
		tmp += fis->node[i]->para_n;
	}

	/* allocate input array for each node */
	for (i = 0; i < fis->node_n; i++)
		fis->node[i]->input = (DOUBLE *)
			fisCalloc(fis->node[i]->fanin_n, sizeof(DOUBLE));

	/* copy input MF parameters from FIS data structure */
	tmp = 0;
	for (i = 0; i < fis->in_n; i++)
		for (j = 0; j < fis->input[i]->mf_n; j++) {
			mf_type = fis->input[i]->mf[j]->type;
			for (k = 0; k < fisGetMfParaN(mf_type); k++)
				fis->para[tmp++] = fis->input[i]->mf[j]->params[k]; 
		}

	/* copy output parameters from FIS data structure */
	for (i = 0; i < fis->out_n; i++) {
		for (j = 0; j < fis->output[i]->mf_n; j++) {
			if (fis->order==1)
				for (k = 0; k < fis->in_n+1; k++)
					fis->para[tmp++] = fis->output[i]->mf[j]->params[k]; 
			else
				fis->para[tmp++] = fis->output[i]->mf[j]->params[fis->in_n];
		}
	}
}


static void anfisAssignForwardFunction(FIS *fis)
{
	int i, j, start, stop;
	DOUBLE (*nodeFcn)();

	for (i = 0; i < 7; i++) {
		switch(i) {
			case 0:
				nodeFcn = anfisInputNode;
				break;
			case 1:
				nodeFcn = anfisMfNode;
				break;
			case 2:
				nodeFcn = anfisInvNode;
				break;
			case 3:
				nodeFcn = anfisAndOrNode;
				break;
			case 4:
				nodeFcn = anfisRuleOutputNode;
				break;
			case 5:
				nodeFcn = anfisSummationNode;
				break;
			case 6:
				nodeFcn = anfisDivisionNode;
				break;
			default:
				fisError("Unknown layer!");
		}
		start = fis->layer[i]->index;
		stop = start + fis->layer_size[i] - 1;
		for (j = start; j <= stop; j++)
			fis->node[j]->nodeFcn = nodeFcn;
	}
}

static void anfisFreeAnNode(NODE *node)
{
	int i;
	FAN *now, *next;

	FREEARRAY(node->input);

	/* free fanin list */
	now = node->fanin;
	for (i = 0; i < node->fanin_n; i++) {
		next = now->next;
		FREEARRAY(now);
		now = next;
	}

	/* free fanout list */
	now = node->fanout;
	for (i = 0; i < node->fanout_n; i++) {
		next = now->next;
		FREEARRAY(now);
		now = next;
	}
	/*
	FREEARRAY(node);
	*/
	/* node->para, node->de_dp, and node->do_dp
	are freed in anfisFreeAnfis() */
}

static void anfisFreeAnfis(FIS *fis)
{
	int i, in_n, out_n;

	FREEARRAY(fis->in_mf_n);
	FREEARRAY(fis->out_mf_n);
	FREEARRAY(fis->para);
	FREEARRAY(fis->trn_best_para);
	FREEARRAY(fis->chk_best_para);
	FREEARRAY(fis->de_dp);
	FREEARRAY(fis->do_dp);
	for (i = 0; i < fis->node_n; i++)
		anfisFreeAnNode(fis->node[i]);
	FREEARRAY(fis->node[0]);
	FREEARRAY(fis->node);
	FREEMAT((void **)fis->trn_data, fis->trn_data_n);
	FREEMAT((void **)fis->chk_data, fis->chk_data_n);
	FREEARRAY(fis->ss_array);
	FREEARRAY(fis->trn_error);
	FREEARRAY(fis->chk_error);
	FREEARRAY(fis->kalman_io_pair);
	FREEMAT((void **)fis->tmp_node_output, fis->trn_data_n);

	/* the following is for kalman matrices */
	if (fis->method==1 || fis->method==0)
		in_n = ((fis->order)*(fis->in_n)+1)*fis->rule_n;
	else
		in_n = fis->para_n;
	out_n = fis->out_n;

	FREEMAT((void **)fis->kalman_para, in_n);

	FREEMAT((void **)fis->S, in_n);
	FREEMAT((void **)fis->P, in_n);
	FREEMAT((void **)fis->a, in_n);
	FREEMAT((void **)fis->b, out_n);
	FREEMAT((void **)fis->a_t, 1);
	FREEMAT((void **)fis->b_t, 1);
	FREEMAT((void **)fis->tmp1, in_n);
	FREEMAT((void **)fis->tmp2, 1);
	FREEMAT((void **)fis->tmp3, 1);
	FREEMAT((void **)fis->tmp4, in_n);
	FREEMAT((void **)fis->tmp5, 1);
	FREEMAT((void **)fis->tmp6, in_n);
	FREEMAT((void **)fis->tmp7, in_n);
}

/* Initial variables, for off-line learning only */
static void anfisSetVariable(FIS *fis)
{
	int i, in_n, out_n;

	fis->ss_array = (DOUBLE *)fisCalloc(fis->epoch_n, sizeof(DOUBLE));
	for (i = 0; i < fis->epoch_n; i++)
		fis->ss_array[i] = -1;
	fis->trn_error = (DOUBLE *)fisCalloc(fis->epoch_n, sizeof(DOUBLE));
	for (i = 0; i < fis->epoch_n; i++)
		fis->trn_error[i] = -1;
	if (fis->chk_data_n != 0) {
		fis->chk_error = (DOUBLE *)fisCalloc(fis->epoch_n,sizeof(DOUBLE));
		for (i = 0; i < fis->epoch_n; i++)
			fis->chk_error[i] = -1;
	}

	if (fis->method==1 || fis->method==0)
		in_n = ((fis->order)*(fis->in_n)+1)*fis->rule_n;
	else 
		in_n = fis->para_n;
	out_n = fis->out_n;

	fis->kalman_io_pair = (DOUBLE *)fisCalloc
		(in_n+fis->out_n, sizeof(DOUBLE));
	fis->kalman_para = (DOUBLE **)fisCreateMatrix
		(in_n, 1, sizeof(DOUBLE));
	fis->tmp_node_output = (DOUBLE **)fisCreateMatrix
		(fis->trn_data_n, fis->in_n+2*fis->total_in_mf_n+fis->rule_n,
		sizeof(DOUBLE));
	fis->lambda = 1;
	fis->min_trn_error = pow(2.0, 31.0)-1;
	fis->min_chk_error = pow(2.0, 31.0)-1;
	fis->last_dec_ss = 0;
	fis->last_inc_ss = 0;

	/* allocate static memory for Kalman filter algorithm */
	{
	/* ========== */
	fis->S = (DOUBLE **)fisCreateMatrix(in_n, in_n, sizeof(DOUBLE));
	fis->P = (DOUBLE **)fisCreateMatrix(in_n, out_n, sizeof(DOUBLE));
	fis->a = (DOUBLE **)fisCreateMatrix(in_n, 1, sizeof(DOUBLE));
	fis->b = (DOUBLE **)fisCreateMatrix(out_n, 1, sizeof(DOUBLE));
	fis->a_t = (DOUBLE **)fisCreateMatrix(1, in_n, sizeof(DOUBLE));
	fis->b_t = (DOUBLE **)fisCreateMatrix(1, out_n, sizeof(DOUBLE));
	fis->tmp1 = (DOUBLE **)fisCreateMatrix(in_n, 1, sizeof(DOUBLE));
	fis->tmp2 = (DOUBLE **)fisCreateMatrix(1, 1, sizeof(DOUBLE));
	fis->tmp3 = (DOUBLE **)fisCreateMatrix(1, in_n, sizeof(DOUBLE));
	fis->tmp4 = (DOUBLE **)fisCreateMatrix(in_n, in_n, sizeof(DOUBLE));
	fis->tmp5 = (DOUBLE **)fisCreateMatrix(1, out_n, sizeof(DOUBLE));
	fis->tmp6 = (DOUBLE **)fisCreateMatrix(in_n, out_n, sizeof(DOUBLE));
	fis->tmp7 = (DOUBLE **)fisCreateMatrix(in_n, out_n, sizeof(DOUBLE));
	}
}

/* Initial variables, for on-line learning only */
static void anfisSetVariable1(FIS *fis)
{

	fis->kalman_io_pair = (DOUBLE *)fisCalloc
		((fis->in_n+1)*fis->rule_n+fis->out_n, sizeof(DOUBLE));
	fis->kalman_para = (DOUBLE **)fisCreateMatrix
		((fis->in_n+1)*fis->rule_n, 1, sizeof(DOUBLE));
	fis->display_anfis_info = 1;	/* always display anfis info */
	/* allocate static memory for Kalman filter algorithm */
	{
	int in_n = (fis->in_n+1)*fis->rule_n;
	int out_n = fis->out_n;
	fis->S = (DOUBLE **)fisCreateMatrix(in_n, in_n, sizeof(DOUBLE));
	fis->P = (DOUBLE **)fisCreateMatrix(in_n, out_n, sizeof(DOUBLE));
	fis->a = (DOUBLE **)fisCreateMatrix(in_n, 1, sizeof(DOUBLE));
	fis->b = (DOUBLE **)fisCreateMatrix(out_n, 1, sizeof(DOUBLE));
	fis->a_t = (DOUBLE **)fisCreateMatrix(1, in_n, sizeof(DOUBLE));
	fis->b_t = (DOUBLE **)fisCreateMatrix(1, out_n, sizeof(DOUBLE));
	fis->tmp1 = (DOUBLE **)fisCreateMatrix(in_n, 1, sizeof(DOUBLE));
	fis->tmp2 = (DOUBLE **)fisCreateMatrix(1, 1, sizeof(DOUBLE));
	fis->tmp3 = (DOUBLE **)fisCreateMatrix(1, in_n, sizeof(DOUBLE));
	fis->tmp4 = (DOUBLE **)fisCreateMatrix(in_n, in_n, sizeof(DOUBLE));
	fis->tmp5 = (DOUBLE **)fisCreateMatrix(1, out_n, sizeof(DOUBLE));
	fis->tmp6 = (DOUBLE **)fisCreateMatrix(in_n, out_n, sizeof(DOUBLE));
	fis->tmp7 = (DOUBLE **)fisCreateMatrix(in_n, out_n, sizeof(DOUBLE));
	}
}

/* check the validity of the FIS structure for learning */
static void anfisCheckFisForLearning(FIS *fis)
{
	int i, j, mfcount=0;
	int *mfarray;

        mfarray = (int *)fisCalloc(fis->rule_n, sizeof(int));
        for (i=0; i<fis->rule_n; i++){
           mfarray[i]=0;
        }
	/* user-defined operators are not allow */
	if (fis->userDefinedAnd || fis->userDefinedOr ||
	    fis->userDefinedImp || fis->userDefinedAgg ||
	    fis->userDefinedDefuzz) {
		fisFreeFisNode(fis);
		fisError("User-defined operators are not allowed!");
	}

	/* user-defined MF are not allow */
	for (i = 0; i < fis->in_n; i++)
		for (j = 0; j < fis->input[i]->mf_n; j++)
			if (fis->input[i]->mf[j]->userDefined) {
				fisFreeFisNode(fis);
				fisError("User-defined MF's are not allowed!");
			}
	for (i = 0; i < fis->out_n; i++)
		for (j = 0; j < fis->output[i]->mf_n; j++)
			if (fis->output[i]->mf[j]->userDefined) {
				fisFreeFisNode(fis);
				fisError("User-defined MF's are not allowed!");
			}

	/* must be sugeno type */
	if (strcmp(fis->type, "sugeno")) {
		fisFreeFisNode(fis);
		fisError("Given FIS matrix is not of Sugeno type!"); 
	}

	/* must have only one output */
	if (fis->out_n != 1) {
		fisFreeFisNode(fis);
		fisError("Given FIS has more than one output!"); 
	}

	/* must use weighted average for deriving final output */
	if (strcmp(fis->defuzzMethod, "wtaver")) {
		fisFreeFisNode(fis);
		fisError("ANFIS only supports weighted average (wtaver)."); 
	}

	/* must have more than one rule */
	if (fis->rule_n <= 1) {
		fisFreeFisNode(fis);
		fisError("Need at least two rules for ANFIS learning!");
	}

	/* output MF no. must be the same as rule no. */
	if (fis->output[0]->mf_n != fis->rule_n) {
		fisFreeFisNode(fis);
		PRINTF("Number of output MF's is not equal to number of rules -->\n");
		fisError("Parameter sharing in FIS is not allowed!");
	}
	else { 
             /* output Parameter sharing in FIS is not allowed! */
           for (i=0; i< fis->rule_n; i++){
              mfcount=fis->rule_list[i][fis->in_n]-1;
              mfarray[mfcount] ++;
           }
           for (i=0; i<fis->rule_n; i++){
              if (mfarray[mfcount]==0 || mfarray[mfcount]>1){
		PRINTF("Output MF %s is used twice\n", fis->output[0]->mf[i]->label);
		fisError("Parameter sharing in FIS is not allowed!");
              }
           }
        }

	/* ========== */ 
	/* output MF must be of linear */ 
	/*
	for (i = 0; i < fis->output[0]->mf_n; i++)
		if (strcmp(fis->output[0]->mf[i]->type, "linear")) {
			fisFreeFisNode(fis);
			fisError("Each rule's output must be of linear type!");
		}
	*/
	/* output MF must be either all linear or all constant */ 
	{
	int all_linear = 1;
	int all_constant = 1;
	for (i = 0; i < fis->output[0]->mf_n; i++)
		if (strcmp(fis->output[0]->mf[i]->type, "linear")) {
			all_linear = 0;
			break;
		}
	for (i = 0; i < fis->output[0]->mf_n; i++)
		if (strcmp(fis->output[0]->mf[i]->type, "constant")) {
			all_constant = 0;
			break;
		}
	if (all_linear == 0 && all_constant == 0) {
		fisFreeFisNode(fis);
		fisError("Rules' outputs must be either of all linear"
			" or all constant!");
	}
	/*
	if (all_linear == 1)
		printf("Rule outputs are all linear.\n");
	if (all_constant == 1)
		printf("Rule outputs are all constant.\n");
	*/
	}

	/* rule weight must be one */
	for (i = 0; i < fis->rule_n; i++)
		if (fis->rule_weight[i] != 1) {
			fis->rule_weight[i] = 1;
			PRINTF("Warning: weight of rule %d is set to 1"
				" for ANFIS learning!\n", i+1);
		}
}
