/*
 * File : rt_intrp2linf.c
 *        $Revision: 1.1.6.2 $
 * 
 *   Copyright 1994-2003 The MathWorks, Inc.
 *
 *
 */

#include "rtlooksrc.h"


/* Function: rt_Intrp2linf ====================================================
 * Abstract:
 *
 *   2-D linear interpolation for an n-D column major table.
 *
 *   Index searches have already been performed.
 *
 *
 */
real32_T rt_Intrp2Linf(const int32_T  * const idx,
                       const real32_T * const lambda,
                       const real32_T * const T,
                       const int32_T          stride)
{
  int32_T idxL, idxU;
  real32_T yL0;

  idxL      =   idx[1] * stride      /* now pointing at a column      */
              + idx[0];              /* now pointing at a row element */
  idxU      =   idxL   + stride;

  yL0   =  T[idxL] + lambda[0] * (T[idxL+1] - T[idxL]); /* 1-D lower result */
  return(  yL0     + lambda[1] * (
          (T[idxU] + lambda[0] * (T[idxU+1] - T[idxU]))
                                  - yL0));              /* 2-D lower result, 
                                                         * w/1-D upper folded in 
                                                         */ 
}

/* [EOF] rt_intrp2linf.c */
