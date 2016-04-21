/* $Revision: 1.2 $ */
#ifndef _LCC_WCHAR
#define _LCC_WCHAR
#include <stdio.h>
#pragma pack(push,8)

#ifndef _SIZE_T_DEFINED
typedef unsigned int size_t;
#define _SIZE_T_DEFINED
#endif

#ifndef _TIME_T_DEFINED
typedef long time_t;
#define _TIME_T_DEFINED
#endif

#ifndef _WCHAR_T_DEFINED
typedef unsigned short wchar_t;
#define _WCHAR_T_DEFINED
#endif


#ifndef _WCTYPE_T_DEFINED
typedef wchar_t wint_t;
typedef wchar_t wctype_t;
#define _WCTYPE_T_DEFINED
#endif


#ifndef _VA_LIST_DEFINED
typedef char *  va_list;
#define _VA_LIST_DEFINED
#endif

#ifndef WEOF
#define WEOF (wint_t)(0xFFFF)
#endif


#ifndef _FSIZE_T_DEFINED
typedef unsigned long _fsize_t; /* Could be 64 bits for Win32 */
#define _FSIZE_T_DEFINED
#endif

#ifndef _WFINDDATA_T_DEFINED

struct _wfinddata_t {
        unsigned attrib;
        time_t   time_create;   /* -1 for FAT file systems */
        time_t   time_access;   /* -1 for FAT file systems */
        time_t   time_write;
        _fsize_t size;
        wchar_t  name[260];
};

#if     !defined(_M_MPPC) && !defined(_M_M68K)
#if     _INTEGRAL_MAX_BITS >= 64
struct _wfinddatai64_t {
        unsigned attrib;
        time_t   time_create;   /* -1 for FAT file systems */
        time_t   time_access;   /* -1 for FAT file systems */
        time_t   time_write;
        __int64  size;
        wchar_t  name[260];
};
#endif
#endif

#define _WFINDDATA_T_DEFINED
#endif

/*
 * This declaration allows the user access to the ctype look-up
 * array _ctype defined in ctype.obj by simply including ctype.h
 */


extern unsigned short * _ctype;
#define _pctype     (*_pctype_dll)
extern unsigned short **_pctype_dll;
#define _pwctype    (*_pwctype_dll)
extern unsigned short **_pwctype_dll;

#define _UPPER      0x1     /* upper case letter */
#define _LOWER      0x2     /* lower case letter */
#define _DIGIT      0x4     /* digit[0-9] */
#define _SPACE      0x8     /* tab, carriage return, newline, */
                            /* vertical tab or form feed */
#define _PUNCT      0x10    /* punctuation character */
#define _CONTROL    0x20    /* control character */
#define _BLANK      0x40    /* space char */
#define _HEX        0x80    /* hexadecimal digit */

#define _LEADBYTE   0x8000  /* multibyte leadbyte */
#define _ALPHA      (0x0100|_UPPER|_LOWER)  /* alphabetic character */

#ifndef _WCTYPE_DEFINED

/* Character classification function prototypes */
/* also declared in ctype.h */

 int  iswalpha(wint_t);
 int  iswupper(wint_t);
 int  iswlower(wint_t);
 int  iswdigit(wint_t);
 int  iswxdigit(wint_t);
 int  iswspace(wint_t);
 int  iswpunct(wint_t);
 int  iswalnum(wint_t);
 int  iswprint(wint_t);
 int  iswgraph(wint_t);
 int  iswcntrl(wint_t);
 int  iswascii(wint_t);
 int  isleadbyte(int);

 wchar_t  towupper(wchar_t);
 wchar_t  towlower(wchar_t);

 int  iswctype(wint_t, wctype_t);
#define _WCTYPE_DEFINED
#endif

#ifndef _WDIRECT_DEFINED

/* also declared in direct.h */

 int  _wchdir(const wchar_t *);
 wchar_t *  _wgetcwd(wchar_t *, int);
 wchar_t *  _wgetdcwd(int, wchar_t *, int);
 int  _wmkdir(const wchar_t *);
 int  _wrmdir(const wchar_t *);

#define _WDIRECT_DEFINED
#endif

#ifndef _WIO_DEFINED

/* also declared in io.h */

 int  _waccess(const wchar_t *, int);
 int  _wchmod(const wchar_t *, int);
 int  _wcreat(const wchar_t *, int);
 long  _wfindfirst(const wchar_t *, struct _wfinddata_t *);
 int  _wfindnext(long, struct _wfinddata_t *);
 int  _wunlink(const wchar_t *);
 int  _wrename(const wchar_t *, const wchar_t *);
 int  _wopen(const wchar_t *, int, ...);
 int  _wsopen(const wchar_t *, int, int, ...);
 wchar_t *  _wmktemp(wchar_t *);
