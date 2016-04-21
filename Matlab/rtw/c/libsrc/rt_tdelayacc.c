/* File: rt_tdelayacc.c
 * Abstract:
 *   Transport Delay and Variable Transport Delay update support routine
 *   
 *   Shared between Simulink and Real-Time Workshop.
 *
 *   See sl_blks/rt_tdelayacc.c for source.
 *
 * $Revision: 1.1.10.2 $
 * $Date: 2002/09/23 16:13:38 $
 */



#include <stdlib.h> /* size_t */
#include "rtwtypes.h"

extern void   utFree(void*);
extern void * utMalloc(size_t);
  
#ifndef PUBLIC
#define PUBLIC
#endif



/* Function: rt_TDelayUpdateTailOrGrowBuf ======================================
 * Abstract:
 *   The current head has reach the tail of the t, u history circular buffers. 
 *   Therefore, move the tail forward if possible, otherwise grow the circular 
 *   buffer size by 1024 entries.
 *
 *   Returns true on success, false if memory alloc failure.
 */
PUBLIC boolean_T rt_TDelayUpdateTailOrGrowBuf(
    int_T  *bufSzPtr,        /* in/out - circular buffer size                 */
    int_T  *tailPtr,         /* in/out - tail of circular buffer              */
    int_T  *headPtr,         /* in/out - head of circular buffer              */
    int_T  *lastPtr,         /* in/out - same logical 'last' referenced index */
    real_T tMinusDelay,      /* in     - last point we are looking at         */
    real_T **tBufPtr,        /* in/out - larger buffer                        */
    real_T **uBufPtr,        /* in/out - larger buffer                        */
    int    *maxNewBufSzPtr)  /* out    - max buffer size needed for sim       */
{
    int_T  testIdx;
    int_T  tail  = *tailPtr;
    int_T  bufSz = *bufSzPtr;
    real_T *tBuf = *tBufPtr;

    /*    Get testIdx, the index of the second oldest data point and
     *    see if this is older than current sim time minus applied delay,
     *    used to see if we can move tail forward 
     */
    testIdx = (tail < (bufSz - 1)) ? (tail + 1) : 0;

    if (tMinusDelay <= tBuf[testIdx]) {                
        int_T  j;
        real_T *tempT;
        real_T *tempU;

        real_T *uBuf     = *uBufPtr;
        int_T  newBufSz  = bufSz + 1024;

        if (newBufSz > *maxNewBufSzPtr) {
            *maxNewBufSzPtr = newBufSz; /* save for warning*/
        }

        tempU = (real_T*)utMalloc(2*newBufSz*sizeof(tempU[0]));
        if (tempU == NULL) {
            return(false);
        }
        tempT = tempU + newBufSz;
    
        for (j = tail; j < bufSz; j++) {
            tempT[j - tail] = tBuf[j];
            tempU[j - tail] = uBuf[j];
        }
        for (j = 0; j < tail; j++) {
            tempT[j + bufSz - tail] = tBuf[j];
            tempU[j + bufSz - tail] = uBuf[j];
        }

        if (*lastPtr > tail) {
            *lastPtr -= tail;
        } else {
            *lastPtr += (bufSz - tail);
        }
        tail = 0;
        *headPtr = bufSz;
        
        utFree(uBuf);
        
        *bufSzPtr = newBufSz;
        *tBufPtr  = tempT;
        *uBufPtr  = tempU;

    } else {
        *tailPtr = testIdx; /* move tail forward */
    }

    return(true);
} /* end rt_TDelayUpdateTailOrGrowBuf */

/* [eof] rt_tdelayacc.c */
