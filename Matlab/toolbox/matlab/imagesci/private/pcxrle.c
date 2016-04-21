/* $Revision: 1.1.6.1 $ */
/* Copyright 1984-2001 The MathWorks, Inc.  */

/*
 * PCXRLE.MEX
 *
 * MATLAB usage:
 *   pcxrle(filename, data)
 *
 * Encodes the *columns* of the data array as PCX-rle encoded
 * scanlines, appending the encoded data to the specified file.
 *
 * The class of the data array must be uint8.
 */

static char rcsid[] = "$Id: pcxrle.c,v 1.1.6.1 2003/12/13 03:00:56 batserve Exp $";

#include "mex.h"


#include <errno.h>
#include <string.h>
#include "mex.h"

/*
 * ValidateInput --- input argument parsing and error checking
 *
 * Inputs:  nlhs --- number of left-side arguments
 *          nrhs --- number of right-side arguments
 *          prhs --- array of pointers to right-side arguments
 *
 * Outputs: fp       --- file pointer
 *          A        --- data array
 *
 * Return:  none
 */
void ValidateInput(int nlhs, int nrhs, const mxArray *prhs[],
                   FILE **fp, const mxArray **A)
{
    char *fname = NULL;
    long length;

    if (nrhs < 2)
    {
        mexErrMsgTxt("Too few input arguments");
    }
    if (nrhs > 2)
    {
        mexErrMsgTxt("Too many input arguments");
    }
    if (nlhs > 0)
    {
        mexErrMsgTxt("Too many output arguments");
    }

    if (!mxIsChar(prhs[0]))
    {
        mexErrMsgTxt("FILENAME must be a string");
    }

    if (!mxIsUint8(prhs[1]))
    {
        mexErrMsgTxt("Class of data array must be uint8");
    }

    length = mxGetM(prhs[0]) * mxGetN(prhs[0]) * sizeof(mxChar) + 1;
    fname = mxCalloc(length, sizeof(*fname));
    mxGetString(prhs[0], fname, length);
    
    *fp = fopen(fname, "ab");
    if (*fp == NULL)
    {
        mexErrMsgTxt(strerror(errno));
    }

    *A = prhs[1];

    mxFree((void *) fname);
}

void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{
    FILE *fp;
    const mxArray *A;
    uint8_T *prA;
    uint8_T value;
    uint8_T count;
    uint8_T *buffer;
    size_t writeCount;
    unsigned int bufferIdx;
    int width;
    int height;
    int k;
    int p;
    bool runIsFinished;

    ValidateInput(nlhs, nrhs, prhs, &fp, &A);

    if (mxIsEmpty(A))
    {
        fclose(fp);
        return;
    }

    width = mxGetN(A);
    height = mxGetM(A);
    prA = (uint8_T *) mxGetData(A);

    buffer = mxCalloc(2*height, sizeof(*buffer));

    for (k = 0; k < width; k++)
    {
        bufferIdx = 0;
        p = 0;
        while (p < height)
        {
            /*
             * Form a run
             */
            count = 1;
            value = *prA++;
            p++;
            runIsFinished = false;
            while (! runIsFinished)
            {
                if ((p == height) || (count == 63) || (*prA != value))
                {
                    runIsFinished = true;
                }
                else
                {
                    p++;
                    prA++;
                    count++;
                }
            }

            /*
             * Add run info to the buffer
             */
            if ((count == 1) && (value <= 63))
            {
                buffer[bufferIdx++] = value;
            }
            else
            {
                buffer[bufferIdx++] = count | 0xC0;
                buffer[bufferIdx++] = value;
            }
        }

        /*
         * Write out the buffer 
         */
        writeCount = fwrite((void *) buffer, sizeof(*buffer), bufferIdx, fp);
        if (writeCount < bufferIdx)
        {
            fclose(fp);
            mxFree((void *) buffer);
            mexErrMsgTxt(strerror(errno));
        }
    }

    mxFree((void *) buffer);
    fclose(fp);
}
     

            
            


