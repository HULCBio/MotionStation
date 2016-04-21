/*
 * Copyright 1993-2003 The MathWorks, Inc.
 * $Revision $  $Date: 2003/08/01 18:09:29 $
 */

/*
 * neighborhood.c is a module that supports arbitrary-dimensional
 * neighborhood operations (such as the various morphology functions)
 * in the Image Processing Toolbox.
 *
 * It implements two types of objects: the neighborhood (Neighborhood_T), 
 * and the neighborhood walker (NeighborhoodWalker_T).  The neighborhood
 * contains a list of arbitrary-dimensional relative neighbor offsets
 * that defines the domain of a neighborhood with respect to a given
 * pixel location.
 *
 * Typical use scenario
 * ====================
 * Suppose I is a pointer to the beginning of the image array.  We
 * want to loop over all the pixels in I; for each pixel we want
 * to loop over all the inbounds neighbors and do something with
 * the pixel value for each neighbor.  D is an mxArray specifying
 * the domain of the neighborhood (see help for ORDFILT2 for more info).
 * Furthermore, when we loop over each neighbor of a pixel, we want 
 * to skip the pixel itself, whether or not the center value of D is 1.
 *
 * nhood = nhMakeNeighborhood(D,NH_CENTER_MIDDLE_ROUNDDOWN);
 * walker = nhMakeNeighborhoodWalker(nhood, input_size, input_ndims,
 *                                   NH_SKIP_CENTER);
 *
 * for (p = 0; p < num_elements; p++)
 * {
 *     nhSetWalkerLocation(walker, p);
 *     while (nhGetNextInboundsNeighbor(walker, &q, NULL))
 *     {
 *         I[q] <-- value of the neighbor pixel
 *     }
 * }
 */

#include "neighborhood.h"
#include "iptutil.h"
#include "mex.h"

static char rcsid[] = "$Id: neighborhood.cpp,v 1.1.6.3 2003/08/01 18:09:29 batserve Exp $";

/*
 * ind_to_sub
 * Convert from linear index to array coordinates.  This is similar
 * to MATLAB's IND2SUB function, except that here it's zero-based
 * instead of one-based.  This algorithm used here is adapted from
 * ind2sub.m.
 *
 * Inputs
 * ======
 * p        - zero-based linear index
 * num_dims - number of dimensions
 * size     - image size (ind_to_sub must be computed with respect
 *            to a known image size)
 *
 * Output
 * ======
 * coords   - array of array coordinates
 */
void ind_to_sub(int p, int num_dims, const int size[],
                int *cumprod, int *coords)
{
    int j;

    mxAssert(num_dims > 0, "");
    mxAssert(coords != NULL, "");
    mxAssert(cumprod != NULL, "");
    
    for (j = num_dims-1; j >= 0; j--)
    {
        coords[j] = p / cumprod[j];
        p = p % cumprod[j];
    }
}

/*
 * sub_to_ind
 * Convert from array coordinates to linear index.  This is similar
 * to MATLAB's SUB2IND function, except that here it's zero-based
 * instead of one-based.  The algorithm used here is adapted from
 * sub2ind.m.
 *
 * Inputs
 * ======
 * coords    - array of array coordinates
 * size      - image size (linear index has to be computed with
 *             respect to a known image size)
 * cumprod   - cumulative product of image size
 * num_dims  - number of dimensions
 *
 * Return
 * ======
 * zero-based linear index
 */
int32_T sub_to_ind(int32_T *coords, int32_T *cumprod, int32_T num_dims)
{
    int index = 0;
    int k;

    mxAssert(coords != NULL, "");
    mxAssert(cumprod != NULL, "");
    mxAssert(num_dims > 0, "");
    
    for (k = 0; k < num_dims; k++)
    {
        index += coords[k] * cumprod[k];
    }

    return index;
}

/*
 * sub_to_relative_ind
 * Compute linear relative offset when given relative array
 * offsets.
 *
 * Inputs
 * ======
 * coords   - array of relative array offsets
 * num_dims - number of dimensions
 *
 * Return
 * ======
 * relative linear offset
 */
