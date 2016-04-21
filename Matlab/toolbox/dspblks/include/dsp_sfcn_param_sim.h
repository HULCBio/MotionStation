/*
 *  dsp_sfcn_param_sim.h
 *  CMEX S-Fcn parameter handling for DSP Blockset
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.13.4.2 $ $Date: 2004/04/12 23:11:33 $
 */

#ifndef dsp_sfcn_param_sim_h
#define dsp_sfcn_param_sim_h

#include "dsp_sim.h"

/*
 * Methods to get a pointer to dialog mask parameters
 */
#define GET_SFCN_PARAM_REAL_PTR(S,ArgIdx) mxGetPr(ssGetSFcnParam(S,ArgIdx))
#define GET_SFCN_PARAM_IMAG_PTR(S,ArgIdx) mxGetPi(ssGetSFcnParam(S,ArgIdx))

/*
 * Method to get the number of array entries in dialog mask parameter field.
 * If parameter is a complex array, this returns number of complex entries.
 * If parameter is a real array, this returns number of real entries.
 */
#define GET_SFCN_NUM_ELEMENTS(S,ArgIdx) mxGetNumberOfElements(ssGetSFcnParam(S,ArgIdx))

/*
 * Methods to get a scalar value within a dialog mask parameter array.
 *
 * Type-casting is as follows:
 *
 * Suffix   Description
 * ------   --------------------------------------------------------------------
 * <none> - Generic floating-point (real_T) [usually equivalent to real64_T]
 * DBL    - 64-bit double precision floating-point (real_T) [usually real64_T]
 * SGL    - 32-bit single precision floating-point (real32_T)
 * BLN    - Boolean (boolean_T)
 * INT    - Integer (int_T) [using platform's natural precision]
 * INT8   - 8-bit signed integer    (int8_T)
 * INT16  - 16-bit signed integer   (int16_T)
 * INT32  - 32-bit signed integer   (int32_T)
 * UINT8  - 8-bit unsigned integer  (uint8_T)
 * UINT16 - 16-bit unsigned integer (uint16_T)
 * UINT32 - 32-bit unsigned integer (uint32_T)
 */
#define GET_SFCN_PARAM_REAL_VAL(S,ArgIdx,ArrayIdx)        (real_T)((GET_SFCN_PARAM_REAL_PTR(S,ArgIdx))[ArrayIdx])
#define GET_SFCN_PARAM_IMAG_VAL(S,ArgIdx,ArrayIdx)        (real_T)((GET_SFCN_PARAM_IMAG_PTR(S,ArgIdx))[ArrayIdx])

#define GET_SFCN_PARAM_REAL_VAL_DBL(S,ArgIdx,ArrayIdx)    GET_SFCN_PARAM_REAL_VAL(S,ArgIdx,ArrayIdx)
#define GET_SFCN_PARAM_IMAG_VAL_DBL(S,ArgIdx,ArrayIdx)    GET_SFCN_PARAM_IMAG_VAL(S,ArgIdx,ArrayIdx)

#define GET_SFCN_PARAM_REAL_VAL_SGL(S,ArgIdx,ArrayIdx)    (real32_T)((GET_SFCN_PARAM_REAL_PTR(S,ArgIdx))[ArrayIdx])
#define GET_SFCN_PARAM_IMAG_VAL_SGL(S,ArgIdx,ArrayIdx)    (real32_T)((GET_SFCN_PARAM_IMAG_PTR(S,ArgIdx))[ArrayIdx])

#define GET_SFCN_PARAM_REAL_VAL_BLN(S,ArgIdx,ArrayIdx)    (boolean_T)((GET_SFCN_PARAM_REAL_PTR(S,ArgIdx))[ArrayIdx])
#define GET_SFCN_PARAM_IMAG_VAL_BLN(S,ArgIdx,ArrayIdx)    (boolean_T)((GET_SFCN_PARAM_IMAG_PTR(S,ArgIdx))[ArrayIdx])

