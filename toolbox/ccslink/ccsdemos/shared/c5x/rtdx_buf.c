/*************************************************************************
* $RCSfile: rtdx_buf.c,v $
*
* Declares buffers used by RTDX buffer manager.
*************************************************************************/
#include <RTDX_access.h>        /* RTDX_CODE, RTDX_DATA                 */

#ifndef BUFRSZ
#define BUFRSZ 600
#endif

#if RTDX_USE_DATA_SECTION
#pragma DATA_SECTION(RTDX_Buffer,".rtdx_data")
#pragma DATA_SECTION(RTDX_Buffer_Start,".rtdx_data")
#pragma DATA_SECTION(RTDX_Buffer_End,".rtdx_data")
#endif

/* Must align buffer on 32bit boundary for RTDX DMA requirements.		*/
#pragma DATA_ALIGN(RTDX_Buffer,2)
long RTDX_DATA RTDX_Buffer[BUFRSZ];

/*
 * The buffer used by RTDX is defined by 2 symbols: RTDX_Buffer_Start
 * and RTDX_Buffer_End.  We use the following declarations in order to
 * export these names
*/

const void RTDX_DATA *RTDX_Buffer_Start = &RTDX_Buffer[0];
const void RTDX_DATA *RTDX_Buffer_End  = &RTDX_Buffer[BUFRSZ-1];

/* (eof) rtdx_buf.c */