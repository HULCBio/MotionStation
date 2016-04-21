/* $Revision: 1.2 $ */
/* 
 * DSP_UNWRAP_SIM Simulation mid-level functions for DSP Blockset 
 * Unwrap block
 * 
 * The Unwrap block unwraps radian phases in the input 
 * vector by replacing absolute jumps greater than the 
 * specified Tolerance with their 2*pi complement. 
 * 
 * Copyright 1995-2002 The MathWorks, Inc.
 *
 */ 

#ifndef dsp_unwrap_sim_h
#define dsp_unwrap_sim_h

/* UnwrapArgsCache is a structure used to contain parameters/arguments 
 * for each of the individual runtime functions listed below. 
 */ 

typedef struct {
    const void             *in;         /* Input data */
          void            *out;         /* Output data */
          int_T         inCols;         /* Number of columns  in input */
          int_T         inRows;         /* Number of columns  in output */
          int_T       numChans;         /* Number of channels in input */
          void           *prev;         /* Previous value - used for running case*/
          void         *cumsum;         /* Cumulative sum of phase */
          void         *cutoff;         /* Threshold for phase unwrap */
          boolean_T  *firstime;
} UnwrapArgsCache;

/* 
 * Function naming glossary 
 * --------------------------- 
 * Data types - (describe inputs to functions, and outputs) 
 * R = real single-precision 
 * D = real double-precision 
 */ 

/*
 * Function naming convention
 * ---------------------------
 *
 * Unwrap_<DType>_<FunctionType>
 *
 * 1) The second field indicates that this function is implementing the 
 *    Phase unwrap function for removing discontinuities in phase.
 * 2) The third field indicates the DataType of the input and output.
 * 3) The fourth field indicates whether this functions is one of the following types.
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

extern void Unwrap_D_NRIP(UnwrapArgsCache *args);
extern void Unwrap_D_NROP(UnwrapArgsCache *args);
extern void Unwrap_D_RIPF(UnwrapArgsCache *args);
extern void Unwrap_D_RIPS(UnwrapArgsCache *args);
extern void Unwrap_D_ROPF(UnwrapArgsCache *args);
extern void Unwrap_D_ROPS(UnwrapArgsCache *args);
extern void Unwrap_R_NRIP(UnwrapArgsCache *args);
extern void Unwrap_R_NROP(UnwrapArgsCache *args);
extern void Unwrap_R_RIPF(UnwrapArgsCache *args);
extern void Unwrap_R_RIPS(UnwrapArgsCache *args);
extern void Unwrap_R_ROPF(UnwrapArgsCache *args);
extern void Unwrap_R_ROPS(UnwrapArgsCache *args);

#endif  /* dsp_unwrap_sim_h */

/* [EOF] dsp_unwrap_sim.h */
