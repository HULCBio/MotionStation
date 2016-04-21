/* Copyright 1984-2002 The MathWorks, Inc.  */

/*
 * hdfgd.c --- support file for HDF.MEX
 *
 * This module supports the HDF-EOS GD interface.  The only public
 * function is hdfGD(), which is called by mexFunction().
 * hdfGD looks at the second input argument to determine which
 * private function should get control.
 *
 */

/* $Revision: 1.1.6.1 $  $Date: 2003/12/13 03:02:00 $ */

static char rcsid[] = "$Id: hdfgd.c,v 1.1.6.1 2003/12/13 03:02:00 batserve Exp $";

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

#define NUM_PROJ_PARMS 16
#define BUFLEN 128

/*
 * GetProjParm
 *
 * Purpose: Fill in projection parameter vector from MATLAB array.
 *
 * Inputs:  inStr --- MATLAB array; should be NUM_PROJ_PARMS-element array
 * Outputs: proj_parm[NUM_PROJ_PARMS] --- projection parameters
 * Return:  none
 */
static
void GetProjParm(const mxArray *array, float64 proj_parm[NUM_PROJ_PARMS])
{
    double *pr;
    int k;
    int num_elements = mxGetNumberOfElements(array);
    
    if (! mxIsDouble(array) || (num_elements > NUM_PROJ_PARMS))
    {
        mexErrMsgTxt("Invalid projection parameter vector.");
    }
    
    pr = mxGetPr(array);
    for (k = 0; k < num_elements; k++)
    {
        proj_parm[k] = pr[k];
    }
    for (k = num_elements; k < NUM_PROJ_PARMS; k++)
    {
        proj_parm[k] = 0;
    }
}

/*
 * GetProjCode
 *
 * Purpose: Given MATLAB string array, return HDF-EOS projection code
 *
 * Inputs:  inStr --- MATLAB string array
 * Outputs: none
 * Return:  HDF-EOS projection code; errors out if none found
 */
static
int32 GetProjCode(const mxArray *inStr)
{
    static struct 
    {
        char *longStr;
        char *shortStr;
        int32 code;
    }
    projCodes[] = 
    {
        {"gctp_geo",    "geo",     GCTP_GEO},
        {"gctp_utm",    "utm",     GCTP_UTM},
        {"gctp_lamcc",  "lamcc",   GCTP_LAMCC},
        {"gctp_ps",     "ps",      GCTP_PS},
        {"gctp_polyc",  "polyc",   GCTP_POLYC},
        {"gctp_tm",     "tm",      GCTP_TM},
        {"gctp_lamaz",  "lamaz",   GCTP_LAMAZ},
        {"gctp_hom",    "hom",     GCTP_HOM},
        {"gctp_som",    "som",     GCTP_SOM},
        {"gctp_good",   "good",    GCTP_GOOD},
        {"gctp_isinus", "isinus",  GCTP_ISINUS}
    };
    static int numCodes = sizeof(projCodes) / sizeof(*projCodes);

    char buffer[BUFLEN];
    int32 projCode;
    int k = 0;
    bool codeFound = false;

    if (!mxIsChar(inStr))
    {
        mexErrMsgTxt("Projection code must be a string.");
    }
    
    mxGetString(inStr, buffer, BUFLEN);
    for (k = 0; k < numCodes; k++)
    {
        if ((haStrcmpi(buffer, projCodes[k].longStr) == 0) ||
            (haStrcmpi(buffer, projCodes[k].shortStr) == 0))
        {
            projCode = projCodes[k].code;
            codeFound = true;
            break;
        }
    }
    
    if (! codeFound)
    {
        mexErrMsgTxt("Invalid projection code.");
    }

    return(projCode);
}

/*
 * GetOriginCode
 *
 * Purpose: Given MATLAB string array, return HDF-EOS origin code
 *
 * Inputs:  inStr --- MATLAB string array
 * Outputs: none
 * Return:  HDF-EOS origin code; errors out if none found
 */
static
int32 GetOriginCode(const mxArray *inStr)
{
    static struct 
    {
        char *longStr;
        char *shortStr;
        int32 code;
    }
    originCodes[] = 
    {
        {"hdfe_gd_ul",  "ul",   HDFE_GD_UL},
        {"hdfe_gd_ur",  "ur",   HDFE_GD_UR},
        {"hdfe_gd_ll",  "ll",   HDFE_GD_LL},
        {"hdfe_gd_lr",  "lr",   HDFE_GD_LR}
    };
    static int numCodes = sizeof(originCodes) / sizeof(*originCodes);

    char buffer[BUFLEN];
    int32 originCode;
    int k = 0;
    bool codeFound = false;

    if (!mxIsChar(inStr))
    {
        mexErrMsgTxt("Origin code must be a string.");
    }
    
    mxGetString(inStr, buffer, BUFLEN);
    for (k = 0; k < numCodes; k++)
    {
        if ((haStrcmpi(buffer, originCodes[k].longStr) == 0) ||
            (haStrcmpi(buffer, originCodes[k].shortStr) == 0))
        {
            originCode = originCodes[k].code;
            codeFound = true;
            break;
        }
    }
    
    if (! codeFound)
    {
        mexErrMsgTxt("Invalid origin code.");
    }

    return(originCode);
}

int32 GetEntryCode(const mxArray *inStr)
{
    static struct 
    {
        char *longStr;
        char *shortStr;
        int32 code;
    }
    entryCodes[] = 
    {
        {"hdfe_nentdim",  "nentdim",   HDFE_NENTDIM},
        {"hdfe_nentdfld", "nentdfld",  HDFE_NENTDFLD}
    };
    static int numCodes = sizeof(entryCodes) / sizeof(*entryCodes);

    char buffer[BUFLEN];
    int32 entryCode;
    int k = 0;
    bool codeFound = false;

    if (!mxIsChar(inStr))
    {
        mexErrMsgTxt("Entry code must be a string.");
    }
    
    mxGetString(inStr, buffer, BUFLEN);
    for (k = 0; k < numCodes; k++)
    {
        if ((haStrcmpi(buffer, entryCodes[k].longStr) == 0) ||
            (haStrcmpi(buffer, entryCodes[k].shortStr) == 0))
        {
            entryCode = entryCodes[k].code;
            codeFound = true;
            break;
        }
    }
    
    if (! codeFound)
    {
        mexErrMsgTxt("Invalid entry code.");
    }

    return(entryCode);
}

int32 GetPixReg(const mxArray *inStr)
{
    static struct 
    {
        char *longStr;
        char *shortStr;
        int32 code;
    }
    codes[] = 
    {
        {"hdfe_center",  "center",   HDFE_CENTER},
        {"hdfe_corner",  "corner",   HDFE_CORNER}
    };
    static int numCodes = sizeof(codes) / sizeof(*codes);

    char buffer[BUFLEN];
    int32 code;
    int k = 0;
    bool codeFound = false;

    if (!mxIsChar(inStr))
    {
        mexErrMsgTxt("Registration code must be a string.");
    }
    
    mxGetString(inStr, buffer, BUFLEN);
    for (k = 0; k < numCodes; k++)
    {
        if ((haStrcmpi(buffer, codes[k].longStr) == 0) ||
            (haStrcmpi(buffer, codes[k].shortStr) == 0))
        {
            code = codes[k].code;
            codeFound = true;
            break;
        }
    }
    
    if (! codeFound)
    {
        mexErrMsgTxt("Invalid registration code.");
    }

    return(code);
}

int32 GetTileCode(const mxArray *inStr)
{
    static struct 
    {
        char *longStr;
        char *shortStr;
        int32 code;
    }
    codes[] = 
    {
        {"hdfe_tile",    "tile",     HDFE_TILE},
        {"hdfe_notile",  "notile",   HDFE_NOTILE}
    };
    static int numCodes = sizeof(codes) / sizeof(*codes);

    char buffer[BUFLEN];
    int32 code;
    int k = 0;
    bool codeFound = false;

    if (!mxIsChar(inStr))
    {
        mexErrMsgTxt("Tile code must be a string.");
    }
    
    mxGetString(inStr, buffer, BUFLEN);
    for (k = 0; k < numCodes; k++)
    {
        if ((haStrcmpi(buffer, codes[k].longStr) == 0) ||
            (haStrcmpi(buffer, codes[k].shortStr) == 0))
        {
            code = codes[k].code;
            codeFound = true;
            break;
        }
    }
    
    if (! codeFound)
    {
        mexErrMsgTxt("Invalid tile code.");
    }

    return(code);
}

/*
 * GetCompressionStringFromCode
 * 
 * Purpose: Return an mxArray containing the string corresponding to the
 *          given compression code.
 *
 * Inputs:  int32 compcode
 *    
 * Outputs: none
 * 
 * Returns: mxArray compressionString
 */
static
mxArray *GetCompressionStringFromCode(int32 compcode)
{
    mxArray *compstring;
    
    if (compcode == HDFE_COMP_RLE)
        compstring = mxCreateString("rle");
    else if (compcode == HDFE_COMP_SKPHUFF)
        compstring = mxCreateString("skphuff");
    else if (compcode == HDFE_COMP_DEFLATE)
        compstring = mxCreateString("deflate");
    else if (compcode == HDFE_COMP_NONE)
        compstring = mxCreateString("none");
    else if (compcode == HDFE_COMP_NBIT)    
        compstring = mxCreateString("nbit");
    else
        mexErrMsgTxt("unknown");

    return(compstring);
}

/*
 * GetOriginStringFromCode
 * 
 * Purpose: Return an mxArray containing the string corresponding to the
 *          given origin code.
 *
 * Inputs:  int32 origincode
 *    
 * Outputs: none
 * 
 * Returns: mxArray originString
 */
static
mxArray *GetOriginStringFromCode(int32 origincode)
{
    mxArray *originstring;
    
    if (origincode == HDFE_GD_UL)
        originstring = mxCreateString("ul");
    else if (origincode == HDFE_GD_UR)
        originstring = mxCreateString("ur");
    else if (origincode == HDFE_GD_LL)
        originstring = mxCreateString("ll");
    else if (origincode == HDFE_GD_LR)
        originstring = mxCreateString("lr");
    else
        originstring = mxCreateString("unknown");

    return(originstring);
}

/*
 * GetPixregStringFromCode
 * 
 * Purpose: Return an mxArray containing the string corresponding to the
 *          given pixreg code.
 *
 * Inputs:  int32 pixregcode
 *    
 * Outputs: none
 * 
 * Returns: mxArray pixregString
 */
static
mxArray *GetPixregStringFromCode(int32 pixregcode)
{
    mxArray *pixregstring;
    
    if (pixregcode == HDFE_CENTER)
        pixregstring = mxCreateString("center");
    else if (pixregcode == HDFE_CORNER)
        pixregstring = mxCreateString("corner");
    else
        pixregstring = mxCreateString("unknown");

    return(pixregstring);
}

/*
 * GetTileStringFromCode
 * 
 * Purpose: Return an mxArray containing the string corresponding to the
 *          given tile code.
 *
 * Inputs:  int32 tilecode
 *    
 * Outputs: none
 * 
 * Returns: mxArray tileString
 */
static
mxArray *GetTileStringFromCode(int32 tilecode)
{
    mxArray *tilestring;
    
    if (tilecode == HDFE_TILE)
        tilestring = mxCreateString("tile");
    else if (tilecode == HDFE_NOTILE)
        tilestring = mxCreateString("notile");
    else
        tilestring = mxCreateString("unknown");

    return(tilestring);
}

/*
 * GetProjStringFromCode
 * 
 * Purpose: Return an mxArray containing the string corresponding to the
 *          given projection code.
 *
 * Inputs:  int32 projcode
 *    
 * Outputs: none
 * 
 * Returns: mxArray projString
 */
static
mxArray *GetProjStringFromCode(int32 projcode)
{
    mxArray *projstring;

    if (projcode == GCTP_GEO)
        projstring = mxCreateString("geo");
    else if (projcode == GCTP_UTM)
        projstring = mxCreateString("utm");
    else if (projcode == GCTP_LAMCC)
        projstring = mxCreateString("lamcc");
    else if (projcode == GCTP_PS)
        projstring = mxCreateString("ps");
    else if (projcode == GCTP_TM)
        projstring = mxCreateString("tm");
    else if (projcode == GCTP_LAMAZ)
        projstring = mxCreateString("lamaz");
    else if (projcode == GCTP_HOM)
        projstring = mxCreateString("hom");
    else if (projcode == GCTP_SOM)
        projstring = mxCreateString("som");
    else if (projcode == GCTP_GOOD)
        projstring = mxCreateString("good");
    else if (projcode == GCTP_ISINUS)
        projstring = mxCreateString("isinus");
    else
        projstring = mxCreateString("unknown");

    return(projstring);
}

/*
 * CreateDoubleMxArrayFromINT32Array
 * 
 * Purpose: Allocates an mxArray of class double and copies
 *          into it the values from the given int32 array
 *
 * Inputs:  array    - the int32 array
 *          ndims    - number of dimensions in the array
 *          dims     - size along each dimension
 *    
 * Outputs: none
 * 
 * Returns: out      - the MATLAB array
 */
static
mxArray *CreateDoubleMxArrayFromINT32Array(int32 *array, int ndims, int *dims)
{
    int i;
    mxArray *out;
    double *pr;
    int length;
    
    out = mxCreateNumericArray(ndims, dims, mxDOUBLE_CLASS, mxREAL);
    pr = mxGetPr(out);

    length = mxGetNumberOfElements(out);
    
    for (i=0; i<length; i++) {
        pr[i] = (double) array[i];
    }
    return(out);
}

/*
 * hdfGDattach
 *
 * Purpose: gateway to GDattach()
 *          Attaches to an existing grid
 *
 * MATLAB usage:
 * gridid = hdf('gd','attach',fid,gridname)
 */
