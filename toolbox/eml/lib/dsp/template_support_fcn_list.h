/* This header file is parsed when eML runtime library template
functions are used from this directory. 
This header file must contain the declarations for all c-functions
needed by the template eML files in this directory.
Note that this file MUST NOT have any preprocessor directives.
Apart from standard c-types, the following type names are
recognized:
 real_T      creal_T   
 uint8_T     cuint8_T  
 int8_T      cint8_T   
 uint16_T    cuint16_T 
 int16_T     cint16_T  
 uint32_T    cuint32_T 
 int32_T     cint32_T   
 real32_T    creal32_T 
 real64_T    creal64_T 
 boolean_T   
 bool   
 int_T
 uint_T
 byte_T 
 
*/
void MWDSP_IIR_DF2T_A0Scale_DD(const real_T         *u,
                              real_T               *y,
                              real_T * const       mem_base,
                              const int_T          numDelays,
                              const int_T          sampsPerChan,
                              const int_T          numChans,
                              const real_T * const num,
                              const int_T          ordNUM,
                              const real_T * const den,
                              const int_T          ordDEN,
                              const boolean_T      one_fpf);
void MWDSP_IIR_DF2T_A0Scale_DZ(const real_T          *u,
                              creal_T               *y,
                              creal_T * const       mem_base,
                              const int_T           numDelays,
                              const int_T           sampsPerChan,
                              const int_T           numChans,
                              const creal_T * const num,
                              const int_T           ordNUM,
                              const creal_T * const den,
                              const int_T           ordDEN,
                              const boolean_T       one_fpf);

void MWDSP_IIR_DF2T_A0Scale_ZD(const creal_T         *u,
                              creal_T               *y,
                              creal_T * const       mem_base,
                              const int_T           numDelays,
                              const int_T           sampsPerChan,
                              const int_T           numChans,
                              const real_T * const  num,
                              const int_T           ordNUM,
                              const real_T * const  den,
                              const int_T           ordDEN,
                              const boolean_T       one_fpf);

void MWDSP_IIR_DF2T_A0Scale_ZZ(const creal_T         *u,
                              creal_T               *y,
                              creal_T * const       mem_base,
                              const int_T           numDelays,
                              const int_T           sampsPerChan,
                              const int_T           numChans,
                              const creal_T * const num,
                              const int_T           ordNUM,
                              const creal_T * const den,
                              const int_T           ordDEN,
                              const boolean_T       one_fpf);
                              
                              
void MWDSP_IIR_DF2T_A0Scale_RR(const real32_T         *u,
                              real32_T               *y,
                              real32_T * const       mem_base,
                              const int_T          numDelays,
                              const int_T          sampsPerChan,
                              const int_T          numChans,
                              const real32_T * const num,
                              const int_T          ordNUM,
                              const real32_T * const den,
                              const int_T          ordDEN,
                              const boolean_T      one_fpf);
                              
void MWDSP_IIR_DF2T_A0Scale_RC(const real32_T          *u,
                              creal32_T               *y,
                              creal32_T * const       mem_base,
                              const int_T             numDelays,
                              const int_T             sampsPerChan,
                              const int_T             numChans,
                              const creal32_T * const num,
                              const int_T             ordNUM,
                              const creal32_T * const den,
                              const int_T             ordDEN,
                              const boolean_T         one_fpf);

void MWDSP_IIR_DF2T_A0Scale_CR(const creal32_T         *u,
                              creal32_T               *y,
                              creal32_T * const       mem_base,
                              const int_T             numDelays,
                              const int_T             sampsPerChan,
                              const int_T             numChans,
                              const real32_T * const  num,
                              const int_T             ordNUM,
                              const real32_T * const  den,
                              const int_T             ordDEN,
                              const boolean_T         one_fpf);

void MWDSP_IIR_DF2T_A0Scale_CC(const creal32_T         *u,
                              creal32_T               *y,
                              creal32_T * const       mem_base,
                              const int_T             numDelays,
                              const int_T             sampsPerChan,
                              const int_T             numChans,
                              const creal32_T * const num,
                              const int_T             ordNUM,
                              const creal32_T * const den,
                              const int_T             ordDEN,
                              const boolean_T         one_fpf);
                              

void MWDSP_IIR_DF2T_DD(       const real_T         *u,
                              real_T               *y,
                              real_T * const       mem_base,
                              const int_T          numDelays,
                              const int_T          sampsPerChan,
                              const int_T          numChans,
                              const real_T * const num,
                              const int_T          ordNUM,
                              const real_T * const den,
                              const int_T          ordDEN,
                              const boolean_T      one_fpf);
                              
