/*
 *  dspg711_rt.h
 *  G711 run-time library function prototypes
 *
 *  Copyright 2003-2004 The MathWorks, Inc.
 *  $Revision: 1.1.6.4 $ $Date: 2004/04/12 23:11:53 $
 */

#ifndef dspg711_rt_h
#define dspg711_rt_h

#include "dsp_rt.h"

#ifdef DSPG711_EXPORTS
#define DSPG711_EXPORT EXPORT_FCN
#else
#define DSPG711_EXPORT extern
#endif

/* 
 * List of individual G711 functions:
 */

/* A-law encoding, Saturate on input overflow */
DSPG711_EXPORT void MWDSP_G711EncASat(const int16_T *u, uint8_T *y, int nElems);

/* A-law encoding, Wrap on input overflow */
DSPG711_EXPORT void MWDSP_G711EncAWrap(const int16_T *u, uint8_T *y, int nElems);   

/* mu-law encoding, Saturate on input overflow */
DSPG711_EXPORT void MWDSP_G711EncMuSat(const int16_T *u, uint8_T *y, int nElems);

/* mu-law encoding, Wrap on input overflow */
DSPG711_EXPORT void MWDSP_G711EncMuWrap(const int16_T *u, uint8_T *y, int nElems);   

#endif /* dspg711_rt_h */

/* [EOF] dspg711_rt.h */
