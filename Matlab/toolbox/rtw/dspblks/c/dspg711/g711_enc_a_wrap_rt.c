/*
 *  G711_ENC_A_WRAP Helper function for G711 block.
 *
 *  Copyright 2003 The MathWorks, Inc.
 *  $Revision: 1.1.6.2 $  $Date: 2003/07/10 19:58:39 $
 */
#include "dspg711_rt.h"

EXPORT_FCN void MWDSP_G711EncAWrap(const int16_T *u, uint8_T *y, int nElems)
{
    static int16_T A_SEG_BOUNDARIES[8] = {0x1F, 0x3F, 0x7f, 0xFF,
                                      0x1FF, 0x3FF, 0x7FF, 0xFFF};
    int_T         i;

    for (i = 0; i < nElems; i++) {
        int16_T inPcmVal = u[i] & 0x9FFF;
        int16_T mask     = (inPcmVal >= 0) ? 0xD5 : 0x55;
        uint8_T seg;

        inPcmVal = (inPcmVal >= 0) ? inPcmVal : (-inPcmVal-1);

        for (seg = 0; seg < 8; seg++) {
            if (inPcmVal <= A_SEG_BOUNDARIES[seg]) {
                break;
            }
        }
        
        y[i] = (((inPcmVal >> ((seg==0) ? 1 : seg)) & 0x0F) | (seg << 4))^mask;
    }
}
/* [EOF] g711_enc_a_wrap_rt */

