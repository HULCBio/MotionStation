/*
 * WTIFC.MEX
 * 
 * This is a mex interface to LIBTIFF for writing TIFF files.
 * 
 * The syntaxes are:
 *   
 *     wtifc(CMYK, [], filename, compression, description, resolution, overwrite);
 *     wtifc(A, [], filename, compression, description, resolution, overwrite, colorspace);
 *     wtifc(RGB, [], filename, compression, description, resolution, overwrite);
 *     wtifc(GRAY, [], filename, compression, description, resolution, overwrite);
 *     wtifc(X, map, filename, compression, description, resolution, overwrite);
 *   
 * RGB is an mxnx3 uint8 array, an mxnx3 uint16 array, or a mxn uint32 array [with 
 * each 4 bytes being RGBA, were A is currently garbage (maybe 
 * Alpha in the future)] containing a 24-bit image to
 * be stored in the TIFF file filename.    
 * 
 * GRAY is a mxn uint8 or uint16 array containing a grayscale image to
 * be stored in the TIFF file filename.    
 * 
 * X is a uint8 array of indices into the colormap map.
 * map is an M-by-3 uint8 array, where M <= 256.
 *
 * The compression string allows a choice between the following
 * compression schemes:
 * "packbits"   Runlength encoding (default)
 * "ccitt"      CCITT Group 3 1-D Modified Huffman RLE alg.
 * "packbits"   Macintosh PackBits algorithm
 * "thunder"    ThunderScan 4-bit RLE algorithm
 * "next"       NeXT 2-bit RLE algorithm
 * "none"       No compression
 *
 * The resolution is the same for both X and Y. 
 * 
 * The overwrite flag indicates whether we should overwrite an existing
 * file (if overwrite is 1) or append to an existing file (if overwrite
 * is 0).
 *
 * 
 * KNOWN BUGS:
 * -----------
 *    Thunderscan compression isn't correctly implemented yet. 
 *    NeXT compression isn't correctly implemented yet.
 *    
 * ENHANCEMENTS UNDER CONSIDERATION:
 * ---------------------------------
 *    Add CCITT Fax3 and Fax4 writing support 
 *      (probably very simple since CCITTRLE is already implemented.)
 *    Allow tifwrite to write tiled tiff images.
 *
 * 
 * Copyright 1984-2003 The MathWorks, Inc. 
 * $Revision: 1.1.6.1 $  $Date: 2003/12/13 03:01:45 $
 */

#include "mex.h"
#include <stdio.h>
#include <string.h>
#include "tiffio.h"
#include "tiff_utils.h"

void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[]) {
    
/* Pointer from the TIFFOpen for writing */
    TIFF *tif;

/* The input data from MATLAB */
    const mxArray *inputArray, *mapArray;
    const mxArray *fnameArray, *compArray, *desArray, *resArray;
    const mxArray *colorspaceArray;

/* Number of dimensions for input array */
    int ndims;                    

/* The size of the image */
    const int *size;

/* The output filename */
    char *filename;
    long stringlen;

/* width, height, and number of planes */
    int w,h;                    
/* Compression */
    int comp;                     
/* Will we overwrite or append? Default is overwrite*/
    int overwrite=1;            

/* The image type and the image class */
    int inClass;

/* The number of rows per strip (calculated) */
    int rowsPerStrip;

    int samplesPerPixel;
    int photo;

/* Resolution parameters */
    unsigned short resolutionUnit = 2;   /* Always */
    float xres, yres;
    
/**
 * Check the number of input arguments
 */
    if (nrhs < 6 || nrhs > 8) {
        mexErrMsgTxt("Illegal number of input arguments.");
    }      

/**
 * Set the handlers to write TIFF warnings and error with MEX functions
 */
    TIFFSetErrorHandler(MexErrHandler);
    TIFFSetWarningHandler(MexWarnHandler);
    
    
/**
 * Assign the inputs from the input MATLAB arguments
 * First argument is the image data 
 */
    inputArray = prhs[0];         
    mapArray   = prhs[1];
    fnameArray = prhs[2];
    compArray  = prhs[3];
    desArray   = prhs[4];
    resArray   = prhs[5];
    overwrite  = (int) mxGetScalar(prhs[6]);
    colorspaceArray = (nrhs > 7) ? prhs[7] : NULL;

/* 
 * Get the Class Id of the input image
 */
    inClass = mxGetClassID(inputArray); 

/**
 * Get the number of dimensions of the input image
 */
    ndims = mxGetNumberOfDimensions(inputArray);

/**
 * Assign the x and y resolution values
 */
    setXYRes(resArray, &xres, &yres);

/**
 * Get the size and assign the height and width
 */
    size = mxGetDimensions(inputArray);
    h = size[0];
    w = size[1];

    samplesPerPixel = getSamplesPerPixel(inputArray);
    photo = getPhotometricInterpretation(mxGetClassID(inputArray), 
                                         samplesPerPixel,
                                         mxIsEmpty(mapArray),
                                         colorspaceArray);

/**
 * Get the image compression value
 */
    comp = getCompNew(compArray, photo);

/**
 * Get the input filename
 */
    filename = getTIFFFilename(fnameArray);

/** 
 * Open the TIFF file for writing 
 */ 
    if (overwrite) {
      if ((tif = TIFFOpen(filename, "w")) == NULL) 
        mexErrMsgTxt("Couldn't open TIFF file for writing.");
    }
    else {
      if ((tif = TIFFOpen(filename, "a")) == NULL) 
            mexErrMsgTxt("Couldn't open TIFF file for append.");
    }
    mxFree((void *) filename);

/**
 * Write the TIFF Tags to the file
 */ 
    rowsPerStrip = getRowsPerStripNew(photo, w, samplesPerPixel);
    writeTIFFTagsNew(tif, inClass, photo, 
                     w, h, desArray, comp, resolutionUnit,
                     samplesPerPixel, xres, yres, rowsPerStrip);
    
/**
 * Write the TIFF colormap to the file
 */
    writeTIFFColormapNew(tif, photo, mapArray, inClass);

/* 
 * Write the image data 
 */ 
    writeImageFromMxArrayNew(tif, photo, inputArray, w, h, 
                             samplesPerPixel, rowsPerStrip);

/**
 * Close the file
 */
    TIFFClose(tif);
    return;
}


