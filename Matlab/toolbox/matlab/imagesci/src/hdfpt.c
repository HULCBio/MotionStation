/* Copyright 1984-2002 The MathWorks, Inc.  */

/*
 * hdfpt.c --- support file for HDF.MEX
 *
 * This module supports the HDF-EOS PT interface.  The only public
 * function is hdfPT(), which is called by mexFunction().
 * hdfPT looks at the second input argument to determine which
 * private function should get control.
 *
 */

/* $Revision: 1.1.6.1 $ */

static char rcsid[] = "$Id: hdfpt.c,v 1.1.6.1 2003/12/13 03:02:17 batserve Exp $";

#include <string.h>
#include <math.h>

/* Main HDF library header file */
#include "hdf.h"

/* MATLAB API header file */
#include "mex.h"

/* HDFMEX utility functions */
#include "hdfutils.h"

/* HDF-EOS header file */
#include "HdfEosDef.h"

#include "hdfpt.h"

#define SETUP 1

/*********************************************************
 *   Utility routines 
 *********************************************************/
 
/* 
 * GetFieldIndexFromList Returns the position of item in
 *                       the comma separated list
 */
static int32 GetFieldIndexFromList(char *item,const char *fieldlist)
{
    char *listcopy;
    char *s;
    int32 i;
    
    /* Make local copy of list since strtok changes it */
    listcopy = mxCalloc(strlen(fieldlist)+1,1);
    strcpy(listcopy,fieldlist);
    
    s = strtok(listcopy,",");
    i = 0;
    while (s != NULL)
    {
    	if (strcmp(item,s)==0)
    	   break;
    	s = strtok(NULL,",");
    	i++;
    }
    
    mxFree(listcopy);
    
    if (s != NULL)
	return i;
    else
	return FAIL;
}

/*
 * GetNumFields Returns the number of fields in the list
 */
static int32 GetNumFields(const char *fieldlist)
{
    int k;
    int32 numcommas = 0;
    int32 numfields;
    int len;
    
    /* 
     * How many fields are in the field list?  Add 1 to the number 
     * of commas that we find.
     */
    len = strlen(fieldlist);
    for (k = 0; k < len; k++)
    {
        if (fieldlist[k] == ',')
        {
            numcommas++;
        }
    }
    numfields = numcommas + 1;
    
    return numfields;
}

/*
 * LevelInfoFromList Returns number of fields in fieldslist or FAIL.
 *
 * INPUTS: pointid
 *         level
 *         fieldlist
 * OUTPUTS: fieldtype must be at least as big as the number of fields in fieldlist
 *          fieldorder must be at least as big as the number of fields in the fieldlist
 */
static int32 LevelinfoFromList(
	int32 pointid, 
	int32 level, 
	const char *fieldlist, 
	int32 *fieldtype, 
	int32 *fieldorder
    )
{
    intn status;
    int32 numfields;
    int32 allfields;
    int32 *allfieldtype = NULL;
    int32 *allfieldorder = NULL;
    char *allfieldlist = NULL;
    int32 *fieldlevel = NULL;
    int32 *records = NULL;
    int32 strbufsize;
    VOIDP data = NULL;
    int i;
    int k;
    char *s1,*s2;
    int foundit;
    const char *items;
    const char *list;
    int item_len, list_len;
    
    
    /* Count the number of fields in fieldlist */
    numfields = GetNumFields(fieldlist);
    
    allfields = PTnfields(pointid, level, &strbufsize);
    status = (allfields == FAIL) ? FAIL : SUCCEED;
    if (status != FAIL)
    {
        allfieldtype = (int32 *) mxCalloc(allfields, sizeof(*allfieldtype));
        allfieldorder = (int32 *) mxCalloc(allfields, sizeof(*allfieldorder));
        allfieldlist = (char *) mxCalloc(strbufsize + 1, sizeof(*allfieldlist));
        allfields = PTlevelinfo(pointid, level, allfieldlist, allfieldtype, allfieldorder);
        status = (allfields == FAIL) ? FAIL : SUCCEED;
    }

    if (status != FAIL)
    {
	/* Determine the field info for the fields in fieldlist */
	items = fieldlist;
	i = 0;
	while (items != NULL)
	{
	    s1 = strchr(items,',');
	    if (s1 != NULL)
	        item_len = (s1 - items);
	    else
	    	item_len = strlen(items);
	    
	    /* Search for item in list */
	    list = allfieldlist;
	    k = 0;
	    foundit = 0;
	    while (list != NULL)
	    {
		s2 = strchr(list,',');
		if (s2 != NULL)
		    list_len = (s2 - list);
		else
		    list_len = strlen(list);
		    
		if (list_len == item_len && strncmp(list,items,item_len)==0)
		{
		    foundit = 1;
		    break;
		}
		k++;
		if (s2 != NULL)
		    list = s2 + 1;
		else
		    list = NULL;
	    }
	    
	    /* If a match was found update return arguments */
	    if (foundit)
	    {
	        fieldtype[i] = allfieldtype[k];
	        fieldorder[i] = allfieldorder[k];
	        i++;
	        if (s1 != NULL)
	            items = s1 + 1;
	        else
	            items = NULL;
	    }
	    else
	    {
	         numfields = FAIL;
	         break;
	     }
	}
    }
    else
    {
    	numfields = FAIL;
    }
    
    return numfields;
}

 /*******************************************************
  * hdf routines
  *******************************************************/
/*
 * hdfPTattach
 *
 * Purpose: gateway to PTattach()
 *          attaches to an existing point within the file.
 *
 * MATLAB usage:
 * point_id = hdf('PT', 'attach', ptfile_id, pointname)
 *            returns -1 on failure.
 */
static void hdfPTattach(int nlhs,
                        mxArray *plhs[],
                        int nrhs,
                        const mxArray *prhs[])
{
    int32 pointfile_id;
    char *pointname = NULL;
    int32 point_id;
    intn status;
    
    haNarginChk(4, 4, nrhs);
    haNargoutChk(0, 1, nlhs);
    
    pointfile_id = (int32) haGetNonNegativeDoubleScalar(prhs[2], "Point file ID");
    pointname = haGetString(prhs[3], "Point name");

    point_id = PTattach(pointfile_id, pointname);
    if (point_id != FAIL)
    {
        status = haAddIDToList(point_id, Point_ID_List);
        if (status == FAIL)
        {
            /* 
             * Couldn't add the point_id to the list.  This might
             * cause data loss later, so we don't allow it.
             */
            PTdetach(point_id);
            point_id = FAIL;
        }
    }

    plhs[0] = haCreateDoubleScalar(point_id);

    mxFree(pointname);
}

/*
 * hdfPTattrinfo
 *
 * Purpose: gateway to PTattrinfo()
 *          returns information about a point attribute
 *
 * MATLAB usage:
 * [numbertype, count, status] = hdf('PT','attrinfo',point_id,attr_name)
 */
static void hdfPTattrinfo(int nlhs,
                          mxArray *plhs[],
                          int nrhs,
                          const mxArray *prhs[])
{
    char *attr_name = NULL;
    int32 point_id;
    int32 number_type;
    int32 count;
    intn status;
    
    haNarginChk(4, 4, nrhs);
    haNargoutChk(0, 3, nlhs);

    point_id = (int32) haGetNonNegativeDoubleScalar(prhs[2], "Point ID");
    attr_name = haGetString(prhs[3], "Attribute name");
    
    status = PTattrinfo(point_id, attr_name, &number_type, &count);
    
    if (status == SUCCEED)
    {
        plhs[0] = mxCreateString(haGetNumberTypeString(number_type));
        
        if (nlhs > 1)
        {
            plhs[1] = haCreateDoubleScalar((double) count);
        }
        
        if (nlhs > 2)
        {
            plhs[2] = haCreateDoubleScalar((double) status);
        }
    }
    else
    {
        plhs[0] = EMPTYSTR;
        
        if (nlhs > 1)
        {
            plhs[1] = EMPTY;
        }
        
        if (nlhs > 2)
        {
            plhs[2] = haCreateDoubleScalar((double) status);
        }
    }

    if (attr_name != NULL)
    {
        mxFree(attr_name);
    }
}

/*
 * hdfPTbcklinkinfo
 *
 * Purpose: Gateway to PTbcklinkinfo()
 *          Returns the linkfield to the previous level
 *
 * MATLAB usage:
 * [linkfield,status] = hdf('PT','bcklinkinfo',pointid,level)
 */
static void hdfPTbcklinkinfo(int nlhs,
                                mxArray *plhs[],
                                int nrhs,
                                const mxArray *prhs[])
{
    int32 pointid;
    int32 level;
    char linkfield[FIELDNAMELENMAX];
    intn status;
    
    haNarginChk(4, 4, nrhs);
    haNargoutChk(0, 2, nlhs);
    
    pointid = (int32) haGetNonNegativeDoubleScalar(prhs[2], "Point identifier");
    level = (int32) haGetDoubleScalar(prhs[3], "Level");
    
    status = PTbcklinkinfo(pointid, level, linkfield);
    
    if (status != FAIL)
    {
        plhs[0] = mxCreateString(linkfield);
    }
    else
    {
        plhs[0] = EMPTY;
    }
    
    if (nlhs > 1)
    {
        plhs[1] = haCreateDoubleScalar((double) status);
    }
}

/*
 * hdfPTclose
 * 
 * Purpose: Gateway to the HDF-EOS Library function PTclose
 *          Closes file.
 *
 * MATLAB usage:
 *          status = hdf('PT', 'close', fid)
 *
 * Inputs:  fid       - File identifier
 *    
 * Outputs: status    - 0 if succeeded, -1 if failed.
 * 
 * Returns: none
 */
static void hdfPTclose(int nlhs,
                   mxArray *plhs[],
                   int nrhs,
                   const mxArray *prhs[])
{
    int32 fid;
    intn status;

    /* Argument checking */
    haNarginChk(3, 3, nrhs);
    haNargoutChk(0, 1, nlhs);
    
    /* Get data from MATLAB arrays */
    fid = (int32) haGetDoubleScalar(prhs[2], "File identifier");
    
    /* Call HDF-EOS library function, and output result */
    status = PTclose(fid);
    if (status == SUCCEED)
    {
        haDeleteIDFromList(fid, Pointfile_ID_List);
    }
    
    plhs[0] = haCreateDoubleScalar((double) status);
}

