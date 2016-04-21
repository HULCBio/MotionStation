/* 
 *  dsp_levdurb_sim.h   Simulation mid-level functions and structure declarations
 *                      for DSP Blockset Levinson-Durbin block. 
 * 
 *  Solves the Hermitian Toeplitz system of equations using the Levinson-Durbin
 *  recursion. 
 * 
 *  Copyright 1995-2002 The MathWorks, Inc.
 *  $Revision: 1.2 $  $Date: 2002/04/14 20:37:10 $ 
 */ 
#ifndef dsp_levdurb_sim_h 
#define dsp_levdurb_sim_h 

#include "dsp_sim.h" 

/* MWDSP_LevDurbArgsCache is a structure used to contain parameters/arguments 
 * for each of the individual mid-level functions listed below . 
 * 
 * Note that not all members of this structure have to be defined 
 * for every mid-level function.  Please refer to the description in the 
 * comments before each function prototype for more specific details. 
 */ 
typedef struct { 
    const void *u;      /* Input ACF parameters */ 
          int_T nSamps; /* Number of samples per input channel */
                        /* (length of u array / nChans) */ 
          int_T nChans; /* Number of input channels (in u array) */ 
    void       *y_A;    /* A output pointer (LPC coeffs) */ 
    void       *y_K;    /* K output pointer (Reflection coeffs) */ 
    void       *y_P;    /* P output pointer (Prediction error energy) */  
} MWDSP_LevDurbArgsCache; 

typedef void (*LevDurbFcn) (MWDSP_LevDurbArgsCache *args);

typedef struct {
    MWDSP_LevDurbArgsCache  args;
    LevDurbFcn              LevDurbFcnPtr;
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
 * LevDurb_<OutputOptions>_<Optional: Chk>_<DataType> 
 * 
 *    1) The first field indicates that this function is implementing the 
 *       Levinson-Durbin algorithm. 
 *    2) The second field is a string indicating output options in terms of 
 *       number of outputs as well as the nature of each output:  
 *       A   - One output, LPC filter coefficients 
 *       AK  - Two outputs, LPC filter coefficients and Reflection coefficients 
 *       AP  - Two outputs, LPC filter coefficients and Prediction error energy 
 *       AKP - Three outputs, LPC filter coefficients, Reflection coefficients 
 *       and Prediction error energy 
 *    3) The third field, which may or may not be present (denoted by "Chk"), 
 *       indicates that the input is checked every sample time for zero-valued 
 *       first element. Based on the result of that checking different operations
 *       are performed. If the first element is zero, a predefined set of outputs 
 *       are generated otherwise the usual Levinson recursion algorithm is performed.
 *    4) The last field enumerates the data type from the above list. 
 *       Single/double precision and complexity are specified within a single letter. 
 *       The data types of the input and output are the same. 
 * 
 *    Examples: 
 *       LevDurb_AKP_Z is the Levinson Durbin mid-level function for  
 *       double precision complex inputs. Three outputs (A, K, and P) are computed. 
 */ 
extern void LevDurb_No_Op(MWDSP_LevDurbArgsCache *args);

extern void LevDurb_A_D(MWDSP_LevDurbArgsCache *args);
extern void LevDurb_AK_D(MWDSP_LevDurbArgsCache *args); 
extern void LevDurb_AP_D(MWDSP_LevDurbArgsCache *args); 
extern void LevDurb_AKP_D(MWDSP_LevDurbArgsCache *args); 

extern void LevDurb_A_R(MWDSP_LevDurbArgsCache *args); 
extern void LevDurb_AK_R(MWDSP_LevDurbArgsCache *args); 
extern void LevDurb_AP_R(MWDSP_LevDurbArgsCache *args); 
extern void LevDurb_AKP_R(MWDSP_LevDurbArgsCache *args); 

extern void LevDurb_A_Z(MWDSP_LevDurbArgsCache *args); 
extern void LevDurb_AK_Z(MWDSP_LevDurbArgsCache *args); 
extern void LevDurb_AP_Z(MWDSP_LevDurbArgsCache *args); 
extern void LevDurb_AKP_Z(MWDSP_LevDurbArgsCache *args); 

extern void LevDurb_A_C(MWDSP_LevDurbArgsCache *args); 
extern void LevDurb_AK_C(MWDSP_LevDurbArgsCache *args); 
extern void LevDurb_AP_C(MWDSP_LevDurbArgsCache *args); 
extern void LevDurb_AKP_C(MWDSP_LevDurbArgsCache *args); 

/* These routines add the checking for input to the routines above */

extern void LevDurb_A_Chk_D(MWDSP_LevDurbArgsCache *args);
extern void LevDurb_AK_Chk_D(MWDSP_LevDurbArgsCache *args);
extern void LevDurb_AP_Chk_D(MWDSP_LevDurbArgsCache *args);
extern void LevDurb_AKP_Chk_D(MWDSP_LevDurbArgsCache *args);

extern void LevDurb_A_Chk_R(MWDSP_LevDurbArgsCache *args);
extern void LevDurb_AK_Chk_R(MWDSP_LevDurbArgsCache *args);
extern void LevDurb_AP_Chk_R(MWDSP_LevDurbArgsCache *args);
extern void LevDurb_AKP_Chk_R(MWDSP_LevDurbArgsCache *args);

extern void LevDurb_A_Chk_Z(MWDSP_LevDurbArgsCache *args);
extern void LevDurb_AK_Chk_Z(MWDSP_LevDurbArgsCache *args);
extern void LevDurb_AP_Chk_Z(MWDSP_LevDurbArgsCache *args);
extern void LevDurb_AKP_Chk_Z(MWDSP_LevDurbArgsCache *args);

extern void LevDurb_A_Chk_C(MWDSP_LevDurbArgsCache *args);
extern void LevDurb_AK_Chk_C(MWDSP_LevDurbArgsCache *args);
extern void LevDurb_AP_Chk_C(MWDSP_LevDurbArgsCache *args);
extern void LevDurb_AKP_Chk_C(MWDSP_LevDurbArgsCache *args);

#endif /*  dsp_levdurb_sim_h */ 

/* [EOF] dsp_levdurb_sim.h */ 
