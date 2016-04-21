/*
 *  string.h    String functions
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
#ifndef _STRING_H_INCLUDED
#define _STRING_H_INCLUDED
#if !defined(_ENABLE_AUTODEPEND)
  #pragma read_only_file;
#endif

#ifdef __cplusplus
extern "C" {
#endif /* __cplusplus */

#ifndef _COMDEF_H_INCLUDED
 #include <_comdef.h>
#endif

#ifndef _WCHAR_T_DEFINED
#define _WCHAR_T_DEFINED
#define _WCHAR_T_DEFINED_
#ifdef __cplusplus
typedef long char wchar_t;
#else
typedef unsigned short wchar_t;
#endif
#endif

#ifndef _WCTYPE_T_DEFINED
#define _WCTYPE_T_DEFINED
#define _WCTYPE_T_DEFINED_
typedef wchar_t wint_t;
typedef wchar_t wctype_t;
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

#ifndef _NLSCMPERROR
 #include <limits.h>
 #define _NLSCMPERROR INT_MAX
#endif

_WCIRTLINK extern void *memchr( const void *__s, int __c, size_t __n );
_WCIRTLINK extern int memcmp( const void *__s1, const void *__s2, size_t __n );
_WCIRTLINK extern void *memcpy( void *__s1, const void *__s2, size_t __n );
_WCRTLINK extern void *memmove( void *__s1, const void *__s2, size_t __n );
#if defined(M_I86)
_WCIRTLINK
#else
_WCRTLINK
#endif
extern void *memset( void *__s, int __c, size_t __n );
_WCIRTLINK extern char *strcat( char *__s1, const char *__s2 );
_WCIRTLINK extern char *strchr( const char *__s, int __c );
#if defined(M_I86)
_WCIRTLINK
#else
_WCRTLINK
#endif
extern int strcmp( const char *__s1, const char *__s2 );
_WCRTLINK extern int strcoll( const char *__s1, const char *__s2 );
_WCRTLINK extern int _stricoll( const char *__s1, const char *__s2 );
_WCRTLINK extern int _strncoll( const char *__s1, const char *__s2, size_t __n );
_WCRTLINK extern int _strnicoll( const char *__s1, const char *__s2, size_t __n );
_WCRTLINK extern size_t strxfrm( char *__s1, const char *__s2, size_t __n );
_WCIRTLINK extern char *strcpy( char *__s1, const char *__s2 );
_WCRTLINK extern size_t strcspn( const char *__s1, const char *__s2 );
_WCRTLINK extern char *strerror( int __errnum );
_WCIRTLINK extern size_t strlen( const char *__s );
_WCRTLINK extern char *strncat( char *__s1, const char *__s2, size_t __n );
_WCRTLINK extern int strncmp( const char *__s1, const char *__s2, size_t __n );
_WCRTLINK extern char *strncpy( char *__s1, const char *__s2, size_t __n );
_WCRTLINK extern char *strpbrk( const char *__s1, const char *__s2 );
_WCRTLINK extern char *strrchr( const char *__s, int __c );
_WCRTLINK extern size_t strspn( const char *__s1, const char *__s2 );
_WCRTLINK extern char *strspnp( const char *__s1, const char *__s2 );
_WCRTLINK extern char *strstr( const char *__s1, const char *__s2 );
_WCRTLINK extern char *strtok( char *__s1, const char *__s2 );

#if !defined(NO_EXT_KEYS) /* extensions enabled */

/* WATCOM's Additional Functions (non-ANSI, non-POSIX) */

