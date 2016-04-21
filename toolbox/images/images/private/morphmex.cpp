/*
 * Copyright 1993-2003 The MathWorks, Inc.
 * $Revision: 1.1.6.2 $  $Date: 2003/08/01 18:11:21 $
 *
 * MORPHMEX(MEX_METHOD, B, NHOOD, HEIGHT, UNPACKED_M)
 *
 * MEX_METHOD:
 *            'dilate_binary'
 *            'erode_binary'
 *            'dilate_binary_packed'
 *            'erode_binary_packed'
 *            'dilate_gray_flat'
 *            'erode_gray_flat'
 *            'dilate_gray_nonflat'
 *            'erode_gray_nonflat'
 *
 * B: input image array
 *
 * NHOOD: neighborhood of structuring element; N-D double array of 0s and 1s
 *
 * HEIGHT: double array of heights; same size as NHOOD
 *
 * UNPACKED_M: row size of original input image before it was packed;
 *             only used for the erode_binary_packed method; otherwise
 *             it is ignored.
 */

static char rcsid[] = "$Id: morphmex.cpp,v 1.1.6.2 2003/08/01 18:11:21 batserve Exp $";

#include <string.h>
#include <math.h>
#include "morphmex.h"

void dilate_binary(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    Neighborhood_T nhood;
    NeighborhoodWalker_T walker;
    const int *input_size;
    int input_dims;
    const mxArray *input_image = prhs[1];
    const mxArray *input_nhood = prhs[2];
    mxArray *output_image;

    if (!mxIsLogical(input_image))
    {
        mexErrMsgIdAndTxt("Images:morphmex:"
                          "inputImageMustBeLogicalForDilateMethod",
                          "%s","Input image must be logical for"
                          " dilate_binary method.");
    }
    
    input_dims = mxGetNumberOfDimensions(input_image);
    input_size = mxGetDimensions(input_image);

    nhood = nhMakeNeighborhood(input_nhood,NH_CENTER_MIDDLE_ROUNDDOWN);
    walker = nhMakeNeighborhoodWalker(nhood, input_size, input_dims, 0U);

    output_image = mxCreateLogicalArray(input_dims, input_size);

    dilate_logical((mxLogical *) mxGetData(input_image),
                   (mxLogical *) mxGetData(output_image),
                   mxGetNumberOfElements(input_image),
                   walker);
    
    nhDestroyNeighborhood(nhood);
    nhDestroyNeighborhoodWalker(walker);

    plhs[0] = output_image;
}

void erode_binary(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    Neighborhood_T nhood;
    NeighborhoodWalker_T walker;
    const int *input_size;
    int input_dims;
    const mxArray *input_image = prhs[1];
    const mxArray *input_nhood = prhs[2];
    mxArray *output_image;

    if (!mxIsLogical(input_image))
    {
        mexErrMsgIdAndTxt("Images:morphmex:"
                          "inputImageMustBeLogicalForErodeMethod",
                          "%s","Input image must be logical for "
                          "erode_binary method.");
    }

    input_dims = mxGetNumberOfDimensions(input_image);
    input_size = mxGetDimensions(input_image);

    nhood = nhMakeNeighborhood(input_nhood,NH_CENTER_MIDDLE_ROUNDDOWN);
    walker = nhMakeNeighborhoodWalker(nhood, input_size, input_dims, 0U);

    output_image = mxCreateLogicalArray(input_dims, input_size);
    
    erode_logical((mxLogical *) mxGetData(input_image),
                  (mxLogical *) mxGetData(output_image),
                  mxGetNumberOfElements(input_image),
                  walker);
    
    nhDestroyNeighborhood(nhood);
    nhDestroyNeighborhoodWalker(walker);

    plhs[0] = output_image;
}

