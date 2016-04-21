/* 
 *  dsp_ldl_sim.h   Simulation mid-level prototype function & structure declarations
 *                  for DSP Blockset LDL Factorization block. 
 * 
 *  Copyright 1995-2002 The MathWorks, Inc.
 *  $Revision: 1.2 $  $Date: 2002/04/14 20:38:47 $ 
 */ 
#ifndef dsp_ldl_sim_h 
#define dsp_ldl_sim_h 

#include "dsp_sim.h" 

/* DSPSIM_LDLArgsCache is a structure used to contain parameters/arguments 
 * for each of the individual mid-level functions listed below . 
 * 
 * Note that not all members of this structure have to be defined 
 * for every mid-level function.  Please refer to the description in the 
 * comments before each function prototype for more specific details. 
 */ 
typedef struct { 
    const void  *u;            /* Input square matrix */ 
          void  *y;            /* Output matrix composed on L and D elements */
          void  *v;            /* Intermediate variable */
          int_T N;             /* Number of matrix rows or columns */
          boolean_T *state;    /* Positive definiteness of input matrix */
          boolean_T need_copy; /* Need to copy from input to output */
} DSPSIM_LDLArgsCache; 

typedef enum {                  /* In case of non-positive definite matrix */
    ERR_IGNORE=1,               /* Ignore */
    ERR_WARNING,                /* Throw only warning */
    ERR_ERROR                   /* Throw warning and error out Simulation */
} ErrMode;

typedef void (*ldlFcn) (DSPSIM_LDLArgsCache *args);

typedef struct {
    DSPSIM_LDLArgsCache args;       /* ArgsCache structure */
    ErrMode             err;        /* Error handling modes */
    ldlFcn              ldlFcnPtr;  /* Function pointer */
} SFcnCache;

/* 
 * Mid-level function naming glossary 
 * --------------------------- 
 * 
 * Data types - (describe inputs to functions, not outputs) 
 * R = real single-precision 
 * C = complex single-precision 
 * D = real double-precision 
 * Z = complex double-precision 
 */ 
 
/* Function naming convention 
 * -------------------------- 
 * 
 
 * DSPSIM_ldl_<DataType> 
 * 
 *    1) DSPSIM is a prefix used with DSP simulation helper functions. 
 *    2) The second field indicates that this function is implementing the 
 *       LDL Factorization algorithm. 
 *    3) The third field enumerates the data type from the above list. 
 *       Single/double precision and complexity are specified within a single letter. 
 *       The input data type is indicated. 
 * 
 *    Examples: 
 *       DSPSIM_ldl_D is the LDL Factorization helper function for  
 *       double precision Real inputs. 
 */ 

extern void DSPSIM_LDL_D(DSPSIM_LDLArgsCache *args);
extern void DSPSIM_LDL_R(DSPSIM_LDLArgsCache *args);
extern void DSPSIM_LDL_Z(DSPSIM_LDLArgsCache *args);
extern void DSPSIM_LDL_C(DSPSIM_LDLArgsCache *args);
extern void DSPSIM_LDL_No_Op(DSPSIM_LDLArgsCache *args);

void DSPSIM_DisplayLDLError(
    SimStruct             *S,
    DSPSIM_LDLArgsCache *args,
    ErrMode     errMode
    );

#endif /*  dsp_ldl_sim_h */ 

/* [EOF] dsp_ldl_sim.h */ 

