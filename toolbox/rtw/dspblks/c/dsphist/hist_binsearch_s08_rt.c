/* MWDSP_Hist_BinSearch_S08 Function to perform binary search on
 * a real input array of int8_T for Histogram block in Signal Processing Blockset
 *
 *  Implement binary search algorithm
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.1.6.1 $  $Date: 2003/12/06 15:56:23 $
 */

#include "dsphist_rt.h"

EXPORT_FCN void MWDSP_Hist_BinSearch_S08(int_T     firstBin, 
                                         int_T     lastBin, 
                                         int8_T    data, 
                                         const int8_T    *bin,
                                         uint32_T  *hist )
{
    int_T binIdx = firstBin + ((lastBin-firstBin+1)>>1);

    if (data <  bin[binIdx-1]) {            /* data < lower bin boundary */
        if ((binIdx - 1) <= firstBin) {
            hist[firstBin]++;  
            return;
        } else {
            MWDSP_Hist_BinSearch_S08(firstBin, binIdx - 1, data, bin, hist);
        }

    } else if (data > bin[binIdx]) {        /* data > upper bin boundary */
        if ((lastBin - binIdx) <= 1) {
            hist[lastBin]++;  
            return;
        } else {
            MWDSP_Hist_BinSearch_S08(binIdx, lastBin, data, bin, hist);
        }
        
    } else if (data == bin[binIdx - 1]) {   /* data == lower bin boundary */
        hist[binIdx-1]++;
        return;

    } else {                                /* data <= upper bin boundary */
        hist[binIdx]++;
        return;
    } 
}

/* [EOF] */