#define _WIO_DEFINED
#endif

#ifndef _WLOCALE_DEFINED

 wchar_t *  _wsetlocale(int, const wchar_t *);

#define _WLOCALE_DEFINED
#endif

#ifndef _WPROCESS_DEFINED

/* also declared in process.h */

 int  _wexecl(const wchar_t *, const wchar_t *, ...);
 int  _wexecle(const wchar_t *, const wchar_t *, ...);
 int  _wexeclp(const wchar_t *, const wchar_t *, ...);
 int  _wexeclpe(const wchar_t *, const wchar_t *, ...);
 int  _wexecv(const wchar_t *, const wchar_t * const *);
 int  _wexecve(const wchar_t *, const wchar_t * const *, const wchar_t * const *);
 int  _wexecvp(const wchar_t *, const wchar_t * const *);
 int  _wexecvpe(const wchar_t *, const wchar_t * const *, const wchar_t * const *);
 int  _wspawnl(int, const wchar_t *, const wchar_t *, ...);
 int  _wspawnle(int, const wchar_t *, const wchar_t *, ...);
 int  _wspawnlp(int, const wchar_t *, const wchar_t *, ...);
 int  _wspawnlpe(int, const wchar_t *, const wchar_t *, ...);
 int  _wspawnv(int, const wchar_t *, const wchar_t * const *);
 int  _wspawnve(int, const wchar_t *, const wchar_t * const *,
        const wchar_t * const *);
 int  _wspawnvp(int, const wchar_t *, const wchar_t * const *);
 int  _wspawnvpe(int, const wchar_t *, const wchar_t * const *,
        const wchar_t * const *);
 int  _wsystem(const wchar_t *);

#define _WPROCESS_DEFINED
#endif

#define iswalpha(_c)    ( iswctype(_c,_ALPHA) )
#define iswupper(_c)    ( iswctype(_c,_UPPER) )
#define iswlower(_c)    ( iswctype(_c,_LOWER) )
#define iswdigit(_c)    ( iswctype(_c,_DIGIT) )
#define iswxdigit(_c)   ( iswctype(_c,_HEX) )
#define iswspace(_c)    ( iswctype(_c,_SPACE) )
#define iswpunct(_c)    ( iswctype(_c,_PUNCT) )
#define iswalnum(_c)    ( iswctype(_c,_ALPHA|_DIGIT) )
#define iswprint(_c)    ( iswctype(_c,_BLANK|_PUNCT|_ALPHA|_DIGIT) )
#define iswgraph(_c)    ( iswctype(_c,_PUNCT|_ALPHA|_DIGIT) )
#define iswcntrl(_c)    ( iswctype(_c,_CONTROL) )
#define iswascii(_c)    ( (unsigned)(_c) < 0x80 )

#define isleadbyte(_c)  (_pctype[(unsigned char)(_c)] & _LEADBYTE)

#if !defined(_POSIX_)

/* define structure for returning status information */

#ifndef _INO_T_DEFINED

typedef unsigned short _ino_t;  /* i-node number (not used on DOS) */

#if     !__STDC__
/* Non-ANSI name for compatibility */
#ifdef  _NTSDK
#define ino_t _ino_t
#else   /* ndef _NTSDK */
typedef unsigned short ino_t;
#endif  /* _NTSDK */
#endif

#define _INO_T_DEFINED
#endif


#ifndef _DEV_T_DEFINED

#ifdef  _NTSDK
typedef short _dev_t;           /* device code */
#else   /* ndef _NTSDK */
typedef unsigned int _dev_t;    /* device code */
#endif  /* _NTSDK */

#if     !__STDC__
/* Non-ANSI name for compatibility */
#ifdef  _NTSDK
#define dev_t _dev_t
#else   /* ndef _NTSDK */
typedef unsigned int dev_t;
#endif  /* _NTSDK */
#endif

#define _DEV_T_DEFINED
#endif

#ifndef _OFF_T_DEFINED

typedef long _off_t;            /* file offset value */

#if     !__STDC__
/* Non-ANSI name for compatibility */
#ifdef  _NTSDK
#define off_t _off_t
#else   /* ndef _NTSDK */
typedef long off_t;
#endif  /* _NTSDK */
#endif

#define _OFF_T_DEFINED
#endif

#ifndef _STAT_DEFINED

struct _stat {
        _dev_t st_dev;
        _ino_t st_ino;
        unsigned short st_mode;
        short st_nlink;
        short st_uid;
        short st_gid;
        _dev_t st_rdev;
        _off_t st_size;
        time_t st_atime;
        time_t st_mtime;
        time_t st_ctime;
        };

#if     !__STDC__ && !defined(_NTSDK)

