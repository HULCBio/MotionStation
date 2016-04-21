/* $Revision: 1.3.4.2 $ */
/* 
 *  DSPUNWRAP_RT Runtime functions for DSP Blockset Uwrap block.
 *
 *  Removes phase discontinuities by adding or subtracting 2*pi.
 * 
 *  Copyright 1995-2003 The MathWorks, Inc.
 *
 */ 

#ifndef dspunwrap_rt_h
#define dspunwrap_rt_h

#include "dsp_rt.h"

#ifdef DSPUNWRAP_EXPORTS
#define DSPUNWRAP_EXPORT EXPORT_FCN
#else
#define DSPUNWRAP_EXPORT MWDSP_IDECL
#endif

/* 
 * Function naming glossary 
 * --------------------------- 
 * 
 * MWDSP = MathWorks DSP Blockset 
 * 
 * Data types - (describe inputs to functions, and outputs) 
 * R = real single-precision 
 * D = real double-precision 
 */ 

/*
 * Function naming convention
 * ---------------------------
 *
 * MWDSP_Unwrap_<DType>_<FunctionType>
 *
 * 1) MWDSP is a prefix used with all Mathworks DSP runtime library functions
 * 2) The second field indicates that this function is implementing the 
 *    Phase unwrap function for removing discontinuities in phase.
 * 3) The third field indicates the DataType of the input and output.
 * 4) The fourth field indicates whether this functions is one of the following types.
 *    Running or Non-running, Inplace or outofplace and frame based or sample based.
 *    The naming convention uesd is as below.
 *    R - Running, NR - Nonrunning
 *    IP - In place, OP - Out of place
 *    F - frame based, S - sample based
 *
 * For example MWDSP_Unwrap_R_RIPS takes input single precision data values and
 * does phase unwrapping with the settings running and inplace computation and sample based.
 *
 */

DSPUNWRAP_EXPORT void MWDSP_Unwrap_D_NRIP(      real_T *y,
                                const real_T  cutoff,
                                      int_T   inCols,
                                      int_T   inRows
                                );

DSPUNWRAP_EXPORT void MWDSP_Unwrap_D_NROP(const real_T *u,
                                      real_T *y,
                                const real_T  cutoff,
                                      int_T   inCols,
                                      int_T   inRows
                                );

DSPUNWRAP_EXPORT void MWDSP_Unwrap_D_RIPF(      real_T *y,
                                      real_T *prev,
                                      real_T *pcumsum,
                                const real_T cutoff,
                                      int_T  inCols,
                                      int_T  inRows,
                                      boolean_T *firstime
                                );

DSPUNWRAP_EXPORT void MWDSP_Unwrap_D_RIPS(      real_T *y,
                                      real_T *prev,
                                      real_T *pcumsum,
                                const real_T cutoff,
                                      int_T  numChans,
                                      boolean_T *firstime
                                );

DSPUNWRAP_EXPORT void MWDSP_Unwrap_D_ROPF(const real_T *u,
                                      real_T *y,
                                      real_T *prev,
                                      real_T *pcumsum,
                                const real_T cutoff,
                                      int_T  inCols,
                                      int_T  inRows,
                                      boolean_T *firstime);

DSPUNWRAP_EXPORT void MWDSP_Unwrap_D_ROPS(const real_T *u,
                                      real_T *y,
                                      real_T *prev,
                                      real_T *pcumsum,
                                const real_T cutoff,
                                      int_T   numChans,
                                      boolean_T *firstime);

DSPUNWRAP_EXPORT void MWDSP_Unwrap_R_NRIP(      real32_T *y,
                                const real32_T cutoff,
                                      int_T  inCols,
                                      int_T  inRows);

DSPUNWRAP_EXPORT void MWDSP_Unwrap_R_NROP(const real32_T *u,
                                      real32_T *y,
                                const real32_T cutoff,
                                      int_T   inCols,
                                      int_T   inRows);

DSPUNWRAP_EXPORT void MWDSP_Unwrap_R_RIPF(      real32_T *y,
                                      real32_T *prev,
                                      real32_T *pcumsum,
                                const real32_T cutoff,
                                      int_T  inCols,
                                      int_T  inRows,
                                      boolean_T *firstime);

DSPUNWRAP_EXPORT void MWDSP_Unwrap_R_RIPS(      real32_T *y,
                                      real32_T *prev,
                                      real32_T *pcumsum,
                                const real32_T cutoff,
                                      int_T  numChans,
                                      boolean_T *firstime);

DSPUNWRAP_EXPORT void MWDSP_Unwrap_R_ROPF(const real32_T *u,
                                      real32_T *y,
                                      real32_T *prev,
                                      real32_T *pcumsum,
                                const real32_T cutoff,
                                      int_T  inCols,
                                      int_T  inRows,
                                      boolean_T *firstime);

DSPUNWRAP_EXPORT void MWDSP_Unwrap_R_ROPS(const real32_T *u,
                                      real32_T *y,
                                      real32_T *prev,
                                      real32_T *pcumsum,
                                const real32_T cutoff,
                                      int_T   numChans,
                                      boolean_T *firstime);

#ifdef MWDSP_INLINE_DSPRTLIB
#include "dspunwrap/unwrap_d_nrip_rt.c"
#include "dspunwrap/unwrap_d_nrop_rt.c"
#include "dspunwrap/unwrap_d_ripf_rt.c"
#include "dspunwrap/unwrap_d_rips_rt.c"
#include "dspunwrap/unwrap_d_ropf_rt.c"
#include "dspunwrap/unwrap_d_rops_rt.c"
#include "dspunwrap/unwrap_r_nrip_rt.c"
#include "dspunwrap/unwrap_r_nrop_rt.c"
#include "dspunwrap/unwrap_r_ripf_rt.c"
#include "dspunwrap/unwrap_r_rips_rt.c"
#include "dspunwrap/unwrap_r_ropf_rt.c"
#include "dspunwrap/unwrap_r_rops_rt.c"
#endif

#endif /* dspunwrap */

/* [EOF] dspunwrap */
