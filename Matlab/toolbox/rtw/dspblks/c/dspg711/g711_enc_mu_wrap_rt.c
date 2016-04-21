/*
 *  G711_ENC_MU_WRAP Helper function for G711 block.
 *
 *  Copyright 2003 The MathWorks, Inc.
 *  $Revision: 1.1.6.2 $  $Date: 2003/07/10 19:58:41 $
 */

#include "dspg711_rt.h"

EXPORT_FCN void MWDSP_G711EncMuWrap(const int16_T *u, uint8_T *y, int nElems)
{
    static int16_T MU_SEG_BOUNDARIES[8] = {0x3F, 0x7F, 0xFF, 0x1FF, 
                                           0x3FF, 0x7FF, 0xFFF, 0x1FFF};
    int_T         i;

    for (i = 0; i < nElems; i++) {
        int16_T inPcmVal = u[i];
        int16_T mask;
        uint8_T seg;

        inPcmVal &= 0xBFFF;

        mask     = (inPcmVal >= 0) ? 0xFF : 0x7F;
        inPcmVal = (inPcmVal >= 0) ? inPcmVal : -inPcmVal;

        inPcmVal  = (inPcmVal > 8158) ? 8158 : inPcmVal; /* Clip */
        inPcmVal += 33; /* Add bias */

        for (seg = 0; seg < 8; seg++) {
            if (inPcmVal <= MU_SEG_BOUNDARIES[seg]) {
                break;
            }
        }

        y[i] = ((seg << 4) | ((inPcmVal >> (seg + 1)) & 0x0F)) ^ mask;
    }
}
/* [EOF] g711_enc_mu_wrap_rt */

