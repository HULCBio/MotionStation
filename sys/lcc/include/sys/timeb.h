/* $Revision: 1.2 $ */
#ifndef _LCC_TIMEB
#define _LCC_TIMEB


#ifndef _TIME_T_DEFINED
typedef long time_t;
#define _TIME_T_DEFINED
#endif
#define timeb	_timeb
/* current definition */
struct timeb {
	time_t time;
	unsigned short pad0;
	unsigned long lpad0;
	unsigned short millitm;
	unsigned short pad1;
	unsigned long lpad1;
	short timezone;
	unsigned short pad2;
	unsigned long lpad2;
	short dstflag;
	};

void _ftime(struct _timeb *);
#endif	/* _LCC_TIMEB */
