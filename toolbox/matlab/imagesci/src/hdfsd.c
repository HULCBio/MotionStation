/* Copyright 1984-2002 The MathWorks, Inc.  */

/*
 * hdfsd.c --- support file for HDF.MEX
 *
 * This module supports the HDF SD interface.  The only public
 * function is hdfSD(), which is called by mexFunction().
 * hdfSD looks at the second input argument to determine which
 * private function should get control.
 *
 * Syntaxes
 * ========
 * [name, data_type, count, status] = hdf('SD', 'attrinfo', file_id/sds_id/dim_id, attr_idx)
 * sds_id = hdf('SD', 'create', sd_id, name, data_type, rank, dimsizes)
 * [name,count,data_type,nattrs,status] = hdf('SD', 'diminfo', dim_id)
 * status = hdf('SD', 'end', sd_id)
 * status = hdf('SD', 'endaccess', sds_id)
 * [ndatasets, nglobal_attr, status] = hdf('SD', 'fileinfo', sd_id)
 * attr_index = hdf('SD', 'findattr', file_id/sds_id/dim_id, name)
 * [cal,cal_err,offset,offset_err,data_type,status] = hdf('SD', 'getcal', sds_id)
 * [chunk_lengths,chunked,compressed,status] = hdf('SD', 'getchunkinfo', sds_id)
 *    chunked or compressed will be true (1) if the SDS if chunked or compressed.
 *    compressed will only be true if chunked is also true.
 * [label,unit,format,coordsys,status] = hdf('SD', 'getdatastrs', sds_id, maxlen)
 * dim_id = hdf('SD', 'getdimid', sds_id, dim_number)
 * [scale,status] = hdf('SD', 'getdimscale', dim_id)
 * [label,unit,format,status] = hdf('SD', 'getdimstrs', dim_id)
 * [fill,status] = hdf('SD', 'getfillvalue', sds_id)
 * [name,rank,dimsizes,data_type,nattrs,status] = hdf('SD', 'getinfo', sds_id)
 * [rmax,rmin,status] = hdf('SD', 'getrange', sds_id)
 * ref = hdf('SD', 'idtoref', sds_id)
 * tf = hdf('SD', 'iscoordvar', sds_id)
 * tf = hdf('SD', 'isdimval_bwcomp', sds_id)
 * tf = hdf('SD', 'isrecord', sds_id)
 * idx = hdf('SD', 'nametoindex', sd_id, name)
 * [data, status] = hdf('SD','readattr',file_id/sds_id/dim_id,attr_index)
 * [data, status] = hdf('SD','readchunk',sds_id,origin)
 * [data, status] = hdf('SD','readdata',sds_id,start,stride,edge)
 * sds_index = hdf('SD', 'reftoindex', sd_id, ref)
 * sds_id = hdf('SD', 'select', sd_id, sds_index)
 * status = hdf('SD', 'setaccesstype', sd_id, access_mode)
 *          access_mode can be 'serial' or 'parallel'
 * status = hdf('SD', 'setattr',file_id/sds_id/dim_id, name, A)
 * status = hdf('SD', 'setblocksize',sd_id, blocksize)
 * status = hdf('SD', 'setcal', sds_id, cal, cal_err, offset, offset_err, data_type)
 * status = hdf('SD', 'setchunk', sds_id, chunk_lengths, comp_type, ...)
 *      comp_type can be 'none','jpeg','rle','deflate',or 'skphuff'.
 *      'none' implies HDF_CHUNK, the others imply HDF_CHUNK | HDF_COMP.
 *      Additional param/value pairs must be passed for some methods.  This routine
 *      understands the following param/value pairs:
 *         'jpeg_quality'        , integer
 *         'jpeg_force_baseline' , integer
 *         'skphuff_skp_size'    , integer
 *         'deflate_level'       , integer
 * status = hdf('SD', 'setchunkcache', sds_id, maxcache, flags)
 * status = hdf('SD', 'setcompress', sd_id, comp_type, ...)
 *      comp_type can be 'none','jpeg','rle','deflate',or 'skphuff'.
 *      Additional param/value pairs must be passed for some methods.  This routine
 *      understands the following param/value pairs:
 *         'jpeg_quality'        , integer
 *         'jpeg_force_baseline' , integer
 *         'skphuff_skp_size'    , integer
 *         'deflate_level'       , integer
 * status = hdf('SD', 'setdatastrs', sds_id, label, unit, format, coordsys)
 * status = hdf('SD', 'setdimname', dim_id, name)
 * status = hdf('SD', 'setdimscale', dim_id, scale)
 * status = hdf('SD', 'setdimstrs', dim_id, label, unit, format)
 * status = hdf('SD', 'setdimval_comp', dim_id, mode)
 *      mode can be 'comp' or 'incomp'.
 * status = hdf('SD', 'setexternalfile', sds_id, filename, offset)
 * status = hdf('SD', 'setfillmode', dim_id, mode)
 *      mode can be 'fill' or 'nofill'.
 * status = hdf('SD', 'setfillvalue', sds_id, value)
 * status = hdf('SD', 'setnbitdataset', sds_id, start_bit, bit_len, sign_ext, fill_one)
 * status = hdf('SD', 'setrange', sds_id, max, min)
 * sd_id = hdf('SD', 'start', filename, access_mode)
 *     access_mode can be 'read','write','create', 'rdwr', or 'rdonly'
 * status = hdf('SD','writechunk',sds_id,origin,data)
 * status = hdf('SD','writedata',sds_id, start, stride, edge, data)
 */

/* $Revision: 1.1.6.1 $  $Date: 2003/12/13 03:02:19 $ */

static char rcsid[] = "$Id: hdfsd.c,v 1.1.6.1 2003/12/13 03:02:19 batserve Exp $";

#include <string.h>
#include <math.h>

/* Main HDF library header file */
#include "hdf.h"

/* Multifile scientific dataset interface header file */
#include "mfhdf.h"

/* MATLAB API header file */
#include "mex.h"

/* HDFMEX utility functions */
#include "hdfutils.h"

#include "hdfsd.h"

/*
 * hdfSDattrinfo
 *
 * Purpose: gateway to SDattrinfo()
 *
 * MATLAB usage:
 * [name, data_type, count, status] = hdf('SD', 'attrinfo', file_id/sds_id/dim_id, attr_idx)
 */
static void hdfSDattrinfo(int nlhs,
                          mxArray *plhs[],
                          int nrhs,
                          const mxArray *prhs[])
{
    int32 id;
    int32 attr_index;
    char name[MAX_NC_NAME];
    int32 data_type;
    const char *data_type_str;
    int32 count;
    intn status;

    haNarginChk(4, 4, nrhs);
    haNargoutChk(0, 4, nlhs);

    id = (int32) haGetDoubleScalar(prhs[2], "Identifier");
    attr_index = (int32) haGetDoubleScalar(prhs[3], "Attribute index");

    status = SDattrinfo(id, attr_index, name, &data_type, &count);
	if (status == SUCCEED)
	{
		plhs[0] = mxCreateString(name);
		data_type_str = haGetDataTypeString(data_type);
		plhs[1] = mxCreateString(data_type_str);

	    if (nlhs > 2)
	        plhs[2] = haCreateDoubleScalar((double) count);
	}
	else
	{
		plhs[0] = EMPTYSTR;
	    plhs[1] = EMPTYSTR;

	    if (nlhs > 2)
	        plhs[2] = ZERO;
	}
	
    if (nlhs > 3)
        plhs[3] = haCreateDoubleScalar((double) status);
}
    

/*
 * hdfSDcreate
 *
 * Purpose: gateway to SDcreate()
 *
 * MATLAB usage:
 * sds_id = hdf('SD', 'create', sd_id, name, data_type, rank, dimsizes)
 */
static void hdfSDcreate(int nlhs,
                        mxArray *plhs[],
                        int nrhs,
                        const mxArray *prhs[])
{
    int32 sd_id;
    char *name;
    int32 data_type;
    int32 rank;
    int32 dim_sizes[MAX_VAR_DIMS];
    int32 sds_id;
    intn status;
    mxClassID class_id;

    haNarginChk(7, 7, nrhs);
    haNargoutChk(0, 1, nlhs);

    sd_id = (int32) haGetDoubleScalar(prhs[2], "SD identifier");
    name = haGetString(prhs[3], "Variable name");
    data_type = haGetDataType(prhs[4]);
    
    /* Make sure we can support this data_type */
    class_id = haGetClassIDFromDataType(data_type);
    if (class_id == mxUNKNOWN_CLASS)
    {
        mexErrMsgTxt("Unsupported HDF data type.");
    }
    
    rank = haGetDimensions(prhs[5],prhs[6],dim_sizes);

    sds_id = SDcreate(sd_id, name, data_type, rank, dim_sizes);
    if (sds_id != FAIL)
    {
        status = haAddIDToList(sds_id, SDS_ID_List);
        if (status == FAIL)
        {
            /* Failed to add sd_id to the list. */
            /* This could cause data loss later, so don't allow it. */
            SDendaccess(sds_id);
            sds_id = FAIL;
        }
    }

    plhs[0] = haCreateDoubleScalar((double) sds_id);

    mxFree(name);
}


/*
 * hdfSDdiminfo
 *
 * Purpose: gateway to SDdiminfo()
 *
 * MATLAB usage:
 * [name,count,data_type,nattrs,status] = hdf('SD', 'diminfo', dim_id)
 */
