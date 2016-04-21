/*
 * Copyright 1993-2003 The MathWorks, Inc.
 * $Revision: 1.1.6.2 $  $Date: 2003/05/03 17:52:23 $
 */

/*
 * WATERSHED_VS MEX-file
 *
 * L = WATERSHED_VS(A,CONN,IDX) finds the watershed regions of A, producing 
 * a label array L.  IDX is a zero-based sort index for A, which can be 
 * computed in MATLAB as follows:
 *    [junk,idx] = sort(A(:));
 *    idx = idx - 1;
 *
 * Input-output specs
 * ------------------
 * A      N-D full, real, numeric array
 *        empty allowed
 *        +/- Inf allowed
 *        NaN not allowed
 *        logical ignored
 *
 * CONN   See connectivity spec
 *
 * IDX    Double vector containing zero-based sort permutation index for A(:).
 *        This input is *not* checked to make sure that is a valid
 *        sort permutation index.  If it isn't valid, the results will
 *        be unpredictable.
 *
 * L      Full double array of the same size as A.
 */

#include "neighborhood.h"
#include "queue.h"
#include "mex.h"

static char rcsid[] = "$Id: watershed_vs.cpp,v 1.1.6.2 2003/05/03 17:52:23 batserve Exp $";

#define INIT -1
#define MASK -2
#define WSHED 0
#define FICTITIOUS -1

/*
 * Instantiate compute_watershed_vs_TYPE functions.
 */

#undef TYPE
#undef DO_NAN_CHECK

#define TYPE uint8_T
void compute_watershed_vs_uint8(TYPE *I, int N, NeighborhoodWalker_T walker,
                                double *sort_index, double *L)
#include "watershed_vs.h"

#define TYPE mxLogical
void compute_watershed_vs_logical(TYPE *I, int N, NeighborhoodWalker_T walker,
                                  double *sort_index, double *L)
#include "watershed_vs.h"

#define TYPE uint16_T
void compute_watershed_vs_uint16(TYPE *I, int N, NeighborhoodWalker_T walker,
                                 double *sort_index, double *L)
#include "watershed_vs.h"

#define TYPE uint32_T
void compute_watershed_vs_uint32(TYPE *I, int N, NeighborhoodWalker_T walker,
                                 double *sort_index, double *L)
#include "watershed_vs.h"

#define TYPE int8_T
void compute_watershed_vs_int8(TYPE *I, int N, NeighborhoodWalker_T walker,
                                 double *sort_index, double *L)
#include "watershed_vs.h"

#define TYPE int16_T
void compute_watershed_vs_int16(TYPE *I, int N, NeighborhoodWalker_T walker,
                                 double *sort_index, double *L)
#include "watershed_vs.h"

#define TYPE int32_T
void compute_watershed_vs_int32(TYPE *I, int N, NeighborhoodWalker_T walker,
                                 double *sort_index, double *L)
#include "watershed_vs.h"

#define TYPE float
#define DO_NAN_CHECK
void compute_watershed_vs_float(TYPE *I, int N, NeighborhoodWalker_T walker,
                                 double *sort_index, double *L)
#include "watershed_vs.h"

#define TYPE double
#define DO_NAN_CHECK
void compute_watershed_vs_double(TYPE *I, int N, NeighborhoodWalker_T walker,
                                 double *sort_index, double *L)
#include "watershed_vs.h"

void check_inputs(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    if (nrhs != 3)
    {
        mexErrMsgIdAndTxt("Images:watershed_vs:invalidNumInputs",
                          "%s",
                          "WATERSHED_VS needs 3 input arguments.");
    }
    if (mxGetNumberOfElements(prhs[2]) != mxGetNumberOfElements(prhs[0]))
    {
        mexErrMsgIdAndTxt("Images:watershed_vs:sortIndexMismatchedSize",
                          "%s",
                          "Sort index must have the same number of "
                          "elements as the input image.");
    }
}

extern "C"
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    void *I;
    double *L;
    double *sort_index;
    int num_elements;
    const int *input_size;
    int ndims;
    mxClassID class_id;
    Neighborhood_T nhood;
    NeighborhoodWalker_T walker;

    check_inputs(nlhs, plhs, nrhs, prhs);

    if (mxIsLogical(prhs[0]))
    {
        I = mxGetLogicals(prhs[0]);
    }
    else
    {
        I = mxGetData(prhs[0]);
    }
    num_elements = mxGetNumberOfElements(prhs[0]);
    class_id = mxGetClassID(prhs[0]);
    input_size = mxGetDimensions(prhs[0]);
    ndims = mxGetNumberOfDimensions(prhs[0]);
    
    plhs[0] = mxCreateNumericArray(ndims, input_size, mxDOUBLE_CLASS, mxREAL);
    L = mxGetPr(plhs[0]);

    nhood = nhMakeNeighborhood(prhs[1],NH_CENTER_MIDDLE_ROUNDDOWN);
    walker = nhMakeNeighborhoodWalker(nhood,input_size,ndims,NH_SKIP_CENTER);

    sort_index = mxGetPr(prhs[2]);
    
    switch (class_id)
    {
    case mxLOGICAL_CLASS:
        compute_watershed_vs_logical((mxLogical *)I, num_elements,
                                     walker, sort_index, L);
        break;

    case mxUINT8_CLASS:
        compute_watershed_vs_uint8((uint8_T *)I, num_elements, walker, 
                                   sort_index, L);
        break;
        
    case mxUINT16_CLASS:
        compute_watershed_vs_uint16((uint16_T *)I, num_elements, 
                                    walker, sort_index, L);
        break;

    case mxUINT32_CLASS:
        compute_watershed_vs_uint32((uint32_T *)I, num_elements,
                                    walker, sort_index, L);
        break;

    case mxINT8_CLASS:
        compute_watershed_vs_int8((int8_T *)I, num_elements, 
                                  walker, sort_index, L);
        break;

    case mxINT16_CLASS:
        compute_watershed_vs_int16((int16_T *)I, num_elements,
                                   walker, sort_index, L);
        break;

    case mxINT32_CLASS:
        compute_watershed_vs_int32((int32_T *)I, num_elements,
                                   walker, sort_index, L);
        break;

    case mxSINGLE_CLASS:
        compute_watershed_vs_float((float *)I, num_elements, 
                                   walker, sort_index, L);
        break;

    case mxDOUBLE_CLASS:
        compute_watershed_vs_double((double *)I, num_elements,
                                    walker, sort_index, L);
        break;

    default:
        mxAssert(false, "");
        break;
    }

    nhDestroyNeighborhood(nhood);
    nhDestroyNeighborhoodWalker(walker);
}