/* Non-ANSI names for compatibility */

struct stat {
        _dev_t st_dev;
        _ino_t st_ino;
        unsigned short st_mode;
        short st_nlink;
        short st_uid;
        short st_gid;
        _dev_t st_rdev;
        _off_t st_size;
        time_t st_atime;
        time_t st_mtime;
        time_t st_ctime;
        };

#endif  /* __STDC__ */

#if     _INTEGRAL_MAX_BITS >= 64
struct _stati64 {
        _dev_t st_dev;
        _ino_t st_ino;
        unsigned short st_mode;
        short st_nlink;
        short st_uid;
        short st_gid;
        _dev_t st_rdev;
        __int64 st_size;
        time_t st_atime;
        time_t st_mtime;
        time_t st_ctime;
        };
#endif

#define _STAT_DEFINED
#endif


#ifndef _WSTAT_DEFINED

/* also declared in stat.h */

 int  _wstat(const wchar_t *, struct _stat *);

#if     _INTEGRAL_MAX_BITS >= 64
 int  _wstati64(const wchar_t *, struct _stati64 *);
#endif

#define _WSTAT_DEFINED
#endif

#endif  /* !_POSIX_ */


#ifndef _WSTDIO_DEFINED

/* also declared in stdio.h */

#ifdef  _POSIX_
 FILE *  _wfsopen(const wchar_t *, const wchar_t *);
#else
 FILE *  _wfsopen(const wchar_t *, const wchar_t *, int);
#endif

 wint_t  fgetwc(FILE *);
 wint_t  _fgetwchar(void);
 wint_t  fputwc(wint_t, FILE *);
 wint_t  _fputwchar(wint_t);
 wint_t  getwc(FILE *);
 wint_t  getwchar(void);
 wint_t  putwc(wint_t, FILE *);
 wint_t  putwchar(wint_t);
 wint_t  ungetwc(wint_t, FILE *);

 wchar_t *  fgetws(wchar_t *, int, FILE *);
 int  fputws(const wchar_t *, FILE *);
 wchar_t *  _getws(wchar_t *);
 int  _putws(const wchar_t *);

 int  fwprintf(FILE *, const wchar_t *, ...);
 int  wprintf(const wchar_t *, ...);
 int  _snwprintf(wchar_t *, size_t, const wchar_t *, ...);
 int  swprintf(wchar_t *, const wchar_t *, ...);
 int  vfwprintf(FILE *, const wchar_t *, va_list);
 int  vwprintf(const wchar_t *, va_list);
 int  _vsnwprintf(wchar_t *, size_t, const wchar_t *, va_list);
 int  vswprintf(wchar_t *, const wchar_t *, va_list);
 int  fwscanf(FILE *, const wchar_t *, ...);
 int  swscanf(const wchar_t *, const wchar_t *, ...);
 int  wscanf(const wchar_t *, ...);

#define getwchar()      fgetwc(stdin)
#define putwchar(_c)    fputwc((_c),stdout)
#define getwc(_stm)     fgetwc(_stm)
#define putwc(_c,_stm)  fputwc(_c,_stm)

 FILE *  _wfdopen(int, const wchar_t *);
 FILE *  _wfopen(const wchar_t *, const wchar_t *);
 FILE *  _wfreopen(const wchar_t *, const wchar_t *, FILE *);
 void  _wperror(const wchar_t *);
 FILE *  _wpopen(const wchar_t *, const wchar_t *);
 int  _wremove(const wchar_t *);
 wchar_t *  _wtempnam(const wchar_t *, const wchar_t *);
 wchar_t *  _wtmpnam(wchar_t *);

#define _WSTDIO_DEFINED
#endif


#ifndef _WSTDLIB_DEFINED

/* also declared in stdlib.h */

 wchar_t *  _itow (int, wchar_t *, int);
 wchar_t *  _ltow (long, wchar_t *, int);
 wchar_t *  _ultow (unsigned long, wchar_t *, int);
 double  wcstod(const wchar_t *, wchar_t **);
 long    wcstol(const wchar_t *, wchar_t **, int);
 unsigned long  wcstoul(const wchar_t *, wchar_t **, int);
 wchar_t *  _wgetenv(const wchar_t *);
 int     _wsystem(const wchar_t *);
 int  _wtoi(const wchar_t *);
 long  _wtol(const wchar_t *);

#define _WSTDLIB_DEFINED
#endif


#ifndef _WSTDLIBP_DEFINED

