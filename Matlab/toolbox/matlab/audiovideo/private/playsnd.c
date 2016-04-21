/*
 * playsnd.c - driver that includes the appropriate
 *    platform-dependent code.
 *
 * $Revision: 1.1.6.2 $ $Date: 2004/04/15 00:00:25 $
 * Copyright 1984-2004 The MathWorks, Inc.
 */

#if defined(ARCH_MAC)
#include "playsnd_mac.c"

#elif defined(WIN32)
#include "playsnd_nt.c"

#else
#include "no_audio.c"

#endif

/* [EOF] playsnd.c */
