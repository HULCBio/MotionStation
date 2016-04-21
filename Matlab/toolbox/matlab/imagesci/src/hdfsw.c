/* Copyright 1984-2002 The MathWorks, Inc.  */

/*
 * hdfsw.c --- support file for HDF.MEX
 *
 * This module supports the HDF-EOS SW interface.  The only public
 * function is hdfSW(), which is called by mexFunction().
 * hdfSW looks at the second input argument to determine which
 * private function should get control.
 *
 */


/* $Revision: 1.1.6.1 $  $Date: 2003/12/13 03:02:21 $ */

static char rcsid[] = "$Id: hdfsw.c,v 1.1.6.1 2003/12/13 03:02:21 batserve Exp $";

#include <string.h>
#include <math.h>

/* Main HDF library header file */
#include "hdf.h"

/* MATLAB API header file */
#include "mex.h"

/* HDFMEX utility functions */
#include "hdfutils.h"

/* Multifile scientific dataset interface header file */
#include "mfhdf.h"

/* HDF-EOS header file */
#include "HdfEosDef.h"

#define BUFLEN 128

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
        mexErrMsgTxt("Invalid compression code.");

    return(compstring);
}


/*
 * GetEntryCode
 * 
 * Purpose: Get the entry code from a MATLAB array
 *
 * Inputs:  entrycodeArray - mxArray containing the code
 *    
 * Outputs: none
 * 
 * Returns: Entry Code
 */
static
int32 GetEntryCode(const mxArray *entrycodeArray) 
{
    int32 entrycode;
    char string[BUFLEN];
    
    if (!mxIsChar(entrycodeArray) || mxIsEmpty(entrycodeArray))
        mexErrMsgTxt("Invalid entry code, must be 'NENTDIM', "
                     "'NENTMAP', 'NENTIMAP', 'NENTGFLD',"
                     "or 'NENTDFLD'.");
    
    mxGetString(entrycodeArray, string, BUFLEN);
        
    if (!haStrcmpi(string, "HDFE_NENTDIM") || 
        !haStrcmpi(string, "NENTDIM"))
        entrycode = HDFE_NENTDIM;
    else if (!haStrcmpi(string, "HDFE_NENTMAP") ||
             !haStrcmpi(string, "NENTMAP"))
        entrycode = HDFE_NENTMAP;
    else if (!haStrcmpi(string, "HDFE_NENTIMAP") ||
             !haStrcmpi(string, "NENTIMAP"))
        entrycode = HDFE_NENTIMAP;
    else if (!haStrcmpi(string, "HDFE_NENTGFLD") ||
             !haStrcmpi(string, "NENTGFLD"))
        entrycode = HDFE_NENTGFLD;
    else if (!haStrcmpi(string, "HDFE_NENTDFLD") ||
             !haStrcmpi(string, "NENTDFLD"))
        entrycode = HDFE_NENTDFLD;
    else
        mexErrMsgTxt("Invalid entry code, must be 'NENTDIM', "
                     "'NENTMAP', 'NENTIMAP', 'NENTGFLD',"
                     "or 'NENTDFLD'.");
    return(entrycode);
}



/*
 * GetCrossTrackInclusionMode
 * 
 * Purpose: Get the cross track inclusion mode from a MATLAB array
 *
 * Inputs:  modestr - mxArray containing the code
 *    
 * Outputs: none
 * 
 * Returns: mode
 */
static
int32 GetCrossTrackInclusionMode(const mxArray *modestr) 
{
    int32 mode;
    char string[BUFLEN];
    
    if (!mxIsChar(modestr) || mxIsEmpty(modestr))
        mexErrMsgTxt("Invalid mode, must be 'MIDPOINT', "
                     "'ENDPOINT', or 'ANYPOINT'.");
    
    mxGetString(modestr, string, BUFLEN);
        
    if (!haStrcmpi(string, "HDFE_MIDPOINT") ||
        !haStrcmpi(string, "MIDPOINT"))
        mode = HDFE_MIDPOINT;
    else if (!haStrcmpi(string, "HDFE_ENDPOINT") ||
             !haStrcmpi(string, "ENDPOINT"))
        mode = HDFE_ENDPOINT;
    else if (!haStrcmpi(string, "HDFE_ANYPOINT") ||
             !haStrcmpi(string, "ANYPOINT"))
        mode = HDFE_ANYPOINT;
    else
        mexErrMsgTxt("Invalid mode, must be 'MIDPOINT', "
                     "'ENDPOINT', or 'ANYPOINT'.");
    return(mode);
}



/*
 * GetExternalMode
 * 
 * Purpose: Get the external geolocation mode from a MATLAB array
 *
 * Inputs:  modestr - mxArray containing the mode
 *    
 * Outputs: none
 * 
 * Returns: mode
 */
static
int32 GetExternalMode(const mxArray *modestr) 
{
    int32 mode;
    char string[BUFLEN];
    
    if (!mxIsChar(modestr) || mxIsEmpty(modestr))
        mexErrMsgTxt("Invalid mode, must be 'EXTERNAL', or 'INTERNAL'.");
    
    mxGetString(modestr, string, BUFLEN);
        
    if (!haStrcmpi(string, "HDFE_EXTERNAL") ||
        !haStrcmpi(string, "EXTERNAL"))
        mode = HDFE_EXTERNAL;
    else if (!haStrcmpi(string, "HDFE_INTERNAL") ||
        !haStrcmpi(string, "INTERNAL"))
        mode = HDFE_INTERNAL;
    else
        mexErrMsgTxt("Invalid mode, must be 'EXTERNAL', or 'INTERNAL'.");
    return(mode);
}



/*
 * hdfSWopen
 * 
 * Purpose: Gateway to the HDF-EOS Library function SWopen
 *          Opens or creates an HDF file in order to create, read
 *          or write a swath
 *
 * MATLAB usage:
 *          fid = hdf('SW', 'open', filename, access)
 *
 * Inputs:  filename - Name of the HDF file
 *          access   - The access mode for the HDF file
 *    
 * Outputs: fid      - File identifier
 * 
 * Returns: none
 */
static
void hdfSWopen(int nlhs,
                  mxArray *plhs[],
                  int nrhs,
                  const mxArray *prhs[])
{
    intn access;
    char *filename;
    int32 fid;
    intn status;
    
    /* Argument checking */
    haNarginChk(4, 4, nrhs);
    haNargoutChk(0, 1, nlhs);
    
    /* Get data from MATLAB arrays */
    filename = haGetString(prhs[2], "Filename");
    access = haGetAccessMode(prhs[3]);
    
    /* Call HDF-EOS library function, and output result */
    fid = SWopen(filename, access);
    if (fid != FAIL) {
        status = haAddIDToList(fid, SWFile_ID_List);
        if (status == FAIL) {
            SWclose(fid);
            fid = FAIL;
        }
    }
    plhs[0] = haCreateDoubleScalar((double) fid);

    /* Clean up */
    mxFree(filename);
}


/*
 * hdfSWcreate
 * 
 * Purpose: Gateway to the HDF-EOS Library function SWcreate
 *          Create a swath within an HDF file.
 *
 * MATLAB usage:
 *          swathid = hdf('SW', 'create', fid, swathname)
 *
 * Inputs:  fid       - File identifier
 *          swathname - Name of swath
 *    
 * Outputs: swathid   - Swath handle
 * 
 * Returns: none
 */
static
void hdfSWcreate(int nlhs,
                  mxArray *plhs[],
                  int nrhs,
                  const mxArray *prhs[])
{
    char *swathname;
    int32 fid;
    int32 swathid;
    intn status;
    
    /* Argument checking */
    haNarginChk(4, 4, nrhs);
    haNargoutChk(0, 1, nlhs);
    
    /* Get data from MATLAB arrays */
    fid = (int32) haGetNonNegativeDoubleScalar(prhs[2], "File identifier");
    swathname = haGetString(prhs[3], "Swath name");
    
    /* Call HDF-EOS library function, and output result */
    swathid = SWcreate(fid, swathname);
    if (swathid != FAIL) {
        status = haAddIDToList(swathid, Swath_ID_List);
        if (status == FAIL) {
            SWdetach(swathid);
            swathid = FAIL;
        }
    }
    
    plhs[0] = haCreateDoubleScalar((double) swathid);

    /* Clean up */
    mxFree(swathname);
}



/*
 * hdfSWattach
 * 
 * Purpose: Gateway to the HDF-EOS Library function SWattach
 *          Attaches to an existing swath within a file
 *
 * MATLAB usage:
 *          swathid = hdf('SW', 'attach', fid, swathname)
 *
 * Inputs:  fid       - File identifier
 *          swathname - Name of swath
 *    
 * Outputs: swathid   - Swath handle
 * 
 * Returns: none
 */
static
void hdfSWattach(int nlhs,
                    mxArray *plhs[],
                    int nrhs,
                    const mxArray *prhs[])
{
    char *swathname;
    int32 fid;
    int32 swathid;
    intn status;
    
    /* Argument checking */
    haNarginChk(4, 4, nrhs);
    haNargoutChk(0, 1, nlhs);
    
    /* Get data from MATLAB arrays */
    fid = (int32) haGetNonNegativeDoubleScalar(prhs[2], "File identifier");
    swathname = haGetString(prhs[3], "Swath name");
    
    /* Call HDF-EOS library function, and output result */
    swathid = SWattach(fid, swathname);
    if (swathid != FAIL) {
        status = haAddIDToList(swathid, Swath_ID_List);
        if (status == FAIL) {
            SWdetach(swathid);
            swathid = FAIL;
        }
    }
    
    plhs[0] = haCreateDoubleScalar((double) swathid);

    /* Clean UP */
    mxFree(swathname);
}


/*
 * hdfSWdetach
 * 
 * Purpose: Gateway to the HDF-EOS Library function SWdetach
 *          Detaches from Swath interface.
 *
 * MATLAB usage:
 *          status = hdf('SW', 'detach', swathid)
 *
 * Inputs:  swathid   - Swath handle
 *    
 * Outputs: status    - 0 if succeeded, -1 if failed.
 * 
 * Returns: none
 */
static
void hdfSWdetach(int nlhs,
                    mxArray *plhs[],
                    int nrhs,
                    const mxArray *prhs[])
{
    int32 swathid;
    int status;
    
    /* Argument checking */
    haNarginChk(3, 3, nrhs);
    haNargoutChk(0, 1, nlhs);
    
    /* Get data from MATLAB arrays */
    swathid = (int32) haGetNonNegativeDoubleScalar(prhs[2], "Swath identifier");
    
    /* Call HDF-EOS library function, and output result */
    status = SWdetach(swathid);
    if (status == SUCCEED)
    {
        haDeleteIDFromList(swathid, Swath_ID_List);
    }
    plhs[0] = haCreateDoubleScalar((double) status);
}


/*
 * hdfSWclose
 * 
 * Purpose: Gateway to the HDF-EOS Library function SWclose
 *          Closes file.
 *
 * MATLAB usage:
 *          status = hdf('SW', 'close', fid)
 *
 * Inputs:  fid       - File identifier
 *    
 * Outputs: status    - 0 if succeeded, -1 if failed.
 * 
 * Returns: none
 */
