#include "hdf5.h"
#include "mex.h"
#include "hdf5utils.h"

static bool mexAtExitIsSet = false;

/* binky - Take this out */
#define MAX_FILENAME_LEN   500   /* Max length of an HDF5 filename that we allow */

/*
 * Forward declarations of functions within this file
 */
group_info get_object_info(hid_t, char *, char *);
mxArray *  datatype_to_description(hid_t);
mxArray *  create_group_structure(hid_t, char *, char *, group_info, bool);
mxArray *  create_dataset_structure(hid_t, const char *, const char *, ginfo_ptr, bool);
mxArray *  create_named_datatype_structure(hid_t, const char *, const char *, ginfo_ptr);
mxArray *  create_datatype_structure(hid_t);
mxArray *  create_attribute_structure(hid_t, const char *, const char *, ginfo_ptr, bool);
mxArray *  create_link_structure(hid_t, const char *, ginfo_ptr, bool, const char*);
herr_t     get_num_members(hid_t, const char *, ginfo_ptr);
void       free_heap_memory(ginfo_ptr);

/*
 * This is an entry in the table which has room to store object numbers
 * and the corresponding object name
 */
struct entry {
    unsigned long objno[2];
    char *objname;
};

int num_entries = 0;

/* 
 * This is table keeps track of the objects with more than 1 hard
 * link pointing to it.  It stores the name of the object in the table.
 */

/* TBD- turn this into a linked list */
struct entry table[1000];  /* no more than 1000 objects allowed */

/* This function looks up an object, and returns the index into
 * the table if it's found.  If it isn't found, it returns -1.
 */

int find_entry( unsigned long objno[2]) {
int i;
        for (i = 0; i < num_entries; i++) {
                if ((objno[0] == table[i].objno[0]) && 
                        (objno[1] == table[i].objno[1])) {
                        return i;
                }
        }
        return -1;
}

/* This puts an object into the table if it hasn't been found
 */

int insert_entry( unsigned long objno[2], char *objname) {
    int rv;
    if ((rv = find_entry(objno)) > 0) {
	return(rv);
    }
    else {
	if (num_entries >= 1000) {
	    mexPrintf("Exceeded number of hardlinks available");
	}
        table[num_entries].objno[0] = objno[0];
        table[num_entries].objno[1] = objno[1];
	table[num_entries].objname = mxMalloc(strlen(objname) * sizeof(char) + 1);
	strcpy(table[num_entries].objname,objname);
        num_entries++;
        return(num_entries);
    }
}


/*
 * This is the main entry point of the MEX-file
 */
void mexFunction(int nlhs, mxArray *plhs[], 
                 int nrhs, const mxArray *prhs[] )

{
    char       *filename;             /* name of HDF5 file */
    hid_t      fid;                   /* fid for opening the HDF5 file */
    hid_t      plist;                 /* file creation property list */
    bool       read_attribute_values; /* whether or not to read attribute values */
    hsize_t    block_size;            /* block_size (offset) before data starts */
    herr_t     err;                   /* error ID */
    mxArray    *group_hierarchy;      /* group structure for root group */
    int        num_group_fields;      /* number of fields for the group structure */
    group_info ginfo;                 /* group info struct for root group */
    unsigned majnum;
    unsigned minnum;
    unsigned relnum;

    num_group_fields = GET_NUMBER_FIELDNAMES(group_fields);
    
    if (! mexAtExitIsSet)
    {
        H5dont_atexit();
	InitializeLists();
        mexAtExit(h5MexAtExit);
        mexAtExitIsSet = true;
    }

#if SUPPRESS_BACKTRACE
    /*
     * Turn off HDF5's automatic backtracing
     */
    H5Eset_auto(NULL, NULL);
#endif

    /*
     * Get filename and open it.
     */

    filename = (char *) mxMalloc((MAX_FILENAME_LEN + 1) * sizeof(char));

    if ((!mxIsChar(prhs[0])) || 
        (mxGetString(prhs[0], filename, (MAX_FILENAME_LEN + 1)))) {
        errHandler("Invalid file name.");
    }

    fid = open_file(filename, H5F_ACC_RDONLY, H5P_DEFAULT);

    /*
     * Should we read in the attribute values or just provide info?
     */
    if (nrhs > 1)
    {
        if(!mxIsLogical(prhs[1]))
            errHandler("The second input argument to HDF5INFOC must be a logical array.");
        read_attribute_values = *(mxGetLogicals(prhs[1]));
    }else
    {
        read_attribute_values = true;
    }

    /*
     * Get the offset, also known as the "user-block" from a file
     * creation property list.
     */
    plist = H5Fget_create_plist(fid);
    err = H5Pget_userblock(plist, &block_size);
    
    if (err < 0)
    {
        errHandler("Error getting user-block size");
    }

    plhs[0] = mxCreateDoubleScalar((int) block_size);

    /*
     * Get the version of the library that we are working with
     */
    H5get_libversion(&majnum, &minnum, &relnum);
    plhs[2] = mxCreateDoubleScalar(majnum);
    plhs[3] = mxCreateDoubleScalar(minnum);
    plhs[4] = mxCreateDoubleScalar(relnum);

    /*
     * Get Group Hierarchy which is a group structure
     */
    plhs[1] = mxCreateStructMatrix(1, 1, num_group_fields, group_fields);

    ginfo = get_object_info(fid, filename, "/");

    group_hierarchy = create_group_structure(fid, filename, "/", ginfo, read_attribute_values);
    mxSetField(plhs[1], 0, "Filename", mxCreateString(filename));
    mxSetField(plhs[1], 0, "Name", mxCreateString("/"));
    if (group_hierarchy != NULL)
    {
        mxSetField(plhs[1], 0, "Groups", group_hierarchy);
    }
    /*
     * Create the dataset structure.
     */
    if (ginfo.num_datasets > 0)
    {
        mxArray * dataset_structure;
        
        dataset_structure = create_dataset_structure(fid, "/", filename, &ginfo, read_attribute_values);
        mxSetField(plhs[1], 0, "Datasets", dataset_structure);
    }

    /*
     * Create the attributes structure.
     */
    if (ginfo.num_attributes > 0)
    {
        mxArray * attribute_structure;
        
        attribute_structure = create_attribute_structure(fid, filename, "/", &ginfo, read_attribute_values);
        mxSetField(plhs[1], 0, "Attributes", attribute_structure);
    }

    /*
     * Create the datatypes structure.
     */
    if (ginfo.num_datatypes > 0)
    {
        mxArray * datatype_structure;
        
        datatype_structure = create_named_datatype_structure(fid, filename, "/", &ginfo);
        mxSetField(plhs[1], 0, "Datatypes", datatype_structure);
    }

    /*
     * Create the attributes structure.
     */
    if (ginfo.num_links > 0)
    {
        mxArray * link_structure;
        
        link_structure = create_link_structure(fid, "/", &ginfo, false, NULL);
        mxSetField(plhs[1], 0, "Links", link_structure);
    }

    /*
     * Close/release resources.
     */

    free_heap_memory(&ginfo);

    close_file(fid);
    mxFree(filename);
}

