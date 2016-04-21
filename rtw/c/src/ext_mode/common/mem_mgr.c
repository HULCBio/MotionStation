/*
 * Copyright 1994-2002 The MathWorks, Inc.
 *
 * File: mem_mgr.c     $Revision: 1.1.6.1 $
 *
 * Abstract:
 */

#include <assert.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

#include "tmwtypes.h"

#include "ext_types.h"
#include "ext_share.h"

#include "mem_mgr.h"

PRIVATE char MemoryBuffer[EXTMODE_STATIC_SIZE];

PRIVATE MemBufHdr *FreeQueue = NULL;
PRIVATE MemBufHdr InUseQueue = {NULL, NULL, NULL, 0};

#ifdef VERBOSE
uint32_T numBytesAllocated = 0;
#endif

PRIVATE void insertMemBufRight(MemBufHdr *buf, MemBufHdr *queue)
{
    assert(queue != NULL);
    assert(buf != NULL);

    buf->memBufPrev = queue;
    buf->memBufNext = queue->memBufNext;

    if (buf->memBufNext != NULL) {
	buf->memBufNext->memBufPrev = buf;
    }

    queue->memBufNext = buf;
}

PRIVATE void removeMemBuf(MemBufHdr *buf)
{
    MemBufHdr *rightMemBuf;
    MemBufHdr *leftMemBuf;

    assert(buf != NULL);

    rightMemBuf = buf->memBufNext;
    leftMemBuf  = buf->memBufPrev;

    if (rightMemBuf != NULL) {
	rightMemBuf->memBufPrev = leftMemBuf;
    }
    if (leftMemBuf != NULL) {
	leftMemBuf->memBufNext = rightMemBuf;
    }

    buf->memBufNext = NULL;
    buf->memBufPrev = NULL;
}

PRIVATE bool moveRight(MemBufHdr *buf)
{
    MemBufHdr *buf2;

    assert(buf != NULL);

    if (buf->memBufNext == NULL) {
	return false;
    } else {
	buf2 = buf->memBufNext;
	removeMemBuf(buf);
	insertMemBufRight(buf,buf2);
    }
    return true;    
}

PRIVATE bool sortRight(MemBufHdr *buf)
{
    assert(buf != NULL);

    if ((buf->memBufNext != NULL) && (buf > buf->memBufNext)) {
	return moveRight(buf);
    }
    return false;
}

PRIVATE bool sortLeft(MemBufHdr *buf)
{
    assert(buf != NULL);

    if ((buf->memBufPrev != NULL) && (buf < buf->memBufPrev)) {
	return moveRight(buf->memBufPrev);
    }
    return false;
}

PRIVATE bool mergeWithMemBufOnRight(MemBufHdr *buf)
{
    assert(buf != NULL);

    /*
     * If this memory buffer is adjacent to a free memory buffer to its right,
     * merge the two memory buffers into one contiguous free memory buffer.
     */
    if (buf->memBufNext != NULL) {
	MemBufHdr *leftMemBuf   = buf;
	MemBufHdr *rightMemBuf  = buf->memBufNext;
	
	/* Assumes data portion of mem buf is contiguous with mem buf header. */
	char *pointer1 = ((char *)leftMemBuf + sizeof(MemBufHdr) + leftMemBuf->size);
	char *pointer2 = (char *)leftMemBuf->memBufNext;

	if (pointer1 == pointer2)
        {
            removeMemBuf(rightMemBuf);
            leftMemBuf->size += rightMemBuf->size + sizeof(MemBufHdr);
            return true;
        }
    }
    return false;
}

PRIVATE bool mergeMemBuf(MemBufHdr *buf)
{
    bool statusRight = false;
    bool statusLeft  = false;

    assert(buf != NULL);

    statusRight = mergeWithMemBufOnRight(buf);

    if (buf->memBufPrev != NULL) {
        statusLeft = mergeWithMemBufOnRight(buf->memBufPrev);
    }

    return (statusRight | statusLeft);
}

