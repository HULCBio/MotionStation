/* Copyright 1994-2002 The MathWorks, Inc.
 *
 * File: rt_look2d32_normal.c    $Revision: 1.4 $
 * $Date: 2002/04/14 10:17:19 $
 *
 * Abstract:
 *      Real-Time Workshop index finding routine used in the code
 *      generated from SL models involving 2D Lookup Table
 *      blocks.  This routine assumes there are no repeated zero
 *      values in the row and column data.
 */

#include "rtlibsrc.h"

real32_T rt_Lookup2D32_Normal (const real32_T *xVals, const int_T numX,
                               const real32_T *yVals, const int_T numY,
                               const real32_T *zVals,
                               const real32_T x, const real32_T y)
{
  int_T xIdx, yIdx;
  real32_T ylo, yhi;
  real32_T Zx0yhi, Zx0ylo, xlo, xhi;
  real32_T corner1, corner2;

  xIdx = rt_GetLookupIndex32(xVals,numX,x);
  xlo = xVals[xIdx];
  xhi = xVals[xIdx+1];

  yIdx = rt_GetLookupIndex32(yVals,numY,y);
  ylo = yVals[yIdx];
  yhi = yVals[yIdx+1];

  corner1 = *(zVals +  xIdx    + numX*yIdx);
  corner2 = *(zVals + (xIdx+1) + numX*yIdx);
  Zx0ylo = INTERP(x, xlo, xhi, corner1, corner2);
  corner1 = *(zVals +  xIdx    + numX*(yIdx+1));
  corner2 = *(zVals + (xIdx+1) + numX*(yIdx+1));
  Zx0yhi = INTERP(x, xlo, xhi, corner1, corner2);

  return (INTERP(y,ylo,yhi,Zx0ylo,Zx0yhi));
}

