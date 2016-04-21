/* Simulation support header file for LPC/RC to autocorrelation coeffs. block
 * 
 *  Copyright 1995-2002 The MathWorks, Inc.
 *  $Revision: 1.2 $  $Date: 2002/07/29 21:13:43 $
 */
#ifndef dsp_rc2ac_sim_h                                  
#define dsp_rc2ac_sim_h

#include "dsp_sim.h"
#include "dsprc2ac_rt.h"

/*
 * Argument and function pointer caches:
 */

typedef struct {
    const void *u;        /* Input data pointer  */
    const void *pred_err; /* Pointer to the Prediction error input port */
    void       *y;        /* Output data pointer */
    void       *LPCmtrx;  /* Matrix which holds all LP coefficients from order 1 to "ord"*/
    void       *storeNormLPC; /* pointer to DWork which will hold the normalized 
                                input LPC when needed*/
    int_T       ord;      /* Order of LPC polynomial. */
    boolean_T   doNormalize; /* Flag to determine if we need */
} Rc2AcArgsCache; 

typedef void      (*Rc2AcFcn)(Rc2AcArgsCache *args);
typedef void      (*Rc2AcErrFcn)(SimStruct *S, const void *A, void *normLPC, int_T order, boolean_T *doNormalize);

typedef struct {
    Rc2AcArgsCache Args;
    Rc2AcFcn       Rc2AcFcnPtr;    /* Pointer to function */
    Rc2AcErrFcn    Rc2AcErrFcnPtr; /* Pointer to function which handles non-unity first LPC coeff. */
} SFcnCache;

/* List of run-time functions for LPC and RC inter-conversion. */
extern void Rc2Ac_D(Rc2AcArgsCache *args);
extern void Rc2Ac_R(Rc2AcArgsCache *args);
extern void Lpc2Ac_D(Rc2AcArgsCache *args);
extern void Lpc2Ac_R(Rc2AcArgsCache *args);

#endif
