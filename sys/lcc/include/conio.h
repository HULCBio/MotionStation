/* $Revision: 1.2 $ */
#ifndef _LCC_CONIO
#define _LCC_CONIO
char *  _cgets(char *);
int cprintf(char *, ...);
int cputs(char *);
int cscanf(char *, ...);
#define _cprintf cprintf
#define _cputs cputs
#define _cscanf cscanf
int getch(void);
int  getche(void);
int _np(unsigned short);
unsigned short inpw(unsigned short);
unsigned long  inpd(unsigned short);
int _kbhit(void);
int _outp(unsigned short, int);
unsigned short _outpw(unsigned short, unsigned short);
unsigned long _outpd(unsigned short, unsigned long);
int _inp(unsigned short i);
unsigned short _inpw(unsigned short i);
unsigned long _inpd(unsigned short i);
int putch(int);
int ungetch(int);
#define _getch	getch
#define _getche	getche
#define _kbhit	kbhit
#define _putch	putch
#define _ungetch ungetch
#endif
