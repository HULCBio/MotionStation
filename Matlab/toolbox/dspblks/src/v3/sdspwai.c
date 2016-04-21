/*
 * SDSPWAI: DSP Blockset S-function implementing
 *          wave audio output device
 *
 * Copyright 1995-2002 The MathWorks, Inc.
 * $Revision: 1.12 $ $Date: 2002/04/14 20:43:37 $
 */
#define S_FUNCTION_NAME  sdspwai
#define S_FUNCTION_LEVEL 2

#ifdef WIN32
#   include "dsp_wai_win32.c"
#else
#   include "dsp_wave_in_err.c"
#endif

/* [EOF] sdspwai.c */
