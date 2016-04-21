/* $Revision: 1.2 $ */
/*
Intrinsics recognized by lcc-win32
*/
typedef unsigned char _bcdDigit[10];

double _stdcall _fsincos(double,double *);
double _stdcall	_fbld(_bcdDigit *d);
void _stdcall _fbstp(_bcdDigit *d,double v);
void _stdcall _itobcd(_bcdDigit *d,int i);
long _stdcall _bswap(long);
long _stdcall _fistp(double);
double _stdcall _fabs(double);
double _stdcall _fldpi(void);
double _stdcall _fldl2e(void);
double _stdcall _fldlg2(void);
double _stdcall _fldln2(void);
int _stdcall _carry(void);
int _stdcall _bsf(unsigned int);
int _stdcall _bsr(unsigned int);
long long _stdcall _rdtsc(void);
typedef struct _cpuIdentification {
	char Vendor[16];
	unsigned Stepping:4;
	unsigned Model:4;
	unsigned Family:4;
	unsigned Reserved1:20;
	long Features;
} _CPUID;
long long _stdcall _cpuid(_CPUID *);

