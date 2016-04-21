/*
 *  malloc.h    Memory allocation functions
 *
 *                          Open Watcom Project
 *
 *    Portions Copyright (c) 1983-2002 Sybase, Inc. All Rights Reserved.
 *
 *  ========================================================================
 *
 *    This file contains Original Code and/or Modifications of Original
 *    Code as defined in and that are subject to the Sybase Open Watcom
 *    Public License version 1.0 (the 'License'). You may not use this file
 *    except in compliance with the License. BY USING THIS FILE YOU AGREE TO
 *    ALL TERMS AND CONDITIONS OF THE LICENSE. A copy of the License is
 *    provided with the Original Code and Modifications, and is also
 *    available at www.sybase.com/developer/opensource.
 *
 *    The Original Code and all software distributed under the License are
 *    distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER
 *    EXPRESS OR IMPLIED, AND SYBASE AND ALL CONTRIBUTORS HEREBY DISCLAIM
 *    ALL SUCH WARRANTIES, INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF
 *    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR
 *    NON-INFRINGEMENT. Please see the License for the specific language
 *    governing rights and limitations under the License.
 *
 *  ========================================================================
 */
#ifndef _MALLOC_H_INCLUDED
#define _MALLOC_H_INCLUDED
#if !defined(_ENABLE_AUTODEPEND)
  #pragma read_only_file;
#endif