#define GET_SFCN_PARAM_REAL_VAL_INT(S,ArgIdx,ArrayIdx)    (int_T)((GET_SFCN_PARAM_REAL_PTR(S,ArgIdx))[ArrayIdx])
#define GET_SFCN_PARAM_IMAG_VAL_INT(S,ArgIdx,ArrayIdx)    (int_T)((GET_SFCN_PARAM_IMAG_PTR(S,ArgIdx))[ArrayIdx])

#define GET_SFCN_PARAM_REAL_VAL_INT8(S,ArgIdx,ArrayIdx)   (int8_T)((GET_SFCN_PARAM_REAL_PTR(S,ArgIdx))[ArrayIdx])
#define GET_SFCN_PARAM_IMAG_VAL_INT8(S,ArgIdx,ArrayIdx)   (int8_T)((GET_SFCN_PARAM_IMAG_PTR(S,ArgIdx))[ArrayIdx])

#define GET_SFCN_PARAM_REAL_VAL_INT16(S,ArgIdx,ArrayIdx)  (int16_T)((GET_SFCN_PARAM_REAL_PTR(S,ArgIdx))[ArrayIdx])
#define GET_SFCN_PARAM_IMAG_VAL_INT16(S,ArgIdx,ArrayIdx)  (int16_T)((GET_SFCN_PARAM_IMAG_PTR(S,ArgIdx))[ArrayIdx])

#define GET_SFCN_PARAM_REAL_VAL_INT32(S,ArgIdx,ArrayIdx)  (int32_T)((GET_SFCN_PARAM_REAL_PTR(S,ArgIdx))[ArrayIdx])
#define GET_SFCN_PARAM_IMAG_VAL_INT32(S,ArgIdx,ArrayIdx)  (int32_T)((GET_SFCN_PARAM_IMAG_PTR(S,ArgIdx))[ArrayIdx])

#define GET_SFCN_PARAM_REAL_VAL_UINT8(S,ArgIdx,ArrayIdx)  (uint8_T)((GET_SFCN_PARAM_REAL_PTR(S,ArgIdx))[ArrayIdx])
#define GET_SFCN_PARAM_IMAG_VAL_UINT8(S,ArgIdx,ArrayIdx)  (uint8_T)((GET_SFCN_PARAM_IMAG_PTR(S,ArgIdx))[ArrayIdx])

#define GET_SFCN_PARAM_REAL_VAL_UINT16(S,ArgIdx,ArrayIdx) (uint16_T)((GET_SFCN_PARAM_REAL_PTR(S,ArgIdx))[ArrayIdx])
#define GET_SFCN_PARAM_IMAG_VAL_UINT16(S,ArgIdx,ArrayIdx) (uint16_T)((GET_SFCN_PARAM_IMAG_PTR(S,ArgIdx))[ArrayIdx])

#define GET_SFCN_PARAM_REAL_VAL_UINT32(S,ArgIdx,ArrayIdx) (uint32_T)((GET_SFCN_PARAM_REAL_PTR(S,ArgIdx))[ArrayIdx])
#define GET_SFCN_PARAM_IMAG_VAL_UINT32(S,ArgIdx,ArrayIdx) (uint32_T)((GET_SFCN_PARAM_IMAG_PTR(S,ArgIdx))[ArrayIdx])

/*
 * NOTE: For Simulink parameters, our definition of a vector does NOT include
 *       an N-D ML vector or an "empty" vector (e.g. 1x5 is a vector, 0x5 is not)
 */
#define IS_SCALAR(X)        (mxGetNumberOfElements(X) == 1)
#define IS_VECTOR(X)        ((mxGetM(X) == 1) || (mxGetN(X) == 1))
#define IS_ROW_VECTOR(X)    ((mxGetM(X) == 1) && (mxGetN(X) > 1 ))
#define IS_COLUMN_VECTOR(X) ((mxGetM(X) > 1)  && (mxGetN(X) == 1))
#define IS_FULL_MATRIX(X)   ((mxGetM(X) > 1)  && (mxGetN(X) > 1))

