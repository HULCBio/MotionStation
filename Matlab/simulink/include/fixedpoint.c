/* Copyright 1994-2003 The MathWorks, Inc.
 * $Revision: 1.1.6.1 $
 * $Date: 2003/03/05 06:50:26 $
 *
 * File      : fixedpoint.c
 *
 * This file should be included in user written fixed-point C sfunctions
 * immediately after simulink.c is included.  This usually occurs
 * at the bottom of the sfunction's C source code.
 *
 * Only the API given in the header file fixedpoint.h should be used.
 * Users should not directly access the functions and definitions 
 * given in this C file.  The contents of this C file are likely
 * to change drastically from release to release.  Direct use of 
 * the contents of this C file are likely to necessitate 
 * significant work when upgrading to newer Simulink releases.
 * Not only would a recompile be required, but also a complete
 * rewrite of any code directly accessing the definitions or
 * functions in this C file.  If the sfunction only uses
 * the API given in the header file fixedpoint.h, then
 * migrating to a newer Simulink release should require
 * at most a recompile.   
 */

/* [EOF] fixedpoint.c */
