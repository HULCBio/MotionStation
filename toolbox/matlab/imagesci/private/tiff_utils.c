/*
 * File: tiff_utils.c
 *
 * Purpose:  C functions to interface to MEX and the TIFF libraries
 *           MUST be compiled using the MEX compiler
 *
 * $Date: 2003/12/13 03:01:27 $
 * $Id: tiff_utils.c,v 1.1.6.1 2003/12/13 03:01:27 batserve Exp $
 *
 * 
 */

#include "tiff_utils.h"

void writeImageFromMxArray(TIFF *tif, 
                         int inClass, int imType,
                         const mxArray *inputArray, 
                         int w, int h, int rowsPerStrip) {

    if(imType == RGB_IMG || imType == PACKED_RGB_IMG ) {
/**
 * Write an RGB image
 */
        if ( imType == PACKED_RGB_IMG ) {
            writeRGBFromUint32(tif, inputArray, w, h, rowsPerStrip);
        }
        else if ( inClass == mxUINT8_CLASS )  {
            writeRGBFromUint8(tif, inputArray, w, h, rowsPerStrip);
        }
        else if ( inClass == mxUINT16_CLASS ) {
            writeRGBFromUint16(tif, inputArray, w, h, rowsPerStrip);
        }
        
    } else  {

/**
 * Write an Indexed, Gray or Binary image 
 */ 
        
        if ( inClass == mxLOGICAL_CLASS ) {
            writeBitsFromLogical(tif, inputArray, w, h, rowsPerStrip);
        }
        else if ( inClass == mxUINT8_CLASS ) {
            writeBytesFromUint8(tif, inputArray, w, h, rowsPerStrip);
        }
        else if ( inClass == mxUINT16_CLASS ) {
            writeBytesFromUint16(tif, inputArray, w, h, rowsPerStrip);
        }
    }
}
  
void writeImageFromMxArrayNew(TIFF *tif, 
                              int photo,
                              const mxArray *inputArray, 
                              int w, int h, int spp,
                              int rowsPerStrip) 
{
    if (photo == PHOTOMETRIC_MINISWHITE)
    {
        writeBitsFromLogical(tif, inputArray, w, h, rowsPerStrip);
    }
    else if ((photo == PHOTOMETRIC_RGB) && (mxIsUint32(inputArray)))
    {
        writeRGBFromUint32(tif, inputArray, w, h, rowsPerStrip);
    }
    else
    {
        writeMultisample(tif, mxGetData(inputArray), w, h, spp, 
                         mxGetElementSize(inputArray), rowsPerStrip);
    }
}
  
void writeMultisample(TIFF *tif, 
                      void *data,
                      int w, 
                      int h, 
                      int spp,
                      int bytesPerSample,
                      int rps) {
    
    uint8_T *buf;
    int i,j,p,s;
    int numStrips;
    int strip;
    int col, row;

    /* Allocate buffer for image write */
    buf = (uint8_T *) mxCalloc(w*rps*spp, bytesPerSample);

    numStrips = (h + rps - 1) / rps;

    for (strip = 0, row = 0; strip < numStrips; strip++)
    {
        /* Fill the strip buffer */
        for (p = 0; (p < rps) && (row < h); p++, row++)
        {
            for (col = 0; col < w; col++)
            {
                j = (col + (p*w)) * bytesPerSample * spp;    /* index into buf */
                i = ((col*h) + row) * bytesPerSample;  /* index into data */

                for (s = 0; s < spp; s++)
                {
                    memcpy(buf + j + s*bytesPerSample, 
                           (uint8_T *) data + i + s*w*h*bytesPerSample, 
                           bytesPerSample);
                }
            }
        }
    
        /* Write the strip buffer */
        TIFFWriteEncodedStrip(tif, strip, buf, w*p*spp*bytesPerSample);
    }

    mxFree((void *) buf);
}

