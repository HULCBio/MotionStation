/*
 * Copyright 1996-2002 The MathWorks, Inc.
 * $Revision: 1.11 $ $Date: 2002/03/24 02:11:10 $
 */
 
#ifndef __SCOMCPMDEMOD_H__
#define __SCOMCPMDEMOD_H__

#include "cpmmodulation.h"
#include "trellisdecode.h"

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
    ARGC_TRACEBACK_LENGTH,
    ARGC_MOD_IDX_M,
    ARGC_MOD_IDX_P,
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
#define INITIAL_FILTER_DATA_ARG     ssGetSFcnParam( S, ARGC_INITIAL_FILTER_DATA   )
#define OUTBUF_INITCOND_ARG         ssGetSFcnParam( S, ARGC_INIT_COND_OUTBUF      )  
#define TRACEBACK_LENGTH_ARG        ssGetSFcnParam( S, ARGC_TRACEBACK_LENGTH      )
#define MOD_IDX_M_ARG               ssGetSFcnParam( S, ARGC_MOD_IDX_M             )
#define MOD_IDX_P_ARG               ssGetSFcnParam( S, ARGC_MOD_IDX_P             )

/* Port Index Enumerations */
enum {INPORT  = 0, NUM_INPORTS};
enum {OUTPORT = 0, NUM_OUTPORTS};


/* DWork indices */
enum {
    NUM_DWORKS = 0
};

/* PWork indices */
enum {
    NUM_PWORKS = 0
};

typedef struct {
    decoder_T  *decoderObj;
    buff_T     *inputBuff;
    buff_T     *outputBuff;
    real_T     *tempOutputSymbols;
} userData_T;

#endif
