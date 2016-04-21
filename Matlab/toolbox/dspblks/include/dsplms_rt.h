/* 
 *  dsplms_rt.h   Runtime functions for DSP Blockset LMS Adaptive filter block. 
 * 
 * 
 *  Copyright 1995-2004 The MathWorks, Inc.
 *  $Revision: 1.1.6.3 $  $Date: 2004/04/12 23:12:01 $ 
 */      
#ifndef dsplms_rt_h 
#define dsplms_rt_h 

#include "dsp_rt.h" 

#ifdef DSPLMS_EXPORTS
#define DSPLMS_EXPORT EXPORT_FCN
#else
#define DSPLMS_EXPORT MWDSP_IDECL
#endif

/* 
 * Function naming glossary 
 * --------------------------- 
 * 
 * MWDSP = MathWorks DSP Blockset 
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
 * MWDSP_[lms/lmsn/lmsse/lmssd/lmsss]_a[y/n]_w[y/n]_<Input_Signal_DataType><Desired_Signal_DataType> 
 * 
 *    1) MWDSP_ is a prefix used with all Mathworks DSP runtime library 
 *       functions. 
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
 *       MWDSP_lmsn_ay_wn_ZZ is the Normalized LMS Adaptive filter run time function for  
 *       double precision complex input signal, double precision complex desired signal 
 *       with adapt input port and no weight output port
 */      
/* 000 */     
DSPLMS_EXPORT void MWDSP_lms_an_wn_DD(const real_T *inSigU, 
                                const real_T *deSigU, 
                                const real_T  muU,
                                uint32_T     *buffStartIdx, 
                                real_T       *inBuff, 
                                real_T       *wgtBuff,
                                const int_T   FilterLength, 
                                const real_T  LkgFactor, 
                                const int_T   FrmLen, 
                                const int_T   bytesPerInpElmt,
                                real_T       *outY,
                                real_T       *errY);
/* 001 */     
DSPLMS_EXPORT void MWDSP_lms_an_wn_ZZ(const creal_T *inSigU, 
                                const creal_T *deSigU, 
                                const real_T  muU,
                                uint32_T     *buffStartIdx, 
                                creal_T       *inBuff, 
                                creal_T       *wgtBuff,
                                const int_T   FilterLength, 
                                const real_T  LkgFactor, 
                                const int_T   FrmLen, 
                                const int_T   bytesPerInpElmt,
                                creal_T       *outY,
                                creal_T       *errY);
/* 002 */     
DSPLMS_EXPORT void MWDSP_lms_an_wn_RR(const real32_T *inSigU, 
                                const real32_T *deSigU, 
                                const real32_T  muU,
                                uint32_T     *buffStartIdx, 
                                real32_T       *inBuff, 
                                real32_T       *wgtBuff,
                                const int_T   FilterLength, 
                                const real32_T  LkgFactor, 
                                const int_T   FrmLen, 
                                const int_T   bytesPerInpElmt,
                                real32_T       *outY,
                                real32_T       *errY);
/* 003 */     
DSPLMS_EXPORT void MWDSP_lms_an_wn_CC(const creal32_T *inSigU, 
                                const creal32_T *deSigU, 
                                const real32_T  muU,
                                uint32_T     *buffStartIdx, 
                                creal32_T       *inBuff, 
                                creal32_T       *wgtBuff,
                                const int_T   FilterLength, 
                                const real32_T  LkgFactor, 
                                const int_T   FrmLen, 
                                const int_T   bytesPerInpElmt,
                                creal32_T       *outY,
                                creal32_T       *errY);
/* 004 */     
DSPLMS_EXPORT void MWDSP_lms_an_wy_DD(const real_T *inSigU, 
                                const real_T *deSigU, 
                                const real_T  muU,
                                uint32_T     *buffStartIdx, 
                                real_T       *inBuff, 
                                real_T       *wgtBuff,
                                const int_T   FilterLength, 
                                const real_T  LkgFactor, 
                                const int_T   FrmLen, 
                                const int_T   bytesPerInpElmt,
                                real_T       *outY,
                                real_T       *errY,
                                real_T       *wgtY);
/* 005 */      
DSPLMS_EXPORT void MWDSP_lms_an_wy_ZZ(const creal_T *inSigU, 
                                const creal_T *deSigU, 
                                const real_T  muU,
                                uint32_T     *buffStartIdx, 
                                creal_T       *inBuff, 
                                creal_T       *wgtBuff,
                                const int_T   FilterLength, 
                                const real_T  LkgFactor, 
                                const int_T   FrmLen, 
                                const int_T   bytesPerInpElmt,
                                creal_T       *outY,
                                creal_T       *errY,
                                creal_T       *wgtY);
