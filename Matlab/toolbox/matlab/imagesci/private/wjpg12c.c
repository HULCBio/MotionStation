/*
 * WJPGC8.C 
 *
 * This is a mex interface to the Independent Jpeg Group's (IJG)
 * LIBJPEG libaray.  This can write RGB and grayscale JPEG images.
 * 
 * The syntaxes are:
 *    
 *    
 *      wjpgc(RGB, filename);
 *      wjpgc(GRAY, filename);
 *      wjpgc(... , quality);
 * 
 * RGB is either a mxnx3 uint8 array containing a 24-bit image to
 * be stored in the jpeg file filename or a mxn uint32 array with 
 * each 4 bytes being RGBA, where A is currently garbage (maybe Alpha
 * in the future).
 *       
 * GRAY is a mxn uint8 array containing a grayscale image to
 * be stored in the jpeg file filename.    
 * 
 * The quality argument specifies the compression scheme's quality
 * setting which adjusts the tradeoff between image quality and
 * file-size. 
 * 
 * 
 * KNOWN BUGS:
 * -----------
 *
 * ENHANCEMENTS UNDER CONSIDERATION:
 * ---------------------------------
 * 
 * 
 * The IJG code is available at:
 * ftp://ftp.uu.net/graphics/jpeg/jpegsrc.v6.tar.gz
 * 
 * Chris Griffin, June 1996
 * Copyright 1984-2001 The MathWorks, Inc. 
 * $Revision: 1.1.6.1 $  $Date: 2003/12/13 03:01:30 $
 */



#include "mex.h"
#include <stdio.h>
#include <setjmp.h>
#include <string.h>
#include "jpeglib12.h"

#define IMAGE_TYPE     int
#define RGB_IMG          0
#define GRAY_IMG         1

#define MEX_JPEG_MODE    int
#define MEX_JPEG_LOSSY     0
#define MEX_JPEG_LOSSLESS  1

#define MAX_MODE_LENGTH 8

#define UCHAR UINT8_T

static void getComment(const mxArray *props, 
                       const mxArray **commentArray);

static MEX_JPEG_MODE getCompMode(const mxArray *props);

static void getFilename(const mxArray *fname, 
                        char *filename[]);

static IMAGE_TYPE getImageType(int ndims, 
                               const int *size, 
                               mxClassID inClass);

static int getQuality(const mxArray *props);

static void setColorspace(j_compress_ptr cinfoPtr, 
                          IMAGE_TYPE imageType);

static void setInputComponents(j_compress_ptr cinfoPtr, 
                               IMAGE_TYPE imageType);

static void WriteComment(j_compress_ptr cinfoPtr, 
                         const mxArray *commentArray);

static void WriteGRAYFromUint16(j_compress_ptr cinfoPtr, 
                               uint16_T *uint16Data, 
                               const int *size);

static void WriteImageData(j_compress_ptr cinfoPtr, 
                           const mxArray *inputArray,
                           IMAGE_TYPE imageType,
                           const int *size);

static void WriteRGBFromUint16(j_compress_ptr cinfoPtr, 
                              uint16_T *uint16Data, 
                              const int *size);


/* 
 *  These replace specific routines in the jpeg library's
 *  jerror.c module. 
 */
static void my_error_exit (j_common_ptr cinfo);
static void my_output_message (j_common_ptr cinfo);

struct my_error_mgr {
  struct jpeg_error_mgr pub;	/* "public" fields */
  jmp_buf setjmp_buffer;	/* for return to caller */
};

typedef struct my_error_mgr * my_error_ptr;


