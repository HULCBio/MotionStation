/* Copyright 1984-2002 The MathWorks, Inc. */

/*
 * hdfdf24.c --- support file for HDF.MEX
 *
 * This module supports the HDF DF24 interface.  The only public
 * function is hdfDF24(), which is called by mexFunction().
 * hdfDF24 looks at the second input argument to determine which
 * private function should get control.
 *
 * Syntaxes
 * ========
 * status = hdf('DF24', 'addimage', filename, RGB)
 *
 * [width, height, interlace, status] = hdf('DF24', 'getdims', filename);
 *          interlace will be 'pixel', 'line', or 'component'
 *
 * [RGB, status] = hdf('DF24', 'getimage', filename)
 *
 * ref_num = hdf('DF24', 'lastref')
 *
 * num_images = hdf('DF24', 'nimages', filename)
 *
 * status = hdf('DF24', 'putimage', filename, RGB)
 *
 * status = hdf('DF24', 'readref', filename, ref_num)
 *
 * status = hdf('DF24', 'restart')
 *
 * status = hdf('DF24', 'reqil', il)
 *          il can be 'pixel', 'line', or 'component'
 *
 * status = hdf('DF24', 'setcompress', compress_type, ...)
 *          compress_type can be 'none', 'rle', 'jpeg', or 'imcomp'.
 *          If compress_type is 'jpeg', then two additional parameters
 *          must be passed in: quality (number between 0 and 100) and 
 *          force_baseline (logical, 0 or 1).  Other compression
 *          types do not have additional parameters.
 *
 * status = hdf('DF24', 'setdims', width, height)
 *
 * status = hdf('DF24', 'setil', il)
 *          il can be 'pixel', 'line', or 'component'
 *
 * status = hdf('DF24', 'writeref', filename, ref_num) 
 */

/* $Revision: 1.1.6.1 $ $Date: 2003/12/13 03:01:52 $ */

#include <string.h>
#include <math.h>

/* Main HDF library header file */
#include "hdf.h"

/* MATLAB API header file */
#include "mex.h"

/* HDFMEX utility functions */
#include "hdfutils.h"

#include "hdfdf24.h"

/* The DF24 interface has functions to set the desired interlace */
/* for the next read or write.  Unfortunately, there is no function */
/* to query what the currently requested interlace is.  The gateway */
/* functions for reading and writing need to know the interlace, */
/* so when the user sets the requested read or write interlace we */
/* need to save those values. */
#define UNINITIALIZED (-1)
static int32 NextWriteInterlace = UNINITIALIZED;
static int32 NextReadInterlace = UNINITIALIZED;

/* DF24writeref is missing from HDF 4.1r3 */
#undef HAVE_DF24WRITEREF

/*
 * hdfDF24setdims
 *
 * Purpose: gateway to DF24setdims()
 *
 * MATLAB usage:
 *    status = hdf('DF24', 'setdims', width, height)
 */
static void hdfDF24setdims(int nlhs,
                           mxArray *plhs[],
                           int nrhs,
                           const mxArray *prhs[])
{
    int32 width;
    int32 height;
    intn status;

    haNarginChk(4, 4, nrhs);
    haNargoutChk(0, 1, nlhs);

    width = (int32) haGetDoubleScalar(prhs[2], "Width");
    height = (int32) haGetDoubleScalar(prhs[3], "Height");

    status = DF24setdims(width, height);

    plhs[0] = haCreateDoubleScalar((double) status);
}

#ifdef HAVE_DF24WRITEREF

/*
 * hdfDF24writeref
 *
 * Purpose: gateway to DF24writeref()
 *
 * MATLAB usage:
 *    status = hdf('DF24', 'writeref', filename, refNum)
 */
static void hdfDF24writeref(int nlhs,
                            mxArray *plhs[],
                            int nrhs,
                            const mxArray *prhs[])
{
    char *filename;
    uint16 ref;
    intn status;

    haNarginChk(4, 4, nrhs);
    haNargoutChk(0, 1, nlhs);

    filename = haGetString(prhs[2], "Filename");
    ref = (uint16) haGetDoubleScalar(prhs[3], "Reference number");
    
    status = DF24writeref(filename, ref);

    plhs[0] = haCreateDoubleScalar((double) status);

    mxFree(filename);
}

