/* Copyright 1984-2002 The MathWorks, Inc.  */

/*
 * hdfutils.c --- support file for HDF.MEX
 *
 * This module contains utility functions shared by the other modules
 * in support of the HDF API gateway MEX-file HDF.MEX.  The utility
 * functions are prefixed by ha, as in haGetDoubleScalar().
 *
 * IMPORTANT: this module also maintains linked lists of HDF file and
 * access identifiers.  The HDF API buffers some information about
 * files and the data sets they contain; this information may not get
 * written out until the appropriate function is called to terminate
 * access to that identifier.  For example, every call to Hopen() 
 * (which returns a file identifier) must be paired by a call to Hclose().
 * The HDF MEX-file makes it particularly easy for a user to call
 * HDF API functions interactively, but this also makes it particularly
 * easy to forget to terminate access to identifiers.  Also, an
 * inadvertent "clear mex" or a premature "quit" could cause loss of
 * data.
 *
 * So the strategy is this: every function in the HDF gateway that
 * opens an identifier must record that identifier in the appropriate 
 * linked list.  Every function that terminates access to an identifier 
 * must delete that identifier from the list.  The function haCleanup()
 * is registered as the mexAtExit function, and it will close (in the
 * right order) any identifiers remaining on the lists.
 * So far there are four lists:
 *
 *   file_id_list
 *   access_id_list
 *   gr_id_list
 *   ri_id_list
 *
 * More lists may be added as the number of supported interfaces grows.
 */

/* $Revision: 1.1.6.1 $  $Date: 2003/12/13 03:02:23 $ */

static char rcsid[] = "$Id: hdfutils.c,v 1.1.6.1 2003/12/13 03:02:23 batserve Exp $";

#include <string.h>
#include <ctype.h>

/* Main HDF library header file */
#include "hdf.h"

/* HDF-EOS header file */
#include "HdfEosDef.h"

/* Multifile scientific dataset interface header file */
#include "mfhdf.h"

/* Multifile generalized raster image interface header file */
#include "mfgr.h"

/* Vgroup interface header file */
#include "vg.h"

/* MATLAB API header file */
#include "mex.h"

/* HDFMEX utility functions */
#include "hdfutils.h"

#include "hdfvs.h" /* for hdfVSDetachAndForget */

#include "jerror.h"

#include "jpeglib.h"

#define BUFLEN 128

struct node {
    int32 idnum;
    struct node *previous;
    struct node *next;
};

typedef struct node NodeType;

typedef struct 
{
    NodeType    list;
    intn        (*idCloseFcn)(int32);
    char        *name;
} ListInfo;

static ListInfo listArray[Num_ID_Lists];
static int HDF_library_initialized = 0;

/* Use alternative message handlers for jpeg library.*/
static void my_output_message (j_common_ptr);
static void my_error_exit (j_common_ptr);

/*
 * haLibraryInitialized
 *
 * Purpose: Indicate that HDF library has been called.  This
 * function should be called just before any HDF library calls
 * are mode.  It sets a flag that controls whether the HDF
 * at_exit function is called.
 *
 * Inputs:  none
 * Outputs: none
 * Return:  none
 */
void haLibraryInitialized(void)
{
    HDF_library_initialized = 1;
}

/*
 * haVdetach
 *
 * Purpose: Prototype adapter for Vdetach
 *
 * Inputs:  vgroup_id
 * Outputs: none
 * Return:  status as an intn
 */
static intn haVdetach(int32 vgroup_id)
{
    return (intn) Vdetach(vgroup_id);
}


/*
 * haANend
 *
 * Purpose: Prototype adapter for ANend
 *
 * Inputs:  ann_id
 * Outputs: none
 * Return:  status as an intn
 */
static intn haANend(int32 ann_id)
{
    return (intn) ANend(ann_id);
}

/*
 * haInitializeLists
 *
 * Purpose:  initialize identifier lists
 *
 * Input:    none
 * Output:   none
 * Return:   none
 */
void haInitializeLists(void)
{
    listArray[RI_ID_List].list.idnum    = -1;
    listArray[RI_ID_List].list.next     = NULL;
    listArray[RI_ID_List].list.previous = NULL;
    listArray[RI_ID_List].idCloseFcn    = GRendaccess;
    listArray[RI_ID_List].name          = "RI";
    
    listArray[GR_ID_List].list.idnum    = -1;
    listArray[GR_ID_List].list.next     = NULL;
    listArray[GR_ID_List].list.previous = NULL;
    listArray[GR_ID_List].idCloseFcn    = GRend;
    listArray[GR_ID_List].name          = "GR";
    
    listArray[Access_ID_List].list.idnum    = -1;
    listArray[Access_ID_List].list.next     = NULL;
    listArray[Access_ID_List].list.previous = NULL;
    listArray[Access_ID_List].idCloseFcn    = Hendaccess;
    listArray[Access_ID_List].name          = "access";
    
    listArray[File_ID_List].list.idnum    = -1;
    listArray[File_ID_List].list.next     = NULL;
    listArray[File_ID_List].list.previous = NULL;
    listArray[File_ID_List].idCloseFcn    = Hclose;
    listArray[File_ID_List].name          = "file";

    listArray[AN_ID_List].list.idnum    = -1;
    listArray[AN_ID_List].list.next     = NULL;
    listArray[AN_ID_List].list.previous = NULL;
    listArray[AN_ID_List].idCloseFcn    = haANend;
    listArray[AN_ID_List].name          = "AN";

    listArray[Annot_ID_List].list.idnum    = -1;
    listArray[Annot_ID_List].list.next     = NULL;
    listArray[Annot_ID_List].list.previous = NULL;
    listArray[Annot_ID_List].idCloseFcn    = ANendaccess;
    listArray[Annot_ID_List].name          = "annotation";

    listArray[Point_ID_List].list.idnum    = -1;
    listArray[Point_ID_List].list.next     = NULL;
    listArray[Point_ID_List].list.previous = NULL;
    listArray[Point_ID_List].idCloseFcn    = PTdetach;
    listArray[Point_ID_List].name          = "point";

    listArray[Pointfile_ID_List].list.idnum    = -1;
    listArray[Pointfile_ID_List].list.next     = NULL;
    listArray[Pointfile_ID_List].list.previous = NULL;
    listArray[Pointfile_ID_List].idCloseFcn    = PTclose;
    listArray[Pointfile_ID_List].name          = "point file";

    listArray[Swath_ID_List].list.idnum    = -1;
    listArray[Swath_ID_List].list.next     = NULL;
    listArray[Swath_ID_List].list.previous = NULL;
    listArray[Swath_ID_List].idCloseFcn    = SWdetach;
    listArray[Swath_ID_List].name          = "swath";

    listArray[SWFile_ID_List].list.idnum    = -1;
    listArray[SWFile_ID_List].list.next     = NULL;
    listArray[SWFile_ID_List].list.previous = NULL;
    listArray[SWFile_ID_List].idCloseFcn    = SWclose;
    listArray[SWFile_ID_List].name          = "swath file";

    listArray[SDS_ID_List].list.idnum    = -1;
    listArray[SDS_ID_List].list.next     = NULL;
    listArray[SDS_ID_List].list.previous = NULL;
    listArray[SDS_ID_List].idCloseFcn    = SDendaccess;
    listArray[SDS_ID_List].name          = "scientific dataset";
    
    listArray[SD_ID_List].list.idnum    = -1;
    listArray[SD_ID_List].list.next     = NULL;
    listArray[SD_ID_List].list.previous = NULL;
    listArray[SD_ID_List].idCloseFcn    = SDend;
    listArray[SD_ID_List].name          = "scientific data file";

    listArray[GD_Grid_List].list.idnum    = -1;
    listArray[GD_Grid_List].list.next     = NULL;
    listArray[GD_Grid_List].list.previous = NULL;
    listArray[GD_Grid_List].idCloseFcn    = GDdetach;
    listArray[GD_Grid_List].name          = "grid";

    listArray[GD_File_List].list.idnum    = -1;
    listArray[GD_File_List].list.next     = NULL;
    listArray[GD_File_List].list.previous = NULL;
    listArray[GD_File_List].idCloseFcn    = GDclose;
    listArray[GD_File_List].name          = "grid file";

    listArray[Vgroup_ID_List].list.idnum    = -1;
    listArray[Vgroup_ID_List].list.next     = NULL;
    listArray[Vgroup_ID_List].list.previous = NULL;
    listArray[Vgroup_ID_List].idCloseFcn    = haVdetach;
    listArray[Vgroup_ID_List].name          = "Vgroup";

    listArray[VSdata_ID_List].list.idnum    = -1;
    listArray[VSdata_ID_List].list.next     = NULL;
    listArray[VSdata_ID_List].list.previous = NULL;
    listArray[VSdata_ID_List].idCloseFcn    = hdfVSDetachAndForget;
    listArray[VSdata_ID_List].name          = "Vdata";

    listArray[Vfile_ID_List].list.idnum    = -1;
    listArray[Vfile_ID_List].list.next     = NULL;
    listArray[Vfile_ID_List].list.previous = NULL;
    listArray[Vfile_ID_List].idCloseFcn    = Vfinish; /* The same as Vend */
    listArray[Vfile_ID_List].name          = "Vfile";

}

