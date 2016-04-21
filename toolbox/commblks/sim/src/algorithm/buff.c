/*
 * Copyright 1996-2003 The MathWorks, Inc.
 * $Revision: 1.1.6.3 $ $Date: 2004/04/12 23:03:44 $
 */
 
/*---------------------------------------------------------------------------
 *
 * buff.c - Buffer management
 * 
 * Create and manage a circular buffer.
 *
 * #define DEBUG_BUFFER to enable error messages to be returned from the
 * read and write functions.
 * 
 *---------------------------------------------------------------------------*/

#include "buff.h"

/*---------------------------------------------------------------------------
 * Function: createBuffer
 * Purpose:  Allocate the memory and initialize the pointer for the buffer
 * Pass in:  input width, output width, data element size, number of ic's,
 *           pointer to ic's
 * Pass out: Pointer to the buffer structure (NULL if operation failed)
 *---------------------------------------------------------------------------*/

buff_T *createBuffer(SimStruct *S,
                     const int_T inWidth, 
                     const int_T outWidth, 
                     const int_T size, 
                     const int_T numIC, 
                     const void* icPtr) 
{
    buff_T *buff = (buff_T *)calloc(1,sizeof(buff_T));
    void   *buffPtr;

    const int_T intBuffLen = MAX(inWidth, outWidth) + (MIN(inWidth, outWidth) % MAX(inWidth,outWidth)) + (inWidth - (numIC % inWidth));

    if(buff == NULL){
		return NULL;
	}
    
    buffPtr = (void *)calloc(intBuffLen, size);

    if(buffPtr == NULL) {
        free(buff);
		return(NULL);
    }

    buff->inWidth    = inWidth;
    buff->outWidth   = outWidth;

    buff->dataAvail  = 0;
    buff->intBuffLen = intBuffLen;

    buff->buffPtr    = buffPtr;  
    buff->dataSize   = size; 

    buff->idxTop     = 0;
    buff->idxBottom  = 0;

    if(numIC > 0) {
        writeBuffer(buff, icPtr, numIC);
    }
    return(buff);
}


/*---------------------------------------------------------------------------
 * Function: freeBuffer
 * Purpose:  Free the buffer structure memory and the internal memory
 * Pass in:  pointer to the buffer structure
 * Pass out: void
 *---------------------------------------------------------------------------*/
void freeBuffer(buff_T *buff)
{
    if(NULL != buff->buffPtr) {
		free(buff->buffPtr);
	}
    if(NULL != buff) {
		free(buff);
	}
}

/*---------------------------------------------------------------------------
 * Function: writeBuffer
 * Purpose:  Write count items of dataSize bytes to the buffer. count <= inWidth
 * Pass in:  buff_T pointer, inData, count
 * Pass out: Error message (NULL for no error)
 *---------------------------------------------------------------------------*/
char* writeBuffer(buff_T *buff, const void* inData, const int_T count)
{
    int_T countIdx;

    static char* emsg;
    emsg = NULL;    /* Ensure that the error message is reset */

	for(countIdx=0;countIdx<count;countIdx++) {
        int_T srcIdx, dstIdx;

        srcIdx = buff->dataSize * countIdx;
        dstIdx = buff->dataSize * ((buff->idxTop + countIdx) % buff->intBuffLen);

        memcpy((unsigned char *)buff->buffPtr+dstIdx, (unsigned char *)inData+srcIdx, buff->dataSize);
	}

	/* --- Update index values */
	buff->idxTop     = (buff->idxTop + count) % buff->intBuffLen;
	buff->dataAvail += count;

    return(emsg);
}

/*---------------------------------------------------------------------------
 * Function: readBuffer
 * Purpose:  Read count items of dataSize bytes from the buffer into outData. 
 *           count <= outWidth
 * Pass in:  buff_T pointer, count
 * Pass out: Error message (NULL for no error)
 *---------------------------------------------------------------------------*/
char* readBuffer(buff_T *buff, void* outData, const int_T count)
{
    int_T countIdx;
    static char* emsg;
    emsg = NULL;    /* Ensure that the error message is reset */

	for(countIdx=0;countIdx<count;countIdx++) {
        int_T srcIdx, dstIdx;

        srcIdx = buff->dataSize * ((buff->idxBottom + countIdx) % buff->intBuffLen);
        dstIdx = buff->dataSize * countIdx;

        memcpy((unsigned char *)outData+dstIdx, (unsigned char *)buff->buffPtr+srcIdx, buff->dataSize);

    }

	/* --- Update index values */
	buff->idxBottom  = (buff->idxBottom+count) % buff->intBuffLen;
	buff->dataAvail -= count;

    return(emsg);

}


