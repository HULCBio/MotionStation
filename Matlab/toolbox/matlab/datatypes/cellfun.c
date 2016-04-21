/*  $RCSfile: cellfun.c,v $
 *
 *   CELLFUN Cell array functions.
 *   D = CELLFUN(FUN, C) where FUN is one of 
 *
 *   	'isreal'    -- true for real cell element
 *  	'isempty'   -- true for empty cell element
 *  	'islogical' -- true for logical cell element
 *  	'length'    -- length of cell element
 *  	'ndims'     -- number of dimensions of cell element
 *  	'prodofsize'-- number of elements in cell element
 *
 *  and C is the cell array, returns the results of
 *  applying the specified function to each element of
 *  the cell array. D is a logical or double array the
 *  same size as C containing the results of applying
 *  FUN on the corresponding cell elements of C.
 *
 *  D = CELLFUN('size', C, K) returns the size along
 *  the K-th dimension of each element of C.
 *
 *  D = CELLFUN('isclass', C, CLASSNAME) returns true 
 *  for a cell element if the class of the element 
 *  matches the CLASSNAME string.
 *
 *
 *   $Revision: 1.8.4.1 $
 *
 *
/* 
 * $Log: cellfun.c,v $
 * Revision 1.8.4.1  2004/01/02 18:03:33  batserve
 * 2003/12/12  1.8.14.1  batserve
 *   2003/12/12  1.8.16.1  tfarajia
 *     Code Reviewer: Penny
 *     Did not restrict single, added error IDs
 *   Accepted job 270 in Alead
 * Accepted job 12420 in A
 *
 * Revision 1.8.14.1  2003/12/12 21:03:37  batserve
 * 2003/12/12  1.8.16.1  tfarajia
 *   Code Reviewer: Penny
 *   Did not restrict single, added error IDs
 * Accepted job 270 in Alead
 *
 * Revision 1.8.16.1  2003/12/12 16:39:43  tfarajia
 * Code Reviewer: Penny
 * Did not restrict single, added error IDs
 *
 * Revision 1.8  2002/06/27 20:38:18  maberman
 * Updated copyrights to 2002.
 * Related Records: 127981
 * Code Reviewer: diff, copyrightupdate.pl
 *
 * Revision 1.8  2002/06/17 18:58:31  maberman
 * Updated copyrights to 2002.
 * Related Records: 127981
 * Code Reviewer: diff, copyrightupdate.pl
 *
 * Revision 1.7  2001/10/05 10:39:19  marc
 * Revised to use new mx API for logicals rather than calling
 * mxSetLogical.
 * Related Records: Logical is a type
 * Code Reviewer: TBRB scott; BAT:138422a@R12lang
 *
 * Revision 1.6  2001/09/23 20:31:55  marc
 * Use mxIsComplex() when checking complexity.
 * Related Records: Correct API usage
 * Code Reviewer: TBRB scott; BAT:137300@R12compiler
 *
 * Revision 1.5  2001/04/15 12:03:38  scott
 * Update copyrights to 2001.
 * Related Records: 93825
 * Code Reviewer: mdiff&emacs; BAT:118303c@R12compiler
 *
 * Revision 1.4  2000/06/01 03:54:45  joeya
 * Copyright fix
 *
 * Revision 1.3  1999/07/14 15:39:08  mmirman
 * Fixed RCS Log record
 *
 * Revision 1.2  1999/01/13  17:19:49  joeya
 * Updated the ending copyright date
 *
 * Revision 1.1  1998/02/04  22:28:33  nausheen
 * Initial revision
 *
 *
 *
 *   $Author: batserve $
 *
 *
 *   Copyright 1984-2002 The MathWorks, Inc. 
 *
 */

#include <string.h>
#include <math.h>
#include "mex.h"

/* Function that checks for cell elements that are real */
void cellIsReal(mxLogical *pl, const mxArray *prhs, int numel) 
{
    int	    i;
    mxArray *cell;

    for (i = 0; i < numel; i++) {
        cell = mxGetCell(prhs, i);
	if (cell != NULL)  {
	    if (!mxIsCell(cell) && !mxIsStruct(cell)) {
		*pl = !mxIsComplex(cell);
	    } else {
		*pl = false;
	    }
	} else {
	    /* Empty matrices are regarded to be real */
	    *pl = true;
	}
	pl++;
    }
}

/* Function that tests if the cell elements are empty */
void cellIsEmpty(mxLogical *pl, const mxArray *prhs, int numel)
{
    int	    i;
    mxArray *cell;

    /* Return 1 if contents are empty, 0 otherwise */
    for (i = 0; i < numel; i++) {
	cell = mxGetCell(prhs,i);
	if (cell != NULL) {
	    *pl = mxIsEmpty(cell);
	} else {
	    /* Uninitialized cell elements are treated as [] */
	    *pl = true;
	}
	pl++;
    }
}

