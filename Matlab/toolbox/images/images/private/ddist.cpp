/*
 * DDIST MEX-file
 *
 * Discrete distance transform.
 *
 * D = DDIST(BW,CONN,WEIGHTS) computes the discrete distance transform on the
 * input binary image BW.  Specifically, it computes the distance to the nearest 
 * zero-valued pixel.  The distance between two pixels is constrained to lie along
 * a path that joins neighboring pixels according to the connectivity specified by
 * CONN.  The distance between two neighboring pixel centers is given by the corresponding
 * value in the WEIGHTS vector, which should be as long as the number of neighbors
 * specified by CONN.
 * 
 * [D,L] = DDIST(BW,N) returns a linear index array L representing
 * a nearest-neighbor transform.  Each element of L contains the linear index of the 
 * nearest nonzero pixel of BW.
 */

/*
 * Copyright 1993-2003 The MathWorks, Inc.
 * $Revision: 1.1.6.2 $  $Date: 2003/05/03 17:51:47 $
 */

static char rcsid[] = "$Id";

#include "neighborhood.h"
#include "mex.h"

/*
 * discrete_distance
 * Compute discrete distance transform and nearest-neighbor transform.
 *
 * Inputs
 * ------
 * bw              - array of pixels from binary image
 * trailing_walker - walker used for first pass, first pixel to last
 * leading_walker  - walker used for second pass, last pixel to first
 * w               - array of distances to neighbors
 * num_elements    - number of elements of bw
 *
 * Outputs
 * -------
 * d               - array of distances
 * labels          - array of nearest-neighbor labels; if NULL, this computation
 *                   is not performed.
 */
void discrete_distance(mxLogical *bw, NeighborhoodWalker_T trailing_walker,
                       NeighborhoodWalker_T leading_walker, double *w,
                       int num_elements, double *d, double *labels)
{
    double inf = mxGetInf();
    int p;
    int q;
    int idx;
    double this_label;
    bool do_labels = (labels != NULL);
    double minvalue;
    double newvalue;

    /*
     * Initialize the distance and labels arrays.  The initial distance
     * corresponding to any one-valued element of bw is 0; the initial
     * distance for all other locations is Inf.  The initial label
     * corresponding to any one-valued element of bw is the linear
     * index of that element (plus 1 for 1-based indexing).  The initial
     * label for all other elements is 0.
     */
    for (p = 0; p < num_elements; p++)
    {
        if (bw[p] != 0)
        {
            d[p] = 0.0;
            if (do_labels)
            {
                labels[p] = (double) p + 1.0;  /* 1-based indexing */
            }
        }
        else
        {
            d[p] = inf;
        }
    }

    /*
     * First pass, scan from upper left to lower right along columns.
     */
    for (p = 0; p < num_elements; p++)
    {
        /*
         * Find the minimum of d[q]+w[q] for all q
         * in the trailing neighborhood. The label
         * stored in the location that minimizes 
         * d[q]+w[q] is the label that we will propagate
         * to location p.
         */
        if (do_labels)
        {
            this_label = labels[p];
        }
        minvalue = inf;
        nhSetWalkerLocation(trailing_walker, p);
        while (nhGetNextInboundsNeighbor(trailing_walker, &q, &idx))
        {
            newvalue = d[q] + w[idx];
            if (newvalue < minvalue)
            {
                minvalue = newvalue;
                if (do_labels)
                {
                    this_label = labels[q];
                }
            }
        }
        d[p] = minvalue;
        if (do_labels)
        {
            labels[p] = this_label;
        }
    }

    /*
     * Second pass, scan from lower right to upper left along columns.
     */
    for (p = num_elements - 1; p >= 0; p--)
    {
        /*
         * Find the minimum of d[q]+w[q] for all q
         * in the leading neighborhood. The label
         * stored in the location that minimizes 
         * d[q]+w[q] is the label that we will propagate
         * to lcoation p.
         */
        minvalue = d[p];
        if (do_labels)
        {
            this_label = labels[p];
        }
        nhSetWalkerLocation(leading_walker, p);
        while (nhGetNextInboundsNeighbor(leading_walker, &q, &idx))
        {
            newvalue = d[q] + w[idx];
            if (newvalue < minvalue)
            {
                minvalue = newvalue;
                if (do_labels)
                {
                    this_label = labels[q];
                }
            }
        }
        d[p] = minvalue;
        if (do_labels)
        {
            labels[p] = this_label;
        }
    }
}


extern "C"
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    Neighborhood_T nhood;
    NeighborhoodWalker_T trailing_walker;
    NeighborhoodWalker_T leading_walker;
    int num_dims;
    const int *input_size;
    mxArray *D_array;
    mxArray *Label_array;
    const mxArray *BW_array;
    const mxArray *Conn_array;
    const mxArray *Weights_array;
    mxLogical *bw;
    double *d;
    double *w;
    double *labels = NULL;
    
    if (nrhs != 3)
    {
        mexErrMsgIdAndTxt("Images:ddist:wrongNumberOfInputs",
                          "DDIST requires three input arguments.");
    }

    BW_array = prhs[0];
    Conn_array = prhs[1];
    Weights_array = prhs[2];

    num_dims = mxGetNumberOfDimensions(BW_array);
    input_size = mxGetDimensions(BW_array);

    D_array = mxCreateNumericArray(num_dims, input_size, mxDOUBLE_CLASS, mxREAL);

    d = (double *) mxGetData(D_array);
    bw = mxGetLogicals(BW_array);
    w = (double *) mxGetData(Weights_array);

    nhood = nhMakeNeighborhood(Conn_array,NH_CENTER_MIDDLE_ROUNDDOWN);
    trailing_walker = nhMakeNeighborhoodWalker(nhood, input_size, num_dims, 
                                      NH_SKIP_LEADING);
    leading_walker = nhMakeNeighborhoodWalker(nhood, input_size, num_dims, 
                                      NH_SKIP_TRAILING);
    nhDestroyNeighborhood(nhood);

    if (nlhs > 1)
    {
        Label_array = mxCreateNumericArray(num_dims, input_size, mxDOUBLE_CLASS, mxREAL);
        labels = (double *) mxGetData(Label_array);
    }

    discrete_distance(bw, trailing_walker, leading_walker, w, 
                      mxGetNumberOfElements(BW_array), d, labels);
    
    plhs[0] = D_array;
    if (nlhs > 1)
    {
        plhs[1] = Label_array;
    }
    
    nhDestroyNeighborhoodWalker(trailing_walker);
    nhDestroyNeighborhoodWalker(leading_walker);
}

    
    
    
    