void writeBytesFromUint8(TIFF *tif, 
                         const mxArray *inputArray, 
                         int w, int h, int rps) {
    
    uint8_T *buf;
    int i,j,p;
    int numStrips;
    int strip;
    int col, row;
    uint8_T *data;

    /* Allocate buffer for image write */
    data = (uint8_T *) mxGetData(inputArray);
    buf = (uint8_T *) mxCalloc(w*rps, sizeof(uint8_T));

    numStrips = (h + rps - 1) / rps;

    for (strip = 0, row = 0; strip < numStrips; strip++)
    {
        /* Fill the strip buffer */
        for (p = 0; (p < rps) && (row < h); p++, row++)
        {
            for (col = 0; col < w; col++)
            {
                j = col + (p*w);    /* index into buf */
                i = (col*h) + row;  /* index into data */

                buf[j] = data[i];
            }
        }
    
        /* Write the strip buffer */
        TIFFWriteEncodedStrip(tif, strip, buf, w*p*sizeof(uint8));
    }

    mxFree(buf);
}


void writeBytesFromUint16(TIFF *tif, 
                          const mxArray *inputArray, 
                          int w, int h, int rps) {
    
    uint16_T *buf;
    int i,j,p;
    int numStrips;
    int strip;
    int col, row;
    uint16_T *data;

    /* Allocate buffer for image write */
    data = (uint16_T *) mxGetData(inputArray);
    buf = (uint16_T *) mxCalloc(w*rps, sizeof(uint16_T));

    numStrips = (h + rps - 1) / rps;

    for (strip = 0, row = 0; strip < numStrips; strip++)
    {
        /* Fill the strip buffer */
        for (p = 0; (p < rps) && (row < h); p++, row++)
        {
            for (col = 0; col < w; col++)
            {
                j = col + (p*w);    /* index into buf */
                i = (col*h) + row;  /* index into data */

                buf[j] = data[i];
            }
        }
    
        /* write the strip buffer */
        TIFFWriteEncodedStrip(tif, strip, buf, w*p*sizeof(uint16_T));
    }

    mxFree(buf);
}


/*
 * WriteBitsFromLogical
 * Write from a binary image stored in mxLogicals.
 *
 * Write the image data with White-is-Zero (PHOTOMETRIX_MINISWHITE).  This
 * is non-intuitive, but it is the norm for binary TIFFS.  Many (supposed)
 * Tiff readers will not read the data correctly if it is written with
 * PHOTOMETRIC_MINISBLACK .
 */

void writeBitsFromLogical(TIFF *tif, 
                          const mxArray *inputArray, 
                          int w, int h, int rps) {
    
    uint8_T *buf;
    int i,j,k,p;
    int numStrips;
    int strip;
    uint8_T pixel, byte;
    int col, row;
    int stripBytes;
    mxLogical *data;

    /* Allocate buffer for image write */
    data = mxGetLogicals(inputArray);
    stripBytes = ((w+7)/8) * rps;
    buf = (uint8_T *) mxCalloc(stripBytes, sizeof(uint8_T));

    numStrips = (h + rps - 1) / rps;

    for (strip = 0, row = 0; strip < numStrips; strip++)
    {
        j = 0;    /* index into buf */
        k = 0;  /* bit within a byte */
        byte = 0;
        /* Fill the strip buffer */
        for (p = 0; (p < rps) && (row < h); p++, row++)
        {
            for (col = 0; col < w; col++)
            {
                i = (col*h) + row;          /* index into data */

                pixel = (data[i]==0) ? 1 : 0;  /* 0 is white */
                byte |= (pixel << (7-k));

                k++;
                if ((k == 8) || (col == (w-1)))
                {
                    /* either we've filled a byte or we've */
                    /* reached the end of a row.  Stuff the */
                    /* byte into the buffer. */
                    buf[j] = byte;
                    j++;
                    k = 0;
                    byte = 0;
                }
            }
        }
    
        TIFFWriteEncodedStrip(tif, strip, buf, j);
    }
    mxFree((void *) buf);
}


