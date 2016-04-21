/*
 *  dsp_ts_err.h
 *  Macros for common error checking for DSP Blockset.
 *
 *  Functions to check the input and output port complexity information.
 *
 *  NOTE: This is query on the port dimension information. Therefore, 
 *  the dimension information must already be set for the port.
 *
 *
 *  Copyright 1995-2002 The MathWorks, Inc.
 *  $Revision: 1.7 $ $Date: 2002/04/14 20:35:10 $
 */

#ifndef dsp_ts_err_h
#define dsp_ts_err_h

#include "dsp_ts_sim.h"

/****************************************************/
/*         DEFAULT ERROR MESSAGES                   */
/****************************************************/

#define BlockMustBeContinuous   "Discrete sample times not allowed."
#define BlockMustBeDiscrete     "Continuous sample times not allowed."



/****************************************************/
/*              ERROR CHECKING                      */
/****************************************************/

#define ErrorIfBlockIsContinuous(S, port)           \
    if (isBlockContinuous(S, port)) {               \
        THROW_ERROR(S, BlockMustBeDiscrete);          \
    }                     

#define ErrorIfBlockIsDiscrete(S, port)             \
    if (isBlockDiscrete(S, port)) {                 \
        THROW_ERROR(S, BlockMustBeContinuous);        \
    }                     

#endif  /* dsp_cplx_err_h */
/* end of dsp_cplx_err.h */