#define IS_DOUBLE(X)        (!mxIsComplex(X) && !mxIsSparse(X) && mxIsDouble(X))
/* Note: IS_DOUBLE_NEW should really be re-named IS_DOUBLE  */
/*       This has been gecked and affects lots of S-fcns... */
#define IS_DOUBLE_NEW(X)    (!mxIsSparse(X)  && mxIsDouble(X))
#define IS_REAL_DOUBLE(X)   (!mxIsComplex(X) && IS_DOUBLE_NEW(X))
#define IS_CPLX_DOUBLE(X)   (mxIsComplex(X)  && IS_DOUBLE_NEW(X))

#define IS_SINGLE(X)        (!mxIsSparse(X)  && mxIsSingle(X))
#define IS_REAL_SINGLE(X)   (!mxIsComplex(X) && IS_SINGLE(X))
#define IS_CPLX_SINGLE(X)   (mxIsComplex(X)  && IS_SINGLE(X))

#define IS_BOOLEAN(X)       (!mxIsComplex(X) && !mxIsSparse(X) && mxIsLogical(X))

#define IS_INT8(X)          (!mxIsSparse(X)  && mxIsInt8(X))
#define IS_REAL_INT8(X)     (!mxIsComplex(X) && IS_INT8(X))
#define IS_CPLX_INT8(X)     (mxIsComplex(X)  && IS_INT8(X))

#define IS_UINT8(X)         (!mxIsSparse(X)  && mxIsUint8(X))
#define IS_REAL_UINT8(X)    (!mxIsComplex(X) && IS_UINT8(X))
#define IS_CPLX_UINT8(X)    (mxIsComplex(X)  && IS_UINT8(X))

#define IS_INT16(X)         (!mxIsSparse(X)  && mxIsInt16(X))
#define IS_REAL_INT16(X)    (!mxIsComplex(X) && IS_INT16(X))
#define IS_CPLX_INT16(X)    (mxIsComplex(X)  && IS_INT16(X))

#define IS_UINT16(X)        (!mxIsSparse(X)  && mxIsUint16(X))
#define IS_REAL_UINT16(X)   (!mxIsComplex(X) && IS_UINT16(X))
#define IS_CPLX_UINT16(X)   (mxIsComplex(X)  && IS_UINT16(X))

#define IS_INT32(X)         (!mxIsSparse(X)  && mxIsInt32(X))
#define IS_REAL_INT32(X)    (!mxIsComplex(X) && IS_INT32(X))
#define IS_CPLX_INT32(X)    (mxIsComplex(X)  && IS_INT32(X))

#define IS_UINT32(X)        (!mxIsSparse(X)  && mxIsUint32(X))
#define IS_REAL_UINT32(X)   (!mxIsComplex(X) && IS_UINT32(X))
#define IS_CPLX_UINT32(X)   (mxIsComplex(X)  && IS_UINT32(X))

#if 0
  /* NOTE: the following special cases for 64-bit integers require linking in
   * $(MATLABROOT)/extern/lib/$(PLATFORM)/$(COMPILER_VENDOR)/$(COMPILER_VERSION)/libmx.lib
   * if these are needed.  For now these have been removed until there is a need...
   */
  #define IS_INT64(X)         (!mxIsSparse(X)  && mxIsInt64(X))
  #define IS_REAL_INT64(X)    (!mxIsComplex(X) && IS_INT64(X))
  #define IS_CPLX_INT64(X)    (mxIsComplex(X)  && IS_INT64(X))

  #define IS_UINT64(X)        (!mxIsSparse(X)  && mxIsUint64(X))
  #define IS_REAL_UINT64(X)   (!mxIsComplex(X) && IS_UINT64(X))
  #define IS_CPLX_UINT64(X)   (mxIsComplex(X)  && IS_UINT64(X))
#endif

