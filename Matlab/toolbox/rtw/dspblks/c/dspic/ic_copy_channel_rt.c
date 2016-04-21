/* 
 * ic_copy_channel_rt.c
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.4.2.2 $  $Date: 2004/04/12 23:45:16 $
 *
 * Abstract:
 *   Copy functions for the initial condition handler.
 */

#include "dsp_rt.h"

EXPORT_FCN void MWDSP_CopyChannelICs( byte_T       *dstBuff, 
                           const byte_T *ICBuff, 
                           int_T         numChans, 
                           const int_T   sampsPerChan,
                           const int_T   bytesPerElem )
{
    while (numChans-- > 0) {
        int_T spc = sampsPerChan;
        
        /* Scalar expansion of current IC element over current channel elements */
        while (spc-- > 0) {
            memcpy( dstBuff, ICBuff, bytesPerElem );
            dstBuff += bytesPerElem;
        }

        ICBuff += bytesPerElem;
    }
}

/* [EOF] ic_copy_channel_rt.c */