/* 006 */      
DSPLMS_EXPORT void MWDSP_lms_an_wy_RR(const real32_T *inSigU, 
                                const real32_T *deSigU, 
                                const real32_T  muU,
                                uint32_T     *buffStartIdx, 
                                real32_T       *inBuff, 
                                real32_T       *wgtBuff,
                                const int_T   FilterLength, 
                                const real32_T  LkgFactor, 
                                const int_T   FrmLen, 
                                const int_T   bytesPerInpElmt,
                                real32_T       *outY,
                                real32_T       *errY,
                                real32_T       *wgtY);
/* 007 */      
DSPLMS_EXPORT void MWDSP_lms_an_wy_CC(const creal32_T *inSigU, 
                                const creal32_T *deSigU, 
                                const real32_T  muU,
                                uint32_T     *buffStartIdx, 
                                creal32_T       *inBuff, 
                                creal32_T       *wgtBuff,
                                const int_T   FilterLength, 
                                const real32_T  LkgFactor, 
                                const int_T   FrmLen, 
                                const int_T   bytesPerInpElmt,
                                creal32_T       *outY,
                                creal32_T       *errY,
                                creal32_T       *wgtY);
/* 008 */      
DSPLMS_EXPORT void MWDSP_lms_ay_wn_DD(const real_T *inSigU, 
                                const real_T *deSigU, 
                                const real_T  muU,
                                uint32_T     *buffStartIdx, 
                                real_T       *inBuff, 
                                real_T       *wgtBuff,
                                const int_T   FilterLength, 
                                const real_T  LkgFactor, 
                                const int_T   FrmLen, 
                                const int_T   bytesPerInpElmt,
                                real_T       *outY,
                                real_T       *errY,
                                const boolean_T     NeedAdapt);
/* 009 */      
DSPLMS_EXPORT void MWDSP_lms_ay_wn_ZZ(const creal_T *inSigU, 
                                const creal_T *deSigU, 
                                const real_T  muU,
                                uint32_T     *buffStartIdx, 
                                creal_T       *inBuff, 
                                creal_T       *wgtBuff,
                                const int_T   FilterLength, 
                                const real_T  LkgFactor, 
                                const int_T   FrmLen, 
                                const int_T   bytesPerInpElmt,
                                creal_T       *outY,
                                creal_T       *errY,
                                const boolean_T     NeedAdapt);
/* 010 */     
DSPLMS_EXPORT void MWDSP_lms_ay_wn_RR(const real32_T *inSigU, 
                                const real32_T *deSigU, 
                                const real32_T  muU,
                                uint32_T     *buffStartIdx, 
                                real32_T       *inBuff, 
                                real32_T       *wgtBuff,
                                const int_T   FilterLength, 
                                const real32_T  LkgFactor, 
                                const int_T   FrmLen, 
                                const int_T   bytesPerInpElmt,
                                real32_T       *outY,
                                real32_T       *errY,
                                const boolean_T     NeedAdapt);
/* 011 */     
DSPLMS_EXPORT void MWDSP_lms_ay_wn_CC(const creal32_T *inSigU, 
                                const creal32_T *deSigU, 
                                const real32_T  muU,
                                uint32_T     *buffStartIdx, 
                                creal32_T       *inBuff, 
                                creal32_T       *wgtBuff,
                                const int_T   FilterLength, 
                                const real32_T  LkgFactor, 
                                const int_T   FrmLen, 
                                const int_T   bytesPerInpElmt,
                                creal32_T       *outY,
                                creal32_T       *errY,
                                const boolean_T     NeedAdapt);
/* 012 */     
DSPLMS_EXPORT void MWDSP_lms_ay_wy_DD(const real_T *inSigU, 
                                const real_T *deSigU, 
                                const real_T  muU,
                                uint32_T     *buffStartIdx, 
                                real_T       *inBuff, 
                                real_T       *wgtBuff,
                                const int_T   FilterLength, 
                                const real_T  LkgFactor, 
                                const int_T   FrmLen, 
                                const int_T   bytesPerInpElmt,
                                real_T       *outY,
                                real_T       *errY,
                                real_T       *wgtY,
                                const boolean_T     NeedAdapt);
/* 013 */     
DSPLMS_EXPORT void MWDSP_lms_ay_wy_ZZ(const creal_T *inSigU, 
                                const creal_T *deSigU, 
                                const real_T  muU,
                                uint32_T     *buffStartIdx, 
                                creal_T       *inBuff, 
                                creal_T       *wgtBuff,
                                const int_T   FilterLength, 
                                const real_T  LkgFactor, 
                                const int_T   FrmLen, 
                                const int_T   bytesPerInpElmt,
                                creal_T       *outY,
                                creal_T       *errY,
                                creal_T       *wgtY,
                                const boolean_T     NeedAdapt);
