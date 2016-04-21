/*
 * File: tiff_utils.c
 *
 * Purpose:  C functions to interface to MEX and the TIFF libraries
 *           MUST be compiled using the MEX compiler
 *
 * $Date: 2003/12/13 03:01:28 $
 * $Id: tiff_utils.h,v 1.1.6.1 2003/12/13 03:01:28 batserve Exp $
 * 
 */

#ifndef TIFF_UTILS_H
#define TIFF_UTILS_H

#include "mex.h"
#include <stdio.h>
#include <string.h>
#include "tiffio.h"

/* Different types of images we can write: */
#define BINARY_IMG 0
#define GRAY_IMG   1
#define INDEX_IMG  2
#define RGB_IMG    3
#define RGBA_IMG   4
#define PACKED_RGB_IMG   5

#define STRLEN 1024



/**
 * writeImageFromMxArray will write the image contained
 * in the mxArray inputArray to the TIFF file pointed to 
 * by the TIFF pointer tif.
 *
 * @param tif is the TIFF pointer to the file to write the image
 * @param inClass is the input data class
 * @param imType is the type of image as denoted
 *               by the image type definitions 
 *               (BINARY_IMG, RGB_IMG, etc)
 * @param inputArray is the MEX array holding the input image
 * @param w is the input image width
 * @param h is the input image height
 * @param rowsPerStrip is the number of rows per TIFF strip.
 */
void writeImageFromMxArray(TIFF *tif,
                           int inClass, int imType,
                           const mxArray *inputArray,
                           int w, int h, int rowsPerStrip); 

/**
 * writeImageFromMxArrayNew writes image data using TIFFWriteEncodedStrip().
 *
 * @param tif            TIFF struct
 * @param inClass        Class ID of input image
 * @param photo          TIFF photometric interpretation
 * @param inputArray     Input image array
 * @param w              image width in pixels
 * @param h              image height in pixels
 * @param spp            samples per pixel
 * @param bytesPerSample bytes per sample
 * @param rowsPerStrip   maximum number of rows per strip
 */
void writeImageFromMxArrayNew(TIFF *tif, 
                              int photo,
                              const mxArray *inputArray, 
                              int w, int h, int spp, 
                              int rowsPerStrip);

/**
 * writeMultisample writes an MxNxP array as a P-sample-per-pixel
 *                  TIFF image.
 *
 * @param tif         TIFF struct
 * @param data        Pointer to image pixels
 * @param w           image width in pixels
 * @param h           image height in pixels
 * @param spp         samples per pixel
 * @param bps         bits per sample
 * @param rps         rows per strip
 */           
void writeMultisample(TIFF *tif, 
                      void *data,
                      int w, 
                      int h, 
                      int spp,
                      int bps,
                      int rps);
/**
 * writeBitsFromLogical will write the image contained
 * in the mxArray inputArray to the TIFF file pointed to 
 * by the TIFF pointer tif. The image type is BINARY_IMG.
 *
 * @param tif is the TIFF pointer to the file to write the image
 * @param inputArray is the MEX array holding the input image
 * @param w is the input image width
 * @param h is the input image height
 * @param rowsPerStrip is the number of rows per TIFF strip.
 */
  void writeBitsFromLogical(TIFF *tif, const mxArray *inputArray, 
                            int w, int h, int rps);

/**
 * writeBytesFromUint8 will write the image contained
 * in the mxArray inputArray to the TIFF file pointed to 
 * by the TIFF pointer tif. The image type is 
 * GRAY_IMG, INDEX_IMG, or BINARY_IMG
 *
 * The input image, inputArray, data type is UINT8
 *
 * @param tif is the TIFF pointer to the file to write the image
 * @param inputArray is the MEX array holding the input image
 * @param w is the input image width
 * @param h is the input image height
 * @param rowsPerStrip is the number of rows per TIFF strip.
 */
  void writeBytesFromUint8(TIFF *tif, const mxArray *inputArray, 
                           int w, int h, int rps);

