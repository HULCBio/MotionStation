/* $Revision: 1.4.4.1 $ */
/* $Date: 2003/11/20 11:57:40 $ */

/* Abstract: UDP functions imported from kernel
 *
 *  Copyright 1994-2003 The MathWorks, Inc.
 *
 */


static int (XPCCALLCONV * xpceUDPOpenSend)(const char* Address,
                                           int localPort,
                                           int remotePort,
                                           int Broadcast,
                                           int BufferSize);
static int (XPCCALLCONV * xpceUDPOpenReceive)(int Port,
                                              const char *From,
                                              int bufferSize);
static int (XPCCALLCONV * xpceUDPSend)(int udpDesc,
                                       unsigned char *what,
                                       int length);
static int (XPCCALLCONV * xpceUDPReceive)(int udpDesc,
                                          unsigned char *what,
                                          int length,
                                          unsigned long *from);
static void (XPCCALLCONV * xpceUDPClose)(int udpDesc);
