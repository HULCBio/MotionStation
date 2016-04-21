/* Copyright 1984-2002 The MathWorks, Inc.  */

/*
 * hdfh.c --- support file for HDF.MEX
 *
 * This module supports the HDF H interface.  The only public
 * function is hdfH(), which is called by mexFunction().
 * hdfH looks at the second input argument to determine which
 * private function should get control.
 *
 * Syntaxes
 * ========
 * status = hdf('H', 'appendable', access_id)
 *
 * status = hdf('H', 'close', file_id)
 *
 * status = hdf('H', 'deldd', file_id, tag, ref_num)
 *
 * status = hdf('H', 'dupdd', file_id, tag, ref, old_tag, old_ref)
 *
 * status = hdf('H', 'endaccess', access_id)
 *
 * [filename, access_mode, attach, status] = hdf('H', 'fidinquire', file_id)
 *
 * [tag, ref, offset, length, status] =
 *       hdf('H', 'find', file_id, search_tag, search_ref, search_type, dir)
 *       direction can be 'forward' or 'backward'
 *       search_type can be 'new' or 'continue'
 *
 * [data, status] = hdfHgetelement('H', 'getelement', file_id, tag, ref)
 *     data is a uint8 array containing the byte-stream of the given element
 *
 * [major, minor, release, info, status] = hdf('H', 'getfileversion', file_id)
 *
 * [major, minor, release, info, status] = hdf('H', 'getlibversion')
 *
 * [file_id, tag, ref, length, offset, position, access, special, status] =
 *           hdf('H', 'inquire', access_id)
 *
 * ishdf = hdf('H', 'ishdf', filename)
 *
 * length = hdf('H', 'length', file_id, tag, ref)
 *
 * ref = hdf('H', 'newref', file_id)
 *       returns 0 if unsuccessful
 *
 * status = hdf('H', 'nextread', access_id, tag, ref, origin)
 *          origin can be 'start' or 'current'
 *
 * num = hdf('H', 'number', file_id, tag)
 *
 * offset = hdf('H', 'offset', file_id, tag, ref)
 *
 * file_id = hdf('H', 'open', filename, access, n_dds)
 *           access can be 'read', 'write', 'readwrite', 'create'
 *
 * count = hdf('H', 'putelement', file_id, tag, ref, X)
 *         X must be a uint8 array
 *
 * X = hdf('H', 'read', access_id, length)
 *     If length is 0, read the rest of the data element
 *     length(X) is the number of bytes successfully read
 *
 * status = hdf('H', 'seek', access_id, offset, origin)
 *          origin can be 'start' or 'current'
 *
 * access_id = hdf('H', 'startread', file_id, tag, ref)
 *
 * access_id = hdf('H', 'startwrite', file_id, tag, ref, length)
 *
 * status = hdf('H', 'sync', file_id)
 *
 * length = hdf('H', 'trunc', access_id, trunc_len)
 *
 * count = hdf('H', 'write', access_id, X)
 *         X must be a uint8 array
 *
 */

/* $Revision: 1.1.6.1 $  $Date: 2003/12/13 03:02:04 $ */

static char rcsid[] = "$Id: hdfh.c,v 1.1.6.1 2003/12/13 03:02:04 batserve Exp $";

#include <string.h>
#include <math.h>

/* Main HDF library header file */
#include "hdf.h"

/* H interface header file */
#include "hfile.h"

/* MATLAB API header file */
#include "mex.h"

/* HDFMEX utility functions */
#include "hdfutils.h"

#include "hdfh.h"

/*
 * hdfHappendable
 *
 * Purpose: gateway to Happendable()
 *
 * MATLAB usage:
 * status = hdf('H', 'appendable', access_id)
 */
static void hdfHappendable(int nlhs,
                           mxArray *plhs[],
                           int nrhs,
                           const mxArray *prhs[])
{
    int32 H_id;
    intn status;

    haNarginChk(3, 3, nrhs);
    haNargoutChk(0, 1, nlhs);

    H_id = (int32) haGetDoubleScalar(prhs[2], "Access identifier");

    status = Happendable(H_id);

    plhs[0] = haCreateDoubleScalar((double) status);
}

/*
 * hdfHclose
 *
 * Purpose: gateway to Hclose()
 * 
 * MATLAB usage:
 * status = hdf('H', 'close', file_id)
 */
static void hdfHclose(int nlhs,
                      mxArray *plhs[],
                      int nrhs,
                      const mxArray *prhs[])
{
    int32 file_id;
    intn status;

    haNarginChk(3, 3, nrhs);
    haNargoutChk(0, 1, nlhs);

    file_id = (int32) haGetDoubleScalar(prhs[2], "File identifier");

    status = Hclose(file_id);
    if (status == SUCCEED)
    {
        haDeleteIDFromList(file_id, File_ID_List);
    }

    plhs[0] = haCreateDoubleScalar((double) status);
}

/*
 * hdfHdeldd
 *
 * Purpose: gateway to Hdeldd()
 *
 * MATLAB usage:
 * status = hdf('H', 'deldd', file_id, tag, ref_num)
 */