/*
 * Operator for H5Giterate.  Gets the number of member objects
 * within a certain group.
 */
herr_t get_num_members(hid_t loc_id, const char *member_name, ginfo_ptr ginfo)
{
    
    H5G_stat_t statbuf;

    H5Gget_objinfo(loc_id, member_name, false, &statbuf);
    switch (statbuf.type) {
      case H5G_GROUP:
        ginfo->num_groups++;
	break;
      case H5G_DATASET:
        ginfo->num_datasets++;
        break;
      case H5G_TYPE:
	/*
	 * Why doesn't this pick up un-named committed types?
	 */
        ginfo->num_datatypes++;
        break;
      case H5G_LINK:
        ginfo->num_links++;
        break;
      default:
        errHandler("Unable to identify object");
    }

    return 0;
}

/*
 * Frees heap memory that was allocated for group_info_structure
 */
void free_heap_memory(ginfo_ptr ginfo)
{
    int i;

    for (i = 0; i < ginfo->num_groups; i++)
    {
        mxFree(ginfo->group_names[i]);
	if (ginfo->objno != NULL)
	{
	    mxFree(ginfo->objno[i]);
	}
    }
    
    if (ginfo->objno != NULL)
    {
	mxFree(ginfo->objno);
    }

    /* Check ptr for NULL before trying to free */
    if (ginfo->group_names != NULL)
    {
        mxFree(ginfo->group_names);
    }

    for (i = 0; i < ginfo->num_datatypes; i++)
    {
        mxFree(ginfo->named_datatype_names[i]);
        /*
         * Need to free the class names, too.
         */
    }

    if (ginfo->named_datatype_names != NULL)
    {
        mxFree(ginfo->named_datatype_names);
    }

    for (i = 0; i < ginfo->num_datasets; i++)
    {
        mxFree(ginfo->dataset_names[i]);
    }
    /* Check ptr for NULL before trying to free */
    if (ginfo->dataset_names != NULL)
    {
        mxFree(ginfo->dataset_names);
    }

    for (i = 0; i < ginfo->num_links; i++)
    {
        mxFree(ginfo->link_names[i]);
    }
    /* Check ptr for NULL before trying to free */
    if (ginfo->link_names != NULL)
    {
        mxFree(ginfo->link_names);
    }
    
    for (i = 0; i < ginfo->num_attributes; i++)
    {
        mxFree(ginfo->attribute_names[i]);
    }

    if (ginfo->attribute_names != NULL)
    {
        mxFree(ginfo->attribute_names);
    }

}

/*
 * Goes through and creates the hierarchy of information regarding all of the
 * objects in the given group name.
 */
group_info get_object_info(hid_t fid, char *filename, char *group_name)
{
    int status;     /* status of H5 API function completing */

    int num_datatype_fields; /* number of fields for datatypes */
    int num_link_fields; /* number of fields for links */
    int num_attribute_fields;
    hid_t group_id;  /* ID of the group */
    struct group_info ginfo = {0,0,0,0,0,0,0,0,0,0,NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL};

    num_datatype_fields = GET_NUMBER_FIELDNAMES(datatype_fields);
    num_link_fields = GET_NUMBER_FIELDNAMES(link_fields);
    num_attribute_fields = GET_NUMBER_FIELDNAMES(attribute_fields);

    /*
     * Get all object information within the group.
     */
    status = H5Giterate(fid, group_name, NULL, get_num_members, &ginfo);


    /*
     * Can attributes be hard-linked?  No.  Softlinks cannot be.
     */

    /*
     * Get all attributes attached to the group
     */
    group_id = open_group(fid, group_name);

    ginfo.num_attributes = H5Aget_num_attrs(group_id);

    ginfo.group_names = (char **) mxMalloc(ginfo.num_groups * sizeof(char *));
    ginfo.named_datatype_names = (char **) mxMalloc(ginfo.num_datatypes * sizeof(char *));
    ginfo.dataset_names = (char **) mxMalloc(ginfo.num_datasets * sizeof(char *));
    ginfo.link_names = (char **) mxMalloc(ginfo.num_links * sizeof(char *));
    ginfo.attribute_names = (char **) mxMalloc(ginfo.num_attributes * sizeof(char *));
    ginfo.nlink = (unsigned *) mxMalloc(ginfo.num_groups * sizeof(unsigned));
    ginfo.objno = (unsigned long **) mxMalloc(ginfo.num_groups * sizeof(unsigned long *));
    /* Needs some work if there are multiple named datatypes there */
    /* Don't you want this to be the number of datatypes that are there? */
    ginfo.datatype_class = (int *) mxMalloc(ginfo.num_datasets * sizeof(int));

    if (ginfo.num_attributes > 0)
    {
        status = H5Aiterate(group_id, NULL, populate_attributes, &ginfo);
    }

    status = H5Giterate(fid, group_name, NULL, populate_group_info, &ginfo);

    close_group(group_id);

    return ginfo;
}

/*
 * Re-name this and only call it if there are no named datatypes.
 */
