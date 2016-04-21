/* 
 *  dsp_lms_sim.h       Simulation mid-level functions and structure declarations
 *                      for DSP Blockset LMS ADAPTIVE FILTER block. 
 * 
 * 
 *  Copyright 1995-2004 The MathWorks, Inc.
 *  $Revision: 1.1.6.4 $  $Date: 2004/04/12 23:11:27 $ 
 */ 
#ifndef dsp_lms_sim_h 
#define dsp_lms_sim_h 

#include "dsp_sim.h" 

#ifdef __cplusplus
extern "C" {
#endif

#include "dsplms_rt.h"

/* DSPSIM_lmsArgsCache is a structure used to contain parameters/arguments 
 * for each of the individual mid-level functions listed below . 
 * 
 * Note that not all members of this structure have to be defined 
 * for every mid-level function.  Please refer to the description in the 
 * comments before each function prototype for more specific details. 
 */ 

typedef struct { 
    const void     *inSigU;          /* Input signal pointer */ 
    const void     *deSigU;          /* Desired signal pointer */ 
    const void     *muU;          /* Input mu pointer*/ 

          uint32_T   *buffStartIdx;    /* INBUFF_START_IDX_DWORK pointer */
          void       *inBuff;          /* IN_BUFFER_DWORK pointer */ 
          void       *wgtBuff;         /* WGT_IC_DWORK pointer */ 
    
          int_T       FilterLength;
          void       *pLkgFactor;   /* Leakage factor pointer*/ 
          int_T       FrmLen;
          int_T       bytesPerInpElmt;
          void       *outY;            /* Output signal pointer */ 
          void       *errY;            /* Output error signal pointer */ 
          void       *wgtY;            /* Output weight signal pointer */ 
          boolean_T   NeedAdapt;
          void       *enrgInBuff;          /* Energy of the signal in the input signal buffer (for normalized lms) */      
          void       *wgtICRTP;            /* <-----Only used for resetWeightIC */ 
          boolean_T   IsWgtICinMaskVector; /* <-----Only used for resetWeightIC */
          boolean_T   blkHasResetPort;
          boolean_T   blkHasAdaptPort;          
} DSPSIM_lmsArgsCache; 

typedef struct { 
   const void *adaptU; 
} DSPSIM_adaptArgsCache; 

typedef void      (*lmsFcn)      (DSPSIM_lmsArgsCache *args);
typedef boolean_T (*adaptFcn)    (DSPSIM_adaptArgsCache *aargs);


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
 * DSPSIM_[lms/lmsn/lmsse/lmssd/lmsss]_a[y/n]_w[y/n]_<Input_Signal_DataType><Desired_Signal_DataType> 
 * 
 *    1) DSPSIM is a prefix used with DSP simulation helper functions. 
 *    2) The second field indicates that this function is implementing the 
 *       LMS Adaptive filter algorithm.
 *       lms = LMS, lmsn = NORMALIZED LMS, lmsse = SIGN ERROR LMS
 *       lmssd = SIGN DATA LMS, lmsss = SIGN SIGN LMS 
 *    3) The third field a[y/n] indicates whether there is adapt input port or not
 *       'ay' means there is adapt input port, 'an' means no adapt input port
 *    4) The fourth field w[y/n] indicates whether there is weight output port or not
 *       'wy' means there is weight output port, 'wn' means no weight output port
 *    5) The third field enumerates the data type from the above list. 
 *       Single/double precision and complexity are specified within a single letter. 
 *       The input data type is indicated. 
 * 
 *    Examples: 
 *       DSPSIM_lmsn_ay_wn_ZZ is the Normalized LMS Adaptive filter run time function for  
 *       double precision complex input signal, double precision complex desired signal 
 *       with adapt input port and no weight output port
 */      
 