/*
 * haAddNodeToList
 *
 * Purpose:  Insert a new node at the beginning of a list
 *
 * Inputs:  list --- pointer to list
 *          new  --- pointer to node
 * Outputs: none
 * Return:  none
 */
static void haAddNodeToList(NodeType *list, NodeType *new)
{
    new->next = list->next;
    new->previous = list;
    list->next = new;
    if (new->next != NULL)
    {
        new->next->previous = new;
    }
}

/*
 * haDeleteNodeFromList
 *
 * Purpose:  Delete node from a list; free node memory
 *
 * Inputs:  node --- pointer to node  (this pointer gets freed)
 * Outputs: none
 * Return:  none
 */
static void haDeleteNodeFromList(NodeType *node)
{
    node->previous->next = node->next;
    if (node->next != NULL)
    {
        node->next->previous = node->previous;
    }
    free((void *) node);
}

/*
 * haFindNodeInList
 *
 * Purpose:  Find a node containing a given value
 *
 * Inputs:  list --- pointer to list to search
 *          match --- int32 value to search for
 * Outputs: none
 * Return:  pointer to node found, or NULL if no match is found
 */
static NodeType *haFindNodeInList(NodeType *list, int32 match)
{
    NodeType *current;
    int found = 0;

    current = list->next;
    while (current != NULL)
    {
        if (current->idnum == match)
        {
            found = 1;
            break;
        }
        else
        {
            current = current->next;
        }
    }

    if (found == 0)
    {
        current = NULL;
    }

    return(current);
}

/*
 * haAddIDToList
 *
 * Purpose:  Add an HDF interface identifier to the specified list
 *
 * Inputs:   id  --- int32 interface identifier
 * Outputs:  none
 * Return:   SUCCEED or FAIL
 */
intn haAddIDToList(int32 id, IDList list)
{
    NodeType *listHead = &(listArray[list].list);
    NodeType *new = NULL;
    intn result = SUCCEED;

    mxAssert(listHead != NULL,"");

    new = (NodeType *) malloc(sizeof(*new));
    if (new != NULL)
    {
        new->idnum = id;
        haAddNodeToList(listHead, new);
    }
    else
    {
        mexWarnMsgTxt("Out of memory in HDF MEX gateway.");
        result = FAIL;
    }

    return(result);
}

    

/*
 * haDeleteIDFromList
 *
 * Purpose: Delete interface identifier from the specified list
 *
 * Inputs:  id
 * Outputs: none
 * Return:  none
 */
void haDeleteIDFromList(int32 id, IDList list)
{
    NodeType *match_node;
    NodeType *listHead = &(listArray[list].list);

    mxAssert(listHead != NULL,"");

    match_node = haFindNodeInList(listHead, id);
    if (match_node != NULL)
    {
        haDeleteNodeFromList(match_node);
    }
}

/*
 * haCleanupList
 *
 * Purpose: Close all identifiers in list
 *
 * Inputs:   listInfo
 * Output:   none
 * Return:   none
 */
static void haCleanupList(ListInfo *listInfo)
{
    NodeType *list = &(listInfo->list);

    while (list->next != NULL)
    {
        (*listInfo->idCloseFcn)(list->next->idnum);
        haDeleteNodeFromList(list->next);
    }
}
    

/*
 * haMexAtExit
 *
 * Purpose: Close all open identifiers.  Print warnings if any
 *          open identifiers were found.
 *
 * Inputs:  none
 * Outputs: none
 * Return:  none
 */
void haMexAtExit(void)
{
    int i;
    char buffer[256];
    
    for (i = 0; i < Num_ID_Lists; i++)
    {
        if (listArray[i].list.next != NULL)
        {
            sprintf(buffer, "Closing %s identifiers left open.", listArray[i].name);
            mexWarnMsgTxt(buffer);
            haCleanupList(&listArray[i]);
        }
    }
    if (HDF_library_initialized)
	HPend();
}

/*
 * haQuietCleanup
 *
 * Purpose: Close all open identifiers.  Don't print warnings.
 *
 * Inputs:  none
 * Outputs: none
 * Return:  none
 */
void haQuietCleanup(void)
{
    int i;
    for (i = 0; i < Num_ID_Lists; i++)
    {
        haCleanupList(&listArray[i]);
    }
}

/*
 * haPrintIDListInfo
 *
 * Purpose: Print information about identifer lists to MATLAB command window
 *
 * Inputs:  none
 * Outputs: none
 * Return:  none
 * Side effect: prints information to command window
 */
void haPrintIDListInfo(void)
{
    NodeType *current;
    int i;
    
    for (i = 0; i < Num_ID_Lists; i++)
    {
        if (listArray[i].list.next == NULL)
        {
            mexPrintf("No open %s identifiers\n", listArray[i].name);
        }
        else
        {
            mexPrintf("Open %s identifiers:\n", listArray[i].name);
            current = listArray[i].list.next;
            while (current != NULL)
            {
                mexPrintf("\t%5d\n", current->idnum);
                current = current->next;
            }
        }
    }
}

/*
 * haStrcmpi - case-insensitive string compare
 * code borrowed from src/util/strcmpi.c
 */
int haStrcmpi(const char *s1, const char *s2)
{
    unsigned char c1, c2;

    if (s1 == NULL) s1 = "";
    if (s2 == NULL) s2 = "";

    for ( ; (c1 = tolower(*s1)) == (c2 = tolower(*s2)); s1++, s2++) {
	if (c1 == '\0') {
	    return 0;
	}
    }

    return (int)c1 - (int)c2;
}

/*
 * haNarginChk
 *
 * Purpose: Make sure number of input arguments falls within a
 *          valid range; produce an error if it doesn't.
 *
 * Inputs:  nMin --- minimum acceptable number of input arguments
 *          nMax --- maximum acceptable number of input arguments
 *          nIn  --- actual number of input arguments
 * Outputs: none
 * Return:  none
 */
void haNarginChk(int nMin, int nMax, int nIn)
{
    if (nIn < nMin)
    {
        mexErrMsgTxt("Too few input arguments.");
    }
    if (nIn > nMax)
    {
        mexErrMsgTxt("Too many input arguments.");
    }
}

/*
 * haNargoutChk
 *
 * Purpose: Make sure number of output arguments falls within a
 *          valid range; produce an error if it doesn't.
 *
 * Inputs:  nMin --- minimum acceptable number of output arguments
 *          nMax --- maximum acceptable number of output arguments
 *          nOut --- actual number of output arguments
 * Outputs: none
 * Return:  none
 */
void haNargoutChk(int nMin, int nMax, int nOut)
{
    if (nOut < nMin)
    {
        mexErrMsgTxt("Too few output arguments.");
    }
    if (nOut > nMax)
    {
        mexErrMsgTxt("Too many output arguments.");
    }
}

/*
 * haGetEOSCompressionCode
 *
 * Purpose: Given MATLAB string array, return HDF-EOS compression code
 *
 * Inputs:  inStr --- MATLAB string array
 * Outputs: none
 * Return:  HDF-EOS compression code; errors out if none found
 */