int sub_to_relative_ind(int32_T *coords, int32_T num_dims)
{
    int N;
    int P;
    int abs_coord;
    int cumprod = 1;
    int index = 0;
    int k;

    mxAssert(num_dims > 0, "");
    mxAssert(coords != NULL, "");

    /*
     * Algorithm notes:
     * We want to compute sub_to_ind and see if ind > 0.  However,
     * the output of sub_to_ind is only valid if the specified neighbor
     * is guaranteed to be within the image, as defined by the size
     * used in the sub_to_ind computation.  Hence, we imagine we are
     * computing sub_to_ind on a neighbor of the center pixel of a
     * P-by-P-by- ... -by-P array, where P = 2*N+1, and N is the maximum
     * absolute neighbor offset.  This guarantees the validity of the
     * sub_to_ind computation.
     */

    /*
     * Find the maximum absolute neighbor offset.
     */
    N = 0;
    for (k = 0; k < num_dims; k++)
    {
        abs_coord = coords[k] > 0 ? coords[k] : -coords[k];
        if (abs_coord > N)
        {
            N = abs_coord;
        }
    }
    P = 2*N + 1;

    /*
     * Perform sub_to_ind computation.
     */
    for (k = 0; k < num_dims; k++)
    {
        index += coords[k] * cumprod;
        cumprod *= P;
    }

    return index;
}


/*
 * is_leading_neighbor
 * Is a given neighbor reached before the center pixel in a linear
 * scan of image pixels?
 *
 * Inputs
 * ======
 * coords   - array of neighborhood offset coordinates
 * num_dims - number of dimensions
 *
 * Return
 * ======
 * true/false
 */
static
bool is_leading_neighbor(int32_T *coords, int32_T num_dims)
{
    
    return (sub_to_relative_ind(coords, num_dims) > 0);
}

/*
 * is_trailing_neighbor
 * Is a given neighbor reached after the center pixel in a linear
 * scan of image pixels?
 *
 * Inputs
 * ======
 * coords   - array of neighborhood offset coordinates
 * num_dims - number of dimensions
 *
 * Return
 * ======
 * true/false
 */
static
bool is_trailing_neighbor(int32_T *coords, int32_T num_dims)
{
    return (sub_to_relative_ind(coords, num_dims) < 0);
}

/*
 * is_neighborhood_center
 * Is a given neighbor the neighborhood center?
 *
 * Inputs
 * ======
 * coords   - array of neighborhood offset coordinates
 * num_dims - number of dimensions
 *
 * Return
 * ======
 * true if specified neighbor is the neighborhood center; false otherwise
 */
static
bool is_neighborhood_center(int *coords, int num_dims)
{
    int k;
    bool result = true;

    mxAssert(num_dims > 0, "");
    mxAssert(coords != NULL, "");
    
    for (k = 0; k < num_dims; k++)
    {
        if (coords[k] != 0)
        {
            result = false;
            break;
        }
    }
    
    return result;
}

/*
 * allocate_neighborhood
 * Allocate space for new neighborhood object
 *
 * Inputs
 * ======
 * num_neighbors  - number of neighbors
 * num_dims       - number of dimensions
 *
 * Return
 * ======
 * new neighborhood object
 */
Neighborhood_T allocate_neighborhood(int num_neighbors, int num_dims)
{
    Neighborhood_T result;

    mxAssert(num_neighbors >= 0, "");
    mxAssert(num_dims > 0, "");
    
    result = (Neighborhood_T) mxCalloc(1, sizeof(*result));
    result->array_coords = (int32_T *) mxCalloc(num_neighbors * num_dims,
                                         sizeof(*(result->array_coords)));
    result->num_neighbors = num_neighbors;
    result->num_dims = num_dims;

    return result;
}

/*
 * create_neighborhood_special_2d
 * Create 2-D neighborhood with 4 or 8 neighbors.
 *
 * Input
 * =====
 * code  - either 4 or 8.
 *
 * Return
 * ======
 * new neighborhood object
 */
static
Neighborhood_T create_neighborhood_special_2d(int code)
{
    Neighborhood_T result;
    int r;
    int c;
    int max;
    int sum;
    int p;
    int num_dims = 2;
    int num_neighbors = code + 1; /* + 1 because of center pixel */
    int count;

    switch (code)
    {
    case 4:
        /*
         * Use only edge-connected neighbors
         */
        max = 1;
        break;
        
    case 8:
        /*
         * Use edge- or vertex-connected neighbors
         */
        max = 2;
        break;
        
    default:
        mxAssert(false,"");
    }

    result = allocate_neighborhood(num_neighbors, num_dims);
    count = 0;
    for (c = -1; c <= 1; c++)
    {
        for (r = -1; r <= 1; r++)
        {
            /*
             * sum == 1 implies edge-connected
             * sum == 2 implies edge- or vertex-connected
             */
            sum = (r != 0) + (c != 0);
            if (sum <= max)
            {
                p = count*num_dims;
                (result->array_coords)[p] = r;
                (result->array_coords)[p + 1] = c;
                count++;
            }
        }
    }
    mxAssert(count == num_neighbors,"");

    return result;
}

