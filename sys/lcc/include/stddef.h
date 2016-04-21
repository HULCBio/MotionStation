#ifndef __STDDEF_H
#define __STDDEF_H
#ifndef _SIZE_T_DEFINED
typedef unsigned int size_t;
#define _SIZE_T_DEFINED
#endif
typedef int ptrdiff_t;
#define offsetof(s,m) (int)&(((s *)0)->m)
#endif
