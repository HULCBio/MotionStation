/*
 * Utility functions for IPT MEX-files.
 *
 * Copyright 1993-2003 The MathWorks, Inc.
 */

/* $Revision: 1.10.4.2 $ */

#include <math.h>
#include "mex.h"

static char rcsid[] = "$Id: iptutil.c,v 1.10.4.2 2003/08/01 18:09:18 batserve Exp $";

/*
 * check_nargin --- interface to IPT checknargin function for 
 * checking for the proper number of input arguments.
 */
void check_nargin(double low, 
                  double high, 
                  int numInputs, 
                  const char *function_name)
{
    mxArray *prhs[4];
    mxArray *plhs[1];
    int nlhs = 0;
    int nrhs = 4;

    plhs[0] = NULL;

    prhs[0] = mxCreateScalarDouble((double) low);
    prhs[1] = mxCreateScalarDouble((double) high);
    prhs[2] = mxCreateScalarDouble((double) numInputs);
    prhs[3] = mxCreateString(function_name);

    mexCallMATLAB(nlhs, plhs, nrhs, prhs, "checknargin");
    
    mxDestroyArray(prhs[0]);
    mxDestroyArray(prhs[1]);
    mxDestroyArray(prhs[2]);
    mxDestroyArray(prhs[3]);

    if (plhs[0] != NULL)
    {
        mxDestroyArray(plhs[0]);
    }
}

/*
 * check_input --- interface to IPT checkarray function for
 * checking validity of input arguments.
 */
void check_input(const mxArray *A,
                 const char    *classes,
                 const char    *attributes,
                 const char    *function_name,
                 const char    *variable_name,
                 int           argument_position)
{
    mxArray *prhs[6];
    mxArray *plhs[1];
    int nlhs = 0;
    int nrhs = 6;
        
    prhs[0] = (mxArray *) A;
    prhs[1] = mxCreateString(classes);
    prhs[2] = mxCreateString(attributes);
    prhs[3] = mxCreateString(function_name);
    prhs[4] = mxCreateString(variable_name);
    prhs[5] = mxCreateScalarDouble((double) argument_position);

    plhs[0] = NULL;
    
    mexCallMATLAB(nlhs, plhs, nrhs, prhs, "checkinput");

    mxDestroyArray(prhs[1]);
    mxDestroyArray(prhs[2]);
    mxDestroyArray(prhs[3]);
    mxDestroyArray(prhs[4]);
    mxDestroyArray(prhs[5]);

    if (plhs[0] != NULL)
    {
        mxDestroyArray(plhs[0]);
    }
}

mxArray *call_one_input_one_output_function(const mxArray *A, 
                                            const char *function_name)
{
    int nrhs = 1;
    int nlhs = 1;
    mxArray *prhs[1];
    mxArray *plhs[1];

    prhs[0] = (mxArray *) A;
    
    mexCallMATLAB(nlhs, plhs, nrhs, prhs, function_name);
    
    return plhs[0];
}
    
mxArray *convert_to_logical(const mxArray *A)
{
    int nrhs = 2;
    int nlhs = 1;
    mxArray *prhs[2];
    mxArray *plhs[1];

    prhs[0] = (mxArray *) A;
    prhs[1] = mxCreateScalarDouble(0.0);
    
    mexCallMATLAB(nlhs, plhs, nrhs, prhs, "ne");

    mxDestroyArray(prhs[1]);
    
    return plhs[0];
}
    
/*
 * Given a linear offset p into an M-by-N array, row and column offsets 
 * r and c, and matrix dimensions M and N, return false if the 
 * corresponding neighbor is outside the bounds of the array; 
 * otherwise return true.
 */
bool is_inside(int p, int r_offset, int c_offset, int M, int N)
{
    int row = p % M;
    int col = p / M;
    int new_col = col + c_offset;
    int new_row = row + r_offset;
    
    return ((new_col >= 0) && (new_col < N) &&
            (new_row >= 0) && (new_row < M));
}

/*
 * Given input style (either 4 or 8) and row dimension M, 
 * initialize neighbor arrays nhood_r (row offsets), nhood_c 
 * (column offsets), and nhood (linear offsets).  Also initialize 
 * num_neighbors.
 *
 * nhood_r, nhood_c, and nhood need to have room for at least
 * eight ints.
 */
extern void init_neighbors(int style, int M, int nhood_r[], int nhood_c[], 
                           int nhood[], int *num_neighbors)
{
    int k;
    
    switch (style)
    {
    case 8:
        /* N */
        nhood_r[0] = -1;
        nhood_c[0] = 0;

        /* NE */
        nhood_r[1] = -1;
        nhood_c[1] = 1;
        
        /* E */
        nhood_r[2] = 0;
        nhood_c[2] = 1;
        
        /* SE */
        nhood_r[3] = 1;
        nhood_c[3] = 1;
        
        /* S */
        nhood_r[4] = 1;
        nhood_c[4] = 0;
        
        /* SW */
        nhood_r[5] = 1;
        nhood_c[5] = -1;
        
        /* W */
        nhood_r[6] = 0;
        nhood_c[6] = -1;
        
        /* NW */
        nhood_r[7] = -1;
        nhood_c[7] = -1;

        *num_neighbors = 8;
        break;
        
    case 4:
        /* N */
        nhood_r[0] = -1;
        nhood_c[0] = 0;
        
        /* E */
        nhood_r[1] = 0;
        nhood_c[1] = 1;
        
        /* S */
        nhood_r[2] = 1;
        nhood_c[2] = 0;
        
        /* W */
        nhood_r[3] = 0;
        nhood_c[3] = -1;
        
        *num_neighbors = 4;
        break;
        
    default:
        mexErrMsgIdAndTxt("Images:neighborhood:invalidStyle", "%s",
                          "Internal problem: invalid style");
    }

    for (k = 0; k < *num_neighbors; k++)
    {
        nhood[k] = M*nhood_c[k] + nhood_r[k];
    }
}


