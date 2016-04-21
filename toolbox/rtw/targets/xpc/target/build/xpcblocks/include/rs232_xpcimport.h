/* $Revision: 1.6 $ */
/* $Date: 2002/03/25 04:14:05 $ */

/* Abstract: RS232 functions imported from kernel
*
*  Copyright 1996-2002 The MathWorks, Inc.
*
*/
 
/*
 * $Log: rs232_xpcimport.h,v $
 * Revision 1.6  2002/03/25 04:14:05  batserve
 * Copyright fix in all the files Related Records: . Code Reviewer: rroy
 *
 * Revision 1.6  2002/03/20 20:44:32  ekbas
 * Copyright fix in all the files
 * Related Records: .
 * Code Reviewer: rroy
 *
 * Revision 1.5  2001/04/27 22:53:07  shaishaa
 * Update CopyRights
 * Code Reviewer: Rajiv,Michael
 *
 * Revision 1.4  2000/09/18  22:02:10  greg
 * Fix log prefix
 * Related Records: CVS
 * Code Reviewer: marc, mmirman
 *
 * Revision 1.3  2000/03/17 18:29:31  mvetsch
 * copyright fixes.
 *
 * Revision 1.2  1999/08/31 20:43:15  mvetsch
 * neccessary changes for future support of Visual C/C++
 *
 * Related Records: 66451
 *
 * Revision 1.1.1.1  1999/08/31 18:28:07  mvetsch
 * Branch 1.1.1.1 forced from 1.1 for R11
 *
 * Revision 1.1  1999/07/06 17:36:31  mvetsch
 * Initial revision
 *
*/


#define DATA_READY   0x01     /* not an error               */
#define OVERRUN      0x02     /* error detected by hardware */
#define PARITY       0x04     /* error detected by hardware */
#define FRAME        0x08     /* error detected by hardware */
#define BREAK        0x10     /* not an error               */
#define TIMEOUT      0x40     /* error detected by software */
#define BUFFER_FULL  0x80     /* error detected by software */
#define TXB_EMPTY    0x20     /* not an error               */
#define TX_SHIFT_EMPTY 0x40   /* dito                       */
#define HARD_ERROR   (OVERRUN | PARITY | FRAME | BREAK)


typedef unsigned short COMData;
typedef unsigned char  Byte;

typedef enum { NoProtocol, XOnXOff, RTSCTS, DTRDSR } Protocol;

static int DefaultCOMIOBase[] = {0x3F8, 0x2F8, 0x3E8, 0x2E8}; 
static int DefaultCOMIRQ[] = {4, 3, 4, 3};   

static void (XPCCALLCONV * rl32eInitCOMPort)(int  Port, int  IOBase, int  IRQ, int  Baudrate, int  Parity, int  StopBits, int  WordLength, int  ReceiveBufferSize, int  SendBufferSize, Protocol Prot);
static void (XPCCALLCONV * rl32eCloseCOMPort)(int Port);
static void (XPCCALLCONV * rl32eSendChar)(int Port, Byte Data);
static COMData (XPCCALLCONV * rl32eReceiveChar)(int Port);
static int (XPCCALLCONV * rl32eReceiveBufferCount)(int Port);
static Byte (XPCCALLCONV * rl32eLineStatus)(int Port);
static void (XPCCALLCONV * rl32eSendBlock)(int Port, void * Data, int Length);


