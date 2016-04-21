/* File    : rt_matrx.c
 * Abstract:
 *      Implements RTW stand alone matrix access and creation routines.
 *	There are two types of MATLAB objects which can be "passed" to
 *	the generated code, a 2D real matrix and a string. Strings are
 *	passed as 2D real matrices. The first two elements of an S-function
 *	parameters are the row and column (m and n) dimensions respectively.
 *	These are followed by the matrix data.
 */


#define PUBLIC
#define BEGIN_PUBLIC
#define END_PUBLIC


BEGIN_PUBLIC
/*
 * Copyright 1994-2003 The MathWorks, Inc.
 * $Revision: 1.26.4.3 $
 * $Date: 2004/04/14 23:44:39 $ 
 */

/*==========*
 * Includes *
 *==========*/

#if defined(MATLAB_MEX_FILE)
# error "rt_matrix cannot be used within a mex file. It is for RTW only."
#endif

#include <stdlib.h>    /* needed for malloc, calloc, free, realloc */
#include <string.h>    /* needed for strlen                        */
#include "rtwtypes.h"  /* needed for real_T                        */
#include "rt_mxclassid.h" /* needed for mxClassID                     */
END_PUBLIC

#include <stddef.h>
#include <float.h>  /* needed for definition of eps */
#include "rtlibsrc.h" /* utAssert */

BEGIN_PUBLIC

/*==========*
 * Typedefs *
 *==========*/

#ifndef rt_typedefs_h
#define rt_typedefs_h

#if !defined(TYPEDEF_MX_ARRAY)
# define TYPEDEF_MX_ARRAY
  typedef real_T mxArray;
#endif

typedef real_T mxChar;

#define mxMAXNAM  TMW_NAME_LENGTH_MAX	/* maximum name length */

typedef enum {
    mxREAL,
    mxCOMPLEX
} mxComplexity;

#ifdef V4_COMPAT
typedef double Real;    /* mimic MATLAB 4's matrix.h */
#define Matrix  mxArray
#define COMPLEX mxCOMPLEX
#define REAL    mxREAL
#endif

#endif /* rt_typedefs_h */

/*==================*
 * Extern variables *
 *==================*/

extern real_T rtInf;
extern real_T rtMinusInf;
extern real_T rtNaN;

/*=======================================*
 * Defines for mx Routines and constants *
 *=======================================*/


#define mxCalloc(n,size) \
        calloc(n,size)

#define mxCreateCharArray(ndim, dims) \
        mxCreateNumericArray(ndim, dims, mxCHAR_CLASS);

#define mxDestroyArray(pa) \
        if (pa) free(pa)

/* NOTE: You cannot mxFree(mxGetPr(pa)) !!! */
#define mxFree(ptr) \
        if(ptr)free(ptr)

#define mxGetClassID(pa) \
        mxDOUBLE_CLASS

/* NOTE: mxGetClassName(pa) returns "double" even on a character array */
#define mxGetClassName(pa) \
        "double"

#define mxGetData(pa) \
        ((void *)(&((pa)[2])))

#define mxGetElementSize(pa) \
        (sizeof(real_T))

#define mxGetInf() \
        rtInf

#define mxGetM(pa) \
        ((int) ((pa)[0]))
#define mxGetN(pa) \
        ((int) ((pa)[1]))

#define mxGetNaN() \
        rtNaN

#define mxGetNumberOfDimensions(pa) \
        (2)
#define mxGetNumberOfElements(pa) \
        (mxGetM(pa)*mxGetN(pa))

/* NOTE: mxGetPr() of an empty matrix does NOT return NULL */
#define mxGetPr(pa) \
        ( &((pa)[2]) )

#define mxGetScalar(pa) \
        ((pa)[2])

#define mxIsComplex(pa) \
        false

#define mxIsDouble(pa) \
        true

#define mxIsEmpty(pa) \
        (mxGetM(pa)==0 || mxGetN(pa)==0)

