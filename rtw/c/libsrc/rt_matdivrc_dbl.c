/* Copyright 1994-2003 The MathWorks, Inc.
 *
 * File: rt_matdivrc_dbl.c     $Revision: 1.4.4.2 $
 *
 * Abstract:
 *      Real-Time Workshop support routine which performs
 *      matrix inversion: inv(In1)*In2 using LU factorization.
 *
 */

#include <string.h>   /* needed for memcpy */
#include "rtlibsrc.h"

/* Function: rt_MatDivRC_Dbl ===================================================
 * Abstract: 
 *           Calculate inv(In1)*In2 using LU factorization.
 */
#ifdef CREAL_T
void rt_MatDivRC_Dbl(creal_T   *Out,
                     real_T    *In1,
                     creal_T   *In2,
                     real_T    *lu,
                     int32_T   *piv,
                     creal_T   *x,
                     const int dims[3])
{
  int N = dims[0];
  int N2 = N * N;
  int P = dims[2];
  int NP = N * P;
  const boolean_T unit_upper = FALSE;
  const boolean_T unit_lower = TRUE;

  (void)memcpy(lu, In1, N2*sizeof(real_T));

  rt_lu_real(lu, N, piv);

  rt_ForwardSubstitutionRC_Dbl(lu, In2, x, N, P, piv, unit_lower);

  rt_BackwardSubstitutionRC_Dbl(lu + N2 -1, x + NP -1, Out, N, P, unit_upper);
}
#endif
/* [EOF] rt_matdivrc_dbl.c */
