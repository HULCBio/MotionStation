/* Copyright 1984-2002 The MathWorks, Inc.  */

/*
 * hdfvs.c --- support file for HDF.MEX
 *
 * This module supports the HDF VS interface.  The only public
 * function is hdfVS(), which is called by mexFunction().
 * hdfVS looks at the second input argument to determine which
 * private function should get control.
 *
 * Syntaxes
 * ========
 * vdata_id = hdf('VS', 'attach', file_id, vdata_ref, access)
 * [name,data_type,count,nbytes,status] = hdf('VS','attrinfo',vdata_id,field_index,attr_index)
 *    field_index can an index number or 'vdata'.
 * status = hdf('VS', 'detach', vdata_id)
 * count = hdf('VS', 'elts', vdata_id)
 * status = hdf('V', 'fdefine', vdata_id, fieldname, data_type, order)
 * status = hdf('VS', 'fexist', vdata_id, fields)
 * vdata_ref = hdf('VS', 'find', file_id, vdata_name)
 * [field_index,status] = hdf('VS', 'findex', vdata_id, fieldname)
 * attr_index = hdf('VS', 'findattr', vdata_id, field_index, attr_name)
 *    field_index can be an index number or 'vdata'.
 * vdata_ref = hdf('VS', 'findclass', file_id, vdata_class)
 * [field_index,status] = hdf('VS', 'findex', vdata_id, fieldname)
 *    field_index can be an index number or 'vdata'.
 * count = hdf('VS', 'fnattrs', vdata_id, field_index)
 *    field_index can be an index number or 'vdata'.
 * [values,status] = hdf('VS', 'getattr', vdata_id, field_index, attr_index)
 *    field_index can be an index number or 'vdata'.
 * [class_name,status] = hdf('VS', 'getclass', vdata_id)
 * [field_names,count] = hdf('VS', 'getfields', vdata_id)
 * next_ref = hdf('VS', 'getid', file_id, vdata_ref)
 * [interlace,status] = hdf('VS', 'getinterlace', vdata_id)
 * [vdata_name,status] = hdf('VS', 'getname', vdata_id)
 * version = hdf('VS', 'getversion', vdata_id)
 * [n,interlace,fields,nbytes,vdata_name,status] = hdf('VS', 'inquire', vdata_id)
 * tf = hdf('VS', 'isattr', vdata_id)
 * [refs,count] = hdf('VS', 'lone', file_id, maxsize)
 * count = hdf('VS', 'nattrs', vdata_id)
 * [data, count] = hdf('VS','read', vdata_id, n)
 *    Data is returned in a nfields-by-1 cell array.  Each
 *    cell will contain a order(i)-by-n vector of data where order is the number of scalar
 *    values in each field.  The fields are returned in the same
 *    order as specified in hdfVSsetfields.
 * pos = hdf('VS', 'seek', vdata_id, record)
 * status = hdf('VS', 'setattr', vdata_id, field_index, name, A)
 *    field_index can an index number or 'vdata'.
 * status = hdf('VS', 'setclass', vdata_id, class)
 * status = hdf('VS', 'setexternalfile', vdata_id, filename, offset)
 * status = hdf('VS', 'setfields', vdata_id, fields)
 * status = hdf('VS', 'setinterlace', vdata_id, interlace)
 * status = hdf('VS', 'setname', vdata_id, name)
 * nbytes = hdf('VS', 'sizeof', vdata_id, fields)
 * count = hdf('VS', 'write', vdata_id, data, n, interlace)
 * count = hdf('VS','write', vdata_id, data)
 *    data must be an nfields-by-1 cell array.
 *    each cell must contain an order(i)-by-n vector of data where order(i) is
 *    the number of scalar values in each field.  The types of the data must
 *    match the field types set via hdfVSsetfields.
 * [count,status] = hdf('VS', 'Querycount', vdata_id)
 * [fields,status] = hdf('VS', 'Queryfields', vdata_id)
 * [interlace,status] = hdf('VS', 'Queryinterlace', vdata_id)
 * [name,status] = hdf('VS', 'Queryname', vdata_id)
 * ref = hdf('VS', 'Queryref', vdata_id)
 * tag = hdf('VS', 'Querytag', vdata_id)
 * [vsize,status] = hdf('VS', 'Queryvsize', vdata_id)
 * vsize = hdf('VS', 'Queryvsize', vdata_id)
 */

/* $Revision: 1.1.6.1 $  $Date: 2003/12/13 03:02:31 $ */

static char rcsid[] = "$Id: hdfvs.c,v 1.1.6.1 2003/12/13 03:02:31 batserve Exp $";

#include <string.h>
#include <math.h>

/* Main HDF library header file */
#include "hdf.h"

/* Vgroup interface header file */
#include "vg.h"

/* MATLAB API header file */
#include "mex.h"

/* HDFMEX utility functions */
#include "hdfutils.h"

#include "hdfvs.h"

/*****************************************************************
      SetFields Utility functions (private to hdfvs.c)
	 RememberSetFields(vdata_id,fields)
	 ForgetSetFields(vdata_id)
	 FindFieldInfoNode(vdata_id)
	 GetFieldInfo(vdata_id,&n,&index,&data_types,&order)
 ****************************************************************/

typedef struct fieldinfo *fieldinfoPtr;
typedef struct fieldinfo {
   int32 vdata_id;     /* vdata_id for this node (only one per vdata_id) */
   int32 n;	       /* Number of fields in this setfields spec */
   char *fields;       /* Fieldnames list */
   int32 *index;       /* Length n array of indexes (one for each field) */
   int32 *data_type;   /* Length n array of data_types (one for each field) */
   int32 *order;       /* Length n array of orders (one for each field) */
   fieldinfoPtr prev;  /* Pointer to previous fieldinfo node */
   fieldinfoPtr next;  /* Pointer to next fieldinfo node */
} fieldinfo;

static fieldinfo *head = NULL;

/*
 * Find info node for this vdata_id
 */
static fieldinfo *FindFieldInfoNode(
    int32 vdata_id
    )
{
    fieldinfo *fi = head;
    
    while (fi != NULL && fi->vdata_id != vdata_id)
	fi = fi->next;
    
    return fi;
}


/*
 * Forget (free) the remembered information for this vdata_id.
 * Return SUCCESS or FAIL.
 */
static intn ForgetSetFields(
    int32 vdata_id
    )
{
    fieldinfo *fi = FindFieldInfoNode(vdata_id);
    
    if (fi != NULL)
    {
	/* Free parts */
	if (fi->fields != NULL)
	    mxFree(fi->fields);
	if (fi->index != NULL)
	    mxFree(fi->index);
	if (fi->data_type != NULL)
	    mxFree(fi->data_type);
	if (fi->order != NULL)
	    mxFree(fi->order);
	
	/* Remove node from the list */
	if (fi->prev != NULL)
	    fi->prev->next = fi->next;
	else
	    head = fi->next; /* prev will be null if fi is the head */
	    
	if (fi->next != NULL)
	    fi->next->prev = fi->prev;
	
	mxFree(fi);
	
	return SUCCEED;
    }
    else
	return FAIL;
}


/*
 * Remember the names of fields set in hdfVSsetfields so that 
 * hdfVSread and hdfVSwrite can determine the sizes of each
 * field.  Return SUCCEED or FAIL.
 */
