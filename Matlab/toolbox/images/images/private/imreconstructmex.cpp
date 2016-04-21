/* 
 * Copyright 1993-2003 The MathWorks, Inc.
 * $Revision: 1.1.6.1 $  $Date: 2003/05/03 17:52:04 $
 */

/*
 * IMRECONSTRUCT MEX-file
 *
 * K = IMRECONSTRUCT(J,I,CONN) performs grayscale reconstruction with
 * J as the marker image and I as the mask image.  CONN specifies
 * connectivity.
 *
 * Input and output specs
 * ----------------------
 * J:    N-D real matrix, uint8, uint16, or double
 *       empty allowed
 *       Infs allowed
 *       NaNs not allowed
 *
 * I:    N-D real matrix, same size and class as J
 *       Infs allowed
 *       NaNs not allowed
 *       Elements of I must be >= corresponding elements of J
 * 
 * CONN: See connectivity spec.
 *
 * K:    N-D real matrix, same size and class as I and J.
 *       logical if and only if both inputs are logical.
 */

#include "neighborhood.h"
#include "queue.h"
#include "mex.h"

static char rcsid[] = "$Id: imreconstructmex.cpp,v 1.1.6.1 2003/05/03 17:52:04 batserve Exp $";

/*
 * Instantiate reconstruct_TYPE functions for uint8, uint16, and double.
 */

#undef TYPE
#undef DO_NAN_CHECK

#define TYPE mxLogical
void reconstruct_logical(void *prJ_in, void *prI_in, int num_elements,
                         NeighborhoodWalker_T walker,
                         NeighborhoodWalker_T trailing_walker,
                         NeighborhoodWalker_T leading_walker)
#include "reconstruct.h"
#undef TYPE

#define TYPE uint8_T
void reconstruct_uint8(void *prJ_in, void *prI_in, int num_elements,
                       NeighborhoodWalker_T walker,
                       NeighborhoodWalker_T trailing_walker,
                       NeighborhoodWalker_T leading_walker)
#include "reconstruct.h"
#undef TYPE

#define TYPE uint16_T
void reconstruct_uint16(void *prJ_in, void *prI_in, int num_elements,
                       NeighborhoodWalker_T walker,
                       NeighborhoodWalker_T trailing_walker,
                       NeighborhoodWalker_T leading_walker)
#include "reconstruct.h"
#undef TYPE

#define TYPE uint32_T
void reconstruct_uint32(void *prJ_in, void *prI_in, int num_elements,
                       NeighborhoodWalker_T walker,
                       NeighborhoodWalker_T trailing_walker,
                       NeighborhoodWalker_T leading_walker)
#include "reconstruct.h"
#undef TYPE

#define TYPE int8_T
void reconstruct_int8(void *prJ_in, void *prI_in, int num_elements,
                       NeighborhoodWalker_T walker,
                       NeighborhoodWalker_T trailing_walker,
                       NeighborhoodWalker_T leading_walker)
#include "reconstruct.h"
#undef TYPE

#define TYPE int16_T
void reconstruct_int16(void *prJ_in, void *prI_in, int num_elements,
                       NeighborhoodWalker_T walker,
                       NeighborhoodWalker_T trailing_walker,
                       NeighborhoodWalker_T leading_walker)
#include "reconstruct.h"
#undef TYPE

#define TYPE int32_T
void reconstruct_int32(void *prJ_in, void *prI_in, int num_elements,
                       NeighborhoodWalker_T walker,
                       NeighborhoodWalker_T trailing_walker,
                       NeighborhoodWalker_T leading_walker)
#include "reconstruct.h"
#undef TYPE

#define TYPE float
#define DO_NAN_CHECK
void reconstruct_single(void *prJ_in, void *prI_in, int num_elements,
                       NeighborhoodWalker_T walker,
                       NeighborhoodWalker_T trailing_walker,
                       NeighborhoodWalker_T leading_walker)
#include "reconstruct.h"
#undef TYPE
#undef DO_NAN_CHECK

#define TYPE double
#define DO_NAN_CHECK
void reconstruct_double(void *prJ_in, void *prI_in, int num_elements,
                       NeighborhoodWalker_T walker,
                       NeighborhoodWalker_T trailing_walker,
                       NeighborhoodWalker_T leading_walker)
#include "reconstruct.h"
#undef TYPE
#undef DO_NAN_CHECK

#define DEFAULT_STYLE 8

