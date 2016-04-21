/* Copyright 1984-2001 The MathWorks, Inc.  */

#include <stdio.h>
#include "png.h"
#include "pngutils.h"
#include "pngerrs.h"
#include "mex.h"

static char rcsid[] = "$Revision: 1.1.6.1 $";

#define NUM_INPUTS           (3)
#define FILENAME_IN          (prhs[1])
#define BACKGROUND_IN        (prhs[2])
#define DATA_OUT             (plhs[0])
#define MAP_OUT              (plhs[1])

#define ERRCHECK(fcn) {err_flag = fcn; if (err_flag != SUCCESS) goto CLEANUP;}

void ScaleImage(mxArray *array, int bit_depth)
{
    uint8_T *ptr;
    int k;
    int num_elements;

    mxAssert(mxGetClassID(array) == mxUINT8_CLASS, "");

    ptr = (uint8_T *) mxGetData(array);
    num_elements = mxGetNumberOfElements(array);
    for (k = 0; k < num_elements; k++)
        {
            ptr[k] = (uint8_T) ((double) ptr[k] * 255.0 / MAX_PIXEL_VALUE(bit_depth) + 0.5);
        }
}

static void ReadErrorHandler(png_structp png_ptr, png_const_charp message)
{
    MexInfoType *mexInfo = (MexInfoType *) (png_ptr->error_ptr);

    png_destroy_read_struct(&(mexInfo->png_ptr), &(mexInfo->info_ptr), NULL);
    DestroyMexInfo(mexInfo);
    mexErrMsgTxt(message);
}