static void hdfSDdiminfo(int nlhs,
                     mxArray *plhs[],
                     int nrhs,
                     const mxArray *prhs[])
{
	intn status;
	int32 dim_id;
	char name[MAX_NC_NAME];
	int32 count;
	int32 data_type;
    const char *data_type_str;
	int32 nattrs;
	
    haNarginChk(3, 3, nrhs);
    haNargoutChk(0, 5, nlhs);

	dim_id = (int32) haGetDoubleScalar(prhs[2],"Dimension identifier");
	
	status = SDdiminfo(dim_id,name,&count,&data_type,&nattrs);
	
	if (status == SUCCEED)
	{
		plhs[0] = mxCreateString(name);
		if (nlhs > 1)
		{
			if (count == SD_UNLIMITED)
				plhs[1] = haCreateDoubleScalar(mxGetInf());
			else
				plhs[1] = haCreateDoubleScalar((double) count);
		}	
		if (nlhs > 2)
		{
			data_type_str = haGetDataTypeString(data_type);
			plhs[2] = mxCreateString(data_type_str);
		}
		if (nlhs > 3)
			plhs[3] = haCreateDoubleScalar((double) nattrs);
	}
	else
	{
		plhs[0] = EMPTYSTR;
		if (nlhs > 1)
			plhs[1] = ZERO;
			
		if (nlhs > 2)
		{
			plhs[2] = EMPTYSTR;
		}
		if (nlhs > 3)
			plhs[3] = ZERO;
	}
	if (nlhs > 4)
		plhs[4] = haCreateDoubleScalar((double) status);
}

/*
 * hdfSDend
 *
 * Purpose: gateway to SDend()
 *
 * MATLAB usage:
 * status = hdf('SD', 'end', sd_id)
 */
static void hdfSDend(int nlhs,
                     mxArray *plhs[],
                     int nrhs,
                     const mxArray *prhs[])
{
    int32 sd_id;
    intn status;

    haNarginChk(3, 3, nrhs);
    haNargoutChk(0, 1, nlhs);

    sd_id = (int32) haGetDoubleScalar(prhs[2], "SD identifier");
    status = SDend(sd_id);
    if (status == SUCCEED)
    {
        haDeleteIDFromList(sd_id, SD_ID_List);
    }
    plhs[0] = haCreateDoubleScalar((double) status);
}

/*
 * hdfSDendaccess
 *
 * Purpose: gateway to SDendaccess()
 *
 * MATLAB usage:
 * status = hdf('SD', 'endaccess', sds_id)
 */
static void hdfSDendaccess(int nlhs,
                           mxArray *plhs[],
                           int nrhs,
                           const mxArray *prhs[])
{
    int32 sds_id;
    intn status;

    haNarginChk(3, 3, nrhs);
    haNargoutChk(0, 1, nlhs);

    sds_id = (int32) haGetDoubleScalar(prhs[2], "Scientific dataset identifier");
    status = SDendaccess(sds_id);
    if (status == SUCCEED)
    {
        haDeleteIDFromList(sds_id, SDS_ID_List);
    }

    plhs[0] = haCreateDoubleScalar((double) status);
}

/*
 * hdfSDfileinfo
 *
 * Purpose: gateway to SDfileinfo()
 *
 * MATLAB usage:
 * [ndatasets, nglobal_attr, status] = hdf('SD', 'fileinfo', sd_id)
 */
static void hdfSDfileinfo(int nlhs,
                          mxArray *plhs[],
                          int nrhs,
                          const mxArray *prhs[])
{
    int32 sd_id;
    int32 ndatasets;
    int32 nglobal_attr;
    intn status;

    haNarginChk(3, 3, nrhs);
    haNargoutChk(0, 3, nlhs);

    sd_id = (int32) haGetDoubleScalar(prhs[2], "SD identifier");
    status = SDfileinfo(sd_id, &ndatasets, &nglobal_attr);

    if (status == SUCCEED)
    {
        plhs[0] = haCreateDoubleScalar((double) ndatasets);
        if (nlhs > 1)
            plhs[1] = haCreateDoubleScalar((double) nglobal_attr);
    }
    else
    {
        plhs[0] = ZERO;
        if (nlhs > 1)
            plhs[1] = ZERO;
    }
    if (nlhs > 2)
        plhs[2] = haCreateDoubleScalar((double) status);
}

/*
 * hdfSDfindattr
 *
 * Purpose: gateway to SDfindattr()
 *
 * MATLAB usage:
 * attr_index = hdf('SD', 'findattr', file_id/sds_id/dim_id, name)
 */
static void hdfSDfindattr(int nlhs,
                          mxArray *plhs[],
                          int nrhs,
                          const mxArray *prhs[])
{
    int32 id;
    char *name;
    int32 attr_index;

    haNarginChk(4, 4, nrhs);
    haNargoutChk(0, 1, nlhs);

    id = (int32) haGetDoubleScalar(prhs[2], "Identifier");
    name = haGetString(prhs[3], "Attribute name");

    attr_index = SDfindattr(id, name);

    plhs[0] = haCreateDoubleScalar((double) attr_index);

    mxFree(name);
}

/*
 * hdfSDgetcal
 *
 * Purpose: gateway to SDgetcal()
 *
 * MATLAB usage:
 * [cal,cal_err,offset,offset_err,data_type,status] = hdf('SD', 'getcal', sds_id)
 */
static void hdfSDgetcal(int nlhs,
                         mxArray *plhs[],
                         int nrhs,
                         const mxArray *prhs[])
{
	intn status;
	int32 sds_id;
	float64 cal;
	float64 cal_err;
	float64 offset;
	float64 offset_err;
	int32 data_type;
    const char *data_type_str;
	
    haNarginChk(3, 3, nrhs);
    haNargoutChk(0, 6, nlhs);

    sds_id = (int32) haGetDoubleScalar(prhs[2], "Scientific dataset identifier");
    
    status = SDgetcal(sds_id,&cal,&cal_err,&offset,&offset_err,&data_type);
    
    if (status == SUCCEED)
    {
    	plhs[0] = haCreateDoubleScalar(cal);
    	if (nlhs > 1)
    		plhs[1] = haCreateDoubleScalar(cal_err);
    	if (nlhs > 2)
    		plhs[2] = haCreateDoubleScalar(offset);
    	if (nlhs > 3)
    		plhs[3] = haCreateDoubleScalar(offset_err);
    	if (nlhs > 4)
    	{
			data_type_str = haGetDataTypeString(data_type);
			plhs[4] = mxCreateString(data_type_str);
    	}
    }
    else
    {
    	plhs[0] = ZERO;
    	if (nlhs > 1)
    		plhs[1] = ZERO;
    	if (nlhs > 2)
    		plhs[2] = ZERO;
    	if (nlhs > 3)
    		plhs[3] = ZERO;
    	if (nlhs > 4)
    		plhs[4] = EMPTYSTR;
    }
    if (nlhs > 5)
    	plhs[5] = haCreateDoubleScalar((double) status);
}

/*
 * hdfSDgetchunkinfo
 *
 * Purpose: gateway to SDgetchunkinfo()
 *
 * MATLAB usage:
 * [chunk_lengths,chunked,compressed,status] = hdf('SD', 'getchunkinfo', sds_id)
 *    chunked or compressed will be true (1) if the SDS if chunked or compressed.
 *    compressed will only be true if chunked is also true.
 */
static void hdfSDgetchunkinfo(int nlhs,
                         mxArray *plhs[],
                         int nrhs,
                         const mxArray *prhs[])
{
	intn status;
	int32 sds_id;
    char name[MAX_NC_NAME];
    int32 rank;
    int32 dimsizes[MAX_VAR_DIMS];
    int32 data_type;
    int32 nattrs;
	HDF_CHUNK_DEF cdef;
	int32 flags;
	int siz[2];
	int i;
	double *pr;
	
    haNarginChk(3, 3, nrhs);
    haNargoutChk(0, 4, nlhs);

    sds_id = (int32) haGetDoubleScalar(prhs[2], "Scientific dataset identifier");
    
    /* Get rank of dataset */
	status = SDgetinfo(sds_id,name,&rank,dimsizes,&data_type,&nattrs);
	if (status != SUCCEED)
	{
		plhs[0] = EMPTY;
		if (nlhs > 1)
			plhs[1] = EMPTYSTR;
		if (nlhs > 2)
			plhs[2] = mxCreateCellMatrix(2,0);
		if (nlhs > 3)
	    	plhs[3] = haCreateDoubleScalar((double) status);
	    return;
	}
		
	status = SDgetchunkinfo(sds_id,&cdef,&flags);
	if (status != SUCCEED)
	{
		plhs[0] = EMPTY;
		if (nlhs > 1)
			plhs[1] = EMPTYSTR;
		if (nlhs > 2)
			plhs[2] = mxCreateCellMatrix(2,0);
		if (nlhs > 3)
	    	plhs[3] = haCreateDoubleScalar((double) status);
	    return;
	}
			
	siz[0] = 1;
	siz[1] = rank;
	plhs[0] = mxCreateNumericArray(2,siz,mxDOUBLE_CLASS,mxREAL);
	pr = mxGetPr(plhs[0]);
	for (i=0; i<rank; i++)
	{
	    if (cdef.chunk_lengths[i] == SD_UNLIMITED)
		pr[i] = mxGetInf();
	    else
		pr[i] = (double)cdef.chunk_lengths[i];
	}
	
	if (nlhs > 1)
	{
	    plhs[1] = mxCreateLogicalScalar(flags == HDF_CHUNK);
	}
	
	if (nlhs > 2)
	{
	    plhs[2] = mxCreateLogicalScalar(flags == (HDF_CHUNK | HDF_COMP));
	}
	
	if (nlhs > 3)
	{
	    plhs[3] = haCreateDoubleScalar((double) status);
	}
}

/*
 * hdfSDgetdatastrs
 *
 * Purpose: gateway to SDgetdatastrs()
 *
 * MATLAB usage:
 * [label,unit,format,coordsys,status] = hdf('SD', 'getdatastrs', sds_id, maxlen)
 */