/*
 * create_neighborhood_special_3d
 * Create 3-D neighborhood with 6, 18, or 26 neighbors.
 *
 * Input
 * =====
 * code  - either 6, 18, or 26
 *
 * Return
 * ======
 * new neighborhood object
 */
static
Neighborhood_T create_neighborhood_special_3d(int code)
{
    Neighborhood_T result;
    int r;
    int c;
    int z;
    int max;
    int sum;
    int p;
    int num_dims = 3;
    int num_neighbors = code + 1; /* +1 because of the center pixel */
    int count;

    switch (code)
    {
    case 6:
        /* Face-connected neighbors only */
        max = 1;
        break;
        
    case 18:
        /* Face- or edge-connected neighbors */
        max = 2;
        break;
        
    case 26:
        /* Face-, edge-, or vertex-connected neighbors */
        max = 3;
        break;
        
    default:
        mxAssert(false,"");
    }

    result = allocate_neighborhood(num_neighbors, num_dims);
    count = 0;
    for (z = -1; z <= 1; z++)
    {
        for (c = -1; c <= 1; c++)
        {
            for (r = -1; r <= 1; r++)
            {
                /*
                 * sum == 1 implies face-connected
                 * sum == 2 implies edge-connected
                 * sum == 3 implies vertex-connected
                 */
                sum = (r != 0) + (c != 0) + (z != 0);
                if (sum <= max)
                {
                    p = count*num_dims;
                    (result->array_coords)[p] = r;
                    (result->array_coords)[p + 1] = c;
                    (result->array_coords)[p + 2] = z;
                    count++;
                }
            }
        }
    }
    mxAssert(count == num_neighbors,"");
    
    return result;
}

/*
 * create_neighborhood_special
 * Create 4- or 8-connected 2-D neighborhood, or create
 * 6-, 18-, or 26-connected 3-D neighborhood.
 *
 * Input
 * =====
 * code - either 4, 8, 6, 18, or 26
 *
 * Return
 * ======
 * new neighborhood object
 */
static
Neighborhood_T create_neighborhood_special(int code)
{
    Neighborhood_T result;

    if ((code == 4) || (code == 8))
    {
        result = create_neighborhood_special_2d(code);
    }
    else if ((code == 6) || (code == 18) || (code == 26))
    {
        result = create_neighborhood_special_3d(code);
    }
    else
    {
        mxAssert(false,"");
    }

    return result;
}

/*
 * num_nonzeros
 * Count nonzero elements of real part of double-precision mxArray.
 *
 * Inputs
 * ======
 * D - mxArray, numeric or logical
 *
 * Return
 * ======
 * number of nonzero elements of real part of D.
 */
