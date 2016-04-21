/* Copyright 1994-2002 The MathWorks, Inc.
 *
 * File: rt_urand.c     $Revision: 1.4 $     $Date: 2002/04/14 10:14:55 $
 *
 * Abstract:
 *      Real-Time Workshop Uniform Number generator
 *      routines for use with real-time (fixed-step) and nonreal-time
 *      (variable-step) generated code.
 */

#include <math.h>
#include "rtlibsrc.h"


/* Function: rt_Urand =========================================================
 * Abstract:
 *      Uniform random number generator (random number between 0 and 1)
 */
/*LINTLIBRARY*/
real_T rt_Urand(uint_T *seed)    /* pointer to a running seed */
{
#define IA      16807                   /*      magic multiplier = 7^5  */
#define IM      2147483647              /*      modulus = 2^31-1        */
#define IQ      127773                  /*      IM div IA               */
#define IR      2836                    /*      IM modulo IA            */
#define S       4.656612875245797e-10   /*      reciprocal of 2^31-1    */
 
    uint_T hi   = *seed / IQ;
    uint_T lo   = *seed % IQ;
    int_T  test = IA * lo - IR * hi;  /* never overflows      */
 
    *seed = ((test < 0) ? (uint_T)(test + IM) : (uint_T)test);
 
    return ((real_T) (*seed *S));
 
#undef  IA
#undef  IM
#undef  IQ
#undef  IR
#undef  S
} /* end rt_Urand */


/* [EOF] rt_urand.c */