mxArray * create_datatype_structure(hid_t datatype_id)
{
    mxArray *datatype_structure;
    mxArray *elements;
    char *member_name;
    hid_t member_type;
    int elem_dims[2];
    int num_datatype_fields = GET_NUMBER_FIELDNAMES(datatype_fields);
    int num_members;
    int i;

    datatype_structure = mxCreateStructMatrix(1, 1,
                                             num_datatype_fields,
                                             datatype_fields);

    /* 
     * If the name exists for the datatype, then fill the structure field
     
    if (H5Tcommitted(datatype_id) > 0)
    {
	H5G_stat_t statbuf;

	H5Gget_objinfo(datatype_id, ".", TRUE, &statbuf);
	
    }
    */

    switch (H5Tget_class(datatype_id)) {
    case H5T_INTEGER:
	if (H5Tequal(datatype_id, H5T_STD_I8BE)) {
	    mxSetField(datatype_structure, 0, "Class", mxCreateString("H5T_STD_I8BE"));
	} else if (H5Tequal(datatype_id, H5T_STD_I8LE)) {
	    mxSetField(datatype_structure, 0, "Class", mxCreateString("H5T_STD_I8LE"));
	} else if (H5Tequal(datatype_id, H5T_STD_I16BE)) {
	    mxSetField(datatype_structure, 0, "Class", mxCreateString("H5T_STD_I16BE"));
	} else if (H5Tequal(datatype_id, H5T_STD_I16LE)) {
	    mxSetField(datatype_structure, 0, "Class", mxCreateString("H5T_STD_I16LE"));
	} else if (H5Tequal(datatype_id, H5T_STD_I32BE)) {
	    mxSetField(datatype_structure, 0, "Class", mxCreateString("H5T_STD_I32BE"));
	} else if (H5Tequal(datatype_id, H5T_STD_I32LE)) {
	    mxSetField(datatype_structure, 0, "Class", mxCreateString("H5T_STD_I32LE"));
	} else if (H5Tequal(datatype_id, H5T_STD_I64BE)) {
	    mxSetField(datatype_structure, 0, "Class", mxCreateString("H5T_STD_I64BE"));
	} else if (H5Tequal(datatype_id, H5T_STD_I64LE)) {
	    mxSetField(datatype_structure, 0, "Class", mxCreateString("H5T_STD_I64LE"));
	} else if (H5Tequal(datatype_id, H5T_STD_U8BE)) {
	    mxSetField(datatype_structure, 0, "Class", mxCreateString("H5T_STD_U8BE"));
	} else if (H5Tequal(datatype_id, H5T_STD_U8LE)) {
	    mxSetField(datatype_structure, 0, "Class", mxCreateString("H5T_STD_U8LE"));
	} else if (H5Tequal(datatype_id, H5T_STD_U16BE)) {
	    mxSetField(datatype_structure, 0, "Class", mxCreateString("H5T_STD_U16BE"));
	} else if (H5Tequal(datatype_id, H5T_STD_U16LE)) {
	    mxSetField(datatype_structure, 0, "Class", mxCreateString("H5T_STD_U16LE"));
	} else if (H5Tequal(datatype_id, H5T_STD_U32BE)) {
	    mxSetField(datatype_structure, 0, "Class", mxCreateString("H5T_STD_U32BE"));
	} else if (H5Tequal(datatype_id, H5T_STD_U32LE)) {
	    mxSetField(datatype_structure, 0, "Class", mxCreateString("H5T_STD_U32LE"));
	} else if (H5Tequal(datatype_id, H5T_STD_U64BE)) {
	    mxSetField(datatype_structure, 0, "Class", mxCreateString("H5T_STD_U64BE"));
	} else if (H5Tequal(datatype_id, H5T_STD_U64LE)) {
	    mxSetField(datatype_structure, 0, "Class", mxCreateString("H5T_STD_U64LE"));
	} else if (H5Tequal(datatype_id, H5T_NATIVE_SCHAR)) {
	    mxSetField(datatype_structure, 0, "Class", mxCreateString("H5T_NATIVE_SCHAR"));
	} else if (H5Tequal(datatype_id, H5T_NATIVE_UCHAR)) {
	    mxSetField(datatype_structure, 0, "Class", mxCreateString("H5T_NATIVE_UCHAR"));
	} else if (H5Tequal(datatype_id, H5T_NATIVE_SHORT)) {
	    mxSetField(datatype_structure, 0, "Class", mxCreateString("H5T_NATIVE_SHORT"));
	} else if (H5Tequal(datatype_id, H5T_NATIVE_USHORT)) {
	    mxSetField(datatype_structure, 0, "Class", mxCreateString("H5T_NATIVE_USHORT"));
	} else if (H5Tequal(datatype_id, H5T_NATIVE_INT)) {
	    mxSetField(datatype_structure, 0, "Class", mxCreateString("H5T_NATIVE_INT"));
	} else if (H5Tequal(datatype_id, H5T_NATIVE_UINT)) {
	    mxSetField(datatype_structure, 0, "Class", mxCreateString("H5T_NATIVE_UINT"));
	} else if (H5Tequal(datatype_id, H5T_NATIVE_LONG)) {
	    mxSetField(datatype_structure, 0, "Class", mxCreateString("H5T_NATIVE_LONG"));
	} else if (H5Tequal(datatype_id, H5T_NATIVE_ULONG)) {
	    mxSetField(datatype_structure, 0, "Class", mxCreateString("H5T_NATIVE_ULONG"));
	} else if (H5Tequal(datatype_id, H5T_NATIVE_LLONG)) {
	    mxSetField(datatype_structure, 0, "Class", mxCreateString("H5T_NATIVE_LLONG"));
	} else if (H5Tequal(datatype_id, H5T_NATIVE_ULLONG)) {
	    mxSetField(datatype_structure, 0, "Class", mxCreateString("H5T_NATIVE_ULLONG"));
	} else {
	    errHandler("Encountered unknown integer type");
	}
	break;

    case H5T_FLOAT:
	if (H5Tequal(datatype_id, H5T_IEEE_F32BE)) {
	    mxSetField(datatype_structure, 0, "Class", mxCreateString("H5T_IEEE_F32BE"));
	} else if (H5Tequal(datatype_id, H5T_IEEE_F32LE)) {
	    mxSetField(datatype_structure, 0, "Class", mxCreateString("H5T_IEEE_F32LE"));
	} else if (H5Tequal(datatype_id, H5T_IEEE_F64BE)) {
	    mxSetField(datatype_structure, 0, "Class", mxCreateString("H5T_IEEE_F64BE"));
	} else if (H5Tequal(datatype_id, H5T_IEEE_F64LE)) {
	    mxSetField(datatype_structure, 0, "Class", mxCreateString("H5T_IEEE_F64LE"));
	} else if (H5Tequal(datatype_id, H5T_NATIVE_FLOAT)) {
	    mxSetField(datatype_structure, 0, "Class", mxCreateString("H5T_NATIVE_FLOAT"));
	} else if (H5Tequal(datatype_id, H5T_NATIVE_DOUBLE)) {
	    mxSetField(datatype_structure, 0, "Class", mxCreateString("H5T_NATIVE_DOUBLE"));
	} else if (H5Tequal(datatype_id, H5T_NATIVE_LDOUBLE)) {
	    mxSetField(datatype_structure, 0, "Class", mxCreateString("H5T_NATIVE_LDOUBLE"));
	} else {
	    errHandler("Encountered unknown float type");
	}
	break;

    case H5T_TIME:
	
	break;

    case H5T_STRING:
	mxSetField(datatype_structure, 0, "Class", mxCreateString("H5T_STRING"));
	break;

    case H5T_BITFIELD:
	if (H5Tequal(datatype_id, H5T_STD_B8BE)) {
	    mxSetField(datatype_structure, 0, "Class", mxCreateString("H5T_STD_B8BE"));
	} else if (H5Tequal(datatype_id, H5T_STD_B8LE)) {
	    mxSetField(datatype_structure, 0, "Class", mxCreateString("H5T_STD_B8LE"));
	} else if (H5Tequal(datatype_id, H5T_STD_B16BE)) {
	    mxSetField(datatype_structure, 0, "Class", mxCreateString("H5T_STD_B16BE"));
	} else if (H5Tequal(datatype_id, H5T_STD_B16LE)) {
	    mxSetField(datatype_structure, 0, "Class", mxCreateString("H5T_STD_B16LE"));
	} else if (H5Tequal(datatype_id, H5T_STD_B32BE)) {
	    mxSetField(datatype_structure, 0, "Class", mxCreateString("H5T_STD_B32BE"));
	} else if (H5Tequal(datatype_id, H5T_STD_B32LE)) {
	    mxSetField(datatype_structure, 0, "Class", mxCreateString("H5T_STD_B32LE"));
	} else if (H5Tequal(datatype_id, H5T_STD_B64BE)) {
	    mxSetField(datatype_structure, 0, "Class", mxCreateString("H5T_STD_B64BE"));
	} else if (H5Tequal(datatype_id, H5T_STD_B64LE)) {
	    mxSetField(datatype_structure, 0, "Class", mxCreateString("H5T_STD_B64LE"));
	} else {
	    errHandler("Encountered unknown bitfield datatype");
	}
	break;

    case H5T_OPAQUE:
	mxSetField(datatype_structure, 0, "Class", mxCreateString("H5T_OPAQUE"));
	mxSetField(datatype_structure, 0, "Name", mxCreateString(H5Tget_tag(datatype_id)));
	break;
    

    case H5T_COMPOUND:

	mxSetField(datatype_structure, 0, "Class", mxCreateString("H5T_COMPOUND"));
	/* Add code to do something else if it's a committed type ?
	*/
	num_members = H5Tget_nmembers(datatype_id);
	elem_dims[0] = num_members;
	elem_dims[1] = 2; 

	elements = mxCreateCellArray(2, elem_dims);

	for (i = 0; i < num_members; i++)
	{
	    /*
	     * Or we can print out the names if that would be more helpful
	     */

	    member_name = H5Tget_member_name(datatype_id, i);
	    member_type = H5Tget_member_type(datatype_id, i);

	    mxSetCell(elements, i, mxCreateString(member_name));
	    mxSetCell(elements, i + num_members, datatype_to_description(member_type));
	    close_datatype(member_type);

	}
	mxSetField(datatype_structure, 0, "Elements", elements);
 
	break;

    case H5T_REFERENCE:
	mxSetField(datatype_structure, 0, "Class", mxCreateString("H5T_REFERENCE"));
	break;

    case H5T_ENUM:
    	mxSetField(datatype_structure, 0, "Class", mxCreateString("H5T_ENUM"));

	/*
	 * Set the Elements/Members field 
	 */
	break;

    case H5T_VLEN:
	mxSetField(datatype_structure, 0, "Class", mxCreateString("H5T_VLEN"));
	/* Print the base type somehow.  Nothing more here.
	*/

	break;

    case H5T_ARRAY:
	/* Name should be the base type, maybe? */

	mxSetField(datatype_structure, 0, "Class", mxCreateString("H5T_ARRAY"));
	break;

    default:
	errHandler("Encountered unknown datatype");
	break;
    }
    /*
     * Set the name based on what was recorded
     */
/*
    mxSetField(datatype_structure, 0, "Name", mxCreateString(datatype_name));
*/
    return datatype_structure;
}

