/*
 * SDSPWAFI: DSP Blockset S-function implementing
 *           wave audio input file
 *
 * Copyright 1995-2002 The MathWorks, Inc.
 * $Revision: 1.10 $ $Date: 2002/04/14 20:43:31 $
 */
#define S_FUNCTION_NAME  sdspwafi
#define S_FUNCTION_LEVEL 2

#ifdef WIN32
#   include "dsp_wafi_win32.c"
#else
#   include "dsp_wave_in_err.c"
#endif

/* [EOF] sdspwafi.c */
