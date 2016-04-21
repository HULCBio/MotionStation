/*
 * playsndb.c - driver that includes the appropriate
 *    platform-dependent code.
 *
 *  Win95/98/NT: playsndb_nt.c
 *   All others: no_audio.c
 *
 * Copyright 1984-2002 The MathWorks, Inc. 
 * $Revision: 1.1.6.1 $ $Date: 2003/07/11 15:54:02 $
 */

#if defined(WIN32)
#include "playsndb_nt.c"

#else
#include "no_audio.c"

#endif

/* [EOF] playsndb.c */
