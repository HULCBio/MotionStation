/*
 * File    : sfun_slutils.h
 * Abstract:
 *   External definitions for sfun_utils.c, general utility routines for
 *   S-functions, see sfun_utils.c
 *  
 * 
 *  Copyright 1990-2002 The MathWorks, Inc.
 *  $Revision: 1.4 $
 */

#ifndef sfun_slutils_h
#define sfun_slutils_h

extern boolean_T IsRealMatrix(const mxArray *m);
extern boolean_T IsDoubleMatrix(const mxArray *m);

extern boolean_T IsRealVect(const mxArray *m);
extern boolean_T IsDoubleVect(const mxArray *m);
#endif