/*
 * hdfPTcreate
 *
 * Purpose: gateway to PTcreate()
 *          attaches to an existing point within the file.
 *
 * MATLAB usage:
 * point_id = hdf('PT', 'create', pointid, pointname)
 *            returns -1 on failure.
 */
static void hdfPTcreate(int nlhs,
                        mxArray *plhs[],
                        int nrhs,
                        const mxArray *prhs[])
{
    int32 pointfile_id;
    char *pointname = NULL;
    int32 point_id;
    intn status;
    
    haNarginChk(4, 4, nrhs);
    haNargoutChk(0, 1, nlhs);
    
    pointfile_id = (int32) haGetNonNegativeDoubleScalar(prhs[2], "Point file ID");
    pointname = haGetString(prhs[3], "Point name");

    point_id = PTcreate(pointfile_id, pointname);
    if (point_id != FAIL)
    {
        status = haAddIDToList(point_id, Point_ID_List);
        if (status == FAIL)
        {
            /* 
             * Couldn't add the point_id to the list.  This might
             * cause data loss later, so we don't allow it.
             */
            PTdetach(point_id);
            point_id = FAIL;
        }
    }

    plhs[0] = haCreateDoubleScalar(point_id);

    mxFree(pointname);
}


/*
 * hdfPTdefboxregion
 *
 * Purpose: gateway to PTdefboxregion()
 *          Defines a longitude-latitude box region for a point.
 *
 * MATLAB usage:
 *        regionid = hdf('PT','defboxregion',pointid,cornerlon,cornerlat)
 */
static void hdfPTdefboxregion(int nlhs,
                                 mxArray *plhs[],
                                 int nrhs,
                                 const mxArray *prhs[])
{
    int32 pointid;
    double *lon_ptr;
    double *lat_ptr;
    int32 regionid;
    
    haNarginChk(5, 5, nrhs);
    haNargoutChk(0, 1, nlhs);
    
    pointid = (int32) haGetNonNegativeDoubleScalar(prhs[2], "Point identifier");
    if (!mxIsDouble(prhs[3]) || (mxGetNumberOfElements(prhs[3]) != 2))
    {
        mexErrMsgTxt("CORNERLON must be a 2-element double vector.");
    }
    if (!mxIsDouble(prhs[4]) || (mxGetNumberOfElements(prhs[4]) != 2))
    {
        mexErrMsgTxt("CORNERLAT must be a 2-element double vector.");
    }

    lon_ptr = mxGetPr(prhs[3]);
    lat_ptr = mxGetPr(prhs[4]);
    
    regionid = PTdefboxregion(pointid, lon_ptr, lat_ptr);
    
    plhs[0] = haCreateDoubleScalar((double) regionid);
}

/*
 * hdfPTdeflevel
 *
 * Purpose: gateway to PTdeflevel()
 *          Defines a new level within the point
 *
 * MATLAB usage:
 * status = hdf('PT','deflevel',pointid,levelname,fieldlist,fieldtypes,fieldorders)
 */
static void hdfPTdeflevel(int nlhs,
                             mxArray *plhs[],
                             int nrhs,
                             const mxArray *prhs[])
{
    int32 pointid;
    char *levelname = NULL;
    char *fieldlist = NULL;
    int32 *fieldtype = NULL;
    int32 *fieldorder = NULL;
    int num_fields;
    intn status;
    double *real_ptr;
    int k;
    
    haNarginChk(7, 7, nrhs);
    haNargoutChk(0, 1, nlhs);
    
    pointid = (int32) haGetNonNegativeDoubleScalar(prhs[2],"Point identifier");
    levelname = haGetString(prhs[3], "Level name");
    fieldlist = haGetString(prhs[4], "Field list");

    if (!mxIsCell(prhs[5]))
    {
        mexErrMsgTxt("Fieldtypes must be a cell array of strings.");
    }
    num_fields = mxGetNumberOfElements(prhs[5]);
    if (num_fields < 1)
    {
        mexErrMsgTxt("Fieldtypes cannot be empty.");
    }
    
    fieldtype = (int32 *) mxCalloc(num_fields, sizeof(*fieldtype));
    
    if (!mxIsDouble(prhs[6]))
    {
        mexErrMsgTxt("fieldorder must be a double vector.");
    }
    if (mxGetNumberOfElements(prhs[6]) != num_fields)
    {
        mexErrMsgTxt("Fieldorder must be the same length as fieldtypes.");
    }
    
    fieldorder = (int32 *) mxCalloc(num_fields, sizeof(*fieldorder));
    real_ptr = mxGetPr(prhs[6]);
    for (k = 0; k < num_fields; k++)
    {
        fieldtype[k] = haGetDataType(mxGetCell(prhs[5], k));
        fieldorder[k] = (int32) real_ptr[k];
    }
    
    status = PTdeflevel(pointid,levelname,fieldlist,fieldtype,fieldorder);
    plhs[0] = haCreateDoubleScalar((double) status);

    if (levelname != NULL)
    {
        mxFree(levelname);
    }
    if (fieldlist != NULL)
    {
        mxFree(fieldlist);
    }
}

/*
 * hdfPTdeflinkage
 *
 * Purpose: gateway to PTdeflinkage()
 *          Defines a linkfield between two (adjacent) levels
 *
 * MATLAB usage:
 * status = hdf('PT','deflinkage',pointid,parent,child,linkfield)
 */
static void hdfPTdeflinkage(int nlhs,
                               mxArray *plhs[],
                               int nrhs,
                               const mxArray *prhs[])
{
    int32 pointid;
    char *parent = NULL;
    char *child = NULL;
    char *linkfield = NULL;
    intn status;
    
    haNarginChk(6, 6, nrhs);
    haNargoutChk(0, 1, nlhs);
    
    pointid = (int32) haGetNonNegativeDoubleScalar(prhs[2], "Point identifier");
    parent = haGetString(prhs[3], "Parent");
    child = haGetString(prhs[4], "Child");
    linkfield = haGetString(prhs[5], "Linkfield");
    
    status = PTdeflinkage(pointid,parent,child,linkfield);
    
    plhs[0] = haCreateDoubleScalar((double) status);
    
    if (parent != NULL)
    {
        mxFree(parent);
    }
    if (child != NULL)
    {
        mxFree(child);
    }
    if (linkfield != NULL)
    {
        mxFree(linkfield);
    }
}

/*
 * hdfPTdeftimeperiod
 *
 * Purpose: gateway to PTdeftimeperiod()
 *          Defines a time period for a point
 *
 * MATLAB usage:
 * periodid = hdf('PT','deftimeperiod',pointid,starttime,stoptime)
 */
static void hdfPTdeftimeperiod(int nlhs,
                                  mxArray *plhs[],
                                  int nrhs,
                                  const mxArray *prhs[])
{
    float64 starttime;
    float64 stoptime;
    int32 periodid;
    int32 pointid;
    
    haNarginChk(5, 5, nrhs);
    haNargoutChk(0, 1, nlhs);

    pointid = (int32) haGetNonNegativeDoubleScalar(prhs[2], "Point identifier");
    starttime = haGetDoubleScalar(prhs[3], "Start time");
    stoptime = haGetDoubleScalar(prhs[4], "Stop time");
    
    periodid = PTdeftimeperiod(pointid,starttime,stoptime);
    
    plhs[0] = haCreateDoubleScalar((double) periodid);
}


/*
 * hdfPTdefvrtregion
 *
 * Purpose: gateway to PTdefvrtregion()
 *          Defines a vertical region for a point
 *
 * MATLAB usage:
 * periodid = hdf('PT','PTdefvrtregion',pointid,regionid,fieldname,range)
 */
static void hdfPTdefvrtregion(int nlhs,
                                  mxArray *plhs[],
                                  int nrhs,
                                  const mxArray *prhs[])
{
    int32 pointid;
    int32 regionid;
    char *fieldname;
    double *range_ptr;
    int32 periodid;
    
    haNarginChk(6, 6, nrhs);
    haNargoutChk(0, 1, nlhs);

    pointid = (int32) haGetNonNegativeDoubleScalar(prhs[2], "Point identifier");
    regionid = haGetDoubleScalar(prhs[3], "Region identifier");
    fieldname = haGetString(prhs[4], "Field name");
    
    if (!mxIsDouble(prhs[5]) || (mxGetNumberOfElements(prhs[5]) != 2))
    {
        mexErrMsgTxt("RANGE must be a 2-element double vector.");
    }
    range_ptr = mxGetPr(prhs[5]);
    
    periodid = PTdefvrtregion(pointid,regionid,fieldname,range_ptr);
    
    plhs[0] = haCreateDoubleScalar((double) periodid);

    mxFree(fieldname);
}


/*
 * hdfPTdetach
 * 
 * Purpose: Gateway to the HDF-EOS Library function PTdetach
 *          Detaches from Point data set.
 *
 * MATLAB usage:
 *          status = hdf('PT', 'detach', pointid)
 *
 * Inputs:  pointid   - Point id returned by PTcreate or PTattach
 *    
 * Outputs: status    - 0 if succeeded, -1 if failed.
 * 
 * Returns: none
 */
static void hdfPTdetach(int nlhs,
                    mxArray *plhs[],
                    int nrhs,
                    const mxArray *prhs[])
{
    int32 pointid;
    int status;
    
    /* Argument checking */
    haNarginChk(3, 3, nrhs);
    haNargoutChk(0, 1, nlhs);
    
    /* Get data from MATLAB arrays */
    pointid = (int32) haGetNonNegativeDoubleScalar(prhs[2], "Point identifier");
    
    /* Call HDF-EOS library function, and output result */
    status = PTdetach(pointid);
    if (status == SUCCEED)
    {
        haDeleteIDFromList(pointid, Point_ID_List);
    }
    plhs[0] = haCreateDoubleScalar((double) status);
}

