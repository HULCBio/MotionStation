/* 
 * Copyright 1993-2003 The MathWorks, Inc.
 * $Revision: 1.1.6.1 $  $Date: 2003/01/26 05:59:16 $
 * 
 * Functions for nonflat grayscale dilation and erosion.  The actual dilation
 * and erosion algorithm code can be found in dilate_erode_gray_nonflat.h.
 * That code is parameterized to achieve dilation and erosion for all the
 * different numeric types by #defining TYPE, COMPARE_OP, INIT_VAL, DO_ROUND,
 * MIN_VAL, and MAX_VAL.
 *
 * Note that the dilation functions in this module all require reflected
 * neighborhoods.
 */

static char rcsid[] = "$Id: dilate_erode_gray_nonflat.cpp,v 1.1.6.1 2003/01/26 05:59:16 batserve Exp $";

#include "morphmex.h"

/*
 * dilate_gray_nonflat_uint8
 * Perform nonflat grayscale dilation on a uint8 array.
 *
 * Inputs
 * ======
 * In             - pointer to first element of input array
 * num_elements   - number of elements in input and output arrays
 * walker         - neighborhood walker corresponding to reflected structuring
 *                  element
 * height         - pointer to array of heights; one height value 
 *                  corresponding to each neighborhood element.
 *
 * Output
 * ======
 * Out            - pointer to first element of output array
 */
#define TYPE uint8_T
#define INIT_VAL MIN_uint8_T
#define DO_ROUND
#define MIN_VAL MIN_uint8_T
#define MAX_VAL MAX_uint8_T
#define COMBINE_OP +
#define COMPARE_OP >
void dilate_gray_nonflat_uint8
#include "dilate_erode_gray_nonflat.h"

/*
 * dilate_gray_nonflat_uint16
 */
#define TYPE uint16_T
#define INIT_VAL MIN_uint16_T
#define DO_ROUND
#define MIN_VAL MIN_uint16_T
#define MAX_VAL MAX_uint16_T
#define COMBINE_OP +
#define COMPARE_OP >
void dilate_gray_nonflat_uint16
#include "dilate_erode_gray_nonflat.h"

/*
 * dilate_gray_nonflat_uint32
 */
#define TYPE uint32_T
#define INIT_VAL MIN_uint32_T
#define DO_ROUND
#define MIN_VAL MIN_uint32_T
#define MAX_VAL MAX_uint32_T
#define COMBINE_OP +
#define COMPARE_OP >
void dilate_gray_nonflat_uint32
#include "dilate_erode_gray_nonflat.h"

/*
 * dilate_gray_nonflat_int8
 */
#define TYPE int8_T
#define INIT_VAL MIN_int8_T
#define DO_ROUND
#define MIN_VAL MIN_int8_T
#define MAX_VAL MAX_int8_T
#define COMBINE_OP +
#define COMPARE_OP >
void dilate_gray_nonflat_int8
#include "dilate_erode_gray_nonflat.h"

/*
 * dilate_gray_nonflat_int16
 */
#define TYPE int16_T
#define INIT_VAL MIN_int16_T
#define DO_ROUND
#define MIN_VAL MIN_int16_T
#define MAX_VAL MAX_int16_T
#define COMBINE_OP +
#define COMPARE_OP >
void dilate_gray_nonflat_int16
#include "dilate_erode_gray_nonflat.h"

/*
 * dilate_gray_nonflat_int32
 */
#define TYPE int32_T
#define INIT_VAL MIN_int32_T
#define DO_ROUND
#define MIN_VAL MIN_int32_T
#define MAX_VAL MAX_int32_T
#define COMBINE_OP +
#define COMPARE_OP >
void dilate_gray_nonflat_int32
#include "dilate_erode_gray_nonflat.h"

/*
 * dilate_gray_nonflat_single
 */
#define TYPE float
#define INIT_VAL ( (float) -mxGetInf() )
#define COMBINE_OP +
#define COMPARE_OP >
void dilate_gray_nonflat_single
#include "dilate_erode_gray_nonflat.h"

/*
 * dilate_gray_nonflat_double
 */
#define TYPE double
#define INIT_VAL ( -mxGetInf() )
#define COMBINE_OP +
#define COMPARE_OP >
void dilate_gray_nonflat_double
#include "dilate_erode_gray_nonflat.h"

/*
 * erode_gray_nonflat_uint8
 * Perform nonflat grayscale erosion on a uint8 array.
 *
 * Inputs
 * ======
 * In             - pointer to first element of input array
 * num_elements   - number of elements in input and output arrays
 * walker         - neighborhood walker corresponding to structuring element
 * height         - pointer to array of heights; one height value 
 *                  corresponding to each neighborhood element.
 *
 * Output
 * ======
 * Out            - pointer to first element of output array
 */
#define TYPE uint8_T
#define INIT_VAL MAX_uint8_T
#define DO_ROUND
#define MIN_VAL MIN_uint8_T
#define MAX_VAL MAX_uint8_T
#define COMBINE_OP -
#define COMPARE_OP <
void erode_gray_nonflat_uint8
#include "dilate_erode_gray_nonflat.h"

/*
 * erode_gray_nonflat_uint16
 */
#define TYPE uint16_T
#define INIT_VAL MAX_uint16_T
#define DO_ROUND
#define MIN_VAL MIN_uint16_T
#define MAX_VAL MAX_uint16_T
#define COMBINE_OP -
#define COMPARE_OP <
void erode_gray_nonflat_uint16
#include "dilate_erode_gray_nonflat.h"

/*
 * erode_gray_nonflat_uint32
 */
#define TYPE uint32_T
#define INIT_VAL MAX_uint32_T
#define DO_ROUND
#define MIN_VAL MIN_uint32_T
#define MAX_VAL MAX_uint32_T
#define COMBINE_OP -
#define COMPARE_OP <
void erode_gray_nonflat_uint32
#include "dilate_erode_gray_nonflat.h"

/*
 * erode_gray_nonflat_int8
 */
#define TYPE int8_T
#define INIT_VAL MAX_int8_T
#define DO_ROUND
#define MIN_VAL MIN_int8_T
#define MAX_VAL MAX_int8_T
#define COMBINE_OP -
#define COMPARE_OP <
void erode_gray_nonflat_int8
#include "dilate_erode_gray_nonflat.h"

/*
 * erode_gray_nonflat_int16
 */
#define TYPE int16_T
#define INIT_VAL MAX_int16_T
#define DO_ROUND
#define MIN_VAL MIN_int16_T
#define MAX_VAL MAX_int16_T
#define COMBINE_OP -
#define COMPARE_OP <
void erode_gray_nonflat_int16
#include "dilate_erode_gray_nonflat.h"

/*
 * erode_gray_nonflat_int32
 */
#define TYPE int32_T
#define INIT_VAL MAX_int32_T
#define DO_ROUND
#define MIN_VAL MIN_int32_T
#define MAX_VAL MAX_int32_T
#define COMBINE_OP -
#define COMPARE_OP <
void erode_gray_nonflat_int32
#include "dilate_erode_gray_nonflat.h"

/*
 * erode_gray_nonflat_single
 */
#define TYPE float
#define INIT_VAL ( (float) mxGetInf() )
#define COMBINE_OP -
#define COMPARE_OP <
void erode_gray_nonflat_single
#include "dilate_erode_gray_nonflat.h"

/*
 * erode_gray_nonflat_double
 */
#define TYPE double
#define INIT_VAL ( mxGetInf() )
#define COMBINE_OP -
#define COMPARE_OP <
void erode_gray_nonflat_double
#include "dilate_erode_gray_nonflat.h"




