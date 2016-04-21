/* $Revision: 1.7.6.1 $ */
/* $Date: 2004/04/08 21:02:32 $ */

/* Abstract: I/O functions imported from kernel
*
*  Copyright 1996-2003 The MathWorks, Inc.
*
*/
 
/*
 * $Log: io_xpcimport.h,v $
 * Revision 1.7.6.1  2004/04/08 21:02:32  batserve
 * 2004/04/05  1.7.10.1  gweekly
 *   Updated copyright
 * Accepted job 17399a in A
 *
 * Revision 1.7.10.1  2004/04/05 16:41:37  gweekly
 * Updated copyright
 *
 * Revision 1.7  2003/04/24 18:17:35  pkirwin
 * Have the port I/O functions appropriately typecast parameters passed to them
 * Code Reviewer: pkirwin
 *
 * Revision 1.7  2003/01/03 20:00:09  pkirwin
 * Have the port I/O functions appropriately typecast parameters passed to them
 * Code Reviewer: pkirwin
 *
 * Revision 1.6  2002/03/20 20:44:17  ekbas
 * Copyright fix in all the files
 * Related Records: .
 * Code Reviewer: rroy
 *
 * Revision 1.5  2001/04/27 22:53:00  shaishaa
 * Update CopyRights
 * Code Reviewer: Rajiv,Michael
 *
 * Revision 1.4  2000/09/18  22:02:09  greg
 * Fix log prefix
 * Related Records: CVS
 * Code Reviewer: marc, mmirman
 *
 * Revision 1.3  2000/03/17 18:29:27  mvetsch
 * copyright fixes.
 *
 * Revision 1.2  1999/08/31 20:43:10  mvetsch
 * neccessary changes for future support of Visual C/C++
 *
 * Related Records: 66451
 *
 * Revision 1.1.1.1  1999/08/31 18:27:39  mvetsch
 * Branch 1.1.1.1 forced from 1.1 for R11
 *
 * Revision 1.1  1999/07/06 17:36:24  mvetsch
 * Initial revision
 *
*/

#define RT_PG_USERREADWRITE  0x7

static void * (XPCCALLCONV * rl32eGetDevicePtr)(void *Physical, unsigned Bytes, int Access);

static unsigned long (XPCCALLCONV * rl32eFcnInpDW)(unsigned short port); 
static unsigned short (XPCCALLCONV * rl32eFcnInpW)(unsigned short port);
static unsigned short (XPCCALLCONV * rl32eFcnInpB)(unsigned short port);
static void (XPCCALLCONV * rl32eFcnOutpDW)(unsigned short port, unsigned long value);
static void (XPCCALLCONV * rl32eFcnOutpW)(unsigned short port, unsigned short value); 
static void (XPCCALLCONV * rl32eFcnOutpB)(unsigned short port, unsigned short value); 


#define rl32eInpDW(port) rl32eFcnInpDW( (unsigned short) (port) ) 
#define rl32eInpW(port) rl32eFcnInpW( (unsigned short) (port) )
#define rl32eInpB(port) rl32eFcnInpB( (unsigned short) (port) )
#define rl32eOutpDW(port, value) rl32eFcnOutpDW( (unsigned short) (port), (unsigned long) (value) )
#define rl32eOutpW(port, value) rl32eFcnOutpW( (unsigned short) (port), (unsigned short) (value) ) 
#define rl32eOutpB(port, value) rl32eFcnOutpB( (unsigned short) (port), (unsigned short) (value) ) 


