/* $Revision: 1.2 $ */
/*
	setjmp.h
*/

#ifndef _SETJMP_H_
#define _SETJMP_H_
#include "_ansi.h"
typedef long jmp_buf[18];
void	longjmp(jmp_buf __jmpb, int __retval);
int	setjmp(jmp_buf __jmpb);
#endif /* _SETJMP_H_ */

