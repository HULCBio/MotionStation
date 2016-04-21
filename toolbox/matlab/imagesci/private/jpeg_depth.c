/* $Revision: 1.1.6.1 $ */
/*
 * jpeg_depth.c
 *
 * Returns the bit depth of a JPEG image without opening the image data.
 *
 * Calls the jpeg library which is part of 
 * "The Independent JPEG Group's JPEG software" collection.
 *
 * The jpeg library came from
 * ftp://ftp.uu.net/graphics/jpeg/jpegsrc.v6.tar.gz
 *
 * Copyright 1984-2001 The MathWorks, Inc. 
 * $Revision $  $Date $
 */

#include "mex.h"
#include <stdio.h>
#include <setjmp.h>
#include "jpeglib16.h"
#include "jerror16.h"

static void my_error_exit (j_common_ptr cinfo);
static void my_output_message (j_common_ptr cinfo);

struct my_error_mgr {
  struct jpeg_error_mgr pub;	/* "public" fields */
  jmp_buf setjmp_buffer;	/* for return to caller */
};

typedef struct my_error_mgr * my_error_ptr;

#define GetOut(errmsg) \
            msgArray = mxCreateString(errmsg); \
            plhs[0] = mxCreateDoubleMatrix(0, 0, mxREAL); \
            plhs[1] = msgArray; \
            return;

void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[]) {

  FILE *infile = NULL;
  char *filename;
  int32_T strlen;
  struct jpeg_decompress_struct cinfo;
  char errmsg[1024];
  struct my_error_mgr jerr;
  mxArray *msgArray;

  if (nrhs < 1)
  {
      mexErrMsgTxt("Not enough input arguments.");
  }      
  if(!mxIsChar(prhs[0]))
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
      sprintf(errmsg,"Couldn't open %s.\n",filename);
      jpeg_destroy_decompress(&cinfo);
      GetOut(errmsg);
  }

/*
 * Read the jpg header to get info about size and color depth
 */

  jpeg_stdio_src(&cinfo, infile);

  jpeg_read_header(&cinfo, TRUE);

  plhs[0] = mxCreateScalarDouble((double) cinfo.data_precision);
  plhs[1] = mxCreateString("");

/*
 * Clean up
 */

  fclose(infile);
  jpeg_destroy_decompress(&cinfo);
  
  return;		

}


/*
 * Here's the routine that will replace the standard error_exit method:
 */

static void
my_error_exit (j_common_ptr cinfo)
{
  /* cinfo->err really points to a my_error_mgr struct, so coerce pointer */
  my_error_ptr myerr = (my_error_ptr) cinfo->err;

  if ((cinfo->err->msg_code == JERR_BAD_PRECISION) ||
      (cinfo->err->msg_code == JERR_SOF_UNSUPPORTED)) {

      /* We may be able to handle these.  The message may indicate that this
       * bit-depth and/or compression mode aren't supported by this "flavor"
       * of the library.  Continue on.  */
      return;
  }
  
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
  mexPrintf("%s\n", buffer);
}
