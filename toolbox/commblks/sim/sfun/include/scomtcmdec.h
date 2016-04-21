/*    
 *    Header file for TCM Decoder S-function in Communications
 *    Blockset.
 *
 *    Copyright 1996-2003 The MathWorks, Inc.
 *    $Revision: 1.1.6.2 $ $Date: 2003/06/05 15:20:12 $
 */

#ifndef scomtcmdec_h
#define scomtcmdec_h

#include <math.h> /* for pow */
#include "comm_defs.h"
#include "viterbi_acs_tbdec.h"
       
enum {INPORT_DATA=0, INPORT_RESET};
enum {OUTPORT_DATA=0};
enum {BMETRIC=0, STATE_METRIC, TEMP_METRIC, TBSTATE, TBINPUT, TBPTR, NXTST, ENCOUT, NUM_DWORK};
enum {CONT=1, TRUNC, TERM};

enum {TRELLIS_IN_NUMBITS_ARGC = 0,  /* number of input bits, k      */
      TRELLIS_OUT_NUMBITS_ARGC,     /* number of output bits, n     */
      TRELLIS_NUM_STATES_ARGC,      /* number of states             */
      TRELLIS_OUTPUT_ARGC,          /* output matrix (decimal)      */
      TRELLIS_NEXT_STATE_ARGC,      /* next state matrix            */
      REAL_SIG_PTS_ARGC,            /* signal constellation - real  */
      IMAG_SIG_PTS_ARGC,            /* signal constellation - imag  */
      TB_ARGC,                      /* traceback depth              */
      OPMODE_ARGC,                  /* operation mode               */
      RESET_ARGC,                   /* reset port                   */ 
      NUM_ARGS}; 

#define TRELLIS_IN_NUMBITS_ARG(S)  (ssGetSFcnParam(S, TRELLIS_IN_NUMBITS_ARGC))
#define TRELLIS_OUT_NUMBITS_ARG(S) (ssGetSFcnParam(S, TRELLIS_OUT_NUMBITS_ARGC))
#define TRELLIS_NUM_STATES_ARG(S)  (ssGetSFcnParam(S, TRELLIS_NUM_STATES_ARGC))
#define TRELLIS_OUTPUT_ARG(S)      (ssGetSFcnParam(S, TRELLIS_OUTPUT_ARGC))
#define TRELLIS_NEXT_STATE_ARG(S)  (ssGetSFcnParam(S, TRELLIS_NEXT_STATE_ARGC))
#define REAL_SIG_PTS_ARG(S)        (ssGetSFcnParam(S, REAL_SIG_PTS_ARGC))
#define IMAG_SIG_PTS_ARG(S)        (ssGetSFcnParam(S, IMAG_SIG_PTS_ARGC))
#define TB_ARG(S)                  (ssGetSFcnParam(S, TB_ARGC))
#define OPMODE_ARG(S)              (ssGetSFcnParam(S, OPMODE_ARGC))
#define RESET_ARG(S)               (ssGetSFcnParam(S, RESET_ARGC))


#define IS_CONT_MODE(S)   ((int_T)((mxGetPr(OPMODE_ARG(S))[0]) == CONT))
#define HAS_RST_PORT(S) (boolean_T) \
(IS_CONT_MODE(S) && (((int_T) mxGetPr(RESET_ARG(S))[0]) == 1))

#endif /* scomtcmdec_h*/ 

/* EOF */


