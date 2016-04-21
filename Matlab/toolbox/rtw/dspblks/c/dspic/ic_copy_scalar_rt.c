/* 
 * ic_copy_scalar_rt.c
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.4.2.2 $  $Date: 2004/04/12 23:45:18 $
 *
 * Abstract:
 *   Copy functions for the initial condition handler.
 */

#include "dsp_rt.h"

EXPORT_FCN void MWDSP_CopyScalarICs( byte_T       *dstBuff, 
                          const byte_T *ICBuff, 
                          int_T         numElems, 
                          const int_T   bytesPerElem )
{
    while (numElems-- > 0) {
        memcpy( dstBuff, ICBuff, bytesPerElem );
        dstBuff += bytesPerElem;
    }
}

/* [EOF] ic_copy_scalar_rt.c */
