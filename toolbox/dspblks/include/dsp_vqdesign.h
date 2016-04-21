/*
 *  dsp_vqdesign.h
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.1.6.1 $ $Date: 2003/12/06 15:29:38 $
 */

#ifndef dsp_vqdesign_h
#define dsp_vqdesign_h

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
 
/* Function naming convention 
 * -------------------------- 
 * 
 *    1) DSPMEX_ is a prefix used for DSP Blockset MEX function
 *    2) The second field (vqdes) indicates that this function is implementing the 
 *       Lloyd algorithm to design a vector quantizer. 
 *    3) The third field (floor/ceil) represents the tie-breaking rule which are
 *       'take the lower index' or 'take the higher index'
 *       if the third field is 'CBupdate' the function is used to find updated codebook
 *       if the third field is 'main' the function is the main function
 *       if the third field is 'getentropy' the function is used to find entropy
 *    4) The fourth field (other than D) implies the type of weight 
 *       ((1) no W: no weight, (2) withWv, withWm <-- centroid CB update 
 *        (3) WvMean, WmMean <-- mean CB update method)
 *    5) The last field enumerates the I/O data type (only double precision, non-complex). 
 * 
 *    Examples: 
 *       DSPMEX_vqdes_floor_withWv_D is the vector quantizer design function
 *       which exploits Lloyd algorithm, and takes the lower index to break a tie. 
 *       weight is a vector, CB update method is centroid.
 *       I/O data types are only double precision, non-complex. 
 */ 

extern int_T DSPMEX_vqdes_main_D (
               const real_T  *u_train, 
               const real_T  *u_initCB,
                     real_T  *y_finalCB,
                     boolean_T NeedWeight,
                     boolean_T WdimSameAsTS,
                     int_T     CBupdateMethod,
               const real_T  *u_weight,
               const int_T    CodewordVectorLength,  
               const int_T    NumberOfCodewords,
               const int_T    NumberOfTrainingVector,
               const real_T   RelThreshold,
               const int_T    MaxIter,
                     real_T **ptrErr,
                     real_T **ptrEntropy,
                     int_T    TieBreakingRule,
                     int_T   *CountTSvecPtr,
                     real_T  *ErrPtr,
                     real_T  *SumTSvecPtr,
                     real_T  *SumWvecPtr);

extern void DSPMEX_vqdes_floor_noW_D (
           real_T *CodeBook,
           const int_T   CodewordVectorLength,
           const int_T   NumberOfCodewords,
           const real_T *TrainSet, 
           const int_T   NumberOfTrainingVector,
           const real_T *Weight,
                 int_T  *CountOfTSvec_inAgivenCell,
                 real_T *Err,
                 real_T *SumOfTSvecKthEle_inAgivenCell,
                 real_T *SumOfWvecKthEle_inAgivenCell);

extern void DSPMEX_vqdes_floor_withWv_D (
           real_T *CodeBook,
           const int_T   CodewordVectorLength,
           const int_T   NumberOfCodewords,
           const real_T *TrainSet, 
           const int_T   NumberOfTrainingVector,
           const real_T *Weight,
                 int_T  *CountOfTSvec_inAgivenCell,
                 real_T *Err,
                 real_T *SumOfTSvecKthEle_inAgivenCell,
                 real_T *SumOfWvecKthEle_inAgivenCell);

extern void DSPMEX_vqdes_floor_WvMean_D (
           real_T *CodeBook,
           const int_T   CodewordVectorLength,
           const int_T   NumberOfCodewords,
           const real_T *TrainSet, 
           const int_T   NumberOfTrainingVector,
           const real_T *Weight,
                 int_T  *CountOfTSvec_inAgivenCell,
                 real_T *Err,
                 real_T *SumOfTSvecKthEle_inAgivenCell,
                 real_T *SumOfWvecKthEle_inAgivenCell);

extern void DSPMEX_vqdes_floor_withWm_D (
           real_T *CodeBook,
           const int_T   CodewordVectorLength,
           const int_T   NumberOfCodewords,
           const real_T *TrainSet, 
           const int_T   NumberOfTrainingVector,
           const real_T *Weight,
                 int_T  *CountOfTSvec_inAgivenCell,
                 real_T *Err,
                 real_T *SumOfTSvecKthEle_inAgivenCell,
                 real_T *SumOfWvecKthEle_inAgivenCell);