void writeRGBFromUint8(TIFF *tif, 
                       const mxArray *inputArray, 
                       int w, int h, int rps) {
    
    uint8_T *buf;
    int i,j,p;
    int numStrips;
    int strip;
    int col, row;
    uint8_T *data;

    /* Allocate buffer for image write */
    data = (uint8_T *) mxGetData(inputArray);
    buf = (uint8_T *) mxCalloc(w*rps*3, sizeof(uint8_T));

    numStrips = (h + rps - 1) / rps;

    for (strip = 0, row = 0; strip < numStrips; strip++)
    {
        /* Fill the strip buffer */
        for (p = 0; (p < rps) && (row < h); p++, row++)
        {
            for (col = 0; col < w; col++)
            {
                j = col + (p*w);    /* index into buf */
                i = (col*h) + row;  /* index into data */

                buf[j*3]   = data[i];         /* Red Pixel */
                buf[j*3+1] = data[i+(w*h)];   /* Green Pixel */
                buf[j*3+2] = data[i+(2*w*h)]; /* Blue Pixel */
            }
        }
    
        /* Write the strip buffer */
        TIFFWriteEncodedStrip(tif, strip, buf, w*p*3*sizeof(uint8));
    }

    mxFree((void *) buf);
}

void writeRGBFromUint16(TIFF *tif, const mxArray *inputArray, 
                        int w, int h, int rps) {
    
    uint16_T *buf;
    int i,j,p;
    int numStrips;
    int strip;
    int col, row;
    uint16_T *data;

    /* Allocate buffer for image write */
    data = (uint16_T *) mxGetData(inputArray);
    buf = (uint16_T *) mxCalloc(w*rps*3, sizeof(uint16_T));

    numStrips = (h + rps - 1) / rps;

    for (strip = 0, row = 0; strip < numStrips; strip++)
    {
        /* Fill the strip buffer */
        for (p = 0; (p < rps) && (row < h); p++, row++)
        {
            for (col = 0; col < w; col++)
            {
                j = col + (p*w);    /* index into buf */
                i = (col*h) + row;  /* index into data */

                buf[j*3]   = data[i];         /* Red Pixel */
                buf[j*3+1] = data[i+(w*h)];   /* Green Pixel */
                buf[j*3+2] = data[i+(2*w*h)]; /* Blue Pixel */
            }
        }
    
        /* Write the strip buffer */
        TIFFWriteEncodedStrip(tif, strip, buf, w*p*3*sizeof(uint16_T));
    }

    mxFree((void *) buf);
}


void writeRGBFromUint32(TIFF *tif, 
                        const mxArray *inputArray, 
                        int w, int h, int rps)
{
    
    uint8_T *buf, *data8;
    int j,p;
    int numStrips;
    int strip;
    int col, row;
    uint32_T *data;

    /* Index each byte of the 4 byte uint32 as packed [ Alpha(garbage) R G B ] */
    data8 = (uint8_T *)data;

    /* Allocate buffer for image write */
    data = (uint32_T *) mxGetData(inputArray);
    buf = (uint8_T *) mxCalloc(w*rps*3, sizeof(uint8_T));

    numStrips = (h + rps - 1) / rps;

    for (strip = 0, row = 0; strip < numStrips; strip++)
    {
        /* Fill the strip buffer */
        for (p = 0; (p < rps) && (row < h); p++, row++)
        {
            for (col = 0; col < w; col++)
            {
                j = col + (p*w);      /* index into buf (why not just buf++?) */
                /* Shifts are hardcoded TCPI offsets of IMSAVE driver */
                buf[j*3]   = (*data >> 16) & (uint32_T)255; /* Red Pixel */
                buf[j*3+1] = (*data >>  8) & (uint32_T)255; /* Green Pixel */
                buf[j*3+2] =  *data        & (uint32_T)255; /* Blue Pixel */
                data++;
            }
        }
    
        /* Write the strip buffer */
        TIFFWriteEncodedStrip(tif, strip, buf, w*p*3);
    }

    mxFree((void *) buf);
}



/*
 * Put the colormap into the TIFF structure for the write operation.
 */