#ifdef __cplusplus
extern "C" {
#endif /* __cplusplus */

#ifndef _COMDEF_H_INCLUDED
 #include <_comdef.h>
#endif

#if defined(_M_IX86)
  #pragma pack(__push,1);
#else
  #pragma pack(__push,8);
#endif

#ifndef _SIZE_T_DEFINED
#define _SIZE_T_DEFINED
#define _SIZE_T_DEFINED_
typedef unsigned size_t;
#endif

#ifndef NULL
 #if defined(__SMALL__) || defined(__MEDIUM__) || defined(__386__) || defined(__AXP__) || defined(__PPC__)
  #define NULL   0
 #else
  #define NULL   0L
 #endif
#endif

#ifndef alloca
 _WCRTLINK extern void  *alloca(size_t __size);
 _WCRTLINK extern void  *_alloca(size_t __size);
 _WCRTLINK extern unsigned stackavail( void );
 #if defined(__AXP__) || defined(__PPC__)
  extern void *__builtin_alloca(size_t __size);
  #pragma intrinsic(__builtin_alloca);

  #define __alloca( s )  (__builtin_alloca(s))

  #define alloca( s )   ((s<stackavail())?__alloca(s):NULL)
  #define _alloca( s )  ((s<stackavail())?__alloca(s):NULL)
 #else
  extern void  *__doalloca(size_t __size);
  #pragma aux stackavail __modify __nomemory;

  #define __ALLOCA_ALIGN( s )   (((s)+(sizeof(int)-1))&~(sizeof(int)-1))
  #define __alloca( s )         __doalloca(__ALLOCA_ALIGN(s))

  #if defined(__386__)
   extern void __GRO(size_t __size);
   #pragma aux __GRO "*" __parm __routine [];
   #define alloca( s )  ((__ALLOCA_ALIGN(s)<stackavail())?(__GRO(__ALLOCA_ALIGN(s)),__alloca(s)):NULL)
   #define _alloca( s ) ((__ALLOCA_ALIGN(s)<stackavail())?(__GRO(__ALLOCA_ALIGN(s)),__alloca(s)):NULL)
  #else
   #define alloca( s )  ((__ALLOCA_ALIGN(s)<stackavail())?__alloca(s):NULL)
   #define _alloca( s ) ((__ALLOCA_ALIGN(s)<stackavail())?__alloca(s):NULL)
  #endif

  #if defined(__386__)
   #pragma aux     __doalloca =              \
            "sub esp,eax"                    \
            __parm __nomemory [__eax] __value [__esp] __modify __exact __nomemory [__esp];
  #elif defined(__SMALL__) || defined(__MEDIUM__) /* small data models */
   #pragma aux __doalloca = \
            "sub sp,ax"     \
            __parm __nomemory [__ax] __value [__sp] __modify __exact __nomemory [__sp];
  #else                                           /* large data models */
   #pragma aux __doalloca = \
            "sub sp,ax"     \
            "mov ax,sp"     \
            "mov dx,ss"     \
            __parm __nomemory [__ax] __value [__dx __ax] __modify __exact __nomemory [__dx __ax __sp];
  #endif
 #endif
#endif

#define _HEAPOK         0
#define _HEAPEMPTY      1       /* heap isn't initialized */
#define _HEAPBADBEGIN   2       /* heap header is corrupted */
#define _HEAPBADNODE    3       /* heap entry is corrupted */
#define _HEAPEND        4       /* end of heap entries (_heapwalk) */
#define _HEAPBADPTR     5       /* invalid heap entry pointer (_heapwalk) */

#define _USEDENTRY      0
#define _FREEENTRY      1

typedef struct _heapinfo {
    void _WCFAR *_pentry;       /* heap pointer */
    size_t      _size;          /* heap entry size */
    int         _useflag;       /* heap entry 'in-use' flag */
} _HEAPINFO;

_WCRTLINK extern int _heapenable( int __enabled );
_WCRTLINK extern int _heapchk( void );
_WCRTLINK extern int _nheapchk( void );
_WCRTLINK extern int _fheapchk( void );
_WCRTLINK extern int _heapset( unsigned int __fill );
_WCRTLINK extern int _nheapset( unsigned int __fill );
_WCRTLINK extern int _fheapset( unsigned int __fill );
_WCRTLINK extern int _heapwalk( struct _heapinfo *__entry );
_WCRTLINK extern int _nheapwalk( struct _heapinfo *__entry );
_WCRTLINK extern int _fheapwalk( struct _heapinfo *__entry );

_WCRTLINK extern void _heapgrow( void );
_WCRTLINK extern void _nheapgrow( void );
_WCRTLINK extern void _fheapgrow( void );
_WCRTLINK extern int _heapmin( void );
_WCRTLINK extern int _nheapmin( void );
_WCRTLINK extern int _fheapmin( void );
_WCRTLINK extern int _heapshrink( void );
_WCRTLINK extern int _nheapshrink( void );
_WCRTLINK extern int _fheapshrink( void );

_WCRTLINK extern int __nmemneed( size_t );
_WCRTLINK extern int __fmemneed( size_t );
#if !defined(_fcalloc) || !defined(_INC_WINDOWSX)
_WCRTLINK extern void _WCFAR *_fcalloc( size_t __n, size_t __size );
#endif
#if !defined(_ncalloc) || !defined(_INC_WINDOWSX)
_WCRTLINK extern void _WCNEAR *_ncalloc( size_t __n, size_t __size );
#endif
_WCRTLINK extern void * _expand( void *__ptr, size_t __size );
#if !defined(_fexpand) || !defined(_INC_WINDOWSX)
_WCRTLINK extern void _WCFAR *_fexpand( void _WCFAR *__ptr, size_t __size );
#endif
#if !defined(_nexpand) || !defined(_INC_WINDOWSX)
_WCRTLINK extern void _WCNEAR *_nexpand( void _WCNEAR *__ptr, size_t __size );
#endif
#if !defined(_ffree) || !defined(_INC_WINDOWSX)
_WCRTLINK extern void _ffree( void _WCFAR *__ptr );
#endif
#if !defined(_fmalloc) || !defined(_INC_WINDOWSX)
_WCRTLINK extern void _WCFAR * _fmalloc( size_t __size );
#endif
_WCRTLINK extern unsigned int _freect( size_t __size );
_WCRTLINK extern void _WCHUGE *halloc( long __n, size_t __size );
_WCRTLINK extern void hfree( void _WCHUGE * );
#if !defined(_nfree) || !defined(_INC_WINDOWSX)
_WCRTLINK extern void _nfree( void _WCNEAR *__ptr );
#endif
#if !defined(_nmalloc) || !defined(_INC_WINDOWSX)
_WCRTLINK extern void _WCNEAR *_nmalloc( size_t __size );
#endif
#if !defined(_nrealloc) || !defined(_INC_WINDOWSX)
_WCRTLINK extern void _WCNEAR *_nrealloc( void _WCNEAR *__ptr, size_t __size );
#endif
#if !defined(_frealloc) || !defined(_INC_WINDOWSX)
_WCRTLINK extern void _WCFAR *_frealloc( void _WCFAR *__ptr, size_t __size );
#endif
_WCRTLINK extern size_t _msize( void *__ptr );
#if !defined(_nmsize) || !defined(_INC_WINDOWSX)
_WCRTLINK extern size_t _nmsize( void _WCNEAR *__ptr );
#endif
#if !defined(_fmsize) || !defined(_INC_WINDOWSX)
_WCRTLINK extern size_t _fmsize( void _WCFAR *__ptr );
#endif

_WCRTLINK extern size_t _memavl( void );
_WCRTLINK extern size_t _memmax( void );
_WCRTLINK extern void * calloc( size_t __n, size_t __size );
_WCRTLINK extern void free( void *__ptr );
_WCRTLINK extern void * malloc( size_t __size );
_WCRTLINK extern void * realloc( void *__ptr, size_t __size );

#if defined(_M_IX86)
/* based heap function prototypes */

#define _NULLSEG ((__segment)0)
#define _NULLOFF ((void __based(void) *)~0)

_WCRTLINK extern int _bfreeseg( __segment __seg );
_WCRTLINK extern __segment _bheapseg( size_t size );
_WCRTLINK extern void __based(void) *_bcalloc( __segment __seg, size_t __num, size_t __size );
_WCRTLINK extern void __based(void) *_bexpand( __segment __seg, void __based(void) *__mem, size_t __size );
_WCRTLINK extern void _bfree( __segment __seg, void __based(void) *__mem );
_WCRTLINK extern int _bheapchk( __segment __seg );
_WCRTLINK extern int _bheapmin( __segment __seg );
_WCRTLINK extern int _bheapshrink( __segment __seg );
_WCRTLINK extern int _bheapset( __segment __seg, unsigned int __fill );
_WCRTLINK extern int _bheapwalk( __segment __seg, struct _heapinfo *__entry );
_WCRTLINK extern void __based(void) *_bmalloc( __segment __seg, size_t __size );
_WCRTLINK extern size_t _bmsize( __segment __seg, void __based(void) *__mem );
_WCRTLINK extern void __based(void) *_brealloc( __segment __seg, void __based(void) *__mem, size_t __size );
#endif

#pragma pack(__pop);
#ifdef __cplusplus
};
#endif /* __cplusplus */
#endif
