/*
 * RTIFC.MEX
 * 
 * This is a mex interface to the Sam Leffler's LIBTIFF library which
 * will allow many variants of TIFF images to be read.
 * 
 * The syntaxes are:
 *
 *     [RGB,MAP,DETAILS] = rtifc (filename) 
 *     [GRAY,MAP,DETAILS] = rtifc (filename)
 *     [SAMPLES,MAP,DETAILS] = rtifc (filename)
 *     [X,MAP,DETAILS] = rtifc (filename)
 *     ... = rtifc (filename, n)
 *     ... = rtifc (filename, n, region)
 *   
 * RGB is a mxnx3 uint8 array containing the 24-bit image stored in
 * the tiff file filename.     
 * 
 * GRAY is a mxn uint8 array containing the grayscale image stored in
 * the tiff file filename.   
 *
 * SAMPLES is an mxnxp uint8 or uint16 array containing the 8 or 16-bit
 * data stored in in a multisample image (such as CMYK).  "p" is the
 * number of samples in the image.
 *
 * X is an mxn uint8 array containing indices into the colormap map,
 * which is returned as uint16 (unsigned short).       
 *
 * MAP is the colormap.  MAP is [] for images that are not paletted.
 *
 * DETAILS is a structure containing the value of several TIFF
 * properties that are needed in the M-file wrapper (such as image and
 * tile sizes and PhotometricInterpretation).
 *
 * The region input argument specifies is a MATLAB structure whose
 * values specify an image subregion to read.
 *
 * Read the image from the n'th directory in the TIFF file.   When n is
 * not specified, the default is to read from the first directory in
 * the file.  
 *
 * KNOWN BUGS:
 * -----------
 *    Reading Thunderscan compression isn't correctly implemented yet. 
 *    
 * 
 * Copyright 1984-2004 The MathWorks, Inc. 
 * $Revision: 1.1.6.2 $  $Date: 2004/02/01 22:04:56 $
 */

static char rcsid[] = "$Id: rtifc.c,v 1.1.6.2 2004/02/01 22:04:56 batserve Exp $";


#include "mex.h"
#include <stdio.h>
#include <string.h>
#include "tiffio.h"


/* Different types of images: */
#define PHOTO_WHITE_IS_ZERO   0
#define PHOTO_BLACK_IS_ZERO   1
#define PHOTO_RGB             2
#define PHOTO_INDEXED         3
#define PHOTO_RGBA            4
#define PHOTO_CMYK            5
#define PHOTO_YCBCR           6
#define PHOTO_CIELAB          8


/* Buffer for error handler */
static char *ERROR_BUFFER;


/* Data objects to keep track of details. */
typedef struct {
    uint32 width;
    uint32 height;
    uint16 samplesPerPixel;
    uint16 bps;
    uint16 photometricInterp;
    uint16 compressionType;
    bool   isTiled;
    uint16 extentRows;
    uint16 extentCols;
} IMAGE;

typedef struct {
    uint32 width;
    uint32 height;
} TILE;

typedef struct {
    uint32_T minX;
    uint32_T maxX;
    uint32_T minY;
    uint32_T maxY;
} REGION;


/* Subroutines */
static void ErrHandler(const char *, const char *, va_list);
static void WarnHandler(const char *, const char *, va_list);
static void CloseAndError(TIFF *);
static void setMessageHandlers(void);
static void validateArgs(int nlhs, mxArray *plhs[],
                         int nrhs, const mxArray *prhs[]);
static void openFile(TIFF **tif, const mxArray *prhs[]);
static void selectIFD(TIFF **tif, int dirnum);
static void getImageDetails(TIFF *tif, IMAGE *imageDetails);
static void getTileDetails(TIFF *tif, TILE *tileDetails);
static void createOutputArray(mxArray **outArray, IMAGE *imageDetails);
static void readStripImage(TIFF *tif, IMAGE *imageDetails,
                           mxArray **outArray);
static void readTiledImage(TIFF *tif, IMAGE *imageDetails, TILE *tileDetails,
                           mxArray *outArray, REGION *regionDetails);
static void readTile(TIFF *tif, TILE *tileDetails, uint32 x, uint32 y, 
                     uint32 z, void * tileBuffer);
static void changeMajority(uint8 *post_buffer, uint8 *pre_buffer, 
                           TILE *tileDetails);
static void StuffContigTileBufferIntoRGB(TIFF*,uint8_T*,int,int,uint8_T*,uint8_T*,uint8_T*);
static void getNthKbitNumberFromScanline(void *,int,int,uint8_T *);
static mxArray *GetColormap(TIFF* , uint16_T);
static mxArray *ReadIndexedGrayOrBinaryImage(TIFF *);
static mxArray *ReadRGBImage(TIFF *);
static mxArray *ReadNSampleImage(TIFF *);
static void complementImage(IMAGE *imageDetails, mxArray *outArray);
static mxArray * buildDetailsStruct(IMAGE *imageDetails, TILE *tileDetails);
static void computeExtent(IMAGE *imageDetails, TILE *tileDetails,
                          REGION *regionDetails);
static void getRegionDetails(REGION *regionDetails,
                             const mxArray *regionStruct,
                             IMAGE *imageDetails, 
                             TILE *tileDetails);
static void storeTile(IMAGE *imageDetails, TILE *tileDetails, 
                      REGION *regionDetails,
                      uint32 x, uint32 y, uint32 z,
                      uint8 *imageArray, uint8 *tileBuffer);
static void cleanup(TIFF *tif, IMAGE *imageDetails, TILE *tileDetails,
                    REGION *regionDetails);



