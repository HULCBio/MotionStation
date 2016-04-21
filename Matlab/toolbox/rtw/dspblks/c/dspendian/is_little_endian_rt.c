/*
 *  is_little_endian_rt.c
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.3.2.2 $ $Date: 2004/04/12 23:42:46 $
 */
#include "dspendian_rt.h"

EXPORT_FCN int_T isLittleEndian(void)
{
	int16_T  endck  = 1;
	int8_T  *pendck = (int8_T *)&endck;
	return(pendck[0] == (int8_T)1);
}

/* [EOF] is_little_endian_rt.c */
