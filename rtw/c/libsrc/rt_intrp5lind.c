/*
 * File : rt_intrp5lind.c
 *        $Revision: 1.1.6.2 $
 * 
 *   Copyright 1994-2003 The MathWorks, Inc.
 *
 *
 */

#include "rtlooksrc.h"


/* Function: rt_Intrp5Lind ====================================================
 * Abstract:
 *
 *   5-D linear interpolation for an n-D column major table.
 *
 *   Index searches have already been performed.
 *
 *
 */
real_T   rt_Intrp5Lind(const int32_T  * const idx,
                       const real_T   * const lambda,
                       const real_T   * const T,
                       const int32_T  * const stride)
{
  int32_T idxL, idxU;
  real_T  yL0, yL1, yL2, yL3, yU2;

  idxL      =   idx[4] * stride[4]   /* now pointing at a 4-D chunk   */
              + idx[3] * stride[3]   /* now pointing at a 3-D chunk   */
              + idx[2] * stride[2]   /* now pointing at a 2-D chunk   */
              + idx[1] * stride[1]   /* now pointing at a column      */
              + idx[0];              /* now pointing at a row element */
  idxU      =   idxL   + stride[1];

  /* begin lower 4 */

  /* lower 3 */

  /* lower 2 of lower 3 */
  yL0   =  T[idxL] + lambda[0] * (T[idxL+1] - T[idxL]); /* 1-D lower result */
  yL1   =  yL0     + lambda[1] * (
          (T[idxU] + lambda[0] * (T[idxU+1] - T[idxU]))
                                  - yL0);               /* 2-D lower result, 
                                                         * w/1-D upper 
                                                         * folded in */ 

  /* upper 2 of lower 3 */
  idxL += stride[2];  /* upper 2-D chunk */
  idxU += stride[2];

  yL0   =  T[idxL] + lambda[0] * (T[idxL+1] - T[idxL]); /* 1-D lower result */
  yL2   =  yL1     + lambda[2] * (
          (yL0     + lambda[1] * (
          (T[idxU] + lambda[0] * (T[idxU+1] - T[idxU])) 
                                  - yL0)) 
                                  - yL1);               /* 3-D lower result, 
                                                         * w/1-D & 2-D upper 
                                                         * folded in */

  /* upper 3 */
  idxL += (stride[3] - stride[2]);                      /* next 3-D chunk */
  idxU  = idxL + stride[1];

  /* lower 2 of upper 3 */
  yL0   =  T[idxL] + lambda[0] * (T[idxL+1] - T[idxL]); /* 1-D lower result */
  yL1   =  yL0     + lambda[1] * (
          (T[idxU] + lambda[0] * (T[idxU+1] - T[idxU]))
                                  - yL0);               /* 2-D lower  result, 
                                                         * w/1-D upper 
                                                         * folded in */ 

  /* upper 2 of upper 3 */
  idxL += stride[2];  /* lower 2-D chunk */
  idxU += stride[2];

  yL0   =  T[idxL] + lambda[0] * (T[idxL+1] - T[idxL]); /* 1-D lower result */
  yU2   =  yL1     + lambda[2] * ( 
          (yL0     + lambda[1] * (
          (T[idxU] + lambda[0] * (T[idxU+1] - T[idxU])) 
                                  - yL0)) 
                                  - yL1);               /* 3-D upper result,
                                                         * w/1-D, 2-D upper
                                                         * upper folded in */

  yL3   =  yL2     + lambda[3] * ( yU2 - yL2 );         /* 4-D lower result */


  /*--- begin upper 4 */
  idxL  += stride[4] - (stride[2] + stride[3]);
  idxU   = idxL + stride[1];

  /* lower 3 */

  /* lower 2 of lower 3 */
  yL0   =  T[idxL] + lambda[0] * (T[idxL+1] - T[idxL]); /* 1-D lower result */
  yL1   =  yL0     + lambda[1] * (
          (T[idxU] + lambda[0] * (T[idxU+1] - T[idxU]))
                                  - yL0);               /* 2-D lower result, 
                                                         * w/1-D upper 
                                                         * folded in */ 

  /* upper 2 of lower 3 */
  idxL += stride[2];  /* upper 2-D chunk */
  idxU += stride[2];

  yL0   =  T[idxL] + lambda[0] * (T[idxL+1] - T[idxL]); /* 1-D lower result */
  yL2   =  yL1     + lambda[2] * (
          (yL0     + lambda[1] * (
          (T[idxU] + lambda[0] * (T[idxU+1] - T[idxU])) 
                                  - yL0)) 
                                  - yL1);               /* 3-D lower result, 
                                                         * w/1-D & 2-D upper 
                                                         * folded in */

  /* upper 3 */
  idxL += (stride[3] - stride[2]);                      /* next 3-D chunk */
  idxU  = idxL + stride[1];

  /* lower 2 of upper 3 */
  yL0   =  T[idxL] + lambda[0] * (T[idxL+1] - T[idxL]); /* 1-D lower result */
  yL1   =  yL0     + lambda[1] * (
          (T[idxU] + lambda[0] * (T[idxU+1] - T[idxU]))
                                  - yL0);               /* 2-D lower  result, 
                                                         * w/1-D upper 
                                                         * folded in */ 

  /* upper 2 of upper 3 */
  idxL += stride[2];  /* lower 2-D chunk */
  idxU += stride[2];

  yL0   =  T[idxL] + lambda[0] * (T[idxL+1] - T[idxL]); /* 1-D lower result */
  yU2   =  yL1     + lambda[2] * ( 
          (yL0     + lambda[1] * (
          (T[idxU] + lambda[0] * (T[idxU+1] - T[idxU])) 
                                  - yL0)) 
                                  - yL1);               /* 3-D upper result,
                                                         * w/1-D, 2-D upper
                                                         * folded in */

  /* Finish */
  return(  yL3     + lambda[4] * (
          (yL2     + lambda[3] * (yU2 - yL2))
                                  - yL3));              /* 5-D result, w/4-D 
                                                         * upper folded in */
}

/* [EOF] rt_intrp5lind.c */