static void hdfSDgetdatastrs(int nlhs,
                         mxArray *plhs[],
                         int nrhs,
                         const mxArray *prhs[])
{
	intn status;
	int32 sds_id;
	int32 maxlen;
	char *label;
	char *unit;
	char *format;
	char *coordsys;
	
    haNarginChk(4, 4, nrhs);
    haNargoutChk(0, 5, nlhs);

    sds_id = (int32) haGetDoubleScalar(prhs[2], "Scientific dataset identifier");
    maxlen = (int32) haGetDoubleScalar(prhs[3],"Maximum string length");

	label = mxCalloc(maxlen+1,sizeof(char));
	unit = mxCalloc(maxlen+1,sizeof(char));
	format = mxCalloc(maxlen+1,sizeof(char));
	coordsys = mxCalloc(maxlen+1,sizeof(char));
	
	status = SDgetdatastrs(sds_id,label,unit,format,coordsys,maxlen);
	
	if (status == SUCCEED)
	{
		plhs[0] = strlen(label)>0 ? mxCreateString(label) : EMPTYSTR;
		if (nlhs > 1)
			plhs[1] = strlen(unit)>0 ? mxCreateString(unit) : EMPTYSTR;
		if (nlhs > 2)
			plhs[2] = strlen(format)>0 ? mxCreateString(format) : EMPTYSTR;
		if (nlhs > 3)
			plhs[3] = strlen(coordsys)>0 ? mxCreateString(coordsys) : EMPTYSTR;
	}
	else
	{
		plhs[0] = EMPTYSTR;
		if (nlhs > 1)
			plhs[1] = EMPTYSTR;
		if (nlhs > 2)
			plhs[2] = EMPTYSTR;
		if (nlhs > 3)
			plhs[3] = EMPTYSTR;
	}
	if (nlhs > 4)
		plhs[4] = haCreateDoubleScalar((double) status);
		
	mxFree(label);
	mxFree(unit);
	mxFree(format);
	mxFree(coordsys);
}

/* 
 * hdfSDgetdimid
 *
 * Purpose: gateway to SDgetdimid()
 *
 * MATLAB usage:
 * dim_id = hdf('SD', 'getdimid', sds_id, dim_number)
 */
static void hdfSDgetdimid(int nlhs,
                          mxArray *plhs[],
                          int nrhs,
                          const mxArray *prhs[])
{
    int32 sds_id;
    intn dim_number;
    int32 dim_id;

    haNarginChk(4, 4, nrhs);
    haNargoutChk(0, 1, nlhs);

    sds_id = (int32) haGetDoubleScalar(prhs[2], "Scientific dataset identifier");
    dim_number = (int32) haGetDoubleScalar(prhs[3], "dimension number");

    dim_id = SDgetdimid(sds_id,dim_number);

    plhs[0] = haCreateDoubleScalar((double) dim_id);
}


/* 
 * hdfSDgetdimscale
 *
 * Purpose: gateway to SDgetdimscale()
 *
 * MATLAB usage:
 * [scale,status] = hdf('SD', 'getdimscale', dim_id)
 */
static void hdfSDgetdimscale(int nlhs,
                             mxArray *plhs[],
                             int nrhs,
                             const mxArray *prhs[])
{
    intn status;
    int32 dim_id;
    int32 count;
    int32 data_type;
    int32 nattrs;
    VOIDP scale = NULL;
    bool ok_to_free_scale;
    int siz[2];

    haNarginChk(3, 3, nrhs);
    haNargoutChk(0, 2, nlhs);

    dim_id = (int32) haGetDoubleScalar(prhs[2], "Dimension identifier");

    /* Call SDdiminfo here to make sure a scale exists */
    status = SDdiminfo(dim_id,NULL,&count,&data_type,&nattrs);
    if (status == FAIL)
    {
        plhs[0] = EMPTY;
        if (nlhs > 1)
            plhs[1] = haCreateDoubleScalar((double) status);
        return;
    }
	
    if (data_type == 0)
        mexErrMsgTxt("Attempt to call SDgetdimscale on dimension that doesn't have a scale.");
    if (count == SD_UNLIMITED)
        mexErrMsgTxt("This gateway can't read UNLIMITED datasets yet.");
	
    siz[0] = 1;
    siz[1] = count;

    scale = haMakeHDFDataBuffer(count, data_type);
    if (scale != NULL)
    {
        status = SDgetdimscale(dim_id, scale);
        if (status == SUCCEED)
        {
            plhs[0] = haMakeArrayFromHDFDataBuffer(2, siz, data_type, scale,
                                                   &ok_to_free_scale);
            if (ok_to_free_scale)
            {
                mxFree(scale);
            }
            if (plhs[0] == NULL)
            {
                status = FAIL;
            }
        }
    }

    if (status == FAIL)
    {
        plhs[0] = EMPTY;
    }
	
    if (nlhs > 1)
    {
    	plhs[1] = haCreateDoubleScalar((double) status);
    }

}

/*
 * hdfSDgetdimstrs
 *
 * Purpose: gateway to SDgetdimstrs()
 *
 * MATLAB usage:
 * [label,unit,format,status] = hdf('SD', 'getdimstrs', dim_id)
 */
static void hdfSDgetdimstrs(int nlhs,
                         mxArray *plhs[],
                         int nrhs,
                         const mxArray *prhs[])
{

#define MAX_STR_LEN 1024

	intn status;
	int32 sds_id;
	char label[MAX_STR_LEN];
	char unit[MAX_STR_LEN];
	char format[MAX_STR_LEN];
	
    haNarginChk(3, 3, nrhs);
    haNargoutChk(0, 4, nlhs);

    sds_id = (int32) haGetDoubleScalar(prhs[2], "Dimension identifier");

	status = SDgetdimstrs(sds_id,label,unit,format,MAX_STR_LEN);
	
	if (status == SUCCEED)
	{
		plhs[0] = strlen(label)>0 ? mxCreateString(label) : EMPTYSTR;
		if (nlhs > 1)
			plhs[1] = strlen(unit)>0 ? mxCreateString(unit) : EMPTYSTR;
		if (nlhs > 2)
			plhs[2] = strlen(format)>0 ? mxCreateString(format) : EMPTYSTR;
	}
	else
	{
		plhs[0] = EMPTYSTR;
		if (nlhs > 1)
			plhs[1] = EMPTYSTR;
		if (nlhs > 2)
			plhs[2] = EMPTYSTR;
	}
	if (nlhs > 3)
		plhs[3] = haCreateDoubleScalar((double) status);
}


/* 
 * hdfSDgetfillvalue
 *
 * Purpose: gateway to SDgetfillvalue()
 *
 * MATLAB usage:
 * [fill,status] = hdf('SD', 'getfillvalue', sds_id)
 */
static void hdfSDgetfillvalue(int nlhs,
                              mxArray *plhs[],
                              int nrhs,
                              const mxArray *prhs[])
{
    intn status;
    int32 sds_id;
    char name[MAX_NC_NAME];
    int32 rank;
    int32 dimsizes[MAX_VAR_DIMS];
    int32 data_type;
    int32 nattrs;
    int siz[2];
    VOIDP fill_val;
    bool ok_to_free_fill_val;

    haNarginChk(3, 3, nrhs);
    haNargoutChk(0, 2, nlhs);

    sds_id = (int32) haGetDoubleScalar(prhs[2], "Scientific dataset identifier");

    /* Determine datatype of dataset */
    status = SDgetinfo(sds_id,name,&rank,dimsizes,&data_type,&nattrs);
    if (status == SUCCEED)
    {
        siz[0] = 1;
        siz[1] = 1;

        fill_val = haMakeHDFDataBuffer(1, data_type);
        if (fill_val != NULL)
        {
            status = SDgetfillvalue(sds_id, fill_val);
            if (status == SUCCEED)
            {
                plhs[0] = haMakeArrayFromHDFDataBuffer(2, siz, data_type, 
                                                       fill_val, &ok_to_free_fill_val);
                if (ok_to_free_fill_val)
                {
                    mxFree(fill_val);
                }
                if (plhs[0] == NULL)
                {
                    status = FAIL;
                }
            }
        }
    }

    if (status == FAIL)
    {
        plhs[0] = EMPTY;
    }
    
    if (nlhs > 1)
    {
        plhs[1] = haCreateDoubleScalar((double) status);
    }

}

/* 
 * hdfSDgetinfo
 *
 * Purpose: gateway to SDgetinfo()
 *
 * MATLAB usage:
 * [name,rank,dimsizes,data_type,nattrs,status] = hdf('SD', 'getinfo', sds_id)
 */
static void hdfSDgetinfo(int nlhs,
                          mxArray *plhs[],
                          int nrhs,
                          const mxArray *prhs[])
{
	intn status;
    int32 sds_id;
    char name[MAX_NC_NAME];
    int32 rank;
    int32 dimsizes[MAX_VAR_DIMS];
    int32 data_type;
    const char *data_type_str;
    int32 nattrs;
    int i;
    double *pr;

    haNarginChk(3, 3, nrhs);
    haNargoutChk(0, 6, nlhs);

    sds_id = (int32) haGetDoubleScalar(prhs[2], "Scientific dataset identifier");

	status = SDgetinfo(sds_id,name,&rank,dimsizes,&data_type,&nattrs);
	
	if (status == SUCCEED)
	{
		plhs[0] = mxCreateString(name);
		if (nlhs > 1)
			plhs[1] = haCreateDoubleScalar((double) rank);
		if (nlhs > 2)
		{
			plhs[2] = mxCreateDoubleMatrix(1,rank,mxREAL);
			pr = mxGetPr(plhs[2]);
			
			for (i=0; i<rank; i++) 
			{
				if (dimsizes[i] == SD_UNLIMITED)
					pr[i] = mxGetInf();
				else
					pr[i] = dimsizes[i];
			}
		}
		if (nlhs > 3)
		{
			data_type_str = haGetDataTypeString(data_type);
			plhs[3] = mxCreateString(data_type_str);
		}
		if (nlhs > 4)
			plhs[4] = haCreateDoubleScalar((double) nattrs);
	}
	else
	{
		plhs[0] = EMPTYSTR;
		if (nlhs > 1)
			plhs[1] = ZERO;
		if (nlhs > 2)
			plhs[2] = EMPTY;
		if (nlhs > 3)
			plhs[3] = EMPTYSTR;
		if (nlhs > 4)
			plhs[4] = ZERO;
	}
	if (nlhs > 5)
		plhs[5] = haCreateDoubleScalar((double) status);
}

