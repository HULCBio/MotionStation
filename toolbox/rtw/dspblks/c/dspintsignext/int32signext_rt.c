/*
 * INT32SIGNEXT_RT.C
 *
 * Runtime C code for 32-bit integer sign extension
 *
 * Copyright 1995-2003 The MathWorks, Inc.
 * $Revision: 1.1.6.1 $ $Date: 2003/06/03 16:11:13 $
 */

#include "dspintsignext_rt.h"

MWDSP_IDECL void MWDSP_SignExtendInt32(int32_T *valPtr, int signBitIndex)
{
    static const int32_T MWDSP_sMaskBit[] = {
        0x00000001, 0x00000002, 0x00000004, 0x00000008,
        0x00000010, 0x00000020, 0x00000040, 0x00000080,
        0x00000100, 0x00000200, 0x00000400, 0x00000800,
        0x00001000, 0x00002000, 0x00004000, 0x00008000,
        0x00010000, 0x00020000, 0x00040000, 0x00080000,
        0x00100000, 0x00200000, 0x00400000, 0x00800000,
        0x01000000, 0x02000000, 0x04000000, 0x08000000,
        0x10000000, 0x20000000, 0x40000000
    };

    static const int32_T MWDSP_sMaskLo[]={
        0x00000001, 0x00000003, 0x00000007, 0x0000000F,
        0x0000001F, 0x0000003F, 0x0000007F, 0x000000FF,
        0x000001FF, 0x000003FF, 0x000007FF, 0x00000FFF,
        0x00001FFF, 0x00003FFF, 0x00007FFF, 0x0000FFFF,
        0x0001FFFF, 0x0003FFFF, 0x0007FFFF, 0x000FFFFF,
        0x001FFFFF, 0x003FFFFF, 0x007FFFFF, 0x00FFFFFF,
        0x01FFFFFF, 0x03FFFFFF, 0x07FFFFFF, 0x0FFFFFFF,
        0x1FFFFFFF, 0x3FFFFFFF
    };

    /* Do nothing if already using 32-bit word lengths,
     * otherwise perform sign extension on < 32-bit WLs
     */
    if (signBitIndex < 32) {
        if (*valPtr & (MWDSP_sMaskBit[signBitIndex-1]))
        {
            *valPtr |= (~MWDSP_sMaskLo[signBitIndex-2]);
        }
        else
        {
            *valPtr &= MWDSP_sMaskLo[signBitIndex-2];
        }
    }
}

/* [EOF] */
