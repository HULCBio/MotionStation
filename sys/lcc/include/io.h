#ifndef _INCLUDE_IO
#define _INCLUDE_IO
#include <sys\stat.h>
struct _finddata_t {
    unsigned	attrib;
    unsigned long	time_create;	/* -1 for FAT file systems */
    unsigned long	time_access;	/* -1 for FAT file systems */
    unsigned long	time_write;
    unsigned long	size;
    char	name[260];
};


struct _wfinddata_t {
    unsigned	attrib;
    unsigned long	time_create;	/* -1 for FAT file systems */
    unsigned long	time_access;	/* -1 for FAT file systems */
    unsigned long	time_write;
    unsigned long	size;
    unsigned short	name[260];
};


#define _A_NORMAL	0x00	/* Normal file */
#define _A_RDONLY	0x01	/* Read only file */
#define _A_HIDDEN	0x02	/* Hidden file */
#define _A_SYSTEM	0x04	/* System file */
#define _A_SUBDIR	0x10	/* Subdirectory */
#define _A_ARCH 	0x20	/* Archive file */


int  access(const char *, int);
#define _access access
int  chmod(const char *, int);
#define _chmod chmod
int  chsize(int, long);
#define _chsize chsize
int  _close(int);
int  _commit(int);
int  _creat(const char *, int);
int  _dup(int);
int  _dup2(int, int);
int  _eof(int);
long  _filelength(int);
long  _findfirst(char *, struct _finddata_t *);
int  _findnext(long, struct _finddata_t *);
int  _findclose(long);
int  _isatty(int);
int  _locking(int, int, long);
long  _lseek(int, long, int);
char *  _mktemp(char *);
int  open(const char *, int, ...);
int _open(const char *,int,...);
int  _pipe(int *, unsigned int, int);
int  _read(int, void *, unsigned int);
int  remove(char *);
int  rename(char *, char *);
int  _setmode(int, int);
int  _sopen(const char *, int, int, ...);
long  _tell(int);
int  _umask(int);
int  _unlink(char *);
int  _write(int, const void *, unsigned int);


int  _waccess(const unsigned short *, int);
int  _wchmod(const unsigned short *, int);
int  _wcreat(const unsigned short *, int);
long  _wfindfirst(unsigned short *, struct _wfinddata_t *);
int  _wfindnext(long, struct _wfinddata_t *);
int  _wunlink(const unsigned short *);
int  _wrename(const unsigned short *, const unsigned short *);
int  _wopen(const unsigned short *, int, ...);
int  _wsopen(const unsigned short *, int, int, ...);
unsigned short *  _wmktemp(unsigned short *);

long  get_osfhandle(int);
int  open_osfhandle(long, int);
#define _open_osfhandle open_osfhandle
#define _get_osfhandle get_osfhandle


int  access(const char *, int);
int  chmod(const char *, int);
int  chsize(int, long);
int  close(int);
int  creat(const char *, int);
int  dup(int);
int  dup2(int, int);
int  eof(int);
long  filelength(int);
int  isatty(int);
int  locking(int, int, long);
long  lseek(int, long, int);
char *  mktemp(char *);
int  open(const char *, int, ...);
int  read(int, void *, unsigned int);
int  setmode(int, int);
int  sopen(const char *, int, int, ...);
long  tell(int);
int  umask(int);
int  write(int, const void *, unsigned int);
int _stdcall _lclose(int);
int _stdcall _lopen(const char *,int);
unsigned int _stdcall _lwrite(int,const char *,unsigned int);
unsigned int _stdcall _lread(int,void *,unsigned int);
#endif	/* _INCLUDE_IO */
