#ifndef __COMM_HS_DEFS__
#define __COMM_HS_DEFS__

/* COMM_HS_DEFS.h Common handshake and other utility  macros used in Comms Blockset Sfunctions
 * Copyright 1996-2004 The MathWorks, Inc.
 * $Revision: 1.1.6.3 $ $Date: 2004/04/20 23:15:48 $
 */

/* Macro            : COMM_IS_INPORT_FRAME_BASED
 * Description      : Checks the given input port for frameness
 */

#define COMM_IS_INPORT_FRAME_BASED(S, IN_PORT) \
    ((Frame_T)ssGetInputPortFrameData(S, IN_PORT) == FRAME_YES)

/*****************************************************************************/
/* Macro            : COMM_IS_INPORT_CMPLX
 * Description      : Checks the given input port for complexity
 */

#define COMM_IS_INPORT_CMPLX(S, IN_PORT) \
    ((CSignal_T)ssGetInputPortComplexSignal(S, IN_PORT) == COMPLEX_YES)
    
/****************************************************************************/

#endif



