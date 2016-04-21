/* $Revision: 1.2 $ */
#ifndef _LIMITS_H___
#define CHAR_BIT 8

#ifndef MB_LEN_MAX
#define MB_LEN_MAX 2
#endif

/* Minimum and maximum values a `signed char' can hold.  */
#define SCHAR_MIN (-128)
#define SCHAR_MAX 127

/* Maximum value an `unsigned char' can hold.  (Minimum is 0).  */
#define UCHAR_MAX 255

/* Minimum and maximum values a `char' can hold.  */
#define CHAR_MIN (-128)
#define CHAR_MAX 127

/* Minimum and maximum values a `signed short int' can hold.  */
#define SHRT_MIN (-32768)
#define SHRT_MAX 32767

/* Maximum value an `unsigned short int' can hold.  (Minimum is 0).  */
#define USHRT_MAX 65535

/* Minimum and maximum values a `signed int' can hold.  */
#define __INT_MAX__ 2147483647
#define INT_MIN (-INT_MAX-1)
#define INT_MAX __INT_MAX__

/* Maximum value an `unsigned int' can hold.  (Minimum is 0).  */
#define UINT_MAX (INT_MAX * 2U + 1)

/* Minimum and maximum values a `signed long int' can hold.
   (Same as `int').  */
#define LONG_MAX 2147483647L
#define LONG_MIN (-2147483647L - 1)
/* Maximum value an `unsigned long int' can hold.  (Minimum is 0).  */
#define ULONG_MAX (LONG_MAX * 2UL + 1)
#endif /* _LIMITS_H___ */