#if !defined(_fmemccpy) || !defined(_INC_WINDOWSX)
_WCRTLINK extern void _WCFAR *_fmemccpy( void _WCFAR *__s1, const void _WCFAR *__s2, int __c, size_t __n );
#endif
#if !defined(_fmemchr) || !defined(_INC_WINDOWSX)
_WCIRTLINK extern void _WCFAR *_fmemchr( const void _WCFAR *__s, int __c, size_t __n );
#endif
#if !defined(_fmemcpy) || !defined(_INC_WINDOWSX)
_WCIRTLINK extern void _WCFAR *_fmemcpy( void _WCFAR *__s1, const void _WCFAR *__s2, size_t __n );
#endif
#if !defined(_fmemmove) || !defined(_INC_WINDOWSX)
_WCRTLINK extern void _WCFAR *_fmemmove( void _WCFAR *__s1, const void _WCFAR *__s2, size_t __n );
#endif
#if !defined(_fmemset) || !defined(_INC_WINDOWSX)
_WCIRTLINK extern void _WCFAR *_fmemset( void _WCFAR *__s, int __c, size_t __n );
#endif
#if !defined(_fmemcmp) || !defined(_INC_WINDOWSX)
_WCIRTLINK extern int _fmemcmp( const void _WCFAR *__s1, const void _WCFAR *__s2, size_t __n );
#endif
#if !defined(_fmemicmp) || !defined(_INC_WINDOWSX)
_WCRTLINK extern int _fmemicmp( const void _WCFAR *__s1, const void _WCFAR *__s2, size_t __n );
#endif
#if !defined(_fstrcat) || !defined(_INC_WINDOWSX)
_WCIRTLINK extern char _WCFAR *_fstrcat( char _WCFAR *__s1, const char _WCFAR *__s2 );
#endif
#if !defined(_fstrchr) || !defined(_INC_WINDOWSX)
_WCRTLINK extern char _WCFAR *_fstrchr( const char _WCFAR *__s, int __c );
#endif
#if !defined(_fstrcmp) || !defined(_INC_WINDOWSX)
_WCIRTLINK extern int _fstrcmp( const char _WCFAR *__s1, const char _WCFAR *__s2 );
#endif
#if !defined(_fstrcpy) || !defined(_INC_WINDOWSX)
_WCIRTLINK extern char _WCFAR *_fstrcpy( char _WCFAR *__s1, const char _WCFAR *__s2 );
#endif
#if !defined(_fstrcspn) || !defined(_INC_WINDOWSX)
_WCRTLINK extern size_t _fstrcspn( const char _WCFAR *__s1, const char _WCFAR *__s2 );
#endif
#if !defined(_fstrdup) || !defined(_INC_WINDOWSX)
_WCRTLINK extern char _WCFAR *_fstrdup( const char _WCFAR *__string );
#endif
#if !defined(_fstricmp) || !defined(_INC_WINDOWSX)
_WCRTLINK extern int _fstricmp( const char _WCFAR *__s1, const char _WCFAR *__s2 );
#endif
#if !defined(_fstrncat) || !defined(_INC_WINDOWSX)
_WCRTLINK extern char _WCFAR *_fstrncat( char _WCFAR *__s1, const char _WCFAR *__s2, size_t __n );
#endif
#if !defined(_fstrlen) || !defined(_INC_WINDOWSX)
_WCIRTLINK extern size_t _fstrlen( const char _WCFAR *__s );
#endif
#if !defined(_fstrlwr) || !defined(_INC_WINDOWSX)
_WCRTLINK extern char _WCFAR *_fstrlwr( char _WCFAR *__string );
#endif
#if !defined(_fstrncmp) || !defined(_INC_WINDOWSX)
_WCRTLINK extern int _fstrncmp( const char _WCFAR *__s1, const char _WCFAR *__s2, size_t __n );
#endif
#if !defined(_fstrncpy) || !defined(_INC_WINDOWSX)
_WCRTLINK extern char _WCFAR *_fstrncpy( char _WCFAR *__s1, const char _WCFAR *__s2, size_t __n );
#endif
#if !defined(_fstrnicmp) || !defined(_INC_WINDOWSX)
_WCRTLINK extern int _fstrnicmp( const char _WCFAR *__s1, const char _WCFAR *__s2, size_t __n );
#endif
#if !defined(_fstrnset) || !defined(_INC_WINDOWSX)
_WCRTLINK extern char _WCFAR *_fstrnset( char _WCFAR *__string, int __c, size_t __len );
#endif
#if !defined(_fstrpbrk) || !defined(_INC_WINDOWSX)
_WCRTLINK extern char _WCFAR *_fstrpbrk( const char _WCFAR *__s1, const char _WCFAR *__s2 );
#endif
#if !defined(_fstrrchr) || !defined(_INC_WINDOWSX)
_WCRTLINK extern char _WCFAR *_fstrrchr( const char _WCFAR *__s, int __c );
#endif
#if !defined(_fstrrev) || !defined(_INC_WINDOWSX)
_WCRTLINK extern char _WCFAR *_fstrrev( char _WCFAR *__string );
#endif
#if !defined(_fstrset) || !defined(_INC_WINDOWSX)
_WCRTLINK extern char _WCFAR *_fstrset( char _WCFAR *__string, int __c );
#endif
#if !defined(_fstrspn) || !defined(_INC_WINDOWSX)
_WCRTLINK extern size_t _fstrspn( const char _WCFAR *__s1, const char _WCFAR *__s2 );
#endif
#if !defined(_fstrspnp) || !defined(_INC_WINDOWSX)
_WCRTLINK extern char _WCFAR *_fstrspnp( const char _WCFAR *__s1, const char _WCFAR *__s2 );
#endif
#if !defined(_fstrstr) || !defined(_INC_WINDOWSX)
_WCRTLINK extern char _WCFAR *_fstrstr( const char _WCFAR *__s1, const char _WCFAR *__s2 );
#endif
#if !defined(_fstrtok) || !defined(_INC_WINDOWSX)
_WCRTLINK extern char _WCFAR *_fstrtok( char _WCFAR *__s1, const char _WCFAR *__s2 );
#endif
#if !defined(_fstrupr) || !defined(_INC_WINDOWSX)
_WCRTLINK extern char _WCFAR *_fstrupr( char _WCFAR *__string );
#endif
_WCIRTLINK extern void movedata( unsigned __srcseg, unsigned __srcoff, unsigned __tgtseg, unsigned __tgtoff, unsigned __len );
_WCRTLINK extern int bcmp( const void *__s1, const void *__s2, size_t __n );
_WCRTLINK extern void bcopy( const void *__s1, void *__s2, size_t __n );
_WCRTLINK extern void bzero( void *__s, size_t __n );
_WCRTLINK extern void *memccpy( void *__s1, const void *__s2, int __c, size_t __n );
_WCRTLINK extern int memicmp( const void *__s1, const void *__s2, size_t __n );
_WCRTLINK extern int strcmpi( const char *__s1, const char *__s2 );
_WCRTLINK extern char *strdup( const char *__string );
_WCRTLINK extern int stricmp( const char *__s1, const char *__s2 );
_WCRTLINK extern char *strlwr( char *__string );
_WCRTLINK extern int strnicmp( const char *__s1, const char *__s2, size_t __n );
_WCRTLINK extern char *strnset( char *__string, int __c, size_t __len );
_WCRTLINK extern char *strrev( char *__string );
_WCRTLINK extern char *strset( char *__string, int __c );
_WCRTLINK extern char *strupr( char *__string );
#if defined(__NT__)
_WCRTLINK extern char *_doserror( int __oserrnum );
#endif
_WCRTLINK extern int _memicmp( const void *__s1, const void *__s2, size_t __n );
_WCRTLINK extern char *_strdup( const char *__string );
_WCRTLINK extern char *_strerror( const char *__s );
_WCRTLINK extern int _stricmp( const char *__s1, const char *__s2 );
_WCRTLINK extern char *_strlwr( char *__string );
_WCRTLINK extern int _strnicmp( const char *__s1, const char *__s2, size_t __n );
_WCRTLINK extern char *_strnset( char *__string, int __c, size_t __len );
_WCRTLINK extern char *_strrev( char *__string );
_WCRTLINK extern char *_strset( char *__string, int __c );
_WCRTLINK extern char *_strupr( char *__string );

