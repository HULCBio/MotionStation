/*
 * Copyright 1996-2003 The MathWorks, Inc.
 * $Revision: 1.1.6.3 $ $Date: 2004/04/12 23:03:46 $
 */
#ifndef __BUFF_H__
#define __BUFF_H__
/*---------------------------------------------------------------------------
 *
 * buff.h - Buffer management
 *
 * Create and manage a circular buffer.
 *
 *---------------------------------------------------------------------------*/

#include "comm_defs.h"
#include <stdlib.h>

#undef DEBUG_BUFFER

typedef struct {
    int_T inWidth;      /* Buffer input width */
    int_T outWidth;     /* Buffer output width */

    int_T dataAvail;    /* Data available in the buffer*/

    void *buffPtr;      /* Pointer to the data */
    int_T dataSize;     /* Size of a single piece of data */
    int_T intBuffLen;   /* Length of the internal buffer */

    int_T idxTop;
    int_T idxBottom;


} buff_T;

buff_T *createBuffer(SimStruct *S,
                     const int_T inWidth,
                     const int_T outWidth,
                     const int_T size,
                     const int_T numIC,
                     const void* icPtr);

void    freeBuffer(buff_T *buff);

char   *writeBuffer(buff_T *buff, const void* inData, const int_T count);

char   *readBuffer(buff_T *buff, void* outData, const int_T count);

#endif
