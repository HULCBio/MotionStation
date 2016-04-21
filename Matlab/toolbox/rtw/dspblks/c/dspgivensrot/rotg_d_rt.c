/*
 *  rotg_d_rt.c
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.3.2.2 $ $Date: 2004/04/12 23:45:10 $
 */
#include "dspgivensrot_rt.h"

/*
 * rotg - construct Givens plane rotation 
 */
EXPORT_FCN void rotg(real_T *x, real_T *y, real_T *c, real_T *s)
{
    real_T rho, r, z, absx, absy;
    
    rho = ((absx = fabs(*x)) > (absy = fabs(*y))) ? *x : *y;
    CHYPOT(*x, *y, r);
    r   = (rho > 0.0) ? r : -r;
    *c  = (r == 0.0) ? 1.0 : *x / r;
    *s  = (r == 0.0) ? 0.0 : *y / r;
    z   = (absx > absy) ? *s : 1.0;
    z   = (absy >= absx && *c != 0.0) ? 1.0 / *c : z; 
    *x = r;	
    *y = z;
}


/* [EOF] rotg_d_rt.c */
