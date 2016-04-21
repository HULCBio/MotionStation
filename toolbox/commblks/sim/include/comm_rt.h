/*
* COMM_RT.H Communications Blockset S-Function include file
* for real time code generation.
*
* NOTE for the future:
* this file needs to be moved in to the realtime code generation
* folders when they are created
*
*   Copyright 1996-2004 The MathWorks, Inc.
*   $Revision: 1.1.6.3 $
*   $Date: 2004/04/12 23:03:12 $
*/
#ifndef __COMM_RT__
#define __COMM_RT__
/* DSP files to include for all s-functions
 *
 *  Include dsp_sim.h for simulation and dsp_rt.h for RTW (without TLC's)
 *
 */
#define MWDSPSIMONLY_DO_NOT_INCLUDE_RTWTYPES_H
#include "dsp_rt.h"

/* FIXME: Currently the COMMBLKS has no TLCS and so for rtw support we need to
 *        include simstruc.h and some other definitions.
 *        As we add TLCs for the sfunctions in the COMMBLKS, we need to 
 *        #define COMMBLKS_HAS_TLCS before including comm_defs.h.
 *        Once all of the sfunctions have TLCS, we can delete this block.  
 */
#ifndef COMMBLKS_HAS_TLCS
#   include "simstruc.h"
#   define THROW_ERROR(S,MSG) {ssSetErrorStatus(S,MSG); return;}
#   define IS_SCALAR(X)        (mxGetNumberOfElements(X) == 1)
#endif

#endif /* __COMM_RT__ */
