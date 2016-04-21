/* Copyright 1984-2002 The MathWorks, Inc.  */

/*
 * hdfdfr8.c --- support file for HDF.MEX
 *
 * This module supports the HDF DFR8 interface.  The only public
 * function is hdfDFR8(), which is called by mexFunction().
 * hdfDFR8 looks at the second input argument to determine which
 * private function should get control.
 *
 * Syntaxes
 * ========
 * status = hdf('DFR8', 'addimage', filename, X, compress)
 *          compress can be 'none', 'rle', 'jpeg', or 'imcomp'
 *
 * [width, height, hasmap, status] = hdf('DFR8', 'getdims', filename)
 *
 * [X, map, status] = hdf('DFR8', 'getimage', filename)
 *
 * ref_num = hdf('DFR8', 'lastref')
 *
 * num_images = hdf('DFR8', 'nimages', filename)
 *
 * status = hdf('DFR8', 'putimage', filename, X, compress)
 *          compress can be 'none', 'rle', 'jpeg', or 'imcomp'
 *
 * status = hdf('DFR8', 'readref', filename, ref_num)
 *
 * status = hdf('DFR8', 'restart')
 *
 * status = hdf('DFR8', 'setcompress', compress_type, ...)
 *          compress_type can be 'none', 'rle', 'jpeg', or 'imcomp'.
 *          If compress_type is 'jpeg', then two additional parameters
 *          must be passed in: quality (number between 0 and 100) and 
 *          force_baseline (logical, 0 or 1).  Other compression
 *          types do not have additional parameters.
 *
 * status = hdf('DFR8', 'setpalette', map)
 *          map must be a 3-by-256 uint8 array (or empty)
 *
 * status = hdf('DFR8', 'writeref', filename, ref_num)
 *
 */

/* $Revision: 1.1.6.1 $  $Date: 2003/12/13 03:01:54 $ */

static char rcsid[] = "$Id: hdfdfr8.c,v 1.1.6.1 2003/12/13 03:01:54 batserve Exp $";

#include <string.h>
#include <math.h>

/* Main HDF library header file */
#include "hdf.h"

/* MATLAB API header file */
#include "mex.h"

/* HDFMEX utility functions */
#include "hdfutils.h"

#include "hdfdfr8.h"

/*
 * hdfDFR8setpalette
 *
 * Purpose: gateway to DFR8setpalette()
 *
 * MATLAB usage:
 * status = hdf('DFR8', 'setpalette', map)
 *          map must be a 3-by-256 uint8 array (or empty)
 */
static void hdfDFR8setpalette(int nlhs,
                       mxArray *plhs[],
                       int nrhs,
                       const mxArray *prhs[])
{
    intn status;
    
    haNarginChk(3, 3, nrhs);
    haNargoutChk(0, 1, nlhs);
    
    if (!mxIsEmpty(prhs[2]))
    {
        if (!mxIsUint8(prhs[2]) || (mxGetNumberOfDimensions(prhs[2]) != 2) ||
            (mxGetM(prhs[2]) != 3) || (mxGetN(prhs[2]) != 256))
        {
            mexErrMsgTxt("MAP must be an 3-by-256 uint8 array or empty");
        }
    }

    /* yes, if map is empty, the next call passes a NULL pointer */
    /* to DFR8setpalette.  That's ok.  -sle */    
    status = DFR8setpalette(mxGetData(prhs[2]));

    plhs[0] = haCreateDoubleScalar((double) status);

}

/*
 * hdfDFR8writeref
 *
 * Purpose: gateway to DFR8writeref()
 *
 * MATLAB usage:
 * status = hdf('DFR8', 'writeref', filename, ref_num)
 */
static void hdfDFR8writeref(int nlhs,
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
    
    status = DFR8writeref(filename, ref);

    plhs[0] = haCreateDoubleScalar((double) status);

    mxFree(filename);
}


/*
 * hdfDFR8setcompress
 *
 * Purpose: gateway to DFR8setcompress()
 *
 * MATLAB usage:
 * status = hdf('DFR8', 'setcompress', compress_type, ...)
 *          compress_type can be 'none', 'rle', 'jpeg', or 'imcomp'.
 *          If compress_type is 'jpeg', then two additional parameters
 *          must be passed in: quality (number between 0 and 100) and 
 *          force_baseline (logical, 0 or 1).  Other compression
 *          types do not have additional parameters.
 */
static void hdfDFR8setcompress(int nlhs,
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

    status = DFR8setcompress(compressFlag, &cinfo);

    plhs[0] = haCreateDoubleScalar((double) status);
}
        


/*
 * hdfDFR8restart
 *
 * Purpose: gateway to DFR8restart()
 *
 * MATLAB usage:
 * status = hdf('DFR8', 'restart')
 */
