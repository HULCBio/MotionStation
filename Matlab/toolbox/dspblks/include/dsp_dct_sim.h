/*
 *  dsp_dct_sim.h - DCT and IDCT simulation support functions
 *
 *  Copyright 1995-2002 The MathWorks, Inc.
 *  $Revision: 1.3 $ $Date: 2002/04/14 20:37:05 $
 */

#ifndef dsp_dct_sim_h
#define dsp_dct_sim_h

#include "dsp_fft_common_sim.h"

/* DSPSIM_DCTArgsCache: DCT/IDCT simulation wrapper fcn arguments */
typedef struct {
    int_T       nRows;       /* # of rows = DCT length  */
    int_T       nChans;      /* # of channels (columns) */
    const void *inPtr;       /* Input data pointer      */
    void       *outPtr;      /* Output data pointer     */
    void       *buff1;       /* Scratch buffer 1    (inPtr complexity, length = nRows*nChans) */
    const void *weights;     /* DCT weights         (always complex,   length = nRows       ) */
    int_T bytes_per_element; /* Number of bytes per element for block's datatype */
} DSPSIM_DCTArgsCache;


/* Special-case algorithm for scalar input case */
extern void DSPSIM_DCT_IDCT_Scalar(
    DSPSIM_DCTArgsCache *args,
    MWDSP_FFTArgsCache  *fftArgs);


/* DCT and IDCT function name conventions
 * --------------------------------------
 *
 * DSPSIM_{DCT|IDCT}_{STD|FCT}_{TRIG|TBLS}_{R|C|D|Z}
 *
 *
 * Naming glossary
 * ---------------
 *
 * DSPSIM = DSP simulation support function
 *
 * Operation
 *
 *   DCT   = Discrete Cosine Transform
 *   IDCT  = Inverse Discrete Cosine Transform
 *
 * Algorithm
 *
 *   STD   = Standard "textbook"
 *   FCT   = Fast DCT (length-2N-FFT-based)
 *
 * Trigonometric function computation
 *
 *   TRIG  = Direct trig function evaluation (using cos or sin fcns)
 *   TBLS  = Speed-optimized table-lookup for cos or sin
 *
 * Data types
 *
 *   R = real single-precision I/O
 *   C = complex single-precision I/O
 *   D = real double-precision I/O
 *   Z = complex double-precision I/O
 */
extern void DSPSIM_DCT_FCT_TRIG_D(DSPSIM_DCTArgsCache *args, MWDSP_FFTArgsCache  *fftArgs);
extern void DSPSIM_DCT_FCT_TRIG_R(DSPSIM_DCTArgsCache *args, MWDSP_FFTArgsCache  *fftArgs);
extern void DSPSIM_DCT_FCT_TRIG_Z(DSPSIM_DCTArgsCache *args, MWDSP_FFTArgsCache  *fftArgs);
extern void DSPSIM_DCT_FCT_TRIG_C(DSPSIM_DCTArgsCache *args, MWDSP_FFTArgsCache  *fftArgs);

extern void DSPSIM_IDCT_FCT_TRIG_D(DSPSIM_DCTArgsCache *args, MWDSP_FFTArgsCache  *fftArgs);
extern void DSPSIM_IDCT_FCT_TRIG_R(DSPSIM_DCTArgsCache *args, MWDSP_FFTArgsCache  *fftArgs);
extern void DSPSIM_IDCT_FCT_TRIG_Z(DSPSIM_DCTArgsCache *args, MWDSP_FFTArgsCache  *fftArgs);
extern void DSPSIM_IDCT_FCT_TRIG_C(DSPSIM_DCTArgsCache *args, MWDSP_FFTArgsCache  *fftArgs);

extern void DSPSIM_DCT_FCT_TBLS_D(DSPSIM_DCTArgsCache *args, MWDSP_FFTArgsCache  *fftArgs);
extern void DSPSIM_DCT_FCT_TBLS_R(DSPSIM_DCTArgsCache *args, MWDSP_FFTArgsCache  *fftArgs);
extern void DSPSIM_DCT_FCT_TBLS_Z(DSPSIM_DCTArgsCache *args, MWDSP_FFTArgsCache  *fftArgs);
extern void DSPSIM_DCT_FCT_TBLS_C(DSPSIM_DCTArgsCache *args, MWDSP_FFTArgsCache  *fftArgs);

extern void DSPSIM_IDCT_FCT_TBLS_D(DSPSIM_DCTArgsCache *args, MWDSP_FFTArgsCache  *fftArgs);
extern void DSPSIM_IDCT_FCT_TBLS_R(DSPSIM_DCTArgsCache *args, MWDSP_FFTArgsCache  *fftArgs);
extern void DSPSIM_IDCT_FCT_TBLS_Z(DSPSIM_DCTArgsCache *args, MWDSP_FFTArgsCache  *fftArgs);
extern void DSPSIM_IDCT_FCT_TBLS_C(DSPSIM_DCTArgsCache *args, MWDSP_FFTArgsCache  *fftArgs);

#endif /* dsp_dct_sim_h */

/* [EOF] dsp_dct_sim.h */
