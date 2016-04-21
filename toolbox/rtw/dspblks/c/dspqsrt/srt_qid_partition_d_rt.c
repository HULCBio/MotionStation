/* QSRT_QID_PARTITION_D_RT Helper functions for Sort block in Signal Processing Blockset, data-type = double precision.
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.2.2.3 $  $Date: 2004/04/12 23:48:20 $
 */

#include "dspsrt_rt.h"

EXPORT_FCN int_T MWDSP_SrtQidPartitionD(const real_T *qid_array, int_T *qid_index,
                           int_T i, int_T j, int_T pivot )
{
    real_T pval = *(qid_array + *(qid_index + pivot));

    while (i <= j) {
        while( *( qid_array + *(qid_index+i) ) <  pval) {
            ++i;
        }
        while( *( qid_array + *(qid_index+j) ) >= pval) {
            --j;
        }
        if (i<j) {
            qid_Swap(i,j)
            ++i; --j;
        }
    }
    return(i);
}

/* [EOF] srt_qid_partition_d_rt.c */