/* 
 * hdfSDgetrange
 *
 * Purpose: gateway to SDgetrange()
 *
 * MATLAB usage:
 * [rmax,rmin,status] = hdf('SD', 'getrange', sds_id)
 */
static void hdfSDgetrange(int nlhs,
                          mxArray *plhs[],
                          int nrhs,
                          const mxArray *prhs[])
{
    intn status;
    int32 sds_id;
    char name[MAX_NC_NAME];
    int32 rank;
    int32 dimsizes[MAX_VAR_DIMS];
    int32 data_type;
    int32 nattrs;
    int siz[2];
    mxArray *xmin,*xmax;
    VOIDP data_max, data_min;
    bool ok_to_free_data_max;
    bool ok_to_free_data_min;

    haNarginChk(3, 3, nrhs);
    haNargoutChk(0, 3, nlhs);

    sds_id = (int32) haGetDoubleScalar(prhs[2], "Scientific dataset identifier");

    /* Determine datatype of dataset */
    status = SDgetinfo(sds_id,name,&rank,dimsizes,&data_type,&nattrs);
    if (status == SUCCEED)
    {
        siz[0] = 1;
        siz[1] = 1;

        data_max = haMakeHDFDataBuffer(1, data_type);
        data_min = haMakeHDFDataBuffer(1, data_type);
        if ((data_max == NULL) || (data_min == NULL))
        {
            status = FAIL;
        }
        else
        {
            status = SDgetrange(sds_id, data_max, data_min);
            if (status == SUCCEED)
            {
                xmin = haMakeArrayFromHDFDataBuffer(2, siz, data_type, 
                                                    data_min, 
                                                    &ok_to_free_data_min);
                if (ok_to_free_data_min)
                {
                    mxFree(data_min);
                }
                if (xmin == NULL)
                {
                    status = FAIL;
                }
                else
                {
                    xmax = haMakeArrayFromHDFDataBuffer(2, siz, data_type, 
                                                        data_max, 
                                                        &ok_to_free_data_max);
                    if (ok_to_free_data_max)
                    {
                        mxFree(data_max);
                    }
                    if (xmax == NULL)
                    {
                        status = FAIL;
                        mxDestroyArray(xmin);
                    }
                }
            }
        }
    }

    if (status != SUCCEED)
    {
        xmin = EMPTY;
        xmax = EMPTY;
    }
    
    plhs[0] = xmax;

    if (nlhs > 1)
    {
        plhs[1] = xmin;
    }
    else
    {
        mxDestroyArray(xmin);
    }
    
    if (nlhs > 2)
    {
        plhs[2] = haCreateDoubleScalar((double) status);
    }
}

/*
 * hdfSDidtoref
 *
 * Purpose: gateway to SDidtoref()
 *
 * MATLAB usage:
 * ref = hdf('SD', 'idtoref', sds_id)
 */
static void hdfSDidtoref(int nlhs,
                         mxArray *plhs[],
                         int nrhs,
                         const mxArray *prhs[])
{
    int32 sds_id;
    int32 ref;

    haNarginChk(3, 3, nrhs);
    haNargoutChk(0, 1, nlhs);

    sds_id = (int32) haGetDoubleScalar(prhs[2], "Scientific dataset identifier");
    ref = SDidtoref(sds_id);
    plhs[0] = haCreateDoubleScalar((double) ref);
}

/*
 * hdfSDiscoordvar
 *
 * Purpose: gateway to SDiscoordvar()
 *
 * MATLAB usage:
 * tf = hdf('SD', 'iscoordvar', sds_id)
 */
static void hdfSDiscoordvar(int nlhs,
                         mxArray *plhs[],
                         int nrhs,
                         const mxArray *prhs[])
{
    int32 sds_id;
    intn tf;

    haNarginChk(3, 3, nrhs);
    haNargoutChk(0, 1, nlhs);

    sds_id = (int32) haGetDoubleScalar(prhs[2], "Scientific dataset identifier");
    tf = SDiscoordvar(sds_id);
    plhs[0] = haCreateDoubleScalar((double) tf);
}

/*
 * hdfSDisdimval_bwcomp
 *
 * Purpose: gateway to SDisdimval_bwcomp()
 *
 * MATLAB usage:
 * tf = hdf('SD', 'isdimval_bwcomp', sds_id)
 */
static void hdfSDisdimval_bwcomp(int nlhs,
                         mxArray *plhs[],
                         int nrhs,
                         const mxArray *prhs[])
{
    int32 sds_id;
    intn tf;

    haNarginChk(3, 3, nrhs);
    haNargoutChk(0, 1, nlhs);

    sds_id = (int32) haGetDoubleScalar(prhs[2], "Scientific dataset identifier");
    tf = SDisdimval_bwcomp(sds_id);
    plhs[0] = haCreateDoubleScalar((double) tf);
}

/*
 * hdfSDisrecord
 *
 * Purpose: gateway to SDisrecord()
 *
 * MATLAB usage:
 * tf = hdf('SD', 'isrecord', sds_id)
 */
static void hdfSDisrecord(int nlhs,
                         mxArray *plhs[],
                         int nrhs,
                         const mxArray *prhs[])
{
    int32 sds_id;
    intn tf;

    haNarginChk(3, 3, nrhs);
    haNargoutChk(0, 1, nlhs);

    sds_id = (int32) haGetDoubleScalar(prhs[2], "Scientific dataset identifier");
    tf = SDisrecord(sds_id);
    plhs[0] = haCreateDoubleScalar((double) tf);
}

/* 
 * hdfSDnametoindex
 *
 * Purpose: gateway to SDnametoindex()
 *
 * MATLAB usage:
 * idx = hdf('SD', 'nametoindex', sd_id, name)
 */
static void hdfSDnametoindex(int nlhs,
                             mxArray *plhs[],
                             int nrhs,
                             const mxArray *prhs[])
{
    int32 sd_id;
    char *name;
    int32 idx;

    haNarginChk(4, 4, nrhs);
    haNargoutChk(0, 1, nlhs);

    sd_id = (int32) haGetDoubleScalar(prhs[2], "SD identifier");
    name = haGetString(prhs[3], "Dataset name");

    idx = SDnametoindex(sd_id, name);

    plhs[0] = haCreateDoubleScalar((double) idx);

    mxFree(name);
}

/*
 * hdfSDreadattr
 *
 * Purpose: gateway to SDreadattr()
 *
 * MATLAB usage:
 * [data, status] = hdf('SD','readattr',file_id/sds_id/dim_id,attr_index)
 */
static void hdfSDreadattr(int nlhs,
                          mxArray *plhs[],
                          int nrhs,
                          const mxArray *prhs[])
{
    intn status;
    int32 id;
    int32 attr_index;
    char name[MAX_NC_NAME];
    int32 data_type;
    int32 count;
    int siz[2];
    VOIDP data;
    bool ok_to_free_data;
	
    haNarginChk(4, 4, nrhs);
    haNargoutChk(0, 2, nlhs);

    id = (int32) haGetDoubleScalar(prhs[2], "Identifier");
    attr_index = (int32) haGetDoubleScalar(prhs[3],"Attribute index");
	
    /* Determine size of attribute */
    status = SDattrinfo(id, attr_index, name, &data_type, &count);
    if (status == SUCCEED)
    {
        siz[0] = 1;
        siz[1] = count;

        data = haMakeHDFDataBuffer(count, data_type);
        status = SDreadattr(id, attr_index, data);
        if (status == SUCCEED)
        {
            plhs[0] = haMakeArrayFromHDFDataBuffer(2, siz, data_type,
                                                   data, &ok_to_free_data);
            if (ok_to_free_data)
            {
                mxFree(data);
            }
            
            if (plhs[0] == NULL)
            {
                status = FAIL;
                plhs[0] = EMPTY;
            }
        }
    }

    if (status != SUCCEED)
    {
        plhs[0] = EMPTY;
    }
	
    if (nlhs > 1)
    {
        plhs[1] = haCreateDoubleScalar((double) status);
    }
}

/*
 * hdfSDreadchunk
 *
 * Purpose: gateway to SDreadchunk()
 *
 * MATLAB usage:
 * [data, status] = hdf('SD','readchunk',sds_id,origin)
 */
static void hdfSDreadchunk(int nlhs,
                           mxArray *plhs[],
                           int nrhs,
                           const mxArray *prhs[])
{
    intn status;
    int32 sds_id;
    int32 origin[MAX_VAR_DIMS];
    char name[MAX_NC_NAME];
    int32 rank;
    int32 dimsizes[MAX_VAR_DIMS];
    int32 data_type;
    int32 nattrs;
    HDF_CHUNK_DEF cdef;
    int i;
    int siz[MAX_VAR_DIMS];
    int32 flags;
    VOIDP data;
    bool ok_to_free_data;
	
    haNarginChk(4, 4, nrhs);
    haNargoutChk(0, 2, nlhs);

    sds_id = (int32) haGetDoubleScalar(prhs[2], "Scientific dataset identifier");

    /* Determine rank and datatype of dataset */
    status = SDgetinfo(sds_id,name,&rank,dimsizes,&data_type,&nattrs);
    if (status != SUCCEED)
    {
        plhs[0] = EMPTY;
        if (nlhs > 1)
            plhs[1] = haCreateDoubleScalar((double) status);
        return;
    }
	
    haGetIntegerVector(prhs[3],rank,"Origin",origin);
	
    /* Determine size of chunk */
    status = SDgetchunkinfo(sds_id,&cdef,&flags);
    if (status != SUCCEED)
    {
        plhs[0] = EMPTY;
        if (nlhs > 1)
            plhs[1] = haCreateDoubleScalar((double) status);
        return;
    }
	
    if (rank == 0)
    {
        rank = 2;
        siz[0] = 1;
        siz[1] = 1;
    }
    else if (rank == 1)
    {
        rank = 2;
        siz[0] = cdef.chunk_lengths[0];
        siz[1] = 1;
    }
    else
    {
        for (i=0; i<rank; i++) 
            siz[rank-i-1] = cdef.chunk_lengths[i];
    }

    data = haMakeHDFDataBuffer(haGetNumberOfElements(rank,siz), data_type);
    if (data == NULL)
    {
        plhs[0] = EMPTY;
        if (nlhs > 1) plhs[1] = haCreateDoubleScalar((double) FAIL);
        return;
    }
    
    status = SDreadchunk(sds_id, origin, data);
    if (status != SUCCEED)
    {
        plhs[0] = EMPTY;
        if (nlhs > 1) plhs[1] = haCreateDoubleScalar((double) FAIL);
        mxFree(data);
        return;
    }
    
    plhs[0] = haMakeArrayFromHDFDataBuffer(rank, siz, data_type, data,
                                           &ok_to_free_data);
    if (ok_to_free_data)
    {
        mxFree(data);
    }
    
    if (plhs[0] == NULL)
    {
        plhs[0] = EMPTY;
        if (nlhs > 1) plhs[1] = haCreateDoubleScalar((double) FAIL);
        return;
    }

    if (nlhs > 1)
    {
        plhs[1] = haCreateDoubleScalar((double) status);
    }
}


