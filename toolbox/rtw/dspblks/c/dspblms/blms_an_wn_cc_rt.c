/**********************/  
/* 
 * blms_an_wn_cc_rt.c - Signal Processing Blockset Block LMS adaptive filter run-time function 
 * 
 * Specifications: 
 * 
 * - Complex (single precision) Input Signal
 * - Complex (single precision) Desired Signal
 * - All outputs complex (single precision)
 * - Adapt input port - NO
 * - Weight output port - NO
 * 
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.1.6.1 $  $Date: 2003/12/06 15:53:20 $ 
 */  
#include "dsp_rt.h" 
#include "dspblms_rt.h" 

 
EXPORT_FCN   void MWDSP_blms_an_wn_CC(   const creal32_T *inSigU, 
                                const creal32_T *deSigU, 
                                const real32_T   muU,
                                creal32_T       *inBuff, 
                                creal32_T       *wgtBuff,
                                const int_T    FilterLength, 
                                const int_T    BlockLength, 
                                const real32_T   LkgFactor, 
                                const int_T    FrmLen, 
                                creal32_T       *outY,
                                creal32_T       *errY)

{
int_T i,j,k,m=0;
const int_T FiltLen_minus_1 = FilterLength-1;
const int_T NumberOfFrame   = (int_T)(FrmLen/BlockLength + 0.5); /* To avoid precision problem */  
const int_T bytesPerFiltLen = FilterLength*sizeof(creal32_T);
const int_T bytesPerBlkLen  = BlockLength*sizeof(creal32_T);

memset(outY,0,sizeof(creal32_T)*FrmLen);

for (i=0; i<NumberOfFrame; i++) 
{
  /* Step-1: Copy new BlockLength samples at the END of the linear buffer (has length = FilterLength+BlockLength */  
       memmove(inBuff, (inBuff + BlockLength), bytesPerFiltLen);
       memcpy((inBuff + FilterLength), inSigU + i*BlockLength, bytesPerBlkLen);
           
  /* Step-2: convolve inBuff_vector (length= FilterLength+BlockLength) and wgtIC_vector(length=FilterLength) (not yet updated) and */   
  /* resultantLen = FilterLength+BlockLength + FilterLength - 1, but we need only FilterLength+1:(FilterLength+BlockLength) */ 
       for (j=0; j <BlockLength; j++)        
       {
         int_T j_plus_1 = j+1;
         for (k=0; k < FilterLength; k++)        
         {
            outY[m].re += CMULT_RE(wgtBuff[FiltLen_minus_1-k],inBuff[k+j_plus_1]);
            outY[m].im += CMULT_IM(wgtBuff[FiltLen_minus_1-k],inBuff[k+j_plus_1]);
         }
          /* Step-3: get error for the current sample in the block */
         errY[m].re = deSigU[m].re - outY[m].re;  
         errY[m].im = deSigU[m].im - outY[m].im; 
         m++;
       }

  /* Step-4: correlate inBuff_vector (length= FilterLength+BlockLength) and errY_vector(length=BlockLength) and  */ 
  /* resultantLen = FilterLength+BlockLength + FilterLength - 1, but we need only BlockLength+1:(FilterLength+BlockLength) */ 
       m=i*BlockLength;
       for (j=0; j <FilterLength; j++)        
       {
         creal32_T tmpSum = {0,0};
         int_T j_plus_1 = j+1;
         int_T FiltLen_minus_1_minus_j = FiltLen_minus_1-j;

         for (k=0; k < BlockLength; k++)        
         {
            tmpSum.re += muU * CMULT_YCONJ_RE(errY[m+k], inBuff[k+j_plus_1]);
            tmpSum.im += muU * CMULT_YCONJ_IM(errY[m+k], inBuff[k+j_plus_1]);
         }
         wgtBuff[FiltLen_minus_1_minus_j].re = tmpSum.re + LkgFactor*(wgtBuff[FiltLen_minus_1_minus_j].re);
         wgtBuff[FiltLen_minus_1_minus_j].im = tmpSum.im + LkgFactor*(wgtBuff[FiltLen_minus_1_minus_j].im);
       }
   m=(i+1)*BlockLength;
}
}
/* [EOF] blms_an_wn_cc_rt.c */   

