/*
 *  FLIP_MATRIX_COL_IP_RT.C - Flip runtime helper function
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.6.2.2 $  $Date: 2004/04/12 23:45:04 $
 */
#include "dsp_rt.h"

EXPORT_FCN void MWDSP_FlipMatrixColIP(byte_T  *y,
                           int_T    numRows,
                           int_T    numCols,
                           int_T    bytesPerElement) {
    byte_T tmp[MAX_BYTES_PER_CPLX_DTYPE];
    const int_T numRowsDivTwo = (int_T)(((uint_T)numRows) >> 1);
    int_T c = numCols;

    while(c-- > 0) {
        int_T r = numRowsDivTwo;
        const int_T colsToMove = c*numRows;
        /* cShift = bottom of colsToMove column */
        const int_T cShift = colsToMove + numRows - 1;
        while(r-- > 0) {
            memcpy(tmp,    
                   y+(colsToMove + r)*bytesPerElement,
                   bytesPerElement);
            memcpy(y+(colsToMove + r)*bytesPerElement,
                   y+(cShift - r)*bytesPerElement,
                   bytesPerElement);
            memcpy(y+(cShift - r)*bytesPerElement,
                   tmp,
                   bytesPerElement);
        }
    }
}

/* [EOF] flip_matrix_col_ip_rt.c */
