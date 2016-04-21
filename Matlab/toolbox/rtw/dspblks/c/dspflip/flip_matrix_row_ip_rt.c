/*
 *  FLIP_MATRIX_ROW_IP_RT.C - Flip runtime helper function
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.6.2.2 $  $Date: 2004/04/12 23:45:06 $
 */
#include "dsp_rt.h"

EXPORT_FCN void MWDSP_FlipMatrixRowIP(byte_T  *y,
                           int_T    numRows,
                           int_T    numCols,
                           int_T    bytesPerElement) {
    byte_T tmp[MAX_BYTES_PER_CPLX_DTYPE];
    const int_T numColsDivTwo = (int_T)(((uint_T)numCols) >> 1);
    int_T r = numRows;
    const int_T maxCols = numCols - 1;
    while(r-- > 0) {
        int_T c = numColsDivTwo;
        while (c-- > 0) {
            memcpy(tmp,    
                   y+(r+c*numRows)*bytesPerElement,
                   bytesPerElement);
            memcpy(y+(r+c*numRows)*bytesPerElement,
                   y+(r+(maxCols-c)*numRows)*bytesPerElement,
                   bytesPerElement);
            memcpy(y+(r+(maxCols-c)*numRows)*bytesPerElement,
                   tmp,
                   bytesPerElement);
        }
    }
}

/* [EOF] flip_matrix_row_ip_rt.c */
