/*
 * Copyright 1994-2003 The MathWorks, Inc.
 *
 * File: ext_serial_win32_port.c     $Revision: 1.1.6.3 $
 *
 * Abstract:
 *  The External Mode Serial Port is a logical object providing a standard
 *  interface between the external mode code and the physical serial port.
 *  The prototypes in the 'Visible Functions' section of this file provide
 *  the consistent front-end interface to external mode code.  The
 *  implementations of these functions provide the back-end interface to the
 *  physical serial port.  This layer of abstraction allows for minimal
 *  modifications to external mode code when the physical serial port is
 *  changed.
 *
 *     ----------------------------------
 *     | Host/Target external mode code |
 *     ----------------------------------
 *                   / \
 *                  /| |\
 *                   | |
 *                   | |
 *                  \| |/
 *                   \ /  Provides a standard, consistent interface to extmode
 *     ----------------------------------
 *     | External Mode Serial Port      |
 *     ----------------------------------
 *                   / \  Function definitions specific to physical serial port
 *                  /| |\
 *                   | |
 *                   | |
 *                  \| |/
 *                   \ /
 *     ----------------------------------
 *     | HW/OS/Physical serial port     |
 *     ----------------------------------
 *
 *  See also ext_serial_pkt.c.
 */

#include <string.h>

#include "tmwtypes.h"

#include "ext_types.h"
#include "ext_share.h"
#include "ext_serial_port.h"
#include "ext_serial_pkt.h"

/***************** WIN32 SPECIFIC FUNCTIONS ***********************************/

#include <windows.h>
#include <assert.h>
#include <stdio.h>

/* This is for the lcc compiler. */
#ifndef MAXDWORD
#define MAXDWORD 0xffffffff
#endif

/*PRIVATE COMMTIMEOUTS cto_immediate = { MAXDWORD, 0, 0, 0, 0 };*/
PRIVATE COMMTIMEOUTS cto_timeout   = { MAXDWORD, MAXDWORD, 10000, 0, 0 };
PRIVATE COMMTIMEOUTS cto_blocking  = { 0, 0, 0, 0, 0 };
PRIVATE DCB  	     dcb;
PRIVATE HANDLE       serialHandle  = INVALID_HANDLE_VALUE;

/* Function: initDCB ===========================================================
 * Abstract:
 *  Initializes the control settings for a win32 serial communications device.
 */
PRIVATE void initDCB(uint32_T baud)
{
    dcb.DCBlength       = sizeof(dcb);                   
        
    /* ---------- Serial Port Config ------- */
    dcb.BaudRate        = baud;
    dcb.Parity          = NOPARITY;
    dcb.fParity         = 0;
    dcb.StopBits        = ONESTOPBIT;
    dcb.ByteSize        = 8;
    dcb.fOutxCtsFlow    = 0;
    dcb.fOutxDsrFlow    = 0;
    dcb.fDtrControl     = DTR_CONTROL_DISABLE;
    dcb.fDsrSensitivity = 0;
    dcb.fRtsControl     = RTS_CONTROL_DISABLE;
    dcb.fOutX           = 0;
    dcb.fInX            = 0;
        
    /* ---------- Misc Parameters ---------- */
    dcb.fErrorChar      = 0;
    dcb.fBinary         = 1;
    dcb.fNull           = 0;
    dcb.fAbortOnError   = 0;
    dcb.wReserved       = 0;
    dcb.XonLim          = 2;
    dcb.XoffLim         = 4;
    dcb.XonChar         = 0x13;
    dcb.XoffChar        = 0x19;
    dcb.EvtChar         = 0;

} /* end initDCB */


/* Function: serial_get_string =================================================
 * Abstract:
 *  Attempts to get the specified number of bytes from the comm line.  The
 *  number of bytes read is returned via the 'bytesRead' parameter.  If the
 *  specified number of bytes is not read within the time out period specified
 *  in cto_timeout, an error is returned.
 *
 *  EXT_NO_ERROR is returned on success, EXT_ERROR on failure.
 */
PRIVATE boolean_T serial_get_string(char *data,
                                    uint32_T size,
                                    uint32_T *bytesRead)
{
    boolean_T error = EXT_NO_ERROR;

    assert(serialHandle != NULL);

    SetCommTimeouts(serialHandle,&cto_timeout);

    if (!ReadFile(serialHandle, data, size, (unsigned long *)bytesRead, NULL)) {
        error = EXT_ERROR;
        goto EXIT_POINT;
    }

  EXIT_POINT:
    return error;

} /* end serial_get_string */


