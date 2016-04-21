/* $Revision: 1.1.6.1 $ */
/*
 * Copyright 1993-2003 The MathWorks, Inc.
 * $Revision $  $Date: 2003/05/03 17:52:05 $
 */

/*
 * IMREGIONALMAX MEX-file
 *
 * BW = IMREGIONALMAX(I,N) computes the regional maxima of I, storing the
 * result in a binary image.  N specifies 8- or 4-connectivity.
 *
 * Input and output specs
 * ----------------------
 * I:     N-D, full, real matrix
 *        any numeric type
 *        logical ok, but ignored
 *        Empty ok
 *        Infs ok
 *        NaNs not allowed.
 *
 * CONN:  connectivity
 *
 * BW:    logical uint8, same size as I
 *        contains only 0s and 1s.
 */

#include "neighborhood.h"
#include "stack.h"
#include "mex.h"

/*
 * Instantiate regmax_TYPE functions for uint8, uint16, and double.
 */

#undef TYPE
#undef DO_NAN_CHECK

#define TYPE mxLogical
void regmax_logical(void *prF_in, mxLogical *BW, 
                  int num_elements, NeighborhoodWalker_T walker)
#include "regmax.h"
#undef TYPE

#define TYPE uint8_T
void regmax_uint8(void *prF_in, mxLogical *BW, 
                  int num_elements, NeighborhoodWalker_T walker)
#include "regmax.h"
#undef TYPE

#define TYPE uint16_T
void regmax_uint16(void *prF_in, mxLogical *BW,
                   int num_elements, NeighborhoodWalker_T walker)
#include "regmax.h"
#undef TYPE

#define TYPE uint32_T
void regmax_uint32(void *prF_in, mxLogical *BW,
                   int num_elements, NeighborhoodWalker_T walker)
#include "regmax.h"
#undef TYPE

#define TYPE int8_T
void regmax_int8(void *prF_in, mxLogical *BW,
                   int num_elements, NeighborhoodWalker_T walker)
#include "regmax.h"
#undef TYPE

#define TYPE int16_T
void regmax_int16(void *prF_in, mxLogical *BW,
                   int num_elements, NeighborhoodWalker_T walker)
#include "regmax.h"
#undef TYPE

#define TYPE int32_T
void regmax_int32(void *prF_in, mxLogical *BW,
                   int num_elements, NeighborhoodWalker_T walker)
#include "regmax.h"
#undef TYPE

#define TYPE float
#define DO_NAN_CHECK
void regmax_single(void *prF_in, mxLogical *BW,
                   int num_elements, NeighborhoodWalker_T walker)
#include "regmax.h"
#undef TYPE
#undef DO_NAN_CHECK

#define TYPE double
#define DO_NAN_CHECK
void regmax_double(void *prF_in, mxLogical *BW,
                   int num_elements, NeighborhoodWalker_T walker)
#include "regmax.h"
#undef TYPE
#undef DO_NAN_CHECK


extern "C"
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    const mxArray *F;
    mxArray *BW;
    int num_elements;
    void *prF;
    mxLogical *prBW;
    int input_ndims;
    const int *input_size;
    Neighborhood_T nhood;
    NeighborhoodWalker_T walker;

    if (nrhs < 1)
    {
        mexErrMsgIdAndTxt("Images:imregionalmaxmex:tooFewInputs",
                          "IMREGIONALMAXMEX needs at least one input argument.");
    }

    else if (nrhs > 2)
    {
        mexErrMsgIdAndTxt("Images:imregionalmaxmex:tooManyInputs",
                          "IMREGIONALMAXMEX takes at most three input arguments.");
    }

    /*
     * The regional maximum algorithm works in-place on a copy of the
     * input image.  At the end this copy will hold the result.
     */
    F = prhs[0];
    input_ndims = mxGetNumberOfDimensions(F);
    input_size = mxGetDimensions(F);
    BW = mxCreateLogicalArray(input_ndims, input_size);
    plhs[0] = BW;
    if (mxIsEmpty(BW))
    {
        return;
    }

    prF = mxGetData(F);
    prBW = mxGetLogicals(BW);

    num_elements = mxGetNumberOfElements(prhs[0]);

    if (nrhs > 1)
    {
        nhood = nhMakeNeighborhood(prhs[1],NH_CENTER_MIDDLE_ROUNDDOWN);
    }
    else
    {
        nhood = nhMakeDefaultConnectivityNeighborhood(input_ndims);
    }
    
    walker = nhMakeNeighborhoodWalker(nhood, input_size, input_ndims, 
                                      NH_SKIP_CENTER);

    switch (mxGetClassID(F))
    {
    case mxLOGICAL_CLASS:
        regmax_logical(prF, prBW, num_elements, walker);
        break;
        
    case mxUINT8_CLASS:
        regmax_uint8(prF, prBW, num_elements, walker);
        break;
        
    case mxUINT16_CLASS:
        regmax_uint16(prF, prBW, num_elements, walker);
        break;
        
    case mxUINT32_CLASS:
        regmax_uint32(prF, prBW, num_elements, walker);
        break;
        
    case mxINT8_CLASS:
        regmax_int8(prF, prBW, num_elements, walker);
        break;
        
    case mxINT16_CLASS:
        regmax_int16(prF, prBW, num_elements, walker);
        break;
        
    case mxINT32_CLASS:
        regmax_int32(prF, prBW, num_elements, walker);
        break;
        
    case mxSINGLE_CLASS:
        regmax_single(prF, prBW, num_elements, walker);
        break;
        
    case mxDOUBLE_CLASS:
        regmax_double(prF, prBW, num_elements, walker);
        break;
        
    default:
        mexErrMsgTxt("Unsupported input class.");
        break;
    }

    nhDestroyNeighborhood(nhood);
    nhDestroyNeighborhoodWalker(walker);
}
