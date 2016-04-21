/*
 * DSP_TRAILER DSP Blockset Trailer Code for C-MEX S-Functions.
 *
 *    Standard block of code to be included at
 *    the very end of all C-MEX S-Functions.
 *
 *  Copyright 1995-2002 The MathWorks, Inc.
 *  $Revision: 1.7 $  $Date: 2002/04/14 20:35:26 $
 */

#ifdef __cplusplus
#  include "mdl_sfcn.hpp"
extern "C" {
#endif

#ifdef  MATLAB_MEX_FILE    
#include "simulink.c"      
#else
#include "cg_sfun.h"       
#endif

#ifdef __cplusplus
}
#endif

/* [EOF] dsp_trailer.c */
