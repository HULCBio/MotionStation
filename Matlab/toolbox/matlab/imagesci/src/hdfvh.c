/* Copyright 1984-2002 The MathWorks, Inc.  */

/*
 * hdfvfh.c --- support file for HDF.MEX
 *
 * This module supports the HDF VH interface.  The only public
 * function is hdfVH(), which is called by mexFunction().
 * hdfVH looks at the second input argument to determine which
 * private function should get control.
 *
 * Syntaxes
 * ========
 * vgroup_ref = hdf('VH', 'makegroup', file_id, tags, refs, vgroup_name, vgroup_class)
 * vdata_ref = hdf('VH', 'storedata', file_id, fieldname, data, vdata_name, vdata_class)
 * count = hdf('VH', 'storedatam', file_id, fieldname, data, vdata_name, vdata_class)
 */

/* $Revision: 1.1.6.1 $  $Date: 2003/12/13 03:02:29 $ */

static char rcsid[] = "$Id: hdfvh.c,v 1.1.6.1 2003/12/13 03:02:29 batserve Exp $";

#include <string.h>
#include <math.h>

/* Main HDF library header file */
#include "hdf.h"

/* MATLAB API header file */
#include "mex.h"

/* HDFMEX utility functions */
#include "hdfutils.h"

#include "hdfvh.h"

/*
 * hdfVHmakegroup
 *
 * Purpose: gateway to VHmakegroup()
 *
 * MATLAB usage:
 * vgroup_ref = hdf('VH', 'makegroup', file_id, tags, refs, vgroup_name, vgroup_class)
 */
static void hdfVHmakegroup(int nlhs,
                          mxArray *plhs[],
                          int nrhs,
                          const mxArray *prhs[])
{
	int32 file_id;
	int32 *tags;
	int32 *refs;
	int32 n;
	char *vgroup_name;
	char *vgroup_class;
	int i;
	double *pr;
	int32 status;
	
    haNarginChk(7, 7, nrhs);
    haNargoutChk(0, 1, nlhs);

    file_id = (int32) haGetDoubleScalar(prhs[2], "File identifier");
    n = mxGetNumberOfElements(prhs[3]);
    
    if (n != mxGetNumberOfElements(prhs[4]))
    	mexErrMsgTxt("Lengths of the TAGS and REFS vectors must match.");
    	
    tags = mxCalloc(n,sizeof(int32));
    pr = mxGetPr(prhs[3]);
    for (i=0; i<n; i++)
    	tags[i] = (int32) pr[i];
    	
    refs = mxCalloc(n,sizeof(int32));
    pr = mxGetPr(prhs[4]);
    for (i=0; i<n; i++)
    	refs[i] = (int32) pr[i];
    	
    vgroup_name = haGetString(prhs[5],"Vgroup name");
    vgroup_class = haGetString(prhs[6],"Vgroup class");

    status = VHmakegroup(file_id,tags,refs,n,vgroup_name,vgroup_class);
    
    plhs[0] = haCreateDoubleScalar((double) status);
    
    mxFree(tags);
    mxFree(refs);
    mxFree(vgroup_name);
    mxFree(vgroup_class);
}
    

/*
 * hdfVHstoredata
 *
 * Purpose: gateway to VHstoredata()
 *
 * MATLAB usage:
 * count = hdf('VH', 'storedata', file_id, fieldname, data, vdata_name, vdata_class)
 */
static void hdfVHstoredata(int nlhs,
                          mxArray *plhs[],
                          int nrhs,
                          const mxArray *prhs[])
{
	int32 file_id;
	char *fieldname;
	char *vdata_name;
	char *vdata_class;
	int32 data_type;
	int32 n;
	int32 status;
	char *buffer = NULL;
	VOIDP data;
	
    haNarginChk(7, 7, nrhs);
    haNargoutChk(0, 1, nlhs);

    file_id = (int32) haGetDoubleScalar(prhs[2], "File identifier");
    fieldname = haGetString(prhs[3],"Field name");
    vdata_name = haGetString(prhs[5],"Vdata name");
    vdata_class = haGetString(prhs[6],"Vdata class");
    
    n = mxGetNumberOfElements(prhs[4]);
    data_type = haGetDataTypeFromClassID(mxGetClassID(prhs[4]));
    
    if (data_type == DFNT_CHAR8)
    {
        buffer = mxCalloc(sizeof(mxChar)*n+1,sizeof(char));
        mxGetString(prhs[4],buffer,sizeof(mxChar)*n+1);
        data = (VOIDP) buffer;
        status = VHstoredata(file_id,fieldname,data,strlen(buffer),
                             data_type,vdata_name,vdata_class);
    }
    else
    {
        data = mxGetData(prhs[4]);
        status = VHstoredata(file_id,fieldname,data,n,data_type,vdata_name,
                             vdata_class);
    }
    
    plhs[0] = haCreateDoubleScalar((double) status);
    
    mxFree(vdata_name);
    mxFree(vdata_class);
    mxFree(fieldname);
    if (buffer != NULL)
    	mxFree(buffer);
}
   
    
/*
 * hdfVHstoredatam
 *
 * Purpose: gateway to VHstoredatam()
 *
 * MATLAB usage:
 * count = hdf('VH', 'storedatam', file_id, fieldname, data, vdata_name, vdata_class)
 */
static void hdfVHstoredatam(int nlhs,
                          mxArray *plhs[],
                          int nrhs,
                          const mxArray *prhs[])
{
	int32 file_id;
	char *fieldname;
	char *vdata_name;
	char *vdata_class;
	int32 data_type;
	int32 n;
	int32 order;
	int32 status;
	char *buffer = NULL;
	VOIDP data;
	
    haNarginChk(7, 7, nrhs);
    haNargoutChk(0, 1, nlhs);

    file_id = (int32) haGetDoubleScalar(prhs[2], "File identifier");
    fieldname = haGetString(prhs[3],"Field name");
    vdata_name = haGetString(prhs[5],"Vdata name");
    vdata_class = haGetString(prhs[6],"Vdata class");
    
    order = mxGetM(prhs[4]);
    n = mxGetN(prhs[4]);
    data_type = haGetDataTypeFromClassID(mxGetClassID(prhs[4]));
    
    if (data_type == DFNT_CHAR8)
	{
		buffer = mxCalloc(n*order+1,sizeof(char));
		mxGetString(prhs[4],buffer,n*order+1);
		data = (VOIDP) buffer;
	}
	else
		data = mxGetData(prhs[4]);

    status = VHstoredatam(file_id,fieldname,data,n,data_type,vdata_name,vdata_class,order);
    
    plhs[0] = haCreateDoubleScalar((double) status);
    
    mxFree(vdata_name);
    mxFree(vdata_class);
    mxFree(fieldname);
    if (buffer != NULL)
    	mxFree(buffer);
}
    

/*
 * hdfVH
 *
 * Purpose: Function switchyard for the VH part of the HDF gateway.
 *
 * Inputs:  nlhs --- number of left-side arguments
 *          plhs --- left-side arguments
 *          nrhs --- number of right-side arguments
 *          prhs --- right-side arguments
 *          functionStr --- string specifying which function to call
 * Outputs: none
 * Return:  none
 */
void hdfVH(int nlhs,
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
    	{"makegroup",hdfVHmakegroup},
    	{"storedata",hdfVHstoredata},
    	{"storedatam",hdfVHstoredatam},
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
    mexErrMsgTxt("Unknown HDF VH interface function.");
}