#define IS_SCALAR_DOUBLE(X)           (IS_DOUBLE(X)      && IS_SCALAR(X))
#define IS_VECTOR_DOUBLE(X)           (IS_DOUBLE(X)      && IS_VECTOR(X))
#define IS_FULL_MATRIX_DOUBLE(X)      (IS_DOUBLE(X)      && IS_FULL_MATRIX(X))
#define IS_SCALAR_REAL_DOUBLE(X)      (IS_REAL_DOUBLE(X) && IS_SCALAR(X))
#define IS_VECTOR_REAL_DOUBLE(X)      (IS_REAL_DOUBLE(X) && IS_VECTOR(X))
#define IS_SCALAR_CPLX_DOUBLE(X)      (IS_CPLX_DOUBLE(X) && IS_SCALAR(X))
#define IS_VECTOR_CPLX_DOUBLE(X)      (IS_CPLX_DOUBLE(X) && IS_VECTOR(X))
#define IS_FULL_MATRIX_REAL_DBL(X)    (IS_REAL_DOUBLE(X) && IS_FULL_MATRIX(X))
#define IS_FULL_MATRIX_CPLX_DBL(X)    (IS_CPLX_DOUBLE(X) && IS_FULL_MATRIX(X))

#define IS_SCALAR_SINGLE(X)           (IS_SINGLE(X)      && IS_SCALAR(X))
#define IS_VECTOR_SINGLE(X)           (IS_SINGLE(X)      && IS_VECTOR(X))
#define IS_FULL_MATRIX_SINGLE(X)      (IS_SINGLE(X)      && IS_FULL_MATRIX(X))
#define IS_SCALAR_REAL_SINGLE(X)      (IS_REAL_SINGLE(X) && IS_SCALAR(X))
#define IS_VECTOR_REAL_SINGLE(X)      (IS_REAL_SINGLE(X) && IS_VECTOR(X))
#define IS_SCALAR_CPLX_SINGLE(X)      (IS_CPLX_SINGLE(X) && IS_SCALAR(X))
#define IS_VECTOR_CPLX_SINGLE(X)      (IS_CPLX_SINGLE(X) && IS_VECTOR(X))
#define IS_FULL_MATRIX_REAL_SGL(X)    (IS_REAL_SINGLE(X) && IS_FULL_MATRIX(X))
#define IS_FULL_MATRIX_CPLX_SGL(X)    (IS_CPLX_SINGLE(X) && IS_FULL_MATRIX(X))

#define IS_SCALAR_BOOLEAN(X)          (IS_BOOLEAN(X)     && IS_SCALAR(X))
#define IS_VECTOR_BOOLEAN(X)          (IS_BOOLEAN(X)     && IS_VECTOR(X))
#define IS_FULL_MATRIX_BOOLEAN(X)     (IS_BOOLEAN(X)     && IS_FULL_MATRIX(X))

#define IS_SCALAR_INT8(X)             (IS_INT8(X)        && IS_SCALAR(X))
#define IS_VECTOR_INT8(X)             (IS_INT8(X)        && IS_VECTOR(X))
#define IS_FULL_MATRIX_INT8(X)        (IS_INT8(X)        && IS_FULL_MATRIX(X))
#define IS_SCALAR_REAL_INT8(X)        (IS_REAL_INT8(X)   && IS_SCALAR(X))
#define IS_VECTOR_REAL_INT8(X)        (IS_REAL_INT8(X)   && IS_VECTOR(X))
#define IS_SCALAR_CPLX_INT8(X)        (IS_CPLX_INT8(X)   && IS_SCALAR(X))
#define IS_VECTOR_CPLX_INT8(X)        (IS_CPLX_INT8(X)   && IS_VECTOR(X))
#define IS_FULL_MATRIX_REAL_INT8(X)   (IS_REAL_INT8(X)   && IS_FULL_MATRIX(X))
#define IS_FULL_MATRIX_CPLX_INT8(X)   (IS_CPLX_INT8(X)   && IS_FULL_MATRIX(X))

#define IS_SCALAR_UINT8(X)            (IS_UINT8(X)       && IS_SCALAR(X))
#define IS_VECTOR_UINT8(X)            (IS_UINT8(X)       && IS_VECTOR(X))
#define IS_FULL_MATRIX_UINT8(X)       (IS_UINT8(X)       && IS_FULL_MATRIX(X))
#define IS_SCALAR_REAL_UINT8(X)       (IS_REAL_UINT8(X)  && IS_SCALAR(X))
#define IS_VECTOR_REAL_UINT8(X)       (IS_REAL_UINT8(X)  && IS_VECTOR(X))
#define IS_SCALAR_CPLX_UINT8(X)       (IS_CPLX_UINT8(X)  && IS_SCALAR(X))
#define IS_VECTOR_CPLX_UINT8(X)       (IS_CPLX_UINT8(X)  && IS_VECTOR(X))
#define IS_FULL_MATRIX_REAL_UINT8(X)  (IS_REAL_UINT8(X)  && IS_FULL_MATRIX(X))
#define IS_FULL_MATRIX_CPLX_UINT8(X)  (IS_CPLX_UINT8(X)  && IS_FULL_MATRIX(X))

