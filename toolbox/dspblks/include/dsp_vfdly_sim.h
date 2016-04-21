/* Simulation support header file for variable fractional delay block
 * 
 *  Copyright 1995-2002 The MathWorks, Inc.
 *  $Revision: 1.2 $  $Date: 2002/04/14 20:36:38 $
 */
#ifndef dsp_vfdly_sim_h
#define dsp_vfdly_sim_h

#include "dsp_sim.h"
#include "dspvfdly2_rt.h"
#include "dsp_ic_sim.h"
#include "dsp_dlyerr_sim.h"


typedef enum {
    LINEAR_MODE,
    FIR_MODE
} MWDSP_VfdlyMode;

/* VfdlyArgsCache is a structure used to contain parameters/arguments
 * for each of the individual runtime functions listed below (for Variable Fractional Delay).
 *
 * Note that not all members of this structure have to be defined
 * for every runtime function.  Please refer to the description in the
 * comments before each function prototype for more specific details.
 */

typedef struct {

    void       *y;   /* Output data pointer */
    const void *u;   /* Input data pointer  */
    const void *dptr;/* Delay points pointer */
    int_T       maxDelay;     /* Maximum value of Delay permitted, parameter given by user */
    int_T       nChans;   /* xxx comments needed */
    int_T       nSamps;
    int_T       buflen;       
    int_T       delayLen;    

    /* Need elements corresponding to DWorks in here too */
    void  *buff;      /* element in ArgsCache corresponding to DISC_STATE DWork  */
    int_T *buffoff;  /* element in ArgsCache corresponding to BUFF_OFFSET DWork */

    real_T *filt;      /* Index to filter coeff          */
    int_T   filtlen;   /* For FIR interp mode            */
    int_T   nphases;   /* # phases in FIR interp filter  */
} VfdlyArgsCache;

/* function pointer definition */
typedef void (*VfdlyFcn)(VfdlyArgsCache *args);

/* S-fcn cache definition */
typedef struct {
    CopyICsCache ic_cache;                 /* Cache for function ICs routines */
    boolean_T    incrementDelayPerSample;  /* Increment delays per sample of the input *//* xxx don't need them here */
    boolean_T    incrementDelayPerChannel; /* Increment delays per column of the input *//* xxx don't need them here */
    VfdlyArgsCache Args;                   /* ArgsCache used by run-time functions */
    VfdlyFcn    VfdlyFcnPtr;               /* Pointer to function */
} SFcnCache;

/* The following functions are for simulation-only. 
 * The block uses Linear and Interpolation modes, based on that the functions below 
 * have either "lin" or 'FIR' in the name. Note that in the FIR interpolation mode, the interpolation
 * falls back to Linear mode, in case there are not sufficient samples. 
 * Based on the dimensions of the input data and the delay points, we either increment delay 
 * pointer every sample or increment delay every channel or never increment delay pointer. Hence the words 
 * "Samp", "Chan" and 'None" in the function names. Based on the data-types, we have:-
 * D = double-precision real data-type.
 * R = single-precision real data-type
 * Z = double-precision complex data-type.
 * C = single-precision complex data-type. 
 */
extern void Vfdly_FIR_None_D(VfdlyArgsCache *args);
extern void Vfdly_FIR_Samp_D(VfdlyArgsCache *args);
extern void Vfdly_FIR_Chan_D(VfdlyArgsCache *args);
extern void Vfdly_FIR_None_R(VfdlyArgsCache *args);          
extern void Vfdly_FIR_Samp_R(VfdlyArgsCache *args);          
extern void Vfdly_FIR_Chan_R(VfdlyArgsCache *args);          
extern void Vfdly_Lin_None_D(VfdlyArgsCache *args);
extern void Vfdly_Lin_Samp_D(VfdlyArgsCache *args);
extern void Vfdly_Lin_Chan_D(VfdlyArgsCache *args);
extern void Vfdly_Lin_None_R(VfdlyArgsCache *args);          
extern void Vfdly_Lin_Samp_R(VfdlyArgsCache *args);         
extern void Vfdly_Lin_Chan_R(VfdlyArgsCache *args);         

extern void Vfdly_FIR_None_Z(VfdlyArgsCache *args);
extern void Vfdly_FIR_Samp_Z(VfdlyArgsCache *args);
extern void Vfdly_FIR_Chan_Z(VfdlyArgsCache *args);
extern void Vfdly_FIR_None_C(VfdlyArgsCache *args);          
extern void Vfdly_FIR_Samp_C(VfdlyArgsCache *args);          
extern void Vfdly_FIR_Chan_C(VfdlyArgsCache *args);          
extern void Vfdly_Lin_None_Z(VfdlyArgsCache *args);
extern void Vfdly_Lin_Samp_Z(VfdlyArgsCache *args);
extern void Vfdly_Lin_Chan_Z(VfdlyArgsCache *args);
extern void Vfdly_Lin_None_C(VfdlyArgsCache *args);          
extern void Vfdly_Lin_Samp_C(VfdlyArgsCache *args);          
extern void Vfdly_Lin_Chan_C(VfdlyArgsCache *args);         

#endif
