/* Simulation support header file for LPC to cepstrum coefficients block
 * 
 *  Copyright 1995-2002 The MathWorks, Inc.
 *  $Revision: 1.2 $  $Date: 2002/11/21 16:29:53 $
 */
#ifndef dsp_lpc2cc_sim_h                                  
#define dsp_lpc2cc_sim_h

#include "dsp_sim.h"
#include "dsplpc2cc_rt.h"

/*
 * Argument and function pointer caches:
 */
typedef struct {
    const void *u;              /* Input data pointer  */
    void       *y;              /* Output data pointer */
    const void *energy;         /* Pointer to LPC prediction error power */
    void       *outenergy;      /* Pointer to output LPC prediction error power*/
    void       *storeNormLPC;   /* pointer to DWork which will hold the normalized 
                                 *  input LPC when normalization is needed
                                 */
    int_T  Nlpc;                /* Order of LPC polynomial. (Length - 1) */
    int_T  Ncep;                /* Length of Cepstrum coefficient polynomial. */
    boolean_T   doNormalize;    /* Flag to determine if we need normalization for the LPC coeffs. or not.*/
} Lpc2CcArgsCache; 

/* Function pointer definition which points to appropriate function to be called in mdlOutputs */
typedef void      (*Lpc2CcFcn)(Lpc2CcArgsCache *args);  
/* Function pointer definition for the error function, which points to appropriate function to be called 
 * to handle non-unity first LP coefficient
 */
typedef void      (*Lpc2CcErrFcn)(SimStruct *S, const void *A, void *normLPC, int_T order, boolean_T *doNormalize);

typedef struct {
    Lpc2CcArgsCache Args;
    Lpc2CcFcn       Lpc2CcFcnPtr;    /* Pointer to function */
    Lpc2CcErrFcn    Lpc2CcErrFcnPtr; /* Pointer to function which handles non-unity first LPC coeff. */
} SFcnCache;

/* List of run-time functions for LPC and Cepstral coefficients (CC) inter-conversion. */
/* 
 * Lpc2Cc indicates that the function is used for conversion from LPC to CC
 * Cc2Lpc indicates that the function is used for conversion from CC to LPC
 * 'WEnergy' in the function name indiates that the function is used for the case when
 *  Prediction error power is non-unity, absence of this term indiates prediction error
 *  power is unity. 
 * 'R' -> real single precision;  'D' -> real double precision datatype supported
*/
extern void Lpc2Cc_D(Lpc2CcArgsCache *args);
extern void Lpc2Cc_R(Lpc2CcArgsCache *args);
extern void Cc2Lpc_D(Lpc2CcArgsCache *args);
extern void Cc2Lpc_R(Lpc2CcArgsCache *args);
extern void Lpc2Cc_WEnergy_D(Lpc2CcArgsCache *args);
extern void Lpc2Cc_WEnergy_R(Lpc2CcArgsCache *args);
extern void Cc2Lpc_WEnergy_D(Lpc2CcArgsCache *args);
extern void Cc2Lpc_WEnergy_R(Lpc2CcArgsCache *args);

#endif  /* dsp_lpc2cc_sim.h */

/* [EOF] dsp_lpc2cc_sim.h */