static void hdfDFR8restart(int nlhs,
                     mxArray *plhs[],
                     int nrhs,
                     const mxArray *prhs[])
{
    intn status;

    status = DFR8restart();

    plhs[0] = haCreateDoubleScalar((double) status);
}        


/*
 * hdfDFR8readref
 * 
 * Purpose: gateway to DFR8readref()
 *
 * MATLAB usage:
 * status = hdf('DFR8', 'readref', filename, ref_num)
 */
static void hdfDFR8readref(int nlhs,
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

    status = DFR8readref(filename, refNum);

    plhs[0] = haCreateDoubleScalar((double) status);

    mxFree(filename);
}


/*
 * hdfDFR8putimage
 *
 * Purpose: gateway to DFR8putimage()
 *
 * MATLAB usage:
 * status = hdf('DFR8', 'putimage', filename, X, compress)
 *          compress can be 'none', 'rle', 'jpeg', or 'imcomp'
 */
static void hdfDFR8putimage(int nlhs,
                     mxArray *plhs[],
                     int nrhs,
                     const mxArray *prhs[])
{
    char *filename = NULL;
    uint16 compressFlag = 100;
    intn status = FAIL;
    int32 width = -1;
    int32 height = -1;

    haNarginChk(5, 5, nrhs);
    haNargoutChk(0, 1, nlhs);

    filename = haGetString(prhs[2], "Filename");

    if (!mxIsUint8(prhs[3]) || (mxGetNumberOfDimensions(prhs[3]) != 2))
    {
        mexErrMsgTxt("X must be a 2-D uint8 array.");
    }

    compressFlag = haGetCompressFlag(prhs[4]);

    width = mxGetM(prhs[3]);
    height = mxGetN(prhs[3]);

    status = DFR8putimage(filename, mxGetData(prhs[3]), width, height,
                          compressFlag);

    plhs[0] = haCreateDoubleScalar((double) status);

    mxFree(filename);
}
    

/*
 * hdfDFR8nimages
 *
 * Purpose: gateway to DFR8nimage()
 *
 * MATLAB usage:
 * num_images = hdf('DFR8', 'nimages', filename)
 */
static void hdfDFR8nimages(int nlhs,
                    mxArray *plhs[],
                    int nrhs,
                    const mxArray *prhs[])
{
    char *filename;
    intn numImages;

    haNarginChk(3, 3, nrhs);
    haNargoutChk(0, 1, nlhs);

    filename = haGetString(prhs[2], "Filename");

    numImages = DFR8nimages(filename);
    
    plhs[0] = haCreateDoubleScalar((double) numImages);
    mxFree(filename);
}

    

/*
 * hdfDFR8lastref
 *
 * Purpose: gateway to DFR8lastref()
 *
 * MATLAB usage:
 * ref_num = hdf('DFR8', 'lastref')
 */
static void hdfDFR8lastref(int nlhs,
                    mxArray *plhs[],
                    int nrhs,
                    const mxArray *prhs[])
{
    uint16 ref;

    haNarginChk(2, 2, nrhs);
    haNargoutChk(0, 1, nlhs);

    ref = DFR8lastref();

    plhs[0] = haCreateDoubleScalar((double) ref);
}

/*
 * hdfDFR8getdims
 *
 * Purpose: gateway to DFR8getdims()
 *
 * MATLAB usage:
 * [width, height, hasmap, status] = hdf('DFR8', 'getdims', filename)
 */