void writeTIFFColormap(TIFF *tif, int imType, const mxArray *cmap, int dataClass)
{
    uint16_T *red,*green,*blue;
    int i;
    const int *size;
    int rows, cols, ndims;
    mxClassID mapClass;
    uint8_T *u8_data;
    uint16_T *u16_data;

    red = (uint16_T *) mxCalloc(65536, sizeof(*red));
    green = (uint16_T *) mxCalloc(65536, sizeof(*green));
    blue = (uint16_T *) mxCalloc(65536, sizeof(*blue));
    
    if (imType != INDEX_IMG) return;
    for(i=0; i<256; i++)        /* Clear colormap */
    {
        red[i] = 0;
        green[i] = 0;
        blue[i] = 0;
    }
    
    mapClass = mxGetClassID(cmap);
    ndims = mxGetNumberOfDimensions(cmap);
    if(ndims != 2)
        mexErrMsgTxt("Invalid colormap, must be 2-D.");
    
    size = mxGetDimensions(cmap);
    rows = size[0];
    cols = size[1];

    if(cols!=3)
        mexErrMsgTxt("Invalid colormap, must be n X 3.");

    if( dataClass==mxUINT8_CLASS && rows>256)
        mexErrMsgTxt("Invalid colormap for 8-bit image, must be n X 3 (n<=256).");

    if( dataClass==mxUINT16_CLASS && rows>65536)
        mexErrMsgTxt("Invalid colormap for 16-bit image, must be n X 3 (n<=65536).");


    if (mapClass==mxUINT8_CLASS) {
        /* Multiply data by 65535/255 = 257 */
        u8_data = (uint8_T *) mxGetData(cmap);
        for(i=0; i<rows; i++)
        {
            red[i]   = (uint16_T) (257*u8_data[i]);
            green[i] = (uint16_T) (257*u8_data[i+rows]);
            blue[i]  = (uint16_T) (257*u8_data[i+(rows*2)]);
        }            
    }
    else if(mapClass==mxUINT16_CLASS) {
        u16_data = (uint16_T *) mxGetData(cmap);
        for(i=0; i<rows; i++)
        {
            red[i]   = (uint16_T) u16_data[i];
            green[i] = (uint16_T) u16_data[i+rows];
            blue[i]  = (uint16_T) u16_data[i+(rows*2)];
        }            
    } else
        mexErrMsgTxt("Class of colormap must be uint8 or uint16");

    TIFFSetField(tif, TIFFTAG_COLORMAP, red, green, blue);
}

void writeTIFFColormapNew(TIFF *tif, int photo, const mxArray *cmap, int dataClass)
{
    uint16_T *red,*green,*blue;
    int i;
    const int *size;
    int rows, cols, ndims;
    mxClassID mapClass;
    uint8_T *u8_data;
    uint16_T *u16_data;

    if (photo != PHOTOMETRIC_PALETTE) {
        return;
    }

    red = (uint16_T *) mxCalloc(65536, sizeof(*red));
    green = (uint16_T *) mxCalloc(65536, sizeof(*green));
    blue = (uint16_T *) mxCalloc(65536, sizeof(*blue));
    
    for(i=0; i<256; i++)        /* Clear colormap */
    {
        red[i] = 0;
        green[i] = 0;
        blue[i] = 0;
    }
    
    mapClass = mxGetClassID(cmap);
    ndims = mxGetNumberOfDimensions(cmap);
    if(ndims != 2)
        mexErrMsgTxt("Invalid colormap, must be 2-D.");
    
    size = mxGetDimensions(cmap);
    rows = size[0];
    cols = size[1];

    if(cols!=3)
        mexErrMsgTxt("Invalid colormap, must be n X 3.");

    if( dataClass==mxUINT8_CLASS && rows>256)
        mexErrMsgTxt("Invalid colormap for 8-bit image, must be n X 3 (n<=256).");

    if( dataClass==mxUINT16_CLASS && rows>65536)
        mexErrMsgTxt("Invalid colormap for 16-bit image, must be n X 3 (n<=65536).");


    if (mapClass==mxUINT8_CLASS) {
        /* Multiply data by 65535/255 = 257 */
        u8_data = (uint8_T *) mxGetData(cmap);
        for(i=0; i<rows; i++)
        {
            red[i]   = (uint16_T) (257*u8_data[i]);
            green[i] = (uint16_T) (257*u8_data[i+rows]);
            blue[i]  = (uint16_T) (257*u8_data[i+(rows*2)]);
        }            
    }
    else if(mapClass==mxUINT16_CLASS) {
        u16_data = (uint16_T *) mxGetData(cmap);
        for(i=0; i<rows; i++)
        {
            red[i]   = (uint16_T) u16_data[i];
            green[i] = (uint16_T) u16_data[i+rows];
            blue[i]  = (uint16_T) u16_data[i+(rows*2)];
        }            
    } else
        mexErrMsgTxt("Class of colormap must be uint8 or uint16");

    TIFFSetField(tif, TIFFTAG_COLORMAP, red, green, blue);
}

