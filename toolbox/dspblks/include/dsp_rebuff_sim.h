/* Simulation support header file for Buffer / UnBuffer block
 * 
 *  Copyright 1995-2002 The MathWorks, Inc.
 *  $Revision: 1.3 $  $Date: 2002/04/14 20:38:27 $
 */
#ifndef dsp_rebuff_sim_h
#define dsp_rebuff_sim_h

#include "dsprebuff_rt.h"

/* RebuffArgsCache is a structure used to contain parameters/arguments
 * for each of the individual simulation functions listed below 
 *
 * Note that not all members of this structure have to be defined
 * for every simulation function.  Please refer to the description in the
 * comments before each function prototype for more specific details.
 */
typedef struct {
    /* Common Parameters */
    const byte_T   *u;               /* pointer to input data start address */
          byte_T   *y;               /* pointer to output */
          int_T     N;               /* output frame size */
          int_T     F;               /* input frame size */
          int_T     nChans;          /* number of channels */
          int_T     bytesPerElement; /* bytes per element  */

    /* Parameters for cases with initial conditions (ICs)
     * used for when inputFcn and outputFcn are needed
     */
    byte_T  **inBufPtr;        /* address to internal buffer state memory */
    byte_T  **outBufPtr;       /* address to internal buffer state memory */
    byte_T   *memBase;         /* pointer to internal buffer state memory start address */
    int_T     shiftPerElement; /* shift size = log2(bytesPerElement) */
    int_T     bufLenTimesBpe;  /* buffer lenghth x bytesPerElement */
    int32_T  *ul_count;        /* underlap count */
    int_T     V;               /* overlap size */
    int_T     VtmpTimesBpe;    /* V x bytesPerElement */

    /* Parameters for cases without initial conditions (ICs)
     * used for when copyFcn is needed
     */
     int32_T  *cnt; /* pointer to input data index */

} RebuffArgsCache;

/* The following functions are for simulation-only. 
 * They are wrappers for their corresponding run-time
 * functions.  For more details of their operation,
 * you may refer to the comments in file dsprebuff_rt.h
 */

/* Byte shuffling functions for copying data
 * from state buffer memory to output port
 * (for cases requiring ICs)
 */
extern void DSPSIM_Buf_OutputFrame     (RebuffArgsCache *args);
extern void DSPSIM_Buf_OutputFrame_1ch (RebuffArgsCache *args);
extern void DSPSIM_Buf_OutputScalar    (RebuffArgsCache *args);
extern void DSPSIM_Buf_OutputScalar_1ch(RebuffArgsCache *args);

/* Byte shuffling functions for copying data
 * from input port to state buffer memory
 * (for cases requiring ICs)
 */
extern void DSPSIM_Buf_CopyScalar_UL    (RebuffArgsCache *args);
extern void DSPSIM_Buf_CopyScalar_UL_1ch(RebuffArgsCache *args);
extern void DSPSIM_Buf_CopyScalar_OL    (RebuffArgsCache *args);
extern void DSPSIM_Buf_CopyScalar_OL_1ch(RebuffArgsCache *args);
extern void DSPSIM_Buf_CopyFrame_OL     (RebuffArgsCache *args);
extern void DSPSIM_Buf_CopyFrame_OL_1ch (RebuffArgsCache *args);

/* Byte shuffling functions for copying data
 * from input port to output port (for NO ICs cases)
 */
extern void DSPSIM_memCopy              (RebuffArgsCache *args);
extern void DSPSIM_CopyInputToOutput    (RebuffArgsCache *args);
extern void DSPSIM_CopyInputToOutput_1ch(RebuffArgsCache *args);

#endif

/* [EOF] dsp_rebuff_sim.h */
