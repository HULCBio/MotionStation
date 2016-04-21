/* QSRT_R_RT Function to sort an input array of complex singles for Sort block in Signal Processing Blockset.
 *
 * Implement Quicksort algorithm using indices (qid)
 * Note: this algorithm is different from MATLAB's sorting
 * for complex values with same magnitude.
 *
 * Sorts an array of singles based on the "Quicksort" algorithm,
 * using an index vector rather than the data itself.
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.2.2.3 $  $Date: 2004/04/12 23:48:22 $
 */

#include "dspsrt_rt.h"

EXPORT_FCN void MWDSP_SrtQkRecC(const creal32_T *qid_array, int_T *qid_index, real32_T *sort,
                        int_T i, int_T j )
{
    int_T pivot,cntr;
    for(cntr=0;cntr<=j;cntr++) {
        creal32_T val = qid_array[cntr]; 
        sort[cntr] = CMAGSQ(val);  
    }
    if (MWDSP_SrtQidFindPivotR(sort, qid_index, i, j, &pivot)) {
        int_T k = MWDSP_SrtQidPartitionR(sort, qid_index, i, j, pivot);
        MWDSP_SrtQkRecR(sort, qid_index, i, k-1);
        MWDSP_SrtQkRecR(sort, qid_index, k, j);
    }
}

/* [EOF] srt_qkrec_c_rt.c */