void dilate_gray_flat(int nlhs, mxArray *plhs[], int nrhs, 
                      const mxArray *prhs[])
{
    Neighborhood_T nhood;
    NeighborhoodWalker_T walker;
    const int *input_size;
    int input_dims;
    int input_class;
    const mxArray *input_image = prhs[1];
    const mxArray *input_nhood = prhs[2];
    mxArray *output_image;
    void *In;
    void *Out;
    int num_elements;

    input_size = mxGetDimensions(input_image);
    input_dims = mxGetNumberOfDimensions(input_image);
    input_class = mxGetClassID(input_image);
    output_image = mxCreateNumericArray(input_dims, 
                                        input_size,
                                        mxGetClassID(input_image),
                                        mxREAL);
    
    nhood = nhMakeNeighborhood(input_nhood,NH_CENTER_MIDDLE_ROUNDDOWN);
    nhReflectNeighborhood(nhood);
    walker = nhMakeNeighborhoodWalker(nhood, input_size, input_dims, 0U);

    num_elements = mxGetNumberOfElements(input_image);
    In = mxGetData(input_image);
    Out = mxGetData(output_image);

    switch (input_class)
    {
    case mxUINT8_CLASS:
        dilate_gray_flat_uint8((uint8_T *)In, (uint8_T *)Out,
                               num_elements, walker);
        break;
        
    case mxUINT16_CLASS:
        dilate_gray_flat_uint16((uint16_T *)In, (uint16_T *)Out,
                                num_elements, walker);
        break;
        
    case mxUINT32_CLASS:
        dilate_gray_flat_uint32((uint32_T *)In, (uint32_T *)Out,
                                num_elements, walker);
        break;
        
    case mxINT8_CLASS:
        dilate_gray_flat_int8((int8_T *)In, (int8_T *)Out, 
                              num_elements, walker);
        break;
        
    case mxINT16_CLASS:
        dilate_gray_flat_int16((int16_T *)In, (int16_T *)Out,
                               num_elements, walker);
        break;
        
    case mxINT32_CLASS:
        dilate_gray_flat_int32((int32_T *)In, (int32_T *)Out, 
                               num_elements, walker);
        break;
        
    case mxSINGLE_CLASS:
        dilate_gray_flat_single((float *)In, (float *)Out,
                                num_elements, walker);
        break;
        
    case mxDOUBLE_CLASS:
        dilate_gray_flat_double((double *)In, (double *)Out,
                                num_elements, walker);
        break;
        
    default:
        mexErrMsgIdAndTxt("Images:morphmex:internalInvalidClass",
                          "%s","Internal problem: invalid input image class.");
    }

    nhDestroyNeighborhood(nhood);
    nhDestroyNeighborhoodWalker(walker);

    plhs[0] = output_image;
}

