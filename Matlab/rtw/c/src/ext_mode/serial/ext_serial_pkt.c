/*
 * Copyright 1994-2003 The MathWorks, Inc.
 *
 * File: ext_serial_pkt.c     $Revision: 1.1.6.4 $
 *
 * Abstract:
 *  The External Mode Serial Packet is a container object for the serial data
 *  to be transitted or received and the serial communication overhead (such as
 *  headers, tailers, etc.).  The external mode code writes data to be
 *  transmitted into an External Mode Serial Packet and lets the packet object
 *  handle all of the details involved in sending the data.  Conversely, data to
 *  be received by the external mode code is stored in an External Mode Serial
 *  Packet that handles all of the details in receiving that data.  In this
 *  way, the External Mode Serial Packet provides a clean interface for sending
 *  and receiving data to a serial port without worrying about the details
 *  involved with transmitting and receiving the data.
 *
 *     ----------------------------------
 *     | Host/Target external mode code |
 *     ----------------------------------
 *         / \                 / \
 *        /| |\               /| |\
 *         | |                 | |
 *         | | Connect         | |   Write
 *         | | Disconnect     \| |/  Read
 *         | | Pending         \ /
 *         | |          -----------------
 *         | |          | External Mode |
 *         | |          | Serial Packet |
 *         | |          -----------------
 *         | |                 / \
 *         | |                /| |\  Send
 *         | |                 | |   Receive
 *         | |                 | | 
 *        \| |/               \| |/
 *         \ /                 \ /
 *     ----------------------------------
 *     | External Mode Serial Port      |
 *     ----------------------------------
 *                   / \
 *                  /| |\
 *                   | |
 *                   | |
 *                  \| |/
 *                   \ /
 *     ----------------------------------
 *     | HW/OS/Physical serial port     |
 *     ----------------------------------
 *
 *  See also ext_serial_<TRANSPORT>_port.c.
 */

#include <stdlib.h>
#include <string.h>

#include "tmwtypes.h"

#include "ext_types.h"
#include "ext_share.h"
#include "ext_serial_port.h"
#include "ext_serial_pkt.h"

/* Function: IsEscapeChar ======================================================
 * Abstract:
 *  Returns true if the char belongs to the escape sequence, false otherwise.
 */
PRIVATE boolean_T IsEscapeChar(char c)
{
    if ((c == packet_head) ||
        (c == packet_tail) ||
        (c == escape_character)) {
	return true;
    }

    return false;

} /* end IsEscapeChar */


/* Function: Filter ============================================================
 * Abstract:
 *  Filter the outgoing message to trasnslate any bytes that conflict with
 *  escape chars.  If a byte does conflict, the byte is replaced with two
 *  bytes:  The first is the escape character and the second is the conflicted
 *  byte exclusive or'd with the mask character.  If a byte does not conflict,
 *  it is unchanged.  Returns the new size of the buffer after filtering.
 *
 * Note: In the worst case where every char is an escape char, the
 *       destination buffer will be 2 times the size of the source buffer.
 */
PRIVATE uint32_T Filter(char *dest, char *src, uint32_T bytes)
{
    uint32_T i;
    uint32_T newSize = bytes;
    char     *pDest  = dest;
    char     *pSrc   = src;

    for (i=0 ; i<bytes ; i++, pSrc++) {
	if (IsEscapeChar(*pSrc)) {
	    *pDest = escape_character;
	    pDest++;
	    *pDest = (char)((*pSrc) ^ mask_character);
	    pDest++;
	    newSize++;
	} else {
	    *pDest = *pSrc;
	    pDest++;
	}
    }
    return newSize;

} /* end Filter */


/* Function: Num2String ========================================================
 * Abstract:
 *  Translates unsigned long values into strings and returns the size of the
 *  string.
 */
