/* Copyright 1984-2002 The MathWorks, Inc.  */

/*
 * hdfan.c --- support file for HDF.MEX
 *
 * This module supports the HDF AN interface.  The only public
 * function is hdfAN(), which is called by mexFunction().
 * hdfAN looks at the second input argument to determine which
 * private function should get control.
 *
 */

/* $Revision: 1.1.6.1 $  $Date: 2003/12/13 03:01:50 $ */

static char rcsid[] = "$Id: hdfan.c,v 1.1.6.1 2003/12/13 03:01:50 batserve Exp $";

#include <string.h>
#include <math.h>

/* Main HDF library header file */
#include "hdf.h"
#include "mfan.h"

/* MATLAB API header file */
#include "mex.h"

/* HDFMEX utility functions */
#include "hdfutils.h"

#include "hdfan.h"

/*
 * GetAnnotationType
 *
 * Purpose: Given MATLAB string array, return the corresponding HDF 
 *          annotation type
 *
 * Inputs:  inStr --- MATLAB string array
 * Outputs: none
 * Return:  HDF annotation type
 */
static ann_type GetAnnotationType(const mxArray *inStr)
{
    char *annotationStr;
    ann_type result;

    mxAssertS(inStr != NULL, "inStr is NULL");

    annotationStr = haGetString(inStr, "Annotation type");

    if (strcmp(annotationStr, "data_label") == 0)
    {
        result = AN_DATA_LABEL;
    }
    else if (strcmp(annotationStr, "data_desc") == 0)
    {
        result = AN_DATA_DESC;
    }
    else if (strcmp(annotationStr, "file_label") == 0)
    {
        result = AN_FILE_LABEL;
    }
    else if (strcmp(annotationStr, "file_desc") == 0)
    {
        result = AN_FILE_DESC;
    }
    else
    {
        mexErrMsgTxt("Direction flag must be 'data_label', "
                     "'data_desc', 'file_label', or 'file_desc'.");
    }

    mxFree(annotationStr);

    return(result);
}

/*
 * hdfANannlength
 *
 * Purpose: gateway to ANannlen()
 *          returns the length, in bytes, of the annotation specified
 *          by the given annotation identifier
 *
 * MATLAB usage:
 * length = hdf('AN', 'annlen', ann_id)
 *          Returns -1 on failure
 */
static void hdfANannlen(int nlhs,
                        mxArray *plhs[],
                        int nrhs,
                        const mxArray *prhs[])
{
    int32 length, ann_id;
    
    haNarginChk(3, 3, nrhs);
    haNargoutChk(0, 1, nlhs);
    
    ann_id = (int32) haGetDoubleScalar(prhs[2], "Annotation ID");

    length = ANannlen(ann_id);

    plhs[0] = haCreateDoubleScalar((double) length);
}

/*
 * hdfANannlist
 *
 * Purpose: gateway to ANannlist()
 *          returns a list of annotation identifiers for the annotations
 *          in the file that correspond to the annotation type and
 *          object tag/ref specified.
 *
 * MATLAB usage:
 * [ann_list, status] = hdf('AN', 'annlist', an_id, ann_type, obj_tag, obj_ref)
 *          ann_type can be either 'data_label' or 'data_desc'.
 */
static void hdfANannlist(int nlhs,
                         mxArray *plhs[],
                         int nrhs,
                         const mxArray *prhs[])
{
    intn status = SUCCEED;
    int32 ann_id;
    ann_type annot_type;
    uint16 obj_tag;
    uint16 obj_ref;
    int32 *ann_list = NULL;
    intn num_annotations;
    double *pr;
    int i;
    
    haNarginChk(6, 6, nrhs);
    haNargoutChk(0, 2, nlhs);

    ann_id = (int32) haGetDoubleScalar(prhs[2], "Annotation ID");

    annot_type = GetAnnotationType(prhs[3]);
    if ((annot_type == AN_FILE_LABEL) || (annot_type == AN_FILE_DESC))
    {
        mexErrMsgTxt("File annotation types not allowed with this syntax.");
    }

    obj_tag = (uint16) haGetDoubleScalar(prhs[4], "Object tag");
    obj_ref = (uint16) haGetDoubleScalar(prhs[5], "Object ref");

    num_annotations = ANnumann(ann_id, annot_type, obj_tag, obj_ref);
    if (num_annotations == FAIL)
    {
        status = FAIL;
    }
    else
    {
        if (num_annotations > 0)
        {
            ann_list = mxCalloc(num_annotations, sizeof(*ann_list));
            if (ann_list == NULL)
            {
                status = FAIL;
            }
            else
            {
                status = ANannlist(ann_id, annot_type, obj_tag, 
                                   obj_ref, ann_list);
            }
        }
    }
    
    if (status != FAIL)
    {
        plhs[0] = mxCreateDoubleMatrix(num_annotations, 1, mxREAL);
        pr = (double *) mxGetData(plhs[0]);
        for (i = 0; i < num_annotations; i++)
        {
            pr[i] = (double) ann_list[i];
        }

        if (nlhs > 1)
        {
            plhs[1] = haCreateDoubleScalar((double) status);
        }
    }
    else
    {
        plhs[0] = EMPTY;
        
        if (nlhs > 1)
        {
            plhs[1] = haCreateDoubleScalar((double) status);
        }
    }
    
    if (ann_list != NULL)
    {
        mxFree(ann_list);
    }
}