void CheckInputs(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    int ndims;
    const int *size_0;
    const int *size_1;
    int k;

    if (nrhs < 2)
    {
        mexErrMsgIdAndTxt("Images:imreconstructmex:tooFewInputs",
                          "IMRECONSTRUCTMEX needs at least two input arguments.");
    }

    else if (nrhs > 3)
    {
        mexErrMsgIdAndTxt("Images:imreconstructmex:tooManyInputs",
                          "IMRECONSTRUCTMEX takes at most two input arguments.");
    }

    if (mxGetClassID(prhs[0]) != mxGetClassID(prhs[1]))
    {
        mexErrMsgIdAndTxt("Images:imreconstruct:notSameClass",
                          "%s",
                          "Function imreconstruct expected MARKER and MASK to have the same class.");
    }

    ndims = mxGetNumberOfDimensions(prhs[0]);
    if (ndims != mxGetNumberOfDimensions(prhs[1]))
    {
        mexErrMsgIdAndTxt("Images:imreconstruct:notSameSize",
                          "%s",
                          "Function imreconstruct expected MARKER and MASK to be the same size.");
    }

    size_0 = mxGetDimensions(prhs[0]);
    size_1 = mxGetDimensions(prhs[1]);
    for (k = 0; k < ndims; k++)
    {
        if (size_0[k] != size_1[k])
        {
            mexErrMsgIdAndTxt("Images:imreconstruct:notSameSize",
                              "%s",
                              "Function imreconstruct expected MARKER and MASK to be the same size.");
        }
    }

}

extern "C"
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    mxArray *J;
    const mxArray *I;
    int num_dims;
    int num_elements;
    const int *input_size;
    void *prJ;
    void *prI;
    Neighborhood_T nhood;
    NeighborhoodWalker_T trailing_walker;
    NeighborhoodWalker_T leading_walker;
    NeighborhoodWalker_T walker;

    CheckInputs(nlhs, plhs, nrhs, prhs);

    /*
     * The reconstruction algorithm works in-place on a copy of the
     * input marker image.  At the end this copy will hold the result.
     */
    J = mxDuplicateArray(prhs[0]);
    plhs[0] = J;
    if (mxIsEmpty(J))
    {
        return;
    }

    I = prhs[1];
    num_elements = mxGetNumberOfElements(prhs[0]);
    num_dims = mxGetNumberOfDimensions(prhs[0]);
    input_size = mxGetDimensions(prhs[0]);

    if (nrhs < 3)
    {
        nhood = nhMakeDefaultConnectivityNeighborhood(num_dims);
    }
    else
    {
        nhood = nhMakeNeighborhood(prhs[2],NH_CENTER_MIDDLE_ROUNDDOWN);
    }
    
    trailing_walker = nhMakeNeighborhoodWalker(nhood, input_size, num_dims, 
                                      NH_SKIP_CENTER | NH_SKIP_LEADING);
    leading_walker = nhMakeNeighborhoodWalker(nhood, input_size, num_dims, 
                                      NH_SKIP_CENTER | NH_SKIP_TRAILING);
    walker = nhMakeNeighborhoodWalker(nhood, input_size, num_dims,
                                      NH_SKIP_CENTER);
    nhDestroyNeighborhood(nhood);

    prJ = mxGetData(J);
    prI = mxGetData(I);
    
    switch (mxGetClassID(J))
    {
    case mxLOGICAL_CLASS:
        reconstruct_logical(prJ, prI, num_elements, walker, trailing_walker, 
                            leading_walker);
        break;

    case mxUINT8_CLASS:
        reconstruct_uint8(prJ, prI, num_elements, walker, trailing_walker, 
                          leading_walker);
        break;
        
    case mxUINT16_CLASS:
        reconstruct_uint16(prJ, prI, num_elements, walker, trailing_walker, 
                           leading_walker);
        break;
        
    case mxUINT32_CLASS:
        reconstruct_uint32(prJ, prI, num_elements, walker, trailing_walker, 
                           leading_walker);
        break;
        
    case mxINT8_CLASS:
        reconstruct_int8(prJ, prI, num_elements, walker, trailing_walker, 
                         leading_walker);
        break;
        
    case mxINT16_CLASS:
        reconstruct_int16(prJ, prI, num_elements, walker, trailing_walker, 
                          leading_walker);
        break;
        
    case mxINT32_CLASS:
        reconstruct_int32(prJ, prI, num_elements, walker, trailing_walker, 
                          leading_walker);
        break;
        
    case mxSINGLE_CLASS:
        reconstruct_single(prJ, prI, num_elements, walker, trailing_walker, 
                           leading_walker);
        break;
        
    case mxDOUBLE_CLASS:
        reconstruct_double(prJ, prI, num_elements, walker, trailing_walker, 
                           leading_walker);
        break;
        
    default:
        mexErrMsgIdAndTxt("Images:imreconstruct:badClass",
                          "%s",
                          "Unsupported input class.");
        break;
    }

    nhDestroyNeighborhoodWalker(trailing_walker);
    nhDestroyNeighborhoodWalker(leading_walker);
    nhDestroyNeighborhoodWalker(walker);
    
}

    
