/*
 *  dsppoly2lsp_rt.h
 *
 *  Copyright 1995-2004 The MathWorks, Inc.
 *  $Revision: 1.2.4.3 $ $Date: 2004/04/12 23:12:03 $
 */

#ifndef dsplsp2poly_rt_h
#define dsplsp2poly_rt_h

#include "dsp_rt.h"

#ifdef DSPLSP2POLY_EXPORTS
#define DSPLSP2POLY_EXPORT EXPORT_FCN
#else
#define DSPLSP2POLY_EXPORT extern
#endif

/* 
 *  List of individual "LSP/LSF to Poly block" run-time functions:-
 *
 *  As these are run-time functions for the "LSP/LSF to Polynomial (LPC) conversion" block, 
 *  all the run-time functions have the term "MWDSP_Lsp2Poly" in the beginning. 
 *  There are 4 different run-time functions:- 
 *  If the order of input is Even, we have the "Evenord " term in the run-time function and if 
 *  the order is Odd, we have "Oddord" term. 
 *  If the input is double-precision real data-type, we have the term "D" and for single-precision
 *  real data-type we have the term "R" in the run-time function name. 
 */
DSPLSP2POLY_EXPORT void MWDSP_Lsp2Poly_Evenord_D(const real_T *lsp, const int_T P, real_T *g1, real_T *g2, real_T *Az);
DSPLSP2POLY_EXPORT void MWDSP_Lsp2Poly_Evenord_R(const real32_T *lsp, const int_T P, real32_T *g1, real32_T *g2, real32_T *Az);
DSPLSP2POLY_EXPORT void MWDSP_Lsp2Poly_Oddord_D(const real_T *lsp, const int_T P, real_T *g1, real_T *g2, real_T *Az);
DSPLSP2POLY_EXPORT void MWDSP_Lsp2Poly_Oddord_R(const real32_T *lsp, const int_T P, real32_T *g1, real32_T *g2, real32_T *Az);

#endif /* dsppoly2lsp_rt_h */

/* [EOF] dsppoly2lsp_rt.h */
