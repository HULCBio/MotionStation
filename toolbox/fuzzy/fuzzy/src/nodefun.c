/* Copyright 1994-2002 The MathWorks, Inc.  */
/* $Revision: 1.12 $  $Date: 2002/06/17 12:47:08 $  $Author: eyarrow $ */

/* setup the input array of node with index index */
static void anfisSetupInputArray(FIS *fis, int index)
{
	FAN *p = fis->node[index]->fanin;
	int i;
	for (i = 0; i < fis->node[index]->fanin_n; i++, p = p->next)
		fis->node[index]->input[i] = fis->node[p->index]->value;
}

/* Node function for each layer */
/* action ==   "forward" --> return O_{index}
   action ==  "backward" --> return dO_{index}/dO_{index2}
				(derivative w.r.t. fan-in nodes)
   action == "parameter" --> return dO_{index}/dP_{index2}
				(derivative w.r.t. parameters)
*/

/* layer 0 */
static DOUBLE anfisInputNode(FIS *fis, int index, char *action, int index2)
{
	fisError("anfisInputNode should not be called at all!");
	return(0);	/* for suppressing compiler's warning only */
}

/* layer 1 */
static DOUBLE anfisMfNode(FIS *fis, int index, char *action, int index2)
{
	int which_input = fis->node[index]->fanin->index;
	int which_mf = fis->node[index]->ll_index;
	DOUBLE input_value = fis->node[which_input]->value;
	DOUBLE (*mfFcn)() = fis->input[which_input]->mf[which_mf]->mfFcn;
	DOUBLE *para = fis->node[index]->para;

	if (strcmp(action, "forward") == 0) {
		/* temperary storage for future use */
		fis->node[index]->tmp = (*mfFcn)(input_value, para);
		return(fis->node[index]->tmp);
	}
	if (strcmp(action, "backward") == 0)
		fisError("MF derivatives w.r.t. inputs should not be called!");
	if (strcmp(action, "parameter") == 0) {
		/* temperary storage for future use */
		return(fisMfDerivative(mfFcn, input_value, para, index2));
	}
	fisError("Unknown action!\n");
	return(0);	/* for suppressing compiler's warning only */
}

/* layer 2 */
static DOUBLE anfisInvNode(FIS *fis, int index, char *action, int index2)
{
	int fanin_node_index = fis->node[index]->fanin->index;
	DOUBLE in_mf_value = fis->node[fanin_node_index]->value;

	if (strcmp(action, "forward") == 0)
		return(1.0 - in_mf_value);
	if (strcmp(action, "backward") == 0)
		return(-1.0);
	if (strcmp(action, "parameter") == 0)
		return(0.0);
	fisError("Unknown action!\n");
	return(0);	/* for suppressing compiler's warning only */
}

/* layer 3 */
static DOUBLE anfisAndOrNode(FIS *fis, int index, char *action, int index2)
{
	DOUBLE *input = fis->node[index]->input;
	int which_rule = fis->node[index]->l_index;
	int and_or = fis->and_or[which_rule];
	DOUBLE (*AndOrFcn)() = and_or == 1? fis->andFcn:fis->orFcn;
	int i;

	anfisSetupInputArray(fis, index);

	if (strcmp(action, "forward") == 0) {
		fis->node[index]->tmp =
			fisArrayOperation(input, fis->node[index]->fanin_n,
			AndOrFcn);
		return(fis->node[index]->tmp);
	}
	if (strcmp(action, "backward") == 0) {
		if ((AndOrFcn == fisMin) || (AndOrFcn == fisMax)) {
			for (i = 0; i < fis->node[index]->fanin_n; i++)
				if (fis->node[index]->tmp == input[i])
					break;
			return(index2 == i? 1.0:0.0);
		}
		if (AndOrFcn == fisProduct) {
			DOUBLE product = 1.0;
			for (i = 0; i < fis->node[index]->fanin_n; i++) {
				if (i == index2)
					continue;
				product *= input[i];
			}
			return(product);
		}
		if (AndOrFcn == fisProbOr) {
			DOUBLE product = 1.0;
			for (i = 0; i < fis->node[index]->fanin_n; i++) {
				if (i == index2)
					continue;
				product *= (1 - input[i]);
			}
			return(product);
		}
	}
	if (strcmp(action, "parameter") == 0)
		return(0.0);
	fisError("Unknown action!\n");
	return(0);	/* for suppressing compiler's warning only */
}

/* layer 4 */
static DOUBLE anfisRuleOutputNode(FIS *fis, int index, char *action, int index2)
{
	DOUBLE *input;
	DOUBLE firing_strength;
	DOUBLE *para = fis->node[index]->para;
	int i;
	DOUBLE sum = 0;

	anfisSetupInputArray(fis, index);
	input = fis->node[index]->input;

	/* ========== */
	if (fis->order==1) {
		for (i = 0; i < fis->in_n; i++)
			sum += input[i]*para[i];
		sum += para[fis->in_n];
	} else
		sum = para[0];
	firing_strength = input[fis->in_n];

	if (strcmp(action, "forward") == 0)
		return(firing_strength*sum);

	/* ========== */
	if (strcmp(action, "backward") == 0)
		return(index2 != fis->in_n?
			fis->order*(firing_strength*para[index2]):sum);
	/* ========== */
	if (strcmp(action, "parameter") == 0) {
		if (fis->order == 1)
			return(index2 != fis->in_n?
			firing_strength*input[index2]:firing_strength);
		else
			return(firing_strength);
	}
	fisError("Unknown action!\n");
	return(0);      /* for suppressing compiler's warning only */
}

/* layer 5 */
static DOUBLE anfisSummationNode(FIS *fis, int index, char *action, int index2)
{
	FAN *p, *fanin = fis->node[index]->fanin;
	DOUBLE sum = 0;

	for (p = fanin; p != NULL; p = p->next)
		sum += fis->node[p->index]->value;

	if (strcmp(action, "forward") == 0)
		return(sum);
	if (strcmp(action, "backward") == 0)
		return(1.0);
	if (strcmp(action, "parameter") == 0)
		return(0.0);
	fisError("Unknown action!\n");
	return(0);      /* for suppressing compiler's warning only */
}

/* layer 6 */
static DOUBLE anfisDivisionNode(FIS *fis, int index, char *action, int index2)
{
	DOUBLE total_wf, total_w;

	anfisSetupInputArray(fis, index);
	total_wf = fis->node[index]->input[0];
	total_w = fis->node[index]->input[1];

	if (total_w == 0)
		fisError("Total of firing strength is zero!\n");

	if (strcmp(action, "forward") == 0)
		return(total_wf/total_w);
	if (strcmp(action, "backward") == 0) {
		if (index2 == 0)
			return(1/total_w);
		if (index2 == 1)
			return(-total_wf/(total_w*total_w));
		fisError("Wrong index2!\n");
	}
	if (strcmp(action, "parameter") == 0)
		return(0.0);
	fisError("Unknown action!\n");
	return(0);      /* for suppressing compiler's warning only */
}
