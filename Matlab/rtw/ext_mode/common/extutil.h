/* $Revision: 1.1.6.1 $ */
#ifndef __EXTUTIL__
#define __EXTUTIL__

/*
 * Copyright 1994-2002 The MathWorks, Inc.
 *
 * File    : extutil.h
 * Abstract:
 *  Utilities such as assert.
 */

/*
 * Set ASSERTS_ON to 1 turn asserts on, 0 otherwise.
 */
#define ASSERTS_ON (1)

/*------------------------------------------------------------------------------
 * Do not modify below this line.
 *----------------------------------------------------------------------------*/
#if ASSERTS_ON
#include <assert.h>
#else
#define assert(dum) /* do nothing */
#endif

#endif /* __EXTUTIL__ */
