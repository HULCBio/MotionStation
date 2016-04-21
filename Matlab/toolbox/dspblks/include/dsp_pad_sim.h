/*
 *  DSP_PAD_SIM.H - simulation helper functions for DSP pad operations
 *
 *  Copyright 1995-2002 The MathWorks, Inc.
 *  $Revision: 1.5 $  $Date: 2002/04/14 20:36:49 $
 */

#ifndef dsp_pad_sim_h
#define dsp_pad_sim_h

#include "dsp_rt.h"

/* DSPSIM_PadArgsCache is a structure used to contain parameters/arguments
 * for each of the individual simulation functions listed below.
 */
typedef struct {
    const void *u;        /* pointer to input array  (any data type, any complexity) */
    void       *y;        /* pointer to output array (any data type, any complexity) */
    void       *padValue; /* pointer to value to pad output array
                           * (complexity must match complexity of y)
                           */
    void       *zero;     /* pointer to data-typed "real zero" representation */

    int_T       bytesPerInpElmt; /* number of bytes in each sample in input array */
    int_T       bytesPerInpCol;  /* number of bytes in each column of input array */
    int_T       numInpRows;      /* number of rows in the input array    */
    int_T       numInpCols;      /* number of columns in the input array */

    int_T       numExtraRows;    /* number of additional rows in output array    */
    int_T       numExtraCols;    /* number of additional columns in output array */

    int_T       bytesPerOutCol;  /* number of bytes in each column of output array */
    int_T       numOutRows;      /* number of rows in the output array    */
    int_T       numOutCols;      /* number of columns in the output array */
    int_T       outputWidth;     /* total number of samples in the output array
                                  * (equivalent to numOutRows * numOutCols)
                                  */

} DSPSIM_PadArgsCache;

/* FUNCTION DSPSIM_PadAlongColsSim AND DSPSIM_PadAlongColsMixedSim
 *
 * DESCRIPTION: (Post) pad along columns only.
 *
 * ASSUMES (DSPSIM_PadAlongColsSim):      Input, pad value, and output all same complexity.
 * ASSUMES (DSPSIM_PadAlongColsMixedSim): Real input, complex pad value, complex output.
 */
extern void DSPSIM_PadAlongColsSim(DSPSIM_PadArgsCache *args);
extern void DSPSIM_PadAlongColsMixedSim(DSPSIM_PadArgsCache *args);

/* FUNCTION DSPSIM_PadAlongRowsSim AND DSPSIM_PadAlongRowsMixedSim
 *
 * DESCRIPTION: (Post) pad along rows only.
 *
 * ASSUMES (DSPSIM_PadAlongRowsSim):      Input, pad value, and output all same complexity.
 * ASSUMES (DSPSIM_PadAlongRowsMixedSim): Real input, complex pad value, complex output.
 */
extern void DSPSIM_PadAlongRowsSim(DSPSIM_PadArgsCache *args);
extern void DSPSIM_PadAlongRowsMixedSim(DSPSIM_PadArgsCache *args);

/* FUNCTION DSPSIM_PadAlongRowsColsSim AND DSPSIM_PadAlongRowsColsMixedSim
 *
 * DESCRIPTION: (Post) pad along rows AND columns.
 *
 * ASSUMES (DSPSIM_PadAlongRowsColsSim):      Input, pad value, and output all same complexity.
 * ASSUMES (DSPSIM_PadAlongRowsColsMixedSim): Real input, complex pad value, complex output.
 */
extern void DSPSIM_PadAlongRowsColsSim(DSPSIM_PadArgsCache *args);
extern void DSPSIM_PadAlongRowsColsMixedSim(DSPSIM_PadArgsCache *args);

/* FUNCTION DSPSIM_PadPreAlongColsSim AND DSPSIM_PadPreAlongColsMixedSim
 *
 * DESCRIPTION: (Pre) pad along columns only.
 *
 * ASSUMES (DSPSIM_PadPreAlongColsSim):      Input, pad value, and output all same complexity.
 * ASSUMES (DSPSIM_PadPreAlongColsMixedSim): Real input, complex pad value, complex output.
 */
extern void DSPSIM_PadPreAlongColsSim(DSPSIM_PadArgsCache *args);
extern void DSPSIM_PadPreAlongColsMixedSim(DSPSIM_PadArgsCache *args);

/* FUNCTION DSPSIM_PadPreAlongRowsSim AND DSPSIM_PadPreAlongRowsMixedSim
 *
 * DESCRIPTION: (Pre) pad along rows only.
 *
 * ASSUMES (DSPSIM_PadPreAlongRowsSim):      Input, pad value, and output all same complexity.
 * ASSUMES (DSPSIM_PadPreAlongRowsMixedSim): Real input, complex pad value, complex output.
 */
extern void DSPSIM_PadPreAlongRowsSim(DSPSIM_PadArgsCache *args);
extern void DSPSIM_PadPreAlongRowsMixedSim(DSPSIM_PadArgsCache *args);

/* FUNCTION DSPSIM_PadPreAlongRowsColsSim AND DSPSIM_PadPreAlongRowsColsMixedSim
 *
 * DESCRIPTION: (Pre) pad along rows AND columns.
 *
 * ASSUMES (DSPSIM_PadPreAlongRowsColsSim):      Input, pad value, and output all same complexity.
 * ASSUMES (DSPSIM_PadPreAlongRowsColsMixedSim): Real input, complex pad value, complex output.
 */
extern void DSPSIM_PadPreAlongRowsColsSim(DSPSIM_PadArgsCache *args);
extern void DSPSIM_PadPreAlongRowsColsMixedSim(DSPSIM_PadArgsCache *args);

/* FUNCTION DSPSIM_PadCopyOnlyTruncateRowsSim AND DSPSIM_PadCopyOnlyTruncateColsSim
 *
 * DESCRIPTION: Copy inputs to outputs, including possible
 *              truncation along either rows or columns.
 *
 * DSPSIM_PadCopyOnlyTruncateRowsSim is truncation ALONG row dimension.
 * That is, the number of rows (or length of each column) stays constant from
 * input to output.  However there may be fewer columns in the output
 * (i.e. row lengths may get truncated).
 *
 * DSPSIM_PadCopyOnlyTruncateColsSim is truncation ALONG column dimension.
 * That is, the number of columns (or length of each row) stays constant from
 * input to output.  However there may be fewer rows in the output
 * (i.e. column lengths may get truncated).
 *
 * ASSUMES: Input and output both have same complexity.
 *          (note: pad value and pad value complexity is ignored)
 */
extern void DSPSIM_PadCopyOnlyTruncateRowsSim(DSPSIM_PadArgsCache *args);
extern void DSPSIM_PadCopyOnlyTruncateColsSim(DSPSIM_PadArgsCache *args);

/* FUNCTION DSPSIM_PadNoOpSim
 *
 * DESCRIPTION: Do nothing (a "NOP" function)
 * ASSUMES:     None
 */
extern void DSPSIM_PadNoOpSim(DSPSIM_PadArgsCache *args);

#endif /* dsp_pad_sim_h */

/* [EOF] dsp_pad_sim.h */
