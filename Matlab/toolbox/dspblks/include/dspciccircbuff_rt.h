/*
 * Header file DSPCICCIRCBUFF_RT.H
 *
 * Efficient ANSI-C macros for CIC Filter Circular Buffer (FIFO) handling
 *
 * Copyright 1995-2004 The MathWorks, Inc.
 * $Revision: 1.1.6.4 $ $Date: 2004/04/12 23:11:43 $
 *
 * NOTE: This module is presently optimized for a SAMPLE BASED circular buffer.
 *
 *       The code is designed for use on ***embedded processor hardware***
 *       and there is no checking code to slow it down.  Use carefully!!!
 *
 * Typical use case:
 *
 * 1) Before use, client must allocate the necessary memory
 *    for the circular buffer HEADER and DATA.  Then the client
 *    must initialize the circular buffer header settings.
 *
 *    NOTE: memory in a "MWDSP_CIC_CircBuff" is arranged as follows:
 *
 *        typedef struct {
 *            MWDSP_CIC_CircBuffHeader header;
 *            void *data;
 *        } MWDSP_CIC_CircBuff;
 *
 *        (See code below for MWDSP_CIC_CircBuffHeader typedef)
 *
 *    malloc may be used for the header and data memory allocations.
 *
 *    MWDSP_CICCIRCBUFF_INIT_HEADER provides an encapsulated way
 *    to initialize the header structure AFTER ITS MEMORY IS ALREADY ALLOCATED.
 *    This could instead be done manually by the client if that is desireable.
 *
 *    After the circbuff is allocated and reset it is ready for use!
 *
 *    [See below for a usage example.]
 *
 *
 *    NOTE: If the algorithm is speed critical, memory for a MWDSP_CIC_CircBuff
 *          should reside in the fastest physical memory available on the target.
 *
 *
 * 2) The following operations may be performed after it has been initialized:
 *
 *    MWDSP_CICCIRCBUFF_ZEROIZE       - Sets all bytes of data values to 0.
 *
 *    MWDSP_CICCIRCBUFF_SET_INIT_VALS - Sets all data values to a scalar value.
 *
 *    MWDSP_CICCIRCBUFF_READ_VAL  - Reads present (OLDEST) scalar data value (via ptr)
 *
 *    MWDSP_CICCIRCBUFF_WRITE_VAL - Writes scalar data value into circbuff
 *                                  (by OVERWRITING OLDEST) via pointer.
 *                                  Automatically updates circbuff indices
 *                                  (for future read / write operations).
 *
 *    MWDSP_CICCIRCBUFF_INC_IDX   - Increments internal indices by an integer value
 *                                  (for future read / write operations)
 *
 *    MWDSP_CICCIRCBUFF_DEC_IDX   - Decrements internal indices by an integer value
 *                                  (for future read / write operations)
 *
 *    MWDSP_CICCIRCBUFF_GETOLDCHNKPTR - Get pointer to oldest raw data in buffer (void *)
 *    MWDSP_CICCIRCBUFF_GETOLDCHNKSIZ - Get size of chunk of oldest buffer data  (size_t)
 *
 *    MWDSP_CICCIRCBUFF_GETNEWCHNKPTR - Get pointer to newest raw data in buffer (void *)
 *    MWDSP_CICCIRCBUFF_GETNEWCHNKSIZ - Get size of chunk of newest buffer data  (size_t)
 *
 *
 * EXAMPLES:
 *
 * A) Client allocates memory for a circbuff to contain sixteen 32-bit integers,
 *    and initializes the circbuff header information:
 *
 *    MWDSP_CIC_CircBuff *circBuffPtr = (MWDSP_CIC_CircBuff *)malloc(sizeof(MWDSP_CIC_CircBuff));
 *    if (circBuffPtr == 0) throw_error();
 *    circBuffPtr->data = malloc(16 * sizeof(int32_T));
 *    if (circBuffPtr->data == 0) throw_error();
 *    MWDSP_CICCIRCBUFF_INIT_HEADER(circBuffPtr, sizeof(int32_T), 16)
 *
 *
 * B) Client sets all array values to 0:
 *
 *    MWDSP_CICCIRCBUFF_ZEROIZE(circBuffPtr)
 *
 *
 * C) Client sets all array values to a scalar (e.g. non-zero) value:
 *
 *    MWDSP_CICCIRCBUFF_SET_INIT_VALS(circBuffPtr, scalarValPtr)
 *
 *
 * D) Client writes a scalar value into the circbuff
 *
 *    MWDSP_CICCIRCBUFF_WRITE_VAL(circBuffPtr, scalarValPtr);
 *
 *    [NOTE: increment of circbuff indices happens AUTOMATICALLY
 *           in the MWDSP_CICCIRCBUFF_WRITE_VAL macro upon return, so that
 *           future reads will read oldest value in circbuff first.]
 *
 *
 * E) Client reads a scalar value from the circbuff
 *    and increments the index for future reads:
 *
 *    MWDSP_CICCIRCBUFF_READ_VAL(circBuffPtr, scalarValPtr)
 *    MWDSP_CICCIRCBUFF_INC_IDX( circBuffPtr, 1);
 *
 *    [NOTE: increment of circbuff indices does NOT happen
 *           in the MWDSP_CICCIRCBUFF_READ_VAL macro.]
 *
 *
 * F) Client writes frame of 16 linear buffer values into (size >= 16) circbuff:
 *
 *    {
 *        const int    linBufferSize     = 16 * sizePerElement;
 *        const void * cbOldChunkDataPtr = MWDSP_CICCIRCBUFF_GETOLDCHNKPTR(circBuffPtr);
 *        const int    oldChunkDataSize  = MWDSP_CICCIRCBUFF_GETOLDCHNKSIZ(circBuffPtr);
 *
 *        if (oldChunkDataSize >= linBufferSize) {
 *            memcpy(cbOldChunkDataPtr, linArrayPtr, linBufferSize);
 *        } else {
 *            const void * cbNewChunkDataPtr = MWDSP_CICCIRCBUFF_GETNEWCHNKPTR(circBuffPtr);
 *            const int    newChunkDataSize  = MWDSP_CICCIRCBUFF_GETNEWCHNKSIZ(circBuffPtr);
 *            memcpy(cbOldChunkDataPtr, linArrayPtr, oldChunkDataSize);
 *            if (newChunkDataSize >= (linBufferSize - oldChunkDataSize)) {
 *                const int remainingNumElems = 16 - (oldChunkDataSize / sizePerElement);
 *                memcpy(cbNewChunkDataPtr, (linArrayPtr + oldChunkNumElems), (linBufferSize - oldChunkDataSize));
 *            }
 *        }
 *
 *        MWDSP_CICCIRCBUFF_INC_IDX(circBuffPtr, 16);
 *    }
 *
 *
 * G) Client reads frame of 16 circbuff values into a (size >= 16) linear array:
 *
 *    {
 *        const int    memSizeToCopy     = 16 * sizePerElement;
 *        const void * cbOldChunkDataPtr = MWDSP_CICCIRCBUFF_GETOLDCHNKPTR(circBuffPtr);
 *        const size_t oldChunkDataSize  = MWDSP_CICCIRCBUFF_GETOLDCHNKSIZ(circBuffPtr);
 *
 *        if (oldChunkDataSize >= memSizeToCopy) {
 *            memcpy(linArrayPtr, cbOldChunkDataPtr, memSizeToCopy);
 *        } else {
 *            const void * cbNewChunkDataPtr = MWDSP_CICCIRCBUFF_GETNEWCHNKPTR(circBuffPtr);
 *            memcpy(linArrayPtr, cbOldChunkDataPtr, oldChunkDataSize);
 *            memcpy( ( (unsigned char *)linArrayPtr + memSizeToCopy - oldChunkDataSize ),
 *                    cbNewChunkDataPtr,
 *                    memSizeToCopy - oldChunkDataSize
 *                  );
 *        }
 *
 *        MWDSP_CICCIRCBUFF_INC_IDX(circBuffPtr, 16);
 *    }
 *
 */