/* Function: serial_set_string =================================================
 * Abstract:
 *  Sets (sends) the specified number of bytes on the comm line.  The number of
 *  bytes sent is returned via the 'bytesWritten' parameter.
 *
 *  EXT_NO_ERROR is returned on success, EXT_ERROR on failure.
 */
PRIVATE boolean_T serial_set_string(char *data,
                                    uint32_T size,
                                    uint32_T *bytesWritten)
{
    boolean_T error = EXT_NO_ERROR;

    assert(serialHandle != NULL);
    assert(data != NULL);

    if (!WriteFile(serialHandle,data,size,(unsigned long *)bytesWritten, NULL)){
        error = EXT_ERROR;
        goto EXIT_POINT;
    }

  EXIT_POINT:
    return error;

} /* end serial_set_string */


/* Function: serial_string_pending =============================================
 * Abstract:
 *  Returns, via the 'pendingBytes' arg, the number of bytes pending on the
 *  comm line.
 *
 *  EXT_NO_ERROR is returned on success, EXT_ERROR on failure.
 */
PRIVATE boolean_T serial_string_pending(uint32_T *pendingBytes)
{
    struct _COMSTAT status;
    unsigned long   etat;
    boolean_T       error = EXT_NO_ERROR;

    assert(serialHandle != NULL);

    /* Find out how much data is available. */
    if (!ClearCommError(serialHandle, &etat, &status)) {
        pendingBytes = 0;
        error = EXT_ERROR;
        goto EXIT_POINT;
    } else {
	*pendingBytes = status.cbInQue;
    }

  EXIT_POINT:
    return error;

} /* end serial_string_pending */


/* Function: serial_uart_close =================================================
 * Abstract:
 *  Closes the serial port.
 *
 *  EXT_NO_ERROR is returned on success, EXT_ERROR on failure.
 */
PRIVATE boolean_T serial_uart_close(void)
{
    if (serialHandle != INVALID_HANDLE_VALUE) {
        CloseHandle(serialHandle);
        serialHandle = INVALID_HANDLE_VALUE;
    }
    return EXT_NO_ERROR;

} /* end serial_uart_close */


/* Function: serial_uart_init ==================================================
 * Abstract:
 *  Opens the serial port and initializes the port, baud, and DCB settings.
 *
 *  EXT_NO_ERROR is returned on success, EXT_ERROR on failure.
 */
PRIVATE boolean_T serial_uart_init(uint16_T port, uint32_T baud)
{
    boolean_T error     = EXT_NO_ERROR;
    boolean_T closeFile = false;

    initDCB(baud);

    /* If the serial port is open, close it. */
    if (serialHandle != INVALID_HANDLE_VALUE) {
        error = serial_uart_close();
        if (error != EXT_NO_ERROR) goto EXIT_POINT;
    }

    assert(serialHandle == INVALID_HANDLE_VALUE);

    /* Attempt to open the serial port */
    if (serialHandle == INVALID_HANDLE_VALUE) {
        char localPortString[10];
        sprintf(localPortString, "COM%d:", port);

        serialHandle = (void *) CreateFile(localPortString,
                                           GENERIC_READ | GENERIC_WRITE,
                                           0, NULL, OPEN_EXISTING,
                                           FILE_ATTRIBUTE_NORMAL, NULL);
        if (serialHandle == INVALID_HANDLE_VALUE) {
            error = EXT_ERROR;
            goto EXIT_POINT;
        }
    }

    if (!SetCommTimeouts(serialHandle, &cto_blocking)) {
        closeFile = true;
        error = EXT_ERROR;
        goto EXIT_POINT;
    }

    if (!SetCommState(serialHandle, &dcb)) {
        closeFile = true;
        error = EXT_ERROR;
	goto EXIT_POINT;
    }

  EXIT_POINT:
    if (closeFile) serial_uart_close();
    return error;

} /* end serial_uart_init */


/***************** VISIBLE FUNCTIONS ******************************************/

/* Function: ExtSerialPortCreate ===============================================
 * Abstract:
 *  Creates an External Mode Serial Port object.  The External Mode Serial Port
 *  is an abstraction of the physical serial port providing a standard
 *  interface for external mode code.  A pointer to the created object is
 *  returned.
 *
 */
