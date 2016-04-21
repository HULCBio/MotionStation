/*
 * Copyright 1994-2003 The MathWorks, Inc.
 *
 * File: ext_serial_utils.c     $Revision: 1.1.6.4 $
 *
 * Absract:
 *  External mode shared data structures and functions used by the external
 *  communication, mex link, and generated code.  This file is for definitions
 *  related to custom external mode implementations (e.g., tcpip, serial).
 *  See ext_share.h for definitions common to all implementations of external
 *  mode (ext_share.h should NOT be modified).
 */

/***************** TRANSPORT-DEPENDENT DEFS AND INCLUDES **********************/

#include <stdlib.h>
#include <string.h>

#include "tmwtypes.h"
#include "ext_share.h"
#include "simstruc_types.h"
#include "ext_svr.h"
#include "ext_serial_port.h"
#include "ext_serial_pkt.h"

/*
 * Buffers used for storing incoming and outgoing packets.
 */
PRIVATE ExtSerialPacket buffer1st;
PRIVATE ExtSerialPacket buffer2nd;
PRIVATE ExtSerialPacket *InBuffer  = &buffer1st;
PRIVATE ExtSerialPacket *OutBuffer = &buffer2nd;

/*
 * If waitForAck is true, a packet can not be sent until the other side sends
 * an ack indicating there is space to store the unsent packet.
 */
PRIVATE boolean_T waitForAck = false;

/*
 * NOTE:  When adding or removing a valid baud rate, both the baudRates and
 *        baudRatesStr variables must be modified!
 */
PRIVATE uint32_T baudRates[] = {
    1200, 2400, 4800, 9600, 14400, 19200, 38400, 56000, 57600, 115200 };
PRIVATE const char_T *baudRatesStr =
"baud rate must be one of the following:\n"
"\t1200, 2400, 4800, 9600, 14400,\n"
"\t19200, 38400, 56000, 57600, 115200\n";

/*
 * The maximum number of bytes a serial packet may contain.  Serial pkts
 * larger than the maximum size will be broken up into multiple pkts
 * (each equal to or less than the max size) for transmission.
 */
#define MAX_SERIAL_PKT_SIZE 1024

/*
 * The maximum number of (maximum sized) packets that can be stored at
 * any one time.
 */
#define NUM_FIFO_BUFFERS 5

typedef struct FIFOBuffer_tag {
    char                  pktBuf[MAX_SERIAL_PKT_SIZE];
    uint32_T              size;
    uint32_T              offset;
    struct FIFOBuffer_tag *next;
} FIFOBuffer;

PRIVATE FIFOBuffer *FreeFIFOHead = NULL;
PRIVATE FIFOBuffer *FreeFIFOTail = NULL;
PRIVATE FIFOBuffer *PktFIFOHead  = NULL;
PRIVATE FIFOBuffer *PktFIFOTail  = NULL;

PRIVATE bool isFIFOEmpty(FIFOBuffer *head, FIFOBuffer *tail)
{
    if ((head == NULL) && (tail == NULL))
        return true;

    return false;
}

PRIVATE void InsertFIFO(FIFOBuffer **head, FIFOBuffer **tail, FIFOBuffer *buf)
{
    if (isFIFOEmpty(*head, *tail)) {
        *head = *tail = buf;
        buf->next = NULL;
    } else {
        assert(*head != NULL);
        assert(*tail != NULL);

        (*tail)->next = buf;
        *tail = buf;
        buf->next = NULL;
    }
}

PRIVATE FIFOBuffer *RemoveFIFO(FIFOBuffer **head, FIFOBuffer **tail)
{
    FIFOBuffer *buf = NULL;

    if (isFIFOEmpty(*head, *tail)) {
        return NULL;
    } else {
        assert(*head != NULL);
        assert(*tail != NULL);

        buf = *head;
        *head = buf->next;
        if (*head == NULL) *tail = NULL;
        buf->next = NULL;
    }

    return buf;
}

PRIVATE bool isFIFOFreeEmpty(void)
{
    return isFIFOEmpty(FreeFIFOHead, FreeFIFOTail);
}

PRIVATE bool isFIFOPktEmpty(void)
{
    return isFIFOEmpty(PktFIFOHead, PktFIFOTail);
}

PRIVATE void InsertFIFOFree(FIFOBuffer *buf)
{
    InsertFIFO(&FreeFIFOHead, &FreeFIFOTail, buf);
}

PRIVATE FIFOBuffer *RemoveFIFOFree(void)
{
    return RemoveFIFO(&FreeFIFOHead, &FreeFIFOTail);
}

PRIVATE void InsertFIFOPkt(FIFOBuffer *buf)
{
    InsertFIFO(&PktFIFOHead, &PktFIFOTail, buf);
}