int num_nonzeros(const mxArray *D)
{
    int p;
    int num_elements;
    void *pr;
    int count = 0;
    mxClassID array_class;

    mxAssert(D != NULL,"");

    num_elements = mxGetNumberOfElements(D);
    if (mxIsLogical(D))
    {
        pr = mxGetLogicals(D);
    }
    else
    {
        pr = mxGetData(D);
    }
    array_class = mxGetClassID(D);
    
    switch(array_class)
    {
      case(mxLOGICAL_CLASS):
      case(mxUINT8_CLASS):
      {
          uint8_T *npr = (uint8_T *)pr;
          for (p = 0; p < num_elements; p++)
          { 
              if (*npr) count++; npr++; 
          }
          break;
      }
      case(mxINT8_CLASS):
      {
          int8_T *npr = (int8_T *)pr;
          for (p = 0; p < num_elements; p++)
          { 
              if (*npr) count++; npr++; 
          }
          break;
      }
      case(mxUINT16_CLASS):
      {
          uint16_T *npr = (uint16_T *)pr;
          for (p = 0; p < num_elements; p++)
          { 
              if (*npr) count++; npr++; 
          }
          break;
      }
      case(mxINT16_CLASS):
      {
          int16_T *npr = (int16_T *)pr;
          for (p = 0; p < num_elements; p++)
          { 
              if (*npr) count++; npr++; 
          }
          break;
      }
      case(mxUINT32_CLASS):
      {
          uint32_T *npr = (uint32_T *)pr;
          for (p = 0; p < num_elements; p++)
          { 
              if (*npr) count++; npr++; 
          }
          break;
      }
      case(mxINT32_CLASS):
      {
          int32_T *npr = (int32_T *)pr;
          for (p = 0; p < num_elements; p++)
          { 
              if (*npr) count++; npr++; 
          }
          break;
      }
      case(mxSINGLE_CLASS):
      {
          float *npr = (float *)pr;
          for (p = 0; p < num_elements; p++)
          { 
              if (*npr) count++; npr++; 
          }
          break;
      }
      case(mxDOUBLE_CLASS):
      {
          double *npr = (double *)pr;
          for (p = 0; p < num_elements; p++)
          { 
              if (*npr) count++; npr++; 
          }
          break;
      }
      default:
        //Should never get here
        mexErrMsgIdAndTxt("Images:neighborhood:unsupportedDataType", "%s",
                          "Unsupported data type.");
        break;
    }
    
    return count;
}

/*
 * create_neighborhood_general
 * Create neighborhood from general form of connectivity array.
 *
 * Input
 * =====
 * D - connectivity array, general form
 *
 * center_location - The location of the center of the neighborhood
 *                   Possible values:
 *                   NH_CENTER_MIDDLE_ROUNDDOWN - center in the middle
 *                                                round even dimensions down
 *                   NH_CENTER_MIDDLE_ROUNDUP   - center in the middle
 *                                                round even dimensions up
 *                   NH_CENTER_UL               - center in the upper left
 *                   NH_CENTER_LR               - center in the lower right
 *
 * Return
 * ======
 * new neighborhood object.
 */
static
Neighborhood_T create_neighborhood_general(const mxArray *D,
                                           int center_location)
{
    void *pr;
    mxClassID array_class;
    Neighborhood_T result = NULL;

    mxAssert(D != NULL, "");

    pr = mxIsLogical(D) ? mxGetLogicals(D) : mxGetData(D);
    array_class = mxGetClassID(D);

    switch(array_class)
    {
      case(mxLOGICAL_CLASS):
      case(mxUINT8_CLASS):
        result = create_neighborhood_general_template
            ((uint8_T *)pr, D, center_location);
        break;

      case(mxINT8_CLASS):
        result = create_neighborhood_general_template
            ((int8_T *)pr, D, center_location);
        break;

      case(mxUINT16_CLASS):
        result = create_neighborhood_general_template
            ((uint16_T *)pr, D, center_location);
        break;

      case(mxINT16_CLASS):
        result = create_neighborhood_general_template
            ((int16_T *)pr, D, center_location);
        break;

      case(mxUINT32_CLASS):
        result = create_neighborhood_general_template
            ((uint32_T *)pr, D, center_location);
        break;

      case(mxINT32_CLASS):
        result = create_neighborhood_general_template
            ((int32_T *)pr, D, center_location);
        break;

      case(mxSINGLE_CLASS):
        result = create_neighborhood_general_template
            ((float *)pr, D, center_location);
        break;

      case(mxDOUBLE_CLASS):
        result = create_neighborhood_general_template
            ((double *)pr, D, center_location);
        break;

      default:
        //Should never get here
        mexErrMsgIdAndTxt("Images:neighborhood:unsupportedDataType", "%s",
                          "Unsupported data type.");
        break;
    }

    return(result);
}

static double valid_scalars[] = {0.0, 1.0, 4.0, 6.0, 8.0, 18.0, 26.0};
static int num_valid_scalars = sizeof(valid_scalars) / sizeof(double);

/*
 * nhCheckConnectivityDomain
 * Make sure connectivity array is valid.
 *
 * Input
 * =====
 * D   - connectivity array
 *
 * If D is invalid, this function does not return; instead it 
 * throws a MATLAB error.
 */