/*******************************************/
void MexErrHandler(const char *module, 
                   const char *fmt, va_list ap)
{
  char buf[2048];
  char *cp = buf;


  if (module != NULL) {
    sprintf(cp, "%s: ", module);
    cp = (char *) strchr(cp, '\0');
  }

  vsprintf(cp, fmt, ap);
  strcat(cp, ".");

  mexErrMsgTxt(cp); 
}


/*******************************************/
void MexWarnHandler(const char *module, 
                       const char *fmt, va_list ap)
{
  char buf[2048];
  char *cp = buf;

  if (module != NULL) {
    sprintf(cp, "%s: ", module);
    cp = (char *) strchr(cp, '\0');
  }

  vsprintf(cp, fmt, ap);
  strcat(cp, ".");

  mexWarnMsgTxt(buf);
}


void writeTIFFTags( TIFF *tif,
                    int inClass, int imType,  
                    int ndims, int w, int h, 
                    const mxArray *desArray,
                    int comp,
                    unsigned short resolutionUnit,
                    unsigned short samplesPerPixel,
                    float xres, float yres, int rowsPerStrip) {
    
    char *description = 0;
    long stringlen;
    if (!mxIsEmpty(desArray)) {
      if (!mxIsChar(desArray)) 
        mexErrMsgTxt("DESCRIPTION must be a string");
      stringlen = mxGetM(desArray) * mxGetN(desArray) * sizeof(mxChar) + 1;
      description = (char *) mxCalloc(stringlen, sizeof(*description));
      mxGetString(desArray, description, stringlen);
      if (description != 0) 
        TIFFSetField(tif, TIFFTAG_IMAGEDESCRIPTION, description);
      mxFree((void *) description);
    }

    TIFFSetField(tif, TIFFTAG_IMAGEWIDTH, w);
    TIFFSetField(tif, TIFFTAG_IMAGELENGTH, h);
    TIFFSetField(tif, TIFFTAG_COMPRESSION, comp);
    TIFFSetField(tif, TIFFTAG_RESOLUTIONUNIT, resolutionUnit);    
    TIFFSetField(tif, TIFFTAG_XRESOLUTION, xres);
    TIFFSetField(tif, TIFFTAG_YRESOLUTION, yres);
    
    
    if (comp == COMPRESSION_CCITTFAX3)
        TIFFSetField(tif, TIFFTAG_GROUP3OPTIONS,
                     GROUP3OPT_2DENCODING+GROUP3OPT_FILLBITS);
    
    TIFFSetField(tif, TIFFTAG_PLANARCONFIG, PLANARCONFIG_CONTIG);
    TIFFSetField(tif, TIFFTAG_ORIENTATION, ORIENTATION_TOPLEFT);


    if(imType == RGB_IMG || imType == PACKED_RGB_IMG ) {

        if(inClass == mxUINT16_CLASS) 
            TIFFSetField(tif, TIFFTAG_BITSPERSAMPLE,   16);
        else   /* For mxUINT8_CLASS and mxUINT32_CLASS */
            TIFFSetField(tif, TIFFTAG_BITSPERSAMPLE,   8);
        
        TIFFSetField(tif, TIFFTAG_PHOTOMETRIC, PHOTOMETRIC_RGB);

        samplesPerPixel = 3;
        TIFFSetField(tif, TIFFTAG_SAMPLESPERPIXEL, samplesPerPixel);
        TIFFSetField(tif, TIFFTAG_ROWSPERSTRIP, rowsPerStrip);
        
    } else {
    /* Indexed, Gray or Binary image */
        

        TIFFSetField(tif, TIFFTAG_ROWSPERSTRIP, rowsPerStrip);
        TIFFSetField(tif, TIFFTAG_SAMPLESPERPIXEL, samplesPerPixel);        

        if(imType == INDEX_IMG) {
            if(inClass == mxUINT16_CLASS) 
                TIFFSetField(tif, TIFFTAG_BITSPERSAMPLE,   16);
            else
                TIFFSetField(tif, TIFFTAG_BITSPERSAMPLE,   8);

            TIFFSetField(tif, TIFFTAG_PHOTOMETRIC, PHOTOMETRIC_PALETTE);
        }

        else if(imType == BINARY_IMG) {
            TIFFSetField(tif, TIFFTAG_BITSPERSAMPLE,   1);
            TIFFSetField(tif, TIFFTAG_PHOTOMETRIC, PHOTOMETRIC_MINISWHITE);
        }
        else {
        /* Grayscale or Binary without CCITT compression */
            if(inClass == mxUINT16_CLASS) 
                TIFFSetField(tif, TIFFTAG_BITSPERSAMPLE,   16);
            else
                TIFFSetField(tif, TIFFTAG_BITSPERSAMPLE,   8);

            TIFFSetField(tif, TIFFTAG_PHOTOMETRIC, PHOTOMETRIC_MINISBLACK);
        }
    }
}