void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[]) {

    TIFF *tif;
    IMAGE *imageDetails = NULL;
    TILE *tileDetails = NULL;
    REGION *regionDetails = NULL;
    mxArray *outArray;
    const mxArray *regionStruct = NULL;
    int dirnum = 1;

    /* Set up. */
    setMessageHandlers();
    validateArgs(nlhs, plhs, nrhs, prhs);

    openFile(&tif, prhs);

    /* Set image directory to read. */
    if (nrhs >= 2)
    {
        dirnum = (int) mxGetScalar(prhs[1]);
    }
    selectIFD(&tif, dirnum);

    /* Get image and tile details. */
    imageDetails = (IMAGE *) mxMalloc(sizeof(IMAGE));
    getImageDetails(tif, imageDetails);

    if (nrhs >= 3)
    {
        regionStruct = prhs[2];
    }

    if (imageDetails->isTiled)
    {
        tileDetails = (TILE *) mxMalloc(sizeof(TILE));
        getTileDetails(tif, tileDetails);

        regionDetails = (REGION *) mxMalloc(sizeof(REGION));
        getRegionDetails(regionDetails, regionStruct, 
                         imageDetails, tileDetails);
        computeExtent(imageDetails, tileDetails, regionDetails);
    }

    /* Check for unsupported compression modes. */
    if (imageDetails->compressionType == COMPRESSION_LZW)
    {
        cleanup(tif, imageDetails, tileDetails, regionDetails);
        mexErrMsgTxt("LZW-compressed TIFF images are not supported.");
    }
    else if ((imageDetails->compressionType == COMPRESSION_JPEG) ||
             (imageDetails->compressionType == COMPRESSION_OJPEG))
    {
        cleanup(tif, imageDetails, tileDetails, regionDetails);
        mexErrMsgTxt("JPEG-compressed TIFF images are not supported.");
    }

    /* Read the image and colormap. */
    if (imageDetails->isTiled)
    {

        if (imageDetails->bps > 8)
        {
            cleanup(tif, imageDetails, tileDetails, regionDetails);
            mexErrMsgTxt("Tiled images must have 8 bits per sample or less.");
        }

        createOutputArray(&outArray, imageDetails);
        readTiledImage(tif, imageDetails, tileDetails, 
                       outArray, regionDetails);

        if (imageDetails->photometricInterp == PHOTO_WHITE_IS_ZERO)
        {
            complementImage(imageDetails, outArray);
        }
    }
    else
    {
        readStripImage(tif, imageDetails, &outArray);
    }

    if ((imageDetails->photometricInterp == PHOTO_INDEXED) &&
        (nlhs > 1))
    {
        plhs[1] = GetColormap(tif, imageDetails->bps);
    }

    /* Close the file, set outputs, and clean up. */
    TIFFClose(tif);
    tif = NULL;

    plhs[0]=outArray;
    
    if ( (nlhs > 1) && (plhs[1] == NULL) )
        plhs[1] = mxCreateDoubleMatrix(0, 0, mxREAL);
    
    if (nlhs > 2)
        plhs[2] = buildDetailsStruct(imageDetails, tileDetails);

    cleanup(tif, imageDetails, tileDetails, regionDetails);
    return;

}


/*
** ReadIndexedGrayOrBinaryImage
** 
** This subroutine will read the image data from the TIFF file and return it
** in a MATLAB array.  The image type should be either Indexed, Grayscale or
** Binary.  This routine doesn't do anything with colormaps.
** For Grayscale, it can read 8 or 16 bit images.  I think it will read
** a 16 bit Indexed image, but I could never create or find one to test
** with.
*/

