/* $Revision: 1.2 $ */
/*
	assert.h
*/

#ifdef NDEBUG           /* required by ANSI standard */
#define assert(p)  	((void)0)
#else

#define assert(p)   ((p) ? (void)0 : (void) _assertfail( \
        			"Assertion failed: ", \
    	    		"p", __FILE__, __LINE__ ) )
int _assertfail(char *__msg, char *__cond, char *__file, int __line);

#endif /* NDEBUG */