#endif


/*
 * hdfDF24setcompress
 *
 * Purpose: gateway to DF24setcompress()
 *
 * MATLAB usage:
 *    status = hdf('DF24', 'setcompress', compress_type, ...)
 *             compress_type can be 'none', 'rle', 'jpeg', or 'imcomp'.
 *             If compress_type is 'jpeg', then two additional parameters
 *             must be passed in: quality (number between 0 and 100) and 
 *             force_baseline (logical, 0 or 1).  Other compression
 *             types do not have additional parameters.
 */
static void hdfDF24setcompress(int nlhs,
                        mxArray *plhs[],
                        int nrhs,
                        const mxArray *prhs[])
{
    intn status;
    comp_info cinfo;
    int32 compressFlag;

    if (nrhs < 3)
    {
        mexErrMsgTxt("Too few input arguments.");
    }
    
    compressFlag = haGetCompressFlag(prhs[2]);
    
    if (compressFlag == COMP_JPEG)
    {
        if (nrhs < 5)
        {
            mexErrMsgTxt("Too few input arguments.");
        }
        if (nrhs > 5)
        {
            mexErrMsgTxt("Too many input arguments.");
        }

        /* Arg4 is quality factor; number between 0 and 100 */
        cinfo.jpeg.quality = (intn) haGetDoubleScalar(prhs[3],
                                                      "JPEG quality factor");
        cinfo.jpeg.force_baseline =
            (intn) haGetDoubleScalar(prhs[4], "Force_baseline");
    }
    else
    {
        /* only JPEG takes additional parameters */
        if (nrhs > 3)
        {
            mexErrMsgTxt("Too many input arguments.");
        }
    }

    status = DF24setcompress(compressFlag, &cinfo);

    plhs[0] = haCreateDoubleScalar((double) status);
}
        


/*
 * hdfDF24restart
 *
 * Purpose: gateway to DF24restart()
 *
 * MATLAB usage:
 *    status = hdf('DF24', 'restart')
 */
static void hdfDF24restart(int nlhs,
                           mxArray *plhs[],
                           int nrhs,
                           const mxArray *prhs[])
{
    intn status;

    status = DF24restart();
    if (status != FAIL)
    {
        NextWriteInterlace = UNINITIALIZED;
        NextReadInterlace = UNINITIALIZED;
    }

    plhs[0] = haCreateDoubleScalar((double) status);
}        


/*
 * hdfDF24readref
 *
 * Purpose: gateway to DF24readref()
 *
 * MATLAB usage:
 *    status = hdf('DF24', 'readref', filename, ref_num)
 */
static void hdfDF24readref(int nlhs,
                     mxArray *plhs[],
                     int nrhs,
                     const mxArray *prhs[])
{
    char *filename = NULL;
    uint16 refNum = 0;
    intn status;

    haNarginChk(4, 4, nrhs);
    haNargoutChk(0, 1, nlhs);

    filename = haGetString(prhs[2], "Filename");

    refNum = (uint16) haGetDoubleScalar(prhs[3], "Reference number");

    status = DF24readref(filename, refNum);

    plhs[0] = haCreateDoubleScalar((double) status);

    mxFree(filename);
}


/*
 * hdfDF24putimage
 *
 * Purpose: gateway to DF24putimage()
 *
 * MATLAB usage:
 *    status = hdf('DF24', 'putimage', filename, RGB)
 */