void erode_gray_flat(int nlhs, mxArray *plhs[], int nrhs, 
                     const mxArray *prhs[])
{
    Neighborhood_T nhood;
    NeighborhoodWalker_T walker;
    const int *input_size;
    int input_dims;
    int input_class;
    const mxArray *input_image = prhs[1];
    const mxArray *input_nhood = prhs[2];
    mxArray *output_image;
    void *In;
    void *Out;
    int num_elements;

    input_size = mxGetDimensions(input_image);
    input_dims = mxGetNumberOfDimensions(input_image);
    input_class = mxGetClassID(input_image);
    output_image = mxCreateNumericArray(input_dims, 
                                        input_size,
                                        mxGetClassID(input_image),
                                        mxREAL);
    
    nhood = nhMakeNeighborhood(input_nhood,NH_CENTER_MIDDLE_ROUNDDOWN);
    walker = nhMakeNeighborhoodWalker(nhood,
                                      input_size,
                                      input_dims,
                                      0U);

    num_elements = mxGetNumberOfElements(input_image);
    In = mxGetData(input_image);
    Out = mxGetData(output_image);

    switch (input_class)
    {
    case mxUINT8_CLASS:
        erode_gray_flat_uint8((uint8_T *)In, (uint8_T *)Out,
                              num_elements, walker);
        break;
        
    case mxUINT16_CLASS:
        erode_gray_flat_uint16((uint16_T *)In, (uint16_T *)Out,
                               num_elements, walker);
        break;
        
    case mxUINT32_CLASS:
        erode_gray_flat_uint32((uint32_T *)In, (uint32_T *)Out,
                               num_elements, walker);
        break;
        
    case mxINT8_CLASS:
        erode_gray_flat_int8((int8_T *)In, (int8_T *)Out,
                             num_elements, walker);
        break;
        
    case mxINT16_CLASS:
        erode_gray_flat_int16((int16_T *)In, (int16_T *)Out,
                              num_elements, walker);
        break;
        
    case mxINT32_CLASS:
        erode_gray_flat_int32((int32_T *)In, (int32_T *)Out,
                              num_elements, walker);
        break;
        
    case mxSINGLE_CLASS:
        erode_gray_flat_single((float *)In, (float *)Out, 
                               num_elements, walker);
        break;
        
    case mxDOUBLE_CLASS:
        erode_gray_flat_double((double *)In, (double *)Out,
                               num_elements, walker);
        break;
        
    default:
        mexErrMsgIdAndTxt("Images:morphmex:internalInvalidClass",
                          "%s","Internal problem: invalid input image class.");
    }

    nhDestroyNeighborhood(nhood);
    nhDestroyNeighborhoodWalker(walker);

    plhs[0] = output_image;
}

double *get_heights(const mxArray *input_nhood, const mxArray *input_height)
{
    int num_neighbors;
    int num_elements;
    double *heights;
    double *pr;
    double *input_nhood_pr;
    double *input_height_pr;
    int k;
    
    num_elements = mxGetNumberOfElements(input_nhood);
    input_nhood_pr = (double *) mxGetData(input_nhood);
    num_neighbors = 0;
    for (k = 0; k < num_elements; k++)
    {
        if (input_nhood_pr[k] != 0)
        {
            num_neighbors++;
        }
    }
    
    heights = (double *) mxCalloc(num_neighbors, sizeof(double));
    input_height_pr = (double *) mxGetData(input_height);
    pr = heights;
    for (k = 0; k < num_elements; k++)
    {
        if (input_nhood_pr[k] != 0.0)
        {
            *pr = input_height_pr[k];
            pr++;
        }
    }

    return heights;
}

