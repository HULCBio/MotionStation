/*
 * stdlib.h  Definitions for common types, variables, and functions.  */

#ifndef _STDLIB_H_
#define _STDLIB_H_
#include <stddef.h>
#include <_syslist.h>
#define _MAX_PATH 260
#define _MAX_FNAME	256
#define _MAX_EXT	256
#define _MAX_DRIVE	3
#define _MAX_DIR	256
typedef struct {
  int quot; /* quotient */
  int rem; /* remainder */
} div_t;

typedef struct {
  long quot; /* quotient */
  long rem; /* remainder */
} ldiv_t;

#ifndef NULL
#define NULL 0L
#endif

#ifndef EXIT_FAILURE
#define EXIT_FAILURE 1
#define EXIT_SUCCESS 0
#endif
#ifndef RAND_MAX
#define RAND_MAX 0x7fff
#endif
#define _OUT_TO_DEFAULT	0
#define _OUT_TO_STDERR	1
#define _OUT_TO_MSGBOX	2
#define _REPORT_ERRMODE	3
void	abort(void);
int	abs(int);
int	atexit(void (*_func)(void));
double	atof(char *_nptr);
int	atoi(char *_nptr);
//long long atoll(char *str);
char    *itoa(int,char *,int);
char	*ltoa(long,char *,int);
long	atol(char *_nptr);
void *	bsearch(const void * _key,void * _base, size_t _nmemb, size_t _size,
		       int (*_compar)(void *, void *));
void *	calloc(size_t _nmemb, size_t _size);
div_t	div(int _numer, int _denom);
void	exit(int _status);
void	free(void *);
char	*_fullpath( char *absPath, const char *relPath, size_t maxLength );
char *  getenv(char *_string);
long	labs(long);
ldiv_t	ldiv(long _numer, long _denom);
void *	malloc(size_t _size);
unsigned long _lrotl(unsigned long,int);
unsigned long _rotl(unsigned int,int);
void	qsort(void * _base, size_t _nmemb, size_t _size, int(*_compar)(const void *, const void *));
int	rand(void);
void *	realloc(void * _r, size_t _size);
void	srand(unsigned _seed);
double	strtod(const char *_n, char **_endvoid);
long	strtol(const char *_n, char **_endvoid, int _base);
unsigned long strtoul(const char *_n, char **_end, int _base);
int	system(char *_string);
int	putenv(char *_string);
int	setenv(char *_string, char *_value, int _overwrite);
char *	_gcvt(double,int,char *);
char *	_fcvt(double,int,int *,int *);
char *	_ecvt(double,int,int *,int *);
int     mbstowcs(unsigned short *,char *,int);
int	mblen(char *,int);
int	mbstrlen(char *s);
extern int _sleep(unsigned long);
#define sleep _sleep
#define	_mbstrlen mbstrlen
#define CRTAPI1
#define _fmode *(_imp___fmode_dll)
extern int _fmode;
extern char **_environ;
extern unsigned int _osver;
extern unsigned int *(_imp___osver);
#define _osver *(_imp___osver)
extern unsigned int _winmajor;
extern unsigned int *(_imp___winmajor);
#define _winmajor *(_imp___winmajor)
extern unsigned int _winminor;
extern unsigned int *(_imp___winminor);
#define _winminor *(_imp___winminor)
extern unsigned int _winver;
extern unsigned int *(_imp___winver);
#define _winver *(_imp___winver)
#endif /* _STDLIB_H_ */