static void hdfDF24putimage(int nlhs,
                     mxArray *plhs[],
                     int nrhs,
                     const mxArray *prhs[])
{
    char *filename = NULL;
    intn status = FAIL;
    int32 width = -1;
    int32 height = -1;
    int32 ncomp = -1;
    const int *size;
    int rgb_size[3];

    haNarginChk(4, 4, nrhs);
    haNargoutChk(0, 1, nlhs);

    filename = haGetString(prhs[2], "Filename");

    if (!mxIsUint8(prhs[3]))
    {
        mexErrMsgTxt("RGB must be a uint8 array.");
    }
    size = mxGetDimensions(prhs[3]);
    rgb_size[0] = size[0];
    rgb_size[1] = size[1];
    if (mxGetNumberOfDimensions(prhs[3]) < 3)
    {
        rgb_size[2] = 1;
    }
    else
    {
        rgb_size[2] = size[2];
    }

    if (NextWriteInterlace == UNINITIALIZED)
    {
        NextWriteInterlace = 0;  /* pixel */
        DF24setil(NextWriteInterlace);
    }

    switch (NextWriteInterlace)
    {
    case 0:
        /* PIXEL */
        ncomp = rgb_size[0];
        width = rgb_size[1];
        height = rgb_size[2];
        break;

    case 1:
        /* LINE */
        width = rgb_size[0];
        ncomp = rgb_size[1];
        height = rgb_size[2];
        break;

    case 2:
        /* COMPONENT */
        width = rgb_size[0];
        height = rgb_size[1];
        ncomp = rgb_size[2];
        break;

    default:
        mexErrMsgTxt("Unrecognized or unsupported interlace.");
    }

    if (ncomp != 3)
    {
        mexErrMsgTxt("Input array dimensions not consistent with interlace "
                     "type.");
    }
    
    status = DF24putimage(filename, mxGetData(prhs[3]), 
                          width, height);

    plhs[0] = haCreateDoubleScalar((double) status);

    mxFree(filename);
}
    

/*
 * hdfDF24nimages
 *
 * Purpose: gateway to DF24nimages()
 *
 * MATLAB usage:
 *    num_images = hdf('DF24', 'nimages', filename)
 */
static void hdfDF24nimages(int nlhs,
                    mxArray *plhs[],
                    int nrhs,
                    const mxArray *prhs[])
{
    char *filename;
    intn numImages;

    haNarginChk(3, 3, nrhs);
    haNargoutChk(0, 1, nlhs);

    filename = haGetString(prhs[2], "Filename");

    numImages = DF24nimages(filename);

    plhs[0] = haCreateDoubleScalar((double) numImages);
    
    mxFree(filename);
}

/*
 * hdfDF24lastref
 *
 * Purpose: gateway to DF24lastref()
 *
 * MATLAB usage:
 *    ref_num = hdf('DF24', 'lastref')
 */
static void hdfDF24lastref(int nlhs,
                    mxArray *plhs[],
                    int nrhs,
                    const mxArray *prhs[])
{
    uint16 ref;

    haNarginChk(2, 2, nrhs);
    haNargoutChk(0, 1, nlhs);

    ref = DF24lastref();

    plhs[0] = haCreateDoubleScalar((double) ref);

}

/*
 * hdfDF24getdims
 *
 * Purpose: gateway to DF24getdims()
 *
 * MATLAB usage:
 *    [width, height, interlace, status] = hdf('DF24', 'getdims', filename);
 *             interlace will be 'pixel', 'line', or 'component'
 */
static void hdfDF24getdims(int nlhs,
                    mxArray *plhs[],
                    int nrhs,
                    const mxArray *prhs[])
{
    char *filename = NULL;
    int32 width = -1;
    int32 height = -1;
    intn status = FAIL;
    intn interlace;

    haNarginChk(3, 3, nrhs);
    haNargoutChk(0, 4, nlhs);

    filename = haGetString(prhs[2], "Filename");

    status = DF24getdims(filename, &width, &height, &interlace);
    if (status == SUCCEED)
    {
        plhs[0] = haCreateDoubleScalar((double) width);
        
        if (nlhs > 1)
        {
            plhs[1] = haCreateDoubleScalar((double) height);
        }

        if (nlhs > 2)
        {
            plhs[2] = mxCreateString(haGetInterlaceString(interlace));
        }

        if (nlhs > 3)
        {
            plhs[3] = haCreateDoubleScalar((double) status);
        }
    }
    else
    {
        plhs[0] = EMPTY;

        if (nlhs > 1)
        {
            plhs[1] = EMPTY;
        }

        if (nlhs > 2)
        {
            plhs[2] = EMPTY;
        }

        if (nlhs > 3)
        {
            plhs[3] = haCreateDoubleScalar((double) status);
        }
    }

    mxFree(filename);
}

