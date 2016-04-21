/* MWDSP_Sort_Qk_Idx_U08 Function to sort an input array of real 
 * uint8_T for Sort block in Signal Processing Blockset.
 *
 * Implement Quicksort algorithm using indices
 * Note: this algorithm is different from MATLAB's sorting
 * for complex values with same magnitude.
 *
 * Sorts an array of singles based on the "Quicksort" algorithm,
 * using an index vector rather than the data itself.
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.1.6.3 $  $Date: 2004/04/12 23:48:07 $
 */

#include "dspsrt_rt.h"

static boolean_T findPivot(const uint8_T *dataArray, uint32_T *idxArray,
                               int_T i, int_T j, int_T *pivot )
{
    int_T  mid = (i+j)/2;
    int_T  k;
    uint8_T a, b, c;

    qsortIdxOrder3(i,mid,j);    /* order the 3 values */
    a = *(dataArray + *(idxArray + i  ));
    b = *(dataArray + *(idxArray + mid));
    c = *(dataArray + *(idxArray + j  ));

    if (a < b) {   /* pivot will be higher of 2 values */
        *pivot = mid;
        return((boolean_T)1);
    }
    if (b < c) {
        *pivot = j;
        return((boolean_T)1);
    }
    for (k=i+1; k <= j; k++) {
        uint8_T d = *(dataArray + *(idxArray + k));
        if (d != a) {
          *pivot = (d < a) ? i : k ;
          return((boolean_T)1);
        }
    }
    return((boolean_T)0);
}

static int_T partition(const uint8_T *dataArray, uint32_T *idxArray,
                           int_T i, int_T j, int_T pivot )
{
    uint8_T pval = *(dataArray + *(idxArray + pivot));

    while (i <= j) {
        while( *( dataArray + *(idxArray+i) ) <  pval) {
            ++i;
        }
        while( *( dataArray + *(idxArray+j) ) >= pval) {
            --j;
        }
        if (i<j) {
            qsortIdxSwap(i,j)
            ++i; --j;
        }
    }
    return(i);
}

/* The recursive quicksort routine: */
EXPORT_FCN void MWDSP_Sort_Qk_Idx_U08(const uint8_T *dataArray, uint32_T *idxArray,
                        int_T i, int_T j )
{
    int_T pivot;
    if (findPivot(dataArray, idxArray, i, j, &pivot)) {
        int_T k = partition(dataArray, idxArray, i, j, pivot);
        MWDSP_Sort_Qk_Idx_U08(dataArray, idxArray, i, k-1);
        MWDSP_Sort_Qk_Idx_U08(dataArray, idxArray, k, j);
    }
}


/* [EOF] */