#define mxIsFinite(r) \
        ((r)>rtMinusInf && (r)<rtInf)

#define mxIsInf(r) \
        ((r)==rtInf || (r)==rtMinusInf)

#define mxIsInt16(pa) \
        false

#define mxIsInt32(pa) \
        false

#define mxIsInt8(pa) \
        false

#define mxIsLogical(pa) \
        false

#define mxIsNumeric(pa) \
        true

#define mxIsSingle(pa) \
        false

#define mxIsSparse(pa) \
        false

#define mxIsStruct(pa) \
        false

#define mxIsUint16(pa) \
        false

#define mxIsUint32(pa) \
        false

#define mxIsUint8(pa) \
        false

#define mxMalloc(n) \
        malloc(n)

#define mxRealloc(p,n) \
        realloc(p,n)

END_PUBLIC

/*==============*
 * Local macros *
 *==============*/
#define _mxSetM(pa,m) \
        (pa)[0] = ((int)(m))

#define _mxSetN(pa,n) \
        (pa)[1] = ((int)(n))

BEGIN_PUBLIC


/*==========================*
 * Visible/extern functions *
 *=========================*/
END_PUBLIC

/* Function: mxCreateCharMatrixFromStrings ====================================
 * Abstract:
 *	Create a string array initialized to the strings in str.
 */
PUBLIC mxArray *rt_mxCreateCharMatrixFromStrings(int_T m, const char_T **str)
{
    int_T nchars;
    int_T i, n;
    mxArray *pa;

    utAssert(m >= 0);
    utAssert(str != NULL || (str == NULL && m == 0));

    n = 0;
    for (i = 0; i < m; ++i) {
	nchars = strlen(str[i]);
	if (nchars > n) {
	    n = nchars;
	}
    }
    /*LINTED E_PASS_INT_TO_SMALL_INT*/
    pa = (mxArray *)malloc((m*n+2)*sizeof(real_T));
    if(pa!=NULL) {
	mxChar *chars;
	int_T  j;
	_mxSetM(pa, m);
	_mxSetN(pa, n);
	chars = mxGetPr(pa);
	for (j = 0; j < m; ++j) {
	    const char_T *src  = str[j];
	    mxChar *dest = chars + j;

	    nchars = strlen(src);
	    i = nchars;
	    while (i--) {
		*dest = *src++;
		 dest += m;
	    }
	    i = n - nchars;
	    while (i--) {
		*dest = 0.0;
		dest += m;
	    }
	}
    }
    return pa;
} /* end mxCreateCharMatrixFromStrings */



/* Function: mxCreateString ===================================================
 * Abstract:
 *	Create a 1-by-n string array initialized to null terminated string
 *	where n is the length of the string.
 */
PUBLIC mxArray *rt_mxCreateString(const char *str)
{
    int_T   len = strlen(str);
    /*LINTED E_PASS_INT_TO_SMALL_INT*/
    mxArray *pa = (mxArray *)malloc((len+2)*sizeof(real_T));

    if(pa!=NULL) {
	real_T *pr;
	const unsigned char *ustr_ptr = (const unsigned char *) str;

	_mxSetM(pa, 1);
	_mxSetN(pa, len);
	pr = mxGetPr(pa);
	while (len--) {
            *pr++ = (real_T)*ustr_ptr++;
        }
    }
    return(pa);

} /* end mxCreateString */



/* Function: mxCreateDoubleMatrix =============================================
 * Abstract:
 *	Create a two-dimensional array to hold real_T data,
 *	initialize each data element to 0.
 */
/*LINTLIBRARY*/
PUBLIC mxArray *rt_mxCreateDoubleMatrix(int m, int n, mxComplexity flag)
{
    utAssert(flag == mxREAL);
    if (flag == mxREAL) {
        mxArray *pa = (mxArray *)calloc(m*n+2, sizeof(real_T));
        if(pa!=NULL) {
            _mxSetM(pa, m);
            _mxSetN(pa, n);
        }
        return(pa);
    } else {
        return(NULL);
    }

} /* end mxCreateDoubleMatrix */