/*
 * hdfDF24addimage
 *
 * Purpose: gateway to DF24addimage()
 *
 * MATLAB usage:
 *    status = hdf('DF24', 'addimage', filename, RGB)
 */
static void hdfDF24addimage(int nlhs,
                     mxArray *plhs[],
                     int nrhs,
                     const mxArray *prhs[])
{
    char *filename;
    int32 width;
    int32 height;
    int32 ncomp;
    const int *size;
    int rgb_size[3];
    int status;

    haNarginChk(4, 4, nrhs);
    haNargoutChk(0, 1, nlhs);

    if (!mxIsUint8(prhs[3]))
    {
        mexErrMsgTxt("RGB must be a uint8 array.");
    }
    size = mxGetDimensions(prhs[3]);
    rgb_size[0] = size[0];
    rgb_size[1] = size[1];
    if (mxGetNumberOfDimensions(prhs[3]) < 3)
    {
        rgb_size[2] = 1;
    }
    else
    {
        rgb_size[2] = size[2];
    }

    filename = haGetString(prhs[2], "Filename");

    if (NextWriteInterlace == UNINITIALIZED)
    {
        NextWriteInterlace = 0; /* pixel */
        DF24setil(NextWriteInterlace);
    }

    switch (NextWriteInterlace)
    {
    case 0:
        /* PIXEL */
        ncomp = rgb_size[0];
        width = rgb_size[1];
        height = rgb_size[2];
        break;

    case 1:
        /* LINE */
        width = rgb_size[0];
        ncomp = rgb_size[1];
        height = rgb_size[2];
        break;

    case 2:
        /* COMPONENT */
        width = rgb_size[0];
        height = rgb_size[1];
        ncomp = rgb_size[2];
        break;

    default:
        mexErrMsgTxt("Unrecognized or unsupported interlace.");
    }

    if (ncomp != 3)
    {
        mexErrMsgTxt("Input array dimensions not consistent with interlace "
                     "type.");
    }
    
    status = DF24addimage(filename, mxGetData(prhs[3]), width, height);

    plhs[0] = haCreateDoubleScalar((double) status);

    mxFree(filename);
}

/*
 * hdfDF24getimage
 *
 * Purpose: gateway to DF24getimage()
 *
 * MATLAB usage:
 *    [RGB, status] = hdf('DF24', 'getimage', filename)
 */
static void hdfDF24getimage(int nlhs,
                     mxArray *plhs[],
                     int nrhs,
                     const mxArray *prhs[])
{
    char *filename;
    int32 width;
    int32 height;
    int32 ncomp = 3;
    int outputSize[3];
    intn status = FAIL;
    intn interlace;
    mxArray *RGB;

    haNarginChk(3, 3, nrhs);
    haNargoutChk(0, 2, nlhs);

    filename = haGetString(prhs[2], "Filename");

    status = DF24getdims(filename, &width, &height, &interlace);
    if (status == FAIL)
    {
        plhs[0] = EMPTY;
        if (nlhs > 1)
        {
            plhs[1] = haCreateDoubleScalar((double) status);
        }
    }
    else
    {

        if (NextReadInterlace == UNINITIALIZED)
        {
            NextReadInterlace = interlace;
        }

        switch (NextReadInterlace)
        {
        case 0: 
            /* PIXEL */
            outputSize[0] = ncomp;
            outputSize[1] = width;
            outputSize[2] = height;
            break;

        case 1:
            /* LINE */
            outputSize[0] = width;
            outputSize[1] = ncomp;
            outputSize[2] = height;
            break;

        case 2:
            /* COMPONENT */
            outputSize[0] = width;
            outputSize[1] = height;
            outputSize[2] = ncomp;
            break;

        default:
            mexErrMsgTxt("Unrecognized or unsupported interlace.");
        }

        RGB = mxCreateNumericArray(3, outputSize, mxUINT8_CLASS, mxREAL);

        status = DF24getimage(filename, mxGetData(RGB),
                     width, height);

        if (status == SUCCEED)
        {
            plhs[0] = RGB;
        }
        else
        {
            plhs[0] = EMPTY;
            mxDestroyArray(RGB);
        }

        if (nlhs > 1)
        {
            plhs[1] = haCreateDoubleScalar((double) status);
        }
    }

    mxFree(filename);
}

