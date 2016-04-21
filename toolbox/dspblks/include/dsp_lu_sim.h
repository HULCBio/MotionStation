/* 
 *  dsp_lu_sim.h   Simulation mid-level functions and structure declarations
 *                      for DSP Blockset LU Factorization block. 
 * 
 * 
 *  Copyright 1995-2002 The MathWorks, Inc.
 *  $Revision: 1.3 $  $Date: 2002/04/14 20:38:52 $ 
 */ 
#ifndef dsp_lu_sim_h 
#define dsp_lu_sim_h 

#include "dsp_sim.h" 

/* DSPSIM_luArgsCache is a structure used to contain parameters/arguments 
 * for each of the individual mid-level functions listed below . 
 * 
 * Note that not all members of this structure have to be defined 
 * for every mid-level function.  Please refer to the description in the 
 * comments before each function prototype for more specific details. 
 */ 
typedef struct { 
    void  *u;
    int_T  widthIP;
    void  *p;
    boolean_T *s;
} DSPSIM_luArgsCache; 

typedef void (*luFcn) (DSPSIM_luArgsCache *args);

typedef struct {
    DSPSIM_luArgsCache  args;
    luFcn              luFcnPtr;
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
 
 * DSPSIM_lu_<DataType> 
 * 
 *    1) DSPSIM is a prefix used with DSP simulation helper functions. 
 *    2) The second field indicates that this function is implementing the 
 *       LU Factorization algorithm. 
 *    3) The third field enumerates the data type from the above list. 
 *       Single/double precision and complexity are specified within a single letter. 
 *       The input data type is indicated. 
 * 
 *    Examples: 
 *       DSPSIM_lu_D is the LU Factorization helper function for  
 *       double precision Real inputs. 
 */ 

extern void DSPSIM_lu_D(DSPSIM_luArgsCache *args);
extern void DSPSIM_lu_R(DSPSIM_luArgsCache *args); 
extern void DSPSIM_lu_Z(DSPSIM_luArgsCache *args); 
extern void DSPSIM_lu_C(DSPSIM_luArgsCache *args); 


extern void DSPSIM_lu_No_Op(DSPSIM_luArgsCache *args);

#endif /*  dsp_lu_sim_h */ 

/* [EOF] dsp_lu_sim.h */ 
