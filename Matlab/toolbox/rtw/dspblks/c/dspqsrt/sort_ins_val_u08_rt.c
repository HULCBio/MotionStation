/* MWDSP_Sort_Ins_Val_U08 Function to sort an input array of real 
 * singles for Sort block in Signal Processing Blockset
 *
 *  Implement Insertion sort-by-value algorithm
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.1.6.2 $  $Date: 2003/11/29 20:35:19 $
 */

#include "dspsrt_rt.h"
#define MWDSP_SORT_DTYPE uint8_T

/* insertion sort in-place by value */
EXPORT_FCN void MWDSP_Sort_Ins_Val_U08(uint8_T *a, int_T n )
{
    MWDSP_SORT_DTYPE t0 = a[0];
    int_T i;
    for (i=1; i<n; i++) {
        MWDSP_SORT_DTYPE t1 = a[i];
        if (t0 > t1) {
            int_T j;
            a[i] = t0;
            for (j=i-1; j>0; j--) {
                MWDSP_SORT_DTYPE t2 = a[j-1];
                if (t2 > t1) {
                    a[j] = t2;
                } else {
                    break;
                }
            }
            a[j] = t1;
        } else {
            t0 = t1;
        }
    }
}

/* [EOF] */