/* LMS ONLY */ 
extern void DSPSIM_lms_an_wn_DD (DSPSIM_lmsArgsCache *args);
extern void DSPSIM_lms_an_wn_ZZ (DSPSIM_lmsArgsCache *args);
extern void DSPSIM_lms_an_wn_RR (DSPSIM_lmsArgsCache *args);
extern void DSPSIM_lms_an_wn_CC (DSPSIM_lmsArgsCache *args);
extern void DSPSIM_lms_an_wy_DD (DSPSIM_lmsArgsCache *args);
extern void DSPSIM_lms_an_wy_ZZ (DSPSIM_lmsArgsCache *args);
extern void DSPSIM_lms_an_wy_RR (DSPSIM_lmsArgsCache *args);
extern void DSPSIM_lms_an_wy_CC (DSPSIM_lmsArgsCache *args);
extern void DSPSIM_lms_ay_wn_DD (DSPSIM_lmsArgsCache *args);
extern void DSPSIM_lms_ay_wn_ZZ (DSPSIM_lmsArgsCache *args);
extern void DSPSIM_lms_ay_wn_RR (DSPSIM_lmsArgsCache *args);
extern void DSPSIM_lms_ay_wn_CC (DSPSIM_lmsArgsCache *args);
extern void DSPSIM_lms_ay_wy_DD (DSPSIM_lmsArgsCache *args);
extern void DSPSIM_lms_ay_wy_ZZ (DSPSIM_lmsArgsCache *args);
extern void DSPSIM_lms_ay_wy_RR (DSPSIM_lmsArgsCache *args);
extern void DSPSIM_lms_ay_wy_CC (DSPSIM_lmsArgsCache *args);
/* LMS_NORM */ 
extern void DSPSIM_lmsn_an_wn_DD (DSPSIM_lmsArgsCache *args);
extern void DSPSIM_lmsn_an_wn_ZZ (DSPSIM_lmsArgsCache *args);
extern void DSPSIM_lmsn_an_wn_RR (DSPSIM_lmsArgsCache *args);
extern void DSPSIM_lmsn_an_wn_CC (DSPSIM_lmsArgsCache *args);
extern void DSPSIM_lmsn_an_wy_DD (DSPSIM_lmsArgsCache *args);
extern void DSPSIM_lmsn_an_wy_ZZ (DSPSIM_lmsArgsCache *args);
extern void DSPSIM_lmsn_an_wy_RR (DSPSIM_lmsArgsCache *args);
extern void DSPSIM_lmsn_an_wy_CC (DSPSIM_lmsArgsCache *args);
extern void DSPSIM_lmsn_ay_wn_DD (DSPSIM_lmsArgsCache *args);
extern void DSPSIM_lmsn_ay_wn_ZZ (DSPSIM_lmsArgsCache *args);
extern void DSPSIM_lmsn_ay_wn_RR (DSPSIM_lmsArgsCache *args);
extern void DSPSIM_lmsn_ay_wn_CC (DSPSIM_lmsArgsCache *args);
extern void DSPSIM_lmsn_ay_wy_DD (DSPSIM_lmsArgsCache *args);
extern void DSPSIM_lmsn_ay_wy_ZZ (DSPSIM_lmsArgsCache *args);
extern void DSPSIM_lmsn_ay_wy_RR (DSPSIM_lmsArgsCache *args);
extern void DSPSIM_lmsn_ay_wy_CC (DSPSIM_lmsArgsCache *args);
/*  LMS_SIGN_DATA */ 
extern void DSPSIM_lmsse_an_wn_DD (DSPSIM_lmsArgsCache *args);
extern void DSPSIM_lmsse_an_wn_RR (DSPSIM_lmsArgsCache *args);
extern void DSPSIM_lmsse_an_wy_DD (DSPSIM_lmsArgsCache *args);
extern void DSPSIM_lmsse_an_wy_RR (DSPSIM_lmsArgsCache *args);
extern void DSPSIM_lmsse_ay_wn_DD (DSPSIM_lmsArgsCache *args);
extern void DSPSIM_lmsse_ay_wn_RR (DSPSIM_lmsArgsCache *args);
extern void DSPSIM_lmsse_ay_wy_DD (DSPSIM_lmsArgsCache *args);
extern void DSPSIM_lmsse_ay_wy_RR (DSPSIM_lmsArgsCache *args);
/* LMS_SIGN_DATA */ 
extern void DSPSIM_lmssd_an_wn_DD (DSPSIM_lmsArgsCache *args);
extern void DSPSIM_lmssd_an_wn_RR (DSPSIM_lmsArgsCache *args);
extern void DSPSIM_lmssd_an_wy_DD (DSPSIM_lmsArgsCache *args);
extern void DSPSIM_lmssd_an_wy_RR (DSPSIM_lmsArgsCache *args);
extern void DSPSIM_lmssd_ay_wn_DD (DSPSIM_lmsArgsCache *args);
extern void DSPSIM_lmssd_ay_wn_RR (DSPSIM_lmsArgsCache *args);
extern void DSPSIM_lmssd_ay_wy_DD (DSPSIM_lmsArgsCache *args);
extern void DSPSIM_lmssd_ay_wy_RR (DSPSIM_lmsArgsCache *args);
/* LMS_SIGNerror_SIGNdata */ 
extern void DSPSIM_lmsss_an_wn_DD (DSPSIM_lmsArgsCache *args);
extern void DSPSIM_lmsss_an_wn_RR (DSPSIM_lmsArgsCache *args);
extern void DSPSIM_lmsss_an_wy_DD (DSPSIM_lmsArgsCache *args);
extern void DSPSIM_lmsss_an_wy_RR (DSPSIM_lmsArgsCache *args);
extern void DSPSIM_lmsss_ay_wn_DD (DSPSIM_lmsArgsCache *args);
extern void DSPSIM_lmsss_ay_wn_RR (DSPSIM_lmsArgsCache *args);
extern void DSPSIM_lmsss_ay_wy_DD (DSPSIM_lmsArgsCache *args);
extern void DSPSIM_lmsss_ay_wy_RR (DSPSIM_lmsArgsCache *args);

/****************************************************************/ 
/***********************ADAPT PORT FUNCTIONS ********************/ 

extern boolean_T DSPSIM_adapt_DBL (DSPSIM_adaptArgsCache *aargs);
extern boolean_T DSPSIM_adapt_SGL (DSPSIM_adaptArgsCache *aargs);
extern boolean_T DSPSIM_adapt_I8  (DSPSIM_adaptArgsCache *aargs);
extern boolean_T DSPSIM_adapt_U8  (DSPSIM_adaptArgsCache *aargs);
extern boolean_T DSPSIM_adapt_I16 (DSPSIM_adaptArgsCache *aargs);
extern boolean_T DSPSIM_adapt_U16 (DSPSIM_adaptArgsCache *aargs);
extern boolean_T DSPSIM_adapt_I32 (DSPSIM_adaptArgsCache *aargs);
extern boolean_T DSPSIM_adapt_U32 (DSPSIM_adaptArgsCache *aargs);
extern boolean_T DSPSIM_adapt_BOOL(DSPSIM_adaptArgsCache *aargs);


#ifdef __cplusplus
}
#endif

#endif  

/* [EOF] dsp_lms_sim.h */ 
