/* Simulation support header file for DWT/IDWT blocks
 * 
 *  Copyright 1995-2002 The MathWorks, Inc.
 *  $Revision: 1.3 $  $Date: 2002/03/08 16:55:58 $
 */
#ifndef dsp_filterbank_sim_h
#define dsp_filterbank_sim_h

#include "dsp_sim.h"
#include "dspfilterbank_rt.h"

/* AnalysisFilterBankArgsCache is a structure used to contain parameters/arguments
 * for each of the individual simulation functions listed below 
 *
 * Note that not all members of this structure have to be defined
 * for every simulation function.  Please refer to the description in the
 * comments before each function prototype for more specific details.
 */
/* Analysis Filter Bank Run-time functions */
typedef void (*ABankFcn)(   void  *input, 
                            void  *longFiltOutput,
                            void  *shortFiltOutput,
                            void  *tapBuf,
                            void  *sums, 
                            void  *filtLong,  
                            void  *filtShort,          
                            int_T *tapIdx,
                            int_T *phaseIdx,
                            int_T  numChans,
                            int_T  inFrameSize,
                            int_T  polyphaseLongFiltLen,
                            int_T  polyphaseShortFiltLen ); 

typedef struct {
    const void *input;                 /* memory location for inputs */
    void       *memBase;               /* memory buffer base address */
    void       *tapBuf;                /* points to input buffer start address per channel */
    void       *sums;                  /* points to sums of FIR filter, two per channel,
                                               one for Long and one for Short FIR filter */
    void       *longFilt;              /* Long  FIR coeff memory address */
    void       *shortFilt;             /* Short FIR coeff memory address */
    int_T      *tapIdx;                /* points to input TapDelayBuffer location to read inputs */
    int_T      *phaseIdx;              /* active polyphase index */
    int_T       numChans;              /* number of channels */
    int_T       inFrameSize;           /* input frame size */
    int_T       inElem;
    int_T       numLevels;             /* number of filter bank levels */
    boolean_T   lpfIsLonger;           /* boolean indicating LPF is longer than HPF */
    int_T       polyphaseLongFiltLen;  /* length of Long  polyphase filter */
    int_T       polyphaseShortFiltLen; /* length of Short polyphase filter */
    int_T       maxInTapLen;           /* maximum input tap length */
    int_T       bytesPerElem;          /* bytes per element */
    ABankFcn    fptr;                  /* pointer to 2-channel analysis bank filter */
    boolean_T   needInportBuf;         /* boolean indicating an input port buffer is needed :
                                          the criteria is real inputs and cplx filter coefficients */
    byte_T     *inportBuffer;          /* inportBuffer is only used for real input and cplx filters */
} AnalysisFilterBankArgsCache;

/* Synthesis Filter Bank Byte-shuffling functions*/
extern void DSPSIM_SymABank (SimStruct *S, AnalysisFilterBankArgsCache *args);
extern void DSPSIM_AsymABank(SimStruct *S, AnalysisFilterBankArgsCache *args);

/* Byte-shuffling functions for copying buffer memory to output port(s)
 *
 * [As|S]ym      : asymmetric / symmetric tree structure
 * A[S]Bank      : analysis / synthesis filter bank
 * Multi[Single] : Multiple or Single output port(s)
 *
 */
extern void DSPSIM_SymABankMultiOutput  (SimStruct *S, AnalysisFilterBankArgsCache *args);
extern void DSPSIM_AsymABankMultiOutput (SimStruct *S, AnalysisFilterBankArgsCache *args);
extern void DSPSIM_SymABankSingleOutput (SimStruct *S, AnalysisFilterBankArgsCache *args);
extern void DSPSIM_AsymABankSingleOutput(SimStruct *S, AnalysisFilterBankArgsCache *args);


/* Synthesis Filter Bank Run-time functions */
typedef void (*RTFcnPtr)(   void  *inputToLongFilt, 
                            void  *inputToShortFilt, 
                            void  *output,
                            void  *longFiltTapBuf,
                            void  *shortFiltTapBuf,              
                            void  *longFilt,  
                            void  *shortFilt,          
                            int_T *longFiltTapIdx, 
                            int_T *shortFiltTapIdx, 
                            int_T  numChans,
                            int_T  inFrameSize,          
                            int_T  polyphaseLongFiltLen,
                            int_T  polyphaseShortFiltLen  ); 

typedef struct {
    byte_T    *memBase;         /* memory buffer base address */
    byte_T    *longFiltTapBuf;  /* points to long filter tap delay buffer start address */
    byte_T    *shortFiltTapBuf; /* points to short filter tap delay buffer start address */
    void      *longFilt;        /* Long  FIR coeff memory address */
    void      *shortFilt;       /* Short FIR coeff memory address */
    int_T     *longFiltTapIdx;  /* index to long filter tap delay buffer */
    int_T     *shortFiltTapIdx; /* index to long filter tap delay buffer */
    int_T      numChans;        /* total number of channels */
    int_T      frameSize;       /* input frame size */
    int_T      numLevels;       /* number of filter bank levels */
    boolean_T  lpfIsLonger;     /* boolean indicating LPF is longer than HPF */
    int_T      longTapLen;      /* length of long  filter input tap delay */
    int_T      shortTapLen;     /* length of short filter input tap delay */
    int_T      bytesPerElem;    /* bytes per element */
    boolean_T  needInportBuf;   /* boolean indicating an input port buffer is needed :
                                   the criteria is real inputs and cplx filter coefficients */
    boolean_T  IDWTPort;        /* boolean indicating signal coming from a single IDWT port */
    RTFcnPtr   fptr;            /* pointer to 2-channel synthesis bank */
    byte_T    *inportBuffer;    /* inportBuffer is only needed when needInportBuf flag is set */
} SynFilterBankArgsCache;

/* Synthesis Filter Bank Byte-shuffling functions*/
extern void DSPSIM_SymSBank (SimStruct *S, SynFilterBankArgsCache *args);
extern void DSPSIM_AsymSBank(SimStruct *S, SynFilterBankArgsCache *args);

#endif

/* [EOF] dsp_filterbank_sim.h */