void nhCheckConnectivityDomain(const mxArray *D,
                               const char *function_name,
                               const char *variable_name,
                               int argument_position)
{
    double scalar;
    int num_elements;
    const int *size;
    int num_dims;
    double *pr;
    int k;
    bool found;

    int nrhs = 4;
    int nlhs = 0;
    mxArray *prhs[4];
    mxArray *plhs[1];
    
    plhs[0] = NULL;
    
    prhs[0] = (mxArray *) D;
    prhs[1] = mxCreateString(function_name);
    prhs[2] = mxCreateString(variable_name);
    prhs[3] = mxCreateDoubleScalar((double) argument_position);
    
    mexCallMATLAB(nlhs, plhs, nrhs, prhs, "checkconn");
    
    mxDestroyArray(prhs[1]);
    mxDestroyArray(prhs[2]);
    mxDestroyArray(prhs[3]);

    if (plhs[0] != NULL)
    {
        mxDestroyArray(plhs[0]);
    }
}


/*
 * nhCheckDomain
 * Make sure domain array is valid.
 *
 * Input
 * =====
 * D   - domain array
 *
 * If D is invalid, this function does not return; instead it 
 * throws a MATLAB error.
 */
void nhCheckDomain(const mxArray *D)
{
    int num_elements;
    double *pr;
    int k;
    bool found;
    double scalar;

    mxAssert(D != NULL, "");
    num_elements = mxGetNumberOfElements(D);
    
    if (!mxIsDouble(D) || mxIsComplex(D))
    {
        mexErrMsgIdAndTxt("Images:neighborhood:domainMustBeRealDoubleArray",
                          "%s", "DOMAIN must be a real double array.");
    }

    if (mxIsSparse(D))
    {
        mexErrMsgIdAndTxt("Images:neighborhood:domainMustBeNonsparse", 
                          "%s","DOMAIN must not be sparse.");
    }

    if (mxGetNumberOfElements(D) == 1)
    {
        found = false;
        scalar = mxGetScalar(D);
        for (k = 0; k < num_valid_scalars; k++)
        {
            if (scalar == valid_scalars[k])
            {
                found = true;
                break;
            }
        }
        if (! found)
        {
            mexErrMsgIdAndTxt("Images:neighborhood:invalidScalarDomain", 
                              "%s","If DOMAIN is a scalar,"
                              " it must be 0, 1, 4, 6, 8, 18, or 26.");
        }
    }
    else
    {
        pr = mxGetPr(D);
        for (k = 0; k < num_elements; k++)
        {
            if ((pr[k] != 0.0) && (pr[k] != 1.0))
            {
                mexErrMsgIdAndTxt("Images:neighborhood:invalidDomain", 
                                  "%s","DOMAIN can contain only 0s and 1s.");
            }
        }
    }
}

/*
 * nhMakeNeighborhood
 * Make neighborhood object.
 *
 * Input
 * =====
 * D - Connectivity array.  In its most general form, D can be
 *     an N-D array of 0s and 1s.  The 1s indicate members of the
 *     neighborhood, relative to the center of D (rounded to 
 *     the upper left).  D can also be one of these scalars:
 *     4  - 2-D neighborhood, neighbors connected to center by an edge
 *     8  - 2-D neighborhood, neighbors connected to center by an edge
 *          or a vertex
 *     6  - 3-D neighborhood, neighbors connected to center by a face
 *     18 - 3-D neighborhood, neighbors connected to center by a face
 *          or an edge
 *     26 - 3-D neighborhood, neighbors connected to center by a face,
 *          edge, or vertex
 *
 *     center_location - The location of the center of the neighborhood
 *                   Possible values:
 *                   NH_CENTER_MIDDLE_ROUNDDOWN - center in the middle
 *                                                round even dimensions down
 *                   NH_CENTER_MIDDLE_ROUNDUP   - center in the middle
 *                                                round even dimensions up
 *                   NH_CENTER_UL               - center in the upper left
 *                   NH_CENTER_LR               - center in the lower right

 * Return
 * ======
 * new Neighborhood_T object.
 */
Neighborhood_T nhMakeNeighborhood(const mxArray *D,int center_location)
{
    Neighborhood_T result;
    int scalar;

    mxAssert(D != NULL, "");

    if (mxGetNumberOfElements(D) == 1)
    {
        scalar = (int) mxGetScalar(D);
        if ((scalar == 0.0) || (scalar == 1.0))
        {
            /*
             * This is really the general case, although
             * degenerate.
             */
            result = create_neighborhood_general(D,center_location);
        }
        else
        {
            result = create_neighborhood_special(scalar);
        }
    }
    else
    {
        result = create_neighborhood_general(D,center_location);
    }

    return result;
}