PRIVATE MemBufHdr *inUseQueueFindMemBufHdr(void *mem)
{
    MemBufHdr *LocalBuf;

    assert(mem != NULL);

    LocalBuf = &InUseQueue;

    if (LocalBuf->MemBuf == mem) return LocalBuf;

    while (LocalBuf->memBufNext != NULL) {
	LocalBuf = LocalBuf->memBufNext;
        if (LocalBuf->MemBuf == mem) return LocalBuf;
    }

    return NULL;
}

PRIVATE void inUseQueueInsert(MemBufHdr *buf)
{
    MemBufHdr *LocalBuf;

    assert(buf != NULL);

    LocalBuf = &InUseQueue;
    while (LocalBuf->memBufNext != NULL) {
	LocalBuf = LocalBuf->memBufNext;
	continue;
    }
    insertMemBufRight(buf, LocalBuf);
}

PRIVATE void sortQueue(MemBufHdr *buf)
{
    int count = 1;

    assert(buf != NULL);

    /* Bi-directional bubble sort...
     *
     * Whatever packet given, move it left until the packet to the
     * left belongs there, or there is no packet to the left.
     *
     * If there is a packet to the left, move it to the left as
     * above. 
     *
     * If there is no packet to the left, reverse direction moving
     * packets to the right.
     *
     * Repeat this until no packets are moved.
     */

    /* While something moves... */
    while (count > 0) {
	count = 0;

	/* Bubble left. */
	while (1) {
	    /* Move the current packet as far left as it will go. */
	    if (sortLeft(buf)) {
		count++;
		continue;
	    } else {
		/* Try to merge the packet with its neighbor to the right. */
		mergeMemBuf(buf);

		/* Move the MemBufHdr to the left, if possible, and
		 * continue bubbling left.
		 */ 
		if (buf->memBufPrev != NULL) {
		    buf = buf->memBufPrev;
		    continue;
		} else {
		    break;
		}
	    }
	}

	/* All done bubbling to the left. Now bubble to the right. */

	/* Bubble right. */
	while (1) {
	    /* Move the current packet as far right as it will go. */
	    if (sortRight(buf)) {
		count++;
		continue;
	    } else {
		/* Try to merge the packet with its neighbor to the right. */
		mergeMemBuf(buf);

		/* Move the MemBufHdr to the right, if possible, and
		 * continue bubbling right.
		 */ 
		if (buf->memBufNext != NULL) {
		    buf = buf->memBufNext;
		    continue;
		} else {
		    break;
		}
	    }
	}
    }
}

PRIVATE void initFreeQueue(void)
{
    MemBufHdr *initialFreeMemBuf = NULL;

#ifdef VERBOSE
    /* There is always at least one header allocated from the buffer. */
    numBytesAllocated = sizeof(MemBufHdr);
#endif

    /* The FreeQueue is a pointer to a "free" buffer. */
    FreeQueue = (MemBufHdr *)MemoryBuffer;

    /*
     * The first free packet describes blocks of free space in the free queue
     * buffer (initially the whole buffer) and, as space becomes fragmented, is
     * linked to other "free" buffers.
     */
    initialFreeMemBuf = FreeQueue;

    /*
     * The location and size of the initial free buffer describes the whole
     * memory buffer.
     */
    initialFreeMemBuf->MemBuf = (char *)initialFreeMemBuf + sizeof(MemBufHdr);
    initialFreeMemBuf->size   = sizeof(MemoryBuffer) - sizeof(MemBufHdr);

    /*
     * When there is only one, contiguous memory buffer, the initial free
     * buffer is linked to no other free buffers. When there are more than
     * one, or discontiguous free buffers, these links tie together all free
     * buffers.
     */
    initialFreeMemBuf->memBufPrev = NULL;
    initialFreeMemBuf->memBufNext = NULL;
}

PRIVATE MemBufHdr *findFirstFreeMemBuf(const int bufSize)
{
    /* Get the first free packet. */
    MemBufHdr *buf = FreeQueue;

    /*
     * Loop until we find a free packet big enough for our request or we
     * run out of free packets.
     */
    while (buf != NULL) {
        /* Take the first free packet that fits. */
        if (buf->size >= bufSize) {
            /* Got it. Break out to continue. */
            break;
        }
        /* Get the next free packet. */
        buf = buf->memBufNext;
    }

    return buf;
}

