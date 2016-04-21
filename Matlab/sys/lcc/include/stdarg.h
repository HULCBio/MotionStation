/* $Revision: 1.2 $ */
#ifndef _INC_STDARG
#define _INC_STDARG
#ifndef _VA_LIST_DEFINED
typedef char *	va_list;
#define _VA_LIST_DEFINED
#endif
#define _INTSIZEOF(n)	( (sizeof(n) + sizeof(int) - 1) & ~(sizeof(int) - 1) )
#define va_start(ap,v)	( ap = (va_list)&v + _INTSIZEOF(v) )
#define va_arg(ap,t)	( *(t *)((ap += _INTSIZEOF(t)) - _INTSIZEOF(t)) )
#define va_end(ap)	( ap = (va_list)0 )
#endif	/* _INC_STDARG */