_WCRTLINK extern size_t wcslen( const wchar_t * );
_WCRTLINK extern wchar_t *_wcsnset( wchar_t *, int, size_t );
_WCRTLINK extern size_t wcsspn( const wchar_t *, const wchar_t * );
_WCRTLINK extern wchar_t *_wcsspnp( const wchar_t *__s1, const wchar_t *__s2 );
_WCRTLINK extern size_t wcscspn( const wchar_t *, const wchar_t * );
_WCRTLINK extern wchar_t *wcsncat( wchar_t *, const wchar_t *, size_t );
_WCRTLINK extern int wcsncmp( const wchar_t *, const wchar_t *, size_t );
_WCRTLINK extern wchar_t *wcsncpy( wchar_t *, const wchar_t *, size_t );
_WCRTLINK extern int _wcsnicmp( const wchar_t *, const wchar_t *, size_t );
_WCRTLINK extern wchar_t *wcschr( const wchar_t *, wint_t );
_WCRTLINK extern wchar_t *_wcsdup( const wchar_t * );
_WCRTLINK extern wchar_t *wcscat( wchar_t *, const wchar_t * );
_WCRTLINK extern wchar_t *_wcslwr( wchar_t * );
_WCRTLINK extern wchar_t *_wcsupr( wchar_t * );
_WCRTLINK extern wchar_t *wcscpy( wchar_t *, const wchar_t * );
_WCRTLINK extern int wcscmp( const wchar_t *, const wchar_t * );
_WCRTLINK extern int _wcsicmp( const wchar_t *, const wchar_t * );
_WCRTLINK extern int wcscoll( const wchar_t *__s1, const wchar_t *__s2 );
_WCRTLINK extern int _wcsicoll( const wchar_t *__s1, const wchar_t *__s2 );
_WCRTLINK extern int _wcsncoll( const wchar_t *__s1, const wchar_t *__s2, size_t __n );
_WCRTLINK extern int _wcsnicoll( const wchar_t *__s1, const wchar_t *__s2, size_t __n );
_WCRTLINK extern size_t wcsxfrm( wchar_t *__s1, const wchar_t *__s2, size_t __n );
_WCRTLINK extern wchar_t *wcsstr( const wchar_t *, const wchar_t * );
_WCRTLINK extern wchar_t *wcspbrk( const wchar_t *, const wchar_t * );
_WCRTLINK extern wchar_t *wcstok( wchar_t *, const wchar_t *, wchar_t ** );
_WCRTLINK extern wchar_t *_wcsrev( wchar_t * );
_WCRTLINK extern wchar_t *_wcsset( wchar_t *, wchar_t );
_WCRTLINK extern wchar_t *wcsrchr( const wchar_t *, wint_t );
_WCRTLINK extern int wcscmpi( const wchar_t *, const wchar_t * );
_WCRTLINK extern wchar_t *wcserror( int );
_WCRTLINK extern wchar_t *_wcserror( const wchar_t * );
#if defined(__NT__)
_WCRTLINK extern wchar_t *_wdoserror( int __errnum );
#endif

_WCRTLINK extern wchar_t *_ustrtok( wchar_t *, const wchar_t * );


#endif  /* EXTENSIONS */

#ifdef  __INLINE_FUNCTIONS__
#if !defined(NO_EXT_KEYS) /* extensions enabled */
 #pragma intrinsic(movedata,_fmemchr,_fmemcmp,_fmemcpy,_fmemset)
 #pragma intrinsic(_fstrcat,_fstrcmp,_fstrcpy,_fstrlen)
#endif
 #pragma intrinsic(memchr,memcmp,memcpy,strcat,strcpy,strlen,strchr)
 #if defined(M_I86)
  #pragma intrinsic(memset,strcmp)
 #endif
#endif  /* __INLINE_FUNCTIONS__ */

#ifdef __cplusplus
};
#endif /* __cplusplus */
#endif