/* 014 */     
DSPLMS_EXPORT void MWDSP_lms_ay_wy_RR(const real32_T *inSigU, 
                                const real32_T *deSigU, 
                                const real32_T  muU,
                                uint32_T     *buffStartIdx, 
                                real32_T       *inBuff, 
                                real32_T       *wgtBuff,
                                const int_T   FilterLength, 
                                const real32_T  LkgFactor, 
                                const int_T   FrmLen, 
                                const int_T   bytesPerInpElmt,
                                real32_T       *outY,
                                real32_T       *errY,
                                real32_T       *wgtY,
                                const boolean_T     NeedAdapt);
/* 015 */     
DSPLMS_EXPORT void MWDSP_lms_ay_wy_CC(const creal32_T *inSigU, 
                                const creal32_T *deSigU, 
                                const real32_T  muU,
                                uint32_T     *buffStartIdx, 
                                creal32_T       *inBuff, 
                                creal32_T       *wgtBuff,
                                const int_T   FilterLength, 
                                const real32_T  LkgFactor, 
                                const int_T   FrmLen, 
                                const int_T   bytesPerInpElmt,
                                creal32_T       *outY,
                                creal32_T       *errY,
                                creal32_T       *wgtY,
                                const boolean_T     NeedAdapt);
/*****************************************LMS NORM *******************************************/   

/* 016 */      
DSPLMS_EXPORT void MWDSP_lmsn_an_wn_DD(const real_T *inSigU, 
                                const real_T *deSigU, 
                                const real_T  muU,
                                uint32_T     *buffStartIdx, 
                                real_T       *inBuff, 
                                real_T       *wgtBuff,
                                const int_T   FilterLength, 
                                const real_T  LkgFactor, 
                                const int_T   FrmLen, 
                                const int_T   bytesPerInpElmt,
                                real_T       *outY,
                                real_T       *errY,
                                real_T       *enrgInBuff);
/* 017 */     
DSPLMS_EXPORT void MWDSP_lmsn_an_wn_ZZ(const creal_T *inSigU, 
                                const creal_T *deSigU, 
                                const real_T  muU,
                                uint32_T     *buffStartIdx, 
                                creal_T       *inBuff, 
                                creal_T       *wgtBuff,
                                const int_T   FilterLength, 
                                const real_T  LkgFactor, 
                                const int_T   FrmLen, 
                                const int_T   bytesPerInpElmt,
                                creal_T       *outY,
                                creal_T       *errY,
                                real_T       *enrgInBuff);
/* 018 */     
DSPLMS_EXPORT void MWDSP_lmsn_an_wn_RR(const real32_T *inSigU, 
                                const real32_T *deSigU, 
                                const real32_T  muU,
                                uint32_T     *buffStartIdx, 
                                real32_T       *inBuff, 
                                real32_T       *wgtBuff,
                                const int_T   FilterLength, 
                                const real32_T  LkgFactor, 
                                const int_T   FrmLen, 
                                const int_T   bytesPerInpElmt,
                                real32_T       *outY,
                                real32_T       *errY,
                                real32_T       *enrgInBuff);
/* 019 */     
DSPLMS_EXPORT void MWDSP_lmsn_an_wn_CC(const creal32_T *inSigU, 
                                const creal32_T *deSigU, 
                                const real32_T  muU,
                                uint32_T     *buffStartIdx, 
                                creal32_T       *inBuff, 
                                creal32_T       *wgtBuff,
                                const int_T   FilterLength, 
                                const real32_T  LkgFactor, 
                                const int_T   FrmLen, 
                                const int_T   bytesPerInpElmt,
                                creal32_T       *outY,
                                creal32_T       *errY,
                                real32_T       *enrgInBuff);
/* 020 */     
DSPLMS_EXPORT void MWDSP_lmsn_an_wy_DD(const real_T *inSigU, 
                                const real_T *deSigU, 
                                const real_T  muU,
                                uint32_T     *buffStartIdx, 
                                real_T       *inBuff, 
                                real_T       *wgtBuff,
                                const int_T   FilterLength, 
                                const real_T  LkgFactor, 
                                const int_T   FrmLen, 
                                const int_T   bytesPerInpElmt,
                                real_T       *outY,
                                real_T       *errY,
                                real_T       *wgtY,
                                real_T       *enrgInBuff);
/* 021 */      
DSPLMS_EXPORT void MWDSP_lmsn_an_wy_ZZ(const creal_T *inSigU, 
                                const creal_T *deSigU, 
                                const real_T  muU,
                                uint32_T     *buffStartIdx, 
                                creal_T       *inBuff, 
                                creal_T       *wgtBuff,
                                const int_T   FilterLength, 
                                const real_T  LkgFactor, 
                                const int_T   FrmLen, 
                                const int_T   bytesPerInpElmt,
                                creal_T       *outY,
                                creal_T       *errY,
                                creal_T       *wgtY,
                                real_T       *enrgInBuff);
