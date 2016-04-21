/* $Revision: 1.2 $ */
#ifndef ___BCD__
#define __BCD__
typedef char bcdDigit[10];
int atobcd(char *,bcdDigit *);
long long bcd2ll(bcdDigit *);
char *bcdtoa(bcdDigit *,char *);
#endif
