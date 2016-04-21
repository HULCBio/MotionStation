/*
 * Copyright 1996-2003 The MathWorks, Inc.
 * $Revision: 1.1.6.3 $ $Date: 2004/04/12 23:03:50 $
 */
 
#ifndef __TRELLIS_DECODE_H__
#define __TRELLIS_DECODE_H__


#include "buff.h"
#include "phasetrellis.h"

#define REAL_METRIC

typedef struct {
    int_T input;        /* Previous input causing the path to arrive at this state */
    int_T prevState;    /* Previous state due to the input                         */
} stateMem_T;

typedef struct {
    real_T pathMetric;  /* Accumulated path metric for this state                  */
} pathMem_T;

typedef struct {
    int_T           tbLen;      /* Traceback length                                     */
    int_T           memLen;     /* Memory length (usually tbLen+1)                      */
    boolean_T       traceBack;  /* Indicates that traceback should be performed         */
    int_T           scalingMode;/* Indicates whether metric scaling is applied          */

    int_T           pathPosIdx; /* Position within  the decoder memory                  */

    stateMem_T     *stateMem;   /* Decoder memory array                                 */
    pathMem_T      *pathMem;    /* Accumulated path metric                              */
    pathMem_T      *tempPathMem;/* Accumulated path metric                              */

    stateStruct_T  *stateObj;   /* State transition object                              */

} decoder_T;

#define MIN_METRIC -10000000
#define MAX_METRIC  10000000
#define OUTPUT_DURING_TRACEBACK 0

typedef enum {
    REAL_CORRELATION_METRIC = 0,
    ABS_CORRELATION_METRIC,
    EUCLIDEAN_METRIC,
    HAMMING_METRIC,
    NUM_METRIC_TYPES
} metricOptions_T;

typedef enum {
    SCALING_OFF = 0,
    SCALING_ON,
    NUM_SCALE_OPTIONS
} scaleOptions_T;

typedef enum {
    ALL_STATES_POSSIBLE = -1,
    SPECIFY_STARTING_STATE = 1,
    NUM_INITIAL_STATE_OPTIONS = 2
} initStateOptions_T;

enum {
    DECODE_ENTIRE_BUFFER = -1,
    NUM_DECODE_LENGTH_OPTIONS = 1
};


#define CMULT(A,B,C) { \
    (C).re = (A).re * (B).re - (A).im *(B).im;  \
    (C).im = (A).re * (B).im + (A).im *(B).re;  \
}

#define CMULT_ACONJ(A,B,C) { \
    (C).re = (A).re * (B).re + (A).im *(B).im;  \
    (C).im = (A).re * (B).im - (A).im *(B).re;  \
}

#define CMULT_BCONJ(A,B,C) { \
    (C).re =   (A).re * (B).re + (A).im *(B).im;  \
    (C).im = -((A).re * (B).im - (A).im *(B).re);  \
}

char* computeMetric( const void *rxSym,
                            const void **refSym,
                            const int_T symLength,
                            const int_T numRef,
                            const metricOptions_T metricType,
                            real_T     *metricVec );

decoder_T*   createDecoderObject(SimStruct *S,
                                 const stateStruct_T *stateObj, 
                                 const int_T tbLen, 
                                 const initStateOptions_T startState, 
                                 const scaleOptions_T scalingMode);

char*        decodeSymbols(decoder_T *decoderObj, 
                           buff_T *inputBuff, 
                           buff_T *outputBuff, 
                           const int_T decodeCount);

void         freeDecoderObject(decoder_T *decoderObj);

#endif
