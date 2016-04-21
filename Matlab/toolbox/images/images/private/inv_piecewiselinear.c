/* $Revision: 1.4.4.2 $ */
/* Copyright 1993-2003 The MathWorks, Inc. */

static char rcsid[] = "$Id: inv_piecewiselinear.c,v 1.4.4.2 2003/08/01 18:11:16 batserve Exp $";

#include <math.h>
#include "lwm_piecewiselinear.h"
#include "../../../matlab/polyfun/src/findtri.h"

typedef struct PiecewiseLinearDataType
{
    /*
     * one Reverse affine transform matrix per triangle
     *
     *       A[triangle]  D[triangle]
     *       B[triangle]  E[triangle]
     *       C[triangle]  F[triangle]
     */
    double *A, *B, *C, *D, *E, *F;
    double *Triangles;
    int ntri,nvert,previous_triangle;
    double *xVertices, *yVertices;
    int *ir, *jc; /* nearest neighbor sparse structure */
    bool warned;    
    double *onHull;
}
PiecewiseLinearDataType;

/* 
 *  Find the vertex on the convex hull that the point (vx,vy) is closest to.
 *  Return the index of this vertex.
 */
static int FindHullVertex(double vx, double vy, double *onHull,
                          double *x, double *y, int nvert)
{
    int    k, p;
    double mindist, d;

    mindist = mxGetInf();
    
    for (k = 0; k < nvert; k++)
    {
        if ( onHull[k]==1.0 )
            d = (x[k]-vx)*(x[k]-vx) + (y[k]-vy)*(y[k]-vy);
            if (d<mindist)
            {   
                mindist = d;
                p = k;
            }
    }
       
    return(p);
    
}

/*  Return distance from (projection of (vx,vy) onto edge) to 
 *  closest vertex of edge. Edge is defined by vertices i and j. 
 */
static double edgedist(double vx, double vy, int i, int j, 
                       double *x, double *y) 
{
  double x1, x2, y1, y2;
  double s, d;
	
  x1 = x[i]; 
  x2 = x[j];
  y1 = y[i]; 
  y2 = y[j];
		
  s = (x2-x1)*(x2-x1)+(y2-y1)*(y2-y1);
  if (s != 0) {
      s = ((x2-x1)*(vx-x1)+(y2-y1)*(vy-y1)) / s;
  }

  if ( (s >= 0.0) && (s <= 1.0) )
      d = 0.0;
  else if (s < 0.0)
      d = -s;
  else /* s > 1.0 */
      d = s - 1.0;
  
  return(d);
}

/* 
 *  Find the triangle that the point (vx,vy) is closest to.
 *  Choose from triangles that have edges on the convex hull.
 */
static int FindHullTriangle(double vx, double vy, int t, double *onHull,
                            double *x, double *y, int nvert, 
                            double *tri, int ntri, int *ir, int *jc)
{
    int    i, j, k, n, p;
    double d, mindist;

    /*  
     *  search for the closest convex hull vertex to vx,vy          
     */
    p = FindHullVertex(vx, vy, onHull, x, y, nvert);
        
    /*  
     *  loop over triangles connected to vertex p
     *  find edges that are on convex hull
     *  find closest edge (as defined by edgedist)
     */  
    mindist = mxGetInf();
    for (j = jc[p]; j < jc[p+1]; j++) 
    {
        /* loop over vertices of triangle j */
        for (k = 0; k < 3; k++)   
        { 
            i = ir[j] + k*ntri;  
            n = (int)tri[i]-1;        /* vertex k of triangle j */

            if ( n==p || onHull[n]==0.0 ) /* skip interior vertex */
                continue;

            /*  
             *  Find distance from point (vx,vy) to 
             *  edge with vertices p and n.   
             */
            d = edgedist(vx,vy,p,n,x,y);  
            if (d < mindist) 
            {
                mindist = d;
                t = i%ntri;  /* triangle t */
            }
        }
    }


    return(t);
}


/*
 * PiecewiseLinearReverseMappingT
 *
 * Given a location in output space (x,y) and a triangle t, compute
 * the corresponding location in input space (u,v).  */
