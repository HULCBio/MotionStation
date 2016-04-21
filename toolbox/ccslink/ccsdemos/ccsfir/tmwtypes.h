/*-------------------------------------------------------------------*
 * MATLAB data type conversion for Texas Instruments(R) DSP processors
 *-------------------------------------------------------------------*
 * Copyright 2001-2003 The MathWorks, Inc.
 * $Revision: 1.7.4.1 $ $Date: 2003/11/30 23:03:36 $
 *-------------------------------------------------------------------*/

#ifdef _TMS320C6X	
typedef unsigned char  uint8;
typedef unsigned short uint16;
typedef unsigned int   uint32;
typedef char           int8;
typedef short          int16;
typedef int            int32;
typedef float          single;
#elif (__TMS320C55X__ || _TMS320C5XX) 
typedef unsigned short uint16;
typedef unsigned long  uint32;
typedef short          int16;
typedef long           int32;
typedef float          single;
#elif (_TMS320C28X || _TMS320C27X)
typedef unsigned short uint16;
typedef unsigned long  uint32;
typedef short          int16;
typedef long           int32;
typedef float          single;
#elif _TMS320C2XX
typedef unsigned short uint16;
typedef unsigned long  uint32;
typedef short          int16;
typedef long           int32;
typedef float          single;
#elif __TMS470__
typedef unsigned char  uint8;
typedef unsigned short uint16;
typedef unsigned int   uint32;
typedef signed char    int8;
typedef short          int16;
typedef int            int32;
typedef float          single;	
#endif

/*-------------------------------------------------------------------*
 * Define a boolean type
 *-------------------------------------------------------------------*/
typedef enum {NO=0,YES} bool;