int32 haGetEOSCompressionCode(const mxArray *inStr)
{
    static struct 
    {
        char *compStrLong;
        char *compStrShort;
        intn compCode;
    }
    compCodes[] = 
    {
        {"hdfe_comp_rle",     "rle",     HDFE_COMP_RLE},
        {"hdfe_comp_skphuff", "skphuff", HDFE_COMP_SKPHUFF},
        {"hdfe_comp_deflate", "deflate", HDFE_COMP_DEFLATE},
        {"hdfe_comp_none",    "none",    HDFE_COMP_NONE}
    };
    static int numCompCodes = sizeof(compCodes) / sizeof(*compCodes);

    char buffer[BUFLEN];
    int32 compCode;
    int k = 0;
    bool codeFound = false;

    if (!mxIsChar(inStr))
    {
        mexErrMsgTxt("Compression code must be a string.");
    }
    
    mxGetString(inStr, buffer, BUFLEN);
    for (k = 0; k < numCompCodes; k++)
    {
        if ((haStrcmpi(buffer, compCodes[k].compStrShort) == 0) ||
            (haStrcmpi(buffer, compCodes[k].compStrLong) == 0))
        {
            compCode = compCodes[k].compCode;
            codeFound = true;
            break;
        }
    }
    
    if (! codeFound)
    {
        mexErrMsgTxt("Invalid compression code.");
    }

    return(compCode);
}

/*
 * haGetEOSCompressionParameters
 * 
 * Purpose: Get the HDF-EOS Compression parameters from a MATLAB array
 *
 * Inputs:  array - mxArray containing the code
 *    
 * Outputs: none
 * 
 * Returns: Compression Code
 */
void haGetEOSCompressionParameters(const mxArray *array, 
                                    intn compparm[NUM_EOS_COMP_PARMS])
{
    int length;
    double *data;
    int i;
    
    if (!mxIsDouble(array))
        mexErrMsgTxt("Invalid compression parameters, must be of class double.");
    
    length = mxGetNumberOfElements(array);

    if (length > NUM_EOS_COMP_PARMS)
    {
        mexErrMsgTxt("Compression parameters vector too large.");
    }
    
    data = mxGetPr(array);
    for (i = 0; i < length; i++)
    {
        compparm[i] = (intn) data[i];
    }
    for (i = length; i < NUM_EOS_COMP_PARMS; i++)
    {
        compparm[i] = 0;
    }
}

/*
 * haGetEOSMergeCode
 *
 * Purpose: Given MATLAB string array, return HDF-EOS merge code
 *
 * Inputs:  inStr --- MATLAB string array
 * Outputs: none
 * Return:  HDF-EOS merge code; errors out if none found
 */
int32 haGetEOSMergeCode(const mxArray *inStr)
{
    static struct 
    {
        char *mergeStrLong;
        char *mergeStrShort;
        intn mergeCode;
    }
    mergeCodes[] = 
    {
        {"hdfe_nomerge",    "nomerge",    HDFE_NOMERGE},
        {"hdfe_automerge",  "automerge",  HDFE_AUTOMERGE},
    };
    static int numMergeCodes = sizeof(mergeCodes) / sizeof(*mergeCodes);

    char buffer[BUFLEN];
    int32 mergeCode;
    int k = 0;
    bool codeFound = false;

    if (!mxIsChar(inStr))
    {
        mexErrMsgTxt("Merge code must be a string.");
    }
    
    mxGetString(inStr, buffer, BUFLEN);
    for (k = 0; k < numMergeCodes; k++)
    {
        if ((haStrcmpi(buffer, mergeCodes[k].mergeStrShort) == 0) ||
            (haStrcmpi(buffer, mergeCodes[k].mergeStrLong) == 0))
        {
            mergeCode = mergeCodes[k].mergeCode;
            codeFound = true;
            break;
        }
    }
    
    if (! codeFound)
    {
        mexErrMsgTxt("Invalid merge code.");
    }

    return(mergeCode);
}

/*
 * haGetCompressFlag
 *
 * Purpose: Given a string mxArray, return the corresponding HDF
 *          integer-valued compression flag.
 *
 * Inputs:  inStr --- mxArray containing one of these strings:
 *                    'none', 'jpeg', 'rle', or 'imcomp'
 * Outputs: none
 * Return:  compression flag
 */
uint16_T haGetCompressFlag(const mxArray *inStr)
{
    char *compressStr;
    uint16_T result;

    mxAssertS(inStr != NULL, "inStr is NULL");

    compressStr = haGetString(inStr, "Compression flag");
    if (strlen(compressStr) == 0)
    {
        mexErrMsgTxt("Compression flag cannot be empty.");
    }

    if (haStrcmpi(compressStr, "none") == 0)
    {
        result = COMP_NONE;
    }
    else if (haStrcmpi(compressStr, "jpeg") == 0)
    {
        result = COMP_JPEG;
    }
    else if (haStrcmpi(compressStr, "rle") == 0)
    {
        result = COMP_RLE;
    }
    else if (haStrcmpi(compressStr, "imcomp") == 0)
    {
        result = COMP_IMCOMP;
    }
    else
    {
        mexErrMsgTxt("Compression flag must be 'none', "
                     "'jpeg', 'rle', or 'imcomp'.");
    }

    mxFree(compressStr);

    return(result);
}

/*
 * haGetInterlaceString
 *
 * Purpose: Given HDF interlace flag, return the corresponding string
 *
 * Inputs:  il --- HDF interlace flag
 * Outputs: none
 * Return:  string: "pixel", "line", "component", or "unknown"        
 */
const char *haGetInterlaceString(int32 il)
{
    const char *result;

    switch (il)
    {
    case MFGR_INTERLACE_PIXEL:
        result = "pixel";
        break;

    case MFGR_INTERLACE_LINE:
        result = "line";
        break;

    case MFGR_INTERLACE_COMPONENT:
        result = "component";
        break;

    default:
        result = "unknown";
        break;
    }

    return(result);
}

/*
 * haGetInterlaceFlag
 *
 * Purpose: Given MATLAB string array, return HDF interlace flag value
 *
 * Inputs:  inStr --- MATLAB string array
 * Outputs: none
 * Return:  HDF interlace flag value
 */
int32 haGetInterlaceFlag(const mxArray *inStr)
{
    char *ilStr;
    int32 result;

    mxAssertS(inStr != NULL, "inStr is NULL");

    ilStr = haGetString(inStr, "Interlace specifier");

    if (haStrcmpi(ilStr, "pixel") == 0)
    {
        result = MFGR_INTERLACE_PIXEL;
    }
    else if (haStrcmpi(ilStr, "line") == 0)
    {
        result = MFGR_INTERLACE_LINE;
    }
    else if (haStrcmpi(ilStr, "component") == 0)
    {
        result = MFGR_INTERLACE_COMPONENT;
    }
    else
    {
        mexErrMsgTxt("Interlace specifier must be 'pixel', "
                     "'line', or 'component'.");
    }

    mxFree(ilStr);

    return(result);
}

static struct 
{
    char *accessStrLong;
    char *accessStrShort;
    intn accessMode;
}
accessModes[] = 
{
    {"dfacc_read",     "read",      DFACC_READ},
    {"dfacc_write",    "write",     DFACC_WRITE},
    {"dfacc_create",   "create",    DFACC_CREATE},
    {"dfacc_all",      "all",       DFACC_ALL},
    {"dfacc_rdonly",   "rdonly",    DFACC_RDONLY},
    {"dfacc_rdwr",     "rdwr",      DFACC_RDWR},
    {"dfacc_rdwr",     "readwrite", DFACC_RDWR},    /* this one for compatibility */
    {"dfacc_clobber",  "clobber",   DFACC_CLOBBER},
    {"dfacc_default",  "default",   DFACC_DEFAULT},
    {"dfacc_serial",   "serial",    DFACC_SERIAL},
    {"dfacc_parallel", "parallel",  DFACC_PARALLEL}
};

static int numAccessModes = sizeof(accessModes) / sizeof(*accessModes);

/*
 * haGetAccessMode
 *
 * Purpose: Given MATLAB string array, return HDF access mode flag value
 *
 * Inputs:  inStr --- MATLAB string array
 * Outputs: none
 * Return:  HDF access mode flag value; errors out if none found
 */
