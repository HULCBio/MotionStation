/**********************/  
/* 
 * blms_ay_wy_dd_rt.c - Signal Processing Blockset Block LMS adaptive filter run-time function 
 * 
 * Specifications: 
 * 
 * - Non-complex (double precision) Input Signal
 * - Non-complex (double precision) Desired Signal
 * - All outputs Non-complex (double precision)
 * - Adapt input port - YES
 * - Weight output port - YES
 * 
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.1.6.1 $  $Date: 2003/12/06 15:53:40 $ 
 */  
#include "dsp_rt.h"
#include "dspblms_rt.h" 

EXPORT_FCN   void MWDSP_blms_ay_wy_DD(   const real_T *inSigU, 
                                const real_T *deSigU, 
                                const real_T  muU,
                                real_T       *inBuff, 
                                real_T       *wgtBuff,
                                const int_T   FilterLength,  
                                const int_T   BlockLength, 
                                const real_T  LkgFactor, 
                                const int_T   FrmLen,  
                                real_T       *outY,
                                real_T       *errY,
                                real_T       *wgtY,
                                const boolean_T     NeedAdapt)
{
int_T i,j,k,m=0;
const int_T FiltLen_minus_1 = FilterLength-1;
const int_T NumberOfFrame   = (int_T)(FrmLen/BlockLength + 0.5); /* To avoid precision problem */  
const int_T bytesPerFiltLen = FilterLength*sizeof(real_T);
const int_T bytesPerBlkLen  = BlockLength*sizeof(real_T);

memset(outY,0,sizeof(real_T)*FrmLen);

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
            outY[m] += wgtBuff[FiltLen_minus_1-k] * inBuff[k+j_plus_1];
         }
          /* Step-3: get error for the current sample in the block */
         errY[m] = deSigU[m] - outY[m];  
         m++;
       }

  /* Step-4: correlate inBuff_vector (length= FilterLength+BlockLength) and errY_vector(length=BlockLength) and  */ 
  /* resultantLen = FilterLength+BlockLength + FilterLength - 1, but we need only BlockLength+1:(FilterLength+BlockLength) */ 
  if (NeedAdapt)
  {
       m=i*BlockLength;
       for (j=0; j <FilterLength; j++)        
       {
         real_T tmpSum = 0;
         int_T j_plus_1 = j+1;
         for (k=0; k < BlockLength; k++)        
         {
            tmpSum += muU * errY[m+k] * inBuff[k+j_plus_1];
         }
         wgtBuff[FiltLen_minus_1-j] = tmpSum + LkgFactor*wgtBuff[FiltLen_minus_1-j];
       }
   }
   m=(i+1)*BlockLength;
}

for (j=0; j < FilterLength; j++)   *wgtY++ = *wgtBuff++;

}
/* [EOF] blms_ay_wy_dd_rt.c */   

