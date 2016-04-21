/* Copyright 1993-2003 The MathWorks, Inc. */
/* $Revision: 1.1.6.2 $ */

#include "mex.h"
#include <math.h>

#define PACKED_TYPE uint32_T

typedef PACKED_TYPE PackedType;
#define BITS_PER_WORD (sizeof(PackedType) * 8)

void UnpackImage(PackedType *input_buffer, mxLogical *output_buffer,
                      int M, int M_packed, int N)
{
    int col;
    int row;
    PackedType *ptr = NULL;
    int bit_counter = 0;

    for (col = 0; col < N; col++)
    {
        bit_counter = 0;
        ptr = input_buffer + M_packed*col;
        for (row = 0; row < M; row++)
        {
            *output_buffer = (*ptr >> bit_counter) & 1;
            output_buffer++;
            bit_counter++;
            if (bit_counter == BITS_PER_WORD)
            {
                bit_counter = 0;
                ptr++;
            }
        }
    }
}

void mexFunction(int nlhs,
                 mxArray *plhs[],
                 int nrhs,
                 const mxArray *prhs[])
{
    mxArray *BW = NULL;
    mxLogical *output_buffer = NULL;
    PackedType *input_buffer = NULL;
    int M;
    int N;
    int M_packed;
    int output_size[2];

    M_packed = mxGetM(prhs[0]);
    N = mxGetN(prhs[0]);

    if (nrhs == 1)
    {
        M = BITS_PER_WORD * M_packed;
    }

    else if (nrhs == 2)
    {
        M = (int) mxGetScalar(prhs[1]);
    }

    else if (nrhs < 1)
    {
        mexErrMsgIdAndTxt("Images:bwunpackc:tooFewInputs",
                          "BWUNPACKC needs at least one input argument.");
    }

    else /*nrhs > 2*/
    {
        mexErrMsgIdAndTxt("Images:bwunpackc:tooManyInputs",
                          "BWUNPACKC takes at most two input arguments.");
    }

    
    /*
     * Allocate space for output array.
     */
    output_size[0] = M;
    output_size[1] = N;
    BW = mxCreateLogicalArray(2, output_size);
    if (BW == NULL)
    {
        mexErrMsgIdAndTxt("Images:bwunpackc:outOfMemory",
                          "Out of memory.");
    }

    output_buffer = (mxLogical *) mxGetData(BW);
    input_buffer = (PackedType *) mxGetData(prhs[0]);

    UnpackImage(input_buffer, output_buffer, M, M_packed, N);

    plhs[0] = BW;
}