intn haGetAccessMode(const mxArray *inStr)
{
    char buffer[BUFLEN];
    intn access = -1;
    bool found = false;
    int k = 0;

    if (!mxIsChar(inStr))
    {
        mexErrMsgTxt("Access specifier must be a string.");
    }

    mxGetString(inStr, buffer, BUFLEN);
    for (k = 0; k < numAccessModes; k++)
    {
        if ((haStrcmpi(buffer, accessModes[k].accessStrShort) == 0) ||
            (haStrcmpi(buffer, accessModes[k].accessStrLong) == 0))
        {
            access = accessModes[k].accessMode;
            found = true;
            break;
        }
    }
    
    if (! found)
    {
        mexErrMsgTxt("Invalid access specifier.");
    }

    return(access);
}


/*
 * haGetFieldIndex
 *
 * Purpose: return double value of input or _HDF_VDATA if input is 'vdata'.
 *
 * Inputs:  f --- MATLAB string array
 * Outputs: none
 * Return:  field_index parameter
 */
int32 haGetFieldIndex(const mxArray *f)
{
	char *field_str;
	int32 field_index;
	
    if (mxIsChar(f))
    {
    	field_str = haGetString(f,"Field index");
    	if (haStrcmpi(field_str,"vdata") != 0)
    	{
    		mxFree(field_str);
    		mexErrMsgTxt("Field index must be a field number or the string 'vdata'.");
    	}
    	mxFree(field_str);
    	field_index = _HDF_VDATA;
    }
    else
    	field_index = (int32) haGetDoubleScalar(f, "Field index");

    return(field_index);
}


/*
 * haGetDirection
 *
 * Purpose: Given MATLAB string array, return the corresponding HDF direction
 *          flag
 *
 * Inputs:  inStr --- MATLAB string array
 * Outputs: none
 * Return:  HDF direction flag
 */
intn haGetDirection(const mxArray *inStr)
{
    char *directionStr;
    intn result;

    mxAssertS(inStr != NULL, "inStr is NULL");

    directionStr = haGetString(inStr, "Direction flag");

    if (haStrcmpi(directionStr, "forward") == 0)
    {
        result = DF_FORWARD;
    }
    else if (haStrcmpi(directionStr, "backward") == 0)
    {
        result = DF_BACKWARD;
    }
    else
    {
        mexErrMsgTxt("Direction flag must be 'forward' or 'backward'.");
    }

    mxFree(directionStr);

    return(result);
}

/*
 * haGetDoubleScalar
 *
 * Purpose: Get double value from MATLAB array; error out if array is
 *          empty or not double
 *
 * Inputs:  A --- MATLAB array
 *          name --- string identifying what the input array is supposed
 *                   to represent.  name is used to construct a
 *                   meaningful error message.
 * Outputs: none
 * Return:  double-precision value
 *
 * Note: This function does not insist that the input array be
 * a scalar or that it be real.  It just always returns the first
 * element of the real part.
 */ 
double haGetDoubleScalar(const mxArray *A, char *name)
{
    double result;
    char error_message[255];
    static char trailer[] = " must be a scalar double.";

    mxAssertS(A != NULL, "NULL mxArray pointer");
    mxAssertS(name != NULL, "NULL char pointer");

    if (!mxIsDouble(A) || mxIsEmpty(A))
    {
        strncpy(error_message, name, 255-strlen(trailer)-1);
        strcat(error_message, trailer);
        mexErrMsgTxt(error_message);
    }

    result = *mxGetPr(A);
    return(result);
}
    
/*
 * haGetNonNegativeDoubleScalar
 *
 * Purpose: Get non-negative double value from MATLAB array; 
 *          error out if array is not a scalar, negative, 
 *          complex, or not double
 *
 * Inputs:  A --- MATLAB array
 *          name --- string identifying what the input array is supposed
 *                   to represent.  name is used to construct a
 *                   meaningful error message.
 * Outputs: none
 * Return:  double-precision value
 */ 
double haGetNonNegativeDoubleScalar(const mxArray *A, char *name)
{
    double result;
    char error_message[255];
    static char trailer[] = " must be a non-negative scalar double.";

    mxAssertS(A != NULL, "NULL mxArray pointer");
    mxAssertS(name != NULL, "NULL char pointer");

    if (!mxIsDouble(A) || mxGetNumberOfElements(A) != 1 || mxIsComplex(A) ||
        (*mxGetPr(A) < 0.0))
    {
        strncpy(error_message, name, 255-strlen(trailer)-1);
        strcat(error_message, trailer);
        mexErrMsgTxt(error_message);
    }

    result = *mxGetPr(A);
    return(result);
}


int haGetNumberOfElements(int rank,const int *siz)
{
	int i;
	int result = 1;
	
	for (i=0; i<rank; i++)
		result *= siz[i];
		
	return result;
}

/*
 * haGetIntegerVector
 *
 * Purpose: Get a dimension oriented integer vector from MATLAB array. 
 *          The vector length must be less than MAX_VAR_DIMS.  Example vectors
 *          include origin vectors, stride vectors, edge vectors, start vectors.
 *
 * Inputs:  V --- MATLAB array
 *          rank --- expected number of elements in V.
 *          name --- string identifying what the input array is supposed
 *                   to represent.  name is used to construct a
 *                   meaningful error message.
 * Outputs: vec vector
 * Return:  none
 *       
 */ 
void haGetIntegerVector(const mxArray *V, int32 rank, const char *name, int32 *vec)
{
    char error_message[255];
    static char trailer[] = " must be a double vector whose length is the\nnumber of dimensions of the dataset.";
    double *pr;
    int i;

    mxAssertS(V != NULL, "NULL mxArray pointer");

	if (mxGetNumberOfElements(V) != rank || !mxIsDouble(V))
	{
            strncpy(error_message, name, 255-strlen(trailer)-1);
            strcat(error_message, trailer);
            mexErrMsgTxt(error_message);
	}
	pr = mxGetPr(V);
	for (i=0; i<mxGetNumberOfElements(V); i++)
	{
		if (mxIsInf(pr[i]))
			vec[i] = SD_UNLIMITED;
		else
			vec[i] = (int32) pr[i];
	}
}



/*
 * haGetDimensions
 *
 * Purpose: Get dimension vector and rank from MATLAB arrays.
 *
 * Inputs:  rank --- MATLAB array
 *          dimsizes --- MATLAB array
 * Outputs: siz vector
 * Return:  rank (ndims)
 *
 * Note: This function checks to make sure that rank == length(dimsizes).  The output buffer
 * siz must contain at least MAX_VAR_DIMS elements.  dimsizes will be padded with trailing
 * ones if rank > length(dimsizes).
 *       
 */ 
int32 haGetDimensions(const mxArray *rank, const mxArray *dimsizes, int32 *siz)
{
    int32 ndims;
    double *pr;
    int i;

    mxAssertS(rank != NULL, "NULL mxArray pointer");
    mxAssertS(dimsizes != NULL, "NULL mxArray pointer");

	ndims = (int32) haGetDoubleScalar(rank,"Rank");
	
	if (ndims != mxGetNumberOfElements(dimsizes))
	{
		mexErrMsgTxt("Rank must be == length(dimsizes).");
	}
	if (mxGetNumberOfElements(dimsizes) > MAX_VAR_DIMS)
	{
		mexErrMsgTxt("Dimsizes vector too long.");
	}

	pr = mxGetPr(dimsizes);
	for (i=0; i<mxGetNumberOfElements(dimsizes); i++)
	{
		if (mxIsInf(pr[i]))
			siz[i] = SD_UNLIMITED;
		else
			siz[i] = (int32) pr[i];
	}

    return(ndims);
}


/*
 * haGetString
 * 
 * Purpose: Get C string from MATLAB string array; error out if
 *          array is not a string array
 *
 * Inputs:  A --- MATLAB array
 *          name --- string identifying what the input array is supposed
 *                   to represent.  name is used to construct a
 *                   meaningful error message.
 * Outputs: none
 * Return:  string
 *
 * Note:  This function allocates memory to hold the string.  
 * The calling function is responsible for freeing the memory when done
 * with it!
 */
