/* $Revision: 1.1.6.1 $ */
/* Copyright 1984-2001 The MathWorks, Inc.  */

/*
 * BMPDRLE --- decode RLE-compressed data in a BMP file
 *
 * OUT = BMPDRLE(IN, WIDTH, HEIGHT, METHOD)
 *
 * IN is a uint8 array containing the byte-stream read in from the file.
 *
 * WIDTH, HEIGHT are the expected image dimensions; these are obtained from
 * the header information.
 *
 * METHOD is either 'rle4' or 'rle8'.
 *
 * OUT is a uint8 array containing the decompressed byte-stream.
 * 
 * Reference: Murray and vanRyper, Encyclopedia of Graphics File Formats, 
 *            2nd ed, O'Reilly.
 */

static char rcsid[] = "$Id: bmpdrle.c,v 1.1.6.1 2003/12/13 02:58:43 batserve Exp $";

#include <string.h>
#include "mex.h"

#define RLE4 (1)
#define RLE8 (2)

#define LSN(value) ((value) & 0x0f)        /* least-significant nibble */
#define MSN(value) (((uint8_T) ((value) & 0xf0)) >> 4) /* most-significant */

/*
 * ValidateInput --- input argument-parsing and error checking
 *
 * Inputs:  nlhs   --- number of left-side arguments
 *          nrhs   --- number of right-side arguments
 *          prhs   --- array of right-side arguments
 *         
 * Outputs: width  --- expected image width
 *          height --- expected image height
 *          method --- RLE4 or RLE8
 *
 * Return:  none
 */
void ValidateInput(int nlhs, int nrhs, const mxArray *prhs[],
                   int *width, int *height, int *method)
{
    char *methodString;
    int strLength;

    if (nlhs > 1)
    {
        mexErrMsgTxt("Too many output arguments");
    }
    if (nrhs < 4)
    {
        mexErrMsgTxt("Too few input arguments");
    }
    if (nrhs > 4)
    {
        mexErrMsgTxt("Too many input arguments");
    }

    if (!mxIsUint8(prhs[0]))
    {
        mexErrMsgTxt("First input argument must be uint8");
    }
    if ((mxGetNumberOfElements(prhs[1]) != 1) || !mxIsNumeric(prhs[1]))
    {
        mexErrMsgTxt("Second input argument must be a numeric scalar");
    }
    if ((mxGetNumberOfElements(prhs[2]) != 1) || !mxIsNumeric(prhs[2]))
    {
        mexErrMsgTxt("Third input argument must be a numeric scalar");
    }
    if (!mxIsChar(prhs[3]))
    {
        mexErrMsgTxt("Fourth input argument must be a string");
    }

    *width = mxGetScalar(prhs[1]);
    *height = mxGetScalar(prhs[2]);
    if ((*width < 0) || (*height < 0))
    {
        mexErrMsgTxt("Width and height must be nonnegative");
    }

    strLength = mxGetM(prhs[3]) * mxGetN(prhs[3]) * sizeof(mxChar);
    methodString = mxCalloc(strLength + 1, sizeof(char));
    mxGetString(prhs[3], methodString, strLength + 1);

    if (strcmp(methodString, "rle4") == 0)
    {
        *method = RLE4;
    }
    else if (strcmp(methodString, "rle8") == 0)
    {
        *method = RLE8;
    }
    else {
        mexErrMsgTxt("Second input argument must be ""rle4"" or ""rle8""");
    }
}
    

#define CHK_OUT_BUFFER \
if (outBufferIndex >= outBufferSize) { \
    mexWarnMsgTxt("Apparent RLE decoding failure; BMP file may be corrupt"); \
    inBufferIndex = inBufferSize; \
    continue; \
} \
if (outBufferIndex < 0) { \
    mexErrMsgTxt("RLE decoding failure; BMP file may be corrupt"); \
}

#define CHK_IN_BUFFER \
if (inBufferIndex >= inBufferSize) { \
    mexWarnMsgTxt("Apparent RLE decoding failure; BMP file may be truncated");\
    inBufferIndex = inBufferSize; \
    continue; \
}

/*
 * bmpDecode --- decode rle-encoded byte stream
 *               This routine is used for both 4-bit RLE and 8-bit RLE
 *
 * Inputs:   outBufferSize --- allocated size of outBuffer in bytes
 *           width         --- expected image width
 *           height        --- expected image height
 *           method        --- RLE4 or RLE8
 *           inBuffer      --- input compressed byte-stream
 *           inBufferSize  --- length of input byte-stream in bytes
 *
 * Outputs:  outBuffer     --- decompressed byte-stream; must be preallocated
 *
 * Return:   none
 */