static void hdfHdeldd(int nlhs,
                      mxArray *plhs[],
                      int nrhs,
                      const mxArray *prhs[])
{
    int32 file_id;
    uint16 tag;
    uint16 ref;
    intn status;

    haNarginChk(5, 5, nrhs);
    haNargoutChk(0, 1, nlhs);

    file_id = (int32) haGetDoubleScalar(prhs[2], "File identifier");
    tag = (uint16) haGetDoubleScalar(prhs[3], "Tag");
    ref = (uint16) haGetDoubleScalar(prhs[4], "Reference number");

    status = Hdeldd(file_id, tag, ref);

    plhs[0] = haCreateDoubleScalar((double) status);
}

/*
 * hdfHdupdd
 *
 * Purpose: gateway to Hdupdd()
 *
 * MATLAB usage: 
 * status = hdf('H', 'dupdd', file_id, tag, ref, old_tag, old_ref)
 */
static void hdfHdupdd(int nlhs,
                      mxArray *plhs[],
                      int nrhs,
                      const mxArray *prhs[])
{
    int32 file_id;
    uint16 tag;
    uint16 ref;
    uint16 old_tag;
    uint16 old_ref;
    intn status;

    haNarginChk(7, 7, nrhs);
    haNargoutChk(0, 1, nlhs);

    file_id = (int32) haGetDoubleScalar(prhs[2], "File identifier");
    tag = (uint16) haGetDoubleScalar(prhs[3], "Tag");
    ref = (uint16) haGetDoubleScalar(prhs[4], "Reference number");
    old_tag = (uint16) haGetDoubleScalar(prhs[5], "Old tag");
    old_ref = (uint16) haGetDoubleScalar(prhs[6], "Old reference number");

    status = Hdupdd(file_id, tag, ref, old_tag, old_ref);

    plhs[0] = haCreateDoubleScalar((double) status);
}
    

/*
 * hdfHendaccess
 *
 * Purpose: gateway to Hendaccess()
 *
 * MATLAB usage:
 * status = hdf('H', 'endaccess', access_id)
 */
static void hdfHendaccess(int nlhs,
                          mxArray *plhs[],
                          int nrhs,
                          const mxArray *prhs[])
{
    int32 H_id;
    intn status;

    haNarginChk(3, 3, nrhs);
    haNargoutChk(0, 1, nlhs);

    H_id = (int32) haGetDoubleScalar(prhs[2], "Access identifier");

    status = Hendaccess(H_id);
    if (status == SUCCEED)
    {
        haDeleteIDFromList(H_id, Access_ID_List);
    }

    plhs[0] = haCreateDoubleScalar((double) status);
}

/*
 * hdfHfidinquire
 *
 * Purpose: gateway to Hfidinquire()
 *
 * MATLAB usage:
 * [filename, access_mode, attach, status] = hdf('H', 'fidinquire', file_id)
 */
static void hdfHfidinquire(int nlhs,
                    mxArray *plhs[],
                    int nrhs,
                    const mxArray *prhs[])
{
    intn status;
    int32 file_id;
    char *filename;
    intn access;
    intn attach;
    mxArray *filename_array = NULL;
    mxArray *access_array = NULL;
    mxArray *attach_array = NULL;

    haNarginChk(3, 3, nrhs);
    haNargoutChk(0, 4, nlhs);

    file_id = (int32) haGetDoubleScalar(prhs[2], "File identifier");

    status = Hfidinquire(file_id, &filename, &access, &attach);
    
    if (status == SUCCEED)
    {
        filename_array = mxCreateString(filename);
    }
    else
    {
        filename_array = mxCreateString("");
    }
    plhs[0] = filename_array;

    if (nlhs > 1)
    {
        if (status == SUCCEED)
        {
            switch (access)
            {
            case DFACC_READ:
                access_array = mxCreateString("read");
                break;

            case DFACC_WRITE:
                access_array = mxCreateString("write");
                break;

            case DFACC_RDWR:
                access_array = mxCreateString("readwrite");
                break;

            case DFACC_CREATE:
                access_array = mxCreateString("create");
                break;

            case DFACC_ALL:
                access_array = mxCreateString("all");
                break;

            default:
                access_array = mxCreateString("unknown");
                break;
            }
        }
        else
        {
            access_array = mxCreateString("");
        }
        
        plhs[1] = access_array;
    }

    if (nlhs > 2)
    {
        if (status == SUCCEED)
        {
            attach_array = mxCreateDoubleScalar(attach);
        }
        else
        {
            attach_array = mxCreateDoubleMatrix(0, 0, mxREAL);
        }
        
        plhs[2] = attach_array;
    }

    if (nlhs > 3)
    {
        plhs[3] = haCreateDoubleScalar((double) status);
    }
}

/*
 * hdfHfind
 *
 * Purpose: gateway to Hfind()
 *
 * MATLAB usage:
 * [tag, ref, offset, length, status] =
 *       hdf('H', 'find', file_id, search_tag, search_ref, search_type, dir)
 *       direction can be 'forward' or 'backward'
 *       search_type can be 'new' or 'continue'
 */