/*
 * Returns the dataset structure requested by the info function
 */
mxArray * create_dataset_structure(hid_t fid, const char *group_name, const char *filename, ginfo_ptr ginfo, bool read_attribute_values)
{
    mxArray *dataset_structure;
    int num_dataset_fields; /* number of fields for datasets */
    int i;
    hid_t loc_id;  /* Identifier to the group that the dataset is in */
    bool isimage = false;

    num_dataset_fields = GET_NUMBER_FIELDNAMES(dataset_fields);
    dataset_structure = mxCreateStructMatrix(1, ginfo->num_datasets,
                                             num_dataset_fields,
                                             dataset_fields);
    for (i = 0; i < ginfo->num_datasets; i++)
    {
        hid_t dset;   /* Identifier to dataset */
        hid_t dspace; /* Identifier to dataspace for dataset */
	hid_t dtype;  /* Datatype of dataset */
        hid_t plist;  /* Identifier for creation property list */
        H5G_stat_t statbuf; 
	mxArray *attribute_structure;
	int status;
	void *fvalue;
	mxClassID mltype;
	mxArray *fill_value;
	char *fullname_dataset;
	int j;
        struct group_info attribute_info = {0,0,0,0,0,0,0,0,0,0,NULL, NULL, NULL, NULL, NULL, NULL};

        /*
         * If we have run into a hard link, need to return a link structure
         * AND put it into the link field.  Perhaps we should just
         * automatically dereference any hard link and let that be that.
         */
        loc_id = open_group(fid, group_name);

        /*
         * Populate the dataset structure (array)
         */
        mxSetField(dataset_structure, i, "Filename", mxCreateString(filename));
	/* Why is this strlen being wacky?? */
	/* Add 1 for NULL and 1 for the / */
	if (strcmp(group_name, "/") != 0)
	{
	    fullname_dataset = mxMalloc((strlen(group_name) + strlen(ginfo->dataset_names[i]) + 1 + 1) * sizeof(char));
	    strcpy(fullname_dataset, group_name); 
	    strcat(fullname_dataset,"/");
	    strcat(fullname_dataset, ginfo->dataset_names[i]);
	}else
	{
	    fullname_dataset = mxMalloc((strlen(group_name) + strlen(ginfo->dataset_names[i]) + 1) * sizeof(char));
	    strcpy(fullname_dataset, group_name);
	    strcat(fullname_dataset, ginfo->dataset_names[i]);
	}

	mxSetField(dataset_structure, i, "Name", mxCreateString(fullname_dataset));
        
        /* Rank */
        dset = open_dataset(loc_id, ginfo->dataset_names[i]);
        dspace = H5Dget_space(dset);

        mxSetField(dataset_structure, i, "Rank", mxCreateDoubleScalar(get_rank(dspace)));

        /* Datatype - you want to do an is_committed type thing
	*/

	mxSetField(dataset_structure, i, "Datatype", 
		create_datatype_structure(ginfo->datatype_class[i]));


        /* Dims */
        mxSetField(dataset_structure, i, "Dims", get_dims(dspace));
        /* MaxDims */
        mxSetField(dataset_structure, i, "MaxDims", get_max_dims(dspace));
        
        /* Layout */
        plist = H5Dget_create_plist(dset);
        
        switch (H5Pget_layout(plist)) {
          case H5D_COMPACT:
            mxSetField(dataset_structure, i, "Layout", 
                       mxCreateString("compact"));
            break;
          case H5D_CONTIGUOUS:
            mxSetField(dataset_structure, i, "Layout", 
                       mxCreateString("contiguous"));
            break;
          case H5D_CHUNKED:
            mxSetField(dataset_structure, i, "Layout", 
                       mxCreateString("chunked"));
            /* Chunksize */
            
            break;
          default:
            errHandler("Unable to identify dataset layout");
        }
        /*
         * Need to get object info on everything in here
        member_info = get_object_info(fid, filename, fullname_group);
        */
        H5Gget_objinfo(dset, ".", true, &statbuf);

        /*
         * Links - iterate and get links.
	 */

        /* Attributes - iterate and get attributes.  This should be in it's own function.*/

	attribute_info.num_attributes = H5Aget_num_attrs(dset);


	if (attribute_info.num_attributes > 0)
	{
	    int num_attribute_no_value_fields;
	    int num_attribute_fields;

	    attribute_info.attribute_names = (char **) mxMalloc(attribute_info.num_attributes * sizeof(char *));
	    status = H5Aiterate(dset, NULL, populate_attributes, &attribute_info);

        /*
	 * Change this to read attribute values if the user desires!
	 */
	if (read_attribute_values)
	{
	    num_attribute_fields = GET_NUMBER_FIELDNAMES(attribute_fields);
        
	    attribute_structure = mxCreateStructMatrix(1, attribute_info.num_attributes,
							num_attribute_fields,
							attribute_fields);
	}else
	{
	    num_attribute_no_value_fields = GET_NUMBER_FIELDNAMES(attribute_no_value_fields);
        
	    attribute_structure = mxCreateStructMatrix(1, attribute_info.num_attributes,
							num_attribute_no_value_fields,
						    attribute_no_value_fields);
	}
        for (j = 0; j < attribute_info.num_attributes; j++)
        {
            hid_t attribute;
            hid_t dspace;
	    hid_t atype;
	    char *fullname_attribute;

	    /*
	     * Set filename
	     */

	    mxSetField(attribute_structure, j, "Filename", mxCreateString(filename));

	    /*
	     * Set attribute name
	     */

	    fullname_attribute = (char *) mxMalloc((strlen(fullname_dataset) + 1 + strlen(attribute_info.attribute_names[j]) * sizeof(char)) + 1);
	    strcpy(fullname_attribute, fullname_dataset);
	    strcat(fullname_attribute, "/");
	    strcat(fullname_attribute, attribute_info.attribute_names[j]);

            mxSetField(attribute_structure, j, "Name", mxCreateString(fullname_attribute));
            attribute = open_attribute(dset, attribute_info.attribute_names[j]);
            dspace = get_dataspace(attribute, true);
	    /*
	     * Set value.  First, get datatype, and dataspace.
	     */
	    atype = get_datatype(attribute, true);

	    if (!read_attribute_values)
	    {
		mxSetField(attribute_structure, j, "Rank", mxCreateDoubleScalar(get_rank(dspace)));
		mxSetField(attribute_structure, j, "Dims", get_dims(dspace));
		mxSetField(attribute_structure, j, "MaxDims", get_max_dims(dspace));
		mxSetField(attribute_structure, j, "Datatype", create_datatype_structure(atype));
	    }
	    else
	    {
		mxArray *ml_attr_val;
		mxArray *ml_attr;
		char *attr_val;
/*
		ml_attr_val = read_attribute(fid, fullname_attribute);
*/

		hid_t atype = H5Aget_type(attribute);

		int ndims;
		hsize_t size[H5S_MAX_RANK];
		int *mldims;
		int mlrank = get_ml_rank(ndims);		


		ndims = H5Sget_simple_extent_dims(dspace, size, NULL);
		mlrank = get_ml_rank(ndims);
		mldims = get_ml_dims(mlrank, ndims, size);
		
		attr_val = read_attribute(attribute, dspace, atype, ndims, mlrank, mldims, &ml_attr);
		ml_attr_val = convert_data_to_ML(dspace, atype, ndims, mlrank, mldims, ml_attr, attr_val);

		if ((strncmp(attribute_info.attribute_names[j], "CLASS", 5) == 0) && H5Tequal(H5Tget_class(atype), H5T_STRING))
		{
		    char attr_val[5];
		    mxGetString(ml_attr_val, attr_val, 5);	
		    if (strncmp((const char *) attr_val, "image", 5))
		    {
			isimage = true;
		    }
		}
		mxSetField(attribute_structure, j, "Value", ml_attr_val);
	    }
	    /*
	     * Close all of the ids
	     */
	    close_datatype(atype);
            close_dataspace(dspace);
            close_attribute(attribute);
	    mxFree(fullname_attribute);
        }

	mxSetField(dataset_structure, i, "Attributes", attribute_structure);
	
	
	free_heap_memory(&attribute_info);
	

        /* Is Image - this value can only be set if the attributes are read! */
/*
	if (isimage)
	{
	    mxSetField(dataset_structure, i, "IsImage", mxCreateLogicalScalar(true));
	}
*/
	}


        /* FillValue - should we even leave this in? */

	dtype = H5Dget_type(dset);
	mltype = HDF5_to_ML_datatype(dtype);

	/*
	 * Fill values are always scalar, no? 
	 */
	fill_value = mxCreateNumericMatrix(1, 1, mltype, mxREAL); 
	fvalue = mxGetData(fill_value);
	fvalue = mxMalloc(1 * H5Tget_size(dtype));
	if (H5Pget_fill_value(plist, dtype, fvalue) >= 0)
	{
	    mxSetField(dataset_structure, i, "FillValue", fill_value);
	} 
	else
	{
	    mxFree(fvalue);
	    mxDestroyArray(fill_value);
	}

        close_datatype(ginfo->datatype_class[i]);
        H5Pclose(plist);
        close_dataspace(dspace);
        close_dataset(dset);
        close_group(loc_id);
	mxFree(fullname_dataset);
    }
    return dataset_structure;
}


