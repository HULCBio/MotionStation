/*
 * File : rt_intrpnsplf.c generated from file
 *       gentablefuncs, Revision: 1.7.4.4.2.1 
 * 
 *   Copyright 1994-2003 The MathWorks, Inc.
 *
 *
 */

#include "rtlooksrc.h"


/* Function: ==================================================
 * Abstract:
 *    Second derivative Initialization function for spline
 *    for last dimension.
 *
 */
void rt_Spline2Derivf(const real32_T *x, 
		      const real32_T *y, 
		      int n, 
		      real32_T *u, 
		      real32_T *y2)
{
  real32_T p, qn, sig, un;
  int_T  n1, i, k;
  n1 = n - 1;
  y2[0] = 0.0F;
  u[0]  = 0.0F;
  for (i = 1; i < n1; i++) {
    real32_T dxm1 = x[i] - x[i - 1];
    real32_T dxp1 = x[i + 1] - x[i];
    real32_T dxpm = dxp1 + dxm1;

    sig = dxm1 / dxpm;
    p = sig * y2[i - 1] + 2.0F;
    y2[i] = (sig - 1.0F) / p;
    u[i] = (y[i + 1] - y[i]) / dxp1 - (y[i] - y[i - 1]) / dxm1;
    u[i] = (6.0F * u[i] / dxpm - sig * u[i - 1]) / p;
  }
  qn = 0.0F;
  un = 0.0F;
  y2[n1] = (un - qn * u[n1 - 1]) / (qn * y2[n1 - 1] + 1.0F);
  for (k = n1 - 1; k >= 0; k--) {
    y2[k] = y2[k] * y2[k + 1] + u[k];
  }
  return;
}


/* Function: ==================================================
 * Abstract:
 *    n-D natural spline calculation.
 *
 */
real32_T rt_IntrpNSplf(int_T                          numDims,
		       const rt_LUTSplineWork * const splWork,
		       int_T                          extrapMethod)
{
  int_T     il, iu, k, i;
  real32_T  h, s, p, smsq, pmsq;

  /* intermediate results work areas "this" and "next" */

  const rt_LUTnWork *TWork = (const rt_LUTnWork *)splWork->TWork;
  const real32_T *bpLambda   =                      TWork->bpLambda;
  const real32_T *yp         =                      TWork->tableData;
  real32_T *yyA              =       (real32_T *)  splWork->yyA;
  real32_T *yyB              =       (real32_T *)  splWork->yyB;
  real32_T *yy2              =       (real32_T *)  splWork->yy2;
  real32_T *up               =       (real32_T *)  splWork->up;
  real32_T *y2               =       (real32_T *)  splWork->y2;
  const real32_T **bpDataSet = (const real32_T **) TWork->bpDataSet;
  const real32_T *xp         = bpDataSet[0];
  real32_T *yy               = yyA; 
  int_T    bufBank         = 0;
  int_T    len             = TWork->maxIndex[0] + 1;

  /* Generate first dimension's second derivatives */
  for (i=0; i < splWork->numYWorkElts[0]; i++) {
    rt_Spline2Derivf(xp, yp, len, up, y2);
    yp = &yp[len];
    y2 = &y2[len];
  }

  /* Set pointers back to beginning */    
  yp = (const real32_T *)   TWork->tableData;
  y2 =       (real32_T *) splWork->y2;

  /* Generate at-point splines in each dimension */
  for( k=0; k < numDims; k++ ) {

    /* this dim's input setup */

    xp   = bpDataSet[k];
    len  = TWork->maxIndex[k] + 1;
    il   = TWork->bpIndex[k];
    iu   = il + 1;
    h    = xp[iu] - xp[il];
    p    = bpLambda[k];
    s    = 1.0F - p;
    pmsq = p * (p*p - 1.0F);
    smsq = s * (s*s - 1.0F);

    /* 
     * Calculate spline curves for input in this
     * dimension at each value of the higher
     * other dimensions' points in the table.
     */

    if ( p > 1.0F && extrapMethod == 2 ) {
      real32_T slope;
      for (i = 0; i < splWork->numYWorkElts[k]; i++) {
	slope = (yp[iu] - yp[il]) + y2[il]*h*h/6.0F;
	yy[i] = yp[iu] + slope * (p-1.0F);
	yp = &yp[len];
	y2 = &y2[len];
      }
    } else if ( p < 0.0F && extrapMethod == 2 ) {
      real32_T slope;
      for (i = 0; i < splWork->numYWorkElts[k]; i++) {
	slope = (yp[iu] - yp[il]) - y2[iu]*h*h/6.0F;
	yy[i] = yp[il] + slope * p;
	yp = &yp[len];
	y2 = &y2[len];
      }
    } else {
      for (i = 0; i < splWork->numYWorkElts[k]; i++) {
	yy[i] = yp[il] + p * (yp[iu] - yp[il]) + 
	  (smsq * y2[il] + pmsq * y2[iu])*h*h/6.0F;
	yp = &yp[len];
	y2 = &y2[len];
      }
    }

    /* set pointers to new result and calculate second derivatives */

    yp = yy;
    y2 = yy2;

    if ( splWork->numYWorkElts[k+1] > 0 ) {
      int_T         nextLen = TWork->maxIndex[k+1] + 1;
      const real32_T *nextXp  = bpDataSet[k+1];

      for (i=0; i < splWork->numYWorkElts[k+1]; i++) {
	rt_Spline2Derivf(nextXp, yp, nextLen, up, y2);
	yp = &yp[nextLen];
	y2 = &y2[nextLen];
      }
    }

    /* 
     * Set work vectors yp, y2 and yy for next iteration; 
     * the yy just calculated becomes the yp in the 
     * next iteration, y2 was just calculated for these
     * new points and the yy buffer is swapped to the space
     * for storing the next iteration's results.
     */

    yp = yy;
    y2 = yy2;
    yy = (bufBank==0) ? yyA : yyB; /* swap buffers for next dimension      */
    bufBank = (bufBank!=0) ? 0 : 1; /* toggle bufBank for next iteration   */

  }

  return yp[0];
} /* [EOF] rt_intrpnsplf.c */