/*
 * hdfANatype2tag
 *
 * Purpose: gateway to ANatype2tag()
 *          returns the tag corresponding to the specified annotation type.
 *
 * MATLAB usage:
 * tag = hdf('AN', 'atype2tag', annot_type)
 *       annot_type can be 'file_label', 'file_desc', 'data_label', 
 *       or 'data_desc'.
 */
static void hdfANatype2tag(int nlhs,
                           mxArray *plhs[],
                           int nrhs,
                           const mxArray *prhs[])
{
    uint16 tag;
    ann_type anno_type;

    haNarginChk(3, 3, nrhs);
    haNargoutChk(0, 1, nlhs);

    anno_type = GetAnnotationType(prhs[2]);
    tag = ANatype2tag(anno_type);
    plhs[0] = haCreateDoubleScalar((double) tag);
}

/*
 * hdfANcreate
 *
 * Purpose: gateway to ANcreate()
 *          creates a data annotation for the object identified by the 
 *          specified tag and reference number.
 *
 * MATLAB usage:
 * annot_id = hdf('AN', 'create', an_id, tag, ref, annot_type)
 *       annot_type can be 'data_label', 'data_desc'.
 */
static void hdfANcreate(int nlhs,
                        mxArray *plhs[],
                        int nrhs,
                        const mxArray *prhs[])
{
    int32    an_id;
    uint16   tag;
    uint16   ref;
    ann_type annot_type;
    int32    annot_id;
    intn     status;

    haNarginChk(6, 6, nrhs);
    haNargoutChk(0, 1, nlhs);
    
    an_id = (int32) haGetDoubleScalar(prhs[2], "AN ID");
    tag = (uint16) haGetDoubleScalar(prhs[3], "tag");
    ref = (uint16) haGetDoubleScalar(prhs[4], "ref");
    annot_type = GetAnnotationType(prhs[5]);
    
    if ((annot_type == AN_FILE_LABEL) || (annot_type == AN_FILE_DESC))
    {
        mexErrMsgTxt("annotation type must be 'data_label' or "
                     "'data_desc'.");
    }
    
    annot_id = ANcreate(an_id, tag, ref, annot_type);
    if (annot_id != FAIL)
    {
        status = haAddIDToList(annot_id, Annot_ID_List);
        if (status == FAIL)
        {
            /* 
             * Couldn't add the identifier to the appropriate list.
             * This is bad because data could be lost.  Don't allow
             * this to happen --- close the identifier and return
             * failed status.
             */
            ANendaccess(annot_id);
            annot_id = FAIL;
        }
    }
    
    plhs[0] = haCreateDoubleScalar((double) annot_id);
}

/*
 * hdfANcreatef
 *
 * Purpose: gateway to ANcreatef()
 *          creates a file label or file description annotation.
 *
 * MATLAB usage:
 * annot_id = hdf('AN', 'createf', an_id, annot_type)
 *       annot_type can be 'file_label', 'file_desc'.
 */
