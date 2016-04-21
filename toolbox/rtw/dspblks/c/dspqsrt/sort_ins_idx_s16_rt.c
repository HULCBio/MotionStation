/* MWDSP_Sort_Ins_Val_S16 Function to sort an input array of real 
 * int16_T for Sort block in Signal Processing Blockset
 *
 *  Implement Insertion sort-by-index algorithm
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.1.6.2 $  $Date: 2003/11/29 20:35:09 $
 */

#include "dspsrt_rt.h"
#define MWDSP_SORT_DTYPE int16_T

EXPORT_FCN void MWDSP_Sort_Ins_Idx_S16(const int16_T *a, uint32_T *idx, int_T n)
{
    uint32_T i0 = idx[0];
    MWDSP_SORT_DTYPE t0 = a[i0];
    int_T i;
    for (i=1; i<n; i++) {
        uint32_T i1 = idx[i];
        MWDSP_SORT_DTYPE t1 = a[i1];
        if (t0 > t1) {
            int_T j;
            idx[i] = i0;
            for (j=i-1; j>0; j--) {
                uint32_T i2 = idx[j-1];
                MWDSP_SORT_DTYPE t2 = a[i2];
                if (t2 > t1) {
                    idx[j] = i2;
                } else {
                    break;
                }
            }
            idx[j] = i1;
        } else {
            t0 = t1;
            i0 = i1;
        }
    }
}

/* [EOF] */
