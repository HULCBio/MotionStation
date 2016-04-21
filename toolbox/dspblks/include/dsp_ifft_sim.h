/*
 * dsp_ifft_sim - DSP Blockset 1-D IFFT simulation support
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.7.4.2 $  $Date: 2004/04/12 23:11:25 $
 */

#ifndef dsp_ifft_sim_h
#define dsp_ifft_sim_h

#include "dsp_fft_sim.h"

/*
 * IFFT functions for simulation use only
 */

#ifdef __cplusplus
extern "C" {
#endif

/* NOP = No operation */
extern void dspifft_NOP(MWDSP_FFTArgsCache *args);


/* Scalar cases: */
extern void dspifft_scalar_ZZ(MWDSP_FFTArgsCache *args); /* Complex double in, complex double out */
extern void dspifft_scalar_ZD(MWDSP_FFTArgsCache *args); /* Complex double in, real double out */
extern void dspifft_scalar_DZ(MWDSP_FFTArgsCache *args); /* Real double in, complex double out */
extern void dspifft_scalar_DD(MWDSP_FFTArgsCache *args); /* Real double in, real double out */

extern void dspifft_scalar_CC(MWDSP_FFTArgsCache *args); /* Complex single in, complex single out */
extern void dspifft_scalar_CR(MWDSP_FFTArgsCache *args); /* Complex single in, real single out */
extern void dspifft_scalar_RC(MWDSP_FFTArgsCache *args); /* Real single in, complex single out */
extern void dspifft_scalar_RR(MWDSP_FFTArgsCache *args); /* Real single in, real single out */


/* Output is always in linear order. Input can be either in linear or bit-reversed order. */

/* Double precision IFFT */
/* Linear order at input */
extern void dspifft_R2_TRIG_ZZ(MWDSP_FFTArgsCache *args); /* Complex double in, complex double out, trig fcn */          
extern void dspifft_R2_TBLM_ZZ(MWDSP_FFTArgsCache *args); /* Complex double in, complex double out, table (memory opt) */
extern void dspifft_R2_TBLS_ZZ(MWDSP_FFTArgsCache *args); /* Complex double in, complex double out, table (speed opt) */ 
extern void dspifft_R2_TBLM_2D_ZZ(MWDSP_FFTArgsCache *args); /* Complex double in, complex double out, table (memory opt) */
extern void dspifft_R2_TBLS_2D_ZZ(MWDSP_FFTArgsCache *args); /* Complex double in, complex double out, table (speed opt) */ 
                                                                                                                         
extern void dspifft_R2_TRIG_DZ(MWDSP_FFTArgsCache *args); /* Real double in, complex double out, trig fcn */             
extern void dspifft_R2_TBLM_DZ(MWDSP_FFTArgsCache *args); /* Real double in, complex double out, table (memory opt) */   
extern void dspifft_R2_TBLS_DZ(MWDSP_FFTArgsCache *args); /* Real double in, complex double out, table (speed opt) */    
extern void dspifft_R2_TBLM_2D_DZ(MWDSP_FFTArgsCache *args); /* Real double in, complex double out, table (memory opt) */   
extern void dspifft_R2_TBLS_2D_DZ(MWDSP_FFTArgsCache *args); /* Real double in, complex double out, table (speed opt) */    
                                                                                                                         
extern void dspifft_R2_CS_TRIG_ZD(MWDSP_FFTArgsCache *args); /* Complex double in, real double out, trig fcn */          
extern void dspifft_R2_CS_TBLM_ZD(MWDSP_FFTArgsCache *args); /* Complex double in, real double out, table (memory opt) */
extern void dspifft_R2_CS_TBLS_ZD(MWDSP_FFTArgsCache *args); /* Complex double in, real double out, table (speed opt) */ 
extern void dspifft_R2_CS_TBLM_2D_ZD(MWDSP_FFTArgsCache *args); /* Complex double in, real double out, table (memory opt) */
extern void dspifft_R2_CS_TBLS_2D_ZD(MWDSP_FFTArgsCache *args); /* Complex double in, real double out, table (speed opt) */ 
                                                                                                                         
extern void dspifft_R2_CS_TRIG_DD(MWDSP_FFTArgsCache *args); /* Real double in, real double out, trig fcn */             
extern void dspifft_R2_CS_TBLM_DD(MWDSP_FFTArgsCache *args); /* Real double in, real double out, table (memory opt) */   
extern void dspifft_R2_CS_TBLS_DD(MWDSP_FFTArgsCache *args); /* Real double in, real double out, table (speed opt) */    
extern void dspifft_R2_CS_TBLM_2D_DD(MWDSP_FFTArgsCache *args); /* Real double in, real double out, table (memory opt) */   
extern void dspifft_R2_CS_TBLS_2D_DD(MWDSP_FFTArgsCache *args); /* Real double in, real double out, table (speed opt) */    

/* Bit-reversed order at input */
extern void dspifft_R2_BR_TRIG_ZZ(MWDSP_FFTArgsCache *args); /* Complex double in, complex double out, trig fcn */          
extern void dspifft_R2_BR_TBLM_ZZ(MWDSP_FFTArgsCache *args); /* Complex double in, complex double out, table (memory opt) */
extern void dspifft_R2_BR_TBLS_ZZ(MWDSP_FFTArgsCache *args); /* Complex double in, complex double out, table (speed opt) */ 
extern void dspifft_R2_BR_TBLM_2D_ZZ(MWDSP_FFTArgsCache *args); /* Complex double in, complex double out, table (memory opt) */
extern void dspifft_R2_BR_TBLS_2D_ZZ(MWDSP_FFTArgsCache *args); /* Complex double in, complex double out, table (speed opt) */ 
                                                                                                                            
extern void dspifft_R2_BR_TRIG_DZ(MWDSP_FFTArgsCache *args); /* Real double in, complex double out, trig fcn */             
extern void dspifft_R2_BR_TBLM_DZ(MWDSP_FFTArgsCache *args); /* Real double in, complex double out, table (memory opt) */   
extern void dspifft_R2_BR_TBLS_DZ(MWDSP_FFTArgsCache *args); /* Real double in, complex double out, table (speed opt) */    
extern void dspifft_R2_BR_TBLM_2D_DZ(MWDSP_FFTArgsCache *args); /* Real double in, complex double out, table (memory opt) */   
extern void dspifft_R2_BR_TBLS_2D_DZ(MWDSP_FFTArgsCache *args); /* Real double in, complex double out, table (speed opt) */    
                                                                                                                            
extern void dspifft_R2_BR_CS_TRIG_ZD(MWDSP_FFTArgsCache *args); /* Complex double in, real double out, trig fcn */
extern void dspifft_R2_BR_CS_TBLM_ZD(MWDSP_FFTArgsCache *args); /* Complex double in, real double out, table (memory opt) */
extern void dspifft_R2_BR_CS_TBLS_ZD(MWDSP_FFTArgsCache *args); /* Complex double in, real double out, table (speed opt) */
extern void dspifft_R2_BR_CS_TBLM_2D_ZD(MWDSP_FFTArgsCache *args); /* Complex double in, real double out, table (memory opt) */
extern void dspifft_R2_BR_CS_TBLS_2D_ZD(MWDSP_FFTArgsCache *args); /* Complex double in, real double out, table (speed opt) */
                                                                                                                            
extern void dspifft_R2_BR_CS_TRIG_DD(MWDSP_FFTArgsCache *args); /* Real double in, real double out, trig fcn */
extern void dspifft_R2_BR_CS_TBLM_DD(MWDSP_FFTArgsCache *args); /* Real double in, real double out, table (memory opt) */
extern void dspifft_R2_BR_CS_TBLS_DD(MWDSP_FFTArgsCache *args); /* Real double in, real double out, table (speed opt) */
extern void dspifft_R2_BR_CS_TBLM_2D_DD(MWDSP_FFTArgsCache *args); /* Real double in, real double out, table (memory opt) */
extern void dspifft_R2_BR_CS_TBLS_2D_DD(MWDSP_FFTArgsCache *args); /* Real double in, real double out, table (speed opt) */


/* Single precision IFFT */
/* Linear order at input */
extern void dspifft_R2_TRIG_CC(MWDSP_FFTArgsCache *args); /* Complex single in, complex single out, trig fcn */
extern void dspifft_R2_TBLM_CC(MWDSP_FFTArgsCache *args); /* Complex single in, complex single out, table (memory opt) */
extern void dspifft_R2_TBLS_CC(MWDSP_FFTArgsCache *args); /* Complex single in, complex single out, table (speed opt) */ 
extern void dspifft_R2_TBLM_2D_CC(MWDSP_FFTArgsCache *args); /* Complex single in, complex single out, table (memory opt) */
extern void dspifft_R2_TBLS_2D_CC(MWDSP_FFTArgsCache *args); /* Complex single in, complex single out, table (speed opt) */ 

extern void dspifft_R2_TRIG_RC(MWDSP_FFTArgsCache *args); /* Real single in, complex single out, trig fcn */
extern void dspifft_R2_TBLM_RC(MWDSP_FFTArgsCache *args); /* Real single in, complex single out, table (memory opt) */   
extern void dspifft_R2_TBLS_RC(MWDSP_FFTArgsCache *args); /* Real single in, complex single out, table (speed opt) */    
extern void dspifft_R2_TBLM_2D_RC(MWDSP_FFTArgsCache *args); /* Real single in, complex single out, table (memory opt) */   
extern void dspifft_R2_TBLS_2D_RC(MWDSP_FFTArgsCache *args); /* Real single in, complex single out, table (speed opt) */    

extern void dspifft_R2_CS_TRIG_CR(MWDSP_FFTArgsCache *args); /* Complex single in, real single out, trig fcn */
extern void dspifft_R2_CS_TBLM_CR(MWDSP_FFTArgsCache *args); /* Complex single in, real single out, table (memory opt) */
extern void dspifft_R2_CS_TBLS_CR(MWDSP_FFTArgsCache *args); /* Complex single in, real single out, table (speed opt) */ 
extern void dspifft_R2_CS_TBLM_2D_CR(MWDSP_FFTArgsCache *args); /* Complex single in, real single out, table (memory opt) */
extern void dspifft_R2_CS_TBLS_2D_CR(MWDSP_FFTArgsCache *args); /* Complex single in, real single out, table (speed opt) */ 

extern void dspifft_R2_CS_TRIG_RR(MWDSP_FFTArgsCache *args); /* Real single in, real single out, trig fcn */
extern void dspifft_R2_CS_TBLM_RR(MWDSP_FFTArgsCache *args); /* Real single in, real single out, table (memory opt) */
extern void dspifft_R2_CS_TBLS_RR(MWDSP_FFTArgsCache *args); /* Real single in, real single out, table (speed opt) */
extern void dspifft_R2_CS_TBLM_2D_RR(MWDSP_FFTArgsCache *args); /* Real single in, real single out, table (memory opt) */
extern void dspifft_R2_CS_TBLS_2D_RR(MWDSP_FFTArgsCache *args); /* Real single in, real single out, table (speed opt) */

/* Bit-reversed order at input */
extern void dspifft_R2_BR_TRIG_CC(MWDSP_FFTArgsCache *args); /* Complex single in, complex single out, trig fcn */
extern void dspifft_R2_BR_TBLM_CC(MWDSP_FFTArgsCache *args); /* Complex single in, complex single out, table (memory opt) */
extern void dspifft_R2_BR_TBLS_CC(MWDSP_FFTArgsCache *args); /* Complex single in, complex single out, table (speed opt) */
extern void dspifft_R2_BR_TBLM_2D_CC(MWDSP_FFTArgsCache *args); /* Complex single in, complex single out, table (memory opt) */
extern void dspifft_R2_BR_TBLS_2D_CC(MWDSP_FFTArgsCache *args); /* Complex single in, complex single out, table (speed opt) */

extern void dspifft_R2_BR_TRIG_RC(MWDSP_FFTArgsCache *args); /* Real single in, complex single out, trig fcn */
extern void dspifft_R2_BR_TBLM_RC(MWDSP_FFTArgsCache *args); /* Real single in, complex single out, table (memory opt) */
extern void dspifft_R2_BR_TBLS_RC(MWDSP_FFTArgsCache *args); /* Real single in, complex single out, table (speed opt) */
extern void dspifft_R2_BR_TBLM_2D_RC(MWDSP_FFTArgsCache *args); /* Real single in, complex single out, table (memory opt) */
extern void dspifft_R2_BR_TBLS_2D_RC(MWDSP_FFTArgsCache *args); /* Real single in, complex single out, table (speed opt) */

extern void dspifft_R2_BR_CS_TRIG_CR(MWDSP_FFTArgsCache *args); /* Complex single in, real single out, trig fcn */
extern void dspifft_R2_BR_CS_TBLM_CR(MWDSP_FFTArgsCache *args); /* Complex single in, real single out, table (memory opt) */
extern void dspifft_R2_BR_CS_TBLS_CR(MWDSP_FFTArgsCache *args); /* Complex single in, real single out, table (speed opt) */
extern void dspifft_R2_BR_CS_TBLM_2D_CR(MWDSP_FFTArgsCache *args); /* Complex single in, real single out, table (memory opt) */
extern void dspifft_R2_BR_CS_TBLS_2D_CR(MWDSP_FFTArgsCache *args); /* Complex single in, real single out, table (speed opt) */

extern void dspifft_R2_BR_CS_TRIG_RR(MWDSP_FFTArgsCache *args); /* Real single in, real single out, trig fcn */
extern void dspifft_R2_BR_CS_TBLM_RR(MWDSP_FFTArgsCache *args); /* Real single in, real single out, table (memory opt) */
extern void dspifft_R2_BR_CS_TBLS_RR(MWDSP_FFTArgsCache *args); /* Real single in, real single out, table (speed opt) */
extern void dspifft_R2_BR_CS_TBLM_2D_RR(MWDSP_FFTArgsCache *args); /* Real single in, real single out, table (memory opt) */
extern void dspifft_R2_BR_CS_TBLS_2D_RR(MWDSP_FFTArgsCache *args); /* Real single in, real single out, table (speed opt) */

#ifdef __cplusplus
} // close brace for extern C from above
#endif

#endif /* dsp_ifft_sim_h */

/* [EOF] dsp_ifft_sim.h */
