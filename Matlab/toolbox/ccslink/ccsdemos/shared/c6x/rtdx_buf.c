/* $Revision: 1.1.6.1 $ */
#include <RTDX_access.h>

/* Set the RTDX buffer size to 600 */
#ifndef BUFFERSIZE
#define BUFFERSIZE 600
#endif

#if RTDX_USE_DATA_SECTION
#pragma DATA_SECTION(RTDX_Buffer,".rtdx_data")
#pragma DATA_SECTION(RTDX_Buffer_Start,".rtdx_data")
#pragma DATA_SECTION(RTDX_Buffer_End,".rtdx_data")
#endif

int RTDX_DATA RTDX_Buffer[BUFFERSIZE];

const void RTDX_DATA *RTDX_Buffer_Start = &RTDX_Buffer[0];
const void RTDX_DATA *RTDX_Buffer_End  = &RTDX_Buffer[BUFFERSIZE-1];

/* (eof) rtdx_buf.c */