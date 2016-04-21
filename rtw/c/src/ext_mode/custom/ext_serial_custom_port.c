/*
 * Copyright 1994-2003 The MathWorks, Inc.
 *
 * File: ext_serial_custom_port.c     $Revision.1 $
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
} /* end ExtSerialPortDisconnect */


/* Function: ExtSerialPortIncSendNum ===========================================
 * Abstract:
 *  Returns the next unique serial number for sending a packet.
 */
PUBLIC unsigned int ExtSerialPortIncSendNum(ExtSerialPort *portDev)
{ 
    return ++portDev->SendNum;

} /* end ExtSerialPortIncSendNum */


/* Function: ExtSerialPortIncReceiveNum ========================================
 * Abstract:
 *  Returns the next unique serial number for receiving a packet.
 */
PUBLIC unsigned int ExtSerialPortIncReceiveNum(ExtSerialPort *portDev)
{ 
    return ++portDev->ReceiveNum;

} /* end ExtSerialPortIncReceiveNum */


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
} /* end ExtSerialPortGetRawChar */


/* [EOF] ext_serial_custom_port.c */
