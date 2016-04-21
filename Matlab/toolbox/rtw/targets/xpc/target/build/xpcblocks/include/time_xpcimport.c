/* $Revision: 1.4 $ */
/* $Date: 2002/03/25 04:14:14 $ */

/* Abstract: time-engine functions imported from kernel
*
*  Copyright 1996-2002 The MathWorks, Inc.
*
*/
 
/* 
 * $Log: time_xpcimport.c,v $
 * Revision 1.4  2002/03/25 04:14:14  batserve
 * Copyright fix in all the files Related Records: . Code Reviewer: rroy
 *
 * Revision 1.4  2002/03/20 20:44:38  ekbas
 * Copyright fix in all the files
 * Related Records: .
 * Code Reviewer: rroy
 *
 * Revision 1.3  2001/04/27 22:53:09  shaishaa
 * Update CopyRights
 * Code Reviewer: Rajiv,Michael
 *
 * Revision 1.2  2000/03/17 20:15:05  mvetsch
 * WEB server, Broadcast Memory, GPIB (Beta5)
 *
 * Revision 1.1  1999/07/06 17:36:33  mvetsch
 * Initial revision
 *
*/


rl32eGetTicksDouble = (void*) GetProcAddress(GetModuleHandle(NULL), "rl32eGetTicksDouble");
if (rl32eGetTicksDouble==NULL) {
	printf("Error 1\n");
	return;
}

rl32eETimeDouble = (void*) GetProcAddress(GetModuleHandle(NULL), "rl32eETimeDouble");
if (rl32eETimeDouble==NULL) {
	printf("Error 1\n");
	return;
}

rl32eWaitDouble = (void*) GetProcAddress(GetModuleHandle(NULL), "rl32eWaitDouble");
if (rl32eWaitDouble==NULL) {
	printf("Error 1\n");
	return;
}

xpceGetTET = (void*) GetProcAddress(GetModuleHandle(NULL), "xpceGetTET");
if (xpceGetTET==NULL) {
	printf("Error xpceGetTET\n");
	return;
}

		