void writeTIFFTagsNew( TIFF *tif,
                       int inClass, int photo,
                       int w, int h, 
                       const mxArray *desArray,
                       int comp,
                       unsigned short resolutionUnit,
                       unsigned short samplesPerPixel,
                       float xres, float yres, int rowsPerStrip) 
{
    char *description = NULL;
    int bps;

    if (!mxIsEmpty(desArray))
    {
        if (!mxIsChar(desArray))
        {
            mexErrMsgIdAndTxt("MATLAB:imwrite:badDescription",
                              "DESCRIPTION must be a string.");
        }
        
        description = mxArrayToString(desArray);
        if (description != NULL)
        {
            TIFFSetField(tif, TIFFTAG_IMAGEDESCRIPTION, description);
            mxFree(description);
        }
    }

    TIFFSetField(tif, TIFFTAG_IMAGEWIDTH, w);
    TIFFSetField(tif, TIFFTAG_IMAGELENGTH, h);
    TIFFSetField(tif, TIFFTAG_COMPRESSION, comp);
    TIFFSetField(tif, TIFFTAG_RESOLUTIONUNIT, resolutionUnit);    
    TIFFSetField(tif, TIFFTAG_XRESOLUTION, xres);
    TIFFSetField(tif, TIFFTAG_YRESOLUTION, yres);
    
    
    if (comp == COMPRESSION_CCITTFAX3)
        TIFFSetField(tif, TIFFTAG_GROUP3OPTIONS,
                     GROUP3OPT_2DENCODING+GROUP3OPT_FILLBITS);
    
    TIFFSetField(tif, TIFFTAG_PLANARCONFIG, PLANARCONFIG_CONTIG);
    TIFFSetField(tif, TIFFTAG_ORIENTATION, ORIENTATION_TOPLEFT);

    TIFFSetField(tif, TIFFTAG_PHOTOMETRIC, photo);

    if (inClass == mxLOGICAL_CLASS)
    {
        bps = 1;
    }
    else if ((inClass == mxUINT32_CLASS) && (photo == PHOTOMETRIC_RGB))
    {
        bps = 8;
    }
    else if (inClass == mxUINT8_CLASS)
    {
        bps = 8;
    }
    else if (inClass == mxUINT16_CLASS)
    {
        bps = 16;
    }
    else
    {
        mexErrMsgIdAndTxt("MATLAB:wtifc:unsupportedClass",
                          "Internal error - unsupported input class.");
    }
    TIFFSetField(tif, TIFFTAG_BITSPERSAMPLE, bps);

    TIFFSetField(tif, TIFFTAG_SAMPLESPERPIXEL, samplesPerPixel);
    TIFFSetField(tif, TIFFTAG_ROWSPERSTRIP, rowsPerStrip);

}

