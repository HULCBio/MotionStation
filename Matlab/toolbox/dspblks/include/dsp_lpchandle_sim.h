/* Simulation support header file for LPC/RC to autocorrelation coeffs. block
 * 
 *  Copyright 1995-2002 The MathWorks, Inc.
 *  $Revision: 1.1 $  $Date: 2002/07/29 21:13:48 $
 */
#ifndef dsp_lpchandle_sim_h                                  
#define dsp_lpchandle_sim_h

#include "dsp_sim.h"

/* The following functions are called to take appropriate action in the case
 * when the first coefficient of input LPC polynomial is not equal to unity. 
 * We have the options to :-
 * 1. Ignore
 * 2. Normalize the entire LPC polynomial vector with the first non-unity coeff. 
 * 3. Normalize and warn
 * 4. Error out
 */
extern void LPCPolyCorrectIgnore(SimStruct *S, const real32_T *A, real32_T *normLPC, int_T order, boolean_T *doNormalize);
extern void LPCPolyCorrectNorm_R(SimStruct *S, const real32_T *A, real32_T *normLPC, int_T order, boolean_T *doNormalize);
extern void LPCPolyCorrectNorm_D(SimStruct *S, const real_T *A, real_T *normLPC, int_T order, boolean_T *doNormalize);
extern void LPCPolyCorrectWarn_R(SimStruct *S, const real32_T *A, real32_T *normLPC, int_T order, boolean_T *doNormalize);
extern void LPCPolyCorrectWarn_D(SimStruct *S, const real_T *A, real_T *normLPC, int_T order, boolean_T *doNormalize);
extern void LPCPolyCorrectError_R(SimStruct *S, const real32_T *A, real32_T *normLPC, int_T order, boolean_T *doNormalize);
extern void LPCPolyCorrectError_D(SimStruct *S, const real_T *A, real_T *normLPC, int_T order, boolean_T *doNormalize);


#endif


