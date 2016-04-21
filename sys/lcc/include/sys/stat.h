/* $Revision: 1.2 $ */
/*
*sys/stat.h - defines structure used by stat() and fstat()
*/

#ifndef _INC_STAT
#define _INC_STAT
#pragma pack(push,8)
struct stat {
	unsigned short st_dev;
	unsigned short st_ino;
	unsigned short st_mode;
	short st_nlink;
	short st_uid;
	short st_gid;
	unsigned long st_rdev;
	long st_size;
	long st_atime;
	long st_mtime;
	long st_ctime;
	};
#define _stat stat

#define _S_IFMT 	0170000 	/* file type mask */
#define _S_IFDIR	0040000 	/* directory */
#define _S_IFCHR	0020000 	/* character special */
#define _S_IFIFO	0010000 	/* pipe */
#define _S_IFREG	0100000 	/* regular */
#define _S_IREAD	0000400 	/* read permission, owner */
#define _S_IWRITE	0000200 	/* write permission, owner */
#define _S_IEXEC	0000100 	/* execute/search permission, owner */

#define S_IFMT         0170000
#define S_IFDIR        0040000
#define S_IFCHR        0020000
#define S_IFIFO        0010000
#define S_IFREG        0100000
#define S_IREAD        0000400
#define S_IWRITE       0000200
#define S_IEXEC        0000100

/* Function prototypes */

int fstat(int, struct stat *);
#define _fstat fstat
int stat(char *, struct stat *);
int umask(int);
#define _umask umask
#pragma pack(pop)
#endif	/* _INC_STAT */