static intn RememberSetFields(
    int32 vdata_id,
    char *fields
    )
{
    int n;
    int32 index;
    int32 order;
    int32 data_type;
    intn status;
    char *s;
    int i;
    
    fieldinfo *fi = FindFieldInfoNode(vdata_id);
    
    if (fi == NULL)
    {
	/* Make a new node and insert it at the head of the list */
	fi = mxCalloc(1,sizeof(fieldinfo));
	mexMakeMemoryPersistent(fi);
	    
	fi->vdata_id = vdata_id;
	fi->next = head;
	fi->prev = NULL;
	if (head != NULL)
	    head->prev = fi;
	head = fi;
    }
    else
    {
	/* Free the data associated with this node */
	mxFree(fi->index);
	mxFree(fi->data_type);
	mxFree(fi->order);
    }
    fi->fields = NULL;
    fi->index = NULL;
    fi->data_type = NULL;
    fi->order = NULL;
    
    /* Save fieldnames list */
    fi->fields = mxCalloc(strlen(fields)+1,sizeof(char));
    mexMakeMemoryPersistent(fi->fields);
    strcpy(fi->fields,fields);
    
    /* Determine the number of fields */
    n = 0;
    s = strtok(fields,",");
    while (s != NULL)
    {
	++n;
	s = strtok(NULL,",");
    }
    fi->n = n;
    
    if (n>0)
    {
	fi->index = mxCalloc(n,sizeof(int32)); 
	mexMakeMemoryPersistent(fi->index);
	
	fi->data_type = mxCalloc(n,sizeof(int32)); 
	mexMakeMemoryPersistent(fi->data_type);
	
	fi->order = mxCalloc(n,sizeof(int32)); 
	mexMakeMemoryPersistent(fi->order);

	/* For each field, determine the index, data_type, and order */
	s = fields;
	for (i=0; i<n; i++)
	{
	    status = VSfindex(vdata_id,s,&index);
	    if (status != SUCCEED)
		goto failed;
	    fi->index[i] = index;
	    
	    data_type = VFfieldtype(vdata_id,index);
	    if (data_type == FAIL)
		goto failed;
	    fi->data_type[i] = data_type;
		
	    order = VFfieldorder(vdata_id,index);
	    if (order == FAIL)
		goto failed;
	    fi->order[i] = order;
	    
	    s += strlen(s)+1; /* Skip over the '\0' placed by strtok */
	}
    }
    return SUCCEED;
    
    
failed:
    /* Free partially allocated parts if necessary */
    if (fi != NULL)
	ForgetSetFields(fi->vdata_id);
	
    return FAIL;
}


/*
 * Get pointers to n, index, datatype, and order for the given vdata_id. 
 * Return SUCCEED or FAIL.  
 */
static intn GetFieldInfo(
    int32 vdata_id,
    const char **fields,     /* return fieldnames */
    int32 *n,		     /* return n */
    const int32 **index,     /* return index array */
    const int32 **data_type, /* return data_type array */
    const int32 **order	     /* return order array */
    )
{
    fieldinfo *fi = FindFieldInfoNode(vdata_id);
    
    if (fi != NULL)
    {
	*fields = fi->fields;
	*n = fi->n;
	*index = fi->index;
	*data_type = fi->data_type;
	*order = fi->order;
	
	return SUCCEED;
    }
    else
	return FAIL;
}

/****************************************************************
	     End of SetFields Utility functions
 ***************************************************************/
 

/*
 * hdfVSattach
 *
 * Purpose: gateway to VSattach()
 *
 * MATLAB usage:
 * vdata_id = hdf('VS', 'attach', file_id, vdata_ref, access)
 *     access can be 'r' or 'w'
 */
static void hdfVSattach(int nlhs,
			  mxArray *plhs[],
			  int nrhs,
			  const mxArray *prhs[])
{
    int32 file_id;
    int32 vdata_ref;
    int32 vdata_id;
    char *access;
    int32 status;

    haNarginChk(5, 5, nrhs);
    haNargoutChk(0, 1, nlhs);

    file_id = (int32) haGetDoubleScalar(prhs[2],"File identifier");
    vdata_ref = (int32) haGetDoubleScalar(prhs[3],"Vdata reference number");
    access = haGetString(prhs[4],"File access mode");
    
    if (strcmp(access,"r")!=0 && strcmp(access,"w")!=0)
	mexErrMsgTxt("Access must be one of 'r' or 'w'.");
	
    
    vdata_id = VSattach(file_id,vdata_ref,access);
    if (vdata_id != FAIL)
    {
	status = haAddIDToList(vdata_id, VSdata_ID_List);
	if (status == FAIL)
	{
	    /* Failed to add sd_id to the list. */
	    /* This might cause data loss later, so don't allow it. */
	    VSdetach(vdata_id);
	    vdata_id = FAIL;
	}
    }
    plhs[0] = haCreateDoubleScalar((double) vdata_id);
    
    mxFree(access);
}

/*
 * hdfVSattrinfo
 *
 * Purpose: gateway to VSattrinfo()
 *
 * MATLAB usage:
 * [name,data_type,count,nbytes,status] = hdf('VS', 'attrinfo', vdata_id, field_index, attr_index)
 *    field_index can an index number or 'vdata'.
 */
static void hdfVSattrinfo(int nlhs,
			  mxArray *plhs[],
			  int nrhs,
			  const mxArray *prhs[])
{
    int32 vdata_id;
    int32 attr_index;
    int32 field_index;
    char name[MAX_NC_NAME];
    int32 data_type;
    const char *data_type_str;
    int32 count;
    int32 nbytes;
    intn status;

    haNarginChk(5, 5, nrhs);
    haNargoutChk(0, 5, nlhs);

    vdata_id = (int32) haGetDoubleScalar(prhs[2], "Vdata identifier");
    field_index = haGetFieldIndex(prhs[3]);
    attr_index = (int32) haGetDoubleScalar(prhs[4], "Attribute index");

    status = VSattrinfo(vdata_id, field_index, attr_index, name, &data_type, &count, &nbytes);
    if (status == SUCCEED)
    {
	plhs[0] = mxCreateString(name);
	data_type_str = haGetDataTypeString(data_type);
	plhs[1] = mxCreateString(data_type_str);

	if (nlhs > 2)
	    plhs[2] = haCreateDoubleScalar((double) count);
	if (nlhs > 3)
	    plhs[3] = haCreateDoubleScalar((double) nbytes);
    }
    else
    {
	plhs[0] = EMPTYSTR;
	plhs[1] = EMPTYSTR;

	if (nlhs > 2)
	    plhs[2] = ZERO;
	if (nlhs > 3)
	    plhs[3] = ZERO;
    }
    
    if (nlhs > 4)
	plhs[4] = haCreateDoubleScalar((double) status);
}


/*
 * hdfVSDetachAndForget
 *
 * Detach vdata_id and forget any setfields information that has been saved.
 */ 
intn hdfVSDetachAndForget(
    int32 vdata_id
    )
{
    intn status;
    
    status = VSdetach(vdata_id);
    ForgetSetFields(vdata_id);
    
    return status;
}


/*
 * hdfVSdetach
 *
 * Purpose: gateway to VSdetach()
 *
 * MATLAB usage:
 * status = hdf('VS', 'detach', vdata_id)
 */