PRIVATE uint32_T Num2String(char *dest,
                            uint32_T value,
                            boolean_T doFilter,
                            boolean_T endianess)
{
    char c[sizeof(uint32_T)];
    int i;
    int j;
    numString temp;
    temp.num = value;

    if (!endianess) { /* big endian */
        i = sizeof(uint32_T);
        j = 0;
        while (j<sizeof(uint32_T))
        {
            c[j] = temp.string[i-1];
            j++;
            i--;
        };
        memcpy(temp.string, c, sizeof(uint32_T));
    }

    if (doFilter) {
        return Filter(dest, temp.string, sizeof(uint32_T));
    }
    else {
        memcpy(dest, temp.string, sizeof(uint32_T));
        return sizeof(uint32_T);
    }
} /* end Num2String */


/* Function: String2Num ========================================================
 * Abstract:
 *  Translates strings into unsigned long values and returns the size of the
 *  value of the number.
 */
PRIVATE uint32_T String2Num(char *source, boolean_T endianess)
{
    numString temp;
    numString temp2;

    int i;
    int j;

    temp.num  = 0; /* For compilation warning using lcc. */
    temp2.num = 0; /* For compilation warning using lcc. */

    memcpy(temp.string, source, 4);

    if (!endianess) { /* big endian */
        i = sizeof(uint32_T);
        j = 0;
        temp2.num = 0ul;
        while (j<4)
        {
            temp2.string[i-1] = temp.string[j];
            j++;
            i--;
        };
        return temp2.num;
    }
    else { /* little endian */
        return temp.num;
    }
} /* end String2Num */


/* Function: SetExtSerialPacket ================================================
 * Abstract:
 *  Sets (sends) the contents of an ExtSerialPacket on the comm line.  This
 *  includes the packet's buffer as well as all serial communication overhead
 *  associated with the packet.
 *
 *  EXT_NO_ERROR is returned on success, EXT_ERROR on failure.
 */
PUBLIC boolean_T SetExtSerialPacket(ExtSerialPacket *pkt, ExtSerialPort *portDev)
{
    uint32_T  i;
    uint32_T  numAct       = 0; /* Num bytes actually sent.   */
    uint32_T  numExp       = 0; /* Num bytes ordered to send. */
    uint32_T  newByteCnt   = 0; /* Num bytes after filtering. */
    uint32_T  bytesWritten = 0; /* Num bytes written by send. */
    boolean_T error        = EXT_NO_ERROR;

    char Buffer[sizeof(uint32_T)*2]; /* Local buffer for converting escape chars. */

    /* If not connected, return immediately. */
    if (!portDev->fConnected) return false;

    /* Initialize some fileds of the packet. */
    pkt->head[0]      = packet_head;
    pkt->head[1]      = packet_head;
    pkt->tail[0]      = packet_tail;
    pkt->tail[1]      = packet_tail;
    pkt->state        = ESP_NoPacket;
    pkt->cursor       = 0;
    pkt->DataCount    = 0;
    pkt->inQuote      = false;

    /* Send the packet header. */
    error = ExtSerialPortSetData(portDev, pkt->head, HEAD_SIZE, &bytesWritten);
    if (error != EXT_NO_ERROR) goto EXIT_POINT;
    numAct = bytesWritten;
    numExp = HEAD_SIZE;

    /* Send the packet type. */
    newByteCnt = Filter(Buffer, &(pkt->PacketType), PACKET_TYPE_SIZE);
    error = ExtSerialPortSetData(portDev, Buffer, newByteCnt, &bytesWritten);
    if (error != EXT_NO_ERROR) goto EXIT_POINT;
    numAct += bytesWritten;
    numExp += newByteCnt;

    /* Send the size of the packet buffer. */
    newByteCnt = Num2String(Buffer, pkt->size, true, portDev->isLittleEndian);
    error = ExtSerialPortSetData(portDev, Buffer, newByteCnt, &bytesWritten);
    if (error != EXT_NO_ERROR) goto EXIT_POINT;
    numAct += bytesWritten;
    numExp += newByteCnt;

    /* Send the variable-sized packet buffer data. */
    for (i=0; i<pkt->size; i++)
    {
        newByteCnt = Filter(Buffer, &(pkt->Buffer[i]), 1);
        error = ExtSerialPortSetData(portDev, Buffer, newByteCnt, &bytesWritten);
        if (error != EXT_NO_ERROR) goto EXIT_POINT;
        numAct += bytesWritten;
        numExp += newByteCnt;
    }

    /* Send the packet tail. */
    error = ExtSerialPortSetData(portDev, pkt->tail, TAIL_SIZE, &bytesWritten);
    if (error != EXT_NO_ERROR) goto EXIT_POINT;
    numAct += bytesWritten;
    numExp += TAIL_SIZE;
 
    /*
     * Return false if actual number of bytes sent does not equal the expected
     * number of bytes.  Otherwise, return true.
     */
    if (numAct != numExp) {
        error = EXT_ERROR;
        goto EXIT_POINT;
    }

  EXIT_POINT:
    return error;

} /* end SetExtSerialPacket */