char *haGetString(const mxArray *A, char *name)
{
    int numEl;
    char *result = NULL;
    char error_message[255];
    static char trailer[] = " must be a string.";


    mxAssertS(A != NULL, "NULL mxArray pointer");
    mxAssertS(name != NULL, "NULL char pointer");

    if (!mxIsChar(A))
    {
        strncpy(error_message, name, 255-strlen(trailer)-1);
        strcat(error_message, trailer);
        mexErrMsgTxt(error_message);
    }

    numEl = mxGetM(A) * mxGetN(A) * sizeof(mxChar);
    result = mxCalloc(numEl+1, sizeof(*result));

    mxGetString(A, result, numEl+1);

    return(result);
}

/*
 * haCreateDoubleScalar
 *
 * Purpose: Create a MATLAB scalar array with a given value
 *
 * Inputs:  scalar --- value to assign to the MATLAB array
 * Outputs: none
 * Return:  MATLAB scalar array
 */
mxArray *haCreateDoubleScalar(double scalar)
{
    return mxCreateDoubleScalar(scalar);
}


/*
 * haGetCompType
 *
 * Purpose: Get compression type from input argument
 *
 * Inputs:  mxCHAR array containing compression type as a string
 *          Handles 'none','jpeg','rle','deflate',or 'skphuff'
 * Outputs: none
 * Return:  Compression type enum
 */
int32 haGetCompType(const mxArray *s)
{
	int32 ret;
	char *comp_type = haGetString(s,"Compression method");

	if (haStrcmpi(comp_type,"none")==0)
		ret = COMP_CODE_NONE;
/*	else if (haStrcmpi(comp_type,"jpeg")==0) */
/* 		ret = COMP_CODE_JPEG;         */
	else if (haStrcmpi(comp_type,"rle")==0)
		ret = COMP_CODE_RLE;
	else if (haStrcmpi(comp_type,"deflate")==0)
		ret = COMP_CODE_DEFLATE;
	else if (haStrcmpi(comp_type,"skphuff")==0)
		ret = COMP_CODE_SKPHUFF;
	else
		mexErrMsgTxt("Unknown or invalid compression type.");
	
	mxFree(comp_type);
	return ret;
}

/*
 * haGetCompTypeString
 *
 * Purpose: Get compression type string from enum
 *
 * Inputs:  comp_type enum
 * Outputs: none
 * Return:  mxChar array containing equivalent matlab string.
 *          Handles 'none','jpeg','rle','deflate',or 'skphuff'
 */
mxArray *haGetCompTypeString(int32 comp_type)
{
	mxArray *ret;

	if (comp_type == COMP_CODE_NONE)
		ret = mxCreateString("none");
/* 	else if (comp_type == COMP_CODE_JPEG) */
/* 		ret = mxCreateString("jpeg"); */
	else if (comp_type == COMP_CODE_RLE)
		ret = mxCreateString("rle");
	else if (comp_type == COMP_CODE_DEFLATE)
		ret = mxCreateString("deflate");
	else if (comp_type == COMP_CODE_SKPHUFF)
		ret = mxCreateString("skphuff");
	else
		ret = mxCreateString("unknown type");

	return ret;	
}



/*
 * haGetCompInfo
 *
 * Purpose: Process cinfo param/value pair.  Pass one pair at a time.
 *
 * Inputs:  p -- mxCHAR array containing parameter name.
 *          v -- mxArray containing parameter value.
 * Outputs: cinfo structure (which must be created before calling this routine)
 * Return:  none.
 *
 * Parameters handled:
 *  'jpeg_quality' -- integer
 *  'jpeg_force_baseline' -- integer
 *  'skphuff_skp_size' -- integer
 *  'deflate_level' -- integer
 */
void haGetCompInfo(const mxArray *p, const mxArray *v,comp_info *cinfo)
{
	char *param = haGetString(p,"Compression info parameter");
	
	if (haStrcmpi(param,"jpeg_quality")==0)
	{
		cinfo->jpeg.quality = (intn) haGetDoubleScalar(v,"JPEG quality parameter");
	}
	else if (haStrcmpi(param,"jpeg_force_baseline")==0)
	{
		cinfo->jpeg.force_baseline = (intn) haGetDoubleScalar(v,
											"JPEG force baseline parameter");
	}
	else if (haStrcmpi(param,"skphuff_skp_size")==0)
	{
		cinfo->skphuff.skp_size = (intn) haGetDoubleScalar(v,"Skip size");
	}
	else if (haStrcmpi(param,"deflate_level")==0)
	{
		cinfo->deflate.level = (intn) haGetDoubleScalar(v,"Deflate level");
	}
	else
		mexErrMsgTxt("Unknown or invalid parameter.");
		
	mxFree(param);
}

/*
 * haCreateCharArray
 *
 * Purpose: Create an mxChar MATLAB array from a character buffer.
 *
 * Inputs:  rank -- rank (ndims) of array.
 *          siz -- vector of dimension sizes
 *          data -- character buffer.
 *          n -- number of characters in buffer.
 * Outputs: none.
 * Return:  MATLAB mxChar array.
 */
mxArray *haCreateCharArray(int32 rank,const int *siz,const char *data,int32 n)
{
	mxArray *ret = NULL;
	mxChar *d;
	int i;
	
	if (n==0)
		ret = EMPTYSTR;
	else
	{
		ret = mxCreateNumericArray(rank,siz,mxCHAR_CLASS,mxREAL);
		d = (mxChar *)mxGetData(ret);
		mxAssertS(n == haGetNumberOfElements(rank,siz),
			"Buffer length and number of array elements must match");
		
		for (i=0; i<n; i++)
		{
			d[i] = data[i];
		}
	}
	
	return ret;
}

/*
 * haSizeMatches
 *
 * Purpose: Return true if A as the same size as siz and the same number of dimensions.
 *          This routine assumes the size of A can contain trailing singleton dimensions.
 *
 * Inputs:  A -- MATLAB array
 *          siz -- vector of dimension sizes to match
 *          rank -- number of dimensions to match
 * Outputs: none.
 * Return:  1 if A has the correct size.  0 if not.
 */
int haSizeMatches(const mxArray *A,int32 rank,int *siz)
{
	int i;
	const int *dims = mxGetDimensions(A);
	int ndims = mxGetNumberOfDimensions(A);
	
	
	if (ndims == rank) /* Simple case -- ndims of A matches */
	{
		for (i=0; i<rank; i++)
		{
			if (siz[i] != dims[i])
				return 0;
		}
		return 1;
	} 
	else if (ndims > rank) /* Simple case -- A has wrong size */
	{
            /* Check for the case of the 1-D vector in MATLAB where ndims==2 */
            if ((ndims == 2) && (rank == 1))
            {
                if ((dims[0] == 1) && (dims[1] == siz[0]))
                    return 1;
                else if ((dims[1] == 1) && (dims[0] == siz[0]))
                    return 1;
                else
                    return 0;
            }
            else
            {
                return 0;
            }
	}
	else /* complicated case -- treat A as if it has lots of trailing singletons */
	{
		for (i=0; i<ndims; i++)
		{
			if (siz[i] != dims[i])
				return 0;
		}
		for (i=ndims; i<rank; i++)
		{
			if (siz[i] != 1)
				return 0;
		}
		return 1;
	}
	
}

/*
 * haIsNULL
 *
 * Purpose: Determine if input is NULL.  An empty double matrix is considered to be NULL.
 *
 * Inputs:  A -- MATLAB array
 * Outputs: none
 * Return:  1 if null, 0 otherwise
 */
int haIsNULL(const mxArray *A)
{
	return(mxIsEmpty(A) && mxIsDouble(A));
}

/*
 * haCreateEmptyString
 *
 * Purpose: Create 0-by-0 string array.
 *
 * Inputs:  none
 * Outputs: none
 * Return:  mxArray *
 */
mxArray *haCreateEmptyString(void)
{
	int siz[2] = {0,0};
	
	return mxCreateNumericArray(2, siz, mxCHAR_CLASS, mxREAL);
}

