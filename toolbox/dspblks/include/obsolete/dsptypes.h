/*
 *  dsptypes.h - Macros and private methods for DSP Blockset
 *
 *  Copyright 1995-2002 The MathWorks, Inc.
 *  $Revision: 1.45 $ $Date: 2002/04/14 20:39:42 $
 */
#ifndef dsptypes_h
#define dsptypes_h

#include <math.h>
#include "tmwtypes.h"

#if defined(MATLAB_MEX_FILE)
#    include "simstruc.h"
#else
#    include "simstruc_types.h"
#endif

/*
 * ----------------------------------------------------------
 * Common constants
 * ----------------------------------------------------------
 */
#define TWO_PI_DOUBLE 6.283185307179586476925286766559005768394
#define PI_DOUBLE     3.141592653589743238462643383279502884197

#define MAX_real64_T 1.7976931348623158e+308
#define MAX_real32_T 3.402823466e+38F
#define MAX_real_T   MAX_real64_T

/*
 * ----------------------------------------------------------
 * Common macros
 * ----------------------------------------------------------
 */
#ifndef MAX
#define MAX(a,b) ((a)>(b) ? (a) : (b))
#endif

#ifndef MIN
#define MIN(a,b) ((a)<(b) ? (a) : (b))
#endif


/*
 * ----------------------------------------------------------
 * Error handling
 * ----------------------------------------------------------
 */
#define THROW_ERROR(S,MSG) {ssSetErrorStatus(S,MSG); return;}
#define ANY_ERRORS(S)      (ssGetErrorStatus(S) != NULL)
#define RETURN_IF_ERROR(S) {if (ANY_ERRORS(S)) return;}

/*
 * SET_ERROR is being made obsolete.
 * Please use THROW_ERROR in all new code.
 *
 * The new name better reflects the fact that
 * this macro exits the caller's context.
 */
#define SET_ERROR(S,MSG) {ssSetErrorStatus(S,MSG); return;}


/*
 * ----------------------------------------------------------
 * Declare zero-crossing detector prototype:
 * ----------------------------------------------------------
 */
extern ZCEventType rt_ZCFcn(ZCDirection direction,
                            ZCSigState *prevSigState, 
                            real_T      zcSig);

/*
 * Use as first line in mdlInitializeSizes(), eg:
 *
 *  static void mdlInitializeSizes(SimStruct *S)
 *  {
 *      REGISTER_SFCN_PARAMS(S, NUM_ARGS)
 *      ...
 *  }
 */
#define REGISTER_SFCN_PARAMS(S, numParams) {if(!registerSFunctionParams(S, numParams)) return;}


/*
 * ----------------------------------------------------------
 * Input argument processing
 * ----------------------------------------------------------
 */

/*
 * NOTE: For Simulink, our definition of a vector does NOT include
 *       N-D or an "empty" vector.  Ex: 1x5 is a vector, 0x5 is not.
 */
#define IS_SCALAR(X) (mxGetNumberOfElements(X) == 1)
#define IS_VECTOR(X) ((mxGetM(X) == 1) || (mxGetN(X) == 1))

#define IS_DOUBLE(X) (!mxIsComplex(X) && !mxIsSparse(X) && mxIsDouble(X))

#define IS_SCALAR_DOUBLE(X) (IS_DOUBLE(X) && IS_SCALAR(X))
#define IS_VECTOR_DOUBLE(X) (IS_DOUBLE(X) && IS_VECTOR(X))

/* Check that the scalar double is in a certain range: */
#define IS_SCALAR_DOUBLE_GREATER_THAN(X,V) (IS_SCALAR_DOUBLE(X) && (mxGetPr(X)[0] >  (real_T)V))
#define IS_SCALAR_DOUBLE_GE(X,V) (IS_SCALAR_DOUBLE(X) && (mxGetPr(X)[0] >= (real_T)V))

/* Check an element of a vector: */
#define IS_IDX_FLINT(X,IDX) (IS_DOUBLE(X) && \
                    (IDX < mxGetNumberOfElements(X)) && \
                    (IDX >= 0) && \
                    !mxIsInf(mxGetPr(X)[IDX]) && \
                    !mxIsNaN(mxGetPr(X)[IDX]) && \
                    (mxGetPr(X)[IDX] == floor(mxGetPr(X)[IDX])))

#define IS_IDX_FLINT_GE(X,IDX,V) (IS_IDX_FLINT(X,IDX) && \
                                    (mxGetPr(X)[IDX] >= (real_T)V))


#define IS_IDX_FLINT_IN_RANGE(X,IDX,A,B) (IS_IDX_FLINT(X,IDX) && \
                           (mxGetPr(X)[IDX] >= (real_T)A) && \
                           (mxGetPr(X)[IDX] <= (real_T)B) )

/* Check if arg is a floating-point integer-valued scalar (a "flint"): */
#define IS_FLINT(X)              (IS_SCALAR(X) && IS_IDX_FLINT(X,0))
#define IS_FLINT_GE(X,V)         (IS_SCALAR(X) && IS_IDX_FLINT_GE(X,0,V)) 
#define IS_FLINT_IN_RANGE(X,A,B) (IS_SCALAR(X) && IS_IDX_FLINT_IN_RANGE(X,0,A,B))

/* Use to validate general initial conditions argument
 * May be an empty matrix, may not contain doubles.
 */
#define IS_VALID_IC(X) (!mxIsSparse(X) && mxIsNumeric(X))

