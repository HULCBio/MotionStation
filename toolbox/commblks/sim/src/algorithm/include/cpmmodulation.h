/*
 * Copyright 1996-2003 The MathWorks, Inc.
 * $Revision: 1.1.6.3 $ $Date: 2004/04/12 23:03:47 $
 */

#ifndef __CPM_MODULATION_H__
#define __CPM_MODULATION_H__

#include <stdlib.h>
/* --- Block dimension and pointer structure */
typedef struct {
        
    /* Dimensions */
    int_T   inFramebased;
    int_T   inFrameSize;
    int_T   numChans;

    int_T   inElem;

    int_T   outElem;
    int_T   outFrameSize;

    int_T   numBits;

    uint_T  outBufWidth;   /* ssGetDWorkWidth(S, OutputBuff); */

    int_T   tapDelayLineWidth;

    /* tasking details */
    boolean_T isMultiRateBlk;
    boolean_T isMultiTasking;

    /* Pointer values */
    real_T *phaseState;       /* (real_T *)ssGetDWork(S, PHASE_STATE);        */
    real_T *phaseVector;      /* (real_T *)ssGetDWork(S, PHASE_VECTOR);       */
    real_T *tapDelayLineBuff; /* ssGetDWork(S, TapDelayLineBuff);             */

    int_T  *tapIdx;
    int_T  *rdIdx;
    int_T  *wrIdx;
    real_T *outBuf;

} block_dims_T;

/* --- Operational parameter structure*/
typedef struct {
    int_T   bufferWidth;        /* Buffer width per channel                     */

    int_T   pulseLength;        /* (int_T) *mxGetPr(PULSE_LENGTH_ARG)           */
    int_T   samplesPerSymbol;   /* (int_T) *mxGetPr(SAMPLES_PER_SYMBOL_ARG)     */

    int_T   filterLength;       /* Number of elements in the filter             */
    real_T *filterArg;          /* mxGetPr(FILT_ARG)                            */

    int_T   numInitData;        /* mxGetNumberOfElements(INITIAL_FILTER_DATA_ARG);  mdlCheckParams must ensure that this will be 1 or numChans */
    real_T *initialFilterData;  /* (real_T *)mxGetPr(INITIAL_FILTER_DATA_ARG)   */

    int_T   numOffsets;         /* mxGetNumberOfElements(PHASE_OFFSET_ARG);         mdlCheckParams must ensure that this will be 1 or numChans */
    real_T *phaseOffset;        /* (real_T *)mxGetPr(PHASE_OFFSET_ARG);         */

    int_T   initialPhaseSwitch; /* INITIAL_PHASE_BEFORE_PREHISTORY */
                                /* or INITIAL_PHASE_AFTER_PREHISTORY */

} block_params_T;

typedef struct {
    block_dims_T   BD;
    block_params_T BP;
} block_op_data_T;


/* --- Define the input types and the mapping types */
enum {
    BINARY_INPUT = 1,
    INTEGER_INPUT,
    NUM_INPUT_TYPES
};

enum {
    BINARY_CODE = 1,
    GRAY_CODE,
    NUM_MAPPING_TYPES
};

/* --- Define initial phase options for the modulator */
enum {
    INITIAL_PHASE_BEFORE_PREHISTORY = 0,
    INITIAL_PHASE_AFTER_PREHISTORY,
    NUM_INITIAL_PHASE_OPTIONS
};

/* --- Frequency pulse shapes */
/* NOTE: index starts from zero even though the pop-up will start from 1 */
enum {
    LREC = 0,   /* Rectangular            */
    LRC,        /* Raised cosine          */
    LSRC,       /* Spectral raised cosine */
    GMSK,       /* Gaussian               */
    TFM,        /* Tamed FM               */
    NUM_FREQ_PULSE
};

/* --- Function prototypes */
void initFilter(block_dims_T *BD, block_params_T *BP);

char* initCPMMod(block_dims_T *BD, block_params_T *BP);

void modulate(block_dims_T *BD, block_params_T *BP,
              const boolean_T inportHit, const boolean_T outportHit, 
              real_T *inputPtr);

void integrate(block_dims_T *BD, creal_T *outputPtr);

char* convertAndCheck(const real_T *binPtr, real_T *symPtr, const int_T symVecLen, 
                             const int_T M, 
                             const int_T inputType, const int_T mappingType);

#endif