static void hdfHfind(int nlhs,
                     mxArray *plhs[],
                     int nrhs,
                     const mxArray *prhs[])
{
    intn status;
    int32 file_id;
    uint16 search_tag;
    uint16 search_ref;
    uint16 find_tag;
    uint16 find_ref;
    int32 find_offset;
    int32 find_length;
    intn direction;
    char *search_type = NULL;

    haNarginChk(7, 7, nrhs);
    haNargoutChk(0, 5, nlhs);

    file_id = (int32) haGetDoubleScalar(prhs[2], "File identifier");
    search_tag = (uint16) haGetDoubleScalar(prhs[3], "Search tag");
    search_ref = (uint16) haGetDoubleScalar(prhs[4], "Search ref");
    search_type = haGetString(prhs[5], "Search type");
    direction = haGetDirection(prhs[6]);

    if (strcmp(search_type, "new") == 0)
    {
        /* setting find_tag and find_ref to 0 causes Hfind */
        /* to begin a new search */
        find_tag = 0;
        find_ref = 0;
    }
    else if (strcmp(search_type, "continue") == 0)
    {
        find_tag = 1;
        find_ref = 1;
    }
    else
    {
        mexErrMsgTxt("Search type must be 'new' or 'continue'.");
    }

    status = Hfind(file_id, search_tag, search_ref, &find_tag,
                   &find_ref, &find_offset, &find_length, direction);

    /* assign tag output argument */
    if (status == SUCCEED)
    {
        plhs[0] = haCreateDoubleScalar((double) find_tag);
    }
    else
    {
        plhs[0] = mxCreateDoubleMatrix(0, 0, mxREAL);
    }

    if (nlhs > 1)
    {
        /* assign ref output argument */
        if (status == SUCCEED)
        {
            plhs[1] = haCreateDoubleScalar((double) find_ref);
        }
        else
        {
            plhs[1] = mxCreateDoubleMatrix(0, 0, mxREAL);
        }
    }

    if (nlhs > 2)
    {
        /* assign offset argument */
        if (status == SUCCEED)
        {
            plhs[2] = haCreateDoubleScalar((double) find_offset);
        }
        else
        {
            plhs[2] = mxCreateDoubleMatrix(0, 0, mxREAL);
        }
    }

    if (nlhs > 3)
    {
        /* assign length output argument */
        if (status == SUCCEED)
        {
            plhs[3] = haCreateDoubleScalar((double) find_length);
        }
        else
        {
            plhs[3] = mxCreateDoubleMatrix(0, 0, mxREAL);
        }
    }

    if (nlhs > 4)
    {
        /* assign status output argument */
        plhs[4] = haCreateDoubleScalar((double) status);
    }

    mxFree(search_type);
}
    
/*
 * hdfHgetelement
 *
 * Purpose: gateway to Hgetelement()
 *
 * MATLAB usage:
 * [data, status] = hdfHgetelement('H', 'getelement', file_id, tag, ref)
 *     data is a uint8 array containing the byte-stream of the given element
 */
static void hdfHgetelement(int nlhs,
                           mxArray *plhs[],
                           int nrhs,
                           const mxArray *prhs[])
{
    int32 file_id;
    uint16 tag;
    uint16 ref;
    int32 length;
    mxArray *data_array = NULL;
    int arraySize[2];
    intn status;

    haNarginChk(5, 5, nrhs);
    haNargoutChk(0, 2, nlhs);

    file_id = (int32) haGetDoubleScalar(prhs[2], "File identifier");
    tag = (uint16) haGetDoubleScalar(prhs[3], "Tag");
    ref = (uint16) haGetDoubleScalar(prhs[4], "Reference number");

    /* Find out how big the data element is. */
    length = Hlength(file_id, tag, ref);
    if (length == -1)
    {
        status = FAIL;
    }
    else
    {
        status = SUCCEED;
    }

    if (status == SUCCEED)
    {
        /* Found tag/ref in the file, so allocate a buffer array */
        /* and retrieve the data. */
        arraySize[0] = length;
        arraySize[1] = 1;
        data_array = mxCreateNumericArray(2, arraySize,
                                          mxUINT8_CLASS, mxREAL);
        status = Hgetelement(file_id, tag, ref, (uint8 *) mxGetData(data_array));
    }
    
    if (status != FAIL)
    {
        plhs[0] = data_array;
    }
    else
    {
        /* Hgetelement failed for some reason; return empty */
        arraySize[0] = 0;
        arraySize[1] = 0;
        plhs[0] = mxCreateNumericArray(2, arraySize,
                                       mxUINT8_CLASS, mxREAL);
        if (data_array != NULL)
        {
            mxDestroyArray(data_array);
        }
    }
        
    if (nlhs > 1)
    {
        plhs[1] = haCreateDoubleScalar((double) status);
    }
}

/*
 * hdfHgetfileversion
 *
 * Purpose: gateway to Hgetfileversion()
 *
 * MATLAB usage:
 * [major, minor, release, info, status] = hdf('H', 'getfileversion', file_id)
 */
