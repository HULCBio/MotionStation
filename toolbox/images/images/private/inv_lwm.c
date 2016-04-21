/* $Revision: 1.4.4.2 $ */
/* Copyright 1993-2003 The MathWorks, Inc. */

static char rcsid[] = "$Id: inv_lwm.c,v 1.4.4.2 2003/08/01 18:11:15 batserve Exp $";

#include <math.h>
#include "lwm_piecewiselinear.h"

typedef struct LWMDataType
{
    /*
     * one Reverse polynomial transform per control point, icp:
     *
     *       A0[icp]  B0[icp]
     *       A1[icp]  B1[icp]
     *       A2[icp]  B2[icp]
     *       A3[icp]  B3[icp]
     *       A4[icp]  B4[icp]
     *       A5[icp]  B5[icp]
     */
    double *A0, *A1, *A2, *A3, *A4, *A5;   
    double *B0, *B1, *B2, *B3, *B4, *B5; 
    int    nControlPoints;
    double *xControlPoints, *yControlPoints;
    double *RadiiOfInfluence;
    bool warned;
}
LWMDataType;

static void GetW(double x, double y, LWMDataType *data, double *W) 
{
    int i;
    double dx, dy, dist_to_cp, Ri, Ri2, Ri3;

    for (i=0; i < data->nControlPoints; i++)
    {

        dx = x - data->xControlPoints[i];
        dy = y - data->yControlPoints[i];        
        dist_to_cp = sqrt( dx*dx + dy*dy );

        Ri = dist_to_cp / data->RadiiOfInfluence[i];
        if (Ri >= 1)
            W[i] = 0.0; /* ControlPoint i exerts no influence on (x,y) */
        else
        {
            Ri2 = Ri*Ri;
            Ri3 = Ri*Ri2;
            W[i] = 1.0 - 3.0*Ri2 + 2.0*Ri3; /* weight for ControlPoint i */
        }
    
    }
    
}

static void GetUV(double x, double y, LWMDataType *data,
                  double *W, double *U, double *V) 
{
    int i;
    double xy, x2, y2;

    /* precalculate factors */
    xy = x*y;
    x2 = x*x;
    y2 = y*y;

    for (i=0; i < data->nControlPoints; i++)
    {

        if (W[i] != 0.0)
        {
            U[i] = data->A0[i] + data->A1[i]*x + data->A2[i]*y + 
                data->A3[i]*xy + data->A4[i]*x2 + data->A5[i]*y2;
        
            V[i] = data->B0[i] + data->B1[i]*x + data->B2[i]*y + 
                data->B3[i]*xy + data->B4[i]*x2 + data->B5[i]*y2;
        }
        else
        {
            U[i] = mxGetNaN();
            V[i] = mxGetNaN();
        }
        
    }
    
}
    

/*
 * LWMReverseMapping
 *
 * Given a location in output space (x,y), find the weighted average
 * of the polynomials from all control points that influence (x,y) to
 * compute the corresponding location in input space (u,v).  
 */
static
void LWMReverseMapping(LWMDataType *data,
                       double x, double y,
                       double *u, double *v)
{
    double *W, *U, *V;
    double u_numerator, v_numerator, denominator;
    int i;
   
    W = (double *) mxCalloc(data->nControlPoints,sizeof(double));
    U = (double *) mxCalloc(data->nControlPoints,sizeof(double));
    V = (double *) mxCalloc(data->nControlPoints,sizeof(double));

    u_numerator = 0.0;
    v_numerator = 0.0;    
    denominator = 0.0;

    GetW(x, y, data, W);
    GetUV(x, y, data, W, U, V);

    for (i=0; i < data->nControlPoints; i++)
    {
        if (W[i] != 0.0)
        {
            u_numerator = u_numerator + W[i]*U[i];
            v_numerator = v_numerator + W[i]*V[i];        
            denominator = denominator + W[i];
        }        
    }

    if (denominator!=0.0)
    {
        *u = u_numerator/denominator;
        *v = v_numerator/denominator;        
    }
    else
    {
        /*
         * no control points influence this (x,y) 
         * issue warning, and set warning flag to warn user that there
         * are one or more such points 
         */
        if (! data->warned) {
            mexWarnMsgIdAndTxt("Images:inv_lwm:"
                               "cannotEvaluateTransfAtSomeOutputLocations",
                               "%s",WARN_LWM_HOLE);
            data->warned = true;
        }
        *u = MAX_int32_T - 10; /* subtract 10 as a buffer for interpolation */
        *v = MAX_int32_T - 10; /* methods that need adjacent points         */
    }

    mxFree(W);
    mxFree(U);
    mxFree(V);
    
}

