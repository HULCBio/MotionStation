/* 
 * ic_copy_matrix_rt.c
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.4.2.2 $  $Date: 2004/04/12 23:45:17 $
 *
 * Abstract:
 *   Copy functions for the initial condition handler.
 */

#include "dsp_rt.h"

EXPORT_FCN void MWDSP_CopyMatrixICs( byte_T       *dstBuff, 
                          const byte_T *ICBuff, 
                          const int_T   numElems, 
                          const int_T   bytesPerElem )
{
    memcpy( dstBuff, ICBuff, numElems * bytesPerElem );
}

/* [EOF] ic_copy_matrix_rt.c */
