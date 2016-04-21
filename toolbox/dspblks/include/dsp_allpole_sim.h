/*
 * dsp_allpole_sim - DSP Blockset AllPole Filter simulation support
 *
 *  Copyright 1995-2002 The MathWorks, Inc.
 *  $Revision: 1.6 $  $Date: 2002/03/24 02:31:27 $
 */

#ifndef dsp_allpole_sim_h
#define dsp_allpole_sim_h

#include "dsp_filtstruct_sim.h" /* contains definition of DSPSIM_FilterArgsCache */
#include "dspallpole_rt.h"      /* contains AllPole filter run-time functions */

/*** ALLPOLE Filter Simulation Functions: ***/
/* Transposed direct-form all-pole filters: */
extern void DSPSIM_AllPole_TDF_DD(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_AllPole_TDF_DZ(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_AllPole_TDF_ZD(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_AllPole_TDF_ZZ(const DSPSIM_FilterArgsCache *args);

extern void DSPSIM_AllPole_TDF_RR(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_AllPole_TDF_RC(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_AllPole_TDF_CR(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_AllPole_TDF_CC(const DSPSIM_FilterArgsCache *args);

/* Transposed direct-form all-pole filters: */
extern void DSPSIM_AllPole_TDF_A0Scale_DD(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_AllPole_TDF_A0Scale_DZ(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_AllPole_TDF_A0Scale_ZD(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_AllPole_TDF_A0Scale_ZZ(const DSPSIM_FilterArgsCache *args);

extern void DSPSIM_AllPole_TDF_A0Scale_RR(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_AllPole_TDF_A0Scale_RC(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_AllPole_TDF_A0Scale_CR(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_AllPole_TDF_A0Scale_CC(const DSPSIM_FilterArgsCache *args);

/* Direct-form all-pole filters: */
extern void DSPSIM_AllPole_DF_DD(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_AllPole_DF_DZ(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_AllPole_DF_ZD(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_AllPole_DF_ZZ(const DSPSIM_FilterArgsCache *args);

extern void DSPSIM_AllPole_DF_RR(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_AllPole_DF_RC(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_AllPole_DF_CR(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_AllPole_DF_CC(const DSPSIM_FilterArgsCache *args);

/* Transposed direct-form all-pole filters: */
extern void DSPSIM_AllPole_DF_A0Scale_DD(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_AllPole_DF_A0Scale_DZ(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_AllPole_DF_A0Scale_ZD(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_AllPole_DF_A0Scale_ZZ(const DSPSIM_FilterArgsCache *args);

extern void DSPSIM_AllPole_DF_A0Scale_RR(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_AllPole_DF_A0Scale_RC(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_AllPole_DF_A0Scale_CR(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_AllPole_DF_A0Scale_CC(const DSPSIM_FilterArgsCache *args);

/* Lattice all-pole filters: */
extern void DSPSIM_AllPole_Lat_DD(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_AllPole_Lat_DZ(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_AllPole_Lat_ZD(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_AllPole_Lat_ZZ(const DSPSIM_FilterArgsCache *args);

extern void DSPSIM_AllPole_Lat_RR(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_AllPole_Lat_RC(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_AllPole_Lat_CR(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_AllPole_Lat_CC(const DSPSIM_FilterArgsCache *args);

/*** ALLPOLE Filter Simulation Functions: ***/
/* Lattice all-pole filters: */
extern void DSPSIM_AllPole_Lat_1fpf_DD(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_AllPole_Lat_1fpf_DZ(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_AllPole_Lat_1fpf_ZD(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_AllPole_Lat_1fpf_ZZ(const DSPSIM_FilterArgsCache *args);

extern void DSPSIM_AllPole_Lat_1fpf_RR(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_AllPole_Lat_1fpf_RC(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_AllPole_Lat_1fpf_CR(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_AllPole_Lat_1fpf_CC(const DSPSIM_FilterArgsCache *args);

extern void DSPSIM_AllPole_Lat_1fps_DD(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_AllPole_Lat_1fps_DZ(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_AllPole_Lat_1fps_ZD(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_AllPole_Lat_1fps_ZZ(const DSPSIM_FilterArgsCache *args);

extern void DSPSIM_AllPole_Lat_1fps_RR(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_AllPole_Lat_1fps_RC(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_AllPole_Lat_1fps_CR(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_AllPole_Lat_1fps_CC(const DSPSIM_FilterArgsCache *args);


#endif /* dsp_allpole_sim_h */

/* [EOF] dsp_allpole_sim.h */

