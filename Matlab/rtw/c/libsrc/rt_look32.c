/* Copyright 1994-2002 The MathWorks, Inc.
 *
 * File: rt_look32.c    $Revision: 1.4 $	$Date: 2002/04/14 10:16:49 $
 *
 * Abstract:
 *      Real-Time Workshop index finding routine used in the code
 *      generated from SL models involving 1D and 2D Lookup Table
 *      blocks of type single.
 */

#include "rtlibsrc.h"

/* Function: rt_GetLookupIndex32 ==============================================
 * Abstract:
 *      Routine to get the index of the input from a table using binary or
 *      interpolation search.
 *
 *      Inputs:
 *        *x   : Pointer to table, x[0] ....x[xlen-1]
 *        xlen : Number of values in xtable
 *        u    : input value to look up
 *
 *      Output:
 *        idx  : the index into the table such that:
 *              if u is negative
 *                 x[idx] <= u < x[idx+1]
 *              else
 *                 x[idx] < u <= x[idx+1]
 *
 *      Interpolation Search: If the table contains a large number of nearly
 *      uniformly spaced entries, i.e., x[n] vs n is linear then the index
 *      corresponding to the input can be found in one shot using the linear
 *      interpolation formula. Therefore if you have a look-up table block with
 *      many data points, using interpolation search might speed up the code.
 *      Compile the generated code with the following flag:
 *
 *                 make_rtw OPTS=-DDOINTERPSEARCH
 *
 *      to enable interpolation search.
 */
int_T rt_GetLookupIndex32(const real32_T *x, int_T xlen, real32_T u)
{
   int_T idx = 0;
   int_T bottom = 0;
   int_T top = xlen-1;

   /*
    * Deal with the extreme cases first:
    *   if u <= x[bottom] then return idx = bottom
    *   if u >= x[top]    then return idx = top-1
    */
   if (u <= x[bottom]) {
      return(bottom);
   } else if (u >= x[top]) {
      return(top-1);
   }

   if (u < 0) {
       /* For negative input find index such that: x[idx] <= u < x[idx+1] */
       for (;;) {
           utAssert( (x[bottom] < u) && (u < x[top]) );
#ifdef DOINTERPSEARCH
           real32_T offset = (u-x[bottom])/(x[top]-x[bottom]);
           idx = bottom + (top-bottom)*(offset-DBL_EPSILON);
           utAssert(bottom <= idx && idx < top);
#else
           idx = (bottom + top)/2;
#endif
           if (u < x[idx]) {
               top = idx - 1;
           } else if (u >= x[idx+1]) {
               bottom = idx + 1;
           } else {
               /* we have x[idx] <= u < x[idx+1], return idx */
               return(idx);
           }
       }
   } else {
       /* For non-negative input find index such that: x[idx] < u <= x[idx+1] */
       for (;;) {
           utAssert( (x[bottom] < u) && (u < x[top]) );
#ifdef DOINTERPSEARCH
           real32_T offset = (u-x[bottom])/(x[top]-x[bottom]);
           idx = bottom + (top-bottom)*(offset-DBL_EPSILON);
           utAssert(bottom <= idx && idx < top);
#else
           idx = (bottom + top)/2;
#endif
           if (u <= x[idx]) {
               top = idx - 1;
           } else if (u > x[idx+1]) {
               bottom = idx + 1;
           } else {
               /* we have x[idx] < u <= x[idx+1], return idx */
               return(idx);
           }
       }
   }
}

/* [EOF] rt_look.c */