static void hdfHgetfileversion(int nlhs,
                               mxArray *plhs[],
                               int nrhs,
                               const mxArray *prhs[])
{
    char info[LIBVSTR_LEN+1];
    int32 file_id;
    uint32 major_version;
    uint32 minor_version;
    uint32 release;
    intn status;

    haNarginChk(3, 3, nrhs);
    haNargoutChk(0, 5, nlhs);

    file_id = (int32) haGetDoubleScalar(prhs[2], "File identifier");

    status = Hgetfileversion(file_id, &major_version, &minor_version,
                             &release, info);

    if (status == SUCCEED)
    {
        plhs[0] = haCreateDoubleScalar((double) major_version);
    }
    else
    {
        plhs[0] = mxCreateDoubleMatrix(0, 0, mxREAL);
    }

    if (nlhs > 1)
    {
        if (status == SUCCEED)
        {
            plhs[1] = haCreateDoubleScalar((double) minor_version);
        }
        else
        {
            plhs[1] = mxCreateDoubleMatrix(0, 0, mxREAL);
        }
    }

    if (nlhs > 2)
    {
        if (status == SUCCEED)
        {
            plhs[2] = haCreateDoubleScalar((double) release);
        }
        else
        {
            plhs[2] = mxCreateDoubleMatrix(0, 0, mxREAL);
        }
    }

    if (nlhs > 3)
    {
        if (status == SUCCEED)
        {
            plhs[3] = mxCreateString(info);
        }
        else
        {
            plhs[3] = mxCreateString("");
        }
    }

    if (nlhs > 4)
    {
        plhs[4] = haCreateDoubleScalar((double) status);
    }
}
                           
/*
 * hdfHgetlibversion
 *
 * Purpose: gateway to Hgetlibversion()
 *
 * MATLAB usage:
 * [major, minor, release, info, status] = hdf('H', 'getlibversion')
 */
static void hdfHgetlibversion(int nlhs,
                              mxArray *plhs[],
                              int nrhs,
                              const mxArray *prhs[])
{
    char info[LIBVSTR_LEN+1];
    uint32 major_version;
    uint32 minor_version;
    uint32 release;
    intn status;

    haNarginChk(2, 2, nrhs);
    haNargoutChk(0, 5, nlhs);

    status = Hgetlibversion(&major_version, &minor_version,
                             &release, info);

    if (status == SUCCEED)
    {
        plhs[0] = haCreateDoubleScalar((double) major_version);
    }
    else
    {
        plhs[0] = mxCreateDoubleMatrix(0, 0, mxREAL);
    }

    if (nlhs > 1)
    {
        if (status == SUCCEED)
        {
            plhs[1] = haCreateDoubleScalar((double) minor_version);
        }
        else
        {
            plhs[1] = mxCreateDoubleMatrix(0, 0, mxREAL);
        }
    }

    if (nlhs > 2)
    {
        if (status == SUCCEED)
        {
            plhs[2] = haCreateDoubleScalar((double) release);
        }
        else
        {
            plhs[2] = mxCreateDoubleMatrix(0, 0, mxREAL);
        }
    }

    if (nlhs > 3)
    {
        if (status == SUCCEED)
        {
            plhs[3] = mxCreateString(info);
        }
        else
        {
            plhs[3] = mxCreateString("");
        }
    }

    if (nlhs > 4)
    {
        plhs[4] = haCreateDoubleScalar((double) status);
    }
}

/*
 * hdfHinquire
 *
 * Purpose: gateway to Hinquire()
 *
 * MATLAB usage:
 * [file_id, tag, ref, length, offset, position, access, special, status] =
 *           hdf('H', 'inquire', access_id)
 */
static void hdfHinquire(int nlhs,
                 mxArray *plhs[],
                 int nrhs,
                 const mxArray *prhs[])
{
    int32 H_id;
    int32 file_id;
    uint16 tag;
    uint16 ref;
    int32 length;
    int32 offset;
    int32 position;
    int16 access;
    int16 special;
    intn status;

    haNarginChk(3, 3, nrhs);
    haNargoutChk(0, 9, nlhs);

    H_id = (int32) haGetDoubleScalar(prhs[2], "Access identifier");

    status = Hinquire(H_id, &file_id, &tag, &ref, &length,
                      &offset, &position, &access, &special);

    if (status == SUCCEED)
    {
        plhs[0] = haCreateDoubleScalar((double) file_id);
    }
    else
    {
        plhs[0] = mxCreateDoubleMatrix(0, 0, mxREAL);
    }

    if (nlhs > 1)
    {
        if (status == SUCCEED)
        {
            plhs[1] = haCreateDoubleScalar((double) tag);
        }
        else
        {
            plhs[1] = mxCreateDoubleMatrix(0, 0, mxREAL);
        }
    }

    if (nlhs > 2)
    {
        if (status == SUCCEED)
        {
            plhs[2] = haCreateDoubleScalar((double) ref);
        }
        else
        {
            plhs[2] = mxCreateDoubleMatrix(0, 0, mxREAL);
        }
    }

    if (nlhs > 3)
    {
        if (status == SUCCEED)
        {
            plhs[3] = haCreateDoubleScalar((double) length);
        }
        else
        {
            plhs[3] = mxCreateDoubleMatrix(0, 0, mxREAL);
        }
    }

    if (nlhs > 4)
    {
        if (status == SUCCEED)
        {
            plhs[4] = haCreateDoubleScalar((double) offset);
        }
        else
        {
            plhs[4] = mxCreateDoubleMatrix(0, 0, mxREAL);
        }
    }

    if (nlhs > 5)
    {
        if (status == SUCCEED)
        {
            plhs[5] = haCreateDoubleScalar((double) position);
        }
        else
        {
            plhs[5] = mxCreateDoubleMatrix(0, 0, mxREAL);
        }
    }

    if (nlhs > 6)
    {
        if (status == SUCCEED)
        {
            plhs[6] = haCreateDoubleScalar((double) access);
        }
        else
        {
            plhs[6] = mxCreateDoubleMatrix(0, 0, mxREAL);
        }
    }

    if (nlhs > 7)
    {
        if (status == SUCCEED)
        {
            plhs[7] = haCreateDoubleScalar((double) special);
        }
        else
        {
            plhs[7] = mxCreateDoubleMatrix(0, 0, mxREAL);
        }
    }

    if (nlhs > 8)
    {
        plhs[8] = haCreateDoubleScalar((double) status);
    }
}

