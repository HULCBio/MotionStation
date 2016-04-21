/* 
 *  dsp_offset_sim.h   Simulation mid-level functions and structure declarations
 *                      for DSP Blockset Offset block. 
 * 
 * 
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.1.6.1 $  $Date: 2003/12/06 15:29:35 $ 
 */ 
#ifndef dsp_offset_sim_h 
#define dsp_offset_sim_h 

#include "dsp_sim.h" 

/* DSPSIM_offsetArgsCache is a structure used to contain parameters/arguments 
 * for each of the individual simulation functions listed below . 
 * 
 * Note that not all members of this structure have to be defined 
 * for every simulation function.  Please refer to the description in the 
 * comments before each function prototype for more specific details. 
 */ 

typedef struct { 
    boolean_T ModeTopOrBottom;
    int_T NumDataOffsetPairs;
    int_T ActionWarnErr;    
    int_T InDataPortWidth; 
    int_T BytesPerRealInputEle;
    int_T BytesPerRealInputFr; 
    int_T BytesPerRealOutputFr;     
} DSPSIM_offsetArgsCache; 

typedef void (*offsetFcn) (SimStruct *S, DSPSIM_offsetArgsCache *args);

typedef struct {
    DSPSIM_offsetArgsCache  args;
    offsetFcn        offsetFcnPtr;
} SFcnCache;


/* 
 * Simulation function naming glossary 
 * --------------------------- 
 * 
 * Offset input data types (non-complex) 
 * R   = single
 * D   = double
 * I8  = int8
 * U8  = uint8
 * I16 = int16
 * U16 = uint16
 * I32 = int32
 * U32 = uint32
 */ 
 
/* Function naming convention 
 * -------------------------- 
 * 
 *
 * DSPSIM_offset_<remv/keep>_<OffsetDataType> 
 * 
 *    1) DSPSIM is a prefix used with DSP simulation helper functions. 
 *    2) The second field indicates that this function is implementing the 
 *       Offset algorithm. 
 *    3) The third field indicates the mode of operation (remove or keep)
 *       from Top/End
 *    4) The third field enumerates the offset data type from the above list.
 * 
 *    Examples: 
 *       DSPSIM_offset_remv_D is the Offset simulation function for  
 *       double precision offset input with the mode 'remove from top/end'. 
 */ 

extern void DSPSIM_offset_remv_D  (SimStruct *S, DSPSIM_offsetArgsCache *args);
extern void DSPSIM_offset_keep_D  (SimStruct *S, DSPSIM_offsetArgsCache *args);
extern void DSPSIM_offset_remv_R  (SimStruct *S, DSPSIM_offsetArgsCache *args); 
extern void DSPSIM_offset_keep_R  (SimStruct *S, DSPSIM_offsetArgsCache *args); 
extern void DSPSIM_offset_remv_I8 (SimStruct *S, DSPSIM_offsetArgsCache *args);
extern void DSPSIM_offset_keep_I8 (SimStruct *S, DSPSIM_offsetArgsCache *args);
extern void DSPSIM_offset_remv_U8 (SimStruct *S, DSPSIM_offsetArgsCache *args); 
extern void DSPSIM_offset_keep_U8 (SimStruct *S, DSPSIM_offsetArgsCache *args); 
extern void DSPSIM_offset_remv_I16(SimStruct *S, DSPSIM_offsetArgsCache *args);
extern void DSPSIM_offset_keep_I16(SimStruct *S, DSPSIM_offsetArgsCache *args);
extern void DSPSIM_offset_remv_U16(SimStruct *S, DSPSIM_offsetArgsCache *args);
extern void DSPSIM_offset_keep_U16(SimStruct *S, DSPSIM_offsetArgsCache *args);
extern void DSPSIM_offset_remv_I32(SimStruct *S, DSPSIM_offsetArgsCache *args);
extern void DSPSIM_offset_keep_I32(SimStruct *S, DSPSIM_offsetArgsCache *args);
extern void DSPSIM_offset_remv_U32(SimStruct *S, DSPSIM_offsetArgsCache *args);
extern void DSPSIM_offset_keep_U32(SimStruct *S, DSPSIM_offsetArgsCache *args);

extern void DSPSIM_offset_No_Op(SimStruct *S, DSPSIM_offsetArgsCache *args);

#endif /*  dsp_offset_sim_h */ 

/* [EOF] dsp_offset_sim.h */ 
