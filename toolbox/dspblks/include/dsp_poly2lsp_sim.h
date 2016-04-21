/* Simulation support header file for Polynomial to LSP/LSF block
 * 
 *  Copyright 1995-2002 The MathWorks, Inc.
 *  $Revision: 1.3 $  $Date: 2002/08/26 19:47:27 $
 */
#ifndef dsp_poly2lsp_sim_h                                  
#define dsp_poly2lsp_sim_h

#include "dsp_sim.h"
#include "dsppoly2lsp_rt.h"

/*
 * Argument and function pointer caches:
 */

typedef struct {
    const void *u;        /* Input data pointer  */
    void       *y;        /* Output data pointer */
    boolean_T  *status;   /* Pointer to the output status port, is either 1 or 0, if the 
                           * search for LSP was successful it returns 1, on failure (unstable) case 
                           * it returns 0 */
    void       *b;        /* one of the D-works, used within cheby_poly_solve */
    void       *G1;       /* pointer to D_work G1 */
    void       *G2;       /* pointer to D_Work G2 */
    void       *lastLSP;  /* pointer to D-Work which holds Previous LSP values */
    void       *storeNormLPC; /* pointer to DWork which will hold the normalized 
                                input LPC when needed*/
    int_T       P;        /* Order of LPC polynomial */
    int_T       NSteps;   /* Number of root search steps */
    int_T       NBisects; /* Number of bisections for root refinement */
    int_T       M1;       /* Order of the de-convolved symmetric polynomial G1*/
    int_T       M2;       /* Order of the de-convolved symmetric polynomial G2*/
    boolean_T   doNormalize; /* Flag to determine if we need */
} Poly2LspArgsCache; 

typedef void      (*Poly2LspFcn)(Poly2LspArgsCache *args);
typedef void      (*ComputeGFcn)(Poly2LspArgsCache *args);
typedef void      (*LPCpolycheckFcn)(SimStruct *S, const void *A, void *normLPC, int_T order, boolean_T *doNormalize);

typedef struct {
    Poly2LspArgsCache Args;
    Poly2LspFcn     Poly2LspFcnPtr;    /* Pointer to function */
    ComputeGFcn     ComputeGFcnPtr;    /* Pointer to function which calculates chebychev polynomial G1 and G2 */
    LPCpolycheckFcn LPCpolycheckFcnPtr;/* Pointer to function which checks the input LPC polynomial, first value should be 1 */
} SFcnCache;

/* List of run-time functions to calculate the LSP/LSF vector */
extern void Poly2Lsp_corr_D(Poly2LspArgsCache *args);
extern void Poly2Lsp_noc_D(Poly2LspArgsCache *args);
extern void Poly2Lsp_corr_R(Poly2LspArgsCache *args);
extern void Poly2Lsp_noc_R(Poly2LspArgsCache *args);
extern void Poly2Lsfr_corr_D(Poly2LspArgsCache *args);
extern void Poly2Lsfr_noc_D(Poly2LspArgsCache *args);
extern void Poly2Lsfr_corr_R(Poly2LspArgsCache *args);
extern void Poly2Lsfr_noc_R(Poly2LspArgsCache *args);
extern void Poly2Lsfn_corr_D(Poly2LspArgsCache *args);
extern void Poly2Lsfn_noc_D(Poly2LspArgsCache *args);
extern void Poly2Lsfn_corr_R(Poly2LspArgsCache *args);
extern void Poly2Lsfn_noc_R(Poly2LspArgsCache *args);

/* These are run-time functions used by the above run-time functions to calculate the de-convolved
 * G1 and G2 polynomial 
 */
extern void  Poly2Lsp_GpolyEvenOrd_D(Poly2LspArgsCache *args);
extern void  Poly2Lsp_GpolyEvenOrd_R(Poly2LspArgsCache *args);
extern void  Poly2Lsp_GpolyOddOrd_D(Poly2LspArgsCache *args);
extern void  Poly2Lsp_GpolyOddOrd_R(Poly2LspArgsCache *args);

#endif
