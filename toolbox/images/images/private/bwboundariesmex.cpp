//////////////////////////////////////////////////////////////////////////////
// BWBOUNDARIESMEX.<mex>
//
// B = bwboundariesmex(L,CONN)
//
// This mex function locates boundaries of objects in a labeled image L and
// returns them in a cell array B.
//
// L
//     label matrix such as the one produced by bwlabel
// CONN
//     double, real, integer, scalar equal to 4 or 8
// B
//     P-by-1 cell array, where P is the number of stored boundaries. Each 
//     cell contains a Q-by-2 matrix, where Q is the number of boundary pixels 
//     for the corresponding region.  Each row of B contains the row and
//     column coordinates of a boundary pixel.
//
// $Revision: 1.1.6.3 $  $Date: 2003/05/03 17:51:36 $
// Copyright 1993-2003 The MathWorks, Inc.
//////////////////////////////////////////////////////////////////////////////

#include "boundaries.h"
#include "mex.h"

static char rcsid[] = "$Id: bwboundariesmex.cpp,v 1.1.6.3 2003/05/03 17:51:36 batserve Exp $";

//////////////////////////////////////////////////////////////////////////////
//
//////////////////////////////////////////////////////////////////////////////
#define FCN_NAME "bwboundariesmex"
int checkInputs(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    if (nrhs != 2)
    {
        mexErrMsgIdAndTxt("Images:bwboundariesmex:wrongNumInputs",
                          "BWBOUNDARIESMEX requires two input arguments.");
    }

    int conn = (int)(*((double *)mxGetData(prhs[1])));
    if ( conn != 4 && conn != 8 )
    {
        mexErrMsgIdAndTxt("Images:bwboundariesmex:badScalarConn",
                          "%s %s %s\n%s",
                          "Function", FCN_NAME, "expected its"
                          " second input argument, CONN,",
                          "to be either 4 or 8.");
    }
    
    return(conn);
}

//////////////////////////////////////////////////////////////////////////////
//
//////////////////////////////////////////////////////////////////////////////

//Instantiate the class responsible for all the computations
Boundaries boundaries;

extern "C"
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    int conn = checkInputs(nlhs, plhs, nrhs, prhs);
    const mxArray *BW   = prhs[0]; 
    double *labelMatrix = (double *)mxGetData(BW);
    
    
    const int *dims = mxGetDimensions(BW);
    int numRows = mxGetM(BW);
    int numCols = mxGetN(BW);

    boundaries.setNumCols(numCols);
    boundaries.setNumRows(numRows);
    boundaries.setConnectivity(conn);

    plhs[0] = boundaries.findBoundaries(labelMatrix);
}

