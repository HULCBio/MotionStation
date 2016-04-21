/* Copyright 1993-2003 The MathWorks, Inc. */

/*
 * DILBW Binary image dilation (MEX-file)
 *
 * BW2 = DILBW(BW1, SE) dilates the binary image BW1 by the 
 * structuring element SE.  BW1 must be a 2-D real uint8 array.
 * SE must be a 2-D real double array.  BW2 is a logical uint8 array.
 *
 */

static char rcsid[] = "$Revision: 1.12.4.2 $";

#include "mex.h"

/*
 * ValidateInputs checks to make sure the user has supplied valid
 * input and output arguments.
 */
void ValidateInputs(int nlhs, mxArray *plhs[],
                    int nrhs, const mxArray *prhs[])
{
    if (nrhs < 2) mexErrMsgIdAndTxt("Images:dilbw:tooFewInputs",
                                    "%s","Too few input arguments");
    if (nrhs > 2) mexErrMsgIdAndTxt("Images:dilbw:tooManyInputs",
                                    "%s","Too many input arguments");
    if (nlhs > 1) mexErrMsgIdAndTxt("Images:dilbw:tooManyOutputs",
                                    "%s","Too many output arguments");
    
    if ((mxGetNumberOfDimensions(prhs[0]) != 2) |
        (!mxIsLogical(prhs[0])))
    {
        mexErrMsgIdAndTxt("Images:dilbw:firstArgMustBe2DLogical","%s",
                          "First input argument must be a 2-D logical array");
    }

    if ((mxGetNumberOfDimensions(prhs[1]) != 2) |
        (mxGetClassID(prhs[1]) != mxDOUBLE_CLASS) |
        (mxIsComplex(prhs[1])))
    {
        mexErrMsgIdAndTxt("Images:dilbw:secondArgMustBe2DRealDouble","%s",
                          "Second input argument must be a 2-D real"
                          " double array");
    }
}

int NumberOfNonzeroElements(const mxArray *SE)
{
    int counter = 0;
    double *pr;
    int MN;
    int k;
    
    MN = mxGetNumberOfElements(SE);
    pr = (double *) mxGetData(SE);
    for (k = 0; k < MN; k++)
    {
        if (*pr++)
        {
            counter++;
        }
    }
    
    return(counter);
}

void ComputeStructuringElementOffsets(const mxArray *SE, int **rowOffsets,
                                      int **colOffsets, int *numOffsets)
{
    double *pr;
    int r;
    int c;
    int counter;
    int rowCenter;
    int colCenter;
    int M;
    int N;

    *numOffsets = NumberOfNonzeroElements(SE);
    
    *rowOffsets = (int *) mxCalloc(*numOffsets, sizeof(**rowOffsets));
    *colOffsets = (int *) mxCalloc(*numOffsets, sizeof(**colOffsets));

    M = mxGetM(SE);
    N = mxGetN(SE);

    rowCenter = (int) (((double) M - 1.0) / 2.0);
    colCenter = (int) (((double) N - 1.0) / 2.0);

    counter = 0;
    pr = (double *) mxGetData(SE);
    for (c = 0; c < N; c++)
    {
        for (r = 0; r < M; r++)
        {
            if (*pr++)
            {
                (*rowOffsets)[counter] = r - rowCenter;
                (*colOffsets)[counter] = c - colCenter;
                counter++;
            }
        }
    }
}

void dilate(mxLogical *pout, mxLogical *pin, int M, int N,
            int numOffsets, int *rowOffsets, int *colOffsets)
{
    int col;
    int row;
    int k;
    int c;
    int r;
    
    for (col = 0; col < N; col++)
    {
        for (row = 0; row < M; row++)
        {
            if (*pin++)
            {
                for (k = 0; k < numOffsets; k++)
                {
                    c = col + colOffsets[k];
                    r = row + rowOffsets[k];
                    if ((r >= 0) && (r < M) && (c >= 0) && (c < N))
                    {
                        *(pout + c*M + r) = 1;
                    }
                }
            }
            
        }
        
    }
}

void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[])
{
    const mxArray *BWin;
    mxArray *BWout;
    const mxArray *SE;
    int numOffsets;
    int *rowOffsets;
    int *colOffsets;
    int M;
    int N;
    int size[2];

    /*
     * Check input argument validity
     */
    ValidateInputs(nlhs, plhs, nrhs, prhs);
    BWin = prhs[0];
    SE = prhs[1];

    /*
     * Create the output array
     */
    M = mxGetM(BWin);
    N = mxGetN(BWin);
    size[0] = M;
    size[1] = N;
    BWout = mxCreateLogicalArray(2, size);

    ComputeStructuringElementOffsets(SE, &rowOffsets, &colOffsets, &numOffsets);
    
    dilate(mxGetLogicals(BWout), mxGetLogicals(BWin),
           M, N, numOffsets, rowOffsets, colOffsets);

    plhs[0] = BWout;
}
