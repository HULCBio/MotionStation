/**********************/  
/* 
 * lmssd_an_wn_rr_rt.c - Signal Processing Blockset Sign-Data LMS adaptive filter run-time function 
 * 
 * Specifications: 
 * 
 * - Non-complex (single precision) Input Signal
 * - Non-complex (single precision) Desired Signal
 * - All outputs Non-complex (single precision)
 * - Adapt input port - NO
 * - Weight output port - NO
 * 
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.1.6.1 $Date: 2003/12/06 15:57:42 $ 
 */  
#include "dsp_rt.h"
#include "dsplms_rt.h" 

EXPORT_FCN   void MWDSP_lmssd_an_wn_RR(   const real32_T *inSigU, 
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
                                real32_T       *errY)
{

int_T i,j;
real32_T *initWgtICptr = wgtBuff;

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
       wgtBuff = initWgtICptr;
       for (j=buffStartIdx[0]; j < FilterLength; j++) 
       { /* sign(error)=-1/0/1 */ 
          if (*(inBuff + j) == 0) 
           {
              *wgtBuff = LkgFactor* (*wgtBuff);wgtBuff++;              
           } 
           else if (*(inBuff + j) > 0)
           {
              *wgtBuff = (*errY)*muU + LkgFactor* (*wgtBuff);wgtBuff++;
           }
           else /* if (*(inBuff + j) < 0) */ 
           {
             *wgtBuff = -(*errY)*muU + LkgFactor* (*wgtBuff);wgtBuff++;
           }
       }
       for (j=0; j < (int_T)buffStartIdx[0]; j++) 
       { 
          if (*(inBuff + j) == 0) 
           {
              *wgtBuff = LkgFactor* (*wgtBuff);wgtBuff++;              
           } 
           else if (*(inBuff + j) > 0)
           {
              *wgtBuff = (*errY)*muU + LkgFactor* (*wgtBuff);wgtBuff++;
           }
           else /* if (*(inBuff + j) < 0) */ 
           {
             *wgtBuff = -(*errY)*muU + LkgFactor* (*wgtBuff);wgtBuff++;
           }
       }
       errY++;  
}
}

/* [EOF] lmssd_an_wn_rr_rt.c */   



