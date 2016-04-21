/* Copyright 1994-2002 The MathWorks, Inc.
 *
 * File    : rt_fuzzy.h
 * Abstract:
 *      Entry point to include fuzzy toolbox specific header files.
 *
 * $Author: batserve $
 * $Revision: 1.8 $
 * $Date: 2002/04/14 10:14:28 $
 */

#ifndef __STDC__
# define __STDC__ 1
#endif

#ifdef UNIX

# include "../../../toolbox/fuzzy/fuzzy/src/fis.h"

#else

# include "..\..\..\toolbox\fuzzy\fuzzy\src\fis.h"

#endif

/* [EOF] rt_fuzzy.h */
