/* $Revision: 1.2.2.2 $ */
/*
 *  rotg_r_rt.c
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 */
#include "dspgivensrot_rt.h"

/*
 * rotg - construct Givens plane rotation 
 */
EXPORT_FCN void rotg32(real32_T *x, real32_T *y, real32_T *c, real32_T *s)
{
    real32_T rho, r, z, absx, absy;
    
    rho = ((absx = FABS32(*x)) > (absy = FABS32(*y))) ? *x : *y;
    CHYPOT32(*x, *y, r);
    r   = (rho > 0.0F) ? r : -r;
    *c  = (r == 0.0F) ? 1.0F : *x / r;
    *s  = (r == 0.0F) ? 0.0F : *y / r;
    z   = (absx > absy) ? *s : 1.0F;
    z   = (absy >= absx && *c != 0.0F) ? 1.0F / *c : z; 
    *x = r;	
    *y = z;
}


/* [EOF] rotg_d_rt.c */
