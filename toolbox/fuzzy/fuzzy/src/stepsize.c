/* Copyright 1994-2002 The MathWorks, Inc.  */
/* $Revision: 1.12 $  $Date: 2002/06/17 12:47:12 $  $Author: eyarrow $ */

/* return 1 if the step size needs to be increased, 0 otherwise */
int anfisCheckIncreaseSs(DOUBLE *error_array, int last_change, int current)
{
	if (current - last_change < 4)
		return(0);
	if ((error_array[current]     < error_array[current - 1]) &&
	    (error_array[current - 1] < error_array[current - 2]) &&
	    (error_array[current - 2] < error_array[current - 3]) &&
	    (error_array[current - 3] < error_array[current - 4])) 
		return(1);
	return(0);
}

/* return 1 if the step size needs to be decreased, 0 otherwise */
int anfisCheckDecreaseSs(DOUBLE *error_array, int last_change, int current)
{
	if (current - last_change < 4)
		return(0);
	if ((error_array[current]     < error_array[current - 1]) &&
	    (error_array[current - 1] > error_array[current - 2]) &&
	    (error_array[current - 2] < error_array[current - 3]) &&
	    (error_array[current - 3] > error_array[current - 4])) 
		return(1);
	return(0);
}

/* update step size */
static void anfisUpdateStepSize(FIS *fis, int i)
{
	if (anfisCheckDecreaseSs(fis->trn_error, fis->last_dec_ss, i) &&
		fis->ss_dec_rate != 1) {
		fis->ss *= fis->ss_dec_rate;
		if (fis->display_ss)
		printf("Step size decreases to %f after epoch %d.\n", fis->ss, i+1);
		fis->last_dec_ss = i;
		return;
	}

	if (anfisCheckIncreaseSs(fis->trn_error, fis->last_inc_ss, i) &&
		fis->ss_inc_rate != 1) {
		fis->ss *= fis->ss_inc_rate;
		if (fis->display_ss)
		printf("Step size increases to %f after epoch %d.\n", fis->ss, i+1);
		fis->last_inc_ss = i;
		return;
	}
}