/*
 * hdfSDreaddata
 *
 * Purpose: gateway to SDreaddata()
 *
 * MATLAB usage:
 * [data, status] = hdf('SD','readdata',sds_id/dim_id,start,stride,edge)
 */
static void hdfSDreaddata(int nlhs,
                          mxArray *plhs[],
                          int nrhs,
                          const mxArray *prhs[])
{
    intn status;
    int32 sds_id;
    int32 start[MAX_VAR_DIMS];
    int32 stride[MAX_VAR_DIMS];
    int32 edge[MAX_VAR_DIMS];
    char name[MAX_NC_NAME];
    int32 rank;
    int32 dimsizes[MAX_VAR_DIMS];
    int32 data_type;
    int32 nattrs;
    int32 count;
    int i;
    int siz[MAX_VAR_DIMS];
    VOIDP data;
    bool ok_to_free_data;
    int num_elements;
	
    haNarginChk(6, 6, nrhs);
    haNargoutChk(0, 2, nlhs);

    sds_id = (int32) haGetDoubleScalar(prhs[2], "Scientific dataset identifier");

    /* Determine rank and datatype of dataset */
    status = SDgetinfo(sds_id,name,&rank,dimsizes,&data_type,&nattrs);
    if (status != SUCCEED)
    {
        /* Try treating the id as a dim id */
        status = SDdiminfo(sds_id,NULL,&count,&data_type,&nattrs);
        if (status == SUCCEED)
        {
            rank = 1; /* dim vectors are always 1-D */
            if (data_type == 0)
                mexErrMsgTxt("Attempt to read scale with SDreaddata from dimension that doesn't have one.");
        }
        else
        {
            plhs[0] = EMPTY;
            if (nlhs > 1)
                plhs[1] = haCreateDoubleScalar((double) status);
            return;
        }
    }

    haGetIntegerVector(prhs[3],rank,"Start",start);
    
    if (!haIsNULL(prhs[4]))
    	haGetIntegerVector(prhs[4],rank,"Stride",stride);
    	
    haGetIntegerVector(prhs[5],rank,"Edge",edge);

    if (rank == 0)
    {
        rank = 2;
        siz[0] = 1;
        siz[1] = 1;
    }
    else if (rank == 1)
    {
        rank = 2;
        siz[0] = edge[0];
        siz[1] = 1;
    }
    else
    {
        for (i=0; i<rank; i++)
            siz[rank-i-1] = edge[i];
    }

    num_elements = haGetNumberOfElements(rank, siz);
    data = haMakeHDFDataBuffer(num_elements, data_type);
    if (data == NULL)
    {
        plhs[0] = EMPTY;
        if (nlhs > 1)
            plhs[1] = haCreateDoubleScalar((double) FAIL);
        return;
    }
    
    if (!haIsNULL(prhs[4]))
        status = SDreaddata(sds_id,start,stride,edge,data);
    else
        status = SDreaddata(sds_id,start,NULL,edge,data);

    if (status != SUCCEED)
    {
        mxFree(data);
        plhs[0] = EMPTY;
        if (nlhs > 1)
            plhs[1] = haCreateDoubleScalar((double) status);
        return;
    }
    
    plhs[0] = haMakeArrayFromHDFDataBuffer(rank, siz, data_type, data,
                                           &ok_to_free_data);
    if (ok_to_free_data)
    {
        mxFree(data);
    }
    if (plhs[0] == NULL)
    {
        plhs[0] = EMPTY;
        if (nlhs > 1)
            plhs[1] = haCreateDoubleScalar((double) status);
        return;
    }
    
    if (nlhs > 1)
        plhs[1] = haCreateDoubleScalar((double) status);
}

/*
 * hdfSDreftoindex
 *
 * Purpose: SDreftoindex()
 *
 * MATLAB usage:
 * sds_index = hdf('SD', 'reftoindex', sd_id, ref)
 */
static void hdfSDreftoindex(int nlhs,
                            mxArray *plhs[],
                            int nrhs,
                            const mxArray *prhs[])
{
    int32 sd_id;
    uint16 ref;
    int32 sds_index;

    haNarginChk(4, 4, nrhs);
    haNargoutChk(0, 1, nlhs);

    sd_id = (int32) haGetDoubleScalar(prhs[2], "SD identifier");
    ref = (uint16) haGetDoubleScalar(prhs[3], "Reference number");

    sds_index = SDreftoindex(sd_id, ref);

    plhs[0] = haCreateDoubleScalar((double) sds_index);
}
    
/*
 * hdfSDselect
 *
 * Purpose: gateway to SDselect()
 * 
 * MATLAB usage:
 * sds_id = hdf('SD', 'select', sd_id, sds_idx)
 */
static void hdfSDselect(int nlhs,
                        mxArray *plhs[],
                        int nrhs,
                        const mxArray *prhs[])
{
    int32 sd_id;
    int32 sds_index;
    int32 sds_id;
    intn status;

    haNarginChk(4, 4, nrhs);
    haNargoutChk(0, 1, nlhs);

    sd_id = (int32) haGetDoubleScalar(prhs[2], "SD indentifier");
    sds_index = (int32) haGetDoubleScalar(prhs[3], "SD data-set index");

    sds_id = SDselect(sd_id, sds_index);
    if (sds_id != FAIL)
    {
        status = haAddIDToList(sds_id, SDS_ID_List);
        if (status == FAIL)
        {
            /* Failed to add sds_id to the list. */
            /* This could cause data loss later, so don't allow it. */
            SDendaccess(sds_id);
            sds_id = FAIL;
        }
    }

    plhs[0] = haCreateDoubleScalar((double) sds_id);
}

/*
 * hdfSDsetaccesstype
 *
 * Purpose: gateway to SDsetaccesstype()
 *
 * MATLAB usage:
 * status = hdf('SD', 'setaccesstype', sd_id, access_mode)
 *          access_mode can be 'serial' or 'parallel'
 */
static void hdfSDsetaccesstype(int nlhs,
                               mxArray *plhs[],
                               int nrhs,
                               const mxArray *prhs[])
{
    int32 sd_id;
    uintn access_mode;
    char *access_mode_str;
    intn status;

    haNarginChk(4, 4, nrhs);
    haNargoutChk(0, 1, nlhs);

    sd_id = (int32) haGetDoubleScalar(prhs[2], "SD identifier");
    access_mode_str = haGetString(prhs[3], "Access mode");

    if (strcmp(access_mode_str, "serial") == 0)
    {
        access_mode = DFACC_SERIAL;
    }
    else if (strcmp(access_mode_str, "parallel") == 0)
    {
        access_mode = DFACC_PARALLEL;
    }
    else
    {
        mexErrMsgTxt("Access mode must be 'serial' or 'parallel'.");
    }

    status = SDsetaccesstype(sd_id, access_mode);

    plhs[0] = haCreateDoubleScalar((double) status);

    mxFree(access_mode_str);
}


/*
 * hdfSDsetattr
 *
 * Purpose: gateway to SDsetattr()
 *
 * MATLAB usage:
 * status = hdf('SD', 'setattr',file_id/sds_id/dim_id, name, A)
 */
static void hdfSDsetattr(int nlhs,
                         mxArray *plhs[],
                         int nrhs,
                         const mxArray *prhs[])
{
    int32 id;
    char *name;
    const mxArray *A;
    int32 data_type;
    int32 count;
    VOIDP values;
    bool free_buffer = false;
    intn status;

    haNarginChk(5, 5, nrhs);
    haNargoutChk(0, 1, nlhs);

    id = (int32) haGetDoubleScalar(prhs[2], "Identifier");
    name = haGetString(prhs[3], "Name");
    
    A = prhs[4];
    if(mxIsEmpty(A))
    {
        count = 1;
    }
    else
    {    
        count = mxGetNumberOfElements(A);
    }
    data_type = haGetDataTypeFromClassID(mxGetClassID(A));

    if (mxGetClassID(A) == mxCHAR_CLASS)
    {
        values = haMakeHDFDataBufferFromCharArray(A, data_type);
        free_buffer = true;
    }
    else
    {
        values = mxGetData(A);
    }

    status = SDsetattr(id, name, data_type, count, values);

    plhs[0] = haCreateDoubleScalar((double) status);

    mxFree(name);
    if (free_buffer)
    {
        mxFree(values);
    }
}

/*
 * hdfSDsetblocksize
 *
 * Purpose: gateway to SDsetblocksize()
 *
 * MATLAB usage:
 * status = hdf('SD', 'setblocksize',sd_id, blocksize)
 */
static void hdfSDsetblocksize(int nlhs,
                         mxArray *plhs[],
                         int nrhs,
                         const mxArray *prhs[])
{
    int32 sd_id;
    int32 blocksize;
    intn status;

    haNarginChk(4, 4, nrhs);
    haNargoutChk(0, 1, nlhs);

    sd_id = (int32) haGetDoubleScalar(prhs[2], "SD identifier");
    blocksize = (int32) haGetDoubleScalar(prhs[3], "Blocksize");
    
    status = SDsetblocksize(sd_id,blocksize);

    plhs[0] = haCreateDoubleScalar((double) status);
}