/* Function: mxCreateNumericArray =============================================
 * Abstract:
 *	Create a numeric array and initialize all its data elements to 0.
 */
PUBLIC mxArray *rt_mxCreateNumericArray(int_T ndims, const int_T *dims,
                                     mxClassID classid, mxComplexity flag)
{
    utAssert(ndims==2);
    utAssert(classid==mxDOUBLE_CLASS);
    if (ndims == 2 && classid==mxDOUBLE_CLASS) {
        return(rt_mxCreateDoubleMatrix(dims[0], dims[1], flag));
    } else {
        return(NULL);
    }

} /* end mxCreateNumericArray */



/* Function: mxDuplicateArray =================================================
 * Abstract:
 *	Make a deep copy of an array, return a pointer to the copy.
 */
PUBLIC mxArray *rt_mxDuplicateArray(const mxArray *pa)
{
    /*LINTED E_ASSIGN_INT_TO_SMALL_INT*/
    int_T   nbytes = (mxGetNumberOfElements(pa)+2)*mxGetElementSize(pa);
    mxArray *pcopy = (mxArray *)malloc(nbytes);

    if (pcopy!=NULL) {
	(void)memcpy(pcopy, pa, nbytes);
    }
    return(pcopy);

} /* end mxDuplicateArray */



/* Function: mxGetDimensions ==================================================
 * Abstract:
 *	Get pointer to dimension array
 * 	NOTE: This routine is not reentrant.
 */
PUBLIC const int_T *rt_mxGetDimensions(const mxArray *pa)
{
    static int_T dims[2];
    dims[0] = mxGetM(pa);
    dims[1] = mxGetN(pa);
    return dims;
} /* end mxGetDimensions */




/* Function: mxGetEps =========================================================
 * Abstract:
 *	Return eps, the difference between 1.0 and the least value
 *	greater than 1.0 that is representable as a real_T.
 *	NOTE: Assumes real_T is either double or float.
 */
PUBLIC real_T rt_mxGetEps(void)
{
    return (sizeof(double)==sizeof(real_T)) ? DBL_EPSILON : FLT_EPSILON;
}



/* Function: mxGetString ======================================================
 * Abstract:
 *	Converts a string array to a C-style string.
 */
PUBLIC int_T rt_mxGetString(const mxArray *pa, char_T *buf, int_T buflen)
{
    int_T        nchars;
    const real_T *pr;
    char_T       *pc;
    int_T        truncate = 0;

    utAssert(pa != NULL);
    utAssert(buf != NULL);
    utAssert(buflen > 0);

    nchars = mxGetNumberOfElements(pa);
    if (nchars >= buflen) {
	/* leave room for null byte */
	nchars = buflen - 1;
	truncate = 1;
    }
    pc = buf;
    pr = mxGetPr(pa);
    while (nchars--) {
	*pc++ = (char) (*pr++ + .5);
    }
    *pc = '\0';
    return truncate;
} /* end mxGetString */

BEGIN_PUBLIC

#define mxCreateCharMatrixFromStrings(m, str) \
        rt_mxCreateCharMatrixFromStrings(m, str)

#define mxCreateString(str) \
        rt_mxCreateString(str) 

#define mxCreateDoubleMatrix(m, n, flag) \
        rt_mxCreateDoubleMatrix(m, n, flag)

#define mxCreateNumericArray(ndims, dims, classid, flag) \
        rt_mxCreateNumericArray(ndims, dims, classid, flag)

#define mxDuplicateArray(pa) \
        rt_mxDuplicateArray(pa)

#define mxGetDimensions(pa) \
        rt_mxGetDimensions(pa)

#define mxGetEps() \
        rt_mxGetEps()

#define mxGetString(pa, buf, buflen) \
        rt_mxGetString(pa, buf, buflen)

/*=========================*
 * Unsupported mx Routines *
 *=========================*/