/* 022 */      
DSPLMS_EXPORT void MWDSP_lmsn_an_wy_RR(const real32_T *inSigU, 
                                const real32_T *deSigU, 
                                const real32_T  muU,
                                uint32_T     *buffStartIdx, 
                                real32_T       *inBuff, 
                                real32_T       *wgtBuff,
                                const int_T   FilterLength, 
                                const real32_T  LkgFactor, 
                                const int_T   FrmLen, 
                                const int_T   bytesPerInpElmt,
                                real32_T       *outY,
                                real32_T       *errY,
                                real32_T       *wgtY,
                                real32_T       *enrgInBuff);
/* 023 */      
DSPLMS_EXPORT void MWDSP_lmsn_an_wy_CC(const creal32_T *inSigU, 
                                const creal32_T *deSigU, 
                                const real32_T  muU,
                                uint32_T     *buffStartIdx, 
                                creal32_T       *inBuff, 
                                creal32_T       *wgtBuff,
                                const int_T   FilterLength, 
                                const real32_T  LkgFactor, 
                                const int_T   FrmLen, 
                                const int_T   bytesPerInpElmt,
                                creal32_T       *outY,
                                creal32_T       *errY,
                                creal32_T       *wgtY,
                                real32_T       *enrgInBuff);
/* 024 */      
DSPLMS_EXPORT void MWDSP_lmsn_ay_wn_DD(const real_T *inSigU, 
                                const real_T *deSigU, 
                                const real_T  muU,
                                uint32_T     *buffStartIdx, 
                                real_T       *inBuff, 
                                real_T       *wgtBuff,
                                const int_T   FilterLength, 
                                const real_T  LkgFactor, 
                                const int_T   FrmLen, 
                                const int_T   bytesPerInpElmt,
                                real_T       *outY,
                                real_T       *errY,
                                const boolean_T     NeedAdapt,
                                real_T       *enrgInBuff);
/* 025 */      
DSPLMS_EXPORT void MWDSP_lmsn_ay_wn_ZZ(const creal_T *inSigU, 
                                const creal_T *deSigU, 
                                const real_T  muU,
                                uint32_T     *buffStartIdx, 
                                creal_T       *inBuff, 
                                creal_T       *wgtBuff,
                                const int_T   FilterLength, 
                                const real_T  LkgFactor, 
                                const int_T   FrmLen, 
                                const int_T   bytesPerInpElmt,
                                creal_T       *outY,
                                creal_T       *errY,
                                const boolean_T     NeedAdapt,
                                real_T       *enrgInBuff);
/* 026 */     
DSPLMS_EXPORT void MWDSP_lmsn_ay_wn_RR(const real32_T *inSigU, 
                                const real32_T *deSigU, 
                                const real32_T  muU,
                                uint32_T     *buffStartIdx, 
                                real32_T       *inBuff, 
                                real32_T       *wgtBuff,
                                const int_T   FilterLength, 
                                const real32_T  LkgFactor, 
                                const int_T   FrmLen, 
                                const int_T   bytesPerInpElmt,
                                real32_T       *outY,
                                real32_T       *errY,
                                const boolean_T     NeedAdapt,
                                real32_T       *enrgInBuff);
/* 027 */     
DSPLMS_EXPORT void MWDSP_lmsn_ay_wn_CC(const creal32_T *inSigU, 
                                const creal32_T *deSigU, 
                                const real32_T  muU,
                                uint32_T     *buffStartIdx, 
                                creal32_T       *inBuff, 
                                creal32_T       *wgtBuff,
                                const int_T   FilterLength, 
                                const real32_T  LkgFactor, 
                                const int_T   FrmLen, 
                                const int_T   bytesPerInpElmt,
                                creal32_T       *outY,
                                creal32_T       *errY,
                                const boolean_T     NeedAdapt,
                                real32_T       *enrgInBuff);
/* 028 */     
DSPLMS_EXPORT void MWDSP_lmsn_ay_wy_DD(const real_T *inSigU, 
                                const real_T *deSigU, 
                                const real_T  muU,
                                uint32_T     *buffStartIdx, 
                                real_T       *inBuff, 
                                real_T       *wgtBuff,
                                const int_T   FilterLength, 
                                const real_T  LkgFactor, 
                                const int_T   FrmLen, 
                                const int_T   bytesPerInpElmt,
                                real_T       *outY,
                                real_T       *errY,
                                real_T       *wgtY,
                                const boolean_T     NeedAdapt,
                                real_T       *enrgInBuff);
/* 029 */     
DSPLMS_EXPORT void MWDSP_lmsn_ay_wy_ZZ(const creal_T *inSigU, 
                                const creal_T *deSigU, 
                                const real_T  muU,
                                uint32_T     *buffStartIdx, 
                                creal_T       *inBuff, 
                                creal_T       *wgtBuff,
                                const int_T   FilterLength, 
                                const real_T  LkgFactor, 
                                const int_T   FrmLen, 
                                const int_T   bytesPerInpElmt,
                                creal_T       *outY,
                                creal_T       *errY,
                                creal_T       *wgtY,
                                const boolean_T     NeedAdapt,
                                real_T       *enrgInBuff);
