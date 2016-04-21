/*
 *  FLIP_VECTOR_OP_RT.C - Flip runtime helper function
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.6.2.2 $  $Date: 2004/04/12 23:45:09 $
 */
#include "dsp_rt.h"

EXPORT_FCN void MWDSP_FlipVectorOP(const byte_T *u,
                        byte_T       *y,
                        int_T        numRows,
                        int_T        numCols,
                        int_T        bytesPerElement) {
    const int_T maxIndex = numRows * numCols - 1;
    int_T i = maxIndex + 1;

    while( i-- > 0 ) {
        memcpy(y + i * bytesPerElement, 
               u + (maxIndex - i) * bytesPerElement, 
               bytesPerElement);
    }
}

/* [EOF] flip_vector_op_rt.c */