#define mxCalcSingleSubscript(pa,nsubs,subs) \
        mxCalcSingleSubscript_is_not_supported_in_RTW

#define mxClearLogical(pa) \
        mxClearLogical_is_not_supported_in_RTW

#define mxCreateCellArray(ndim,dims) \
        mxCreateCellArray_is_not_supported_in_RTW

#define mxCreateCellMatrix(m,n) \
        mxCreateCellMatrix_is_not_supported_in_RTW

#define mxCreateSparse(pm,pn,pnzmax,pcmplx_flg) \
        mxCreateSparse_is_not_supported_in_RTW

#define mxCreateStructArray(ndim,dims,nfields,fieldnames) \
        mxCreateStructArray_is_not_supported_in_RTW

#define mxCreateStructMatrix(m,n,nfields,fieldnames) \
        mxCreateStructMatrix_is_not_supported_in_RTW

#define mxGetCell(pa,i) \
        mxGetCell_is_not_supported_in_RTW

#define mxGetField(pa,i,fieldname) \
        mxGetField_is_not_supported_in_RTW

#define mxGetFieldByNumber(s,i,fieldnum) \
        mxGetFieldByNumber_is_not_supported_in_RTW

#define mxGetFieldNameByNumber(pa,n) \
        mxGetFieldNameByNumber_is_not_supported_in_RTW

#define mxGetFieldNumber(pa,fieldname) \
        mxGetFieldNumber_is_not_supported_in_RTW

#define mxGetImagData(pa) \
        mxGetImagData_is_not_supported_in_RTW

#define mxGetIr(ppa) \
        mxGetIr_is_not_supported_in_RTW

#define mxGetJc(ppa) \
        mxGetJc_is_not_supported_in_RTW

#define mxGetNumberOfFields(pa) \
        mxGetNumberOfFields_is_not_supported_in_RTW

#define mxGetNzmax(pa) \
        mxGetNzmax_is_not_supported_in_RTW

#define mxGetPi(pa) \
        mxGetPi_is_not_supported_in_RTW

#define mxIsFromGlobalWS(pa) \
        mxIsFromGlobalWS_is_not_supported_in_RTW

#define mxIsNaN(r) \
        mxIsNaN_is_not_supported_in_RTW

#define mxIsChar(pa) \
        mxIsChar_is_not_supported_in_RTW

#define mxIsClass(pa,class) \
        mxIsClass_is_not_supported_in_RTW

#define mxIsCell(pa) \
        mxIsCell_is_not_supported_in_RTW

#define mxSetCell(pa,i,value) \
        mxSetCell_is_not_supported_in_RTW

#define mxSetClassName(pa,classname) \
        mxSetClassName_is_not_supported_in_RTW

#define mxSetData(pa,pr) \
        mxSetData_is_not_supported_in_RTW

#define mxSetDimensions(pa, size, ndims) \
        mxSetDimensions_is_not_supported_in_RTW

#define mxSetField(pa,i,fieldname,value) \
        mxSetField_is_not_supported_in_RTW

#define mxSetFieldByNumber(pa, index, fieldnum, value) \
        mxSetFieldByNumber_is_not_supported_in_RTW

#define mxSetFromGlobalWS(pa,global) \
        mxSetFromGlobalWS_is_not_supported_in_RTW

#define mxSetImagData(pa,pv) \
        mxSetImagData_is_not_supported_in_RTW

#define mxSetIr(ppa,ir) \
        mxSetIr_is_not_supported_in_RTW

#define mxSetJc(ppa,jc) \
        mxSetJc_is_not_supported_in_RTW

#define mxSetLogical(pa) \
        mxSetLogical_is_not_supported_in_RTW

#define mxSetM(pa, m) \
        mxSetM_is_not_supported_in_RTW

#define mxSetN(pa, m) \
        mxSetN_is_not_supported_in_RTW

#define mxSetPr(pa,pr) \
        mxSetPr_is_not_supported_in_RTW