void MWDSP_IIR_DF2T_DZ(const real_T          *u,
                              creal_T               *y,
                              creal_T * const       mem_base,
                              const int_T           numDelays,
                              const int_T           sampsPerChan,
                              const int_T           numChans,
                              const creal_T * const num,
                              const int_T           ordNUM,
                              const creal_T * const den,
                              const int_T           ordDEN,
                              const boolean_T       one_fpf);

void MWDSP_IIR_DF2T_ZD(const creal_T         *u,
                              creal_T               *y,
                              creal_T * const       mem_base,
                              const int_T           numDelays,
                              const int_T           sampsPerChan,
                              const int_T           numChans,
                              const real_T * const  num,
                              const int_T           ordNUM,
                              const real_T * const  den,
                              const int_T           ordDEN,
                              const boolean_T       one_fpf);

void MWDSP_IIR_DF2T_ZZ(const creal_T         *u,
                              creal_T               *y,
                              creal_T * const       mem_base,
                              const int_T           numDelays,
                              const int_T           sampsPerChan,
                              const int_T           numChans,
                              const creal_T * const num,
                              const int_T           ordNUM,
                              const creal_T * const den,
                              const int_T           ordDEN,
                              const boolean_T       one_fpf);

                              
                              
void MWDSP_IIR_DF2T_RR(       const real32_T         *u,
                              real32_T               *y,
                              real32_T * const       mem_base,
                              const int_T          numDelays,
                              const int_T          sampsPerChan,
                              const int_T          numChans,
                              const real32_T * const num,
                              const int_T          ordNUM,
                              const real32_T * const den,
                              const int_T          ordDEN,
                              const boolean_T      one_fpf);
                              
void MWDSP_IIR_DF2T_RC(const real32_T          *u,
                              creal32_T               *y,
                              creal32_T * const       mem_base,
                              const int_T             numDelays,
                              const int_T             sampsPerChan,
                              const int_T             numChans,
                              const creal32_T * const num,
                              const int_T             ordNUM,
                              const creal32_T * const den,
                              const int_T             ordDEN,
                              const boolean_T         one_fpf);

void MWDSP_IIR_DF2T_CR(const creal32_T         *u,
                              creal32_T               *y,
                              creal32_T * const       mem_base,
                              const int_T             numDelays,
                              const int_T             sampsPerChan,
                              const int_T             numChans,
                              const real32_T * const  num,
                              const int_T             ordNUM,
                              const real32_T * const  den,
                              const int_T             ordDEN,
                              const boolean_T         one_fpf);

void MWDSP_IIR_DF2T_CC(const creal32_T         *u,
                              creal32_T               *y,
                              creal32_T * const       mem_base,
                              const int_T             numDelays,
                              const int_T             sampsPerChan,
                              const int_T             numChans,
                              const creal32_T * const num,
                              const int_T             ordNUM,
                              const creal32_T * const den,
                              const int_T             ordDEN,
                              const boolean_T         one_fpf);
                              
                              
void MWDSP_AllPole_TDF_A0Scale_DD(const real_T         *u,
                                 real_T               *y,
                                 real_T * const       mem_base,
                                 const int_T          numDelays,
                                 const int_T          sampsPerChan,
                                 const int_T          numChans,
                                 const real_T * const den,
                                 const int_T          ordDEN,
                                 const boolean_T      one_fpf);
                                 
void MWDSP_AllPole_TDF_A0Scale_DZ(const real_T          *u,
                                 creal_T               *y,
                                 creal_T * const       mem_base,
                                 const int_T           numDelays,
                                 const int_T           sampsPerChan,
                                 const int_T           numChans,
                                 const creal_T * const den,
                                 const int_T           ordDEN,
                                 const boolean_T       one_fpf);

void MWDSP_AllPole_TDF_A0Scale_ZD(const creal_T         *u,
                                 creal_T               *y,
                                 creal_T * const       mem_base,
                                 const int_T           numDelays,
                                 const int_T           sampsPerChan,
                                 const int_T           numChans,
                                 const real_T * const  den,
                                 const int_T           ordDEN,
                                 const boolean_T       one_fpf);

