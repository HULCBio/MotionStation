/*
 * Copyright 1984-2001 The MathWorks, Inc.
 * $Revision: 1.4 $  $Date: 2002/06/17 13:29:41 $
 *
 * Instantiations of lexicographic comparison functions for each of the
 * nonsparse numeric classes and for char.
 *
 * compare_fcn.h contains the parameterized function body of the comparison
 * function.
 */

#include "lexicmp.h"
#include "mex.h"

static char rcsid[] = "$Id";

#define TYPE mxLogical
int lexi_compare_mxlogical
#include "compare_fcn.h"

#define TYPE mxChar
int lexi_compare_mxchar
#include "compare_fcn.h"

#define TYPE uint8_T
int lexi_compare_uint8
#include "compare_fcn.h"

#define TYPE uint16_T
int lexi_compare_uint16
#include "compare_fcn.h"

#define TYPE uint32_T
int lexi_compare_uint32
#include "compare_fcn.h"

#define TYPE uint64_T
int lexi_compare_uint64
#include "compare_fcn.h"

#define TYPE int8_T
int lexi_compare_int8
#include "compare_fcn.h"

#define TYPE int16_T
int lexi_compare_int16
#include "compare_fcn.h"

#define TYPE int32_T
int lexi_compare_int32
#include "compare_fcn.h"

#define TYPE int64_T
int lexi_compare_int64
#include "compare_fcn.h"

#define TYPE float
#define DO_NAN_CHECK
int lexi_compare_single
#include "compare_fcn.h"

#define TYPE double
#define DO_NAN_CHECK
int lexi_compare_double
#include "compare_fcn.h"