/*
 * Table containing numbertypes, string representations, and
 * the corresponding data types.  Note that where there is
 * more than one HDF number type corresponding to the same
 * mxClassID, the table order is significant!  The first
 * table entry corresponding to a given mxClassID is the
 * default number type that will be used when creating an
 * HDF data object from a MATLAB array.  For example, the
 * default HDF number type for mxCHAR_CLASS is DFNT_UCHAR8.
 */
typedef 
struct  NumberTypeTable {
    char *numTypeStrLong;
    char *numTypeStrShort;
    int32 numType;
    int32 size;
    mxClassID classID;
} NumberTypeTable;

static NumberTypeTable  allNumberTypes[] = {
    {"dfnt_char8",        "char8",          DFNT_CHAR8,         1,  mxCHAR_CLASS},
    {"dfnt_uchar8",       "uchar8",         DFNT_UCHAR8,        1,  mxCHAR_CLASS},
    {"dfnt_uchar",        "uchar",          DFNT_UCHAR,         1,  mxCHAR_CLASS},
    {"dfnt_char",         "char",           DFNT_CHAR,          1,  mxCHAR_CLASS},
    {"dfnt_uchar16",      "uchar16",        DFNT_UCHAR16,       2,  mxCHAR_CLASS},
    {"dfnt_char16",       "char16",         DFNT_CHAR16,        2,  mxCHAR_CLASS},
    {"dfnt_double",       "double",         DFNT_DOUBLE,        8,  mxDOUBLE_CLASS},
    {"dfnt_uint8",        "uint8",          DFNT_UINT8,         1,  mxUINT8_CLASS},
    {"dfnt_uint16",       "uint16",         DFNT_UINT16,        2,  mxUINT16_CLASS},
    {"dfnt_uint32",       "uint32",         DFNT_UINT32,        4,  mxUINT32_CLASS},
    {"dfnt_float",        "float",          DFNT_FLOAT,         4,  mxSINGLE_CLASS},
    {"dfnt_int8",         "int8",           DFNT_INT8,          1,  mxINT8_CLASS},
    {"dfnt_int16",        "int16",          DFNT_INT16,         2,  mxINT16_CLASS},
    {"dfnt_int32",        "int32",          DFNT_INT32,         4,  mxINT32_CLASS},
    {"dfnt_int64",        "int64",          DFNT_INT64,         8,  mxUNKNOWN_CLASS},
    {"dfnt_uint64",       "uint64",         DFNT_UINT64,        8,  mxUNKNOWN_CLASS},
    {"dfnt_float32",      "float32",        DFNT_FLOAT32,       4,  mxSINGLE_CLASS},
    {"dfnt_float64",      "float64",        DFNT_FLOAT64,       8,  mxDOUBLE_CLASS},
    {"dfnt_none",         "none",           DFNT_NONE,          0,  mxUNKNOWN_CLASS},
    {"dfnt_query",        "query",          DFNT_QUERY,         0,  mxUNKNOWN_CLASS},
    {"dfnt_version",      "version",        DFNT_VERSION,       0,  mxUNKNOWN_CLASS},
    {"dfnt_float128",     "float128",       DFNT_FLOAT128,      16, mxUNKNOWN_CLASS},
    {"dfnt_int128",       "int128",         DFNT_INT128,        16, mxUNKNOWN_CLASS},
    {"dfnt_uint128",      "uint128",        DFNT_UINT128,       16, mxUNKNOWN_CLASS},
    {"dfnt_nfloat32",     "nfloat32",       DFNT_NFLOAT32,  	4,  mxSINGLE_CLASS},
    {"dfnt_nfloat64",     "nfloat64",       DFNT_NFLOAT64,      8,  mxDOUBLE_CLASS},
    {"dfnt_nfloat128",    "nfloat128",      DFNT_NFLOAT128,     16, mxUNKNOWN_CLASS},
    {"dfnt_nint8",        "nint8",          DFNT_NINT8,         1,  mxINT8_CLASS},
    {"dfnt_nuint8",       "nuint8",         DFNT_NUINT8,        1,  mxUINT8_CLASS},
    {"dfnt_nint16",       "nint16",         DFNT_NINT16,        2,  mxINT16_CLASS},
    {"dfnt_nuint16",      "nuint16",        DFNT_NUINT16,       2,  mxUINT16_CLASS},
    {"dfnt_nint32",       "nint32",         DFNT_NINT32,        4,  mxINT32_CLASS},
    {"dfnt_nuint32",      "nuint32",        DFNT_NUINT32,       4,  mxUINT32_CLASS},
    {"dfnt_nint64",       "nint64",         DFNT_NINT64,        8,  mxUNKNOWN_CLASS},
    {"dfnt_nuint64",      "nuint64",        DFNT_NUINT64,       8,  mxUNKNOWN_CLASS},
    {"dfnt_nint128",      "nint128",        DFNT_NINT128,       16, mxUNKNOWN_CLASS},
    {"dfnt_nuint128",     "nuint128",       DFNT_NUINT128,      16, mxUNKNOWN_CLASS},
    {"dfnt_nchar8",       "nchar8",         DFNT_NCHAR8,        1,  mxCHAR_CLASS},
    {"dfnt_nchar",        "nchar",          DFNT_NCHAR,         1,  mxCHAR_CLASS},
    {"dfnt_nuchar8",      "nuchar8",        DFNT_NUCHAR8,       1,  mxCHAR_CLASS},
    {"dfnt_nuchar",       "nuchar",         DFNT_NUCHAR,        1,  mxCHAR_CLASS},
    {"dfnt_nchar16",      "nchar16",        DFNT_NCHAR16,       2,  mxCHAR_CLASS},
    {"dfnt_nuchar16",     "nuchar16",       DFNT_NUCHAR16,      2,  mxCHAR_CLASS},
    {"dfnt_lfloat32",     "lfloat32",       DFNT_LFLOAT32,      4,  mxSINGLE_CLASS},
    {"dfnt_lfloat64",     "lfloat64",       DFNT_LFLOAT64,      8,  mxDOUBLE_CLASS},
    {"dfnt_lfloat128",    "lfloat128",      DFNT_LFLOAT128,     16, mxUNKNOWN_CLASS},
    {"dfnt_lint8",        "lint8",          DFNT_LINT8,         1,  mxINT8_CLASS},
    {"dfnt_luint8",       "luint8",         DFNT_LUINT8,        1,  mxUINT8_CLASS},        
    {"dfnt_lint16",       "lint16",         DFNT_LINT16,        2,  mxINT16_CLASS},
    {"dfnt_luint16",      "luint16",        DFNT_LUINT16,       2,  mxUINT16_CLASS},
    {"dfnt_lint32",       "lint32",         DFNT_LINT32,        4,  mxINT32_CLASS},
    {"dfnt_luint32",      "luint32",        DFNT_LUINT32,       4,  mxUINT32_CLASS},
    {"dfnt_lint64",       "lint64",         DFNT_LINT64,        8,  mxUNKNOWN_CLASS},
    {"dfnt_luint64",      "luint64",        DFNT_LUINT64,       8,  mxUNKNOWN_CLASS},
    {"dfnt_lint128",      "lint128",        DFNT_LINT128,       16, mxUNKNOWN_CLASS},
    {"dfnt_luint128",     "luint128",       DFNT_LUINT128,      16, mxUNKNOWN_CLASS},
    {"dfnt_lchar8",       "lchar8",         DFNT_LCHAR8,        1,  mxCHAR_CLASS},
    {"dfnt_lchar",        "lchar",          DFNT_LCHAR,         1,  mxCHAR_CLASS},
    {"dfnt_luchar8",      "luchar8",        DFNT_LUCHAR8,       1,  mxCHAR_CLASS},
    {"dfnt_luchar",       "luchar",         DFNT_LUCHAR,        1,  mxCHAR_CLASS},
    {"dfnt_lchar16",      "lchar16",        DFNT_LCHAR16,       2,  mxCHAR_CLASS},
    {"dfnt_luchar16",     "luchar16",       DFNT_LUCHAR16,  	2,  mxCHAR_CLASS},
};

static int numNumberTypes = sizeof(allNumberTypes) / sizeof(*allNumberTypes);

/*
 * haMakeUChar8First
 *
 * Purpose: Make mxCHAR_CLASS map to DFNT_UCHAR8
 *
 * Inputs: None
 * Outputs: None
 * Return: SUCCEED or FAIL
 */