/*
 * nhMakeDefaultConnectivityNeighborhood
 * Make neighborhood corresponding to DOMAIN = ones(repmat(3,1,num_dims)).
 *
 * Inputs
 * ======
 * num_dims      - number of dimensions
 *
 * Return
 * ======
 * Neighborhood_T object.
 */
Neighborhood_T nhMakeDefaultConnectivityNeighborhood(int32_T num_dims)
{
    Neighborhood_T result;
    int *size;
    int *cumprod;
    int num_neighbors;
    int k;
    int q;
    int *coords;

    num_neighbors = 1;
    size = (int *)mxMalloc(num_dims * sizeof(*size));
    cumprod = (int *)mxMalloc(num_dims * sizeof(*cumprod));
    for (k = 0; k < num_dims; k++)
    {
        size[k] = 3;
        cumprod[k] = num_neighbors;
        num_neighbors *= 3;
    }
    
    result = allocate_neighborhood(num_neighbors, num_dims);
    for (k = 0; k < num_neighbors; k++)
    {
        coords = result->array_coords + k*num_dims;
        ind_to_sub(k, num_dims, size, cumprod, coords);
        for (q = 0; q < num_dims; q++)
        {
            coords[q] -= 1;
        }
    }
    
    mxFree(size);
    mxFree(cumprod);
    
    return result;
}

/*
 * nhReflectNeighborhood
 * Negate all neighborhood offset values
 *
 * Input
 * =====
 * nhood - neighborhood object (modified)
 */
void nhReflectNeighborhood(Neighborhood_T nhood)
{
    int32_T *coords = nhood->array_coords;
    int32_T num_values = nhood->num_neighbors * nhood->num_dims;
    int k;
    
    for (k = 0; k < num_values; k++)
    {
        coords[k] = -coords[k];
    }
}

/*
 * nhDestroyNeighborhood
 * Free space associated with neighborhood object
 *
 * Input
 * =====
 * nhood - neighborhood object (modified)
 */
void nhDestroyNeighborhood(Neighborhood_T nhood)
{
    mxFree(nhood->array_coords);
    mxFree(nhood);
}

/*
 * allocate_neighborhood_walker
 * Allocate space for NeighborhoodWalker_T object.
 *
 * Inputs
 * ======
 * num_neighbors - number of neighbors in the neighborhood
 * num_dims      - number of dimensions
 *
 * Return
 * ======
 * NeighborhoodWalker_T object.
 */
static
NeighborhoodWalker_T allocate_neighborhood_walker(int num_neighbors, 
                                                  int num_dims)
{
    NeighborhoodWalker_T walker;
    
    walker = (NeighborhoodWalker_T) mxMalloc(sizeof(*walker));
    walker->array_coords = (int32_T *) mxMalloc(num_neighbors*num_dims *
                                                sizeof(int32_T));
    walker->neighbor_offsets = (int32_T *) mxMalloc(num_neighbors * 
                                                    sizeof(int32_T));
    walker->image_size = (int32_T *) mxMalloc(num_dims * sizeof(int32_T));
    walker->cumprod = (int32_T *) mxMalloc((num_dims+1)* sizeof(int32_T));
    walker->center_coords = (int32_T *) mxMalloc(num_dims * sizeof(int32_T));
    walker->use = (bool *) mxMalloc(num_neighbors * sizeof(bool));

    /*
     * Set the pixel offset to be negative. An assertion in 
     * nhGetNextInboundsNeighbor will guarantee that nhSetWalkerLocation
     * gets called first.
     */
    walker->pixel_offset = -1;
    
    return walker;
}

/*
 * process_walker_flags
 * Mark certain neighbors to be skipped according to the settings
 * of the options flags.
 *
 * Inputs
 * ======
 * walker   - NeighborhoodWalker_T object (modified)
 * flags    - Binary OR of any combination of
 *            NH_SKIP_LEADING, NH_SKIP_TRAILING, or NH_SKIP_CENTER
 */
