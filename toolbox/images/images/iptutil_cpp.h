//
// Copyright 1993-2003 The MathWorks, Inc.
// $Revision: 1.1.6.4 $
//

//Utilities for C++ IPT mex functions

#ifndef IPTUTIL_CPP_H
#define IPTUTIL_CPP_H

//////////////////////////////////////////////////////////////////////////////
// MACROS
//////////////////////////////////////////////////////////////////////////////

#define DUMMY 0 //Part of the workaround for MS VC++ limitations

//Useful in formulating an error message for uninitialized class variables
#define ERR_STRING(a,b) "Class variable " a " must be" \
" properly initialized prior to calling " b ".\n"

//Macro useful for assigning method pointers.  It is designed to work
//with compilers on different platforms
#if defined(__GNUC__) || defined(ARCH_HPUX) || defined(ARCH_IBM_RS) || \
    defined(ARCH_HP700)
#define MPTR(a) (&a)
#else
#define MPTR(a) (a)
#endif

#endif // IPTUTIL_CPP_H