void dilate_gray_nonflat(int nlhs, mxArray *plhs[], int nrhs, 
                      const mxArray *prhs[])
{
    Neighborhood_T nhood;
    NeighborhoodWalker_T walker;
    const int *input_size;
    int input_dims;
    int input_class;
    const mxArray *input_image = prhs[1];
    const mxArray *input_nhood = prhs[2];
    const mxArray *input_height = prhs[3];
    mxArray *output_image;
    void *In;
    void *Out;
    int num_elements;
    double *heights;

    input_size = mxGetDimensions(input_image);
    input_dims = mxGetNumberOfDimensions(input_image);
    input_class = mxGetClassID(input_image);
    output_image = mxCreateNumericArray(input_dims, 
                                        input_size,
                                        mxGetClassID(input_image),
                                        mxREAL);
    
    nhood = nhMakeNeighborhood(input_nhood,NH_CENTER_MIDDLE_ROUNDDOWN);
    nhReflectNeighborhood(nhood);
    walker = nhMakeNeighborhoodWalker(nhood,
                                      input_size,
                                      input_dims,
                                      0U);

    num_elements = mxGetNumberOfElements(input_image);
    In = mxGetData(input_image);
    Out = mxGetData(output_image);

    heights = get_heights(input_nhood, input_height);

    switch (input_class)
    {
    case mxUINT8_CLASS:
        dilate_gray_nonflat_uint8((uint8_T *)In, (uint8_T *)Out,
                                  num_elements, walker, heights);
        break;
        
    case mxUINT16_CLASS:
        dilate_gray_nonflat_uint16((uint16_T *)In, (uint16_T *)Out,
                                   num_elements, walker, heights);
        break;
        
    case mxUINT32_CLASS:
        dilate_gray_nonflat_uint32((uint32_T *)In, (uint32_T *)Out,
                                   num_elements, walker, heights);
        break;
        
    case mxINT8_CLASS:
        dilate_gray_nonflat_int8((int8_T *)In, (int8_T *)Out,
                                 num_elements, walker, heights);
        break;
        
    case mxINT16_CLASS:
        dilate_gray_nonflat_int16((int16_T *)In, (int16_T *)Out,
                                  num_elements, walker, heights);
        break;
        
    case mxINT32_CLASS:
        dilate_gray_nonflat_int32((int32_T *)In, (int32_T *)Out,
                                  num_elements, walker, heights);
        break;
        
    case mxSINGLE_CLASS:
        dilate_gray_nonflat_single((float *)In, (float *)Out,
                                   num_elements, walker, heights);
        break;
        
    case mxDOUBLE_CLASS:
        dilate_gray_nonflat_double((double *)In, (double *)Out, 
                                   num_elements, walker, heights);
        break;
        
    default:
        mexErrMsgIdAndTxt("Images:morphmex:internalInvalidClass",
                          "%s","Internal problem: invalid input image class.");
    }

    nhDestroyNeighborhood(nhood);
    nhDestroyNeighborhoodWalker(walker);
    mxFree(heights);

    plhs[0] = output_image;
}

void erode_gray_nonflat(int nlhs, mxArray *plhs[], int nrhs, 
                        const mxArray *prhs[])
{
    Neighborhood_T nhood;
    NeighborhoodWalker_T walker;
    const int *input_size;
    int input_dims;
    int input_class;
    const mxArray *input_image = prhs[1];
    const mxArray *input_nhood = prhs[2];
    const mxArray *input_height = prhs[3];
    mxArray *output_image;
    void *In;
    void *Out;
    int num_elements;
    double *heights;

    input_size = mxGetDimensions(input_image);
    input_dims = mxGetNumberOfDimensions(input_image);
    input_class = mxGetClassID(input_image);
    output_image = mxCreateNumericArray(input_dims, 
                                        input_size,
                                        mxGetClassID(input_image),
                                        mxREAL);
    
    nhood = nhMakeNeighborhood(input_nhood,NH_CENTER_MIDDLE_ROUNDDOWN);
    walker = nhMakeNeighborhoodWalker(nhood,
                                      input_size,
                                      input_dims,
                                      0U);

    num_elements = mxGetNumberOfElements(input_image);
    In = mxGetData(input_image);
    Out = mxGetData(output_image);
    
    heights = get_heights(input_nhood, input_height);

    switch (input_class)
    {
    case mxUINT8_CLASS:
        erode_gray_nonflat_uint8((uint8_T *)In, (uint8_T *)Out, 
                                 num_elements, walker, heights);
        break;
        
    case mxUINT16_CLASS:
        erode_gray_nonflat_uint16((uint16_T *)In, (uint16_T *)Out,
                                  num_elements, walker, heights);
        break;
        
    case mxUINT32_CLASS:
        erode_gray_nonflat_uint32((uint32_T *)In, (uint32_T *)Out,
                                  num_elements, walker, heights);
        break;
        
    case mxINT8_CLASS:
        erode_gray_nonflat_int8((int8_T *)In, (int8_T *)Out, 
                                num_elements, walker, heights);
        break;
        
    case mxINT16_CLASS:
        erode_gray_nonflat_int16((int16_T *)In, (int16_T *)Out,
                                 num_elements, walker, heights);
        break;
        
    case mxINT32_CLASS:
        erode_gray_nonflat_int32((int32_T *)In, (int32_T *)Out,
                                 num_elements, walker, heights);
        break;
        
    case mxSINGLE_CLASS:
        erode_gray_nonflat_single((float *)In, (float *)Out,
                                  num_elements, walker, heights);
        break;
        
    case mxDOUBLE_CLASS:
        erode_gray_nonflat_double((double *)In, (double *)Out, 
                                  num_elements, walker, heights);
        break;
        
    default:
        mexErrMsgIdAndTxt("Images:morphmex:internalInvalidClass",
                          "%s","Internal problem: invalid input image class.");
    }

    nhDestroyNeighborhood(nhood);
    nhDestroyNeighborhoodWalker(walker);
    mxFree(heights);

    plhs[0] = output_image;
}