/*
 * OK_TO_CHECK_VAR is used to determine if the contents of an
 *   "edit"-style mask dialog box should be checked in
 *   the mdlCheckParameters section of a CMEX S-Function.
 *   Edit boxes may contain variables instead of constants,
 *   and those variables might not be defined in the workspace
 *   at "dialog apply" time.  This should not be an error, so
 *   the dialog parameter should not be checked unless the user
 *   is running the simulation.  There is no need to use it for
 *   Checkboxes, Popups, etc.
 *
 * Typical usage:
 *   if OK_TO_CHECK_VAR(S, PARAM1) {
 *      <check PARAM1 content here>
 *   }
 */
#define OK_TO_CHECK_VAR(S, ARG) ((ssGetSimMode(S) != SS_SIMMODE_SIZES_CALL_ONLY) || !mxIsEmpty(ARG))


/*
 * ----------------------------------------------------------
 * Complex data macros
 * ----------------------------------------------------------
 */

/*
 *  4 forms of complex multiply:
 */
#define CMULT_RE(X,Y)        ( (X).re * (Y).re - (X).im * (Y).im)
#define CMULT_IM(X,Y)        ( (X).re * (Y).im + (X).im * (Y).re)

#define CMULT_XCONJ_RE(X,Y)  ( (X).re * (Y).re + (X).im * (Y).im)
#define CMULT_XCONJ_IM(X,Y)  ( (X).re * (Y).im - (X).im * (Y).re)

#define CMULT_YCONJ_RE(X,Y)  ( (X).re * (Y).re + (X).im * (Y).im)
#define CMULT_YCONJ_IM(X,Y)  (-(X).re * (Y).im + (X).im * (Y).re)

#define CMULT_XYCONJ_RE(X,Y) ( (X).re * (Y).re - (X).im * (Y).im)
#define CMULT_XYCONJ_IM(X,Y) (-(X).re * (Y).im - (X).im * (Y).re)

/* Complex conjugate: */
#define CCONJ(X,Y)     \
{                      \
   (Y).re =  (X).re;   \
   (Y).im = -((X).im); \
}

/*
 *  Complex magnitude squared ( X * conj(X), or |X|^2 )
 *   CMAGSQ: arg is a complex struct
 *   CMAGSQp: arg is a pointer to a complex struct
 */
#define CMAGSQ(X)   ((X).re   * (X).re   + (X).im   * (X).im)
#define CMAGSQp(pX) ((pX)->re * (pX)->re + (pX)->im * (pX)->im)

/*
 * Quick-and-dirty (approximate) complex absolute value:
 */
#define CQABS(X) (fabs((X).re) + fabs((X).im))

/*
 *  Complex reciprocal: C = 1 / B  (A=1)
 */
#define CRECIP(B,C)                     \
{                                       \
    const real_T _s = 1.0 / CQABS(B);   \
    real_T  _d;                         \
    creal_T _bs;                        \
    _bs.re = (B).re * _s;               \
    _bs.im = (B).im * _s;               \
    _d = 1.0 / CMAGSQ(_bs);             \
    (C).re = ( _s * _bs.re) * _d;       \
    (C).im = (-_s * _bs.im) * _d;       \
}

/*
 * Complex division: C = A / B
 */
#define CDIV(A,B,C)                             \
{                                               \
    if ((B).im == 0.0) {                        \
	(C).re = (A).re / (B).re;               \
	(C).im = (A).im / (B).re;               \
    } else {                                    \
        const real_T _s = 1.0 / CQABS(B);       \
        real_T  _d;                             \
        creal_T _as, _bs;                       \
        _as.re = (A).re * _s;                   \
        _as.im = (A).im * _s;                   \
        _bs.re = (B).re * _s;                   \
        _bs.im = (B).im * _s;                   \
        _d = 1.0 / CMAGSQ(_bs);                 \
        (C).re = CMULT_YCONJ_RE(_as, _bs) * _d; \
        (C).im = CMULT_YCONJ_IM(_as, _bs) * _d; \
    }                                           \
}

/*
 *  Hypotenuse: c = sqrt(a^2 + b^2)
 */
#define CHYPOT(A,B,C)                          \
{                                              \
    if (fabs(A) > fabs(B)) {                   \
        real_T _tmp = (B)/(A);                 \
        (C) = (fabs(A)*sqrt(1+_tmp*_tmp));     \
    } else {                                   \
    if ((B) == 0.0) {                          \
            (C) = 0.0;                         \
        } else {                               \
            real_T _tmp = (A)/(B);             \
            (C) = (fabs(B)*sqrt(1+_tmp*_tmp)); \
        }                                      \
    }                                          \
}

/*
 *  Complex modulus: Y = abs(X)
 */
#define CABS(X,Y) CHYPOT((X).re, (X).im, (Y))


/*
 * ----------------------------------------------------------
 * Cache functions
 * ----------------------------------------------------------
 */
#define CallocSFcnCache(S, SFcnCache)                              \
{                                                                  \
    SFcnCache *cache = (SFcnCache *)mxCalloc(1,sizeof(SFcnCache)); \
    if (cache == NULL) {                                           \
        SET_ERROR(S, "Memory allocation failure");                 \
    }                                                              \
    /* prevent MATLAB from deallocating behind our backs */        \
    mexMakeMemoryPersistent(cache);                                \
    ssSetUserData(S, cache);                                       \
}

#define FreeSFcnCache(S, SFcnCache)                   \
{                                                     \
    SFcnCache *cache = (SFcnCache *)ssGetUserData(S); \
    if (cache != NULL) {                              \
        mxFree(cache);                                \
	ssSetUserData(S, NULL);                       \
    }                                                 \
}


#endif  /* dsptypes_h */

/* [EOF] dsptypes.h */