static
void hdfSWclose(int nlhs,
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
    fid = (int32) haGetNonNegativeDoubleScalar(prhs[2], "File identifier");
    
    /* Call HDF-EOS library function, and output result */
    status = SWclose(fid);
    if (status == SUCCEED)
    {
        haDeleteIDFromList(fid, SWFile_ID_List);
    }
    
    plhs[0] = haCreateDoubleScalar((double) status);
}


/*
 * hdfSWdefdim
 * 
 * Purpose: Gateway to the HDF-EOS Library function SWdefdim
 *          Defines a new dimension within the swath.
 *
 * MATLAB usage:
 *          status = hdf('SW', 'defdim', swathid, fieldname, dim)
 *
 * Inputs:  swathid     - Swath identifier
 *          fieldname   - Name of dimension to be defined
 *          dim         - The size of the dimension
 *
 * Outputs: status      - 0 if succeeded, -1 if failed.
 * 
 * Returns: none
 */
static
void hdfSWdefdim(int nlhs,
                    mxArray *plhs[],
                    int nrhs,
                    const mxArray *prhs[])
{
    int32 swathid;
    char *fieldname;
    int32 dim;
    intn status;
    double ddim;
    
    /* Argument checking */
    haNarginChk(5, 5, nrhs);
    haNargoutChk(0, 1, nlhs);
    
    /* Get data from MATLAB arrays */
    swathid = (int32) haGetNonNegativeDoubleScalar(prhs[2], "Swath identifier");
    fieldname = haGetString(prhs[3], "Field name");

    ddim =  haGetDoubleScalar(prhs[4], "Dimension size");
    if (!mxIsFinite(ddim))
        dim = SD_UNLIMITED;
    else
        dim = (int32) ddim;
        
    
    /* Call HDF-EOS library function, and output result */
    status = SWdefdim(swathid, fieldname, dim);
    plhs[0] = haCreateDoubleScalar((double) status);

    /* Clean up */
    mxFree(fieldname);
}


/*
 * hdfSWdefdimmap
 * 
 * Purpose: Gateway to the HDF-EOS Library function SWdefdimmap
 *          Defines monotonic mapping between the geolocation
 *          dimension with respect to the data dimension.
 *
 * MATLAB usage:
 *          status = hd('SW', 'defdimmap', swathid, geodim, datadim, ...
 *                      offset, increment)
 *
 * Inputs:  swathid     - Swath identifier
 *          geodim      - Geolocation dimension name
 *          datadim     - Data dimension name
 *          offset      - Offset of geolocation dimension wrt data dimesion
 *          increment   - increment of geolocation dimension wrt data dimension
 *
 * Outputs: status      - 0 if succeeded, -1 if failed.
 * 
 * Returns: none
 */
static
void hdfSWdefdimmap(int nlhs,
                       mxArray *plhs[],
                       int nrhs,
                       const mxArray *prhs[])
{
    int32 swathid;
    char *geodim;
    char *datadim;
    int32 offset;
    int32 increment;
    intn status;
    
    /* Argument checking */
    haNarginChk(7, 7, nrhs);
    haNargoutChk(0, 1, nlhs);
    
    /* Get data from MATLAB arrays */
    swathid = (int32) haGetNonNegativeDoubleScalar(prhs[2], "Swath identifier");
    geodim = haGetString(prhs[3], "Geolocation dimension name");
    datadim = haGetString(prhs[4], "Data dimension name");
    offset = (int32) haGetDoubleScalar(prhs[5], "Offset");
    increment = (int32) haGetDoubleScalar(prhs[6], "Increment");
    
    /* Call HDF-EOS library function, and output result */
    status = SWdefdimmap(swathid, geodim, datadim, offset, increment);
    plhs[0] = haCreateDoubleScalar((double) status);

    /* Clean up */
    mxFree(geodim);
    mxFree(datadim);
}


/*
 * hdfSWdefidxmap
 * 
 * Purpose: Gateway to the HDF-EOS Library function SWdefidxmap
 *          Defines non-regular mapping between the geolocation and 
 *          data dimensions.
 *
 * MATLAB usage:
 *          status = hd('SW', 'defidxmap', swathid, geodim, datadim, index)
 *
 * Inputs:  swathid     - Swath identifier
 *          geodim      - Geolocation dimension name
 *          datadim     - Data dimension name
 *          index       - array containing the indices of the data dimension
 *                        to which each geolocation element corresponds.
 *
 * Outputs: status      - 0 if succeeded, -1 if failed.
 * 
 * Returns: none
 */
static
void hdfSWdefidxmap(int nlhs,
                       mxArray *plhs[],
                       int nrhs,
                       const mxArray *prhs[])
{
    int32 swathid;
    char *geodim;
    char *datadim;
    int32 *index;
    intn status;

    int dimsize;
    
    /* Argument checking */
    haNarginChk(6, 6, nrhs);
    haNargoutChk(0, 1, nlhs);
    
    /* Get data from MATLAB arrays */
    swathid = (int32) haGetNonNegativeDoubleScalar(prhs[2], "Swath identifier");
    geodim = haGetString(prhs[3], "Geolocation dimension name");
    datadim = haGetString(prhs[4], "Data dimension name");
    
    dimsize = SWdiminfo(swathid, geodim);
    index = (int32 *) mxCalloc(dimsize, sizeof(int32));
    haGetIntegerVector(prhs[5],dimsize,"Index", index);
    
    /* Call HDF-EOS library function, and output result */
    status = SWdefidxmap(swathid, geodim, datadim, index);
    plhs[0] = haCreateDoubleScalar((double) status);

    /* Clean up */
    mxFree(geodim);
    mxFree(datadim);
    mxFree(index);
}



/*
 * hdfSWdefgeofield
 * 
 * Purpose: Gateway to the HDF-EOS Library function SWdefgeofield
 *          Defines a new geolocation field within the Swath
 *
 * MATLAB usage:
 *          status = hd('SW', 'defgeofield', swathid, fieldname, dimlist, ...
 *                      numbertype, merge)
 *
 * Inputs:  swathid     - Swath identifier
 *          fieldname   - Name of field to be defined
 *          dimlist     - list of geolocation dimensions defining a field
 *          numbertype  - the number type of the data stored in the field
 *          merge       - Merge code
 *
 * Outputs: status      - 0 if succeeded, -1 if failed.
 * 
 * Returns: none
 */
static
void hdfSWdefgeofield(int nlhs,
                         mxArray *plhs[],
                         int nrhs,
                         const mxArray *prhs[])
{
    int32 swathid;
    char *fieldname;
    char *dimlist;
    int32 numbertype;
    int32 merge;
    intn status;
    
    /* Argument checking */
    haNarginChk(7, 7, nrhs);
    haNargoutChk(0, 1, nlhs);
    
    /* Get data from MATLAB arrays */
    swathid = (int32) haGetNonNegativeDoubleScalar(prhs[2], "Swath identifier");
    fieldname = haGetString(prhs[3], "Field name");
    dimlist = haGetString(prhs[4], "Dimension list");
    numbertype = haGetDataType(prhs[5]);
    merge = haGetEOSMergeCode(prhs[6]);

    /* Call HDF-EOS library function, and output result */
    status = SWdefgeofield(swathid, fieldname, dimlist, numbertype, merge);
    plhs[0] = haCreateDoubleScalar((double) status);

    /* Clean up */
    mxFree(fieldname);
    mxFree(dimlist);
}


/*
 * hdfSWdefdatafield
 * 
 * Purpose: Gateway to the HDF-EOS Library function SWdefdatafield
 *          Defines a new data field within the Swath
 *
 * MATLAB usage:
 *          status = hd('SW', 'defdatafield', swathid, fieldname, dimlist, ...
 *                      numbertype, merge)
 *
 * Inputs:  swathid     - Swath identifier
 *          fieldname   - Name of field to be defined
 *          dimlist     - list of geolocation dimensions defining a field
 *          numbertype  - the number type of the data stored in the field
 *          merge       - Merge code
 *
 * Outputs: status      - 0 if succeeded, -1 if failed.
 * 
 * Returns: none
 */
static
void hdfSWdefdatafield(int nlhs,
                          mxArray *plhs[],
                          int nrhs,
                          const mxArray *prhs[])
{
    int32 swathid;
    char *fieldname;
    char *dimlist;
    int32 numbertype;
    int32 merge;
    intn status;
    
    /* Argument checking */
    haNarginChk(7, 7, nrhs);
    haNargoutChk(0, 1, nlhs);
    
    /* Get data from MATLAB arrays */
    swathid = (int32) haGetNonNegativeDoubleScalar(prhs[2], "Swath identifier");
    fieldname = haGetString(prhs[3], "Field name");
    dimlist = haGetString(prhs[4], "Dimension list");
    numbertype = haGetDataType(prhs[5]);
    merge = haGetEOSMergeCode(prhs[6]);

    /* Call HDF-EOS library function, and output result */
    status = SWdefdatafield(swathid, fieldname, dimlist, numbertype, merge);
    plhs[0] = haCreateDoubleScalar((double) status);

    /* Clean up */
    mxFree(fieldname);
    mxFree(dimlist);
}



/*
 * hdfSWwritefield
 * 
 * Purpose: Gateway to the HDF-EOS Library function SWwritefield
 *          Write data to a swath field.
 *
 * MATLAB usage:
 *          status = hd('SW', 'writefield', swathid, fieldname, ...
 *                      start, stride, edge, data)
 *
 * Inputs:  swathid     - Swath identifier
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
void hdfSWwritefield(int nlhs,
                        mxArray *plhs[],
                        int nrhs,
                        const mxArray *prhs[])
{
    int32 swathid;
    char *fieldname;
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
    swathid = (int32) haGetNonNegativeDoubleScalar(prhs[2], "Swath identifier");
    fieldname = haGetString(prhs[3], "Field name");
    
    if (SWfieldinfo(swathid, fieldname, &rank, dims, &ntype, NULL)==FAIL) {
        status = FAIL;
    }
    else {

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
        status = SWwritefield(swathid, fieldname, pstart, pstride, pedge, data);
    }
    
    plhs[0] = haCreateDoubleScalar((double) status);

    /* Clean up */
    mxFree(fieldname);
    if (free_buffer) {
        mxFree(data);
    }
}