static mxArray *
ReadIndexedGrayOrBinaryImage(TIFF *tif)             /* Grayscale, Binary, or Indexed Image */
{
    mxLogical *ptrLogical;
    uint8_T  *ptrUint8, out8;
    uint16_T *ptrUint16, out16;
    uint32_T *ptrUint32, out32;
    real32_T *ptrFloat32;
    mxArray *outArray;
    int pixmax;             /* Maximum allowable pixel value (1<<bps)-1 */
    unsigned long row,col,imcol;
    uint16 bps,spp,photo,sampleFormat=SAMPLEFORMAT_UINT;
    unsigned int scanlineSize, bit;
    uint32 imageWidth,imageHeight;         /* image width, height */
    int dims[3];         /* For the calls to mxCreateNumericArray */
    uint8_T bytebuffer[8];
    uint8_T   *scanline8, *scanline16, *scanline32;
    uint16_T  *buf_int_16;
    uint32_T  *buf_int_32;
    real32_T  *buf_float_32;

  /* TIFFGetField only errors if asked for a field which doesn't exist in
   * the spec.  Consequently, we needn't wrap calls to it in error-handling
   * routines. */
    TIFFGetField(tif, TIFFTAG_PHOTOMETRIC, &photo);
    TIFFGetField(tif, TIFFTAG_IMAGEWIDTH, &imageWidth);
    TIFFGetField(tif, TIFFTAG_IMAGELENGTH, &imageHeight);
    TIFFGetFieldDefaulted(tif, TIFFTAG_SAMPLESPERPIXEL, &spp);
    TIFFGetFieldDefaulted(tif, TIFFTAG_BITSPERSAMPLE, &bps);
    TIFFGetField(tif, TIFFTAG_SAMPLEFORMAT, &sampleFormat);


    /* 
     *  Comment out the following four lines to enable reading of N-bit UINT packed 
     *  images (16<N<32), 32 bit integer and 32 bit floating point images          
     */


    if(bps>16) {
        TIFFClose(tif);
        mexErrMsgTxt("Cannot read images with greater than 16 bits per sample.");
    }

  
    dims[0]  = imageHeight;                 /* Image Height */
    dims[1]  = imageWidth;                 /* Image Width  */
    dims[2]  = 1;
    
    pixmax = (1<<bps)-1;          /* Maximum allowable pixel value */

    if(sampleFormat==SAMPLEFORMAT_IEEEFP) {
        if (bps==32) {
            outArray = mxCreateNumericArray(2, dims, mxSINGLE_CLASS, mxREAL); 
            ptrFloat32 = (real32_T *) mxGetData(outArray);
        }
        else {
            TIFFClose(tif);
            mexErrMsgTxt("Unsupported bit-depth for IEEE floating point data.");
        }
    }
    else {  
        /* It must be a SAMPLEFORMAT_UINT.  I don't explicitly test for this
        ** due to a bug in LIBTIFF where it doesn't always return the right
        ** value for SAMPLEFORMAT_UINT. */
	if(bps == 1) {
	    outArray = mxCreateLogicalArray(2, dims);
	    ptrLogical = mxGetLogicals(outArray);
	} else if (bps>1 && bps<=8) {
            outArray = mxCreateNumericArray(2, dims, mxUINT8_CLASS, mxREAL); 
            ptrUint8 = (uint8_T *) mxGetData(outArray);
        } 
        else if (bps>8 && bps<=16) {
            outArray = mxCreateNumericArray(2, dims, mxUINT16_CLASS, mxREAL); 
            ptrUint16 = (uint16_T *) mxGetData(outArray);
        }
        else if (bps>16 && bps<=32) {
            outArray = mxCreateNumericArray(2, dims, mxUINT32_CLASS, mxREAL); 
            ptrUint32 = (uint32_T *) mxGetData(outArray);
        }
        else {
            TIFFClose(tif);
            mexErrMsgTxt("Unsupported bit-depth for integer image data.");
        }
    }
    
    if(TIFFIsTiled(tif)){
        TIFFClose(tif);
        mexErrMsgTxt("Tiled TIFF images are not supported");
    }


    /* Image is organized in strips */
    scanlineSize = TIFFScanlineSize(tif);


    /* 8-bit Gray or Indexed */
    if(bps == 8)          
    {
        scanline8 = (uint8_T *) mxCalloc(scanlineSize, sizeof(mxUINT8_CLASS));
        for (row = 0; row < imageHeight; row++)
        {
            if (TIFFReadScanline(tif, scanline8, row, 0) == -1)
                CloseAndError(tif);

            for (col = 0; col < imageWidth; col++)
            {
                if (photo==0) /* White is Zero - complement */
                    ptrUint8[row+(col*imageHeight)] = (pixmax)-scanline8[col];
                else          /* Black is zero */
                    ptrUint8[row+(col*imageHeight)] = scanline8[col];
            }
        }        
        mxFree(scanline8);
    }
    
    /* 16-bit Grayscale or Indexed */
    else if (bps == 16)   
    {
        buf_int_16 = (uint16_T *) mxCalloc(scanlineSize, sizeof(mxUINT16_CLASS));
        for (row = 0; row < imageHeight; row++)
        {
            if (TIFFReadScanline(tif, buf_int_16, row, 0) == -1)
                CloseAndError(tif);

            for (col = 0; col < imageWidth; col++)
            {
                if (photo==0) /* White is Zero - complement */
                    ptrUint16[row+(col*imageHeight)] = (pixmax)-buf_int_16[col];
                else          /* Black is zero */
                    ptrUint16[row+(col*imageHeight)] = buf_int_16[col];
            }
        }        
        mxFree(buf_int_16);
    }
    
    /* 32-bit Grayscale */
    else if ((bps == 32) && (sampleFormat!=SAMPLEFORMAT_IEEEFP))
    {
        buf_int_32 = (uint32_T *) mxCalloc(scanlineSize, sizeof(mxUINT32_CLASS));
        for (row = 0; row < imageHeight; row++)
        {
            if (TIFFReadScanline(tif, buf_int_32, row, 0) == -1)
                CloseAndError(tif);

            for (col = 0; col < imageWidth; col++)
            {
                if (photo==0) /* White is Zero - complement */
                    ptrUint32[row+(col*imageHeight)] = (pixmax)-buf_int_32[col];
                else          /* Black is zero */
                    ptrUint32[row+(col*imageHeight)] = buf_int_32[col];
            }
        }        
        mxFree(buf_int_32);
    }
    
    /* 32 bit floating point grayscale image */
    else if ((bps == 32) && (sampleFormat==SAMPLEFORMAT_IEEEFP))
    {
        buf_float_32 = (real32_T *) mxCalloc(scanlineSize, sizeof(mxSINGLE_CLASS));
        for (row = 0; row < imageHeight; row++)
        {
            if (TIFFReadScanline(tif, buf_float_32, row, 0) == -1)
                CloseAndError(tif);

            for (col = 0; col < imageWidth; col++)
            {
                if (photo==0) { /* White is Zero - complement */
                    TIFFClose(tif);
                    mexErrMsgTxt("Floating point TIFF file has Photometric 0 (White is 0).");
                }
                else          /* Black is zero */
                    ptrFloat32[row+(col*imageHeight)] = buf_float_32[col];
            }
        }        
        mxFree(buf_float_32);
    }

    else if (bps == 4)
    {
        scanline8 = (uint8_T *) mxCalloc(scanlineSize, sizeof(mxUINT8_CLASS));
        for (row = 0; row < imageHeight; row++)
        {
            if (TIFFReadScanline(tif, scanline8, row, 0) == -1)
                CloseAndError(tif);

            for (col = 0, imcol = 0; col < scanlineSize; col++)
            {
                if (imcol < imageWidth)
                {
                    ptrUint8[row + imcol*imageHeight] = 
                        (scanline8[col] >> 4) & 0x0F;
                    imcol++;
                }
                if (imcol < imageWidth)
                {
                    ptrUint8[row + imcol*imageHeight] =
                        (scanline8[col] & 0x0F);
                    imcol++;
                }
            }
        }
        mxFree(scanline8);
    }

    /* Binary */
    else if(bps == 1)     
    {
        /* Read the binary image into an 8-bit MATLAB array */
        scanline8 = (uint8_T *) mxCalloc(scanlineSize, sizeof(mxUINT8_CLASS));
        for (row = 0; row < imageHeight; row++)
        {
            if (TIFFReadScanline(tif, scanline8, row, 0) == -1)
                CloseAndError(tif);

            for(col=0; col < scanlineSize; col++)
            {
                
                if(photo==0) /* White is zero */
                    for(bit=0;bit<8;bit++)
                    {
                        bytebuffer[7-bit] = ! ((scanline8[col]>>bit) & 1);
                    }
                else      /* Black is zero */
                    for(bit=0;bit<8;bit++)
                    {
                        bytebuffer[7-bit] = (scanline8[col]>>bit) & 1;
                    }                          
                
                for(bit=0; bit<8 && (8*col+bit)<imageWidth; bit++)
                {
                    ptrLogical[row+((8*col+bit)*imageHeight)] = bytebuffer[bit];
                }
            }
        }
        mxFree(scanline8);
    }


    /* Tightly packed non-standard integer sizes, for example: 11-bit Grayscale Kodak images */
    else if(bps<32)   
    {
        /* Allocate a scanline of the appropriate size */

        if (bps>1 && bps<8)   /* We're using uint8's */
            scanline8 = (uint8_T *) mxCalloc(scanlineSize, sizeof(uint8_T));
        else if(bps>8 && bps<16) /* We're using uint16's */
            scanline16 = (uint8_T *) mxCalloc(scanlineSize, sizeof(uint16_T));
        else if(bps>16 && bps<32) /* We're using uint32's */
            scanline32 = (uint8_T *) mxCalloc(scanlineSize, sizeof(uint32_T));

        /* Read the data into scanline, and copy it to the output array */

        for (row = 0; row < imageHeight; row++)
        {

            if (bps>1 && bps<8) {  /* We're using uint8's */
                if (TIFFReadScanline(tif, scanline8, row, 0) == -1)
                    CloseAndError(tif);

                for(col=0; col < imageWidth; col++) 
                {
                    getNthKbitNumberFromScanline(&out8, col, bps, scanline8);
                    if (photo==0) /* White is Zero - complement */
                        ptrUint8[row+(col*imageHeight)] = (pixmax)-(out8); 
                    else          /* Black is zero */
                        ptrUint8[row+(col*imageHeight)] = out8; 
                }
            }
            
            else if(bps>8 && bps<16) { /* We're using uint16's */
                if (TIFFReadScanline(tif, scanline16, row, 0) == -1)
                    CloseAndError(tif);

                for(col=0; col < imageWidth; col++)  
                {
                    getNthKbitNumberFromScanline(&out16, col, bps, scanline16);                    
                    if (photo==0) /* White is Zero - complement */
                        ptrUint16[row+(col*imageHeight)] = (pixmax)-(out16); 
                    else          /* Black is zero */
                        ptrUint16[row+(col*imageHeight)] = out16; 
                }
            }

            else if(bps>16 && bps<32) { /* We're using uint32's */
                if (TIFFReadScanline(tif, scanline32, row, 0) == -1)
                    CloseAndError(tif);

                for(col=0; col < imageWidth; col++)  
                {
                    getNthKbitNumberFromScanline(&out32, col, bps, scanline32);                    
                    if (photo==0) /* White is Zero - complement */
                        ptrUint32[row+(col*imageHeight)] = (pixmax)-(out32); 
                    else          /* Black is zero */
                        ptrUint32[row+(col*imageHeight)] = out32; 
                }
            }
        }
        
        if (bps>1 && bps<8)   
            mxFree(scanline8);
        else if(bps>8 && bps<16)
            mxFree(scanline16);
        else if(bps>16 && bps<32)
            mxFree(scanline32);
    }
    
    return outArray;
}

