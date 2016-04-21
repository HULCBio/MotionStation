/* $Revision: 1.6.6.1 $ */
/* $Date: 2004/04/08 21:02:31 $ */

/* Abstract: I/O functions imported from kernel
*
*  Copyright 1996-2003 The MathWorks, Inc.
*
*/
 
/*
 * $Log: io_xpcimport.c,v $
 * Revision 1.6.6.1  2004/04/08 21:02:31  batserve
 * 2004/04/05  1.6.10.1  gweekly
 *   Updated copyright
 * Accepted job 17399a in A
 *
 * Revision 1.6.10.1  2004/04/05 16:41:37  gweekly
 * Updated copyright
 *
 * Revision 1.6  2003/04/24 18:17:34  pkirwin
 * Have the port I/O functions appropriately typecast parameters passed to them
 * Code Reviewer: pkirwin
 *
 * Revision 1.6  2003/01/03 20:00:07  pkirwin
 * Have the port I/O functions appropriately typecast parameters passed to them
 * Code Reviewer: pkirwin
 *
 * Revision 1.5  2002/03/20 20:44:15  ekbas
 * Copyright fix in all the files
 * Related Records: .
 * Code Reviewer: rroy
 *
 * Revision 1.4  2001/04/27 22:52:58  shaishaa
 * Update CopyRights
 * Code Reviewer: Rajiv,Michael
 *
 * Revision 1.3  2000/09/18  22:02:09  greg
 * Fix log prefix
 * Related Records: CVS
 * Code Reviewer: marc, mmirman
 *
 * Revision 1.2  2000/03/17 18:29:24  mvetsch
 * copyright fixes.
 *
 * Revision 1.1  1999/07/06 17:36:22  mvetsch
 * Initial revision
 *
*/


rl32eGetDevicePtr = (void*) GetProcAddress(GetModuleHandle(NULL), "rl32eGetDevicePtr");
if (rl32eGetDevicePtr==NULL) {
	printf("Error 3\n");
	return;
}

rl32eFcnOutpDW = (void*) GetProcAddress(GetModuleHandle(NULL), "rl32eOutpDW");
if (rl32eFcnOutpDW==NULL) {
	printf("Error 4\n");
	return;
}

rl32eFcnOutpW = (void*) GetProcAddress(GetModuleHandle(NULL), "rl32eOutpW");
if (rl32eFcnOutpW==NULL) {
	printf("Error 4\n");
	return;
}

rl32eFcnOutpB = (void*) GetProcAddress(GetModuleHandle(NULL), "rl32eOutpB");
if (rl32eFcnOutpB==NULL) {
	printf("Error 5\n");
	return;
}

rl32eFcnInpDW = (void*) GetProcAddress(GetModuleHandle(NULL), "rl32eInpDW");
if (rl32eFcnInpDW==NULL) {
	printf("Error 6\n");
	return;
}


rl32eFcnInpW = (void*) GetProcAddress(GetModuleHandle(NULL), "rl32eInpW");
if (rl32eFcnInpW==NULL) {
	printf("Error 6\n");
	return;
}

rl32eFcnInpB = (void*) GetProcAddress(GetModuleHandle(NULL), "rl32eInpB");
if (rl32eFcnInpB==NULL) {
	printf("Error 7\n");
	return;
}