void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[]) {

    const mxArray *inputArray;
    const mxArray *commentArray = 0;
    const mxArray *props;

    struct jpeg_compress_struct cinfo;
    struct my_error_mgr jerr;

    double *doubleData;
    int ndims, imageType;
    const int *size;
    char *filename = 0;
    FILE *outfile=NULL;
    int inClass, quality;
    MEX_JPEG_MODE compMode;
   

    /*
     * Argument parsing.
     */

    if (nrhs != 3)
    {
        mexErrMsgTxt("Three input arguments required.");
    }

    if (! mxIsChar(prhs[1]))
    {
        mexErrMsgTxt("Second argument must be a string.");
    }

    if (! mxIsStruct(prhs[2]))
    {
        mexErrMsgTxt("Third argument must be a property structure.");
    }


    inputArray = prhs[0];

    getFilename(prhs[1], &filename);
    compMode = getCompMode(prhs[2]); 
    getComment(prhs[2], &commentArray);

    if (compMode == MEX_JPEG_LOSSY)
    {
        quality = getQuality(prhs[2]); 
    }

    
    /*
     * Initialize the JPEG library message handlers.
     */
    
    cinfo.err = jpeg_std_error(&jerr.pub);
    jerr.pub.output_message = my_output_message;
    jerr.pub.error_exit = my_error_exit;
    if(setjmp(jerr.setjmp_buffer))
    {
        /* If we get here, the JPEG code has signaled an error.
         * We need to clean up the JPEG object, close the input file, 
         * and return.
         */
        jpeg_destroy_compress(&cinfo);
        fclose(outfile);
        return;
    }


    /*
     * Set up the info parameters.
     */
    
    jpeg_create_compress(&cinfo);

    ndims = mxGetNumberOfDimensions(inputArray);
    size = mxGetDimensions(inputArray);
    inClass = mxGetClassID(inputArray); 

    imageType = getImageType(ndims, size, inClass);
    
    cinfo.image_width =  size[1];
    cinfo.image_height = size[0]; 

    setColorspace(&cinfo, imageType);
    setInputComponents(&cinfo, imageType);

    /* Set default compression parameters. */
    jpeg_set_defaults(&cinfo);
    jpeg_set_quality(&cinfo, quality, TRUE);

    
    /*
     * Open output file.
     */
    
    if ((outfile = fopen(filename, "wb")) == NULL) {
        mexErrMsgTxt("Couldn't open file for JPEG write.");
    }

    jpeg_stdio_dest(&cinfo, outfile);


    /*
     * Write data.
     */

    if (compMode == MEX_JPEG_LOSSLESS)
    {
        jpeg_simple_lossless(&cinfo, 1, 0);
    }

    jpeg_start_compress(&cinfo, TRUE);

    WriteComment(&cinfo, commentArray);
    WriteImageData(&cinfo, inputArray, imageType, size);


    /*
     * Clean up.
     */
    
    jpeg_finish_compress(&cinfo); fclose(outfile);
    jpeg_destroy_compress(&cinfo);
    mxFree(filename);
    return;		
}



static void 
WriteRGBFromUint16(j_compress_ptr cinfoPtr, 
                   uint16_T *uint16Data, 
                   const int *size)
{
    int row_stride,i,j;
  JSAMPARRAY buffer;

  row_stride = size[1] * 3;	
  buffer = (*cinfoPtr->mem->alloc_sarray)
                ((j_common_ptr) cinfoPtr, JPOOL_IMAGE, row_stride, 1);

  /* jpeg_write_scanlines expects an array of pointers to scanlines.
   * Here the array is only one element long, but you could pass
   * more than one scanline at a time if that's more convenient.
   */

  while (cinfoPtr->next_scanline < cinfoPtr->image_height) {
      /* construct a buffer which contains the next scanline with data in
       * RGBRGBRGB... format */
      i = cinfoPtr->next_scanline;
      for(j=0; j<cinfoPtr->image_width; j++)
      {
          buffer[0][3*j]   = uint16Data[i+(j*size[0])]; /* Red */
          buffer[0][3*j+1] = uint16Data[i+(j*size[0])+(size[0]*size[1])]; /* Green */
          buffer[0][3*j+2] = uint16Data[i+(j*size[0])+(2*size[0]*size[1])]; /* Blue */
      }
      (void) jpeg_write_scanlines(cinfoPtr, buffer, 1);
  } 
}  
  


static void 
WriteGRAYFromUint16(j_compress_ptr cinfoPtr, 
                  uint16_T *uint16Data, 
                  const int *size)
{
  int row_stride,i,j;
  JSAMPARRAY buffer;

  row_stride = size[1];	
  buffer = (*cinfoPtr->mem->alloc_sarray)
                ((j_common_ptr) cinfoPtr, JPOOL_IMAGE, row_stride, 1);

  /* jpeg_write_scanlines expects an array of pointers to scanlines.
   * Here the array is only one element long, but you could pass
   * more than one scanline at a time if that's more convenient.
   */

  while (cinfoPtr->next_scanline < cinfoPtr->image_height) {
      /* construct a buffer which contains the next scanline with data in
       * RGBRGBRGB... format */
      i = cinfoPtr->next_scanline;
      for(j=0; j<cinfoPtr->image_width; j++)
      {
          buffer[0][j]   = uint16Data[i+(j*size[0])]; 
      }
      (void) jpeg_write_scanlines(cinfoPtr, buffer, 1);
  } 
}  



/*
 * Here's the routine that will replace the standard error_exit method:
 */

static void
my_error_exit (j_common_ptr cinfo)
{
  /* cinfo->err really points to a my_error_mgr struct, so coerce pointer */
  my_error_ptr myerr = (my_error_ptr) cinfo->err;

  /* Always display the message. */
  /* We coulD postpone this until after returning, if we chose. */
  (*cinfo->err->output_message) (cinfo);

  /* Return control to the setjmp point */
  longjmp(myerr->setjmp_buffer, 1);
}