void MWDSP_AllPole_TDF_A0Scale_ZZ(const creal_T         *u,
                                 creal_T               *y,
                                 creal_T * const       mem_base,
                                 const int_T           numDelays,
                                 const int_T           sampsPerChan,
                                 const int_T           numChans,
                                 const creal_T * const den,
                                 const int_T           ordDEN,
                                 const boolean_T       one_fpf);
                                 
                                 
void MWDSP_AllPole_TDF_DD(       const real_T         *u,
                                 real_T               *y,
                                 real_T * const       mem_base,
                                 const int_T          numDelays,
                                 const int_T          sampsPerChan,
                                 const int_T          numChans,
                                 const real_T * const den,
                                 const int_T          ordDEN,
                                 const boolean_T      one_fpf);
                                 
void MWDSP_AllPole_TDF_DZ(const real_T          *u,
                                 creal_T               *y,
                                 creal_T * const       mem_base,
                                 const int_T           numDelays,
                                 const int_T           sampsPerChan,
                                 const int_T           numChans,
                                 const creal_T * const den,
                                 const int_T           ordDEN,
                                 const boolean_T       one_fpf);

void MWDSP_AllPole_TDF_ZD(const creal_T         *u,
                                 creal_T               *y,
                                 creal_T * const       mem_base,
                                 const int_T           numDelays,
                                 const int_T           sampsPerChan,
                                 const int_T           numChans,
                                 const real_T * const  den,
                                 const int_T           ordDEN,
                                 const boolean_T       one_fpf);

void MWDSP_AllPole_TDF_ZZ(const creal_T         *u,
                                 creal_T               *y,
                                 creal_T * const       mem_base,
                                 const int_T           numDelays,
                                 const int_T           sampsPerChan,
                                 const int_T           numChans,
                                 const creal_T * const den,
                                 const int_T           ordDEN,
                                 const boolean_T       one_fpf);
                                 
                                 
void MWDSP_FIR_TDF_DD(       const real_T         *u,
                             real_T               *y,
                             real_T * const       mem_base,
                             const int_T          numDelays,
                             const int_T          sampsPerChan,
                             const int_T          numChans,
                             const real_T * const num,
                             const int_T          ordNUM,
                             const boolean_T      one_fpf);
                             
void MWDSP_FIR_TDF_DZ(const real_T          *u,
                             creal_T               *y,
                             creal_T * const       mem_base,
                             const int_T           numDelays,
                             const int_T           sampsPerChan,
                             const int_T           numChans,
                             const creal_T * const num,
                             const int_T           ordNUM,
                             const boolean_T       one_fpf);

void MWDSP_FIR_TDF_ZD(const creal_T         *u,
                             creal_T               *y,
                             creal_T * const       mem_base,
                             const int_T           numDelays,
                             const int_T           sampsPerChan,
                             const int_T           numChans,
                             const real_T * const  num,
                             const int_T           ordNUM,
                             const boolean_T       one_fpf);

void MWDSP_FIR_TDF_ZZ(const creal_T         *u,
                             creal_T               *y,
                             creal_T * const       mem_base,
                             const int_T           numDelays,
                             const int_T           sampsPerChan,
                             const int_T           numChans,
                             const creal_T * const num,
                             const int_T           ordNUM,
                             const boolean_T       one_fpf);
                             
                                 
void MWDSP_AllPole_TDF_A0Scale_RR(const real32_T         *u,
                                 real32_T               *y,
                                 real32_T * const       mem_base,
                                 const int_T          numDelays,
                                 const int_T          sampsPerChan,
                                 const int_T          numChans,
                                 const real32_T * const den,
                                 const int_T          ordDEN,
                                 const boolean_T      one_fpf);
                                 
void MWDSP_AllPole_TDF_A0Scale_RC(const real32_T          *u,
                                 creal32_T               *y,
                                 creal32_T * const       mem_base,
                                 const int_T             numDelays,
                                 const int_T             sampsPerChan,
                                 const int_T             numChans,
                                 const creal32_T * const den,
                                 const int_T             ordDEN,
                                 const boolean_T         one_fpf);

void MWDSP_AllPole_TDF_A0Scale_CR(const creal32_T         *u,
                                 creal32_T               *y,
                                 creal32_T * const       mem_base,
                                 const int_T             numDelays,
                                 const int_T             sampsPerChan,
                                 const int_T             numChans,
                                 const real32_T * const  den,
                                 const int_T             ordDEN,
                                 const boolean_T         one_fpf);