/*
 * Returns an attribute structure.
 */
mxArray * create_attribute_structure(hid_t fid, const char *filename, const char *group_name, ginfo_ptr ginfo, 
                                  bool read_attribute_values)
{
    mxArray *attribute_structure;
    int num_attribute_fields;
    int num_attribute_no_value_fields;
    int i;
    hid_t loc_id;

    /*
     * loc_id is the group id
     */
    loc_id = open_group(fid, group_name);

    if (read_attribute_values)
    {
        /*
         * If we're reading the attribute values, the struct array
         * has only 2 fields per attribute
         */
        num_attribute_fields = GET_NUMBER_FIELDNAMES(attribute_fields);
        attribute_structure = mxCreateStructMatrix(1, ginfo->num_attributes,
                                                   num_attribute_fields,
                                                   attribute_fields);
        for (i = 0; i < ginfo->num_attributes; i++)
        {
	    mxArray *ml_attr_val;
	    char *fullname_attribute;
	    char *attr_val;
	    hid_t atype;
	    int ndims;
	    hsize_t size[H5S_MAX_RANK];
	    int *mldims;
	    int mlrank = get_ml_rank(ndims);		
	    hid_t loc_id, attribute;
	    hid_t dspace;
	    mxArray *ml_attr;


	    mxSetField(attribute_structure, i, "Filename", mxCreateString(filename));

	    /* Add 1 for NULL and 1 for the / */
	    if (strcmp(group_name, "/") != 0)
	    {
		fullname_attribute = mxMalloc((strlen(group_name) + strlen(ginfo->attribute_names[i]) + 1 + 1) * sizeof(char));
		strcpy(fullname_attribute, group_name); 
		strcat(fullname_attribute,"/");
		strcat(fullname_attribute, ginfo->attribute_names[i]);
	    }else
	    {
		fullname_attribute = mxMalloc((strlen(group_name) + strlen(ginfo->attribute_names[i]) + 1) * sizeof(char));
		strcpy(fullname_attribute, group_name);
		strcat(fullname_attribute, ginfo->attribute_names[i]);
	    }

	    mxSetField(attribute_structure, i, "Name", mxCreateString(fullname_attribute));

            /*
             * loc_id must be the fullname, not just the group name
             * where the attribute lives
             */

	    loc_id = open_location(fid, fullname_attribute);

	    attribute = open_attribute(loc_id, ginfo->attribute_names[i]);    

	    atype = get_datatype(attribute, true);
	    dspace =  get_dataspace(attribute, true);
	    ndims = H5Sget_simple_extent_dims(dspace, size, NULL);
	    mlrank = get_ml_rank(ndims);
	    mldims = get_ml_dims(mlrank, ndims, size);

	    attr_val = read_attribute(attribute, dspace, atype, ndims, mlrank, mldims, &ml_attr);
	    ml_attr_val = convert_data_to_ML(dspace, atype, ndims, mlrank, mldims, ml_attr, attr_val);

	    mxSetField(attribute_structure, i, "Value", ml_attr_val);
        }
    } else
    {
        num_attribute_no_value_fields = GET_NUMBER_FIELDNAMES(attribute_no_value_fields);
        
        attribute_structure = mxCreateStructMatrix(1, ginfo->num_attributes,
                                                   num_attribute_no_value_fields,
                                                   attribute_no_value_fields);
        for (i = 0; i < ginfo->num_attributes; i++)
        {
            hid_t attribute;
            hid_t dspace;
	    hid_t atype;
	    char *fullname_attribute;

	    mxSetField(attribute_structure, i, "Filename", mxCreateString(filename));

	    /* Add 1 for NULL and 1 for the / */
	    if (strcmp(group_name, "/") != 0)
	    {
		fullname_attribute = mxMalloc((strlen(group_name) + strlen(ginfo->attribute_names[i]) + 1 + 1) * sizeof(char));
		strcpy(fullname_attribute, group_name); 
		strcat(fullname_attribute,"/");
		strcat(fullname_attribute, ginfo->attribute_names[i]);
	    }else
	    {
		fullname_attribute = mxMalloc((strlen(group_name) + strlen(ginfo->attribute_names[i]) + 1) * sizeof(char));
		strcpy(fullname_attribute, group_name);
		strcat(fullname_attribute, ginfo->attribute_names[i]);
	    }

	    /* Name */
	    mxSetField(attribute_structure, i, "Name", mxCreateString(fullname_attribute));

            /*Rank*/
            attribute = open_attribute(loc_id, ginfo->attribute_names[i]);
            dspace = get_dataspace(attribute, true);
	    atype = get_datatype(attribute, true);
            mxSetField(attribute_structure, i, "Rank", mxCreateDoubleScalar(get_rank(dspace)));
            /* Datatype*/
	    mxSetField(attribute_structure, i, "Datatype", create_datatype_structure(atype));
            /* Dims*/
            mxSetField(attribute_structure, i, "Dims", get_dims(dspace));
            /*MaxDims*/
            mxSetField(attribute_structure, i, "MaxDims", get_max_dims(dspace));
            close_dataspace(dspace);
            close_attribute(attribute);
	    close_datatype(atype);
        }
    }

    close_group(loc_id);
    return attribute_structure;
}


