/* $Revision: 1.2 $ */
/* string.h * Definitions for memory and string functions.  */
#ifndef _STRING_H_DEFINED_
#define	_STRING_H_DEFINED_
#ifndef _SIZE_T_DEFINED
#define _SIZE_T_DEFINED
typedef int size_t;
#endif
#ifndef NULL
#define NULL 0L
#endif
void *	 memchr(const void *, int, size_t);
int 	 memcmp(const void *, const void *, size_t);
void * 	 memcpy(void *, const void *, size_t);
void *	 memmove(void *, const void *, size_t);
void *	 memset(void *, int, size_t);
char 	*strcat(char *, const char *);
char 	*strchr(const char *, int);
int	 strcmp(const char *, const char *);
int	 strcoll(const char *, const char *);
#if __LCCOPTIMLEVEL > 0
char * _stdcall strcpy(char *,const char *);
#else
char 	* strcpy(char *, const char *);
#endif
size_t	 strcspn(const char *, const char *);
char    *strupr(char *);
char    *strlwr(char *);
char 	*strerror(int);
size_t	 strlen(const char *);
char 	*strncat(char *, const char *, size_t);
int	 strncmp(const char *, const char *, size_t);
char 	*strncpy(char *, const char *, size_t);
char 	*strpbrk(const char *, const char *);
char 	*strrchr(const char *, int);
size_t	 strspn(const char *, const char *);
char 	*strstr(const char *, const char *);
char 	*strtok(char *, const char *);
void *	 memccpy(void *, const void *, int, size_t);
int	 strcmpi(const char *, const char *);
char 	*strdup(const char *);
int	 strnicmp(const char *, const char *, size_t);
void	 swab(const char *, char *, size_t);
#define _stricmp strcmpi
#endif /* _STRING_H_DEFINED_ */