/* Function: GetExtSerialPacket ================================================
 * Abstract:
 *  Examines incoming bytes for a packet header and discards any chars that do
 *  not fit into a packet header.  After receiving a packet header, records
 *  incoming bytes into a packet buffer until a packet tail is read.  Compares
 *  incoming bytes with the escape character and handles any escaped chars
 *  appropriately (escape char is discarded and next char is exclusive or'd
 *  with the mask character).
 *
 *  EXT_NO_ERROR is returned on success, EXT_ERROR on failure.
 */
PUBLIC boolean_T GetExtSerialPacket(ExtSerialPacket *pkt, ExtSerialPort *portDev)
{
    char      char1        = 0;
    uint32_T  numCharRecvd = 0;
    boolean_T doFilter     = false;
    boolean_T PacketError  = false;
    boolean_T error        = EXT_NO_ERROR;

    /* If not connected, return immediately. */
    if (!portDev->fConnected) return EXT_ERROR;

    /* Initialize some fileds of the packet. */
    pkt->head[0]      = packet_head;
    pkt->head[1]      = packet_head;
    pkt->tail[0]      = packet_tail;
    pkt->tail[1]      = packet_tail;
    pkt->state        = ESP_NoPacket;
    pkt->cursor       = 0;
    pkt->DataCount    = 0;
    pkt->inQuote      = false;

    while (1) {
        /* Get a character from input stream. */
        error = ExtSerialPortGetRawChar(portDev, &char1, &numCharRecvd);
        if (error != EXT_NO_ERROR) goto EXIT_POINT;

        if (numCharRecvd != 1) {
            pkt->state  = ESP_NoPacket;
            pkt->cursor = 0;
            error = EXT_ERROR;
            goto EXIT_POINT;
        }

        /* Handle quoting and filtering (does not deal with xon/xoff issues). */
        switch (pkt->state) {
          case ESP_InType:
          case ESP_InSize:
          case ESP_InPayload:
            /* Handle quoted characters in payload. */
            if (pkt->inQuote) {
                pkt->inQuote = false;
                char1 ^= mask_character;
            } else {
                /*
                 * No characters requiring escaping should be in the input
                 * stream, except for control purposes.
                 */
                switch (char1) {
                  case escape_character:
                    pkt->inQuote = true;
                    /* Need to go get next charater at this point. */
                    continue;
                    break;
                    /*
                     * other special characters should only exist
                     * in payload when quoted.
                     */
                  case packet_head:
                    /*
                     * Error - start handling the packet this header
                     * goes with.
                     */
                    pkt->cursor = (char *)&pkt->head;
                    *pkt->cursor++ = char1;
                    pkt->DataCount++;
                    pkt->state = ESP_InHead;
                    continue;
                  case packet_tail:
                    /* Error - reset packet handling. */
                    pkt->cursor = 0;
                    pkt->state  = ESP_NoPacket;
                    PacketError   = false;
                    break;
                  default:
                    break;
                }
            }
            break;
            /* No quoting in non-payload portions. */
          case ESP_NoPacket:
          case ESP_InHead:
          case ESP_InTail:
          case ESP_Complete:
          default:
            break;
        }

        switch (pkt->state) {
          case ESP_NoPacket:
            if (char1 == packet_head) {
                /*
                 * When a byte matches a packet header tag byte,
                 * save it and change state.
                 */
                pkt->cursor = (char *)&pkt->head;
                *pkt->cursor++ = char1;
                pkt->DataCount++;
                pkt->state = ESP_InHead;
            }		    
            break;
          case ESP_InHead:
            if (char1 == packet_head) {
                /*
                 * In this state, the only acceptable input is a packet header
                 * tag byte which will cause packet processing to progress to
                 * the next state.
                 */
                *pkt->cursor++ = char1;
                pkt->DataCount = 0;
                pkt->state = ESP_InType;
                pkt->cursor = (char *)&pkt->PacketType;
            } else {
                PacketError = true; 
            }
            break;
          case ESP_InType:
            if (pkt->DataCount < sizeof(pkt->PacketType)) {
                /*
                 * In this state, the byte count determines where this
                 * state stands.
                 */
                *pkt->cursor++ = char1;
                pkt->DataCount++;
                if (pkt->DataCount == sizeof(pkt->PacketType)) {
                    pkt->state = ESP_InSize;
                    pkt->cursor = (char *)&pkt->size;
                    pkt->DataCount = 0;
                }
            } else {
                PacketError = true; 
            }
            break;
          case ESP_InSize:
            if (pkt->DataCount < sizeof(pkt->size)) {
                /*
                 * In this state, the byte count determines where this
                 * state stands.
                 */
                *pkt->cursor++ = char1;
                pkt->DataCount++;
                if (pkt->DataCount == sizeof(pkt->size)) {
                    pkt->size = String2Num((char *)&pkt->size, portDev->isLittleEndian);
                    pkt->DataCount = 0;
                    if (pkt->size != 0) {
			pkt->state = ESP_InPayload;
                        pkt->cursor = (char *)pkt->Buffer;
                    } else {
			pkt->state = ESP_InTail;
			pkt->cursor = (char *)&pkt->tail;
                    }
                }
            } else {
                PacketError = true; 
            }
            break;
          case ESP_InPayload:
            if (pkt->DataCount < pkt->size) {
                /*
                 * In this state, the byte count determines where this
                 * state stands.
                 */
                *pkt->cursor++ = char1;
                pkt->DataCount++;
                if (pkt->DataCount == pkt->size) {
                    pkt->state = ESP_InTail;
                    pkt->cursor = (char *)&pkt->tail;
                    pkt->DataCount = 0;
                }
            } else {
                PacketError = true; 
            }
            break;
          case ESP_InTail:
            if (pkt->DataCount < sizeof(pkt->tail)) {
                if (char1 == packet_tail) {
                    /*
                     * In this state, the only acceptable input is a packet
                     * tail tag byte.
                     */
                    *pkt->cursor++ = char1;
                    pkt->DataCount++;
                    if (pkt->DataCount == sizeof(pkt->tail)) {
                        pkt->state = ESP_Complete;
                        pkt->cursor = NULL;
                        pkt->DataCount = 0;
                        if (pkt->state != ESP_Complete) error = EXT_ERROR;
                        goto EXIT_POINT;
                    }
                } else {
                    PacketError = true; 
                }
            } else {
                PacketError = true; 
            }
            break;
          case ESP_Complete:
            break;
          default:
            break;
        }

        if (PacketError) {
            pkt->cursor = 0;
            pkt->state  = ESP_NoPacket;
            PacketError    = false;
        }
    } /* end-of-while */

  EXIT_POINT:
    return error;
} /* end GetExtSerialPacket */


/* [EOF] ext_serial_pkt.c */
