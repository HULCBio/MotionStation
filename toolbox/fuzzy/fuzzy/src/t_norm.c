/***********************************************************************
 T-norm and T-conorm operators
 **********************************************************************/
/* Copyright 1994-2002 The MathWorks, Inc.  */
/* $Revision: $  $Date: $  */

static DOUBLE fisMin(DOUBLE x, DOUBLE y)
{return((x) < (y) ? (x) : (y));}

static DOUBLE fisMax(DOUBLE x, DOUBLE y)
{return((x) > (y) ? (x) : (y));}

static DOUBLE fisProduct(DOUBLE x, DOUBLE y)
{return(x*y);} 

static DOUBLE fisProbOr(DOUBLE x, DOUBLE y)
{return(x + y - x*y);} 

static DOUBLE fisSum(DOUBLE x, DOUBLE y)
{return(x + y);} 

/* apply given function to an array */
static DOUBLE fisArrayOperation(DOUBLE *array, int size, DOUBLE (*fcn)())
{
	int i;
	DOUBLE out;

	if (size == 0)
		fisError("Given size is zero!");

	out = array[0];
	for (i = 1; i < size; i++)
		out = (*fcn)(out, array[i]);
	return(out);
}
