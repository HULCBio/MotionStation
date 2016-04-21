/* $Revision: 1.2 $ */
#ifndef _FCNTL_H_INCLUDED
#define _FCNTL_H_INCLUDED
#define _O_RDONLY       0x0000  /* reading only */
#define O_RDONLY	_O_RDONLY
#define _O_WRONLY       0x0001  /* writing only */
#define O_WRONLY	_O_WRONLY
#define _O_RDWR         0x0002  /* reading and writing */
#define O_RDWR		_O_RDWR
#define _O_APPEND       0x0008  /* writes done at eof */
#define O_APPEND	_O_APPEND
/*this should be 0x100 but _lopen needs 0x1000 */
#define _O_CREAT        0x100  /* create and open file */
#define O_CREAT		_O_CREAT
#define _O_TRUNC        0x0200  /* open and truncate */
#define O_TRUNC		_O_TRUNC
#define _O_EXCL         0x0400  /* open only if file doesn't already exist */
#define O_EXCL		_O_EXCL
#define _O_TEXT         0x4000
#define O_TEXT		_O_TEXT
#define _O_BINARY       0x8000
#define O_BINARY	_O_BINARY
#define _O_RAW  _O_BINARY
#define _O_NOINHERIT    0x0080
#define _O_TEMPORARY    0x0040
#define _O_SHORT_LIVED  0x1000
#define _O_SEQUENTIAL   0x0020
#define _O_RANDOM 0x0010
#endif
