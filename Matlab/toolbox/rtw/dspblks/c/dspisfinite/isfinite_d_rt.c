/*
 *  isfinite_d_rt.c
 *
 *  Copyright 1995-2004 The MathWorks, Inc.
 *  $Revision: 1.3.2.3 $ $Date: 2004/04/12 23:46:29 $
 */
#include "dspisfinite_rt.h"
#include "dspendian_rt.h"

EXPORT_FCN int_T dspIsFinite(double x)
{
	int hx;

	if (isLittleEndian()) {
		hx = *(1+(int32_T*)&x); /* Little Endian */
	} else {
		hx = *((int32_T *)&x); /* Big Endian */
	}

	return (int32_T) (((uint32_T)((hx & 0x7fffffff)-0x7ff00000)>>31) != 0);	
}

/* [EOF] isfinite_d_rt.c */