/*
 * hdfHishdf
 *
 * Purpose: gateway to Hishdf()
 *
 * MATLAB usage:
 * ishdf = hdf('H', 'ishdf', filename)
 */
static void hdfHishdf(int nlhs,
                      mxArray *plhs[],
                      int nrhs,
                      const mxArray *prhs[])
{
    char *filename;

    haNarginChk(3, 3, nrhs);
    haNargoutChk(0, 1, nlhs);

    filename = haGetString(prhs[2], "Filename");

    plhs[0] = mxCreateLogicalScalar(Hishdf(filename));

    mxFree(filename);
}


/*
 * hdfHlength
 *
 * Purpose: gateway to Hlength()
 *
 * MATLAB usage:
 * length = hdf('H', 'length', file_id, tag, ref)
 */
static void hdfHlength(int nlhs,
                       mxArray *plhs[],
                       int nrhs,
                       const mxArray *prhs[])
{
    int32 length;
    int32 file_id;
    uint16 tag;
    uint16 ref;

    haNarginChk(5, 5, nrhs);
    haNargoutChk(0, 1, nlhs);

    file_id = (int32) haGetDoubleScalar(prhs[2], "File identifier");
    tag = (uint16) haGetDoubleScalar(prhs[3], "Tag");
    ref = (uint16) haGetDoubleScalar(prhs[4], "Reference number");

    length = Hlength(file_id, tag, ref);

    plhs[0] = haCreateDoubleScalar((double) length);
}

/*
 * hdfHnewref
 *
 * Purpose: gateway to Hnewref()
 *
 * MATLAB usage:
 * ref = hdf('H', 'newref', file_id)
 *       returns 0 if unsuccessful
 */
static void hdfHnewref(int nlhs,
                       mxArray *plhs[],
                       int nrhs,
                       const mxArray *prhs[])
{
    int32 file_id;
    uint16 ref;

    haNarginChk(3, 3, nrhs);
    haNargoutChk(0, 1, nlhs);

    file_id = (int32) haGetDoubleScalar(prhs[2], "File identifier");
    
    ref = Hnewref(file_id);

    plhs[0] = haCreateDoubleScalar((double) ref);
}

/*
 * hdfHnextread
 *
 * Purpose: gateway to Hnextread()
 *
 * MATLAB usage:
 * status = hdf('H', 'nextread', access_id, tag, ref, origin)
 *          origin can be 'start' or 'current'
 */
static void hdfHnextread(int nlhs,
                         mxArray *plhs[],
                         int nrhs,
                         const mxArray *prhs[])
{
    int32 H_id;
    uint16 tag;
    uint16 ref;
    char *origin_string;
    int origin;
    intn status;

    haNarginChk(6, 6, nrhs);
    haNargoutChk(0, 1, nlhs);

    H_id = (int32) haGetDoubleScalar(prhs[2], "Access identifier");
    tag = (uint16) haGetDoubleScalar(prhs[3], "Tag");
    ref = (uint16) haGetDoubleScalar(prhs[4], "Reference number");
    origin_string = haGetString(prhs[5], "Search origin");
    if (strcmp(origin_string, "start") == 0)
    {
        origin = DF_START;
    }
    else if (strcmp(origin_string, "current") == 0)
    {
        origin = DF_CURRENT;
    }
    else
    {
        mexErrMsgTxt("Search origin must be 'start' or 'current'.");
    }

    status = Hnextread(H_id, tag, ref, origin);

    plhs[0] = haCreateDoubleScalar((double) status);

    mxFree(origin_string);
}

/*
 * hdfHnumber
 *
 * Purpose: gateway to Hnumber()
 *
 * MATLAB usage:
 * num = hdf('H', 'number', file_id, tag)
 */
static void hdfHnumber(int nlhs,
                       mxArray *plhs[],
                       int nrhs,
                       const mxArray *prhs[])
{
    int32 file_id;
    uint16 tag;
    int32 number;

    haNarginChk(4, 4, nrhs);
    haNargoutChk(0, 1, nlhs);

    file_id = (int32) haGetDoubleScalar(prhs[2], "File identifier");
    tag = (uint16) haGetDoubleScalar(prhs[3], "Tag");

    number = Hnumber(file_id, tag);

    plhs[0] = haCreateDoubleScalar((double) number);
}