static void hdfANcreatef(int nlhs,
                         mxArray *plhs[],
                         int nrhs,
                         const mxArray *prhs[])
{
    int32    an_id;
    ann_type annot_type;
    int32    annot_id;
    intn     status;

    haNarginChk(4, 4, nrhs);
    haNargoutChk(0, 1, nlhs);
    
    an_id = (int32) haGetDoubleScalar(prhs[2], "AN ID");
    annot_type = GetAnnotationType(prhs[3]);
    
    if ((annot_type == AN_DATA_LABEL) || (annot_type == AN_DATA_DESC))
    {
        mexErrMsgTxt("annotation type must be 'file_label' or "
                     "'file_desc'.");
    }
    
    annot_id = ANcreatef(an_id, annot_type);
    if (annot_id != FAIL)
    {
        status = haAddIDToList(annot_id, Annot_ID_List);
        if (status == FAIL)
        {
            /* 
             * Couldn't add the identifier to the appropriate list.
             * This is bad because data could be lost.  Don't allow
             * this to happen --- close the identifier and return
             * failed status.
             */
            ANendaccess(annot_id);
            annot_id = FAIL;
        }
    }
    
    plhs[0] = haCreateDoubleScalar((double) annot_id);
}

/*
 * hdfANdestroy
 *
 * Purpose: gateway to ANdestroy()
 *          deallocates all internal data structures used by the 
 *          multifile annotation interface.
 *
 * MATLAB usage:
 * status = hdf('AN', 'destroy');
 */
static void hdfANdestroy(int nlhs,
                         mxArray *plhs[],
                         int nrhs,
                         const mxArray *prhs[])
{
    haNarginChk(2, 2, nrhs);
    haNargoutChk(0, 1, nlhs);

    plhs[0] = haCreateDoubleScalar((double) ANdestroy());
}

/*
 * hdfANend
 *
 * Purpose: gateway to ANend()
 *          terminates access to the multifile annotation interface
 *
 * MATLAB usage:
 * status = hdf('AN', 'end', an_id);
 */
static void hdfANend(int nlhs,
                     mxArray *plhs[],
                     int nrhs,
                     const mxArray *prhs[])
{
    int32  an_id;
    intn   status;
    
    haNarginChk(3, 3, nrhs);
    haNargoutChk(0, 1, nlhs);

    an_id = (int32) haGetDoubleScalar(prhs[2], "AN ID");
    status = ANend(an_id);
    if (status != FAIL)
    {
        haDeleteIDFromList(an_id, AN_ID_List);
    }
    plhs[0] = haCreateDoubleScalar((double) status);
}

/*
 * hdfANendaccess
 *
 * Purpose: gateway to ANendaccess()
 *          terminates access to an annotation
 *
 * MATLAB usage:
 * status = hdf('AN', 'endaccess', annot_id);
 */
static void hdfANendaccess(int nlhs,
                           mxArray *plhs[],
                           int nrhs,
                           const mxArray *prhs[])
{
    int32  annot_id;
    intn   status;
    
    haNarginChk(3, 3, nrhs);
    haNargoutChk(0, 1, nlhs);

    annot_id = (int32) haGetDoubleScalar(prhs[2], "annotation ID");
    status = ANendaccess(annot_id);
    if (status != FAIL)
    {
        haDeleteIDFromList(annot_id, Annot_ID_List);
    }
    plhs[0] = haCreateDoubleScalar((double) status);
}

/*
 * hdfANfileinfo
 *
 * Purpose: gateway to ANfileinfo()
 *          returns the number of annotations of each type in the current file
 *
 * MATLAB usage:
 * [nfl, nfd, ndl, ndd, status] = hdf('AN', 'fileinfo', an_id);
 */
static void hdfANfileinfo(int nlhs,
                          mxArray *plhs[],
                          int nrhs,
                          const mxArray *prhs[])
{
    intn  status;
    int32 an_id;
    int32 n_file_label;
    int32 n_file_desc;
    int32 n_data_label;
    int32 n_data_desc;
    
    haNarginChk(3, 3, nrhs);
    haNargoutChk(0, 5, nlhs);

    an_id = (int32) haGetDoubleScalar(prhs[2], "AN ID");
    
    status = ANfileinfo(an_id, &n_file_label, &n_file_desc,
                        &n_data_label, &n_data_desc);
    

    plhs[0] = (status == FAIL) ? EMPTY : 
        haCreateDoubleScalar((double) n_file_label);

    if (nlhs > 1)
    {
        plhs[1] = (status == FAIL) ? EMPTY : 
            haCreateDoubleScalar((double) n_file_desc);
    }

    if (nlhs > 2)
    {
        plhs[2] = (status == FAIL) ? EMPTY : 
            haCreateDoubleScalar((double) n_data_label);
    }

    if (nlhs > 3)
    {
        plhs[3] = (status == FAIL) ? EMPTY : 
            haCreateDoubleScalar((double) n_data_desc);
    }

    if (nlhs > 4)
    {
        plhs[4] = haCreateDoubleScalar((double) status);
    }
}

