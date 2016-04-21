/*****************************************************************************
******************************************************************************
*
*               Include file to be included by models compiled for
*               the Real-Time Windows Target.
*
*               $Revision: 1.14 $
*               $Date: 2002/04/14 18:54:39 $
*               $Author: batserve $
*
*               Copyright 1994-2002 The MathWorks, Inc.
*
******************************************************************************
*****************************************************************************/


#ifndef __RTWINTGT_H_INCLUDED
#define __RTWINTGT_H_INCLUDED


/* include types common for generated target code and the loader */

#include <rtwintyp.h>


/* Real-Time Windows Target library function prototypes */

int RTBIO_DriverIO(int drv, DRVIOACTION action, int method, int n, const int* ch, double* val, const void* parm);


/* macros for some math functions not in the RTWT library */

#define asin(x) atan2( (x), sqrt(1-(x)*(x)) )
#define acos(x) atan2( sqrt(1-(x)*(x)), (x) )
#define cosh(x) ( (exp(x)+exp(-(x)))/2 )
#define sinh(x) ( (exp(x)-exp(-(x)))/2 )
#define tanh(x) ( 1-(2/(exp(2*(x))+1)) )


#endif // __RTWINTGT_H_INCLUDED