/*
 * hdfPTextractperiod
 *
 * Purpose: gateway to PTextractperiod()
 *          Reads data from subsetted time period
 *
 * MATLAB usage:
 * [data,status] = hdf('PT','extractperiod',pointid,periodid,...
 *                 level,fieldlist)
 *    Data is returned in a nfields-by-1 cell array.  Each
 *    cell will contain a order(i)-by-n vector of data where order(i) 
 *    is the field order and n is the number of records.
 */
static void hdfPTextractperiod(int nlhs,
                                  mxArray *plhs[],
                                  int nrhs,
                                  const mxArray *prhs[])
{
    int32 pointid;
    int32 periodid;
    int32 level;
    intn status;
    int32 numfields = 0;
    int32 *fieldtype = NULL;
    int32 *fieldorder = NULL;
    char *fieldlist = NULL;
    int32 *fieldlevel = NULL;
    int32 strbufsize;
    mxArray *cellarray = NULL;
    VOIDP data = NULL;
    VOIDP *bufptrs = NULL;
    int i;
    int32 fieldbytes;
    int32 bytes_per_record;
    int32 offset;
    int32 numrecords;
    int32 this_data_type;
    bool ok2free = false;
    
    haNarginChk(6, 6, nrhs);
    haNargoutChk(0, 2, nlhs);
    
    pointid = (int32) haGetNonNegativeDoubleScalar(prhs[2], "Point identifier");
    periodid = (int32) haGetNonNegativeDoubleScalar(prhs[3], "Period identifier");
    level = (int32) haGetDoubleScalar(prhs[4], "Level");
    fieldlist = haGetString(prhs[5], "Field list");

    /*
     * How many records are in the subsetted period?
     */
    status = PTperiodrecs(pointid, periodid, level, &numrecords, NULL);
    
    /*
     * Find out how many fields there are, plus the number
     * type and order of each field.
     */
    if (status != FAIL)
    {
        numfields = PTnfields(pointid, level, &strbufsize);
        status = (numfields == FAIL) ? FAIL : SUCCEED;
        if (status != FAIL)
        {
            fieldtype = (int32 *) mxCalloc(numfields, sizeof(*fieldtype));
            fieldorder = (int32 *) mxCalloc(numfields, sizeof(*fieldorder));
            numfields = LevelinfoFromList(pointid, level, fieldlist, fieldtype, 
                                fieldorder);
            status = (numfields == FAIL) ? FAIL : SUCCEED;
        }
    }   

    /* 
     * Determine size of required data buffer 
     */
    if (status != FAIL)
    {
        cellarray = mxCreateCellMatrix(numfields, 1);
        fieldlevel = (int32 *) mxCalloc(numfields, sizeof(*fieldlevel));
        for (i = 0; i < numfields; i++)
        {
            fieldlevel[i] = level;
        }
        bytes_per_record = PTsizeof(pointid, fieldlist, fieldlevel);
        status = (bytes_per_record == FAIL) ? FAIL : SUCCEED;
    }
    
    /*
     * Create buffers and read in data
     */
    if (status != FAIL)
    {
        data = (VOIDP) mxCalloc(bytes_per_record * numrecords, 1);
        bufptrs = (VOIDP *) mxCalloc(numfields, sizeof(VOIDP));
        
        for (i = 0; i < numfields; i++)
        {
            this_data_type = fieldtype[i];
            bufptrs[i] = haMakeHDFDataBuffer(fieldorder[i] * numrecords, 
                                             this_data_type);
        }

        status = PTextractperiod(pointid, periodid, level, fieldlist, data);
    }

    /* 
     * Unpack data buffer and make cells of cell array
     */
    if (status != FAIL)
    {
        offset = 0;
        for (i = 0; i < numfields; i++)
        {
            fieldbytes = numrecords * fieldorder[i] * 
                haGetDataTypeSize(fieldtype[i]);
            memcpy(bufptrs[i], (void *) ((char *) data + offset), fieldbytes);
            offset += fieldbytes;
        }

        for (i = 0; i < numfields; i++)
        {
            int ndims = 2;
            int siz[2];
            siz[0] = fieldorder[i];
            siz[1] = numrecords;
            mxSetCell(cellarray, i,
                      haMakeArrayFromHDFDataBuffer(ndims, siz,
                                                   fieldtype[i], bufptrs[i],
                                                   &ok2free));
            if (ok2free)
            {
                mxFree(bufptrs[i]);
            }
        }
    }

    if (status == FAIL)
    {
        plhs[0] = EMPTY;
    }
    else
    {
        plhs[0] = cellarray;
    }
    
    if (nlhs > 1)
    {
        plhs[1] = haCreateDoubleScalar((double) status);
    }

    if (fieldtype != NULL)
    {
        mxFree(fieldtype);
    }
    if (fieldorder != NULL)
    {
        mxFree(fieldorder);
    }
    if (fieldlist != NULL)
    {
        mxFree(fieldlist);
    }
    if (bufptrs != NULL)
    {
        mxFree(bufptrs);
    }
    if (data != NULL)
    {
    	mxFree(data);
    }
    if ((status == FAIL) && (cellarray != NULL))
    {
        mxDestroyArray(cellarray);
    }
}

/*
 * hdfPTextractregion
 *
 * Purpose: gateway to PTextractregion()
 *          Reads data from subsetted area of interest
 *
 * MATLAB usage:
 * [data,status] = hdf('PT','extractregion',pointid,regionid,...
 *                 level,fieldlist)
 *    Data is returned in a nfields-by-1 cell array.  Each
 *    cell will contain a order(i)-by-n vector of data where order(i) 
 *    is the field order and n is the number of records.
 */
static void hdfPTextractregion(int nlhs,
                                  mxArray *plhs[],
                                  int nrhs,
                                  const mxArray *prhs[])
{
    int32 pointid;
    int32 regionid;
    int32 level;
    intn status;
    int32 numfields;
    int32 *fieldtype = NULL;
    int32 *fieldorder = NULL;
    char *fieldlist = NULL;
    int32 *fieldlevel = NULL;
    int32 strbufsize;
    mxArray *cellarray = NULL;
    VOIDP data = NULL;
    VOIDP *bufptrs = NULL;
    int i,j;
    int32 fieldbytes;
    int32 bytes_per_record;
    int32 offset;
    int32 numrecords;
    int32 this_data_type;
    bool ok2free = false;
    
    haNarginChk(6, 6, nrhs);
    haNargoutChk(0, 2, nlhs);
    
    pointid = (int32) haGetNonNegativeDoubleScalar(prhs[2], "Point identifier");
    regionid = (int32) haGetNonNegativeDoubleScalar(prhs[3], "Region identifier");
    level = (int32) haGetDoubleScalar(prhs[4], "Level");
    fieldlist = haGetString(prhs[5], "Field list");

    /*
     * How many records are in the subsetted period?
     */
    status = PTregionrecs(pointid, regionid, level, &numrecords, NULL);
    
    /*
     * Find out how many fields there are, plus the number
     * type and order of each field.
     */
    if (status != FAIL)
    {
        numfields = PTnfields(pointid, level, &strbufsize);
        status = (numfields == FAIL) ? FAIL : SUCCEED;
        if (status != FAIL)
        {
            fieldtype = (int32 *) mxCalloc(numfields, sizeof(*fieldtype));
            fieldorder = (int32 *) mxCalloc(numfields, sizeof(*fieldorder));
            numfields = LevelinfoFromList(pointid, level, fieldlist, fieldtype, 
                                fieldorder);
            status = (numfields == FAIL) ? FAIL : SUCCEED;
        }
    }
    
    /* 
     * Determine size of required data buffer 
     */
    if (status != FAIL)
    {
        cellarray = mxCreateCellMatrix(numfields, 1);
        fieldlevel = (int32 *) mxCalloc(numfields, sizeof(*fieldlevel));
        for (i = 0; i < numfields; i++)
        {
            fieldlevel[i] = level;
        }
        bytes_per_record = PTsizeof(pointid, fieldlist, fieldlevel);
        status = (bytes_per_record == FAIL) ? FAIL : SUCCEED;
    }
    
    /*
     * Create buffers and read in data
     */
    if (status != FAIL)
    {
        data = (VOIDP) mxCalloc(bytes_per_record * numrecords, 1);
        bufptrs = (VOIDP *) mxCalloc(numfields, sizeof(VOIDP));
        
        for (i = 0; i < numfields; i++)
        {
            this_data_type = fieldtype[i];
            bufptrs[i] = haMakeHDFDataBuffer(fieldorder[i] * numrecords, 
                                             this_data_type);
        }

        status = PTextractregion(pointid, regionid, level, fieldlist, data);
    }

    /* 
     * Unpack data buffer and make cells of cell array
     */
    if (status != FAIL)
    {
        offset = 0;
        for (j = 0; j < numrecords; j++)
        {
            for (i = 0; i < numfields; i++)
            {
                fieldbytes = fieldorder[i] * haGetDataTypeSize(fieldtype[i]);
                memcpy((void *) ((char *) bufptrs[i] + fieldbytes*j), 
                       (void *) ((char *) data + offset), fieldbytes);
                offset += fieldbytes;
            }
        }

        for (i = 0; i < numfields; i++)
        {
            int ndims = 2;
            int siz[2];
            siz[0] = fieldorder[i];
            siz[1] = numrecords;
            mxSetCell(cellarray, i,
                      haMakeArrayFromHDFDataBuffer(ndims, siz,
                                                   fieldtype[i], bufptrs[i],
                                                   &ok2free));
            if (ok2free)
            {
                mxFree(bufptrs[i]);
            }
        }
    }

    if (status == FAIL)
    {
        plhs[0] = EMPTY;
    }
    else
    {
        plhs[0] = cellarray;
    }
    
    if (nlhs > 1)
    {
        plhs[1] = haCreateDoubleScalar((double) status);
    }

    if (fieldtype != NULL)
    {
        mxFree(fieldtype);
    }
    if (fieldorder != NULL)
    {
        mxFree(fieldorder);
    }
    if (fieldlist != NULL)
    {
        mxFree(fieldlist);
    }
    if (bufptrs != NULL)
    {
        mxFree(bufptrs);
    }
    if (data != NULL)
    {
    	mxFree(data);
    }
    if ((status == FAIL) && (cellarray != NULL))
    {
        mxDestroyArray(cellarray);
    }
}

