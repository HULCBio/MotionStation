/*
 * SDSPWAFO: DSP Blockset S-function implementing
 *           wave audio output file
 *
 * Copyright 1995-2002 The MathWorks, Inc.
 * $Revision: 1.8 $ $Date: 2002/04/14 20:43:34 $
 */
#define S_FUNCTION_NAME  sdspwafo
#define S_FUNCTION_LEVEL 2

#ifdef WIN32
#   include "dsp_wafo_win32.c"
#else
#   include "dsp_wave_out_err.c"
#endif

/* [EOF] sdspwafo.c */
