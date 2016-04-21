/*
 * Copyright 1994-2003 The MathWorks, Inc.
 *
 * File: ext_serial_port.h     $Revision: 1.1.6.3 $
 *
 * Abstract:
 *  Function prototypes for the External Mode Serial Port object.
 */

#ifndef __EXT_SERIAL_PORT__
#define __EXT_SERIAL_PORT__

typedef struct ExtSerialPort_tag
{
    bool isLittleEndian; /* Endianess of target. */
    bool fConnected;     /* Connected or not.    */
} ExtSerialPort;

extern ExtSerialPort *ExtSerialPortCreate       (void);
extern void          ExtSerialPortDestroy       (ExtSerialPort *portDev);
extern boolean_T     ExtSerialPortConnect       (ExtSerialPort *portDev,
                                                 uint16_T portNum,
                                                 uint32_T baudRate);
extern boolean_T     ExtSerialPortDisconnect    (ExtSerialPort *portDev);
extern boolean_T     ExtSerialPortSetData       (ExtSerialPort *portDev,
                                                 char *data,
                                                 uint32_T size,
                                                 uint32_T *bytesWritten);
extern boolean_T     ExtSerialPortDataPending   (ExtSerialPort *portDev,
                                                 uint32_T *bytesPending);
extern boolean_T     ExtSerialPortGetRawChar    (ExtSerialPort *portDev,
                                                 char *c,
                                                 uint32_T *bytesRead);

#endif /* __EXT_SERIAL_PORT__ */

/* [EOF] ext_serial_port.h */
