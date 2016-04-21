/* Copyright 1984-2002 The MathWorks, Inc.  */

/*
 * hdfv.c --- support file for HDF.MEX
 *
 * This module supports the HDF V interface.  The only public
 * function is hdfV(), which is called by mexFunction().
 * hdfV looks at the second input argument to determine which
 * private function should get control.
 *
 * Syntaxes
 * ========
 * status = hdf('V', 'addtagref', vgroup_id, tag, ref)
 * vgroup_id = hdf('V', 'attach', file_id, vgroup_ref, access)
 *     access can be 'r' or 'w'
 * [name,data_type,count,nbytes,status] = hdf('V', 'attrinfo', vgroup_id, attr_index)
 * status = hdf('V', 'detach', vgroup_id)
 * status = hdf('V', 'end', file_id)
 * vgroup_ref = hdf('V', 'find', file_id, vgroup_name)
 * attr_index = hdf('V', 'findattr', vgroup_id, attr_name)
 * vgroup_ref = hdf('V', 'findclass', file_id, vgroup_class)
 * vdata_ref = hdf('V', 'flocate', vgroup_id, field)
 * [values,status] = hdf('V', 'getattr', vgroup_id, attr_index)
 * [class_name,status] = hdf('V', 'getclass', vgroup_id)
 * next_ref = hdf('V', 'getid', file_id, vgroup_ref)
 * [vgroup_name,status] = hdf('V', 'getname', vgroup_id)
 * [tag,ref,status] = hdf('V', 'gettagref', vgroup_id, index)
 * [tags,refs,count] = hdf('V', 'gettagrefs', vgroup_id, maxsize)
 * version = hdf('V', 'getversion', vgroup_id)
 *      version will be 2, 3 or 4 corresponding to VSET_OLD_VERSION,VSET_VERSION, 
 *      or VSET_NEW_VERSION
 * [n,vgroup_name,status] = hdf('V', 'inquire', vgroup_id)
 * tf = hdf('V', 'inqtagref', vgroup_id, tag, ref)
 * ref = hdf('V', 'insert', vgroup_id, vdata_id/vgroup_id)
 * status = hdf('V', 'isvg', vgroup_id, vdata_ref/vgroup_ref)
 * status = hdf('V', 'isvs', vgroup_id, vdata_ref)
 * [refs,count] = hdf('V', 'lone', file_id, maxsize)
 * count = hdf('V', 'nattrs', vgroup_id)
 * count = hdf('V', 'nrefs', vgroup_id, tag)
 * count = hdf('V', 'ntagrefs', vgroup_id)
 * status = hdf('V', 'setattr', vgroup_id, name, A)
 * status = hdf('V', 'setclass', vgroup_id, class)
 * status = hdf('V', 'setname', vgroup_id, name)
 * status = hdf('V', 'start', file_id)
 * ref = hdf('V', 'Queryref', vgroup_id)
 * tag = hdf('V', 'Querytag', vgroup_id)
 */

/* $Revision: 1.1.6.1 $  $Date: 2003/12/13 03:02:25 $ */

static char rcsid[] = "$Id: hdfv.c,v 1.1.6.1 2003/12/13 03:02:25 batserve Exp $";

#include <string.h>
#include <math.h>

/* Main HDF library header file */
#include "hdf.h"

/* MATLAB API header file */
#include "mex.h"

/* HDFMEX utility functions */
#include "hdfutils.h"

#include "hdfv.h"

/*
 * hdfVaddtagref
 *
 * Purpose: gateway to Vaddtagref()
 *
 * MATLAB usage:
 * status = hdf('V', 'addtagref', vgroup_id, tag, ref)
 */
static void hdfVaddtagref(int nlhs,
                          mxArray *plhs[],
                          int nrhs,
                          const mxArray *prhs[])
{
    int32 vgroup_id;
    int32 tag;
    int32 ref;
    int32 status;

    haNarginChk(5, 5, nrhs);
    haNargoutChk(0, 1, nlhs);

    vgroup_id = (int32) haGetDoubleScalar(prhs[2], "Vgroup identifier");
    tag = (int32) haGetDoubleScalar(prhs[3],"Tag");
    ref = (int32) haGetDoubleScalar(prhs[4],"Reference number");
    
    status = Vaddtagref(vgroup_id,tag,ref);
    
    plhs[0] = haCreateDoubleScalar((double) status);
}
    