/* 030 */     
DSPLMS_EXPORT void MWDSP_lmsn_ay_wy_RR(const real32_T *inSigU, 
                                const real32_T *deSigU, 
                                const real32_T  muU,
                                uint32_T     *buffStartIdx, 
                                real32_T       *inBuff, 
                                real32_T       *wgtBuff,
                                const int_T   FilterLength, 
                                const real32_T  LkgFactor, 
                                const int_T   FrmLen, 
                                const int_T   bytesPerInpElmt,
                                real32_T       *outY,
                                real32_T       *errY,
                                real32_T       *wgtY,
                                const boolean_T     NeedAdapt,
                                real32_T       *enrgInBuff);
/* 031 */     
DSPLMS_EXPORT void MWDSP_lmsn_ay_wy_CC(const creal32_T *inSigU, 
                                const creal32_T *deSigU, 
                                const real32_T  muU,
                                uint32_T     *buffStartIdx, 
                                creal32_T       *inBuff, 
                                creal32_T       *wgtBuff,
                                const int_T   FilterLength, 
                                const real32_T  LkgFactor, 
                                const int_T   FrmLen, 
                                const int_T   bytesPerInpElmt,
                                creal32_T       *outY,
                                creal32_T       *errY,
                                creal32_T       *wgtY,
                                const boolean_T     NeedAdapt,
                                real32_T       *enrgInBuff);

/**************************************LMS_SIGN_ERROR************************************/ 
/* 032 */     
DSPLMS_EXPORT void MWDSP_lmsse_an_wn_DD(const real_T *inSigU, 
                                const real_T *deSigU, 
                                const real_T  muU,
                                uint32_T     *buffStartIdx, 
                                real_T       *inBuff, 
                                real_T       *wgtBuff,
                                const int_T   FilterLength, 
                                const real_T  LkgFactor, 
                                const int_T   FrmLen, 
                                const int_T   bytesPerInpElmt,
                                real_T       *outY,
                                real_T       *errY);
/* 033 */     
DSPLMS_EXPORT void MWDSP_lmsse_an_wn_RR(const real32_T *inSigU, 
                                const real32_T *deSigU, 
                                const real32_T  muU,
                                uint32_T     *buffStartIdx, 
                                real32_T       *inBuff, 
                                real32_T       *wgtBuff,
                                const int_T   FilterLength, 
                                const real32_T  LkgFactor, 
                                const int_T   FrmLen, 
                                const int_T   bytesPerInpElmt,
                                real32_T       *outY,
                                real32_T       *errY);
/* 034 */     
DSPLMS_EXPORT void MWDSP_lmsse_an_wy_DD(const real_T *inSigU, 
                                const real_T *deSigU, 
                                const real_T  muU,
                                uint32_T     *buffStartIdx, 
                                real_T       *inBuff, 
                                real_T       *wgtBuff,
                                const int_T   FilterLength, 
                                const real_T  LkgFactor, 
                                const int_T   FrmLen, 
                                const int_T   bytesPerInpElmt,
                                real_T       *outY,
                                real_T       *errY,
                                real_T       *wgtY);
/* 035 */      
DSPLMS_EXPORT void MWDSP_lmsse_an_wy_RR(const real32_T *inSigU, 
                                const real32_T *deSigU, 
                                const real32_T  muU,
                                uint32_T     *buffStartIdx, 
                                real32_T       *inBuff, 
                                real32_T       *wgtBuff,
                                const int_T   FilterLength, 
                                const real32_T  LkgFactor, 
                                const int_T   FrmLen, 
                                const int_T   bytesPerInpElmt,
                                real32_T       *outY,
                                real32_T       *errY,
                                real32_T       *wgtY);
/* 036 */      
DSPLMS_EXPORT void MWDSP_lmsse_ay_wn_DD(const real_T *inSigU, 
                                const real_T *deSigU, 
                                const real_T  muU,
                                uint32_T     *buffStartIdx, 
                                real_T       *inBuff, 
                                real_T       *wgtBuff,
                                const int_T   FilterLength, 
                                const real_T  LkgFactor, 
                                const int_T   FrmLen, 
                                const int_T   bytesPerInpElmt,
                                real_T       *outY,
                                real_T       *errY,
                                const boolean_T     NeedAdapt);
/* 037 */     
DSPLMS_EXPORT void MWDSP_lmsse_ay_wn_RR(const real32_T *inSigU, 
                                const real32_T *deSigU, 
                                const real32_T  muU,
                                uint32_T     *buffStartIdx, 
                                real32_T       *inBuff, 
                                real32_T       *wgtBuff,
                                const int_T   FilterLength, 
                                const real32_T  LkgFactor, 
                                const int_T   FrmLen, 
                                const int_T   bytesPerInpElmt,
                                real32_T       *outY,
                                real32_T       *errY,
                                const boolean_T     NeedAdapt);
