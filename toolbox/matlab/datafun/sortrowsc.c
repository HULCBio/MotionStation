/*
 * Copyright 1984-2002 The MathWorks, Inc.
 * $Revision: 1.5.4.1 $  $Date: 2003/12/26 18:08:45 $
 *
 * NDX = SORTROWSC(X) returns a permutation vector NDX such that 
 * X(NDX,:) sorts the rows of X.  X must be a 2-D real numeric (nonsparse) 
 * or char matrix.  NDX is an M-by-1 double matrix, where M=SIZE(X,1).  
 * SORTROWSMEX uses the standard C library function qsort().  The
 * comparison functions (see compare_fcn.c) are written to use the
 * row index as a tiebreaker; this has the effect of making the sort
 * stable.
 */

static char rcsid[] = "$Id: sortrowsc.c,v 1.5.4.1 2003/12/26 18:08:45 batserve Exp $";

#include "lexicmp.h"
#include "mex.h"

/*
 * tiebreak_fcn
 * Used by the comparison functions in compare_fcn.c to break ties
 * between two equal rows.  Break the tie using the index value
 * to preserve a stable sort.
 */
int tiebreak_fcn(const void *ptr1, const void *ptr2)
{
    sort_item *item1 = (sort_item *) ptr1;
    sort_item *item2 = (sort_item *) ptr2;
    
    return(item1->index > item2->index ? S1_IS_GREATER : S2_IS_GREATER);
}

/*
 * make_sort_item_array
 * Allocates and initializes an array of sort_item structs.  Caller is 
 * responsible for freeing the allocated array.
 *
 * Inputs
 * ------
 * in       - mxArray; must be a 2-D numeric or char matrix.
 *
 * Returns allocated sort_item array.
 */
sort_item *make_sort_item_array(const mxArray *in)
{
    int num_rows;
    sort_item *result;
    uint8_T *byte_ptr;
    int elem_size;
    int stride;
    int length;
    int k;

    num_rows = mxGetM(in);
    result = (sort_item *) mxCalloc(num_rows, sizeof(sort_item));
    byte_ptr = (uint8_T *) mxGetData(in);
    elem_size = mxGetElementSize(in);

    /*
     * stride is the linear offset between adjacent matrix
     * elements on the same row.
     */
    stride = num_rows;

    /*
     * length is the number of matrix elements on each row.
     */
    length = mxGetN(in);

    for (k = 0; k < num_rows; k++)
    {
        /* 
         * The k-th item in the array has to have a pointer
         * to the k-th row in the input matrix.  This is 
         * accomplished via a little arithmetic on byte pointers.
         */
		if (byte_ptr != NULL)
		{
			result[k].data = (void *) (byte_ptr + k*elem_size);
		}
		else
		{
			result[k].data = NULL;
		}

        result[k].stride = stride;
        result[k].length = length;
        result[k].index = k+1;        /* one-based for MATLAB */
        result[k].tiebreak_fcn = tiebreak_fcn;
        result[k].user_data = NULL;   /* unused by sortrowsmex */
    }

    return(result);
}

/*
 * select_compare_function
 * Select the comparison function to pass to qsort according to
 * the class of the input matrix.
 *
 * Input
 * -----
 * in      - input matrix (mxArray)
 *
 * Returns function pointer
 */
compare_function select_compare_function(const mxArray *in)
{
    compare_function result;

    switch (mxGetClassID(in))
    {
    case mxLOGICAL_CLASS:
	result = lexi_compare_mxlogical;
	break;

    case mxCHAR_CLASS:
        result = lexi_compare_mxchar;
        break;

    case mxUINT8_CLASS:
        result = lexi_compare_uint8;
        break;

    case mxUINT16_CLASS:
        result = lexi_compare_uint16;
        break;

    case mxUINT32_CLASS:
        result = lexi_compare_uint32;
        break;

    case mxUINT64_CLASS:
	result = lexi_compare_uint64;
        break;

    case mxINT8_CLASS:
        result = lexi_compare_int8;
        break;

    case mxINT16_CLASS:
        result = lexi_compare_int16;
        break;

    case mxINT32_CLASS:
        result = lexi_compare_int32;
        break;

    case mxINT64_CLASS:
        result = lexi_compare_int64;
        break;

    case mxSINGLE_CLASS:
        result = lexi_compare_single;
        break;

    case mxDOUBLE_CLASS:
        result = lexi_compare_double;
        break;

    default:
        mexErrMsgIdAndTxt("MATLAB:sortrowsc:UnsupportedDataType",
        "Unsupported class.");
    }

    return(result);
}

/*
 * check_inputs
 * Perform error checking on input arguments.
 */


void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    sort_item *sort_item_array;
    compare_function cmp_function;
    double *pr;
    int num_rows;
    int k;

    const int NumInputs = 1;

    if (nrhs < NumInputs) mexErrMsgIdAndTxt("MATLAB:sortrowsc:TooManyInputs",
        "Too few inputs.");

    if (nrhs > NumInputs) mexErrMsgIdAndTxt("MATLAB:sortrowsc:TooFewInputs",
        "Too many inputs.");
    
    if (mxGetNumberOfDimensions(prhs[0]) > 2)
    {
        mexErrMsgIdAndTxt("MATLAB:sortrowsc:InvalidInput1",
        "Input must be 2-D.");
    }
	if (mxIsSparse(prhs[0]))
	{
        mexErrMsgIdAndTxt("MATLAB:sortrowsc:InvalidInput2",
        "Input must not be sparse.");
	}
    if (! mxIsNumeric(prhs[0]) && ! mxIsChar(prhs[0]) && ! mxIsLogical(prhs[0]))
    {
        mexErrMsgIdAndTxt("MATLAB:sortrowsc:InvalidInput3",
        "Input must be a numeric or char or logical matrix.");
    }

    num_rows = mxGetM(prhs[0]);

    sort_item_array = make_sort_item_array(prhs[0]);

    cmp_function = select_compare_function(prhs[0]);

    qsort(sort_item_array, num_rows, sizeof(sort_item), cmp_function);

    /*
     * Create the output index array and fill it in.
     */
    plhs[0] = mxCreateDoubleMatrix(num_rows, 1, mxREAL);
    pr = (double *) mxGetData(plhs[0]);
    for (k = 0; k < num_rows; k++)
    {
        pr[k] = sort_item_array[k].index;
    }

    mxFree(sort_item_array);
}



