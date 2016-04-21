#ifndef __COMM_ALGO_DEFS__
#define __COMM_ALGO_DEFS__

/* COMM_ALGO_DEFS.h Common handshake and other utility  macros used in Comms Blockset Sfunctions
 * Copyright 1996-2004 The MathWorks, Inc.
 * $Revision: 1.1.6.3 $ $Date: 2004/04/20 23:15:47 $
 */

 

/* Macro            : SET_CREAL_PTR
 * Description      : Set the real and imaginary
 *                    parts of the creal_T struct CMPLX to 
 *                    the give RE and IM
 */
#define SET_CREAL_PTR(CMPLX,RE,IM) \
{ \
	CMPLX->re = RE; \
    CMPLX->im = IM; \
}
/*****************************************************************************/
/* Macro            : RESET_CREAL_PTR
 * Description      : Initializes the real and imaginary
 *                    parts of the creal_T struct CMPLX to 0.0;
 *                    
 */
#define RESET_CREAL_PTR(CMPLX) \
{ \
    SET_CREAL_PTR(CMPLX,0.0,0.0); \
}
/*****************************************************************************/
/* Macro            : INCREMENT_CMPLX_PTR
 * Description      : Increment the real and imaginary
 *                    parts of the creal_T struct CMPLX with RE and IM
 *                    
 */
#define INCREMENT_CMPLX_PTR(CMPLX, RE, IM) \
{ \
	CMPLX->re += RE; \
	CMPLX->im += IM; \
}

#endif

 