static void hdfVSdetach(int nlhs,
			   mxArray *plhs[],
			   int nrhs,
			   const mxArray *prhs[])
{
    int32 vdata_id;
    int32 status;

    haNarginChk(3, 3, nrhs);
    haNargoutChk(0, 1, nlhs);

    vdata_id = (int32) haGetDoubleScalar(prhs[2], "Vdata identifier");
    status = hdfVSDetachAndForget(vdata_id);
    if (status == SUCCEED)
    {
	haDeleteIDFromList(vdata_id, VSdata_ID_List);
    }
    
    plhs[0] = haCreateDoubleScalar((double) status);
}


/*
 * hdfVSelts
 *
 * Purpose: gateway to VSelts()
 *
 * MATLAB usage:
 * count = hdf('VS', 'elts', vdata_id)
 */
static void hdfVSelts(int nlhs,
		     mxArray *plhs[],
		     int nrhs,
		     const mxArray *prhs[])
{
    int32 vdata_id;
    intn status;

    haNarginChk(3, 3, nrhs);
    haNargoutChk(0, 1, nlhs);

    vdata_id = (int32) haGetDoubleScalar(prhs[2], "Vdata identifier");
    status = VSelts(vdata_id);

    plhs[0] = haCreateDoubleScalar((double) status);
}

/*
 * hdfVSfdefine
 *
 * Purpose: gateway to VSfdefine()
 *
 * MATLAB usage:
 * status = hdf('VS', 'fdefine', vdata_id, fieldname, data_type, order)
 */
static void hdfVSfdefine(int nlhs,
			 mxArray *plhs[],
			 int nrhs,
			 const mxArray *prhs[])
{
    int32 id;
    char *fieldname;
    int32 data_type;
    int32 order;
    intn status;

    haNarginChk(6, 6, nrhs);
    haNargoutChk(0, 1, nlhs);

    id = (int32) haGetDoubleScalar(prhs[2], "Vdata identifier");
    fieldname = haGetString(prhs[3], "Field name");
    data_type = haGetDataType(prhs[4]);
    order = (int32) haGetDoubleScalar(prhs[5],"Order");
    
    status = VSfdefine(id, fieldname, data_type, order);

    plhs[0] = haCreateDoubleScalar((double) status);

    mxFree(fieldname);
}


/*
 * hdfVSfexist
 *
 * Purpose: gateway to VSfexist()
 *
 * MATLAB usage:
 * status = hdf('VS', 'fexist', vdata_id, fields)
 */
static void hdfVSfexist(int nlhs,
		     mxArray *plhs[],
		     int nrhs,
		     const mxArray *prhs[])
{
    int32 vdata_id;
    char *fields;
    intn status;

    haNarginChk(4, 4, nrhs);
    haNargoutChk(0, 1, nlhs);

    vdata_id = (int32) haGetDoubleScalar(prhs[2], "Vdata identifier");
    fields = haGetString(prhs[3],"Field names");
    
    status = VSfexist(vdata_id,fields);

    plhs[0] = haCreateDoubleScalar((double) status);
    
    mxFree(fields);
}


/*
 * hdfVSfind
 *
 * Purpose: gateway to VSfind()
 *
 * MATLAB usage:
 * vdata_ref = hdf('VS', 'find', file_id, vdata_name)
 */
static void hdfVSfind(int nlhs,
		     mxArray *plhs[],
		     int nrhs,
		     const mxArray *prhs[])
{
    int32 file_id;
    char *vdata_name;
    int32 vdata_ref;

    haNarginChk(4, 4, nrhs);
    haNargoutChk(0, 1, nlhs);

    file_id = (int32) haGetDoubleScalar(prhs[2], "Vfile identifier");
    vdata_name = haGetString(prhs[3],"Vdata name");
    
    vdata_ref = VSfind(file_id,vdata_name);
    
    plhs[0] = haCreateDoubleScalar((double) vdata_ref);
    
    mxFree(vdata_name);
}


/*
 * hdfVSfindex
 *
 * Purpose: gateway to VSfindex()
 *
 * MATLAB usage:
 * [field_index,status] = hdf('VS', 'findex', vdata_id, fieldname)
 *    field_index can be an index number or 'vdata'.
 */
static void hdfVSfindex(int nlhs,
		     mxArray *plhs[],
		     int nrhs,
		     const mxArray *prhs[])
{
    int32 vdata_id;
    char *fieldname;
    int32 field_index;
    intn status;

    haNarginChk(4, 4, nrhs);
    haNargoutChk(0, 2, nlhs);

    vdata_id = (int32) haGetDoubleScalar(prhs[2], "Vdata identifier");
    fieldname = haGetString(prhs[3],"Field name");
    
    status = VSfindex(vdata_id,fieldname,&field_index);
    
    plhs[0] = haCreateDoubleScalar((double) field_index);
    if (nlhs > 1)
	plhs[1] = haCreateDoubleScalar((double) status);
    
    mxFree(fieldname);
}


/*
 * hdfVSfindattr
 *
 * Purpose: gateway to VSfindattr()
 *
 * MATLAB usage:
 * attr_index = hdf('VS', 'findattr', vdata_id, field_index, attr_name)
 *    field_index can be an index number or 'vdata'.
 */
static void hdfVSfindattr(int nlhs,
		     mxArray *plhs[],
		     int nrhs,
		     const mxArray *prhs[])
{
    int32 vdata_id;
    char *attr_name;
    int32 field_index;
    intn attr_index;

    haNarginChk(5, 5, nrhs);
    haNargoutChk(0, 1, nlhs);

    vdata_id = (int32) haGetDoubleScalar(prhs[2], "Vdata identifier");
    field_index = haGetFieldIndex(prhs[3]);
    attr_name = haGetString(prhs[4],"Attribute name");
    
    attr_index = VSfindattr(vdata_id,field_index,attr_name);
    
    plhs[0] = haCreateDoubleScalar((double) attr_index);
    
    mxFree(attr_name);
}


/*
 * hdfVSfindclass
 *
 * Purpose: gateway to VSfindclass()
 *
 * MATLAB usage:
 * vdata_ref = hdf('VS', 'findclass', file_id, vdata_class)
 */
static void hdfVSfindclass(int nlhs,
		     mxArray *plhs[],
		     int nrhs,
		     const mxArray *prhs[])
{
    int32 file_id;
    char *vdata_class;
    intn vdata_ref;

    haNarginChk(4, 4, nrhs);
    haNargoutChk(0, 1, nlhs);

    file_id = (int32) haGetDoubleScalar(prhs[2], "Vfile identifier");
    vdata_class = haGetString(prhs[3],"Vdata class");
    
    vdata_ref = VSfindclass(file_id,vdata_class);
    
    plhs[0] = haCreateDoubleScalar((double) vdata_ref);
    
    mxFree(vdata_class);
}


/*
 * hdfVSfnattrs
 *
 * Purpose: gateway to VSfnattrs()
 *
 * MATLAB usage:
 * count = hdf('VS', 'fnattrs', vdata_id, field_index)
 *    field_index can be an index number or 'vdata'.
 */
static void hdfVSfnattrs(int nlhs,
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
    field_index = haGetFieldIndex(prhs[3]);
    
    status = VSfnattrs(vdata_id,field_index);
    
    plhs[0] = haCreateDoubleScalar((double) status);
}


