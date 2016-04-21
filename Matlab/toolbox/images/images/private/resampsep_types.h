// 
// Copyright 1993-2003 The MathWorks, Inc.
// $Revision: 1.1.6.2 $
//

#ifndef RESAMPSEP_TYPES_H
#define RESAMPSEP_TYPES_H

//////////////////////////////////////////////////////////////////////////////
// Typedefs
//////////////////////////////////////////////////////////////////////////////

/*============================ Iterator Struct =============================*/

typedef struct Iterator
{
    int   ndims;   // number of dimensions
    int   offset;  // current offset value
    int   length;  // number subscript values
    int*  size;    // size of each dimension
    int*  subs;    // current subscript vector
}
Iterator;

/*========================== Config Struct =================================*/

/*
 * The transform dimensions in tdims may be out of sequence. That's
 * fine, but the values in tsize and cpTrans must
 * be consistent with the order used in tdims. cpTrans and cpOther
 * each contain elements of the cumulative product vector of size,
 * with a one inserted at the front. The elements corresponding
 * to tdims are ordered the same way as the positions listed in
 * tdims -- so if the elements of tdims are out of sequence, then
 * the values in cpTrans will not be monotonically increasing.
 * No problem.
 */

typedef struct Config
{
    int  ndims;    // total number of dimensions
    int  nTrans;   // number of transform dimensions
    int  nOther;   // number of non-transform dimensions
    int  tlength;  // total number of transform dimension elements
    int* size;     // size of each dimension, in order
    int* tdims;    // position of each transform dimension
    int* tsize;    // size of each transform dimension
    int* osize;    // size of each non-transform dimension
    int* cpTrans;  // cumulative product at the position of each transform 
                   // dimension
    int* cpOther;  // cumulative product at the position of each 
                   // non-transform dimension
}
Config;

/*========================== Kernel Struct =================================*/

typedef struct Kernel
{
    double   halfwidth;
    int      nSamplesInPositiveHalf;
    double*  positiveHalf;
    int      stride; // The maximum number of integer values that 
                     // the kernel can span, given any possible shift.
    double   indexFactor; // Precomputing this value will save us time in
                          // EvaluateKernel function
}
Kernel;

/*=================== Pad Method and Convolver Struct =====================*/

typedef enum { Fill, Bound, Replicate, Circular, Symmetric } PadMethod;

typedef struct Convolver
{
    PadMethod padmethod;   // Method for defining values for points that map
                           // outside A
    int       ndims;       // Number of input transform dimensions
    int       nPoints;     // Total number of interpolating points
    int*      size;        // Length of the weight array for each transform 
                           // dimension
    int*      cumsum;      // Cumulative sum of sizes, with a zero inserted 
                           // at the front
    int*      cumprod;     // Cumulative product of sizes, with a one inserted
                           // at the front
    double**  weights;     // Array of pointers to the weight arrays for each
                           // transform dimension
    int*      tsize;       // Input tsize

    int**     tsub;        // Array pointers to the subscript arrays for each
                           // transform dimension
    int**     subs;        // A list of transform subscripts for each local 
                           // point
    int*      useFill;     // Boolean array, one value for each local point

    double*   weight_data; // Storage for the arrays pointed to by weights
    int*      tsub_data;   // Storage for the arrays pointed to by tsub
    int*      subs_data;   // Storage for the arrays pointed to by subs

    double*   lo;          // Lower bounds for range checking
    double*   hi;          // Upper bounds for range checking

    Kernel**  kernelset;   // An interpolating kernel for each input
                           // transform dimension
    Iterator* localIt;     // Iterator for local grid points in transform
                           // space
 }
Convolver;

#endif
