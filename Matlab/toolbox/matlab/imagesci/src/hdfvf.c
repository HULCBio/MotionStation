/* Copyright 1984-2002 The MathWorks, Inc.  */

/*
 * hdfvf.c --- support file for HDF.MEX
 *
 * This module supports the HDF VF interface.  The only public
 * function is hdfVF(), which is called by mexFunction().
 * hdfVF looks at the second input argument to determine which
 * private function should get control.
 *
 * Syntaxes
 * ========
 * fsize = hdf('VF', 'fieldesize', vdata_id, field_index)
 * fsize = hdf('VF', 'fieldisize', vdata_id, field_index)
 * name = hdf('VF', 'fieldname', vdata_id, field_index)
 * order = hdf('VF', 'fieldorder', vdata_id, field_index)
 * data_type = hdf('VF', 'fieldtype', vdata_id, field_index)
 * count = hdf('VF', 'nfields', vdata_id)
 */

/* $Revision: 1.1.6.1 $  $Date: 2003/12/13 03:02:27 $ */

static char rcsid[] = "$Id: hdfvf.c,v 1.1.6.1 2003/12/13 03:02:27 batserve Exp $";

#include <string.h>
#include <math.h>

/* Main HDF library header file */
#include "hdf.h"

/* MATLAB API header file */
#include "mex.h"

/* HDFMEX utility functions */
#include "hdfutils.h"

#include "hdfvf.h"

/*
 * hdfVFfieldesize
 *
 * Purpose: gateway to VFfieldesize()
 *
 * MATLAB usage:
 * fsize = hdf('VF', 'fieldesize', vdata_id, field_index)
 */
static void hdfVFfieldesize(int nlhs,
                          mxArray *plhs[],
                          int nrhs,
                          const mxArray *prhs[])
{
    int32 vdata_id;
    int32 field_index;
    int32 status;

    haNarginChk(4, 4, nrhs);
    haNargoutChk(0, 1, nlhs);

    vdata_id = (int32) haGetDoubleScalar(prhs[2], "Vdata identifier");
    field_index = (int32) haGetDoubleScalar(prhs[3],"Field index");
    
    status = VFfieldesize(vdata_id,field_index);
    
    plhs[0] = haCreateDoubleScalar((double) status);
}
    

/*
 * hdfVFfieldisize
 *
 * Purpose: gateway to VFfieldisize()
 *
 * MATLAB usage:
 * fsize = hdf('VF', 'fieldisize', vdata_id, field_index)
 */
static void hdfVFfieldisize(int nlhs,
                          mxArray *plhs[],
                          int nrhs,
                          const mxArray *prhs[])
{
    int32 vdata_id;
    int32 field_index;
    int32 status;

    haNarginChk(4, 4, nrhs);
    haNargoutChk(0, 1, nlhs);

    vdata_id = (int32) haGetDoubleScalar(prhs[2], "Vdata identifier");
    field_index = (int32) haGetDoubleScalar(prhs[3],"Field index");
    
    status = VFfieldisize(vdata_id,field_index);
    
    plhs[0] = haCreateDoubleScalar((double) status);
}


/*
 * hdfVFfieldname
 *
 * Purpose: gateway to VFfieldname()
 *
 * MATLAB usage:
 * name = hdf('VF', 'fieldname', vdata_id, field_index)
 */
static void hdfVFfieldname(int nlhs,
                          mxArray *plhs[],
                          int nrhs,
                          const mxArray *prhs[])
{
    int32 vdata_id;
    int32 field_index;
    char *name;

    haNarginChk(4, 4, nrhs);
    haNargoutChk(0, 1, nlhs);

    vdata_id = (int32) haGetDoubleScalar(prhs[2], "Vdata identifier");
    field_index = (int32) haGetDoubleScalar(prhs[3],"Field index");
    
    name = VFfieldname(vdata_id,field_index);
    
    plhs[0] = mxCreateString(name);
}


/*
 * hdfVFfieldorder
 *
 * Purpose: gateway to VFfieldorder()
 *
 * MATLAB usage:
 * order = hdf('VF', 'fieldorder', vdata_id, field_index)
 */