void get_rc_offsets(const mxArray *nhood, int *num_neighbors, 
                    double **rc_offsets)
{
    int M;
    int N;
    int center_row;
    int center_col;
    double *pr;
    int num_elements;
    int k;
    int counter;
    int c;
    int r;
    
    if (mxGetNumberOfDimensions(nhood) != 2)
    {
        mexErrMsgIdAndTxt("Images:morphmex:nhoodMustBe2DForPackedMethods",
                          "%s","Neighborhood must be 2-D for packed methods.");
    }

    M = mxGetM(nhood);
    N = mxGetN(nhood);
    num_elements = M*N;

    center_row = (M-1)/2;
    center_col = (N-1)/2;
    *num_neighbors = 0;
    pr = (double *) mxGetData(nhood);
    
    for (k = 0; k < num_elements; k++)
    {
        if (pr[k] != 0.0)
        {
            (*num_neighbors)++;
        }
    }
    
    *rc_offsets = (double *) mxCalloc(*num_neighbors * 2, sizeof(double));
    
    counter = 0;
    for (c = 0; c < N; c++)
    {
        for (r = 0; r < M; r++)
        {
            if (*pr != 0.0)
            {
                (*rc_offsets)[counter] = r - center_row;
                (*rc_offsets)[counter + *num_neighbors] = c - center_col;
                counter++;
            }
            pr++;
        }
    }
}

void dilate_packed(int nlhs, mxArray *plhs[], int nrhs,
                   const mxArray *prhs[])
{
    const mxArray *input_image = prhs[1];
    const mxArray *input_nhood = prhs[2];
    mxArray *output_image;
    uint32_T *In;
    uint32_T *Out;
    int M;
    int N;
    int num_neighbors;
    double *rc_offsets;

    if (!mxIsUint32(input_image))
    {
        mexErrMsgIdAndTxt("Images:morphmex:"
                          "inputImageMustBeUint32ForPackedMethods",
                          "%s","Input image must be uint32 for packed methods.");
    }

    if (mxGetNumberOfDimensions(input_image) != 2)
    {
        mexErrMsgIdAndTxt("Images:morphmex:inputImageMustBe2DForPackedMethods",
                          "%s","Input image must be 2-D for packed methods.");
    }

    M = mxGetM(input_image);
    N = mxGetN(input_image);
    output_image = mxCreateNumericMatrix(M,N,mxUINT32_CLASS,mxREAL);

    get_rc_offsets(input_nhood, &num_neighbors, &rc_offsets);
    
    In = (uint32_T *) mxGetData(input_image);
    Out = (uint32_T *) mxGetData(output_image);

    dilate_packed_uint32(In, Out, M, N, rc_offsets, num_neighbors);
    
    mxFree(rc_offsets);

    plhs[0] = output_image;
}

