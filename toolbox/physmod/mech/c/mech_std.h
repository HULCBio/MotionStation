#ifndef __mech_std_h__
#define __mech_std_h__

/***************************************************************
 ** File    :mech_std.h
 ** Abstract:
 **      Types and macros for standalone SimMechanics
 **
 ** Copyright 2002-2003 The MathWorks, Inc.
 **
 ***************************************************************/



/**************************
 ** Includes 
 **************************/

/*
 * types
 */
#include "tmwtypes.h"

/*
 * system header files
 */
#include <math.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdarg.h>
#include <float.h>

/**************************
 ** Macros and Prototypes
 **************************/

/*
 * real numbers
 */
real_T   pmGetEps(void);
real_T   pmGetPI(void);
double   pmGetRealMax(void);
double   pmGetRealMin(void);

/*
 * string functions
 */
#define  pmStrcpy   strcpy
#define  pmStrncpy  strncpy
#define  pmPrintf   printf

/*
 * method registration
 */
#define REQUEST_METHOD(_table, _meth) mech_method_table._meth##_method; (void) _table;
#define REQUEST_VMETHOD(_vmt, _table, _meth) *(_vmt->_meth##_vmethod); (void) _table;

#define MECH_DEFINE_PROTOTYPES
#define MECH_DEFINE_METHOD_TABLE
#define MECH_IMPLEMENT_METHOD_TABLE

#endif /* __mech_std_h__ */

/* [EOF] mech_std.h */