#define IS_SCALAR_INT16(X)            (IS_INT16(X)       && IS_SCALAR(X))
#define IS_VECTOR_INT16(X)            (IS_INT16(X)       && IS_VECTOR(X))
#define IS_FULL_MATRIX_INT16(X)       (IS_INT16(X)       && IS_FULL_MATRIX(X))
#define IS_SCALAR_REAL_INT16(X)       (IS_REAL_INT16(X)  && IS_SCALAR(X))
#define IS_VECTOR_REAL_INT16(X)       (IS_REAL_INT16(X)  && IS_VECTOR(X))
#define IS_SCALAR_CPLX_INT16(X)       (IS_CPLX_INT16(X)  && IS_SCALAR(X))
#define IS_VECTOR_CPLX_INT16(X)       (IS_CPLX_INT16(X)  && IS_VECTOR(X))
#define IS_FULL_MATRIX_REAL_INT16(X)  (IS_REAL_INT16(X)  && IS_FULL_MATRIX(X))
#define IS_FULL_MATRIX_CPLX_INT16(X)  (IS_CPLX_INT16(X)  && IS_FULL_MATRIX(X))

#define IS_SCALAR_UINT16(X)           (IS_UINT16(X)      && IS_SCALAR(X))
#define IS_VECTOR_UINT16(X)           (IS_UINT16(X)      && IS_VECTOR(X))
#define IS_FULL_MATRIX_UINT16(X)      (IS_UINT16(X)      && IS_FULL_MATRIX(X))
#define IS_SCALAR_REAL_UINT16(X)      (IS_REAL_UINT16(X) && IS_SCALAR(X))
#define IS_VECTOR_REAL_UINT16(X)      (IS_REAL_UINT16(X) && IS_VECTOR(X))
#define IS_SCALAR_CPLX_UINT16(X)      (IS_CPLX_UINT16(X) && IS_SCALAR(X))
#define IS_VECTOR_CPLX_UINT16(X)      (IS_CPLX_UINT16(X) && IS_VECTOR(X))
#define IS_FULL_MATRIX_REAL_UINT16(X) (IS_REAL_UINT16(X) && IS_FULL_MATRIX(X))
#define IS_FULL_MATRIX_CPLX_UINT16(X) (IS_CPLX_UINT16(X) && IS_FULL_MATRIX(X))

#define IS_SCALAR_INT32(X)            (IS_INT32(X)       && IS_SCALAR(X))
#define IS_VECTOR_INT32(X)            (IS_INT32(X)       && IS_VECTOR(X))
#define IS_FULL_MATRIX_INT32(X)       (IS_INT32(X)       && IS_FULL_MATRIX(X))
#define IS_SCALAR_REAL_INT32(X)       (IS_REAL_INT32(X)  && IS_SCALAR(X))
#define IS_VECTOR_REAL_INT32(X)       (IS_REAL_INT32(X)  && IS_VECTOR(X))
#define IS_SCALAR_CPLX_INT32(X)       (IS_CPLX_INT32(X)  && IS_SCALAR(X))
#define IS_VECTOR_CPLX_INT32(X)       (IS_CPLX_INT32(X)  && IS_VECTOR(X))
#define IS_FULL_MATRIX_REAL_INT32(X)  (IS_REAL_INT32(X)  && IS_FULL_MATRIX(X))
#define IS_FULL_MATRIX_CPLX_INT32(X)  (IS_CPLX_INT32(X)  && IS_FULL_MATRIX(X))