/*
 * hdfPTfwdlinkinfo
 *
 * Purpose: Gateway to PTfwdlinkinfo()
 *          Returns the linkfield to the following level
 *
 * MATLAB usage:
 * [linkfield,status] = hdf('PT','fwdlinkinfo',pointid,level)
 */
static void hdfPTfwdlinkinfo(int nlhs,
                                mxArray *plhs[],
                                int nrhs,
                                const mxArray *prhs[])
{
    int32 pointid;
    int32 level;
    char linkfield[FIELDNAMELENMAX];
    intn status;
    
    haNarginChk(4, 4, nrhs);
    haNargoutChk(0, 2, nlhs);
    
    pointid = (int32) haGetNonNegativeDoubleScalar(prhs[2], "Point identifier");
    level = (int32) haGetDoubleScalar(prhs[3], "Level");
    
    status = PTfwdlinkinfo(pointid, level, linkfield);
    
    if (status != FAIL)
    {
        plhs[0] = mxCreateString(linkfield);
    }
    else
    {
        plhs[0] = EMPTY;
    }
    
    if (nlhs > 1)
    {
        plhs[1] = haCreateDoubleScalar((double) status);
    }
}

/*
 * hdfPTgetlevelname
 *
 * Purpose: gateway to PTgetlevelname()
 *          Returns the name of a level given the level number
 *
 * MATLAB usage:
 * [levelname,status] = hdf('PT','getlevelname',pointid,level)
 */
static void hdfPTgetlevelname(int nlhs,
                              mxArray *plhs[],
                              int nrhs,
                              const mxArray *prhs[])
{
    int32 pointid;
    int32 level;
    char *levelname = NULL;
    intn status;
    int32 strbufsize;
    
    haNarginChk(4, 4, nrhs);
    haNargoutChk(0, 2, nlhs);
    
    pointid = (int32) haGetNonNegativeDoubleScalar(prhs[2], "Point identifier");
    level = (int32) haGetDoubleScalar(prhs[3], "Level");
    
    /* How long is the level name? */
    status = PTgetlevelname(pointid,level,NULL,&strbufsize);
    
    /* Allocate space for and get the level name */
    if (status != FAIL)
    {
        levelname = mxCalloc(strbufsize + 1, sizeof(*levelname));
        status = PTgetlevelname(pointid,level,levelname,&strbufsize);
    }
    
    if (status == FAIL)
    {
        plhs[0] = EMPTY;
    }
    else
    {
        plhs[0] = mxCreateString(levelname);
    }
    
    if (nlhs > 1)
    {
        plhs[1] = haCreateDoubleScalar((double) status);
    }
    
    if (levelname != NULL)
    {
        mxFree(levelname);
    }
}

/*
 * hdfPTgetrecnums
 *
 * Purpose: gateway to PTgetrecnums()
 *          Returns the record numbers in one level corresponding to 
 *          a group of records in a different levels
 *
 * MATLAB usage:
 * [outrecords,status] = hdf('PT','getrecnums',pointid,inlevel,...
 *                           outlevel,inrecords)
 */
static void hdfPTgetrecnums(int nlhs,
                               mxArray *plhs[],
                               int nrhs,
                               const mxArray *prhs[])
{
    int32 pointid;
    int32 inlevel;
    int32 outlevel;
    int32 num_in_records;
    int32 num_out_records;
    int32 numrecords;
    int32 *inrecords = NULL;
    int32 *outrecords = NULL;
    intn status;
    double *real_ptr;
    int i;

    haNarginChk(6, 6, nrhs);
    haNargoutChk(0, 2, nlhs);

    pointid = (int32) haGetNonNegativeDoubleScalar(prhs[2], "Point identifier");
    inlevel = (int32) haGetDoubleScalar(prhs[3], "Input level");
    outlevel = (int32) haGetDoubleScalar(prhs[4], "Output level");

    if (!mxIsDouble(prhs[5]))
    {
        mexErrMsgTxt("INRECORDS must be a double vector.");
    }
    num_in_records = mxGetNumberOfElements(prhs[5]);
    inrecords = (int32 *) mxCalloc(num_in_records, sizeof(*inrecords));
    real_ptr = mxGetPr(prhs[5]);
    for (i = 0; i < num_in_records; i++)
    {
        inrecords[i] = (int32) real_ptr[i];
    }

    numrecords = PTnrecs(pointid,outlevel);
    status = (numrecords == FAIL) ? FAIL : SUCCEED;
    
    if (status != FAIL)
    {
        outrecords = (int32 *) mxCalloc(numrecords, sizeof(*outrecords));
        status = PTgetrecnums(pointid, inlevel, outlevel, num_in_records,
                              inrecords, &num_out_records, outrecords);
    }
    
    if (status != FAIL)
    {
        plhs[0] = mxCreateDoubleMatrix(1, num_out_records, mxREAL);
        real_ptr = mxGetPr(plhs[0]);
        for (i = 0; i < num_out_records; i++)
        {
            real_ptr[i] = (double) outrecords[i];
        }
    }
    else
    {
        plhs[0] = EMPTY;
    }
    
    if (nlhs > 1)
    {
        plhs[1] = haCreateDoubleScalar((double) status);
    }

    if (inrecords != NULL)
    {
        mxFree(inrecords);
    }
    if (outrecords != NULL)
    {
        mxFree(outrecords);
    }
}

/*
 * hdfPTinqattrs
 *
 * Purpose: gateway to PTinqattrs()
 *          Retrieve information about attributes defined in a point
 *
 * MATLAB usage:
 * [nattrs,attrnames] = hdf('PT','inqattrs',pointid)
 */
static void hdfPTinqattrs(int nlhs,
                             mxArray *plhs[],
                             int nrhs,
                             const mxArray *prhs[])
{
    int32 pointid;
    int32 nattrs;
    char *attrnames = NULL;
    int32 strbufsize = 0;
    
    haNarginChk(3, 3, nrhs);
    haNargoutChk(0, 2, nlhs);
    
    pointid = (int32) haGetNonNegativeDoubleScalar(prhs[2], "Point identifier");
    
    /* How long is the attribute name list? */
    nattrs = PTinqattrs(pointid, NULL, &strbufsize);
    
    /* Allocate space for the attribute name list and get it */
    if (nattrs != FAIL)
    {
        attrnames = (char *) mxCalloc(strbufsize + 1, sizeof(*attrnames));
        nattrs = PTinqattrs(pointid, attrnames, &strbufsize);
    }
    
    plhs[0] = haCreateDoubleScalar((double) nattrs);
    
    if (nlhs > 1)
    {
        if (nattrs == FAIL)
        {
            plhs[1] = EMPTY;
        }
        else
        {
            plhs[1] = mxCreateString(attrnames);
        }
    }
    
    if (attrnames != NULL)
    {
        mxFree(attrnames);
    }
}

/*
 * hdfPTinqpoint
 *
 * Purpose: gateway to PTinqpoint()
 *          Retrieves number and names of points defined in HDF-EOS file
 *
 * MATLAB usage:
 * [numpoints,pointnames] = hdf('PT','inqpoint',filename)
 */
static void hdfPTinqpoint(int nlhs,
                             mxArray *plhs[],
                             int nrhs,
                             const mxArray *prhs[])
{
    int32 numpoints;
    char *filename = NULL;
    char *pointnames = NULL;
    int32 strbufsize;
    
    haNarginChk(3, 3, nrhs);
    haNargoutChk(0, 2, nlhs);
    
    filename = haGetString(prhs[2], "Filename");
    
    /* How big is the pointname list? */
    numpoints = PTinqpoint(filename, NULL, &strbufsize);
    
    /* Allocate space for the pointname list and get it */
    if (numpoints != FAIL)
    {
        pointnames = (char *) mxCalloc(strbufsize + 1, sizeof(*pointnames));
        numpoints = PTinqpoint(filename, pointnames, &strbufsize);
    }
    
    plhs[0] = haCreateDoubleScalar((double) numpoints);
    
    if (nlhs > 1)
    {
        if (numpoints == FAIL)
        {
            plhs[1] = EMPTY;
        }
        else
        {
            plhs[1] = mxCreateString(pointnames);
        }
    }
    
    if (filename != NULL)
    {
        mxFree(filename);
    }
    if (pointnames != NULL)
    {
        mxFree(pointnames);
    }
}

/*
 * hdfPTlevelindx
 *
 * Purpose: gateway to PTlevelindx()
 *          Returns the level index for a given level
 *
 * MATLAB usage:
 * level = hdf('PT','levelindx',pointid,levelname)
 */
static void hdfPTlevelindx(int nlhs,
                              mxArray *plhs[],
                              int nrhs,
                              const mxArray *prhs[])
{
    int32 pointid;
    char *levelname = NULL;
    int32 level;

    haNarginChk(4, 4, nrhs);
    haNargoutChk(0, 1, nlhs);
    
    pointid = (int32) haGetNonNegativeDoubleScalar(prhs[2], "Point identifier");
    levelname = haGetString(prhs[3], "Level name");
    level = PTlevelindx(pointid,levelname);
    plhs[0] = haCreateDoubleScalar((double) level);

    if (levelname != NULL)
    {
        mxFree(levelname);
    }
}


/*
 * hdfPTlevelinfo
 *
 * Purpose: gateway to PTlevelinfo()
 *          Returns information on fields in a given level.
 *
 * MATLAB usage:
 * [numfields,fieldlist,fieldtype,fieldorder] = hdf('PT','levelinfo',...
 *                      pointid,level)
 */
