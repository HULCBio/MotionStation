/* $Revision: 1.5.4.1 $ */
/* Copyright 2002-2003 The MathWorks, Inc. */
/* RTDX tutorial target application: read from host and echo back */

#include <rtdx.h>						/* RTDX_Data_Read				*/
#include <stdio.h>						/* printf						*/
#include "target.h"						/* TARGET_INITIALIZE			*/

#define MAX 10   

short recvd[MAX];

RTDX_CreateInputChannel(ichan);			/* Channel to receive data from */   
RTDX_CreateOutputChannel(ochan);		/* Channel to use to write data */

void main( void )
{
	int i,j;  

	TARGET_INITIALIZE();				/* target specific RTDX init	*/

    while ( !RTDX_isInputEnabled(&ichan) ) 
      {/* wait for channel enable from MATLAB */}
	RTDX_read( &ichan, recvd, sizeof(recvd) );	
    puts("\n\n Read Completed ");
                  
    for (j=1; j<=20; j++) {
      for (i=0; i<MAX; i++) {
        recvd[i] +=1;
      }
      while ( !RTDX_isOutputEnabled(&ochan) ) 
        { /* wait for channel enable from MATLAB */ }            	
	  RTDX_write( &ochan, recvd, sizeof(recvd) );
  	  while ( RTDX_writing != NULL ) 
  	    { /* wait for data xfer INTERRUPT DRIVEN for C6000 */ }    
	}
		
	while ( RTDX_isInputEnabled(&ichan) || RTDX_isOutputEnabled(&ochan) ) 
	  { /* wait for channel disable from MATLAB */ }
	puts("\n\n Test Completed ");
    while (1) {}
}                



