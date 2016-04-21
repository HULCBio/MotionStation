/* $Revision: 1.2.2.3 $ */
/*
 *  isfinite_r_rt.c
 *
 *  Copyright 1995-2004 The MathWorks, Inc.
 */
#include "dspisfinite_rt.h"

EXPORT_FCN int_T dspIsFinite32(float x)
{
    return (int32_T) ((uint32_T)(((*((int32_T *)&x)) & 0x7fffffff) - 0x7f800000) >> 31 != 0);
}

/* [EOF] isfinite_d_rt.c */