#ifndef _DSPCICIRCBUFF_RT_
#define _DSPCICIRCBUFF_RT_

#include "rtwtypes.h" /* for int_T and int32_T defs only */
#include <string.h>   /* for "memset" library fcn only   */

/* ---------------------------
 * CIRCULAR BUFFER DEFINITIONS
 * ---------------------------
 */

typedef struct {
    int numElements;
    int sizePerElem;
    int currentIndex;
} MWDSP_CIC_CircBuffHeader;


typedef struct {
    MWDSP_CIC_CircBuffHeader header;
    void *data;
} MWDSP_CIC_CircBuff;

/* If *EITHER* of the typedefs above change, update the next line!!! */
#define NUM_INT32_PER_CICCIRCBUFF 4

#define NUM_INT_T_PER_CICCIRCBUFF (sizeof(MWDSP_CIC_CircBuff) / sizeof(int_T  ))

/* ------------------------------
 * CIRCULAR BUFFER INITIALIZATION
 * ------------------------------
 */

#define MWDSP_CICCIRCBUFF_INIT_HEADER(CIRCBUFF_HEADER_PTR, SIZE_PER_ELEMENT, NUM_ELEMENTS) \
    ((MWDSP_CIC_CircBuffHeader *)(CIRCBUFF_HEADER_PTR))->numElements  = (NUM_ELEMENTS); \
    ((MWDSP_CIC_CircBuffHeader *)(CIRCBUFF_HEADER_PTR))->sizePerElem  = (SIZE_PER_ELEMENT); \
    ((MWDSP_CIC_CircBuffHeader *)(CIRCBUFF_HEADER_PTR))->currentIndex = 0

