/* Simulation support header file for LSP/LSF to Polynomial(LPC) conversion block
 * 
 *  Copyright 1995-2002 The MathWorks, Inc.
 *  $Revision: 1.2 $  $Date: 2002/04/14 20:36:54 $
 */
#ifndef dsp_lsp2poly_sim_h
#define dsp_lsp2poly_sim_h

#include "dsp_sim.h"
#include "dsplsp2poly_rt.h"

/*
 * Argument and function pointer caches:
 */

typedef struct {
    const void *u;        /* Input data pointer  */
    void       *y;        /* Output data pointer */
    void       *G1;       /* pointer to D_work G1 */
    void       *G2;       /* pointer to D_Work G2 */
    int_T        P;       /* Order of LPC polynomial */
} Lsp2PolyArgsCache;  


typedef void (*Lsp2PolyFcn)(Lsp2PolyArgsCache *args);

typedef struct {
    Lsp2PolyArgsCache Args;
    Lsp2PolyFcn     Lsp2PolyFcnPtr;    /* Pointer to function */
} SFcnCache;

/* List of run-time functions to calculate the LSP/LSF vector */
extern void Lsp2Poly_Evenord_D(Lsp2PolyArgsCache *args);
extern void Lsp2Poly_Evenord_R(Lsp2PolyArgsCache *args);
extern void Lsp2Poly_Oddord_D(Lsp2PolyArgsCache *args);
extern void Lsp2Poly_Oddord_R(Lsp2PolyArgsCache *args);

extern void Lsfr2Poly_Evenord_D(Lsp2PolyArgsCache *args);
extern void Lsfr2Poly_Evenord_R(Lsp2PolyArgsCache *args);
extern void Lsfr2Poly_Oddord_D(Lsp2PolyArgsCache *args);
extern void Lsfr2Poly_Oddord_R(Lsp2PolyArgsCache *args);

extern void Lsfn2Poly_Evenord_D(Lsp2PolyArgsCache *args);
extern void Lsfn2Poly_Evenord_R(Lsp2PolyArgsCache *args);
extern void Lsfn2Poly_Oddord_D(Lsp2PolyArgsCache *args);
extern void Lsfn2Poly_Oddord_R(Lsp2PolyArgsCache *args);

#endif /* dsp_lsp2poly_sim.h */

/* [EOF] dsp_lsp2poly_sim.h  */