/*
 * hdfSWreadfield
 * 
 * Purpose: Gateway to the HDF-EOS Library function SWreadfield
 *          Reads data from a swath field.
 *
 * MATLAB usage:
 *          [buffer,status] = hd('SW', 'readfield', swathid, ...
 *                               fieldname, start, stride, edge)
 *
 * Inputs:  swathid     - Swath identifier
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
void hdfSWreadfield(int nlhs,
                       mxArray *plhs[],
                       int nrhs,
                       const mxArray *prhs[])
{
    int32 swathid;
    char *fieldname;
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
    swathid = (int32) haGetNonNegativeDoubleScalar(prhs[2], "Swath identifier");
    fieldname = haGetString(prhs[3], "Field name");

    /* Get dimensions for the field */
    if(SWfieldinfo(swathid, fieldname, &rank, dims, &numbertype, NULL) == FAIL) {
        status = FAIL;
        plhs[0] = EMPTY;
    }
    else {
        
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
                    mexErrMsgTxt("The EDGE vector specified a larger data dimension than exists in file.");
            }
        }
    
        /* Allocate the buffer */
        bufsize = 1;
        for (i=0; i<rank; i++)  {
            bufsize *= edge[i];
        }
        buffer = haMakeHDFDataBuffer(bufsize, numbertype);
    
        /* Call HDF-EOS library function */
        status = SWreadfield(swathid, fieldname, start, stride, edge, buffer);
    
        if (status == 0) {
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
        
            plhs[0] = haMakeArrayFromHDFDataBuffer(rank, matlabdims, numbertype, 
                                                   buffer, &ok_to_free);
        }
        else {
            plhs[0] = EMPTY;
        }
    }
    
    if (nlhs == 2) {
        plhs[1] = haCreateDoubleScalar((double) status);
    }

    /* Clean up */
    mxFree(fieldname);
    if (ok_to_free && buffer != NULL) {
        mxFree(buffer);
    }
}



/*
 * hdfSWwriteattr
 * 
 * Purpose: Gateway to the HDF-EOS Library function SWwriteattr
 *          Writes/Updates attributes in a swath
 *
 * MATLAB usage:
 *          status = hd('SW', 'writeattr', swathid, attrname, databuf)
 *
 * Inputs:  swathid     - Swath identifier
 *          attrname    - Name of attribute
 *          databuf     - Attribute values to be written to the field
 *
 * Outputs: status      - 0 if succeeded, -1 if failed.
 * 
 * Returns: none
 */
static
void hdfSWwriteattr(int nlhs,
                       mxArray *plhs[],
                       int nrhs,
                       const mxArray *prhs[])
{
    int32 swathid;
    char *attrname;
    VOIDP datbuf;
    intn status;

    mxClassID classid;
    int32 ntype;
    int32 count;
    bool free_buf = false;
    
    /* Argument checking */
    haNarginChk(5, 5, nrhs);
    haNargoutChk(0, 1, nlhs);
    
    swathid = (int32) haGetNonNegativeDoubleScalar(prhs[2], "Swath identifier");
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
    status = SWwriteattr(swathid, attrname, ntype, count, datbuf);
    plhs[0] = haCreateDoubleScalar((double) status);

    /* Clean up */
    mxFree(attrname);
    if (free_buf) {
        mxFree(datbuf);
    }
}



/*
 * hdfSWreadattr
 * 
 * Purpose: Gateway to the HDF-EOS Library function SWreadattr
 *          Reads attributes from a swath
 *
 * MATLAB usage:
 *          [databuf, status] = hd('SW', 'readattr', swathid, attrname)
 *
 * Inputs:  swathid     - Swath identifier
 *          attrname    - Name of attribute
 *
 * Outputs: databuf     - Attribute values read from the field
 *          status      - 0 if succeeded, -1 if failed.
 * 
 * Returns: none
 */
static
void hdfSWreadattr(int nlhs,
                      mxArray *plhs[],
                      int nrhs,
                      const mxArray *prhs[])
{
    int32 swathid;
    char *attrname;
    VOIDP datbuf = NULL;
    intn status;

    int32 numbertype;
    int32 count;
    int dims[2] = {0, 1};
    bool ok_to_free = true;

    /* Argument checking */
    haNarginChk(4, 4, nrhs);
    haNargoutChk(0, 2, nlhs);
    
    /* Get datbuf from MATLAB arrays */
    swathid = (int32) haGetNonNegativeDoubleScalar(prhs[2], "Swath identifier");
    attrname = haGetString(prhs[3], "Attribute name");

    if (SWattrinfo(swathid, attrname, &numbertype, &count) == FAIL) {
        plhs[0] = EMPTY;
        status = FAIL;
    }
    else 
    {
        /* Allocate space for the data to be read */
        datbuf = haMakeHDFDataBuffer(count, numbertype);

        /* Call HDF-EOS library function, and output result */
        status = SWreadattr(swathid, attrname, datbuf);

        if (status == 0) {
            dims[0] = count;
            plhs[0] = haMakeArrayFromHDFDataBuffer(2, dims, numbertype, 
                                                   datbuf, &ok_to_free);
        }
        else {
            plhs[0] = EMPTY;
        }
    }

    if (nlhs == 2) {
        plhs[1] = haCreateDoubleScalar((double) status);
    }

    /* Clean up */
    mxFree(attrname);
    if (ok_to_free && (datbuf != NULL)) {
        mxFree(datbuf);
    }
}



/*
 * hdfSWinqdims
 * 
 * Purpose: Gateway to the HDF-EOS Library function SWinqdims
 *          Retrieve information about all of the dimensions 
 *          defined in a swath.
 *
 * MATLAB usage:
 *          [ndims, dimname, dims] = hdf('SW', 'inqdims', swathid);
 *
 * Inputs:  swathid     - Swath identifier
 *          
 * Outputs: ndims       - number of dimension entries found
 *          dimname     - dimension list
 *          dims        - array conaining size of each dimension
 * 
 * Returns: none
 */
