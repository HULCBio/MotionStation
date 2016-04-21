/*
 *  FLIP_VECTOR_IP_RT.C - Flip runtime helper function
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.7.2.2 $  $Date: 2004/04/12 23:45:08 $
 */
#include "dsp_rt.h"

EXPORT_FCN void MWDSP_FlipVectorIP(byte_T  *y,
                        int_T  numRows,
                        int_T  numCols,
                        int_T  bytesPerElement) {
    const int_T maxIndex = numRows * numCols - 1;
    int_T maxIndexDivTwo = (int_T)(((uint_T)maxIndex + 1) >> 1);
    byte_T tmp[MAX_BYTES_PER_CPLX_DTYPE];

    while ( maxIndexDivTwo-- > 0 ) {
            memcpy(tmp,
                   y + maxIndexDivTwo * bytesPerElement,
                   bytesPerElement);
            memcpy(y + maxIndexDivTwo * bytesPerElement, 
                   y + (maxIndex - maxIndexDivTwo) * bytesPerElement, 
                   bytesPerElement);
            memcpy(y + (maxIndex - maxIndexDivTwo) * bytesPerElement,
                   tmp,
                   bytesPerElement);
    }
}

/* [EOF] flip_vector_ip_rt.c */