/* 038 */     
DSPLMS_EXPORT void MWDSP_lmsse_ay_wy_DD(const real_T *inSigU, 
                                const real_T *deSigU, 
                                const real_T  muU,
                                uint32_T     *buffStartIdx, 
                                real_T       *inBuff, 
                                real_T       *wgtBuff,
                                const int_T   FilterLength, 
                                const real_T  LkgFactor, 
                                const int_T   FrmLen, 
                                const int_T   bytesPerInpElmt,
                                real_T       *outY,
                                real_T       *errY,
                                real_T       *wgtY,
                                const boolean_T     NeedAdapt);
/* 039 */     
DSPLMS_EXPORT void MWDSP_lmsse_ay_wy_RR(const real32_T *inSigU, 
                                const real32_T *deSigU, 
                                const real32_T  muU,
                                uint32_T     *buffStartIdx, 
                                real32_T       *inBuff, 
                                real32_T       *wgtBuff,
                                const int_T   FilterLength, 
                                const real32_T  LkgFactor, 
                                const int_T   FrmLen, 
                                const int_T   bytesPerInpElmt,
                                real32_T       *outY,
                                real32_T       *errY,
                                real32_T       *wgtY,
                                const boolean_T     NeedAdapt);

/************************************LMS_SIGN_DATA*************************************/
/* 040 */     
DSPLMS_EXPORT void MWDSP_lmssd_an_wn_DD(const real_T *inSigU, 
                                const real_T *deSigU, 
                                const real_T  muU,
                                uint32_T     *buffStartIdx, 
                                real_T       *inBuff, 
                                real_T       *wgtBuff,
                                const int_T   FilterLength, 
                                const real_T  LkgFactor, 
                                const int_T   FrmLen, 
                                const int_T   bytesPerInpElmt,
                                real_T       *outY,
                                real_T       *errY);
/* 041 */     
DSPLMS_EXPORT void MWDSP_lmssd_an_wn_RR(const real32_T *inSigU, 
                                const real32_T *deSigU, 
                                const real32_T  muU,
                                uint32_T     *buffStartIdx, 
                                real32_T       *inBuff, 
                                real32_T       *wgtBuff,
                                const int_T   FilterLength, 
                                const real32_T  LkgFactor, 
                                const int_T   FrmLen, 
                                const int_T   bytesPerInpElmt,
                                real32_T       *outY,
                                real32_T       *errY);
/* 042 */     
DSPLMS_EXPORT void MWDSP_lmssd_an_wy_DD(const real_T *inSigU, 
                                const real_T *deSigU, 
                                const real_T  muU,
                                uint32_T     *buffStartIdx, 
                                real_T       *inBuff, 
                                real_T       *wgtBuff,
                                const int_T   FilterLength, 
                                const real_T  LkgFactor, 
                                const int_T   FrmLen, 
                                const int_T   bytesPerInpElmt,
                                real_T       *outY,
                                real_T       *errY,
                                real_T       *wgtY);
/* 043 */      
DSPLMS_EXPORT void MWDSP_lmssd_an_wy_RR(const real32_T *inSigU, 
                                const real32_T *deSigU, 
                                const real32_T  muU,
                                uint32_T     *buffStartIdx, 
                                real32_T       *inBuff, 
                                real32_T       *wgtBuff,
                                const int_T   FilterLength, 
                                const real32_T  LkgFactor, 
                                const int_T   FrmLen, 
                                const int_T   bytesPerInpElmt,
                                real32_T       *outY,
                                real32_T       *errY,
                                real32_T       *wgtY);
/* 044 */      
DSPLMS_EXPORT void MWDSP_lmssd_ay_wn_DD(const real_T *inSigU, 
                                const real_T *deSigU, 
                                const real_T  muU,
                                uint32_T     *buffStartIdx, 
                                real_T       *inBuff, 
                                real_T       *wgtBuff,
                                const int_T   FilterLength, 
                                const real_T  LkgFactor, 
                                const int_T   FrmLen, 
                                const int_T   bytesPerInpElmt,
                                real_T       *outY,
                                real_T       *errY,
                                const boolean_T     NeedAdapt);
/* 045 */     
DSPLMS_EXPORT void MWDSP_lmssd_ay_wn_RR(const real32_T *inSigU, 
                                const real32_T *deSigU, 
                                const real32_T  muU,
                                uint32_T     *buffStartIdx, 
                                real32_T       *inBuff, 
                                real32_T       *wgtBuff,
                                const int_T   FilterLength, 
                                const real32_T  LkgFactor, 
                                const int_T   FrmLen, 
                                const int_T   bytesPerInpElmt,
                                real32_T       *outY,
                                real32_T       *errY,
                                const boolean_T     NeedAdapt);
