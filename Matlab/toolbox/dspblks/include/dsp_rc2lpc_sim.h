/* Simulation support header file for LPC and RC inter-conversion block. 
 * 
 *  Copyright 1995-2002 The MathWorks, Inc.
 *  $Revision: 1.2 $  $Date: 2002/07/29 21:13:45 $
 */
#ifndef dsp_rc2lpc_sim_h                                  
#define dsp_rc2lpc_sim_h

#include "dsp_sim.h"
#include "dsprc2lpc_rt.h"

/*
 * Argument and function pointer caches:
 */

typedef struct {
    const void *u;        /* Input data pointer  */
    void       *y;        /* Output data pointer */
    void       *pred_err; /* Pointer to the Prediction error output port */
    void       *storeNormLPC; /* pointer to DWork which will hold the normalized 
                                input LPC when needed*/
    boolean_T  *isStable; /* Output port denoting the stability of the LPC/RC pair*/
    int_T       ord;      /* Order of LPC polynomial. */
    boolean_T   doNormalize; /* Flag to determine if we need */
} Rc2lpcArgsCache; 

typedef void      (*Rc2lpcFcn)(Rc2lpcArgsCache *args);
typedef void      (*Rc2lpcPolyChkFcn)(SimStruct *S, const void *A, void *normLPC, int_T order, boolean_T *doNormalize);

typedef struct {
    Rc2lpcArgsCache Args;
    Rc2lpcFcn         Rc2lpcFcnPtr;        /* Pointer to function */
    Rc2lpcPolyChkFcn  Rc2lpcPolyChkFcnPtr; /* Pointer to function which normalizes the input LPC poly.*/
} SFcnCache;

/* List of run-time functions for LPC and RC inter-conversion. 
 * D -> Function works on double precision datatype 
 * R -> Function works on single precision datatype 
 * Rc2Lpc -> Conversion of RC to LPC 
 * Lpc2Rc -> Conversion of LPC to RC
 * perr   -> calculate Prediction error also for the given LPC/RC pair
 * isStable -> indicate whether the LPC polynomial is stable or not.
 *
 * Thus a funciton like Lpc2Rc_perr_isStable_R would indicate that this function
 * is used to convert LPC to RC using single precision datatype and also
 * calculates the Prediction error and stability of the LPC/RC pair. 
 */
extern void Rc2Lpc_D(Rc2lpcArgsCache *args);
extern void Rc2Lpc_R(Rc2lpcArgsCache *args);
extern void Lpc2Rc_D(Rc2lpcArgsCache *args);
extern void Lpc2Rc_R(Rc2lpcArgsCache *args);
extern void Rc2Lpc_perr_D(Rc2lpcArgsCache *args);
extern void Rc2Lpc_perr_R(Rc2lpcArgsCache *args);
extern void Lpc2Rc_perr_D(Rc2lpcArgsCache *args);
extern void Lpc2Rc_perr_R(Rc2lpcArgsCache *args);

extern void Rc2Lpc_isStable_D(Rc2lpcArgsCache *args);
extern void Rc2Lpc_isStable_R(Rc2lpcArgsCache *args);
extern void Lpc2Rc_isStable_D(Rc2lpcArgsCache *args);
extern void Lpc2Rc_isStable_R(Rc2lpcArgsCache *args);
extern void Rc2Lpc_perr_isStable_D(Rc2lpcArgsCache *args);
extern void Rc2Lpc_perr_isStable_R(Rc2lpcArgsCache *args);
extern void Lpc2Rc_perr_isStable_D(Rc2lpcArgsCache *args);
extern void Lpc2Rc_perr_isStable_R(Rc2lpcArgsCache *args);

#endif