/*
 * hdfSDsetcal
 *
 * Purpose: gateway to SDsetcal()
 *
 * MATLAB usage:
 * status = hdf('SD', 'setcal', sds_id, cal, cal_err, offset, offset_err, data_type)
 */
static void hdfSDsetcal(int nlhs,
                         mxArray *plhs[],
                         int nrhs,
                         const mxArray *prhs[])
{
	int32 sds_id;
	float64 cal;
	float64 cal_err;
	float64 offset;
	float64 offset_err;
	int32 data_type;
	intn status;
	mxClassID class_id;
	
    haNarginChk(8, 8, nrhs);
    haNargoutChk(0, 1, nlhs);

    sds_id = (int32) haGetDoubleScalar(prhs[2], "Scientific dataset identifier");
    cal = (float64) haGetDoubleScalar(prhs[3], "Calibration factor");
    cal_err = (float64) haGetDoubleScalar(prhs[4], "Calibration error");
    offset = (float64) haGetDoubleScalar(prhs[5], "Uncalibrated offset");
    offset_err = (float64) haGetDoubleScalar(prhs[6], "Uncalibrated offset error");
    data_type = haGetDataType(prhs[7]);
    
    /* Make sure we can support this data_type */
    class_id = haGetClassIDFromDataType(data_type);
    if (class_id == mxUNKNOWN_CLASS)
    {
        mexErrMsgTxt("Unsupported data type.");
    }

    status = SDsetcal(sds_id,cal,cal_err,offset,offset_err,data_type);
    
    plhs[0] = haCreateDoubleScalar((double) status);
}

/*
 * hdfSDsetchunk
 *
 * Purpose: gateway to SDsetchunk()
 *
 * MATLAB usage:
 * status = hdf('SD', 'setchunk', sds_id, chunk_lengths, comp_type, ...)
 *      comp_type can be 'none','jpeg','rle','deflate',or 'skphuff'.
 *      Additional param/value pairs must be passed for some methods.  This routine
 *      understands the following param/value pairs:
 *         'jpeg_quality'        , integer
 *         'jpeg_force_baseline' , integer
 *         'skphuff_skp_size'    , integer
 *         'deflate_level'       , integer
 */
static void hdfSDsetchunk(int nlhs,
                         mxArray *plhs[],
                         int nrhs,
                         const mxArray *prhs[])
{
	int32 sds_id;
    char name[MAX_NC_NAME];
    int32 rank;
    int32 dimsizes[MAX_VAR_DIMS];
    int32 chunk_lengths[MAX_VAR_DIMS];
    int32 data_type;
    int32 nattrs;
	HDF_CHUNK_DEF cdef;
	int32 flags;
	intn status;
	int i;
	
    haNarginChk(5, 9, nrhs);
    haNargoutChk(0, 1, nlhs);

    sds_id = (int32) haGetDoubleScalar(prhs[2], "Scientific dataset identifier");

	/* Determine rank of dataset */
	status = SDgetinfo(sds_id,name,&rank,dimsizes,&data_type,&nattrs);
	if (status != SUCCEED)
	{
		plhs[0] = haCreateDoubleScalar((double) status);
		return;
	}

	/* Initialize HDF_CHUNK_DEF */
	cdef.comp.comp_type = COMP_CODE_NONE;
	cdef.comp.model_type = COMP_MODEL_STDIO;

    haGetIntegerVector(prhs[3],rank,"Chunk lengths",chunk_lengths);
    cdef.comp.comp_type = haGetCompType(prhs[4]);
    
    if (cdef.comp.comp_type != COMP_CODE_NONE)
    {
    	flags = HDF_CHUNK | HDF_COMP;
    	for (i=0; i<rank; i++)
    	{
    		cdef.chunk_lengths[i] = cdef.comp.chunk_lengths[i] = chunk_lengths[i];
    	}
    }
	else
	{
		flags = HDF_CHUNK;
		for (i=0; i<rank; i++)
		{
			cdef.chunk_lengths[i] = chunk_lengths[i];
		}
	}
    
    if (nrhs % 2 != 1)
    	mexErrMsgTxt("Wrong number of inputs.");
    	
    for (i=5; i<nrhs; i+=2)
    	haGetCompInfo(prhs[i],prhs[i+1],&(cdef.comp.cinfo));
		
	status = SDsetchunk(sds_id,cdef,flags);
	
	plhs[0] = haCreateDoubleScalar((double) status);
}

/*
 * hdfSDsetchunkcache
 *
 * Purpose: gateway to SDsetchunkcache()
 *
 * MATLAB usage:
 * status = hdf('SD', 'setchunkcache', sds_id, maxcache, flags)
 */
static void hdfSDsetchunkcache(int nlhs,
                         mxArray *plhs[],
                         int nrhs,
                         const mxArray *prhs[])
{
	int32 sds_id;
	int32 maxcache;
	int32 flags;
	intn  status;
	
    haNarginChk(5, 5, nrhs);
    haNargoutChk(0, 1, nlhs);

    sds_id = (int32) haGetDoubleScalar(prhs[2], "Scientific dataset identifier");
    maxcache = (int32) haGetDoubleScalar(prhs[3], "Max cache number");
    flags = (int32) haGetDoubleScalar(prhs[4], "Flags");
    
    status = SDsetchunkcache(sds_id,maxcache,flags);
    
	plhs[0] = haCreateDoubleScalar((double) status);
}

/*
 * hdfSDsetcompress
 *
 * Purpose: gateway to SDsetcompress()
 *
 * MATLAB usage:
 * status = hdf('SD', 'setcompress', sd_id, comp_type, ...)
 *      comp_type can be 'none','jpeg','rle','deflate',or 'skphuff'.
 *      Additional param/value pairs must be passed for some methods.  This routine
 *      understands the following param/value pairs:
 *         'jpeg_quality'        , integer
 *         'jpeg_force_baseline' , integer
 *         'skphuff_skp_size'    , integer
 *         'deflate_level'       , integer
 */
static void hdfSDsetcompress(int nlhs,
                         mxArray *plhs[],
                         int nrhs,
                         const mxArray *prhs[])
{
	int32 sd_id;
	int32 comp_type;
	comp_info cinfo;
	intn  status;
	int i;
	
    haNarginChk(4, 8, nrhs);
    haNargoutChk(0, 1, nlhs);

    sd_id = (int32) haGetDoubleScalar(prhs[2], "SD identifier");

    comp_type = haGetCompType(prhs[3]);
    	
    if (nrhs % 2 != 0)
    	mexErrMsgTxt("Wrong number of inputs.");
    	
    for (i=4; i<nrhs; i+=2)
    	haGetCompInfo(prhs[i],prhs[i+1],&cinfo);
    
    status = SDsetcompress(sd_id,comp_type,&cinfo);
    
	plhs[0] = haCreateDoubleScalar((double) status);
}

/*
 * hdfSDsetdatastrs
 *
 * Purpose: gateway to SDsetdatastrs()
 *
 * MATLAB usage:
 * status = hdf('SD', 'setdatastrs', sds_id, label, unit, format, coordsys)
 */
static void hdfSDsetdatastrs(int nlhs,
                         mxArray *plhs[],
                         int nrhs,
                         const mxArray *prhs[])
{
	intn status;
	int32 sds_id;
	char *label = NULL;
	char *unit = NULL;
	char *format = NULL;
	char *coordsys = NULL;
	
    haNarginChk(7, 7, nrhs);
    haNargoutChk(0, 1, nlhs);

    sds_id = (int32) haGetDoubleScalar(prhs[2], "Scientific dataset identifier");
    
    if (!haIsNULL(prhs[3]))
    	label = haGetString(prhs[3],"Label string");

    if (!haIsNULL(prhs[4]))
    	unit = haGetString(prhs[4],"Units string");

    if (!haIsNULL(prhs[5]))
    	format = haGetString(prhs[5],"Format string");

    if (!haIsNULL(prhs[6]))
    	coordsys = haGetString(prhs[6],"Coordinate system string");

	status = SDsetdatastrs(sds_id,label,unit,format,coordsys);
	
	plhs[0] = haCreateDoubleScalar((double) status);
	
	mxFree(label);
	mxFree(unit);
	mxFree(format);
	mxFree(coordsys);
}

/*
 * hdfSDsetdimname
 *
 * Purpose: gateway to SDsetdimname()
 *
 * MATLAB usage:
 * status = hdf('SD', 'setdimname', dim_id, name)
 */
static void hdfSDsetdimname(int nlhs,
                         mxArray *plhs[],
                         int nrhs,
                         const mxArray *prhs[])
{
	int32 dim_id;
	char *name;
	intn  status;
	
    haNarginChk(4, 4, nrhs);
    haNargoutChk(0, 1, nlhs);

    dim_id = (int32) haGetDoubleScalar(prhs[2], "Dimension identifier");
    name = haGetString(prhs[3],"Dimension name");
    
    status = SDsetdimname(dim_id,name);
    
	plhs[0] = haCreateDoubleScalar((double) status);
	
	mxFree(name);
}

/*
 * hdfSDsetdimscale
 *
 * Purpose: gateway to SDsetdimscale()
 *
 * MATLAB usage:
 * status = hdf('SD', 'setdimscale', dim_id, scale)
 */
static void hdfSDsetdimscale(int nlhs,
                             mxArray *plhs[],
                             int nrhs,
                             const mxArray *prhs[])
{
    int32 dim_id;
    int32 count;
    int32 data_type;
    VOIDP data;
    bool free_buffer = false;
    intn  status;
	
    haNarginChk(4, 4, nrhs);
    haNargoutChk(0, 1, nlhs);

    dim_id = (int32) haGetDoubleScalar(prhs[2], "Dimension identifier");
    data_type = haGetDataTypeFromClassID(mxGetClassID(prhs[3]));
    count = mxGetNumberOfElements(prhs[3]);

    if (mxGetClassID(prhs[3]) == mxCHAR_CLASS)
    {
        data = haMakeHDFDataBufferFromCharArray(prhs[3], data_type);
        free_buffer = true;
    }
    else
    {
    	data = mxGetData(prhs[3]);
    }
    
    status = SDsetdimscale(dim_id,count,data_type,data);
    
    plhs[0] = haCreateDoubleScalar((double) status);
	
    if (free_buffer)
        mxFree(data);
}


