/*
 * File: ccp_defines.h
 *
 * Abstract:
 *   CAN Calibration Protocol
 *
 * $Revision: 1.11.4.1 $
 * $Date: 2004/04/19 01:19:42 $
 *
 * Copyright 2001-2002 The MathWorks, Inc.
 */

#define CCP_CONNECT              0x01
#define CCP_EXCHANGE_ID          0x17
#define CCP_GET_SEED             0x12
#define CCP_UNLOCK               0x13
#define CCP_SET_MTA              0x02
#define CCP_DNLOAD               0x03
#define CCP_DNLOAD_6             0x23
#define CCP_UPLOAD               0x04
#define CCP_SHORT_UPLOAD         0x0F
#define CCP_SET_CAL_PAGE         0x11
#define CCP_GET_DAQ_SIZE         0x14
#define CCP_SET_DAQ_PTR          0x15
#define CCP_WRITE_DAQ            0x16
#define CCP_START_STOP           0x06
#define CCP_DISCONNECT           0x07
#define CCP_SET_S_STATUS         0x0C
#define CCP_GET_S_STATUS         0x0D
#define CCP_BUILD_CHKSUM         0x0E
#define CCP_CLEAR_MEMORY         0x10
#define CCP_PROGRAM              0x18
#define CCP_PROGRAM_6            0x22 
#define CCP_MOVE                 0x19
#define CCP_DIAG_SERVICE         0x20
#define CCP_ACTION_SERVICE       0x21
#define CCP_TEST                 0x05
#define CCP_START_STOP_ALL       0x08
#define CCP_GET_ACTIVE_CAL_PAGE  0x09
#define CCP_GET_CCP_VERSION      0x1B

/* Extensions */
#define CCP_PROGRAM_PREPARE       0x1E

/* Command Return Codes */
#define CCP_CRC_OK                 0x00
#define CCP_CRC_UNKNOWN_COMMAND    0x30

#define CCP_DTO_ID  0xFF

