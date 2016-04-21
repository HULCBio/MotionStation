/* MWDSP_Sort_Qk_Val_U08 Function to sort an input array of real 
 * uint8_T for Sort block in Signal Processing Blockset
 *
 *  Implement Quicksort in-place sort-by-value algorithm
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.1.6.3 $  $Date: 2004/04/12 23:48:15 $
 */

#include "dspsrt_rt.h"

static boolean_T findPivot(uint8_T *dataArray, int_T i, int_T j, int_T *pivot )
{
    int_T   mid = (i+j)>>1;
    int_T   k;
    uint8_T  a, b, c;

    if(dataArray[i] > dataArray[mid]) {
        uint8_T   tmp = dataArray[i];
        dataArray[i] = dataArray[mid];
        dataArray[mid] = tmp;
    }
    if(dataArray[i] > dataArray[j]) {
        uint8_T   tmp = dataArray[i];
        dataArray[i] = dataArray[j];
        dataArray[j] = tmp;
    }
    if(dataArray[mid] > dataArray[j]) {
        uint8_T   tmp = dataArray[mid];
        dataArray[mid] = dataArray[j];
        dataArray[j] = tmp;
    }

    a = dataArray[i];
    b = dataArray[mid];
    c = dataArray[j];

    if (a < b) {   
        *pivot = mid;
        return((boolean_T)1);
    }
    if (b < c) {
        *pivot = j;
        return((boolean_T)1);
    }
    for (k=i+1; k <= j; k++) {
        uint8_T d = dataArray[k];
        if (d != a) {
          *pivot = (d < a) ? i : k ;
          return((boolean_T)1);
        }
    }
    return((boolean_T)0);

}

static int_T partition(uint8_T *dataArray, int_T i, int_T j, int_T pivot )
{
    uint8_T pval = dataArray[pivot];

    while (i <= j) {
        while(dataArray[i] < pval) {
            ++i;
        }
        while(dataArray[j] >= pval) {
            --j;
        }
        if (i<j) {
            uint8_T   tmp = dataArray[i];
            dataArray[i] = dataArray[j];
            dataArray[j] = tmp;
            ++i; 
            --j;
        }
    }
    return(i);
}

/* The recursive quicksort routine: */
EXPORT_FCN void MWDSP_Sort_Qk_Val_U08(uint8_T *dataArray, int_T i, int_T j )
{
    int_T pivot;
    if (findPivot(dataArray, i, j, &pivot)) {
        int_T k = partition(dataArray, i, j, pivot);
        MWDSP_Sort_Qk_Val_U08(dataArray, i, k-1);
        MWDSP_Sort_Qk_Val_U08(dataArray, k, j);
    }
}


/* [EOF] */
