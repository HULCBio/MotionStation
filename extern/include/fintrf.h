#if defined(WITH_COMMENTS)
/*
 * fintrf.h	- MATLAB/FORTRAN interface header file. This file
 *		  contains the declaration of the pointer type needed
 *		  by the MATLAB/FORTRAN interface.
 *
 * Copyright (c) 1984-98 by The MathWorks, Inc.
 * All Rights Reserved.
 * $Revision: 1.11.6.3 $  $Date: 2004/04/06 00:30:20 $
 */
/*
 * Can't use _LP64 here because e.g. efc doesn't define it
 * Revisit as more _LP64 platforms come on-line
 */
#endif
#if defined( __ia64__ ) || defined (__x86_64__ )
#define mwpointer integer*8
#define MWPOINTER INTEGER*8
#else
#define mwpointer integer
#define MWPOINTER INTEGER
#endif

