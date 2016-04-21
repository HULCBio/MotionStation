/*   Copyright 1990-2002 The MathWorks, Inc. */
/* $Revision: 1.5 $ */
/* 
 * File : sfun_frmunbuff_wrapper.c
 * Abstract:
 *    Routine that implement the unbuffer
 *
 */

#include "tmwtypes.h"
#include "sfun_frmunbuff_wrapper.h"
#include <math.h>

void sfun_frm_unbuff_wrapper(int count, int nChans, int frmSize,
                                    real_T *y, real_T *u)
{
    int_T  i;

#ifdef S_DEBUG       
    for (i = 0; i < nChans * frmSize; i++) {
        printf("In[%d]  = %f\n", i, u[i]);
    }
#endif
    
    u += count;
    
    for (i = 0; i < nChans; i++) {
        y[i] = *u;
        u += frmSize;
#ifdef S_DEBUG       
        printf("Out[%d] = %f\n", i, y[i]);
#endif
    }
}

/* [EOF] sfun_frmunbuff_wrapper.c */