intn haMakeUChar8First(void)
{
    int i;
    int k;
    bool found = false;
    intn result = SUCCEED;
    NumberTypeTable temp;

    for (i=0; i<numNumberTypes; i++)
        {
            if ( allNumberTypes[i].numType == DFNT_UCHAR8 )
                {
                    found = true;
                    k=i;
                    break;
                }
        }
    
    if (! found)
        {
            mexErrMsgTxt("DFNT_UCHAR8 not found.");
        }

    for (i=0; i<numNumberTypes; i++)
        {
            if ( allNumberTypes[i].numType == DFNT_CHAR8 )
                {
                    found = true;
		    break;
		}
	}

    if (! found)
        {
            mexErrMsgTxt("DFNT_CHAR8 not found.");
        }

    if ( k > i ) /* Only swap if DNFT_UCHAR8 is not first */
	{
            temp = allNumberTypes[i];
	    allNumberTypes[i] = allNumberTypes[k];
            allNumberTypes[k] = temp;
        }
    return(result);
}


/*
 * haMakeChar8First
 *
 * Purpose: Make mxCHAR_CLASS map to DFNT_CHAR8
 *
 * Inputs: None
 * Outputs: None
 * Return: SUCCEED or FAIL
 */

intn haMakeChar8First(void)
{
    int i;
    int k;
    bool found = false;
    intn result=SUCCEED;
    NumberTypeTable temp;
    
    for (i=0; i<numNumberTypes; i++)
        {
            if ( allNumberTypes[i].numType == DFNT_UCHAR8 )
                {
                    found = true;
                    k=i;
                    break;
                }
        }
    
    if (! found)
        {
            mexErrMsgTxt("DFNT_UCHAR8 not found.");
        }
    
    for (i=0; i<numNumberTypes; i++)
        {
            if ( allNumberTypes[i].numType == DFNT_CHAR8 )
                {
                    found = true;
                    break;
                }
        }
    
    if (! found)
        {
            mexErrMsgTxt("DFNT_CHAR8 not found.");
        }
    
    if ( k < i ) /* Only swap if DNFT_CHAR8 is not first */
        {
            temp = allNumberTypes[i];
            allNumberTypes[i] = allNumberTypes[k];
            allNumberTypes[k] = temp;
        }
    return(result);
}



/*
 * haGetDataTypeString
 *
 * Purpose: Given HDF data-type flag value, return the 
 *          corresponding short string
 *
 * Inputs:  datatype
 * Outputs: none
 * Return:  data-type string
 */
const char *haGetDataTypeString(int32 datatype)
{
    int i;
    int k = 0;
    bool found = false;
	
    for (i=0; i<numNumberTypes; i++)
    {
        if ( datatype == allNumberTypes[i].numType )
        {
            k = i;
            found = true;
            break;
        }
    }
    
    if (! found)
    {
        mexErrMsgTxt("Invalid or unsupported data type.");
    }
    
    return(allNumberTypes[k].numTypeStrShort);
}

/*
 * haGetDataType
 *
 * Purpose: Given MATLAB string array, return HDF data type flag value
 *
 * Inputs:  inStr --- MATLAB string array
 * Outputs: none
 * Return:  HDF data-type flag value
 */
int32 haGetDataType(const mxArray *inStr)
{
    int i;
    char buffer[BUFLEN];
    int32 numberType;
    bool found = false;

    if (! mxIsChar(inStr))
    {
        mexErrMsgTxt("Number type must be a string.");
    }
    
    mxGetString(inStr, buffer, BUFLEN);
    for (i=0; i<numNumberTypes; i++)
    {
        if ( !haStrcmpi(buffer,allNumberTypes[i].numTypeStrLong) ||
             !haStrcmpi(buffer,allNumberTypes[i].numTypeStrShort) )
        {
            numberType = allNumberTypes[i].numType;
            found = true;
            break;
        }
    }

    if (! found)
        mexErrMsgTxt("Invalid or unsupported data type.");

    return(numberType);
}

/*
 * haGetDataTypeFromClassID
 *
 * Purpose: Given MATLAB class ID, return corresponding HDF data type flag
 *
 * Inputs:  classID --- MATLAB class ID
 * Outputs: none
 * Return:  HDF data-type flag
 */
int32 haGetDataTypeFromClassID(mxClassID classID)
{
    int i;
    int k = 0;
    bool found = false;
	
    for (i=0; i<numNumberTypes; i++)
    {
        if (classID == allNumberTypes[i].classID)
        {
            k = i;
            found = true;
            break;
        }
    }
    if (! found)
    {
        mexErrMsgTxt("Unrecognized MATLAB Class ID.");
    }
    
    return(allNumberTypes[k].numType);
}

/*
 * haGetClassIDFromDataType
 *
 * Purpose: Given an HDF integer-valued flag indicating data type,
 *          return the corresponding MATLAB class ID.  Returns
 *          mxUNKNOWN_CLASS for unsupported data types.
 *
 * Inputs:  data_type --- HDF data type flag
 * Outputs: none
 * Return:  MATLAB class ID
 */
mxClassID haGetClassIDFromDataType(int32 data_type)
{
    int k;
    int p = 0;
    bool found = false;

    for (k=0; k<numNumberTypes; k++)
    {
        if (allNumberTypes[k].numType == data_type)
        {
            p = k;
            found = true;
            break;
        }
    }
    if (! found)
    {
        mexErrMsgTxt("Unknown HDF number type.");
    }
    
    return(allNumberTypes[p].classID);
}

/*
 * haGetNumberTypeString
 *
 * Purpose: Return a string corresponding to HDF number type.
 *
 * Inputs:  numbertype --- HDF number type
 * Outputs: none
 * Return:  string pointer
 */
const char *haGetNumberTypeString(int32 numbertype)
{
    int k;
    bool found = false;
    const char *result;
    
    for (k = 0; k < numNumberTypes; k++)
    {
        if (allNumberTypes[k].numType == numbertype)
        {
            result = allNumberTypes[k].numTypeStrShort;
            found = true;
            break;
        }
    }
    
    if (! found)
    {
        return("unknown");
    }
    else
    {
        return(result);
    }
}

/*
 * haGenerateNumberTypeArray
 *
 * Purpose: Return a cell array of number type strings.
 *
 * Inputs:  length     - lenght of the cell array to return
 *          numbertype - array of length length with the numbertype
 *
 * Return:  MATLAB array
 */
mxArray *haGenerateNumberTypeArray(int length, int32 *numbertype)
{
    mxArray *out;
    const char *numberTypeStr;
    int i=0;
    int k;

    out = mxCreateCellMatrix(length, 1);
    
    for (k=0; k<length; k++) 
    {
        numberTypeStr = haGetNumberTypeString(numbertype[k]);
        mxSetCell(out, k, mxCreateString(numberTypeStr));
    }

    return(out);
}
            
/*
 * haGetDataTypeSize
 *
 * Purpose: Given an HDF integer-values flag indicating data type,
 *          return the data type's size in bytes.  Returns 0 if
 *          unknown.
 *
 * Inputs:  data_type --- HDF data type flag
 * Outputs: none
 * Return:  data type size in bytes
 */
int32 haGetDataTypeSize(int32 data_type)
{
    int k;
    int p = 0;
    bool found = false;
    
    for (k=0; k<numNumberTypes; k++)
    {
        if (allNumberTypes[k].numType == data_type)
        {
            p = k;
            found = true;
            break;
        }
    }
    if (! found)
    {
        mexErrMsgTxt("Unknown HDF number type.");
    }
    
    return(allNumberTypes[p].size);
}

/*
 * haMakeHDFDataBuffer
 *
 * Purpose: Given desired number of elements and the
 *          HDF data type, allocate and return a buffer 
 *          of the appropriate size.
 *
 * Inputs:  num_elements --- number of data elements
 *          data_type    --- HDF data type flag
 * Outputs: none
 * Return:  allocated buffer (NULL if allocation fails)
 */
