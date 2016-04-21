/*    
 *    Header file for MLSE Equalizer S-function in Communications
 *    Blockset.
 *
 *    Copyright 1996-2004 The MathWorks, Inc.
 *    $Revision: 1.1.8.5 $ $Date: 2004/04/12 23:03:14 $
 */

#ifndef scommlseeq_h
#define scommlseeq_h

#include "comm_defs.h"
#include <math.h>

/* S-function helper file */
#include "viterbi_acs_tbdec.h"

enum {INPORT_DATA=0,INPORT_CHAN, INPORT_RESET};
enum {OUTPORT_DATA=0};
enum {VIA_PORT=1, VIA_MASK};
enum {MLSE_DISABLE=0, MLSE_ENABLE};
enum {CONT=1, RST_FRAME};
 
/* Work Vectors:
 * BMETRIC      : Stores the branch metric for all branch in trellis 
 * STATE_METRIC : Stores state metrics of every state
 * TEMP_METRIC  : Stores temporary state metric
 * TBSTATE      : Stores the traceback state
 * TBINPUT      : Stores the traceback input
 * TBPTR        : Stores the traceback pointer to begin traceback
 * EXP_OUTPUT   : Stores the expected output computed from channel 
 *                estimates and constellation information
 * LEN_PREAMBLE : Stores the preamble length
 * LEN_POSTAMBLE: Stores the postamble length
 * CHANTAPS_IM  : Channel values for IMAG part 
 * CHANTAPS_RE  : Channel values for REAL part 
 * NUM_STATES   : Stores the number of trellis states
 * NUM_DWORK    : Number of Work Vectors *
 */
enum {BMETRIC=0, STATE_METRIC, TEMP_METRIC, TBSTATE, TBINPUT, TBPTR, \
      EXP_OUTPUT, LEN_PREAMBLE, LEN_POSTAMBLE, CHANTAPS_IM, CHANTAPS_RE,\
      NUM_STATES, NXT_STATES, OUTPUTS, NUM_DWORK};

/* Mask parameters  */
enum {CHAN_MODE_ARGC,     /* Specify Channel : via Port or via Mask */ 
      CHAN_COEFF_RE_ARGC, /* Channel coefficient vector - real      */     
      CHAN_COEFF_IM_ARGC, /* Channel coefficient vector - imag      */     
      CONST_PTS_RE_ARGC,  /* Constellation points - real            */  
      CONST_PTS_IM_ARGC,  /* Constellation points - imag            */  
      TB_ARGC,            /* Traceback depth                        */
      OPMODE_ARGC,        /* Operation mode                         */
      EN_PREAMBLE_ARGC,   /* Input contains preamble                */  
      PREAMBLE_ARGC,      /* Preamble                               */
      EN_POSTAMBLE_ARGC,  /* Input contains postamble               */    
      POSTAMBLE_ARGC,     /* Postamble                              */
      SAMP_PER_SYM_ARGC,  /* Samples per input symbol               */
      RESET_ARGC,         /* Enable input port to reset Viterbi
                           * available in CONT mode only
                           */ 
      NUM_ARGS};          /* Total number of arguments              */

#define CHAN_MODE_ARG(S)     (ssGetSFcnParam(S, CHAN_MODE_ARGC))
#define CHAN_COEFF_RE_ARG(S) (ssGetSFcnParam(S, CHAN_COEFF_RE_ARGC))
#define CHAN_COEFF_IM_ARG(S) (ssGetSFcnParam(S, CHAN_COEFF_IM_ARGC))
#define CONST_PTS_RE_ARG(S)  (ssGetSFcnParam(S, CONST_PTS_RE_ARGC))
#define CONST_PTS_IM_ARG(S)  (ssGetSFcnParam(S, CONST_PTS_IM_ARGC))
#define TB_ARG(S)            (ssGetSFcnParam(S, TB_ARGC))
#define OPMODE_ARG(S)        (ssGetSFcnParam(S, OPMODE_ARGC))
#define EN_PREAMBLE_ARG(S)   (ssGetSFcnParam(S, EN_PREAMBLE_ARGC))
#define PREAMBLE_ARG(S)      (ssGetSFcnParam(S, PREAMBLE_ARGC))
#define EN_POSTAMBLE_ARG(S)  (ssGetSFcnParam(S, EN_POSTAMBLE_ARGC))
#define POSTAMBLE_ARG(S)     (ssGetSFcnParam(S, POSTAMBLE_ARGC))
#define SAMP_PER_SYM_ARG(S)  (ssGetSFcnParam(S, SAMP_PER_SYM_ARGC))
#define RESET_ARG(S)         (ssGetSFcnParam(S, RESET_ARGC))

#define IS_CONT_MODE(S)   ((int_T)((mxGetPr(OPMODE_ARG(S))[0]) == CONT))

/* Real and Imaginary part defined for Complex multiplication */
#define CPLX_MULT_REAL(reA,imA,reB,imB) ((reA*reB)-(imA*imB))
#define CPLX_MULT_IMAG(reA,imA,reB,imB) ((reA*imB)+(imA*reB))

/* Check channel coefficients'complexity */
#define IS_CHAN_CPLX_PORT(S) (boolean_T) (ssGetInputPortComplexSignal \
                             (S, INPORT_CHAN) == COMPLEX_YES)

/* Number of channel coefficient(s) for port and dialog option */
#define CHMEM_PORT(S,ns) ((int_T)(ssGetInputPortWidth(S, INPORT_CHAN)/ns) -1)
#define CHMEM_MASK(S,ns) ((int_T)(mxGetNumberOfElements(CHAN_COEFF_RE_ARG(S))/ns) -1)

/* Check for presence of channel and reset port */
#define HAS_CHAN_PORT(S) (boolean_T)\
        ( (int_T)(mxGetPr(ssGetSFcnParam(S, CHAN_MODE_ARGC))[0])==VIA_PORT )
#define HAS_RST_PORT(S) (boolean_T) \
(IS_CONT_MODE(S) && (((int_T) mxGetPr(RESET_ARG(S))[0]) == 1))
        
#endif /*scommlseeq_h*/ 

/* EOF */