static
void process_walker_flags(NeighborhoodWalker_T walker, unsigned int flags)
{
    int k;
    int *pr;
    int num_dims;
    bool skip_center;
    bool skip_leading;
    bool skip_trailing;

    mxAssert(walker != NULL, "");
    
    num_dims = walker->num_dims;
    skip_center = flags & NH_SKIP_CENTER;
    skip_leading = flags & NH_SKIP_LEADING;
    skip_trailing = flags & NH_SKIP_TRAILING;
    
    for (k = 0; k < walker->num_neighbors; k++)
    {
        pr = walker->array_coords + k * walker->num_dims;
        if ((skip_leading && is_leading_neighbor(pr, num_dims)) ||
            (skip_trailing && is_trailing_neighbor(pr, num_dims)) ||
            (skip_center && is_neighborhood_center(pr, num_dims)))
        {
            walker->use[k] = false;
        }
    }
}

/*
 * nhMakeNeighborhoodWalker
 * Make neighborhood walker object.
 *
 * Inputs
 * ======
 * nhood       - Neighborhood_T object
 * input_size  - array of image dimensions
 * input_dims  - number of image dimensions
 * flags       - options flags; see below
 *
 * Return
 * ======
 * NeighborhoodWalker_T object
 *
 * Options values include:
 * NH_SKIP_CENTER     - walker will the center pixel itself
 * NH_SKIP_LEADING    - walker will skip neighbors that precede
 *                      the center pixel in a linear scan of pixels
 * NH_SKIP_TRAILING   - walker will skip neighbors that follow
 *                      the center pixel in a linear scan of pixels
 *
 * Options values can be OR'd together.  For example, if flags is
 * NH_SKIP_CENTER | NH_SKIP_LEADING, then both the center pixel
 * and leading neighbors will be skipped.
 */
NeighborhoodWalker_T nhMakeNeighborhoodWalker(Neighborhood_T nhood,
                                              const int input_size[],
                                              int num_input_dims,
                                              unsigned int flags)
{
    int num_dims;
    NeighborhoodWalker_T walker;
    int num_neighbors = nhood->num_neighbors;
    int k;
    int *pr_in;
    int *pr_out;
    int p;

    /*
     * The dimensionality of the walker is either the image dimensionality
     * or the neighborhood dimensionality, whichever is greater.
     */
    if (num_input_dims > nhood->num_dims)
    {
        num_dims = num_input_dims;
    }
    else
    {
        num_dims = nhood->num_dims;
    }
    
    walker = allocate_neighborhood_walker(num_neighbors, num_dims);
    walker->num_neighbors = num_neighbors;
    walker->num_dims = num_dims;

    for (k = 0; k < num_neighbors; k++)
    {
        pr_in = nhood->array_coords + k*nhood->num_dims;
        pr_out = walker->array_coords + k*walker->num_dims;
        for (p = 0; p < nhood->num_dims; p++)
        {
            pr_out[p] = pr_in[p];
        }

        /*
         * The next loop will only be entered if the image
         * has higher dimensionality than the neighborhood; in this case
         * the neighborhood offsets along those higher dimensions
         * are all 0.
         */
        for (p = nhood->num_dims; p < walker->num_dims; p++)
        {
            pr_out[p] = 0;
        }
    }

    for (k = 0; k < num_input_dims; k++)
    {
        walker->image_size[k] = input_size[k];
    }
    /*
     * If the neighborhood has higher dimensionality than the
     * input image, the image size along all those higher
     * dimensions is 1.
     */
    for (k = num_input_dims; k < walker->num_dims; k++)
    {
        walker->image_size[k] = 1;
    }

    walker->cumprod[0] = 1;
    for (k = 1; k <= walker->num_dims; k++)
    {
        walker->cumprod[k] = walker->cumprod[k-1] * 
            walker->image_size[k-1];
    }
    
    for (k = 0; k < num_neighbors; k++)
    {
        pr_in = walker->array_coords + k*walker->num_dims;
        walker->neighbor_offsets[k] = sub_to_ind(pr_in, walker->cumprod,
                                                 walker->num_dims);
    }

    for (k = 0; k < num_neighbors; k++)
    {
        walker->use[k] = true;
    }

    process_walker_flags(walker, flags);
    
    return walker;
}

/*
 * nhSetWalkerLocation
 * Prepare to walk the neighborhood surrounding a specified pixel.
 *
 * Inputs
 * ======
 * walker   - neighborhood walker; this input is modified
 * p        - pixel location, specified as a linear offset from
 *            the beginning of the image array
 */
