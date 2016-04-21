/* QSRT_QID_FINDPIVOT_D_RT Helper functions for Sort block in Signal Processing Blockset, data-type = double precision.
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.2.2.3 $  $Date: 2004/04/12 23:48:18 $
 */

#include "dspsrt_rt.h"

EXPORT_FCN boolean_T MWDSP_SrtQidFindPivotD(const real_T *qid_array, int_T *qid_index,
                               int_T i, int_T j, int_T *pivot )
{
    int_T  mid = (i+j)/2;
    int_T  k;
    real_T a, b, c;

    qid_Order3(i,mid,j);    /* order the 3 values */
    a = *(qid_array + *(qid_index + i  ));
    b = *(qid_array + *(qid_index + mid));
    c = *(qid_array + *(qid_index + j  ));

    if (a < b) {   /* pivot will be higher of 2 values */
        *pivot = mid;
        return((boolean_T)1);
    }
    if (b < c) {
        *pivot = j;
        return((boolean_T)1);
    }
    for (k=i+1; k <= j; k++) {
        real_T d = *(qid_array + *(qid_index + k));
        if (d != a) {
          *pivot = (d < a) ? i : k ;
          return((boolean_T)1);
        }
    }
    return((boolean_T)0);
}

/* [EOF] srt_qid_findpivot_d_rt.c */