/*
 * hdfVattach
 *
 * Purpose: gateway to Vattach()
 *
 * MATLAB usage:
 * vgroup_id = hdf('V', 'attach', file_id, vgroup_ref, access)
 *     access can be 'r' or 'w'
 */
static void hdfVattach(int nlhs,
                          mxArray *plhs[],
                          int nrhs,
                          const mxArray *prhs[])
{
	int32 file_id;
    int32 vgroup_ref;
    int32 vgroup_id;
    char *access;
    int32 status;

    haNarginChk(5, 5, nrhs);
    haNargoutChk(0, 1, nlhs);

	file_id = (int32) haGetDoubleScalar(prhs[2],"File identifier");
	vgroup_ref = (int32) haGetDoubleScalar(prhs[3],"Vgroup reference number");
	access = haGetString(prhs[4],"File access mode");
	
	if (strcmp(access,"r")!=0 && strcmp(access,"w")!=0)
		mexErrMsgTxt("Access must be one of 'r' or 'w'.");		
	
    vgroup_id = Vattach(file_id,vgroup_ref,access);
    if (vgroup_id != FAIL)
    {
        status = haAddIDToList(vgroup_id, Vgroup_ID_List);
        if (status == FAIL)
        {
            /* Failed to add sd_id to the list. */
            /* This might cause data loss later, so don't allow it. */
            Vdetach(vgroup_id);
            vgroup_id = FAIL;
        }
    }
    plhs[0] = haCreateDoubleScalar((double) vgroup_id);
    
    mxFree(access);
}

/*
 * hdfVattrinfo
 *
 * Purpose: gateway to Vattrinfo()
 *
 * MATLAB usage:
 * [name,data_type,count,nbytes,status] = hdf('V', 'attrinfo', vgroup_id, attr_index)
 */