/* 046 */     
DSPLMS_EXPORT void MWDSP_lmssd_ay_wy_DD(const real_T *inSigU, 
                                const real_T *deSigU, 
                                const real_T  muU,
                                uint32_T     *buffStartIdx, 
                                real_T       *inBuff, 
                                real_T       *wgtBuff,
                                const int_T   FilterLength, 
                                const real_T  LkgFactor, 
                                const int_T   FrmLen, 
                                const int_T   bytesPerInpElmt,
                                real_T       *outY,
                                real_T       *errY,
                                real_T       *wgtY,
                                const boolean_T     NeedAdapt);
/* 047 */     
DSPLMS_EXPORT void MWDSP_lmssd_ay_wy_RR(const real32_T *inSigU, 
                                const real32_T *deSigU, 
                                const real32_T  muU,
                                uint32_T     *buffStartIdx, 
                                real32_T       *inBuff, 
                                real32_T       *wgtBuff,
                                const int_T   FilterLength, 
                                const real32_T  LkgFactor, 
                                const int_T   FrmLen, 
                                const int_T   bytesPerInpElmt,
                                real32_T       *outY,
                                real32_T       *errY,
                                real32_T       *wgtY,
                                const boolean_T     NeedAdapt);

/*************************************LMS_SIGN_ERROR_SIGN_DATA****************************************/ 
/* 048 */     
DSPLMS_EXPORT void MWDSP_lmsss_an_wn_DD(const real_T *inSigU, 
                                const real_T *deSigU, 
                                const real_T  muU,
                                uint32_T     *buffStartIdx, 
                                real_T       *inBuff, 
                                real_T       *wgtBuff,
                                const int_T   FilterLength, 
                                const real_T  LkgFactor, 
                                const int_T   FrmLen, 
                                const int_T   bytesPerInpElmt,
                                real_T       *outY,
                                real_T       *errY);
/* 049 */     
DSPLMS_EXPORT void MWDSP_lmsss_an_wn_RR(const real32_T *inSigU, 
                                const real32_T *deSigU, 
                                const real32_T  muU,
                                uint32_T     *buffStartIdx, 
                                real32_T       *inBuff, 
                                real32_T       *wgtBuff,
                                const int_T   FilterLength, 
                                const real32_T  LkgFactor, 
                                const int_T   FrmLen, 
                                const int_T   bytesPerInpElmt,
                                real32_T       *outY,
                                real32_T       *errY);
/* 050 */     
DSPLMS_EXPORT void MWDSP_lmsss_an_wy_DD(const real_T *inSigU, 
                                const real_T *deSigU, 
                                const real_T  muU,
                                uint32_T     *buffStartIdx, 
                                real_T       *inBuff, 
                                real_T       *wgtBuff,
                                const int_T   FilterLength, 
                                const real_T  LkgFactor, 
                                const int_T   FrmLen, 
                                const int_T   bytesPerInpElmt,
                                real_T       *outY,
                                real_T       *errY,
                                real_T       *wgtY);
/* 051 */      
DSPLMS_EXPORT void MWDSP_lmsss_an_wy_RR(const real32_T *inSigU, 
                                const real32_T *deSigU, 
                                const real32_T  muU,
                                uint32_T     *buffStartIdx, 
                                real32_T       *inBuff, 
                                real32_T       *wgtBuff,
                                const int_T   FilterLength, 
                                const real32_T  LkgFactor, 
                                const int_T   FrmLen, 
                                const int_T   bytesPerInpElmt,
                                real32_T       *outY,
                                real32_T       *errY,
                                real32_T       *wgtY);
/* 052 */      
DSPLMS_EXPORT void MWDSP_lmsss_ay_wn_DD(const real_T *inSigU, 
                                const real_T *deSigU, 
                                const real_T  muU,
                                uint32_T     *buffStartIdx, 
                                real_T       *inBuff, 
                                real_T       *wgtBuff,
                                const int_T   FilterLength, 
                                const real_T  LkgFactor, 
                                const int_T   FrmLen, 
                                const int_T   bytesPerInpElmt,
                                real_T       *outY,
                                real_T       *errY,
                                const boolean_T     NeedAdapt);
/* 053 */     
DSPLMS_EXPORT void MWDSP_lmsss_ay_wn_RR(const real32_T *inSigU, 
                                const real32_T *deSigU, 
                                const real32_T  muU,
                                uint32_T     *buffStartIdx, 
                                real32_T       *inBuff, 
                                real32_T       *wgtBuff,
                                const int_T   FilterLength, 
                                const real32_T  LkgFactor, 
                                const int_T   FrmLen, 
                                const int_T   bytesPerInpElmt,
                                real32_T       *outY,
                                real32_T       *errY,
                                const boolean_T     NeedAdapt);
/* 054 */     
DSPLMS_EXPORT void MWDSP_lmsss_ay_wy_DD(const real_T *inSigU, 
                                const real_T *deSigU, 
                                const real_T  muU,
                                uint32_T     *buffStartIdx, 
                                real_T       *inBuff, 
                                real_T       *wgtBuff,
                                const int_T   FilterLength, 
                                const real_T  LkgFactor, 
                                const int_T   FrmLen, 
                                const int_T   bytesPerInpElmt,
                                real_T       *outY,
                                real_T       *errY,
                                real_T       *wgtY,
                                const boolean_T     NeedAdapt);
