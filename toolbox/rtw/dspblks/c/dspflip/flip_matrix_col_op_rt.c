/*
 *  FLIP_MATRIX_COL_OP_RT.C - Flip runtime helper function
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.6.2.2 $  $Date: 2004/04/12 23:45:05 $
 */
#include "dsp_rt.h"

EXPORT_FCN void MWDSP_FlipMatrixColOP(const byte_T *u,
                           byte_T       *y,
                           int_T         numRows,
                           int_T         numCols,
                           int_T         bytesPerElement) {
    int_T c = numCols;

    while(c-- > 0) {
        int_T r = numRows;
        const int_T colsToMove = c*numRows;
        /* cShift = bottom of colsToMove column */
        const int_T cShift = colsToMove + numRows - 1;
        while(r-- > 0) { 
            memcpy(y+(colsToMove+r)*bytesPerElement,
                   u+(cShift-r)*bytesPerElement,
                   bytesPerElement);
        }
    }
}

/* [EOF] flip_matrix_col_op_rt.c */
