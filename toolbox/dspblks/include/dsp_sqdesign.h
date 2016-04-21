/*
 *  dsp_sqdesign.h
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.1.6.1 $ $Date: 2003/12/06 15:29:36 $
 */

#ifndef dsp_sqdesign_h
#define dsp_sqdesign_h

#include "dsp_rt.h"

/* 
 * Function naming glossary 
 * --------------------------- 
 * 
 * DSPMEX = DSP Blockset MEX function
 * 
 * Data types - (describe inputs to functions, not outputs) 
 * D = real double-precision 
 */ 
 
/* Function naming convention (2nd-5th: four functions)
 * -------------------------- 
 * 
 *    1) DSPMEX_ is a prefix used for DSP Blockset MEX function 
 *    2) The second field (sqdes) indicates that this function is implementing the 
 *       Lloyd algorithm to design a scalar quantizer. 
 *    3) The third field (bin/lin) represents the searching method which are
 *       binary or linear respectively.
 *    3) The fourth field (floor/ceil) represents the tie-breaking rule which are
 *       'take the lower index' or 'take the higher index's
 *    3) The last field enumerates the I/O data type (only double precision, non-complex). 
 * 
 *    Examples: 
 *       DSPMEX_sqdes_bin_floor is the scalar quantizer design function
 *       which exploits Lloyd algorithm with binary searching method, and takes the 
 *       lower index to break a tie. I/O data types are only double precision, non-complex. 
 */ 

/* The recursive quicksort routine - these functions call themselves, hence recursive: */

extern int_T DSPMEX_sqdes_main_D (
               const real_T  *u1_train, 
               const real_T  *u2_initCB,
               const real_T  *u3_initPT, 
                     real_T  *y1_finalCB,
                     real_T  *y2_finalPT,
               const int_T    CodeBookLength,  
               const int_T    WidthTrainSet,
               const real_T   RelThreshold,
               const int_T    MaxIter,
                     real_T **ptrErr,
                     int_T    SearchingMethod,
                     int_T    TieBreakingRule);

extern real_T DSPMEX_sqdes_bin_floor_D (
           real_T *CodeBook,
           real_T *Partition, 
           const int_T LengthCB, 
           const real_T *TrainSet, 
           const int_T WidthTS);

extern real_T DSPMEX_sqdes_lin_floor_D (
           real_T *CodeBook,
           real_T *Partition, 
           const int_T LengthCB, 
           const real_T *TrainSet, 
           const int_T WidthTS);

extern real_T DSPMEX_sqdes_bin_ceil_D (
           real_T *CodeBook,
           real_T *Partition, 
           const int_T LengthCB, 
           const real_T *TrainSet, 
           const int_T WidthTS);

extern real_T DSPMEX_sqdes_lin_ceil_D (
           real_T *CodeBook,
           real_T *Partition, 
           const int_T LengthCB, 
           const real_T *TrainSet, 
           const int_T WidthTS);

extern void DSPMEX_sqdes_sort_ascend_D (         
       real_T *CodeBook, 
       const int_T LengthCB);

              
#define FALSE 0
#define TRUE  1
#define MAX_STRIDE 50

#endif /* dsp_sqdesign_h */

/* [EOF] dsp_sqdesign.h */

