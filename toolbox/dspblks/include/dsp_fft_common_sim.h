/*
 * dsp_fft_common_sim - DSP Blockset definitions
 *       common to both FFT and IFFT blocks.
 *
 *  Copyright 1995-2004 The MathWorks, Inc.
 *  $Revision: 1.5.4.3 $  $Date: 2004/04/12 23:11:17 $
 */

#ifndef dsp_fft_common_sim_h
#define dsp_fft_common_sim_h

#include "dsp_sim.h"
#include "dspfft_rt.h" /* Run-time support functions for FFT and IFFT */

#ifdef __cplusplus
extern "C" {
#endif

/*
 * FFT common argument cache, used during simulation only
 */
typedef struct {
    int_T       nRows;        /* # of rows = fft length */
    int_T       nChans;       /* # of channels/cols     */
    int_T       invScale;     /* Flag: scale IFFT by N  */
    void       *outPtr;       /* Output data pointer    */
    const void *inPtr;        /* Input data pointer     */
    void       *dataPtr;      /* Pointer to data on which FFT has to be performed
                               * For in-place, same as outPtr, else same as inPtr
                               */
    const void *twidPtr;      /* Twiddle table Pointer  */
    const void *zero;         /* Pointer to unknown datatype zero */
    int_T bytes_per_element;  /* Number of bytes per element for unknown datatype */
    void       *wkspace;      /* Pointer to DWork for Deinterleaver */
    int_T       twidTableSize;
    int_T       twiddleStep;  /* Strides to take within twiddle table */
    int_T       twiddleStepAlongR;/* Strides to take within twiddle table along row */
    void       *copyDWork;     /* DWork used in 2D FFT for copying rows as columns */
    void       *copyDWork1;    /* DWork used in 2D FFT for copying rows as columns */
    void       *copyCS;        /* DWork used for CS IFFT mode. */
} MWDSP_FFTArgsCache;

/* Functions to create RTP Sine table for FFT routines */
extern void CreateFullFloatSineTableRTP(SimStruct *S, 
                                        int_T      N,
                                        int_T      rtp_index, 
                                        DTypeId    rtp_dtype, 
                                        const char *rtpName);
extern void CreateSineTableRTP(SimStruct *S, 
                               boolean_T  SPEED, 
                               int_T      NFFT,
                               int_T      rtp_index, 
                               DTypeId    rtp_dtype,
                               const char *rtpName);

#ifdef __cplusplus
} // close brace for extern C from above
#endif

#endif /* dsp_fft_common_sim_h */

/* [EOF] dsp_fft_common_sim.h */