int getSamplesPerPixel(const mxArray *inputArray)
{
    int spp;
    const int *size;

    if (mxIsUint32(inputArray))
    {
        /*
         * Packed Handle Graphics RGBA array
         */
        spp = 3;
    }
    else if (mxGetNumberOfDimensions(inputArray) == 2)
    {
        spp = 1;
    }
    else
    {
        size = mxGetDimensions(inputArray);
        spp = size[2];
    }

    return(spp);
}

/*
 * The following define is not in tiff.h.  See "Adobe Photoshop TIFF Technical Notes," 
 * March 22, 2002, www.adobe.com.
 */
#define PHOTOMETRIC_ICCLAB ( 9 )

int getPhotometricInterpretation(int inClass,
                                 int samplesPerPixel,
                                 bool emptyMap,
                                 const mxArray *colorspaceArray)
{
    int photo = PHOTOMETRIC_MINISBLACK;
    char *colorspace = NULL;

    if (samplesPerPixel == 1)
    {
        if (inClass == mxLOGICAL_CLASS)
        {
            photo = PHOTOMETRIC_MINISWHITE;
        }
        else
        {
            photo = emptyMap ? PHOTOMETRIC_MINISBLACK : PHOTOMETRIC_PALETTE;
        }
    }
    else if (samplesPerPixel == 3)
    {
        if (colorspaceArray == NULL)
        {
            photo = PHOTOMETRIC_RGB;
        }
        else
        {
            colorspace = mxArrayToString(colorspaceArray);
            if (strcmp(colorspace, "rgb") == 0)
            {
                photo = PHOTOMETRIC_RGB;
            }
            else if (strcmp(colorspace, "icclab") == 0)
            {
                photo = PHOTOMETRIC_ICCLAB;
            }
            else if (strcmp(colorspace, "cielab") == 0)
            {
                photo = PHOTOMETRIC_CIELAB;
            }
            else
            {
                mexErrMsgIdAndTxt("MATLAB:wtifc:unrecognizedColorspaceString",
                                  "Internal error - unrecognized colorspace string");
            }
            mxFree(colorspace);
        }
    }
    else if (samplesPerPixel == 4)
    {
        photo = PHOTOMETRIC_SEPARATED;
    }
    else
    {
        mexErrMsgIdAndTxt("MATLAB:imwrite:badSamplesPerPixel",
                          "Image must have 1, 3, or 4 samples per pixel for writing a TIFF file.");
    }

    return(photo);
}


int getImType(int ndims, int inClass, const int *size, 
              const mxArray *mapArray, const mxArray *inputArray) {

    int imType;

/* if RGB Image */
    if(ndims == 3 && (inClass == mxUINT8_CLASS || 
                      inClass == mxUINT16_CLASS))  {
        if(size[2]==3)
            imType = RGB_IMG;
        else          
            mexErrMsgTxt("Invalid image array; third dimension must be 1 or 3");
    }

    else if(ndims == 2 && inClass == mxUINT32_CLASS ) {
/* Packed, ZBuffer type, true-color data */
        imType = PACKED_RGB_IMG;
    }

    else if(ndims == 2 && 
           (inClass == mxLOGICAL_CLASS ||
        inClass == mxUINT8_CLASS ||
        inClass == mxUINT16_CLASS)) {
        /* if Indexed Image */
        if(!mxIsEmpty(mapArray)) {
            imType = INDEX_IMG;
        }
        else {
        /* it's a Gray or Binary Image */
            imType = mxIsLogical(inputArray) ? BINARY_IMG : GRAY_IMG;
        }
    }
    else
        mexErrMsgTxt("Invalid image array, format and number of dimensions does not match");

    return imType;
}


