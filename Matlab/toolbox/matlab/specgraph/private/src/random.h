/* Copyright 1993-2002 The MathWorks, Inc.  */

/*
  Source file for reducep MEX file
*/

/* $Revision: 1.4 $ */

#ifndef GFXMATH_RANDOM_INCLUDED // -*- C++ -*-
#define GFXMATH_RANDOM_INCLUDED

#include <stdlib.h>
#include <limits.h>

//
// Generate random numbers in [0..1]
#define GFX_USE_RAND
inline real random1()
{
#if defined(WIN32) || defined(GFX_USE_RAND)
	return (real)rand() / (real)LONG_MAX;
#else
	return (real)random() / (real)LONG_MAX;
#endif
}



// GFXMATH_RANDOM_INCLUDED
#endif