/*
 * MWDSP_CICCIRCBUFF_ZEROIZE does not work for types
 * whos "zero" value is not equal to all bytes "0"
 * (i.e. "non-zero bias" fixpt types NOT supported)
 */
#define MWDSP_CICCIRCBUFF_ZEROIZE(CIRCBUFF_PTR) \
    memset( ((CIRCBUFF_PTR)->data), 0, \
            (((CIRCBUFF_PTR)->header.numElements) * ((CIRCBUFF_PTR)->header.sizePerElem)) )


/*
 * Note that temp stack variables "numElements" and "sizePerElem"
 * are used only to reduce number of indirect memory reads on the target
 */
#define MWDSP_CICCIRCBUFF_SET_INIT_VALS(CIRCBUFF_PTR, SCALAR_PTR) \
    { \
        int        numElements  = (CIRCBUFF_PTR)->header.numElements; \
        const int  sizePerElem  = (CIRCBUFF_PTR)->header.sizePerElem; \
        void      *cbRawDataPtr = (CIRCBUFF_PTR)->data; \
        while (numElements--)  { \
            memcpy(cbRawDataPtr, (SCALAR_PTR), sizePerElem ); \
            cbRawDataPtr = ((unsigned char *)cbRawDataPtr + sizePerElem); \
        } \
    }

/* ---------------------------------
 * CIRCULAR BUFFER MEMORY MANAGEMENT
 * ---------------------------------
 */

/* Operations for pointer to and number of bytes in
 * OLDEST linear data memory "chunk" residing in circbuff
 */
