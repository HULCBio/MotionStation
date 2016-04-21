/*
 * dsp_flip_sim - mid-level simulation functions
 *  for the flip block
 *
 *  Copyright 1995-2004 The MathWorks, Inc.
 *  $Revision: 1.3.4.2 $  $Date: 2004/04/12 23:11:21 $
 */

#ifndef DSP_FLIP_SIM_H
#define DSP_FLIP_SIM_H

/* version.h indirectly includes tmwtypes.h
 * after compiler switch automagic
 */
#include "version.h"

typedef struct {
    const void *u;                /* pointer to input array */
    void       *y;                /* pointer to output array */
    int_T       numRows;          /* number of rows in input array */
    int_T       numCols;          /* number of columns in input array */
    int_T       bytesPerElement;  /* number of bytes per element in input array */
} DSPSIM_FlipArgsCache;

/* Simulation wrapper functions for those defined in 
 * dspflip_rt.h.  Please refer to that file for 
 * explanations of the corresponding functions.
 */
extern void DSPSIM_FlipNoOp(DSPSIM_FlipArgsCache* args);
extern void DSPSIM_FlipCopyInputToOutput(DSPSIM_FlipArgsCache* args);
extern void DSPSIM_FlipVectorIP(DSPSIM_FlipArgsCache* args);
extern void DSPSIM_FlipVectorOP(DSPSIM_FlipArgsCache* args);
extern void DSPSIM_FlipMatrixRowIP(DSPSIM_FlipArgsCache* args);
extern void DSPSIM_FlipMatrixRowOP(DSPSIM_FlipArgsCache* args);
extern void DSPSIM_FlipMatrixColIP(DSPSIM_FlipArgsCache* args);
extern void DSPSIM_FlipMatrixColOP(DSPSIM_FlipArgsCache* args);

#endif

/* [EOF] dsp_flip_sim.h */
