/* $Revision: 1.4 $ */
/* $Date: 2002/03/25 04:13:56 $ */

/* Abstract: PCI-bus functions imported from kernel
*
*  Copyright 1996-2002 The MathWorks, Inc.
*
*/
 
/* 
 * $Log: pci_xpcimport.c,v $
 * Revision 1.4  2002/03/25 04:13:56  batserve
 * Copyright fix in all the files Related Records: . Code Reviewer: rroy
 *
 * Revision 1.4  2002/03/20 20:44:26  ekbas
 * Copyright fix in all the files
 * Related Records: .
 * Code Reviewer: rroy
 *
 * Revision 1.3  2001/04/27 22:53:02  shaishaa
 * Update CopyRights
 * Code Reviewer: Rajiv,Michael
 *
 * Revision 1.2  2000/03/17 20:14:58  mvetsch
 * WEB server, Broadcast Memory, GPIB (Beta5)
 *
 * Revision 1.1  1999/07/06 17:36:26  mvetsch
 * Initial revision
 *
*/


rl32eShowPCIDev = (void*) GetProcAddress(GetModuleHandle(NULL), "rl32eShowPCIDev");
if (rl32eShowPCIDev==NULL) {
	printf("Error 1\n");
	return;
}

rl32eShowPCIInfo = (void*) GetProcAddress(GetModuleHandle(NULL), "rl32eShowPCIInfo");
if (rl32eShowPCIInfo==NULL) {
	printf("Error 1\n");
	return;
}

rl32eGetPCIInfo = (void*) GetProcAddress(GetModuleHandle(NULL), "rl32eGetPCIInfo");
if (rl32eGetPCIInfo==NULL) {
	printf("Error 2\n");
	return;
}

rl32eGetPCIInfoAtSlot = (void*) GetProcAddress(GetModuleHandle(NULL), "rl32eGetPCIInfoAtSlot");
if (rl32eGetPCIInfoAtSlot==NULL) {
	printf("Error 3\n");
	return;
}

xpceAssignPCIInterrupt = (void*) GetProcAddress(GetModuleHandle(NULL), "xpceAssignPCIInterrupt");
if (xpceAssignPCIInterrupt==NULL) {
	printf("Error xpceAssignPCIInterrupt\n");
	return;
}
