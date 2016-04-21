/* $Revision: 1.2 $ */
#ifndef _LCC_SIGNAL
#define _LCC_SIGNAL

#define NSIG 23     /* maximum signal number + 1 */

/* Signal types */

#define SIGINT		2	/* Interrupt, normally Ctrl-C */
#define SIGILL		4	/* illegal instruction. (Bug in the code generator) */
#define SIGFPE		8	/* floating point problem */
#define SIGSEGV 	11	/* segment violation trap 13 */
#define SIGTERM 	15	/* termination signal from kill */
#define SIGBREAK	21	/* Ctrl-Break */
#define SIGABRT 	22	/* abnormal termination */

/* signal action codes */
#define SIG_DFL (void ( *)(int))0	   /* default signal action */
#define SIG_IGN (void ( *)(int))1	   /* ignore signal */
#define SIG_SGE (void ( *)(int))3	   /* signal gets error */
#define SIG_ACK (void ( *)(int))4	   /* acknowledge */

/* signal error value (returned by signal call on error) */

#define SIG_ERR (void ( *)(int))-1	   /* signal error value */
/* pointer to exception information pointers structure */
extern void * _pxcptinfoptrs;

/* Function prototypes */

extern void ( * signal(int, void (*)(int)))(int);
int raise(int);
#endif	/* _LCC_SIGNAL */
