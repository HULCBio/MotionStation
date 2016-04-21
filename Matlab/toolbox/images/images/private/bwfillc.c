/* Copyright 1993-2003 The MathWorks, Inc. */

/* 
 * Helper MEX-file for BWFILL
 *
 * J = BWFILLC(Ip, OFFSETS, STYLE) creates a uint8 logical
 * matrix J, the same size as Ip, that is background filled starting
 * from linear offset locations in OFFSETS.  STYLE, which is 4
 * or 8, indicates the connectedness to use during the fill.
 * Ip must be logical.
 *
 * IMPORTANT NOTE:  For optimization purposes, BWFILLC assumes that
 * Ip has been one-padded around the edges, and that no seed locations 
 * are on the top row, bottom row, left column or right column.  The
 * BWFILL M-file takes care of this padding.
 *
 */

#include "mex.h"

static char rcsid[] = "$Revision: 1.6.4.2 $";

typedef struct stacknode 
{
    int offset;
    struct stacknode *next;
}
StackNode;

StackNode *stackTop = NULL;

void push(int newOffset)
{
    StackNode *newNode = NULL;
    
    newNode = mxCalloc(1, sizeof(*newNode));
    newNode->offset = newOffset;
    newNode->next = stackTop;
    stackTop = newNode;
}

int pop(void)
{
    int result;
    StackNode *topNode = stackTop;
    
    result = topNode->offset;
    stackTop = topNode->next;
    mxFree((void *) topNode);

    return(result);
}

void ValidateInputs(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    mxLogical *p;
    double *pr;
    int style;
    int offset;
    int M;
    int N;
    int numElements;
    int k;

    if (nrhs < 3)
    {
        mexErrMsgIdAndTxt("Images:bwfillc:tooFewInputs",
                          "%s", "Too few inputs.");
    }
    if (nrhs > 3)
    {
        mexErrMsgIdAndTxt("Images:bwfillc:tooManyInputs",
                          "%s", "Too many inputs.");
    }
    if (!mxIsLogical(prhs[0]))
    {
        mexErrMsgIdAndTxt("Images:bwfillc:inputImageMustBeLogical",
                          "%s", "Input image must be logical.");
    }
    if (!mxIsDouble(prhs[1]) || !mxIsDouble(prhs[2]))
    {
        mexErrMsgIdAndTxt("Images:bwfillc:offsetsAndStyleMustBeDouble",
                          "%s", "OFFSETS and STYLE must be double.");
    }

    style = (int) mxGetScalar(prhs[2]);
    if ((style != 4) && (style != 8))
    {
        mexErrMsgIdAndTxt("Images:bwfillc:styleMustBeFourOrEight",
                          "%s", "STYLE must be 4 or 8.");
    }

    p = mxGetLogicals(prhs[0]);
    M = mxGetM(prhs[0]);
    N = mxGetN(prhs[0]);
    /* Make sure input image is one-padded. */
    for (k = 0; k < M; k++)
    {
        if ((*(p + k) == 0) || (*(p + (N-1)*M + k) == 0))
        {
            mexErrMsgIdAndTxt("Images:bwfillc:imageCannotHaveZerosOnBorder",
                          "%s","Input image cannot have zeros on the border.");
        }
    }
    for (k = 0; k < N; k++)
    {
        if ((*(p + M*k) == 0) || (*(p + M-1 + M*k) == 0))
        {
            mexErrMsgIdAndTxt("Images:bwfillc:imageCannotHaveZerosOnBorder",
                              "%s", "Input image cannot have zeros"
                              " on the border.");
        }
    }
    
    numElements = M*N;
    
    pr = mxGetPr(prhs[1]);
    for (k = 0; k < mxGetNumberOfElements(prhs[1]); k++)
    {
        offset = (int) pr[k];
        if ((offset <= 0) || (offset > numElements))
        {
            mexErrMsgIdAndTxt("Images:bwfillc:offsetsOutOfRange",
                              "%s", "OFFSETS contains values out of range.");
        }
    }
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    mxLogical *Ip;
    mxLogical *J;
    int *neighbors;
    int style;
    int numNeighbors;
    int size[2];
    int offset;
    int neighborOffset;
    int k;
    double *pr;

    ValidateInputs(nlhs, plhs, nrhs, prhs);
    
    Ip = mxGetLogicals(prhs[0]);
    size[0] = mxGetM(prhs[0]);
    size[1] = mxGetN(prhs[0]);
    plhs[0] = mxCreateLogicalArray(2,size);
    J = mxGetLogicals(plhs[0]);

    style = (int) mxGetScalar(prhs[2]);
    if (style == 8)
    {
        /* foreground is 8-connected; implies background is 4-connected */
        numNeighbors = 4;
        neighbors = mxCalloc(numNeighbors, sizeof(*neighbors));
        neighbors[0] = 1;
        neighbors[1] = -1;
        neighbors[2] = size[0];
        neighbors[3] = -size[0];
    }
    else
    {
        /* foreground is 4-connected; implies background is 8-connected */
        numNeighbors = 8;
        neighbors = mxCalloc(numNeighbors, sizeof(*neighbors));
        neighbors[0] = 1;
        neighbors[1] = 1+size[0];
        neighbors[2] = size[0];
        neighbors[3] = size[0]-1;
        neighbors[4] = -1;
        neighbors[5] = -size[0]-1;
        neighbors[6] = -size[0];
        neighbors[7] = -size[0]+1;
    }
    
    pr = mxGetPr(prhs[1]);
    for (k = 0; k < mxGetNumberOfElements(prhs[1]); k++) {
        if (Ip[(int) (pr[k] - 1)] == 0)
        {
            push((int) pr[k] - 1);
            J[(int) pr[k] - 1] = 1;
        }
    }
    
    while (stackTop != NULL) {
        offset = pop();
        for (k = 0; k < numNeighbors; k++) {
            neighborOffset = offset + neighbors[k];
            if ( (Ip[neighborOffset] == 0) &&
                 (J[neighborOffset] == 0)) {
                push(neighborOffset);
                J[neighborOffset] = 1;
            }
        }
    }
}