/*
** getNthKbitNumberFromScanline
**
** getNthKbitNumberFromScanline(void *out, int n, int bps, uint8_T *scanline)
** INPUTS:
**    void *out  - this is the integer (uint8, uint16, or uint32) which we
**                 will be writing to.
**    int n      - We will get the n'th integer from the scanline. n=0 gets
**                 the first integer.
**    int bps    - This is k, or the number of bits per integer we are 
**                 getting.
**    uint8 scanline - the scanline
*/

static void
getNthKbitNumberFromScanline(void *out, int n, int bps, uint8_T *scanline)
{
    uint8_T *out8, temp8, bit;
    uint16_T *out16;
    uint32_T *out32;
    uint32_T byteIdx;
    int  bitIdx;
    int i;
    
    byteIdx = n * bps / 8;         /* the first byte we will be looking at */
    bitIdx = 7 - ((n * bps) % 8);  /* index of the bit within byte byteIdx */

    /* Case 1: The output is stored in uint8's */
    if(bps>=1 && bps<=8) {
        out8 = (uint8_T *) out;     /* out8 points to the same integer as out */
        *out8 = 0;                  /* Make sure we start out with a bunch of 0's */
        temp8 = scanline[byteIdx];

        for(i=bps-1; i>=0; i--) {
            bit = (temp8>>bitIdx) & (uint8_T) 1;       /* get bit from scanline */
            *out8 =  *out8 | (bit << i);                  /* put bit into output integer */
            bitIdx--;

            /* See if we crossed a byte boundary */
            if(bitIdx<0) {
                bitIdx = 7;
                byteIdx++;
                temp8 = scanline[byteIdx];
            }
        }
    }
    
    /* Case 2: The output is stored in uint16's */
    else if(bps>8 && bps<=16) {
        out16 = (uint16_T *) out; 
        *out16 = 0;               
        temp8 = scanline[byteIdx]; 

        for(i=bps-1; i>=0; i--) {
            bit = (temp8>>bitIdx) & (uint8_T) 1;       /* get bit from scanline */
            *out16 = *out16 | (bit << i);                /* put bit into output integer */
            bitIdx--;

            /* See if we crossed a byte boundary */
            if(bitIdx<0) {
                bitIdx = 7;
                byteIdx++;
                temp8 = scanline[byteIdx];
            }
        }
    }

    /* Case 3: The output is stored in uint32's */
    else if(bps>16 && bps<=32) {
        out32 = (uint32_T *) out; /* out32 points to the same integer as out */
        *out32 = 0;               /* Meke sure we start out with a bunch of 0's */
        temp8 = scanline[byteIdx]; 

        for(i=bps-1; i>=0; i--) {
            bit = (temp8>>bitIdx) & (uint8_T) 1;       /* get bit from scanline */
            *out32 = *out32 | (bit << i);                /* put bit into output integer */
            bitIdx--;

            /* See if we crossed a byte boundary */
            if(bitIdx<0) {
                bitIdx = 7;
                byteIdx++;
                temp8 = scanline[byteIdx];
            }
        }
    }
    else
        mexErrMsgTxt("Too many bits-per-sample for packed integer data.");
}

/*
** ReadRGBImage
** 
** This subroutine will read the image data from the TIFF file and return it
** in a MATLAB array.  The image type should be RGB Truecolor, 8 or 16 bits.
*/

