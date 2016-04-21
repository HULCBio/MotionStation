//////////////////////////////////////////////////////////////////////////////
// BWTRACEBOUNDARYMEX.<mex>
//
// B = bwtraceboundarymex(BW,P,N,CONN)
//
// This mex function traces a boundary of an object in an image BW and
// returns X-Y coordinates of the boundary points in the Matlab array B.
//
// BW 
//     binary image of class UINT8
// 
// CONN
//     double, real, integer, scalar equal to 4 or 8
// B
//     B is a Q-by-2 matrix, where Q is the number of boundary pixels 
//     for the region.  
//
// $Revision: 1.1.6.3 $  $Date: 2003/05/03 17:51:40 $
// Copyright 1993-2003 The MathWorks, Inc.
//////////////////////////////////////////////////////////////////////////////

#include "boundaries.h"
#include "mex.h"

static char rcsid[] = "$Id: bwtraceboundarymex.cpp,v 1.1.6.3 2003/05/03 17:51:40 batserve Exp $";

//Struct for parameters needed by the boundary tracing routine
typedef struct
{
    int      conn;         //connectivity
    int      numRows;      //number of rows in the input image
    int      numCols;      //number of cols in the input image
    uint8_T *imgData;      //pointer to raw image buffer  
    int      startRow;     //coordinates of the point where tracing will begin
    int      startCol;
    tdir_T   direction;    //trace clockwise, or counterclockwise
    int      maxNumPoints; //number of points to trace
    int      firstStep;    //first step in the search: north, south...
} mexInputs_T;

//////////////////////////////////////////////////////////////////////////////
//
//////////////////////////////////////////////////////////////////////////////
#define FCN_NAME "bwtraceboundarymex"
void checkInputs(int nlhs, mxArray *plhs[], 
                 int nrhs, const mxArray *prhs[], mexInputs_T *in)
{
    if (nrhs < 3)
    {
        mexErrMsgIdAndTxt("Images:bwlabelnmex:tooFewInputs",
                          "BWLABELNMEX needs at least three inputs.");
    }
    if (nrhs > 6)
    {
        mexErrMsgIdAndTxt("Images:bwlabelnmex:tooManyInputs",
                          "BWLABELNMEX accepts at most six inputs.");
    }

    const mxArray *array;  //temporary storage
    int   par=0; //parameter number

    //BW: binary image
    ////////////////////////////////////////////////////
    array = prhs[par];

    in->imgData = (uint8_T *)mxGetData(array);

    in->numRows = mxGetM(array);
    in->numCols = mxGetN(array);

    //P: starting point of the boundary
    ////////////////////////////////////////////////////
    par++; array = prhs[par];

    double *startPoint = (double *)mxGetData(array);
    in->startRow = (int)startPoint[0];
    in->startCol = (int)startPoint[1];
    if(in->startRow > in->numRows || in->startCol > in->numCols)
    {
        mexErrMsgIdAndTxt("Images:bwtraceboundarymex:invalidStartingPoint",
                          "%s %s %s\n",
                          "Function", FCN_NAME, "expected its"
                          " input argument, P,"
                          "to be a point inside BW.");
    }

    //CONN: connectivity
    ////////////////////////////////////////////////////
    par++; array = prhs[par];

    in->conn = (int)(*((double *)mxGetData(array)));
    if ( in->conn != 4 && in->conn != 8 )
    {
        mexErrMsgIdAndTxt("Images:bwtraceboundarymex:mismatchedLength",
                          "%s %s %s\n",
                          "Function", FCN_NAME, "expected its"
                          " input argument, CONN, "
                          "to be either 4 or 8.");
    }

    //FSTEP: first step
    ////////////////////////////////////////////////////
    par++; array = prhs[par];

    in->firstStep = (int)(*((double *)mxGetData(array)));
    if ( in->firstStep < 0 || in->firstStep > in->conn-1 )
    {
        mexErrMsgIdAndTxt("Images:bwtraceboundarymex:invalidInitialStep",
                          "%s %s %s %d\n",
                          "Function", FCN_NAME, "expected its"
                          " input argument, FSTEP,"
                          "to be between 0 and ", in->conn-1);
    }

    //N: number of points to trace
    ////////////////////////////////////////////////////
    par++; array = prhs[par];

    in->maxNumPoints = (int)(*((double *)mxGetData(array)));

    //DIR: direction in which to trace
    ////////////////////////////////////////////////////
    par++; array = prhs[par];
    
    in->direction = (tdir_T)(*((uint8_T *)mxGetData(array)));
}

//////////////////////////////////////////////////////////////////////////////
//
//////////////////////////////////////////////////////////////////////////////

//Instantiate the class responsible for all the computations
Boundaries boundaries;

extern "C"
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    mexInputs_T in;

    checkInputs(nlhs, plhs, nrhs, prhs, &in);

    boundaries.setNumCols(in.numCols);
    boundaries.setNumRows(in.numRows);
    boundaries.setConnectivity(in.conn);

    plhs[0] = boundaries.traceBoundary(in.imgData, 
                                       in.startRow,
                                       in.startCol,
                                       in.firstStep,
                                       in.direction,
                                       in.maxNumPoints);
}
