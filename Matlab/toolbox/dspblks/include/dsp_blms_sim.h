/* 
 *  dsp_blms_sim.h       Simulation mid-level functions and structure declarations
 *                       for DSP Blockset BLOCK LMS ADAPTIVE FILTER block. 
 * 
 * 
 *  Copyright 1995-2004 The MathWorks, Inc.
 *  $Revision: 1.1.6.3 $  $Date: 2004/04/12 23:11:11 $ 
 */ 
#ifndef dsp_blms_sim_h 
#define dsp_blms_sim_h 

#include "dsp_sim.h" 

#ifdef __cplusplus
extern "C" {
#endif

#include "dspblms_rt.h"

/* DSPSIM_blmsArgsCache is a structure used to contain parameters/arguments 
 * for each of the individual mid-level functions listed below . 
 * 
 * Note that not all members of this structure have to be defined 
 * for every mid-level function.  Please refer to the description in the 
 * comments before each function prototype for more specific details. 
 */ 

typedef struct { 
    boolean_T BlockHasResetPort;
    boolean_T BlockHasAdaptPort;

    const void      *inSigU;           /* Input signal pointer */ 
    const void      *deSigU;           /* Desired signal pointer */ 
    const void      *muU;              /* Input mu pointer*/ 

          void       *inBuff;          /* IN_BUFFER_DWORK pointer */ 
          void       *wgtBuff;         /* WGT_IC_DWORK pointer */ 
    
          int_T       FilterLength;
          int_T       BlockLength;
          void       *pLkgFactor;      /* Leakage factor pointer*/ 
          int_T       FrmLen;
          int_T       bytesPerInpElmt; /* Not used in run-time functions */ 
          void       *outY;            /* Output signal pointer */ 
          void       *errY;            /* Output error signal pointer */ 
          void       *wgtY;            /* Output weight signal pointer */ 
          boolean_T   NeedAdapt;
          void       *wgtICRTP;            /* <-----Only used for resetWeightIC */ 
          boolean_T   IsWgtICinMaskVector; /* <-----Only used for resetWeightIC */
} DSPSIM_blmsArgsCache; 

typedef struct { 
   const void *adaptU; 
} DSPSIM_badaptArgsCache; 

typedef void      (*blmsFcn)      (DSPSIM_blmsArgsCache *args);
typedef boolean_T (*badaptFcn)    (DSPSIM_badaptArgsCache *aargs);


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
 * DSPSIM_blms_a[y/n]_w[y/n]_<Input_Signal_DataType><Desired_Signal_DataType> 
 * 
 *    1) DSPSIM is a prefix used with DSP simulation helper functions. 
 *    2) The second field indicates that this function is implementing the 
 *       BLOCK LMS Adaptive filter algorithm.
 *    3) The third field a[y/n] indicates whether there is adapt input port or not
 *       'ay' means there is adapt input port, 'an' means no adapt input port
 *    4) The fourth field w[y/n] indicates whether there is weight output port or not
 *       'wy' means there is weight output port, 'wn' means no weight output port
 *    5) The third field enumerates the data type from the above list. 
 *       Single/double precision and complexity are specified within a single letter. 
 *       The input data type is indicated. 
 * 
 *    Examples: 
 *       DSPSIM_blms_ay_wn_ZZ is the BLOCK LMS Adaptive filter run time function for  
 *       double precision complex input signal, double precision complex desired signal 
 *       with adapt input port and no weight output port
 */      
 
/* Block LMS  */ 
extern void DSPSIM_blms_an_wn_DD (DSPSIM_blmsArgsCache *args);
extern void DSPSIM_blms_an_wn_ZZ (DSPSIM_blmsArgsCache *args);
extern void DSPSIM_blms_an_wn_RR (DSPSIM_blmsArgsCache *args);
extern void DSPSIM_blms_an_wn_CC (DSPSIM_blmsArgsCache *args);
extern void DSPSIM_blms_an_wy_DD (DSPSIM_blmsArgsCache *args);
extern void DSPSIM_blms_an_wy_ZZ (DSPSIM_blmsArgsCache *args);
extern void DSPSIM_blms_an_wy_RR (DSPSIM_blmsArgsCache *args);
extern void DSPSIM_blms_an_wy_CC (DSPSIM_blmsArgsCache *args);
extern void DSPSIM_blms_ay_wn_DD (DSPSIM_blmsArgsCache *args);
extern void DSPSIM_blms_ay_wn_ZZ (DSPSIM_blmsArgsCache *args);
extern void DSPSIM_blms_ay_wn_RR (DSPSIM_blmsArgsCache *args);
extern void DSPSIM_blms_ay_wn_CC (DSPSIM_blmsArgsCache *args);
extern void DSPSIM_blms_ay_wy_DD (DSPSIM_blmsArgsCache *args);
extern void DSPSIM_blms_ay_wy_ZZ (DSPSIM_blmsArgsCache *args);
extern void DSPSIM_blms_ay_wy_RR (DSPSIM_blmsArgsCache *args);
extern void DSPSIM_blms_ay_wy_CC (DSPSIM_blmsArgsCache *args);
/****************************************************************/ 
/***********************ADAPT PORT FUNCTIONS ********************/ 

extern boolean_T DSPSIM_badapt_DBL (DSPSIM_badaptArgsCache *aargs);
extern boolean_T DSPSIM_badapt_SGL (DSPSIM_badaptArgsCache *aargs);
extern boolean_T DSPSIM_badapt_I8  (DSPSIM_badaptArgsCache *aargs);
extern boolean_T DSPSIM_badapt_U8  (DSPSIM_badaptArgsCache *aargs);
extern boolean_T DSPSIM_badapt_I16 (DSPSIM_badaptArgsCache *aargs);
extern boolean_T DSPSIM_badapt_U16 (DSPSIM_badaptArgsCache *aargs);
extern boolean_T DSPSIM_badapt_I32 (DSPSIM_badaptArgsCache *aargs);
extern boolean_T DSPSIM_badapt_U32 (DSPSIM_badaptArgsCache *aargs);
extern boolean_T DSPSIM_badapt_BOOL(DSPSIM_badaptArgsCache *aargs);


#ifdef __cplusplus
}
#endif

#endif  

/* [EOF] dsp_blms_sim.h */ 