static void hdfDFR8getdims(int nlhs,
                    mxArray *plhs[],
                    int nrhs,
                    const mxArray *prhs[])
{
    char *filename = NULL;
    int32 width = -1;
    int32 height = -1;
    intn hasPalette = -1;
    intn status = FAIL;

    haNarginChk(3, 3, nrhs);
    haNargoutChk(0, 4, nlhs);

    filename = haGetString(prhs[2], "Filename");

    status = DFR8getdims(filename, &width, &height, &hasPalette);
    if (status == SUCCEED)
    {
        plhs[0] = haCreateDoubleScalar((double) width);
        
        if (nlhs > 1)
        {
            plhs[1] = haCreateDoubleScalar((double) height);
        }

        if (nlhs > 2)
        {
            plhs[2] = mxCreateLogicalScalar(hasPalette);
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
 * hdfDFR8addimage
 *
 * Purpose: gateway to DFR8addimage()
 *
 * MATLAB usage:
 * status = hdf('DFR8', 'addimage', filename, X, compress)
 *          compress can be 'none', 'rle', 'jpeg', or 'imcomp'
 */
static void hdfDFR8addimage(int nlhs,
                     mxArray *plhs[],
                     int nrhs,
                     const mxArray *prhs[])
{
    char *filename;
    uint16 compressFlag;
    int32 width;
    int32 height;
    int status;

    haNarginChk(5, 5, nrhs);
    haNargoutChk(0, 1, nlhs);

    if (!mxIsUint8(prhs[3]) || (mxGetNumberOfDimensions(prhs[3]) > 2))
    {
        mexErrMsgTxt("X must be a 2-D uint8 array.");
    }

    filename = haGetString(prhs[2], "Filename");
    compressFlag = haGetCompressFlag(prhs[4]);

    width = mxGetM(prhs[3]);
    height = mxGetN(prhs[3]);

    status = DFR8addimage(filename, mxGetData(prhs[3]), width, height, 
                          compressFlag);

    plhs[0] = haCreateDoubleScalar((double) status);

    mxFree(filename);
}

/*
 * hdfDFR8getimage
 *
 * Purpose: gateway to DFR8getimage()
 *
 * MATLAB usage:
 * [X, map, status] = hdf('DFR8', 'getimage', filename)
 */
static void hdfDFR8getimage(int nlhs,
                     mxArray *plhs[],
                     int nrhs,
                     const mxArray *prhs[])
{
    char *filename;
    int32 width;
    int32 height;
    intn hasPalette;
    intn status;
    int output_size[2];
    mxArray *X;
    mxArray *map;
    uint8 palette[256*3];
    uint8_T *prin;
    uint8_T *prout;
    int k;

    haNarginChk(3, 3, nrhs);
    haNargoutChk(0, 3, nlhs);

    filename = haGetString(prhs[2], "Filename");

    status = DFR8getdims(filename, &width, &height, &hasPalette);
    if (status != SUCCEED)
    {
        /* Failure: return empty X, empty map, status=-1 */
        plhs[0] = EMPTY;

        if (nlhs > 1)
        {
            plhs[1] = EMPTY;
        }
        if (nlhs > 2)
        {
            plhs[2] = haCreateDoubleScalar((double) status);
        }
    }
    else
    {
        output_size[0] = width;
        output_size[1] = height;
        X = mxCreateNumericArray(2, output_size, mxUINT8_CLASS, mxREAL);

        status = DFR8getimage(filename, mxGetData(X),
                     width, height, palette);

        if (status == SUCCEED)
        {
            plhs[0] = X;
        }
        else
        {
            plhs[0] = EMPTY;
            mxDestroyArray(X);
        }

        if (nlhs > 1)
        {
            if (!hasPalette || (status != SUCCEED))
            {
                map = EMPTY;
            }
            else
            {
                output_size[0] = 3;
                output_size[1] = 256;
                map = mxCreateNumericArray(2, output_size, mxUINT8_CLASS, mxREAL);
                prin = (uint8_T *) palette;
                prout = (uint8_T *) mxGetData(map);
                for (k = 0; k < 256*3; k++)
                {
                    *prout++ = *prin++;
                }
            }
            plhs[1] = map;
        }

        if (nlhs > 2)
        {
            plhs[2] = haCreateDoubleScalar((double) status);
        }
    }

    mxFree(filename);
}


/*
 * hdfDFR8
 *
 * Purpose: Function switchyard for the DFR8 part of the HDF gateway.
 *
 * Inputs:  nlhs --- number of left-side arguments
 *          plhs --- left-side arguments
 *          nrhs --- number of right-side arguments
 *          prhs --- right-side arguments
 *          functionStr --- string specifying which DFR8 function to call
 * Outputs: none
 * Return:  none
 */
void hdfDFR8(int nlhs,
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
        func = hdfDFR8addimage;
    }
    else if (strcmp(functionStr, "getdims") == 0)
    {
        func = hdfDFR8getdims;
    }
    else if (strcmp(functionStr, "getimage") == 0)
    {
        func = hdfDFR8getimage;
    }
    else if (strcmp(functionStr, "lastref") == 0)
    {
        func = hdfDFR8lastref;
    }
    else if (strcmp(functionStr, "nimages") == 0)
    {
        func = hdfDFR8nimages;
    }
    else if (strcmp(functionStr, "putimage") == 0)
    {
        func = hdfDFR8putimage;
    }
    else if (strcmp(functionStr, "readref") == 0)
    {
        func = hdfDFR8readref;
    }
    else if (strcmp(functionStr, "restart") == 0)
    {
        func = hdfDFR8restart;
    }
    else if (strcmp(functionStr, "setcompress") == 0)
    {
        func = hdfDFR8setcompress;
    }
    else if (strcmp(functionStr, "setpalette") == 0)
    {
        func = hdfDFR8setpalette;
    }
    else if (strcmp(functionStr, "writeref") == 0)
    {
        func = hdfDFR8writeref;
    }
    else
    {
        mexErrMsgTxt("Unknown DFR8 interface function.");
    }

    (*func)(nlhs, plhs, nrhs, prhs);
}

