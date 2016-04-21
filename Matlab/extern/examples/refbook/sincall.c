/* $Revision: 1.4 $ */
/*=====================================================================
 * sincall.c
 *
 * example for illustrating how to use mexCallMATLAB
 * 
 * creates an mxArray and passes its associated  pointers (in this demo,
 * only pointer to its real part, pointer to number of rows, pointer to
 * number of columns) to subfunction fill() to get data filled up, then 
 * calls mexCallMATLAB to calculate sin function and plot the result.
 *
 * This is a MEX-file for MATLAB.
 * Copyright 1984-2000 The MathWorks, Inc.
 *===================================================================*/
#include "mex.h"
#define MAX 1000

/* subroutine for filling up data */
void fill( double *pr, int *pm, int *pn, int max )
{
    int i;  
    /* you can fill up to max elements, so (*pr)<=max */
    *pm = max/2;
    *pn = 1;
    for (i=0; i < (*pm); i++) 
      pr[i]=i*(4*3.14159/max);
}

/* gateway function */
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{
    int     m, n, max=MAX;
    mxArray *rhs[1], *lhs[1];

    rhs[0] = mxCreateDoubleMatrix(max, 1, mxREAL);

    /* pass the pointers and let fill() fill up data */
    fill(mxGetPr(rhs[0]), &m, &n, MAX);
    mxSetM(rhs[0], m);
    mxSetN(rhs[0], n);
    

    /* get the sin wave and plot it */
    mexCallMATLAB(1, lhs, 1, rhs, "sin");
    mexCallMATLAB(0, NULL, 1, lhs, "plot");

    /* cleanup allocated memory */
    mxDestroyArray(rhs[0]);
    mxDestroyArray(lhs[0]);
     
    return;
}