VOIDP haMakeHDFDataBuffer(int32 num_elements, int32 data_type)
{
    VOIDP buffer = NULL;
    int32 element_size = haGetDataTypeSize(data_type);
    
    if (element_size > 0)
    {
        buffer = mxCalloc(num_elements, element_size);
        if (buffer == NULL)
        {
            HEpush(DFE_NOSPACE,"haMakeHDFDataBuffer",__FILE__,__LINE__);
        }
    }
    return(buffer);
}

/*
 * haMakeHDFDataBufferFromCharArray
 *
 * Purpose: Given MATLAB char array, allocate a buffer of the desired
 *          HDF data type and copy/cast the char array data into it.
 *          Caller must free the buffer.
 */
VOIDP haMakeHDFDataBufferFromCharArray(const mxArray *inStr, int32 datatype)
{
    VOIDP *result;
    mxChar *in_ptr = (mxChar *) mxGetData(inStr);
    int num_elems = mxGetNumberOfElements(inStr);
    int k;

    if ((datatype == DFNT_UCHAR8) || (datatype == DFNT_UCHAR))
    {
        uint8_T *buf_ptr = mxCalloc(num_elems, sizeof(*buf_ptr));
        for (k = 0; k < num_elems; k++)
        {
            buf_ptr[k] = (uint8_T) in_ptr[k];
        }
        result = (VOIDP) buf_ptr;
    }
    
    else if ((datatype == DFNT_CHAR8) || (datatype == DFNT_CHAR))
    {
        int8_T *buf_ptr = mxCalloc(num_elems, sizeof(*buf_ptr));
        for (k = 0; k < num_elems; k++)
        {
            buf_ptr[k] = (int8_T) in_ptr[k];
        }
        result = (VOIDP) buf_ptr;
    }
    
    else if (datatype == DFNT_UCHAR16)
    {
        uint16_T *buf_ptr = mxCalloc(num_elems, sizeof(*buf_ptr));
        for (k = 0; k < num_elems; k++)
        {
            buf_ptr[k] = (uint16_T) in_ptr[k];
        }
        result = (VOIDP) buf_ptr;
    }
    
    else if (datatype == DFNT_CHAR16)
    {
        int16_T *buf_ptr = mxCalloc(num_elems, sizeof(*buf_ptr));
        for (k = 0; k < num_elems; k++)
        {
            buf_ptr[k] = (int16_T) in_ptr[k];
        }
        result = (VOIDP) buf_ptr;
    }
    else
    {
        mexErrMsgTxt("Unrecognized HDF char data type.");
    }

    return(result);
}

/*
 * haMakeCharArrayFromHDFDataBuffer
 * 
 * Purpose: Create a MATLAB char array from any of the HDF char types.
 *          This function copies the data, so the calling function
 *          can free or modify the data buffer after this call.
 *
 * Inputs:  ndims     --- number of dimensions of MATLAB char array
 *          siz       --- size vector for MATLAB char array
 *          data_type --- HDF data type flag
 *          data      --- data buffer
 * Outputs: none
 * Return:  array     --- might be NULL if memory failure
 */
static
mxArray *haMakeCharArrayFromHDFDataBuffer(int ndims, int siz[],
                                          int32 data_type, VOIDP data)
{
    mxArray *array = mxCreateNumericArray(ndims, siz, mxCHAR_CLASS, mxREAL);
    
    if (array != NULL)
    {
        int num_elements = mxGetNumberOfElements(array);
        mxChar *array_ptr = mxGetChars(array);
        int k = 0;
        uchar8 *uchar8_ptr = NULL;
        char8 *char8_ptr = NULL;
        uint16_T *uchar16_ptr = NULL;
        int16_T *char16_ptr = NULL;
        
        switch (data_type)
        {
        case DFNT_UCHAR8:   /* fall-through */
            /*
             * There should be a DFNT_UCHAR case, but it's defined
             * to be the same as DFNT_UCHAR8, which causes some
             * compilers to complain.
             */
            uchar8_ptr = (uchar8 *) data;
            for (k = 0; k < num_elements; k++)
            {
                *array_ptr++ = (mxChar) *uchar8_ptr++;
            }
            break;
            
        case DFNT_CHAR8:   /* fall-through */
            /*
             * There should be a DFNT_CHAR case, but it's defined
             * to be the same as DFNT_CHAR8, which causes some
             * compilers to complain.
             */
            char8_ptr = (char8 *) data;
            for (k = 0; k < num_elements; k++)
            {
                *array_ptr++ = (mxChar) *char8_ptr++;
            }
            break;
            
        case DFNT_UCHAR16:
            uchar16_ptr = (uint16_T *) data;
            for (k = 0; k < num_elements; k++)
            {
                *array_ptr++ = (mxChar) *uchar16_ptr++;
            }
            break;
            
        case DFNT_CHAR16:
            char16_ptr = (int16_T *) data;
            for (k = 0; k < num_elements; k++)
            {
                *array_ptr++ = (mxChar) *char16_ptr++;
            }
            break;
            
        default:
            mexErrMsgTxt("Unknown HDF char data type.");
        }
    }
    
    return(array);
}

/*
 * haMakeArrayFromHDFDataBuffer
 *
 * Purpose: Given a data buffer, HDF data type, and
 *          MATLAB ndims and size vectors, construct
 *          an mxArray from the data buffer.
 *          Automatically construct a MATLAB string
 *          from any of the HDF char data types.
 *
 * Inputs:  ndims       --- number of dimensions of MATLAB array
 *          siz         --- MATLAB array size vector
 *          data_type   --- HDF data type flag
 *          data        --- data buffer
 * Outputs: ok_to_free  --- boolean indicating whether the
 *                          calling function is allowed
 *                          to free the data buffer
 * Return:  mxArray     --- NULL if memory failure
 */
mxArray *haMakeArrayFromHDFDataBuffer(int ndims, int siz[],
                                      int32 data_type, VOIDP data,
                                      bool *ok_to_free)
{
    mxArray *array = NULL;
    mxClassID classID = haGetClassIDFromDataType(data_type);

    *ok_to_free = false;

    if (classID == mxUNKNOWN_CLASS)
    {
        mexErrMsgTxt("Unsupported HDF data type.");
    }
    
    if ((classID == mxCHAR_CLASS) && (data_type != DFNT_UCHAR16))
    {
        array = haMakeCharArrayFromHDFDataBuffer(ndims, siz, data_type, data);
        *ok_to_free = true;
    }
    else
    {
        int emptySiz[2] = {0, 0};
        array = mxCreateNumericArray(2, emptySiz, classID, mxREAL);
        if (mxSetDimensions(array, siz, ndims) != 0)
        {
            /* set dimensions failed */
            mxDestroyArray(array);
            array = NULL;
        }
        else
        {
            mxSetData(array, data);
        }
    }
    if (array == NULL)
    {
        HEpush(DFE_NOSPACE,"MakeArrayFromHDFDataBuffer",__FILE__,__LINE__);
        *ok_to_free = true;
    }
    return(array);
}

/*
 * haRegJPGHandler
 *
 * Purpose: Register message and error handlers in the JPEG library
 *          
 * Inputs:  none
 * Outputs: none
 * Return:  void
 */
void
haRegJPGHandler()
{
    init_jpg_error_handler( my_error_exit );
    init_jpg_message_handler( my_output_message );
}

/*
 * my_error_exit
 *
 * Purpose: Error handler for the JPG library
 *          
 * Inputs:  cinfo  --- pointer to the JPEG information struct
 * Outputs: none
 * Return:  void
 */
static void
my_error_exit (j_common_ptr cinfo)
{  
    char buffer[JMSG_LENGTH_MAX];
 
    /* Let the memory manager delete any temp files before we die */
    jpeg_destroy(cinfo);

    (*cinfo->err->format_message) (cinfo, buffer);
    /* Return gracefully to MATLAB */
    mexErrMsgTxt(buffer);
}

/*
 * my_output_message
 *
 * Purpose: Message handler for the JPG library
 *          
 * Inputs:  cinfo  --- pointer to the JPEG information struct
 * Outputs: none
 * Return:  void
 */
static void
my_output_message (j_common_ptr cinfo)
{
  char buffer[JMSG_LENGTH_MAX];

  /* Create the message */
  (*cinfo->err->format_message) (cinfo, buffer);

  /* Send it to MATLAB Command Window */
  mexWarnMsgTxt(buffer);
}

        
    

