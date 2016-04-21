/*
 * Copyright 1993-2003 The MathWorks, Inc.
 * $Revision: 1.8.4.1 $  $Date: 2003/01/26 05:57:07 $
 */

#ifndef NEIGHBORHOOD_H
#define NEIGHBORHOOD_H

#include "mex.h"

#define NH_SKIP_TRAILING 1
#define NH_SKIP_LEADING  2
#define NH_SKIP_CENTER   4

#define NH_CENTER_MIDDLE_ROUNDUP   0
#define NH_CENTER_MIDDLE_ROUNDDOWN 2
#define NH_CENTER_UL               4
#define NH_CENTER_LR               8

typedef struct Neighborhood_tag
{
    /* 
     * Conceptually, array_coords is a num_neighbors-by-num_dims array 
     * containing relative offsets.  num_dims is the array dimension
     * that varies quickest.
     */
    int32_T *array_coords;  
    int32_T num_neighbors;
    int32_T num_dims;
} *Neighborhood_T;

typedef struct NeighborhoodWalker_tag
{
    /* 
     * Conceptually, array_coords is a num_neighbors-by-num_dims array 
     * containing relative offsets.
     */
    int32_T *array_coords;

    /*
     * neighbor_offsets is an an array containing linear neighbor
     * offsets, computed with respect to a given image size.
     */
    int32_T *neighbor_offsets;
    int32_T *image_size;

    /*
     * Contains the array coordinates for the image pixel whose
     * neighborhood we are about to walk.
     */
    int32_T *center_coords;

    /*
     * Contains the cumulative product of the image_size array;
     * used in the sub_to_ind and ind_to_sub calculations.
     */
    int32_T *cumprod;

    /*
     * Linear index of image pixel whose neighborhood we are about to
     * walk.
     */
    int32_T pixel_offset;

    /*
     * Used to filter out certain neighbors in a neighborhood walk.
     */
    bool    *use;

    /*
     * Index of the next neighbor in the walk.
     */
    int32_T next_neighbor_idx;
    int32_T num_neighbors;
    int32_T num_dims;
} *NeighborhoodWalker_T;

Neighborhood_T nhMakeNeighborhood(const mxArray *D,int center_location);
NeighborhoodWalker_T nhMakeNeighborhoodWalker(Neighborhood_T nhood,
                                              const int *input_size,
                                              int input_dims,
                                              unsigned int flags);
Neighborhood_T nhMakeDefaultConnectivityNeighborhood(int32_T num_dims);
void nhReflectNeighborhood(Neighborhood_T nhood);
void nhDestroyNeighborhoodWalker(NeighborhoodWalker_T walker);
void nhDestroyNeighborhood(Neighborhood_T nhood);
void nhSetWalkerLocation(NeighborhoodWalker_T walker, int p);
bool nhGetNextInboundsNeighbor(NeighborhoodWalker_T walker, int32_T *p,
                               int32_T *idx);
void nhCheckDomain(const mxArray *D);

extern void nhCheckConnectivityDomain(const mxArray *D,
                                      const char *function_name,
                                      const char *variable_name,
                                      int argument_position);

int32_T sub_to_ind(int32_T *coords, int32_T *cumprod, int32_T num_dims);
void ind_to_sub(int p, int num_dims, const int size[],
                int *cumprod, int *coords);

int32_T *nhGetWalkerNeighborOffsets(NeighborhoodWalker_T walker);
int num_nonzeros(const mxArray *D);
Neighborhood_T allocate_neighborhood(int num_neighbors, int num_dims);

/////////////////////////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////////////////////////
template<typename _T1>
Neighborhood_T create_neighborhood_general_template(_T1 *pr,
                                                    const mxArray *D,
                                                    int center_location)
{
    int num_neighbors;
    int num_dims;
    int num_elements;
    const int *size_D;
    int *cumprod;
    int p;
    int q;
    int *coords;
    mxClassID array_class;
    Neighborhood_T result;
    int count = 0;

    mxAssert(D != NULL, "");

    num_neighbors = num_nonzeros(D);
    num_dims = mxGetNumberOfDimensions(D);
    num_elements = mxGetNumberOfElements(D);
    size_D = mxGetDimensions(D);

    result = allocate_neighborhood(num_neighbors, num_dims);
    cumprod = (int *)mxMalloc(num_dims * sizeof(*cumprod));
    cumprod[0] = 1;
    for (p = 1; p < num_dims; p++)
    {
        cumprod[p] = cumprod[p-1] * size_D[p-1];
    }
    
    for (p = 0; p < num_elements; p++)
    {
        if (*pr)
        {
            coords = result->array_coords + count*num_dims;
            ind_to_sub(p, num_dims, size_D, cumprod, coords);
            if(center_location == NH_CENTER_MIDDLE_ROUNDDOWN)
            {
                /*
                 * Subtract the location of the center pixel from
                 * the neighbor coordinates.
                 */
                for (q = 0; q < num_dims; q++)
                {
                    coords[q] -= (size_D[q] - 1) / 2;
                }
            }
            else if(center_location == NH_CENTER_UL)
            {
                /*
                 * No change required for center in Upper Left
                 * assuming that ind_to_sub returns a zero based
                 * subscript with the top in the upper left
                 */
            }
            else if(center_location == NH_CENTER_LR)
            {
                for (q = 0; q < num_dims; q++)
                {
                    coords[q] -= (size_D[q] - 1);
                }
            }
            if(center_location == NH_CENTER_MIDDLE_ROUNDUP)
            {
                /*
                 * Subtract the location of the center pixel from
                 * the neighbor coordinates.
                 */
                for (q = 0; q < num_dims; q++)
                {
                    coords[q] -= (size_D[q] - 1) / 2 +
                        ((size_D[q] - 1) % 2 ? 1:0);
                }
            }
            count++;
        }
        pr++;
    }
    
    mxFree(cumprod);
    return result;
}

#endif
