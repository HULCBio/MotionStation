/*
 * File : rt_intrp3linf.c
 *        $Revision: 1.1.6.2 $
 * 
 *   Copyright 1994-2003 The MathWorks, Inc.
 *
 *
 */

#include "rtlooksrc.h"


/* Function: rt_Intrp3linf ====================================================
 * Abstract:
 *
 *   3-D linear interpolation for an n-D column major table.
 *
 *   Index searches have already been performed.
 *
 *
 */
real32_T rt_Intrp3Linf(const int32_T  * const idx,
                       const real32_T * const lambda,
                       const real32_T * const T,
                       const int32_T  * const stride)
{
  int32_T  idxL, idxU;
  real32_T yL0, yL1;

  idxL      =   idx[2] * stride[2]   /* now pointing at a 2-D chunk   */
              + idx[1] * stride[1]   /* now pointing at a column      */
              + idx[0];              /* now pointing at a row element */
  idxU      =   idxL   + stride[1];

  /* lower 2 */
  yL0   =  T[idxL] + lambda[0] * (T[idxL+1] - T[idxL]); /* 1-D lower result */
  yL1   =  yL0     + lambda[1] * (
          (T[idxU] + lambda[0] * (T[idxU+1] - T[idxU]))
                                  - yL0);               /* 2-D lower result, 
                                                         * w/1-D upper 
                                                         * folded in        */ 

  /* upper 2 */
  idxL += stride[2];  /* upper 2-D chunk */
  idxU += stride[2];

  yL0   =  T[idxL] + lambda[0] * (T[idxL+1] - T[idxL]); /* 1-D lower result */

  /* finish */
  return(  yL1     + lambda[2] * (
          (yL0     + lambda[1] * (
          (T[idxU] + lambda[0] * (T[idxU+1] - T[idxU])) 
                                  - yL0)) 
                                  - yL1));               /* 3-D result, w/1-D 
                                                          * & 2-D upper 
                                                          * folded in         */
}

/* [EOF] rt_intrp3linf.c */