static void hdfPTlevelinfo(int nlhs,
                              mxArray *plhs[],
                              int nrhs,
                              const mxArray *prhs[])
{
    int32 pointid;
    int32 level;
    char *fieldlist = NULL;
    int32 *fieldtype = NULL;
    int32 *fieldorder = NULL;
    int32 numfields;
    int32 strbufsize;
    intn status;
    double *real_ptr;
    int k;
    
    haNarginChk(4, 4, nrhs);
    haNargoutChk(0, 4, nlhs);
    
    pointid = (int32) haGetNonNegativeDoubleScalar(prhs[2], "Point identifier");
    level = (int32) haGetDoubleScalar(prhs[3], "Level");

    /* How many fields are there, and how big is the field list? */
    numfields = PTnfields(pointid,level,&strbufsize);
    status = (numfields < 0) ? FAIL : SUCCEED;

    /* Allocate space for the outputs and get info */
    if (status != FAIL)
    {
        fieldlist = (char *) mxCalloc(strbufsize + 1, sizeof(*fieldlist));
        fieldtype = (int32 *) mxCalloc(numfields, sizeof(*fieldtype));
        fieldorder = (int32 *) mxCalloc(numfields, sizeof(*fieldorder));
        numfields = PTlevelinfo(pointid,level,fieldlist,fieldtype,fieldorder);
        status = (numfields == FAIL) ? FAIL : SUCCEED;
    }
    
    /* Output arguments */
    plhs[0] = haCreateDoubleScalar((double) numfields);

    if (nlhs > 1)
    {
        if (status == FAIL)
        {
            plhs[1] = EMPTY;
        }
        else
        {
            plhs[1] = mxCreateString(fieldlist);
        }
    }
    
    if (nlhs > 2)
    {
        if (status == FAIL)
        {
            plhs[2] = EMPTY;
        }
        else
        {
            plhs[2] = haGenerateNumberTypeArray(numfields, fieldtype);
        }
    }
    
    if (nlhs > 3)
    {
        if (status == FAIL)
        {
            plhs[3] = EMPTY;
        }
        else
        {
            plhs[3] = mxCreateDoubleMatrix(1, numfields, mxREAL);
            real_ptr = mxGetPr(plhs[3]);
            for (k = 0; k < numfields; k++)
            {
                real_ptr[k] = (double) fieldorder[k];
            }
        }
    }
    
    /* Clean up */
    if (fieldlist != NULL)
    {
        mxFree(fieldlist);
    }
    if (fieldtype != NULL)
    {
        mxFree(fieldtype);
    }
    if (fieldorder != NULL)
    {
        mxFree(fieldorder);
    }
}

/*
 * hdfPTopen
 *
 * Purpose: gateway to PTopen()
 *          opens or creates HDF file
 *
 * MATLAB usage:
 * fileid = hdf('PT', 'open', filename, access)
 *          access can be 'read', 'readwrite', or 'create'
 *
 */
static void hdfPTopen(int nlhs,
                      mxArray *plhs[],
                      int nrhs,
                      const mxArray *prhs[])
{
    intn access;
    char *filename;
    int32 fileid;
    intn status;

    haNarginChk(4, 4, nrhs);
    haNargoutChk(0, 1, nlhs);
    
    filename = haGetString(prhs[2], "Filename");
    access = haGetAccessMode(prhs[3]);
    
    fileid = PTopen(filename, access);
    if (fileid != FAIL)
    {
        status = haAddIDToList(fileid, Pointfile_ID_List);
        if (status == FAIL)
        {
            /* 
             * Couldn't add the file_id to the list.  This might
             * cause data loss later, so we don't allow it.
             */
            PTclose(fileid);
            fileid = FAIL;
        }
    }
    
    plhs[0] = haCreateDoubleScalar((double) fileid);
    
    mxFree(filename);
}

/*
 * hdfPTnfields
 *
 * Purpose: gateway to PTnfields()
 *          Returns number of fields in a level and the size of the
 *          fieldlist.
 *
 * MATLAB usage:
 * [numfields,strbufsize] = hdf('PT','nfields',pointid,level)
 */
static void hdfPTnfields(int nlhs,
                            mxArray *plhs[],
                            int nrhs,
                            const mxArray *prhs[])
{
    int32 pointid;
    int32 level;
    int32 numfields;
    int32 strbufsize;
    
    haNarginChk(4, 4, nrhs);
    haNargoutChk(0, 2, nlhs);
    
    pointid = (int32) haGetNonNegativeDoubleScalar(prhs[2], "Point identifier");
    level = (int32) haGetDoubleScalar(prhs[3], "Level");
    
    numfields = PTnfields(pointid, level, &strbufsize);
    
    plhs[0] = haCreateDoubleScalar((double) numfields);
    if (nlhs > 1)
    {
        if (numfields == FAIL)
        {
            plhs[1] = EMPTY;
        }
        else
        {
            plhs[1] = haCreateDoubleScalar((double) strbufsize);
        }
    }
}
    
/*
 * hdfPTnlevels
 * 
 * Purpose: gateway to PTnlevels()
 *          Returns number of levels in a point.
 *
 * MATLAB usage:
 * nlevels = hdf('PT','nlevels',pointid)
 */
static void hdfPTnlevels(int nlhs,
                            mxArray *plhs[],
                            int nrhs,
                            const mxArray *prhs[])
{
    int32 pointid;
    int32 nlevels;
    
    haNarginChk(3, 3, nrhs);
    haNargoutChk(0, 1, nlhs);
    
    pointid = (int32) haGetNonNegativeDoubleScalar(prhs[2], "Point identifier");
    nlevels = PTnlevels(pointid);
    plhs[0] = haCreateDoubleScalar((double) nlevels);
}

/*
 * hdfPTnrecs
 * 
 * Purpose: gateway to PTnrecs()
 *          Returns number of records in a given level
 *
 * MATLAB usage:
 * nrecs = hdf('PT','nrecs',pointid,level)
 */
static void hdfPTnrecs(int nlhs,
                          mxArray *plhs[],
                          int nrhs,
                          const mxArray *prhs[])
{
    int32 pointid;
    int32 level;
    int32 nrecs;
    
    haNarginChk(4, 4, nrhs);
    haNargoutChk(0, 1, nlhs);
    
    pointid = (int32) haGetNonNegativeDoubleScalar(prhs[2], "Point identifier");
    level = (int32) haGetDoubleScalar(prhs[3], "Level");
    nrecs = PTnrecs(pointid,level);
    plhs[0] = haCreateDoubleScalar((double) nrecs);
}

/*
 * hdfPTperiodinfo
 *
 * Purpose: gateway to PTperiodinfo()
 *          Retrieves size in bytes of subsetted period
 *
 * MATLAB usage:
 * [bytesize,status] = hdf('PT','periodinfo',pointid,periodid,level,fieldlist)
 */
static void hdfPTperiodinfo(int nlhs,
                               mxArray *plhs[],
                               int nrhs,
                               const mxArray *prhs[])
{
    int32 pointid;
    int32 periodid;
    int32 level;
    char *fieldlist = NULL;
    int32 bytesize;
    intn status;
    
    haNarginChk(6, 6, nrhs);
    haNargoutChk(0, 2, nlhs);
    
    pointid = (int32) haGetNonNegativeDoubleScalar(prhs[2], "Point identifier");
    periodid = (int32) haGetNonNegativeDoubleScalar(prhs[3], "Period identifier");
    level = (int32) haGetDoubleScalar(prhs[4], "Level");
    fieldlist = haGetString(prhs[5], "Field list");
    
    status = PTperiodinfo(pointid, periodid, level, fieldlist, &bytesize);
    
    if (status == FAIL)
    {
        plhs[0] = haCreateDoubleScalar((double) FAIL);
    }
    else
    {
        plhs[0] = haCreateDoubleScalar((double) bytesize);
    }
    if (nlhs > 1)
    	plhs[1] = haCreateDoubleScalar((double) status);
    
    if (fieldlist != NULL)
    {
        mxFree(fieldlist);
    }
}

/*
 * hdfPTperiodrecs
 *
 * Purpose: gateway to PTperiodrecs()
 *          Retrieves record numbers within period in level
 *
 * MATLAB usage:
 * [numrecs,recnumbers,status] = hdf('PT','periodrecs',pointid,periodid,level)
 */
static void hdfPTperiodrecs(int nlhs,
                               mxArray *plhs[],
                               int nrhs,
                               const mxArray *prhs[])
{
    int32 pointid;
    int32 periodid;
    int32 level;
    int32 numrecs;
    int32 *recnumbers = NULL;
    intn status;
    double *real_ptr;
    int k;
    
    haNarginChk(5, 5, nrhs);
    haNargoutChk(0, 3, nlhs);
    
    pointid = (int32) haGetNonNegativeDoubleScalar(prhs[2], "Point identifier");
    periodid = (int32) haGetNonNegativeDoubleScalar(prhs[3], "Period identifier");
    level = (int32) haGetDoubleScalar(prhs[4], "Level");
    
    /* How many records are within the subsetted period? */
    status = PTperiodrecs(pointid, periodid, level, &numrecs, NULL);
    
    /* Allocate space for the record numbers and get them */
    if (status != FAIL)
    {
        recnumbers = (int32 *) mxCalloc(numrecs, sizeof(*recnumbers));
        status = PTperiodrecs(pointid, periodid, level, &numrecs, recnumbers);
    }
    
    if (status == FAIL)
    {
    	plhs[0] = haCreateDoubleScalar((double) FAIL);
    }
    else
    {
    	plhs[0] = haCreateDoubleScalar((double) numrecs);
    }
    
    if (nlhs > 1)
    {
        if (status == FAIL)
        {
            plhs[1] = EMPTY;
        }
        else
        {
            plhs[1] = mxCreateDoubleMatrix(1, numrecs, mxREAL);
            real_ptr = mxGetPr(plhs[1]);
            for (k = 0; k < numrecs; k++)
            {
                real_ptr[k] = (double) recnumbers[k];
            }
        }
    }
    
    if (nlhs > 2)
    {
    	plhs[2] = haCreateDoubleScalar((double) status);
    }
    	
    if (recnumbers != NULL)
    {
        mxFree(recnumbers);
    }
}