static
void PiecewiseLinearReverseMappingT(PiecewiseLinearDataType *data,
                                    double x, double y, 
                                    double *u, double *v, int t)
{
    *u = x * data->A[t] + y * data->B[t] + data->C[t];
    *v = x * data->D[t] + y * data->E[t] + data->F[t];
}

/*
 * PiecewiseLinearReverseMapping
 *
 * Given a location in output space (x,y), find the triangle that
 * contains (x,y), then compute the corresponding location in input space
 * (u,v).  */
static
void PiecewiseLinearReverseMapping(PiecewiseLinearDataType *data,
                                   double x, double y,
                                   double *u, double *v)
{
    int t;

    t = FindTriangle(x,y,data->previous_triangle,
                     data->xVertices,data->yVertices,
                     data->Triangles,data->ntri,
                     data->ir,data->jc,&(data->warned));

    if (t == -1) /* point outside convex hull */
    {
        t = FindHullTriangle(x,y,data->previous_triangle,data->onHull,
                             data->xVertices,data->yVertices,data->nvert,
                             data->Triangles,data->ntri,
                             data->ir,data->jc);
    }

    PiecewiseLinearReverseMappingT(data, x, y, u, v, t);

    data->previous_triangle = t; /* store triangle for next search */
}

static
void DestroyPiecewiseLinearData(PiecewiseLinearDataType *data)
{
    /*
     * The piecewise linear data structure contains dynamically
     * allocated memory, free this first, then free the structure.  
     */

    mxFree(data->A);
    mxFree(data->B);
    mxFree(data->C);
    mxFree(data->D);
    mxFree(data->E);
    mxFree(data->F);
    mxFree(data);
}

/*
 * InitPiecewiseLinearData
 *
 * This function is responsible for filling in the values
 * in the PiecewiseLinearDataType structure.
 *
 */
