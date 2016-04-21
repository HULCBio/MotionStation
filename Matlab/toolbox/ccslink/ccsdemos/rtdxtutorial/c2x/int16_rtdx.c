/* $Revision: 1.2.6.1 $ */
/* Copyright 2002-2003 The MathWorks, Inc. */
/* RTDX tutorial target application: read from host and echo back */

#include <rtdx.h>						/* RTDX_Data_Read				*/
#include <stdio.h>						/* printf						*/
#include "target.h"						/* TARGET_INITIALIZE			*/
#include "watchdog.h"					/* Disable watchdog				*/

#define MAX 10   

short recvd[MAX];

RTDX_CreateInputChannel(ichan);			/* Channel to receive data from */   
RTDX_CreateOutputChannel(ochan);		/* Channel to use to write data */

void main( void )
{
	int i,j;  

	#if defined(_TMS320C28X)
    Disable_WD();
	#endif
	
	TARGET_INITIALIZE();				/* target specific RTDX init	*/
    
    while ( !RTDX_isInputEnabled(&ichan) ) 
      { RTDX_Poll(); }
	RTDX_read( &ichan, recvd, sizeof(recvd) );	
                  
    for (j=1; j<=20; j++) {
      for (i=0; i<MAX; i++) {
        recvd[i] +=1;
      }
      while ( !RTDX_isOutputEnabled(&ochan) ) 
        { RTDX_Poll();}            	
	  RTDX_write( &ochan, recvd, sizeof(recvd) );
  	  while ( RTDX_writing != NULL ) 
  	    { RTDX_Poll(); }    
	}
		
	while ( RTDX_isInputEnabled(&ichan) || RTDX_isOutputEnabled(&ochan) ) 
	  { RTDX_Poll(); }
    while (1) {}
}                