static void hdfGDattach(int nlhs,
                           mxArray *plhs[],
                           int nrhs,
                           const mxArray *prhs[])
{
    int32 fid;
    int32 gridid;
    char *gridname = NULL;
    intn status;

    haNarginChk(4, 4, nrhs);
    haNargoutChk(0, 1, nlhs);

    fid = (int32) haGetNonNegativeDoubleScalar(prhs[2], "File identifier");
    gridname = haGetString(prhs[3], "Grid name");
    
    gridid = GDattach(fid, gridname);
    if (gridid != FAIL)
    {
        status = haAddIDToList(gridid, GD_Grid_List);
        if (status == FAIL)
        {
            /*
             * Failed to add gridid to the list.
             * This might cause data loss later, so don't allow it.
             */
            GDdetach(gridid);
            gridid = FAIL;
        }
    }

    plhs[0] = haCreateDoubleScalar((double) gridid);

    if (gridname != NULL)
    {
        mxFree(gridname);
    }
}

/*
 * hdfGDattrinfo
 * 
 * Purpose: Gateway to the HDF-EOS Library function GDattrinfo
 *          Returns information about a grid attribute.
 *
 * MATLAB usage:
 *          [numbertype, count, status] = ...
 *                   hdf('GD', 'attrinfo', gridid, attrname);
 *
 * Inputs:  gridid     - Grid identifier
 *          attrname    - attribute name
 *
 * Outputs: numbertype  - number type of attribute
 *          count       - number of total bytes in attribute
 *          status      - returns 0 if succeed, and -1 if fail
 * 
 * Retuns:  none
 */
static
void hdfGDattrinfo(int nlhs,
                      mxArray *plhs[],
                      int nrhs,
                      const mxArray *prhs[])
{
    int32 gridid;
    char *attrname = NULL;
    int32 numbertype;
    int32 count;
    int32 status;
        
    /* Argument checking */
    haNarginChk(4, 4, nrhs);
    haNargoutChk(0, 3, nlhs);
    
    /* Get data from MATLAB arrays */
    gridid = (int32) haGetNonNegativeDoubleScalar(prhs[2], "Grid identifier");
    attrname = haGetString(prhs[3], "Attribute name");
    
    /* Call HDF-EOS library function, and output result */
    status = GDattrinfo(gridid, attrname, &numbertype, &count);

    if (status != FAIL)
    {
        plhs[0] = mxCreateString(haGetNumberTypeString(numbertype)); 
    }
    else
    {
        plhs[0] = EMPTY;
    }
    
    if (nlhs > 1)
    {
        if (status != FAIL)
        {
            plhs[1] = haCreateDoubleScalar((double) count);
        }
        else
        {
            plhs[1] = EMPTY;
        }
    }
    
    if (nlhs > 2)
    {
        plhs[2] = haCreateDoubleScalar(status);
    }

    /* Clean up */
    if (attrname != NULL)
    {
        mxFree(attrname);
    }
}

/*
 * hdfGDblkSOMoffset
 * 
 * Purpose: Gateway to the HDF-EOS Library function GDblkSOMoffset
 *          Write a block of SOM offset values
 * 
 * MATLAB usage: status = hdf('GD','blksomoffset',gridid,offset);
 * 
 * Inputs: gridid         - Grid ID
 *         offset         - Offset values for SOM Projection data
 * 
 * Outputs: status        - 0 for success, 1 for failure
 * 
 * Returns: none
 */

static
void hdfGDblkSOMoffset(int nlhs,
                        mxArray *plhs[],
                        int nrhs,
                        const mxArray *prhs[])
{

    char code[] = {"w"};
    intn status;
    int32 gridid;
    float32 *offset;
    int32 count;
    double *offset_ptr;
    int i;

    /* Get data from MATLAB arrays */
    gridid = (int32) haGetNonNegativeDoubleScalar(prhs[2], "Grid file identifier");
    count = mxGetNumberOfElements(prhs[3]);
    if(mxGetClassID(prhs[3]) != mxDOUBLE_CLASS)
        {
            mexErrMsgTxt("OFFSET values must be double precision.");
        }
    offset = mxMalloc(count*sizeof(int32));
    offset_ptr = mxGetPr(prhs[3]);
    for(i=0;i<count;i++)
        {
            offset[i] = (float32) offset_ptr[i];
        }

    /* Call HDF-EOS Library function and return result */
    status = GDblkSOMoffset(gridid,offset,count,code);
    plhs[0] = haCreateDoubleScalar((double)status);

    /* Clean up */
    if(offset != NULL)
        {
            mxFree(offset);
        }
}






/*
 * hdfGDclose
 *
 * Purpose: gateway to GDclose()
 *          Closes HDF file
 *
 * MATLAB usage:
 * status = hdf('gd','close',fid)
 */
static void hdfGDclose(int nlhs,
                          mxArray *plhs[],
                          int nrhs,
                          const mxArray *prhs[])
{
    int32 fid;
    intn status;
    
    haNarginChk(3, 3, nrhs);
    haNargoutChk(0, 1, nlhs);
    
    fid = (int32) haGetNonNegativeDoubleScalar(prhs[2], "Grid file identifier");
    status = GDclose(fid);
    if (status != FAIL)
    {
        haDeleteIDFromList(fid, GD_File_List);
    }
    plhs[0] = haCreateDoubleScalar((double) status);
}

/*
 * hdfGDcompinfo
 * 
 * Purpose: Gateway to the HDF-EOS Library function GDcompinfo
 *          Retreives compression information about a field
 *
 * MATLAB usage:
 *          [compcode, compparm, status] = ...
 *                      hdf('GD', 'compinfo', gridid, fieldname);
 *
 * Inputs:  gridid     - Grid identifier
 *          fieldname   - field name
 *
 * Outputs: compcode    - HDF compression code
 *          compparm    - compression parameters
 *          status      - returns 0 if succeed, and -1 if fail
 * 
 * Retuns:  none
 */
static
void hdfGDcompinfo(int nlhs,
                      mxArray *plhs[],
                      int nrhs,
                      const mxArray *prhs[])
{
    int32 gridid;
    char *fieldname = NULL;
    int32 compcode;
    intn compparm[NUM_EOS_COMP_PARMS];
    double *real_ptr;
    intn status;
    int i;

    /* Argument checking */
    haNarginChk(4, 4, nrhs);
    haNargoutChk(0, 3, nlhs);
    
    /* Get data from MATLAB arrays */
    gridid = (int32) haGetNonNegativeDoubleScalar(prhs[2], "Grid identifier");
    fieldname = haGetString(prhs[3], "Field name");

    /* Initialize parameter vector to zeros, because HDF-EOS library */
    /* may not fill it. */
    for (i = 0; i < NUM_EOS_COMP_PARMS; i++)
    {
        compparm[i] = 0;
    }
    
    /* Call HDF-EOS library function. */
    status = GDcompinfo(gridid, fieldname, &compcode, compparm);
    
    if (status != FAIL)
    {
        plhs[0] = GetCompressionStringFromCode(compcode); 
    }
    else
    {
        plhs[0] = EMPTY;
    }
    
    if (status != FAIL)
    {
        plhs[1] = mxCreateDoubleMatrix(1, NUM_EOS_COMP_PARMS, mxREAL);
        real_ptr = mxGetPr(plhs[1]);
        for (i = 0; i < NUM_EOS_COMP_PARMS; i++)
        {
            real_ptr[i] = (double) compparm[i];
        }
    }
    else
    {
        plhs[1] = EMPTY;
    }
    
    if (nlhs > 2) {
        plhs[2] = haCreateDoubleScalar(status);
    }

    /* Clean up */
    if (fieldname != NULL)
    {
        mxFree(fieldname);
    }
}

/*
 * hdfGDcreate
 *
 * Purpose: gateway to GDcreate()
 *          Creates a new grid in the file
 *
 * MATLAB usage:
 * gridid = hdf('gd','create',fid,gridname,xdimsize,ydimsize,...
 *                   upleftpt,lowrightpt)
 *
 */
static void hdfGDcreate(int nlhs,
                           mxArray *plhs[],
                           int nrhs,
                           const mxArray *prhs[])
{
    int32 gridid;
    int32 fid;
    char *gridname;
    int32 xdimsize;
    int32 ydimsize;
    float64 *upleftpt;
    float64 *lowrightpt;
    intn status;

    haNarginChk(8, 8, nrhs);
    haNargoutChk(0, 1, nlhs);

    fid = (int32) haGetNonNegativeDoubleScalar(prhs[2], "File identifier");
    gridname = haGetString(prhs[3], "Grid name");
    
    xdimsize = (int32) haGetDoubleScalar(prhs[4], "X dimension size");
    if (xdimsize < 0)
    {
        mexErrMsgTxt("xdimsize must be a nonnegative integer.");
    }
    
    ydimsize = (int32) haGetDoubleScalar(prhs[5], "Y dimension size");
    if (ydimsize < 0)
    {
        mexErrMsgTxt("ydimsize must be a nonnegative integer.");
    }

    if (haIsNULL(prhs[6]))
    {
        upleftpt = NULL;
    }
    else
    {
        if (!mxIsDouble(prhs[6]) || (mxGetNumberOfElements(prhs[6]) != 2))
        {
            mexErrMsgTxt("upleftpt must be [] or a 2-element vector.");
        }
        else
        {
            upleftpt = mxGetPr(prhs[6]);
        }
    }
    
    if (haIsNULL(prhs[7]))
    {
        lowrightpt = NULL;
    }
    else
    {
        if (!mxIsDouble(prhs[7]) || (mxGetNumberOfElements(prhs[7]) != 2))
        {
            mexErrMsgTxt("lowrightpt must be [] or a 2-element vector.");
        }
        else
        {
            lowrightpt = mxGetPr(prhs[7]);
        }
    }
    
    gridid = GDcreate(fid, gridname, xdimsize, ydimsize, upleftpt, lowrightpt);
    if (gridid != FAIL)
    {
        status = haAddIDToList(gridid, GD_Grid_List);
        if (status == FAIL)
        {
            /*
             * Failed to add gridid to the list.
             * This might cause data loss later, so don't allow it.
             */
            GDdetach(gridid);
            gridid = FAIL;
        }
    }

    plhs[0] = haCreateDoubleScalar((double) gridid);
    mxFree((void *) gridname);
}

/*
 * hdfGDdefboxregion
 *
 * Purpose: gateway to GDdefboxregion()
 *          Defines a longitude-latitude box region for a grid.
 *
 * MATLAB usage:
 *        regionid = hdf('GD','defboxregion',gridid,cornerlon,cornerlat)
 */
static void hdfGDdefboxregion(int nlhs,
                                 mxArray *plhs[],
                                 int nrhs,
                                 const mxArray *prhs[])
{
    int32 gridid;
    double *lon_ptr;
    double *lat_ptr;
    int32 regionid;
    
    haNarginChk(5, 5, nrhs);
    haNargoutChk(0, 1, nlhs);
    
    gridid = (int32) haGetNonNegativeDoubleScalar(prhs[2], "Grid identifier");
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
    
    regionid = GDdefboxregion(gridid, lon_ptr, lat_ptr);
    
    plhs[0] = haCreateDoubleScalar((double) regionid);
}

/*
 * hdfGDdefcomp
 *
 * Purpose: gateway to GDdefcomp()
 *          Sets the field compression for all subsequent field
 *          definitions.
 *
 * MATLAB usage:
 * status = hdf('GD','defcomp',gridid,compcode,compparm)
 */
static void hdfGDdefcomp(int nlhs,
                            mxArray *plhs[],
                            int nrhs,
                            const mxArray *prhs[])
{
    int32 gridid;
    int32 compcode;
    intn compparm[NUM_EOS_COMP_PARMS];
    intn status;
    
    haNarginChk(5, 5, nrhs);
    haNargoutChk(0, 1, nlhs);
    
    gridid = (int32) haGetNonNegativeDoubleScalar(prhs[2], "Grid identifier");
    compcode = haGetEOSCompressionCode(prhs[3]);
    haGetEOSCompressionParameters(prhs[4], compparm);
    
    status = GDdefcomp(gridid, compcode, compparm);
    plhs[0] = haCreateDoubleScalar((double) status);
}

/*
 * hdfGDdefdim
 *
 * Purpose: gateway to GDdefdim()
 *          Defines a new dimension within the grid
 *
 * MATLAB usage:
 * status = hdf('gd','defdim',gridid,dimname,dim)
 */
static void hdfGDdefdim(int nlhs,
                           mxArray *plhs[],
                           int nrhs,
                           const mxArray *prhs[])
{
    int32 gridid;
    int32 dim;
    char *dimname;
    intn status;
    

    haNarginChk(5, 5, nrhs);
    haNargoutChk(0, 1, nlhs);
    
    gridid = (int32) haGetNonNegativeDoubleScalar(prhs[2], "Grid identifier");
    dim = (int32) haGetDoubleScalar(prhs[4], "Dimension size");
    if (dim < 0)
    {
        mexErrMsgTxt("Dimension size must be a nonnegative integer.");
    }
    
    dimname = haGetString(prhs[3], "Dimension name");
    
    status = GDdefdim(gridid, dimname, dim);
    plhs[0] = haCreateDoubleScalar((double) status);
    mxFree((void *) dimname);
}

/*
 * hdfGDdeffield
 *
 * Purpose: gateway to GDdeffield()
 *          Defines data fields to be stored in a grid
 *
 * MATLAB usage:
 * status = hdf('GD','deffield',gridid,fieldname,dimlist,numbertype,
 *                   merge)
 */
