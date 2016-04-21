/* $Revision: 1.2 $ */

#include <stdio.h>
#include <stdlib.h> 
#include "tmwtypes.h"

enum etype { 
       NO_ERROR = 0,
	   COEFF_OVER,
	   COEFF_UNDER,
	   BUF_OVER,
	   BUF_UNDER,
       UNKNOWN
	};
         
enum etype errorcondition = NO_ERROR;

/*-- define constants --*/

#define MAX_BUFSIZE    2048   /*-- Upper limit on data buffer --*/
#define MAX_COEFF      64     /*-- Upper limit on number of coeff --*/

/*-- define buffers, leave uninitialized, to be supplied by MATLAB -*/

int16 din[MAX_BUFSIZE];
int16 dout[MAX_BUFSIZE];
                        
int16 coeff[MAX_COEFF];
int16 state[MAX_COEFF+1];

/*-- defines actual size, must be less than limit -*/

int32 ncoeff;
int32 nbuf;

/*----------- fir_filter ---------------------------------------*
 *  Implementation of FIR filter
 *  By default, this subroutine uses a "C" implementation
 *  of the FIR filter.  However, it is possible to substitute
 *  the default code for the FIR filter routine 'fir-gen' supplied
 *  in the optimized DSP Library created by Texas Instruments.
 *  
 *--------------------------------------------------------------*/

void fir_filter( )
{ 
   int32 sum;  
   int16 k, t, p, d;  /* p&d index for state,  k index for kernel coeff, 
                         t index for time histories */  
   if( ncoeff < 1 ) {
     errorcondition= COEFF_UNDER;
     return;
   }
   else if( ncoeff > MAX_COEFF) {
     errorcondition= COEFF_OVER;
     return;
   }
   else if ( nbuf < 1) {
     errorcondition= BUF_UNDER;
     return;
   }    
   else if ( nbuf > MAX_BUFSIZE) {
     errorcondition= BUF_UNDER;
     return;
   } 
            
            
   /* get last p index value from filter state */         
   p=state[ncoeff]; /* last index into state was stored at end of state */
   for (t = 0; t < nbuf; t++) {
   	 sum = 0;
   	 state[p]=din[t];  /* move a new sample into the state vector (delay elements) */
   	                   /* the indexing of p makes this a circular buffer */
   	 d=p;
     for (k = 0; k < ncoeff; k++) {
         sum += (int32)((int32)(coeff[k])*(int32)(state[d++]));
         d    = d % ncoeff;    /* modulo counter for circular buffer */ 
      }
     /* decrement p and check for going negative */
     if (--p < 0){
        p=ncoeff-1;
     }
     dout[t] = sum >> 15;
   }  
   state[ncoeff]=p; /* save last p index for next filter run */
   errorcondition = NO_ERROR;
   
   return;                                                               
}
