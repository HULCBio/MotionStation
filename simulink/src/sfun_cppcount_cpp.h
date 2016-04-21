#ifndef _SFUN_CPPCOUNT_CPP_
#define _SFUN_CPPCOUNT_CPP_

#ifdef __cplusplus
extern "C" { /* use the C fcn-call standard for all functions*/
#endif       /* defined within this scope*/

void *createCounter();
void deleteCounter(void *obj);
double counterOutput(void *obj);

#ifdef __cplusplus
} /* end of extern "C" scope */
#endif

#endif


