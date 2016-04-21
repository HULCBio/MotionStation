/*
 * Copyright 1993-2003 The MathWorks, Inc.
 * $Revision: 1.5.4.1 $  $Date: 2003/01/26 06:00:37 $
 */

#ifndef MORPHMEX_H
#define MORPHMEX_H

#include <math.h>
#include "../neighborhood.h"

#define BITS_PER_WORD 32
#define LEFT_SHIFT(x,shift) (shift == 0 ? x : (shift == BITS_PER_WORD ? 0 : x << shift))
#define RIGHT_SHIFT(x,shift) (shift == 0 ? x : (shift == BITS_PER_WORD ? 0 : x >> shift))

void dilate_logical(mxLogical *In, mxLogical *Out, int num_elements,
                         NeighborhoodWalker_T walker);

void erode_logical(mxLogical *In, mxLogical *Out, int num_elements,
                        NeighborhoodWalker_T walker);

void dilate_gray_flat_uint8(uint8_T *In, uint8_T *Out, int num_elements, 
                            NeighborhoodWalker_T walker);

void dilate_gray_flat_uint16(uint16_T *In, uint16_T *Out, int num_elements, 
                             NeighborhoodWalker_T walker);

void dilate_gray_flat_uint32(uint32_T *In, uint32_T *Out, int num_elements, 
                             NeighborhoodWalker_T walker);

void dilate_gray_flat_int8(int8_T *In, int8_T *Out, int num_elements, 
                           NeighborhoodWalker_T walker);

void dilate_gray_flat_int16(int16_T *In, int16_T *Out, int num_elements, 
                            NeighborhoodWalker_T walker);

void dilate_gray_flat_int32(int32_T *In, int32_T *Out, int num_elements, 
                            NeighborhoodWalker_T walker);

void dilate_gray_flat_single(float *In, float *Out, int num_elements, 
                             NeighborhoodWalker_T walker);

void dilate_gray_flat_double(double *In, double *Out, int num_elements, 
                             NeighborhoodWalker_T walker);

void erode_gray_flat_uint8(uint8_T *In, uint8_T *Out, int num_elements, 
                           NeighborhoodWalker_T walker);

void erode_gray_flat_uint16(uint16_T *In, uint16_T *Out, int num_elements, 
                            NeighborhoodWalker_T walker);
    
void erode_gray_flat_uint32(uint32_T *In, uint32_T *Out, int num_elements, 
                            NeighborhoodWalker_T walker);
    
void erode_gray_flat_int8(int8_T *In, int8_T *Out, int num_elements, 
                          NeighborhoodWalker_T walker);

void erode_gray_flat_int16(int16_T *In, int16_T *Out, int num_elements, 
                           NeighborhoodWalker_T walker);

void erode_gray_flat_int32(int32_T *In, int32_T *Out, int num_elements, 
                           NeighborhoodWalker_T walker);

void erode_gray_flat_single(float *In, float *Out, int num_elements, 
                            NeighborhoodWalker_T walker);

void erode_gray_flat_double(double *In, double *Out, int num_elements, 
                            NeighborhoodWalker_T walker);

void dilate_gray_nonflat_uint8(uint8_T *In, uint8_T *Out, int num_elements,
                               NeighborhoodWalker_T walker, double *heights);

void dilate_gray_nonflat_uint16(uint16_T *In, uint16_T *Out, int num_elements,
                                NeighborhoodWalker_T walker, double *heights);

void dilate_gray_nonflat_uint32(uint32_T *In, uint32_T *Out, int num_elements,
                                NeighborhoodWalker_T walker, double *heights);

void dilate_gray_nonflat_int8(int8_T *In, int8_T *Out, int num_elements,
                              NeighborhoodWalker_T walker, double *heights);

void dilate_gray_nonflat_int16(int16_T *In, int16_T *Out, int num_elements,
                               NeighborhoodWalker_T walker, double *heights);

void dilate_gray_nonflat_int32(int32_T *In, int32_T *Out, int num_elements,
                               NeighborhoodWalker_T walker, double *heights);

void dilate_gray_nonflat_single(float *In, float *Out, int num_elements,
                                NeighborhoodWalker_T walker, double *heights);

void dilate_gray_nonflat_double(double *In, double *Out, int num_elements,
                                NeighborhoodWalker_T walker, double *heights);

void erode_gray_nonflat_uint8(uint8_T *In, uint8_T *Out, int num_elements,
                              NeighborhoodWalker_T walker, double *heights);

void erode_gray_nonflat_uint16(uint16_T *In, uint16_T *Out, int num_elements,
                               NeighborhoodWalker_T walker, double *heights);

void erode_gray_nonflat_uint32(uint32_T *In, uint32_T *Out, int num_elements,
                               NeighborhoodWalker_T walker, double *heights);

void erode_gray_nonflat_int8(int8_T *In, int8_T *Out, int num_elements,
                             NeighborhoodWalker_T walker, double *heights);

void erode_gray_nonflat_int16(int16_T *In, int16_T *Out, int num_elements,
                              NeighborhoodWalker_T walker, double *heights);

void erode_gray_nonflat_int32(int32_T *In, int32_T *Out, int num_elements,
                              NeighborhoodWalker_T walker, double *heights);

void erode_gray_nonflat_single(float *In, float *Out, int num_elements,
                               NeighborhoodWalker_T walker, double *heights);

void erode_gray_nonflat_double(double *In, double *Out, int num_elements,
                               NeighborhoodWalker_T walker, double *heights);

void dilate_packed_uint32(uint32_T *In, uint32_T *Out, int M, int N,
                          double *rc_offsets, int num_neighbors);

void erode_packed_uint32(uint32_T *In, uint32_T *Out, int M, int N,
                         double *rc_offsets, int num_neighbors,
                         int unpacked_M);


#endif /* MORPHMEX_H */
