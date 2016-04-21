/* $Revision: 1.3 $ */

/* Abstract: Broadcast Memory functions imported from kernel
*
*  Copyright 1996-2002 The MathWorks, Inc.
*
*/
 
/* 
 * $Log: broadcastm_xpcimport.c,v $
 * Revision 1.3  2002/03/25 04:13:26  batserve
 * Copyright fix in all the files Related Records: . Code Reviewer: rroy
 *
 * Revision 1.3  2002/03/20 20:44:07  ekbas
 * Copyright fix in all the files
 * Related Records: .
 * Code Reviewer: rroy
 *
 * Revision 1.2  2001/04/27 22:52:54  shaishaa
 * Update CopyRights
 * Code Reviewer: Rajiv,Michael
 *
 * Revision 1.1  2000/03/17 20:14:17  mvetsch
 * Initial revision
 *
 *
*/


xpceInitBroadcastM = (void*) GetProcAddress(GetModuleHandle(NULL), "xpceInitBroadcastM");
if (xpceInitBroadcastM==NULL) {
	printf("xpceInitBroadcastM not found\n");
	return;
}

xpceGetBroadcastM = (void*) GetProcAddress(GetModuleHandle(NULL), "xpceGetBroadcastM");
if (xpceGetBroadcastM==NULL) {
	printf("xpceGetBroadcastM not found\n");
	return;
}