static void hdfVFfieldorder(int nlhs,
                          mxArray *plhs[],
                          int nrhs,
                          const mxArray *prhs[])
{
    int32 vdata_id;
    int32 field_index;
    int32 status;

    haNarginChk(4, 4, nrhs);
    haNargoutChk(0, 1, nlhs);

    vdata_id = (int32) haGetDoubleScalar(prhs[2], "Vdata identifier");
    field_index = (int32) haGetDoubleScalar(prhs[3],"Field index");
    
    status = VFfieldorder(vdata_id,field_index);
    
    plhs[0] = haCreateDoubleScalar((double) status);
}


/*
 * hdfVFfieldtype
 *
 * Purpose: gateway to VFfieldtype()
 *
 * MATLAB usage:
 * data_type = hdf('VF', 'fieldtype', vdata_id, field_index)
 */
static void hdfVFfieldtype(int nlhs,
                          mxArray *plhs[],
                          int nrhs,
                          const mxArray *prhs[])
{
    int32 vdata_id;
    int32 field_index;
    int32 data_type;

    haNarginChk(4, 4, nrhs);
    haNargoutChk(0, 1, nlhs);

    vdata_id = (int32) haGetDoubleScalar(prhs[2], "Vdata identifier");
    field_index = (int32) haGetDoubleScalar(prhs[3],"Field index");
    
    data_type = VFfieldtype(vdata_id,field_index);
    
    if (data_type != FAIL)
    	plhs[0] = mxCreateString(haGetDataTypeString(data_type));
    else
    	plhs[0] = EMPTY;
}


/*
 * hdfVFnfields
 *
 * Purpose: gateway to VFnfields()
 *
 * MATLAB usage:
 * count = hdf('VF', 'nfields', vdata_id)
 */
static void hdfVFnfields(int nlhs,
                          mxArray *plhs[],
                          int nrhs,
                          const mxArray *prhs[])
{
    int32 vdata_id;
    int32 status;

    haNarginChk(3, 3, nrhs);
    haNargoutChk(0, 1, nlhs);

    vdata_id = (int32) haGetDoubleScalar(prhs[2], "Vdata identifier");
    
    status = VFnfields(vdata_id);
    
    plhs[0] = haCreateDoubleScalar((double) status);
}


/*
 * hdfVF
 *
 * Purpose: Function switchyard for the VF part of the HDF gateway.
 *
 * Inputs:  nlhs --- number of left-side arguments
 *          plhs --- left-side arguments
 *          nrhs --- number of right-side arguments
 *          prhs --- right-side arguments
 *          functionStr --- string specifying which function to call
 * Outputs: none
 * Return:  none
 */
void hdfVF(int nlhs,
           mxArray *plhs[],
           int nrhs,
           const mxArray *prhs[],
           char *functionStr
           )
{
    typedef void (MATLAB_FCN)(int nlhs, mxArray *plhs[], 
                 int nrhs, const mxArray *prhs[]);
    struct {
    	char *name;
    	MATLAB_FCN *func;
    } Fcns[] = {
    	{"fieldesize",hdfVFfieldesize},
    	{"fieldisize",hdfVFfieldisize},
    	{"fieldname",hdfVFfieldname},
    	{"fieldorder",hdfVFfieldorder},
    	{"fieldtype",hdfVFfieldtype},
    	{"nfields",hdfVFnfields},
	   	{"",NULL}
    };
    	
	int i = 0;
	
	if (nrhs > 0)
		functionStr = haGetString(prhs[1],"Function name");
	else
		mexErrMsgTxt("Not enough input arguments.");
		
	while (Fcns[i].func != NULL)
	{
		if (strcmp(functionStr,Fcns[i].name)==0)
		{
			(*(Fcns[i].func))(nlhs, plhs, nrhs, prhs);
			mxFree(functionStr);
			return;
		}
		i++;
	}
    mexErrMsgTxt("Unknown HDF VF interface function.");
}
