/*
 * recsnd.c - driver that includes the correct C code
 *            with respect to the supported architecures.
 *
 * $Revision: 1.1.6.1 $ $Date: 2003/07/11 15:54:07 $
 * Copyright 1984-2002 The MathWorks, Inc.
 */

#if defined(WIN32)
#include "recsnd_nt.c"

#else
#include "no_audio.c"

#endif

/* [EOF] recsnd.c */
