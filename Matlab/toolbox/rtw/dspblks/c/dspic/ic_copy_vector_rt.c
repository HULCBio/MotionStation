/* 
 * ic_copy_vector_rt.c
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.4.2.2 $  $Date: 2004/04/12 23:45:19 $
 *
 * Abstract:
 *   Copy functions for the initial condition handler.
 */

#include "dsp_rt.h"

EXPORT_FCN void MWDSP_CopyVectorICs( byte_T       *dstBuff, 
                          const byte_T *ICBuff, 
                          int_T         numChans, 
                          const int_T   bytesPerChan )
{
    while (numChans-- > 0) {
        memcpy( dstBuff, ICBuff, bytesPerChan );
        dstBuff += bytesPerChan;
    }
}

/* [EOF] ic_copy_vector_rt.c */