/*
 * hdfPTreadattr
 * 
 * Purpose: Gateway to the HDF-EOS Library function PTreadattr
 *          Reads attributes from a point
 *
 * MATLAB usage:
 *          [databuf, status] = hd('PT', 'readattr', pointid, attrname)
 *
 * Inputs:  pointid     - Point identifier
 *          attrname    - Name of attribute
 *
 * Outputs: databuf     - Attribute values read from the field
 *          status      - 0 if succeeded, -1 if failed.
 * 
 * Returns: none
 */
static
void hdfPTreadattr(int nlhs,
                      mxArray *plhs[],
                      int nrhs,
                      const mxArray *prhs[])
{
    int32 pointid;
    char *attrname = NULL;
    VOIDP datbuf;
    intn status;

    int32 numbertype;
    int32 count;
    int32 num_elements;
    int dims[2] = {0, 0};
    bool ok_to_free = false;

    /* Argument checking */
    haNarginChk(4, 4, nrhs);
    haNargoutChk(0, 2, nlhs);
    
    /* Get datbuf from MATLAB arrays */
    pointid = (int32) haGetNonNegativeDoubleScalar(prhs[2], "Point identifier");
    attrname = haGetString(prhs[3], "Attribute name");

    status = PTattrinfo(pointid, attrname, &numbertype, &count);
    
    if (status != FAIL)
    {
    	num_elements = count / haGetDataTypeSize(numbertype);
    	
        /* Allocate space for the data to be read */
        datbuf = haMakeHDFDataBuffer(num_elements, numbertype);

        /* Call HDF-EOS library function, and output result */
        status = PTreadattr(pointid, attrname, datbuf);

    }

    if (status != FAIL)
    {
        dims[0] = 1;
        dims[1] = num_elements;
        plhs[0] = haMakeArrayFromHDFDataBuffer(2, dims, numbertype, 
                                               datbuf, &ok_to_free);
    }
    else
    {
        plhs[0] = EMPTY;
    }

    if (nlhs > 1) 
    {
        plhs[1] = haCreateDoubleScalar((double) status);
    }

    /* Clean up */
    if (attrname != NULL)
    {
        mxFree(attrname);
    }
    if (ok_to_free) {
        mxFree(datbuf);
    }
}

/*
 * hdfPTreadlevel
 *
 * Purpose: gateway to PTreadlevel()
 *          Reads data from a point level
 *
 * MATLAB usage:
 * [data,status] = hdf('PT','readlevel',pointid,level,fieldlist,records)
 *    Data is returned in a nfields-by-1 cell array.  Each
 *    cell will contain a order(i)-by-n vector of data where order(i) 
 *    is the field order and n is the number of records requested.
 */
static void hdfPTreadlevel(int nlhs,
                               mxArray *plhs[],
                               int nrhs,
                               const mxArray *prhs[])
{
    int32 pointid;
    int32 level;
    intn status;
    int32 numfields;
    int32 *fieldtype = NULL;
    int32 *fieldorder = NULL;
    char *fieldlist = NULL;
    int32 *fieldlevel = NULL;
    int32 strbufsize;
    mxArray *cellarray = NULL;
    int32 *records = NULL;
    VOIDP data = NULL;
    VOIDP *bufptrs = NULL;
    int i,j;
    int32 fieldbytes;
    int32 bytes_per_record;
    int32 offset;
    int32 numrecords;
    int32 this_data_type;
    double *real_ptr;
    bool ok2free = false;
    
    haNarginChk(6, 6, nrhs);
    haNargoutChk(0, 2, nlhs);
    
    pointid = (int32) haGetNonNegativeDoubleScalar(prhs[2], "Point identifier");
    level = (int32) haGetDoubleScalar(prhs[3], "Level");
    fieldlist = haGetString(prhs[4], "Field list");

    if (!mxIsDouble(prhs[5]))
    {
        mexErrMsgTxt("RECORDS must be a double vector.");
    }
    numrecords = mxGetNumberOfElements(prhs[5]);
    real_ptr = mxGetPr(prhs[5]);
    records = (int32 *) mxCalloc(numrecords, sizeof(*records));
    for (i = 0; i < numrecords; i++)
    {
        records[i] = (int32) real_ptr[i];
    }
    
    /*
     * Find out how many fields there are, plus the number
     * type and order of each field.
     */
    numfields = PTnfields(pointid, level, &strbufsize);
    status = (numfields == FAIL) ? FAIL : SUCCEED;
    if (status != FAIL)
    {
        fieldtype = (int32 *) mxCalloc(numfields, sizeof(*fieldtype));
        fieldorder = (int32 *) mxCalloc(numfields, sizeof(*fieldorder));
        numfields = LevelinfoFromList(pointid, level, fieldlist, fieldtype, fieldorder);
        status = (numfields == FAIL) ? FAIL : SUCCEED;
    }

    /* 
     * Determine size of required data buffer 
     */
    if (status != FAIL)
    {
        cellarray = mxCreateCellMatrix(numfields, 1);
        fieldlevel = (int32 *) mxCalloc(numfields, sizeof(*fieldlevel));
        for (i = 0; i < numfields; i++)
        {
            fieldlevel[i] = level;
        }
        bytes_per_record = PTsizeof(pointid, fieldlist, fieldlevel);
        status = (bytes_per_record == FAIL) ? FAIL : SUCCEED;
    }
    
    /*
     * Create buffers and read in data
     */
    if (status != FAIL)
    {
        data = (VOIDP) mxCalloc(bytes_per_record * numrecords, 1);
        bufptrs = (VOIDP *) mxCalloc(numfields, sizeof(VOIDP));
        
        for (i = 0; i < numfields; i++)
        {
            this_data_type = fieldtype[i];
            bufptrs[i] = haMakeHDFDataBuffer(fieldorder[i] * numrecords, 
                                             this_data_type);
        }

        status = PTreadlevel(pointid, level, fieldlist, numrecords,
                             records, data);
    }

    /* 
     * Unpack data buffer and make cells of cell array
     */
    if (status != FAIL)
    {
        offset = 0;
        for (j = 0; j < numrecords; j++)
        {
            for (i = 0; i < numfields; i++)
            {
                fieldbytes = fieldorder[i] * haGetDataTypeSize(fieldtype[i]);
                memcpy((void *) ((char *) bufptrs[i] + fieldbytes*j), 
                       (void *) ((char *) data + offset), fieldbytes);
                offset += fieldbytes;
            }
	}
        for (i = 0; i < numfields; i++)
        {
            int ndims = 2;
            int siz[2];
            siz[0] = fieldorder[i];
            siz[1] = numrecords;
            mxSetCell(cellarray, i,
                      haMakeArrayFromHDFDataBuffer(ndims, siz,
                                                   fieldtype[i], bufptrs[i],
                                                   &ok2free));
            if (ok2free)
            {
                mxFree(bufptrs[i]);
            }
        }
    }

    if (status == FAIL)
    {
        plhs[0] = EMPTY;
    }
    else
    {
        plhs[0] = cellarray;
    }
    
    if (nlhs > 1)
    {
        plhs[1] = haCreateDoubleScalar((double) status);
    }

    if (fieldtype != NULL)
    {
        mxFree(fieldtype);
    }
    if (fieldorder != NULL)
    {
        mxFree(fieldorder);
    }
    if (fieldlist != NULL)
    {
        mxFree(fieldlist);
    }
    if (records != NULL)
    {
        mxFree(records);
    }
    if (bufptrs != NULL)
    {
        mxFree(bufptrs);
    }
    if (data != NULL)
    {
    	mxFree(data);
    }
    if ((status == FAIL) && (cellarray != NULL))
    {
        mxDestroyArray(cellarray);
    }
}


/*
 * hdfPTregioninfo
 *
 * Purpose: gateway to PTregioninfo()
 *          Retrieves size in bytes of subsetted region
 *
 * MATLAB usage:
 * [bytesize,status] = hdf('PT','regioninfo',pointid,regionid,level,fieldlist)
 */
static void hdfPTregioninfo(int nlhs,
                               mxArray *plhs[],
                               int nrhs,
                               const mxArray *prhs[])
{
    int32 pointid;
    int32 regionid;
    int32 level;
    char *fieldlist = NULL;
    int32 bytesize;
    intn status;
    
    haNarginChk(6, 6, nrhs);
    haNargoutChk(0, 2, nlhs);
    
    pointid = (int32) haGetNonNegativeDoubleScalar(prhs[2], "Point identifier");
    regionid = (int32) haGetNonNegativeDoubleScalar(prhs[3], "Region identifier");
    level = (int32) haGetDoubleScalar(prhs[4], "Level");
    fieldlist = haGetString(prhs[5], "Field list");
    
    status = PTregioninfo(pointid, regionid, level, fieldlist, &bytesize);
    
    if (status == FAIL)
    {
        plhs[0] = haCreateDoubleScalar((double) FAIL);
    }
    else
    {
        plhs[0] = haCreateDoubleScalar((double) bytesize);
    }
    if (nlhs > 1)
    	plhs[1] = haCreateDoubleScalar((double) status);
    	
    if (fieldlist != NULL)
    {
        mxFree(fieldlist);
    }
}

/*
 * hdfPTregionrecs
 *
 * Purpose: gateway to PTregionrecs()
 *          Retrieves record numbers within geographic region in level
 *
 * MATLAB usage:
 * [numrecs,recnumbers,status] = hdf('PT','regionrecs',pointid,regionid,level)
 */