PRIVATE FIFOBuffer *RemoveFIFOPkt(void)
{
    return RemoveFIFO(&PktFIFOHead, &PktFIFOTail);
}

PRIVATE FIFOBuffer *GetFIFOPkt(void)
{
    return PktFIFOHead;
}

PRIVATE boolean_T AddToFIFOFree(void)
{
    int       i;
    boolean_T error = EXT_NO_ERROR;

    for (i=0 ; i<NUM_FIFO_BUFFERS ; i++) {
        FIFOBuffer *buf = calloc(1, sizeof(FIFOBuffer));
        if (buf == NULL) {
            error = EXT_ERROR;
            goto EXIT_POINT;
        }
        InsertFIFOFree(buf);
    }
  EXIT_POINT:
    return(error);
}

PRIVATE void SavePkt(char *mem, int size)
{
    FIFOBuffer *buf = RemoveFIFOFree();

    /* The ack protocol ensures there is available space to save the pkt. */
    assert(buf);

    /* The max transmission size ensures we never exceed memory when copying. */
    assert(size<=MAX_SERIAL_PKT_SIZE);

    memcpy(buf->pktBuf,mem,size);
    buf->size   = size;
    buf->offset = 0;

    InsertFIFOPkt(buf);
}


/***************** PRIVATE FUNCTIONS ******************************************/

/* Forward declaration */
PRIVATE boolean_T ExtSetPkt(ExtSerialPort*, char*, int, int*, PacketTypeEnum);

/* Function: ExtGetPktBlocking =================================================
 * Abstract:
 *  Blocks until a packet is available on the comm line.  If the incoming packet
 *  is an ACK, the packet is processed and thrown away.  Otherwise, the packet
 *  is saved.
 *
 *  EXT_NO_ERROR is returned on success, EXT_ERROR on failure.
 */
PRIVATE boolean_T ExtGetPktBlocking(ExtSerialPort *portDev)
{
    boolean_T error = EXT_NO_ERROR;

    /* Block until a packet is available from the comm line. */
    error = GetExtSerialPacket(InBuffer, portDev);
    if (error != EXT_NO_ERROR) goto EXIT_POINT;

    /* Process ACK packets, don't pass on to application. */
    if (InBuffer->PacketType == ACK_PACKET) {
        waitForAck = false;
        goto EXIT_POINT;
    }

    SavePkt(InBuffer->Buffer, InBuffer->size);

    if (!isFIFOFreeEmpty()) {
        int bytesWritten;

        error = ExtSetPkt(portDev, NULL, 0, &bytesWritten, ACK_PACKET);
        if (error != EXT_NO_ERROR) goto EXIT_POINT;
    }

  EXIT_POINT:
    return error;

} /* end ExtGetPktBlocking */


/* Function: ExtSetPkt =========================================================
 * Abstract:
 *  Sets (sends) the specified number of bytes on the comm line.  As long as an
 *  error does not occur, this function is guaranteed to set the requested
 *  number of bytes.  The number of bytes set is returned via the 'nBytesSet'
 *  parameter.  If a previously sent packet has not yet received an ACK, then we
 *  block for the next packet which must be an ACK.
 *
 *  EXT_NO_ERROR is returned on success, EXT_ERROR on failure.
 */
PRIVATE boolean_T ExtSetPkt(ExtSerialPort *portDev,
                            char *pktData,
                            int pktSize,
                            int *bytesWritten,
                            PacketTypeEnum pktType)
{
    int       bytesToSend;
    int       deadlockCntr;
    boolean_T error = EXT_NO_ERROR;

    bytesToSend = (pktSize > MAX_SERIAL_PKT_SIZE) ?
        MAX_SERIAL_PKT_SIZE : pktSize;
    *bytesWritten = bytesToSend;

    /*
     * Wait for an ACK packet if needed. Every packet sent must be ACKed before
     * another can be sent (the only exceptions are ACK packets which are never
     * ACKed).
     */
    deadlockCntr = 0;
    while (waitForAck && (pktType != ACK_PACKET)) {
        uint32_T numPending = 0;

        error = ExtSerialPortDataPending(portDev, &numPending);
        if (error != EXT_NO_ERROR) goto EXIT_POINT;

        if (numPending) {
            error = ExtGetPktBlocking(portDev);
            if (error != EXT_NO_ERROR) goto EXIT_POINT;
        }

        /*
         * If we are in this loop, it means we are trying to send a pkt but
         * have not received an ACK from the other side.  If we don't get an
         * ACK after some amount of time, we may be in a deadlock condition
         * where both sides are waiting for an ACK.  In this case, allocating
         * some more free packets will break the deadlock condition.
         */
        if ((++deadlockCntr == 200) && isFIFOFreeEmpty()) {
            int temp;

            deadlockCntr = 0;
            error = AddToFIFOFree();
            if (error != EXT_NO_ERROR) goto EXIT_POINT;

            error = ExtSetPkt(portDev, NULL, 0, &temp, ACK_PACKET);
            if (error != EXT_NO_ERROR) goto EXIT_POINT;
        }
    }

    /*
     * Write the packet to the outgoing buffer. The output buffer is
     * guaranteed to be big enough to hold the maximum size packet.
     */
    OutBuffer->size = (uint32_T)bytesToSend;
    OutBuffer->PacketType = (char)pktType;
    memcpy(OutBuffer->Buffer,pktData,(uint32_T)bytesToSend);

    /* Send the packet over the comm line. */
    error = SetExtSerialPacket(OutBuffer,portDev);
    if (error != EXT_NO_ERROR) goto EXIT_POINT;

  EXIT_POINT:
    return error;

} /* end ExtSetPkt */