#define mxSetNzmax(pa,nzmax) \
        mxSetNzmax_is_not_supported_in_RTW

#define mxSetPi(pa,pv) \
        mxSetPi_is_not_supported_in_RTW



/*======================*
 * Obsolete mx routines *
 *======================*/

#ifdef V4_COMPAT
# define mxIsFull(pa)              (!mxIsSparse(pa))
# define mxCreateFull(m,n,complex) mxCreateDoubleMatrix(m,n,complex)
# define mxFreeMatrix(pm)          mxDestroyArray(pm)
#else
# define mxCreateFull(m,n,complex) mxCreateFull_is_obsolete
# define mxFreeMatrix(p)           mxFreeMatrix_is_obsolete
# define mxIsFull(pa)              mxIsFull_is_obsolete
# define mxIsString(pm)            mxIsString_is_obsolete
# define mxGetName(pa)             mxGetName_is_obsolete
# define mxSetName(ppa,name)       mxSetName_is_obsolete
#endif


/*==========================*
 * Unsupported mex routines *
 *==========================*/

#define mexPrintAssertion(test,fname,linenum,message) \
        mexPrintAssertion_is_not_supported_by_RTW

#define mexEvalString(str) \
        mexEvalString_is_not_supported_by_RTW

#define mexErrMsgTxt(str) \
        mexErrMsgTxt_is_not_supported_by_RTW

#define mexWarnMsgTxt(warning_msg) \
        mexWarnMsgTxt_is_not_supported_by_RTW

#define mexPrintf \
        mexPrintf_is_not_supported_by_RTW

#define mexMakeArrayPersistent(pa) \
        mexMakeArrayPersistent_is_not_supported_by_RTW

#define mexMakeMemoryPersistent(ptr) \
        mexMakeMemoryPersistent_is_not_supported_by_RTW

#define mexLock() \
        mexLock_is_not_supported_by_RTW

#define mexUnlock() \
        mexUnlock_is_not_supported_by_RTW

#define mexFunctionName() \
        mexFunctionName_is_not_supported_by_RTW

#define mexIsLocked() \
        mexIsLocked_is_not_supported_by_RTW

#define mexGetFunctionHandle() \
        mexGetFunctionHandle_is_not_supported_by_RTW

#define mexCallMATLABFunction() \
        mexCallMATLABFunction_is_not_supported_by_RTW

#define mexRegisterFunction() \
        mexRegisterFunction_is_not_supported_by_RTW

#define mexSet(handle,property,value) \
        mexSet_is_not_supported_by_RTW

#define mexGet(handle,property) \
        mexGet_is_not_supported_by_RTW

#define mexPutArray(pm,workspace) \
        mexPutArray_is_not_supported_by_RTW

#define mexGetArrayPtr(name,workspace) \
        mexGetArrayPtr_is_not_supported_by_RTW

#define mexGetArray(name,workspace) \
        mexGetArray_is_not_supported_by_RTW

#define mexCallMATLAB(nlhs,plhs,nrhs,prhs,fcn) \
        mexCallMATLAB_is_not_supported_by_RTW

#define mexSetTrapFlag(flag) \
        mexSetTrapFlag_is_not_supported_by_RTW

#define mexUnlink(a) \
        mexUnlink_is_not_supported_by_RTWw

#define mexSubsAssign(plhs,sub,nsubs,prhs) \
        mexSubsAssign_is_not_supported_by_RTW

#define mexSubsReference(prhs,subs,nsubs) \
        mexSubsReference_is_not_supported_by_RTW

#define mexPrintAssertion(test,fname,linenum,message) \
        mexPrintAssertion_is_not_supported_by_RTW

#define mexAddFlops(count) \
        mexAddFlops_is_not_supported_by_RTW

#define mexIsGlobal(pa) \
        mexIsGlobal_is_not_supported_by_RTW

#define mexAtExit(fcn) \
        mexAtExit_is_not_supported_by_RTW

END_PUBLIC

/* [EOF] rt_matrx.c */
