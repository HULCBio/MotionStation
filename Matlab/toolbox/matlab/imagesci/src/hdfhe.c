/* Copyright 1984-2002 The MathWorks, Inc.  */

/*
 * hdfhe.c --- support file for HDF.MEX
 *
 * This module supports a *portion* of the HDF HE interface.  The only public
 * function is hdfHE(), which is called by mexFunction().
 * hdfHE looks at the second input argument to determine which
 * private function should get control.
 *
 * Syntaxes
 * ========
 * hdf('HE', 'clear')
 * 
 * hdf('HE', 'print', level)
 *     If level is 0, the entire error stack is printed.
 *
 * error_text = hdf('HE', 'string', error_code)
 *
 * error_code = hdf('HE', 'value', stack_offset)
 *              stack_offset of 1 gets the most recent error code
 *
 *
 */

/* $Revision: 1.1.6.1 $  $Date: 2003/12/13 03:02:08 $ */

static char rcsid[] = "$Id: hdfhe.c,v 1.1.6.1 2003/12/13 03:02:08 batserve Exp $";

#include <string.h>

/* Main HDF library header file */
#include "hdf.h"

/* MATLAB API header file */
#include "mex.h"

/* HDFMEX utility functions */
#include "hdfutils.h"

#include "hdfhe.h"

/*
 * hdfHEvalue
 *
 * Purpose: gateway to HEvalue()
 * 
 * MATLAB usage:
 * error_code = hdf('HE', 'value', stack_offset)
 *              stack_offset of 1 gets the most recent error code
 */
static void hdfHEvalue(int nlhs,
                       mxArray *plhs[],
                       int nrhs,
                       const mxArray *prhs[])
{
    intn stack_offset;

    haNarginChk(3, 3, nrhs);
    haNargoutChk(0, 1, nlhs);

    stack_offset = (intn) haGetDoubleScalar(prhs[2], "Stack offset");

    plhs[0] = haCreateDoubleScalar((double) HEvalue(stack_offset));
}

/*
 * hdfHEstring
 *
 * Purpose: gateway to HEstring()
 *
 * MATLAB usage:
 * error_text = hdf('HE', 'string', error_code)
 */
static void hdfHEstring(int nlhs,
                        mxArray *plhs[],
                        int nrhs,
                        const mxArray *prhs[])
{
    hdf_err_code_t error_code;

    haNarginChk(3, 3, nrhs);
    haNargoutChk(0, 1, nlhs);

    error_code = (hdf_err_code_t) ((int16) haGetDoubleScalar(prhs[2], "Error code"));

    plhs[0] = mxCreateString(HEstring(error_code));
}

/*
 * hdfHEclear
 *
 * Purpose: gateway to HEclear()
 *
 * MATLAB usage:
 * hdf('HE', 'clear')
 */
static void hdfHEclear(int nlhs,
                       mxArray *plhs[],
                       int nrhs,
                       const mxArray *prhs[])
{
    haNarginChk(2, 2, nrhs);
    haNargoutChk(0, 0, nlhs);

    HEclear();
}

/*
 * hdfHEprint
 *
 * Purpose: gateway to HEprint()
 *
 * MATLAB usage:
 * hdf('HE', 'print', level)
 *     If level is 0, the entire error stack is printed.
 */
static void hdfHEprint(int nlhs,
                mxArray *plhs[],
                int nrhs,
                const mxArray *prhs[])
{
    int32 level;
    int32 i;
    hdf_err_code_t e;

    haNarginChk(3, 3, nrhs);
    haNargoutChk(0, 0, nlhs);

    level = (int32) haGetDoubleScalar(prhs[2], "Error stack level");

    if (level == 0)
    {
        /* print all error information */
        i = 1;
        while ((e = (hdf_err_code_t) HEvalue(i)) != DFE_NONE)
        {
            mexPrintf("%s\n", HEstring(e));
            i++;
        }
    }
    else
    {
        mexPrintf("%s\n", HEstring((hdf_err_code_t)HEvalue(level)));
    }
}

/*
 * hdfHE
 *
 * Purpose: Function switchyard for the HE part of the HDF gateway.
 *
 * Inputs:  nlhs --- number of left-side arguments
 *          plhs --- left-side arguments
 *          nrhs --- number of right-side arguments
 *          prhs --- right-side arguments
 *          functionStr --- string specifying which HE function to call
 * Outputs: none
 * Return:  none
 */
void hdfHE(int nlhs,
          mxArray *plhs[],
          int nrhs,
          const mxArray *prhs[],
          char *functionStr
          )
{
    void (*func)(int nlhs, mxArray *plhs[], 
                 int nrhs, const mxArray *prhs[]);

    if (strcmp(functionStr, "value") == 0)
    {
        func = hdfHEvalue;
    }
    else if (strcmp(functionStr, "string") == 0)
    {
        func = hdfHEstring;
    }
    else if (strcmp(functionStr, "clear") == 0)
    {
        func = hdfHEclear;
    }
    else if (strcmp(functionStr, "print") == 0)
    {
        func = hdfHEprint;
    }
    else
    {
        mexErrMsgTxt("Unknown or unsupported HE interface function.");
    }

    (*func)(nlhs, plhs, nrhs, prhs);
}

