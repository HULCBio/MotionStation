/* SRT_REC_Z_RT Function to sort an input array of complex doubles for Sort block in Signal Processing Blockset.
 *
 * Implement Quicksort algorithm using indices (qid)
 * Note: this algorithm is different from MATLAB's sorting
 * for complex values with same magnitude.
 *
 * Sorts an array of doubles based on the "Quicksort" algorithm,
 * using an index vector rather than the data itself.
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.2.2.3 $  $Date: 2004/04/12 23:48:25 $
 */

#include "dspsrt_rt.h"

EXPORT_FCN void MWDSP_SrtQkRecZ(const creal_T *qid_array, int_T *qid_index, real_T *sort, 
                        int_T i, int_T j )
{
    int_T pivot,cntr;
    for(cntr=0;cntr<=j;cntr++) {
        creal_T val = qid_array[cntr]; 
        sort[cntr] = CMAGSQ(val);  
    }
    if (MWDSP_SrtQidFindPivotD(sort, qid_index, i, j, &pivot)) {
        int_T k = MWDSP_SrtQidPartitionD(sort, qid_index, i, j, pivot);
        MWDSP_SrtQkRecD(sort, qid_index, i, k-1);
        MWDSP_SrtQkRecD(sort, qid_index, k, j);
    }
}

/* [EOF] srt_qkrec_z_rt.c */

