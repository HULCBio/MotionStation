/*
 * BWPACK - Image Processing Toolbox MEX-function
 *
 * BW2 = BWPACK(BW)
 * BW is a logical uint8 array.  BWPACK packs each group of 32 rows of BW
 * a single row of the uint32 array BW2.
 *
 */

/*
 * Copyright 1993-2003 The MathWorks, Inc.
 * $Revision: 1.1.6.2 $  $Date: 2003/08/01 18:10:12 $
 */

#include <math.h>
#include "mex.h"

static char rcsid[] = "$Id: bwpackc.c,v 1.1.6.2 2003/08/01 18:10:12 batserve Exp $";

#define PACKED_TYPE uint32_T

typedef PACKED_TYPE PackedType;
#define BITS_PER_WORD (sizeof(PackedType) * 8)

void PackImage(mxLogical *input_buffer, PackedType *output_buffer, int M, 
               int M_packed, int N)
{
    int col;
    int row;
    mxLogical *input_scan_ptr = input_buffer;
    PackedType *output_scan_ptr = NULL;
    int bit_counter = 0;

    for (col = 0; col < N; col++)
    {
        bit_counter = 0;
        output_scan_ptr = output_buffer + M_packed*col;
        for (row = 0; row < M; row++)
        {
            if (*input_scan_ptr != 0)
            {
                *output_scan_ptr |= 1 << bit_counter;
            }
            input_scan_ptr++;
            bit_counter++;

            if (bit_counter == BITS_PER_WORD)
            {
                bit_counter = 0;
                output_scan_ptr++;
            }
        }
    }
}

void mexFunction(int nlhs,
                 mxArray *plhs[],
                 int nrhs,
                 const mxArray *prhs[])
{
    const mxArray *BW = NULL;
    mxArray *BW_out = NULL;
    mxLogical *input_buffer = NULL;
    PackedType *output_buffer = NULL;
    int M;
    int N;
    int M_packed;
    int output_size[2];

    if (nrhs != 1)
    {
        mexErrMsgIdAndTxt("Images:bwpackc:invalidNumInputs",
                          "%s",
                          "BWPACKC needs one input argument.");
    }
    BW = prhs[0];
    M = mxGetM(BW);
    N = mxGetN(BW);

    /* 
     * How many packed rows are needed?  The last packed row will
     * only be partially full if M is not a multiple of BITS_PER_WORD.
     */
    M_packed = (M + BITS_PER_WORD - 1) / BITS_PER_WORD;

    /*
     * Allocate space for output array.
     */
    output_size[0] = M_packed;
    output_size[1] = N;
    BW_out = mxCreateNumericArray(2, output_size, mxUINT32_CLASS, mxREAL);
    if (BW_out == NULL)
    {
        mexErrMsgIdAndTxt("Images:bwpackc:outOfMemory",
                          "%s","Out of memory.");
    }

    input_buffer = (mxLogical *) mxGetData(BW);        
    output_buffer = (PackedType *) mxGetData(BW_out);

    PackImage(input_buffer, output_buffer, M, M_packed, N);

    plhs[0] = BW_out;

}
