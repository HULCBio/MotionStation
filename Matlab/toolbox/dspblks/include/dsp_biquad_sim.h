/*
 * dsp_biqad_sim - DSP Blockset BiQuad Filter simulation support
 *
 *  Copyright 1995-2002 The MathWorks, Inc.
 *  $Revision: 1.2 $  $Date: 2002/04/14 20:37:58 $
 */

#ifndef dsp_biquad_sim_h
#define dsp_biquad_sim_h

#include "dsp_filtstruct_sim.h" /* contains definition of const DSPSIM_FilterArgsCache */
#include "dspbiquad_rt.h"       /* contains BiQuad filter run-time functions */

/*** BiQuad Filter Simulation Functions: ***/
/* BiQuad6 Filters: */
extern void DSPSIM_BQ6_DF2T_1fpf_1sos_DD(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_BQ6_DF2T_1fpf_1sos_DZ(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_BQ6_DF2T_1fpf_1sos_ZD(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_BQ6_DF2T_1fpf_1sos_ZZ(const DSPSIM_FilterArgsCache *args);

extern void DSPSIM_BQ6_DF2T_1fpf_1sos_RR(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_BQ6_DF2T_1fpf_1sos_RC(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_BQ6_DF2T_1fpf_1sos_CR(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_BQ6_DF2T_1fpf_1sos_CC(const DSPSIM_FilterArgsCache *args);

extern void DSPSIM_BQ6_DF2T_1fpf_Nsos_DD(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_BQ6_DF2T_1fpf_Nsos_DZ(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_BQ6_DF2T_1fpf_Nsos_ZD(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_BQ6_DF2T_1fpf_Nsos_ZZ(const DSPSIM_FilterArgsCache *args);

extern void DSPSIM_BQ6_DF2T_1fpf_Nsos_RR(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_BQ6_DF2T_1fpf_Nsos_RC(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_BQ6_DF2T_1fpf_Nsos_CR(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_BQ6_DF2T_1fpf_Nsos_CC(const DSPSIM_FilterArgsCache *args);

/* BiQuad5 Filters: */
extern void DSPSIM_BQ5_DF2T_1fpf_1sos_DD(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_BQ5_DF2T_1fpf_1sos_DZ(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_BQ5_DF2T_1fpf_1sos_ZD(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_BQ5_DF2T_1fpf_1sos_ZZ(const DSPSIM_FilterArgsCache *args);

extern void DSPSIM_BQ5_DF2T_1fpf_1sos_RR(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_BQ5_DF2T_1fpf_1sos_RC(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_BQ5_DF2T_1fpf_1sos_CR(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_BQ5_DF2T_1fpf_1sos_CC(const DSPSIM_FilterArgsCache *args);

extern void DSPSIM_BQ5_DF2T_1fpf_Nsos_DD(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_BQ5_DF2T_1fpf_Nsos_DZ(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_BQ5_DF2T_1fpf_Nsos_ZD(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_BQ5_DF2T_1fpf_Nsos_ZZ(const DSPSIM_FilterArgsCache *args);

extern void DSPSIM_BQ5_DF2T_1fpf_Nsos_RR(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_BQ5_DF2T_1fpf_Nsos_RC(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_BQ5_DF2T_1fpf_Nsos_CR(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_BQ5_DF2T_1fpf_Nsos_CC(const DSPSIM_FilterArgsCache *args);

/* BiQuad4 Filters: */
extern void DSPSIM_BQ4_DF2T_1fpf_1sos_DD(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_BQ4_DF2T_1fpf_1sos_DZ(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_BQ4_DF2T_1fpf_1sos_ZD(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_BQ4_DF2T_1fpf_1sos_ZZ(const DSPSIM_FilterArgsCache *args);

extern void DSPSIM_BQ4_DF2T_1fpf_1sos_RR(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_BQ4_DF2T_1fpf_1sos_RC(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_BQ4_DF2T_1fpf_1sos_CR(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_BQ4_DF2T_1fpf_1sos_CC(const DSPSIM_FilterArgsCache *args);

extern void DSPSIM_BQ4_DF2T_1fpf_Nsos_DD(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_BQ4_DF2T_1fpf_Nsos_DZ(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_BQ4_DF2T_1fpf_Nsos_ZD(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_BQ4_DF2T_1fpf_Nsos_ZZ(const DSPSIM_FilterArgsCache *args);

extern void DSPSIM_BQ4_DF2T_1fpf_Nsos_RR(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_BQ4_DF2T_1fpf_Nsos_RC(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_BQ4_DF2T_1fpf_Nsos_CR(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_BQ4_DF2T_1fpf_Nsos_CC(const DSPSIM_FilterArgsCache *args);

#endif /* dsp_biquad_sim_h */

/* [EOF] dsp_biquad_sim.h */
