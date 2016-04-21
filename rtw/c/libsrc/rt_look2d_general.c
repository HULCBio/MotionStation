/* Copyright 1994-2002 The MathWorks, Inc.
 *
 * File: rt_look2d_general.c    $Revision: 1.8 $
 * $Date: 2002/04/14 10:14:49 $
 *
 * Abstract:
 *      Real-Time Workshop index finding routine used in the code
 *      generated from SL models involving 2D Lookup Table
 *      blocks.  This generalized lookup routine provides special code
 *      for repeated zero values in the row and/or column data.
 */

#include "rtlibsrc.h"

real_T rt_Lookup2D_General (const real_T *rowVals, const int_T numRowVals,
                            const real_T *colVals, const int_T numColVals,
                            const real_T *outputValues,
                            const real_T uX, const real_T uY,
                            const int_T colZeroIdx,
                            const ZeroTechnique colZeroTechnique,
                            const real_T *outputAtRowZero)
{
  int_T yIdx;
  real_T ylo, yhi;

  if (uY == 0.0) {
    yIdx = colZeroIdx;
  } else {
    yIdx = rt_GetLookupIndex(colVals,numColVals,uY);
  }
  ylo = colVals[yIdx];
  yhi = colVals[yIdx+1];

  if (uX == 0.0) {
    real_T Zx0ylo, Zx0yhi;
    Zx0ylo = outputAtRowZero[yIdx];
    Zx0yhi = outputAtRowZero[yIdx+1];
    
    if (colZeroTechnique == NORMAL_INTERP) {
      return (INTERP(uY,ylo,yhi,Zx0ylo,Zx0yhi));
    } else {
      if (uY != 0.0) {
        return (INTERP(uY,ylo,yhi,Zx0ylo,Zx0yhi));
      } else {
        if (colZeroTechnique == AVERAGE_VALUE) {
          return(Zx0yhi + outputAtRowZero[yIdx+2])/2.0;
        } else {
          /* (colZeroTechnique == MIDDLE_VALUE) */
          return (outputAtRowZero[yIdx+2]);
        }
      }
    }
  } else {
    int_T xIdx;
    real_T xlo, xhi, Zx0ylo, Zx0yhi;

    xIdx = rt_GetLookupIndex(rowVals,numRowVals,uX);
    xlo = rowVals[xIdx];
    xhi = rowVals[xIdx+1];

    Zx0ylo = INTERP(uX,xlo,xhi,
                    *(outputValues +  xIdx    + numRowVals*yIdx),
                    *(outputValues + (xIdx+1) + numRowVals*yIdx));
    
    Zx0yhi = INTERP(uX,xlo,xhi,
                    *(outputValues +  xIdx    + numRowVals*(yIdx+1)),
                    *(outputValues + (xIdx+1) + numRowVals*(yIdx+1)));

    if (colZeroTechnique == NORMAL_INTERP) {
      return (INTERP(uY,ylo,yhi,Zx0ylo,Zx0yhi));
    } else {
      if (uY != 0.0) {
        return(INTERP(uY,ylo,yhi,Zx0ylo,Zx0yhi));
      } else {
        if (colZeroTechnique == AVERAGE_VALUE) {
          real_T Zx0yvh = INTERP(uX,xlo,xhi,
                              *(outputValues +  xIdx    + numRowVals*(yIdx+2)),
                              *(outputValues + (xIdx+1) + numRowVals*(yIdx+2)));
          return ((Zx0yhi+Zx0yvh)/2.0);
        } else {
          /* (colZeroTechnique == MIDDLE_VALUE) */
          return (INTERP(uX,xlo,xhi,
                         *(outputValues +  xIdx    + numRowVals*(yIdx+2)),
                         *(outputValues + (xIdx+1) + numRowVals*(yIdx+2)) ));
        }
      }
    }
  }
}