#define IS_SCALAR_UINT32(X)           (IS_UINT32(X)      && IS_SCALAR(X))
#define IS_VECTOR_UINT32(X)           (IS_UINT32(X)      && IS_VECTOR(X))
#define IS_FULL_MATRIX_UINT32(X)      (IS_UINT32(X)      && IS_FULL_MATRIX(X))
#define IS_SCALAR_REAL_UINT32(X)      (IS_REAL_UINT32(X) && IS_SCALAR(X))
#define IS_VECTOR_REAL_UINT32(X)      (IS_REAL_UINT32(X) && IS_VECTOR(X))
#define IS_SCALAR_CPLX_UINT32(X)      (IS_CPLX_UINT32(X) && IS_SCALAR(X))
#define IS_VECTOR_CPLX_UINT32(X)      (IS_CPLX_UINT32(X) && IS_VECTOR(X))
#define IS_FULL_MATRIX_REAL_UINT32(X) (IS_REAL_UINT32(X) && IS_FULL_MATRIX(X))
#define IS_FULL_MATRIX_CPLX_UINT32(X) (IS_CPLX_UINT32(X) && IS_FULL_MATRIX(X))

#if 0
  /* NOTE: the following special cases for 64-bit integers require linking in
   * $(MATLABROOT)/extern/lib/$(PLATFORM)/$(COMPILER_VENDOR)/$(COMPILER_VERSION)/libmx.lib
   * if these are needed.  For now these have been removed until there is a need...
   */
  #define IS_SCALAR_INT64(X)            (IS_INT64(X)       && IS_SCALAR(X))
  #define IS_VECTOR_INT64(X)            (IS_INT64(X)       && IS_VECTOR(X))
  #define IS_FULL_MATRIX_INT64(X)       (IS_INT64(X)       && IS_FULL_MATRIX(X))
  #define IS_SCALAR_REAL_INT64(X)       (IS_REAL_INT64(X)  && IS_SCALAR(X))
  #define IS_VECTOR_REAL_INT64(X)       (IS_REAL_INT64(X)  && IS_VECTOR(X))
  #define IS_SCALAR_CPLX_INT64(X)       (IS_CPLX_INT64(X)  && IS_SCALAR(X))
  #define IS_VECTOR_CPLX_INT64(X)       (IS_CPLX_INT64(X)  && IS_VECTOR(X))
  #define IS_FULL_MATRIX_REAL_INT64(X)  (IS_REAL_INT64(X)  && IS_FULL_MATRIX(X))
  #define IS_FULL_MATRIX_CPLX_INT64(X)  (IS_CPLX_INT64(X)  && IS_FULL_MATRIX(X))

  #define IS_SCALAR_UINT64(X)           (IS_UINT64(X)      && IS_SCALAR(X))
  #define IS_VECTOR_UINT64(X)           (IS_UINT64(X)      && IS_VECTOR(X))
  #define IS_FULL_MATRIX_UINT64(X)      (IS_UINT64(X)      && IS_FULL_MATRIX(X))
  #define IS_SCALAR_REAL_UINT64(X)      (IS_REAL_UINT64(X) && IS_SCALAR(X))
  #define IS_VECTOR_REAL_UINT64(X)      (IS_REAL_UINT64(X) && IS_VECTOR(X))
  #define IS_SCALAR_CPLX_UINT64(X)      (IS_CPLX_UINT64(X) && IS_SCALAR(X))
  #define IS_VECTOR_CPLX_UINT64(X)      (IS_CPLX_UINT64(X) && IS_VECTOR(X))
  #define IS_FULL_MATRIX_REAL_UINT64(X) (IS_REAL_UINT64(X) && IS_FULL_MATRIX(X))
  #define IS_FULL_MATRIX_CPLX_UINT64(X) (IS_CPLX_UINT64(X) && IS_FULL_MATRIX(X))
#endif

/* Determine number of bytes in input parameter data type PER SAMPLE.
 * Note: complex parameters have twice as many bytes per sample.
 *       mxGetElementSize returns the number of bytes per REAL element only.
 */
#define GET_SFCN_PARAM_NUM_BYTES_PER_SAMPLE(X) ((1 + (int_T)(mxIsComplex(X))) * mxGetElementSize(X))