static mxArray *
ReadRGBImage(TIFF *tif)             /* RGB Image */
{
    uint8_T  *ptrRed8,  *ptrGreen8,  *ptrBlue8;  /* RGB arrays */
    uint16_T *ptrRed16, *ptrGreen16, *ptrBlue16;
    mxArray *outArray;
    uint32_T i,j,row,col;
    uint16 bps,spp,config,sampleFormat;
    uint32 imageWidth,imageHeight;                   /* image width, height */
    int dims[3];         /* For the calls to mxCreateNumericArray */
    char errmsg[1024];
    unsigned int scanlineSize;
    uint8_T *buf_8;
    uint16_T *buf_16;
    
  /* TIFFGetField only errors if asked for a field which doesn't exist in
   * the spec.  Consequently, we needn't wrap calls to it in error-handling
   * routines. */
    TIFFGetField(tif, TIFFTAG_IMAGEWIDTH,  &imageWidth);
    TIFFGetField(tif, TIFFTAG_IMAGELENGTH, &imageHeight);
    TIFFGetFieldDefaulted(tif, TIFFTAG_SAMPLESPERPIXEL, &spp);
    TIFFGetFieldDefaulted(tif, TIFFTAG_BITSPERSAMPLE, &bps);
    TIFFGetField(tif, TIFFTAG_PLANARCONFIG, &config);
    TIFFGetField(tif, TIFFTAG_SAMPLEFORMAT, &sampleFormat);

    if(spp < 3)
    {
        sprintf(errmsg,"RGB image has %d (not 3) samples per pixel.",spp);
        TIFFClose(tif);
        mexErrMsgTxt(errmsg);
    } else if (spp > 3) {
        sprintf(errmsg,"RGB image has %d (not 3) samples per pixel.",spp);
        mexWarnMsgTxt(errmsg);
    }

    dims[0]  = imageHeight;                /* Image Height */
    dims[1]  = imageWidth;                 /* Image Width  */
    dims[2]  = spp;                        /* Color planes */
    
    if(TIFFIsTiled(tif)) {
        TIFFClose(tif);
        mexErrMsgTxt("Tiled TIFF images are not supported");
    }

    /* Image is organized in strips */
    scanlineSize = TIFFScanlineSize(tif);


    if (bps==8) {
        outArray = mxCreateNumericArray(3, dims, mxUINT8_CLASS, mxREAL); 
        ptrRed8   = (uint8_T *) mxGetData(outArray);
        ptrGreen8 = ptrRed8 + (imageHeight*imageWidth);
        ptrBlue8  = ptrRed8 + (2*imageHeight*imageWidth);
    } else if (bps==16) {
        outArray = mxCreateNumericArray(3, dims, mxUINT16_CLASS, mxREAL); 
        ptrRed16   = (uint16_T *) mxGetData(outArray);
        ptrGreen16 = ptrRed16 + (imageHeight*imageWidth);
        ptrBlue16  = ptrRed16 + (2*imageHeight*imageWidth);
    } else {
        TIFFClose(tif);
        mexErrMsgTxt("Unsupported bit-depth for RGB TIFF image file.");
    }

         
    if(config==PLANARCONFIG_CONTIG)   {
        /* Chunky mode - RGBRGBRGB... */

        if (bps==8) {
            buf_8 = (uint8_T *) mxCalloc(scanlineSize,sizeof(uint8_T));
            
            for (row = 0; row < imageHeight; row++)
            {
                if (TIFFReadScanline(tif, buf_8, row, 0) == -1)
                    CloseAndError(tif);

                for (col = 0; col < imageWidth; col++)
                {
                    j = row + (col * imageHeight);
                    ptrRed8[j]   = buf_8[col*spp];    /* If there is alpha-channel in the */
                    ptrGreen8[j] = buf_8[col*spp+1];  /* fourth pixel (spp = 4), this should*/
                    ptrBlue8[j]  = buf_8[col*spp+2];  /* just skip right over it */
                }
            }          
            mxFree(buf_8);
        } 

        else if (bps==16) {
            buf_16 = (uint16_T *) mxCalloc(scanlineSize, sizeof(uint16_T));
            
            for (row = 0; row < imageHeight; row++)
            {
                if (TIFFReadScanline(tif, buf_16, row, 0) == -1)
                    CloseAndError(tif);

                for (col = 0; col < imageWidth; col++)
                {
                    j = row + (col * imageHeight);
                    ptrRed16[j]   = buf_16[col*spp];    /* If there is alpha-channel in the */
                    ptrGreen16[j] = buf_16[col*spp+1];  /* fourth pixel (spp = 4), this should*/
                    ptrBlue16[j]  = buf_16[col*spp+2];  /* just skip right over it */
                }
            }          
            mxFree(buf_16);
        }   
    }
    else if(config == PLANARCONFIG_SEPARATE)   {
          /* Planar format - RRRRRR...  GGGGG... BBBBB.... */

        if (bps==8) {
            buf_8 = (uint8_T *) mxCalloc(scanlineSize,sizeof(uint8_T));
            
            for (i = 0; i < (int) spp; i++) /* Loop over image planes */
                for (row = 0; row < imageHeight; row++)
                {
                    if (TIFFReadScanline(tif, buf_8, row, (uint16_T) i) == -1)
                        CloseAndError(tif);

                    for (col = 0; col < imageWidth; col++)
                    {
                        j = row + (col * imageHeight);
                        switch(i) /* Figure out which plane we are in */
                        {
                        case 0:
                            ptrRed8[j] = buf_8[col];
                            break;
                        case 1:
                            ptrGreen8[j] = buf_8[col];
                            break;
                        case 2:
                            ptrBlue8[j] = buf_8[col];
                            break;
                        }
                    }
                }   
            mxFree(buf_8);
        }
        else if (bps==16) {
            buf_16 = (uint16_T *) mxCalloc(scanlineSize,sizeof(uint16_T));
            
            for (i = 0; i < (int) spp; i++) /* Loop over image planes */
                for (row = 0; row < imageHeight; row++)
                {
                    if (TIFFReadScanline(tif, buf_16, row, (uint16_T) i) == -1)
                        CloseAndError(tif);

                    for (col = 0; col < imageWidth; col++)
                    {
                        j = row + (col * imageHeight);
                        switch(i) /* Figure out which plane we are in */
                        {
                        case 0:
                            ptrRed16[j] = buf_16[col];
                            break;
                        case 1:
                            ptrGreen16[j] = buf_16[col];
                            break;
                        case 2:
                            ptrBlue16[j] = buf_16[col];
                            break;
                        }
                    }
                }   
            mxFree(buf_16);
        }
    }
    return outArray;
}


/*
** ReadNSampleImage
** 
** This subroutine will read the image data from a TIFF file containing an
** arbitrary number of samples. Image data can contain 8 or 16 bits.
*/

static mxArray *
ReadNSampleImage(TIFF *tif)
{
    uint8_T   **ptrSamples8 ;
    uint16_T  **ptrSamples16 ;
    mxArray *outArray;
    uint32_T i,j,row,col,k;
    uint16 bps,spp,config,sampleFormat; 
    uint32 imageWidth,imageHeight;         /* image width, height */
    int dims[3];         /* For the calls to mxCreateNumericArray */
    unsigned int scanlineSize;
    uint8_T *buf_8;
    uint16_T *buf_16;
    
  /* TIFFGetField only errors if asked for a field which doesn't exist in
   * the spec.  Consequently, we needn't wrap calls to it in error-handling
   * routines. */
    TIFFGetField(tif, TIFFTAG_IMAGEWIDTH,  &imageWidth);
    TIFFGetField(tif, TIFFTAG_IMAGELENGTH, &imageHeight);
    TIFFGetFieldDefaulted(tif, TIFFTAG_SAMPLESPERPIXEL, &spp);
    TIFFGetFieldDefaulted(tif, TIFFTAG_BITSPERSAMPLE, &bps);
    TIFFGetField(tif, TIFFTAG_PLANARCONFIG, &config);
    TIFFGetField(tif, TIFFTAG_SAMPLEFORMAT, &sampleFormat);

    dims[0]  = imageHeight;                /* Image Height */
    dims[1]  = imageWidth;                 /* Image Width  */
    dims[2]  = spp;                        /* Color planes */
      
    if(TIFFIsTiled(tif)) {
        TIFFClose(tif);
        mexErrMsgTxt("Tiled TIFF images are not supported");
    }

    /* Image is organized in strips */
    scanlineSize = TIFFScanlineSize(tif);
      
    
      
    if (bps==8) {
    
        outArray = mxCreateNumericArray(3, dims, mxUINT8_CLASS, mxREAL);
 
        /* Create array of pointers for each sample in the image. */
        ptrSamples8 = (uint8_T **) mxMalloc(spp*sizeof(uint8_T *));
        *ptrSamples8 = (uint8_T *) mxGetData(outArray);

        for(j = 1; j < spp; j++)
        {
            *(ptrSamples8+j) = *ptrSamples8 + (j*imageHeight*imageWidth);
        }
        
                   
    } else if (bps==16) {
    
        outArray = mxCreateNumericArray(3, dims, mxUINT16_CLASS, mxREAL); 
        
        /* Create array of pointers for each sample in the image. */
        ptrSamples16 = (uint16_T **) mxMalloc(spp*sizeof(uint16_T *));
        *ptrSamples16 = (uint16_T *) mxGetData(outArray);
        
        for(j = 1; j < spp; j++)
        {
            *(ptrSamples16+j) = *ptrSamples16 + (j*imageHeight*imageWidth);
        }
        
    } else {
        TIFFClose(tif);
        mexErrMsgTxt("Unsupported bit-depth for TIFF image file.");
    }

         
    if(config==PLANARCONFIG_CONTIG)   {

        /* Chunky mode - RGBRGBRGB... */

        if (bps==8) {
            buf_8 = (uint8_T *) mxCalloc(scanlineSize,sizeof(uint8_T));
            
            for (row = 0; row < imageHeight; row++)
            {
                if (TIFFReadScanline(tif, buf_8, row, 0) == -1)
                    CloseAndError(tif);
                
                for (col = 0; col < imageWidth; col++)
                {
                    j = row + (col * imageHeight);
                    for(k = 0; k < spp; k++)
                    {
                        *(*(ptrSamples8+k)+j)  = buf_8[col*spp+k];;
                    }
                }
            }          
            mxFree(buf_8);
            mxFree(ptrSamples8);
            
        } else if (bps==16) {
            
            buf_16 = (uint16_T *) mxCalloc(scanlineSize, sizeof(uint16_T));
            
            for (row = 0; row < imageHeight; row++)
            {
                if (TIFFReadScanline(tif, buf_16, row, 0) == -1)
                    CloseAndError(tif);
                
                for (col = 0; col < imageWidth; col++)
                {
                    j = row + (col * imageHeight);
                    for(k = 0; k < spp; k++)
                    {
                        *(*(ptrSamples16+k)+j)  = buf_16[col*spp+k];;
                    } 
                }
            }          
            mxFree(buf_16);
            mxFree(ptrSamples16);
        }   

    } else if(config == PLANARCONFIG_SEPARATE)   {

        /* Planar format - RRRRRR...  GGGGG... BBBBB.... */
        
        if (bps==8) {
            buf_8 = (uint8_T *) mxCalloc(scanlineSize,sizeof(uint8_T));
            
            for (i = 0; i < (int) spp; i++) /* Loop over image planes */
                for (row = 0; row < imageHeight; row++)
                {
                    if (TIFFReadScanline(tif, buf_8, row, (uint8_T) i) == -1)
                        CloseAndError(tif);
                    
                    for (col = 0; col < imageWidth; col++)
                    {
                        j = row + (col * imageHeight);
                        
                        *(*(ptrSamples8+i)+j) = buf_8[col];
                        
                    }
                }   
            mxFree(buf_8);
            mxFree(ptrSamples8);
        }
        else if (bps==16) {
            buf_16 = (uint16_T *) mxCalloc(scanlineSize,sizeof(uint16_T));
            
            for (i = 0; i < (int) spp; i++) /* Loop over image planes */
                for (row = 0; row < imageHeight; row++)
                {
                    if (TIFFReadScanline(tif, buf_16, row, (uint16_T) i) == -1)
                        CloseAndError(tif);
                    
                    for (col = 0; col < imageWidth; col++)
                    {
                        j = row + (col * imageHeight);
                        
                        *(*(ptrSamples16+i)+j) = buf_16[col];
                        
                    }
                }   
            mxFree(buf_16);
            mxFree(ptrSamples16);
        }
    }

    return outArray;

}