static
void DestroyLWMData(LWMDataType *data)
{
    /*
     *  The lwm data structure contains dynamically allocated memory,
     *  free this first, then free the structure.  
     */

    mxFree(data->A0);
    mxFree(data->A1);
    mxFree(data->A2);
    mxFree(data->A3);
    mxFree(data->A4);
    mxFree(data->A5);
    mxFree(data->B0);
    mxFree(data->B1);
    mxFree(data->B2);
    mxFree(data->B3);
    mxFree(data->B4);
    mxFree(data->B5);
    mxFree(data);
}

/*
 * InitLWMData
 *
 * This function is responsible for filling in the values
 * in the LWMDataType structure.
 *
 */
void InitLWMData(const mxArray *T, LWMDataType *data)
{
    mxArray *Tinv, *ControlPoints, *RadiiOfInfluence;
    double *pr_Tinv = NULL;
    double *pr_Tri = NULL;
    double *pr_CP = NULL;
    double *pr_Radii = NULL;
    int k, nControlPoints;
    const int *dim_Tinv;
    
    Tinv = mxGetField(T,0,"LWMTData");
    if ((Tinv != NULL) && !mxIsEmpty(Tinv))
    {
        dim_Tinv = mxGetDimensions(Tinv);
        nControlPoints = dim_Tinv[2];
        data->nControlPoints = nControlPoints;
        
        /*
         * Tinv must be a real 6-by-2-by-nControlPoints double-precision 
         * matrix.
         */
        if (!mxIsDouble(Tinv) ||
            (mxGetNumberOfDimensions(Tinv) > 3) ||
            (dim_Tinv[0] != 6) ||
            (dim_Tinv[1] != 2) ||
            mxIsComplex(Tinv))
        {
            mexErrMsgIdAndTxt("Images:inv_lwm:badLWMTdata",
                              "%s",ERR_LWM_TDATA_BAD);
        }
        
        pr_Tinv = (double *) mxGetData(Tinv);
        
        /*
         * Tinv must not contain Inf's or NaN's.
         */
        for (k = 0; k < mxGetNumberOfElements(Tinv); k++)
        {
            if (! mxIsFinite(pr_Tinv[k]))
            {
                mexErrMsgIdAndTxt("Images:inv_lwm:lwmTdataHasNansOrInfs",
                                  "%s",ERR_LWM_TDATA_NANINF);
            }
        }
        
        /*
         * Allocate memory for A0,A1,A2,A3,A4,A5 and B0,B1,B2,B3,B4,B5 
         * based on nControlPoints.
         */
        data->A0 = (double *) mxCalloc(nControlPoints,sizeof(double));
        data->A1 = (double *) mxCalloc(nControlPoints,sizeof(double));
        data->A2 = (double *) mxCalloc(nControlPoints,sizeof(double));
        data->A3 = (double *) mxCalloc(nControlPoints,sizeof(double));
        data->A4 = (double *) mxCalloc(nControlPoints,sizeof(double));
        data->A5 = (double *) mxCalloc(nControlPoints,sizeof(double));

        data->B0 = (double *) mxCalloc(nControlPoints,sizeof(double));
        data->B1 = (double *) mxCalloc(nControlPoints,sizeof(double));
        data->B2 = (double *) mxCalloc(nControlPoints,sizeof(double));
        data->B3 = (double *) mxCalloc(nControlPoints,sizeof(double));
        data->B4 = (double *) mxCalloc(nControlPoints,sizeof(double));
        data->B5 = (double *) mxCalloc(nControlPoints,sizeof(double));

        /*
         * Assign Tinv values to reverse mapping variables.
         */
        for (k = 0; k < nControlPoints; k++)
        {

            data->A0[k] = pr_Tinv[0 + k*12];
            data->A1[k] = pr_Tinv[1 + k*12];
            data->A2[k] = pr_Tinv[2 + k*12];
            data->A3[k] = pr_Tinv[3 + k*12];
            data->A4[k] = pr_Tinv[4 + k*12];
            data->A5[k] = pr_Tinv[5 + k*12];

            data->B0[k] = pr_Tinv[6 + k*12];
            data->B1[k] = pr_Tinv[7 + k*12];
            data->B2[k] = pr_Tinv[8 + k*12];
            data->B3[k] = pr_Tinv[9 + k*12];
            data->B4[k] = pr_Tinv[10 + k*12];
            data->B5[k] = pr_Tinv[11 + k*12];

        }
        
    }
    else
    {
        mexErrMsgIdAndTxt("Images:inv_lwm:badLWMTdata",
                          "%s",ERR_LWM_TDATA_BAD);
    }

    ControlPoints = mxGetField(T,0,"ControlPoints");
    if ((ControlPoints != NULL) && !mxIsEmpty(ControlPoints))
    {

        /*
         * ControlPoints must be a real nControlPoints-by-2 double-precision 
         * matrix.
         */
        if (!mxIsDouble(ControlPoints) ||
            (mxGetNumberOfDimensions(ControlPoints) > 2) ||
            (mxGetM(ControlPoints) != nControlPoints) ||
            (mxGetN(ControlPoints) != 2) ||
            mxIsComplex(ControlPoints))
        {
            mexErrMsgIdAndTxt("Images:inv_lwm:badControlpoints",
                          "%s",ERR_CONTROLPOINTS_BAD);
        }
        
        pr_CP = (double *) mxGetData(ControlPoints);
        
        /*
         * ControlPoints must not contain Inf's or NaN's.
         */ 
        for (k = 0; k < nControlPoints*2; k++)
        {
            if (! mxIsFinite(pr_CP[k]))
            {
                mexErrMsgIdAndTxt("Images:inv_lwm:controlpointsHaveNansOrInfs",
                          "%s",ERR_CONTROLPOINTS_NANINF);
            }
        }

        /*
         * Get pointers to ControlPoints array that is passed in
         * from MATLAB as a field of T structure.
         */
        data->xControlPoints = pr_CP;
        data->yControlPoints = pr_CP + nControlPoints;
                        
    }
    else
    {
        mexErrMsgIdAndTxt("Images:inv_lwm:badControlpoints",
                          "%s",ERR_CONTROLPOINTS_BAD);
    }


    RadiiOfInfluence = mxGetField(T,0,"RadiiOfInfluence");
    if ((RadiiOfInfluence != NULL) && !mxIsEmpty(RadiiOfInfluence))
    {

        /*
         * RadiiOfInfluence must be a real nControlPoints-by-1 
         * double-precision matrix.
         */
        if (!mxIsDouble(RadiiOfInfluence) ||
            (mxGetNumberOfDimensions(RadiiOfInfluence) > 2) ||
            (mxGetNumberOfElements(RadiiOfInfluence) != nControlPoints) ||
            mxIsComplex(RadiiOfInfluence))
        {
            mexErrMsgIdAndTxt("Images:inv_lwm:badRadiiOfInfluence",
                          "%s",ERR_RADIIOFINFLUENCE_BAD);
        }
        
        pr_Radii = (double *) mxGetData(RadiiOfInfluence);
        
        /*
         * RadiiOfInfluence must not contain Inf's or NaN's.
         * and must contain positive numbers
         */ 
        for (k = 0; k < nControlPoints; k++)
        {
            if (! mxIsFinite(pr_Radii[k]))
            {
                mexErrMsgIdAndTxt("Images:inv_lwm:"
                                  "radiiOfInfluenceHaveNansOrInfs",
                                  "%s",ERR_RADIIOFINFLUENCE_NANINF);
            }

            if (pr_Radii[k]<=0.0) 
            {
                 mexErrMsgIdAndTxt("Images:inv_lwm:"
                                   "radiiOfInfluenceAreNegative",
                                   "%s",ERR_RADIIOFINFLUENCE_NEG);
            }
        }

        /*
         * Get pointer to RadiiOfInfluence
         */
        data->RadiiOfInfluence = pr_Radii;

    }
    else
    {
        mexErrMsgIdAndTxt("Images:inv_lwm:badRadiiOfInfluence",
                          "%s",ERR_RADIIOFINFLUENCE_BAD);
    }

    data->warned = false;         /* false means no warnings yet */

}

#define TYPE LWMDataType
#define INIT_DATA(a,b) InitLWMData(a,b)
#define REVERSE_MAPPING(a,b,c,d,e) LWMReverseMapping(a,b,c,d,e)
#define DESTROY_DATA(a) DestroyLWMData(a)
static void TransformPoints
#include "transform_points.h"

/*
 * mexFunction
 *
 * Main entry point for the MEX-file.  Passes control immediately to other functions
 * depending on the number of input arguments.
 */
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    if (nrhs < 2)
    {
        mexErrMsgIdAndTxt("Images:inv_lwm:tooFewInputs",
                          "%s",ERR_TOO_FEW_INPUTS);
    }
    else if (nrhs == 2)
    {
        TransformPoints(nlhs, plhs, nrhs, prhs);
    }
    else
    {
        mexErrMsgIdAndTxt("Images:inv_lwm:tooManyInputs",
                          "%s",ERR_TOO_MANY_INPUTS);
    }
}