static void hdfPTregionrecs(int nlhs,
                               mxArray *plhs[],
                               int nrhs,
                               const mxArray *prhs[])
{
    int32 pointid;
    int32 regionid;
    int32 level;
    int32 numrecs;
    int32 *recnumbers = NULL;
    intn status;
    double *real_ptr;
    int k;
    
    haNarginChk(5, 5, nrhs);
    haNargoutChk(0, 3, nlhs);
    
    pointid = (int32) haGetNonNegativeDoubleScalar(prhs[2], "Point identifier");
    regionid = (int32) haGetNonNegativeDoubleScalar(prhs[3], "Region identifier");
    level = (int32) haGetDoubleScalar(prhs[4], "Level");
    
    /* How many record are within the subsetted region? */
    status = PTregionrecs(pointid, regionid, level, &numrecs, NULL);
    
    /* Allocate space for the record numbers and get them */
    if (status != FAIL)
    {
        recnumbers = (int32 *) mxCalloc(numrecs, sizeof(*recnumbers));
        status = PTregionrecs(pointid, regionid, level, &numrecs, recnumbers);
    }
    
    if (status != FAIL)
    {
    	plhs[0] = haCreateDoubleScalar((double) numrecs);
    }
    else
    {
    	plhs[0] = haCreateDoubleScalar((double) FAIL);
    }
    
    if (nlhs > 1)
    {
        if (status == FAIL)
        {
            plhs[1] = EMPTY;
        }
        else
        {
            plhs[1] = mxCreateDoubleMatrix(1, numrecs, mxREAL);
            real_ptr = mxGetPr(plhs[1]);
            for (k = 0; k < numrecs; k++)
            {
                real_ptr[k] = (double) recnumbers[k];
            }
        }
    }
    
    if (nlhs > 2)
    {
    	plhs[2] = haCreateDoubleScalar((double) status);
    }
    
    if (recnumbers != NULL)
    {
        mxFree(recnumbers);
    }
}

/*
 * hdfPTsizeof
 *
 * Purpose: gateway to PTsizeof()
 *          Returns information on specified fields in point
 *
 * MATLAB usage:
 * [bytesize,fieldlevels] = hdf('PT','sizeof',pointid,fieldlist)
 */
static void hdfPTsizeof(int nlhs,
                           mxArray *plhs[],
                           int nrhs,
                           const mxArray *prhs[])
{
    int32 pointid;
    char *fieldlist = NULL;
    int32 bytesize;
    int32 *fieldlevels = NULL;
    uint32_T numcommas = 0;
    uint32_T numfields = 0;
    double *real_ptr;
    uint32_T k;
    
    haNarginChk(4, 4, nrhs);
    haNargoutChk(0, 2, nlhs);
    
    pointid = (int32) haGetNonNegativeDoubleScalar(prhs[2], "Point identifier");
    fieldlist = haGetString(prhs[3], "Field list");
    
    numfields = GetNumFields(fieldlist);
    
    /* Allocate space for the fieldlevels array */
    fieldlevels = (int32 *) mxCalloc(numfields, sizeof(*fieldlevels));
    
    /* Get the info */
    bytesize = PTsizeof(pointid, fieldlist, fieldlevels);

    plhs[0] = haCreateDoubleScalar((double) bytesize);
    
    if (nlhs > 1)
    {
        if (bytesize != FAIL)
        {
            plhs[1] = mxCreateDoubleMatrix(1, numfields, mxREAL);
            real_ptr = mxGetPr(plhs[1]);
            for (k = 0; k < numfields; k++)
            {
                real_ptr[k] = (double) fieldlevels[k];
            }
        }
        else
        {
            plhs[1] = EMPTY;
        }
    }
    
    if (fieldlist != NULL)
    {
        mxFree(fieldlist);
    }
    if (fieldlevels != NULL)
    {
        mxFree(fieldlevels);
    }
}

/*
 * hdfPTupdatelevel
 *
 * Purpose: gateway to PTupdatelevel()
 *          Updates (corrects) data records in a point level
 *
 * MATLAB usage:
 * status = hdf('PT','updatelevel',pointid,level,fieldlist,records,data)
 *    records is a vector of record numbers to be updated.
 *    data must be an nfields-by-1 cell array.
 *    each cell must contain an order(i)-by-n vector of data where order(i) is
 *    the number of scalar values in each field, and n is the length of
 *    records.
 */
static void hdfPTupdatelevel(int nlhs,
                                mxArray *plhs[],
                                int nrhs,
                                const mxArray *prhs[])
{
    int32 pointid;
    int32 level;
    intn status;
    int32 numfields;
    int32 *fieldtype = NULL;
    int32 *fieldorder = NULL;
    char *fieldlist = NULL;
    int32 *fieldlevel = NULL;
    int32 *records = NULL;
    const mxArray *cellarray;
    VOIDP data = NULL;
    VOIDP *bufptrs = NULL;
    int i,j;
    int32 fieldbytes;
    int32 bytesize;
    int32 offset;
    int32 numrecords;
    int32 this_data_type;
    double *real_ptr;
    
    haNarginChk(7, 7, nrhs);
    haNargoutChk(0, 1, nlhs);
    
    pointid = (int32) haGetNonNegativeDoubleScalar(prhs[2], "Point identifier");
    level = (int32) haGetDoubleScalar(prhs[3], "Level");
    fieldlist = haGetString(prhs[4], "Field list");
    cellarray = prhs[6];
    
    /*
     * Find out how many fields there are, plus the number
     * type and order of each field.
     */
    numfields = GetNumFields(fieldlist);

    fieldtype = (int32 *) mxCalloc(numfields, sizeof(*fieldtype));
    fieldorder = (int32 *) mxCalloc(numfields, sizeof(*fieldorder));
    numfields = LevelinfoFromList(pointid, level, fieldlist, fieldtype, fieldorder);
    status = (numfields == FAIL) ? FAIL : SUCCEED;
    
    /*
     * Perform some error checking on the data cell array
     */
    if (status != FAIL)
    {
        if (!mxIsDouble(prhs[5]))
        {
            mexErrMsgTxt("Records must be a double vector.");
        }
        numrecords = mxGetNumberOfElements(prhs[5]);
        records = (int32 *) mxCalloc(numrecords, sizeof(*records));
        real_ptr = mxGetPr(prhs[5]);
        for (i = 0; i < numrecords; i++)
        {
            records[i] = (int32) real_ptr[i];
        }

        if (!mxIsCell(cellarray) || (mxGetNumberOfDimensions(cellarray) != 2))
        {
            mexErrMsgTxt("Data must be a 2-D cell array.");
        }
        if (mxGetNumberOfElements(cellarray) != numfields)
        {
            mexErrMsgTxt("Cell array length must match the number of "
                         "specified fields.");
        }

        for (i = 0; i < numfields; i++)
        {
            mxArray *cell = mxGetCell(cellarray, i);
            if (haGetClassIDFromDataType(fieldtype[i]) != mxGetClassID(cell))
            {
                mexErrMsgTxt("Data class must match field class.");
            }
            if (mxGetM(cell) != fieldorder[i])
            {
                mexErrMsgTxt("Number of rows of data must match order "
                             "of field.");
            }
            if (numrecords < 0)
            {
                numrecords = mxGetN(cell);
            }
            
            if (mxGetN(cell) != numrecords)
            {
                mexErrMsgTxt("Number of columns of each element of data "
                             "must be the same as the length of records.");
            }
        }
    }

    /* 
     * Determine size of required data buffer 
     */
    if (status != FAIL)
    {
        fieldlevel = (int32 *) mxCalloc(numfields, sizeof(*fieldlevel));
        for (i = 0; i < numfields; i++)
        {
            fieldlevel[i] = level;
        }
        bytesize = PTsizeof(pointid, fieldlist, fieldlevel);
        status = (bytesize == FAIL) ? FAIL : SUCCEED;
    }
    
    if (status != FAIL)
    {
        data = (VOIDP) mxCalloc(numrecords,bytesize);
        bufptrs = (VOIDP *) mxCalloc(numfields, sizeof(VOIDP));
        
        for (i = 0; i < numfields; i++)
        {
            this_data_type = fieldtype[i];
            if (haGetClassIDFromDataType(this_data_type) == mxCHAR_CLASS)
            {
                bufptrs[i] =
                    haMakeHDFDataBufferFromCharArray(mxGetCell(cellarray,i),
                                                     this_data_type);
            }
            else
            {
                bufptrs[i] = mxGetData(mxGetCell(cellarray,i));
            }
        }
            
        /* Pack array buffers into data */
        offset = 0;
        for (j = 0; j < numrecords; j++)
        {
            for (i = 0; i < numfields; i++)
            {
                fieldbytes = fieldorder[i] * haGetDataTypeSize(this_data_type);
                memcpy((void *) ((char *) data + offset),
                       (void *) ((char *) bufptrs[i] + fieldbytes*j), fieldbytes);
                offset += fieldbytes;
            }
        }
        
        /* Finally! We're ready to write the data. */
        status = PTupdatelevel(pointid, level, fieldlist, numrecords, 
                               records, data);
        
    }
    
    plhs[0] = haCreateDoubleScalar((double) status);
    
    /* Clean up */
    if (bufptrs != NULL)
    {
        /* Destroy temporary character buffers */
        for (i = 0; i < numfields; i++)
        {
            if (haGetClassIDFromDataType(fieldtype[i]) == mxCHAR_CLASS)
            {
                mxFree(bufptrs[i]);
            }
        }
        mxFree(bufptrs);
    }
    if (fieldtype != NULL)
    {
        mxFree(fieldtype);
    }
    if (fieldorder != NULL)
    {
        mxFree(fieldorder);
    }
    if (fieldlist != NULL)
    {
        mxFree(fieldlist);
    }
    if (fieldlevel != NULL)
    {
        mxFree(fieldlevel);
    }
    if (data != NULL)
    {
        mxFree(data);
    }
    if (records != NULL)
    {
    	mxFree(records);
    }
}

/*
 * hdfPTwriteattr
 * 
 * Purpose: Gateway to the HDF-EOS Library function PTwriteattr
 *          Writes/Updates attributes in a point
 *
 * MATLAB usage:
 *          status = hd('PT', 'writeattr', pointid, attrname, data)
 *
 * Inputs:  pointid     - Point identifier
 *          attrname    - Name of attribute
 *          data        - Attribute values to be written to the field
 *
 * Outputs: status      - 0 if succeeded, -1 if failed.
 * 
 * Returns: none
 */