PUBLIC ExtSerialPort *ExtSerialPortCreate(void)
{
    static ExtSerialPort serialPort;
    ExtSerialPort *portDev = &serialPort;

    /* Determine and save endianess. */
    {
        union Char2Integer_tag
        {
            int IntegerMember;
            char CharMember[sizeof(int)];
        } temp;

        temp.IntegerMember = 1;
        if (temp.CharMember[0] != 1)
            portDev->isLittleEndian = false;
        else
            portDev->isLittleEndian = true;
    }

    portDev->fConnected = false;

    return portDev;

} /* end ExtSerialPortCreate */


/* Function: ExtSerialPortConnect ==============================================
 * Abstract:
 *  Performs a logical connection between the external mode code and the
 *  External Mode Serial Port object and a real connection between the External
 *  Mode Serial Port object and the physical serial port.
 *
 *  EXT_NO_ERROR is returned on success, EXT_ERROR on failure.
 */
PUBLIC boolean_T ExtSerialPortConnect(ExtSerialPort *portDev,
                                      uint16_T port,
                                      uint32_T baudRate)
{
    boolean_T error = EXT_NO_ERROR;

    if (portDev->fConnected) {
        error = EXT_ERROR;
        goto EXIT_POINT;
    }

    portDev->fConnected = true;

    error = serial_uart_init(port, baudRate);
    if (error != EXT_NO_ERROR) {
        portDev->fConnected = false;
        goto EXIT_POINT;
    }

  EXIT_POINT:
    return error;

} /* end ExtSerialPortConnect */


/* Function: ExtSerialPortDisconnect ===========================================
 * Abstract:
 *  Performs a logical disconnection between the external mode code and the
 *  External Mode Serial Port object and a real disconnection between the
 *  External Mode Serial Port object and the physical serial port.
 *
 *  EXT_NO_ERROR is returned on success, EXT_ERROR on failure.
 */
PUBLIC boolean_T ExtSerialPortDisconnect(ExtSerialPort *portDev)
{
    boolean_T error = EXT_NO_ERROR;

    if (!portDev->fConnected) {
        error = EXT_ERROR;
        goto EXIT_POINT;
    }

    portDev->fConnected = false;

    error = serial_uart_close();
    if (error != EXT_NO_ERROR) goto EXIT_POINT;

  EXIT_POINT:
    return error;

} /* end ExtSerialPortDisconnect */


/* Function: ExtSerialPortSetData ==============================================
 * Abstract:
 *  Sets (sends) the specified number of bytes on the comm line.  The number of
 *  bytes sent is returned via the 'bytesWritten' parameter.
 *
 *  EXT_NO_ERROR is returned on success, EXT_ERROR on failure.
 */
PUBLIC boolean_T ExtSerialPortSetData(ExtSerialPort *portDev,
                                      char *data,
                                      uint32_T size,
                                      uint32_T *bytesWritten)
{
    if (!portDev->fConnected) return EXT_ERROR;

    return serial_set_string(data, size, bytesWritten);

} /* end ExtSerialPortSetData */


/* Function: ExtSerialPortDataPending ==========================================
 * Abstract:
 *  Returns, via the 'bytesPending' arg, the number of bytes pending on the
 *  comm line.
 *
 *  EXT_NO_ERROR is returned on success, EXT_ERROR on failure.
 */
PUBLIC boolean_T ExtSerialPortDataPending(ExtSerialPort *portDev,
                                          uint32_T *bytesPending)
{
    if (!portDev->fConnected) return EXT_ERROR;

    return serial_string_pending(bytesPending);

} /* end ExtSerialPortDataPending */


/* Function: ExtSerialPortGetRawChar ===========================================
 * Abstract:
 *  Attempts to get one byte from the comm line.  The number of bytes read is
 *  returned via the 'bytesRead' parameter.
 *
 *  EXT_NO_ERROR is returned on success, EXT_ERROR on failure.
 */
PUBLIC boolean_T ExtSerialPortGetRawChar(ExtSerialPort *portDev,
                                         char *c,
                                         uint32_T *bytesRead)
{
    if (!portDev->fConnected) return EXT_ERROR;

    return serial_get_string(c, 1, bytesRead);

} /* end ExtSerialPortGetRawChar */


/* [EOF] ext_serial_win32_port.c */
