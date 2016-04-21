/*    
 *    Header file for Soft input soft output APP algorithm.
 *    Copyright 1996-2003 The MathWorks, Inc.
 *    $Revision: 1.1.6.2 $
 *    $Date: 2004/04/12 23:03:45 $
 *    Author: Mojdeh Shakeri
 */

#ifndef app_h
#define app_h

#define  TRUE_APP_INT_MAX     (600)
#define  MAX_APP_INT_MAX      (1e30)

typedef enum {
    TRUNCATED = 1,
    TERMINATED,
    CONTINUOUS
}terminationMethod_T;

typedef enum {
    TRUE_APP_ALG = 1,
    MAX_STAR_ALG,
    MAX_ALG
}algorithm_T;

#define  APP_INT_MAX(alg) \
  (((alg) == TRUE_APP_ALG)? TRUE_APP_INT_MAX : MAX_APP_INT_MAX)

/* macro:  APP_INIT_VALUE =====================================================
 * This macro is used in ture APP, max and max* algorithms. In true app,
 * we need to initialize the values to -inf. In max and max* algorithms,
 * we need to initialize them to 0.
 */
#define APP_INIT_VALUE(alg)  (((alg) == TRUE_APP_ALG)? 0 : -APP_INT_MAX(alg))

typedef struct App_tag{
    double *branchMetrics; /* Branch metrics               */
    double *beta;          /* beta for backward recursion  */
    double *alpha;         /* alpha for forward recursion  */

    struct {        /* reliability == (log-likelihood) */
	double *uI; /* Input: reliability of u (input data) bits */
	double *cI; /* Input: reliability of c (code) bits       */
    }inputs;

    struct {
	double *uO; /* Output: reliability of u (input data) bits */     
	double *cO; /* Output: reliability of c (code) bits       */
    }outputs;

    int     blockSize;        /* frame size                       */
    int     *currAlphaFlag;   /* For efficiency, we only store
                               *  alpha for states at time k and 
                               *  k+1. Therefore, alpha is being 
                               *  used as a circular buffer. Using
                               *  this flag we appropriately use
                               *  alpha at each time.
                               */
                                              
    terminationMethod_T  terminationMethod;/* continuous,truncated,terminated */
    algorithm_T          alg;              /* true APP, max* and max          */
    double               *maxStarTable;       /* Table for approximating
                                                 log(sum(exp(a_i)...))        */
    double               maxStarTableLength;  /* Table length                 */
    int                  scale;               /* for max* can be >= 1 . 
                                                 otherwise is 1               */


}app_T;

extern void app_SoftInputSoftOutput(Trellis_T *trellis, app_T *app);

#endif /* app_h */