/*
 * hdfANgettagref
 *
 * Purpose: gateway to ANget_tagref()
 *          returns the tag/reference number pair of the specified annotation
 *
 * MATLAB usage:
 * [tag, ref, status] = hdf('AN','get_tagref',an_id,index,annot_type)
 */
static void hdfANgettagref(int nlhs,
                           mxArray *plhs[],
                           int nrhs,
                           const mxArray *prhs[])
{
    int32 an_id;
    int32 index;
    ann_type annot_type;
    uint16 ann_tag;
    uint16 ann_ref;
    int32 status;

    haNarginChk(5, 5, nrhs);
    haNargoutChk(0, 3, nlhs);

    an_id = (int32) haGetDoubleScalar(prhs[2], "AN ID");
    index = (int32) haGetDoubleScalar(prhs[3], "annotation index");
    annot_type = GetAnnotationType(prhs[4]);
    
    status = ANget_tagref(an_id, index, annot_type, &ann_tag, &ann_ref);
    
    plhs[0] = (status == FAIL) ? EMPTY : 
        haCreateDoubleScalar((double) ann_tag);

    if (nlhs > 1)
    {
        plhs[1] = (status == FAIL) ? EMPTY : 
            haCreateDoubleScalar((double) ann_ref);
    }

    if (nlhs > 2)
    {
        plhs[2] = haCreateDoubleScalar((double) status);
    }
}

/*
 * hdfANid2tagref
 *
 * Purpose: gateway to ANid2tagref
 *          returns the tag/reference number pair of the specified annotation
 *
 * MATLAB usage:
 * [tag, ref, status] = hdf('AN','id2tagref',annot_id)
 */
static void hdfANid2tagref(int nlhs,
                           mxArray *plhs[],
                           int nrhs,
                           const mxArray *prhs[])
{
    int32 annot_id;
    uint16 ann_tag;
    uint16 ann_ref;
    int32 status;

    haNarginChk(3, 3, nrhs);
    haNargoutChk(0, 3, nlhs);

    annot_id = (int32) haGetDoubleScalar(prhs[2], "AN ID");
    
    status = ANid2tagref(annot_id, &ann_tag, &ann_ref);
    
    plhs[0] = (status == FAIL) ? EMPTY : 
        haCreateDoubleScalar((double) ann_tag);

    if (nlhs > 1)
    {
        plhs[1] = (status == FAIL) ? EMPTY : 
            haCreateDoubleScalar((double) ann_ref);
    }

    if (nlhs > 2)
    {
        plhs[2] = haCreateDoubleScalar((double) status);
    }
}

/*
 * hdfANnumann
 *
 * Purpose: gateway to ANnumann
 *          returns the total number of annotations in the file that
 *          correspond to the annotation type specified by annot_type,
 *          the tag specified by obj_tag, and the reference number
 *          specified by obj_ref.
 *
 * MATLAB usage:
 * num_annot = hdf('AN','numann',an_id,annot_type,tag,ref)
 */
static void hdfANnumann(int nlhs,
                        mxArray *plhs[],
                        int nrhs,
                        const mxArray *prhs[])
{
    int32 an_id;
    ann_type annot_type;
    uint16 tag;
    uint16 ref;
    intn num_annot;

    haNarginChk(6, 6, nrhs);
    haNargoutChk(0, 1, nlhs);

    an_id = (int32) haGetDoubleScalar(prhs[2], "AN ID");
    annot_type = GetAnnotationType(prhs[3]);
    tag = (uint16) haGetDoubleScalar(prhs[4],"object tag");
    ref = (uint16) haGetDoubleScalar(prhs[5],"object reference");

    if ((annot_type != AN_DATA_LABEL) && (annot_type != AN_DATA_DESC))
    {
        mexErrMsgTxt("annot_type must be 'data_label' or 'data_desc'.");
    }
    
    num_annot = ANnumann(an_id, annot_type, tag, ref);
    
    plhs[0] = haCreateDoubleScalar((double) num_annot);
}

