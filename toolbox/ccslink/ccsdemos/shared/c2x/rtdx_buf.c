#include <RTDX_access.h>

/* Set the RTDX buffer size to 600 */
#ifndef BUFRSIZE
#define BUFRSIZE 600
#endif

#if RTDX_USE_DATA_SECTION
#pragma DATA_SECTION(RTDX_Buffer,".rtdx_data")
#pragma DATA_SECTION(RTDX_Buffer_Start,".rtdx_data")
#pragma DATA_SECTION(RTDX_Buffer_End,".rtdx_data")
#endif

/* Must align buffer on 32bit boundary for RTDX DMA requirements.		*/
// #pragma DATA_ALIGN(RTDX_Buffer,2)

int RTDX_DATA RTDX_Buffer[BUFRSIZE];
const void RTDX_DATA *RTDX_Buffer_Start = &RTDX_Buffer[0];
const void RTDX_DATA *RTDX_Buffer_End   = &RTDX_Buffer[BUFRSIZE-1];
