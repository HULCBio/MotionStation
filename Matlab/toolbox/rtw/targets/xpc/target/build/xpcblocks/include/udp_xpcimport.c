/* $Revision: 1.4 $ */
/* $Date: 2002/03/25 04:14:20 $ */

/* Abstract: UDP functions imported from kernel
 *
 *  Copyright 1994-2002 The MathWorks, Inc.
 *
 */

/*
 * $Log: udp_xpcimport.c,v $
 * Revision 1.4  2002/03/25 04:14:20  batserve
 * Copyright fix in all the files Related Records: . Code Reviewer: rroy
 *
 * Revision 1.4  2002/03/20 20:44:43  ekbas
 * Copyright fix in all the files
 * Related Records: .
 * Code Reviewer: rroy
 *
 * Revision 1.3  2001/06/11 19:57:12  rroy
 * This file was created from toolbox/rtw/targets/xpc/udpstuff/udp_xpcimport.c (1.2)
 * Put back udp stuff.
 * Related Records: 100792
 *
 * Revision 1.2  2001/04/25 20:29:44  rroy
 * This file was created from toolbox/rtw/targets/xpc/target/build/xpcblocks/include/udp_xpcimport.c (1.1)
 * Move to udpstuff
 *
 * Revision 1.1  2000/12/04  21:14:28  rroy
 * Initial revision
 *
 *
 */


xpceUDPOpenSend = (void*) GetProcAddress(GetModuleHandle(NULL),
                                         "xpceUDPOpenSend");
if (xpceUDPOpenSend==NULL) {
    printf("xpceUDPOpenSend\n");
    return;
}

xpceUDPOpenReceive = (void*) GetProcAddress(GetModuleHandle(NULL),
                                            "xpceUDPOpenReceive");
if (xpceUDPOpenReceive==NULL) {
    printf("xpceUDPOpenReceive\n");
    return;
}

xpceUDPSend = (void*) GetProcAddress(GetModuleHandle(NULL), "xpceUDPSend");
if (xpceUDPSend==NULL) {
    printf("xpceUDPSend\n");
    return;
}

xpceUDPReceive = (void*) GetProcAddress(GetModuleHandle(NULL),
                                        "xpceUDPReceive");
if (xpceUDPReceive==NULL) {
    printf("xpceUDPReceive\n");
    return;
}

xpceUDPClose = (void*) GetProcAddress(GetModuleHandle(NULL),
                                      "xpceUDPClose");
if (xpceUDPClose==NULL) {
    printf("xpceUDPClose\n");
    return;
}