static void hdfVattrinfo(int nlhs,
                          mxArray *plhs[],
                          int nrhs,
                          const mxArray *prhs[])
{
    int32 vgroup_id;
    intn attr_index;
    char name[MAX_NC_NAME];
    int32 data_type;
    const char *data_type_str;
    int32 count;
    int32 nbytes;
    intn status;

    haNarginChk(4, 4, nrhs);
    haNargoutChk(0, 5, nlhs);

    vgroup_id = (int32) haGetDoubleScalar(prhs[2], "Vgroup identifier");
    attr_index = (intn) haGetDoubleScalar(prhs[3], "Attribute index");

    status = Vattrinfo(vgroup_id, attr_index, name, &data_type, &count, &nbytes);
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
 * hdfVdetach
 *
 * Purpose: gateway to Vdetach()
 *
 * MATLAB usage:
 * status = hdf('V', 'detach', vgroup_id)
 */
static void hdfVdetach(int nlhs,
                           mxArray *plhs[],
                           int nrhs,
                           const mxArray *prhs[])
{
    int32 vgroup_id;
    int32 status;

    haNarginChk(3, 3, nrhs);
    haNargoutChk(0, 1, nlhs);

    vgroup_id = (int32) haGetDoubleScalar(prhs[2], "Vgroup identifier");
    status = Vdetach(vgroup_id);
    if (status == SUCCEED)
    {
        haDeleteIDFromList(vgroup_id, Vgroup_ID_List);
    }

    plhs[0] = haCreateDoubleScalar((double) status);
}


/*
 * hdfVend
 *
 * Purpose: gateway to Vend()
 *
 * MATLAB usage:
 * status = hdf('V', 'end', file_id)
 */
static void hdfVend(int nlhs,
                     mxArray *plhs[],
                     int nrhs,
                     const mxArray *prhs[])
{
    int32 file_id;
    intn status;

    haNarginChk(3, 3, nrhs);
    haNargoutChk(0, 1, nlhs);

    file_id = (int32) haGetDoubleScalar(prhs[2], "Vfile identifier");
    status = Vend(file_id);
    if (status == SUCCEED)
    {
        haDeleteIDFromList(file_id, Vfile_ID_List);
    }
    plhs[0] = haCreateDoubleScalar((double) status);
}


/*
 * hdfVfind
 *
 * Purpose: gateway to Vfind()
 *
 * MATLAB usage:
 * vgroup_ref = hdf('V', 'find', file_id, vgroup_name)
 */
static void hdfVfind(int nlhs,
                     mxArray *plhs[],
                     int nrhs,
                     const mxArray *prhs[])
{
    int32 file_id;
    char *vgroup_name;
    int32 vgroup_ref;

    haNarginChk(4, 4, nrhs);
    haNargoutChk(0, 1, nlhs);

    file_id = (int32) haGetDoubleScalar(prhs[2], "Vfile identifier");
    vgroup_name = haGetString(prhs[3],"Vgroup name");
    
    vgroup_ref = Vfind(file_id,vgroup_name);
    
    plhs[0] = haCreateDoubleScalar((double) vgroup_ref);
    
    mxFree(vgroup_name);
}


/*
 * hdfVfindattr
 *
 * Purpose: gateway to Vfindattr()
 *
 * MATLAB usage:
 * attr_index = hdf('V', 'findattr', vgroup_id, attr_name)
 */
static void hdfVfindattr(int nlhs,
                     mxArray *plhs[],
                     int nrhs,
                     const mxArray *prhs[])
{
    int32 vgroup_id;
    char *attr_name;
    intn attr_index;

    haNarginChk(4, 4, nrhs);
    haNargoutChk(0, 1, nlhs);

    vgroup_id = (int32) haGetDoubleScalar(prhs[2], "Vgroup identifier");
    attr_name = haGetString(prhs[3],"Attribute name");
    
    attr_index = Vfindattr(vgroup_id,attr_name);
    
    plhs[0] = haCreateDoubleScalar((double) attr_index);
    
    mxFree(attr_name);
}


/*
 * hdfVfindclass
 *
 * Purpose: gateway to Vfindclass()
 *
 * MATLAB usage:
 * vgroup_ref = hdf('V', 'findclass', file_id, vgroup_class)
 */
static void hdfVfindclass(int nlhs,
                     mxArray *plhs[],
                     int nrhs,
                     const mxArray *prhs[])
{
    int32 file_id;
    char *vgroup_class;
    intn vgroup_ref;

    haNarginChk(4, 4, nrhs);
    haNargoutChk(0, 1, nlhs);

    file_id = (int32) haGetDoubleScalar(prhs[2], "Vfile identifier");
    vgroup_class = haGetString(prhs[3],"Vgroup class");
    
    vgroup_ref = Vfindclass(file_id,vgroup_class);
    
    plhs[0] = haCreateDoubleScalar((double) vgroup_ref);
    
    mxFree(vgroup_class);
}


/*
 * hdfVflocate
 *
 * Purpose: gateway to Vflocate()
 *
 * MATLAB usage:
 * vdata_ref = hdf('V', 'flocate', vgroup_id, field)
 */
static void hdfVflocate(int nlhs,
                     mxArray *plhs[],
                     int nrhs,
                     const mxArray *prhs[])
{
    int32 vgroup_id;
    char *field;
    intn vdata_ref;

    haNarginChk(4, 4, nrhs);
    haNargoutChk(0, 1, nlhs);

    vgroup_id = (int32) haGetDoubleScalar(prhs[2], "Vgroup identifier");
    field = haGetString(prhs[3],"field name");
    
    vdata_ref = Vflocate(vgroup_id,field);
    
    plhs[0] = haCreateDoubleScalar((double) vdata_ref);
    
    mxFree(field);
}


/*
 * hdfVgetattr
 *
 * Purpose: gateway to Vgetattr()
 *
 * MATLAB usage:
 * [values,status] = hdf('V', 'getattr', vgroup_id, attr_index)
 */
static void hdfVgetattr(int nlhs,
                        mxArray *plhs[],
                        int nrhs,
                        const mxArray *prhs[])
{
    int32 vgroup_id;
    intn attr_index;
    int32 data_type;
    int32 count;
    intn status;
    int siz[2];
    VOIDP data;
    bool ok_to_free_data;

    haNarginChk(4, 4, nrhs);
    haNargoutChk(0, 5, nlhs);

    vgroup_id = (int32) haGetDoubleScalar(prhs[2], "Vgroup identifier");
    attr_index = (intn) haGetDoubleScalar(prhs[3], "Attribute index");

    /* Determine datatype and size of the attribute values */
    status = Vattrinfo(vgroup_id, attr_index, NULL, &data_type, &count, NULL);
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
        
        status = Vgetattr(vgroup_id, attr_index, data);
        if (status == FAIL)
        {
            mxFree(data);
            plhs[0] = EMPTY;
            if (nlhs > 1) plhs[1] = haCreateDoubleScalar((double) status);
            return;
        }

        plhs[0] = haMakeArrayFromHDFDataBuffer(2,siz,data_type,data,
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
 * hdfVgetclass
 *
 * Purpose: gateway to Vgetclass()
 *
 * MATLAB usage:
 * [class_name,status] = hdf('V', 'getclass', vgroup_id)
 */
static void hdfVgetclass(int nlhs,
                     mxArray *plhs[],
                     int nrhs,
                     const mxArray *prhs[])
{
    int32 vgroup_id;
    intn status;
    char name[VGNAMELENMAX];

    haNarginChk(3, 3, nrhs);
    haNargoutChk(0, 2, nlhs);

    vgroup_id = (int32) haGetDoubleScalar(prhs[2], "Vgroup identifier");
    
    status = Vgetclass(vgroup_id,name);
    
    plhs[0] = mxCreateString(name);
    if (nlhs > 1)
    	plhs[1] = haCreateDoubleScalar((double) status);
}


/*
 * hdfVgetid
 *
 * Purpose: gateway to Vgetid()
 *
 * MATLAB usage:
 * next_ref = hdf('V', 'getid', file_id, vgroup_ref)
 */
static void hdfVgetid(int nlhs,
                     mxArray *plhs[],
                     int nrhs,
                     const mxArray *prhs[])
{
    int32 file_id;
    int32 vgroup_ref;
    int32 next_ref;

    haNarginChk(4, 4, nrhs);
    haNargoutChk(0, 1, nlhs);

    file_id = (int32) haGetDoubleScalar(prhs[2], "Vfile identifier");
    vgroup_ref = (int32) haGetDoubleScalar(prhs[3], "Vgroup reference number");
    
    next_ref = Vgetid(file_id,vgroup_ref);
    
    plhs[0] = haCreateDoubleScalar((double) next_ref);
}


/*
 * hdfVgetname
 *
 * Purpose: gateway to Vgetname()
 *
 * MATLAB usage:
 * [vgroup_name,status] = hdf('V', 'getname', vgroup_id)
 */
static void hdfVgetname(int nlhs,
                     mxArray *plhs[],
                     int nrhs,
                     const mxArray *prhs[])
{
    int32 vgroup_id;
    int32 status;
    char name[VGNAMELENMAX];

    haNarginChk(3, 3, nrhs);
    haNargoutChk(0, 2, nlhs);

    vgroup_id = (int32) haGetDoubleScalar(prhs[2], "Vgroup identifier");
    
    status = Vgetname(vgroup_id,name);
    
    plhs[0] = mxCreateString(name);
    if (nlhs > 1)
    	plhs[1] = haCreateDoubleScalar((double) status);
}

#ifdef OBSOLETE
/*
 * hdfVgetnext
 *
 * Purpose: gateway to Vgetnext()
 *
 * MATLAB usage:
 * next_ref = hdf('V', 'getnext', vgroup_id, vgroup_ref/vdata_ref)
 */
static void hdfVgetnext(int nlhs,
                     mxArray *plhs[],
                     int nrhs,
                     const mxArray *prhs[])
{
    int32 file_id;
    int32 elem_ref;
    int32 next_ref;

    haNarginChk(4, 4, nrhs);
    haNargoutChk(0, 1, nlhs);

    file_id = (int32) haGetDoubleScalar(prhs[2], "Vfile identifier");
    elem_ref = (int32) haGetDoubleScalar(prhs[3], "Reference number");
    
    next_ref = Vgetnext(file_id,elem_ref);
    
    plhs[0] = haCreateDoubleScalar((double) next_ref);
}
#endif

/*
 * hdfVgettagref
 *
 * Purpose: gateway to Vgettagref()
 *
 * MATLAB usage:
 * [tag,ref,status] = hdf('V', 'gettagref', vgroup_id, index)
 */
static void hdfVgettagref(int nlhs,
                     mxArray *plhs[],
                     int nrhs,
                     const mxArray *prhs[])
{
    int32 vgroup_id;
    int32 index;
    int32 tag;
    int32 ref;
    int32 status;

    haNarginChk(4, 4, nrhs);
    haNargoutChk(0, 3, nlhs);

    vgroup_id = (int32) haGetDoubleScalar(prhs[2], "Vgroup identifier");
    index = (int32) haGetDoubleScalar(prhs[3], "Tag/ref index");
    
    status = Vgettagref(vgroup_id,index,&tag,&ref);
    if (status == SUCCEED)
    {
    	plhs[0] = haCreateDoubleScalar((double) tag);
    	if (nlhs > 1)
    		plhs[1] = haCreateDoubleScalar((double) ref);
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
 * hdfVgettagrefs
 *
 * Purpose: gateway to Vgettagrefs()
 *
 * MATLAB usage:
 * [tags,refs,count] = hdf('V', 'gettagrefs', vgroup_id, maxsize)
 */
static void hdfVgettagrefs(int nlhs,
                     mxArray *plhs[],
                     int nrhs,
                     const mxArray *prhs[])
{
    int32 vgroup_id;
    int32 maxsize;
    int32 *tags;
    int32 *refs;
    int32 count;
    int i;
    int n;
    double *pr;

    haNarginChk(4, 4, nrhs);
    haNargoutChk(0, 3, nlhs);

    vgroup_id = (int32) haGetDoubleScalar(prhs[2], "Vgroup identifier");
    maxsize = (int32) haGetDoubleScalar(prhs[3], "Maxsize specifier");
    
    tags = (int32 *)mxCalloc(maxsize,sizeof(int32));
    refs = (int32 *)mxCalloc(maxsize,sizeof(int32));
    
    count = Vgettagrefs(vgroup_id,tags,refs,maxsize);
    if (count != FAIL)
    {
    	n = MIN(maxsize,count);
    	plhs[0] = mxCreateDoubleMatrix(1,n,mxREAL);
    	pr = mxGetPr(plhs[0]);
    	for (i=0; i<n; i++)
    		pr[i] = (double) tags[i];
    		
    	if (nlhs > 1)
    	{
	    	plhs[1] = mxCreateDoubleMatrix(1,n,mxREAL);
	    	pr = mxGetPr(plhs[1]);
	    	for (i=0; i<n; i++)
	    		pr[i] = (double) refs[i];
		}
    }
    else
    {
    	plhs[0] = EMPTY;
    	if (nlhs > 1)
    		plhs[1] = EMPTY;
    }
    if (nlhs > 2)
    	plhs[2] = haCreateDoubleScalar((double) count);
    	
    mxFree(tags);
    mxFree(refs);
}


/*
 * hdfVgetversion
 *
 * Purpose: gateway to Vgetversion()
 *
 * MATLAB usage:
 * version = hdf('V', 'getversion', vgroup_id)
 *      version will be 2, 3 or 4 corresponding to VSET_OLD_VERSION,VSET_VERSION, 
 *      or VSET_NEW_VERSION
 */
static void hdfVgetversion(int nlhs,
                     mxArray *plhs[],
                     int nrhs,
                     const mxArray *prhs[])
{
    int32 vgroup_id;
    int32 version;

    haNarginChk(3, 3, nrhs);
    haNargoutChk(0, 1, nlhs);

    vgroup_id = (int32) haGetDoubleScalar(prhs[2], "Vgroup identifier");
    
    version = Vgetversion(vgroup_id);
    
    plhs[0] = haCreateDoubleScalar((double) version);
}


/*
 * hdfVinqtagref
 *
 * Purpose: gateway to Vinqtagref()
 *
 * MATLAB usage:
 * tf = hdf('V', 'inqtagref', vgroup_id, tag, ref)
 */
static void hdfVinqtagref(int nlhs,
                          mxArray *plhs[],
                          int nrhs,
                          const mxArray *prhs[])
{
    int32 vgroup_id;
    int32 tag;
    int32 ref;
    int32 status;

    haNarginChk(5, 5, nrhs);
    haNargoutChk(0, 1, nlhs);

    vgroup_id = (int32) haGetDoubleScalar(prhs[2], "Vgroup identifier");
    tag = (int32) haGetDoubleScalar(prhs[3],"Tag");
    ref = (int32) haGetDoubleScalar(prhs[4],"Reference number");
    
    status = Vinqtagref(vgroup_id,tag,ref);
    
    plhs[0] = haCreateDoubleScalar((double) status);
}

/*
 * hdfVinquire
 *
 * Purpose: gateway to Vinquire()
 *
 * MATLAB usage:
 * [n,vgroup_name,status] = hdf('V', 'inquire', vgroup_id)
 */
static void hdfVinquire(int nlhs,
                          mxArray *plhs[],
                          int nrhs,
                          const mxArray *prhs[])
{
    int32 vgroup_id;
    int32 n;
    char name[VGNAMELENMAX];
    int32 status;

    haNarginChk(3, 3, nrhs);
    haNargoutChk(0, 3, nlhs);

    vgroup_id = (int32) haGetDoubleScalar(prhs[2], "Vgroup identifier");
    
    status = Vinquire(vgroup_id,&n,name);
    if (status == SUCCEED)
    {
    	plhs[0] = haCreateDoubleScalar((double) n);
    	if (nlhs > 1)
    		plhs[1] = mxCreateString(name);
    }
    else
    {
    	plhs[0] = ZERO;
    	if (nlhs > 1)
    		plhs[1] = EMPTYSTR;
    }
    if (nlhs > 2)
    	plhs[2] = haCreateDoubleScalar((double) status);
}

/*
 * hdfVinsert
 *
 * Purpose: gateway to Vinsert()
 *
 * MATLAB usage:
 * ref = hdf('V', 'insert', vgroup_id, vdata_id/vgroup_id)
 */
static void hdfVinsert(int nlhs,
                          mxArray *plhs[],
                          int nrhs,
                          const mxArray *prhs[])
{
    int32 vgroup_id;
    int32 v_id;
    int32 ref;

    haNarginChk(4, 4, nrhs);
    haNargoutChk(0, 1, nlhs);

    vgroup_id = (int32) haGetDoubleScalar(prhs[2], "Vgroup identifier");
    v_id = (int32) haGetDoubleScalar(prhs[3], "Identifier");
    
    ref = Vinsert(vgroup_id,v_id);
    plhs[0] = haCreateDoubleScalar((double) ref);
}


/*
 * hdfVisvg
 *
 * Purpose: gateway to Visvg()
 *
 * MATLAB usage:
 * tf = hdf('V', 'isvg', vgroup_id, vdata_ref/vgroup_ref)
 */
static void hdfVisvg(int nlhs,
                          mxArray *plhs[],
                          int nrhs,
                          const mxArray *prhs[])
{
    int32 vgroup_id;
    int32 v_ref;
    int32 status;

    haNarginChk(4, 4, nrhs);
    haNargoutChk(0, 1, nlhs);

    vgroup_id = (int32) haGetDoubleScalar(prhs[2], "Vgroup identifier");
    v_ref = (int32) haGetDoubleScalar(prhs[3], "Reference");
    
    status = Visvg(vgroup_id,v_ref);
    plhs[0] = haCreateDoubleScalar((double) status);
}


/*
 * hdfVisvs
 *
 * Purpose: gateway to Visvs()
 *
 * MATLAB usage:
 * tf = hdf('V', 'isvs', vgroup_id, vdata_ref)
 */
static void hdfVisvs(int nlhs,
                          mxArray *plhs[],
                          int nrhs,
                          const mxArray *prhs[])
{
    int32 vgroup_id;
    int32 v_ref;
    int32 status;

    haNarginChk(4, 4, nrhs);
    haNargoutChk(0, 1, nlhs);

    vgroup_id = (int32) haGetDoubleScalar(prhs[2], "Vgroup identifier");
    v_ref = (int32) haGetDoubleScalar(prhs[3], "Vdata reference");
    
    status = Visvs(vgroup_id,v_ref);
    plhs[0] = haCreateDoubleScalar((double) status);
}


/*
 * hdfVlone
 *
 * Purpose: gateway to Vlone()
 *
 * MATLAB usage:
 * [refs,count] = hdf('V', 'lone', file_id, maxsize)
 */
static void hdfVlone(int nlhs,
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
    
    count = Vlone(file_id,refs,maxsize);
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
 * hdfVnattrs
 *
 * Purpose: gateway to Vnattrs()
 *
 * MATLAB usage:
 * count = hdf('V', 'nattrs', vgroup_id)
 */
static void hdfVnattrs(int nlhs,
                     mxArray *plhs[],
                     int nrhs,
                     const mxArray *prhs[])
{
    int32 vgroup_id;
    int32 status;

    haNarginChk(3, 3, nrhs);
    haNargoutChk(0, 1, nlhs);

    vgroup_id = (int32) haGetDoubleScalar(prhs[2], "Vgroup identifier");
    
    status = Vnattrs(vgroup_id);
    
    plhs[0] = haCreateDoubleScalar((double) status);
}


/*
 * hdfVnrefs
 *
 * Purpose: gateway to Vnrefs()
 *
 * MATLAB usage:
 * count = hdf('V', 'nrefs', vgroup_id, tag)
 */
static void hdfVnrefs(int nlhs,
                     mxArray *plhs[],
                     int nrhs,
                     const mxArray *prhs[])
{
    int32 vgroup_id;
    int32 tag;
    int32 status;

    haNarginChk(4, 4, nrhs);
    haNargoutChk(0, 1, nlhs);

    vgroup_id = (int32) haGetDoubleScalar(prhs[2], "Vgroup identifier");
    tag = (int32) haGetDoubleScalar(prhs[3], "Reference");
    
    status = Vnrefs(vgroup_id,tag);
    
    plhs[0] = haCreateDoubleScalar((double) status);
}


/*
 * hdfVntagrefs
 *
 * Purpose: gateway to Vntagrefs()
 *
 * MATLAB usage:
 * count = hdf('V', 'ntagrefs', vgroup_id)
 */
static void hdfVntagrefs(int nlhs,
                     mxArray *plhs[],
                     int nrhs,
                     const mxArray *prhs[])
{
    int32 vgroup_id;
    int32 status;

    haNarginChk(3, 3, nrhs);
    haNargoutChk(0, 1, nlhs);

    vgroup_id = (int32) haGetDoubleScalar(prhs[2], "Vgroup identifier");
    
    status = Vntagrefs(vgroup_id);
    
    plhs[0] = haCreateDoubleScalar((double) status);
}


/*
 * hdfVsetattr
 *
 * Purpose: gateway to Vsetattr()
 *
 * MATLAB usage:
 * status = hdf('V', 'setattr', vgroup_id, name, A)
 */
static void hdfVsetattr(int nlhs,
                         mxArray *plhs[],
                         int nrhs,
                         const mxArray *prhs[])
{
    int32 id;
    char *name;
    char *buffer = NULL;
    const mxArray *A;
    int32 data_type;
    int32 count;
    VOIDP values;
    intn status;

    haNarginChk(5, 5, nrhs);
    haNargoutChk(0, 1, nlhs);

    id = (int32) haGetDoubleScalar(prhs[2], "Vgroup identifier");
    name = haGetString(prhs[3], "Attribute name");
    
    A = prhs[4];
    data_type = haGetDataTypeFromClassID(mxGetClassID(A));
    count = mxGetM(A) * mxGetN(A);

    if (data_type == DFNT_CHAR8)
    {
        buffer = mxCalloc(sizeof(mxChar)*count+1, sizeof(*buffer));
        mxGetString(A, buffer, sizeof(mxChar)*count+1);
        values = (VOIDP) buffer;
        status = Vsetattr(id, name, data_type, strlen(buffer), values);
    }
    else
    {
        values = mxGetData(A);
        status = Vsetattr(id, name, data_type, count, values);
    }

    plhs[0] = haCreateDoubleScalar((double) status);

    mxFree(name);
    if (buffer != NULL)
    {
        mxFree(buffer);
    }
}

/*
 * hdfVsetclass
 *
 * Purpose: gateway to Vsetclass()
 *
 * MATLAB usage:
 * status = hdf('V', 'setclass', vgroup_id, class)
 */
static void hdfVsetclass(int nlhs,
                         mxArray *plhs[],
                         int nrhs,
                         const mxArray *prhs[])
{
	int32 status;
	int32 vgroup_id;
	char *name;
	
    haNarginChk(4, 4, nrhs);
    haNargoutChk(0, 1, nlhs);

    vgroup_id = (int32) haGetDoubleScalar(prhs[2], "Vgroup identifier");
    name = haGetString(prhs[3],"Class name");
    	
	status = Vsetclass(vgroup_id,name);
	
	plhs[0] = haCreateDoubleScalar((double) status);
	
	mxFree(name);
}

/*
 * hdfVsetname
 *
 * Purpose: gateway to Vsetname()
 *
 * MATLAB usage:
 * status = hdf('V', 'setname', vgroup_id, name)
 */
static void hdfVsetname(int nlhs,
                         mxArray *plhs[],
                         int nrhs,
                         const mxArray *prhs[])
{
	int32 status;
	int32 vgroup_id;
	char *name;
	
    haNarginChk(4, 4, nrhs);
    haNargoutChk(0, 1, nlhs);

    vgroup_id = (int32) haGetDoubleScalar(prhs[2], "Vgroup identifier");
    name = haGetString(prhs[3],"Vgroup name");
    	
	status = Vsetname(vgroup_id,name);
	
	plhs[0] = haCreateDoubleScalar((double) status);
	
	mxFree(name);
}


/*
 * hdfVstart
 * 
 * Purpose: gateway to Vstart()
 *
 * MATLAB usage:
 * status = hdf('V', 'start', file_id)
 */
static void hdfVstart(int nlhs,
                       mxArray *plhs[],
                       int nrhs,
                       const mxArray *prhs[])
{
	int32 file_id;
	intn status;
	
	file_id = (int32) haGetDoubleScalar(prhs[2],"File identifier");
	
    status = Vstart(file_id);
    if (status != FAIL)
    {
        status = haAddIDToList(file_id, Vfile_ID_List);
        if (status == FAIL)
        {
            /* Failed to add file_id to the list. */
            /* This might cause data loss later, so don't allow it. */
            Vend(file_id);
            status = FAIL;
        }
    }
    plhs[0] = haCreateDoubleScalar((double) status);
}


/*
 * hdfVQueryref
 *
 * Purpose: gateway to VQueryref()
 *
 * MATLAB usage:
 * ref = hdf('V', 'Queryref', vgroup_id)
 */
static void hdfVQueryref(int nlhs,
                         mxArray *plhs[],
                         int nrhs,
                         const mxArray *prhs[])
{
    int32 vgroup_id;
    int32 ref;

    haNarginChk(3, 3, nrhs);
    haNargoutChk(0, 1, nlhs);

    vgroup_id = (int32) haGetDoubleScalar(prhs[2], "Vgroup identifier");
    ref = VQueryref(vgroup_id);
    plhs[0] = haCreateDoubleScalar((double) ref);
}


/*
 * hdfVQuerytag
 *
 * Purpose: gateway to VQuerytag()
 *
 * MATLAB usage:
 * tag = hdf('V', 'Querytag', vgroup_id)
 */
static void hdfVQuerytag(int nlhs,
                         mxArray *plhs[],
                         int nrhs,
                         const mxArray *prhs[])
{
    int32 vgroup_id;
    int32 tag;

    haNarginChk(3, 3, nrhs);
    haNargoutChk(0, 1, nlhs);

    vgroup_id = (int32) haGetDoubleScalar(prhs[2], "Vgroup identifier");
    tag = VQuerytag(vgroup_id);
    plhs[0] = haCreateDoubleScalar((double) tag);
}


/*
 * hdfV
 *
 * Purpose: Function switchyard for the V part of the HDF gateway.
 *
 * Inputs:  nlhs --- number of left-side arguments
 *          plhs --- left-side arguments
 *          nrhs --- number of right-side arguments
 *          prhs --- right-side arguments
 *          functionStr --- string specifying which function to call
 * Outputs: none
 * Return:  none
 */
void hdfV(int nlhs,
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
    	{"addtagref",hdfVaddtagref},
    	{"attach",hdfVattach},
    	{"attrinfo",hdfVattrinfo},
    	{"detach",hdfVdetach},
    	{"end",hdfVend},
    	{"find",hdfVfind},
    	{"findattr",hdfVfindattr},
    	{"findclass",hdfVfindclass},
    	{"flocate",hdfVflocate},
    	{"getattr",hdfVgetattr},
    	{"getclass",hdfVgetclass},
    	{"getid",hdfVgetid},
    	{"getname",hdfVgetname},
    	{"gettagref",hdfVgettagref},
    	{"gettagrefs",hdfVgettagrefs},
    	{"getversion",hdfVgetversion},
    	{"inqtagref",hdfVinqtagref},
    	{"inquire",hdfVinquire},
    	{"insert",hdfVinsert},
    	{"isvg",hdfVisvg},
    	{"isvs",hdfVisvs},
    	{"lone",hdfVlone},
    	{"nattrs",hdfVnattrs},
        {"nrefs",hdfVnrefs},
    	{"ntagrefs",hdfVntagrefs},
    	{"setattr",hdfVsetattr},
    	{"setclass",hdfVsetclass},
    	{"setname",hdfVsetname},
    	{"start",hdfVstart},
    	{"Queryref",hdfVQueryref},
    	{"Querytag",hdfVQuerytag},
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
