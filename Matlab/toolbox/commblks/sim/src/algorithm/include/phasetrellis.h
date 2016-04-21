/*
 * Copyright 1996-2003 The MathWorks, Inc.
 * $Revision: 1.1.6.2 $ $Date: 2004/04/12 23:03:48 $
 */

#ifndef __PHASE_TRELLIS_H__
#define __PHASE_TRELLIS_H__

#include "comm_defs.h"
#include "cpmmodulation.h"

typedef struct {
    int_T   input;              /* Input value corresponding to the output    */
    real_T  nextPhase;          /* Next phase state                           */
    int_T  *dataState;          /* The data state of the next output          */
    void   *output;           /* Output data or waveform                    */
} transition_T;

typedef struct {
    real_T  phase;              /* phase of the state                         */
    int_T  *data;               /* data used to define the state (prehistory) */
    transition_T *transitions;  /* output transitions due to inputs           */
} state_T;

typedef struct {
    /* --- Basic parameters */
    int_T M;
    int_T L;
    int_T m;
    int_T p;
    int_T samplesPerSymbol;

    /* --- Derived parameters */
    int_T  numPhaseStates;
    int_T  numDataStates;
    int_T  numStates;

    state_T *states;
} stateStruct_T;

typedef struct {
    int_T   numPhases;
    real_T  *phase;
}phaseOffset_T;

phaseOffset_T *createPhaseOffsets( SimStruct *S,
                                   const int_T M,                  /* Alphabet size    */
                                   const int_T L,                  /* Pulse length     */
                                   const int_T samplesPerSymbol,
                                   const real_T *filterPtr,        /* Matlab filter                */
                                   const int_T  numCoef,          /* Number of filter coeficients */
							       const real_T *preHistory,		  /* Data prehistory */
		                           const real_T initialPhase);	  /* Initial phase offset */

stateStruct_T *createPhaseTrellis(SimStruct *S,
                                   const int_T M,                  /* Alphabet size                */
                                  const int_T L,                  /* Pulse length                 */
                                  const int_T m, const int_T p,   /* Modindex h = m/p             */
                                  const int_T samplesPerSymbol,
                                  const real_T *filterPtr,        /* Matlab filter                */
                                  const int_T  numCoef,           /* Number of filter coeficients */
                                  const phaseOffset_T *phaseOffsets); /* phase offsets */

void freePhaseTrellis(stateStruct_T *stateObj);

enum {INT_T_VEC=0,
      REAL_T_VEC
};


char* dec2base( const void  *decVal,
                const int_T  inBase,
                const int_T  inLen,
                const int_T  inType,
                const int_T  inMapped,
                const int_T  inGrayMapped,
                void        *outVec,
                const int_T  outBase,
                const int_T  outSize,
                const int_T  outType,
                const int_T  outMapped);

char* base2dec( const void  *baseVal,
                const int_T  base,
                const int_T  inSize,
                const int_T  inLen,
                const int_T  inType,
                void        *outVec,
                const int_T  outType,
                const int_T  outMapped);

#endif
