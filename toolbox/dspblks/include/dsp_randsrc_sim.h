/*
 *  dsp_randsrc_sim.h - mid-level simulation
 *     functions for the random source block
 *
 *  Copyright 1995-2004 The MathWorks, Inc.
 *  $Revision: 1.3.4.2 $ $Date: 2004/04/12 23:11:30 $
 */

#ifndef DSP_RANDSRC_SIM_H
#define DSP_RANDSRC_SIM_H

/* version.h indirectly includes tmwtypes.h
 * after compiler switch automagic
 */
#include "version.h"

typedef struct {
    void   *y;          /* pointer to output array */
    const void *m_or_m; /* vector of minimums or means */
    int_T   momLen;     /* length of m_or_m vector */
    const void *m_or_v; /* vector of maximums or variances */
    int_T   movLen;     /* length of m_or_v vector */
    void   *state;      /* state array */
    int_T   nChans;     /* number of channels in output array */
    int_T   nSamps;     /* number of samples per channel in output array */
    void   *cltVec;     /* vector for storing temp uniform values */
    int_T   cltLen;     /* length of cltVec */
} DSPSIM_RandSrcArgsCache;


/* Simulation wrapper functions for those defined in 
 * dsprandsrc_rt.h.  Please refer to that file for 
 * explanations of the corresponding functions.
 */

/* Uniform Distribution */
extern void DSPSIM_RandSrcInitState_U_64(const uint_T *seed, 
                                         void         *state,
                                         int_T         nChans);
extern void DSPSIM_RandSrcInitState_U_32(const uint_T *seed, 
                                         void         *state,
                                         int_T         nChans);
extern void DSPSIM_RandSrc_U_R(DSPSIM_RandSrcArgsCache *args);
extern void DSPSIM_RandSrc_U_C(DSPSIM_RandSrcArgsCache *args);
extern void DSPSIM_RandSrc_U_D(DSPSIM_RandSrcArgsCache *args);
extern void DSPSIM_RandSrc_U_Z(DSPSIM_RandSrcArgsCache *args);

/* Gaussian Distribution, Ziggurat Method */
extern void DSPSIM_RandSrcInitState_GZ(const uint_T *seed,
                                       void         *state,
                                       int_T         nChans);
extern void DSPSIM_RandSrc_GZ_R(DSPSIM_RandSrcArgsCache *args);
extern void DSPSIM_RandSrc_GZ_C(DSPSIM_RandSrcArgsCache *args);
extern void DSPSIM_RandSrc_GZ_D(DSPSIM_RandSrcArgsCache *args);
extern void DSPSIM_RandSrc_GZ_Z(DSPSIM_RandSrcArgsCache *args);

/* Gaussian Distribution, CLT Summation Method */
extern void DSPSIM_RandSrcInitState_GC_64(const uint_T *seed,
                                          void         *state,
                                          int_T         nChans);
extern void DSPSIM_RandSrcInitState_GC_32(const uint_T *seed,
                                          void         *state,
                                          int_T         nChans);
extern void DSPSIM_RandSrc_GC_R(DSPSIM_RandSrcArgsCache *args);
extern void DSPSIM_RandSrc_GC_C(DSPSIM_RandSrcArgsCache *args);
extern void DSPSIM_RandSrc_GC_D(DSPSIM_RandSrcArgsCache *args);
extern void DSPSIM_RandSrc_GC_Z(DSPSIM_RandSrcArgsCache *args);

/* Seed creation utility functions */
extern void DSPSIM_RandSrcCreateSeeds_64(uint32_T initSeed,
                                         uint32_T *array,
                                         uint32_T len);
extern void DSPSIM_RandSrcCreateSeeds_32(uint32_T initSeed,
                                         uint32_T *array,
                                         uint32_T len);

#endif /* DSP_RANDSRC_SIM_H */

/* [EOF] dsp_randsrc_sim.h */
