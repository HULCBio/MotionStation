/*
 * Copyright 1984-2002 The MathWorks, Inc.
 * $Revision: 1.4.4.1 $  $Date: 2003/12/26 18:08:44 $
 *
 * NDX = SORTCELLCHAR(X) returns a permutation vector NDX such that
 * X(NDX) sorts the cells of X by lexicographic order (dictionary
 * sort).  X must be a cell array containing char arrays and possibly
 * empty arrays.  X is sorted as X(:).  SORTCELLCHAR uses the standard
 * C library function qsort() and the char lexicographic comparison
 * function in compare_fcn.c.  The comparison function is written to use
 * a string's linear index as a tiebreaker; this has the effect of making
 * the sort stable.
 */

static char rcsid[] = "$Id: sortcellchar.c,v 1.4.4.1 2003/12/26 18:08:44 batserve Exp $";

#include "lexicmp.h"
#include "mex.h"

/*
 * is_normal_empty
 *
 * Is an mxArray pointer either NULL or [].
 */
bool is_normal_empty(const mxArray *in)
{
	bool result;

	if (in == NULL)
	{
		result = true;
	}
	else
	{
		result = mxIsDouble(in)                && 
			(mxGetNumberOfDimensions(in) == 2) &&
			(mxGetM(in) == 0)                  &&
			(mxGetN(in) == 0);
	}

	return(result);
}

/*
 * check_cell
 *
 * Make sure that the cell is either a char array, [], or NULL.
 * NULL flags a cell in a cell array that has not yet been assigned
 * a value, which is treated by MATLAB as if it were the same as [].
 */
void check_cell(const mxArray *cell)
{
    if (!is_normal_empty(cell) && !mxIsChar(cell))
    {
        mexErrMsgIdAndTxt("MATLAB:sortcellchar:UnsupportedDataType",
        "Cell array can only contain char arrays and []'s.");
    }
}

/*
 * tiebreak_fcn
 * Used by the comparison functions in compare_fcn.c to break ties
 * between two equal rows.  Sort an empty string ('') greater than
 * an unfilled cell.  Otherwise use the index as a tiebreaker to
 * make a stable sort.
 */
int tiebreak_fcn(const void *ptr1, const void *ptr2)
{
    sort_item *item1 = (sort_item *) ptr1;
    sort_item *item2 = (sort_item *) ptr2;

    if (item1->data == NULL)
    {
        /*
         * Both items are empty.  Do we have the case where one is
         * an empty string and the other is an unfilled cell?
         * The user_data field contains the pointer returned
         * by mxGetCell(mxArray *in, int k).  If user_data is NULL,
         * then that cell is unfilled.  Otherwise that cell must
         * be an empty char array.
         */

        mxArray *cell1 = (mxArray *) item1->user_data;
        mxArray *cell2 = (mxArray *) item2->user_data;
        
        if (is_normal_empty(cell1) && (cell2 != NULL) && mxIsChar(cell2))
        {
            /*
             * item1 is [] and item2 is ''.
             */
            return(S2_IS_GREATER);
        }
        else if ((cell1 != NULL) && mxIsChar(cell1) && is_normal_empty(cell2))
        {
            /*
             * item1 is '' and item2 is []
             */
            return(S1_IS_GREATER);
        }
        else
        {
            /*
             * Both items are the same kind of "empty."  Do nothing here.
             */
        }
    }

    /*
     * Use the index field as a tiebreaker.
     */
    return(item1->index > item2->index ? S1_IS_GREATER : S2_IS_GREATER);
}
/*
 * make_sort_item_array
 *
 * Allocate sort_item array and fill it.  Treat NULL cells and empty
 * cells the same way --- data pointer = NULL and length = 0.
 */
sort_item  *make_sort_item_array(const mxArray *in)
{
    sort_item *result;
    int num_elements;
    int k;
    mxArray *cell;

    num_elements = mxGetNumberOfElements(in);
    result = (sort_item *) mxCalloc(num_elements, sizeof(sort_item));

    for (k = 0; k < num_elements; k++)
    {
        cell = mxGetCell(in, k);
        check_cell(cell);

        result[k].index = k + 1;  /* one-based for MATLAB */
        result[k].tiebreak_fcn = tiebreak_fcn;
        result[k].user_data = (void *) cell;

        if (cell == NULL)
        {
            result[k].data = NULL;
            result[k].length = 0;
            result[k].stride = 1;
        }
        else
        {
            result[k].data = mxGetData(cell);
            result[k].length = mxGetNumberOfElements(cell);
            result[k].stride = 1;
        }
    }

    return result;
}

/*
 * check_inputs
 *
 * Perform error checking on input arguments.
 */
void check_inputs(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{

}

void mexFunction(int nlhs, 
                 mxArray *plhs[], 
                 int nrhs, 
                 const mxArray *prhs[])
{
    int num_elements;
    int k;
    sort_item *sort_item_array;
    double *pr;

    const int NumInputs = 1;

    if (nrhs > NumInputs) mexErrMsgIdAndTxt("MATLAB:sortcellchar:TooManyInputs",
         "Too many input arguments.");
    if (nrhs < NumInputs) mexErrMsgIdAndTxt("MATLAB:sortcellchar:TooFewInputs",
       "Not enough input arguments.");
  
    if (! mxIsCell(prhs[0])) mexErrMsgIdAndTxt("MATLAB:sortcellchar:InvalidInput",
        "Input must be a cell array.");
    
    num_elements = mxGetNumberOfElements(prhs[0]);

    sort_item_array = make_sort_item_array(prhs[0]);

    qsort((void *) sort_item_array, num_elements, sizeof(sort_item),
          lexi_compare_mxchar);

    /*
     * Create the output index vector and fill it.
     */
    plhs[0] = mxCreateDoubleMatrix(num_elements, 1, mxREAL);
    pr = (double *) mxGetData(plhs[0]);
    for (k = 0; k < num_elements; k++)
    {
        pr[k] = (double) sort_item_array[k].index;
    }

    mxFree(sort_item_array);
}