/* Function: ExtSetPktWithACK ==================================================
 * Abstract:
 *  Sets (sends) the specified number of bytes on the comm line and waits for a
 *  return packet.  As long as an error does not occur, this function is
 *  guaranteed to set the requested number of bytes.  The number of bytes set is
 *  returned via the 'nBytesSet' parameter.
 *
 *  If the return packet is an ACK, the ACK is processed and thrown away.  If
 *  the return packet is something other than an ACK, the packet is saved and
 *  processed and a global flag is set to indicate we are still waiting for an
 *  ACK packet.  A typical scenario where the return packet is not an ACK is
 *  when both the host and target send a packet to each other simultaneously.
 *
 *  EXT_NO_ERROR is returned on success, EXT_ERROR on failure.
 */
PRIVATE boolean_T ExtSetPktWithACK(ExtSerialPort *portDev,
                                   char *pktData,
                                   int pktSize,
                                   PacketTypeEnum pktType)
{
    int       bytesWritten      = 0;
    int       totalBytesWritten = 0;
    boolean_T error             = EXT_NO_ERROR;

    while (totalBytesWritten < pktSize) {
        /* Send the packet. */
        error = ExtSetPkt(portDev, pktData+totalBytesWritten,
                          pktSize-totalBytesWritten, &bytesWritten, pktType);
        if (error != EXT_NO_ERROR) goto EXIT_POINT;

        totalBytesWritten += bytesWritten;

        /* We must get an ACK back. */
        waitForAck = true;
    }

  EXIT_POINT:
    return error;

} /* end ExtSetPktWithACK */


/* Function: ExtGetPkt =========================================================
 * Abstract:
 *  Attempts to get the specified number of bytes from the comm line.  The
 *  number of bytes read is returned via the 'nBytesGot' parameter.
 *
 *  EXT_NO_ERROR is returned on success, EXT_ERROR on failure.
 *
 * NOTES:
 *  o it is not an error for 'nBytesGot' to be returned as 0
 *  o this function blocks if no data is available
 */
PRIVATE boolean_T ExtGetPkt(ExtSerialPort *portDev,
                            char *dst,
                            int nBytesToGet,
                            int *returnBytesGot)
{
    FIFOBuffer *buf;
    int        UnusedBytes;
    boolean_T  error = EXT_NO_ERROR;

    buf = GetFIFOPkt();
    while (buf == NULL) {
        error = ExtGetPktBlocking(portDev);
        if (error != EXT_NO_ERROR) goto EXIT_POINT;

        buf = GetFIFOPkt();
    }

    UnusedBytes = buf->size - buf->offset;
    /* Test packet size. */
    if (nBytesToGet >= UnusedBytes) {
	*returnBytesGot = UnusedBytes;
    } else {
	*returnBytesGot = nBytesToGet;
    }

    /* Save packet using char* for proper math. */
    {
	char *tempPtr = buf->pktBuf;
	tempPtr += buf->offset;
	(void)memcpy(dst, tempPtr, *returnBytesGot);
    }

    /* Determine if the packet can be discarded. */
    buf->offset += *returnBytesGot;

    if (buf->offset == buf->size) {
        int  bytesWritten;
        bool isEmpty = isFIFOFreeEmpty();

        buf->size   = 0;
        buf->offset = 0;

        InsertFIFOFree(RemoveFIFOPkt());

        if (isEmpty) {
            error = ExtSetPkt(portDev, NULL, 0, &bytesWritten, ACK_PACKET);
            if (error != EXT_NO_ERROR) goto EXIT_POINT;
        }
    }

  EXIT_POINT:
    return error;

} /* end ExtGetPkt */