/*
 * hdfHoffset
 *
 * Purpose: gateway to Hoffset()
 *
 * MATLAB usage:
 * offset = hdf('H', 'offset', file_id, tag, ref)
 */
static void hdfHoffset(int nlhs,
                       mxArray *plhs[],
                       int nrhs,
                       const mxArray *prhs[])
{
    int32 offset;
    int32 file_id;
    uint16 tag;
    uint16 ref;

    haNarginChk(5, 5, nrhs);
    haNargoutChk(0, 1, nlhs);

    file_id = (int32) haGetDoubleScalar(prhs[2], "File identifier");
    tag = (uint16) haGetDoubleScalar(prhs[3], "Tag");
    ref = (uint16) haGetDoubleScalar(prhs[4], "Reference number");

    offset = Hoffset(file_id, tag, ref);

    plhs[0] = haCreateDoubleScalar((double) offset);
}

/* 
 * hdfHopen
 *
 * Purpose: gateway to Hopen()
 *
 * MATLAB usage:
 * file_id = hdf('H', 'open', filename, access, n_dds)
 *           access can be 'read', 'write', 'readwrite', 'create'
 */
static void hdfHopen(int nlhs,
                     mxArray *plhs[],
                     int nrhs,
                     const mxArray *prhs[])
{
    int32 file_id;
    char *filename;
    intn access;
    int16 n_dds;
    intn status;

    haNarginChk(5, 5, nrhs);
    haNargoutChk(0, 1, nlhs);

    filename = haGetString(prhs[2], "Filename");
    access = haGetAccessMode(prhs[3]);
    n_dds = (int16) haGetDoubleScalar(prhs[4], 
                                      "Number of data descriptors");

    file_id = Hopen(filename, access, n_dds);
    if (file_id != FAIL)
    {
        status = haAddIDToList(file_id,File_ID_List);
        if (status == FAIL)
        {
            /* Couldn't add the file_id to the list. */
            /* This might cause data loss later, so we don't */
            /* allow it. */
            Hclose(file_id);
            file_id = FAIL;
        }

    }

    plhs[0] = haCreateDoubleScalar((double) file_id);

    mxFree(filename);
}

/*
 * hdfHputelement
 *
 * Purpose: gateway to Hputelement()
 *
 * MATLAB usage:
 * count = hdf('H', 'putelement', file_id, tag, ref, X)
 *         X must be a uint8 array
 */
static void hdfHputelement(int nlhs,
                           mxArray *plhs[],
                           int nrhs,
                           const mxArray *prhs[])
{
    int32 file_id;
    uint16 tag;
    uint16 ref;
    const mxArray *X;
    int32 length;
    int32 count;

    haNarginChk(6, 6, nrhs);
    haNargoutChk(0, 1, nlhs);

    file_id = (int32) haGetDoubleScalar(prhs[2], "File identifier");
    tag = (uint16) haGetDoubleScalar(prhs[3], "Tag");
    ref = (uint16) haGetDoubleScalar(prhs[4], "Reference number");
    X = prhs[5];

    if (!mxIsUint8(X))
    {
        mexErrMsgTxt("X must be a uint8 array.");
    }

    length = mxGetM(X) * mxGetN(X);

    count = Hputelement(file_id, tag, ref, (uint8 *) mxGetData(X), length);

    plhs[0] = haCreateDoubleScalar((double) count);
}

/*
 * hdfHread
 *
 * Purpose: gateway to Hread()
 *
 * MATLAB usage:
 * X = hdf('H', 'read', access_id, length)
 *     If length is 0, read the rest of the data element
 *     length(X) is the number of bytes successfully read.
 */
static void hdfHread(int nlhs,
                     mxArray *plhs[],
                     int nrhs,
                     const mxArray *prhs[])
{
    int32 H_id;
    int32 length;
    int32 element_length;
    int32 current_position;
    int32 count = FAIL;
    intn status = SUCCEED;
    int output_size[2];
    mxArray *X = NULL;
    mxArray *Xtmp = NULL;
    int k;
    uint8_T *pin;
    uint8_T *pout;

    haNarginChk(4, 4, nrhs);
    haNargoutChk(0, 1, nlhs);

    H_id = (int32) haGetDoubleScalar(prhs[2], "Access identifier");
    length = (int32) haGetDoubleScalar(prhs[3], "Length");

    if (length == 0)
    {
        /* we have to find out how big to make the buffer */
        status = Hinquire(H_id, NULL, NULL, NULL, &element_length,
                          NULL, &current_position, NULL, NULL);
        
        if (status == SUCCEED)
        {
            length = element_length - current_position;
        }
    }

    if (status == SUCCEED)
    {
        output_size[0] = length;
        output_size[1] = 1;
        X = mxCreateNumericArray(2, output_size, mxUINT8_CLASS, mxREAL);
        count = Hread(H_id, length, (uint8 *) mxGetData(X));
        if (count == FAIL)
        {
            status = FAIL;
        }
        else
        {
            status = SUCCEED;
        }
    }

    if ((status == SUCCEED) && (count < length))
    {
        /* We didn't read in as many bytes as requested. */
        /* Readjust the size of the output array. */
        output_size[0] = count;
        output_size[1] = 1;
        Xtmp = X;
        X = mxCreateNumericArray(2, output_size, mxUINT8_CLASS, mxREAL);
        pin = (uint8_T *) mxGetData(Xtmp);
        pout = (uint8_T *) mxGetData(X);
        for (k = 0; k < count; k++)
        {
            *pout = *pin;
            pout++;
            pin++;
        }
        mxDestroyArray(Xtmp);
    }

    if (status == SUCCEED)
    {
        plhs[0] = X;
    }
    else
    {
        plhs[0] = mxCreateDoubleMatrix(0, 0, mxREAL);
        if (X != NULL)
        {
            mxDestroyArray(X);
        }
    }

}