void MWDSP_AllPole_TDF_A0Scale_CC(const creal32_T         *u,
                                 creal32_T               *y,
                                 creal32_T * const       mem_base,
                                 const int_T             numDelays,
                                 const int_T             sampsPerChan,
                                 const int_T             numChans,
                                 const creal32_T * const den,
                                 const int_T             ordDEN,
                                 const boolean_T         one_fpf);                                 
                                 
void MWDSP_AllPole_TDF_RR(       const real32_T         *u,
                                 real32_T               *y,
                                 real32_T * const       mem_base,
                                 const int_T          numDelays,
                                 const int_T          sampsPerChan,
                                 const int_T          numChans,
                                 const real32_T * const den,
                                 const int_T          ordDEN,
                                 const boolean_T      one_fpf);
                                 
void MWDSP_AllPole_TDF_RC(const real32_T          *u,
                                 creal32_T               *y,
                                 creal32_T * const       mem_base,
                                 const int_T             numDelays,
                                 const int_T             sampsPerChan,
                                 const int_T             numChans,
                                 const creal32_T * const den,
                                 const int_T             ordDEN,
                                 const boolean_T         one_fpf);

void MWDSP_AllPole_TDF_CR(const creal32_T         *u,
                                 creal32_T               *y,
                                 creal32_T * const       mem_base,
                                 const int_T             numDelays,
                                 const int_T             sampsPerChan,
                                 const int_T             numChans,
                                 const real32_T * const  den,
                                 const int_T             ordDEN,
                                 const boolean_T         one_fpf);

void MWDSP_AllPole_TDF_CC(const creal32_T         *u,
                                 creal32_T               *y,
                                 creal32_T * const       mem_base,
                                 const int_T             numDelays,
                                 const int_T             sampsPerChan,
                                 const int_T             numChans,
                                 const creal32_T * const den,
                                 const int_T             ordDEN,
                                 const boolean_T         one_fpf);
                                 
                                 
void MWDSP_FIR_TDF_RR(       const real32_T         *u,
                             real32_T               *y,
                             real32_T * const       mem_base,
                             const int_T          numDelays,
                             const int_T          sampsPerChan,
                             const int_T          numChans,
                             const real32_T * const num,
                             const int_T          ordNUM,
                             const boolean_T      one_fpf);

void MWDSP_FIR_TDF_RC(const real32_T          *u,
                             creal32_T               *y,
                             creal32_T * const       mem_base,
                             const int_T             numDelays,
                             const int_T             sampsPerChan,
                             const int_T             numChans,
                             const creal32_T * const num,
                             const int_T             ordNUM,
                             const boolean_T         one_fpf);

void MWDSP_FIR_TDF_CR(const creal32_T         *u,
                             creal32_T               *y,
                             creal32_T * const       mem_base,
                             const int_T             numDelays,
                             const int_T             sampsPerChan,
                             const int_T             numChans,
                             const real32_T * const  num,
                             const int_T             ordNUM,
                             const boolean_T         one_fpf);

void MWDSP_FIR_TDF_CC(const creal32_T         *u,
                             creal32_T               *y,
                             creal32_T * const       mem_base,
                             const int_T             numDelays,
                             const int_T             sampsPerChan,
                             const int_T             numChans,
                             const creal32_T * const num,
                             const int_T             ordNUM,
                             const boolean_T         one_fpf);
                             
                              
/* Run time functions to support 'conv' function . */
/*
 * Double Precision, Time Domain Convolution
 */
void MWDSP_Conv_TD_DD(
    const real_T  *inPtrA,
    int_T         nRowsA,    /* number of rows in input A     */
    boolean_T     multiChanA,/* Boolean indicating whether A has more than 1 channel */

    const real_T  *inPtrB,
    int_T         nRowsB,    /* number of rows in input B     */
    boolean_T     multiChanB,/* Boolean indicating whether B has more than 1 channel */

    real_T        *outPtr,
    int_T         nRowsY,    /* number of rows in the output array    */
    int_T         nChansY   /* number of columns in the output array */
);

void MWDSP_Conv_TD_DZ(
    const real_T  *inPtrA,
    int_T         nRowsA,    /* number of rows in input A     */
    boolean_T     multiChanA,/* Boolean indicating whether A has more than 1 channel */

    const creal_T *inPtrB,
    int_T         nRowsB,    /* number of rows in input B     */
    boolean_T     multiChanB,/* Boolean indicating whether B has more than 1 channel */

    creal_T       *outPtr,
    int_T         nRowsY,    /* number of rows in the output array    */
    int_T         nChansY   /* number of columns in the output array */
);