/*
 * hdfDF24setil
 *
 * Purpose: gateway to DF24setil()
 *
 * MATLAB usage:
 *    status = hdf('DF24', 'setil', il)
 *             il can be 'pixel', 'line', or 'component'
 */
static void hdfDF24setil(int nlhs,
                         mxArray *plhs[],
                         int nrhs,
                         const mxArray *prhs[])
{
    int32 il;
    intn status;

    haNarginChk(3, 3, nrhs);
    haNargoutChk(0, 1, nlhs);

    il = haGetInterlaceFlag(prhs[2]);
    status = DF24setil(il);
    if (status == SUCCEED)
    {
        NextWriteInterlace = il;
    }
    plhs[0] = haCreateDoubleScalar((double) status);
}

/*
 * hdfDF24reqil
 * 
 * Purpose: gateway to DF24reqil()
 *
 * MATLAB usage:
 *    status = hdf('DF24', 'reqil', il)
 *             il can be 'pixel', 'line', or 'component'
 */
static void hdfDF24reqil(int nlhs,
                         mxArray *plhs[],
                         int nrhs,
                         const mxArray *prhs[])
{
    int32 il;
    intn status;

    haNarginChk(3, 3, nrhs);
    haNargoutChk(0, 1, nlhs);

    il = haGetInterlaceFlag(prhs[2]);
    status = DF24reqil(il);
    if (status == SUCCEED)
    {
        NextReadInterlace = il;
    }
    plhs[0] = haCreateDoubleScalar((double) status);
}

/*
 * hdfDF24
 *
 * Purpose: Function switchyard for the DF24 part of the HDF gateway.
 *
 * Inputs:  nlhs --- number of left-side arguments
 *          plhs --- left-side arguments
 *          nrhs --- number of right-side arguments
 *          prhs --- right-side arguments
 *          functionStr --- string specifying which DF24 function to call
 * Outputs: none
 * Return:  none
 */
void hdfDF24(int nlhs,
             mxArray *plhs[],
             int nrhs,
             const mxArray *prhs[],
             char *functionStr
             )
{
    void (*func)(int nlhs, mxArray *plhs[], 
                 int nrhs, const mxArray *prhs[]);

    if (strcmp(functionStr, "addimage") == 0)
    {
        func = hdfDF24addimage;
    }
    else if (strcmp(functionStr, "getdims") == 0)
    {
        func = hdfDF24getdims;
    }
    else if (strcmp(functionStr, "getimage") == 0)
    {
        func = hdfDF24getimage;
    }
    else if (strcmp(functionStr, "lastref") == 0)
    {
        func = hdfDF24lastref;
    }
    else if (strcmp(functionStr, "nimages") == 0)
    {
        func = hdfDF24nimages;
    }
    else if (strcmp(functionStr, "putimage") == 0)
    {
        func = hdfDF24putimage;
    }
    else if (strcmp(functionStr, "readref") == 0)
    {
        func = hdfDF24readref;
    }
    else if (strcmp(functionStr, "reqil") == 0)
    {
        func = hdfDF24reqil;
    }
    else if (strcmp(functionStr, "restart") == 0)
    {
        func = hdfDF24restart;
    }
    else if (strcmp(functionStr, "setcompress") == 0)
    {
        func = hdfDF24setcompress;
    }
    else if (strcmp(functionStr, "setdims") == 0)
    {
        func = hdfDF24setdims;
    }
    else if (strcmp(functionStr, "setil") == 0)
    {
        func = hdfDF24setil;
    }
#ifdef HAVE_DF24WRITEREF
    else if (strcmp(functionStr, "writeref") == 0)
    {
        func = hdfDF24writeref;
    }
#endif
    else
    {
        mexErrMsgTxt("Unknown DF24 interface function.");
    }

    (*func)(nlhs, plhs, nrhs, prhs);
}