/*
 * hdfANreadann
 *
 * Purpose: gateway to ANreadann
 *          reads the annotation identified by the specified
 *          annotation identifier.
 *
 * MATLAB usage:
 * [annot_string, status] = hdf('AN','readann',annot_id,max_str_length)
 */
static void hdfANreadann(int nlhs,
                         mxArray *plhs[],
                         int nrhs,
                         const mxArray *prhs[])
{
    int32 annot_id;
    int32 textbuf_length;
    char  *textbuf;
    intn  status;
    
    haNarginChk(3, 4, nrhs);
    haNargoutChk(0, 2, nlhs);

    annot_id = (int32) haGetDoubleScalar(prhs[2], "annotation ID");
    if(nrhs==4)
        {
            textbuf_length = (int32) haGetDoubleScalar(prhs[3], "max string length");
        }
    else
        {
            textbuf_length = ANannlen(annot_id)+1;
        }

    if (textbuf_length != FAIL)
        {
            textbuf = mxCalloc(textbuf_length+1, sizeof(*textbuf));
            if (textbuf == NULL)
                {
                    status = FAIL;
                }
            else
                {
                    status = ANreadann(annot_id, textbuf, textbuf_length);
                }
        }
    else
        {
            status = FAIL;
        }
    
    plhs[0] = (status == FAIL) ? mxCreateString("") : 
        mxCreateString(textbuf);
    mxFree(textbuf);

    if (nlhs > 1)
    {
        plhs[1] = haCreateDoubleScalar((double) status);
    }
}

/*
 * hdfANselect
 *
 * Purpose: gateway to ANselect
 *          selects and returns the identifier for the annotation
 *          identified by the specified index and annotation type
 *
 * MATLAB usage:
 * annot_id = hdf('AN','select',an_id,index,annot_type)
 */
static void hdfANselect(int nlhs,
                        mxArray *plhs[],
                        int nrhs,
                        const mxArray *prhs[])
{
    int32 an_id;
    int32 index;
    ann_type annot_type;
    int32 annot_id;
    intn  status;
    
    haNarginChk(5, 5, nrhs);
    haNargoutChk(0, 1, nlhs);

    an_id = (int32) haGetDoubleScalar(prhs[2], "AN ID");
    index = (int32) haGetDoubleScalar(prhs[3], "annotation index");
    annot_type = GetAnnotationType(prhs[4]);
    
    annot_id = ANselect(an_id, index, annot_type);
    
    if (annot_id != FAIL)
    {
        status = haAddIDToList(annot_id, Annot_ID_List);
        if (status == FAIL)
        {
            /*
             * Couldn't add the id to the proper list; this could cause
             * the user to lose data, so we don't allow this.  Close the id.
             */
            ANendaccess(annot_id);
            annot_id = FAIL;
        }
    }
    
    plhs[0] = haCreateDoubleScalar((double) annot_id);
}

/*
 * hdfANstart
 *
 * Purpose: gateway to ANstart
 *          initializes the multifile annotation interface
 *
 * MATLAB usage:
 * an_id = hdf('AN','start',file_id)
 */
static void hdfANstart(int nlhs,
                       mxArray *plhs[],
                       int nrhs,
                       const mxArray *prhs[])
{
    int32 file_id;
    int32 an_id;
    intn  status;
    
    haNarginChk(3, 3, nrhs);
    haNargoutChk(0, 1, nlhs);

    file_id = (int32) haGetDoubleScalar(prhs[2], "file ID");
    an_id = ANstart(file_id);
    
    if (an_id != FAIL)
    {
        status = haAddIDToList(an_id, AN_ID_List);
        if (status == FAIL)
        {
            /*
             * Couldn't add the id to the proper list; this could cause
             * the user to lose data, so we don't allow this.  Close the id.
             */
            ANend(an_id);
            an_id = FAIL;
        }
    }
    
    plhs[0] = haCreateDoubleScalar((double) an_id);
}

/*
 * hdfANtag2atype
 *
 * Purpose: gateway to ANtag2atype
 *          returns the annotation type corresponding to the specifed
 *          tag
 *
 * MATLAB usage:
 * annot_type = hdf('AN','tag2atype',tag)
 */
