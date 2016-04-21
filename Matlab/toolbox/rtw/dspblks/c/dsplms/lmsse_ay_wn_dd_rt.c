/**********************/  
/* 
 * lmsse_ay_wn_dd_rt.c - Signal Processing Blockset Sign-Error LMS adaptive filter run-time function 
 * 
 * Specifications: 
 * 
 * - Non-complex (double precision) Input Signal
 * - Non-complex (double precision) Desired Signal
 * - All outputs non-complex (double precision)
 * - Adapt input port - YES
 * - Weight output port - NO
 * 
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.1.6.1 $Date: 2003/12/06 15:57:53 $ 
 */  
#include "dsp_rt.h"
#include "dsplms_rt.h" 

EXPORT_FCN   void MWDSP_lmsse_ay_wn_DD(   const real_T *inSigU, 
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
                                const boolean_T  NeedAdapt)
{

int_T i,j;
real_T *initWgtICptr = wgtBuff;

memset(outY,0,bytesPerInpElmt*FrmLen);


for (i=0; i<FrmLen; i++) 
{
       wgtBuff = initWgtICptr;
  /* Step-1: Copy the current sample at the END of the circular buffer and update BuffStartIdx */  
       *(inBuff+ (*buffStartIdx)) = *(inSigU + i);
       if (++(*buffStartIdx) == (uint32_T)FilterLength) *buffStartIdx=0;
           
  /* Step-2: multiply wgtIC_vector (not yet updated) and inBuff_vector */
       /* note: wgtBuff's starting point is 0 and inBuff's starting point is BuffStartIdx */  
       for (j=buffStartIdx[0]; j < FilterLength; j++ )   {*outY += *wgtBuff * *(inBuff + j); wgtBuff++;}
       for (j=0; j <(int_T) buffStartIdx[0]; j++)        {*outY += *wgtBuff * *(inBuff + j); wgtBuff++;}

  /* Step-3: get error for the current sample */  
       *errY = *deSigU++ - *outY++; 

  /* Step-4:Update wgtIC for next input sample */  
       if (NeedAdapt)
       {
           wgtBuff = initWgtICptr;
           for (j=buffStartIdx[0]; j < FilterLength; j++) 
           { /* sign(error)=-1/0/1 */ 
               if (*errY == 0)
               {
                  *wgtBuff = LkgFactor* (*wgtBuff);wgtBuff++;              
               } 
               else if (*errY > 0)
               {
                  *wgtBuff =   (*(inBuff + j))*muU + LkgFactor* (*wgtBuff);wgtBuff++;
               }
               else /* if (*errY < 0) */ 
               {
                  *wgtBuff =  -(*(inBuff + j))*muU + LkgFactor* (*wgtBuff);wgtBuff++;
               }
           }
           for (j=0; j < (int_T)buffStartIdx[0]; j++) 
           { 
               if (*errY == 0)
               {
                  *wgtBuff = LkgFactor* (*wgtBuff);wgtBuff++;              
               } 
               else if (*errY > 0)
               {
                  *wgtBuff =   (*(inBuff + j))*muU + LkgFactor* (*wgtBuff);wgtBuff++;
               }
               else /* if (*errY < 0) */ 
               {
                  *wgtBuff =  -(*(inBuff + j))*muU + LkgFactor* (*wgtBuff);wgtBuff++;
               }
           }
       }
       errY++;  
}
}

/* [EOF] lmsse_ay_wn_dd_rt.c */   