/* Determine TOTAL number of bytes in input parameter array (or matrix) */
/* Note: complex parameters have twice as many bytes per sample...      */
#define GET_SFCN_PARAM_NUM_BYTES_TOTAL(S,X,ARGC) (GET_SFCN_NUM_ELEMENTS(S,ARGC) * GET_SFCN_PARAM_NUM_BYTES_PER_SAMPLE(X))

/* Check that the scalar double is in a certain range: */
#define IS_SCALAR_DOUBLE_GREATER_THAN(X,V) (IS_SCALAR_DOUBLE(X) && (mxGetPr(X)[0] >  (real_T)V))
#define IS_SCALAR_DOUBLE_GE(X,V)           (IS_SCALAR_DOUBLE(X) && (mxGetPr(X)[0] >= (real_T)V))

/* Check an element of a vector: */
#define IS_IDX_FLINT(X,IDX) (IS_REAL_DOUBLE(X) && \
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
 * Function: interleaveComplexData
 *
 * Abstract: 
 *     This function will interleave the real and imaginary elements 
 *     pointed at by srcRealPtr and srcImagPtr into the memory area
 *     pointed at by dstPtr.  This function will *NOT* allocate the
 *     necessary memory area for dstPtr - it is the calling function's
 *     responsibility to do so prior to calling this function.  Also,
 *     since it is envisaged that this function will be called frequently,
 *     the function does not waste time doing validation checking.  It
 *     assumes the following:
 *     srcRealPtr == pre-allocated, srcImagPtr == pre-allocated
 *     size of srcRealPtr area = size of srcImagPtr area
 *     dstPtr == pre-allocated twice size of srcRealPtr area
 *     numElems > 0
 *     bytesPerRealElement > 0
 *
 * Inputs:
 *     - const byte_T *srcRealPtr
 *       - A pointer to a memory area containing numElems number of data
 *         elements representing the "real" part of the to-be-interleaved
 *         data.  Equivalently, srcRealPtr points to a memory area that
 *         contains (numElems*bytesPerRealElement) bytes of data.
 *     - const byte_T *srcImagPtr
 *       - A pointer to a memory area containing numElems number of data
 *         elements representing the "imag" part of the to-be-interleaved
 *         data.  Equivalently, srcImagPtr points to a memory area that
 *         contains (numElems*bytesPerRealElement) bytes of data.
 *     - byte_T *dstPtr
 *       - A pointer to a memory area that has allocated space to hold
 *         (2*numElems*bytesPerRealElement) bytes of data.
 *     - int_T numElems
 *       - The number of "elements" in srcRealPtr, assumed equal to the
 *         number of "elements" in srcImagPtr.  numElems is assumed to be
 *         greater than zero.  If numElems <= 0, nothing happens.
 *     - int_T bytesPerRealElement
 *       - The number of bytes per element.  Assumed greater than zero.
 *         If bytesPerRealElement <= 0, and numElems > 0, you can expect
 *         unexpected things to happen.
 *
 * Functional spec:
 *     - In array notation, here's how the interleaving happens:
 *       dstPtr[0] = srcRealPtr[0]
 *       dstPtr[1] = srcImagPtr[0]
 *       dstPtr[2] = srcRealPtr[1]
 *       dstPtr[3] = srcImagPtr[1]
 *       ... and so on.
 *     - The actual mechanics of the interleaving are done using calls to
 *       memcpy().
 */
DSP_COMMON_SIM_EXPORT void interleaveComplexData( const byte_T *srcRealPtr, 
                                   const byte_T *srcImagPtr, 
                                   byte_T       *dstPtr, 
                                   int_T         numElems, 
                                   int_T         bytesPerRealElement );