/*
 * Creates a datatype structure to be returned through the info function.  This
 * is specific to named datatypes
 */
mxArray * create_named_datatype_structure(hid_t fid, const char *filename, const char *group_name, ginfo_ptr ginfo)
{
    mxArray *datatype_structure;
    int num_datatype_fields; /* number of fields for datatypes */
    int i;

    num_datatype_fields = GET_NUMBER_FIELDNAMES(datatype_fields);

    datatype_structure = mxCreateStructMatrix(1, ginfo->num_datatypes,
                                             num_datatype_fields,
                                             datatype_fields);
    for (i = 0; i < ginfo->num_datatypes; i++)
    {
	char *fullname_datatype;
	hid_t dtype;
        int elem_counter, num_elements;
	mxArray *elements;
	int elem_dims[2];

	/*
         * Populate the datatype structure (array)
         */
	    
	/* Add 1 for NULL and 1 for the / */
	if (strcmp(group_name, "/") != 0)
	{
	    fullname_datatype = mxMalloc((strlen(group_name) + strlen(ginfo->named_datatype_names[i]) + 1 + 1) * sizeof(char));
	    strcpy(fullname_datatype, group_name); 
	    strcat(fullname_datatype,"/");
	    strcat(fullname_datatype, ginfo->named_datatype_names[i]);
	}else
	{
	    fullname_datatype = mxMalloc((strlen(group_name) + strlen(ginfo->named_datatype_names[i]) + 1) * sizeof(char));
	    strcpy(fullname_datatype, group_name);
	    strcat(fullname_datatype, ginfo->named_datatype_names[i]);
	}

	mxSetField(datatype_structure, i, "Name", mxCreateString(fullname_datatype));

        /*
         * Return the class.  Open the datatype, get the class, etc.  Lord!
         */

	dtype = H5Topen(fid, fullname_datatype);
	AddIDToList(dtype, DatatypeList);

        switch (H5Tget_class(dtype))
	{
          case H5T_INTEGER:
            mxSetField(datatype_structure, i, "Class", mxCreateString("H5T_INTEGER"));
            break;
          case H5T_FLOAT:
            mxSetField(datatype_structure, i, "Class", mxCreateString("H5T_FLOAT"));
            break;
          case H5T_TIME:
            mxSetField(datatype_structure, i, "Class", mxCreateString("H5T_TIME"));
            break;
          case H5T_STRING:
            mxSetField(datatype_structure, i, "Class", mxCreateString("H5T_STRING"));
            break;
          case H5T_BITFIELD:
            mxSetField(datatype_structure, i, "Class", mxCreateString("H5T_BITFIELD"));
            break;
          case H5T_OPAQUE:
            mxSetField(datatype_structure, i, "Class", mxCreateString("H5T_OPAQUE"));
            break;
          case H5T_COMPOUND:
            mxSetField(datatype_structure, i, "Class", mxCreateString("H5T_COMPOUND"));
            break;
          case H5T_REFERENCE:
            mxSetField(datatype_structure, i, "Class", mxCreateString("H5T_REFERENCE"));
            break;
          case H5T_ENUM:
            mxSetField(datatype_structure, i, "Class", mxCreateString("H5T_ENUM"));

	    /*
	     * Return the elements in this named datatype.  Need to do something different for compound types...
	     */
	    num_elements = H5Tget_nmembers(dtype);
	    elem_dims[0] = num_elements;
	    elem_dims[1] = 2; /* Second column is for value */

	    elements = mxCreateCellArray(2, elem_dims);

	    for (elem_counter = 0; elem_counter < num_elements; elem_counter++)
	    {
		char *key = H5Tget_member_name(dtype, elem_counter);
		void *value;
		mxArray *ml_value;
		mxClassID mltype;

		mltype = HDF5_to_ML_datatype(dtype);
		ml_value = mxCreateNumericMatrix(1, 1, mltype, mxREAL);
		value = mxMalloc(1 * sizeof(short));
		value = mxGetData(ml_value);

		H5Tget_member_value(dtype, elem_counter, value);

		mxSetCell(elements, elem_counter, mxCreateString(key));
		mxSetCell(elements, elem_counter + num_elements, ml_value);
	    }

	    mxSetField(datatype_structure, i, "Elements", elements);

            break;
          case H5T_VLEN:
            mxSetField(datatype_structure, i, "Class", mxCreateString("H5T_VLEN"));
            break;
          case H5T_ARRAY:
            mxSetField(datatype_structure, i, "Class", mxCreateString("H5T_ARRAY"));
            break;
        }

	close_datatype(dtype);
	mxFree(fullname_datatype);

    /* You can have attributes in a named datatype structure (???)
     *
     */
    }
    return datatype_structure;
}
/*
 * Creates a link structure to be returned through the info struct.  Right now it only
 * works on softlinks, thanks to HDF5 being weird about hardlinks.
 */