static void hdfANtag2atype(int nlhs,
                           mxArray *plhs[],
                           int nrhs,
                           const mxArray *prhs[])
{
    uint16 tag;
    ann_type annot_type;
    
    haNarginChk(3, 3, nrhs);
    haNargoutChk(0, 1, nlhs);

    tag = (uint16) haGetDoubleScalar(prhs[2], "tag");
    annot_type = ANtag2atype(tag);

    switch (annot_type)
    {
    case AN_DATA_LABEL:
        plhs[0] = mxCreateString("data_label");
        break;
            
    case AN_DATA_DESC:
        plhs[0] = mxCreateString("data_desc");
        break;
        
    case AN_FILE_LABEL:
        plhs[0] = mxCreateString("file_label");
        break;
        
    case AN_FILE_DESC:
        plhs[0] = mxCreateString("file_desc");
        break;
        
    default:
        plhs[0] = mxCreateString("");
        break;
    }
}

/*
 * hdfANtagref2id
 *
 * Purpose: gateway to ANtagref2id
 *          retrieves an annotation for a specified tag/ref pair
 *
 * MATLAB usage:
 * annot_id = hdf('AN','tagref2id',an_id,tag,ref)
 */
static void hdfANtagref2id(int nlhs,
                           mxArray *plhs[],
                           int nrhs,
                           const mxArray *prhs[])
{
    uint16 tag;
    uint16 ref;
    int32 an_id;
    int32 annot_id;
    
    haNarginChk(5, 5, nrhs);
    haNargoutChk(0, 1, nlhs);

    an_id = (int32) haGetDoubleScalar(prhs[2], "AN ID");
    tag = (uint16) haGetDoubleScalar(prhs[3], "tag");
    ref = (uint16) haGetDoubleScalar(prhs[4], "ref");

    annot_id = ANtagref2id(an_id,tag,ref);

    plhs[0] = haCreateDoubleScalar((double) annot_id);
}

/*
 * hdfANwriteann
 *
 * Purpose: gateway to ANwriteann
 *          writes an annotation to the current HDF file
 *
 * MATLAB usage:
 * status = hdf('AN','writeann',annot_id,annot_str)
 */
static void hdfANwriteann(int nlhs,
                          mxArray *plhs[],
                          int nrhs,
                          const mxArray *prhs[])
{
    int32 annot_id;
    int32 annot_length;
    intn  status;
    char  *annot_str;
   
    haNarginChk(4, 4, nrhs);
    haNargoutChk(0, 1, nlhs);

    annot_id = (int32) haGetDoubleScalar(prhs[2], "annotation ID");
    annot_str = haGetString(prhs[3],"annotation");
    annot_length = strlen(annot_str);

    status = ANwriteann(annot_id, annot_str, annot_length);
    plhs[0] = haCreateDoubleScalar((double) status);
}

/*
 * hdfAN
 *
 * Purpose: Function switchyard for the AN part of the HDF gateway.
 *
 * Inputs:  nlhs --- number of left-side arguments
 *          plhs --- left-side arguments
 *          nrhs --- number of right-side arguments
 *          prhs --- right-side arguments
 *          functionStr --- string specifying which AN function to call
 * Outputs: none
 * Return:  none
 */
void hdfAN(int nlhs,
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
    } ANFcns[] = {
        {"annlen",      hdfANannlen},
        {"annlist",     hdfANannlist},
        {"atype2tag",   hdfANatype2tag},
        {"create",      hdfANcreate},
        {"createf",     hdfANcreatef},
        {"destroy",     hdfANdestroy},
        {"end",         hdfANend},
        {"endaccess",   hdfANendaccess},
        {"fileinfo",    hdfANfileinfo},
        {"get_tagref",  hdfANgettagref},
        {"id2tagref",   hdfANid2tagref},
        {"numann",      hdfANnumann},
        {"readann",     hdfANreadann},
	{"select",      hdfANselect},
        {"start",       hdfANstart},
        {"tag2atype",   hdfANtag2atype},
        {"tagref2id",   hdfANtagref2id},
        {"writeann",    hdfANwriteann},
        {"",            NULL}
    };
    
    int i = 0;
    
    if (nrhs > 0)
        functionStr = haGetString(prhs[1],"Function name");
    else
        mexErrMsgTxt("Not enough input arguments.");
    
    while (ANFcns[i].func != NULL)
    {
        if (strcmp(functionStr,ANFcns[i].name)==0)
        {
            (*(ANFcns[i].func))(nlhs, plhs, nrhs, prhs);
            mxFree(functionStr);
            return;
        }
        i++;
    }
    mxFree(functionStr);
    mexErrMsgTxt("Unknown HDF AN interface function.");
}