/* Function that tests if the cell elements are logical */
void cellIsLogical(mxLogical *pl, const mxArray *prhs, int numel)
{
    int	    i;
    mxArray *cell;

    for(i = 0; i < numel; i++) {
	cell = mxGetCell(prhs,i);
	if (cell != NULL) {
	    *pl = mxIsLogical(cell);
	} else {
	    /* Empty matrices are not logical */
	    *pl = false;
	}
	pl++;
    }
}

/* Function that checks for cell elements that match the desired class */
void cellIsClass(mxLogical *pl, const mxArray *prhs[], int numel)
{

    int status, i;
    int buflen = mxGetNumberOfElements(prhs[2]) + 1;
    char *querystr = mxMalloc(buflen*sizeof(char));
    mxArray *cell;
    
    status = mxGetString(prhs[2], querystr, buflen);
    if (status != 0) {
        mexErrMsgIdAndTxt("MATLAB:cellfun:InvalidString",
        "Could not get string.");
    }	    
    
    for (i = 0; i < numel; i++) {
	cell = mxGetCell(prhs[1],i);
	if (cell != NULL) {
	    *pl = mxIsClass(cell, querystr);
	} else {
	    /* Empty matrices belong to the double class */
	    if (!strcmp(querystr,"double")) {
		*pl = true;
	    } else {
		*pl = false;
	    }
	}
	pl++;
    }
    mxFree(querystr);
}

/* Function that computes the size of every cell element based on the
   desired dimensions
 */
void cellSize(double *pr, const mxArray *prhs[], int numel)
{
    double	dim;
    int		i,n;
    mxArray	*cell;

    if (!mxIsDouble(prhs[2]) || mxGetNumberOfElements(prhs[2])!=1) {
        
    mexErrMsgIdAndTxt("MATLAB:cellfun:InvalidThirdInput",
    "Dimension number must be a positive scalar integer.");
    }
    dim = mxGetScalar(prhs[2]);
    if (floor(dim) != dim || dim < 1) {
	mexErrMsgIdAndTxt("MATLAB:cellfun:InvalidThirdInput",
    "Dimension number must be a positive scalar integer.");
    }
    n = (int)(dim - 1);
    
    for ( i = 0; i < numel; i++) {
	cell = mxGetCell(prhs[1], i);
	
	if (cell != NULL) {
	    const int *dims = mxGetDimensions(cell);
	    int ndim = mxGetNumberOfDimensions(cell);
	    *pr = ((double)(n < ndim ? dims[n] : 1.0));
	} else {
	    /* Dimension value greater than 2 for an empty matrix
	       is 1.
	     */
	    *pr = (n < 2 ? 0.0 : 1.0);
	}
	pr++;
    }
}

/* Function that computes the length of the cell elements */
void cellLength(double *pr, const mxArray *prhs, int numel)
{
   
    int		i, j;
    mxArray	*cell;
    const int	*ndims;
    int		lenmax;

    for (i = 0; i<numel; i++) {
	cell = mxGetCell(prhs,i);

	/* return the length of the array */	
	if (cell != NULL) {
	    ndims = mxGetDimensions(cell);
	    lenmax = ndims[0];

	    if (mxIsEmpty(cell)) {
		*pr = 0.0;
	    } else {
		for (j=0;j<mxGetNumberOfDimensions(cell);j++) {
		    if (lenmax < ndims[j]) {
			lenmax = ndims[j];
		    }
		}
		*pr = ((double) lenmax);
	    }
	} else {
	    /*Length of empty matrix is zero */
	    *pr = 0.0;
	}
	pr++;
    }    
}

/* Function that computes the number of dimensions of the cell elements */
void cellNDims(double *pr, const mxArray *prhs, int numel)
{
    int	    i;
    mxArray *cell;

    /* Return the number of dimensions */
    for (i = 0; i < numel; i++) {
	cell = mxGetCell(prhs,i);
	if (cell != NULL) {
	    *pr = ((double)mxGetNumberOfDimensions(cell));
	} else {
	    /* Empty matrix is two dimensional */
	    *pr = 2.0;
	}
	pr++;
    }
}

/* Function that computes the number of elements in a cell */
void cellProdOfSize(double *pr, const mxArray *prhs, int numel)
{
    int	    i;
    mxArray *cell;

    for (i = 0; i < numel; i++) {
	cell = mxGetCell(prhs,i);
	if (cell != NULL) {
	    *pr = ((double)mxGetNumberOfElements(cell));
	} else {
	    /* The number of elements of [] is 0 */
	    *pr = 0.0;
	}
	pr++;
    }
}