/*
 * hdfSDsetdimstrs
 *
 * Purpose: gateway to SDsetdimstrs()
 *
 * MATLAB usage:
 * status = hdf('SD', 'setdimstrs', dim_id, label, unit, format)
 */
static void hdfSDsetdimstrs(int nlhs,
                         mxArray *plhs[],
                         int nrhs,
                         const mxArray *prhs[])
{
	intn status;
	int32 dim_id;
	char *label = NULL;
	char *unit = NULL;
	char *format = NULL;
	
    haNarginChk(6, 6, nrhs);
    haNargoutChk(0, 1, nlhs);

    dim_id = (int32) haGetDoubleScalar(prhs[2], "Dimension identifier");
    if (!haIsNULL(prhs[3]))
    	label = haGetString(prhs[3],"Label string");
    	
    if (!haIsNULL(prhs[4]))
    	unit = haGetString(prhs[4],"Units string");
    	
    if (!haIsNULL(prhs[5]))
    	format = haGetString(prhs[5],"Format string");

	status = SDsetdimstrs(dim_id,label,unit,format);
	
	plhs[0] = haCreateDoubleScalar((double) status);
	
	mxFree(label);
	mxFree(unit);
	mxFree(format);
}

/*
 * hdfSDsetdimval_comp
 *
 * Purpose: gateway to SDsetdimval_comp()
 *
 * MATLAB usage:
 * status = hdf('SD', 'setdimval_comp', dim_id, mode)
 *      mode can be 'comp' or 'incomp'.
 */
static void hdfSDsetdimval_comp(int nlhs,
                         mxArray *plhs[],
                         int nrhs,
                         const mxArray *prhs[])
{
	int32 dim_id;
	char *mode;
	intn comp_mode;
	intn  status;
	
    haNarginChk(4, 4, nrhs);
    haNargoutChk(0, 1, nlhs);

    dim_id = (int32) haGetDoubleScalar(prhs[2], "Dimension identifier");
    
    mode = haGetString(prhs[3],"Compatibility mode");
    if (strcmp(mode,"comp")==0)
    	comp_mode = SD_DIMVAL_BW_COMP;
    else if (strcmp(mode,"incomp")==0)
    	comp_mode = SD_DIMVAL_BW_INCOMP;
    else
    	mexErrMsgTxt("Invalid or unknown compatibiity mode.");
    	
    status = SDsetdimval_comp(dim_id,comp_mode);
    
	plhs[0] = haCreateDoubleScalar((double) status);

   	mxFree(mode);    
}

/*
 * hdfSDsetexternalfile
 *
 * Purpose: gateway to SDsetexternalfile()
 *
 * MATLAB usage:
 * status = hdf('SD', 'setexternalfile', sds_id, filename, offset)
 */
static void hdfSDsetexternalfile(int nlhs,
                                 mxArray *plhs[],
                                 int nrhs,
                                 const mxArray *prhs[])
{
    int32 sds_id;
    char *filename;
    int32 offset;
    intn status;

    haNarginChk(5, 5, nrhs);
    haNargoutChk(0, 1, nlhs);

    sds_id = (int32) haGetDoubleScalar(prhs[2], "Scientific dataset identifier");
    filename = haGetString(prhs[3], "External filename");
    offset = (int32) haGetDoubleScalar(prhs[4], "Offset");

    status = SDsetexternalfile(sds_id, filename, offset);

    plhs[0] = haCreateDoubleScalar((double) status);

    mxFree(filename);
}

/*
 * hdfSDsetfillmode
 *
 * Purpose: gateway to SDsetfillmode()
 *
 * MATLAB usage:
 * status = hdf('SD', 'setfillmode', dim_id, mode)
 *      mode can be 'fill' or 'nofill'.
 */
static void hdfSDsetfillmode(int nlhs,
                         mxArray *plhs[],
                         int nrhs,
                         const mxArray *prhs[])
{
	int32 dim_id;
	char *mode;
	intn fill_mode;
	intn  status;
	
    haNarginChk(4, 4, nrhs);
    haNargoutChk(0, 1, nlhs);

    dim_id = (int32) haGetDoubleScalar(prhs[2], "Dimension identifier");
    
    mode = haGetString(prhs[3],"Fill mode");
    if (strcmp(mode,"fill")==0)
    	fill_mode = SD_FILL;
    else if (strcmp(mode,"nofill")==0)
    	fill_mode = SD_NOFILL;
    else
    	mexErrMsgTxt("Invalid or unknown fill mode.");
    	
    status = SDsetfillmode(dim_id,fill_mode);
    
	plhs[0] = haCreateDoubleScalar((double) status);

   	mxFree(mode);    
}

/*
 * hdfSDsetfillvalue
 *
 * Purpose: gateway to SDsetfillvalue()
 *
 * MATLAB usage:
 * status = hdf('SD', 'setfillvalue', sds_id, value)
 */
static void hdfSDsetfillvalue(int nlhs,
                              mxArray *plhs[],
                              int nrhs,
                              const mxArray *prhs[])
{
    int32 sds_id;
    intn  status;
    char name[MAX_NC_NAME];
    int32 rank;
    int32 dimsizes[MAX_VAR_DIMS];
    int32 data_type;
    int32 nattrs;
    VOIDP fill_val;
    bool free_buffer = false;

    haNarginChk(4, 4, nrhs);
    haNargoutChk(0, 1, nlhs);

    sds_id = (int32) haGetDoubleScalar(prhs[2], "Scientific dataset identifier");
    
    /* Determine datatype of dataset */
    status = SDgetinfo(sds_id,name,&rank,dimsizes,&data_type,&nattrs);
    if (status != SUCCEED)
    {
        plhs[0] = haCreateDoubleScalar((double) status);
        return;
    }
	
    if (mxGetNumberOfElements(prhs[3]) != 1 || 
        haGetClassIDFromDataType(data_type) != mxGetClassID(prhs[3]))
    {
        mexErrMsgTxt("Fill value must be a scalar with the same datatype "
                     "as the dataset.");
    }

    if (mxGetClassID(prhs[3]) == mxCHAR_CLASS)
    {
        fill_val = haMakeHDFDataBufferFromCharArray(prhs[3], data_type);
        free_buffer = true;
    }
    else
    {
    	fill_val = mxGetData(prhs[3]);
    }

    status = SDsetfillvalue(sds_id,fill_val);
    plhs[0] = haCreateDoubleScalar((double) status);
    if (free_buffer)
    {
        mxFree(fill_val);
    }
}


/*
 * hdfSDsetnbitdataset
 *
 * Purpose: gateway to SDsetnbitdataset()
 *
 * MATLAB usage:
 * status = hdf('SD', 'setnbitdataset', sds_id, start_bit, bit_len, sign_ext, fill_one)
 */
static void hdfSDsetnbitdataset(int nlhs,
                         mxArray *plhs[],
                         int nrhs,
                         const mxArray *prhs[])
{
	int32 sds_id;
	intn start_bit;
	intn bit_len;
	intn sign_ext;
	intn fill_one;
	intn  status;
	
    haNarginChk(7, 7, nrhs);
    haNargoutChk(0, 1, nlhs);

    sds_id = (int32) haGetDoubleScalar(prhs[2], "Scientific dataset identifier");
    start_bit = (intn) haGetDoubleScalar(prhs[3], "Leftmost bit");
    bit_len = (intn) haGetDoubleScalar(prhs[4], "Length of bit field");
    sign_ext = (intn) haGetDoubleScalar(prhs[5], "Sign extension specifier");
    fill_one = (intn) haGetDoubleScalar(prhs[6], "Background bit specifier");
    
    sign_ext = (sign_ext) ? TRUE : FALSE;
    fill_one = (fill_one) ? TRUE : FALSE;
    status = SDsetnbitdataset(sds_id,start_bit,bit_len,sign_ext,fill_one);
    
	plhs[0] = haCreateDoubleScalar((double) status);
}

/*
 * hdfSDsetrange
 *
 * Purpose: gateway to SDsetrange()
 *
 * MATLAB usage:
 * status = hdf('SD', 'setrange', sds_id, max, min)
 */
static void hdfSDsetrange(int nlhs,
                          mxArray *plhs[],
                          int nrhs,
                          const mxArray *prhs[])
{
    int32 sds_id;
    intn  status;
    char name[MAX_NC_NAME];
    int32 rank;
    int32 dimsizes[MAX_VAR_DIMS];
    int32 data_type;
    int32 nattrs;
    VOIDP pmin;
    VOIDP pmax;
    bool free_buffers = false;

    haNarginChk(5, 5, nrhs);
    haNargoutChk(0, 1, nlhs);

    sds_id = (int32) haGetDoubleScalar(prhs[2], 
                                       "Scientific dataset identifier");
    
    /* Determine datatype of dataset */
    status = SDgetinfo(sds_id,name,&rank,dimsizes,&data_type,&nattrs);
    if (status != SUCCEED)
    {
        plhs[0] = haCreateDoubleScalar((double) status);
        return;
    }
	
    if (mxGetNumberOfElements(prhs[3]) != 1 || 
        mxGetNumberOfElements(prhs[4]) != 1 ||
        haGetClassIDFromDataType(data_type) != mxGetClassID(prhs[3]) || 
        haGetClassIDFromDataType(data_type) != mxGetClassID(prhs[4]))
    {
        mexErrMsgTxt("Min and max must be scalars with the same "
                     "datatype as the dataset.");
    }

    if (mxGetClassID(prhs[3]) == mxCHAR_CLASS)
    {
        pmax = haMakeHDFDataBufferFromCharArray(prhs[3], data_type);
        pmin = haMakeHDFDataBufferFromCharArray(prhs[3], data_type);
        free_buffers = true;
    }
    else
    {
    	pmax = mxGetData(prhs[3]);
    	pmin = mxGetData(prhs[4]);
    }

    status = SDsetrange(sds_id,pmax,pmin);
    
    plhs[0] = haCreateDoubleScalar((double) status);

    if (free_buffers)
    {
        mxFree(pmin);
        mxFree(pmax);
    }
}

