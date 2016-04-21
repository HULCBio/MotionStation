/* $Revision: 1.2 $ */
#ifndef MALLOC_H_INCLUDED
#define MALLOC_H_INCLUDED
#ifndef _SIZE_T_DEFINED
#define _SIZE_T_DEFINED
typedef int size_t;
#endif
void * calloc(size_t,size_t);
void   free(void *);
void * malloc(size_t);
void *  realloc(void *, size_t);
void * _alloca(unsigned int);
#define _fmalloc malloc
#define _frealloc realloc
#define _ffree free
#endif
