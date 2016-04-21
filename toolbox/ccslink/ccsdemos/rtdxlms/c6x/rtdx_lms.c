/* $Revision: 1.3.4.1 $ */
/* Copyright 2002-2003 The MathWorks, Inc. */
/*-------------------------------------------------------------------*/
/* LMS algorithm to adaptively cancel broadband noise. The error     */
/* at each iteration is the time-series output point of the          */
/* filtered signal (signal + canceled noise)                         */
/*                                                                   */
/* Read from RTDX channels:                                          */
/* Channel Name:    Data:                                            */
/*   ichan0         filtParms                                        */
/*                     filtParms[0] = filter length                  */
/*                     filtParms[1] = frame size                     */
/*                     filtParms[2] = number of frames               */
/*                     filtParms[3] = number of shift bits (scaling) */
/*                                                                   */
/*   ichan0         x (filter input)                                 */
/*   ichan1         y (desired filter output)                        */
/*                                                                   */
/* Write to RTDX channels:                                           */
/* Channel Name:    Data:                                            */
/*   ochan0         hPrime (coefficient updates)                     */
/*                  error  (desired - estimated filter output)       */
/*                                                                   */
/*-------------------------------------------------------------------*/

#include <rtdx.h>	/* RTDX_Read		  */
#include "target.h"	/* TARGET_INITIALIZE  */
#include <stdio.h>	/* printf			  */		
                               
#define MAXFRAME 1024
#define MAXTAPS  64                      
                               
short filtParms[4];
short m, k, numFrames;
short shiftBits;
short x[MAXFRAME], y[MAXFRAME+MAXTAPS-1], xTaps[MAXTAPS+1];
short hPrime[MAXTAPS], yPrime[MAXFRAME];
short mu = 1;             /* mu = 0.5, LSB = 2^-1                        */
short normFactor;         /* step size, and autocorrelation factor       */
short normError;                    /* iterative error, normalized error           */
short outBuf[MAXFRAME];             /* output buffer for coefficients              */

long  error[MAXFRAME];

RTDX_CreateInputChannel(ichan0);	/* Channel from which to receive filter input  */
RTDX_CreateInputChannel(ichan1);	/* Channel from which to receive filter output */
RTDX_CreateOutputChannel(ochan0);	/* Channel to output coefficient updates       */   
                                    /*    and filtered data                        */                                   
	
	void main( void )
	{
	    int h, i,j,n;
	    int wptr = 0;     /* pointer to current location in write buffer */
	    short outError[MAXFRAME];  /* output buffer for filtered signal */ 
	
	    TARGET_INITIALIZE();			/* Target-specific initialization */
	
	    RTDX_enableInput(&ichan0);		/* Enable channels */
	    RTDX_enableInput(&ichan1);			    
	    RTDX_enableOutput(&ochan0);			
		
	    RTDX_read( &ichan0, filtParms, sizeof(filtParms) );	
		
	    m=filtParms[0];           /* filter length               */
	    k=filtParms[1];           /* filter input framesize      */
	    numFrames=filtParms[2];   /* number of frames to process */
	    shiftBits = filtParms[3]; /* LSB: 2^(-shiftBits)         */
					
	    RTDX_read( &ichan0, x, k*2 );
	    RTDX_read( &ichan1, y, (k+m-1)*2 );
	                                
	    /* initialize tap estimates */
	    for (i=0; i<m; i++) {
	       hPrime[i] = 0;
	       xTaps[i] = 0;
	    }
	                                 	                                
	    for (h=0; h<numFrames; h++)
	    {   
	       for (n=0; n<k; n++) {
	           /* update tap delay line buffer */
	           /* and error                    */
	           error[n] = y[n] << shiftBits;
	           xTaps[m] = x[n];
	           normFactor = 0;

	           /* CANNOT combine next loop with the one after it  */
	           /* because the error sample has to be fully formed */
	           for (i=0; i<m; i++) {
	               xTaps[i] = xTaps[i+1];
	               error[n] -= (hPrime[i] * xTaps[i]);
	               normFactor += (xTaps[i] * xTaps[i]) >> shiftBits + 4;
	   	       }
	   	       outError[n] = error[n] >> shiftBits;
	           yPrime[n] = 0;
	           normError = mu * error[n]/normFactor >> 5;
	           for (j=0; j<m; j++){
	               /* update tap coefficients */
	               hPrime[j] += (normError * xTaps[j]) >> shiftBits;
	               outBuf[wptr++] = hPrime[j];
	               /* compute filter output */
	               yPrime[n] += (hPrime[j] * xTaps[j]) >> shiftBits;
	       	   }
	           if (wptr == k) { /* output buffer full? */
	               wptr = 0;
	               while ( RTDX_writing != NULL ) 
	                   {  /* wait for previous write to complete */ }
	               RTDX_write( &ochan0, outBuf, k*2 );
                   while ( RTDX_writing != NULL ) 
                       { /* wait for write to complete */ }   		           
	               RTDX_write( &ochan0, &outError[n-(k/m)+1], (k/m)*2 );	       	   	
     	       }
		    }
            /* overlap with previous frame */
		    for (i=0; i<m; i++) {
		        y[i] = y[k + i];
		    }
		    if (h<numFrames-1) {
		        RTDX_read( &ichan0, x, k*2 );
	            RTDX_read( &ichan1, &y[m], k*2 ); 
	        }
	   }
	   while ( RTDX_writing != NULL ) 
	       { /* wait for previous write to complete */ }	   	        	
	   RTDX_disableInput(&ichan0);
	   RTDX_disableInput(&ichan1);		
	   RTDX_disableOutput(&ochan0);
	
    }   
