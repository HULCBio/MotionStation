/*
 * Copyright 1993-2003 The MathWorks, Inc.
 * $Revision: 1.1.6.1 $  $Date: 2003/01/26 05:59:18 $
 *
 * Packed 2-D binary dilation and erosion.
 */

static char rcsid[] = "$Id: dilate_erode_packed.cpp,v 1.1.6.1 2003/01/26 05:59:18 batserve Exp $";

#include "morphmex.h"

#define BITS_PER_WORD 32
#define LEFT_SHIFT(x,shift) (shift == 0 ? x : (shift == BITS_PER_WORD ? 0 : x << shift))
#define RIGHT_SHIFT(x,shift) (shift == 0 ? x : (shift == BITS_PER_WORD ? 0 : x >> shift))

/*
 * dilate_packed_uint32
 * Packed binary dilation
 *
 * Inputs
 * ======
 * In            - pointer to first element of input array
 * M             - number of rows of packed input array
 * N             - number of columns of packed input array
 * rc_offsets    - Row-column offset locations corresponding to
 *                 each element of the structuring element; storage
 *                 order is that for a MATLAB array, num_neighbors-by-2
 * num_neighbors - number of neighbors in the structuring element
 *
 * Output
 * ======
 * Out           - pointer to first element of output array
 */
void dilate_packed_uint32(uint32_T *In, uint32_T *Out, int M, int N,
                          double *rc_offsets, int num_neighbors)
{
    
    int *column_offset;
    int *row_offset1;
    int *row_offset2;
    int *bit_shift1;
    int *bit_shift2;
    int k;
    int r;
    int c;
    uint32_T val;
    uint32_T shifted_val;
    int cc;
    int rr;
    
    column_offset = (int *) mxCalloc(num_neighbors, sizeof(*column_offset));
    row_offset1 = (int *) mxCalloc(num_neighbors, sizeof(*row_offset1));
    row_offset2 = (int *) mxCalloc(num_neighbors, sizeof(*row_offset2));
    bit_shift1 = (int *) mxCalloc(num_neighbors, sizeof(*bit_shift1));
    bit_shift2 = (int *) mxCalloc(num_neighbors, sizeof(*bit_shift2));
    
    for (k = 0; k < num_neighbors; k++)
    {
        column_offset[k] = (int) rc_offsets[k + num_neighbors];
        r = (int) rc_offsets[k];
        row_offset1[k] = (int) floor((double) r / BITS_PER_WORD);
        row_offset2[k] = row_offset1[k] + 1;
        bit_shift1[k] = r - BITS_PER_WORD*row_offset1[k];
        bit_shift2[k] = BITS_PER_WORD - bit_shift1[k];
    }

    for (c = 0; c < N; c++)
    {
        for (r = 0; r < M; r++)
        {
            val = *In++;
            if (val != 0)
            {
                for (k = 0; k < num_neighbors; k++)
                {
                    cc = c + column_offset[k];
                    if ((cc >= 0) && (cc < N))
                    {
                        rr = r + row_offset1[k];
                        if ((rr >= 0) && (rr < M))
                        {
                            shifted_val = LEFT_SHIFT(val,bit_shift1[k]);
                            Out[cc*M + rr] |= shifted_val;
                        }
                        rr = r + row_offset2[k];
                        if ((rr >= 0) && (rr < M))
                        {
                            shifted_val = RIGHT_SHIFT(val,bit_shift2[k]);
                            Out[cc*M + rr] |= shifted_val;
                        }
                    }
                }
            }
        }
    }

    mxFree(column_offset);
    mxFree(row_offset1);
    mxFree(row_offset2);
    mxFree(bit_shift1);
    mxFree(bit_shift2);
}


/*
 * erode_packed_uint32
 * Packed binary erosion
 *
 * Inputs
 * ======
 * In            - pointer to first element of input array
 * M             - number of rows of packed input array
 * N             - number of columns of packed input array
 * rc_offsets    - Row-column offset locations corresponding to
 *                 each element of the structuring element; storage
 *                 order is that for a MATLAB array, num_neighbors-by-2
 * num_neighbors - number of neighbors in the structuring element
 * unpacked_M    - number of rows of unpacked input array
 *
 * Output
 * ======
 * Out           - pointer to first element of output array
 */
void erode_packed_uint32(uint32_T *In, uint32_T *Out, int M, int N,
                         double *rc_offsets, int num_neighbors,
                         int unpacked_M)
{
    
    int *column_offset;
    int *row_offset1;
    int *row_offset2;
    int *bit_shift1;
    int *bit_shift2;
    int k;
    int r;
    int c;
    uint32_T val;
    uint32_T shifted_val;
    uint32_T last_row_mask;
    int cc;
    int rr;
    int num_real_bits_in_last_row;
    
    column_offset = (int *) mxCalloc(num_neighbors, sizeof(*column_offset));
    row_offset1 = (int *) mxCalloc(num_neighbors, sizeof(*row_offset1));
    row_offset2 = (int *) mxCalloc(num_neighbors, sizeof(*row_offset2));
    bit_shift1 = (int *) mxCalloc(num_neighbors, sizeof(*bit_shift1));
    bit_shift2 = (int *) mxCalloc(num_neighbors, sizeof(*bit_shift2));

    for (k = 0; k < 2*num_neighbors; k++)
    {
        rc_offsets[k] = -rc_offsets[k];
    }
    
    for (k = 0; k < num_neighbors; k++)
    {
        column_offset[k] = (int) rc_offsets[k + num_neighbors];
        r = (int) rc_offsets[k];
        row_offset1[k] = (int) floor((double) r / BITS_PER_WORD);
        row_offset2[k] = row_offset1[k] + 1;
        bit_shift1[k] = r - BITS_PER_WORD*row_offset1[k];
        bit_shift2[k] = BITS_PER_WORD - bit_shift1[k];
    }

    num_real_bits_in_last_row = unpacked_M % BITS_PER_WORD;
    if (num_real_bits_in_last_row == 0)
    {
        num_real_bits_in_last_row = BITS_PER_WORD;
    }

    last_row_mask = 0;
    for (k = 0; k < num_real_bits_in_last_row; k++)
    {
        last_row_mask |= 1 << k;
    }

    for (c = 0; c < N; c++)
    {
        for (r = 0; r < M; r++)
        {
            val = ~(*In++);
            if (r == (M - 1))
            {
                val = val & last_row_mask;
            }
            if (val != 0)
            {
                for (k = 0; k < num_neighbors; k++)
                {
                    cc = c + column_offset[k];
                    if ((cc >= 0) && (cc < N))
                    {
                        rr = r + row_offset1[k];
                        if ((rr >= 0) && (rr < M))
                        {
                            shifted_val = LEFT_SHIFT(val,bit_shift1[k]);
                            Out[cc*M + rr] |= shifted_val;
                        }
                        rr = r + row_offset2[k];
                        if ((rr >= 0) && (rr < M))
                        {
                            shifted_val = RIGHT_SHIFT(val,bit_shift2[k]);
                            Out[cc*M + rr] |= shifted_val;
                        }
                    }
                }
            }
        }
    }

    for (k = 0; k < M*N; k++)
    {
        Out[k] = ~Out[k];
    }

    /*
     * Mask out extraneous bits in the last row.
     */
    for (c = 0; c < N; c++)
    {
        Out[c*M + M - 1] &= last_row_mask;
    }

    mxFree(column_offset);
    mxFree(row_offset1);
    mxFree(row_offset2);
    mxFree(bit_shift1);
    mxFree(bit_shift2);
}