#define MWDSP_CICCIRCBUFF_GETOLDCHNKPTR(CIRCBUFF_PTR) \
    (void *)(((const unsigned char *)((CIRCBUFF_PTR)->data) + (((CIRCBUFF_PTR)->header.currentIndex) * ((CIRCBUFF_PTR)->header.sizePerElem)))


#define MWDSP_CICCIRCBUFF_GETOLDCHNKSIZ(CIRCBUFF_PTR) \
    (((CIRCBUFF_PTR)->header.currentIndex) == 0) ? ( ( (CIRCBUFF_PTR)->header.numElements                                       ) * ( (CIRCBUFF_PTR)->header.sizePerElem ) ) \
                                                 : ( ( (CIRCBUFF_PTR)->header.numElements - (CIRCBUFF_PTR)->header.currentIndex ) * ( (CIRCBUFF_PTR)->header.sizePerElem ) )

/* Operations for pointer to and number of bytes in
 * NEWEST linear data memory "chunk" residing in circbuff
 */
#define MWDSP_CICCIRCBUFF_GETNEWCHNKPTR(CIRCBUFF_PTR) \
    ((CIRCBUFF_PTR)->data)


#define MWDSP_CICCIRCBUFF_GETNEWCHNKSIZ(CIRCBUFF_PTR) \
    ( ((CIRCBUFF_PTR)->header.currentIndex) * ((CIRCBUFF_PTR)->header.sizePerElem) )

/* ----------------------------------
 * CIRCBUFF INDEX INCREMENT/DECREMENT
 * ----------------------------------
 */

/* MWDSP_CICCIRCBUFF_INC_IDX - Increment index
 *
 * UINT_VAL must be a positive integer value.
 * UINT_VAL must be less than the maximum number of elements in the circbuff.
 *
 * Note that temp stack variables "newIndexVal" and "numElements"
 * are used to minimize number of indirect memory reads.
 */
#define MWDSP_CICCIRCBUFF_INC_IDX(CIRCBUFF_PTR, UINT_VAL) \
    { \
        const int numElements = (CIRCBUFF_PTR)->header.numElements; \
        int       newIndexVal = (CIRCBUFF_PTR)->header.currentIndex + (UINT_VAL); \
        if (newIndexVal >= numElements) newIndexVal -= numElements; \
        ((CIRCBUFF_PTR)->header.currentIndex) = newIndexVal; \
    }


/* MWDSP_CICCIRCBUFF_DEC_IDX - Decrement index
 *
 * UINT_VAL must be a positive integer value.
 * UINT_VAL must be less than the maximum number of elements in the circbuff.
 */
#define MWDSP_CICCIRCBUFF_DEC_IDX(CIRCBUFF_PTR, UINT_VAL) \
    { \
        int newIndexVal = ((CIRCBUFF_PTR)->header.currentIndex) - (UINT_VAL); \
        if (newIndexVal < 0) newIndexVal += ((CIRCBUFF_PTR)->header.numElements); \
        ((CIRCBUFF_PTR)->header.currentIndex) = newIndexVal; \
    }

/* --------------------------------
 * CIRCBUFF DATA VALUE READ / WRITE
 * --------------------------------
 */

/* MWDSP_CICCIRCBUFF_READ_VAL
 *
 * Since index always "points" at the OLDEST value,
 * read value in buffer at present index location
 * and copy to VALUE_PTR location.
 */
#define MWDSP_CICCIRCBUFF_READ_VAL(CIRCBUFF_PTR, VALUE_PTR) \
    memcpy( (VALUE_PTR), \
            ( (const unsigned char *)((CIRCBUFF_PTR)->data) + ( ((CIRCBUFF_PTR)->header.currentIndex) * ((CIRCBUFF_PTR)->header.sizePerElem) ) ), \
            (CIRCBUFF_PTR)->header.sizePerElem )


/* MWDSP_CICCIRCBUFF_WRITE_VAL
 *
 * Overwrite oldest value (the one at current index)
 * and increment index to "point" at next oldest value.
 */
#define MWDSP_CICCIRCBUFF_WRITE_VAL(CIRCBUFF_PTR, VALUE_PTR) \
    memcpy( ( (unsigned char *)((CIRCBUFF_PTR)->data) + (((CIRCBUFF_PTR)->header.currentIndex) * ((CIRCBUFF_PTR)->header.sizePerElem) ) ), \
            (VALUE_PTR), \
            (CIRCBUFF_PTR)->header.sizePerElem ); \
    MWDSP_CICCIRCBUFF_INC_IDX(CIRCBUFF_PTR, 1)


#endif /* _DSPCICIRCBUFF_RT_ */

/* [EOF] */
