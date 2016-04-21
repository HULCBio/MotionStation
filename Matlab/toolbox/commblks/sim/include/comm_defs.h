/*
* COMM_DEFS.H Communications Blockset S-Function include file
* for definitions and deciding which of the communications/
* DSP files to include for the simulation only case and for
* the realtime code generation case.
*
*
*   Copyright 1996-2003 The MathWorks, Inc.
*   $Revision: 1.1.6.3 $
*   $Date: 2004/04/12 23:03:11 $
*/

#ifndef __COMM_DEFS__
#define __COMM_DEFS__

/* DSP files to include for all s-functions
 *
 *  Include dsp_sim.h for simulation and dsp_rt.h for RTW (without TLC's)
 *
 */

#include "comm_hs_err.h"
#include "comm_mask_err.h"
#include "comm_hs_defs.h"
#include "comm_algo_defs.h"

#ifdef MATLAB_MEX_FILE
  #include "comm_sim.h"
#else
  #include "comm_rt.h"
#endif														                              		   

#endif /* __COMM_DEFS__ */