/* 055 */     
DSPLMS_EXPORT void MWDSP_lmsss_ay_wy_RR(const real32_T *inSigU, 
                                const real32_T *deSigU, 
                                const real32_T  muU,
                                uint32_T     *buffStartIdx, 
                                real32_T       *inBuff, 
                                real32_T       *wgtBuff,
                                const int_T   FilterLength, 
                                const real32_T  LkgFactor, 
                                const int_T   FrmLen, 
                                const int_T   bytesPerInpElmt,
                                real32_T       *outY,
                                real32_T       *errY,
                                real32_T       *wgtY,
                                const boolean_T     NeedAdapt);




#ifdef MWDSP_INLINE_DSPRTLIB
/* LMS ONLY */     
#include "dsplms/lms_an_wn_cc_rt.c"
#include "dsplms/lms_an_wn_dd_rt.c"
#include "dsplms/lms_an_wn_rr_rt.c"
#include "dsplms/lms_an_wn_zz_rt.c"
#include "dsplms/lms_an_wy_cc_rt.c"
#include "dsplms/lms_an_wy_dd_rt.c"
#include "dsplms/lms_an_wy_rr_rt.c"
#include "dsplms/lms_an_wy_zz_rt.c"
#include "dsplms/lms_ay_wn_cc_rt.c"
#include "dsplms/lms_ay_wn_dd_rt.c"
#include "dsplms/lms_ay_wn_rr_rt.c"
#include "dsplms/lms_ay_wn_zz_rt.c"
#include "dsplms/lms_ay_wy_cc_rt.c"
#include "dsplms/lms_ay_wy_dd_rt.c"
#include "dsplms/lms_ay_wy_rr_rt.c"
#include "dsplms/lms_ay_wy_zz_rt.c"
/* LMS NORM */      
#include "dsplms/lmsn_an_wn_cc_rt.c"
#include "dsplms/lmsn_an_wn_dd_rt.c"
#include "dsplms/lmsn_an_wn_rr_rt.c"
#include "dsplms/lmsn_an_wn_zz_rt.c"
#include "dsplms/lmsn_an_wy_cc_rt.c"
#include "dsplms/lmsn_an_wy_dd_rt.c"
#include "dsplms/lmsn_an_wy_rr_rt.c"
#include "dsplms/lmsn_an_wy_zz_rt.c"
#include "dsplms/lmsn_ay_wn_cc_rt.c"
#include "dsplms/lmsn_ay_wn_dd_rt.c"
#include "dsplms/lmsn_ay_wn_rr_rt.c"
#include "dsplms/lmsn_ay_wn_zz_rt.c"
#include "dsplms/lmsn_ay_wy_cc_rt.c"
#include "dsplms/lmsn_ay_wy_dd_rt.c"
#include "dsplms/lmsn_ay_wy_rr_rt.c"
#include "dsplms/lmsn_ay_wy_zz_rt.c"
/* LMS_SIGN_ERROR */      
#include "dsplms/lmsse_an_wn_dd_rt.c"
#include "dsplms/lmsse_an_wn_rr_rt.c"
#include "dsplms/lmsse_an_wy_dd_rt.c"
#include "dsplms/lmsse_an_wy_rr_rt.c"
#include "dsplms/lmsse_ay_wn_dd_rt.c"
#include "dsplms/lmsse_ay_wn_rr_rt.c"
#include "dsplms/lmsse_ay_wy_dd_rt.c"
/* LMS_SIGN_DATA */      
#include "dsplms/lmssd_an_wn_dd_rt.c"
#include "dsplms/lmssd_an_wn_rr_rt.c"
#include "dsplms/lmssd_an_wy_dd_rt.c"
#include "dsplms/lmssd_an_wy_rr_rt.c"
#include "dsplms/lmssd_ay_wn_dd_rt.c"
#include "dsplms/lmssd_ay_wn_rr_rt.c"
#include "dsplms/lmssd_ay_wy_dd_rt.c"
/* LMS_SIGN_ERROR_SIGN_DATA */      
#include "dsplms/lmsss_an_wn_dd_rt.c"
#include "dsplms/lmsss_an_wn_rr_rt.c"
#include "dsplms/lmsss_an_wy_dd_rt.c"
#include "dsplms/lmsss_an_wy_rr_rt.c"
#include "dsplms/lmsss_ay_wn_dd_rt.c"
#include "dsplms/lmsss_ay_wn_rr_rt.c"
#include "dsplms/lmsss_ay_wy_dd_rt.c"
#endif

#endif /*  dsplms_rt_h */      

/* [EOF] dsplms_rt.h */      