/**
 * writeBytesFromUint16 will write the image contained
 * in the mxArray inputArray to the TIFF file pointed to 
 * by the TIFF pointer tif. The image type is 
 * GRAY_IMG, INDEX_IMG, or BINARY_IMG
 *
 * The input image, inputArray, data type is UINT16
 *
 * @param tif is the TIFF pointer to the file to write the image
 * @param inputArray is the MEX array holding the input image
 * @param w is the input image width
 * @param h is the input image height
 * @param rowsPerStrip is the number of rows per TIFF strip.
 */
  void writeBytesFromUint16(TIFF *tif, const mxArray *intputArray, 
                            int w, int h, int rps);

/**
 * writeRGBFromUint8 will write the image contained
 * in the mxArray inputArray to the TIFF file pointed to 
 * by the TIFF pointer tif. The image type is an RGB image
 *
 * The input image, inputArray, data type is UINT8
 *
 * @param tif is the TIFF pointer to the file to write the image
 * @param inputArray is the MEX array holding the input image
 * @param w is the input image width
 * @param h is the input image height
 * @param rowsPerStrip is the number of rows per TIFF strip.
 */
  void writeRGBFromUint8(TIFF *tif, const mxArray *inputArray, 
                         int w, int h, int rps);

/**
 * writeRGBFromUint16 will write the image contained
 * in the mxArray inputArray to the TIFF file pointed to 
 * by the TIFF pointer tif. The image type is an RGB image
 *
 * The input image, inputArray, data type is UINT16
 *
 * @param tif is the TIFF pointer to the file to write the image
 * @param inputArray is the MEX array holding the input image
 * @param w is the input image width
 * @param h is the input image height
 * @param rowsPerStrip is the number of rows per TIFF strip.
 */
  void writeRGBFromUint16(TIFF *tif, const mxArray *inputArray, 
                          int w, int h, int rps);

/**
 * writeRGBFromUint32 will write the image contained
 * in the mxArray inputArray to the TIFF file pointed to 
 * by the TIFF pointer tif. The image type is an RGB image
 *
 * The input image, inputArray, data type is UINT32
 *
 * @param tif is the TIFF pointer to the file to write the image
 * @param inputArray is the MEX array holding the input image
 * @param w is the input image width
 * @param h is the input image height
 * @param rowsPerStrip is the number of rows per TIFF strip.
 */
  void writeRGBFromUint32(TIFF *tif, const mxArray *inputArray, 
                          int w, int h, int rps);

/**
 * writeTIFFColormap will write the image colormap contained
 * in the mxArray cmap to the TIFF file pointed to 
 * by the TIFF pointer tif.
 *
 * @param tif is the TIFF pointer to the file to write the colormap
 * @param imType is the type of image as denoted
 *               by the image type definitions 
 *               (BINARY_IMG, RGB_IMG, etc)
 * @param cmap is the MEX array holding the colormap
 * @param w is the input image width
 * @param h is the input image height
 * @param dataClass is the type of data in the cmap mxArray
 */
  void writeTIFFColormap(TIFF *tif, int imType, 
                         const mxArray *cmap, int dataClass);

void writeTIFFColormapNew(TIFF *tif, int photo, const mxArray *cmap, int dataClass);

/**
 * writeImageFromMxArray will write the image contained
 * in the mxArray inputArray to the TIFF file pointed to 
 * by the TIFF pointer tif.
 *
 * @param tif is the TIFF pointer to the image file 
 * @param inClass is the image data class
 * @param imType is the type of image as denoted
 *               by the image type definitions 
 *               (BINARY_IMG, RGB_IMG, etc)
 * @param ndims is the number of dimensions of the image (1, 2, or 3)
 * @param w is the input image width
 * @param h is the input image height
 * @param desArray is the MEX array holding the description of the image
 * @param comp is the TIFF tag number for the compression type
 * @param xres is the resolution of the image in the X direction
 * @param yres is the resolution of the image in the Y direction
 * @param resolutionUnit is the TIFF resolution per unit
 * @param samplesPerPixel is the TIFF samples per pixel
 * @param rowsPerStrip is the number of rows per TIFF strip.
 */
  void writeTIFFTags( TIFF *tif,
                    int inClass, int imType,
                    int ndims, int w, int h,
                    const mxArray *desArray,
                    int comp,
                    unsigned short resolutionUnit,
                    unsigned short samplesPerPixel,
                    float xres, float yres, int rowsPerStrip);