mxArray * create_link_structure(hid_t fid, const char *group_name, ginfo_ptr ginfo, bool ishardlink, const char* hardlink_target)
{
    mxArray *link_structure;
    int num_link_fields; /* number of fields for links */

    num_link_fields = sizeof(link_fields) / sizeof(*link_fields);


    if (ishardlink)
    {
	link_structure = mxCreateStructMatrix(1, 1, num_link_fields, link_fields);
	mxSetField(link_structure, 0, "Name", mxCreateString(group_name));
	mxSetField(link_structure, 0, "IsHardLink", mxCreateLogicalScalar(ishardlink));
	mxSetField(link_structure, 0, "Target", mxCreateString(hardlink_target));
    }else
    {
        int i;
	hid_t loc_id;

	loc_id = open_group(fid, group_name);

        link_structure = mxCreateStructMatrix(1, ginfo->num_links,
                                             num_link_fields,
                                             link_fields);
	for (i = 0; i < ginfo->num_links; i++)
	{
	    H5G_stat_t statbuf;
	    char * target_name;
        
            H5Gget_objinfo(loc_id, ginfo->link_names[i], false, &statbuf);
	    target_name = mxMalloc((statbuf.linklen + 1) * sizeof(char));
	    H5Gget_linkval(loc_id, ginfo->link_names[i], statbuf.linklen, target_name);
	    /*
	     * Populate the link structure (array)
	     */
	    mxSetField(link_structure, i, "Name", mxCreateString(ginfo->link_names[i]));
	    mxSetField(link_structure, i, "IsHardLink", mxCreateLogicalScalar(ishardlink));
	    mxSetField(link_structure, i, "Target", mxCreateString(target_name));
	    mxFree(target_name);
	}
	close_group(loc_id);
    }
    return link_structure;
}

/*
 * Creates a group structure that is to be returned through the info function
 */
mxArray * create_group_structure(hid_t fid, char *filename, char *group_name, group_info ginfo, bool read_attribute_values)
{
    int i;
    int num_group_fields; /* number of fields for groups */
    mxArray *group_structure;
    group_info member_info;

    num_group_fields = GET_NUMBER_FIELDNAMES(group_fields);

    if (ginfo.num_groups > 0)
    {
        group_structure = mxCreateStructMatrix(1, ginfo.num_groups,
                                               num_group_fields, group_fields);
    }else
    {
        group_structure = NULL;
    }

    for (i = 0; i < ginfo.num_groups; i++)
    {
        char *member_group_name;
	char *fullname_group;
	mxArray *member_group;
	bool ishardlink = false;
        
        member_group_name = ginfo.group_names[i];

        if (strcmp(group_name, "/") != 0)
        {
            fullname_group = mxMalloc((strlen(member_group_name) + strlen(group_name) + 1 + 1) * sizeof(char));
            strcpy(fullname_group, group_name); 
            strcat(fullname_group,"/");
            strcat(fullname_group, member_group_name);
        }else
        {
            fullname_group = mxMalloc((strlen(member_group_name) + strlen(group_name) + 1) * sizeof(char));
            strcpy(fullname_group, group_name);
            strcat(fullname_group, member_group_name);
        }
        
        /* 
         * Get the group structure
         */
        member_info = get_object_info(fid, filename, fullname_group);

	/* If we have a hard link, we have to return a link structure
	 */
	if (ginfo.nlink[i] > 1)
	{
	    int index_to_linked_obj;
	    index_to_linked_obj = find_entry(ginfo.objno[i]);
	    if (index_to_linked_obj < 0) {
		insert_entry(ginfo.objno[i], ginfo.group_names[i]);
	    }
	    else
	    {
		/* We have a hard link and should return a link structure.
		*/
		member_group = create_link_structure(fid, fullname_group, NULL, true, table[index_to_linked_obj].objname);
		mxSetField(group_structure, i, "Links", member_group);
		mxFree(fullname_group);
		ishardlink = true;
		break;
	    }
	}
	if (!ishardlink)
	{
	    member_group = create_group_structure(fid, filename, fullname_group, member_info, read_attribute_values);
	    mxSetField(group_structure, i, "Groups", member_group);
	    mxSetField(group_structure, i, "Filename", mxCreateString(filename));
	    mxSetField(group_structure, i, "Name", mxCreateString(fullname_group));
	}

        /*
         * Instead of this, do the NULL check in create_dataset_structure
         */
        if (member_info.num_datasets > 0)
        {
            mxArray * dataset_structure;
            
            dataset_structure = create_dataset_structure(fid, fullname_group, filename, &member_info, read_attribute_values);
            mxSetField(group_structure, i, "Datasets", dataset_structure);
        }
        
        /*
         * Get attribute structure
         */
        if (member_info.num_attributes > 0)
        {
            mxArray * attribute_structure;
            
            attribute_structure = create_attribute_structure(fid, filename, fullname_group, &member_info, read_attribute_values);
            mxSetField(group_structure, i, "Attributes", attribute_structure);
        }
        
        /*
         * Get datatype structure
         */
        if (member_info.num_datatypes > 0)
        {
            mxArray * datatype_structure;
            
            datatype_structure = create_named_datatype_structure(fid, filename, fullname_group, &member_info);
            mxSetField(group_structure, i, "Datatypes", datatype_structure);
        }
        
        /*
         * Links are really soft links.  Hard links aren't defined as
         * a "object type" - rather, that just refers to objects that are
         * hard linked.
         */
        if (member_info.num_links > 0)
        {
            mxArray * link_structure;
            
            link_structure = create_link_structure(fid, fullname_group, &member_info, false, NULL);
            mxSetField(group_structure, i, "Links", link_structure);
        }

	free_heap_memory(&member_info);
        mxFree(fullname_group);

    } /* end for */
    
    return group_structure;
}


/*
 * Returns an character array mxArray when passed
 * an HDF5 datatype.
 */

