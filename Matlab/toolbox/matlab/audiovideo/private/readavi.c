/* 
 * This MEX-file is an interface to the Microsoft AVIFILE routines to read 
 * compressed and uncompressed AVI files on Windows.  
 *
 * MOVIEDATA = readavi(FILENAME,INDEX) reads from the AVI file FILENAME.  If
 * INDEX is 0, all frames in the movie are read. Otherwise, only frame number
 * INDEX is read.  The MEX-file returns a MATLAB structure MOVIEDATA with 
 * fields cdata and colormap.  cdata contains frame data that must be rotated 
 * and reshaped.  colormap contains the colormap if the frame is an Indexed 
 * image.  colormap must also be massaged into the correct size.
 *
 *   Copyright 1984-2001 The MathWorks, Inc.
 *   $Revision: 1.1.6.2 $  $Date: 2004/03/05 18:11:20 $
 */

#include <windows.h>
#include <vfw.h>
#include "mex.h"

static char rcsid[] = "$Id: readavi.c,v 1.1.6.2 2004/03/05 18:11:20 batserve Exp $";

void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[])
{

    int	i,
        j,
        start,
        end,
        frameCount,
        formatSize,
        n,
        height,
        width,
        pad,
        paddedWidth;
    char *filename;
    int dims[2];
    int ColormapDims[2];
    char *fieldNames[2] = {"cdata","colormap"};
    double *index;
    PAVIFILE pfile;
    PAVISTREAM vidStream;
    HRESULT hr;
    PBITMAPINFO bi;
    LPBITMAPINFOHEADER lpbi = NULL;
    PGETFRAME pframe[1];
    mxArray *mxframe;
    mxArray *mxcolormap;
    uint16_T *bit16frame;
    uint8_T *frame;
    uint8_T *colormap;
#ifdef DEBUG
    HDRAWDIB	    ghdd[1];	/* drawdib handles */
    RECT        rcFrame;
    HDC hdc;
#endif

    /* Input argument checking */
    if(!mxIsChar(prhs[0]))
        {
            mexErrMsgTxt("First input to the READAVI MEX-file must be the filename.");
        }
    if(!mxIsNumeric(prhs[1]))
        {
            mexErrMsgTxt("Second input to the READAVI MEX-file must be an index number.");
        }
	
    filename = mxArrayToString(prhs[0]);
    index = mxGetPr(prhs[1]);
    n = mxGetNumberOfElements(prhs[1]);
	
    AVIFileInit();
    hr = AVIFileOpen(&pfile,filename, OF_READ, NULL);
    if(hr != AVIERR_OK)
        {
            mexErrMsgTxt("Unable to open file.");
        }
    mxFree(filename);

    hr = AVIFileGetStream(pfile, &vidStream, streamtypeVIDEO, 0);
    if(hr == AVIERR_NODATA)
        {
            AVIFileRelease(pfile);
            mexErrMsgTxt("Unable to locate a video stream.");
        }
    else if (hr == AVIERR_MEMORY)
        {
            AVIFileRelease(pfile);
            mexErrMsgTxt("Out of memory error when opening the video stream."); 
        }

    hr = AVIStreamFormatSize(vidStream, 0, &formatSize);
    if(hr != AVIERR_OK)
        {
            AVIStreamRelease(vidStream);
            AVIFileRelease(pfile);
            mexErrMsgTxt("Unable to read stream format.");
        }

    bi = (PBITMAPINFO) mxMalloc(formatSize);

    hr = AVIStreamReadFormat(vidStream, 0, bi, &formatSize);

    if(hr != AVIERR_OK)
        {
            AVIStreamRelease(vidStream);
            AVIFileRelease(pfile);
            mexErrMsgTxt("Unable to read stream format.");
        }
	
    bi->bmiHeader.biCompression = mmioFOURCC('N','o','n','e'); 
    
    start = AVIStreamStart(vidStream);
    if (start == -1)
        {
            AVIStreamRelease(vidStream);
            AVIFileRelease(pfile);
            mexErrMsgTxt("Unable to locate starting point of video stream.");
        }

    end = AVIStreamEnd(vidStream);
    if (end == -1)
        {
            AVIStreamRelease(vidStream);
            AVIFileRelease(pfile);
            mexErrMsgTxt("Unable to locate ending point of video stream.");
        }
    
    if(index[0] == -1)
        {
            plhs[0] = mxCreateStructMatrix(1,end-start,2,fieldNames);
        }
    else
        {
            plhs[0] = mxCreateStructMatrix(1,n,2,fieldNames);
        }


    dims[0] = 1;
		
    pframe[0] = AVIStreamGetFrameOpen(vidStream, NULL);
    if (pframe[0] == NULL)
        {
            AVIStreamRelease(vidStream);
            AVIFileRelease(pfile);            
            mexErrMsgTxt("Unable to locate decompressor to decompress video stream");
        }
    
    frameCount = 0;
    for(j=0;j<n;j++)
        {
            if( index[0] != -1 )
                {
                    start = (int) index[j];
                    end = (int) index[j]+1;
                }
            
            for(i=start; i<end; i++)
                {
                    lpbi = AVIStreamGetFrame(pframe[0],i);
                    
                    if(lpbi == NULL)
                        {
                            AVIStreamRelease(vidStream);
                            AVIFileRelease(pfile);
                            mexErrMsgTxt("Error getting frame data.");
                        }
		    
                    /*
                      A negative value for height means the bitmap is
                      stored top down.  Can't use negative number for
                      calculations.
                    */
                    height = lpbi->biHeight > 0 ? lpbi->biHeight : -lpbi->biHeight;
                    width  = lpbi->biWidth;

                    if( (lpbi->biBitCount!=24) &&
                        (lpbi->biBitCount!=8)  &&
                        ((lpbi->biBitCount!=16)) && (lpbi->biCompression!=3))
                        {
                            AVIStreamGetFrameClose(pframe[0]);
                            AVIStreamRelease(vidStream);
                            AVIFileRelease(pfile);
                            mexErrMsgTxt("Frames must be either 8-bit (Indexed or grayscale), 16-bit grayscale or 24-bit (TrueColor).");
                        }
                    
                    if( (lpbi->biBitCount == 8) ||
                        (lpbi->biBitCount == 16) )
                        {
                            pad = 4-(width%4);
                            paddedWidth= width + (pad==4 ? 0:pad);
                        }
                    else if( lpbi->biBitCount == 24 )
                        {
                            /*
                              The padding is added after the second and third
                              dimensions have been "squeezed".
                            */
                            pad = 4-(width*3)%4;
                            paddedWidth = width*3 + (pad==4 ? 0:pad);
                        }

                    dims[1] = paddedWidth*height;
                    
                    if(lpbi->biBitCount == 8 || lpbi->biBitCount == 24)
                        {
                            mxframe = mxCreateNumericArray(2,dims,mxUINT8_CLASS,mxREAL);
                            frame = mxGetData(mxframe);
                        }
                    else if(lpbi->biBitCount == 16)
                        {
                            mxframe = mxCreateNumericArray(2,dims,mxUINT16_CLASS,mxREAL);
                            bit16frame = mxGetData(mxframe);
                        }
                    
#ifdef DEBUG
                    rcFrame.left = 111;
                    rcFrame.top = 56;
                    rcFrame.right = 201;
                    rcFrame.bottom = 122;
                    hdc = GetDC(NULL);
                    ghdd[1] = DrawDibOpen();
                    DrawDibDraw(ghdd[1],hdc,
                                rcFrame.left, rcFrame.top,
                                rcFrame.right - rcFrame.left,
                                rcFrame.bottom - rcFrame.top,
                                lpbi, NULL,
                                0, 0, -1, -1,
                                0);
                    DrawDibClose(ghdd[i]);
#endif

                    if(lpbi->biBitCount == 8)
                        {
                            if(lpbi->biClrUsed!=0)
                                {
                                    ColormapDims[0] = 1;
                                    ColormapDims[1] = 4*lpbi->biClrUsed;
                                    mxcolormap = mxCreateNumericArray(2,
                                                                      ColormapDims,
                                                                      mxUINT8_CLASS,
                                                                      mxREAL);
                                    colormap = mxGetData(mxcolormap);
                                    memcpy(colormap,(uint8_T *)lpbi+lpbi->biSize,
                                           lpbi->biClrUsed*sizeof(RGBQUAD)*sizeof(unsigned char));
                                    mxSetField(plhs[0],frameCount,fieldNames[1],mxcolormap);
                                }
                            memcpy(frame,(uint8_T *)lpbi+lpbi->biSize+lpbi->biClrUsed*sizeof(RGBQUAD),paddedWidth*height*sizeof(unsigned char));
                        }
                    else if(lpbi->biBitCount == 16)
                        {
                            memcpy(bit16frame,(uint8_T *)lpbi + lpbi->biSize,
                                   paddedWidth*height*sizeof(uint16_T));
                        }
                    else if(lpbi->biBitCount == 24)
                        {
                            memcpy(frame,(uint8_T *)lpbi + lpbi->biSize,
                                   paddedWidth*height*sizeof(unsigned char));
                        }
                    mxSetField(plhs[0],frameCount,fieldNames[0],mxframe);
                    frameCount++;
                }
	}
    mxFree(bi);

    AVIStreamGetFrameClose(pframe[0]);
    AVIStreamRelease(vidStream);
    AVIFileRelease(pfile);
}














