/*
 * Copyright 1996-2002 The MathWorks, Inc.
 * $Revision: 1.10 $ $Date: 2002/03/24 02:11:01 $
 */
 
#ifndef __SCOMCPMMOD_H__
#define __SCOMCPMMOD_H__

#include "cpmmodulation.h"

/* --- Define the input parameters */
enum {
    ARGC_M = 0,
    ARGC_INPUT_TYPE,
    ARGC_MAPPING_TYPE,
    ARGC_MOD_IDX,
    ARGC_PULSE_SHAPE,
    ARGC_BT,
    ARGC_MAIN_LOBE_PULSE_LENGTH,
    ARGC_ROLL_OFF,
    ARGC_PULSE_LENGTH,
    ARGC_PHASE_OFFSET,
    ARGC_SAMPLES_PER_SYMBOL,
    ARGC_FILT,
    ARGC_INITIAL_FILTER_DATA,
    ARGC_INIT_COND_OUTBUF,
    NUM_ARGS
};

#define M_ARG                       ssGetSFcnParam( S, ARGC_M                     )  
#define INPUT_TYPE_ARG              ssGetSFcnParam( S, ARGC_INPUT_TYPE            )  
#define MAPPING_TYPE_ARG            ssGetSFcnParam( S, ARGC_MAPPING_TYPE          )  
#define MOD_IDX_ARG                 ssGetSFcnParam( S, ARGC_MOD_IDX               )  
#define PULSE_SHAPE_ARG             ssGetSFcnParam( S, ARGC_PULSE_SHAPE           )  
#define BT_ARG                      ssGetSFcnParam( S, ARGC_BT                    )  
#define MAIN_LOBE_PULSE_LENGTH_ARG  ssGetSFcnParam( S, ARGC_MAIN_LOBE_PULSE_LENGTH)
#define ROLL_OFF_ARG                ssGetSFcnParam( S, ARGC_ROLL_OFF              )  
#define PULSE_LENGTH_ARG            ssGetSFcnParam( S, ARGC_PULSE_LENGTH          )  
#define PHASE_OFFSET_ARG            ssGetSFcnParam( S, ARGC_PHASE_OFFSET          )  
#define SAMPLES_PER_SYMBOL_ARG      ssGetSFcnParam( S, ARGC_SAMPLES_PER_SYMBOL    )  
#define FILT_ARG                    ssGetSFcnParam( S, ARGC_FILT                  )  
#define OUTBUF_INITCOND_ARG         ssGetSFcnParam( S, ARGC_INIT_COND_OUTBUF      )  
#define INITIAL_FILTER_DATA_ARG     ssGetSFcnParam( S, ARGC_INITIAL_FILTER_DATA   )


/* Port Index Enumerations */
enum {INPORT  = 0, NUM_INPORTS};
enum {OUTPORT = 0, NUM_OUTPORTS};

/* DWork indices */
enum {
    TapDelayIndex = 0, /* Index into the input tap-delay line buffer           */
    OutputBuff,        /* Interpolated and filtered output sample buffer       */
    WriteIdx,          /* Index to write to in the output sample buffer        */
    ReadIdx,           /* Index to read from in the output sample buffer       */
    TapDelayLineBuff,  /* Raw input sample (Direct-Form II) tap delay buffer   */
    PHASE_STATE,       /* Use for the initial/final phase state                */
    PHASE_VECTOR,      /* The is output of the filter                          */
    BIN2INT_VECTOR,    /* Used to hold the intger values for the binary inputs */
    NUM_DWORKS
};


/* PWork indices (used by RTW) */
enum {CffPtr = 0, NUM_PWORKS};

void populateUserData(SimStruct *S, block_dims_T *BD, block_params_T *BP);

#endif