/**
 * writeTIFFTagsNew writes a standard set of TIFF tags into the libtiff TIFF struct.
 *
 * @param tif      TIFF struct
 * @param inClass  class ID of the input image
 * @param photo    TIFF photometric interpretation of the image
 * @param w        image width in pixels
 * @param h        image height in pixels
 * @param desArray MATLAB string array containing the image description, or NULL
 * @param comp     compression method
 * @param resUnit  unit of measurement corresponding to the resolution tag
 * @param spp      number of samples per image pixel
 * @param xres     spatial resolution in the horizontal direction
 * @param yres     spatial resolution in the vertical direction
 * @param rps      number of rows per strip
 */
void writeTIFFTagsNew( TIFF *tif,
                       int inClass, int photo,
                       int w, int h, 
                       const mxArray *desArray,
                       int comp,
                       unsigned short resUnit,
                       unsigned short spp,
                       float xres, float yres, int rps);

/**
 * getImType will return the image type based on the input parameters.
 *
 * @param ndims is the number of dimensions of the image (1, 2, or 3)
 * @param inClass is the image data class
 * @param size is the height and width values in an array
 * @param mapArray is the colormap index (null if not available)
 * @param inputArray is the input image array
 *
 * @return the image type definition
 */
  int getImType(int ndims, int inClass, const int *size,
                const mxArray *mapArray, const mxArray *inputArray);

/**
 * getSamplesPerPixel will return the number of samples per image pixel.
 *
 * @param inputArray is the input image array
 *
 * @return the number of samples per image pixel
 */
int getSamplesPerPixel(const mxArray *inputArray);

/**
 * getPhotometricInterpretation returns the TIFF photometric interpretation.
 *
 * @param inClass is the class ID of the input image
 * @param samplesPerPixel is the number of samples per image pixel
 * @param emptyMap is a boolean; true if the input colormap array is empty
 * @param colorspaceArray is the input colorspace array; it can be NULL
 *                        if not present
 *
 * @return the photometric interpretation value for use with TIFFSetField().
 */
int getPhotometricInterpretation(int inClass,
                                 int samplesPerPixel,
                                 bool emptyMap,
                                 const mxArray *colorspaceArray);

/**
 * getComp will return the image compression TIFF tag value
 *
 * @param compArray the mxArray string denoting the desired compression
 * @param imType the image type returned by getImType
 *
 * @return the TIFF compression value
 */
  int getComp(const mxArray *compArray, int imType);

int getCompNew(const mxArray *compArray, int photo);

/**
 * getTIFFFIlename will return the character string 
 * name for the file from the mxArray
 *
 * @param fnameArray the mxArray containg the TIFF filename
 * @return the char filename
 */
  char *getTIFFFilename(const mxArray *fnameArray);

/**
 * getRowsPerStrip will return the number of rows per strip
 * required based on the image type and the image width
 *
 * @param imType the image type
 * @param w the image width
 */
  int getRowsPerStrip(int imType, int w);

/**
 * getRowsPerStripNew returns the recommended number of rows 
 * per strip.
 *
 * @param photo the TIFF photometric interpretation
 * @param w the image width
 * @param spp the number of samples per image pixel
 *
 * @return the number of rows per strip; at least 1
 */
int getRowsPerStripNew(int photo, int w, int spp);

/**
 * mexErrHandler will output error messages through the MEX interface.
 */
  void MexErrHandler(const char *module, const char *fmt, va_list ap);

/**
 * mexWarnHandler will output warning messages through the MEX interface.
 */
  void MexWarnHandler(const char *module, const char *fmt, va_list ap);

#endif
