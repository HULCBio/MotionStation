/* $Revision: 1.5 $ */
/* $Date: 2002/03/25 04:14:02 $ */

/* Abstract: RS232 functions imported from kernel
*
*  Copyright 1996-2002 The MathWorks, Inc.
*
*/
 
/*
 * $Log: rs232_xpcimport.c,v $
 * Revision 1.5  2002/03/25 04:14:02  batserve
 * Copyright fix in all the files Related Records: . Code Reviewer: rroy
 *
 * Revision 1.5  2002/03/20 20:44:30  ekbas
 * Copyright fix in all the files
 * Related Records: .
 * Code Reviewer: rroy
 *
 * Revision 1.4  2001/04/27 22:53:06  shaishaa
 * Update CopyRights
 * Code Reviewer: Rajiv,Michael
 *
 * Revision 1.3  2000/09/18  22:02:10  greg
 * Fix log prefix
 * Related Records: CVS
 * Code Reviewer: marc, mmirman
 *
 * Revision 1.2  2000/03/17 18:29:29  mvetsch
 * copyright fixes.
 *
 * Revision 1.1  1999/07/06 17:36:30  mvetsch
 * Initial revision
 *
*/


rl32eInitCOMPort = (void*) GetProcAddress(GetModuleHandle(NULL), "rl32eInitCOMPort");
if (rl32eInitCOMPort==NULL) {
	printf("Error 1\n");
	return;
}

rl32eCloseCOMPort = (void*) GetProcAddress(GetModuleHandle(NULL), "rl32eCloseCOMPort");
if (rl32eCloseCOMPort==NULL) {
	printf("Error 1\n");
	return;
}

rl32eSendChar = (void*) GetProcAddress(GetModuleHandle(NULL), "rl32eSendChar");
if (rl32eSendChar==NULL) {
	printf("Error 2\n");
	return;
}

rl32eReceiveChar = (void*) GetProcAddress(GetModuleHandle(NULL), "rl32eReceiveChar");
if (rl32eReceiveChar==NULL) {
	printf("Error 3\n");
	return;
}

rl32eReceiveBufferCount = (void*) GetProcAddress(GetModuleHandle(NULL), "rl32eReceiveBufferCount");
if (rl32eReceiveBufferCount==NULL) {
	printf("Error 2\n");
	return;
}

rl32eLineStatus = (void*) GetProcAddress(GetModuleHandle(NULL), "rl32eLineStatus");
if (rl32eLineStatus==NULL) {
	printf("Error 3\n");
	return;
}

rl32eSendBlock = (void*) GetProcAddress(GetModuleHandle(NULL), "rl32eSendBlock");
if (rl32eSendBlock==NULL) {
	printf("Error 3\n");
	return;
}