void MWDSP_Conv_TD_ZZ(
    const creal_T *inPtrA,
    int_T         nRowsA,    /* number of rows in input A     */
    boolean_T     multiChanA,/* Boolean indicating whether A has more than 1 channel */

    const creal_T *inPtrB,
    int_T         nRowsB,    /* number of rows in input B     */
    boolean_T     multiChanB,/* Boolean indicating whether B has more than 1 channel */

    creal_T       *outPtr,
    int_T         nRowsY,    /* number of rows in the output array    */
    int_T         nChansY   /* number of columns in the output array */
);

/*
 * Single Precision, Time Domain Convolution
 */
void MWDSP_Conv_TD_RR(
    const real32_T  *inPtrA,
    int_T           nRowsA,    /* number of rows in input A     */
    boolean_T       multiChanA,/* Boolean indicating whether A has more than 1 channel */

    const real32_T  *inPtrB,
    int_T           nRowsB,    /* number of rows in input B     */
    boolean_T       multiChanB,/* Boolean indicating whether B has more than 1 channel */

    real32_T        *outPtr,
    int_T           nRowsY,    /* number of rows in the output array    */
    int_T           nChansY   /* number of columns in the output array */
);

void MWDSP_Conv_TD_RC(
    const real32_T  *inPtrA,
    int_T           nRowsA,    /* number of rows in input A     */
    boolean_T       multiChanA,/* Boolean indicating whether A has more than 1 channel */

    const creal32_T *inPtrB,
    int_T           nRowsB,    /* number of rows in input B     */
    boolean_T       multiChanB,/* Boolean indicating whether B has more than 1 channel */

    creal32_T       *outPtr,
    int_T           nRowsY,    /* number of rows in the output array    */
    int_T           nChansY   /* number of columns in the output array */
);

void MWDSP_Conv_TD_CC(
    const creal32_T *inPtrA,
    int_T           nRowsA,    /* number of rows in input A     */
    boolean_T       multiChanA,/* Boolean indicating whether A has more than 1 channel */

    const creal32_T *inPtrB,
    int_T           nRowsB,    /* number of rows in input B     */
    boolean_T       multiChanB,/* Boolean indicating whether B has more than 1 channel */

    creal32_T       *outPtr,
    int_T           nRowsY,    /* number of rows in the output array    */
    int_T           nChansY   /* number of columns in the output array */
);

/* Run time function for 'xcorr' function. */
void MWDSP_Corr_TD_DD(
    const real_T  *inPtrA,
    int_T         nRowsA,    /* number of rows in input A     */
    boolean_T     multiChanA,/* Boolean indicating whether A has more than 1 channel */

    const real_T  *inPtrB,
    int_T         nRowsB,    /* number of rows in input B     */
    boolean_T     multiChanB,/* Boolean indicating whether B has more than 1 channel */

    real_T        *outPtr,
    int_T         nRowsY,    /* number of rows in the output array    */
    int_T         nChansY   /* number of columns in the output array */
);

void MWDSP_Corr_TD_DZ(
    const real_T  *inPtrA,
    int_T         nRowsA,    /* number of rows in input A     */
    boolean_T     multiChanA,/* Boolean indicating whether A has more than 1 channel */

    const creal_T *inPtrB,
    int_T         nRowsB,    /* number of rows in input B     */
    boolean_T     multiChanB,/* Boolean indicating whether B has more than 1 channel */

    creal_T       *outPtr,
    int_T         nRowsY,    /* number of rows in the output array    */
    int_T         nChansY   /* number of columns in the output array */
);

void MWDSP_Corr_TD_ZD(
    const creal_T *inPtrA,
    int_T         nRowsA,    /* number of rows in input A     */
    boolean_T     multiChanA,/* Boolean indicating whether A has more than 1 channel */

    const real_T  *inPtrB,
    int_T         nRowsB,    /* number of rows in input B     */
    boolean_T     multiChanB,/* Boolean indicating whether B has more than 1 channel */

    creal_T       *outPtr,
    int_T         nRowsY,    /* number of rows in the output array    */
    int_T         nChansY   /* number of columns in the output array */
);

