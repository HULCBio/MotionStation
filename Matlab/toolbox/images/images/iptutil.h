/*
 * Copyright 1993-2003 The MathWorks, Inc.
 * $Revision: 1.8.4.2 $
 */


#ifndef IPTUTIL_H
#define IPTUTIL_H

#include "mex.h"


#ifdef __cplusplus
    extern "C" {
#endif

mxArray *call_one_input_one_output_function(const mxArray *A, 
                                            const char *function_name);

mxArray *convert_to_logical(const mxArray *A);

void check_nargin(double low, 
                  double high, 
                  int numInputs, 
                  const char *function_name);

extern void check_input(const mxArray *A,
                        const char    *classes,
                        const char    *attributes,
                        const char    *function_name,
                        const char    *variable_name,
                        int           argument_position);

extern bool is_inside(int p, int r_offset, int c_offset, int M, int N);

extern void init_neighbors(int style, int M, int nhood_r[8], int nhood_c[8], 
                           int nhood[8], int *num_neighbors);

#ifdef __cplusplus
    }   /* extern "C" */
#endif

#endif /* IPTUTIL_H */
