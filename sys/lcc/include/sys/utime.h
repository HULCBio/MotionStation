/* $Revision: 1.2 $ */
#ifndef _INC_UTIME
#define _INC_UTIME
#pragma pack(push,8)
struct _utimbuf {
	long actime;		/* access time */
	long modtime; 	/* modification time */
	};
#define utimbuf _utimbuf
int _utime(const char *, struct _utimbuf *);
int _futime(int, struct _utimbuf *);
int _wutime(const short *, struct _utimbuf *);
#pragma pack(pop)
#endif	/* _INC_UTIME */
