/* $Revision: 1.11 $ */
/*
 *  dsp_dlyerr_sim.h
 *  CMEX S-Fcn error handling library for DSP Blockset Delay Blocks
 *
 *  Copyright 1995-2002 The MathWorks, Inc.
 */
#ifndef dsp_dlyerr_sim_h
#define dsp_dlyerr_sim_h

#include "dsp_sim.h"

#ifdef __cplusplus
extern "C" {
#endif

struct signalInfo {
    int_T *Dims;
    int_T NumElements;
    int_T NumDims;
    boolean_T isScalarValued;
    boolean_T isOriented;
    boolean_T isVector;
    boolean_T isRowVector;
    boolean_T isColVector;
    boolean_T isMatrix;
};

typedef struct signalInfo signalInfo;

/*
 * Source located in dsp_dlyerr_sim.c:
 */
extern void delayValidator(SimStruct *S,
                    signalInfo Input,
                    signalInfo Delay,
                    const boolean_T isFrame);

#ifdef __cplusplus
}
#endif

#endif  /* dsp_dlyerr_sim_h */

/* [EOF] dsp_dlyerr_sim.h */
