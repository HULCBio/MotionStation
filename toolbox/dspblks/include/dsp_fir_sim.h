/*
 * dsp_fir_sim - DSP Blockset FIR Filter simulation support
 *
 *  Copyright 1995-2002 The MathWorks, Inc.
 *  $Revision: 1.6 $  $Date: 2002/04/14 20:39:14 $
 */

#ifndef dsp_fir_sim_h
#define dsp_fir_sim_h

#include "dsp_filtstruct_sim.h" /* contains definition of const DSPSIM_FilterArgsCache */
#include "dspfir_rt.h"          /* contains FIR filter run-time functions */

/*** FIR Filter Simulation Functions: ***/
/* Transposed direct-form FIR filters: */
extern void DSPSIM_FIR_TDF_DD(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_FIR_TDF_DZ(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_FIR_TDF_ZD(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_FIR_TDF_ZZ(const DSPSIM_FilterArgsCache *args);

extern void DSPSIM_FIR_TDF_RR(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_FIR_TDF_RC(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_FIR_TDF_CR(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_FIR_TDF_CC(const DSPSIM_FilterArgsCache *args);

/* Direct-form FIR filters: */
extern void DSPSIM_FIR_DF_DD(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_FIR_DF_DZ(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_FIR_DF_ZD(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_FIR_DF_ZZ(const DSPSIM_FilterArgsCache *args);

extern void DSPSIM_FIR_DF_RR(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_FIR_DF_RC(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_FIR_DF_CR(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_FIR_DF_CC(const DSPSIM_FilterArgsCache *args);

/* Lattice FIR filters: */
extern void DSPSIM_FIR_Lat_DD(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_FIR_Lat_DZ(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_FIR_Lat_ZD(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_FIR_Lat_ZZ(const DSPSIM_FilterArgsCache *args);

extern void DSPSIM_FIR_Lat_RR(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_FIR_Lat_RC(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_FIR_Lat_CR(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_FIR_Lat_CC(const DSPSIM_FilterArgsCache *args);

#endif /* dsp_fir_sim_h */

/* [EOF] dsp_fir_sim.h */