static
void hdfSWinqdims(int nlhs,
                     mxArray *plhs[],
                     int nrhs,
                     const mxArray *prhs[])
{
    int32 swathid;
    int32 ndims;
    char *dimname = NULL;
    int32 dims[MAX_VAR_DIMS];
    int dimsdims[2] = {0, 0};
    int32 strbufsz;
    intn status;

    /* Argument checking */
    haNarginChk(3, 3, nrhs);
    haNargoutChk(0, 3, nlhs);
    
    /* Get data from MATLAB arrays */
    swathid = (int32) haGetNonNegativeDoubleScalar(prhs[2], "Swath identifier");
    status = (swathid < 0) ? FAIL : SUCCEED;

    /* Call HDF-EOS library function, and output result */
    if (status != FAIL)
    {
        ndims = SWnentries(swathid, HDFE_NENTDIM, &strbufsz);
        status = (ndims < 0) ? FAIL : SUCCEED;
    }

    /* Allocate space and call HDF-EOS function. */
    if (status != FAIL)
    {
        dimname = mxCalloc(strbufsz+1, sizeof(char));
        ndims = SWinqdims(swathid, dimname, dims);
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
            dimsdims[1] = ndims;  /* dimsdims contains dimensions of 
                                  ** the output dimensions array.  */
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
 * hdfSWinqmaps
 * 
 * Purpose: Gateway to the HDF-EOS Library function SWinqmaps
 *          Retrieve information about all of the (non-indexed)
 *          geolocation relations defined in a swath.
 *
 * MATLAB usage:
 *          [nmaps, dimmap, offset, increment] = ...
 *                              hdf('SW', 'inqmaps', swathid);
 *
 * Inputs:  swathid     - Swath identifier
 *          
 * Outputs: nmaps       - number of geolocation entries found
 *          dimmap      - dimension mapping list
 *          offset      - array containing the offset of each 
 *                        geolocation relation
 *          increment   - array containing the increment of each 
 *                        geolocation relation
 *
 * Returns: none
 */
static
void hdfSWinqmaps(int nlhs,
                     mxArray *plhs[],
                     int nrhs,
                     const mxArray *prhs[])
{
    int32 swathid;

    int32 nmaps;
    char *dimmap = NULL;
    int32 *offset = NULL;
    int32 *increment = NULL;
    int32 strbufsz;
    intn status;
    int dims[2] = {0, 1};
    
    /* Argument checking */
    haNarginChk(3, 3, nrhs);
    haNargoutChk(4, 4, nlhs);
    
    /* Get data from MATLAB arrays */
    swathid = (int32) haGetNonNegativeDoubleScalar(prhs[2], "Swath identifier");
    status = (swathid < 0) ? FAIL : SUCCEED;
    
    /* Find out how much space we need to allocate. */
    if (status != FAIL)
    {
        nmaps = SWnentries(swathid, HDFE_NENTMAP, &strbufsz);
        status = (nmaps < 0) ? FAIL : SUCCEED;
    }
    
    /* Allocate space and call HDF-EOS function. */
    dimmap = mxCalloc(strbufsz+1, sizeof(char));
    offset = mxCalloc(nmaps, sizeof(int32));
    increment = mxCalloc(nmaps, sizeof(int32));
    nmaps = SWinqmaps(swathid, dimmap, offset, increment);
    status = (nmaps < 0) ? FAIL : SUCCEED;
    
    plhs[0] = haCreateDoubleScalar((double) nmaps);

    if (nlhs > 1)
    {
        plhs[1] = (status == FAIL) ? EMPTY : mxCreateString(dimmap);
    }
    
    if (nlhs > 2)
    {
        if (status != FAIL)
        {
            dims[0] = nmaps;      /* dims contains dimensions of the output  
                              ** arrays (offset & increment) */
            plhs[2] = CreateDoubleMxArrayFromINT32Array(offset, 2, dims);
        }
        else
        {
            plhs[2] = EMPTY;
        }
    }
    
    if (nlhs > 3)
    {
        plhs[3] = (status == FAIL) ? EMPTY :
            CreateDoubleMxArrayFromINT32Array(increment, 2, dims);
    }
    
    /* Clean up */
    if (dimmap != NULL)
    {
        mxFree(dimmap);
    }
    if (offset != NULL)
    {
        mxFree(offset);
    }
    if (increment != NULL)
    {
        mxFree(increment);
    }
}



/*
 * hdfSWinqidxmaps
 * 
 * Purpose: Gateway to the HDF-EOS Library function SWinqidxmaps
 *          Retrieve information about all of the indexed 
 *          geolocation/data mappings defined in a swath.
 *
 * MATLAB usage:
 *          [nidxmaps, idxmap, idxsizes] = ...
 *                              hdf('SW', 'inqidxmaps', swathid);
 *
 * Inputs:  swathid     - Swath identifier
 *          
 * Outputs: nidxmaps    - number of indexed mapping relations found
 *          idxmap      - indexed dimension mapping list
 *          idxsizes    - array conaining the sizes of the corresponding
 *                        index arrays
 *
 * Returns: none
 */
static
void hdfSWinqidxmaps(int nlhs,
                        mxArray *plhs[],
                        int nrhs,
                        const mxArray *prhs[])
{
    int32 swathid;

    int32 nidxmaps;
    char *idxmap = NULL;
    int32 *idxsizes = NULL;
    int32 strbufsz;
    int dims[2] = {0, 1};
    intn status;
    
    /* Argument checking */
    haNarginChk(3, 3, nrhs);
    haNargoutChk(0, 3, nlhs);
    
    /* Get data from MATLAB arrays */
    swathid = (int32) haGetNonNegativeDoubleScalar(prhs[2], "Swath identifier");
    status = (swathid < 0) ? FAIL : SUCCEED;
    
    /* How much space do we need to allocate? */
    if (status != FAIL)
    {
        nidxmaps = SWnentries(swathid, HDFE_NENTIMAP, &strbufsz);
        status = (nidxmaps < 0) ? FAIL : SUCCEED;
    }
    
    /* Allocate space and call HDF-EOS function. */
    if (status != FAIL)
    {
        idxsizes = mxCalloc(nidxmaps, sizeof(int32));
        idxmap = mxCalloc(strbufsz+1, sizeof(char));
        nidxmaps = SWinqidxmaps(swathid, idxmap, idxsizes);
        status = (nidxmaps < 0) ? FAIL : SUCCEED;
    }
    
    if (status != FAIL)
    {
        plhs[0] = haCreateDoubleScalar((double) nidxmaps);
    }
    else
    {
        plhs[0] = haCreateDoubleScalar((double) FAIL);
    }

    if (nlhs > 1)
    {
        plhs[1] = (status == FAIL) ? EMPTY : mxCreateString(idxmap);
    }
    
    if (nlhs > 2)
    {
        if (status != FAIL) 
        {
            dims[0] = nidxmaps;   /* dims contains dimensions of 
                                  ** the output idxsizes array. */
            plhs[2] = CreateDoubleMxArrayFromINT32Array(idxsizes, 2, dims);
        }
        else
        {
            plhs[2] = EMPTY;
        }
    }

    /* Clean up */
    if (idxmap != NULL) 
    {
        mxFree(idxmap);
    }
    if (idxsizes != NULL) 
    {
        mxFree(idxsizes);
    }
}



/*
 * hdfSWinqgeofields
 * 
 * Purpose: Gateway to the HDF-EOS Library function SWinqgeofields
 *          Retrieve information about all of the geolocation
 *          fields defined in a swath.
 *
 * MATLAB usage:
 *          [nfields, fieldlist, rank, numbertype] = ...
 *                              hdf('SW', 'inqgeofields', swathid);
 *
 * Inputs:  swathid     - Swath identifier
 *          
 * Outputs: nfields     - number of geolocation fields found
 *          fieldlist   - listing of geolocation fields
 *          rank        - array conaining rank of each geolocation field
 *          numbertype  - cell-array conaining numbertype of each field
 *
 * Returns: none
 */
static
void hdfSWinqgeofields(int nlhs,
                          mxArray *plhs[],
                          int nrhs,
                          const mxArray *prhs[])
{
    int32 swathid;

    int32 nfields;
    char *fieldlist = NULL;
    int32 *rank = NULL;
    int32 *numbertype = NULL;
    int32 strbufsz;
    intn status;
    
    int dims[2] = {0, 1};
    
    /* Argument checking */
    haNarginChk(3, 3, nrhs);
    haNargoutChk(4, 4, nlhs);
    
    /* Get data from MATLAB arrays */
    swathid = (int32) haGetNonNegativeDoubleScalar(prhs[2], "Swath identifier");
    status = (swathid < 0) ? FAIL : SUCCEED;
    
    /* How much space do we need to allocate? */
    if (status != FAIL)
    {
        nfields = SWnentries(swathid, HDFE_NENTGFLD, &strbufsz);
        status = (nfields < 0) ? FAIL : SUCCEED;
    }
    
    /* Allocate space and call the HDF-EOS library function. */
    if (status != FAIL)
    {
        fieldlist = mxCalloc(strbufsz + 1, sizeof(char));
        rank = mxCalloc(nfields, sizeof(int32));
        numbertype = mxCalloc(nfields, sizeof(int32));
        nfields = SWinqgeofields(swathid, fieldlist, rank, numbertype);
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
            dims[0] = nfields;    /* dims contains dimensions of 
                                  ** the output idxsizes array. */
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
 * hdfSWinqdatafields
 * 
 * Purpose: Gateway to the HDF-EOS Library function SWinqdatafields
 *          Retrieve information about all of the data
 *          fields defined in a swath.
 *
 * MATLAB usage:
 *          [nfields, fieldlist, rank, numbertype] = ...
 *                              hdf('SW', 'inqdatafields', swathid);
 *
 * Inputs:  swathid     - Swath identifier
 *          
 * Outputs: nfields     - number of data fields found
 *          fieldlist   - listing of data fields
 *          rank        - array conaining rank of each data field
 *          numbertype  - array conaining numbertype of each data field
 *
 * Returns: none
 */
static
void hdfSWinqdatafields(int nlhs,
                           mxArray *plhs[],
                           int nrhs,
                           const mxArray *prhs[])
{
    int32 swathid;

    int32 nfields;
    char *fieldlist = NULL;
    int32 *rank = NULL;
    int32 *numbertype = NULL;
    int32 strbufsz;
    intn status;

    int dims[2] = {0, 1};
    
    /* Argument checking */
    haNarginChk(3, 3, nrhs);
    haNargoutChk(0, 4, nlhs);
    
    /* Get data from MATLAB arrays */
    swathid = (int32) haGetNonNegativeDoubleScalar(prhs[2], "Swath identifier");
    status = (swathid == FAIL) ? FAIL : SUCCEED;

    /* How much space do we need to allocate? */
    if (status != FAIL)
    {
        nfields = SWnentries(swathid, HDFE_NENTDFLD, &strbufsz);
        status = (nfields < 0) ? FAIL : SUCCEED;
    }
    
    /* Allocate space and call library function */
    if (status != FAIL)
    {
        fieldlist = mxCalloc(strbufsz + 1, sizeof(char));
        rank = mxCalloc(nfields, sizeof(int32));
        numbertype = mxCalloc(nfields, sizeof(int32));
        nfields = SWinqdatafields(swathid, fieldlist, rank, numbertype);
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
            dims[0] = nfields;    /* dims contains dimensions of the output  
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
 * hdfSWnentries
 * 
 * Purpose: Gateway to the HDF-EOS Library function SWnentries
 *          Returns number of entries for a specified entity
 *
 * MATLAB usage:
 *          [nmaps,strbufsize] = hdf('SW', 'nentries', swathid, entrycode);
 *
 * Inputs:  swathid     - Swath identifier
 *          entrycode   - Entry code
 *
 * Outputs: nmaps       - number of entries
 *
 * Returns: none
 */
static
void hdfSWnentries(int nlhs,
                      mxArray *plhs[],
                      int nrhs,
                      const mxArray *prhs[])
{
    int32 swathid;
    int32 nmaps;
    int32 entrycode;
    int32 strbufsize;
    
    /* Argument checking */
    haNarginChk(4, 4, nrhs);
    haNargoutChk(0, 2, nlhs);
    
    /* Get data from MATLAB arrays */
    swathid = (int32) haGetNonNegativeDoubleScalar(prhs[2], "Swath identifier");
    entrycode = GetEntryCode(prhs[3]);
    
    /* Call HDF-EOS library function, and output result */
    nmaps = SWnentries(swathid, entrycode, &strbufsize);
    
    plhs[0] = haCreateDoubleScalar((double) nmaps);

    if (nlhs > 1)
    {
        if (nmaps == FAIL)
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
 * hdfSWdiminfo
 * 
 * Purpose: Gateway to the HDF-EOS Library function SWdiminfo
 *          Retrieve size of specified dimension
 *
 * MATLAB usage:
 *          dimsize = hdf('SW', 'diminfo', swathid, dimname);
 *
 * Inputs:  swathid     - Swath identifier
 *          dimname     - dimension name
 *
 * Outputs: dimsize     - size of dimension
 *
 * Retuns:  none
 */
static
void hdfSWdiminfo(int nlhs,
                     mxArray *plhs[],
                     int nrhs,
                     const mxArray *prhs[])
{
    int32 swathid;
    int32 dimsize;
    char *dimname;
    
    /* Argument checking */
    haNarginChk(4, 4, nrhs);
    haNargoutChk(0, 1, nlhs);
    
    /* Get data from MATLAB arrays */
    swathid = (int32) haGetNonNegativeDoubleScalar(prhs[2], "Swath identifier");
    dimname = haGetString(prhs[3], "Dimension name");
    
    /* Call HDF-EOS library function, and output result */
    dimsize = SWdiminfo(swathid, dimname);
    
    plhs[0] = haCreateDoubleScalar((double) dimsize);

    /* Clean up */
    mxFree(dimname);
}


    
/*
 * hdfSWmapinfo
 * 
 * Purpose: Gateway to the HDF-EOS Library function SWmapinfo
 *          Retrieve offset and increment of specific monotonic
 *          geolocation mapping.
 *
 * MATLAB usage:
 *          [offset, increment, status] = ...
 *                hdf('SW', 'mapinfo', swathid, geodim, datadim);
 *
 * Inputs:  swathid     - Swath identifier
 *          geodim      - Geolocation dimension name
 *          datadim     - Data dimension name
 *
 * Outputs: offset      - mapping offset
 *          increment   - mapping increment
 *          status      - 0 if succeeded, -1 if failed.
 *
 * Retuns:  none
 */
static
void hdfSWmapinfo(int nlhs,
                     mxArray *plhs[],
                     int nrhs,
                     const mxArray *prhs[])
{
    int32 swathid;
    char *geodim;
    char *datadim;
    int32 offset;
    int32 increment;
    int32 status;
    
    /* Argument checking */
    haNarginChk(5, 5, nrhs);
    haNargoutChk(0, 3, nlhs);
    
    /* Get data from MATLAB arrays */
    swathid = (int32) haGetNonNegativeDoubleScalar(prhs[2], "Swath identifier");
    geodim = haGetString(prhs[3], "Geolocation dimension name");
    datadim = haGetString(prhs[4], "Data dimension name");
    
    /* Call HDF-EOS library function, and output result */
    status = SWmapinfo(swathid, geodim, datadim, &offset, &increment);

    plhs[0] = haCreateDoubleScalar((double) offset);
    if (nlhs > 1) {
        plhs[1] = haCreateDoubleScalar((double) increment);
    }
    if (nlhs > 2) {
        plhs[2] = haCreateDoubleScalar((double) status);
    }

    /* Clean up */
    mxFree(geodim);
    mxFree(datadim);
}


    
/*
 * hdfSWidxmapinfo
 * 
 * Purpose: Gateway to the HDF-EOS Library function SWidxmapinfo
 *          Retrieve indexed array of specified geolocation mapping.
 *
 * MATLAB usage:
 *          [idxsize, index] = ...
 *                hdf('SW', 'idxmapinfo', swathid, geodim, datadim);
 *
 * Inputs:  swathid     - Swath identifier
 *          geodim      - Geolocation dimension name
 *          datadim     - Data dimension name
 *
 * Outputs: idxsize     - size of indexed array
 *          index       - mapping offset
 *
 * Retuns:  none
 */
static
void hdfSWidxmapinfo(int nlhs,
                        mxArray *plhs[],
                        int nrhs,
                        const mxArray *prhs[])
{
    int32 swathid;
    char *geodim = NULL;
    char *datadim = NULL;
    int32 idxsize;
    int32 dimsize;
    int32 *index = NULL;
    int dims[2] = {0,1};
    int32 mapsize = 32000;
    intn status;
        
    /* Argument checking */
    haNarginChk(5, 5, nrhs);
    haNargoutChk(0, 2, nlhs);
    
    /* Get data from MATLAB arrays */
    swathid = (int32) haGetNonNegativeDoubleScalar(prhs[2], "Swath identifier");
    geodim = haGetString(prhs[3], "Geolocation dimension name");
    datadim = haGetString(prhs[4], "Data dimension name");

    /* How big is the dimension? */
    dimsize = SWdiminfo(swathid, datadim);
    status = (dimsize < 0) ? FAIL : SUCCEED;
    
    /* Allocate space and get result. */
    if (status != FAIL)
    {
        index = mxCalloc( mapsize , sizeof(int32));
        idxsize = SWidxmapinfo(swathid, geodim, datadim, index);
        status = (idxsize < 0) ? FAIL : SUCCEED;
    }

    if (status != FAIL)
    {
        plhs[0] = haCreateDoubleScalar((double) idxsize);
    }
    else 
    {
        plhs[0] = haCreateDoubleScalar((double) FAIL);
    }
    
    if (nlhs > 1)
    {
        if (status != FAIL)
        {
            dims[0] = idxsize;
            plhs[1] = CreateDoubleMxArrayFromINT32Array(index, 2, dims);
        }
        else
        {
            plhs[1] = EMPTY;
        }
    }

    /* Clean up */
    if (geodim != NULL)
    {
        mxFree(geodim);
    }
    if (datadim != NULL)
    {
        mxFree(datadim);
    }
    if (index != NULL)
    {
        mxFree(index);
    }
}




    
/*
 * hdfSWfieldinfo
 * 
 * Purpose: Gateway to the HDF-EOS Library function SWfieldinfo
 *          Returns information about a specified geolocation 
 *          or data field within a swath.
 *
 * MATLAB usage:
 *          [rank, dims, numbertype, dimlist, status] = ...
 *                      hdf('SW', 'fieldinfo', swathid, fieldname);
 *
 * Inputs:  swathid     - Swath identifier
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
void hdfSWfieldinfo(int nlhs,
                       mxArray *plhs[],
                       int nrhs,
                       const mxArray *prhs[])
{
    int32 swathid;
    char *fieldname = NULL;
    int32 rank;
    int32 dims[MAX_VAR_DIMS];
    int32 numbertype;
    char *dimlist = NULL;
    int dimsdims[2] = {0, 0};
    intn status;    
    int32 strbufsz;
    int32 ndims;

    /* Argument checking */
    haNarginChk(4, 4, nrhs);
    haNargoutChk(0, 5, nlhs);
    
    /* Get data from MATLAB arrays */
    swathid = (int32) haGetNonNegativeDoubleScalar(prhs[2], "Swath identifier");
    fieldname = haGetString(prhs[3], "Field name");
    
    /* Call HDF-EOS library function, and output result */
    ndims = SWnentries(swathid, HDFE_NENTDIM, &strbufsz);
    status = (ndims < 0) ? FAIL : SUCCEED;
    
    if (status != FAIL)
    {
        dimlist = mxCalloc(strbufsz+1, sizeof(char));
        status = SWfieldinfo(swathid, fieldname, &rank, dims,
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
 * hdfSWdefboxregion
 * 
 * Purpose: Gateway to the HDF-EOS Library function SWdefboxregion
 *          Defines a longitude-latitude box region for a swath
 *
 * MATLAB usage:
 *          regionid = hdf('SW', 'defboxregion', swathid, ...
 *                         cornerlon, cornerlat, mode);
 *
 * Inputs:  swathid     - Swath identifier
 *          cornerlon   - Longitude in decimal degrees of box corners
 *          cornerlat   - Latitude in decimal degrees of box corners
 *          mode        - Cross track inclusion mode
 *
 * Outputs: regionid    - Swath region ID
 * 
 * Retuns:  none
 */
static
void hdfSWdefboxregion(int nlhs,
                          mxArray *plhs[],
                          int nrhs,
                          const mxArray *prhs[])
{
    int32 swathid;
    int32 regionid;
    double cornerlon[2];
    double cornerlat[2];
    int32 mode;
    
    double *pd;
    
    /* Argument checking */
    haNarginChk(6, 6, nrhs);
    haNargoutChk(0, 1, nlhs);
    
    /* Get data from MATLAB arrays */
    swathid  = (int32) haGetNonNegativeDoubleScalar(prhs[2], "Swath identifier");
    if (mxGetNumberOfElements(prhs[3]) != 2 ||
        mxGetNumberOfElements(prhs[4]) != 2) {
        mexErrMsgTxt("cornerlat and cornerlon must be 2 element vectors.");
    }
    if (!mxIsDouble(prhs[3]) || !mxIsDouble(prhs[4])) {
        mexErrMsgTxt("cornerlat and cornerlon must be of class double.");
    }

    pd = mxGetData(prhs[3]);
    cornerlon[0] = pd[0];
    cornerlon[1] = pd[1];
    pd = mxGetData(prhs[4]);
    cornerlat[0] = pd[0];
    cornerlat[1] = pd[1];
    
    mode = GetCrossTrackInclusionMode(prhs[5]);
    
    /* Call HDF-EOS library function, and output result */
    regionid = SWdefboxregion(swathid, cornerlon, cornerlat, mode);

    plhs[0] = haCreateDoubleScalar((double) regionid);
}


    
/*
 * hdfSWregionindex
 * 
 * Purpose: Gateway to the HDF-EOS Library function SWregionindex
 *          Defines a longitude-latitude box region for a swath
 *
 * MATLAB usage:
 *          [regionid, geodim, idxrange] = hdf('SW', 'regionindex', swathid, ...
 *                         cornerlon, cornerlat, mode);
 *
 * Inputs:  swathid     - Swath identifier
 *          cornerlon   - Longitude in decimal degrees of box corners
 *          cornerlat   - Latitude in decimal degrees of box corners
 *          mode        - Cross track inclusion mode
 *
 * Outputs: regionid    - Swath region ID
            geodim      - Geolocation track dimension name
            idxrange    - range of the dimension
 * 
 * Returns:  none
 */
static
void hdfSWregionindex(int nlhs,
                      mxArray *plhs[],
                      int nrhs,
                      const mxArray *prhs[])
{
    int32 swathid;
    int32 regionid;
    double cornerlon[2];
    double cornerlat[2];

    int32 mode;
    
    double *pd;

    char *geodim;
    int32 idxrange[2];
    int32 ndims;
    int32 strbufsz;
    int dimsdims[2] = {1,2};
    
    /* Argument checking */
    haNarginChk(6, 6, nrhs);
    haNargoutChk(0, 3, nlhs);
    
    /* Get data from MATLAB arrays */
    swathid  = (int32) haGetNonNegativeDoubleScalar(prhs[2], "Swath identifier");
    if (mxGetNumberOfElements(prhs[3]) != 2 ||
        mxGetNumberOfElements(prhs[4]) != 2) {
        mexErrMsgTxt("cornerlat and cornerlon must be 2 element vectors.");
    }
    if (!mxIsDouble(prhs[3]) || !mxIsDouble(prhs[4])) {
        mexErrMsgTxt("cornerlat and cornerlon must be of class double.");
    }

    pd = mxGetData(prhs[3]);
    cornerlon[0] = pd[0];
    cornerlon[1] = pd[1];
    pd = mxGetData(prhs[4]);
    cornerlat[0] = pd[0];
    cornerlat[1] = pd[1];
    
    mode = GetCrossTrackInclusionMode(prhs[5]);

    /* Get size of geodim */
    ndims = SWnentries(swathid, HDFE_NENTDIM, &strbufsz);
    geodim = mxMalloc(strbufsz*sizeof(char));
    
    /* Call HDF-EOS library function, and output result */
    regionid = SWregionindex(swathid, cornerlon, cornerlat, mode, geodim, idxrange);

    plhs[0] = haCreateDoubleScalar((double) regionid);
    plhs[1] = mxCreateString(geodim);
    plhs[2] = CreateDoubleMxArrayFromINT32Array(idxrange, 2, dimsdims);
    
    if(geodim != NULL)
        {
            mxFree(geodim);
        }
}

/*
 * hdfSWupdateidxmap
 * 
 * Purpose: Gateway to the HDF-EOS Library function SWupdateidxmap
 *          Retrieves indexed array of specified geolocation mapping
 *          for a specified region.
 * 
 * MATLAB usage: [indexout, indices, idxsz] = ...
 *                    hdf('SW','updateidxmap',swathid, regionid,indexin);
 * 
 * Inputs: swathid     - Swath identifier
 *         regionid    - Region identifier
 *         indexin     - Array containing indices of the data dimension 
 *                       to which each geolocation element corresponds
 *         
 * Outputs: indexout   - Array containing indices of the data dimension
 *                       to which each geolocation corresponds in the 
 *                       subsetted region.
 *          indices    - Array containing indices for start and stop of region
 *          idxsz      - Size of updated indexed aray, -1 if failed
 * 
 * Returns: none
 */
static
void hdfSWupdateidxmap(int nlhs,
                       mxArray *plhs[],
                       int nrhs,
                       const mxArray *prhs[])
{
    int32 swathid;
    int32 regionid;
    int32 *indexout;
    int32 *indexin;
    int32 indices[2];
    int32 idxsz;
    double *indexin_ptr;

    int dimsdims[2];
    int i,
        count;

    /* Argument checking */
    haNarginChk(5,5,nrhs);
    haNargoutChk(0,3,nlhs);

    /* Get data from MATLAB arrays */
    swathid = (int32) haGetNonNegativeDoubleScalar(prhs[2], "Swath identifier");
    regionid = (int32) haGetNonNegativeDoubleScalar(prhs[3], "Region identifier");
    if(mxGetClassID(prhs[4]) != mxDOUBLE_CLASS)
        {
            mexErrMsgTxt("OFFSET values must be double precision.");
        }
    count = mxGetNumberOfElements(prhs[4]);
    indexin = mxMalloc(count*sizeof(int32));
    indexin_ptr = mxGetPr(prhs[4]);
    for(i=0;i<count;i++)
        {
            indexin[i] = (int32) indexin_ptr[i];
        }

    /* Get size of output array and allocate memory */
    idxsz = SWupdateidxmap(swathid,regionid,indexin,NULL,indices);
    if(idxsz != FAIL)
        {
            indexout = (int32 *) mxMalloc(idxsz*sizeof(int32));

            /* Get the array index region and output results */
            idxsz = SWupdateidxmap(swathid,regionid,indexin,indexout,indices);

            dimsdims[0] = 1;
            dimsdims[1] = idxsz;
            plhs[0] =  CreateDoubleMxArrayFromINT32Array(indexout, 2, dimsdims);
            dimsdims[1] = 2;
            plhs[1] =  CreateDoubleMxArrayFromINT32Array(indices, 2, dimsdims);

            /* Clean up */
            if(indexout != NULL)
                {
                    mxFree(indexout);
                }
        }
    else
        {
            plhs[0] = EMPTY;
            plhs[1] = EMPTY;
        }
    plhs[2] = haCreateDoubleScalar(idxsz);
}

/*
 * hdfSWregioninfo
 * 
 * Purpose: Gateway to the HDF-EOS Library function SWregioninfo
 *          Retrieves information about the subsetted region.
 *
 * MATLAB usage:
 *          [ntype, rank, dims, size, status] = ...
 *               hdf('SW', 'regioninfo', swathid, regionid, fieldname);
 *
 * Inputs:  swathid     - Swath identifier
 *          regionid    - Region identifier
 *          fieldname   - field to subset
 *
 * Outputs: ntype       - number type of field
 *          rank        - rank of field
 *          dims        - dimensions of subset region
 *          size        - Size in bytes of subset region
 *          status      - 0 if succeed, -1 if fail
 * 
 * Retuns:  none
 */
static
void hdfSWregioninfo(int nlhs,
                        mxArray *plhs[],
                        int nrhs,
                        const mxArray *prhs[])
{
    int32 swathid;
    int32 regionid;
    char *fieldname;
    int32 ntype;
    int32 rank;
    int32 dims[MAX_VAR_DIMS];
    int32 size;
    intn status;
    
    int dimsdims[2] = {0, 0};
    
    /* Argument checking */
    haNarginChk(5, 5, nrhs);
    haNargoutChk(0, 5, nlhs);
    
    /* Get data from MATLAB arrays */
    swathid = (int32) haGetNonNegativeDoubleScalar(prhs[2], "Swath identifier");
    regionid = (int32) haGetNonNegativeDoubleScalar(prhs[3], "Region identifier");
    fieldname = haGetString(prhs[4], "Field name");
    
    /* Call HDF-EOS library function, and output result */
    status = SWregioninfo(swathid, regionid, fieldname, &ntype, 
                          &rank, dims, &size);

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
    
    if (nlhs > 4) {
        plhs[4] = haCreateDoubleScalar((double) status); 
    }

    /* Clean up */
    mxFree(fieldname);
}



    
/*
 * hdfSWextractregion
 * 
 * Purpose: Gateway to the HDF-EOS Library function SWextractregion
 *          Extracts (Reads) from subsetted region.
 *
 * MATLAB usage:
 *          [buffer, status] = hdf('SW', 'extractregion', swathid, ...
 *                                 regionid, fieldname, external_mode);
 *
 * Inputs:  swathid     - Swath identifier
 *          regionid    - Region identifier
 *          fieldname   - field to subset
 *          external_mode - external geoloaction mode
 * 
 * Outputs: buffer      - data buffer
 *          status      - 0 if succeed, -1 if fail
 * 
 * Retuns:  none
 */
static
void hdfSWextractregion(int nlhs,
                           mxArray *plhs[],
                           int nrhs,
                           const mxArray *prhs[])
{
    int32 swathid;
    int32 regionid;
    char *fieldname;
    int32 external_mode;
    VOIDP buffer = NULL;
    intn status;

    int32 ntype;
    int32 rank;
    int32 dims[MAX_VAR_DIMS];
    int32 size;
    int matlabdims[MAX_VAR_DIMS];
    int i;
    bool ok2free = true;
    
    /* Argument checking */
    haNarginChk(6, 6, nrhs);
    haNargoutChk(0, 2, nlhs);
    
    /* Get data from MATLAB arrays */
    swathid = (int32) haGetNonNegativeDoubleScalar(prhs[2], "Swath identifier");
    regionid = (int32) haGetNonNegativeDoubleScalar(prhs[3], "Region identifier");
    fieldname = haGetString(prhs[4], "Field name");
    external_mode = GetExternalMode(prhs[5]);
    
    /* Get the number type */
    status = SWregioninfo(swathid, regionid, fieldname, &ntype, 
                          &rank, dims, &size);
    if (status != FAIL) {
        int count = 1;
        /* flip the size vector */
        if (rank==0) {
            matlabdims[0] = 1;
            matlabdims[1] = 1;
            rank = 2;
        }
        else if (rank == 1) {
            matlabdims[0] = dims[0];
            matlabdims[1] = 1;
            rank = 2;
            count = dims[0];
        }
        else {
            for (i =0; i<rank; i++) {
                matlabdims[i] = dims[rank-i-1];
                count *= matlabdims[i];
            }
        }
        
        /* Allocate memory for the buffer */
        buffer = haMakeHDFDataBuffer(count, ntype);
        
        /* Call HDF-EOS library function, and output result */
        status = SWextractregion(swathid, regionid, fieldname, 
                                 external_mode, buffer);
        
        if (status == 0) {
            plhs[0] = haMakeArrayFromHDFDataBuffer(rank, matlabdims, 
                                                   ntype, buffer, &ok2free);
        }
        else  {
            plhs[0] = EMPTY;
        }
    }
    else {
        plhs[0] = EMPTY;
    }
        
    if (nlhs == 2) {
        plhs[1] = haCreateDoubleScalar((double) status);
    }
 
    /* Clean up */
    mxFree(fieldname);
    if (ok2free && (buffer != NULL)) {
        mxFree(buffer);
    }
}


/*
 * hdfSWdeftimeperiod
 * 
 * Purpose: Gateway to the HDF-EOS Library function SWdeftimeperiod
 *          Defines a time period for a swath
 *
 * MATLAB usage:
 *          periodid = hdf('SW', 'deftimeperiod', swathid, ...
 *                         starttime, stoptime, mode);
 *
 * Inputs:  swathid     - Swath identifier
 *          starttime   - start time of period
 *          stoptime    - stop time of period
 *          mode        - Cross Track Inclusion mode
 * 
 * Outputs: periodid    - swath period ID
 * 
 * Retuns:  none
 */
static
void hdfSWdeftimeperiod(int nlhs,
                           mxArray *plhs[],
                           int nrhs,
                           const mxArray *prhs[])
{
    int32 swathid;
    double starttime;
    double stoptime;
    int32 mode;
    int32 periodid;
    
    /* Argument checking */
    haNarginChk(6, 6, nrhs);
    haNargoutChk(0, 1, nlhs);
    
    /* Get data from MATLAB arrays */
    swathid = (int32) haGetNonNegativeDoubleScalar(prhs[2], "Swath identifier");
    starttime = haGetDoubleScalar(prhs[3], "Start time");
    stoptime  = haGetDoubleScalar(prhs[4], "Stop time");
    mode = GetCrossTrackInclusionMode(prhs[5]);
    
    /* Call HDF-EOS library function, and output result */
    periodid = SWdeftimeperiod(swathid, starttime, stoptime, mode);
    plhs[0] = haCreateDoubleScalar((double) periodid);
}


/*
 * hdfSWperiodinfo
 * 
 * Purpose: Gateway to the HDF-EOS Library function SWperiodinfo
 *          Retrieves information about the subsetted period.
 *
 * MATLAB usage:
 *          [ntype, rank, dims, size, status] = ...
 *               hdf('SW', 'periodinfo', swathid, periodid, fieldname);
 *
 * Inputs:  swathid     - Swath identifier
 *          periodid    - Period identifier
 *          fieldname   - field to subset
 *
 * Outputs: ntype       - number type of field
 *          rank        - rank of field
 *          dims        - dimensions of subset period
 *          size        - Size in bytes of subset period
 *          status      - 0 if succeed, -1 if fail
 * 
 * Retuns:  none
 */
static
void hdfSWperiodinfo(int nlhs,
                        mxArray *plhs[],
                        int nrhs,
                        const mxArray *prhs[])
{
    int32 swathid;
    int32 periodid;
    char *fieldname = NULL;
    int32 ntype;
    int32 rank;
    int32 dims[MAX_VAR_DIMS];
    int32 size;
    intn status;
    
    int dimsdims[2] = {0, 1};
    
    /* Argument checking */
    haNarginChk(5, 5, nrhs);
    haNargoutChk(0, 5, nlhs);
    
    /* Get data from MATLAB arrays */
    swathid = (int32) haGetNonNegativeDoubleScalar(prhs[2], "Swath identifier");
    periodid = (int32) haGetNonNegativeDoubleScalar(prhs[3], "Period identifier");
    fieldname = haGetString(prhs[4], "Field name");
    
    /* Call HDF-EOS library function, and output result */
    status = SWperiodinfo(swathid, periodid, fieldname, &ntype, 
                          &rank, dims, &size);

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
            dimsdims[0] = rank;
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

    if (nlhs > 4) {
        plhs[4] = haCreateDoubleScalar((double) status); 
    }

    /* Clean up */
    if (fieldname != NULL)
    {
        mxFree(fieldname);
    }
}



/*
 * hdfSWextractperiod
 * 
 * Purpose: Gateway to the HDF-EOS Library function SWextractperiod
 *          Extracts (Reads) from subsetted time period.
 *
 * MATLAB usage:
 *          [buffer, status] = hdf('SW', 'extractperiod', swathid, ...
 *                                 periodid, fieldname, external_mode);
 *
 * Inputs:  swathid     - Swath identifier
 *          periodid    - Period identifier
 *          fieldname   - field to subset
 *          external_mode - external geoloaction mode
 * 
 * Outputs: buffer      - data buffer
 *          status      - 0 if succeed, -1 if fail
 * 
 * Retuns:  none
 */
static
void hdfSWextractperiod(int nlhs,
                           mxArray *plhs[],
                           int nrhs,
                           const mxArray *prhs[])
{
    int32 swathid;
    int32 periodid;
    char *fieldname;
    int32 external_mode;
    VOIDP buffer = NULL;
    intn status;

    int32 ntype;
    int32 rank;
    int32 dims[MAX_VAR_DIMS];
    int32 size;
    int matlabdims[MAX_VAR_DIMS];
    int i;
    bool ok2free = true;
    
    /* Argument checking */
    haNarginChk(6, 6, nrhs);
    haNargoutChk(0, 2, nlhs);
    
    /* Get data from MATLAB arrays */
    swathid = (int32) haGetNonNegativeDoubleScalar(prhs[2], "Swath identifier");
    periodid = (int32) haGetNonNegativeDoubleScalar(prhs[3], "Period identifier");
    fieldname = haGetString(prhs[4], "Field name");
    external_mode = GetExternalMode(prhs[5]);
    
    /* Get the number type */
    status = SWperiodinfo(swathid, periodid, fieldname, &ntype, 
                          &rank, dims, &size);
    if (status != FAIL) {
        int count = 1;
        
        /* flip the size vector */
        if (rank==0) {
            matlabdims[0] = 1;
            matlabdims[1] = 1;
            rank = 2;
        }
        else if (rank == 1) {
            matlabdims[0] = dims[0];
            matlabdims[1] = 1;
            rank = 2;
            count = dims[0];
        }
        else {
            for (i =0; i<rank; i++) {
                matlabdims[i] = dims[rank-i-1];
                count *= matlabdims[i];
            }
        }

        /* Allocate space for the buffer */
        buffer = haMakeHDFDataBuffer(count, ntype);

        /* Call HDF-EOS library function, and output result */
        status = SWextractperiod(swathid, periodid, fieldname, 
                                 external_mode, buffer);
        
        if (status == 0) {
            plhs[0] = haMakeArrayFromHDFDataBuffer(rank, matlabdims, ntype,
                                                   buffer, &ok2free);
        }
        else {
            plhs[0] = EMPTY;
        }
    }
    else {
        plhs[0] = EMPTY;
    }
    
    if (nlhs == 2) {
        plhs[1] = haCreateDoubleScalar((double) status);
    }
 
    /* Clean up */
    mxFree(fieldname);
    if (ok2free && buffer != NULL) {
        mxFree(buffer);
    }
}

/*
 * hdfSWinqattrs
 * 
 * Purpose: Gateway to the HDF-EOS Library function SWinqattrs
 *          Retrieve information about all of the attributes
 *          defined in a swath.
 *
 * MATLAB usage:
 *          [nattr, attrlist] = hdf('SW', 'inqattrs', swathid);
 *
 * Inputs:  swathid     - Swath identifier
 *          
 * Outputs: nattr       - number of data fields found
 *          attrlist    - attribute list
 *
 * Returns: none
 */
static
void hdfSWinqattrs(int nlhs,
                      mxArray *plhs[],
                      int nrhs,
                      const mxArray *prhs[])
{
    int32 swathid;
    int32 nattr;
    char *attrlist = NULL;
    int32 strbufsize;
    intn status;
    
    /* Argument checking */
    haNarginChk(3, 3, nrhs);
    haNargoutChk(0, 2, nlhs);
    
    /* Get data from MATLAB arrays */
    swathid = (int32) haGetNonNegativeDoubleScalar(prhs[2], "Swath identifier");

    /* How many attributes are there? */
    nattr = SWinqattrs(swathid, NULL, &strbufsize);
    status = (nattr < 0) ? FAIL : SUCCEED;
    
    /* Allocate space for and get the attribute list */
    if (status != FAIL)
    {
        attrlist = mxCalloc(strbufsize + 1, sizeof(char));
        nattr = SWinqattrs(swathid, attrlist, &strbufsize);
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
 * hdfSWattrinfo
 * 
 * Purpose: Gateway to the HDF-EOS Library function SWattrinfo
 *          Returns information about a swath attribute.
 *
 * MATLAB usage:
 *          [numbertype, count, status] = ...
 *                   hdf('SW', 'attrinfo', swathid, attrname);
 *
 * Inputs:  swathid     - Swath identifier
 *          attrname    - attribute name
 *
 * Outputs: numbertype  - number type of attribute
 *          count       - number of total bytes in attribute
 *          status      - returns 0 if succeed, and -1 if fail
 * 
 * Retuns:  none
 */
static
void hdfSWattrinfo(int nlhs,
                      mxArray *plhs[],
                      int nrhs,
                      const mxArray *prhs[])
{
    int32 swathid;
    char *attrname = NULL;
    int32 numbertype;
    int32 count;
    int32 status;
        
    /* Argument checking */
    haNarginChk(4, 4, nrhs);
    haNargoutChk(0, 3, nlhs);
    
    /* Get data from MATLAB arrays */
    swathid = (int32) haGetNonNegativeDoubleScalar(prhs[2], "Swath identifier");
    attrname = haGetString(prhs[3], "Attribute name");
    
    /* Call HDF-EOS library function, and output result */
    status = SWattrinfo(swathid, attrname, &numbertype, &count);

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
 * hdfSWcompinfo
 * 
 * Purpose: Gateway to the HDF-EOS Library function SWcompinfo
 *          Retreives compression information about a field
 *
 * MATLAB usage:
 *          [compcode, compparm, status] = ...
 *                      hdf('SW', 'compinfo', swathid, fieldname);
 *
 * Inputs:  swathid     - Swath identifier
 *          fieldname   - field name
 *
 * Outputs: compcode    - HDF compression code
 *          compparm    - compression parameters
 *          status      - returns 0 if succeed, and -1 if fail
 * 
 * Retuns:  none
 */
static
void hdfSWcompinfo(int nlhs,
                      mxArray *plhs[],
                      int nrhs,
                      const mxArray *prhs[])
{
    int32 swathid;
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
    swathid = (int32) haGetNonNegativeDoubleScalar(prhs[2], "Swath identifier");
    fieldname = haGetString(prhs[3], "Field name");

    /* Initialize parameter vector to zeros, because HDF-EOS library */
    /* may not fill it. */
    for (i = 0; i < NUM_EOS_COMP_PARMS; i++)
    {
        compparm[i] = 0;
    }
    
    /* Call HDF-EOS library function. */
    status = SWcompinfo(swathid, fieldname, &compcode, compparm);
    
    if (status != FAIL)
    {
        plhs[0] = GetCompressionStringFromCode(compcode); 
    }
    else
    {
        plhs[0] = EMPTY;
    }
    
    if (nlhs > 1) 
    {
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
 * hdfSWinqswath
 * 
 * Purpose: Gateway to the HDF-EOS Library function SWinqswath
 *          Retreives compression information about a field
 *
 * MATLAB usage:
 *          [nswath, swathlist] = hdf('SW', 'inqswath', filename);
 *
 * Inputs:  filename    - HDF file name
 *
 * Outputs: nswath      - Number of swaths found
 *          swathlist   - listing of swaths in file
 * 
 * Retuns:  none
 */
static
void hdfSWinqswath(int nlhs,
                      mxArray *plhs[],
                      int nrhs,
                      const mxArray *prhs[])
{
    char *filename = NULL;
    int32 nswath;
    char *swathlist = NULL;
    int32 strbufsize;
    intn status;
    
    /* Argument checking */
    haNarginChk(3, 3, nrhs);
    haNargoutChk(0, 2, nlhs);
    
    /* Get data from MATLAB arrays */
    filename = haGetString(prhs[2], "Filename");
    
    /* How much space do we need to allocate? */
    nswath = SWinqswath(filename, NULL, &strbufsize);
    status = (nswath < 0) ? FAIL : SUCCEED;
    
    /* Allocate space and get the swathlist */
    if (status != FAIL)
    {
        swathlist = mxCalloc(strbufsize+1, sizeof(char));
        nswath = SWinqswath(filename, swathlist, &strbufsize);
    }

    plhs[0] = haCreateDoubleScalar((double) nswath);

    if (nlhs > 1)
    {
        if (status != FAIL)
        {
            plhs[1] = mxCreateString(swathlist);
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
    if (swathlist != NULL)
    {
        mxFree(swathlist);
    }
}

/* hdfSWgeomapinfo
 * 
 * Purpose: Gateway to the HDF-EOS Library function SWgeomapinfo
 *          Retrieves type of dimension mapping for a dimension
 *
 * MATLAB usage: 
 *          regmap = hdf('SW','geomapinfo',swathid, geodim)
 * 
 * Inputs:  swathid     - Swath identifier
 *          geodim      - Dimension name
 *
 * Outputs: none
 * 
 * Returns: regmap      - An integer 
 *                          -1 Failed
 *                           0 not mapped
 *                           1 regular mapping
 *                           2 indexed mapping 
 *                           3 regular and indexed mapping
 *
 */
static
void hdfSWgeomapinfo(int nlhs,
                     mxArray *plhs[],
                     int nrhs,
                     const mxArray *prhs[])
{
    int32 swathid;
    char *geodim;
    intn regmap;
    char dimmap[8];

    haNarginChk(4,4,nrhs);
    haNargoutChk(0,1,nlhs);

    /* Get data from MATLAB arrays */
    swathid = (int32) haGetNonNegativeDoubleScalar(prhs[2], "Swath identifier");
    geodim = haGetString(prhs[3],"Dimension name");

    /* Call HDF-EOS library function and output result */
    regmap = SWgeomapinfo(swathid,geodim);

    plhs[0] = haCreateDoubleScalar((double)regmap);

    /* Clean up */
    if(geodim != NULL)
        {
            mxFree(geodim);
        }
}



/*
 * hdfSWdefcomp
 * 
 * Purpose: Gateway to the HDF-EOS Library function SWdefcomp
 *          Sets the field compression for all subsequent field definitions.
 *
 * MATLAB usage:
 *          status = hdf('SW', 'defcomp', swathid, compcode, compparm)
 *
 * Inputs:  swathid     - Swath identifier
 *          compcode    - HDF Compression code
 *          compparm    - Compression parameters (if applicable)
 *
 * Outputs: status      - 0 if succeeded, -1 if failed.
 * 
 * Returns: none
 */
static
void hdfSWdefcomp(int nlhs,
                     mxArray *plhs[],
                     int nrhs,
                     const mxArray *prhs[])
{
    int32 swathid;
    int32 compcode;
    intn compparm[NUM_EOS_COMP_PARMS];
    intn status;
    
    /* Argument checking */
    haNarginChk(5, 5, nrhs);
    haNargoutChk(0, 1, nlhs);
    
    /* Get data from MATLAB arrays */
    swathid = (int32) haGetNonNegativeDoubleScalar(prhs[2], "Swath identifier");
    compcode = haGetEOSCompressionCode(prhs[3]); 
    haGetEOSCompressionParameters(prhs[4], compparm);

    /* Call HDF-EOS library function, and output result */
    status = SWdefcomp(swathid, compcode, compparm);
    plhs[0] = haCreateDoubleScalar((double) status);

}


/*
 * hdfSWwritegeometa
 * 
 * Purpose: Gateway to the HDF-EOS Library function SWwritegeometa
 *          Writes field metadata for an existing swath geolocation field
 *
 * MATLAB usage:
 *          status = hd('SW', 'writegeometa', swathid, fieldname, ...
 *                      dimlist, numbertype)
 *
 * Inputs:  swathid     - Swath identifier
 *          fieldname   - Name of field
 *          dimlist     - list of geolocation dimensions defining the field
 *          numbertype  - The numbertype of the data stored in the field
 *
 * Outputs: status      - 0 if succeeded, -1 if failed.
 * 
 * Returns: none
 */
static
void hdfSWwritegeometa(int nlhs,
                          mxArray *plhs[],
                          int nrhs,
                          const mxArray *prhs[])
{
    int32 swathid;
    char *fieldname = NULL;
    char *dimlist = NULL;
    int32 numbertype;
    intn status;
    
    /* Argument checking */
    haNarginChk(6, 6, nrhs);
    haNargoutChk(0, 1, nlhs);
    
    /* Get data from MATLAB arrays */
    swathid = (int32) haGetNonNegativeDoubleScalar(prhs[2], "Swath identifier");
    fieldname = haGetString(prhs[3], "Field name");
    dimlist = haGetString(prhs[4], "Dimension list");
    numbertype = haGetDataType(prhs[5]);

    /* Call HDF-EOS library function, and output result */
    status = SWwritegeometa(swathid, fieldname, dimlist, numbertype);
    plhs[0] = haCreateDoubleScalar((double) status);

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
 * hdfSWwritedatameta
 * 
 * Purpose: Gateway to the HDF-EOS Library function SWwritedatameta
 *          Writes field metadata for an existing swath data field
 *
 * MATLAB usage:
 *          status = hd('SW', 'writedatameta', swathid, fieldname, ...
 *                      dimlist, numbertype)
 *
 * Inputs:  swathid     - Swath identifier
 *          fieldname   - Name of field
 *          dimlist     - list of geolocation dimensions defining the field
 *          numbertype  - The numbertype of the data stored in the field
 *
 * Outputs: status      - 0 if succeeded, -1 if failed.
 * 
 * Returns: none
 */
static
void hdfSWwritedatameta(int nlhs,
                           mxArray *plhs[],
                           int nrhs,
                           const mxArray *prhs[])
{
    int32 swathid;
    char *fieldname = NULL;
    char *dimlist = NULL;
    int32 numbertype;
    intn status;

    /* Argument checking */
    haNarginChk(6, 6, nrhs);
    haNargoutChk(0, 1, nlhs);
    
    /* Get data from MATLAB arrays */
    swathid = (int32) haGetNonNegativeDoubleScalar(prhs[2], "Swath identifier");
    fieldname = haGetString(prhs[3], "Field name");
    dimlist = haGetString(prhs[4], "Dimension list");
    numbertype = haGetDataType(prhs[5]);
    
    /* Call HDF-EOS library function, and output result */
    status = SWwritedatameta(swathid, fieldname, dimlist, numbertype);
    plhs[0] = haCreateDoubleScalar((double) status);

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
 * hdfSWsetfillvalue
 * 
 * Purpose: Gateway to the HDF-EOS Library function SWsetfillvalue
 *          Sets fill value for the specified field.
 *
 * MATLAB usage:
 *          status = hd('SW', 'setfillvalue', swathid, fieldname, fillvalue)
 *
 * Inputs:  swathid     - Swath identifier
 *          fieldname   - field name
 *          fillvalue   - fill value to use
 *          
 * Outputs: status      - 0 if succeeded, -1 if failed.
 * 
 * Returns: none
 */
static
void hdfSWsetfillvalue(int nlhs,
                          mxArray *plhs[],
                          int nrhs,
                          const mxArray *prhs[])
{
    int32 swathid;
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
    swathid = (int32) haGetNonNegativeDoubleScalar(prhs[2], "Swath identifier");
    fieldname = haGetString(prhs[3], "Field name");

    /* Call fieldinfo to get the data type of the field */
    status = SWfieldinfo(swathid, fieldname, &rank, dims,
                         &numbertype, NULL);

    if (status != FAIL)
    {
        if (haGetClassIDFromDataType(numbertype) != mxGetClassID(prhs[4])) {
            mexErrMsgTxt("The data type of the fill value must match the "
                         "data type of the field.");
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
        status = SWsetfillvalue(swathid, fieldname, fillvalue);
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
 * hdfSWgetfillvalue
 * 
 * Purpose: Gateway to the HDF-EOS Library function SWgetfillvalue
 *          Gets fill value for the specified field.
 *
 * MATLAB usage:
 *          [fillvalue, status] = hdf('SW', 'getfillvalue', swathid, ...
 *                                    fieldname)
 *
 * Inputs:  swathid     - Swath identifier
 *          fieldname   - field name
 *          
 * Outputs: fillvalue   - fill value 
 *          status      - 0 if succeeded, -1 if failed.
 * 
 * Returns: none
 */
static
void hdfSWgetfillvalue(int nlhs,
                          mxArray *plhs[],
                          int nrhs,
                          const mxArray *prhs[])
{
    int32 swathid;
    char *fieldname = NULL;
    VOIDP fillvalue = NULL;
    intn status;
    
    int32 numbertype;
    int32 rank;
    int32 dims[MAX_VAR_DIMS];
    int matlab_dims[MAX_VAR_DIMS];
    bool ok2free = true;
    
    /* Argument checking */
    haNarginChk(4, 4, nrhs);
    haNargoutChk(0, 2, nlhs);
    
    /* Get data from MATLAB arrays */
    swathid = (int32) haGetNonNegativeDoubleScalar(prhs[2], "Swath identifier");
    fieldname = haGetString(prhs[3], "Field name");

    /* Get number type for the field */
    status = SWfieldinfo(swathid, fieldname, &rank, dims, 
                         &numbertype, NULL);

    /* Allocate space for fillvalue and get it */
    if (status != FAIL)
    {
        fillvalue = haMakeHDFDataBuffer(1, numbertype);
        status = SWgetfillvalue(swathid, fieldname, fillvalue);
    }

    matlab_dims[0] = 1;
    matlab_dims[1] = 1;
    if (status == 0) {
        plhs[0] = haMakeArrayFromHDFDataBuffer(2, matlab_dims, numbertype, 
                                               fillvalue, &ok2free);
    }
    else {
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
    if (ok2free && fillvalue!=NULL) {
        mxFree(fillvalue);
    }
}


/*
 * hdfSWdefvrtregion
 * 
 * Purpose: Gateway to the HDF-EOS Library function SWdefvrtregion
 *          Subsets on a monotonic field or contiguous elements of
 *          a dimension.
 *
 * MATLAB usage:
 *          regionid2 = hdf('SW', 'defvrtregion', swathid, ...
 *                          regionid, vertobj, range);
 *
 * Inputs:  swathid     - Swath identifier
 *          regionid    - Region (or period) ID from previous subset call
 *                        (may be -1 for "stand-alone"
 *          vertobj     - Dimension or field to subset by
 *          range       - minimum and maximum range for subset
 *
 * Outputs: regionid2   - Swath region ID
 * 
 * Retuns:  none
 */
static
void hdfSWdefvrtregion(int nlhs,
                          mxArray *plhs[],
                          int nrhs,
                          const mxArray *prhs[])
{
    int32 swathid;
    int32 regionid;
    char *vertobj = NULL;
    char *regidmacro = NULL;
    double *range = NULL;
    int32 regionid2;
    
    /* Argument checking */
    haNarginChk(6, 6, nrhs);
    haNargoutChk(0, 1, nlhs);
    
    /* Get data from MATLAB arrays */
    swathid = (int32) haGetNonNegativeDoubleScalar(prhs[2], "Swath identifier");
    if (mxIsChar(prhs[3])) {
        regidmacro = haGetString(prhs[3], "Region Identifier macro");
        if (!haStrcmpi(regidmacro, "HDFE_NOPREVSUB") || 
            !haStrcmpi(regidmacro, "NOPREVSUB")) {
            regionid = HDFE_NOPREVSUB;
        }  else {
            mexErrMsgTxt("REGIONID must be a valid region identifier or 'noprevsub'");
        }
        mxFree(regidmacro);
    }
    else {
        regionid = (int32) haGetNonNegativeDoubleScalar(prhs[3], "Region identifier");
    }
    
    vertobj = haGetString(prhs[4], "VertObj");
    if (!mxIsDouble(prhs[5]) || (mxGetNumberOfElements(prhs[5]) != 2)) {
        mexErrMsgTxt("range must be a double array of length 2.");
    }
    range = mxGetPr(prhs[5]);
    
    /* Call HDF-EOS library function, and output result */
    regionid2 = SWdefvrtregion(swathid, regionid, vertobj, range);
    plhs[0] = haCreateDoubleScalar((double) regionid2);

    /* Clean up */
    if (vertobj != NULL)
    {
        mxFree(vertobj);
    }
}



/*
 * hdfSWdupregion
 * 
 * Purpose: Gateway to the HDF-EOS Library function SWdupregion
 *          Duplicates a region.
 *
 * MATLAB usage:
 *          regionid2 = hdf('SW', 'dupregion', regionid);
 *
 * Inputs:  regionid    - Region (or period) ID from previous subset call
 *
 * Outputs: regionid2   - Swath region ID
 * 
 * Retuns:  none
 */
static
void hdfSWdupregion(int nlhs,
                          mxArray *plhs[],
                          int nrhs,
                          const mxArray *prhs[])
{
    int32 regionid;
    int32 regionid2;
    
    /* Argument checking */
    haNarginChk(3, 3, nrhs);
    haNargoutChk(0, 1, nlhs);
    
    /* Get data from MATLAB arrays */
    regionid = (int32) haGetNonNegativeDoubleScalar(prhs[2], "Region identifier");
    
    /* Call HDF-EOS library function, and output result */
    regionid2 = SWdupregion(regionid);
    plhs[0] = haCreateDoubleScalar((double) regionid2);
}

/*
 * hdfSW
 *
 * Purpose: Function switchyard for the HDF-EOS SW part of the HDF gateway.
 *
 * Inputs:  nlhs --- number of left-side arguments
 *          plhs --- left-side arguments
 *          nrhs --- number of right-side arguments
 *          prhs --- right-side arguments
 *          functionStr --- string specifying which SW function to call
 * Outputs: none
 * Return:  none
 */
void hdfSW(int nlhs,
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
    } SWFcns[] = {
        {"open",              hdfSWopen},
        {"create",            hdfSWcreate},
        {"attach",            hdfSWattach},
        {"detach",            hdfSWdetach},
        {"close",             hdfSWclose},
        {"defdim",            hdfSWdefdim},
        {"defdimmap",         hdfSWdefdimmap},
        {"defidxmap",         hdfSWdefidxmap},
        {"defgeofield",       hdfSWdefgeofield},
        {"defdatafield",      hdfSWdefdatafield},
        {"writefield",        hdfSWwritefield},
        {"readfield",         hdfSWreadfield},
        {"writeattr",         hdfSWwriteattr},
        {"readattr",          hdfSWreadattr},
        {"inqdims",           hdfSWinqdims},
        {"inqmaps",           hdfSWinqmaps},
        {"inqidxmaps",        hdfSWinqidxmaps},
        {"inqgeofields",      hdfSWinqgeofields},
        {"inqdatafields",     hdfSWinqdatafields},
        {"nentries",          hdfSWnentries},
        {"diminfo",           hdfSWdiminfo},
        {"mapinfo",           hdfSWmapinfo},
        {"idxmapinfo",        hdfSWidxmapinfo},
        {"fieldinfo",         hdfSWfieldinfo},
        {"defboxregion",      hdfSWdefboxregion},
        {"regioninfo",        hdfSWregioninfo},
        {"extractregion",     hdfSWextractregion},
        {"deftimeperiod",     hdfSWdeftimeperiod},
        {"periodinfo",        hdfSWperiodinfo},
        {"extractperiod",     hdfSWextractperiod},
        {"inqattrs",          hdfSWinqattrs},
        {"attrinfo",          hdfSWattrinfo},
        {"compinfo",          hdfSWcompinfo},
        {"inqswath",          hdfSWinqswath},
        {"defcomp",           hdfSWdefcomp},
        {"writegeometa",      hdfSWwritegeometa},
        {"writedatameta",     hdfSWwritedatameta},
        {"setfillvalue",      hdfSWsetfillvalue},
        {"getfillvalue",      hdfSWgetfillvalue},
        {"defvrtregion",      hdfSWdefvrtregion},
        {"dupregion",         hdfSWdupregion},
        {"geomapinfo",        hdfSWgeomapinfo},
        {"updateidxmap",      hdfSWupdateidxmap},
    };
    int NumberOfFunctions = sizeof(SWFcns) / sizeof(*SWFcns);

    int i;
    bool found = false;

    for (i=0; i<NumberOfFunctions; i++)
    {
        if (strcmp(functionStr,SWFcns[i].name)==0)
        {
            (*(SWFcns[i].func))(nlhs, plhs, nrhs, prhs);
            found = true;
            break;
        }
    }
    
    if (! found)
        mexErrMsgTxt("Unknown HDF-EOS SW interface function.");
    
    return;
}