static
void hdfPTwriteattr(int nlhs,
                       mxArray *plhs[],
                       int nrhs,
                       const mxArray *prhs[])
{
    int32 pointid;
    char *attrname = NULL;
    VOIDP datbuf;
    intn status;

    mxClassID classid;
    int32 ntype;
    int32 count;
    bool free_buf = false;
    
    /* Argument checking */
    haNarginChk(5, 5, nrhs);
    haNargoutChk(0, 1, nlhs);
    
    pointid = (int32) haGetNonNegativeDoubleScalar(prhs[2], "Point identifier");
    attrname = haGetString(prhs[3], "Attribute name");

    /* Get numbertype and count */
    count = mxGetNumberOfElements(prhs[4]);
    classid = mxGetClassID(prhs[4]);
    ntype = haGetDataTypeFromClassID(classid);

    /* Get data buffer from MATLAB array */
    if (classid == mxCHAR_CLASS) {
        datbuf = haMakeHDFDataBufferFromCharArray(prhs[4], ntype);
        free_buf = true;
    }
    else {
        datbuf = mxGetData(prhs[4]);
    }
    
    /* Call HDF-EOS library function, and output result */
    status = PTwriteattr(pointid, attrname, ntype, count, datbuf);
    plhs[0] = haCreateDoubleScalar((double) status);

    /* Clean up */
    if (attrname != NULL)
    {
        mxFree(attrname);
    }
    if (free_buf) {
        mxFree(datbuf);
    }
}

/*
 * hdfPTwritelevel
 *
 * Purpose: gateway to PTwritelevel()
 *          Writes (appends) new records to a point level
 *
 * MATLAB usage:
 * status = hdf('PT','writelevel',pointid,level,data)
 *    data must be an nfields-by-1 cell array.
 *    each cell must contain an order(i)-by-n vector of data where order(i) is
 *    the number of scalar values in each field, and n is the number of 
 *    records.
 */
static void hdfPTwritelevel(int nlhs,
                               mxArray *plhs[],
                               int nrhs,
                               const mxArray *prhs[])
{
    int32 pointid;
    int32 level;
    intn status;
    int32 numfields;
    int32 *fieldtype = NULL;
    int32 *fieldorder = NULL;
    char *fieldlist = NULL;
    int32 *fieldlevel = NULL;
    int32 strbufsize;
    const mxArray *cellarray;
    VOIDP data = NULL;
    VOIDP *bufptrs = NULL;
    int i,j;
    int32 fieldbytes;
    int32 bytes_per_record;
    int32 offset;
    int32 numrecords;
    int32 this_data_type;
    int32 this_data_size;
    
    haNarginChk(5, 5, nrhs);
    haNargoutChk(0, 1, nlhs);
    
    pointid = (int32) haGetNonNegativeDoubleScalar(prhs[2], "Point identifier");
    level = (int32) haGetDoubleScalar(prhs[3], "Level");
    cellarray = prhs[4];
    
    /*
     * Find out how many fields there are, plus the number
     * type and order of each field.
     */
    numfields = PTnfields(pointid, level, &strbufsize);
    status = (numfields == FAIL) ? FAIL : SUCCEED;
    if (status != FAIL)
    {
        fieldtype = (int32 *) mxCalloc(numfields, sizeof(*fieldtype));
        fieldorder = (int32 *) mxCalloc(numfields, sizeof(*fieldorder));
        fieldlist = (char *) mxCalloc(strbufsize + 1, sizeof(*fieldlist));
        numfields = PTlevelinfo(pointid, level, fieldlist, fieldtype, fieldorder);
        status = (numfields == FAIL) ? FAIL : SUCCEED;
    }

    /*
     * Perform some error checking on the data cell array
     */
    if (status != FAIL)
    {
        if (!mxIsCell(cellarray) || (mxGetNumberOfDimensions(cellarray) != 2))
        {
            mexErrMsgTxt("Data must be a 2-D cell array.");
        }
        if (mxGetNumberOfElements(cellarray) != numfields)
        {
            mexErrMsgTxt("Cell array length must match the number of "
                         "specified fields.");
        }

        numrecords = -1;
        for (i = 0; i < numfields; i++)
        {
            mxArray *cell = mxGetCell(cellarray, i);
            if (haGetClassIDFromDataType(fieldtype[i]) != mxGetClassID(cell))
            {
                mexErrMsgTxt("Data class must match field class.");
            }
            if (mxGetM(cell) != fieldorder[i])
            {
                mexErrMsgTxt("Number of rows of data must match order "
                             "of field.");
            }
            if (numrecords < 0)
            {
                numrecords = mxGetN(cell);
            }
            
            if (mxGetN(cell) != numrecords)
            {
                mexErrMsgTxt("Number of columns of each element of data "
                             "must be the same.");
            }
        }
    }

    /* 
     * Determine size of required data buffer 
     */
    if (status != FAIL)
    {
        fieldlevel = (int32 *) mxCalloc(numfields, sizeof(*fieldlevel));
        for (i = 0; i < numfields; i++)
        {
            fieldlevel[i] = level;
        }
        bytes_per_record = PTsizeof(pointid, fieldlist, fieldlevel);
        status = (bytes_per_record == FAIL) ? FAIL : SUCCEED;
    }
    
    if (status != FAIL)
    {
        data = (VOIDP) mxCalloc(bytes_per_record*numrecords, 1);
        bufptrs = (VOIDP *) mxCalloc(numfields, sizeof(VOIDP));
        
        for (i = 0; i < numfields; i++)
        {
            this_data_type = fieldtype[i];
            if (haGetClassIDFromDataType(this_data_type) == mxCHAR_CLASS)
            {
                bufptrs[i] =
                    haMakeHDFDataBufferFromCharArray(mxGetCell(cellarray,i),
                                                     this_data_type);
            }
            else
            {
                bufptrs[i] = mxGetData(mxGetCell(cellarray,i));
            }
        }
    
       /* Pack array buffers into data */
        offset = 0;
        for (j = 0; j < numrecords; j++)
        {
	    for (i = 0; i < numfields; i++)
            {
		this_data_type = fieldtype[i];
		this_data_size = haGetDataTypeSize(this_data_type);
		fieldbytes = fieldorder[i] * this_data_size;
		memcpy((void *) ((char *) data + offset), 
		       (void *) ((char *) bufptrs[i] + fieldbytes*j), fieldbytes);
		offset += fieldbytes;
	    }
        }
        /* Finally! We're ready to write the data. */
        status = PTwritelevel(pointid, level, numrecords, data);
        
    }
    
    plhs[0] = haCreateDoubleScalar((double) status);
    
    /* Clean up */
    if (bufptrs != NULL)
    {
        /* Destroy temporary character buffers */
        for (i = 0; i < numfields; i++)
        {
            if (haGetClassIDFromDataType(fieldtype[i]) == mxCHAR_CLASS)
            {
                mxFree(bufptrs[i]);
            }
        }
        mxFree(bufptrs);
    }
    if (fieldtype != NULL)
    {
        mxFree(fieldtype);
    }
    if (fieldorder != NULL)
    {
        mxFree(fieldorder);
    }
    if (fieldlist != NULL)
    {
        mxFree(fieldlist);
    }
    if (fieldlevel != NULL)
    {
        mxFree(fieldlevel);
    }
    if (data != NULL)
    {
        mxFree(data);
    }
}


/*
 * hdfPT
 *
 * Purpose: Function switchyard for the PT part of the HDF-EOS gateway.
 *
 * Inputs:  nlhs --- number of left-side arguments
 *          plhs --- left-side arguments
 *          nrhs --- number of right-side arguments
 *          prhs --- right-side arguments
 *          functionStr --- string specifying which AN function to call
 * Outputs: none
 * Return:  none
 */
void hdfPT(int nlhs,
              mxArray *plhs[],
              int nrhs,
              const mxArray *prhs[],
              char *functionStr)
{
    typedef void (MATLAB_FCN)(int nlhs, mxArray *plhs[], 
                              int nrhs, const mxArray *prhs[]);
    
    struct {
    	char *name;
    	MATLAB_FCN *func;
    } PTFcns[] = {
        {"attach",            hdfPTattach},
        {"attrinfo",          hdfPTattrinfo},
        {"bcklinkinfo",       hdfPTbcklinkinfo},
        {"close",             hdfPTclose},
        {"create",            hdfPTcreate},
        {"defboxregion",      hdfPTdefboxregion},
        {"deflevel",          hdfPTdeflevel},
        {"deflinkage",        hdfPTdeflinkage},
        {"deftimeperiod",     hdfPTdeftimeperiod},
	{"defvrtregion",      hdfPTdefvrtregion},
        {"detach",            hdfPTdetach},
        {"extractperiod",     hdfPTextractperiod},
        {"extractregion",     hdfPTextractregion},
        {"fwdlinkinfo",       hdfPTfwdlinkinfo},
        {"getlevelname",      hdfPTgetlevelname},
        {"getrecnums",        hdfPTgetrecnums},
        {"inqattrs",          hdfPTinqattrs},
        {"inqpoint",          hdfPTinqpoint},
        {"levelindx",         hdfPTlevelindx},
        {"levelinfo",         hdfPTlevelinfo},
        {"nfields",           hdfPTnfields},
        {"nlevels",           hdfPTnlevels},
        {"nrecs",             hdfPTnrecs},
        {"open",              hdfPTopen},
        {"periodinfo",        hdfPTperiodinfo},
        {"periodrecs",        hdfPTperiodrecs},
        {"readattr",          hdfPTreadattr},
        {"readlevel",         hdfPTreadlevel},
        {"regioninfo",        hdfPTregioninfo},
        {"regionrecs",        hdfPTregionrecs},
        {"sizeof",            hdfPTsizeof},
        {"updatelevel",       hdfPTupdatelevel},
        {"writeattr",         hdfPTwriteattr},
        {"writelevel",        hdfPTwritelevel}
    };
   
    int NumberOfFunctions = sizeof(PTFcns) / sizeof(*PTFcns);
    
    int i;
    bool found = false;
    
    for(i=0; i<NumberOfFunctions; i++)
    {
        if (strcmp(functionStr,PTFcns[i].name)==0)
        {
            (*(PTFcns[i].func))(nlhs, plhs, nrhs, prhs);
            found = true;
            break;
        }
    }
    
    if (! found)
        mexErrMsgTxt("Unknown HDF-EOS PT interface function.");
}