/* 
 *  Here's the routine to replace the standard output_message method:
 */

static void
my_output_message (j_common_ptr cinfo)
{
  char buffer[JMSG_LENGTH_MAX];

  /* Create the message */
  (*cinfo->err->format_message) (cinfo, buffer);

  /* Send it to stderr, adding a newline */
  mexWarnMsgTxt(buffer);
}



void WriteComment(j_compress_ptr cinfoPtr, const mxArray *commentArray)
{
    /*
     * Write out each row of commentArray as a comment.
     * This has to be called after jpeg_start_compress().
     */
    char comment[0xFFFF]; /* Buffer for c-string comment */
    int numRows;          /* number of rows in the cell array input */
    long stringLength;          /* length of the comment string */
    int i;                /* counter */

    if (commentArray != 0)
    {
        numRows = mxGetM(commentArray);
        for (i = 0; i < numRows; i++)
        {
            if (mxIsCell(commentArray)) 
	    {
		mxArray *commentA = mxGetCell(commentArray, i);
		stringLength = mxGetM(commentA) * mxGetN(commentA) * sizeof(mxChar) + 1;
		mxGetString(commentA, comment, stringLength);

                jpeg_write_marker(cinfoPtr, JPEG_COM, (UCHAR *) comment, stringLength);
	    }
        }
    }   
}



static void getFilename(const mxArray *fname, char *filename[])
{
    long stringLength;

    stringLength = mxGetM(fname) * mxGetN(fname) * sizeof(mxChar) + 1;
    *filename = (char *) mxCalloc(stringLength, sizeof(*filename));
    mxGetString(fname, *filename, stringLength);
}



static MEX_JPEG_MODE getCompMode(const mxArray *props)
{
    mxArray *compModePtr;
    MEX_JPEG_MODE compMode;
    char buf[MAX_MODE_LENGTH + 1];
    
    compModePtr = mxGetField(props, 0, "mode");
    if (compModePtr == NULL)
    {
        mexErrMsgTxt("Property struct must have a 'mode' field.");
    }

    mxGetString(compModePtr, buf, (MAX_MODE_LENGTH + 1));
    
    if (!strncmp(buf, "lossless", MAX_MODE_LENGTH))
    {
        return MEX_JPEG_LOSSLESS;
    } 
    else if (!strncmp(buf, "lossy", MAX_MODE_LENGTH))
    {
        return MEX_JPEG_LOSSY;
    }
    else
    {
        mexErrMsgTxt("Unrecognized JPEG compression mode.");
    }
}



static int getQuality(const mxArray *props)
{
    mxArray *qualityPtr;

    qualityPtr = mxGetField(props, 0, "quality");
    if (qualityPtr == NULL)
    {
        mexErrMsgTxt("Property struct must have a 'quality' field.");
    }

    return (int) mxGetScalar(qualityPtr);
}



static void getComment(const mxArray *props, const mxArray **commentArray)
{
    *commentArray = mxGetField(props, 0, "comment");

    if (*commentArray == NULL)
    {
        mexErrMsgTxt("Property struct must have a 'comments' field.");
    }
}



static IMAGE_TYPE getImageType(int ndims, const int *size, mxClassID inClass)
{
    if( (ndims == 3 && size[2] == 3) && inClass == mxUINT16_CLASS )
    {
        return RGB_IMG;
    }
    else if(ndims == 2 && inClass == mxUINT16_CLASS )
    {
        return GRAY_IMG;
    }
    else
    {
        mexErrMsgTxt("Invalid image array");
    }
}



static void setColorspace(j_compress_ptr cinfoPtr, IMAGE_TYPE imageType)
{
    /* Colorspace of the input image.  */
    switch (imageType) {
    case RGB_IMG:
        cinfoPtr->in_color_space = JCS_RGB;
        break;

    case GRAY_IMG:
        cinfoPtr->in_color_space = JCS_GRAYSCALE;
        break;

    }
}



static void setInputComponents(j_compress_ptr cinfoPtr, IMAGE_TYPE imageType)
{
    switch (imageType) {
    case RGB_IMG:
        cinfoPtr->input_components = 3;
        break;

    case GRAY_IMG:
        cinfoPtr->input_components = 1;
        break;

    }
}



static void WriteImageData(j_compress_ptr cinfoPtr, 
                           const mxArray *inputArray,
                           IMAGE_TYPE imageType,
                           const int *size)
{
    switch (imageType) {
    case RGB_IMG:
        WriteRGBFromUint16(cinfoPtr, (uint16_T *) mxGetData(inputArray), size);
        break;

    case GRAY_IMG:
        WriteGRAYFromUint16(cinfoPtr, (uint16_T *) mxGetData(inputArray), size);
        break;

    }
}
