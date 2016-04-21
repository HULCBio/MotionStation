/* Copyright 1993-2002 The MathWorks, Inc.  */

/*
  Source file for reducep MEX file
*/

/* $Revision: 1.13.4.1 $ */

#ifndef GFX_STD_INCLUDED // -*- C++ -*-
#define GFX_STD_INCLUDED

/************************************************************************

  Standard base include file for all gfx-based programs.  This defines
  various common stuff that is used elsewhere.

 ************************************************************************/


#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <iostream>


#if !defined(HUGE) && !defined(_MSC_VER)
#define HUGE MAXFLOAT
#endif

//
// Define the real (ie. default floating point) type
//
#ifdef GFX_REAL_FLOAT
typedef float real;
#else
#define GFX_REAL_DOUBLE
typedef double real;
#endif

// Handle platforms which don't define M_PI in <math.h>
#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif

//
// Define min/max.
// These are defined as inlined template functions because that's a more
// C++ish thing to do.
//
#ifndef GFX_NO_MINMAX
#  ifndef min
template<class T>
inline T min(T a, T b) { return (a < b)?a:b; }

template<class T>
inline T max(T a, T b) { return (a > b)?a:b; }
#  endif
#endif

//
// For the old school, we also have MIN/MAX defined as macros.
//
#ifndef MIN
#define MIN(a,b) (((a)>(b))?(b):(a))
#define MAX(a,b) (((a)>(b))?(a):(b))
#endif


#ifndef ABS
#define ABS(x) (((x)<0)?-(x):(x))
#endif

#define GFX_DEF_FMATH
#ifdef GFX_DEF_FMATH
#ifndef fabsf
#define fabsf(a) ((float)fabs((double)a))
#endif
#define cosf(a) ((float)cos(double)a)
#define sinf(a) ((float)sin(double)a)
#endif

#ifndef FEQ_EPS
#define FEQ_EPS 1e-6
#define FEQ_EPS2 1e-12
#endif
inline bool FEQ(double a,double b,double eps=FEQ_EPS) { return fabs(a-b)<eps; }
inline bool FEQ(float a,float b,float eps=FEQ_EPS) { return fabsf(a-b)<eps; }

#ifndef GFX_NO_AXIS_NAMES
enum Axis {X=0, Y=1, Z=2, W=3};
#endif




#define fatal_error(s)  report_error(s,__FILE__,__LINE__)

#ifdef assert
#  undef assert
#endif
#define  assert(i)  (i)?((void)NULL):assert_failed(# i,__FILE__,__LINE__)

#ifdef SAFETY
#  define AssertBound(t) assert(t)
#else
#  define AssertBound(t)
#endif

//
// Define the report_error and assert_failed functions.
//
inline void report_error(const char *msg,const char *file,int line)
{
    std::cerr << msg << " ("<<file<<":"<<line<<")"<<std::endl;
    exit(1);
}

inline void assert_failed(const char *text,const char *file,int line)
{
    std::cerr << "Assertion failed: {" << text <<"} at ";
    std::cerr << file << ":" << line << std::endl;
    abort();
}

inline void assertf(int test, const char *msg,
                    const char *file=__FILE__, int line=__LINE__)
{
    if( !test )
    {
        std::cerr << "Assertion failed: " << msg << " at ";
        std::cerr << file << ":" << line << std::endl;
        abort();
    }
}

// GFX_STD_INCLUDED
#endif
