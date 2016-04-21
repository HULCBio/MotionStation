#include <string.h> /* needed for memcpy() */
#include "mex.h"

/*
 * doubleelement.c - example found in API guide
 *
 * constructs a 2-by-2 matrix with unsigned 16-bit integers, doubles
 * each element, and returns the matrix
 *
 * This is a MEX-file for MATLAB.
 * Copyright 1984-2000 The MathWorks, Inc.
 */

/* $Revision: 1.9 $ */

#define NDIMS 2
#define TOTAL_ELEMENTS 4

/* the computational subroutine */
void dbl_elem(unsigned short *x)
{
  unsigned short scalar=2;
  int i,j;

  for(i=0;i<2;i++) {
    for(j=0;j<2;j++) {
      *(x+i+j) = scalar * *(x+i+j);
    }
  }
}

/* the gataway function */
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{
  const int dims[]={2,2};
  unsigned char *start_of_pr;
  unsigned short data[]={1,2,3,4};
  int bytes_to_copy;

  /* call the computational subroutine */
  dbl_elem(data);

  /* create a 2-by-2 array of unsigned 16-bit integers */
  plhs[0] = mxCreateNumericArray(NDIMS,dims,mxUINT16_CLASS,mxREAL);

  /* populate the real part of the created array */
  start_of_pr = (unsigned char *)mxGetData(plhs[0]);
  bytes_to_copy = TOTAL_ELEMENTS * mxGetElementSize(plhs[0]);
  memcpy(start_of_pr,data,bytes_to_copy);
}