/*
 * hdfHseek
 *
 * Purpose: gateway to Hseek()
 *
 * MATLAB usage:
 * status = hdf('H', 'seek', access_id, offset, origin)
 *          origin can be 'start' or 'current'
 */
static void hdfHseek(int nlhs,
                     mxArray *plhs[],
                     int nrhs,
                     const mxArray *prhs[])
{
    int32 H_id;
    int32 offset;
    intn origin;
    char *origin_string;
    intn status;

    haNarginChk(5, 5, nrhs);
    haNargoutChk(0, 1, nlhs);

    H_id = (int32) haGetDoubleScalar(prhs[2], "Access identifier");
    offset = (int32) haGetDoubleScalar(prhs[3], "Offset");
    origin_string = haGetString(prhs[4], "Origin");

    if (strcmp(origin_string, "start") == 0)
    {
        origin = DF_START;
    }
    else if (strcmp(origin_string, "current") == 0)
    {
        origin = DF_CURRENT;
    }
    else
    {
        mexErrMsgTxt("Origin must be 'start' or 'current'.");
    }

    status = Hseek(H_id, offset, origin);

    plhs[0] = haCreateDoubleScalar((double) status);

    mxFree(origin_string);
}

/*
 * hdfHstartread
 *
 * Purpose: gateway to Hstartread()
 *
 * MATLAB usage:
 * access_id = hdf('H', 'startread', file_id, tag, ref)
 */
static void hdfHstartread(int nlhs,
                          mxArray *plhs[],
                          int nrhs,
                          const mxArray *prhs[])
{
    int32 file_id;
    uint16 tag;
    uint16 ref;
    int32 H_id;
    intn status;

    haNarginChk(5, 5, nrhs);
    haNargoutChk(0, 1, nlhs);

    file_id = (int32) haGetDoubleScalar(prhs[2], "File identifier");
    tag = (uint16) haGetDoubleScalar(prhs[3], "Tag");
    ref = (uint16) haGetDoubleScalar(prhs[4], "Reference number");

    H_id = Hstartread(file_id, tag, ref);
    if (H_id != FAIL)
    {
        status = haAddIDToList(H_id, Access_ID_List);
        if (status == FAIL)
        {
            /* Failed to add H_id to the access list.  This */
            /* might cause data loss later, so we don't allow it. */
            Hendaccess(H_id);
            H_id = FAIL;
        }
    }

    plhs[0] = haCreateDoubleScalar((double) H_id);
}

/*
 * hdfHstartwrite
 *
 * Purpose: gateway to Hstartwrite()
 *
 * MATLAB usage:
 * access_id = hdf('H', 'startwrite', file_id, tag, ref, length)
 */
static void hdfHstartwrite(int nlhs,
                          mxArray *plhs[],
                          int nrhs,
                          const mxArray *prhs[])
{
    int32 file_id;
    uint16 tag;
    uint16 ref;
    int32 H_id;
    int32 length;
    intn status;

    haNarginChk(6, 6, nrhs);
    haNargoutChk(0, 1, nlhs);

    file_id = (int32) haGetDoubleScalar(prhs[2], "File identifier");
    tag = (uint16) haGetDoubleScalar(prhs[3], "Tag");
    ref = (uint16) haGetDoubleScalar(prhs[4], "Reference number");
    length = (int32) haGetDoubleScalar(prhs[5], "Length");

    H_id = Hstartwrite(file_id, tag, ref, length);
    if (H_id != FAIL)
    {
        status = haAddIDToList(H_id, Access_ID_List);
        if (status == FAIL)
        {
            /* Failed to add the access id to the list. */
            /* This might cause data loss later, so we don't allow it. */
            Hendaccess(H_id);
            H_id = FAIL;
        }
    }

    plhs[0] = haCreateDoubleScalar((double) H_id);
}

/*
 * hdfHsync
 *
 * Purpose: gateway to Hsync()
 *
 * MATLAB usage:
 * status = hdf('H', 'sync', file_id)
 */
static void hdfHsync(int nlhs,
                     mxArray *plhs[],
                     int nrhs,
                     const mxArray *prhs[])
{
    int32 file_id;
    intn status;

    haNarginChk(3, 3, nrhs);
    haNargoutChk(0, 1, nlhs);

    file_id = (int32) haGetDoubleScalar(prhs[2], "File identifier");

    status = Hsync(file_id);

    plhs[0] = haCreateDoubleScalar((double) status);
}