void MWDSP_Corr_TD_ZZ(
    const creal_T *inPtrA,
    int_T         nRowsA,    /* number of rows in input A     */
    boolean_T     multiChanA,/* Boolean indicating whether A has more than 1 channel */

    const creal_T *inPtrB,
    int_T         nRowsB,    /* number of rows in input B     */
    boolean_T     multiChanB,/* Boolean indicating whether B has more than 1 channel */

    creal_T       *outPtr,
    int_T         nRowsY,    /* number of rows in the output array    */
    int_T         nChansY   /* number of columns in the output array */
);

void MWDSP_Corr_TD_RR(
    const real32_T  *inPtrA,
    int_T           nRowsA,    /* number of rows in input A     */
    boolean_T       multiChanA,/* Boolean indicating whether A has more than 1 channel */

    const real32_T  *inPtrB,
    int_T           nRowsB,    /* number of rows in input B     */
    boolean_T       multiChanB,/* Boolean indicating whether B has more than 1 channel */

    real32_T        *outPtr,
    int_T           nRowsY,    /* number of rows in the output array    */
    int_T           nChansY   /* number of columns in the output array */
);

void MWDSP_Corr_TD_RC(
    const real32_T  *inPtrA,
    int_T           nRowsA,    /* number of rows in input A     */
    boolean_T       multiChanA,/* Boolean indicating whether A has more than 1 channel */

    const creal32_T *inPtrB,
    int_T           nRowsB,    /* number of rows in input B     */
    boolean_T       multiChanB,/* Boolean indicating whether B has more than 1 channel */

    creal32_T       *outPtr,
    int_T           nRowsY,    /* number of rows in the output array    */
    int_T           nChansY   /* number of columns in the output array */
);

void MWDSP_Corr_TD_CR(
    const creal32_T *inPtrA,
    int_T           nRowsA,    /* number of rows in input A     */
    boolean_T       multiChanA,/* Boolean indicating whether A has more than 1 channel */

    const real32_T  *inPtrB,
    int_T           nRowsB,    /* number of rows in input B     */
    boolean_T       multiChanB,/* Boolean indicating whether B has more than 1 channel */

    creal32_T       *outPtr,
    int_T           nRowsY,    /* number of rows in the output array    */
    int_T           nChansY   /* number of columns in the output array */
);

void MWDSP_Corr_TD_CC(
    const creal32_T *inPtrA,
    int_T           nRowsA,    /* number of rows in input A     */
    boolean_T       multiChanA,/* Boolean indicating whether A has more than 1 channel */

    const creal32_T *inPtrB,
    int_T           nRowsB,    /* number of rows in input B     */
    boolean_T       multiChanB,/* Boolean indicating whether B has more than 1 channel */

    creal32_T       *outPtr,
    int_T           nRowsY,    /* number of rows in the output array    */
    int_T           nChansY   /* number of columns in the output array */
);

/* Run-time functions to support 'chol' function */
void MWDSP_Chol_D(real_T    *A, int_T n);
void MWDSP_Chol_R(real32_T  *A, int_T n);
void MWDSP_Chol_Z(creal_T   *A, int_T n);
void MWDSP_Chol_C(creal32_T *A, int_T n);


/* Run time functions to support 'sosfilt' function. */
void MWDSP_BQ6_DF2T_1fpf_Nsos_DD(const real_T *u,
                                        real_T       *y,
                                        real_T       *state,
                                        const real_T *coeffs,
                                        const real_T *a0invs,
                                        const int_T   sampsPerChan,
                                        const int_T   numChans,
                                        const int_T   numSections);
                                        
void MWDSP_BQ6_DF2T_1fpf_Nsos_DZ(const real_T  *u,
                                        creal_T       *y,
                                        creal_T       *state,
                                        const creal_T *coeffs,
                                        const creal_T *a0invs,
                                        const int_T    sampsPerChan,
                                        const int_T    numChans,
                                        const int_T    numSections);

void MWDSP_BQ6_DF2T_1fpf_Nsos_ZD(const creal_T *u,
                                        creal_T       *y,
                                        creal_T       *state,
                                        const real_T  *coeffs,
                                        const real_T  *a0invs,
                                        const int_T    sampsPerChan,
                                        const int_T    numChans,
                                        const int_T    numSections);

void MWDSP_BQ6_DF2T_1fpf_Nsos_ZZ(const creal_T *u,
                                        creal_T       *y,
                                        creal_T       *state,
                                        const creal_T *coeffs,
                                        const creal_T *a0invs,
                                        const int_T    sampsPerChan,
                                        const int_T    numChans,
                                        const int_T    numSections);
                                        
                                        
