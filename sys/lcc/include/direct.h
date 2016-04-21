/* $Revision: 1.2 $ */
#ifndef _INC_DIRECT
#define _INC_DIRECT
struct _diskfree_t {
	unsigned total_clusters;
	unsigned avail_clusters;
	unsigned sectors_per_cluster;
	unsigned bytes_per_sector;
	};


int  _chdir(const char *);
int  _chdrive(int);
char *  _getcwd(char *, int);
char *  _getdcwd(int, char *, int);
int  _getdrive(void);
int  mkdir(const char *);
unsigned  _getdiskfree(unsigned, struct _diskfree_t *);
unsigned long  _getdrives(void);
int  _wchdir(const unsigned short *);
unsigned short *  _wgetcwd(unsigned short *, int);
unsigned short *  _wgetdcwd(int, unsigned short *, int);
int  _wmkdir(const unsigned short *);
int  _wrmdir(const unsigned short *);
int  chdir(const char *);
char *  getcwd(char *, int);
int  mkdir(const char *);
int  rmdir(const char *);
#define diskfree_t  _diskfree_t

#endif	/* _INC_DIRECT */