void nhSetWalkerLocation(NeighborhoodWalker_T walker, int p)
{
    mxAssert(walker != NULL, "");
    mxAssert(p >= 0, "");

    walker->pixel_offset = p;
    ind_to_sub(p, walker->num_dims, walker->image_size, walker->cumprod,
               walker->center_coords);
    walker->next_neighbor_idx = 0;
}

/*
 * is_inbounds_neighbor
 * Given pixel coordinates, offset coordinates for a neighbor, and 
 * image size, is the neighbor inside the image or not?
 *
 * Inputs
 * ======
 * offset_coords - array of neighbor offset coordinates
 * array_coords  - array of pixel coordinates
 * input_size    - array of image dimensions
 * num_dims      - length of the above arrays
 *
 * Return
 * ======
 * true if specified neighbor of specified pixel is within the bounds
 * of the image; false otherwise.
 */
static
bool is_inbounds_neighbor(int *offset_coords, int *array_coords, 
                          const int *input_size, int num_dims)
{
    bool result = true;
    int k;
    int coordinate;

    mxAssert(offset_coords != NULL, "");
    mxAssert(array_coords != NULL, "");
    mxAssert(input_size != NULL, "");
    mxAssert(num_dims >= 2, "");
    
    for (k = 0; k < num_dims; k++)
    {
        coordinate = array_coords[k] + offset_coords[k];
        if ((coordinate < 0) || (coordinate >= input_size[k]))
        {
            result = false;
            break;
        }
    }
    
    return result;
}

/*
 * nhGetNextInboundsNeighbor
 *
 * Gets the next neighbor that isn't outside the image.  Caller must
 * call nhSetWalkerLocation first.
 *
 * Inputs:
 * - walker  NeighborhoodWalker_T; this input is modified
 *
 * Outputs:
 * - p       Neigbhbor location, expressed as a zero-based offset into
 *           the image array
 * - idx     Index of the neighbor, 0 to P-1, where P is the number of 
 *           neighbors in the neighborhood.  idx can be NULL, in which
 *           case this value is not output.
 *
 * Return value:
 * true if successful; false if there were no more neighbors.  If false is 
 * returned then p and idx are not set.
 */
bool nhGetNextInboundsNeighbor(NeighborhoodWalker_T walker, int32_T *p,
                               int32_T *idx)
{
    bool found = false;
    int k;

    mxAssert(walker != NULL, "");
    mxAssert(p != NULL, "");
    mxAssert(walker->pixel_offset >= 0, "");
    
    for (k = walker->next_neighbor_idx; k < walker->num_neighbors; k++)
    {
        if (walker->use[k] &&
            is_inbounds_neighbor(walker->array_coords + k*walker->num_dims,
                                 walker->center_coords, walker->image_size, 
                                 walker->num_dims))
        {
            found = true;
            *p = walker->pixel_offset + walker->neighbor_offsets[k];
            if (idx != NULL)
            {
                *idx = k;
            }
            walker->next_neighbor_idx = k + 1;
            break;
        }
    }

    if (! found)
    {
        /*
         * Make sure this walker can't be used again until
         * nhSetWalkerLocation is called.
         */
        walker->pixel_offset = -1;
    }
        
    return found;
}

/*
 * nhGetWalkerNeighborOffsets
 * Get an array containing linear neighbor offsets, computed
 * with respect to a given image size.
 *
 * Input
 * =====
 * walker - NeighborhoodWalker_T object
 *
 * Return
 * ======
 * offsets - array of array coordinates
 */
int32_T *nhGetWalkerNeighborOffsets(NeighborhoodWalker_T walker)
{
    mxAssert(walker != NULL, "");

    return(walker->neighbor_offsets);
}
 
/*
 * nhDestroyNeighborhoodWalker
 * Free space allocated by walker object.
 *
 * Input
 * =====
 * walker - NeighborhoodWalker_T object (modified)
 *
 */
void nhDestroyNeighborhoodWalker(NeighborhoodWalker_T walker)
{
    mxAssert(walker != NULL, "");
    
    mxFree(walker->array_coords);
    mxFree(walker->neighbor_offsets);
    mxFree(walker->image_size);
    mxFree(walker->cumprod);
    mxFree(walker->center_coords);
    mxFree(walker->use);
    
    mxFree(walker);
}

