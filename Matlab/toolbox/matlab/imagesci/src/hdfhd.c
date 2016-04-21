/* Copyright 1984-2002 The MathWorks, Inc.  */

/*
 * hdfhd.c --- support file for HDF.MEX
 *
 * This module supports a *portion* of the HDF HD interface.  The only public
 * function is hdfHD(), which is called by mexFunction().
 * hdfHD looks at the second input argument to determine which
 * private function should get control.
 *
 * Syntaxes
 * ========
 * tag_name = hdf('HD', 'gettagsname', tag)
 */

/* $Revision: 1.1.6.1 $  $Date: 2003/12/13 03:02:06 $ */

static char rcsid[] = "$Id: hdfhd.c,v 1.1.6.1 2003/12/13 03:02:06 batserve Exp $";

#include <string.h>

#include "hdf.h"

#include "hdfmex.h"
#include "mex.h"

/*
 * hdfHDgettagsname
 * 
 * Purpose: gateway to HDgettagsname()
 *
 * MATLAB usage:
 * tag_name = hdf('HD', 'gettagsname', tag)
 */
static void hdfHDgettagsname(int nlhs,
                             mxArray *plhs[],
                             int nrhs,
                             const mxArray *prhs[])
{
    uint16 tag;
    char *name;

    haNarginChk(3, 3, nrhs);
    haNargoutChk(0, 1, nlhs);

    tag = (uint16) haGetDoubleScalar(prhs[2], "Tag");
    name = HDgettagsname(tag);
    if (name == NULL)
    {
        plhs[0] = mxCreateString("");
    }
    else
    {
        plhs[0] = mxCreateString(name);
	free(name);
    }
}

/*
 * hdfHD
 *
 * Purpose: Function switchyard for the HD part of the HDF gateway.
 *
 * Inputs:  nlhs --- number of left-side arguments
 *          plhs --- left-side arguments
 *          nrhs --- number of right-side arguments
 *          prhs --- right-side arguments
 *          functionStr --- string specifying which HD function to call
 * Outputs: none
 * Return:  none
 */
void hdfHD(int nlhs,
          mxArray *plhs[],
          int nrhs,
          const mxArray *prhs[],
          char *functionStr
          )
{
    void (*func)(int nlhs, mxArray *plhs[], 
                 int nrhs, const mxArray *prhs[]);

    if (strcmp(functionStr, "gettagsname") == 0)
    {
        func = hdfHDgettagsname;
    }
    else
    {
        mexErrMsgTxt("Unknown or unsupported HD interface function");
    }

    (*func)(nlhs, plhs, nrhs, prhs);
}