/*
 * hdfSDstart
 * 
 * Purpose: gateway to SDstart()
 *
 * MATLAB usage:
 * sd_id = hdf('SD', 'start', filename, access_mode)
 *     access_mode can be 'read','write','create', 'rdwr', or 'rdonly'
 */
static void hdfSDstart(int nlhs,
                       mxArray *plhs[],
                       int nrhs,
                       const mxArray *prhs[])
{
    char *filename;
    int32 access_mode;
    int32 sd_id;
    intn status;

    haNarginChk(4, 4, nrhs);
    haNargoutChk(0, 1, nlhs);

    filename = haGetString(prhs[2], "Filename");
    access_mode = haGetAccessMode(prhs[3]);
    	
    sd_id = SDstart(filename,access_mode);
    if (sd_id != FAIL)
    {
        status = haAddIDToList(sd_id, SD_ID_List);
        if (status == FAIL)
        {
            /* Failed to add sd_id to the list. */
            /* This might cause data loss later, so don't allow it. */
            SDend(sd_id);
            sd_id = FAIL;
        }
    }
    plhs[0] = haCreateDoubleScalar((double) sd_id);
    
    mxFree(filename);
}

/*
 * hdfSDwritechunk
 *
 * Purpose: gateway to SDwritechunk()
 *
 * MATLAB usage:
 * status = hdf('SD','writechunk',sds_id,origin,data)
 */
static void hdfSDwritechunk(int nlhs,
                            mxArray *plhs[],
                            int nrhs,
                            const mxArray *prhs[])
{
    intn status;
    int32 sds_id;
    int32 origin[MAX_VAR_DIMS];
    char name[MAX_NC_NAME];
    int32 rank;
    int32 dimsizes[MAX_VAR_DIMS];
    int32 data_type;
    int32 nattrs;
    HDF_CHUNK_DEF cdef;
    int i;
    int siz[MAX_VAR_DIMS];
    int32 flags;
    VOIDP data;
    bool free_buffer = false;
	
    haNarginChk(5, 5, nrhs);
    haNargoutChk(0, 1, nlhs);

    sds_id = (int32) haGetDoubleScalar(prhs[2], "Scientific dataset identifier");

    /* Determine rank and datatype of dataset */
    status = SDgetinfo(sds_id,name,&rank,dimsizes,&data_type,&nattrs);
    if (status != SUCCEED)
    {
        plhs[0] = haCreateDoubleScalar((double) status);
        return;
    }

    haGetIntegerVector(prhs[3],rank,"Origin",origin);
	
    /* Determine size of chunk */
    status = SDgetchunkinfo(sds_id,&cdef,&flags);
    if (status != SUCCEED)
    {
        plhs[0] = haCreateDoubleScalar((double) status);
        return;
    }
    for (i=0; i<rank; i++) 
        siz[rank-i-1] = cdef.chunk_lengths[i];

    if (!haSizeMatches(prhs[4],rank,siz) ||
        haGetClassIDFromDataType(data_type) != mxGetClassID(prhs[4]))
    {
        mexErrMsgTxt("Data array must match chunk size and data type.");
    }

    if (mxGetClassID(prhs[4]) == mxCHAR_CLASS)
    {
        data = haMakeHDFDataBufferFromCharArray(prhs[4],data_type);
        free_buffer = true;
    }
    else
    {
        data = mxGetData(prhs[4]);
    }
				
    status = SDwritechunk(sds_id,origin,data);
	
    plhs[0] = haCreateDoubleScalar((double) status);
	
    if (free_buffer)
    {
        mxFree(data);
    }
}

/*
 * hdfSDwritedata
 *
 * Purpose: gateway to SDwritedata()
 *
 * MATLAB usage:
 * status = hdf('SD','writedata',sds_id, start, stride, edge, data)
 */
static void hdfSDwritedata(int nlhs,
                           mxArray *plhs[],
                           int nrhs,
                           const mxArray *prhs[])
{
    intn status;
    int32 sds_id;
    int32 start[MAX_VAR_DIMS];
    int32 stride[MAX_VAR_DIMS];
    int32 edge[MAX_VAR_DIMS];
    char name[MAX_NC_NAME];
    int32 rank;
    int32 dimsizes[MAX_VAR_DIMS];
    int32 data_type;
    int32 nattrs;
    int i;
    int siz[MAX_VAR_DIMS];
    VOIDP data;
    bool free_buffer = false;
	
    haNarginChk(7, 7, nrhs);
    haNargoutChk(0, 1, nlhs);

    sds_id = (int32) haGetDoubleScalar(prhs[2], "Scientific dataset identifier");
	
    /* Determine rank and datatype of dataset */
    status = SDgetinfo(sds_id,name,&rank,dimsizes,&data_type,&nattrs);
    if (status != SUCCEED)
    {
        plhs[0] = haCreateDoubleScalar((double) status);
        return;
    }
	
    haGetIntegerVector(prhs[3],rank,"Start",start);
    
    if (!haIsNULL(prhs[4]))
    	haGetIntegerVector(prhs[4],rank,"Stride",stride);
    	
    haGetIntegerVector(prhs[5],rank,"Edge",edge);

    for (i=0; i<rank; i++) siz[rank-i-1] = edge[i];

    /* 
     * Here we are only checking that the input array has the right number of
     * of elements.  We don't check to make sure it has the right size.
     */
    if (!haSizeMatches(prhs[6],rank,siz) ||
        haGetClassIDFromDataType(data_type) != mxGetClassID(prhs[6]))
    {
        mexErrMsgTxt("Data array size must match edge specification "
                     "and datatype must match dataset.");
    }

    if (mxGetClassID(prhs[6]) == mxCHAR_CLASS)
    {
        data = haMakeHDFDataBufferFromCharArray(prhs[6], data_type);
        free_buffer = true;
    }
    else
    {
        data = mxGetData(prhs[6]);
    }
	
    if (!haIsNULL(prhs[4]))
        status = SDwritedata(sds_id,start,stride,edge,data);
    else
        status = SDwritedata(sds_id,start,NULL,edge,data);
	
    plhs[0] = haCreateDoubleScalar((double) status);
	
    if (free_buffer)
    {
        mxFree(data);
    }
}

/*
 * hdfSD
 *
 * Purpose: Function switchyard for the SD part of the HDF gateway.
 *
 * Inputs:  nlhs --- number of left-side arguments
 *          plhs --- left-side arguments
 *          nrhs --- number of right-side arguments
 *          prhs --- right-side arguments
 *          functionStr --- string specifying which SD function to call
 * Outputs: none
 * Return:  none
 */
void hdfSD(int nlhs,
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
    } SDFcns[] = {
    	{"attrinfo",hdfSDattrinfo},
    	{"create",hdfSDcreate},
    	{"diminfo",hdfSDdiminfo},
    	{"end",hdfSDend},
    	{"endaccess",hdfSDendaccess},
    	{"fileinfo",hdfSDfileinfo},
    	{"findattr",hdfSDfindattr},
    	{"getcal",hdfSDgetcal},
    	{"getchunkinfo",hdfSDgetchunkinfo},
    	{"getdatastrs",hdfSDgetdatastrs},
    	{"getdimid",hdfSDgetdimid},
    	{"getdimscale",hdfSDgetdimscale},
    	{"getdimstrs",hdfSDgetdimstrs},
    	{"getfillvalue",hdfSDgetfillvalue},
    	{"getinfo",hdfSDgetinfo},
    	{"getrange",hdfSDgetrange},
    	{"idtoref",hdfSDidtoref},
    	{"iscoordvar",hdfSDiscoordvar},
    	{"isdimval_bwcomp",hdfSDisdimval_bwcomp},
    	{"isrecord",hdfSDisrecord},
    	{"nametoindex",hdfSDnametoindex},
    	{"readattr",hdfSDreadattr},
    	{"readchunk",hdfSDreadchunk},
    	{"readdata",hdfSDreaddata},
    	{"reftoindex",hdfSDreftoindex},
    	{"select",hdfSDselect},
    	{"setaccesstype",hdfSDsetaccesstype},
    	{"setattr",hdfSDsetattr},
    	{"setblocksize",hdfSDsetblocksize},
    	{"setcal",hdfSDsetcal},
    	{"setchunk",hdfSDsetchunk},
    	{"setchunkcache",hdfSDsetchunkcache},
    	{"setcompress",hdfSDsetcompress},
    	{"setdatastrs",hdfSDsetdatastrs},
    	{"setdimname",hdfSDsetdimname},
    	{"setdimscale",hdfSDsetdimscale},
    	{"setdimstrs",hdfSDsetdimstrs},
    	{"setdimval_comp",hdfSDsetdimval_comp},
    	{"setexternalfile",hdfSDsetexternalfile},
    	{"setfillmode",hdfSDsetfillmode},
    	{"setfillvalue",hdfSDsetfillvalue},
    	{"setnbitdataset",hdfSDsetnbitdataset},
    	{"setrange",hdfSDsetrange},
    	{"start",hdfSDstart},
    	{"writechunk",hdfSDwritechunk},
    	{"writedata",hdfSDwritedata},
    	{"",NULL}
    };
    	
	int i = 0;
	
	if (nrhs > 0)
		functionStr = haGetString(prhs[1],"Function name");
	else
		mexErrMsgTxt("Not enough input arguments.");
		
	while (SDFcns[i].func != NULL)
	{
		if (strcmp(functionStr,SDFcns[i].name)==0)
		{
			(*(SDFcns[i].func))(nlhs, plhs, nrhs, prhs);
			mxFree(functionStr);
			return;
		}
		i++;
	}
    mexErrMsgTxt("Unknown HDF SD interface function.");
}