void ReadPNG(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    png_uint_32 width;
    png_uint_32 height;
    png_uint_32 y;
    int bit_depth;
    int color_type;
    int interlace_type;
    ErrorFlag err_flag = SUCCESS;
    MexInfoType *mexInfo;
    double *pr;
    png_colorp palette;
    int num_palette = 0;
    int k;
    png_color_16 background;
    png_color_16p file_background;
    int bytesPerRow;
    int ndims;
    int size[3];
    png_bytep firstByte;
    bool bg_is_none = false;
    
    InitErrorMessages();
    mexInfo = InitMexInfo();
    
    if (nrhs < NUM_INPUTS)
        {
            mexErrMsgTxt("Too few inputs.");
        }
    else if (nrhs > NUM_INPUTS)
        {
            mexErrMsgTxt("Too many inputs.");
        }

    ERRCHECK(GetFilename(FILENAME_IN,&(mexInfo->filename)));

    mexInfo->fp = fopen(mexInfo->filename, "rb");
    if (mexInfo->fp == NULL)
        {
            err_flag = FILE_OPEN;
            goto CLEANUP;
        }

    mexInfo->png_ptr = png_create_read_struct(PNG_LIBPNG_VER_STRING, 
                                              mexInfo, 
                                              ReadErrorHandler, 
                                              WarningHandler);
    if (mexInfo->png_ptr == NULL)
        {
            err_flag = PNG_LIB_INIT;
            goto CLEANUP;
        }

    mexInfo->info_ptr = png_create_info_struct(mexInfo->png_ptr);
    if (mexInfo->info_ptr == NULL)
        {
            err_flag = PNG_LIB_INIT;
            goto CLEANUP;
        }

    png_init_io(mexInfo->png_ptr, mexInfo->fp);

    png_read_info(mexInfo->png_ptr, mexInfo->info_ptr);

    png_get_IHDR(mexInfo->png_ptr, mexInfo->info_ptr, &width, &height, 
                 &bit_depth, &color_type, &interlace_type, NULL, NULL);

    if ((bit_depth == 16) && (CheckByteOrder() == LSB_FIRST))
        {
            /*
             * PNG library returns 16-bit values as big-endian by default,
             * and we're on a little-endian machine.  Tell libpng to swap
             * bytes.
             */
            png_set_swap(mexInfo->png_ptr);
        }
    
    if (bit_depth < 8)
        {
            /*
             * Ask libpng to expand 1-, 2-, or 4-bit values into bytes.
             */
            png_set_packing(mexInfo->png_ptr);
        }
    
    if (!mxIsEmpty(BACKGROUND_IN))
        {
            ERRCHECK(GetBackgroundColor(BACKGROUND_IN, &background, color_type,
                                        bit_depth, &bg_is_none));
            if (! bg_is_none)
                {
                    png_set_background(mexInfo->png_ptr, &background,
                                       PNG_BACKGROUND_GAMMA_FILE, 0, 1.0);
                }
        }
    
    else if (png_get_valid(mexInfo->png_ptr, mexInfo->info_ptr, PNG_INFO_bKGD))
        {
            png_get_bKGD(mexInfo->png_ptr, mexInfo->info_ptr, &file_background);
            png_set_background(mexInfo->png_ptr, file_background,
                               PNG_BACKGROUND_GAMMA_FILE, 1, 1.0);
        }
    else if (! bg_is_none)
        {
            background.index = 0;
            background.gray = 0;
            background.red = 0;
            background.green = 0;
            background.blue = 0;
            png_set_background(mexInfo->png_ptr, &background,
                               PNG_BACKGROUND_GAMMA_FILE, 0, 1.0);
        }

    /*
     * This call is necessary before calling png_get_rowbytes and before
     * getting the palette.
     */
    png_read_update_info(mexInfo->png_ptr, mexInfo->info_ptr);
    bytesPerRow = png_get_rowbytes(mexInfo->png_ptr, mexInfo->info_ptr);
    
    if (nlhs > 1)
        {
            if (png_get_valid(mexInfo->png_ptr, mexInfo->info_ptr, PNG_INFO_PLTE))
                {
                    png_get_PLTE(mexInfo->png_ptr, mexInfo->info_ptr, &palette, 
                                 &num_palette);
                    MAP_OUT = mxCreateDoubleMatrix(num_palette, 3, mxREAL);
                    pr = mxGetPr(MAP_OUT);
                    for (k = 0; k < num_palette; k++)
                        {
                            pr[k] = (double) palette[k].red / 255.0;
                            pr[k + num_palette] = (double) palette[k].green / 255.0;
                            pr[k + 2*num_palette] = (double) palette[k].blue / 255.0;
                        }
                }
            else
                {
                    MAP_OUT = mxCreateDoubleMatrix(0, 0, mxREAL);
                }
        }
    
    /*
     * Allocate space for output array, dimensions = 3xWxH or WxH
     */
    switch (color_type)
        {
          case PNG_COLOR_TYPE_GRAY:
          case PNG_COLOR_TYPE_PALETTE:
            ndims = 2;
            size[0] = width;
            size[1] = height;
            break;

          case PNG_COLOR_TYPE_GRAY_ALPHA:
            if (bg_is_none)
                {
                    ndims = 3;
                    size[0] = 2;
                    size[1] = width;
                    size[2] = height;
                }
            else
                {
                    ndims = 2;
                    size[0] = width;
                    size[1] = height;
                }
            break;
        
          case PNG_COLOR_TYPE_RGB:
            ndims = 3;
            size[0] = 3;
            size[1] = width;
            size[2] = height;
            break;
        
          case PNG_COLOR_TYPE_RGB_ALPHA:
            if (bg_is_none)
                {
                    ndims = 3;
                    size[0] = 4;
                    size[1] = width;
                    size[2] = height;
                }
            else
                {
                    ndims = 3;
                    size[0] = 3;
                    size[1] = width;
                    size[2] = height;
                }
            break;
        }

    if (bit_depth == 16)
        {
            DATA_OUT = mxCreateNumericArray(ndims, size, mxUINT16_CLASS, mxREAL);
        }
    else if ((bit_depth != 1) || (color_type == PNG_COLOR_TYPE_PALETTE))
        {
            DATA_OUT = mxCreateNumericArray(ndims, size, mxUINT8_CLASS, mxREAL);
        }
    else
        {
	    DATA_OUT = mxCreateLogicalArray(ndims, size);
	}

    /*
     * Sanity check on the space required
     */
    mxAssert(mxGetElementSize(DATA_OUT) * mxGetNumberOfElements(DATA_OUT) ==
             (int) bytesPerRow * (int) height, "");

    /*
     * Allocate space for row pointers
     */
    mexInfo->rows = (png_bytep *) mxCalloc(height, sizeof(png_bytep));
    firstByte = (png_bytep) mxGetData(DATA_OUT);
    for (y = 0; y < height; y++)
        {
            mexInfo->rows[y] = firstByte + bytesPerRow * y;
        }

    /*
     * Read entire image
     */
    png_read_image(mexInfo->png_ptr, mexInfo->rows);

    png_read_end(mexInfo->png_ptr, mexInfo->info_ptr);

    if ((bit_depth == 1) && (color_type != PNG_COLOR_TYPE_PALETTE))
        {
	    /* It's logical, do nothing */
        }
    else if ((bit_depth < 8) && ((color_type == PNG_COLOR_TYPE_GRAY) ||
                                 (color_type == PNG_COLOR_TYPE_GRAY_ALPHA)))
        {
            ScaleImage(DATA_OUT, bit_depth);
        }
    

 CLEANUP:

    png_destroy_read_struct(&(mexInfo->png_ptr), &(mexInfo->info_ptr), NULL);
    DestroyMexInfo(mexInfo);
    if (err_flag != SUCCESS)
        {
            pngErrorReturn(err_flag);
        }
}
