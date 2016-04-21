/* Copyright 1993-2003 The MathWorks, Inc. */
/* $Revision: 1.3.4.1 $ $Date: 2003/01/26 06:00:33 $ */

#ifndef IMTRANSFORM_H
#define IMTRANSFORM_H

#include "mex.h"

/*
 * User error messages
 */
#define ERR_INPUT_NOT_A_STRUCT "Second input argument must be a tform structure."
#define ERR_PIECEWISELINEAR_TDATA_BAD "PiecewiseLinearTData must be a 3-by-2-by-T double matrix."
#define ERR_PIECEWISELINEAR_TDATA_NANINF "PiecewiseLinearTData must not contain NaN or Inf."
#define ERR_TRIANGLES_BAD "Triangles must be a T-by-3 double matrix."
#define ERR_TRIANGLES_NANINF "Triangles must not contain NaN or Inf."
#define ERR_TRIANGLES_INT "Triangles must contain integers between 1 and V."
#define ERR_CONTROLPOINTS_BAD "ControlPoints must be an M-by-2 double matrix."
#define ERR_CONTROLPOINTS_NANINF "ControlPoints must not contain NaN or Inf."
#define ERR_TRIANGLEGRAPH_BAD "TriangleGraph must be a sparse T-by-M matrix."
#define ERR_ONHULL_BAD "OnHull must be an M-by-1 double matrix."
#define ERR_ONHULL_NANINF "OnHull must not contain NaN or Inf."
#define ERR_ONHULL_BINARY "OnHull must contain only zeros and ones."
#define ERR_LWM_TDATA_BAD "LWMTData must be a 6-by-2-by-M double matrix."
#define ERR_LWM_TDATA_NANINF "LWMTData must not contain NaN or Inf."
#define ERR_RADIIOFINFLUENCE_BAD "RadiiOfInfluence must be an M-by-1 double matrix."
#define ERR_RADIIOFINFLUENCE_NANINF "RadiiOfInfluence must not contain NaN or Inf."
#define ERR_RADIIOFINFLUENCE_NEG "RadiiOfInfluence must contain only positive numbers."
#define WARN_LWM_HOLE "Cannot evaluate LWM transformation at some output locations \n which are beyond the RadiiOfInfluence of control point polynomials.\n Try spreading control points more uniformly over image."
#define ERR_TOO_FEW_INPUTS "Too few input arguments."
#define ERR_TOO_MANY_INPUTS "Too many input arguments."
#define ERR_X_BAD "X must be a real 2-D double matrix."
#define ERR_X_NANINF "X must contain only finite values."
#define ERR_T_BAD "T must be a TFORM structure."
    
#endif /* IMTRANSFORM_H */
