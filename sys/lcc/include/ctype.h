/* $Revision: 1.2 $ */
#ifndef _CTYPE_H_
#define _CTYPE_H_

int isalnum (int c);
int isalpha (int c);
int iscntrl (int c);
int isdigit (int c);
int isgraph (int c);
int islower (int c);
int isprint (int c);
int ispunct (int c);
int isspace (int c);
int isupper (int c);
int isxdigit(int c);
int tolower (int c);
int toupper (int c);

int isascii (int c);
int toascii (int c);
int _tolower (int c);
int _toupper (int c);

#define	_UPPER		01
#define	_LOWER		02
#define	_DIGIT		04
#define	_SPACE		010
#define _PUNCT		020
#define _CONTROL	040
#define _HEX		0100
#define	_BLANK		0200

extern	unsigned char	_ctype[];

#define	isalpha(c)	((_ctype+1)[c]&(_UPPER|_LOWER))
#define	isupper(c)	((_ctype+1)[c]&_UPPER)
#define	islower(c)	((_ctype+1)[c]&_LOWER)
#define	isdigit(c)	((_ctype+1)[c]&_DIGIT)
#define	isxdigit(c)	((_ctype+1)[c]&(_HEX|_DIGIT))
#define	isspace(c)	((_ctype+1)[c]&_SPACE)
#define ispunct(c)	((_ctype+1)[c]&_PUNCT)
#define isalnum(c)	((_ctype+1)[c]&(_UPPER|_LOWER|_DIGIT))
#define isprint(c)	((_ctype+1)[c]&(_PUNCT|_UPPER|_LOWER|_DIGIT|_BLANK))
#define	isgraph(c)	((_ctype+1)[c]&(_PUNCT|_UPPER|_LOWER|_DIGIT))
#define iscntrl(c)	((_ctype+1)[c]&_CONTROL)

#define isascii(c)	((unsigned)(c)<=0177)
#define toascii(c)	((c)&0177)

#endif /* _CTYPE_H_ */