/* also declared in stdlib.h  */

 wchar_t *  _wfullpath(wchar_t *, const wchar_t *, size_t);
 void    _wmakepath(wchar_t *, const wchar_t *, const wchar_t *, const wchar_t *,
        const wchar_t *);
 void    _wperror(const wchar_t *);
 int     _wputenv(const wchar_t *);
 void    _wsearchenv(const wchar_t *, const wchar_t *, wchar_t *);
 void    _wsplitpath(const wchar_t *, wchar_t *, wchar_t *, wchar_t *, wchar_t *);

#define _WSTDLIBP_DEFINED
#endif


#ifndef _WSTRING_DEFINED

 wchar_t *  wcscat(wchar_t *, const wchar_t *);
 wchar_t *  wcschr(const wchar_t *, wchar_t);
 int  wcscmp(const wchar_t *, const wchar_t *);
 wchar_t *  wcscpy(wchar_t *, const wchar_t *);
 size_t  wcscspn(const wchar_t *, const wchar_t *);
 size_t  wcslen(const wchar_t *);
 wchar_t *  wcsncat(wchar_t *, const wchar_t *, size_t);
 int  wcsncmp(const wchar_t *, const wchar_t *, size_t);
 wchar_t *  wcsncpy(wchar_t *, const wchar_t *, size_t);
 wchar_t *  wcspbrk(const wchar_t *, const wchar_t *);
 wchar_t *  wcsrchr(const wchar_t *, wchar_t);
 size_t  wcsspn(const wchar_t *, const wchar_t *);
 wchar_t *  wcsstr(const wchar_t *, const wchar_t *);
 wchar_t *  wcstok(wchar_t *, const wchar_t *);

 wchar_t *  _wcsdup(const wchar_t *);
 int  _wcsicmp(const wchar_t *, const wchar_t *);
 int  _wcsnicmp(const wchar_t *, const wchar_t *, size_t);
 wchar_t *  _wcsnset(wchar_t *, wchar_t, size_t);
 wchar_t *  _wcsrev(wchar_t *);
 wchar_t *  _wcsset(wchar_t *, wchar_t);

 wchar_t *  _wcslwr(wchar_t *);
 wchar_t *  _wcsupr(wchar_t *);
 size_t  wcsxfrm(wchar_t *, const wchar_t *, size_t);
 int  wcscoll(const wchar_t *, const wchar_t *);
 int  _wcsicoll(const wchar_t *, const wchar_t *);
 int  _wcsncoll(const wchar_t *, const wchar_t *, size_t);
 int  _wcsnicoll(const wchar_t *, const wchar_t *, size_t);

/* Old names */
#define wcswcs wcsstr

#if     !__STDC__

#ifdef _NTSDK

/* Non-ANSI names for compatibility */
#define wcsdup  _wcsdup
#define wcsicmp _wcsicmp
#define wcsnicmp _wcsnicmp
#define wcsnset _wcsnset
#define wcsrev  _wcsrev
#define wcsset  _wcsset
#define wcslwr  _wcslwr
#define wcsupr  _wcsupr
#define wcsicoll _wcsicoll

#else /* ndef _NTSDK */

/* prototypes for oldnames.lib functions */
 wchar_t *  wcsdup(const wchar_t *);
 int  wcsicmp(const wchar_t *, const wchar_t *);
 int  wcsnicmp(const wchar_t *, const wchar_t *, size_t);
 wchar_t *  wcsnset(wchar_t *, wchar_t, size_t);
 wchar_t *  wcsrev(wchar_t *);
 wchar_t *  wcsset(wchar_t *, wchar_t);
 wchar_t *  wcslwr(wchar_t *);
 wchar_t *  wcsupr(wchar_t *);
 int  wcsicoll(const wchar_t *, const wchar_t *);

#endif /* ndef _NTSDK */

#endif /* !__STDC__ */

#define _WSTRING_DEFINED
#endif

#ifndef _TM_DEFINED
struct tm {
        int tm_sec;     /* seconds after the minute - [0,59] */
        int tm_min;     /* minutes after the hour - [0,59] */
        int tm_hour;    /* hours since midnight - [0,23] */
        int tm_mday;    /* day of the month - [1,31] */
        int tm_mon;     /* months since January - [0,11] */
        int tm_year;    /* years since 1900 */
        int tm_wday;    /* days since Sunday - [0,6] */
        int tm_yday;    /* days since January 1 - [0,365] */
        int tm_isdst;   /* daylight savings time flag */
        };
#define _TM_DEFINED
#endif

#ifndef _WTIME_DEFINED

 wchar_t *  _wasctime(const struct tm *);
 wchar_t *  _wctime(const time_t *);
 size_t  wcsftime(wchar_t *, size_t, const wchar_t *,
        const struct tm *);
 wchar_t *  _wstrdate(wchar_t *);
 wchar_t *  _wstrtime(wchar_t *);

#define _WTIME_DEFINED
#endif


#pragma pack(pop)

#endif


