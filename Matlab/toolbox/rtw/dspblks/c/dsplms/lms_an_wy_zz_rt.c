/**********************/  
/* 
 * lms_an_wy_zz_rt.c - Signal Processing Blockset LMS adaptive filter run-time function 
 * 
 * Specifications: 
 * 
 * - Complex (double precision) Input Signal
 * - Complex (double precision) Desired Signal
 * - All outputs complex (double precision)
 * - Adapt input port - NO
 * - Weight output port - YES
 * 
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.1.6.1 $Date: 2003/12/06 15:57:04 $ 
 */  
#include "dsp_rt.h" 
#include "dsplms_rt.h" 


EXPORT_FCN   void MWDSP_lms_an_wy_ZZ(   const creal_T *inSigU, 
                                const creal_T *deSigU, 
                                const real_T   muU,
                                uint32_T      *buffStartIdx, 
                                creal_T       *inBuff, 
                                creal_T       *wgtBuff,
                                const int_T    FilterLength, 
                                const real_T   LkgFactor, 
                                const int_T    FrmLen, 
                                const int_T    bytesPerInpElmt,
                                creal_T       *outY,
                                creal_T       *errY,
                                creal_T       *wgtY)
{

int_T i,j;
creal_T *initWgtICptr = wgtBuff;

memset(outY,0,bytesPerInpElmt*FrmLen);


for (i=0; i<FrmLen; i++) 
{
       wgtBuff = initWgtICptr ;
 /* Step-1: Copy the current sample at the END of the circular buffer and update BuffStartIdx */  
       *(inBuff+ (*buffStartIdx)) = *(inSigU + i);
       if (++(*buffStartIdx) == (uint32_T)FilterLength) *buffStartIdx=0;

 /* Step-2: multiply wgtBuff_vector (not yet updated) and inBuff_vector */  
       for (j=buffStartIdx[0]; j < FilterLength; j++) 
       {  /* note: wgtBuff's starting point is 0 and inBuff's starting point is BuffStartIdx */  
          outY->re += (wgtBuff->re)*((inBuff + j)->re) - (wgtBuff->im)*((inBuff + j)->im);
          outY->im += (wgtBuff->re)*((inBuff + j)->im) + (wgtBuff->im)*((inBuff + j)->re);wgtBuff++;
       }  
       for (j=0; j < (int_T)buffStartIdx[0]; j++) 
       {  /* note: wgtBuff's starting point is 0 and inBuff's starting point is BuffStartIdx */  
          outY->re += (wgtBuff->re)*((inBuff + j)->re) - (wgtBuff->im)*((inBuff + j)->im);
          outY->im += (wgtBuff->re)*((inBuff + j)->im) + (wgtBuff->im)*((inBuff + j)->re);wgtBuff++;          
       }

  /* Step-3: get error for the current sample */  
       errY->re = deSigU->re - outY->re;
       errY->im = (deSigU++)->im - (outY++)->im;  /* errY++ not here */  

  /* Step-4:Update wgtIC for next input sample */  
       wgtBuff = initWgtICptr;
       for (j=buffStartIdx[0]; j < FilterLength; j++) 
       {  /* note: wgtBuff's starting point is 0 and inBuff's starting point is BuffStartIdx */   
          wgtBuff->re = ( (errY->re)*((inBuff + j)->re) + (errY->im)*((inBuff + j)->im))*muU + LkgFactor*(wgtBuff->re);
          wgtBuff->im = (-(errY->re)*((inBuff + j)->im) + (errY->im)*((inBuff + j)->re))*muU + LkgFactor*(wgtBuff->im);wgtBuff++;
          
       } 
       for (j=0; j < (int_T)buffStartIdx[0]; j++) 
       {  /* note: wgtBuff's starting point is 0 and inBuff's starting point is BuffStartIdx */  
          wgtBuff->re = ( (errY->re)*((inBuff + j)->re) + (errY->im)*((inBuff + j)->im))*muU + LkgFactor*(wgtBuff->re);
          wgtBuff->im = (-(errY->re)*((inBuff + j)->im) + (errY->im)*((inBuff + j)->re))*muU + LkgFactor*(wgtBuff->im);wgtBuff++;
          
       }
       errY++;
}
/* flip wgtBuff to get wgtY */
for (j=0; j < FilterLength; j++)    *(wgtY++) = *(--wgtBuff);
}

/* [EOF] lms_an_wy_zz_rt.c */   

