/* HIST_C_RT Function to  which bins the elements of input vector into N
 * equally spaced containers and outputs the number of elements in each container. 
 *
 *  This function creates a histogram for single-precision complex data. 
 * 
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.4.2.3 $  $Date: 2004/04/12 23:45:12 $
 */

#include "dsp_rt.h"

EXPORT_FCN void MWDSP_HistC(
        const creal32_T *u_data,
        real32_T *y,
        int_T nChans,
        int_T nSamps,
        real32_T umin,
        real32_T umax, 
        int_T Nbins,
        real32_T idelta)
{
    /* Channel loop */
    while(nChans-- > 0) {
        int_T j = nSamps;

        /* Sample loop */
        while(j-- > 0) {
           int_T i;
           real32_T val = sqrtf(CMAGSQ(*u_data));
           u_data++;
            /* Update appropriate histogram bin: */
	        if (val <= umin) {
		        i = 0;
	        } else if (val > umax) {
		        i = Nbins-1;
	        } else {
		        i = (int_T)(ceilf((val-umin) * idelta) - 1) ;
                        i = MIN(i, Nbins-1);
	        }
            (*(y + i))++;
        }
        y += Nbins;
    }
}

/* [EOF] hist_c_rt.c */