void InitPiecewiseLinearData(const mxArray *T, PiecewiseLinearDataType *data)
{
    mxArray *Tinv, *Triangles, *ControlPoints, *TriangleGraph, *onHull;
    double *pr_Tinv = NULL;
    double *pr_Tri = NULL;
    double *pr_CP = NULL;
    double *pr_Hull = NULL;
    int k, ntri, nvert;
    const int *dim_Tinv;
    
    Tinv = mxGetField(T,0,"PiecewiseLinearTData");
    if ((Tinv != NULL) && !mxIsEmpty(Tinv))
    {
        dim_Tinv = mxGetDimensions(Tinv);
        ntri = dim_Tinv[2];
        data->ntri = ntri;
        
        /*
         * Tinv must be a real 3-by-2-by-ntri double-precision matrix.
         */
        if (!mxIsDouble(Tinv) ||
            (mxGetNumberOfDimensions(Tinv) > 3) ||
            (dim_Tinv[0] != 3) ||
            (dim_Tinv[1] != 2) ||
            mxIsComplex(Tinv))
        {
            mexErrMsgIdAndTxt("Images:inv_piecewiselinear:badTdata",
                              "%s",ERR_PIECEWISELINEAR_TDATA_BAD);
        }
        
        pr_Tinv = (double *) mxGetData(Tinv);
        
        /*
         * Tinv must not contain Inf's or NaN's.
         */
        for (k = 0; k < mxGetNumberOfElements(Tinv); k++)
        {
            if (! mxIsFinite(pr_Tinv[k]))
            {
                mexErrMsgIdAndTxt("Images:inv_piecewiselinear:"
                                  "tdataHasNansOrInfs",
                                  "%s",ERR_PIECEWISELINEAR_TDATA_NANINF);
            }
        }
        
        /*
         * Allocate memory for A,B,C,D,E,F based on ntri.
         */
        data->A = (double *) mxCalloc(ntri,sizeof(double));
        data->B = (double *) mxCalloc(ntri,sizeof(double));
        data->C = (double *) mxCalloc(ntri,sizeof(double));
        data->D = (double *) mxCalloc(ntri,sizeof(double));
        data->E = (double *) mxCalloc(ntri,sizeof(double));
        data->F = (double *) mxCalloc(ntri,sizeof(double));

        /*
         * Assign Tinv values to reverse mapping variables.
         */
        for (k = 0; k < ntri; k++)
        {
            data->A[k] = pr_Tinv[0 + k*6];
            data->B[k] = pr_Tinv[1 + k*6];
            data->C[k] = pr_Tinv[2 + k*6];
            data->D[k] = pr_Tinv[3 + k*6];
            data->E[k] = pr_Tinv[4 + k*6];
            data->F[k] = pr_Tinv[5 + k*6];
        }
        
    }
    else
    {
        mexErrMsgIdAndTxt("Images:inv_piecewiselinear:badTdata",
                          "%s",ERR_PIECEWISELINEAR_TDATA_BAD);
    }

    ControlPoints = mxGetField(T,0,"ControlPoints");
    if ((ControlPoints != NULL) && !mxIsEmpty(ControlPoints))
    {

        nvert = mxGetM(ControlPoints);
        data->nvert = nvert;
        
        /*
         * ControlPoints must be a real nvert-by-2 double-precision matrix.
         */
        if (!mxIsDouble(ControlPoints) ||
            (mxGetNumberOfDimensions(ControlPoints) > 2) ||
            (mxGetN(ControlPoints) != 2) ||
            mxIsComplex(ControlPoints))
        {
            mexErrMsgIdAndTxt("Images:inv_piecewiselinear:badControlPoints",
                              "%s",ERR_CONTROLPOINTS_BAD);
        }
        
        pr_CP = (double *) mxGetData(ControlPoints);
        
        /*
         * ControlPoints must not contain Inf's or NaN's.
         */ 
        for (k = 0; k < nvert*2; k++)
        {
            if (! mxIsFinite(pr_CP[k]))
            {
                mexErrMsgIdAndTxt("Images:inv_piecewiselinear:"
                                  "controlPointsHaveNansOrInfs",
                                  "%s",ERR_CONTROLPOINTS_NANINF);
            }
        }

        /*
         * Get pointers to ControlPoints array that is passed in
         * from MATLAB as a field of T structure.
         */
        data->xVertices = pr_CP;
        data->yVertices = pr_CP + nvert;
                        
    }
    else
    {
        mexErrMsgIdAndTxt("Images:inv_piecewiselinear:badControlPoints",
                          "%s",ERR_CONTROLPOINTS_BAD);
    }

    Triangles = mxGetField(T,0,"Triangles");
    if ((Triangles != NULL) && !mxIsEmpty(Triangles))
    {
        
        /*
         * Triangles must be a real ntri-by-3 double-precision matrix.
         */
        if (!mxIsDouble(Triangles) ||
            (mxGetNumberOfDimensions(Triangles) > 2) ||
            (mxGetM(Triangles) != ntri) ||
            (mxGetN(Triangles) != 3) ||
            mxIsComplex(Triangles))
        {
            mexErrMsgIdAndTxt("Images:inv_piecewiselinear:badTriangles",
                              "%s",ERR_TRIANGLES_BAD);
        }
        
        pr_Tri = (double *) mxGetData(Triangles);
        
        /*
         * Triangles must not contain Inf's or NaN's.
         * and must contain integers between 1 and nvert
         */ 
        for (k = 0; k < ntri*3; k++)
        {
            if (! mxIsFinite(pr_Tri[k]))
            {
                mexErrMsgIdAndTxt("Images:inv_piecewiselinear:"
                                  "trianglesHaveNansOrInfs",
                                  "%s",ERR_TRIANGLES_NANINF);
            }

            if ( (pr_Tri[k]<1.0) || 
                 (pr_Tri[k]>nvert) || 
                 ( pr_Tri[k]!=floor(pr_Tri[k]) ) ) 
            {
                mexErrMsgIdAndTxt("Images:inv_piecewiselinear:"
                                  "trianglesMustContainIntegersInProperRange",
                                  "%s",ERR_TRIANGLES_INT);
            }
        }

        /*
         * Get pointer to Triangles array
         */
        data->Triangles = pr_Tri;
                        
    }
    else
    {
        mexErrMsgIdAndTxt("Images:inv_piecewiselinear:badTriangles",
                          "%s",ERR_TRIANGLES_BAD);
    }

    /* 
     * Set up sparse matrix
     */
    TriangleGraph = mxGetField(T,0,"TriangleGraph");
    if ((TriangleGraph != NULL) && !mxIsEmpty(TriangleGraph))
    {
        if (!mxIsSparse(TriangleGraph) ||
            (mxGetNumberOfDimensions(TriangleGraph) > 2) ||
            (mxGetM(TriangleGraph) != ntri) ||
            (mxGetN(TriangleGraph) != nvert) || 
            mxIsComplex(TriangleGraph))
        {
            mexErrMsgIdAndTxt("Images:inv_piecewiselinear:badTriangleGraph",
                              "%s",ERR_TRIANGLEGRAPH_BAD);
        }

        data->ir = mxGetIr(TriangleGraph); /* indices of points */
        data->jc = mxGetJc(TriangleGraph); /* indices of points */
    }
    else
    {
        mexErrMsgIdAndTxt("Images:inv_piecewiselinear:badTriangleGraph",
                          "%s",ERR_TRIANGLEGRAPH_BAD);
    }

    onHull = mxGetField(T,0,"OnHull");
    if ((onHull != NULL) && !mxIsEmpty(onHull))
    {

        /*
         * onHull must be a real nvert-by-1 double-precision matrix.
         */
        if (!mxIsDouble(onHull) ||
            (mxGetNumberOfDimensions(onHull) > 2) ||
            (mxGetNumberOfElements(onHull) != nvert) ||
            mxIsComplex(onHull))
        {
            mexErrMsgIdAndTxt("Images:inv_piecewiselinear:badOnHull",
                              "%s",ERR_ONHULL_BAD);
        }
        
        pr_Hull = (double *) mxGetData(onHull);
        
        /*
         * onHull must not contain Inf's or NaN's.
         * and must be zero or one.
         */ 
        for (k = 0; k < nvert; k++)
        {
            if (! mxIsFinite(pr_Hull[k]))
            {
                mexErrMsgIdAndTxt("Images:inv_piecewiselinear:"
                                  "onHullHasNansOrInfs",
                                  "%s",ERR_ONHULL_NANINF);
            }

            if ( (pr_Hull[k]!=0.0) && (pr_Hull[k]!=1.0) )
            {
                mexErrMsgIdAndTxt("Images:inv_piecewiselinear:"
                                  "onHullMustBeBinary",
                                  "%s",ERR_ONHULL_BINARY);
            }
        }

        /*
         * Get pointer to onHull array
         */
        data->onHull = pr_Hull;

    }
    else
    {
        mexErrMsgIdAndTxt("Images:inv_piecewiselinear:badOnHull",
                          "%s",ERR_ONHULL_BAD);
    }

    /* 
     *  initialize variables for findtri. 
     */
    data->warned = false;         /* false means no warnings yet */
    data->previous_triangle = 0;  /* start with triangle 0 */

}

#define TYPE PiecewiseLinearDataType
#define INIT_DATA(a,b) InitPiecewiseLinearData(a,b)
#define REVERSE_MAPPING(a,b,c,d,e) PiecewiseLinearReverseMapping(a,b,c,d,e)
#define DESTROY_DATA(a) DestroyPiecewiseLinearData(a)
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
        mexErrMsgIdAndTxt("Images:inv_piecewiselinear:tooFewInputs",
                          "%s",ERR_TOO_FEW_INPUTS);
    }
    else if (nrhs == 2)
    {
        TransformPoints(nlhs, plhs, nrhs, prhs);
    }
    else
    {
        mexErrMsgIdAndTxt("Images:inv_piecewiselinear:tooManyInputs",
                          "%s",ERR_TOO_MANY_INPUTS);
    }
}