void bmpDecode(uint8_T *outBuffer, 
               int outBufferSize,
               int width, 
               int height, 
               int method,
               uint8_T *inBuffer,
               int inBufferSize)
{

    uint8_T runCount;
    uint8_T runValue;
    uint8_T value1;
    uint8_T value2;
    int32_T inBufferIndex = 0;
    int32_T outBufferIndex = 0;
    int32_T currentRow = 0;
    int32_T currentColumn = 0;
    int k;
    bool endOfBitmapFound = false;

    while (inBufferIndex < inBufferSize) {
        CHK_IN_BUFFER;
        runCount = (int32_T) inBuffer[inBufferIndex++];
        CHK_IN_BUFFER;
        runValue = inBuffer[inBufferIndex++];

        switch (runCount) {

          case 0:

            switch (runValue) {
              case 0:
                /* end-of-scanline escape code */
                currentRow = 0;
                currentColumn++;
                outBufferIndex = currentColumn * width + currentRow;
                
                break;

              case 1:
                /* end-of-bitmap escape code */
                if (inBufferIndex < inBufferSize) {
                    mexWarnMsgTxt("End-of-bitmap code encountered "
                                  "before end of data");
                    inBufferIndex = inBufferSize;
                    continue;
                }
                endOfBitmapFound = true;
                
                break;

              case 2:
                /* delta escape code */
                CHK_IN_BUFFER;
                currentRow += inBuffer[inBufferIndex++];
                CHK_IN_BUFFER;
                currentColumn -= inBuffer[inBufferIndex++];
                /* BMP "width" is MATLAB's height because we're reading */
                /* into a column-major array. */
                outBufferIndex = currentColumn * width + currentRow;

                break;

              default:
                /* literal run */

                if (method == RLE8) {
                    for (k = 0; k < (int) runValue/2; k++) {
                        /* Read 2 bytes from input buffer */
                        CHK_IN_BUFFER;
                        value1 = inBuffer[inBufferIndex++];
                        CHK_IN_BUFFER;
                        value2 = inBuffer[inBufferIndex++];

                        CHK_OUT_BUFFER;
                        outBuffer[outBufferIndex++] = value1;
                        currentRow++;

                        CHK_OUT_BUFFER;
                        outBuffer[outBufferIndex++] = value2;
                        currentRow++;
                    }

                    if ((runValue % 2) != 0) {
                        /* Read 2 bytes from input buffer */
                        CHK_IN_BUFFER;
                        value1 = inBuffer[inBufferIndex++];
                        CHK_IN_BUFFER;
                        value2 = inBuffer[inBufferIndex++];

                        /* only first value gets used */
                        CHK_OUT_BUFFER;
                        outBuffer[outBufferIndex++] = value1;
                    }

                } else {
                    /* decoding is broken up below because runs */
                    /* must be word-aligned */
                    for (k = 0; k < (int) runValue/4; k++) {
                        /* Read 2 bytes from input buffer */
                        CHK_IN_BUFFER;
                        value1 = inBuffer[inBufferIndex++];
                        CHK_IN_BUFFER;
                        value2 = inBuffer[inBufferIndex++];

                        /* put 4 values into the output buffer */
                        CHK_OUT_BUFFER;
                        outBuffer[outBufferIndex++] = MSN(value1);
                        currentRow++;

                        CHK_OUT_BUFFER;
                        outBuffer[outBufferIndex++] = LSN(value1);
                        currentRow++;

                        CHK_OUT_BUFFER;
                        outBuffer[outBufferIndex++] = MSN(value2);
                        currentRow++;

                        CHK_OUT_BUFFER;
                        outBuffer[outBufferIndex++] = LSN(value2);
                        currentRow++;
                    }
                    
                    if ((runValue % 4) != 0) {
                        /* Read 2 bytes from input buffer */
                        CHK_IN_BUFFER;
                        value1 = inBuffer[inBufferIndex++];
                        CHK_IN_BUFFER;
                        value2 = inBuffer[inBufferIndex++];

                        CHK_OUT_BUFFER;
                        outBuffer[outBufferIndex++] = MSN(value1);
                        currentRow++;

                        if ((int) (runValue % 4) > 1) {
                            CHK_OUT_BUFFER;
                            outBuffer[outBufferIndex++] = LSN(value1);
                            currentRow++;
                        }

                        if ((int) (runValue % 4) > 2) {
                            CHK_OUT_BUFFER;
                            outBuffer[outBufferIndex++] = MSN(value2);
                        }
                    }

                }
            }

            break;

        default:  /* encoded run */
            
            if (method == RLE4) {
                /* alternate writing the most-significant and
                 * least-significant nibble to the buffer
                 */
                for (k = 0; k < (int) runCount/2; k++) {
                    CHK_OUT_BUFFER;
                    outBuffer[outBufferIndex++] = MSN(runValue);
                    currentRow++;

                    CHK_OUT_BUFFER;
                    outBuffer[outBufferIndex++] = LSN(runValue);
                    currentRow++;
                }

                if ((runCount % 2) != 0) {
                    /* odd-length run */
                    CHK_OUT_BUFFER;
                    outBuffer[outBufferIndex++] = MSN(runValue);
                    currentRow++;
                }

            } else {
                /* write an 8-bit value */
                while (runCount--) {
                    CHK_OUT_BUFFER;
                    outBuffer[outBufferIndex++] = runValue;
                }
            }
            break;
            
        }
    }

    if (!endOfBitmapFound)
    {
        mexWarnMsgTxt("No end-of-bitmap code; BMP file may be truncated");
    }
}


void mexFunction(int nlhs, 
                 mxArray *plhs[], 
                 int nrhs, 
                 const mxArray *prhs[])
{
    int width;
    int height;
    int method;
    int inputBufferLength;
    int outputBufferLength;
    uint8_T *inputBuffer;
    uint8_T *outputBuffer;
    mxArray *Out;
    int outputSize[2];

    ValidateInput(nlhs, nrhs, prhs, &width, &height, &method);

    outputSize[0] = width;
    outputSize[1] = height;
    Out = mxCreateNumericArray(2, outputSize, mxUINT8_CLASS, mxREAL);
    outputBuffer = (uint8_T *) mxGetData(Out);
    outputBufferLength = width * height;

    inputBuffer = (uint8_T *) mxGetData(prhs[0]);
    inputBufferLength = mxGetM(prhs[0]) * mxGetN(prhs[0]);

    bmpDecode(outputBuffer, outputBufferLength, width, height, method, 
              inputBuffer, inputBufferLength);

    plhs[0] = Out;

}







                    
                