int getComp(const mxArray *compArray, int imType) {
    int comp;
    char compStr[64];

    if (!mxIsChar(compArray)) 
      mexErrMsgTxt("COMPRESSION must be a string");
    mxGetString(compArray, compStr, 64);
    
    if(!strncmp(compStr, "packbits",64))
        comp = COMPRESSION_PACKBITS; 
    else if(!strncmp(compStr, "ccitt",64))
        comp = COMPRESSION_CCITTRLE;
    else if(!strncmp(compStr, "thunder",64))
        comp = COMPRESSION_THUNDERSCAN;
    else if(!strncmp(compStr, "next",64))
        comp = COMPRESSION_NEXT;
    else if(!strncmp(compStr, "fax3",64))
        comp = COMPRESSION_CCITTFAX3;
    else if(!strncmp(compStr, "fax4",64))
        comp = COMPRESSION_CCITTFAX4;
    else if(!strncmp(compStr, "none",64))
        comp = COMPRESSION_NONE;
    else
        mexErrMsgTxt("Invalid compression scheme requested.");
    
    if((comp == COMPRESSION_CCITTRLE || 
        comp == COMPRESSION_CCITTFAX3 ||
        comp == COMPRESSION_CCITTFAX4) && imType != BINARY_IMG)
        mexErrMsgTxt("CCITT compression is only valid for binary images.");
    return comp;
}

int getCompNew(const mxArray *compArray, int photo) {
    int comp;
    char compStr[64];

    if (!mxIsChar(compArray)) 
      mexErrMsgTxt("COMPRESSION must be a string");
    mxGetString(compArray, compStr, 64);
    
    if(!strncmp(compStr, "packbits",64))
        comp = COMPRESSION_PACKBITS; 
    else if(!strncmp(compStr, "ccitt",64))
        comp = COMPRESSION_CCITTRLE;
    else if(!strncmp(compStr, "thunder",64))
        comp = COMPRESSION_THUNDERSCAN;
    else if(!strncmp(compStr, "next",64))
        comp = COMPRESSION_NEXT;
    else if(!strncmp(compStr, "fax3",64))
        comp = COMPRESSION_CCITTFAX3;
    else if(!strncmp(compStr, "fax4",64))
        comp = COMPRESSION_CCITTFAX4;
    else if(!strncmp(compStr, "none",64))
        comp = COMPRESSION_NONE;
    else
        mexErrMsgTxt("Invalid compression scheme requested.");
    
    if((comp == COMPRESSION_CCITTRLE || 
        comp == COMPRESSION_CCITTFAX3 ||
        comp == COMPRESSION_CCITTFAX4) && photo != PHOTOMETRIC_MINISWHITE)
        mexErrMsgTxt("CCITT compression is only valid for binary images.");
    return comp;
}

void setXYRes(const mxArray *resArray, float *xres, float *yres) {

    double *resPr;
    if (!mxIsDouble(resArray)) 
      mexErrMsgTxt("Resolution argument must be double.");
    resPr = mxGetPr( resArray ); 

    switch (mxGetNumberOfElements(resArray)) {
    case 1:
        *xres = *yres = (float) resPr[0];
        break;
        
    case 2:
        *xres = (float) resPr[0];
        *yres = (float) resPr[1];
        break;
        
    default:
        mexErrMsgTxt("Resolution must be a scalar or a 2-element vector.");
    }
}

char *getTIFFFilename(const mxArray *fnameArray) {

    char *filename;
    long stringlen;

    if (!mxIsChar(fnameArray))
      mexErrMsgTxt("FILENAME must be a string");

    stringlen = mxGetM(fnameArray) * mxGetN(fnameArray) * sizeof(mxChar) + 1;
    filename = (char *) mxCalloc(stringlen, sizeof(*filename));
    mxGetString(fnameArray, filename, stringlen);
    return filename;
}

int getRowsPerStrip(int imType, int w) {
    int rowsPerStrip = 1;
    if (imType == RGB_IMG || imType == PACKED_RGB_IMG ) {
       /* Make each uncompressed strip fit in 8k if possible */
       if (w != 0) rowsPerStrip = 8192 / (w * 3);
     }
     else {
        /* Make each uncompressed strip fit in 8k if possible */
       if (w != 0) rowsPerStrip = 8192/w;
     }
     if (rowsPerStrip == 0)
       rowsPerStrip = 1;
     return rowsPerStrip;
}

int getRowsPerStripNew(int photo, int w, int spp) {

    int rowsPerStrip = 1;

    if (w != 0)
    {
        rowsPerStrip = 8192 / (w * spp);
    }

    if (rowsPerStrip == 0)
    {
        rowsPerStrip = 1;
    }

    return(rowsPerStrip);
}
