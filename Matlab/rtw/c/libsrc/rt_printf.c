/* Copyright 1994-2002 The MathWorks, Inc.
 *
 * File: rt_printf.c
 *
 * Abstract:
 *      Stub I/O printf facility for systems which don't have stdio.
 *
 * $Revision: 1.7 $
 * $Date: 2002/04/14 10:15:01 $
 */



/* Function: rtPrintfNoOp ======================================================
 * Abstract:
 *      Maps ssPrintf to rtPrintfNoOp if HAVESTDIO is not defined (see
 *      simstruct.h
 */
int rtPrintfNoOp(const char *fmt, ...)
{
    /* do nothing */
    return(fmt == (const char *)0); /* use fmt to quiet unused var warning */
}


/* [eof] rt_printf.c */