extern void DSPMEX_vqdes_floor_WmMean_D (
           real_T *CodeBook,
           const int_T   CodewordVectorLength,
           const int_T   NumberOfCodewords,
           const real_T *TrainSet, 
           const int_T   NumberOfTrainingVector,
           const real_T *Weight,
                 int_T  *CountOfTSvec_inAgivenCell,
                 real_T *Err,
                 real_T *SumOfTSvecKthEle_inAgivenCell,
                 real_T *SumOfWvecKthEle_inAgivenCell);

extern void DSPMEX_vqdes_ceil_noW_D (
           real_T *CodeBook,
           const int_T   CodewordVectorLength,
           const int_T   NumberOfCodewords,
           const real_T *TrainSet, 
           const int_T   NumberOfTrainingVector,
           const real_T *Weight,
                 int_T  *CountOfTSvec_inAgivenCell,
                 real_T *Err,                            
                 real_T *SumOfTSvecKthEle_inAgivenCell,
                 real_T *SumOfWvecKthEle_inAgivenCell);

extern void DSPMEX_vqdes_ceil_withWv_D (
           real_T *CodeBook,
           const int_T   CodewordVectorLength,
           const int_T   NumberOfCodewords,
           const real_T *TrainSet, 
           const int_T   NumberOfTrainingVector,
           const real_T *Weight,
                 int_T  *CountOfTSvec_inAgivenCell,
                 real_T *Err,
                 real_T *SumOfTSvecKthEle_inAgivenCell,
                 real_T *SumOfWvecKthEle_inAgivenCell);

extern void DSPMEX_vqdes_ceil_WvMean_D (
           real_T *CodeBook,
           const int_T   CodewordVectorLength,
           const int_T   NumberOfCodewords,
           const real_T *TrainSet, 
           const int_T   NumberOfTrainingVector,
           const real_T *Weight,
                 int_T  *CountOfTSvec_inAgivenCell,
                 real_T *Err,
                 real_T *SumOfTSvecKthEle_inAgivenCell,
                 real_T *SumOfWvecKthEle_inAgivenCell);

extern void DSPMEX_vqdes_ceil_withWm_D (
           real_T *CodeBook,
           const int_T   CodewordVectorLength,
           const int_T   NumberOfCodewords,
           const real_T *TrainSet, 
           const int_T   NumberOfTrainingVector,
           const real_T *Weight,
                 int_T  *CountOfTSvec_inAgivenCell,
                 real_T *Err,
                 real_T *SumOfTSvecKthEle_inAgivenCell,
                 real_T *SumOfWvecKthEle_inAgivenCell);

extern void DSPMEX_vqdes_ceil_WmMean_D (
           real_T *CodeBook,
           const int_T   CodewordVectorLength,
           const int_T   NumberOfCodewords,
           const real_T *TrainSet, 
           const int_T   NumberOfTrainingVector,
           const real_T *Weight,
                 int_T  *CountOfTSvec_inAgivenCell,
                 real_T *Err,
                 real_T *SumOfTSvecKthEle_inAgivenCell,
                 real_T *SumOfWvecKthEle_inAgivenCell);

extern real_T DSPMEX_vqdes_CBupdate_noW_D (real_T *CodeBook,                      
                      const int_T   CodewordVectorLength,
                      const int_T   NumberOfCodewords,
                      const int_T   NumberOfTrainingVector,
                            int_T  *CountTSvecPtr,
                            real_T *ErrPtr,
                            real_T *SumTSvecPtr,
                            real_T *SumWvecPtr,
                            real_T *EntropyVal);

extern real_T DSPMEX_vqdes_CBupdate_WMean_D (real_T *CodeBook,
                      const int_T   CodewordVectorLength,
                      const int_T   NumberOfCodewords,
                      const int_T   NumberOfTrainingVector,
                            int_T  *CountTSvecPtr,
                            real_T *ErrPtr,
                            real_T *SumTSvecPtr,
                            real_T *SumWvecPtr,
                            real_T *EntropyVal);

extern real_T DSPMEX_vqdes_getentropy_D(int_T  *Count, 
                                      const int_T   NumberOfCodewords, 
                                      const int_T   NumberOfTrainingVector);


#define FALSE 0
#define TRUE  1
#define MAX_STRIDE 50

#endif /* dsp_vqdesign_h */

/* [EOF] dsp_vqdesign.h */

