/*
 * imjpg.c  
 *  
 * Returns information about a JPEG image file.
 *
 * Calls the jpeg library which is part of 
 * "The Independent JPEG Group's JPEG software" collection.
 *
 * The jpeg library came from
 * ftp://ftp.uu.net/graphics/jpeg/jpegsrc.v6.tar.gz
 *
 * Chris Griffin, June 1996
 * Copyright 1984-2001 The MathWorks, Inc. 
 * $Revision: 1.1.6.1 $  $Date: 2003/12/13 03:00:25 $
 */

#include "mex.h"
#include <stdio.h>
#include <setjmp.h>
#include "jpeglib8.h"

static void my_error_exit (j_common_ptr cinfo);
static void my_output_message (j_common_ptr cinfo);

struct my_error_mgr {
  struct jpeg_error_mgr pub;	/* "public" fields */
  jmp_buf setjmp_buffer;	/* for return to caller */
};

typedef struct my_error_mgr * my_error_ptr;

/* structure field table */
static const char *fieldTable[] = {
  "Filename",
  "FileModDate",
  "FileSize",
  "Format",
  "FormatVersion",
  "Width",
  "Height",
  "BitDepth",
  "ColorType",
  "FormatSignature",
  "NumberOfSamples",
  "CodingMethod",
  "CodingProcess",
  "Comment"
};

#define NUM_FIELDS (sizeof(fieldTable)/sizeof(*fieldTable))
#define MAX_COMMENT_LENGTH 65535  /* Maximum comment length */

/*EXTERN(boolean) jpeg_start_decompress JPP((j_decompress_ptr cinfo)) {
return FALSE;
} */

#define GetOut(errmsg) \
            msgArray = mxCreateString(errmsg); \
            infoArray = mxCreateDoubleMatrix(0,0,mxREAL); \
            plhs[0] = infoArray; \
            plhs[1] = msgArray; \
            return;

mxArray* ReadComments(struct jpeg_decompress_struct cinfo)
{
    mxArray *commentArray;
    int num_comments = 0;          /* Number of comments in the file */
    int i;                         /* Counter on number of comments */

    if (cinfo.marker_list != 0)
    {
        char *comment_C_string;
        size_t slen;                   /* Length of the comment */

        jpeg_saved_marker_ptr tmpptr;  /* Temp pointer */
        
        /* First count the number of comments */
        tmpptr = cinfo.marker_list;
        while ((tmpptr != 0) && tmpptr->marker != 0)
        {
            if ((cinfo.marker_list)->marker == JPEG_COM)
            {
                num_comments++;
            }
            tmpptr = tmpptr->next;
        }

        /* Set up the cell array to return */
        commentArray = mxCreateCellMatrix(num_comments, 1);

        /* Populate the cell array */
        i = 0;
        while ((cinfo.marker_list != 0) && (cinfo.marker_list)->marker != 0)
        {
            if ((cinfo.marker_list)->marker == JPEG_COM)
            {
                slen = (cinfo.marker_list)->data_length;
                comment_C_string = (char *) mxMalloc((slen+1) * sizeof(char));
                memcpy(comment_C_string, (const char *) (cinfo.marker_list)->data, slen);
                comment_C_string[slen] = 0;
                mxSetCell(commentArray, i, mxCreateString(comment_C_string));
                mxFree(comment_C_string);
            }
            cinfo.marker_list = (cinfo.marker_list)->next;
            i++;
        }
    }else
    {
        commentArray = mxCreateCellMatrix(0,0);
    }

    return commentArray;
}

void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[]) { 
  FILE *infile = NULL;
  char *filename;
  int32_T strlen;
  struct jpeg_decompress_struct cinfo;
  char errmsg[1024];
  struct my_error_mgr jerr;
  double rows, cols, output_components;
  const char gray_string[] = "gray";
  const char rgb_string[]  = "rgb";
  mxArray *infoArray, *msgArray;            /* The structure array for returning info */
  mxArray *rowArray, *colArray, *typeArray, *formatArray, *filenameArray;
  mxArray *bitDepthArray, *formatVersionArray, *formatSignatureArray;
  mxArray *commentArray, *numberOfSamplesArray, *codingMethod, *codingProcess;

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

  /* Set up the decompression object to take read comment markers */
  jpeg_save_markers(&cinfo, JPEG_COM, MAX_COMMENT_LENGTH);

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
  jpeg_start_decompress(&cinfo);

  output_components = cinfo.output_components;
  cols = cinfo.output_width;
  rows = cinfo.output_height;

  infoArray = mxCreateStructMatrix(1,1,NUM_FIELDS,fieldTable);
  
  rowArray = mxCreateDoubleScalar(rows);
  mxSetField(infoArray, 0, "Height", rowArray);
  
  colArray = mxCreateDoubleScalar(cols);
  mxSetField(infoArray, 0, "Width", colArray);
  
  if(output_components == 1)
      typeArray = mxCreateString(gray_string);
  else if(output_components == 3)
      typeArray = mxCreateString(rgb_string);
  else 
  {
      jpeg_destroy_decompress(&cinfo);
      fclose(infile);
      GetOut("Jpeg image is neither grayscale or RGB.");
  }
  mxSetField(infoArray, 0, "ColorType", typeArray);

  bitDepthArray = mxCreateDoubleScalar(output_components * cinfo.data_precision);
  mxSetField(infoArray, 0, "BitDepth", bitDepthArray);

  formatArray = mxCreateString("jpg");
  mxSetField(infoArray, 0, "Format", formatArray);

  filenameArray = mxCreateString(filename);
  mxSetField(infoArray, 0, "Filename", filenameArray);

  formatVersionArray = mxCreateString("");
  mxSetField(infoArray, 0, "FormatVersion", formatVersionArray);

  formatSignatureArray = mxCreateString("");
  mxSetField(infoArray, 0, "FormatSignature", formatSignatureArray);

  numberOfSamplesArray = mxCreateDoubleScalar(output_components);
  mxSetField(infoArray, 0, "NumberOfSamples", numberOfSamplesArray);

  codingMethod = mxCreateDoubleScalar(cinfo.arith_code);
  mxSetField(infoArray, 0, "CodingMethod", codingMethod);

  codingProcess = mxCreateDoubleScalar(cinfo.process);
  mxSetField(infoArray, 0, "CodingProcess", codingProcess);

  commentArray = ReadComments(cinfo);
  mxSetField(infoArray, 0, "Comment", commentArray);

/*
 * Clean up
 */

  fclose(infile);
  jpeg_destroy_decompress(&cinfo);

/*
 * Give the mexfile output arguments by making the
 * pointer to left hand side point to the RGB matrices.
 */

  msgArray = mxCreateString("");
  
  plhs[0] = infoArray;
  plhs[1] = msgArray;
  
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
  mexPrintf("%s\n", buffer);
}