static void hdfGDdeffield(int nlhs,
                             mxArray *plhs[],
                             int nrhs,
                             const mxArray *prhs[])
{
    int32 gridid;
    char *fieldname = NULL;
    char *dimlist = NULL;
    int32 numbertype;
    int32 merge;
    intn status;
    
    haNarginChk(7, 7, nrhs);
    haNargoutChk(0, 1, nlhs);
    
    gridid = (int32) haGetNonNegativeDoubleScalar(prhs[2], "Grid identifier");
    fieldname = haGetString(prhs[3], "Field name");
    dimlist = haGetString(prhs[4], "Dimension list");
    numbertype = haGetDataType(prhs[5]);
    merge = haGetEOSMergeCode(prhs[6]);
    
    status = GDdeffield(gridid, fieldname, dimlist, numbertype, merge);
    plhs[0] = haCreateDoubleScalar((double) status);

    if (fieldname != NULL)
    {
        mxFree((void *) fieldname);
    }
    if (dimlist != NULL)
    {
        mxFree((void *) dimlist);
    }
}

/*
 * hdfGDdeforigin
 *
 * Purpose: gateway to GDdeforigin()
 *          Defines origin of grid
 *
 * MATLAB usage:
 * status = hdf('gd','deforigin',gridid,origin)
 *          origin can be 'HDFE_GD_UL', 'HDFE_GD_UR', 'HDFE_GD_LL',
 *          'HDFE_GD_LR'; alternatively, origin can be 'ul', 'ur', 'll',
 *          or 'lr'.
 */
static void hdfGDdeforigin(int nlhs,
                              mxArray *plhs[],
                              int nrhs,
                              const mxArray *prhs[])
{
    int32 gridid;
    int32 origincode;
    intn status;
    
    haNarginChk(4, 4, nrhs);
    haNargoutChk(0, 1, nlhs);
    
    gridid = (int32) haGetNonNegativeDoubleScalar(prhs[2], "Grid identifier");
    origincode = GetOriginCode(prhs[3]);
    
    status = GDdeforigin(gridid, origincode);
    
    plhs[0] = haCreateDoubleScalar((double) status);
}

/*
 * hdfGDdefpixreg
 *
 * Purpose: gateway to GDdefpixreg()
 *          Defines pixel registration within grid cell
 *
 * MATLAB usage:
 * status = hdf('GD','defpixreg',gridid,pixreg)
 *          pixreg can be:
 *              'HDFE_CENTER'   or 'center'
 *              'HDFE_CORNER'   or 'corner'
 */
static void hdfGDdefpixreg(int nlhs,
                              mxArray *plhs[],
                              int nrhs,
                              const mxArray *prhs[])
{
    int32 gridid;
    int32 pixreg;
    intn status;
    
    haNarginChk(4, 4, nrhs);
    haNargoutChk(0, 1, nlhs);
    
    gridid = (int32) haGetNonNegativeDoubleScalar(prhs[2], "Grid identifier");
    pixreg = GetPixReg(prhs[3]);
    status = GDdefpixreg(gridid, pixreg);
    plhs[0] = haCreateDoubleScalar((double) status);
}

/*
 * hdfGDdefproj
 *
 * Purpose: gateway to GDdefproj()
 *          Defines projection of grid
 *
 * MATLAB usage:
 * status = hdf('gd','defproj',gridid,projcode,zonecode,spherecode,
 *                   projparm)
 *          When not needed, zonecode, spherecode, projparm can be empty.
 */
static void hdfGDdefproj(int nlhs,
                            mxArray *plhs[],
                            int nrhs,
                            const mxArray *prhs[])
{
    int32 gridid;
    int32 projcode;
    int32 zonecode;
    int32 spherecode;
    float64 projparm[NUM_PROJ_PARMS];
    intn status;
    
    haNarginChk(7, 7, nrhs);
    haNargoutChk(0, 1, nlhs);
    
    gridid = (int32) haGetNonNegativeDoubleScalar(prhs[2], "Grid identifier");
    projcode = GetProjCode(prhs[3]);
    if (haIsNULL(prhs[4]))
    {
        zonecode = 0;
    }
    else
    {
        zonecode = (int32) haGetDoubleScalar(prhs[4], "Zone code");
    }
    
    if (haIsNULL(prhs[5]))
    {
        spherecode = 0;
    }
    else
    {
        spherecode = (int32) haGetDoubleScalar(prhs[5], "Spheroid code");
    }
    
    if (haIsNULL(prhs[6]))
    {
        status = GDdefproj(gridid, projcode, zonecode, spherecode, NULL);
    }
    else
    {
        GetProjParm(prhs[6], projparm);
        status = GDdefproj(gridid, projcode, zonecode, spherecode, projparm);
    }
    
    plhs[0] = haCreateDoubleScalar((double) status);
}

/*
 * hdfGDdeftimeperiod
 * 
 * Purpose: Gateway to the HDF-EOS Library function GDdeftimeperiod
 *          Defines a time period for a grid
 *
 * MATLAB usage:
 *          periodid = hdf('GD', 'deftimeperiod', gridid, periodid
 *                         starttime, stoptime)
 *                     periodid can be -1 if first call
 *
 * Inputs:  gridid     - Grid identifier
 *          periodid   - periodid from previous subset call
 *          starttime   - start time of period
 *          stoptime    - stop time of period
 * 
 * Outputs: periodid    - grid period ID
 * 
 * Retuns:  none
 */
static
void hdfGDdeftimeperiod(int nlhs,
                           mxArray *plhs[],
                           int nrhs,
                           const mxArray *prhs[])
{
    int32 gridid;
    double starttime;
    double stoptime;
    int32 periodid;
    
    /* Argument checking */
    haNarginChk(6, 6, nrhs);
    haNargoutChk(0, 1, nlhs);
    
    /* Get data from MATLAB arrays */
    gridid = (int32) haGetNonNegativeDoubleScalar(prhs[2], "Grid identifier");
    periodid = (int32) haGetDoubleScalar(prhs[3], "Period identifier");
    starttime = haGetDoubleScalar(prhs[4], "Start time");
    stoptime  = haGetDoubleScalar(prhs[5], "Stop time");

    /* Call HDF-EOS library function, and output result */
    periodid = GDdeftimeperiod(gridid, periodid, starttime, stoptime);
    plhs[0] = haCreateDoubleScalar((double) periodid);
}

/*
 * hdfGDdeftile
 *
 * Purpose: gateway to GDdeftile()
 *          Defines tiling dimensions for subsequent field definitions
 *
 * MATLAB usage:
 * status = hdf('GD','deftile',gridid,tilecode,tiledims)
 */
static void hdfGDdeftile(int nlhs,
                            mxArray *plhs[],
                            int nrhs,
                            const mxArray *prhs[])
{
    int32 gridid;
    int32 tilecode;
    int32 tilerank;
    double *real_ptr;
    int32 *tiledims_ptr = NULL;
    intn status;
    int k;
    
    haNarginChk(5, 5, nrhs);
    haNargoutChk(0, 1, nlhs);
    
    gridid = (int32) haGetNonNegativeDoubleScalar(prhs[2],"Grid identifier");
    tilecode = GetTileCode(prhs[3]);
    
    if (!mxIsDouble(prhs[4]))
    {
        mexErrMsgTxt("Tiledims must be double.");
    }
    tilerank = mxGetNumberOfElements(prhs[4]);
    tiledims_ptr = (int32 *) mxCalloc(tilerank, sizeof(*tiledims_ptr));
    real_ptr = mxGetPr(prhs[4]);
    for (k = 0; k < tilerank; k++)
    {
        tiledims_ptr[k] = (int32) real_ptr[k];
    }
    
    status = GDdeftile(gridid, tilecode, tilerank, tiledims_ptr);
    
    plhs[0] = haCreateDoubleScalar((double) status);
    
    if (tiledims_ptr != NULL)
    {
        mxFree(tiledims_ptr);
    }
}

/*
 * hdfGDdefvrtregion
 * 
 * Purpose: Gateway to the HDF-EOS Library function GDdefvrtregion
 *          Subsets on a monotonic field or contiguous elements of
 *          a dimension.
 *
 * MATLAB usage:
 *          regionid2 = hdf('GD', 'defvrtregion', gridid, ...
 *                          regionid, vertobj, range);
 *
 * Inputs:  gridid     - Grid identifier
 *          regionid    - Region (or period) ID from previous subset call
 *                        (may be -1 for "stand-alone"
 *          vertobj     - Dimension or field to subset by
 *          range       - minimum and maximum range for subset
 *
 * Outputs: regionid2   - Grid region ID
 * 
 * Retuns:  none
 */
static
void hdfGDdefvrtregion(int nlhs,
                          mxArray *plhs[],
                          int nrhs,
                          const mxArray *prhs[])
{
    int32 gridid;
    int32 regionid;
    char *vertobj = NULL;
    double *range = NULL;
    int32 regionid2;
    
    /* Argument checking */
    haNarginChk(6, 6, nrhs);
    haNargoutChk(0, 1, nlhs);
    
    /* Get data from MATLAB arrays */
    gridid = (int32) haGetNonNegativeDoubleScalar(prhs[2], "Grid identifier");
    regionid = (int32) haGetDoubleScalar(prhs[3], "Region identifier");
    vertobj = haGetString(prhs[4], "VertObj");
    if (!mxIsDouble(prhs[5]) || (mxGetNumberOfElements(prhs[5]) != 2)) {
        mexErrMsgTxt("range must be a double array of length 2.");
    }
    range = mxGetPr(prhs[5]);
    
    /* Call HDF-EOS library function, and output result */
    regionid2 = GDdefvrtregion(gridid, regionid, vertobj, range);
    plhs[0] = haCreateDoubleScalar((double) regionid2);

    /* Clean up */
    if (vertobj != NULL)
    {
        mxFree(vertobj);
    }
}

/*
 * hdfGDdetach
 *
 * Purpose: gateway to GDdetach()
 *          Detaches from grid interface
 *
 * MATLAB usage:
 * status = hdf('gd','detach',gridid)
 */
static void hdfGDdetach(int nlhs,
                           mxArray *plhs[],
                           int nrhs,
                           const mxArray *prhs[])
{
    intn status;
    int32 gridid;

    haNarginChk(3, 3, nrhs);
    haNargoutChk(0, 1, nlhs);
    
    gridid = (int32) haGetNonNegativeDoubleScalar(prhs[2], "Grid identifier");
    status = GDdetach(gridid);
    if (status != FAIL)
    {
        haDeleteIDFromList(gridid, GD_Grid_List);
    }
    plhs[0] = haCreateDoubleScalar((double) status);
}

/*
 * hdfGDdiminfo
 * 
 * Purpose: Gateway to the HDF-EOS Library function GDdiminfo
 *          Retrieve size of specified dimension
 *
 * MATLAB usage:
 *          dimsize = hdf('GD', 'diminfo', gridid, dimname);
 *
 * Inputs:  gridid      - Grid identifier
 *          dimname     - dimension name
 *
 * Outputs: dimsize     - size of dimension
 *
 * Retuns:  none
 */
static
void hdfGDdiminfo(int nlhs,
                     mxArray *plhs[],
                     int nrhs,
                     const mxArray *prhs[])
{
    int32 gridid;
    int32 dimsize;
    char *dimname = NULL;
    
    /* Argument checking */
    haNarginChk(4, 4, nrhs);
    haNargoutChk(0, 1, nlhs);
    
    /* Get data from MATLAB arrays */
    gridid = (int32) haGetNonNegativeDoubleScalar(prhs[2], "Grid identifier");
    dimname = haGetString(prhs[3], "Dimension name");
    
    /* Call HDF-EOS library function, and output result */
    dimsize = GDdiminfo(gridid, dimname);
    
    plhs[0] = haCreateDoubleScalar((double) dimsize);

    /* Clean up */
    if (dimname != NULL)
    {
        mxFree(dimname);
    }
}

/*
 * hdfGDdupregion
 *
 * Purpose: gateway to GDdupregion()
 *          Duplicates a region
 *
 * MATLAB usage:
 * regionid2 = hdf('GD','dupregion',regionid)
 */
static void hdfGDdupregion(int nlhs,
                              mxArray *plhs[],
                              int nrhs,
                              const mxArray *prhs[])
{
    int32 regionid;
    int32 regionid2;
    
    haNarginChk(3, 3, nrhs);
    haNargoutChk(0, 1, nlhs);
    
    regionid = (int32) haGetNonNegativeDoubleScalar(prhs[2],"Region identifier");
    regionid2 = GDdupregion(regionid);
    plhs[0] = haCreateDoubleScalar((double) regionid2);
}
    
/*
 * hdfGDextractregion
 * 
 * Purpose: Gateway to the HDF-EOS Library function GDextractregion
 *          Extracts (Reads) from subsetted region.
 *
 * MATLAB usage:
 *          [buffer, status] = hdf('GD', 'extractregion', gridid, ...
 *                                 regionid, fieldname);
 *
 * Inputs:  gridid      - Grid identifier
 *          regionid    - Region identifier
 *          fieldname   - field to subset
 * 
 * Outputs: buffer      - data buffer
 *          status      - 0 if succeed, -1 if fail
 * 
 * Retuns:  none
 */
