/* Simulation support header file for FIR decimation block
 * 
 *  Copyright 1995-2002 The MathWorks, Inc.
 *  $Revision: 1.3 $  $Date: 2002/04/14 20:36:05 $
 */
#ifndef dsp_fir_rate_change_sim_h
#define dsp_fir_rate_change_sim_h

#include "dspfirdn_rt.h"
#include "dspupfir_rt.h"

/* FirRateChangeArgsCache is a structure used to contain parameters/arguments
 * for each of the individual simulation functions listed below 
 *
 * Note that not all members of this structure have to be defined
 * for every simulation function.  Please refer to the description in the
 * comments before each function prototype for more specific details.
 */

typedef struct {
    const void *u;                      /* input port                                                  */
    void       *yout;                   /* double length output buffer                                 */
    void       *y;                      /* output port                                                 */
    void       *tap0;                   /* points to input buffer start address per channel            */
    void       *sums;                   /* points to sums of FIR filter, one per channel               */
    void       *filter;                 /* FIR coeff                                                   */
    void      **cffPtr;                 /* filter coeff pointer                                        */
    int_T      *tapIdx;                 /* points to input TapDelayBuffer location to read in u        */
    int_T      *outIdx;                 /* points to output buffer data for transfer to y              */
    int_T      *phaseIdx;               /* active polyphase index                                      */
    boolean_T  *wrtBuf;                 /* determines which one of the two double buffer to store data */
    boolean_T  *readBuf;                /* determines which one of the two double buffer to read data  */
    int_T      filtLen;                 /* length of FIR filter                                        */
    int_T      numChans;                /* number of channels                                          */
    int_T      inFrameSize;             /* input frame size                                            */
    int_T      outFrameSize;            /* output frame size                                           */
    int_T      factor;                  /* decimation OR interpolation factor                          */
    int_T      polyphaseFiltLen;        /* length of each polyphase filter                             */
    int_T      outElem;                 /* number of output elements                                   */
    int_T      bytesToCopy;             /* number of bytes to copy from output buffer to output port   */
    int_T      bytesPerElem;            /* bytes per element                                           */
    int_T      perChanOutBufElems;      /* number of elements in each output buffer per channel        */
    int_T      perChanOutBufBytes;      /* number of bytes in each output buffer per channel           */
    int_T      outBufBaseOffsetInBytes; /* offset in bytes for output buffer base address pointer      */
    int_T      rdIdxSpan;               /* number of output buffer elements spanned by rdIdx           */
} FirRateChangeArgsCache;


/* Simulation function pointer definition */
typedef void (*FirRateChangeFcn)(FirRateChangeArgsCache *args);

/* S-fcn cache definition */
typedef struct {
    FirRateChangeArgsCache Args;                /* Args used by functions */
    FirRateChangeFcn       FirRateChangeFcnPtr; /* Pointer to function */
} SFcnCache;

/* The following functions are for simulation-only. */

/* Byte shuffling functions for copying data from output buffer
   to output port */
extern void DSPSIM_CopyBufferToOutPort(FirRateChangeArgsCache *args);
/*  DSPSIM_UpFIR_CopyData is used only for FIR interpolation.
 *  It is more complicated than it has to be because it is designed to copy data
 *  from output buffer to output port regardless of the block multirate status.  
 *  If the block is not multi-rate, the filter outputs from the run-time functions
 *  should be directed at the output port without using this function.  
 *  If the caller distinguishes the non-multirate status, this function need not
 *  be called; when the status is multirate, this function should be inlined 
 *  for code generation (sdspfirdn2.tlc) and the caller should use 
 *  DSPSIM_CopyBufferToOutPort for simulation.
 */  
extern void DSPSIM_UpFIR_CopyData(FirRateChangeArgsCache *args);

/* FIR Decimation OR interpolation Simulation Functions
 *
 * FIRDn - FIR Decimation
 * UpFIR - FIR Interpolation
 *
 * DF  - direct form FIR polyphase implementation.
 * TDF - transposed direct form FIR polyphase implementation.
 *
 * DblBuf - uses double ("ping-pong") output buffer.
 *
 * Based on the data-types, we have:-
 * D = double-precision real data-type.
 * R = single-precision real data-type
 * Z = double-precision complex data-type.
 * C = single-precision complex data-type. 
 *
 * The first letter refers to the input port data type.
 * The second letter refers to filter coefficient data type.
 *
 */

extern void DSPSIM_FIRDn_DF_DblBuf_DD(FirRateChangeArgsCache *args);
extern void DSPSIM_FIRDn_DF_DblBuf_DZ(FirRateChangeArgsCache *args);
extern void DSPSIM_FIRDn_DF_DblBuf_ZD(FirRateChangeArgsCache *args);
extern void DSPSIM_FIRDn_DF_DblBuf_ZZ(FirRateChangeArgsCache *args);

extern void DSPSIM_FIRDn_DF_DblBuf_RR(FirRateChangeArgsCache *args);
extern void DSPSIM_FIRDn_DF_DblBuf_RC(FirRateChangeArgsCache *args);
extern void DSPSIM_FIRDn_DF_DblBuf_CR(FirRateChangeArgsCache *args);
extern void DSPSIM_FIRDn_DF_DblBuf_CC(FirRateChangeArgsCache *args);

extern void DSPSIM_UpFIR_DF_DblBuf_DD(FirRateChangeArgsCache *args);
extern void DSPSIM_UpFIR_DF_DblBuf_DZ(FirRateChangeArgsCache *args);
extern void DSPSIM_UpFIR_DF_DblBuf_ZD(FirRateChangeArgsCache *args);
extern void DSPSIM_UpFIR_DF_DblBuf_ZZ(FirRateChangeArgsCache *args);

extern void DSPSIM_UpFIR_DF_DblBuf_RR(FirRateChangeArgsCache *args);
extern void DSPSIM_UpFIR_DF_DblBuf_RC(FirRateChangeArgsCache *args);
extern void DSPSIM_UpFIR_DF_DblBuf_CR(FirRateChangeArgsCache *args);
extern void DSPSIM_UpFIR_DF_DblBuf_CC(FirRateChangeArgsCache *args);

#endif

/* [EOF] dsp_fir_rate_change_sim.h */