void MWDSP_BQ6_DF2T_1fpf_1sos_DD(const real_T *u,
                                        real_T       *y,
                                        real_T       *state,
                                        const real_T *coeffs,
                                        const real_T  a0inv,
                                        const int_T   sampsPerChan,
                                        const int_T   numChans);
                                        
void MWDSP_BQ6_DF2T_1fpf_1sos_DZ(const real_T  *u,
                                        creal_T       *y,
                                        creal_T       *state,
                                        const creal_T *coeffs,
                                        const creal_T  a0inv,
                                        const int_T    sampsPerChan,
                                        const int_T    numChans);

void MWDSP_BQ6_DF2T_1fpf_1sos_ZD(const creal_T *u,
                                        creal_T       *y,
                                        creal_T       *state,
                                        const real_T  *coeffs,
                                        const real_T   a0inv,
                                        const int_T    sampsPerChan,
                                        const int_T    numChans);

void MWDSP_BQ6_DF2T_1fpf_1sos_ZZ(const creal_T *u,
                                        creal_T       *y,
                                        creal_T       *state,
                                        const creal_T *coeffs,
                                        const creal_T  a0inv,
                                        const int_T    sampsPerChan,
                                        const int_T    numChans);    
                                        
void MWDSP_BQ6_DF2T_1fpf_Nsos_RR(const real32_T *u,
                                        real32_T       *y,
                                        real32_T       *state,
                                        const real32_T *coeffs,
                                        const real32_T *a0invs,
                                        const int_T     sampsPerChan,
                                        const int_T     numChans,
                                        const int_T     numSections);

void MWDSP_BQ6_DF2T_1fpf_Nsos_RC(const real32_T  *u,
                                        creal32_T       *y,
                                        creal32_T       *state,
                                        const creal32_T *coeffs,
                                        const creal32_T *a0invs,
                                        const int_T      sampsPerChan,
                                        const int_T      numChans,
                                        const int_T      numSections);

void MWDSP_BQ6_DF2T_1fpf_Nsos_CR(const creal32_T *u,
                                        creal32_T       *y,
                                        creal32_T       *state,
                                        const real32_T  *coeffs,
                                        const real32_T  *a0invs,
                                        const int_T      sampsPerChan,
                                        const int_T      numChans,
                                        const int_T      numSections);

void MWDSP_BQ6_DF2T_1fpf_Nsos_CC(const creal32_T *u,
                                        creal32_T       *y,
                                        creal32_T       *state,
                                        const creal32_T *coeffs,
                                        const creal32_T *a0invs,
                                        const int_T      sampsPerChan,
                                        const int_T      numChans,
                                        const int_T      numSections);    
                                        
void MWDSP_BQ6_DF2T_1fpf_1sos_RR(const real32_T *u,
                                        real32_T       *y,
                                        real32_T       *state,
                                        const real32_T *coeffs,
                                        const real32_T  a0inv,
                                        const int_T     sampsPerChan,
                                        const int_T     numChans);

void MWDSP_BQ6_DF2T_1fpf_1sos_RC(const real32_T  *u,
                                        creal32_T       *y,
                                        creal32_T       *state,
                                        const creal32_T *coeffs,
                                        const creal32_T  a0inv,
                                        const int_T      sampsPerChan,
                                        const int_T      numChans);

void MWDSP_BQ6_DF2T_1fpf_1sos_CR(const creal32_T *u,
                                        creal32_T       *y,
                                        creal32_T       *state,
                                        const real32_T  *coeffs,
                                        const real32_T   a0inv,
                                        const int_T      sampsPerChan,
                                        const int_T      numChans);

void MWDSP_BQ6_DF2T_1fpf_1sos_CC(const creal32_T *u,
                                        creal32_T       *y,
                                        creal32_T       *state,
                                        const creal32_T *coeffs,
                                        const creal32_T  a0inv,
                                        const int_T      sampsPerChan,
                                        const int_T      numChans);
                                        
                                        
/* Run time functions to support 'fft' function. */                                        
void MWDSP_FFTInterleave_BR_D(
    creal_T      *y,
    const real_T *u,
    const int_T   nChans,
    const int_T   nRows
    );
    
void MWDSP_DblSig_Z(
    creal_T    *y,
    int_T       nChans,
    const int_T nRows
    );
    
void MWDSP_R2DIT_TRIG_Z(
    creal_T    *y,
    int_T       nChans,
    const int_T nRows,
    const int_T fftLen,
    const int_T isInverse
    );