void erode_packed(int nlhs, mxArray *plhs[], int nrhs,
                  const mxArray *prhs[])
{
    const mxArray *input_image = prhs[1];
    const mxArray *input_nhood = prhs[2];
    mxArray *output_image;
    uint32_T *In;
    uint32_T *Out;
    int M;
    int N;
    int num_neighbors;
    int unpacked_M;
    double *rc_offsets;

    if (!mxIsUint32(input_image))
    {
        mexErrMsgIdAndTxt("Images:morphmex:"
                          "inputImageMustBeUint32ForPackedMethods","%s",
                          "Input image must be uint32 for packed methods.");
    }

    if (mxGetNumberOfDimensions(input_image) != 2)
    {
        mexErrMsgIdAndTxt("Images:morphmex:inputImageMustBe2DForPackedMethods",
                          "%s","Input image must be 2-D for packed methods.");
    }

    if (nrhs < 5)
    {
        mexErrMsgIdAndTxt("Images:morphmex:missingMForPackedErosion",
                          "%s","M must be provided for packed erosion.");
    }

    unpacked_M = (int) mxGetScalar(prhs[4]);
    if (unpacked_M < 0)
    {
        mexErrMsgIdAndTxt("Images:morphmex:inputMMustBeNonnegative",
                          "%s","M must be nonnegative.");
    }
    
    M = mxGetM(input_image);
    N = mxGetN(input_image);
    output_image = mxCreateNumericMatrix(M,N,mxUINT32_CLASS,mxREAL);

    get_rc_offsets(input_nhood, &num_neighbors, &rc_offsets);
    
    In = (uint32_T *) mxGetData(input_image);
    Out = (uint32_T *) mxGetData(output_image);

    erode_packed_uint32(In, Out, M, N, rc_offsets, num_neighbors, 
                        unpacked_M);
    
    mxFree(rc_offsets);

    plhs[0] = output_image;
}

void check_for_nans(const mxArray *input_image)
{
    double *double_ptr;
    float *single_ptr;
    int k;
    int num_elements;
    
    num_elements = mxGetNumberOfElements(input_image);
    
    if (mxIsDouble(input_image))
    {
        double_ptr = (double *) mxGetData(input_image);
        for (k = 0; k < num_elements; k++)
        {
            if (mxIsNaN(double_ptr[k]))
            {
                mexErrMsgIdAndTxt("Images:morphmex:expectedNonnan",
                                  "%s",
                                  "Input image may not contain NaNs.");
            }
        }
    }
    else if (mxIsSingle(input_image))
    {
        single_ptr = (float *) mxGetData(input_image);
        for (k = 0; k < num_elements; k++)
        {
            if (mxIsNaN(single_ptr[k]))
            {
                mexErrMsgIdAndTxt("Images:morphmex:expectedNonnan",
                                  "%s","Input image may not contain NaNs.");
            }
        }
    }
    else
    {
        mexErrMsgIdAndTxt("Images:morphmex:internalBadInputClass",
                          "%s","Internal problem: unexpected input"
                          " class in check_for_nans.");
    }
}

typedef void (matlab_fcn)(int nlhs, mxArray *plhs[], int nrhs,
                          const mxArray *prhs[]);