PUBLIC void ExtModeFree(void *mem)
{
    MemBufHdr *buf = NULL;

    if (mem == NULL) return;

    /* Find the header associated with the memory pointer. */
    buf = inUseQueueFindMemBufHdr(mem);
    assert(buf != NULL);

#ifdef VERBOSE
    numBytesAllocated -= (buf->size + sizeof(MemBufHdr));
    printf("\nBytes allocated: %d out of %d.\n", numBytesAllocated, EXTMODE_STATIC_SIZE);
#endif

    /* Remove the buffer from the linked list. */
    removeMemBuf(buf);

    /* Put the buffer back in the free queue. */
    insertMemBufRight(buf, FreeQueue);
    mergeMemBuf(buf);
}

PUBLIC void *ExtModeCalloc(uint32_T number, uint32_T size)
{
    uint32_T numBytes = number*size;
    void     *mem     = ExtModeMalloc(numBytes);

    if (mem == NULL) goto EXIT_POINT;

    memset(mem, 0, numBytes);

  EXIT_POINT:
    return mem;
}

PUBLIC void *ExtModeMalloc(uint32_T size)
{
    bool keepTrying = false;

    MemBufHdr *LocalMemBuf; /* Requested buffer (NULL if none available). */
    MemBufHdr *FreeMemBuf;  /* First free buffer big enough for request. */

    /*
     * Must allocate enough space for the requested number of bytes plus the
     * size of the memory buffer header.
     */
    int sizeToAlloc = size + sizeof(MemBufHdr);

    while (!keepTrying) {
        keepTrying = true;

        LocalMemBuf = NULL;
        FreeMemBuf  = NULL;

        /* Initialize the free queue. */
        if (FreeQueue == NULL) initFreeQueue();

        /* Find first free packet big enough for our request. */
        FreeMemBuf = findFirstFreeMemBuf(sizeToAlloc);

        if (FreeMemBuf == NULL) {
            /* We couldn't find a free buffer.  Run garbage collection to merge
               free buffers together and try again. */
            sortQueue(FreeQueue);

            FreeMemBuf = findFirstFreeMemBuf(sizeToAlloc);
        }

        /* No free buffers are available which satisfy the request. */
        if (FreeMemBuf == NULL) goto EXIT_POINT;

        /*
         * Found a free buffer with enough space.  Carve out the exact buffer size
         * needed from the end of the free buffer.
         */
        LocalMemBuf = (MemBufHdr *)(FreeMemBuf->MemBuf +
                                    FreeMemBuf->size -
                                    sizeToAlloc);

        /*
         * The pointer to the free memory must be longword aligned.  If it
         * is not, adjust the size to allocate and try again.
         */
        {
            int alignBytes = (int)LocalMemBuf % 4;
            if (alignBytes) {
                sizeToAlloc += (4-alignBytes);
                keepTrying = false;
            }
        }
    }

    /* Set up the new packet's info. */
    LocalMemBuf->memBufPrev = NULL;
    LocalMemBuf->memBufNext = NULL;
    LocalMemBuf->MemBuf     = (char *)LocalMemBuf + sizeof(MemBufHdr);
    LocalMemBuf->size       = size;

    /* Insert the newly created buffer into the InUseQueue. */
    inUseQueueInsert(LocalMemBuf);

    /* Update the free packet's size to reflect giving up a piece. */
    FreeMemBuf->size -= sizeToAlloc;

  EXIT_POINT:
    if (LocalMemBuf) {
#ifdef VERBOSE
        numBytesAllocated += sizeToAlloc;
        printf("\nBytes allocated: %d out of %d.\n", numBytesAllocated, EXTMODE_STATIC_SIZE);
#endif
        return LocalMemBuf->MemBuf;
    }

#ifdef VERBOSE
    printf("\nBytes allocated: %d out of %d.", numBytesAllocated+sizeToAlloc, EXTMODE_STATIC_SIZE);
    printf("\nMust increase size of static allocation!\n");
#endif
    return NULL;
}