void MWDSP_DblLen_TRIG_Z(
    creal_T    *y,
    const int_T nRows
    );
void MWDSP_R2BR_Z_OOP(
    creal_T       *y,
    const creal_T *x,
    int_T          nChans,
    const int_T    nRows,
    const int_T    fftLen
    );
    
void MWDSP_R2BR_C_OOP(
    creal32_T       *y,
    const creal32_T *x,
    int_T            nChans,
    const int_T      nRows,
    const int_T      fftLen
    );
    
void MWDSP_R2DIT_TRIG_C(
    creal32_T    *y,
    int_T         nChans,
    const int_T   nRows,
    const int_T   fftLen,
    const int_T   isInverse
    );
    
void MWDSP_FFTInterleave_BR_R(
    creal32_T      *y,
    const real32_T *u,
    const int_T     nChans,
    const int_T     nRows
    );
                      
void MWDSP_DblSig_C(
    creal32_T  *y,
    int_T       nChans,
    const int_T nRows
    );
void MWDSP_DblLen_TRIG_C(
    creal32_T    *y,
    const int_T   nRows
    );
 
/* Run-time functions needed to support IFFT funciton. */    
void MWDSP_Ifft_AddCSSignals_D_Zbr_Oop(
    creal_T *y,
    const real_T *u,
    const int_T   nChans,
    const int_T   nRows
    );
    
void MWDSP_Ifft_Deinterleave_D_D_Inp(
    real_T *array,
    const int_T nChansby2,
    const int_T Ntimes2,
    real_T *tmp
    );

void MWDSP_Ifft_DblLen_TRIG_D_Zbr_Oop(
    creal_T       *y,
    const real_T  *x,
    const int_T    fftLen
    );

void MWDSP_ScaleData_DD(
    real_T      *realData,
    int_T        cnt,
    const real_T scaleFactor
    );
    
void MWDSP_R2BR_DZ_OOP(
    creal_T       *y,
    const  real_T *x,
    int_T          nChans,
    const int_T    nRows,
    const int_T    fftLen
    );
    
void MWDSP_ScaleData_DZ(
    creal_T     *cplxData,
    int_T        cnt,
    const real_T scaleFactor
    );
    
void MWDSP_Ifft_AddCSSignals_Z_Zbr(
    creal_T *y,
    const creal_T *u,
    const int_T   nChans,
    const int_T   nRows
    );

void MWDSP_Ifft_DblLen_TRIG_Z_Zbr_Oop(
    creal_T       *y,
    const creal_T *x,
    const int_T    fftLen
    );
    
void MWDSP_R2BR_C_OOP(
    creal32_T       *y,
    const creal32_T *x,
    int_T            nChans,
    const int_T      nRows,
    const int_T      fftLen
    );
    
void MWDSP_ScaleData_RC(
    creal32_T     *cplxData,
    int_T          cnt,
    const real32_T scaleFactor
    );
    
void MWDSP_ScaleData_RR(
    real32_T      *realData,
    int_T          cnt,
    const real32_T scaleFactor
    );
    
void MWDSP_R2BR_RC_OOP(
    creal32_T       *y,
    const  real32_T *x,
    int_T            nChans,
    const int_T      nRows,
    const int_T      fftLen
    );
    
    

int_T MWDSP_SVD_Z
(
                   creal_T	*x,
                   int_T	n,
                   int_T	p,
                   creal_T	*s,
                   creal_T	*e,
                   creal_T	*work,
                   creal_T	*u,
                   creal_T	*v,
                   int_T	wantv
);


int_T MWDSP_SVD_C
(
                   creal32_T	*x,
                   int_T	n,
                   int_T	p,
                   creal32_T	*s,
                   creal32_T	*e,
                   creal32_T	*work,
                   creal32_T	*u,
                   creal32_T	*v,
                   int_T	wantv
);


int_T MWDSP_SVD_D
(
                   real_T	*x,
                   int_T	n,
                   int_T	p,
                   real_T	*s,
                   real_T	*e,
                   real_T	*work,
                   real_T	*u,
                   real_T	*v,
                   int_T	wantv
);

int_T MWDSP_SVD_R
(
                   real32_T	*x,
                   int_T	 n,
                   int_T	 p,
                   real32_T	*s,
                   real32_T	*e,
                   real32_T	*work,
                   real32_T	*u,
                   real32_T	*v,
                   int_T	 wantv
);
