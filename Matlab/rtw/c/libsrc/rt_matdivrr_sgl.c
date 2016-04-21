/* Copyright 1994-2002 The MathWorks, Inc.
 *
 * File: rt_matdivrr_dbl.c     $Revision: 1.2 $
 *
 * Abstract:
 *      Real-Time Workshop support routine which performs
 *      matrix inversion for two real double precision float operands
 *
 */

#include <string.h>   /* needed for memcpy */
#include "rtlibsrc.h"

/*
 * Function: rt_MatDivRR_Sgl
 * Abstract:
 *      2-real double input matrix division function
 */
void rt_MatDivRR_Sgl(real32_T    *Out,
                     real32_T    *In1,
                     real32_T    *In2,
                     real32_T    *lu,
                     int32_T   *piv,
                     real32_T    *x,
                     const int dims[3])
{
  int N = dims[0];
  int N2 = N * N;
  int P = dims[2];
  int NP = N * P;
  const boolean_T unit_upper = FALSE;
  const boolean_T unit_lower = TRUE;

  (void)memcpy(lu, In1, N2*sizeof(real_T));

  rt_lu_real_sgl(lu, N, piv);

  rt_ForwardSubstitutionRR_Sgl(lu, In2, x, N, P, piv, unit_lower);

  rt_BackwardSubstitutionRR_Sgl(lu + N2 -1, x + NP -1, Out, N, P, unit_upper);
}

/* [EOF] rt_matdivrr_dbl.c */