static void
StuffContigTileBufferIntoRGB(TIFF *tif,
                             uint8_T *buf,
                             int tileCol,
                             int tileRow,
                             uint8_T *ptrRed,
                             uint8_T *ptrGreen,
                             uint8_T *ptrBlue)
{
    int cols, rows, twid, tlen;
    int i,j, matrixIdx;
    
  /* TIFFGetField only errors if asked for a field which doesn't exist in
   * the spec.  Consequently, we needn't wrap calls to it in error-handling
   * routines. */
    TIFFGetField(tif, TIFFTAG_TILEWIDTH, &twid);
    TIFFGetField(tif, TIFFTAG_TILELENGTH, &tlen);
    TIFFGetField(tif, TIFFTAG_IMAGEWIDTH, &cols);
    TIFFGetField(tif, TIFFTAG_IMAGELENGTH, &rows);

    for(i=0; i<tileRow; i++)
        for(j=0; j<tileCol; j+=3)
        {
            matrixIdx = (i+tileRow*tlen) + (rows*(j+tileCol*twid));
            ptrRed[matrixIdx] = buf[j + i*twid];
            ptrGreen[matrixIdx] = buf[j+1 + i*twid];
            ptrBlue[matrixIdx] = buf[j+2 + i*twid];
        }
}



/*******************************************/
static void ErrHandler(const char *module, 
                       const char *fmt, va_list ap)
{

  char *cp;
  char *buf;

  buf = cp = (char *) mxMalloc(2048 * sizeof(char));

  if (module != NULL) {
    sprintf(cp, "%s: ", module);
    cp = (char *) strchr(cp, '\0');
  }

  vsprintf(cp, fmt, ap);
  strcat(cp, ".");

  ERROR_BUFFER = buf;
}


/*******************************************/
static void CloseAndError(TIFF *tif)
{
    TIFFClose(tif);
    mexErrMsgTxt(ERROR_BUFFER);
}


/*******************************************/
static void WarnHandler(const char *module, 
                       const char *fmt, va_list ap)
{
    /* ignore libtiff warnings */
}


/*******************************************/
static mxArray *
GetColormap(TIFF* tif, uint16_T bps)
{
    int cmdims[2];
    mxArray *colormap;
    uint16_T *red_colormap, *green_colormap, *blue_colormap;  
    uint16_T *ptrCmRed, *ptrCmGreen, *ptrCmBlue; /* Colormap arrays */
    int pixmax,i;             /* Maximum allowable pixel value (1<<bps)-1 */

    pixmax = (1<<bps)-1;          /* Maximum allowable pixel value with */

    if(TIFFGetField(tif, TIFFTAG_COLORMAP, &red_colormap,
                    &green_colormap, &blue_colormap))
    {                         /* We know it's an indexed image */
        cmdims[0] = 1<<bps;   /* Length of colormap */
        cmdims[1] = 3;        /* 3 colors */
        colormap = mxCreateNumericArray(2, cmdims, mxUINT16_CLASS, mxREAL);
        ptrCmRed   = (uint16_T *) mxGetData(colormap);
        ptrCmGreen = &ptrCmRed[pixmax+1];
        ptrCmBlue  = &ptrCmGreen[pixmax+1];
        
        for(i=0; i<cmdims[0]; i++)
        {
            ptrCmRed[i]   = red_colormap[i];
            ptrCmGreen[i] = green_colormap[i];
            ptrCmBlue[i]  = blue_colormap[i];
        }      
    }
    
    else
    {
        mexWarnMsgTxt("TIFF file contains indexed image without colormap.");
        colormap = mxCreateDoubleMatrix(0, 0, mxREAL);
    }
    return colormap;
}



void setMessageHandlers(void)
{

    ERROR_BUFFER = NULL;  /* Reset error buffer */
    TIFFSetErrorHandler(ErrHandler);
    TIFFSetWarningHandler(WarnHandler);
    
}