/*
 * hdfHtrunc
 *
 * Purpose: gateway to Htrunc()
 *
 * MATLAB usage:
 * length = hdf('H', 'trunc', access_id, trunc_len)
 */
static void hdfHtrunc(int nlhs,
                      mxArray *plhs[],
                      int nrhs,
                      const mxArray *prhs[])
{
    int32 H_id;
    int32 trunc_len;
    int32 length;

    haNarginChk(4, 4, nrhs);
    haNargoutChk(0, 1, nlhs);

    H_id = (int32) haGetDoubleScalar(prhs[2], "Access identifier");
    trunc_len = (int32) haGetDoubleScalar(prhs[3], "Truncate length");

    length = Htrunc(H_id, trunc_len);

    plhs[0] = haCreateDoubleScalar((double) length);
}

/*
 * hdfHwrite
 * 
 * Purpose: gateway to Hwrite()
 *
 * MATLAB usage:
 * count = hdf('H', 'write', access_id, X)
 *         X must be a uint8 array
 */
static void hdfHwrite(int nlhs,
                      mxArray *plhs[],
                      int nrhs,
                      const mxArray *prhs[])
{
    int32 H_id;
    int32 length;
    const mxArray *X;
    int32 count;

    haNarginChk(4, 4, nrhs);
    haNargoutChk(0, 1, nlhs);

    H_id = (int32) haGetDoubleScalar(prhs[2], "Access identifier");
    X = prhs[3];

    if (!mxIsUint8(X))
    {
        mexErrMsgTxt("X must be a uint8 array.");
    }
   
    length = mxGetM(X) * mxGetN(X);

    count = Hwrite(H_id, length, (uint8 *) mxGetData(X));

    plhs[0] = haCreateDoubleScalar((double) count);
}



/*
 * hdfH
 *
 * Purpose: Function switchyard for the H part of the HDF gateway.
 *
 * Inputs:  nlhs --- number of left-side arguments
 *          plhs --- left-side arguments
 *          nrhs --- number of right-side arguments
 *          prhs --- right-side arguments
 *          functionStr --- string specifying which H function to call
 * Outputs: none
 * Return:  none
 */
void hdfH(int nlhs,
          mxArray *plhs[],
          int nrhs,
          const mxArray *prhs[],
          char *functionStr
          )
{
    void (*func)(int nlhs, mxArray *plhs[], 
                 int nrhs, const mxArray *prhs[]);

    if (strcmp(functionStr, "appendable") == 0)
    {
        func = hdfHappendable;
    }
    else if (strcmp(functionStr, "close") == 0)
    {
        func = hdfHclose;
    }
    else if (strcmp(functionStr, "deldd") == 0)
    {
        func = hdfHdeldd;
    }
    else if (strcmp(functionStr, "dupdd") == 0)
    {
        func = hdfHdupdd;
    }
    else if (strcmp(functionStr, "endaccess") == 0)
    {
        func = hdfHendaccess;
    }
    else if (strcmp(functionStr, "fidinquire") == 0)
    {
        func = hdfHfidinquire;
    }
    else if (strcmp(functionStr, "find") == 0)
    {
        func = hdfHfind;
    }
    else if (strcmp(functionStr, "getelement") == 0)
    {
        func = hdfHgetelement;
    }
    else if (strcmp(functionStr, "getfileversion") == 0)
    {
        func = hdfHgetfileversion;
    }
    else if (strcmp(functionStr, "getlibversion") == 0)
    {
        func = hdfHgetlibversion;
    }
    else if (strcmp(functionStr, "inquire") == 0)
    {
        func = hdfHinquire;
    }
    else if (strcmp(functionStr, "ishdf") == 0)
    {
        func = hdfHishdf;
    }
    else if (strcmp(functionStr, "length") == 0)
    {
        func = hdfHlength;
    }
    else if (strcmp(functionStr, "newref") == 0)
    {
        func = hdfHnewref;
    }
    else if (strcmp(functionStr, "nextread") == 0)
    {
        func = hdfHnextread;
    }
    else if (strcmp(functionStr, "number") == 0)
    {
        func = hdfHnumber;
    }
    else if (strcmp(functionStr, "offset") == 0)
    {
        func = hdfHoffset;
    }
    else if (strcmp(functionStr, "open") == 0)
    {
        func = hdfHopen;
    }
    else if (strcmp(functionStr, "putelement") == 0)
    {
        func = hdfHputelement;
    }
    else if (strcmp(functionStr, "read") == 0)
    {
        func = hdfHread;
    }
    else if (strcmp(functionStr, "seek") == 0)
    {
        func = hdfHseek;
    }
    else if (strcmp(functionStr, "startread") == 0)
    {
        func = hdfHstartread;
    }
    else if (strcmp(functionStr, "startwrite") == 0)
    {
        func = hdfHstartwrite;
    }
    else if (strcmp(functionStr, "sync") == 0)
    {
        func = hdfHsync;
    }
    else if (strcmp(functionStr, "trunc") == 0)
    {
        func = hdfHtrunc;
    }
    else if (strcmp(functionStr, "write") == 0)
    {
        func = hdfHwrite;
    }
    else
    {
        mexErrMsgTxt("Unknown H interface function.");
    }

    (*func)(nlhs, plhs, nrhs, prhs);
}