/* ******************** MEX GATEWAY ***************************************/
/*  Mex interface to functions that operate on cell elements.
    Currently supported functions are - isreal, isempty, isclass,
    islogical, size, length, ndims.
 */
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
        
    int			numel;
    int			buflen, status, twoinputs;
    double		*pr = NULL;
    mxLogical		*pl = NULL;
    char		*buf;
    const char		*errMsg = "Incorrect number of inputs.";
    const int MaxNumInputs = 3;
    const int MinNumInputs = 2; 

    /* Get the inputs - mostly two and three for size and isclass */
    if (nrhs < MinNumInputs) mexErrMsgIdAndTxt("MATLAB:cellfun:TooFewInputs",
				     "Too few inputs.");
    if (nrhs > MaxNumInputs) mexErrMsgIdAndTxt("MATLAB:cellfun:TooManyInputs",
				     "Too many inputs.");

    /* Ensure that the first argument is a string and the second is a cell */
    if (!mxIsChar(prhs[0])) {
    mexErrMsgIdAndTxt("MATLAB:cellfun:InvalidFirstInput","Function name must be a string.");
    } else if (!mxIsCell(prhs[1])) {
    mexErrMsgIdAndTxt("MATLAB:cellfun:InvalidSecondInput","cellfun works only on cells.");
    }
    
    /* Get the number of elements in the cell */
    numel = mxGetNumberOfElements(prhs[1]);


    /* Get the name of the function */
    buflen = mxGetNumberOfElements(prhs[0]) + 1;
    buf	   = mxMalloc(buflen);
    
    status = mxGetString(prhs[0], buf, buflen);
    if (status != 0) {
        mexErrMsgIdAndTxt("MATLAB:cellfun:InvalidString",
        "Could not get string.");
        
    }	
   
    /* Create an output array the same size as the input cell array */
    if ( (strncmp(buf,"is",2) == 0) ) {
	/* is* functions return logicals */
	plhs[0] = mxCreateLogicalArray(mxGetNumberOfDimensions(prhs[1]),
				       mxGetDimensions(prhs[1]));
	pl      = mxGetLogicals(plhs[0]);
    } else {
	plhs[0] = mxCreateNumericArray(mxGetNumberOfDimensions(prhs[1]),
				       mxGetDimensions(prhs[1]),
				       mxDOUBLE_CLASS, mxREAL);
	pr      = mxGetPr(plhs[0]);
    }
    
    /* Set error flag for functions that take only two args */
    twoinputs = (nrhs == 2);

    /* Processing the cell elements begins here */
    if (!strcmp(buf,"isreal")) {
	if (!twoinputs) {
        mexErrMsgIdAndTxt("MATLAB:cellfun:InvalidInput",errMsg);
	}
	cellIsReal(pl, prhs[1], numel);	

    } else if (!strcmp(buf,"isempty")) {
	if (!twoinputs) {
	    mexErrMsgIdAndTxt("MATLAB:cellfun:InvalidInput",errMsg);
	}
	cellIsEmpty(pl, prhs[1], numel);
    
     } else if (!strcmp(buf, "islogical")) {
	if (!twoinputs) {
	    mexErrMsgIdAndTxt("MATLAB:cellfun:InvalidInput",errMsg);;
	}
	cellIsLogical(pl, prhs[1], numel);

     } else if (!strcmp(buf,"isclass")) {	
	if (nrhs != 3) {
	    mexErrMsgIdAndTxt("MATLAB:cellfun:InvalidInput",errMsg);
	}
	cellIsClass(pl, prhs, numel);	

    } else if (!strcmp(buf,"size")) {	
	if (nrhs != 3) {
	    mexErrMsgIdAndTxt("MATLAB:cellfun:InvalidInput",errMsg);
	}
	cellSize(pr, prhs, numel);

    } else if (!strcmp(buf,"length")) {
	if (!twoinputs) {
	    mexErrMsgIdAndTxt("MATLAB:cellfun:InvalidInput",errMsg);
	}
	cellLength(pr, prhs[1], numel);	

    } else if (!strcmp(buf,"ndims")) {
	if (!twoinputs) {
	    mexErrMsgIdAndTxt("MATLAB:cellfun:InvalidInput",errMsg);
	}
	cellNDims(pr, prhs[1], numel);

    } else if (!strcmp(buf,"prodofsize")) {
	if (!twoinputs) {
	    mexErrMsgIdAndTxt("MATLAB:cellfun:InvalidInput",errMsg);
	}
	cellProdOfSize(pr, prhs[1], numel);

    } else {
        mexErrMsgIdAndTxt("MATLAB:cellfun:UnknownOption",
        "Unknown option.");
    }
    
    /* Free the temporary buffer */
    mxFree(buf);  
}
