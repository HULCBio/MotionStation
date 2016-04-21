
/*-------------------------------------------------------------------*
 * FIR.C - Target Source code for a FIR filter
 *   Implements a simple FIR filter that uses signed integers (16-bit)
 *   for both data and coefficients.
 *
 * Unintialized data (must be filled in before execution!)
 *  int16 din[];        - input data of storage (data to be filtered)
 *  int32 nbuf          - number of valid elements stored in din[] (and dout)
 *  int16 coeff[];      - FIR filter coefficients
 *  int32 ncoeff;       - number of valid elements stored in coeff[]
 *------------------------------------------------------------------*/
/* Copyright 2001-2003 The MathWorks, Inc.
 * $Revision: 1.1.4.1 $ $Date: 2003/11/30 23:04:38 $ */

#include <stdio.h> 
#include <stdlib.h> 
#include "fir_filter.h"


#ifdef DEBUG
#define  dbg_puts(STR)  puts(STR)
#else
#define  dbg_puts(STR)  
#endif 




/*----------- fir_filter ---------------------------------------*
 *  Implementation of FIR filter
 *  By default, this subroutine uses a "C" implementation
 *  of the FIR filter.  However, it is possible to substitute
 *  the default code for the FIR filter routine 'fir-gen' supplied
 *  in the optimized DSP Library created by Texas Instruments.
 *  
 *--------------------------------------------------------------*/
void fir_filter(int16 *din, int16 *coeff, int16 *dout, int32 ncoeff, int32 nbuf )
{ 
  /* This is an alternate version of fir_filter program that 
   *  uses the Texas Instruments library file: dsplib.lib
   *  To use this version, include this library in the project,
   *  then substitute this code for the C version of the filter.
   *  the library version is an optimized Assembly language library
   *  routine that should run much faster
   * fir_filter syntax:
   *  void fir_filter (short *x, short *h, short *r, int nh, int nr)  
   *  x = input array
   *  h = coefficient array
   *  r = output array
   *  nh = number of coefficients (nh >= 5)
   *  nr = number of output samples (nr >= 1) 
   */
   /*
   if (nbuf < 1) { 
     errorcondition = DIN_OVER;
     printf("Illegal buffer size\n");
   }
   if (ncoeff < 5) {
     errorcondition = COEFF_OVER;
     printf("Illegal buffer size\n");
   }
   fir_filter(din,coeff,dout,ncoeff,nbuf); 
  */
   	
   int32 i, j, sum;
   for (j = 0; j < nbuf; j++) {
   	 sum = 0;
     for (i = 0; i < ncoeff; i++) {
       sum = sum + ((int32)din[i + j] * coeff[i]); 
       dout[j] = sum >> 15;
     } 
   } 
   return;                                                               
}