void validateArgs(int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[])
{

    if (nrhs < 1)
    {
        mexErrMsgTxt("Not enough input arguments.");
    }      
    
    if (nrhs > 3)
    {
        mexErrMsgTxt("Too many input arguments.");
    }

    if (nlhs > 3)
    {
        mexErrMsgTxt("Too many output arguments.");
    }

    if (!mxIsChar(prhs[0]))
    {
        mexErrMsgTxt("First argument is not a string.");
    }
    
    if ((nrhs == 3) && (!mxIsStruct(prhs[2])))
    {
        mexErrMsgTxt("Third argument is not a structure.");
    }

}



void openFile(TIFF **tif, const mxArray *prhs[])
{

    char *filename;
    int buflen;

    /* Get filename. */
    buflen = mxGetM(prhs[0]) * mxGetN(prhs[0]) * sizeof(mxChar) + 1;
    filename = (char *) mxCalloc(buflen, sizeof(*filename));
    mxGetString(prhs[0], filename, buflen);
  
    /* Open TIFF file. */
    if ((*tif = TIFFOpen(filename, "ru")) == NULL) {
        if (ERROR_BUFFER != NULL)
            mexErrMsgTxt(ERROR_BUFFER);
        else
            mexErrMsgTxt("Couldn't open file");
    }

    mxFree((void *) filename);

}



void selectIFD(TIFF **tif, int dirnum)
{

    /* The directories passed from MATLAB are 1-based. */
    if(dirnum == 0)
    {
        TIFFClose(*tif);
        mexErrMsgTxt("The first image directory is chosen with index 1, not 0.");
    }      
    
    /* Nevertheless, the first directory in the TIFF is dirnum == 0! */
    if (! TIFFSetDirectory(*tif, (uint16_T) (dirnum-1)))
    {
        TIFFClose(*tif);
        mexErrMsgTxt("Invalid TIFF image index specified.");
    }
    
}



void getImageDetails(TIFF *tif, IMAGE *imageDetails)
{

    TIFFGetField(tif, TIFFTAG_IMAGEWIDTH, &(imageDetails->width));
    TIFFGetField(tif, TIFFTAG_IMAGELENGTH, &(imageDetails->height));
    TIFFGetField(tif, TIFFTAG_PHOTOMETRIC, &(imageDetails->photometricInterp));
    TIFFGetField(tif, TIFFTAG_COMPRESSION, &(imageDetails->compressionType));
    TIFFGetFieldDefaulted(tif, TIFFTAG_SAMPLESPERPIXEL,
                          &(imageDetails->samplesPerPixel));
    TIFFGetFieldDefaulted(tif, TIFFTAG_BITSPERSAMPLE,
                          &(imageDetails->bps));
    
    if (TIFFIsTiled(tif))
        imageDetails->isTiled = true;
    else
        imageDetails->isTiled = false;

}



void getTileDetails(TIFF *tif, TILE *tileDetails)
{

    TIFFGetField(tif, TIFFTAG_TILEWIDTH, &(tileDetails->width));
    TIFFGetField(tif, TIFFTAG_TILELENGTH, &(tileDetails->height));

}



void createOutputArray(mxArray **outArray, IMAGE *imageDetails)
{

    int dims[3];

    dims[0] = imageDetails->extentRows;
    dims[1] = imageDetails->extentCols;
    dims[2] = imageDetails->samplesPerPixel;

    if (imageDetails->bps == 1)
    {
        *outArray = mxCreateNumericArray(3, dims, mxLOGICAL_CLASS, mxREAL);
    }
    else if (imageDetails->bps <= 8)
    {
        *outArray = mxCreateNumericArray(3, dims, mxUINT8_CLASS, mxREAL);
    }
    else if (imageDetails->bps <= 16)
    {
        *outArray = mxCreateNumericArray(3, dims, mxUINT16_CLASS, mxREAL);
    }
    else if (imageDetails->bps <= 32)
    {
        *outArray = mxCreateNumericArray(3, dims, mxUINT32_CLASS, mxREAL);
    }

}



void readTiledImage(TIFF *tif, IMAGE *imageDetails, TILE *tileDetails, 
                    mxArray *outArray, REGION *region)
{

    void * tileBuffer;
    void * tmp;
    void * tmp2;
    uint32_T tileBytes;
    uint32_T x, y, z;

    tileBytes = tileDetails->width * tileDetails->height * sizeof(uint8_T);

    tileBuffer = (void *) mxMalloc(tileBytes);
    tmp = (void *) mxMalloc(tileBytes);
    tmp2 = (void *) mxMalloc(tileBytes);

    for (z = 0; z < imageDetails->samplesPerPixel; z++)
    {
        for (y = region->minY; y < region->maxY; y += (tileDetails->height))
        {
            for (x = region->minX; x < region->maxX; x += (tileDetails->width))
            {
                /* Read the tile. */
                TIFFReadTile(tif, tileBuffer, x, y, z, 0);
                
                /* Permute the tile. */
                changeMajority((uint8 *) tmp, (uint8 *) tileBuffer, 
                               tileDetails);
                memcpy(tmp2, tmp, tileBytes);

                /* Store the tile. */
                storeTile(imageDetails, tileDetails, region,
                          x, y, z, 
                          (uint8_T *) mxGetData(outArray), 
                          (uint8_T *) tmp2);
            }
        }
    }

    mxFree(tmp2);
    mxFree(tmp);
    mxFree(tileBuffer);

}



void changeMajority(uint8 *post_buffer, uint8 *pre_buffer, 
                    TILE *tileDetails)
{

    uint32 pre_width = tileDetails->width;
    uint32 pre_height = tileDetails->height;
    uint32 x, y;
    uint32 idx;

    /* Loop over pre_buffer. */
    idx = 0;
    for (x = 0; x < pre_width; x++)
        for (y = 0; y < pre_height; y++)
            post_buffer[idx++] = pre_buffer[x + (y * pre_width)];

}


static void readStripImage(TIFF *tif, IMAGE *imageDetails,
                           mxArray **outArray)
{

    char errmsg[1024];

    /*
     * Figure out the image type: Binary, RGB, RGBA, index, ...
     */
    
    if (imageDetails->photometricInterp == PHOTO_INDEXED)
    {
        *outArray = ReadIndexedGrayOrBinaryImage(tif);
    }
    
    else if (imageDetails->photometricInterp == PHOTO_RGB)
    {
        *outArray = ReadRGBImage(tif);
    }
    
    else if (imageDetails->photometricInterp == PHOTO_CMYK)
    {
        
        if(imageDetails->samplesPerPixel < 4)
        {
            sprintf(errmsg, "CMYK image has %d (not 4) samples per pixel.",
                    imageDetails->samplesPerPixel);
            TIFFClose(tif);
            mexErrMsgTxt(errmsg);
        } else if (imageDetails->samplesPerPixel > 4) {
            sprintf(errmsg, "CMYK image has %d (not 4) samples per pixel.",
                    imageDetails->samplesPerPixel);
            mexWarnMsgTxt(errmsg);
        }
        
        *outArray = ReadNSampleImage(tif);
        
    }
    
    else if (((imageDetails->photometricInterp == PHOTO_WHITE_IS_ZERO) ||
              (imageDetails->photometricInterp == PHOTO_BLACK_IS_ZERO)) &&
             (imageDetails->samplesPerPixel == 1))
    {
        *outArray = ReadIndexedGrayOrBinaryImage(tif);
    }
    
    else                                  /* Other image type */
    {
        *outArray = ReadNSampleImage(tif);
    }
    
}