void check_inputs_generic(int nlhs, mxArray *plhs[], int nrhs,
                          const mxArray *prhs[])
{
    const mxArray *method;
    const mxArray *input_image;
    const mxArray *nhood;
    const mxArray *height;
    const mxArray *unpacked_M;
    int num_nhood_dims;
    const int *nhood_size;
    const int *height_size;
    int i;
    double scalar;
    
    if (nrhs < 4)
    {
        mexErrMsgIdAndTxt("Images:morphmex:tooFewInputs",
                          "%s","Not enough input arguments.");
    }
    
    method = prhs[0];
    input_image = prhs[1];
    nhood = prhs[2];
    height = prhs[3];
    
    if (!mxIsChar(method))
    {
        mexErrMsgIdAndTxt("Images:morphmex:firstInputMustBeMethodString","%s",
                          "First input argument must be a method string.");
    }
    
    if (!mxIsNumeric(input_image) && !mxIsLogical(input_image))
    {
        mexErrMsgIdAndTxt("Images:morphmex:inputImageMustBeNumericOrLogical",
                          "%s","Input image must be numeric or logical.");
    }
    if (mxIsSparse(input_image))
    {
        mexErrMsgIdAndTxt("Images:morphmex:inputImageMustBeNonsparse",
                          "%s","Input image must not be sparse.");
    }
    if (mxIsComplex(input_image))
    {
        mexErrMsgIdAndTxt("Images:morphmex:inputImageMustBeReal",
                          "%s","Input image must be real.");
    }
    
    if (mxIsDouble(input_image) || mxIsSingle(input_image))
    {
        check_for_nans(input_image);
    }

    nhCheckDomain(nhood);
    
    if (mxIsSparse(height))
    {
        mexErrMsgIdAndTxt("Images:morphmex:heightMustBeNonsparse",
                          "%s","Height must not be sparse.");
    }
    if (!mxIsDouble(height))
    {
        mexErrMsgIdAndTxt("Images:morphmex:heightMustBeDoubleArray",
                          "%s","Height must be a double array.");
    }
    if (mxIsComplex(height))
    {
        mexErrMsgIdAndTxt("Images:morphmex:heightMustBeReal",
                          "%s","Height must be real.");
    }

    num_nhood_dims = mxGetNumberOfDimensions(nhood);
    if (num_nhood_dims != mxGetNumberOfDimensions(height))
    {
        mexErrMsgIdAndTxt("Images:morphmex:nhoodAndHeightMustHaveSameSize",
                          "%s",
                          "Neighborhood and height must have the same size.");
    }
    nhood_size = mxGetDimensions(nhood);
    height_size = mxGetDimensions(height);
    for (i = 0; i < num_nhood_dims; i++)
    {
        if (nhood_size[i] != height_size[i])
        {
            mexErrMsgIdAndTxt("Images:morphmex:nhoodAndHeightMustHaveSameSize",
                              "%s","Neighborhood and height must have"
                              " the same size.");
        }
    }

    if (nrhs == 5)
    {
        unpacked_M = prhs[4];
        if (! mxIsDouble(unpacked_M) || 
            (mxGetNumberOfElements(unpacked_M) != 1))
        {
            mexErrMsgIdAndTxt("Images:morphmex:inputMMustBeDoubleScalar",
                              "%s","M must be a double scalar.");
        }
        scalar = mxGetScalar(unpacked_M);
        if (floor(scalar) != scalar)
        {
            mexErrMsgIdAndTxt("Images:morphmex:inputMMustBeInteger",
                              "%s","M must be an integer.");
        }
    }
}

extern "C"
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    struct 
    {
        char *name;
        matlab_fcn *func;
    }
    morph_methods[] = {
        {"dilate_binary",        dilate_binary},
        {"erode_binary",         erode_binary},
        {"dilate_binary_packed", dilate_packed},
        {"erode_binary_packed",  erode_packed},
        {"dilate_gray_flat",     dilate_gray_flat},
        {"erode_gray_flat",      erode_gray_flat},
        {"dilate_gray_nonflat",  dilate_gray_nonflat},
        {"erode_gray_nonflat",   erode_gray_nonflat},
        {"",                     NULL}
    };

    int i = 0;
    char *method_string;
    int method_idx;

    check_inputs_generic(nlhs, plhs, nrhs, prhs);
    
    method_string = mxArrayToString(prhs[0]);
        
    while (morph_methods[i].func != NULL)
    {
        if (strcmp(method_string, morph_methods[i].name) == 0)
        {
            method_idx = i;
            break;
        }
        i++;
    }
    
    mxFree(method_string);
    
    if (method_idx >= 0)
    {
        (*(morph_methods[method_idx].func))(nlhs, plhs, nrhs, prhs);
    }
    else
    {
        mexErrMsgIdAndTxt("Images:morphmex:unknownMethodString",
                          "%s","Unknown method string.");
    }
}