/*
 * hdfVSfpack
 *
 * Purpose: gateway to VSfpack()
 *
 * MATLAB usage:
 * [buf,status] = hdf('VS', 'fpack', vdata_id, 'pack', fields_in_buf, n, fields, data)
 * [data,status] = hdf('VS', 'fpack', vdata_id, 'unpack', fields_in_buf, buf, n, fields)
 */
static void hdfVSfpack(int nlhs,
			  mxArray *plhs[],
			  int nrhs,
			  const mxArray *prhs[])
{
    mexErrMsgTxt("This function isn't supported.");
}


/*
 * hdfVSgetattr
 *
 * Purpose: gateway to VSgetattr()
 *
 * MATLAB usage:
 * [values,status] = hdf('VS', 'getattr', vdata_id, field_index, attr_index)
 *    field_index can be an index number or 'vdata'.
 */
static void hdfVSgetattr(int nlhs,
                         mxArray *plhs[],
                         int nrhs,
                         const mxArray *prhs[])
{
    int32 vdata_id;
    int32 field_index;
    int32 attr_index;
    int32 data_type;
    int32 count;
    intn status;
    int siz[2];
    VOIDP data;
    bool ok_to_free_data;

    haNarginChk(5, 5, nrhs);
    haNargoutChk(0, 2, nlhs);

    vdata_id = (int32) haGetDoubleScalar(prhs[2], "Vdata identifier");
    field_index = haGetFieldIndex(prhs[3]);
    attr_index = (intn) haGetDoubleScalar(prhs[4], "Attribute index");

    /* Determine datatype and size of the attribute values */
    status = VSattrinfo(vdata_id, field_index, attr_index, NULL, &data_type, &count, NULL);
    if (status == SUCCEED)
    {
	siz[0] = 1;
	siz[1] = count;

        data = haMakeHDFDataBuffer(count, data_type);
        if (data == NULL)
        {
            plhs[0] = EMPTY;
            if (nlhs > 1) plhs[1] = haCreateDoubleScalar((double) FAIL);
            return;
        }
        
        status = VSgetattr(vdata_id, field_index, attr_index, data);
        if (status != SUCCEED)
        {
            mxFree(data);
            plhs[0] = EMPTY;
            if (nlhs > 1) plhs[1] = haCreateDoubleScalar((double) FAIL);
            return;
        }
        
        plhs[0] = haMakeArrayFromHDFDataBuffer(2, siz, data_type, data,
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
    }
    else
    {
	plhs[0] = EMPTY;
    }
    
    if (nlhs > 1)
	plhs[1] = haCreateDoubleScalar((double) status);
}


/*
 * hdfVSgetclass
 *
 * Purpose: gateway to VSgetclass()
 *
 * MATLAB usage:
 * [class_name,status] = hdf('VS', 'getclass', vdata_id)
 */
static void hdfVSgetclass(int nlhs,
		     mxArray *plhs[],
		     int nrhs,
		     const mxArray *prhs[])
{
    int32 vdata_id;
    intn status;
    char name[VSNAMELENMAX];

    haNarginChk(3, 3, nrhs);
    haNargoutChk(0, 2, nlhs);

    vdata_id = (int32) haGetDoubleScalar(prhs[2], "Vdata identifier");
    
    status = VSgetclass(vdata_id,name);
    
    plhs[0] = mxCreateString(name);
    if (nlhs > 1)
	plhs[1] = haCreateDoubleScalar((double) status);
}


/*
 * hdfVSgetfields
 *
 * Purpose: gateway to VSgetfields()
 *
 * MATLAB usage:
 * [field_names,count] = hdf('VS', 'getfields', vdata_id)
 */
static void hdfVSgetfields(int nlhs,
		     mxArray *plhs[],
		     int nrhs,
		     const mxArray *prhs[])
{
    int32 vdata_id;
    intn status;
    char name[VSFIELDMAX*(FIELDNAMELENMAX+1)];

    haNarginChk(3, 3, nrhs);
    haNargoutChk(0, 2, nlhs);

    vdata_id = (int32) haGetDoubleScalar(prhs[2], "Vdata identifier");
    
    status = VSgetfields(vdata_id,name);
    
    plhs[0] = mxCreateString(name);
    if (nlhs > 1)
	plhs[1] = haCreateDoubleScalar((double) status);
}


/*
 * hdfVSgetid
 *
 * Purpose: gateway to VSgetid()
 *
 * MATLAB usage:
 * next_ref = hdf('VS', 'getid', file_id, vdata_ref)
 */
static void hdfVSgetid(int nlhs,
		     mxArray *plhs[],
		     int nrhs,
		     const mxArray *prhs[])
{
    int32 file_id;
    int32 vdata_ref;
    int32 next_ref;

    haNarginChk(4, 4, nrhs);
    haNargoutChk(0, 1, nlhs);

    file_id = (int32) haGetDoubleScalar(prhs[2], "Vfile identifier");
    vdata_ref = (int32) haGetDoubleScalar(prhs[3], "Vdata reference number");
    
    next_ref = VSgetid(file_id,vdata_ref);
    
    plhs[0] = haCreateDoubleScalar((double) next_ref);
}


/*
 * hdfVSgetinterlace
 *
 * Purpose: gateway to VSgetinterlace()
 *
 * MATLAB usage:
 * [interlace,status] = hdf('VS', 'getinterlace', vdata_id)
 */
static void hdfVSgetinterlace(int nlhs,
		     mxArray *plhs[],
		     int nrhs,
		     const mxArray *prhs[])
{
    int32 vdata_id;
    int32 status;

    haNarginChk(3, 3, nrhs);
    haNargoutChk(0, 2, nlhs);

    vdata_id = (int32) haGetDoubleScalar(prhs[2], "Vdata identifier");
    
    status = VSgetinterlace(vdata_id);
    if (status != FAIL)
    {
	if (status == FULL_INTERLACE)
	    plhs[0] = mxCreateString("full");
	else if (status == NO_INTERLACE)
	    plhs[0] = mxCreateString("no");
	else
	    plhs[0] = mxCreateString("Unknown interlace");
    }
    else
	plhs[0] = EMPTYSTR;

    if (nlhs > 1)
	plhs[1] = haCreateDoubleScalar((double) status);
}


/*
 * hdfVSgetname
 *
 * Purpose: gateway to VSgetname()
 *
 * MATLAB usage:
 * [vdata_name,status] = hdf('VS', 'getname', vdata_id)
 */
static void hdfVSgetname(int nlhs,
		     mxArray *plhs[],
		     int nrhs,
		     const mxArray *prhs[])
{
    int32 vdata_id;
    int32 status;
    char name[VSNAMELENMAX];

    haNarginChk(3, 3, nrhs);
    haNargoutChk(0, 2, nlhs);

    vdata_id = (int32) haGetDoubleScalar(prhs[2], "Vdata identifier");
    
    status = VSgetname(vdata_id,name);
    
    plhs[0] = mxCreateString(name);
    if (nlhs > 1)
	plhs[1] = haCreateDoubleScalar((double) status);
}


/*
 * hdfVSgetversion
 *
 * Purpose: gateway to VSgetversion()
 *
 * MATLAB usage:
 * version = hdf('VS', 'getversion', vdata_id)
 */
static void hdfVSgetversion(int nlhs,
		     mxArray *plhs[],
		     int nrhs,
		     const mxArray *prhs[])
{
    int32 vdata_id;
    int32 version;

    haNarginChk(3, 3, nrhs);
    haNargoutChk(0, 2, nlhs);

    vdata_id = (int32) haGetDoubleScalar(prhs[2], "Vdata identifier");
    
    version = VSgetversion(vdata_id);
    
    plhs[0] = haCreateDoubleScalar((double) version);
}





/*
 * hdfVSinquire
 *
 * Purpose: gateway to VSinquire()
 *
 * MATLAB usage:
 * [n,interlace,fields,nbytes,vdata_name,status] = hdf('VS', 'inquire', vdata_id)
 */
static void hdfVSinquire(int nlhs,
			  mxArray *plhs[],
			  int nrhs,
			  const mxArray *prhs[])
{
    int32 vdata_id;
    int32 n;
    int32 interlace;
    char fields[FIELDNAMELENMAX*VSFIELDMAX];
    int32 nbytes;
    char name[VSNAMELENMAX];
    int32 status;

    haNarginChk(3, 3, nrhs);
    haNargoutChk(0, 6, nlhs);

    vdata_id = (int32) haGetDoubleScalar(prhs[2], "Vdata identifier");
    
    status = VSinquire(vdata_id,&n,&interlace,fields,&nbytes,name);
    if (status == SUCCEED)
    {
	plhs[0] = haCreateDoubleScalar((double) n);
	if (nlhs > 1)
	{
	    if (interlace == FULL_INTERLACE)
		plhs[1] = mxCreateString("full");
	    else if (interlace == NO_INTERLACE)
		plhs[1] = mxCreateString("no");
	    else
		plhs[1] = mxCreateString("Unknown interlace");
	}
	if (nlhs > 2)
	    plhs[2] = mxCreateString(fields);
	if (nlhs > 3)
	    plhs[3] = haCreateDoubleScalar((double) nbytes);
	if (nlhs > 4)
	    plhs[4] = mxCreateString(name);
    }
    else
    {
	plhs[0] = ZERO;
	if (nlhs > 1)
	    plhs[1] = EMPTYSTR;
	if (nlhs > 2)
	    plhs[2] = EMPTYSTR;
	if (nlhs > 3)
	    plhs[3] = ZERO;
	if (nlhs > 4)
	    plhs[4] = EMPTYSTR;
    }
    if (nlhs > 5)
	plhs[5] = haCreateDoubleScalar((double) status);
}


/*
 * hdfVSisattr
 *
 * Purpose: gateway to VSisattr()
 *
 * MATLAB usage:
 * tf = hdf('VS', 'isattr', vdata_id)
 */
static void hdfVSisattr(int nlhs,
			  mxArray *plhs[],
			  int nrhs,
			  const mxArray *prhs[])
{
    int32 vdata_id;
    int32 status;

    haNarginChk(3, 3, nrhs);
    haNargoutChk(0, 1, nlhs);

    vdata_id = (int32) haGetDoubleScalar(prhs[2], "Vdata identifier");
    
    status = VSisattr(vdata_id);
    plhs[0] = haCreateDoubleScalar((double) status);
}


/*
 * hdfVSlone
 *
 * Purpose: gateway to VSlone()
 *
 * MATLAB usage:
 * [refs,count] = hdf('VS', 'lone', file_id, maxsize)
 */
static void hdfVSlone(int nlhs,
		     mxArray *plhs[],
		     int nrhs,
		     const mxArray *prhs[])
{
    int32 file_id;
    int32 maxsize;
    int32 count;
    int32 *refs;
    int i;
    int n;
    double *pr;

    haNarginChk(4, 4, nrhs);
    haNargoutChk(0, 2, nlhs);

    file_id = (int32) haGetDoubleScalar(prhs[2], "Vfile identifier");
    maxsize = (int32) haGetDoubleScalar(prhs[3], "Maxsize specifier");
    
    refs = mxCalloc(maxsize,sizeof(int32));
    
    count = VSlone(file_id,refs,maxsize);
    if (count != FAIL)
    {
	n = MIN(count,maxsize);
	plhs[0] = mxCreateDoubleMatrix(1,n,mxREAL);
	pr = mxGetPr(plhs[0]);
	for (i=0; i<n; i++)
	    pr[i] = (double)refs[i];
    }
    else
    {
	plhs[0] = EMPTY;
    }
    if (nlhs > 1)
	    plhs[1] = haCreateDoubleScalar((double) count);
}


/*
 * hdfVSnattrs
 *
 * Purpose: gateway to VSnattrs()
 *
 * MATLAB usage:
 * count = hdf('VS', 'nattrs', vdata_id)
 */
static void hdfVSnattrs(int nlhs,
		     mxArray *plhs[],
		     int nrhs,
		     const mxArray *prhs[])
{
    int32 vdata_id;
    int32 status;

    haNarginChk(3, 3, nrhs);
    haNargoutChk(0, 1, nlhs);

    vdata_id = (int32) haGetDoubleScalar(prhs[2], "Vdata identifier");
    
    status = VSnattrs(vdata_id);
    
    plhs[0] = haCreateDoubleScalar((double) status);
}


/*
 * hdfVSread
 *
 * Purpose: gateway to VSread()
 *
 * MATLAB usage:
 * [data, count] = hdf('VS','read', vdata_id, n)
 *    Data is returned in a nfields-by-1 cell array.  Each
 *    cell will contain a order(i)-by-n vector of data where order(i) is the number of scalar
 *    values in each field.  The fields are returned in the same
 *    order as specified in hdfVSsetfields.
 */
static void hdfVSread(int nlhs,
		      mxArray *plhs[],
		      int nrhs,
		      const mxArray *prhs[])
{
    intn status;
    int32 vdata_id; 
    int32 n;
    int i;
    int nbytes;
    int32 count;
    int32 nfields;
    const int32 *index;
    const int32 *data_type;
    const int32 *order;
    const char *infoFields;
    char *fields;
    mxArray *tmp;
    bool ok_to_free_bufptr;

    haNarginChk(4, 4, nrhs);
    haNargoutChk(0, 2, nlhs);

    vdata_id = (int32) haGetDoubleScalar(prhs[2], "Vdata identifier");
    n = (int32) haGetDoubleScalar(prhs[3],"Number of records");
    
    /* Determine the number of fields, their index, data_type, and order */
    status = GetFieldInfo(vdata_id,&infoFields,&nfields,&index,&data_type,&order);
    if (status != FAIL)
    {	
        fields = mxCalloc(strlen(infoFields)+1,sizeof(char));
        strcpy(fields,infoFields);

        /* Determine size of required data buffer */
	status = nbytes = VSsizeof(vdata_id,fields);
	if (status != FAIL)
	{
	    VOIDP data = mxCalloc(n,nbytes);
	
	    status = count = VSread(vdata_id,data,n,FULL_INTERLACE);
	    if (status != FAIL)
	    {
		/* Set up bufptrs for VSfpack */
		VOIDP *bufptrs = mxCalloc(nfields,sizeof(VOIDP));
		
		plhs[0] = mxCreateCellMatrix(nfields, 1);
		for (i=0; i<nfields; i++)
		{
                    bufptrs[i] = haMakeHDFDataBuffer(count*order[i], data_type[i]);
		}
		
		/* Unpack data into array buffers */
		status = VSfpack(vdata_id,_HDF_VSUNPACK,fields,data,n*nbytes,count,
                                 NULL,bufptrs);
		if (status == FAIL)
		    mxDestroyArray(plhs[0]);
		else
		{
                    int siz[2];
		    for (i=0; i<nfields; i++)
		    {
                        siz[0] = order[i];
                        siz[1] = count;
                        tmp = haMakeArrayFromHDFDataBuffer(2,siz,data_type[i],
                                                           bufptrs[i],
                                                           &ok_to_free_bufptr);
                        if (ok_to_free_bufptr)
                        {
                            mxFree(bufptrs[i]);
                        }
                        mxSetCell(plhs[0], i, tmp);
                    }
                }
		mxFree(bufptrs);
	    }
	    mxFree(data);
        }
        mxFree(fields);
    }
    
    if (status == FAIL)
	plhs[0] = mxCreateCellMatrix(1,0);
	
    if (nlhs > 1)
    {
	if (status != FAIL)
	    plhs[1] = haCreateDoubleScalar((double) count);
	else
	    plhs[1] = haCreateDoubleScalar((double) status);
    }
}


/*
 * hdfVSseek
 *
 * Purpose: gateway to VSseek()
 *
 * MATLAB usage:
 * pos = hdf('VS', 'seek', vdata_id, record)
 */
static void hdfVSseek(int nlhs,
		     mxArray *plhs[],
		     int nrhs,
		     const mxArray *prhs[])
{
    int32 vdata_id;
    int32 record;
    int32 pos;

    haNarginChk(4, 4, nrhs);
    haNargoutChk(0, 1, nlhs);

    vdata_id = (int32) haGetDoubleScalar(prhs[2], "Vdata identifier");
    record = (int32) haGetDoubleScalar(prhs[3], "Record number");
    
    pos = VSseek(vdata_id,record);
    
    plhs[0] = haCreateDoubleScalar((double) pos);
}


/*
 * hdfVSsetattr
 *
 * Purpose: gateway to VSsetattr()
 *
 * MATLAB usage:
 * status = hdf('VS', 'setattr', vdata_id, field_index, name, A)
 *    field_index can an index number or 'vdata'.
 */
static void hdfVSsetattr(int nlhs,
			 mxArray *plhs[],
			 int nrhs,
			 const mxArray *prhs[])
{
    int32 id;
    int32 field_index;
    char *name;
    char *buffer = NULL;
    const mxArray *A;
    int32 data_type;
    int32 count;
    VOIDP values;
    bool free_values = false;
    intn status;

    haNarginChk(6, 6, nrhs);
    haNargoutChk(0, 1, nlhs);

    id = (int32) haGetDoubleScalar(prhs[2], "Vdata identifier");
    field_index = haGetFieldIndex(prhs[3]);
    name = haGetString(prhs[4], "Attribute name");
    
    A = prhs[5];
    data_type = haGetDataTypeFromClassID(mxGetClassID(A));
    count = mxGetNumberOfElements(A);

    if (mxGetClassID(A) == mxCHAR_CLASS)
    {
        values = haMakeHDFDataBufferFromCharArray(A,data_type);
        free_values = true;
    }
    else
    {
	values = mxGetData(A);
    }

    status = VSsetattr(id, field_index, name, data_type, count, values);

    plhs[0] = haCreateDoubleScalar((double) status);

    mxFree(name);
    if (free_values)
    {
	mxFree(values);
    }
}

/*
 * hdfVSsetclass
 *
 * Purpose: gateway to VSsetclass()
 *
 * MATLAB usage:
 * status = hdf('VS', 'setclass', vdata_id, class)
 */
static void hdfVSsetclass(int nlhs,
			 mxArray *plhs[],
			 int nrhs,
			 const mxArray *prhs[])
{
    int32 status;
    int32 vdata_id;
    char *name;
    
    haNarginChk(4, 4, nrhs);
    haNargoutChk(0, 1, nlhs);

    vdata_id = (int32) haGetDoubleScalar(prhs[2], "Vdata identifier");
    name = haGetString(prhs[3],"Class name");
	
    status = VSsetclass(vdata_id,name);
    
    plhs[0] = haCreateDoubleScalar((double) status);
    
    mxFree(name);
}

/*
 * hdfVSsetexternalfile
 *
 * Purpose: gateway to VSsetexternalfile()
 *
 * MATLAB usage:
 * status = hdf('VS', 'setexternalfile', vdata_id, filename, offset)
 */
static void hdfVSsetexternalfile(int nlhs,
				 mxArray *plhs[],
				 int nrhs,
				 const mxArray *prhs[])
{
    int32 vdata_id;
    char *filename;
    int32 offset;
    intn status;

    haNarginChk(5, 5, nrhs);
    haNargoutChk(0, 1, nlhs);

    vdata_id = (int32) haGetDoubleScalar(prhs[2], "Vdata identifier");
    filename = haGetString(prhs[3], "External filename");
    offset = (int32) haGetDoubleScalar(prhs[4], "Offset");

    status = VSsetexternalfile(vdata_id, filename, offset);

    plhs[0] = haCreateDoubleScalar((double) status);

    mxFree(filename);
}
 
 
/*
 * hdfVSsetfields
 *
 * Purpose: gateway to VSsetfields()
 *
 * MATLAB usage:
 * status = hdf('VS', 'setfields', vdata_id, fields)
 */
static void hdfVSsetfields(int nlhs,
			 mxArray *plhs[],
			 int nrhs,
			 const mxArray *prhs[])
{
    int32 status;
    int32 vdata_id;
    char *names;
    
    haNarginChk(4, 4, nrhs);
    haNargoutChk(0, 1, nlhs);

    vdata_id = (int32) haGetDoubleScalar(prhs[2], "Vdata identifier");
    names = haGetString(prhs[3],"Field names");
	
    status = VSsetfields(vdata_id,names);
    if (status != FAIL)
    {
	status = RememberSetFields(vdata_id,names);
    }
	
    plhs[0] = haCreateDoubleScalar((double) status);
    
    mxFree(names);
}


/*
 * hdfVSsetinterlace
 *
 * Purpose: gateway to VSsetinterlace()
 *
 * MATLAB usage:
 * status = hdf('VS', 'setinterlace', vdata_id, interlace)
 */
static void hdfVSsetinterlace(int nlhs,
			 mxArray *plhs[],
			 int nrhs,
			 const mxArray *prhs[])
{
    int32 status;
    int32 vdata_id;
    int32 interlace;
    char *interlace_str;
    
    haNarginChk(4, 4, nrhs);
    haNargoutChk(0, 1, nlhs);

    vdata_id = (int32) haGetDoubleScalar(prhs[2], "Vdata identifier");
    interlace_str = haGetString(prhs[3],"Interlace mode");
    if (strcmp(interlace_str,"full")==0)
	interlace = FULL_INTERLACE;
    else if (strcmp(interlace_str,"no")==0)
	interlace = NO_INTERLACE;
    else
    {
	mxFree(interlace_str);
	mexErrMsgTxt("Interlace mode must be either 'full' or 'no'.");
    }
	
    status = VSsetinterlace(vdata_id,interlace);
    
    plhs[0] = haCreateDoubleScalar((double) status);

    mxFree(interlace_str);
}


/*
 * hdfVSsetname
 *
 * Purpose: gateway to VSsetname()
 *
 * MATLAB usage:
 * status = hdf('VS', 'setname', vdata_id, name)
 */
static void hdfVSsetname(int nlhs,
			 mxArray *plhs[],
			 int nrhs,
			 const mxArray *prhs[])
{
    int32 status;
    int32 vdata_id;
    char *name;
    
    haNarginChk(4, 4, nrhs);
    haNargoutChk(0, 1, nlhs);

    vdata_id = (int32) haGetDoubleScalar(prhs[2], "Vdata identifier");
    name = haGetString(prhs[3],"Vdata name");
	
    status = VSsetname(vdata_id,name);
    
    plhs[0] = haCreateDoubleScalar((double) status);
    
    mxFree(name);
}


/*
 * hdfVSsizeof
 *
 * Purpose: gateway to VSsizeof()
 *
 * MATLAB usage:
 * nbytes = hdf('VS', 'sizeof', vdata_id, fields)
 */
static void hdfVSsizeof(int nlhs,
		     mxArray *plhs[],
		     int nrhs,
		     const mxArray *prhs[])
{
    int32 vdata_id;
    char *fields;
    int32 status;

    haNarginChk(4, 4, nrhs);
    haNargoutChk(0, 1, nlhs);

    vdata_id = (int32) haGetDoubleScalar(prhs[2], "Vdata identifier");
    fields = haGetString(prhs[3],"Field names");
    
    status = VSsizeof(vdata_id,fields);
    
    plhs[0] = haCreateDoubleScalar((double) status);
    
    mxFree(fields);
}


/*
 * hdfVSwrite
 *
 * Purpose: gateway to VSwrite()
 *
 * MATLAB usage:
 * count = hdf('VS','write', vdata_id, data)
 *    data must be an nfields-by-1 cell array.
 *    each cell must contain an order(i)-by-n vector of data where order(i) is
 *    the number of scalar values in each field.  The types of the data must
 *    match the field types set via hdfVSsetfields.
 */
static void hdfVSwrite(int nlhs,
                       mxArray *plhs[],
                       int nrhs,
                       const mxArray *prhs[])
{
    intn status;
    int32 vdata_id; 
    int32 n;
    int i;
    int nbytes;
    int32 count;
    int32 nfields;
    const int32 *index;
    const int32 *data_type;
    int32 this_data_type;
    const int32 *order;
    const char *infoFields;
    char *fields;
    const mxArray *datacell;

    haNarginChk(4, 4, nrhs);
    haNargoutChk(0, 1, nlhs);

    vdata_id = (int32) haGetDoubleScalar(prhs[2], "Vdata identifier");
    datacell = prhs[3];
    if (mxGetClassID(datacell) != mxCELL_CLASS)
	mexErrMsgTxt("Data must be a cell array.");
    
    
    /* Determine the number of fields, their index, data_type, and order */
    if (FindFieldInfoNode(vdata_id) == NULL)
    {
	char fieldnames[VSFIELDMAX*(FIELDNAMELENMAX+1)];

	/* 
	 * If the vdatas already exists, a call to VSsetfields is not necessary 
	 * so fill in the setfield info for all the fields
	 */
	status = VSgetfields(vdata_id,fieldnames);
	if (status != FAIL)
	{
	    RememberSetFields(vdata_id,fieldnames);
	    status = GetFieldInfo(vdata_id,&infoFields,&nfields,
                                  &index,&data_type,&order);
	}
    }
    else
    {
	status = GetFieldInfo(vdata_id,&infoFields,&nfields,&index,
                              &data_type,&order);
    }
    
    if (status != FAIL)
    {
        fields = mxCalloc(strlen(infoFields)+1,sizeof(char));
        strcpy(fields,infoFields);

	/* Consistency checks on the input data */
	if (nfields != mxGetNumberOfElements(datacell))
	    mexErrMsgTxt("Cell array length must match the number of "
                         "specified fields.");
	
	n = -1;
	for (i=0; i<nfields; i++)
	{
	    mxArray *cell = mxGetCell(datacell,i);

	    if (haGetClassIDFromDataType(data_type[i]) != mxGetClassID(cell))
	    {
		mexErrMsgTxt("Data class must match field class.");
	    }
	    if (mxGetM(cell) != order[i])
		mexErrMsgTxt("Number of rows of data must match order "
                             "of field.");
	
	    if (n < 0)
		n = mxGetN(cell);
		
	    if (mxGetN(cell) != n)
		mexErrMsgTxt("Number of columns of each element of data "
                             "must be the same.");
	}
	
	/* Determine size of required data buffer */
	status = nbytes = VSsizeof(vdata_id,fields);
	if (status != FAIL)
	{
	    VOIDP data = mxCalloc(n,nbytes);
            /* bufptrs for VSfpack */
	    VOIDP *bufptrs = mxCalloc(nfields,sizeof(VOIDP)); 

	    /* Set up bufptrs */
	    for (i=0; i<nfields; i++)
	    {
                this_data_type = data_type[i];
                if (haGetClassIDFromDataType(this_data_type) == mxCHAR_CLASS)
                {
                    bufptrs[i] = haMakeHDFDataBufferFromCharArray(mxGetCell(datacell,i),
                                                                  this_data_type);
                }
		else
		{
		    bufptrs[i] = mxGetData(mxGetCell(datacell,i));
		}
	    }
	    
	    /* Pack array buffers into data */
	    status = VSfpack(vdata_id,_HDF_VSPACK,fields,data,n*nbytes,n,
                             NULL,bufptrs);
	
	    status = count = VSwrite(vdata_id,data,n,FULL_INTERLACE);

	    /* Destroy temporary character buffers */
	    for (i=0; i<nfields; i++)
	    {
                if (haGetClassIDFromDataType(data_type[i]) == mxCHAR_CLASS)
                {
                    mxFree(bufptrs[i]);
                }
            }
	    mxFree(bufptrs);
	    mxFree(data);
	}
	mxFree(fields);
    }
    plhs[0] = haCreateDoubleScalar((double) status);	
}


/*
 * hdfVSQuerycount
 *
 * Purpose: gateway to VSQuerycount()
 *
 * MATLAB usage:
 * [count,status] = hdf('VS', 'Querycount', vdata_id)
 */
static void hdfVSQuerycount(int nlhs,
			 mxArray *plhs[],
			 int nrhs,
			 const mxArray *prhs[])
{
    int32 vdata_id;
    int32 count;
    intn status;

    haNarginChk(3, 3, nrhs);
    haNargoutChk(0, 2, nlhs);

    vdata_id = (int32) haGetDoubleScalar(prhs[2], "Vdata identifier");
    status = VSQuerycount(vdata_id,&count);
    
    if (status == SUCCEED)
	plhs[0] = haCreateDoubleScalar((double) count);
    else
	plhs[0] = ZERO;
    if (nlhs > 1)
	plhs[1] = haCreateDoubleScalar((double) status);
}


/*
 * hdfVSQueryfields
 *
 * Purpose: gateway to VSQueryfields()
 *
 * MATLAB usage:
 * [fields,status] = hdf('VS', 'Queryfields', vdata_id)
 */
static void hdfVSQueryfields(int nlhs,
			 mxArray *plhs[],
			 int nrhs,
			 const mxArray *prhs[])
{
    int32 vdata_id;
    char fields[FIELDNAMELENMAX];
    intn status;

    haNarginChk(3, 3, nrhs);
    haNargoutChk(0, 2, nlhs);

    vdata_id = (int32) haGetDoubleScalar(prhs[2], "Vdata identifier");
    status = VSQueryfields(vdata_id,fields);
    
    if (status == SUCCEED)
	plhs[0] = mxCreateString(fields);
    else
	plhs[0] = EMPTYSTR;
	
    if (nlhs > 1)
	plhs[1] = haCreateDoubleScalar((double) status);
}


/*
 * hdfVSQueryinterlace
 *
 * Purpose: gateway to VSQueryinterlace()
 *
 * MATLAB usage:
 * [interlace,status] = hdf('VS', 'Queryinterlace', vdata_id)
 */
static void hdfVSQueryinterlace(int nlhs,
		     mxArray *plhs[],
		     int nrhs,
		     const mxArray *prhs[])
{
    int32 vdata_id;
    int32 interlace;
    int32 status;

    haNarginChk(3, 3, nrhs);
    haNargoutChk(0, 2, nlhs);

    vdata_id = (int32) haGetDoubleScalar(prhs[2], "Vdata identifier");
    
    status = VSQueryinterlace(vdata_id,&interlace);
    if (status != FAIL)
    {
	if (interlace == FULL_INTERLACE)
	    plhs[0] = mxCreateString("full");
	else if (interlace == NO_INTERLACE)
	    plhs[0] = mxCreateString("no");
	else
	    plhs[0] = mxCreateString("Unknown interlace");
    }
    else
	plhs[0] = EMPTYSTR;

    if (nlhs > 1)
	plhs[1] = haCreateDoubleScalar((double) status);
}


/*
 * hdfVSQueryname
 *
 * Purpose: gateway to VSQueryname()
 *
 * MATLAB usage:
 * [name,status] = hdf('VS', 'Queryname', vdata_id)
 */
static void hdfVSQueryname(int nlhs,
			 mxArray *plhs[],
			 int nrhs,
			 const mxArray *prhs[])
{
    int32 vdata_id;
    char name[VSNAMELENMAX];
    intn status;

    haNarginChk(3, 3, nrhs);
    haNargoutChk(0, 2, nlhs);

    vdata_id = (int32) haGetDoubleScalar(prhs[2], "Vdata identifier");
    status = VSQueryname(vdata_id,name);
    
    if (status == SUCCEED)
	plhs[0] = mxCreateString(name);
    else
	plhs[0] = EMPTYSTR;
    if (nlhs > 1)
	plhs[1] = haCreateDoubleScalar((double) status);
}


/*
 * hdfVSQueryref
 *
 * Purpose: gateway to VSQueryref()
 *
 * MATLAB usage:
 * ref = hdf('VS', 'Queryref', vdata_id)
 */
static void hdfVSQueryref(int nlhs,
			 mxArray *plhs[],
			 int nrhs,
			 const mxArray *prhs[])
{
    int32 vdata_id;
    int32 ref;

    haNarginChk(3, 3, nrhs);
    haNargoutChk(0, 1, nlhs);

    vdata_id = (int32) haGetDoubleScalar(prhs[2], "Vdata identifier");
    ref = VSQueryref(vdata_id);
    plhs[0] = haCreateDoubleScalar((double) ref);
}


/*
 * hdfVSQuerytag
 *
 * Purpose: gateway to VSQuerytag()
 *
 * MATLAB usage:
 * tag = hdf('VS', 'Querytag', vdata_id)
 */
static void hdfVSQuerytag(int nlhs,
			 mxArray *plhs[],
			 int nrhs,
			 const mxArray *prhs[])
{
    int32 vdata_id;
    int32 tag;

    haNarginChk(3, 3, nrhs);
    haNargoutChk(0, 1, nlhs);

    vdata_id = (int32) haGetDoubleScalar(prhs[2], "Vdata identifier");
    tag = VSQuerytag(vdata_id);
    plhs[0] = haCreateDoubleScalar((double) tag);
}


/*
 * hdfVSQueryvsize
 *
 * Purpose: gateway to VSQueryvsize()
 *
 * MATLAB usage:
 * [vsize,status] = hdf('VS', 'Queryvsize', vdata_id)
 */
static void hdfVSQueryvsize(int nlhs,
			 mxArray *plhs[],
			 int nrhs,
			 const mxArray *prhs[])
{
    int32 vdata_id;
    int32 vsize;
    intn status;

    haNarginChk(3, 3, nrhs);
    haNargoutChk(0, 2, nlhs);

    vdata_id = (int32) haGetDoubleScalar(prhs[2], "Vdata identifier");
    status = VSQueryvsize(vdata_id,&vsize);
    if (status == SUCCEED)
	plhs[0] = haCreateDoubleScalar((double) vsize);
    else
	plhs[0] = ZERO;
	
    if (nlhs > 1)
	plhs[1] = haCreateDoubleScalar((double) status);
}


/*
 * hdfVS
 *
 * Purpose: Function switchyard for the VS part of the HDF gateway.
 *
 * Inputs:  nlhs --- number of left-side arguments
 *	    plhs --- left-side arguments
 *	    nrhs --- number of right-side arguments
 *	    prhs --- right-side arguments
 *	    functionStr --- string specifying which function to call
 * Outputs: none
 * Return:  none
 */
void hdfVS(int nlhs,
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
	{"attach",hdfVSattach},
	{"attrinfo",hdfVSattrinfo},
	{"detach",hdfVSdetach},
	{"elts",hdfVSelts},
	{"fdefine",hdfVSfdefine},
	{"fexist",hdfVSfexist},
	{"find",hdfVSfind},
	{"findex",hdfVSfindex},
	{"findattr",hdfVSfindattr},
	{"findclass",hdfVSfindclass},
	{"fnattrs",hdfVSfnattrs},
	{"fpack",hdfVSfpack},
	{"getattr",hdfVSgetattr},
	{"getclass",hdfVSgetclass},
	{"getfields",hdfVSgetfields},
	{"getid",hdfVSgetid},
	{"getinterlace",hdfVSgetinterlace},
	{"getname",hdfVSgetname},
	{"getversion",hdfVSgetversion},
	{"inquire",hdfVSinquire},
	{"isattr",hdfVSisattr},
	{"lone",hdfVSlone},
	{"nattrs",hdfVSnattrs},
	{"read",hdfVSread},
	{"seek",hdfVSseek},
	{"setattr",hdfVSsetattr},
	{"setclass",hdfVSsetclass},
	{"setexternalfile",hdfVSsetexternalfile},
	{"setfields",hdfVSsetfields},
	{"setinterlace",hdfVSsetinterlace},
	{"setname",hdfVSsetname},
	{"sizeof",hdfVSsizeof},
	{"write",hdfVSwrite},
	{"Querycount",hdfVSQuerycount},
	{"Queryfields",hdfVSQueryfields},
	{"Queryinterlace",hdfVSQueryinterlace},
	{"Queryname",hdfVSQueryname},
	{"Queryref",hdfVSQueryref},
	{"Querytag",hdfVSQuerytag},
	{"Queryvsize",hdfVSQueryvsize},
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
    mexErrMsgTxt("Unknown HDF V interface function.");
}
