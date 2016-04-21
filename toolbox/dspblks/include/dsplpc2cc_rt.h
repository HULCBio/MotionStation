/*
 *  dsplpc2cc_rt.h
 *
 *  Copyright 1995-2004 The MathWorks, Inc.
 *  $Revision: 1.2.4.3 $ $Date: 2004/04/12 23:12:02 $
 */

#ifndef dsplpc2cc_rt_h
#define dsplpc2cc_rt_h

#include "dsp_rt.h"

#ifdef DSPLPC2CC_EXPORTS
#define DSPLPC2CC_EXPORT EXPORT_FCN
#else
#define DSPLPC2CC_EXPORT extern
#endif

/* 
 * List of individual LPC to/from CC functions:-
 */
/* 
 * Function naming glossary 
 * --------------------------- 
 * 
 * MWDSP = MathWorks DSP Blockset 
 * 
 * Data types - (describe inputs to functions, not outputs) 
 * R = real single-precision 
 * D = real double-precision 
 */ 


/*
 * Function naming convention
 * ---------------------------
 *
 * MWDSP_Burg_<outputoption>_<DataType>
 *
 * 1)  MWDSP is a prefix used with all Mathworks DSP runtime library functions
 * 2) The second field indicates the  conversion this algorithm is performing. 
 *    Lpc2Cc indicates that the LPC is being converted to Cepstral coefficients(CC)
 *    Cc2Lpc indicates that the Cepstral coefficients (CC) are being converted to LPC
 *    Lpc2CcWE indicates the the conversion is LPC to CC, and the prediction error
 *    power associated with the LPC polynomial is non-unity. 
 * 3) The third field is a string indicating the datatype.
 */

DSPLPC2CC_EXPORT void MWDSP_Cc2Lpc_D(const real_T *cc, real_T *lpc, const int_T Np);
DSPLPC2CC_EXPORT void MWDSP_Lpc2Cc_D(const real_T *lpc, real_T *cc, const int_T Np, const int_T Ncc);
DSPLPC2CC_EXPORT void MWDSP_Cc2Lpc_R(const real32_T *cc, real32_T *lpc, const int_T Np);
DSPLPC2CC_EXPORT void MWDSP_Lpc2Cc_R(const real32_T *lpc, real32_T *cc, const int_T Np, const int_T Ncc);

#endif /* dsplpc2cc_rt_h */

/* [EOF] dsplpc2cc_rt.h */