mxArray * datatype_to_description(hid_t datatype_id)
{
    switch (H5Tget_class(datatype_id)) {
    case H5T_INTEGER:
	if (H5Tequal(datatype_id, H5T_STD_I8BE)) {
	    return mxCreateString("H5T_STD_I8BE");
	} else if (H5Tequal(datatype_id, H5T_STD_I8LE)) {
	    return mxCreateString("H5T_STD_I8LE");
	} else if (H5Tequal(datatype_id, H5T_STD_I16BE)) {
	    return mxCreateString("H5T_STD_I16BE");
	} else if (H5Tequal(datatype_id, H5T_STD_I16LE)) {
	    return mxCreateString("H5T_STD_I16LE");
	} else if (H5Tequal(datatype_id, H5T_STD_I32BE)) {
	    return mxCreateString("H5T_STD_I32BE");
	} else if (H5Tequal(datatype_id, H5T_STD_I32LE)) {
	    return mxCreateString("H5T_STD_I32LE");
	} else if (H5Tequal(datatype_id, H5T_STD_I64BE)) {
	    return mxCreateString("H5T_STD_I64BE");
	} else if (H5Tequal(datatype_id, H5T_STD_I64LE)) {
	    return mxCreateString("H5T_STD_I64LE");
	} else if (H5Tequal(datatype_id, H5T_STD_U8BE)) {
	    return mxCreateString("H5T_STD_U8BE");
	} else if (H5Tequal(datatype_id, H5T_STD_U8LE)) {
	    return mxCreateString("H5T_STD_U8LE");
	} else if (H5Tequal(datatype_id, H5T_STD_U16BE)) {
	    return mxCreateString("H5T_STD_U16BE");
	} else if (H5Tequal(datatype_id, H5T_STD_U16LE)) {
	    return mxCreateString("H5T_STD_U16LE");
	} else if (H5Tequal(datatype_id, H5T_STD_U32BE)) {
	    return mxCreateString("H5T_STD_U32BE");
	} else if (H5Tequal(datatype_id, H5T_STD_U32LE)) {
	    return mxCreateString("H5T_STD_U32LE");
	} else if (H5Tequal(datatype_id, H5T_STD_U64BE)) {
	    return mxCreateString("H5T_STD_U64BE");
	} else if (H5Tequal(datatype_id, H5T_STD_U64LE)) {
	    return mxCreateString("H5T_STD_U64LE");
	} else if (H5Tequal(datatype_id, H5T_NATIVE_SCHAR)) {
	    return mxCreateString("H5T_NATIVE_SCHAR");
	} else if (H5Tequal(datatype_id, H5T_NATIVE_UCHAR)) {
	    return mxCreateString("H5T_NATIVE_UCHAR");
	} else if (H5Tequal(datatype_id, H5T_NATIVE_SHORT)) {
	    return mxCreateString("H5T_NATIVE_SHORT");
	} else if (H5Tequal(datatype_id, H5T_NATIVE_USHORT)) {
	    return mxCreateString("H5T_NATIVE_USHORT");
	} else if (H5Tequal(datatype_id, H5T_NATIVE_INT)) {
	    return mxCreateString("H5T_NATIVE_INT");
	} else if (H5Tequal(datatype_id, H5T_NATIVE_UINT)) {
	    return mxCreateString("H5T_NATIVE_UINT");
	} else if (H5Tequal(datatype_id, H5T_NATIVE_LONG)) {
	    return mxCreateString("H5T_NATIVE_LONG");
	} else if (H5Tequal(datatype_id, H5T_NATIVE_ULONG)) {
	    return mxCreateString("H5T_NATIVE_ULONG");
	} else if (H5Tequal(datatype_id, H5T_NATIVE_LLONG)) {
	    return mxCreateString("H5T_NATIVE_LLONG");
	} else if (H5Tequal(datatype_id, H5T_NATIVE_ULLONG)) {
	    return mxCreateString("H5T_NATIVE_ULLONG");
	} else {
	    errHandler("Encountered unknown integer type");
	}
	break;

    case H5T_FLOAT:
	if (H5Tequal(datatype_id, H5T_IEEE_F32BE)) {
	    return mxCreateString("H5T_IEEE_F32BE");
	} else if (H5Tequal(datatype_id, H5T_IEEE_F32LE)) {
	    return mxCreateString("H5T_IEEE_F32LE");
	} else if (H5Tequal(datatype_id, H5T_IEEE_F64BE)) {
	    return mxCreateString("H5T_IEEE_F64BE");
	} else if (H5Tequal(datatype_id, H5T_IEEE_F64LE)) {
	    return mxCreateString("H5T_IEEE_F64LE");
	} else if (H5Tequal(datatype_id, H5T_NATIVE_FLOAT)) {
	    return mxCreateString("H5T_NATIVE_FLOAT");
	} else if (H5Tequal(datatype_id, H5T_NATIVE_DOUBLE)) {
	    return mxCreateString("H5T_NATIVE_DOUBLE");
	} else if (H5Tequal(datatype_id, H5T_NATIVE_LDOUBLE)) {
	    return mxCreateString("H5T_NATIVE_LDOUBLE");
	} else {
	    errHandler("Encountered unknown float type");
	}
	break;

    case H5T_TIME:
	
	break;

    case H5T_STRING:
	return mxCreateString("H5T_STRING");
	break;

    case H5T_BITFIELD:
	if (H5Tequal(datatype_id, H5T_STD_B8BE)) {
	    return mxCreateString("H5T_STD_B8BE");
	} else if (H5Tequal(datatype_id, H5T_STD_B8LE)) {
	    return mxCreateString("H5T_STD_B8LE");
	} else if (H5Tequal(datatype_id, H5T_STD_B16BE)) {
	    return mxCreateString("H5T_STD_B16BE");
	} else if (H5Tequal(datatype_id, H5T_STD_B16LE)) {
	    return mxCreateString("H5T_STD_B16LE");
	} else if (H5Tequal(datatype_id, H5T_STD_B32BE)) {
	    return mxCreateString("H5T_STD_B32BE");
	} else if (H5Tequal(datatype_id, H5T_STD_B32LE)) {
	    return mxCreateString("H5T_STD_B32LE");
	} else if (H5Tequal(datatype_id, H5T_STD_B64BE)) {
	    return mxCreateString("H5T_STD_B64BE");
	} else if (H5Tequal(datatype_id, H5T_STD_B64LE)) {
	    return mxCreateString("H5T_STD_B64LE");
	} else {
	    errHandler("Encountered unknown bitfield datatype");
	}
	break;

    case H5T_OPAQUE:
	return mxCreateString("H5T_OPAQUE");
	break;
    

    case H5T_COMPOUND:
	return mxCreateString("H5T_COMPOUND"); 
	break;

    case H5T_REFERENCE:
	return mxCreateString("H5T_REFERENCE");
	break;

    case H5T_ENUM:
    	return mxCreateString("H5T_ENUM");
	/*
	 * Set the Elements/Members field 
	 */
	break;

    case H5T_VLEN:
	return mxCreateString("H5T_VLEN");
	/* Print the base type somehow.  Nothing more here.
	*/

	break;

    case H5T_ARRAY:
	/* Name should be the base type, maybe? */

	return mxCreateString("H5T_ARRAY");
	break;

    default:
	errHandler("Encountered unknown datatype");
	return mxCreateString(""); /* bogus - to eliminate compiler warning */
	break;
    }
    return mxCreateString(""); /* bogus - to eliminate compiler warning */
}