static void complementImage(IMAGE *imageDetails, mxArray *outArray)
{

    int i, numElts;
    void *dataPtr;
    int pixmax;

    pixmax = (1 << (imageDetails->bps)) - 1;
    
    dataPtr = mxGetData(outArray);
    numElts = mxGetNumberOfElements(outArray);

    for (i = 0; i < numElts; i++)
    {
        if (imageDetails->bps == 1)
            ((uint8_T *) dataPtr)[i] = ! ((uint8_T *) dataPtr)[i];
        else if (imageDetails->bps <= 8)
            ((uint8_T *) dataPtr)[i] =  pixmax - ((uint8_T *) dataPtr)[i];
        else if (imageDetails->bps <= 16)
            ((uint16_T *) dataPtr)[i] =  pixmax - ((uint16_T *) dataPtr)[i];
        else if (imageDetails->bps <= 32)
            ((uint32_T *) dataPtr)[i] =  pixmax - ((uint32_T *) dataPtr)[i];
    }
}



static mxArray * buildDetailsStruct(IMAGE *imageDetails, TILE *tileDetails)
{
    
    mxArray *details;
    const char *fields[] = {
        "ImageWidth",
        "ImageHeight",
        "TileWidth",
        "TileHeight",
        "Photo"};

    details = mxCreateStructMatrix(1, 1, 5, fields);
    if (details == NULL)
    {
        return details;
    }

    mxSetField(details, 0, "ImageWidth", 
               mxCreateDoubleScalar((double) imageDetails->width));
    mxSetField(details, 0, "ImageHeight", 
               mxCreateDoubleScalar((double) imageDetails->height));
    mxSetField(details, 0, "Photo", 
               mxCreateDoubleScalar((double) imageDetails->photometricInterp));

    if (tileDetails != NULL)
    {
        mxSetField(details, 0, "TileWidth", 
                   mxCreateDoubleScalar((double) tileDetails->width));
        mxSetField(details, 0, "TileHeight", 
                   mxCreateDoubleScalar((double) tileDetails->height));
    }
    else
    {
        mxSetField(details, 0, "TileWidth", 
                   mxCreateDoubleMatrix(0, 0, mxREAL));
        mxSetField(details, 0, "TileHeight", 
                   mxCreateDoubleMatrix(0, 0, mxREAL));
    }
    
    return details;

}



static void computeExtent(IMAGE *imageDetails, TILE *tileDetails,
                          REGION *regionDetails)
{

    imageDetails->extentRows = regionDetails->maxY - regionDetails->minY + 1;
    imageDetails->extentCols = regionDetails->maxX - regionDetails->minX + 1;
    
}



static void getRegionDetails(REGION *regionDetails, 
                             const mxArray *regionStruct,
                             IMAGE *imageDetails, 
                             TILE *tileDetails)
{

    uint32_T minX, minY;
    uint32_T maxX, maxY;
    double stop;

    if (regionStruct == NULL)
    {
        /* The region is the whole image. */
        minX = 0;
        minY = 0;
        maxX = imageDetails->width - 1;
        maxY = imageDetails->height - 1;

    }
    else
    {
        
        /* The region to read covers all of pixels in the required tiles. */
        minX = (uint32_T) mxGetScalar(mxGetField(regionStruct, 1, "start"));
        minX = ((int32_T) minX < 0) ? 0 : minX;
        
        stop = mxGetScalar(mxGetField(regionStruct, 1, "stop"));
        if (mxIsInf(stop))
            maxX = imageDetails->width - 1;
        else
        {
            maxX = (uint32_T) stop;
            maxX = (maxX > imageDetails->width) ? 
                imageDetails->width - 1 : maxX;
        }
        
        minY = (uint32_T) mxGetScalar(mxGetField(regionStruct, 0, "start"));
        minY = ((int32_T) minY < 0) ? 0 : minY;
        
        stop = mxGetScalar(mxGetField(regionStruct, 0, "stop"));
        if (mxIsInf(stop))
            maxY = imageDetails->height - 1;
        else
        {
            maxY = (uint32_T) stop;
            maxY = (maxY > imageDetails->width) ? 
                imageDetails->height - 1 : maxY;
        }
    }

    /* Find the limits of the required tiles. */
    minX = (minX / tileDetails->width) * tileDetails->width;
    maxX = ((maxX / tileDetails->width) + 1) * tileDetails->width - 1;
    minY = (minY / tileDetails->height) * tileDetails->height;
    maxY = ((maxY / tileDetails->height) + 1) * tileDetails->height - 1;

    regionDetails->minX = minX;
    regionDetails->minY = minY;
    regionDetails->maxX = maxX;
    regionDetails->maxY = maxY;

}


static void storeTile(IMAGE *imageDetails, TILE *tileDetails,
                      REGION *regionDetails,
                      uint32 x, uint32 y, uint32 z,
                      uint8 *imageArray, uint8 *tileBuffer)
{
    
    uint32_T startX, startY;
    uint32_T p, q;
    uint32_T tilePos, imagePos;
    uint32_T tileWidth, tileHeight;

    /* Determine where this tile is in the output array. */
    startX = x - regionDetails->minX;
    startY = y - regionDetails->minY;

    tileWidth = tileDetails->width;
    tileHeight = tileDetails->height;
    
    /* Copy samples from tileBuffer to imageArray. */
    imagePos = startX * imageDetails->extentRows + startY + 
        z * imageDetails->extentRows * imageDetails->extentCols;
    tilePos = 0;
    for (p = 0; (p < tileWidth) && ((p + x) < imageDetails->width); p++)
    {
        tilePos = p * tileDetails->height;

        for (q = 0; (q < tileHeight) && ((q + y) < imageDetails->height); q++)
        {
            imageArray[imagePos + q] = tileBuffer[tilePos + q];
        }

        imagePos += imageDetails->extentRows;
    }
}



static void cleanup(TIFF *tif, IMAGE *imageDetails, TILE *tileDetails,
                    REGION *regionDetails)
{

    if (tif != NULL)
    {
        TIFFClose(tif);
        tif = NULL;
    }

    if (imageDetails != NULL)
    {
        mxFree(imageDetails);
        imageDetails = NULL;
    }

    if (tileDetails != NULL)
    {
        mxFree(tileDetails);
        tileDetails = NULL;
    }
        
    if (regionDetails != NULL)
    {
        mxFree(regionDetails);
        regionDetails = NULL;
    }
        
}