/*
 * Function: interleaveRealDataWithImagElement 
 *
 * Abstract:
 *     This function interleaves the numElems elements stored in the
 *     memory area pointed at by srcRealPtr with the single element
 *     stored in the memory area pointed at by imagElementPtr.  The
 *     resulting 2*numElems elements are stored in the memory area
 *     pointed at by dstPtr.  It is assumed that each element in
 *     srcRealPtr (and the one element in imagElementPtr) is exactly
 *     bytesPerRealElement long.  This function will *NOT* allocate
 *     the necessary memory area for dstPtr - it is the calling
 *     function's responsibility to do so prior to calling this
 *     function.  Also, since it is envisaged that this function will
 *     be called frequently, the function does not waste time doing
 *     validation checking.  It assumes the following: 
 *     srcRealPtr == pre-allocated, atleast (numElems*bytesPerRealElement)
 *     imagElementPtr == pre-allocated, atleast bytesPerRealElement
 *     dstPtr == pre-allocated twice size of srcRealPtr area 
 *     numElems > 0 bytesPerRealElement > 0
 *
 * Inputs:
 *     - byte_T *srcRealPtr
 *       - A pointer to a memory area containing numElems number of data
 *         elements representing the "real" part of the to-be-interleaved
 *         data.  Equivalently, srcRealPtr points to a memory area that
 *         contains (numElems*bytesPerRealElement) bytes of data.
 *     - byte_T *imagElementPtr
 *       - A pointer to a memory area containing a single element of data,
 *         representing the "imag" part of the to-be-interleaved
 *         data.  Equivalently, imagElementPtr points to a memory area
 *         that contains (bytesPerRealElement) bytes of data.
 *     - byte_T *dstPtr
 *       - A pointer to a memory area that has allocated space to hold
 *         (2*numElems*bytesPerRealElement) bytes of data.
 *     - int_T numElems
 *       - The number of "elements" in srcRealPtr.  numElems is 
 *         assumed to be greater than zero.
 *         If numElems <= 0, nothing happens.
 *     - int_T bytesPerRealElement
 *       - The number of bytes per element.  Assumed greater than zero.
 *         If bytesPerRealElement <= 0, and numElems > 0, you can expect
 *         unexpected things to happen.
 *
 * Functional spec:
 *     - In array notation, here's how the interleaving happens:
 *       dstPtr[0] = srcRealPtr[0]
 *       dstPtr[1] = imagElementPtr[0]
 *       dstPtr[2] = srcRealPtr[1]
 *       dstPtr[3] = imagElementPtr[0]
 *       ... and so on.
 *     - The actual mechanics of the interleaving are done using calls to
 *       memcpy().  
 */
DSP_COMMON_SIM_EXPORT void interleaveRealDataWithImagElement( const byte_T *srcRealPtr,
                                               const byte_T *imagElementPtr,
                                               byte_T       *dstPtr,
                                               int_T         numElems,
                                               int_T         bytesPerRealElement );


/*  The following function "getScalarParamSingle(S, array)" is used to read in 
 *  the Real parameter (or the real part of a complex parameter) from a mask edit 
 *  box in the case when the block is working in single precision mode. 
 *  The  argument  "array"  is the mxArray read from the mask
 *  edit box and the return argument is a real32_T variable which 
 *  is the (real part of a) single precision parameter value. 
 */

DSP_COMMON_SIM_EXPORT real32_T getRealScalarParamSingle(SimStruct *S, const mxArray *array);                                

/* The function below reads the Imaginary part of a mask parameter
 * and returns the single precision equivalent of it. 
 */

DSP_COMMON_SIM_EXPORT real32_T getImagScalarParamSingle(SimStruct *S, const mxArray *array);                                


/*  The following function "getScalarParamDouble(S,array)" is used to read in 
 *  the Real parameter (or the real part of a complex parameter) from a mask edit 
 *  box in the case when the block is working in double precision mode. 
 *  The  argument  "array"  is the mxArray read from the mask
 *  edit box and the second argument is a real_T variable which is
 *  the (real part of a) double precision parameter value. 
 */
DSP_COMMON_SIM_EXPORT real_T getRealScalarParamDouble(SimStruct *S, const mxArray *array);

/* The function below reads the Imaginary part of a mask parameter
 * and returns the double precision equivalent of it. 
 */

DSP_COMMON_SIM_EXPORT real_T getImagScalarParamDouble(SimStruct *S, const mxArray *array);

#endif  /* dsp_sfcn_param_sim_h */

/* [EOF] dsp_sfcn_param_sim.h */