/* Function: ExtPktPending =====================================================
 * Abstract:
 *  Returns true, via the 'pending' arg, if data is pending on the comm line.
 *  Returns false otherwise.  If data is pending, the packet is read from the
 *  comm line.  If that packet is an ACK packet, false is returned.  If the
 *  packet is an extmode packet, it is saved and true is returned.
 *
 *  EXT_NO_ERROR is returned on success, EXT_ERROR on failure.
 */
PRIVATE boolean_T ExtPktPending(ExtSerialPort *portDev,
                                boolean_T *pending)
{
    boolean_T error = EXT_NO_ERROR;

    *pending = false;

    if (isFIFOPktEmpty()) {
        /*
         * Is there a pkt already waiting?  If so, return true for pending pkt.
         * Otherwise, try to grab a pkt from the comm line (if one exists).
         */
        uint32_T numPending = 0;

        error = ExtSerialPortDataPending(portDev, &numPending);
        if (error != EXT_NO_ERROR) goto EXIT_POINT;

        if (numPending) {
            error = ExtGetPktBlocking(portDev);
            if (error != EXT_NO_ERROR) goto EXIT_POINT;

            /*
             * Only if the pkt is saved in the fifo do we return a pkt is
             * pending.  If the acquired pkt was an ACK, it would have been
             * thrown away.
             */
            if (!isFIFOPktEmpty()) *pending = true;
        }
    } else {
        *pending = true;
    }

  EXIT_POINT:
    return error;

} /* end ExtPktPending */


/* Function: ExtClearSerialConnection ==========================================
 * Abstract:
 *  Clear the connection by setting certain global variables to their initial
 *  states.  The difference between ExtResetSerialConnection() and
 *  ExtClearSerialConnection() is that the reset function frees all allocated
 *  memory and nulls out all pointers.  The clear function only initializes
 *  some global variables without freeing any memory.  When the connection is
 *  being opened or closed, use the reset function.  If the host and target
 *  are only disconnecting, use the clear function.
 */
PRIVATE void ExtClearSerialConnection(void)
{
    waitForAck = false;

} /* end ExtClearSerialConnection */


/* Function: ExtResetSerialConnection ==========================================
 * Abstract:
 *  Reset the connection with the target by initializing some global variables
 *  and freeing/nulling all allocated memory.
 */
PRIVATE void ExtResetSerialConnection(void)
{
    while (!isFIFOFreeEmpty()) {
        free(RemoveFIFOFree());
    }

    while (!isFIFOPktEmpty()) {
        free(RemoveFIFOPkt());
    }

    free(InBuffer->Buffer);
    memset(InBuffer, 0, sizeof(ExtSerialPacket));

    free(OutBuffer->Buffer);
    memset(OutBuffer, 0, sizeof(ExtSerialPacket));

    PktFIFOHead  = PktFIFOTail  = NULL;
    FreeFIFOHead = FreeFIFOTail = NULL;

    ExtClearSerialConnection();

} /* end ExtResetSerialConnection */


/* Function: ExtOpenSerialConnection ===========================================
 * Abstract:
 *  Open the connection with the target.
 */
PRIVATE ExtSerialPort *ExtOpenSerialConnection(uint16_T port, uint32_T baud)
{
    ExtSerialPort *portDev = NULL;
    uint32_T      maxSize  = MAX_SERIAL_PKT_SIZE*2;
    boolean_T     error    = EXT_NO_ERROR;

    portDev = ExtSerialPortCreate();
    if (portDev == NULL) goto EXIT_POINT;

    ExtResetSerialConnection();

    /*
     * Allocate the buffers for sending and receiving packets big enough to
     * hold the maximum size packet possible for transmission.
     */
    OutBuffer->Buffer = (char *)malloc(maxSize);
    if (OutBuffer->Buffer == NULL) {
        error = EXT_ERROR;
        goto EXIT_POINT;
    }
    OutBuffer->BufferSize = maxSize;

    InBuffer->Buffer = (char *)malloc(maxSize);
    if (InBuffer->Buffer == NULL) {
        error = EXT_ERROR;
        goto EXIT_POINT;
    }
    InBuffer->BufferSize = maxSize;

    error = AddToFIFOFree();
    if (error != EXT_NO_ERROR) goto EXIT_POINT;

    error = ExtSerialPortConnect(portDev, port, baud);
    if (error != EXT_NO_ERROR) goto EXIT_POINT;

  EXIT_POINT:
    if (error != EXT_NO_ERROR) portDev = NULL;
    return portDev;

} /* end ExtOpenSerialConnection */


/* Function: ExtCloseSerialConnection ==========================================
 * Abstract:
 *  Close the connection with the target.
 */
PRIVATE boolean_T ExtCloseSerialConnection(ExtSerialPort *portDev)
{
    ExtResetSerialConnection();

    return(ExtSerialPortDisconnect(portDev));

} /* end ExtCloseSerialConnection */


/* [EOF] ext_serial_utils.c */