static
void hdfGDextractregion(int nlhs,
                           mxArray *plhs[],
                           int nrhs,
                           const mxArray *prhs[])
{
    int32 gridid;
    int32 regionid;
    char *fieldname = NULL;
    VOIDP buffer = NULL;
    intn status;

    int32 ntype;
    int32 rank;
    int32 dims[MAX_VAR_DIMS];
    int32 size;
    int matlabdims[MAX_VAR_DIMS];
    int i;
    bool ok2free = true;
    double upleft[2];
    double lowright[2];
    
    /* Argument checking */
    haNarginChk(5, 5, nrhs);
    haNargoutChk(0, 2, nlhs);
    
    /* Get data from MATLAB arrays */
    gridid = (int32) haGetNonNegativeDoubleScalar(prhs[2], "Grid identifier");
    regionid = (int32) haGetNonNegativeDoubleScalar(prhs[3], "Region identifier");
    fieldname = haGetString(prhs[4], "Field name");
    
    /* Get the number type */
    status = GDregioninfo(gridid, regionid, fieldname, &ntype, 
                          &rank, dims, &size, upleft, lowright);
    if (status != FAIL) 
    {
        int count = 1;
        /* flip the size vector */
        if (rank==0) 
        {
            matlabdims[0] = 1;
            matlabdims[1] = 1;
            rank = 2;
        }
        else if (rank == 1) 
        {
            matlabdims[0] = dims[0];
            matlabdims[1] = 1;
            rank = 2;
            count = dims[0];
        }
        else 
        {
            for (i =0; i<rank; i++) 
            {
                matlabdims[i] = dims[rank-i-1];
                count *= matlabdims[i];
            }
        }
        
        /* Allocate memory for the buffer */
        buffer = haMakeHDFDataBuffer(count, ntype);
        
        /* Call HDF-EOS library function, and output result */
        status = GDextractregion(gridid, regionid, fieldname, buffer);

        if (status != FAIL)
        {
            plhs[0] = haMakeArrayFromHDFDataBuffer(rank, matlabdims, 
                                                   ntype, buffer, &ok2free);
        }
        else
        {
            plhs[0] = EMPTY;
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
 
    /* Clean up */
    if (fieldname != NULL)
    {
        mxFree(fieldname);
    }
    if (ok2free && (buffer != NULL)) 
    {
        mxFree(buffer);
    }
}

/*
 * hdfGDfieldinfo
 * 
 * Purpose: Gateway to the HDF-EOS Library function SWfieldinfo
 *          Returns information about a specified geolocation 
 *          or data field within a grid.
 *
 * MATLAB usage:
 *          [rank, dims, numbertype, dimlist, status] = ...
 *                      hdf('GD', 'fieldinfo', gridid, fieldname);
 *
 * Inputs:  gridid     - Grid identifier
 *          fieldname   - field name
 *
 * Outputs: rank        - rank of field
 *          dims        - array containing the dimension sizes 
 *                        of the field.
 *          numbertype  - number type of field
 *          dimlist     - list of dimensions in a field
 *          status      - returns 0 if succeed, and -1 if fail
 * 
 * Retuns:  none
 */
static
void hdfGDfieldinfo(int nlhs,
                       mxArray *plhs[],
                       int nrhs,
                       const mxArray *prhs[])
{
    int32 gridid;
    char *fieldname = NULL;
    int32 rank;
    int32 dims[MAX_VAR_DIMS];
    int32 numbertype;
    char *dimlist = NULL;
    int dimsdims[2] = {0, 1};
    intn status;    
    int32 strbufsz;
    int32 ndims;

    /* Argument checking */
    haNarginChk(4, 4, nrhs);
    haNargoutChk(0, 5, nlhs);
    
    /* Get data from MATLAB arrays */
    gridid = (int32) haGetNonNegativeDoubleScalar(prhs[2], "Grid identifier");
    fieldname = haGetString(prhs[3], "Field name");
    
    status = GDfieldinfo(gridid, fieldname, &rank, dims,
                         &numbertype, NULL);
    if (status != FAIL)
    {
        strbufsz = rank*MAX_NC_NAME;
        dimlist = mxCalloc(strbufsz+1, sizeof(char));
        status = GDfieldinfo(gridid, fieldname, &rank, dims,
                             &numbertype, dimlist);
    }

    if (status != FAIL) 
    {
        plhs[0] = haCreateDoubleScalar((double) rank);
    }
    else
    {
        plhs[0] = EMPTY;
    }
    
    if (nlhs > 1)
    {
        if (status != FAIL)
        {
            dimsdims[0] = 1;
            dimsdims[1] = rank;
            plhs[1] = CreateDoubleMxArrayFromINT32Array(dims, 2, dimsdims);
        }
        else
        {
            plhs[1] = EMPTY;
        }
    }
    
    if (nlhs > 2)
    {
        if (status != FAIL)
        {
            plhs[2] = mxCreateString(haGetNumberTypeString(numbertype));
        }
        else
        {
            plhs[2] = EMPTY;
        }
    }
    
    if (nlhs > 3)
    {
        if (status != FAIL)
        {
            plhs[3] = mxCreateString(dimlist);
        }
        else
        {
            plhs[3] = EMPTY;
        }
    }

    if (nlhs > 4) {
        plhs[4] = haCreateDoubleScalar(status);
    }

    /* Clean up */
    if (fieldname != NULL)
    {
        mxFree(fieldname);
    }
    if (dimlist != NULL)
    {
        mxFree(dimlist);
    }
}
    
/*
 * hdfGDgetfillvalue
 *
 * Purpose: Gateway to the HDF-EOS Library function GDgetfillvalue.
 *          Retrieves fill value for the specified field.
 *
 * MATLAB usage:
 *          [fillvalue,status] = hdf('GD','getfillvalue',gridid,fieldname)
 */
static
void hdfGDgetfillvalue(int nlhs,
                          mxArray *plhs[],
                          int nrhs,
                          const mxArray *prhs[])
{
    int32 gridid;
    char *fieldname = NULL;
    intn status;
    void *buffer = NULL;
    int matlab_dims[2];
    int32 numbertype;
    int32 rank;
    int32 dims[MAX_VAR_DIMS];
    bool ok2free = true;
    
    haNarginChk(4, 4, nrhs);
    haNargoutChk(0, 2, nlhs);
    
    gridid = (int32) haGetNonNegativeDoubleScalar(prhs[2],"Grid identifier");
    fieldname = haGetString(prhs[3], "Field name");
    
    /* Get number type for the field */
    status = GDfieldinfo(gridid, fieldname, &rank, dims, &numbertype, NULL);
    
    /* Allocate space for fillvalue and get it */
    if (status != FAIL)
    {
        buffer = haMakeHDFDataBuffer(1, numbertype);
        status = GDgetfillvalue(gridid,fieldname,buffer);
    }
    
    matlab_dims[0] = 1;
    matlab_dims[1] = 1;
    
    if (status != FAIL)
    {
        plhs[0] = haMakeArrayFromHDFDataBuffer(2, matlab_dims, numbertype,
                                               buffer, &ok2free);
    }
    else
    {
        plhs[0] = EMPTY;
    }
    
    if (nlhs > 1)
    {
        plhs[1] = haCreateDoubleScalar((double) status);
    }
    
    if (fieldname != NULL)
    {
        mxFree(fieldname);
    }
    if (ok2free && (buffer != NULL))
    {
        mxFree(buffer);
    }
}

/*
 * hdfGDgetpixels
 *
 * Purpose: gateway to GDgetpixels()
 *          Get pixel coordinates corresponding to latitude and longitude
 *
 * MATLAB usage:
 * [row,col,status] = hdf('GD','getpixels',gridid,lon,lat)
 */
static void hdfGDgetpixels(int nlhs,
                              mxArray *plhs[],
                              int nrhs,
                              const mxArray *prhs[])
{
    int32 gridid;
    intn status;
    double *lon_ptr;
    double *lat_ptr;
    double *real_ptr;
    int lat_ndims;
    int lon_ndims;
    const int *lat_size;
    const int *lon_size;
    int k;
    int32 *row_ptr = NULL;
    int32 *col_ptr = NULL;
    int num_elements;

    haNarginChk(5, 5, nrhs);
    haNargoutChk(0, 3, nlhs);
    
    gridid = (int32) haGetNonNegativeDoubleScalar(prhs[2], "Grid identifier");
    num_elements = mxGetNumberOfElements(prhs[3]);
    
    if (!mxIsDouble(prhs[3]) || !mxIsDouble(prhs[4]))
    {
        mexErrMsgTxt("LON and LAT must double.");
    }

    lon_ndims = mxGetNumberOfDimensions(prhs[3]);
    lon_size = mxGetDimensions(prhs[3]);
    lat_ndims = mxGetNumberOfDimensions(prhs[4]);
    lat_size = mxGetDimensions(prhs[4]);
    
    if (lon_ndims != lat_ndims)
    {
        mexErrMsgTxt("LON and LAT must be the same size.");
    }
    for (k = 0; k < lon_ndims; k++)
    {
        if (lon_size[k] != lat_size[k])
        {
            mexErrMsgTxt("LON and LAT must be the same size.");
        }
    }
    lon_ptr = mxGetPr(prhs[3]);
    lat_ptr = mxGetPr(prhs[4]);
    
    row_ptr = mxCalloc(num_elements, sizeof(*row_ptr));
    col_ptr = mxCalloc(num_elements, sizeof(*col_ptr));
    
    status = GDgetpixels(gridid, num_elements, lon_ptr, lat_ptr,
                         row_ptr, col_ptr);
    
    if (status != FAIL)
    {
        plhs[0] = mxCreateNumericArray(lon_ndims,lon_size,mxDOUBLE_CLASS,mxREAL);
        real_ptr = mxGetPr(plhs[0]);
        for (k = 0; k < num_elements; k++)
        {
            real_ptr[k] = row_ptr[k];
        }
    }
    else
    {
        plhs[0] = EMPTY;
    }
    
    if (nlhs > 1)
    {
        if (status != FAIL)
        {
            plhs[1] = mxCreateNumericArray(lon_ndims,lon_size,mxDOUBLE_CLASS,mxREAL);
            real_ptr = mxGetPr(plhs[1]);
            for (k = 0; k < num_elements; k++)
            {
                real_ptr[k] = col_ptr[k];
            }
        }
        else
        {
            plhs[1] = EMPTY;
        }
    }
    
    if (nlhs > 2)
    {
        plhs[2] = haCreateDoubleScalar((double) status);
    }

    if (row_ptr != NULL)
    {
        mxFree(row_ptr);
    }
    if (col_ptr != NULL)
    {
        mxFree(col_ptr);
    }
}

/*
 * hdfGDgetpixvalues
 *
 * Purpose: gateway to GDgetpixvalues()
 *          Read field data values for specified pixels
 *
 * MATLAB usage:
 * [buffer,bytesize] = hdf('GD','getpixvalues',gridid,row,col,fieldname)
 *                   buffer returned as column
 */
static void hdfGDgetpixvalues(int nlhs,
                                 mxArray *plhs[],
                                 int nrhs,
                                 const mxArray *prhs[])
{
    int32 gridid;
    char *fieldname = NULL;
    int32 rank;
    int32 dims[MAX_VAR_DIMS];
    int32 numbertype;
    int32 *row_ptr = NULL;
    int32 *col_ptr = NULL;
    double *real_ptr;
    int32 bufsize = -1;
    int32 elemsize;
    VOIDP buffer = NULL;
    int num_inputs;
    int num_outputs;
    bool ok2free = true;
    intn status;
    int k;
    
    haNarginChk(6, 6, nrhs);
    haNargoutChk(0, 2, nlhs);

    gridid = (int32) haGetNonNegativeDoubleScalar(prhs[2],"Grid identifier");
    fieldname = haGetString(prhs[5],"Field name");

    if (!mxIsDouble(prhs[3]) || !mxIsDouble(prhs[4]))
    {
        mexErrMsgTxt("Row and Col must be double.");
    }
    num_inputs = mxGetNumberOfElements(prhs[3]);
    if (mxGetNumberOfElements(prhs[4]) != num_inputs)
    {
        mexErrMsgTxt("Row and Col must have the same number of elements.");
    }
    
    /* Find out the number type of the field. */
    status = GDfieldinfo(gridid, fieldname, &rank, dims, &numbertype, NULL);

    if (status != FAIL)
    {
        row_ptr = (int32 *) mxCalloc(num_inputs, sizeof(*row_ptr));
        col_ptr = (int32 *) mxCalloc(num_inputs, sizeof(*col_ptr));
        real_ptr = mxGetPr(prhs[3]);
        for (k = 0; k < num_inputs; k++)
        {
            row_ptr[k] = (int32) real_ptr[k];
        }
        
        real_ptr = mxGetPr(prhs[4]);
        for (k = 0; k < num_inputs; k++)
        {
            col_ptr[k] = (int32) real_ptr[k];
        }
    }
    
    if (status != FAIL)
    {
        /* Find out size of data buffer (in bytes) */
        bufsize = GDgetpixvalues(gridid, num_inputs, row_ptr, col_ptr,
                                 fieldname, NULL);
        status = (bufsize < 0) ? FAIL : SUCCEED;
    }
    
    if (status != FAIL)
    {
        elemsize = haGetDataTypeSize(numbertype);
    }
    
    /* How many outputs are there? */
    if (status != FAIL)
    {
        num_outputs = bufsize / elemsize;
        buffer = haMakeHDFDataBuffer(num_outputs, numbertype);

        bufsize = GDgetpixvalues(gridid, num_inputs, row_ptr, col_ptr,
                                 fieldname, buffer);
        status = (bufsize < 0) ? FAIL : SUCCEED;

        if (status != FAIL)
        {
            int ndims = 2;
            int siz[2];
            siz[0] = num_outputs;
            siz[1] = 1;
            plhs[0] = haMakeArrayFromHDFDataBuffer(ndims, siz,
                                                   numbertype, buffer,
                                                   &ok2free);
        }
        else
        {
            plhs[0] = EMPTY;
        }
    }
    else
    {
        plhs[0] = EMPTY;
    }
    
    if (nlhs > 1)
    {
        plhs[1] = haCreateDoubleScalar((double) bufsize);
    }
    
    if (ok2free && (buffer != NULL))
    {
        mxFree(buffer);
    }
    if (fieldname != NULL)
    {
        mxFree(fieldname);
    }
    if (row_ptr != NULL)
    {
        mxFree(row_ptr);
    }
    if (col_ptr != NULL)
    {
        mxFree(col_ptr);
    }
}
    
/*
 * hdfGDgridinfo
 *
 * Purpose: gateway to GDgridinfo()
 *          Returns position and size of grid
 *
 * MATLAB usage:
 * [xdimsize,ydimsize,upleft,lowright,status] = hdf('GD','gridinfo',gridid)
 */
static void hdfGDgridinfo(int nlhs,
                             mxArray *plhs[],
                             int nrhs,
                             const mxArray *prhs[])
{
    float64 upleft[2];
    float64 lowright[2];
    int32 xdimsize;
    int32 ydimsize;
    int32 gridid;
    double *real_ptr;
    intn status;

    haNarginChk(3, 3, nrhs);
    haNargoutChk(0, 5, nlhs);
    
    gridid = (int32) haGetNonNegativeDoubleScalar(prhs[2], "Grid identifier");
    
    status = GDgridinfo(gridid, &xdimsize, &ydimsize, upleft, lowright);
    
    if (status != FAIL)
    {
        plhs[0] = haCreateDoubleScalar((double) xdimsize);
    }
    else
    {
        plhs[0] = EMPTY;
    }
    
    if (nlhs > 1)
    {
        if (status != FAIL)
        {
            plhs[1] = haCreateDoubleScalar((double) ydimsize);
        }
        else
        {
            plhs[1] = EMPTY;
        }
    }
    
    if (nlhs > 2)
    {
        if (status != FAIL)
        {
            plhs[2] = mxCreateDoubleMatrix(1, 2, mxREAL);
            real_ptr = mxGetPr(plhs[2]);
            real_ptr[0] = upleft[0];
            real_ptr[1] = upleft[1];
        }
        else
        {
            plhs[2] = EMPTY;
        }
    }
    
    if (nlhs > 3)
    {
        if (status != FAIL)
        {
            plhs[3] = mxCreateDoubleMatrix(1, 2, mxREAL);
            real_ptr = mxGetPr(plhs[3]);
            real_ptr[0] = lowright[0];
            real_ptr[1] = lowright[1];
        }
        else
        {
            plhs[3] = EMPTY;
        }
    }
    
    if (nlhs > 4)
    {
        plhs[4] = haCreateDoubleScalar((double) status);
    }
}

/*
 * hdfGDinqattrs
 * 
 * Purpose: Gateway to the HDF-EOS Library function GDinqattrs
 *          Retrieve information about all of the attributes
 *          defined in a grid.
 *
 * MATLAB usage:
 *          [nattr, attrlist] = hdf('GD', 'inqattrs', gridid);
 *
 * Inputs:  gridid     - Grid identifier
 *          
 * Outputs: nattr       - number of data fields found
 *          attrlist    - attribute list
 *
 * Returns: none
 */
static
void hdfGDinqattrs(int nlhs,
                      mxArray *plhs[],
                      int nrhs,
                      const mxArray *prhs[])
{
    int32 gridid;
    int32 nattr;
    char *attrlist = NULL;
    int32 strbufsize = 0;  /* see comment below */
    intn status;
    
    /* Argument checking */
    haNarginChk(3, 3, nrhs);
    haNargoutChk(0, 2, nlhs);
    
    /* Get data from MATLAB arrays */
    gridid = (int32) haGetNonNegativeDoubleScalar(prhs[2], "Grid identifier");

    /* How many attributes are there? */
    nattr = GDinqattrs(gridid, NULL, &strbufsize);
    status = (nattr < 0) ? FAIL : SUCCEED;
    
    /* 
     * Allocate space for and get the attribute list.
     * Note that HDF-EOS library can return 0 for nattr,
     * and when it does, it doesn't set strbufsize.
     * By initializing strbufsize to 0 above, we'll
     * end up with attrlist being an empty string here
     * in that case.  -sle, June 1998
     */
    if (status != FAIL)
    {
        attrlist = mxCalloc(strbufsize + 1, sizeof(char));
        nattr = GDinqattrs(gridid, attrlist, &strbufsize);
    }
    
    plhs[0] = haCreateDoubleScalar((double) nattr);

    if (nlhs > 1)
    {
        if (status != FAIL)
        {
            plhs[1] = mxCreateString(attrlist);
        }
        else
        {
            plhs[1] = EMPTY;
        }
    }
    
    /* Clean up */
    if (attrlist != NULL)
    {
        mxFree(attrlist);
    }
}

/*
 * hdfGDinqdims
 * 
 * Purpose: Gateway to the HDF-EOS Library function GDinqdims
 *          Retrieve information about all of the dimensions 
 *          defined in a grid.
 *
 * MATLAB usage:
 *          [ndims, dimname, dims] = hdf('GD', 'inqdims', gridid);
 *
 * Inputs:  gridid     - Grid identifier
 *          
 * Outputs: ndims       - number of dimension entries found
 *          dimname     - dimension list
 *          dims        - array conaining size of each dimension
 * 
 * Returns: none
 */
static
void hdfGDinqdims(int nlhs,
                     mxArray *plhs[],
                     int nrhs,
                     const mxArray *prhs[])
{
    int32 gridid;
    int32 ndims;
    char *dimname = NULL;
    int32 dims[MAX_VAR_DIMS];
    int dimsdims[2] = {0, 0};
    int32 strbufsz = 0;
    intn status;

    /* Argument checking */
    haNarginChk(3, 3, nrhs);
    haNargoutChk(0, 3, nlhs);
    
    /* Get data from MATLAB arrays */
    gridid = (int32) haGetNonNegativeDoubleScalar(prhs[2], "Grid identifier");
    status = (gridid < 0) ? FAIL : SUCCEED;

    /* Call HDF-EOS library function, and output result */
    if (status != FAIL)
    {
        ndims = GDnentries(gridid, HDFE_NENTDIM, &strbufsz);
        status = (ndims < 0) ? FAIL : SUCCEED;
    }

    /* Allocate space and call HDF-EOS function. */
    if (status != FAIL)
    {
        dimname = mxCalloc(strbufsz+1, sizeof(char));
        ndims = GDinqdims(gridid, dimname, dims);
         status = (ndims < 0) ? FAIL : SUCCEED;
    }
    
    if (status != FAIL)
    {
        plhs[0] = haCreateDoubleScalar((double) ndims);
    }
    else
    {
        plhs[0] = haCreateDoubleScalar((double) FAIL);
    }
    
    if (nlhs > 1)
    {
        if (status != FAIL)
        {
            plhs[1] = mxCreateString(dimname);
        }
        else
        {
            plhs[1] = EMPTY;
        }
    }
    
    if (nlhs > 2)
    {
        if (status != FAIL)
        {
            dimsdims[0] = 1;
            dimsdims[1] = ndims;  /* dimsdims contains dimensions of the output  
                                  ** dimensions array.                           */
            plhs[2] = CreateDoubleMxArrayFromINT32Array(dims, 2, dimsdims);
        }
        else
        {
            plhs[2] = EMPTY;
        }
    }

    /* Clean up */
    if (dimname != NULL)
    {
        mxFree(dimname);
    }
}

/*
 * hdfGDinqfields
 * 
 * Purpose: Gateway to the HDF-EOS Library function GDinqfields
 *          Retrieve information about all of the data
 *          fields defined in a grid.
 *
 * MATLAB usage:
 *          [nfields, fieldlist, rank, numbertype] = ...
 *                              hdf('GD', 'inqfields', gridid);
 *
 * Inputs:  gridid     - Grid identifier
 *          
 * Outputs: nfields     - number of data fields found
 *          fieldlist   - listing of data fields
 *          rank        - array conaining rank of each data field
 *          numbertype  - array conaining numbertype of each data field
 *
 * Returns: none
 */
static
void hdfGDinqfields(int nlhs,
                           mxArray *plhs[],
                           int nrhs,
                           const mxArray *prhs[])
{
    int32 gridid;

    int32 nfields;
    char *fieldlist = NULL;
    int32 *rank = NULL;
    int32 *numbertype = NULL;
    int32 strbufsz;
    intn status;

    int dims[2] = {0, 0};
    
    /* Argument checking */
    haNarginChk(3, 3, nrhs);
    haNargoutChk(0, 4, nlhs);
    
    /* Get data from MATLAB arrays */
    gridid = (int32) haGetNonNegativeDoubleScalar(prhs[2], "Grid identifier");

    /* 
     * How many fields are there, and how much space do we need
     * field list?
     */
    nfields = GDnentries(gridid, HDFE_NENTDFLD, &strbufsz);
    status = (nfields < 0) ? FAIL : SUCCEED;
    
    /* Allocate space and call library function */
    if (status != FAIL)
    {
        fieldlist = mxCalloc(strbufsz + 1, sizeof(char));
        rank = mxCalloc(nfields, sizeof(int32));
        numbertype = mxCalloc(nfields, sizeof(int32));
        nfields = GDinqfields(gridid, fieldlist, rank, numbertype);
        status = (nfields < 0) ? FAIL : SUCCEED;
    }
    
    if (status != FAIL)
    {
        plhs[0] = haCreateDoubleScalar((double) nfields);
    }
    else
    {
        plhs[0] = haCreateDoubleScalar((double) FAIL);
    }
    
    if (nlhs > 1)
    {
        if (status != FAIL)
        {
            plhs[1] = mxCreateString(fieldlist);
        }
        else
        {
            plhs[1] = EMPTY;
        }
    }
    
    if (nlhs > 2)
    {
        if (status != FAIL)
        {
            dims[0] = 1;
            dims[1] = nfields;    /* dims contains dimensions of the output  
                                  ** idxsizes array.                       */
            plhs[2] = CreateDoubleMxArrayFromINT32Array(rank, 2, dims);
        }
        else
        {
            plhs[2] = EMPTY;
        }
    }
    
    if (nlhs > 3)
    {
        if (status != FAIL)
        {
            plhs[3] = haGenerateNumberTypeArray(nfields, numbertype);
        }
        else
        {
            plhs[3] = EMPTY;
        }
    }
    
    /* Clean up */
    if (fieldlist != NULL)
    {
        mxFree(fieldlist);
    }
    if (rank != NULL)
    {
        mxFree(rank);
    }
    if (numbertype != NULL)
    {
        mxFree(numbertype);
    }
}

/*
 * hdfGDinqgrid
 * 
 * Purpose: Gateway to the HDF-EOS Library function GDinqgrid
 *          Retreives compression information about a field
 *
 * MATLAB usage:
 *          [ngrid, gridlist] = hdf('GD', 'inqgrid', filename);
 *
 * Inputs:  filename    - HDF file name
 *
 * Outputs: ngrid      - Number of grids found
 *          gridlist   - listing of grids in file
 * 
 * Retuns:  none
 */
static
void hdfGDinqgrid(int nlhs,
                      mxArray *plhs[],
                      int nrhs,
                      const mxArray *prhs[])
{
    char *filename = NULL;
    int32 ngrid;
    char *gridlist = NULL;
    int32 strbufsize;
    intn status;
    
    /* Argument checking */
    haNarginChk(3, 3, nrhs);
    haNargoutChk(0, 2, nlhs);
    
    /* Get data from MATLAB arrays */
    filename = haGetString(prhs[2], "Filename");
    
    /* How much space do we need to allocate? */
    ngrid = GDinqgrid(filename, NULL, &strbufsize);
    status = (ngrid < 0) ? FAIL : SUCCEED;
    
    /* Allocate space and get the gridlist */
    if (status != FAIL)
    {
        gridlist = mxCalloc(strbufsize+1, sizeof(char));
        ngrid = GDinqgrid(filename, gridlist, &strbufsize);
    }

    plhs[0] = haCreateDoubleScalar((double) ngrid);

    if (nlhs > 1)
    {
        if (status != FAIL)
        {
            plhs[1] = mxCreateString(gridlist);
        }
        else
        {
            plhs[1] = EMPTY;
        }
    }

    /* Clean up */
    if (filename != NULL)
    {
        mxFree(filename);
    }
    if (gridlist != NULL)
    {
        mxFree(gridlist);
    }
}

/*
 * hdfGDinterpolate
 *
 * Purpose: gateway to GDinterpolate()
 *          Performs bilinear interpolation on a grid field
 *
 * MATLAB usage:
 * [buffer,bytesize] = hdf('GD','getpixvalues',gridid,lon,lat,fieldname)
 *                   buffer returned as column
 */
static void hdfGDinterpolate(int nlhs,
                                mxArray *plhs[],
                                int nrhs,
                                const mxArray *prhs[])
{
    int32 gridid;
    char *fieldname = NULL;
    double *lon_ptr;
    double *lat_ptr;
    int32 bufsize;
    double *buffer;
    int num_inputs;
    bool ok2free = false;
    
    haNarginChk(6, 6, nrhs);
    haNargoutChk(0, 2, nlhs);

    gridid = (int32) haGetNonNegativeDoubleScalar(prhs[2],"Grid identifier");
    fieldname = haGetString(prhs[5],"Field name");

    if (!mxIsDouble(prhs[3]) || !mxIsDouble(prhs[4]))
    {
        mexErrMsgTxt("Lon and Lat must be double.");
    }
    num_inputs = mxGetNumberOfElements(prhs[3]);
    if (mxGetNumberOfElements(prhs[4]) != num_inputs)
    {
        mexErrMsgTxt("Lon and Lat must have the same number of elements.");
    }

    lon_ptr = mxGetPr(prhs[3]);
    lat_ptr = mxGetPr(prhs[4]);

    plhs[0] = mxCreateDoubleMatrix(num_inputs, 1, mxREAL);
    buffer = mxGetPr(plhs[0]);
    
    bufsize = GDinterpolate(gridid, num_inputs, lon_ptr, lat_ptr,
                            fieldname, buffer);

    if (bufsize == FAIL)
    {
        mxDestroyArray(plhs[0]);
        plhs[0] = EMPTY;
    }
    
    if (nlhs > 1)
    {
        plhs[1] = haCreateDoubleScalar((double) bufsize);
    }
    
    if (fieldname != NULL)
    {
        mxFree(fieldname);
    }
}

/*
 * hdfGDopen
 *
 * Purpose: gateway to GDopen()
 *          Opens or creates HDF file in order to create, read or write
 *          a grid
 *
 * MATLAB usage:
 * fid = hdf('gd','open',filename,access)
 */
static void hdfGDopen(int nlhs,
                         mxArray *plhs[],
                         int nrhs,
                         const mxArray *prhs[])
{
    int32 fid;
    intn access;
    intn status;
    char *filename;
        
    haNarginChk(4, 4, nrhs);
    haNargoutChk(0, 1, nlhs);

    filename = haGetString(prhs[2], "Filename");
    access = haGetAccessMode(prhs[3]);

    fid = GDopen(filename,access);
    if (fid != FAIL)
    {
        status = haAddIDToList(fid, GD_File_List);
        if (status == FAIL)
        {
            /* 
             * Failed to add fid to the list. 
             * This might cause data loss later, so don't allow it.
             */
            GDclose(fid);
            fid = FAIL;
        }
    }
    plhs[0] = haCreateDoubleScalar((double) fid);
    mxFree(filename);
}

/*
 * hdfGDorigininfo
 *
 * Purpose: gateway to GDorigininfo()
 *          Returns the origin code for a grid.
 *
 * MATLAB usage:
 * origincode = hdf('GD','origininfo',gridid)
 */
static void hdfGDorigininfo(int nlhs,
                               mxArray *plhs[],
                               int nrhs,
                               const mxArray *prhs[])
{
    int32 gridid;
    int32 origincode;
    
    haNarginChk(3, 3, nrhs);
    haNargoutChk(0, 1, nlhs);
    
    gridid = (int32) haGetNonNegativeDoubleScalar(prhs[2],"Grid identifier");
    origincode = GDorigininfo(gridid, &origincode);
    
    if (origincode != FAIL)
    {
        plhs[0] = GetOriginStringFromCode(origincode);
    }
    else
    {
        plhs[0] = EMPTY;
    }
}

/*
 * hdfGDnentries
 * 
 * Purpose: Gateway to the HDF-EOS Library function GDnentries
 *          Returns number of entries for a specified entity
 *
 * MATLAB usage:
 *          [nentries,strbufsize] = hdf('GD', 'nentries', gridid, entrycode);
 *
 * Inputs:  gridid      - Grid identifier
 *          entrycode   - Entry code
 *
 * Outputs: nentries    - number of entries
 *
 * Returns: none
 */
static
void hdfGDnentries(int nlhs,
                      mxArray *plhs[],
                      int nrhs,
                      const mxArray *prhs[])
{
    int32 gridid;
    int32 nentries;
    int32 entrycode;
    int32 strbufsize;
    
    /* Argument checking */
    haNarginChk(4, 4, nrhs);
    haNargoutChk(0, 2, nlhs);
    
    /* Get data from MATLAB arrays */
    gridid = (int32) haGetNonNegativeDoubleScalar(prhs[2], "Grid identifier");
    entrycode = GetEntryCode(prhs[3]);
    
    /* Call HDF-EOS library function, and output result */
    nentries = GDnentries(gridid, entrycode, &strbufsize);
    
    plhs[0] = haCreateDoubleScalar((double) nentries);

    if (nlhs > 1)
    {
        if (nentries == FAIL)
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
 * hdfGDpixreginfo
 *
 * Purpose: gateway to GDpixreginfo()
 *          Returns the pixreg code for a grid.
 *
 * MATLAB usage:
 * pixregcode = hdf('GD','pixreginfo',gridid)
 */
static void hdfGDpixreginfo(int nlhs,
                               mxArray *plhs[],
                               int nrhs,
                               const mxArray *prhs[])
{
    int32 gridid;
    int32 pixregcode;
    
    haNarginChk(3, 3, nrhs);
    haNargoutChk(0, 1, nlhs);
    
    gridid = (int32) haGetNonNegativeDoubleScalar(prhs[2],"Grid identifier");
    pixregcode = GDpixreginfo(gridid, &pixregcode);
    
    if (pixregcode != FAIL)
    {
        plhs[0] = GetPixregStringFromCode(pixregcode);
    }
    else
    {
        plhs[0] = EMPTY;
    }
}

/*
 * hdfGDprojinfo
 *
 * Purpose: gateway to GDprojinfo()
 *          Retrieves projection information of grid
 *
 * MATLAB usage:
 * [projcode,zonecode,spherecode,projparm,status] = hdf('GD','projinfo',gridid)
 */
static void hdfGDprojinfo(int nlhs,
                             mxArray *plhs[],
                             int nrhs,
                             const mxArray *prhs[])
{
    intn status;
    int32 gridid;
    int32 projcode;
    int32 zonecode;
    int32 spherecode;
    float64 projparm[NUM_PROJ_PARMS];
    int k;
    double *real_ptr;

    haNarginChk(3, 3, nrhs);
    haNargoutChk(0, 5, nlhs);
    
    gridid = (int32) haGetNonNegativeDoubleScalar(prhs[2], "Grid identifier");

    /*
     * zero out projparm because GDprojinfo might not fill it.
     */
    for (k = 0; k < NUM_PROJ_PARMS; k++)
    {
        projparm[k] = 0;
    }
    
    status = GDprojinfo(gridid, &projcode, &zonecode, &spherecode,
                        projparm);
    
    if (status != FAIL)
    {
        plhs[0] = GetProjStringFromCode(projcode);
    }
    else
    {
        plhs[0] = EMPTY;
    }

    if (nlhs > 1)
    {
        if (status != FAIL)
        {
            plhs[1] = haCreateDoubleScalar((double) zonecode);
        }
        else
        {
            plhs[1] = EMPTY;
        }
    }
    
    if (nlhs > 2)
    {
        if (status != FAIL)
        {
            plhs[2] = haCreateDoubleScalar((double) spherecode);
        }
        else
        {
            plhs[2] = EMPTY;
        }
    }
    
    if (nlhs > 3)
    {
        if (status != FAIL)
        {
            plhs[3] = mxCreateDoubleMatrix(1, NUM_PROJ_PARMS, mxREAL);
            real_ptr = mxGetPr(plhs[3]);
            for (k = 0; k < NUM_PROJ_PARMS; k++)
            {
                real_ptr[k] = (double) projparm[k];
            }
        }
        else
        {
            plhs[3] = EMPTY;
        }
    }
    
    if (nlhs > 4)
    {
        plhs[4] = haCreateDoubleScalar((double) status);
    }
}

/*
 * hdfGDreadattr
 * 
 * Purpose: Gateway to the HDF-EOS Library function GDreadattr
 *          Reads attributes from a grid
 *
 * MATLAB usage:
 *          [databuf, status] = hd('GD', 'readattr', gridid, attrname)
 *
 * Inputs:  gridid     - Grid identifier
 *          attrname    - Name of attribute
 *
 * Outputs: databuf     - Attribute values read from the field
 *          status      - 0 if succeeded, -1 if failed.
 * 
 * Returns: none
 */
static
void hdfGDreadattr(int nlhs,
                      mxArray *plhs[],
                      int nrhs,
                      const mxArray *prhs[])
{
    int32 gridid;
    char *attrname = NULL;
    VOIDP datbuf = NULL;
    intn status;

    int32 numbertype;
    int32 count;
    int dims[2] = {0, 0};
    bool ok_to_free = true;

    /* Argument checking */
    haNarginChk(4, 4, nrhs);
    haNargoutChk(0, 2, nlhs);
    
    /* Get datbuf from MATLAB arrays */
    gridid = (int32) haGetNonNegativeDoubleScalar(prhs[2], "Grid identifier");
    attrname = haGetString(prhs[3], "Attribute name");

    status = GDattrinfo(gridid, attrname, &numbertype, &count);
    
    if (status != FAIL)
    {
        /* Allocate space for the data to be read */
        datbuf = haMakeHDFDataBuffer(count, numbertype);

        /* Call HDF-EOS library function, and output result */
        status = GDreadattr(gridid, attrname, datbuf);

    }

    if (status != FAIL)
    {
        dims[0] = 1;
        dims[1] = count;
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
    if (ok_to_free && (datbuf != NULL)) {
        mxFree(datbuf);
    }
}

/*
 * hdfGDreadfield
 * 
 * Purpose: Gateway to the HDF-EOS Library function GDreadfield
 *          Reads data from a grid field.
 *
 * MATLAB usage:
 *          [buffer,status] = hd('GD', 'readfield', gridid, ...
 *                               fieldname, start, stride, edge)
 *
 * Inputs:  gridid      - Grid identifier
 *          fieldname   - Name of field
 *          start       - Array specifying the starting location within
 *                        each dimension
 *          stride      - Array speficying the number of values to skip
 *                        along each dimension
 *          edge        - Array specifying the number of values to read 
 *                        along each dimension
 *
 * Outputs: buffer      - Values read from the field
 *          status      - 0 if succeeded, -1 if failed.
 * 
 * Returns: none
 */
static
void hdfGDreadfield(int nlhs,
                       mxArray *plhs[],
                       int nrhs,
                       const mxArray *prhs[])
{
    int32 gridid;
    char *fieldname = NULL;
    int32 start[MAX_VAR_DIMS];
    int32 stride[MAX_VAR_DIMS];
    int32 edge[MAX_VAR_DIMS];
    VOIDP buffer = NULL;
    int bufsize;
    intn status;

    int32 numbertype;
    int32 rank;
    int32 dims[MAX_VAR_DIMS];
    int matlabdims[MAX_VAR_DIMS];
    int i;
    bool ok_to_free = true;
    
    /* Argument checking */
    haNarginChk(7, 7, nrhs);
    haNargoutChk(0, 2, nlhs);
    
    /* Get data from MATLAB arrays */
    gridid = (int32) haGetNonNegativeDoubleScalar(prhs[2], "Grid identifier");
    fieldname = haGetString(prhs[3], "Field name");

    /* Get dimensions for the field */
    status = GDfieldinfo(gridid, fieldname, &rank, dims, 
                         &numbertype, NULL);
    
    if (status != FAIL)
    {
        /* Get the START */
        if (mxIsEmpty(prhs[4])) { /* use default */
            for (i=0; i<rank; i++)    
                start[i] = 0;
        }
        else {
            haGetIntegerVector(prhs[4], rank, "Start", &start[0]);
        }

        /* Get the STRIDE */
        if (mxIsEmpty(prhs[5])) {
            for (i=0; i<rank; i++)  
                stride[i] = 1;    
        }
        else {   
            haGetIntegerVector(prhs[5], rank, "Stride", &stride[0]);
        }

        /* Get the EDGE */
        if (mxIsEmpty(prhs[6])) {
            for (i=0; i<rank; i++) 
                edge[i] = (dims[i] - start[i]) / stride[i];
        }
        else {
            haGetIntegerVector(prhs[6], rank, "Edge", &edge[0]);
        
            /* Check to make sure that the user doesn't ask 
             * for more data than there is in the field.    */
            for (i=0; i<rank; i++)  {
                if (edge[i] > ((dims[i] - start[i]) / stride[i]))
                    mexErrMsgTxt("The EDGE vector specified a larger data "
                                 "dimension than exists in file.");
            }
        }
    
        /* Allocate the buffer */
        bufsize = 1;
        for (i=0; i<rank; i++)  {
            bufsize *= edge[i];
        }
        buffer = haMakeHDFDataBuffer(bufsize, numbertype);
    
        /* Call HDF-EOS library function */
        status = GDreadfield(gridid, fieldname, start, stride, edge, buffer);

        if (status != FAIL)
        {
            /* flip the size vector */
            if (rank==0) {
                matlabdims[0] = 1;
                matlabdims[1] = 1;
                rank = 2;
            }
            else if (rank == 1) {
                matlabdims[0] = edge[0];
                matlabdims[1] = 1;
                rank = 2;
            }
            else {
                for (i=0; i<rank; i++) {
                    matlabdims[i] = edge[rank-i-1];
                }
            }
            
            plhs[0] = haMakeArrayFromHDFDataBuffer(rank, matlabdims, 
                                                   numbertype, buffer, 
                                                   &ok_to_free);
        }
    }

    if (status == FAIL)
    {
        plhs[0] = EMPTY;
    }
    
    if (nlhs > 1) {
        plhs[1] = haCreateDoubleScalar((double) status);
    }

    /* Clean up */
    if (fieldname != NULL)
    {
        mxFree(fieldname);
    }
    if (ok_to_free && (buffer != NULL)) {
        mxFree(buffer);
    }
}

/*
 * hdfGDreadtile
 *
 * Purpose: gateway to GDreadtile()
 *          Reads from tile within field
 *
 * MATLAB usage:
 * [buffer,status] = hdf('GD','readtile',gridid,fieldname,tilecoords)
 *                   buffer returned as column
 */
static void hdfGDreadtile(int nlhs,
                             mxArray *plhs[],
                             int nrhs,
                             const mxArray *prhs[])
{
    int32 gridid;
    char *fieldname = NULL;
    int32 *tilecoords;
    int32 *tiledims_ptr = NULL;
    double *real_ptr;
    VOIDP buffer = NULL;
    intn status;
    int32 numbertype;
    int32 tilecode;
    int32 tilerank;
    int32 fieldrank;
    int32 dims[MAX_VAR_DIMS];
    bool ok2free = true;
    int num_elements;
    int k;

    haNarginChk(5, 5, nrhs);
    haNargoutChk(0, 2, nlhs);
    
    gridid = (int32) haGetNonNegativeDoubleScalar(prhs[2],"Grid identifier");
    fieldname = haGetString(prhs[3],"Fieldname");

    /* How many elements are in each tile? */
    status = GDtileinfo(gridid,fieldname,&tilecode,&tilerank,NULL);
    if (status != FAIL)
        {    
            if (!mxIsDouble(prhs[4]) ||
                (mxGetNumberOfElements(prhs[4]) != tilerank))
                {
                    mexErrMsgTxt("Length of Tilecoords must be a double vector with a length equal to number of field dimensions.");
                }
            tilecoords = mxCalloc(tilerank, sizeof(int32));
            real_ptr = mxGetPr(prhs[4]);
            for (k = 0; k < tilerank; k++)
                {
                    tilecoords[k] = (int32) real_ptr[k];
                }
            tiledims_ptr = (int32 *) mxCalloc(tilerank, sizeof(*tiledims_ptr));
            status = GDtileinfo(gridid,fieldname,&tilecode,&tilerank,tiledims_ptr);
            if (status != FAIL)
                {
                    num_elements = 1;
                    for (k = 0; k < tilerank; k++)
                        {
                            num_elements *= tiledims_ptr[k];
                        }
                }
        }
    
    /* What is the number type of the field? */
    if (status != FAIL)
    {
        status = GDfieldinfo(gridid, fieldname, &fieldrank, dims, 
                             &numbertype, NULL);
    }
    
    /* Allocate data buffer and get data */
    if (status != FAIL)
    {
        buffer = haMakeHDFDataBuffer(num_elements, numbertype);
        status = GDreadtile(gridid,fieldname,tilecoords,buffer);
    }

    if (status != FAIL)
    {
        int ndims = 2;
        int siz[2];
        siz[0] = num_elements;
        siz[1] = 1;
        plhs[0] = haMakeArrayFromHDFDataBuffer(ndims,siz,
                                               numbertype, buffer,
                                               &ok2free);
    }
    else
    {
        plhs[0] = EMPTY;
    }

    if (nlhs > 1)
    {
        plhs[1] = haCreateDoubleScalar((double) status);
    }

    if (ok2free && (buffer != NULL))
    {
        mxFree(buffer);
    }
    if (fieldname != NULL)
    {
        mxFree(fieldname);
    }
    if (tiledims_ptr != NULL)
    {
        mxFree(tiledims_ptr);
    }
}

/*
 * hdfGDregioninfo
 * 
 * Purpose: Gateway to the HDF-EOS Library function GDregioninfo
 *          Retrieves information about the subsetted region.
 *
 * MATLAB usage:
 *          [ntype, rank, dims, size, upleft, lowright, status] = ...
 *               hdf('GD', 'regioninfo', gridid, regionid, fieldname);
 *
 * Inputs:  gridid      - Grid identifier
 *          regionid    - Region identifier
 *          fieldname   - field to subset
 *
 * Outputs: ntype       - number type of field
 *          rank        - rank of field
 *          dims        - dimensions of subset region
 *          size        - Size in bytes of subset region
 *          upleft      - upper left point of subset region
 *          lowright    - lower right of subset region
 *          status      - 0 if succeed, -1 if fail
 * 
 * Retuns:  none
 */
static
void hdfGDregioninfo(int nlhs,
                        mxArray *plhs[],
                        int nrhs,
                        const mxArray *prhs[])
{
    int32 gridid;
    int32 regionid;
    char *fieldname = NULL;
    int32 ntype;
    int32 rank;
    int32 dims[MAX_VAR_DIMS];
    int32 size;
    intn status;
    double *real_ptr;
    double upleft[2], lowright[2];
    
    int dimsdims[2] = {0, 0};
    
    /* Argument checking */
    haNarginChk(5, 5, nrhs);
    haNargoutChk(0, 7, nlhs);
    
    /* Get data from MATLAB arrays */
    gridid = (int32) haGetNonNegativeDoubleScalar(prhs[2], "Grid identifier");
    regionid = (int32) haGetNonNegativeDoubleScalar(prhs[3], "Region identifier");
    fieldname = haGetString(prhs[4], "Field name");
    
    /* Call HDF-EOS library function, and output result */
    status = GDregioninfo(gridid, regionid, fieldname, &ntype, 
                          &rank, dims, &size, upleft, lowright);

    if (status != FAIL) {
        plhs[0] = mxCreateString(haGetNumberTypeString(ntype));
    } 
    else {
        plhs[0] = EMPTY;
    }
    
    if (nlhs > 1) {
        if (status != FAIL) {
            plhs[1] = haCreateDoubleScalar((double) rank); 
        }
        else {
            plhs[1] = EMPTY;
        }
    }
    
    if (nlhs > 2) {
        if (status != FAIL) {
            dimsdims[0] = 1;
            dimsdims[1] = rank;
            plhs[2] = CreateDoubleMxArrayFromINT32Array(dims, 2, dimsdims);
        }
        else {
            plhs[2] = EMPTY;
        }
    }
    
    if (nlhs > 3) {
        if (status != FAIL) {
            plhs[3] = haCreateDoubleScalar((double) size); 
        }
        else {
            plhs[3] = EMPTY;
        }
    }

    if (nlhs > 4) 
    {
        if (status != FAIL)
        {
            plhs[4] = mxCreateDoubleMatrix(1, 2, mxREAL);
            real_ptr = mxGetPr(plhs[4]);
            real_ptr[0] = upleft[0];
            real_ptr[1] = upleft[1];
        }
        else
        {
            plhs[4] = EMPTY;
        }
    }
    
    if (nlhs > 5) 
    {
        if (status != FAIL)
        {
            plhs[5] = mxCreateDoubleMatrix(1, 2, mxREAL);
            real_ptr = mxGetPr(plhs[5]);
            real_ptr[0] = lowright[0];
            real_ptr[1] = lowright[1];
        }
        else
        {
            plhs[5] = EMPTY;
        }
    }
    
    if (nlhs > 6) 
    {
        plhs[6] = haCreateDoubleScalar((double) status); 
    }

    /* Clean up */
    if (fieldname != NULL)
    {
        mxFree(fieldname);
    }
}

/*
 * hdfGDsetfillvalue
 * 
 * Purpose: Gateway to the HDF-EOS Library function GDsetfillvalue
 *          Sets fill value for the specified field.
 *
 * MATLAB usage:
 *          status = hd('GD', 'setfillvalue', gridid, fieldname, fillvalue)
 *
 * Inputs:  gridid      - Grid identifier
 *          fieldname   - field name
 *          fillvalue   - fill value to use
 *          
 * Outputs: status      - 0 if succeeded, -1 if failed.
 * 
 * Returns: none
 */
static
void hdfGDsetfillvalue(int nlhs,
                          mxArray *plhs[],
                          int nrhs,
                          const mxArray *prhs[])
{
    int32 gridid;
    char *fieldname = NULL;
    void *fillvalue = NULL;
    intn status;

    int32 rank;
    int32 dims[MAX_VAR_DIMS];
    int32 numbertype;
    bool free_fillvalue = false;
    
    /* Argument checking */
    haNarginChk(5, 5, nrhs);
    haNargoutChk(0, 1, nlhs);
    

    /* Get data from MATLAB arrays */
    gridid = (int32) haGetNonNegativeDoubleScalar(prhs[2], "Grid identifier");
    fieldname = haGetString(prhs[3], "Field name");

    /* Call fieldinfo to get the data type of the field */
    status = GDfieldinfo(gridid, fieldname, &rank, dims,
                         &numbertype, NULL);

    if (status != FAIL)
    {
        if (haGetClassIDFromDataType(numbertype) != mxGetClassID(prhs[4])) {
            mexErrMsgTxt("The data type of the fill value must match the "
                         "data type of the field.");
        }
        
        if (mxGetNumberOfElements(prhs[4]) != 1)
        {
            mexErrMsgTxt("Fill value must be a scalar.");
        }
        
        if (mxGetClassID(prhs[4]) == mxCHAR_CLASS) {
            fillvalue = haMakeHDFDataBufferFromCharArray(prhs[4], numbertype);
            free_fillvalue = true;
        }
        else {
            fillvalue = mxGetData(prhs[4]);
        }
    }
    

    /* Call HDF-EOS library function, and output result */
    if (status != FAIL)
    {
        status = GDsetfillvalue(gridid, fieldname, fillvalue);
    }
    
    plhs[0] = haCreateDoubleScalar((double) status);

    /* Clean up */
    if (fieldname != NULL)
    {
        mxFree(fieldname);
    }
    if (free_fillvalue) {
        mxFree(fillvalue);
    }
}

/*
 * hdfGDsettilecache
 *
 * Purpose: gateway to GDsettilecache()
 *          Sets tile cache parameters
 *
 * MATLAB usage:
 * status = hdf('GD','settilecache',gridid,fieldname,maxcache)
 */
static void hdfGDsettilecache(int nlhs,
                                mxArray *plhs[],
                                int nrhs,
                                const mxArray *prhs[])
{
    int32 gridid;
    char *fieldname = NULL;
    int32 maxcache;
    int32 cachecode = 0;  /* 0 is only currently supported value */
    intn status;
    
    haNarginChk(5, 5, nrhs);
    haNargoutChk(0, 1, nlhs);
    
    gridid = (int32) haGetNonNegativeDoubleScalar(prhs[2],"Grid identifier");
    fieldname = haGetString(prhs[3],"Field name");
    maxcache = (int32) haGetDoubleScalar(prhs[4],"Maxcache");
    
    status = GDsettilecache(gridid,fieldname,maxcache,cachecode);
    
    plhs[0] = haCreateDoubleScalar((double) status);
}

/*
 * hdfGDsettilecomp
 * 
 * Purpose: Gateway to the HDF-EOS Library function GDsettilecomp
 *          Sets tiling and compression parameters for a field that 
 *          has fill values
 * 
 * MATLAB usage: 
 *  status = hdf('GD','settilecomp',...
 *               gridid,fieldname,tiledims,compcode,compparm)
 * 
 * Inputs: gridid         - Grid ID
 *         fieldname      - Fieldname
 *         tiledims       - Tile dimensions
 *         compcode       - HDF compression code
 *         compparm       - Compression parameters
 * 
 * Outputs: status        - 0 for success, 1 for failure
 * 
 * Returns: none
 */
static
void hdfGDsettilecomp(int nlhs,
                      mxArray *plhs[],
                      int nrhs,
                      const mxArray *prhs[])
{

    int32 gridid;
    int32 tilerank;
    int32 compcode;
    int32 *tiledims_ptr = NULL;
    intn compparm[NUM_EOS_COMP_PARMS];
    intn status;
    
    int32 field_rank;
    int32 field_dims[MAX_VAR_DIMS];
    int32 numbertype;

    double *real_ptr;
    int k;
    char *fieldname = NULL;

    /* Argument checking */
    haNarginChk(7,7,nrhs);
    haNargoutChk(1,1,nlhs);

    /* Get data from MATLAB arrays */
    gridid = (int32) haGetNonNegativeDoubleScalar(prhs[2], "Grid identifier");
    fieldname = haGetString(prhs[3], "Fieldname");
    if (!mxIsDouble(prhs[4]))
    {
        mexErrMsgTxt("TILEDIMS must be double.");
    }
    real_ptr = mxGetPr(prhs[4]);
    tilerank = mxGetNumberOfElements(prhs[4]);
    tiledims_ptr = (int32 *) mxCalloc(tilerank, sizeof(int32));
    for (k = 0; k < tilerank; k++)
    {
        tiledims_ptr[k] = (int32) real_ptr[k];
    }
    compcode = haGetCompType(prhs[5]);
    haGetEOSCompressionParameters(prhs[6],compparm);

    /* Make sure tile rank and field rank are equal and
       the tile dimensions are an integral divisor of the 
       corresponding field dimensions 
    */
    status = GDfieldinfo(gridid, fieldname, &field_rank, field_dims,
                         &numbertype, NULL);
    if(field_rank != tilerank)
        {  
            if(fieldname != NULL)
                {
                    mxFree(fieldname);
                }
            if(tiledims_ptr != NULL)
                {
                    mxFree(tiledims_ptr);
                }
            mexErrMsgTxt("Number of tile dimensions must be equal to the number of field dimensions.");
        }
    for(k = 0; k<tilerank;k++)
        {
            if(field_dims[k]%tiledims_ptr[k])
                {
                    if(fieldname != NULL)
                        {
                            mxFree(fieldname);
                        }
                    if(tiledims_ptr != NULL)
                        {
                            mxFree(tiledims_ptr);
                        }
                    mexErrMsgTxt("Tile dimensions must be an integral divisor of the field dimensions");
                }
        }
    /* Call library function and return result */
    status = GDsettilecomp(gridid,fieldname,tilerank,tiledims_ptr,compcode,compparm);
    plhs[0] = haCreateDoubleScalar(status);

    /* Clean up */
    if(fieldname != NULL)
        {
            mxFree(fieldname);
        }
    if(tiledims_ptr != NULL)
        {
            mxFree(tiledims_ptr);
        }
}

/*
 * hdfGDtileinfo
 *
 * Purpose: gateway to GDtileinfo()
 *          Retrieves tiling info about a field
 *
 * MATLAB usage:
 * [tilecode,tiledims,tilerank,status] = hdf('GD','tileinfo',gridid,fieldname)
 */
static void hdfGDtileinfo(int nlhs,
                             mxArray *plhs[],
                             int nrhs,
                             const mxArray *prhs[])
{
    int32 gridid;
    char *fieldname = NULL;
    int32 tilecode;
    /*
     * initialize tilerank here because GDtileinfo doesn't set
     * it if tilecode is NO_TILE.  -sle, June 1998
     */
    int32 tilerank = 0;
    int32 *tiledims_ptr = NULL;
    intn status;
    double *real_ptr;
    int k;
    
    haNarginChk(4, 4, nrhs);
    haNargoutChk(0, 4, nlhs);
    
    gridid = (int32) haGetNonNegativeDoubleScalar(prhs[2], "Grid identifier");
    fieldname = haGetString(prhs[3], "Fieldname");
    
    status = GDtileinfo(gridid,fieldname,&tilecode,&tilerank,NULL);
    
    if (status != FAIL)
    {
        tiledims_ptr = (int32 *) mxCalloc(tilerank, sizeof(*tiledims_ptr));
        status = GDtileinfo(gridid,fieldname,&tilecode,&tilerank,tiledims_ptr);
    }
    
    if (status != FAIL)
    {
        plhs[0] = GetTileStringFromCode(tilecode);
    }
    else
    {
        plhs[0] = EMPTY;
    }

    if (nlhs > 1)
    {
        if (status != FAIL)
        {
            plhs[1] = mxCreateDoubleMatrix(1, tilerank, mxREAL);
            real_ptr = mxGetPr(plhs[1]);
            for (k = 0; k < tilerank; k++)
            {
                real_ptr[k] = (double) tiledims_ptr[k];
            }
        }
        else
        {
            plhs[1] = EMPTY;
        }
    }

    if (nlhs > 2)
    {
        if (status != FAIL)
        {
            plhs[2] = haCreateDoubleScalar((double) tilerank);
        }
        else
        {
            plhs[2] = EMPTY;
        }
    }
    
    if (nlhs > 3)
    {
        plhs[3] = haCreateDoubleScalar((double) status);
    }
    
    if (fieldname != NULL)
    {
        mxFree(fieldname);
    }
    if (tiledims_ptr != NULL)
    {
        mxFree(tiledims_ptr);
    }
}

/*
 * hdfGDwriteattr
 * 
 * Purpose: Gateway to the HDF-EOS Library function GDwriteattr
 *          Writes/Updates attributes in a grid
 *
 * MATLAB usage:
 *          status = hd('GD', 'writeattr', gridid, attrname, databuf)
 *
 * Inputs:  gridid      - Grid identifier
 *          attrname    - Name of attribute
 *          databuf     - Attribute values to be written to the field
 *
 * Outputs: status      - 0 if succeeded, -1 if failed.
 * 
 * Returns: none
 */
static
void hdfGDwriteattr(int nlhs,
                       mxArray *plhs[],
                       int nrhs,
                       const mxArray *prhs[])
{
    int32 gridid;
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
    
    gridid = (int32) haGetNonNegativeDoubleScalar(prhs[2], "Grid identifier");
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
    status = GDwriteattr(gridid, attrname, ntype, count, datbuf);
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
 * hdfGDwritefield
 * 
 * Purpose: Gateway to the HDF-EOS Library function GDwritefield
 *          Write data to a grid field.
 *
 * MATLAB usage:
 *          status = hd('GD', 'writefield', gridid, fieldname, ...
 *                      start, stride, edge, data)
 *
 * Inputs:  gridid      - Grid identifier
 *          fieldname   - Name of field
 *          start       - Array specifying the starting location within
 *                        each dimension
 *          stride      - Array speficying the number of values to skip
 *                        along each dimension
 *          edge        - Array specifying the number of values to write 
 *                        along each dimension
 *          data        - Values to be written to the field
 *
 * Outputs: status      - 0 if succeeded, -1 if failed.
 * 
 * Returns: none
 */
static
void hdfGDwritefield(int nlhs,
                        mxArray *plhs[],
                        int nrhs,
                        const mxArray *prhs[])
{
    int32 gridid;
    char *fieldname = NULL;
    int32 start[MAX_VAR_DIMS];
    int32 stride[MAX_VAR_DIMS];
    int32 edge[MAX_VAR_DIMS];
    int32 *pstart, *pstride, *pedge;
    VOIDP data;
    intn status;
    int32 rank;
    int32 ntype;
    int32 dims[MAX_VAR_DIMS];
    int size[MAX_VAR_DIMS];
    int i;
    bool free_buffer = false;

    /* Argument checking */
    haNarginChk(8, 8, nrhs);
    haNargoutChk(0, 1, nlhs);

    /* Get data from MATLAB arrays */
    gridid = (int32) haGetNonNegativeDoubleScalar(prhs[2], "Grid identifier");
    fieldname = haGetString(prhs[3], "Field name");
    
    status = GDfieldinfo(gridid, fieldname, &rank, dims, &ntype, NULL);

    if (status != FAIL)
    {
        pstart = pstride = pedge = NULL; /* use defaults */

        if (!haIsNULL(prhs[4])) {
            pstart = &start[0];
            haGetIntegerVector(prhs[4], rank, "Start", pstart);
        }  
        if (!haIsNULL(prhs[5])) {
            pstride = &stride[0];
            haGetIntegerVector(prhs[5], rank, "Stride", pstride);
        }
        if (!haIsNULL(prhs[6])) {
            pedge = &edge[0];
            haGetIntegerVector(prhs[6], rank, "Edge", pedge);
        }
 
        /* Set up a size vector to check the array size of the input data */
        if (pedge != NULL) {
            for (i=0; i<rank; i++) 
                size[rank-i-1] = edge[i];
        }
        else {
            /* give start and stride defaults if they need 'em */
            if (pstart == NULL)  
                for (i=0; i<rank; i++) 
                    start[i] = 0;

            if (pstride == NULL)
                for (i=0; i<rank; i++)
                    stride[i] = 1;
                
            for (i=0; i<rank; i++) {
                size[rank-i-1] = (dims[i]-start[i]) / stride[i];
            }
        }
        
        /* Check to see that the number of elements in the input array is 
         * correct.  Also make sure that the data type is correct */
        if (!haSizeMatches(prhs[7], rank, size) || 
            (haGetClassIDFromDataType(ntype) != mxGetClassID(prhs[7]))) {
            mexErrMsgTxt("Data array size must match edge specification and "
                         "datatype must match dataset");
        }
    
        if (mxGetClassID(prhs[7]) == mxCHAR_CLASS) {
            data = haMakeHDFDataBufferFromCharArray(prhs[7], ntype);
            free_buffer = true;
        }
        else {
            data = mxGetData(prhs[7]);
        }

        /* Call HDF-EOS library function, and output result */
        status = GDwritefield(gridid, fieldname, pstart, pstride, pedge, data);
    }
    
    plhs[0] = haCreateDoubleScalar((double) status);

    /* Clean up */
    if (fieldname != NULL)
    {
        mxFree(fieldname);
    }
    if (free_buffer) {
        mxFree(data);
    }
}

/*
 * hdfGDwritefieldmeta
 *
 * Purpose: gateway to GDwritefieldmeta()
 *          Writes field metadata for an existing grid field not defined
 *          with the Grid API
 *
 * MATLAB usage:
 * status = hdf('GD','writefieldmeta',gridid,fieldname,dimlist,numbertype)
 */
static void hdfGDwritefieldmeta(int nlhs,
                                   mxArray *plhs[],
                                   int nrhs,
                                   const mxArray *prhs[])
{
    int32 gridid;
    char *fieldname = NULL;
    char *dimlist = NULL;
    int32 numbertype;
    intn status;

    haNarginChk(6, 6, nrhs);
    haNargoutChk(0, 1, nlhs);
        
    gridid = (int32) haGetNonNegativeDoubleScalar(prhs[2], "Grid identifier");
    fieldname = haGetString(prhs[3], "Field name");
    dimlist = haGetString(prhs[4], "Dimension list");
    numbertype = haGetDataType(prhs[5]);
    
    status = GDwritefieldmeta(gridid, fieldname, dimlist, numbertype);
    plhs[0] = haCreateDoubleScalar((double) status);

    if (fieldname != NULL)
    {
        mxFree((void *) fieldname);
    }
    if (dimlist != NULL)
    {
        mxFree((void *) dimlist);
    }
}

/*
 * hdfGDwritetile
 *
 * Purpose: gateway to GDwritetile()
 *          Writes to tile within a field
 *
 * MATLAB usage:
 * status = hdf('GD','writetile',gridid,fieldname,tilecoords,data)
 */
static void hdfGDwritetile(int nlhs,
                              mxArray *plhs[],
                              int nrhs,
                              const mxArray *prhs[])
{
    int32 gridid;
    char *fieldname = NULL;
    VOIDP data;
    intn status;
    int32 tilecode;
    int32 tilerank;
    int32 *tiledims_ptr = NULL;
    int32 fieldrank;
    int32 dims[MAX_VAR_DIMS];
    int32 numbertype;
    int32 *tilecoords = NULL;
    double *real_ptr;
    int num_elements;
    int k;
    bool ok2free = false;
    
    haNarginChk(6, 6, nrhs);
    haNargoutChk(0, 1, nlhs);

    gridid = (int32) haGetNonNegativeDoubleScalar(prhs[2],"Grid identifier");
    fieldname = haGetString(prhs[3],"Fieldname");
    
    /* Get tile info */
    status = GDtileinfo(gridid,fieldname,&tilecode,&tilerank,NULL);
    if ((status != FAIL) & (tilecode == HDFE_NOTILE))
    {
        mexErrMsgTxt("Cannot write tile to untiled field.");
    }
    
    /* How many elements per tile? */
    if (status != FAIL)
    {
        tiledims_ptr = (int32 *) mxCalloc(tilerank, sizeof(*tiledims_ptr));
        status = GDtileinfo(gridid,fieldname,&tilecode,&tilerank,tiledims_ptr);
        if (status != FAIL)
        {
            num_elements = 1;
            for (k = 0; k < tilerank; k++)
            {
                num_elements *= tiledims_ptr[k];
            }
        }
    }

    if (!mxIsDouble(prhs[4]))
    {
        mexErrMsgTxt("Tilecoords must be double.");
    }
    if (mxGetNumberOfElements(prhs[4]) != tilerank)
    {
        mexErrMsgTxt("Length of tilecoords not equal to tile rank.");
    }
    
    tilecoords = (int32 *) mxCalloc(tilerank, sizeof(*tilecoords));
    real_ptr = mxGetPr(prhs[4]);
    for (k = 0; k < tilerank; k++)
    {
        tilecoords[k] = (int32) real_ptr[k];
    }
    
    /* What is the number type of the field? */
    if (status != FAIL)
    {
        status = GDfieldinfo(gridid, fieldname, &fieldrank, dims, 
                             &numbertype, NULL);
    }

    if (haGetClassIDFromDataType(numbertype) != mxGetClassID(prhs[5]))
    {
        mexErrMsgTxt("Datatype must match dataset.");
    }
    
    if (mxGetNumberOfElements(prhs[5]) != num_elements)
    {
        mexErrMsgTxt("Number of data elements does not match tile size.");
    }
    
    if (mxGetClassID(prhs[5]) == mxCHAR_CLASS)
    {
        data = haMakeHDFDataBufferFromCharArray(prhs[5],numbertype);
        ok2free = true;
    }
    else
    {
        data = mxGetData(prhs[5]);
    }
    
    status = GDwritetile(gridid, fieldname, tilecoords, data);
    
    plhs[0] = haCreateDoubleScalar((double) status);
    
    if (ok2free)
    {
        mxFree(data);
    }
    if (fieldname != NULL)
    {
        mxFree(fieldname);
    }
    if (tiledims_ptr != NULL)
    {
        mxFree(tiledims_ptr);
    }
    if (tilecoords != NULL)
    {
        mxFree(tilecoords);
    }
}

/*
 * hdfGD
 *
 * Purpose: Function switchyard for the HDF-EOS GD part of the HDF gateway.
 *
 * Inputs:  nlhs --- number of left-side arguments
 *          plhs --- left-side arguments
 *          nrhs --- number of right-side arguments
 *          prhs --- right-side arguments
 *          functionStr --- string specifying which GD function to call
 * Outputs: none
 * Return:  none
 */
void hdfGD(int nlhs,
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
    } GDFcns[] = {
        {"attach",            hdfGDattach},
        {"attrinfo",          hdfGDattrinfo},
        {"blksomoffset",      hdfGDblkSOMoffset},
        {"close",             hdfGDclose},
        {"compinfo",          hdfGDcompinfo},
        {"create",            hdfGDcreate},
        {"defboxregion",      hdfGDdefboxregion},
        {"defcomp",           hdfGDdefcomp},
        {"defdim",            hdfGDdefdim},
        {"deffield",          hdfGDdeffield},
        {"deforigin",         hdfGDdeforigin},
        {"defpixreg",         hdfGDdefpixreg},
        {"defproj",           hdfGDdefproj},
        {"deftimeperiod",     hdfGDdeftimeperiod},
        {"deftile",           hdfGDdeftile},
        {"defvrtregion",      hdfGDdefvrtregion},
        {"detach",            hdfGDdetach},
        {"diminfo",           hdfGDdiminfo},
        {"dupregion",         hdfGDdupregion},
        {"extractregion",     hdfGDextractregion},
        {"fieldinfo",         hdfGDfieldinfo},
        {"getfillvalue",      hdfGDgetfillvalue},
        {"getpixels",         hdfGDgetpixels},
        {"getpixvalues",      hdfGDgetpixvalues},
        {"gridinfo",          hdfGDgridinfo},
        {"inqattrs",          hdfGDinqattrs},
        {"inqdims",           hdfGDinqdims},
        {"inqfields",         hdfGDinqfields},
        {"inqgrid",           hdfGDinqgrid},
        {"interpolate",       hdfGDinterpolate},
        {"open",              hdfGDopen},
        {"origininfo",        hdfGDorigininfo},
        {"nentries",          hdfGDnentries},
        {"pixreginfo",        hdfGDpixreginfo},
        {"projinfo",          hdfGDprojinfo},
        {"readattr",          hdfGDreadattr},
        {"readfield",         hdfGDreadfield},
        {"readtile",          hdfGDreadtile},
        {"regioninfo",        hdfGDregioninfo},
        {"setfillvalue",      hdfGDsetfillvalue},
        {"settilecache",      hdfGDsettilecache},
        {"settilecomp",       hdfGDsettilecomp},
        {"tileinfo",          hdfGDtileinfo},
        {"writeattr",         hdfGDwriteattr},
        {"writefield",        hdfGDwritefield},
        {"writefieldmeta",    hdfGDwritefieldmeta},
        {"writetile",         hdfGDwritetile}
    };
    int numFcns = sizeof(GDFcns) / sizeof(*GDFcns);
    int i;
    bool found = false;

    for (i = 0; i < numFcns; i++)
    {
        if (strcmp(functionStr,GDFcns[i].name)==0)
        {
            (*(GDFcns[i].func))(nlhs, plhs, nrhs, prhs);
            found = true;
            break;
        }
    }

    if (! found)
        mexErrMsgTxt("Unknown HDF-EOS GD interface function.");
}
