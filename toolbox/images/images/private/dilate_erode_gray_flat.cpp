/* 
 * Copyright 1993-2003 The MathWorks, Inc.
 * $Revision: 1.1.6.1 $  $Date: 2003/01/26 05:59:14 $
 * 
 * Functions for flat grayscale dilation and erosion.  The actual dilation
 * and erosion algorithm code can be found in dilate_erode_gray_flat.h.
 * That code is parameterized to achieve dilation and erosion for all the
 * different numeric types by #defining TYPE, COMPARE_OP, and INIT_VAL.
 *
 * Note that the dilation functions in this module all require reflected
 * neighborhoods.
 */

static char rcsid[] = "$Id: dilate_erode_gray_flat.cpp,v 1.1.6.1 2003/01/26 05:59:14 batserve Exp $";

#include "morphmex.h"

/*
 * dilate_gray_flat_uint8
 * Perform flat grayscale dilation on a uint8 array.
 *
 * Inputs
 * ======
 * In             - pointer to first element of input array
 * num_elements   - number of elements in input and output arrays
 * walker         - neighborhood walker corresponding to reflected structuring
 *                  element
 *
 * Output
 * ======
 * Out            - pointer to first element of output array
 */
#define TYPE uint8_T
#define COMPARE_OP >
#define INIT_VAL MIN_uint8_T
void dilate_gray_flat_uint8
#include "dilate_erode_gray_flat.h"

/*
 * dilate_gray_flat_uint16
 */
#define TYPE uint16_T
#define COMPARE_OP >
#define INIT_VAL MIN_uint16_T
void dilate_gray_flat_uint16
#include "dilate_erode_gray_flat.h"

/*
 * dilate_gray_flat_uint32
 */
#define TYPE uint32_T
#define COMPARE_OP >
#define INIT_VAL MIN_uint32_T
void dilate_gray_flat_uint32
#include "dilate_erode_gray_flat.h"

/*
 * dilate_gray_flat_int8
 */
#define TYPE int8_T
#define COMPARE_OP >
#define INIT_VAL MIN_int8_T
void dilate_gray_flat_int8
#include "dilate_erode_gray_flat.h"

/*
 * dilate_gray_flat_int16
 */
#define TYPE int16_T
#define COMPARE_OP >
#define INIT_VAL MIN_int16_T
void dilate_gray_flat_int16
#include "dilate_erode_gray_flat.h"

/*
 * dilate_gray_flat_int32
 */
#define TYPE int32_T
#define COMPARE_OP >
#define INIT_VAL MIN_int32_T
void dilate_gray_flat_int32
#include "dilate_erode_gray_flat.h"

/*
 * dilate_gray_flat_single
 */
#define TYPE float
#define COMPARE_OP >
#define INIT_VAL ( (float) -mxGetInf() )
void dilate_gray_flat_single
#include "dilate_erode_gray_flat.h"

/*
 * dilate_gray_flat_double
 */
#define TYPE double
#define COMPARE_OP >
#define INIT_VAL ( -mxGetInf() )
void dilate_gray_flat_double
#include "dilate_erode_gray_flat.h"

/*
 * erode_gray_flat_uint8
 * Perform flat grayscale erosion on a uint8 array.
 *
 * Inputs
 * ======
 * In             - pointer to first element of input array
 * num_elements   - number of elements in input and output arrays
 * walker         - neighborhood walker corresponding to structuring element
 *
 * Output
 * ======
 * Out            - pointer to first element of output array
 */
#define TYPE uint8_T
#define COMPARE_OP <
#define INIT_VAL MAX_uint8_T
void erode_gray_flat_uint8
#include "dilate_erode_gray_flat.h"

/*
 * erode_gray_flat_uint16
 */
#define TYPE uint16_T
#define COMPARE_OP <
#define INIT_VAL MAX_uint16_T
void erode_gray_flat_uint16
#include "dilate_erode_gray_flat.h"

/*
 * erode_gray_flat_uint32
 */
#define TYPE uint32_T
#define COMPARE_OP <
#define INIT_VAL MAX_uint32_T
void erode_gray_flat_uint32
#include "dilate_erode_gray_flat.h"

/*
 * erode_gray_flat_int8
 */
#define TYPE int8_T
#define COMPARE_OP <
#define INIT_VAL MAX_int8_T
void erode_gray_flat_int8
#include "dilate_erode_gray_flat.h"

/*
 * erode_gray_flat_int16
 */
#define TYPE int16_T
#define COMPARE_OP <
#define INIT_VAL MAX_int16_T
void erode_gray_flat_int16
#include "dilate_erode_gray_flat.h"

/*
 * erode_gray_flat_int32
 */
#define TYPE int32_T
#define COMPARE_OP <
#define INIT_VAL MAX_int32_T
void erode_gray_flat_int32
#include "dilate_erode_gray_flat.h"

/*
 * erode_gray_flat_single
 */
#define TYPE float
#define COMPARE_OP <
#define INIT_VAL ( (float) mxGetInf() )
void erode_gray_flat_single
#include "dilate_erode_gray_flat.h"

/*
 * erode_gray_flat_double
 */
#define TYPE double
#define COMPARE_OP <
#define INIT_VAL ( mxGetInf() )
void erode_gray_flat_double
#include "dilate_erode_gray_flat.h"

