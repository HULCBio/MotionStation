/*
 * RJPGC.MEX 
 *
 * This is a mex interface to the Independent Jpeg Group's (IJG)
 * LIBJPEG libaray.  This can read RGB and grayscale JPEG images.
 * 
 * The syntaxes are:
 *    
 *      RGB = rjpgc(filename);
 *      GRAY = rjpgc(filename); 
 * 
 * RGB is a mxnx3 uint8 array containing the 24-bit image stored in
 * the jpeg file filename.    
 * 
 * GRAY is a mxn uint8 array containing the 8-bit grayscale image
 * stored in the jpeg file filename.    
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
 * $Revision: 1.1.6.1 $  $Date: 2003/12/13 03:01:22 $
 */

static char rcsid[] = "$Id: rjpg8c.c,v 1.1.6.1 2003/12/13 03:01:22 batserve Exp $";


#include "mex.h"
#include <stdio.h>
#include <setjmp.h>
#include "jpeglib8.h"

static mxArray *ReadRgbJPEG(j_decompress_ptr cinfoPtr);
static mxArray *ReadGrayJPEG(j_decompress_ptr cinfoPtr);
static void my_error_exit (j_common_ptr cinfo);
static void my_output_message (j_common_ptr cinfo);

struct my_error_mgr {
  struct jpeg_error_mgr pub;	/* "public" fields */
  jmp_buf setjmp_buffer;	/* for return to caller */
};

typedef struct my_error_mgr *my_error_ptr;



void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[]) { 
  FILE *infile=NULL;
  mxArray *outArray;
  char *filename;
  int32_T strlen;
  struct jpeg_decompress_struct cinfo;
  struct my_error_mgr jerr;
  int current_row;
  
  if (nrhs < 1)
  {
      mexErrMsgTxt("Not enough input arguments.");
  }      
  if(! mxIsChar(prhs[0]))
  {
      mexErrMsgTxt("First argument is not a string.");
  }

  strlen = mxGetM(prhs[0]) * mxGetN(prhs[0]) * sizeof(mxChar) + 1;
  filename = (char *) mxCalloc(strlen, sizeof(*filename));
  mxGetString(prhs[0],filename,strlen);  /* First argument is the filename */

/*
 * Initialize the jpeg library
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
      jpeg_destroy_decompress(&cinfo);
      fclose(infile);
      return;
  }
     
  jpeg_create_decompress(&cinfo);

/*
 * Open jpg file
 */

  if ((infile = fopen(filename, "rb")) == NULL) {
    mexErrMsgTxt("Couldn't open file");
  }
  mxFree((void *) filename);

/*
 * Read the jpg header to get info about size and color depth
 */

  jpeg_stdio_src(&cinfo, infile);
  jpeg_read_header(&cinfo, TRUE);
  jpeg_start_decompress(&cinfo);
  if (cinfo.output_components == 1) { /* Grayscale */
      outArray = ReadGrayJPEG(&cinfo);
  }
  else 
  {
      outArray = ReadRgbJPEG(&cinfo);
  }

/*
 * Clean up
 */

  jpeg_finish_decompress(&cinfo); fclose(infile);
  jpeg_destroy_decompress(&cinfo);

/*
 * Give the mexfile output arguments by making the
 * pointer to left hand side point to the RGB matrices.
 */

  plhs[0]=outArray;
  
  return;		
}


static mxArray *
ReadRgbJPEG(j_decompress_ptr cinfoPtr)
{
    long i,j,k,row_stride;
    int dims[3];                  /* For the call to mxCreateNumericArray */
    mxArray *img;
    JSAMPARRAY buffer;
    int current_row;
    uint8_T *pr_red, *pr_green, *pr_blue;
    
    /*
     * Allocate buffer for one scan line
     */
    
    row_stride = cinfoPtr->output_width * cinfoPtr->output_components;
    buffer = (*cinfoPtr->mem->alloc_sarray)
        ((j_common_ptr) cinfoPtr, JPOOL_IMAGE, row_stride, 1);
    
    /*
     * Create 3 matrices, One each for the Red, Green, and Blue componenet of 
     * the image.
     */
    
    dims[0]  = cinfoPtr->output_height;
    dims[1]  = cinfoPtr->output_width;
    dims[2]  = 3;
    
    img = mxCreateNumericArray(3, dims, mxUINT8_CLASS, mxREAL);
    
    
    /*
     * Get pointers to the real part of each matrix (data is stored 
     * in a 1 dimensional double array).
     */
    
    pr_red   = (uint8_T *) mxGetData(img);
    pr_green = pr_red + (dims[0]*dims[1]);
    pr_blue  = pr_red + (2*dims[0]*dims[1]);
    
    while (cinfoPtr->output_scanline < cinfoPtr->output_height) {
        current_row = cinfoPtr->output_scanline; /* Temp var won't get ++'d */
        jpeg_read_scanlines(cinfoPtr, buffer,1); /*  by jpeg_read_scanlines */
        for (i=0;i<cinfoPtr->output_width;i++) {     
            j=(i)*cinfoPtr->output_height+current_row;       
            pr_red[j]   = buffer[0][i*3+0];
            pr_green[j] = buffer[0][i*3+1];
            pr_blue[j]  = buffer[0][i*3+2];
        }
    }
    return img;
}



static mxArray *
ReadGrayJPEG(j_decompress_ptr cinfoPtr)
{
    long i,j,k,row_stride;
    int dims[3];                  /* For the call to mxCreateNumericArray */
    mxArray *img;
    JSAMPARRAY buffer;
    int current_row;
    uint8_T *pr_gray;
        
    /*
     * Allocate buffer for one scan line
     */
    
    row_stride = cinfoPtr->output_width * cinfoPtr->output_components;
    buffer = (*cinfoPtr->mem->alloc_sarray)
        ((j_common_ptr) cinfoPtr, JPOOL_IMAGE, row_stride, 1);
    
    /*
     * Create 3 matrices, One each for the Red, Green, and Blue componenet of 
     * the image.
     */
    
    dims[0]  = cinfoPtr->output_height;
    dims[1]  = cinfoPtr->output_width;
    dims[2]  = 1;
    
    img = mxCreateNumericArray(2, dims, mxUINT8_CLASS, mxREAL);
    
    
    /*
     * Get pointers to the real part of each matrix (data is stored 
     * in a 1 dimensional double array).
     */
    
    pr_gray   = (uint8_T *) mxGetData(img);
    
    while (cinfoPtr->output_scanline < cinfoPtr->output_height) {
        current_row=cinfoPtr->output_scanline; /* Temp var won't get ++'d */
        jpeg_read_scanlines(cinfoPtr, buffer,1); /*  by jpeg_read_scanlines */
        for (i=0;i<cinfoPtr->output_width;i++) {     
            j=(i)*cinfoPtr->output_height+current_row;       
            pr_gray[j]   = buffer[0][i];
        }
    }
    return img;
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
  /* We could postpone this until after returning, if we chose. */
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
