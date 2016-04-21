/*
 *  FLIP_MATRIX_ROW_OP_RT.C - Flip runtime helper function
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.6.2.2 $  $Date: 2004/04/12 23:45:07 $
 */
#include "dsp_rt.h"

EXPORT_FCN void MWDSP_FlipMatrixRowOP(const byte_T *u,
                           byte_T       *y,
                           int_T         numRows,
                           int_T         numCols,
                           int_T         bytesPerElement) {
    int_T r = numRows;
    const int_T maxCols = numCols - 1;

    while(r-- > 0) {
        int_T c = numCols;
        while(c-- > 0) {
            memcpy(y+(r+c*numRows)*bytesPerElement,
                   u+(r+(maxCols-c)*numRows)*bytesPerElement,
                   bytesPerElement);
        }
    }
}

/* [EOF] flip_matrix_row_op_rt.c */
