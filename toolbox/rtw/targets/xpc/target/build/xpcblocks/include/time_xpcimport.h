/* $Revision: 1.5 $ */
/* $Date: 2002/03/25 04:14:17 $ */

/* Abstract: time-engine functions imported from kernel
*
*  Copyright 1996-2002 The MathWorks, Inc.
*
*/
 
/* 
 * $Log: time_xpcimport.h,v $
 * Revision 1.5  2002/03/25 04:14:17  batserve
 * Copyright fix in all the files Related Records: . Code Reviewer: rroy
 *
 * Revision 1.5  2002/03/20 20:44:40  ekbas
 * Copyright fix in all the files
 * Related Records: .
 * Code Reviewer: rroy
 *
 * Revision 1.4  2001/04/27 22:53:11  shaishaa
 * Update CopyRights
 * Code Reviewer: Rajiv,Michael
 *
 * Revision 1.3  2000/03/17 20:15:09  mvetsch
 * WEB server, Broadcast Memory, GPIB (Beta5)
 *
 * Revision 1.2  1999/08/31 20:43:19  mvetsch
 * neccessary changes for future support of Visual C/C++
 *
 * Related Records: 66451
 *
 * Revision 1.1.1.1  1999/08/31 18:28:23  mvetsch
 * Branch 1.1.1.1 forced from 1.1 for R11
 *
 * Revision 1.1  1999/07/06 17:36:35  mvetsch
 * Initial revision
 *
*/


static double (XPCCALLCONV * rl32eGetTicksDouble)(void);
static double (XPCCALLCONV * rl32eETimeDouble)(double start, double stop);
static void (XPCCALLCONV * rl32eWaitDouble)(double waitt);
static double (XPCCALLCONV * xpceGetTET)(void);
 




